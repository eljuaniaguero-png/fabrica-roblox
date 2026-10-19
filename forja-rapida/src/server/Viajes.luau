--!strict
-- Mojones de viaje (idea elegida del 19/10/2026: "Teletransporte por bioma").
--   Lobby   una fila de mojones, uno por zona. Si la zona está abierta para vos, te lleva al
--           inicio de esa zona; si no, te dice cuánta Fuerza te falta.
--   Zonas   al inicio de cada zona, un mojón "Volver al Lobby".
-- Así no hace falta caminar 2 minutos para farmear en el Volcán o el Abismo.
-- El destino sale de las puertas del mapa (tag "PuertaZona", atributo Zona): un poco después de
-- cada puerta. La altura se busca con un rayo hacia abajo. Todo lo valida el servidor: zona
-- abierta, distancia al mojón y espera entre viajes.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local V = GameConfig.Viajes
local Viajes = {}

local ultimoViaje: { [Player]: number } = {}

-- Piso debajo de un punto (ignora personajes y geodas).
-- El rayo arranca a la altura `desde` (no desde el cielo, para no caer arriba de un cartel).
local function piso(x: number, z: number, desde: number): Vector3
	local params = RaycastParams.new()
	local ignorar: { Instance } = {}
	for _, p in Players:GetPlayers() do
		if p.Character then
			table.insert(ignorar, p.Character)
		end
	end
	for _, g in CollectionService:GetTagged("Geoda") do
		table.insert(ignorar, g)
	end
	params.FilterDescendantsInstances = ignorar
	params.FilterType = Enum.RaycastFilterType.Exclude
	local r = Workspace:Raycast(Vector3.new(x, desde, z), Vector3.new(0, -200, 0), params)
	return if r then r.Position else Vector3.new(x, 5, z)
end

-- Inicio de cada zona: Z y altura desde donde buscar el piso (la de su puerta).
local function iniciosDeZona(): { [number]: Vector2 }
	local inicios: { [number]: Vector2 } = { [1] = Vector2.new(V.InicioZona1, 20) }
	for _, puerta in CollectionService:GetTagged("PuertaZona") do
		local zona = puerta:GetAttribute("Zona")
		if puerta:IsA("BasePart") and typeof(zona) == "number" then
			inicios[zona] = Vector2.new(puerta.Position.Z + V.Adelante, puerta.Position.Y)
		end
	end
	return inicios
end

local function mojon(nombre: string, pos: Vector3, color: Color3, carpeta: Instance): BasePart
	local base = Instance.new("Part")
	base.Name = nombre
	base.Size = Vector3.new(2.5, 5, 2.5)
	base.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
	base.Anchored = true
	base.Color = Color3.fromHex("#2E3358")
	base.Material = Enum.Material.SmoothPlastic
	base.Parent = carpeta
	local punta = Instance.new("Part")
	punta.Name = "Punta"
	punta.Shape = Enum.PartType.Ball
	punta.Size = Vector3.new(2.2, 2.2, 2.2)
	punta.CFrame = base.CFrame * CFrame.new(0, 3.4, 0)
	punta.Anchored = true
	punta.CanCollide = false
	punta.CanQuery = false
	punta.Color = color
	punta.Material = Enum.Material.Neon
	punta.Parent = base
	return base
end

local function cartel(parte: BasePart, texto: string)
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.fromOffset(160, 40)
	b.StudsOffset = Vector3.new(0, 6.2, 0)
	b.MaxDistance = 60
	b.Parent = parte
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Text = texto
	t.Parent = b
end

local function viajar(jugador: Player, parte: BasePart, destino: Vector3): boolean
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	if not raiz or not raiz:IsA("BasePart") then
		return false
	end
	if (raiz.Position - parte.Position).Magnitude > V.Distancia + 4 then
		return false
	end
	local ahora = os.clock()
	if ultimoViaje[jugador] and ahora - ultimoViaje[jugador] < V.Espera then
		return false
	end
	ultimoViaje[jugador] = ahora
	jugador.Character:PivotTo(CFrame.new(destino + Vector3.new(0, 4, 0)))
	return true
end

local function prompt(parte: BasePart, accion: string, objeto: string): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.ActionText = accion
	p.ObjectText = objeto
	p.HoldDuration = 0.3
	p.MaxActivationDistance = V.Distancia
	p.RequiresLineOfSight = false
	p.Parent = parte
	return p
end

function Viajes.iniciar()
	local mapa = Workspace:FindFirstChild("Mapa")
	if not mapa then
		warn("[Viajes] no hay Workspace.Mapa: no se arman los mojones")
		return
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Viajes"
	carpeta.Parent = mapa

	local spawn = mapa:FindFirstChild("Spawn", true)
	local lobby = if spawn and spawn:IsA("BasePart") then spawn.Position else Vector3.new(0, 1, -14)

	local inicios = iniciosDeZona()
	for n, z in GameConfig.Zonas do
		local inicio = inicios[n]
		if not inicio then
			continue
		end
		local inicioZ, alto = inicio.X, inicio.Y
		local color = Color3.fromHex(z.ColorCristal)
		local destino = piso(0, inicioZ, alto)

		-- En el Lobby: ir a la zona.
		local x = V.Lobby.X + (n - 1) * V.Lobby.Separacion
		local ida = mojon("Ir_" .. n, piso(x, V.Lobby.Z, lobby.Y + 10), color, carpeta)
		cartel(ida, z.Nombre)
		prompt(ida, "Viajar", z.Nombre).Triggered:Connect(function(jugador: Player)
			local d = Jugadores.obtener(jugador)
			if not d then
				return
			end
			if not d.Zonas[n] then
				local falta = z.FuerzaParaAbrir - Jugadores.fuerza(d)
				Remotos.Aviso:FireClient(
					jugador,
					("Te faltan %s de Fuerza para %s"):format(
						Formato.corto(math.max(1, falta)),
						z.Nombre
					)
				)
				return
			end
			viajar(jugador, ida, destino)
		end)

		-- En la zona: volver al Lobby.
		local vuelta = mojon(
			"Volver_" .. n,
			piso(0, inicioZ - V.Atras, alto),
			Color3.fromHex("#FFFFFF"),
			carpeta
		)
		cartel(vuelta, "Lobby")
		prompt(vuelta, "Volver", "Lobby").Triggered:Connect(function(jugador: Player)
			viajar(jugador, vuelta, lobby)
		end)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		ultimoViaje[jugador] = nil
	end)
end

return Viajes
