--!strict
-- Clavijas especiales del paso 5a, sin Instances (las usan Simulacion, el servidor, el cliente y
-- las pruebas con Lune): cuánto suma cada tipo según su nivel, el tablero de la partida, qué
-- cartas salen y qué clavijas convierte una carta. Los números están en Config.Clavijas.
--
-- El tablero de la partida es una lista densa (una entrada por Id de clavija, en el orden de
-- shared/Tablero) con el tipo de cada una: "gris", "roja", "azul", "dorada", "verde", "violeta" o
-- "hueco". Densa y con claves de texto en los niveles para que viaje bien por los remotos.

local Azar = require(script.Parent.Azar)
local Config = require(script.Parent.Config)

export type TableroPartida = { string } -- Id de clavija -> tipo
export type Niveles = { [string]: number } -- tipo -> nivel (falta = 1)

local Clavijas = {}

local function datos(tipo: string): any
	return (Config.Clavijas :: any)[tipo] or Config.Clavijas.gris
end

-- valor de nivel 1 + porNivel × (nivel - 1)
local function conNivel(base: number?, porNivel: number?, nivel: number): number
	return (base or 0) + (porNivel or 0) * (nivel - 1)
end

function Clavijas.existe(tipo: any): boolean
	return typeof(tipo) == "string" and (Config.Clavijas :: any)[tipo] ~= nil
end

function Clavijas.nivel(niveles: Niveles?, tipo: string): number
	return if niveles then niveles[tipo] or 1 else 1
end

function Clavijas.tipo(tablero: TableroPartida?, id: number): string
	return if tablero then tablero[id] or "gris" else "gris"
end

function Clavijas.fuerza(tipo: string, nivel: number): number
	local d = datos(tipo)
	return conNivel(d.Fuerza, d.FuerzaPorNivel, nivel)
end

function Clavijas.multi(tipo: string, nivel: number): number
	local d = datos(tipo)
	return conNivel(d.Multi, d.MultiPorNivel, nivel)
end

-- Por cuánto multiplica el Multi (1 = no multiplica).
function Clavijas.porMulti(tipo: string, nivel: number): number
	local d = datos(tipo)
	return if d.PorMulti then conNivel(d.PorMulti, d.PorMultiPorNivel, nivel) else 1
end

function Clavijas.oro(tipo: string, nivel: number): number
	local d = datos(tipo)
	return conNivel(d.Oro, d.OroPorNivel, nivel)
end

-- Cuántas veces cuenta la próxima clavija después de esta (0 = no es violeta).
function Clavijas.eco(tipo: string, nivel: number): number
	local d = datos(tipo)
	return conNivel(d.Eco, d.EcoPorNivel, nivel)
end

function Clavijas.color(tipo: string): string
	return datos(tipo).Color
end

-- Tablero nuevo de la partida: todas grises.
function Clavijas.nuevoTablero(cantidad: number): TableroPartida
	local t: TableroPartida = {}
	for i = 1, cantidad do
		t[i] = "gris"
	end
	return t
end

-- Convierte hasta `cantidad` clavijas grises (elegidas con la semilla) en `tipo`. Devuelve los Id.
function Clavijas.convertir(
	tablero: TableroPartida,
	tipo: string,
	cantidad: number,
	semilla: number
): { number }
	local grises: { number } = {}
	for id, t in tablero do
		if t == "gris" then
			table.insert(grises, id)
		end
	end
	Azar.mezclar(grises, Azar.nuevo(semilla))
	local elegidas: { number } = {}
	for i = 1, math.min(cantidad, #grises) do
		tablero[grises[i]] = tipo
		table.insert(elegidas, grises[i])
	end
	table.sort(elegidas)
	return elegidas
end

-- Cuántas clavijas hay de cada tipo.
function Clavijas.contar(tablero: TableroPartida): { [string]: number }
	local cuenta: { [string]: number } = {}
	for _, t in tablero do
		cuenta[t] = (cuenta[t] or 0) + 1
	end
	return cuenta
end

-- Las cartas que salen al ganar una pelea (3 tipos distintos, con la semilla).
function Clavijas.ofrecer(semilla: number): { string }
	local todas = table.clone(Config.OrdenClavijas)
	Azar.mezclar(todas, Azar.nuevo(semilla))
	local elegidas: { string } = {}
	for i = 1, math.min(Config.Cartas.PorPantalla, #todas) do
		table.insert(elegidas, todas[i])
	end
	return elegidas
end

-- Qué hace un tipo, en una frase corta (para cartas y carteles).
function Clavijas.efecto(tipo: string, nivel: number): string
	if tipo == "roja" then
		return ("+%d Multi"):format(Clavijas.multi(tipo, nivel))
	elseif tipo == "azul" then
		return ("×%s Multi, a veces se rompe"):format(
			Clavijas.numeroCorto(Clavijas.porMulti(tipo, nivel))
		)
	elseif tipo == "dorada" then
		return ("+%d Fuerza y +%d oro"):format(
			Clavijas.fuerza(tipo, nivel),
			Clavijas.oro(tipo, nivel)
		)
	elseif tipo == "verde" then
		return ("+%d Fuerza y la bola sale disparada"):format(Clavijas.fuerza(tipo, nivel))
	elseif tipo == "violeta" then
		return ("la próxima clavija cuenta %d veces"):format(Clavijas.eco(tipo, nivel))
	elseif tipo == "gris" then
		return ("+%d Fuerza"):format(Clavijas.fuerza(tipo, nivel))
	end
	return ""
end

-- Nombre y frase de una carta.
function Clavijas.describir(tipo: string, nivel: number): (string, string)
	local d = datos(tipo)
	return ("Clavijas %s"):format(d.Plural),
		("%d grises se vuelven %s: %s"):format(
			Config.Cartas.ClavijasPorCarta,
			d.Plural,
			Clavijas.efecto(tipo, nivel)
		)
end

-- Números para mostrar: 1,5 · 12,4 mil · 1,5 M (sin decimales si no hacen falta).
function Clavijas.numeroCorto(n: number): string
	-- Hasta `cifras` decimales, sin ceros de más, con coma.
	local function decimal(x: number, cifras: number): string
		local texto = (("%." .. cifras .. "f"):format(x):gsub("0+$", ""):gsub("%.$", ""))
		return (texto:gsub("%.", ","))
	end
	if n >= 1000000 then
		return decimal(n / 1000000, 1) .. " M"
	elseif n >= 10000 then
		return decimal(n / 1000, 1) .. " mil"
	elseif n ~= math.floor(n) then
		return decimal(n, 2)
	end
	return tostring(math.floor(n))
end

return Clavijas
