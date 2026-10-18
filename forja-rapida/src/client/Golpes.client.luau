--!strict
-- Golpear geodas: clic o toque sobre una geoda (mantener apretado sigue pegando). El cliente
-- solo avisa "le pegué a esta"; el servidor decide si cuenta y cuánto daño hace.
-- Cuando el servidor confirma el golpe (Remotos.Golpe): número que salta y se desvanece,
-- destello blanco en la geoda, temblor cortito y cubitos que saltan (Grupo 1, pulido).

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Golpear = remotos:WaitForChild("Golpear") :: RemoteEvent
local Golpe = remotos:WaitForChild("Golpe") :: UnreliableRemoteEvent

-- Un poco por debajo del tope del servidor, así ningún golpe se pierde por apurado.
local INTERVALO = 1 / math.max(1, GameConfig.Golpe.PorSegundo - 1)
local rng = Random.new()

local ultimoGolpe = 0
local apretado = false
local ultimoPunto: { [Model]: Vector3 } = {} -- dónde se tocó cada geoda (para el número)
local numeros = 0

-- Busca la geoda debajo de un punto de la pantalla. Las posiciones de InputObject no cuentan la
-- barra de arriba de Roblox (ScreenPointToRay); GetMouseLocation sí (ViewportPointToRay).
local function geodaEn(posicion: Vector2, conBarra: boolean): (Model?, Vector3?)
	local camara = Workspace.CurrentCamera
	if not camara then
		return nil, nil
	end
	local rayo = if conBarra
		then camara:ViewportPointToRay(posicion.X, posicion.Y)
		else camara:ScreenPointToRay(posicion.X, posicion.Y)
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	filtro.FilterDescendantsInstances = if jugador.Character then { jugador.Character } else {}
	local r = Workspace:Raycast(rayo.Origin, rayo.Direction * 300, filtro)
	if not r then
		return nil, nil
	end
	local nodo: Instance? = r.Instance
	while nodo and nodo ~= Workspace do
		if nodo:IsA("Model") and CollectionService:HasTag(nodo, "Geoda") then
			return nodo, r.Position
		end
		nodo = nodo.Parent
	end
	return nil, nil
end

-- Animación del pico ------------------------------------------------------------------------
-- El brazo derecho sube por arriba de la cabeza y baja de golpe hacia adelante (se mueve el C0
-- del hombro; el Animator no lo pisa). Lo propio se anima al hacer clic; lo de los demás, cuando
-- el servidor marca el golpe en su pico (atributo "Golpe").

-- El hombro es un Motor6D (se mueve su C0) o, con las uniones nuevas de Roblox, un
-- AnimationConstraint (su C0 es de solo lectura: se mueve el Attachment0, que es lo mismo).
local basesHombro: { [Instance]: CFrame } = setmetatable({}, { __mode = "k" }) :: any
local turnoHombro: { [Instance]: number } = setmetatable({}, { __mode = "k" }) :: any

local function hombro(personaje: Model): any
	local brazo = personaje:FindFirstChild("RightUpperArm") or personaje:FindFirstChild("Torso")
	local m = brazo
		and (brazo:FindFirstChild("RightShoulder") or brazo:FindFirstChild("Right Shoulder"))
	if m and m:IsA("Motor6D") then
		return m
	elseif m and m:IsA("AnimationConstraint") and m.Attachment0 then
		return m.Attachment0
	end
	return nil
end

local function girarHombro(h: any, cf: CFrame)
	if h:IsA("Motor6D") then
		h.C0 = cf
	else
		h.CFrame = cf
	end
end

