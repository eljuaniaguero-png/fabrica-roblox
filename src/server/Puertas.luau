--!strict
-- Puertas que piden velocidad mínima, checkpoints detrás de cada puerta,
-- y vuelta al último checkpoint si te caés.
--
-- En el mapa:
--   puerta     = BasePart con atributo PuertaIndice (1, 2, ...)
--   checkpoint = BasePart con atributo CheckpointIndice (el mismo número que su puerta)
--   inicio     = la SpawnLocation

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Datos = require(script.Parent.Datos)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Puertas = {}

local checkpoints: { [number]: BasePart } = {}
local inicio: BasePart? = nil

local function grupoNivel(nivel: number): string
	return `Nivel{nivel}`
end

local function grupoPuerta(indice: number): string
	return `Puerta{indice}`
end

local function registrarGrupo(nombre: string)
	if not PhysicsService:IsCollisionGroupRegistered(nombre) then
		PhysicsService:RegisterCollisionGroup(nombre)
	end
end

-- Cuántas puertas puede pasar con esta velocidad.
local function nivelDe(velocidad: number): number
	local nivel = 0
	for indice, umbral in Config.UmbralesPuertas do
		if velocidad >= umbral then
			nivel = math.max(nivel, indice)
		end
	end
	return nivel
end

local function grupoDe(jugador: Player): string
	local perfil = Datos.obtener(jugador)
	return grupoNivel(if perfil then nivelDe(perfil.Velocidad) else 0)
end

local function asignarGrupo(personaje: Model, grupo: string)
	for _, parte in personaje:GetDescendants() do
		if parte:IsA("BasePart") then
			parte.CollisionGroup = grupo
		end
	end
end

local function alTocarCheckpoint(indice: number, otra: BasePart)
	local personaje = otra.Parent
	local jugador = if personaje then Players:GetPlayerFromCharacter(personaje) else nil
	if not jugador then
		return
	end
	local perfil = Datos.obtener(jugador)
	if not perfil or perfil.Checkpoint >= indice then
		return
	end
	-- Solo cuenta si de verdad tiene la velocidad para haber pasado la puerta.
	if perfil.Velocidad < Config.UmbralesPuertas[indice] then
		return
	end
	perfil.Checkpoint = indice
	Velocidad.aplicar(jugador)
	Remotos.avisar(jugador, `¡Checkpoint {indice}!`)
end

function Puertas.iniciar()
	local cantidad = #Config.UmbralesPuertas
	for nivel = 0, cantidad do
		registrarGrupo(grupoNivel(nivel))
	end
	for indice = 1, cantidad do
		registrarGrupo(grupoPuerta(indice))
		for nivel = 0, cantidad do
			PhysicsService:CollisionGroupSetCollidable(
				grupoPuerta(indice),
				grupoNivel(nivel),
				nivel < indice
			)
		end
	end

	for _, parte in workspace:GetDescendants() do
		if parte:IsA("SpawnLocation") then
			inicio = parte
		elseif parte:IsA("BasePart") then
			local puerta = parte:GetAttribute("PuertaIndice")
			if typeof(puerta) == "number" then
				parte.CollisionGroup = grupoPuerta(puerta)
			end
			local checkpoint = parte:GetAttribute("CheckpointIndice")
			if typeof(checkpoint) == "number" then
				checkpoints[checkpoint] = parte
				parte.Touched:Connect(function(otra)
					alTocarCheckpoint(checkpoint, otra)
				end)
			end
		end
	end
end

function Puertas.actualizarNivel(jugador: Player)
	local personaje = jugador.Character
	if personaje then
		asignarGrupo(personaje, grupoDe(jugador))
	end
end

local function posicionReaparicion(jugador: Player): Vector3?
	local perfil = Datos.obtener(jugador)
	local destino = if perfil and perfil.Checkpoint > 0 then checkpoints[perfil.Checkpoint] else nil
	destino = destino or inicio
	if not destino then
		return nil
	end
	return destino.Position + Vector3.new(0, destino.Size.Y / 2 + 3, 0)
end

function Puertas.teletransportar(jugador: Player)
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	local destino = posicionReaparicion(jugador)
	if not personaje or not raiz or not raiz:IsA("BasePart") or not destino then
		return
	end
	personaje:PivotTo(CFrame.new(destino))
	raiz.AssemblyLinearVelocity = Vector3.zero
	Velocidad.olvidarPosicion(jugador)
end

function Puertas.chequearCaida(jugador: Player)
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	local perfil = Datos.obtener(jugador)
	if
		not perfil
		or not raiz
		or not raiz:IsA("BasePart")
		or raiz.Position.Y >= Config.AlturaCaida
	then
		return
	end

	if (perfil.Inventario.Escudo or 0) > 0 then
		perfil.Inventario.Escudo -= 1
		Remotos.avisar(jugador, "¡El Escudo te salvó!")
	else
		local perdida = math.floor(perfil.Velocidad * Config.PenalizacionCaida)
		perfil.Velocidad -= perdida
		Remotos.avisar(jugador, `¡Te caíste! -{perdida} velocidad`)
	end
	-- SONIDO: caída (lo dispara el cliente al ver el atributo "Caidas")
	jugador:SetAttribute("Caidas", (jugador:GetAttribute("Caidas") or 0) :: number + 1)
	Velocidad.aplicar(jugador)
	Puertas.actualizarNivel(jugador)
	Puertas.teletransportar(jugador)
end

function Puertas.alAparecer(jugador: Player, personaje: Model)
	asignarGrupo(personaje, grupoDe(jugador))
	personaje.DescendantAdded:Connect(function(parte)
		if parte:IsA("BasePart") then
			parte.CollisionGroup = grupoDe(jugador)
		end
	end)
	Velocidad.olvidarPosicion(jugador)
	local perfil = Datos.obtener(jugador)
	if perfil and perfil.Checkpoint > 0 then
		task.defer(Puertas.teletransportar, jugador)
	end
end

return Puertas
