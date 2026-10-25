--!strict
-- Golpear geodas: clic o toque sobre una geoda (mantener apretado sigue pegando). El cliente
-- solo avisa "le pegué a esta"; el servidor decide si cuenta y cuánto daño hace.
-- Cuando el servidor confirma el golpe (Remotos.Golpe): número que salta y se desvanece,
-- destello blanco, chispas y cubitos del color de la zona (más grandes en el golpe fuerte del
-- pico). El aplastón y las grietas por vida los hace Geodas.client (los ven todos).

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
-- Tres tiempos: el brazo derecho se levanta hacia atrás, baja con fuerza y rebota al pegar; el
-- torso acompaña un poco. Cada GolpeFuerteCada golpes seguidos sale uno fuerte (más alto, más
-- rebote y un "¡CRACK!" grave). Si el pico toca la geoda al bajar, se frena ahí (no la
-- atraviesa). Al caminar con el pico, el brazo se balancea suave. Se anima lo propio al
-- hacer clic y lo de los demás cuando el servidor marca el golpe en su pico (atributo "Golpe"). Anda igual con todos los picos.

-- Una unión es un Motor6D o, con las uniones nuevas de Roblox, un AnimationConstraint. Los dos
-- tienen Transform, que es lo que escribe el Animator (la pose de sostener la herramienta, el
-- caminar). Se le suma el giro propio en PreSimulation, después del Animator y antes de la
-- física. (Mover el C0 o el Attachment0 no sirve con AnimationConstraint: el brazo no se mueve.)
local function union(personaje: Model, partes: { string }, nombres: { string }): any
	for _, nombreParte in partes do
		local parte = personaje:FindFirstChild(nombreParte)
		for _, nombre in nombres do
			local m = parte and parte:FindFirstChild(nombre)
			if m and (m:IsA("Motor6D") or m:IsA("AnimationConstraint")) then
				return m
			end
		end
	end
	return nil
end

-- Giro pedido por unión, y lo último que se escribió: si el Animator no tocó esa unión en este
-- cuadro (el Transform sigue igual), se parte de la base anterior para no acumular el giro.
-- Tablas normales (no débiles): Roblox puede soltar la referencia de Lua a una Instance viva.
-- Se limpian a mano en el Heartbeat cuando la unión ya no está en el mundo.
local giros: { [Instance]: number } = {}
local escritos: { [Instance]: { base: CFrame, puesto: CFrame } } = {}

local function poner(u: any, grados: number)
	giros[u] = grados
end

local function soltar(u: any)
	giros[u] = nil
	local e = escritos[u]
	if e and u.Transform == e.puesto then
		u.Transform = e.base
	end
	escritos[u] = nil
end

RunService.PreSimulation:Connect(function()
	for u, grados in giros do
		local actual: CFrame = u.Transform
		local e = escritos[u]
		local base = if e and actual == e.puesto then e.base else actual
		local puesto = base * CFrame.Angles(math.rad(grados), 0, 0)
		u.Transform = puesto
		escritos[u] = { base = base, puesto = puesto }
	end
end)

type Golpe = {
	inicio: number,
	desde: number, -- ángulo del brazo al empezar (puede venir de otro golpe a medias)
	fuerte: boolean,
	contacto: number?, -- segundos desde el inicio en que pegó
	impacto: number, -- ángulo en que pegó
	angulo: number, -- último ángulo puesto
	torsoDesde: number, -- inclinación del torso al empezar
	torso: number, -- última inclinación puesta
	tocaba: boolean?, -- el pico ya estaba metido en la geoda en el cuadro anterior
}
local golpes: { [Model]: Golpe } = {}
local combos: { [Model]: { n: number, ultimo: number } } = {}
local animados: { [Model]: boolean } = {}

local G = GameConfig.Golpe
local function suave(t: number, estilo: Enum.EasingStyle, dir: Enum.EasingDirection): number
	return TweenService:GetValue(math.clamp(t, 0, 1), estilo, dir)
end

