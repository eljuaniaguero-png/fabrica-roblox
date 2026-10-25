--!strict
-- Viajes (idea elegida del 19/10/2026: "Teletransporte por bioma"). Desde el menú "Viajar" del
-- HUD el jugador paga Monedas y aparece al inicio de una zona que ya tiene abierta. Volver al
-- Lobby es gratis. Así no hace falta caminar 2 minutos para farmear en el Volcán o el Abismo.
-- El destino sale de las puertas del mapa (tag "PuertaZona", atributo Zona): un poco después de
-- cada puerta. La altura se busca con un rayo hacia abajo desde la altura de la puerta.
-- El servidor revisa: número de zona válido, zona abierta, que alcancen las monedas, que el
-- personaje esté vivo y la espera entre viajes. El precio sale de Reglas.precioViaje.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local Correr = require(script.Parent.Correr)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Analitica = require(script.Parent.Analitica)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local V = GameConfig.Viajes
local Viajes = {}

local ultimoViaje: { [Player]: number } = {}
local destinos: { [number]: Vector3 } = {} -- 0 = Lobby

-- Piso debajo de un punto (ignora personajes y geodas). El rayo arranca a la altura `desde`
-- y no desde el cielo, para no caer arriba de un cartel o un risco.
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
	return if r then r.Position else Vector3.new(x, desde, z)
end

local function calcularDestinos()
	local mapa = Workspace:FindFirstChild("Mapa")
	local spawn = mapa and mapa:FindFirstChild("Spawn", true)
	local lobby = if spawn and spawn:IsA("BasePart") then spawn.Position else Vector3.new(0, 1, -14)
	destinos[0] = piso(lobby.X, lobby.Z, lobby.Y + 10)
	destinos[1] = piso(0, V.InicioZona1, 20)
	for _, puerta in CollectionService:GetTagged("PuertaZona") do
		local zona = puerta:GetAttribute("Zona")
		if puerta:IsA("BasePart") and typeof(zona) == "number" then
			destinos[zona] = piso(0, puerta.Position.Z + V.Adelante, puerta.Position.Y)
		end
	end
end

local function viajar(jugador: Player, zona: unknown)
	if typeof(zona) ~= "number" or zona ~= zona or zona % 1 ~= 0 then
		return
	end
	local destino = destinos[zona]
	local d = Jugadores.obtener(jugador)
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not destino or not d or not personaje or not humanoide or humanoide.Health <= 0 then
		return
	end
	local ahora = os.clock()
	if ultimoViaje[jugador] and ahora - ultimoViaje[jugador] < V.Espera then
		Remotos.Aviso:FireClient(jugador, "Esperá un momento para volver a viajar")
		return
	end
	local precio = 0
	if zona > 0 then
		local z = Reglas.zona(zona) :: GameConfig.Zona
		if not d.Zonas[zona] then
			Remotos.Aviso:FireClient(
				jugador,
				("Para %s necesitás %s"):format(z.Nombre, Reglas.textoRequisito(z, Formato.corto))
			)
			return
		end
		precio = Reglas.precioViaje(zona)
		if d.Monedas < precio then
			Remotos.Aviso:FireClient(
				jugador,
				("Te faltan %s Monedas para viajar"):format(Formato.corto(precio - d.Monedas))
			)
			return
		end
	end
	ultimoViaje[jugador] = ahora
	d.Monedas -= precio
	Analitica.monedas(jugador, false, precio, "Viaje")
	Jugadores.publicar(jugador)
	personaje:PivotTo(CFrame.new(destino + Vector3.new(0, 4, 0)))
	Correr.teletransportado(jugador)
	Remotos.Viajo:FireClient(jugador, zona, precio)
end

function Viajes.iniciar()
	calcularDestinos()
	Remotos.Viajar.OnServerEvent:Connect(viajar)
	Players.PlayerRemoving:Connect(function(jugador)
		ultimoViaje[jugador] = nil
	end)
end

return Viajes
