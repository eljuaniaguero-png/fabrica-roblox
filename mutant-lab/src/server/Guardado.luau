--!strict
-- Guardado de cada jugador en un DataStore (Config.Guardado).
-- Se guarda: ADN, especies descubiertas, mutantes, las criaturas del laboratorio (con su
-- personalidad y variante), las variantes conseguidas, residuos, catalizadores, pistas
-- (compradas y gratis), premios de generación ya cobrados, niveles de las mejoras, los
-- pedidos del tablero y cuántos entregaste. Los guardados de la versión 1 (sin criaturas)
-- se convierten solos: una criatura por especie descubierta.
-- Se guarda al salir, cada Config.Guardado.CadaCuanto segundos y al cerrar el servidor.
-- Si la carga falla, el jugador juega igual pero NO se guarda nada, para no pisar sus datos.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Jugadores = require(script.Parent.Jugadores)
local Reloj = require(script.Parent.Reloj)

local G = Config.Guardado
local VERSION = 2
local MAXIMO_CRIATURAS = 1000

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

-- Solo se guardan los "me gusta" que diste hoy o ayer (los viejos ya no importan).
local function meGustaRecientes(d: Jugadores.Datos): { [string]: number }
	local hoy = Reloj.dia()
	local r = {}
	for k, dia in d.MeGustaDados do
		if dia >= hoy - 1 then
			r[k] = dia
		end
	end
	return r
end

local function aGuardados(d: Jugadores.Datos): Guardados
	local criaturas = {}
	for _, u in d.Criaturas do
		table.insert(criaturas, {
			Clave = u.Clave,
			Mutante = u.Mutante,
			Personalidad = u.Personalidad,
			Variante = u.Variante,
		})
	end
	local pedidos = {}
	for lugar, p in d.Pedidos do
		table.insert(pedidos, { Lugar = lugar, Pedido = p })
	end
	return {
		Version = VERSION,
		ADN = math.floor(d.ADN),
		Especies = lista(d.Especies),
		Mutantes = lista(d.Mutantes),
		Criaturas = criaturas,
		Pistas = table.clone(d.Pistas),
		PistasCompradas = d.PistasCompradas,
		PistasGratis = d.PistasGratis,
		GeneracionesPremiadas = lista(d.GeneracionesPremiadas),
		Mejoras = table.clone(d.Mejoras),
		Pedidos = pedidos,
		Entregados = d.Entregados,
		Residuos = table.clone(d.Residuos),
		Catalizadores = table.clone(d.Catalizadores),
		CatalizadoresVistos = lista(d.CatalizadoresVistos),
		Variantes = Jugadores.aLista(d.Variantes),
		Sellos = Jugadores.aLista(d.Sellos),
		UltimaVez = Reloj.ahora(),
		Fusiones = d.Fusiones,
		Diario = table.clone(d.Diario),
		Misiones = {
			Dia = d.Misiones.Dia,
			Lista = table.clone(d.Misiones.Lista),
			Bono = d.Misiones.Bono,
		},
		ExperimentoGanado = d.ExperimentoGanado,
		Metas = lista(d.Metas),
		Especiales = lista(d.Especiales),
		MeGusta = d.MeGusta,
		MeGustaDados = meGustaRecientes(d),
	}
end

-- Un pedido guardado sirve si tiene todas sus partes con el tipo correcto.
local function pedidoValido(p: any): boolean
	if typeof(p) ~= "table" or typeof(p.Requisito) ~= "table" then
		return false
	end
	return typeof(p.Id) == "number"
		and typeof(p.Cliente) == "number"
		and p.Cliente >= 1
		and p.Cliente <= #Config.Pedidos.Clientes
		and typeof(p.Texto) == "string"
		and typeof(p.Premio) == "number"
		and p.Premio >= 0
		and typeof(p.Dificultad) == "string"
		and typeof(p.Requisito.Tipo) == "string"
end