local function golpeDePico(personaje: Model)
	if not personaje:FindFirstChild("Pico") then
		return
	end
	local ahora = os.clock()
	local actual = golpes[personaje]
	-- mantener apretado: no corta un golpe que todavía no pegó ni su rebote (los golpes
	-- igual cuentan; solo la animación va a su ritmo)
	if actual then
		local contacto = actual.contacto
		if not contacto or ahora - actual.inicio - contacto < G.Rebote then
			return
		end
	end
	local combo = combos[personaje] or { n = 0, ultimo = 0 }
	combos[personaje] = combo
	combo.n = if ahora - combo.ultimo <= G.PausaCombo then combo.n + 1 else 1
	combo.ultimo = ahora
	local desde = if actual then actual.angulo else 0
	golpes[personaje] = {
		inicio = ahora,
		desde = desde,
		fuerte = combo.n % G.GolpeFuerteCada == 0,
		contacto = nil,
		impacto = G.BrazoGolpe,
		angulo = desde,
		torsoDesde = if actual then actual.torso else 0,
		torso = if actual then actual.torso else 0,
	}
end

-- ¿Alguna parte del pico está metida en una geoda?
local filtroGeodas = OverlapParams.new()
filtroGeodas.FilterType = Enum.RaycastFilterType.Include
local function picoTocaGeoda(pico: Instance): boolean
	filtroGeodas.FilterDescendantsInstances = CollectionService:GetTagged("Geoda")
	for _, p in pico:GetDescendants() do
		if p:IsA("BasePart") and #Workspace:GetPartsInPart(p, filtroGeodas) > 0 then
			return true
		end
	end
	return false
end

-- Sacudón corto del golpe fuerte: la cámara cae de golpe y vuelve (Quad Out), así el impacto
-- "pesa". Va después de la cámara de Roblox, como el temblor de Revelacion.
local function sacudonCamara()
	if Efectos.reducidos() then
		return
	end
	local inicio = os.clock()
	local nombre = "SacudonCrack"
	RunService:UnbindFromRenderStep(nombre) -- si venía otro a medias, lo reemplaza
	RunService:BindToRenderStep(nombre, Enum.RenderPriority.Camera.Value + 1, function()
		local camara = Workspace.CurrentCamera
		local t = (os.clock() - inicio) / G.FuerteCamaraDura
		if not camara or t >= 1 then
			RunService:UnbindFromRenderStep(nombre)
			return
		end
		local f = (1 - suave(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)) * G.FuerteCamara
		camara.CFrame *= CFrame.new(rng:NextNumber(-0.3, 0.3) * f, -f, 0)
	end)
end

