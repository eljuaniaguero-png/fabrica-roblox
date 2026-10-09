--!strict
-- Guardado de cada jugador en un DataStore (Config.Guardado).
-- Se guarda: ADN, especies descubiertas (son las criaturas: tenés una de cada especie),
-- mutantes, pistas, premios de generación ya cobrados y niveles de las mejoras.
-- Se guarda al salir, cada Config.Guardado.CadaCuanto segundos y al cerrar el servidor.
-- Si la carga falla, el jugador juega igual pero NO se guarda nada, para no pisar sus datos.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Jugadores = require(script.Parent.Jugadores)

local G = Config.Guardado
local VERSION = 1

type Guardados = Jugadores.Guardados

local almacen: DataStore? = nil
do
	local ok, resultado = pcall(function()
		return DataStoreService:GetDataStore(G.Almacen)
	end)
	if ok then
		almacen = resultado
	else
		warn("[Guardado] No se pudo abrir el DataStore: " .. tostring(resultado))
	end
end

local puedeGuardar: { [Player]: boolean } = {} -- solo si la carga salió bien
local avisoSinAcceso = false

local Guardado = {}

local function clave(jugador: Player): string
	return "J_" .. jugador.UserId
end

-- En Studio, sin "Acceso de Studio a los servicios de API" el DataStore no anda: no tiene
-- sentido reintentar.
local function sinAcceso(err: unknown): boolean
	local texto = tostring(err)
	return texto:find("403") ~= nil or texto:find("API") ~= nil
end

-- Llama a `f` hasta Config.Guardado.Intentos veces. Devuelve ok y el resultado.
local function conReintentos(f: () -> any): (boolean, any)
	local ultimoError: any = nil
	for intento = 1, G.Intentos do
		local ok, resultado = pcall(f)
		if ok then
			return true, resultado
		end
		ultimoError = resultado
		if sinAcceso(resultado) then
			break
		end
		task.wait(intento)
	end
	return false, ultimoError
end

local function lista(conjunto: { [any]: boolean }): { any }
	local r = {}
	for k, v in conjunto do
		if v then
			table.insert(r, k)
		end
	end
	return r
end

local function aGuardados(d: Jugadores.Datos): Guardados
	return {
		Version = VERSION,
		ADN = math.floor(d.ADN),
		Especies = lista(d.Especies),
		Mutantes = lista(d.Mutantes),
		Pistas = table.clone(d.Pistas),
		PistasCompradas = d.PistasCompradas,
		GeneracionesPremiadas = lista(d.GeneracionesPremiadas),
		Mejoras = table.clone(d.Mejoras),
	}
end

-- Revisa lo que vino del DataStore: solo pasan especies que existen y niveles válidos.
local function limpiar(crudo: any): Guardados?
	if typeof(crudo) ~= "table" or crudo.Version ~= VERSION then
		return nil
	end
	local function numero(x: any, minimo: number, maximo: number): number
		if typeof(x) ~= "number" or x ~= x then
			return minimo
		end
		return math.clamp(math.floor(x), minimo, maximo)
	end
	local function claves(x: any): { string }
		local r = {}
		if typeof(x) == "table" then
			for _, k in x do
				if typeof(k) == "string" and Fusion.porClave(k) then
					table.insert(r, k)
				end
			end
		end
		return r
	end
	local pistas = {}
	if typeof(crudo.Pistas) == "table" then
		for k, n in crudo.Pistas do
			if typeof(k) == "string" and Fusion.porClave(k) and typeof(n) == "number" then
				pistas[k] = numero(n, 0, 3)
			end
		end
	end
	local gens = {}
	if typeof(crudo.GeneracionesPremiadas) == "table" then
		for _, g in crudo.GeneracionesPremiadas do
			if g == 1 or g == 2 or g == 3 then
				table.insert(gens, g)
			end
		end
	end
	local m = if typeof(crudo.Mejoras) == "table" then crudo.Mejoras else {}
	local niveles = Mejoras.iniciales()
	for _, nombre in Mejoras.Orden do
		local inicial = (niveles :: any)[nombre] :: number
		(niveles :: any)[nombre] = numero(m[nombre], inicial, Mejoras.maximo(nombre))
	end
	return {
		Version = VERSION,
		ADN = numero(crudo.ADN, 0, 1e15),
		Especies = claves(crudo.Especies),
		Mutantes = claves(crudo.Mutantes),
		Pistas = pistas,
		PistasCompradas = numero(crudo.PistasCompradas, 0, 1e6),
		GeneracionesPremiadas = gens,
		Mejoras = niveles,
	}
end

-- Carga los datos de un jugador. Devuelve los datos (nil si es nuevo) y si se pudo leer.
function Guardado.cargar(jugador: Player): (Guardados?, boolean)
	local a = almacen
	if not a then
		return nil, false
	end
	local ok, crudo = conReintentos(function()
		return a:GetAsync(clave(jugador))
	end)
	if not ok then
		if sinAcceso(crudo) then
			if not avisoSinAcceso then
				avisoSinAcceso = true
				warn(
					"[Guardado] Sin acceso al DataStore (en Studio: Configuración del juego >"
						.. " Seguridad > Acceso de Studio a los servicios de API). No se guarda nada."
				)
			end
		else
			warn(
				"[Guardado] No se pudieron cargar los datos de "
					.. jugador.Name
					.. ": "
					.. tostring(crudo)
			)
		end
		return nil, false
	end
	puedeGuardar[jugador] = true
	return limpiar(crudo), true
end

function Guardado.guardar(jugador: Player): boolean
	local a = almacen
	local d = Jugadores.obtener(jugador)
	if not a or not d or not puedeGuardar[jugador] then
		return false
	end
	local datos = aGuardados(d)
	local ok, err = conReintentos(function()
		return a:UpdateAsync(clave(jugador), function()
			return datos
		end)
	end)
	if not ok then
		warn("[Guardado] No se pudo guardar a " .. jugador.Name .. ": " .. tostring(err))
	end
	return ok
end

-- Al salir: guarda y olvida.
function Guardado.salir(jugador: Player)
	Guardado.guardar(jugador)
	puedeGuardar[jugador] = nil
end

function Guardado.iniciar()
	task.spawn(function()
		while true do
			task.wait(G.CadaCuanto)
			for _, jugador in Players:GetPlayers() do
				task.spawn(Guardado.guardar, jugador)
			end
		end
	end)
	-- Al cerrar el servidor, guardar a todos (Roblox espera hasta 30 segundos).
	game:BindToClose(function()
		local pendientes = 0
		for _, jugador in Players:GetPlayers() do
			pendientes += 1
			task.spawn(function()
				Guardado.guardar(jugador)
				pendientes -= 1
			end)
		end
		local inicio = os.clock()
		while pendientes > 0 and os.clock() - inicio < 25 do
			task.wait(0.2)
		end
	end)
end

return Guardado