-- Revisa lo que vino del DataStore: solo pasan especies que existen y niveles válidos.
local function limpiar(crudo: any): Guardados?
	if typeof(crudo) ~= "table" or (crudo.Version ~= 1 and crudo.Version ~= VERSION) then
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
	-- Criaturas (versión 2). En la versión 1 no existen: las arma Jugadores.crear.
	-- La personalidad y la variante solo pasan si existen (si no, Jugadores pone la de su
	-- especie y ninguna variante).
	local criaturas: { Jugadores.CriaturaGuardada }? = nil
	if crudo.Version == VERSION and typeof(crudo.Criaturas) == "table" then
		local leidas = {}
		for _, c in crudo.Criaturas do
			if
				#leidas < MAXIMO_CRIATURAS
				and typeof(c) == "table"
				and typeof(c.Clave) == "string"
				and Fusion.porClave(c.Clave)
			then
				table.insert(leidas, {
					Clave = c.Clave,
					Mutante = c.Mutante == true,
					Personalidad = if typeof(c.Personalidad) == "string"
							and Personalidades.Datos[c.Personalidad]
						then c.Personalidad
						else nil,
					Variante = if typeof(c.Variante) == "string"
							and Catalizadores.porClave(c.Variante)
						then c.Variante
						else nil,
				})
			end
		end
		criaturas = leidas
	end
	local variantes = {}
	if typeof(crudo.Variantes) == "table" then
		for _, texto in crudo.Variantes do
			local especie, v =
				string.match(if typeof(texto) == "string" then texto else "", "^([^|]+)|(.+)$")
			if especie and v and Fusion.porClave(especie) and Catalizadores.porClave(v) then
				table.insert(variantes, especie .. "|" .. v)
			end
		end
	end
	local sellos = {}
	if typeof(crudo.Sellos) == "table" then
		for _, texto in crudo.Sellos do
			local especie, p =
				string.match(if typeof(texto) == "string" then texto else "", "^([^|]+)|(.+)$")
			if especie and p and Fusion.porClave(especie) and Personalidades.Datos[p] then
				table.insert(sellos, especie .. "|" .. p)
			end
		end
	end
	local pedidos = {}
	if typeof(crudo.Pedidos) == "table" then
		for _, g in crudo.Pedidos do
			if typeof(g) == "table" and typeof(g.Lugar) == "number" and pedidoValido(g.Pedido) then
				table.insert(pedidos, { Lugar = math.floor(g.Lugar), Pedido = g.Pedido })
			end
		end
	end
	-- Residuos (parejas de especies que existen) y catalizadores (de los que existen).
	local residuos = {}
	if typeof(crudo.Residuos) == "table" then
		for _, r in crudo.Residuos do
			if
				#residuos < 100
				and typeof(r) == "table"
				and typeof(r.A) == "string"
				and typeof(r.B) == "string"
				and Fusion.porClave(r.A)
				and Fusion.porClave(r.B)
			then
				table.insert(residuos, { A = r.A, B = r.B })
			end
		end
	end
	local catalizadores, vistos = {}, {}
	for _, c in Catalizadores.Lista do
		if typeof(crudo.Catalizadores) == "table" then
			catalizadores[c.Clave] = numero(crudo.Catalizadores[c.Clave], 0, 1e6)
		end
		if
			typeof(crudo.CatalizadoresVistos) == "table"
			and table.find(crudo.CatalizadoresVistos, c.Clave)
		then
			table.insert(vistos, c.Clave)
		end
	end
	-- Volver mañana (Parte 8): racha, misiones del día, metas y especies especiales.
	local diario = nil
	if typeof(crudo.Diario) == "table" then
		diario = {
			Racha = numero(crudo.Diario.Racha, 0, #Config.Diario.Premios),
			UltimoDia = numero(crudo.Diario.UltimoDia, -1, 1e9),
		}
	end
	local misiones = nil
	if typeof(crudo.Misiones) == "table" and typeof(crudo.Misiones.Lista) == "table" then
		local leidas = {}
		for _, mision in crudo.Misiones.Lista do
			if
				#leidas < Config.Misiones.PorDia
				and typeof(mision) == "table"
				and typeof(mision.Tipo) == "string"
				and typeof(mision.Meta) == "number"
				and typeof(mision.Progreso) == "number"
			then
				table.insert(leidas, {
					Tipo = mision.Tipo,
					Meta = numero(mision.Meta, 1, 1000),
					Progreso = numero(mision.Progreso, 0, 1000),
					Dato = if typeof(mision.Dato) == "string" then mision.Dato else nil,
					Hecha = mision.Hecha == true,
				})
			end
		end
		misiones = {
			Dia = numero(crudo.Misiones.Dia, -1, 1e9),
			Lista = leidas,
			Bono = crudo.Misiones.Bono == true,
		}
	end
	local metas = {}
	for _, k in if typeof(crudo.Metas) == "table" then crudo.Metas else {} do
		if typeof(k) == "string" then
			table.insert(metas, k)
		end
	end
	local meGustaDados = {}
	if typeof(crudo.MeGustaDados) == "table" then
		for k, dia in crudo.MeGustaDados do
			if typeof(k) == "string" and typeof(dia) == "number" then
				meGustaDados[k] = math.floor(dia)
			end
		end
	end
	local especiales = {}
	for _, k in if typeof(crudo.Especiales) == "table" then crudo.Especiales else {} do
		local c = if typeof(k) == "string" then Fusion.porClave(k) else nil
		if c and c.Especial then
			table.insert(especiales, k)
		end
	end

	return {
		Version = VERSION,
		ADN = numero(crudo.ADN, 0, 1e15),
		UltimaVez = if typeof(crudo.UltimaVez) == "number" then crudo.UltimaVez else nil,
		Fusiones = numero(crudo.Fusiones, 0, 1e9),
		Diario = diario,
		Misiones = misiones,
		ExperimentoGanado = numero(crudo.ExperimentoGanado, -1, 1e9),
		Metas = metas,
		Especiales = especiales,
		MeGusta = numero(crudo.MeGusta, 0, 1e9),
		MeGustaDados = meGustaDados,
		Residuos = residuos,
		Catalizadores = catalizadores,
		CatalizadoresVistos = vistos,
		Variantes = variantes,
		Sellos = sellos,
		Especies = claves(crudo.Especies),
		Mutantes = claves(crudo.Mutantes),
		Criaturas = criaturas,
		Pistas = pistas,
		PistasCompradas = numero(crudo.PistasCompradas, 0, 1e6),
		PistasGratis = numero(crudo.PistasGratis, 0, 1e6),
		GeneracionesPremiadas = gens,
		Mejoras = niveles,
		Pedidos = pedidos,
		Entregados = numero(crudo.Entregados, 0, 1e9),
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