local function crack(personaje: Model, pico: Instance)
	local cabeza = pico:FindFirstChild("Handle") or pico:FindFirstChildWhichIsA("BasePart", true)
	-- SONIDO: golpe fuerte (el mismo del pico, más grave)
	Sonidos.tocar(GameConfig.Sonidos.Golpe, G.FuerteTono, 0.9, cabeza)
	if personaje ~= jugador.Character or not cabeza or not cabeza:IsA("BasePart") then
		return
	end
	sacudonCamara()
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = cabeza.Position + Vector3.new(0, 2, 0)
	ancla.Parent = Workspace.Terrain
	local b = Instance.new("BillboardGui")
	b.Adornee = ancla
	b.Size = UDim2.fromOffset(200, 70)
	b.AlwaysOnTop = true
	b.LightInfluence = 0
	b.Parent = ancla
	local t = Estilo.texto("¡CRACK!", 40, Color3.fromHex("#FF8A3D"))
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromScale(0.5, 0.5)
	t.Rotation = rng:NextNumber(-10, 10)
	t.Parent = b
	local escala = Instance.new("UIScale")
	escala.Scale = 1.8
	escala.Parent = t
	TweenService:Create(
		escala,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	task.delay(0.3, function()
		TweenService:Create(t, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		local trazo = t:FindFirstChildOfClass("UIStroke")
		if trazo then
			TweenService:Create(trazo, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		end
	end)
	Debris:AddItem(ancla, 0.7)
end

-- Ángulos (brazo, torso) del golpe en curso; brazo nil cuando terminó.
local function poseGolpe(personaje: Model, g: Golpe, pico: Instance): (number?, number)
	local t = os.clock() - g.inicio
	local arriba = if g.fuerte then G.FuerteArriba else G.BrazoArriba
	local torso = if g.fuerte then G.FuerteTorso else G.Torso
	local rebote = if g.fuerte then G.FuerteRebote else G.ReboteGrados
	if t < G.Levanta then -- se levanta hacia atrás (el torso se echa un poco atrás)
		local f = suave(t / G.Levanta, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		return g.desde + (arriba - g.desde) * f, g.torsoDesde + (-torso * 0.4 - g.torsoDesde) * f
	end
	if not g.contacto then -- baja con fuerza
		local f = suave((t - G.Levanta) / G.Baja, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local angulo = arriba + (G.BrazoGolpe - arriba) * f
		local pego = t >= G.Levanta + G.Baja
		-- Se frena justo cuando el pico entra en la geoda (no la atraviesa). Si ya estaba
		-- adentro desde arriba (el jugador pegado a la roca), no hay dónde frenar: baja entero.
		local toca = picoTocaGeoda(pico)
		if toca and g.tocaba == false then
			angulo = g.angulo
			pego = true
		end
		g.tocaba = toca
		if not pego then
			return angulo, -torso * 0.4 + torso * 1.4 * f
		end
		g.contacto = t
		g.impacto = angulo
		if g.fuerte then
			crack(personaje, pico)
		end
	end
	local desde = t - (g.contacto :: number)
	if desde < G.Rebote then -- rebota apenas
		return g.impacto + rebote * math.sin(desde / G.Rebote * math.pi), torso
	end
	desde -= G.Rebote
	if desde < G.Vuelve then -- vuelve al reposo
		local f = suave(desde / G.Vuelve, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		return g.impacto * (1 - f), torso * (1 - f)
	end
	return nil, 0
end

local function animar(personaje: Model)
	local brazo = union(
		personaje,
		{ "RightUpperArm", "Torso" },
		{ "RightShoulder", "Right Shoulder" }
	)
	local cintura = union(personaje, { "UpperTorso" }, { "Waist" })
	local pico = personaje:FindFirstChild("Pico")
	if not pico or not pico:IsA("Tool") then
		if animados[personaje] then
			animados[personaje] = nil
			golpes[personaje] = nil
			if brazo then
				soltar(brazo)
			end
			if cintura then
				soltar(cintura)
			end
		end
		return
	end
	animados[personaje] = true
	local angulo, torso = 0, 0
	local g = golpes[personaje]
	if g then
		local a, b = poseGolpe(personaje, g, pico)
		if a then
			g.angulo, g.torso = a, b
			angulo, torso = a, b
		else
			golpes[personaje] = nil
		end
	end
	if not golpes[personaje] then -- caminando: balanceo suave en la mano
		local raiz = personaje:FindFirstChild("HumanoidRootPart")
		if raiz and raiz:IsA("BasePart") then
			local v = raiz.AssemblyLinearVelocity
			local rapidez = math.min(Vector3.new(v.X, 0, v.Z).Magnitude / 16, 1)
			angulo = G.Balanceo * rapidez * math.sin(os.clock() * G.BalanceoVelocidad * math.pi * 2)
		end
	end
	if brazo then
		poner(brazo, angulo)
	end
	if cintura then
		poner(cintura, -torso) -- negativo = hacia adelante
	end
end

RunService.Heartbeat:Connect(function()
	for personaje in animados do
		if not personaje.Parent then
			animados[personaje], golpes[personaje], combos[personaje] = nil, nil, nil
		end
	end
	for u in escritos do
		if not u:IsDescendantOf(Workspace) then
			giros[u], escritos[u] = nil, nil
		end
	end
	for _, p in Players:GetPlayers() do
		if p.Character then
			animar(p.Character)
		end
	end
end)

-- Picos que ya se escuchan: al guardar y volver a sacar el pico, ChildAdded salta de nuevo con
-- la misma herramienta y sin esto se sumaba otra conexión cada vez. Claves débiles: si el pico
-- se va sin que llegue Destroying al cliente (personaje viejo al reaparecer), no queda colgado.
local picosVigilados: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function vigilarPicos(otro: Player)
	if otro == jugador then
		return
	end
	local function conPersonaje(personaje: Model)
		local function conHerramienta(h: Instance)
			if h:IsA("Tool") and h.Name == "Pico" and not picosVigilados[h] then
				picosVigilados[h] = true
				h.Destroying:Once(function()
					picosVigilados[h] = nil
				end)
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
	-- el punto tocado sirve para el punto débil (el servidor lo revisa)
	Golpear:FireServer(geoda, punto)
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

local function numeroFlotante(
	roca: BasePart,
	punto: Vector3,
	danio: number,
	grande: boolean,
	fuerte: boolean
)
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
		if grande or fuerte then 44 else 34,
		if grande or fuerte then Color3.fromHex("#FFE14D") else nil
	)
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromScale(0.5, 0.5)
	t.Parent = b
	local escala = Instance.new("UIScale")
	escala.Scale = 1.7
	escala.Parent = t
	-- salta con un rebote, se achica a su tamaño y sube desvaneciéndose
	TweenService:Create(
		escala,
		TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	TweenService:Create(b, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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

-- Chispas: un solo emisor que se mueve al punto del golpe y suelta una tanda.
local ancla = Instance.new("Attachment")
ancla.Parent = Workspace.Terrain
local chispas = Instance.new("ParticleEmitter")
chispas.Enabled = false
chispas.LightEmission = 1
chispas.Lifetime = NumberRange.new(0.2, 0.4)
chispas.Speed = NumberRange.new(12, 22)
chispas.SpreadAngle = Vector2.new(70, 70)
chispas.Acceleration = Vector3.new(0, -40, 0)
chispas.Drag = 3
chispas.Texture = "rbxasset://textures/particles/sparkles_main.dds"
chispas.Parent = ancla

local function colorZona(geoda: Model): Color3
	local lista = GameConfig.Efectos.ColorZona
	local zona = math.max(1, tonumber(geoda:GetAttribute("Zona")) or 1)
	return Color3.fromHex(lista[(zona - 1) % #lista + 1])
end

local function tirarChispas(punto: Vector3, color: Color3, cantidad: number, grandes: boolean)
	ancla.WorldPosition = punto
	chispas.Color = ColorSequence.new(color)
	local t = if grandes then 0.7 else 0.4
	chispas.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, t),
		NumberSequenceKeypoint.new(1, 0),
	})
	chispas:Emit(cantidad)
end

local function cubitos(
	roca: BasePart,
	punto: Vector3,
	cantidad: number,
	color: Color3,
	grandes: boolean
)
	for _ = 1, cantidad do
		local p = Instance.new("Part")
		p.Size = Vector3.one
			* (if grandes then rng:NextNumber(0.35, 0.6) else rng:NextNumber(0.2, 0.4))
		p.Color = if rng:NextNumber() < 0.5 then color else roca.Color
		p.Material = roca.Material
		p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
		p.CFrame = CFrame.new(punto)
		p.AssemblyLinearVelocity =
			Vector3.new(rng:NextNumber(-8, 8), rng:NextNumber(8, 16), rng:NextNumber(-8, 8))
		p.Parent = Workspace
		Debris:AddItem(p, 0.6)
	end
end

Golpe.OnClientEvent:Connect(function(geoda: Model, danio: number, _vida: number, debil: boolean?)
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
	-- ¿este golpe es el fuerte del pico? (el que está bajando o acaba de pegar)
	local personaje = jugador.Character
	local g = personaje and golpes[personaje]
	local fuerte = (g ~= nil and g.fuerte and os.clock() - g.inicio < 0.6) or debil == true
	numeroFlotante(roca, punto, danio, danio >= maxima * 0.5 or debil == true, fuerte)
	if debil then
		-- SONIDO: golpe en el punto débil (más agudo)
		Sonidos.tocar(GameConfig.Sonidos.Golpe, 1.5, 0.8, roca)
	end
	-- Dash minero: el primer golpe después del dash hace un "clank" más fuerte (solo se siente)
	local dash = tonumber(jugador:GetAttribute("UltimoDash"))
	if dash and os.clock() - dash < GameConfig.Dash.VentanaClank then
		jugador:SetAttribute("UltimoDash", nil)
		-- SONIDO: clank fuerte del primer golpe después del dash
		Sonidos.tocar(GameConfig.Sonidos.Golpe, 0.7, 1, roca)
	end
	-- SONIDO: golpe del pico (cambia un poco el tono en cada golpe)
	Sonidos.tocar(GameConfig.Sonidos.Golpe, 0.9 + rng:NextNumber() * 0.25, 0.5, roca)
	destello.Adornee = geoda
	destello.FillTransparency = 0.45
	TweenService:Create(destello, TweenInfo.new(0.15), { FillTransparency = 1 }):Play()
	local E = GameConfig.Efectos
	local color = colorZona(geoda)
	if reducidos then
		tirarChispas(punto, color, math.ceil(E.Chispas / 2), false)
	else
		tirarChispas(punto, color, if fuerte then E.ChispasFuerte else E.Chispas, fuerte)
		cubitos(roca, punto, if fuerte then E.CubitosFuerte else E.Cubitos, color, fuerte)
	end
end)
