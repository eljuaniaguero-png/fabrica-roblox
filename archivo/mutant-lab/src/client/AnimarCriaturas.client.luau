--!strict
-- Anima en el cliente todas las criaturas (modelos con la etiqueta "Criatura"). Las de un
-- mismo corral se ven entre sí (para la vida de cada personalidad, shared/Animacion.luau).
-- Tocar una criatura (mouse o dedo) la hace saltar, sonar y mostrar un cartelito con su nombre
-- y su personalidad.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Animacion = require(ReplicatedStorage.Shared.Animacion)
local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Sonidos = require(script.Parent.Sonidos)

local V = Config.Animacion.Vida
local FUENTE = Font.fromEnum(Enum.Font.FredokaOne)

local jugador = Players.LocalPlayer
local estados: { [Model]: Animacion.Estado } = {}
local paseantes: { [Model]: boolean } = {} -- las criaturas de paseo (siguen a su dueño)

local function agregar(inst: Instance)
	if not inst:IsA("Model") or not inst:IsDescendantOf(workspace) then
		return
	end
	-- Las criaturas que crea el servidor pueden avisar que llegaron antes que sus piezas:
	-- sin la raíz, el pivote da el centro del mapa. Se espera a la raíz y un ratito más
	-- para que lleguen las demás piezas (las usan los rasgos y los mutantes).
	if not inst.PrimaryPart then
		local inicio = os.clock()
		repeat
			task.wait()
		until inst.PrimaryPart or not inst.Parent or os.clock() - inicio > 5
		if not inst.PrimaryPart or not inst.Parent then
			return
		end
		task.wait(0.1)
	end
	estados[inst] = Animacion.preparar(inst)
	if inst:GetAttribute("Paseo") then
		paseantes[inst] = true
	end
end

CollectionService:GetInstanceAddedSignal("Criatura"):Connect(function(inst)
	task.spawn(agregar, inst)
end)
CollectionService:GetInstanceRemovedSignal("Criatura"):Connect(function(inst)
	estados[inst :: Model] = nil
	paseantes[inst :: Model] = nil
end)
for _, inst in CollectionService:GetTagged("Criatura") do
	task.spawn(agregar, inst)
end

---------------------------------------------------------------------------
-- Tocar una criatura
---------------------------------------------------------------------------

-- Una nota por especie base (do re mi... de la rueda); las de más generación, más graves.
local NOTAS = { 0, 2, 4, 5, 7, 9, 11, 12, 14, 16 }

local function cartelito(modelo: Model)
	local raiz = modelo.PrimaryPart
	if not raiz then
		return
	end
	local viejo = raiz:FindFirstChild("Cartelito")
	if viejo then
		viejo:Destroy()
	end
	local personalidad =
		Personalidades.Datos[(modelo:GetAttribute("Personalidad") :: string?) or ""]
	local gui = Instance.new("BillboardGui")
	gui.Name = "Cartelito"
	gui.Size = UDim2.fromScale(8, 2.4)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Paleta.Superficie
	fondo.BackgroundTransparency = 0.05
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0.3, 0)
	esquina.Parent = fondo
	local borde = Instance.new("UIStroke")
	borde.Color = if personalidad
		then (if personalidad.Positiva then Paleta.Acento else Paleta.Alerta)
		else Paleta.Contorno
	borde.Thickness = 3
	borde.Parent = fondo
	local function renglon(texto: string, y: number, alto: number, color: Color3)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Position = UDim2.fromScale(0.05, y)
		t.Size = UDim2.fromScale(0.9, alto)
		t.FontFace = FUENTE
		t.TextScaled = true
		t.Text = texto
		t.TextColor3 = color
		t.Parent = fondo
	end
	renglon(modelo.Name, 0.08, 0.5, Paleta.Texto)
	if personalidad then
		renglon(
			personalidad.Nombre
				.. ": "
				.. personalidad.Efecto:sub(1, 1):lower()
				.. personalidad.Efecto:sub(2),
			0.58,
			0.34,
			borde.Color
		)
	end
	fondo.Parent = gui
	gui.Parent = raiz
	task.delay(V.CartelToque, function()
		gui:Destroy()
	end)
end

local function tocar(modelo: Model)
	local estado = estados[modelo]
	if not estado then
		return
	end
	Animacion.tocar(estado)
	cartelito(modelo)
	local c = Fusion.porClave((modelo:GetAttribute("Clave") :: string?) or "")
	if c then
		-- SONIDO: la voz de la criatura (una nota según su primera base; más grave si es de
		-- más generación). Para cambiarla por sonidos propios, ver Sonidos.luau.
		local nota = (NOTAS[c.Bases[1]] or 0) - (c.Gen - 1) * 5
		Sonidos.nota(nota, 0.45)
		task.delay(0.12, Sonidos.nota, nota + 7, 0.35)
	end
end