local function golpeDePico(personaje: Model)
	if not personaje:FindFirstChild("Pico") then
		return
	end
	local motor = hombro(personaje)
	if not motor then
		return
	end
	local base = basesHombro[motor] or (if motor:IsA("Motor6D") then motor.C0 else motor.CFrame)
	basesHombro[motor] = base
	local turno = (turnoHombro[motor] or 0) + 1
	turnoHombro[motor] = turno
	local duracion = GameConfig.Golpe.Animacion
	local arriba = math.rad(GameConfig.Golpe.BrazoArriba)
	local abajo = math.rad(GameConfig.Golpe.BrazoGolpe)
	local inicio = os.clock()
	local conexion: RBXScriptConnection
	conexion = RunService.Heartbeat:Connect(function()
		if turnoHombro[motor] ~= turno or not motor.Parent then
			conexion:Disconnect()
			return
		end
		local t = (os.clock() - inicio) / duracion
		local angulo
		if t < 0.35 then -- sube
			angulo = arriba
				* TweenService:GetValue(t / 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		elseif t < 0.6 then -- baja de golpe
			local f = TweenService:GetValue(
				(t - 0.35) / 0.25,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			)
			angulo = arriba + (abajo - arriba) * f
		elseif t < 1 then -- vuelve
			angulo = abajo
				* (
					1
					- TweenService:GetValue(
						(t - 0.6) / 0.4,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.Out
					)
				)
		else
			girarHombro(motor, base)
			conexion:Disconnect()
			return
		end
		girarHombro(motor, base * CFrame.Angles(angulo, 0, 0))
	end)
end

local function vigilarPicos(otro: Player)
	if otro == jugador then
		return
	end
	local function conPersonaje(personaje: Model)
		local function conHerramienta(h: Instance)
			if h:IsA("Tool") and h.Name == "Pico" then
				h:GetAttributeChangedSignal("Golpe"):Connect(function()
					if h.Parent == personaje then
						golpeDePico(personaje)
					end
				end)
			end
		end
		personaje.ChildAdded:Connect(conHerramienta)
		for _, h in personaje:GetChildren() do
			conHerramienta(h)
		end
	end
	if otro.Character then
		conPersonaje(otro.Character)
	end
	otro.CharacterAdded:Connect(conPersonaje)
end
for _, p in Players:GetPlayers() do
	vigilarPicos(p)
end
Players.PlayerAdded:Connect(vigilarPicos)

local function intentar(posicion: Vector2, conBarra: boolean)
	local ahora = os.clock()
	if ahora - ultimoGolpe < INTERVALO then
		return
	end
	local geoda, punto = geodaEn(posicion, conBarra)
	if not geoda or geoda:GetAttribute("Rota") == true then
		return
	end
	ultimoGolpe = ahora
	ultimoPunto[geoda] = punto :: Vector3
	Golpear:FireServer(geoda)
	if jugador.Character then
		golpeDePico(jugador.Character)
	end
end

UserInputService.InputBegan:Connect(function(entrada: InputObject, usadoPorUI: boolean)
	if usadoPorUI then
		return
	end
	local tipo = entrada.UserInputType
	if tipo == Enum.UserInputType.MouseButton1 or tipo == Enum.UserInputType.Touch then
		apretado = true
		intentar(Vector2.new(entrada.Position.X, entrada.Position.Y), false)
		-- mantener apretado sigue pegando a lo que esté debajo del dedo o del mouse
		task.spawn(function()
			while apretado do
				task.wait(INTERVALO)
				if apretado then
					if tipo == Enum.UserInputType.Touch then
						intentar(Vector2.new(entrada.Position.X, entrada.Position.Y), false)
					else
						intentar(UserInputService:GetMouseLocation(), true)
					end
				end
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(entrada: InputObject)
	local tipo = entrada.UserInputType
	if tipo == Enum.UserInputType.MouseButton1 or tipo == Enum.UserInputType.Touch then
		apretado = false
	end
end)

-- Efectos del golpe ---------------------------------------------------------------------------

local destello = Instance.new("Highlight")
destello.FillColor = Color3.new(1, 1, 1)
destello.OutlineTransparency = 1
destello.FillTransparency = 1
destello.DepthMode = Enum.HighlightDepthMode.Occluded
destello.Parent = Workspace

local function numeroFlotante(roca: BasePart, punto: Vector3, danio: number, grande: boolean)
	if numeros >= GameConfig.Efectos.NumerosMaximos then
		return
	end
	numeros += 1
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = punto
		+ Vector3.new(rng:NextNumber(-0.6, 0.6), 0.3, rng:NextNumber(-0.6, 0.6))
	ancla.Parent = roca
	local b = Instance.new("BillboardGui")
	b.Adornee = ancla
	b.Size = UDim2.fromOffset(160, 60)
	b.AlwaysOnTop = true
	b.LightInfluence = 0
	b.Parent = ancla
	local t = Estilo.texto(
		"-" .. Formato.corto(danio),
		if grande then 44 else 34,
		if grande then Color3.fromHex("#FFE14D") else nil
	)
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromScale(0.5, 0.5)
	t.Parent = b
	local escala = Instance.new("UIScale")
	escala.Scale = 1.7
	escala.Parent = t
	-- salta, se achica a su tamaño y sube desvaneciéndose
	TweenService:Create(
		escala,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	TweenService:Create(b, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = Vector3.new(0, 3, 0),
	}):Play()
	local trazo = t:FindFirstChildOfClass("UIStroke")
	task.delay(0.35, function()
		TweenService:Create(t, TweenInfo.new(0.45), { TextTransparency = 1 }):Play()
		if trazo then
			TweenService:Create(trazo, TweenInfo.new(0.45), { Transparency = 1 }):Play()
		end
	end)
	task.delay(0.85, function()
		numeros -= 1
		ancla:Destroy()
	end)
end

local function temblor(geoda: Model)
	local original = geoda:GetPivot()
	geoda:PivotTo(
		original * CFrame.new(rng:NextNumber(-0.12, 0.12), 0, rng:NextNumber(-0.12, 0.12))
	)
	task.delay(0.05, function()
		if geoda.Parent then
			geoda:PivotTo(original)
		end
	end)
end

local function cubitos(roca: BasePart, punto: Vector3, cantidad: number)
	for _ = 1, cantidad do
		local p = Instance.new("Part")
		p.Size = Vector3.one * rng:NextNumber(0.2, 0.4)
		p.Color = roca.Color
		p.Material = roca.Material
		p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
		p.CFrame = CFrame.new(punto)
		p.AssemblyLinearVelocity =
			Vector3.new(rng:NextNumber(-8, 8), rng:NextNumber(8, 16), rng:NextNumber(-8, 8))
		p.Parent = Workspace
		Debris:AddItem(p, 0.6)
	end
end

Golpe.OnClientEvent:Connect(function(geoda: Model, danio: number, _vida: number)
	if typeof(geoda) ~= "Instance" or not geoda:IsA("Model") then
		return
	end
	local roca = geoda:FindFirstChild("Roca", true)
	if not roca or not roca:IsA("BasePart") then
		return
	end
	local punto = ultimoPunto[geoda] or roca.Position
	local maxima = tonumber(geoda:GetAttribute("VidaMax")) or 1
	local reducidos = Efectos.reducidos()
	numeroFlotante(roca, punto, danio, danio >= maxima * 0.5)
	-- SONIDO: golpe del pico (cambia un poco el tono en cada golpe)
	Sonidos.tocar(GameConfig.Sonidos.Golpe, 0.9 + rng:NextNumber() * 0.25, 0.5, roca)
	destello.Adornee = geoda
	destello.FillTransparency = 0.45
	TweenService:Create(destello, TweenInfo.new(0.15), { FillTransparency = 1 }):Play()
	if not reducidos then
		temblor(geoda)
		cubitos(roca, punto, 4)
	end
end)
