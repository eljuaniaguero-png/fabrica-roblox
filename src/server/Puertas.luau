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
local alCaerSinEscudo: { (Player) -> () } = {}
local apoyo: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any -- altura del último piso donde estuvo parado
local parametrosPiso = RaycastParams.new()
parametrosPiso.FilterType = Enum.RaycastFilterType.Exclude
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

local function llevarA(jugador: Player, destino: Vector3?)
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not personaje or not raiz or not raiz:IsA("BasePart") or not destino then
		return
	end
	apoyo[jugador] = nil -- un viaje no es una caída
	personaje:PivotTo(CFrame.new(destino))
	raiz.AssemblyLinearVelocity = Vector3.zero
end

-- Al último checkpoint (o al inicio si no tiene).
function Puertas.teletransportar(jugador: Player)
	llevarA(jugador, posicionReaparicion(jugador))
end

-- A la plaza (el inicio), sin tocar el checkpoint guardado.
function Puertas.irAPlaza(jugador: Player)
	llevarA(
		jugador,
		if inicio then inicio.Position + Vector3.new(0, inicio.Size.Y / 2 + 3, 0) else nil
	)
end

-- Altura del piso que tiene debajo, o nil si está en el aire.
local function pisoDebajo(personaje: Model, raiz: BasePart): number?
	parametrosPiso.FilterDescendantsInstances = { personaje }
	local resultado = workspace:Raycast(raiz.Position, Vector3.new(0, -4.5, 0), parametrosPiso)
	return if resultado then resultado.Position.Y else nil
end

function Puertas.chequearCaida(jugador: Player)
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	local perfil = Datos.obtener(jugador)
	if not perfil or not personaje or not raiz or not raiz:IsA("BasePart") then
		return
	end
	-- Caída: al vacío, o aterrizar más de CaidaMinima por debajo de donde estaba parado
	-- (por ejemplo, de una vuelta de la espiral a la de abajo). Bajar caminando no cuenta.
	local cayo = raiz.Position.Y < Config.AlturaCaida
	local piso = pisoDebajo(personaje, raiz)
	if not cayo and piso then
		local antes = apoyo[jugador]
		cayo = antes ~= nil and piso < antes - Config.Torre.CaidaMinima
		apoyo[jugador] = piso
	end
	if not cayo then
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
		for _, funcion in alCaerSinEscudo do
			funcion(jugador)
		end
	end
	jugador:SetAttribute("Caidas", (jugador:GetAttribute("Caidas") or 0) :: number + 1)
	Velocidad.aplicar(jugador)
	Puertas.teletransportar(jugador)
end

-- Llama a `funcion` cada vez que alguien se cae sin Escudo (Pisadas.luau corta el combo).
function Puertas.alCaer(funcion: (Player) -> ())
	table.insert(alCaerSinEscudo, funcion)
end

function Puertas.alAparecer(jugador: Player, personaje: Model)
	apoyo[jugador] = nil
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