UserInputService.InputBegan:Connect(function(entrada: InputObject, procesado: boolean)
	if procesado then
		return
	end
	if
		entrada.UserInputType ~= Enum.UserInputType.MouseButton1
		and entrada.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end
	-- Las piezas de las criaturas no frenan rayos (CanQuery apagado, así no molestan a la
	-- cámara): se busca la criatura cuyo cuerpo, en pantalla, quedó debajo del dedo. Si hay
	-- varias, gana la que tiene el centro más cerca del dedo (medido según su tamaño).
	local camara = workspace.CurrentCamera
	local toque = Vector2.new(entrada.Position.X, entrada.Position.Y)
	local elegida: Model? = nil
	local mejor = 1
	for modelo in estados do
		local pie = modelo:GetPivot().Position
		local centro, visible = camara:WorldToScreenPoint(pie + Vector3.new(0, 2.5, 0))
		if visible and centro.Z < V.DistanciaToque then
			local arriba = camara:WorldToScreenPoint(pie + Vector3.new(0, 5, 0))
			local radio = math.max(
				24,
				(Vector2.new(arriba.X, arriba.Y) - Vector2.new(centro.X, centro.Y)).Magnitude
			)
			local cuanto = (Vector2.new(centro.X, centro.Y) - toque).Magnitude / radio
			if cuanto < mejor then
				elegida, mejor = modelo, cuanto
			end
		end
	end
	if elegida then
		tocar(elegida)
	end
end)

---------------------------------------------------------------------------
-- Criaturas de paseo (Parte 9): siguen a su dueño
---------------------------------------------------------------------------

local P = Config.Paseo
local rayos = RaycastParams.new()
rayos.FilterType = Enum.RaycastFilterType.Exclude

-- Lleva la criatura de paseo detrás de su dueño (un poco al costado), apoyada en el piso.
-- Si quedó muy lejos (el dueño apareció en otro lado), salta directo.
local function seguir(estado: Animacion.Estado, dt: number)
	local modelo = estado.Modelo
	local dueno = Players:GetPlayerByUserId((modelo:GetAttribute("Dueno") :: number?) or 0)
	local personaje = dueno and dueno.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not raiz or not raiz:IsA("BasePart") then
		return
	end
	local destino = raiz.CFrame * Vector3.new(P.Costado, 0, P.Detras)
	local actual = estado.Base.Position
	local hacia = Vector3.new(destino.X - actual.X, 0, destino.Z - actual.Z)
	local nueva = actual
	if hacia.Magnitude > P.Salto then
		nueva = Vector3.new(destino.X, actual.Y, destino.Z)
	elseif hacia.Magnitude > 0.2 then
		local velocidad = math.max(P.Velocidad, hacia.Magnitude * 3)
		nueva = actual + hacia.Unit * math.min(hacia.Magnitude, velocidad * dt)
	end
	-- Apoyada en el piso (sin chocar con los personajes).
	local ignorar = {}
	for _, j in Players:GetPlayers() do
		if j.Character then
			table.insert(ignorar, j.Character)
		end
	end
	rayos.FilterDescendantsInstances = ignorar
	local golpe = workspace:Raycast(nueva + Vector3.new(0, 6, 0), Vector3.new(0, -20, 0), rayos)
	nueva = Vector3.new(nueva.X, if golpe then golpe.Position.Y else raiz.Position.Y - 3, nueva.Z)
	-- Mira hacia donde camina; quieta, hacia donde mira su dueño.
	local mirar = if hacia.Magnitude > 0.5 then hacia else raiz.CFrame.LookVector
	mirar = Vector3.new(mirar.X, 0, mirar.Z)
	local giro = estado.Base.Rotation
	if mirar.Magnitude > 0.01 then
		giro = giro:Lerp(CFrame.lookAt(Vector3.zero, mirar).Rotation, math.min(1, dt * 6))
	end
	estado.Base = CFrame.new(nueva) * giro
end

---------------------------------------------------------------------------
-- Cada cuadro
---------------------------------------------------------------------------

local DISTANCIA = Config.Animacion.DistanciaAnimar

RunService.RenderStepped:Connect(function(dt: number)
	local reloj = os.clock()
	local camara = workspace.CurrentCamera.CFrame.Position
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	local posJugador = if raiz and raiz:IsA("BasePart") then raiz.Position else nil
	-- Las criaturas de cada corral (su carpeta), para que se vean entre sí.
	local grupos: { [Instance]: Animacion.Alrededor } = {}
	for modelo, estado in estados do
		local carpeta = modelo.Parent
		if carpeta and estado.Paseo then
			local g = grupos[carpeta]
			if not g then
				g = { Vecinas = {}, Jugador = posJugador }
				grupos[carpeta] = g
			end
			table.insert(g.Vecinas, estado)
		end
	end
	for modelo, estado in estados do
		if modelo.Parent then
			if paseantes[modelo] then
				seguir(estado, dt)
			end
			-- Las lejanas no se animan (rendimiento en celular); siguen donde quedaron.
			if (estado.Base.Position - camara).Magnitude < DISTANCIA then
				Animacion.paso(estado, reloj, dt, grupos[modelo.Parent :: Instance])
			end
		else
			estados[modelo] = nil
			paseantes[modelo] = nil
		end
	end
end)
