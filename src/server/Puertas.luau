--!strict
-- Puertas que piden un nivel mínimo, checkpoints detrás de cada puerta,
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
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Datos = require(script.Parent.Datos)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Puertas = {}

local checkpoints: { [number]: BasePart } = {}
local inicio: BasePart? = nil

-- Grupo de colisión del personaje: cuántas puertas tiene abiertas.
local function grupoAbiertas(cantidad: number): string
	return `PuertasAbiertas{cantidad}`
end

local function grupoPuerta(indice: number): string
	return `Puerta{indice}`
end

local function registrarGrupo(nombre: string)
	if not PhysicsService:IsCollisionGroupRegistered(nombre) then
		PhysicsService:RegisterCollisionGroup(nombre)
	end
end

-- Cuántas puertas puede pasar con este nivel.
local function puertasAbiertas(nivel: number): number
	local abiertas = 0
	for indice, minimo in Config.NivelPuertas do
		if nivel >= minimo then
			abiertas = math.max(abiertas, indice)
		end
	end
	return abiertas
end

local function nivelDe(perfil: Datos.Perfil): number
	return Niveles.nivelDe(perfil.PasosTotales)
end

local function grupoDe(jugador: Player): string
	local perfil = Datos.obtener(jugador)
	return grupoAbiertas(if perfil then puertasAbiertas(nivelDe(perfil)) else 0)
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
	-- Solo cuenta si de verdad tiene el nivel para haber pasado la puerta (los del parkour no piden).
	if nivelDe(perfil) < (Config.NivelPuertas[indice] or 0) then
		return
	end
	perfil.Checkpoint = indice
	Velocidad.aplicar(jugador)
	-- SONIDO: checkpoint (Config.Efectos.Checkpoint)
	Remotos.avisar(jugador, `¡Checkpoint {indice}!`, "Checkpoint")
end

function Puertas.iniciar()
	local cantidad = #Config.NivelPuertas
	for abiertas = 0, cantidad do
		registrarGrupo(grupoAbiertas(abiertas))
	end
	for indice = 1, cantidad do
		registrarGrupo(grupoPuerta(indice))
		for abiertas = 0, cantidad do
			PhysicsService:CollisionGroupSetCollidable(
				grupoPuerta(indice),
				grupoAbiertas(abiertas),
				abiertas < indice
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
		-- SONIDO: escudo (Config.Efectos.Escudo)
		Remotos.avisar(jugador, "¡El Escudo te salvó!", "Escudo")
	else
		local perdida = math.floor(perfil.Velocidad * Config.PenalizacionCaida)
		perfil.Velocidad -= perdida
		-- SONIDO: nota desafinada (Config.Efectos.Caida)
		Remotos.avisar(jugador, `¡Te caíste! -{perdida} velocidad`, "Caida")
	end
	jugador:SetAttribute("Caidas", (jugador:GetAttribute("Caidas") or 0) :: number + 1)
	Velocidad.aplicar(jugador)
	Puertas.teletransportar(jugador)
end

function Puertas.alAparecer(jugador: Player, personaje: Model)
	asignarGrupo(personaje, grupoDe(jugador))
	personaje.DescendantAdded:Connect(function(parte)
		if parte:IsA("BasePart") then
			parte.CollisionGroup = grupoDe(jugador)
		end
	end)
	local perfil = Datos.obtener(jugador)
	if perfil and perfil.Checkpoint > 0 then
		task.defer(Puertas.teletransportar, jugador)
	end
end

return Puertas
