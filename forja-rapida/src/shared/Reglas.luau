--!strict
-- Fórmulas de Forja Rápida: fuerza, vida, suerte, probabilidades y precios. Las usan el
-- servidor (que decide) y el cliente (que muestra). Solo lógica pura: sin servicios de
-- Roblox, así se prueba con Lune (forja-rapida/pruebas).

local GameConfig = require(script.Parent.GameConfig)

type Rareza = GameConfig.Rareza
type Modificador = GameConfig.Modificador
type Tamano = GameConfig.Tamano
type Zona = GameConfig.Zona
type Gema = GameConfig.Gema

-- Cualquier tabla que se tira con "1 en N": rarezas y modificadores. Las funciones que tiran
-- son genéricas (<T>) porque Luau no deja pasar { Rareza } donde se pide { Tirable }.
type Tirable = { Id: string, UnoEn: number }

local Reglas = {}

-- Índices por Id para no recorrer las listas en cada golpe.
local rarezas: { [string]: Rareza } = {}
for _, r in GameConfig.Rarezas do
	rarezas[r.Id] = r
end
local modificadores: { [string]: Modificador } = {}
for _, m in GameConfig.Modificadores do
	modificadores[m.Id] = m
end
local tamanos: { [string]: Tamano } = {}
for _, t in GameConfig.Tamanos do
	tamanos[t.Id] = t
end
local gemas: { [string]: Gema } = {}
local gemaPorZona: { [number]: { [string]: Gema } } = {}
for _, g in GameConfig.Gemas do
	gemas[g.Id] = g
	gemaPorZona[g.Zona] = gemaPorZona[g.Zona] or {}
	gemaPorZona[g.Zona][g.Rareza] = g
end

function Reglas.rareza(id: string): Rareza?
	return rarezas[id]
end

function Reglas.modificador(id: string): Modificador?
	return modificadores[id]
end

function Reglas.tamano(id: string): Tamano?
	return tamanos[id]
end

function Reglas.zona(numero: number): Zona?
	return GameConfig.Zonas[numero]
end

function Reglas.gema(id: string): Gema?
	return gemas[id]
end

-- La gema de una zona y rareza (hay exactamente una por pareja).
function Reglas.gemaDe(zona: number, rareza: string): Gema?
	local deZona = gemaPorZona[zona]
	return deZona and deZona[rareza]
end

-- Fuerza = daño por golpe. Es el número grande del HUD y lo que piden las puertas.
function Reglas.fuerza(nivelFuerza: number, pico: number): number
	local F = GameConfig.Fuerza
	local p = GameConfig.Picos[pico] or GameConfig.Picos[1]
	local base = (F.Base + nivelFuerza * F.PorNivel) * (1 + F.Extra) ^ nivelFuerza
	return math.floor(base * p.Multiplicador)
end

-- Lo que cuesta pasar del nivel `nivel` al siguiente (nil si ya está al máximo).
function Reglas.precioFuerza(nivel: number): number?
	local F = GameConfig.Fuerza
	if nivel >= F.NivelMaximo then
		return nil
	end
	return math.floor(F.PrecioInicial * F.Crecimiento ^ nivel)
end

-- Suerte propia del jugador: x1 más lo que suman sus amuletos.
function Reglas.suerteJugador(amuletos: { [string]: boolean }): number
	local s = 1
	for _, a in GameConfig.Amuletos do
		if amuletos[a.Id] then
			s += a.Suerte
		end
	end
	return s
end

-- Suerte con la que se tira la gema de una geoda.
function Reglas.suerteGeoda(suerteJugador: number, zona: number, tamano: string): number
	local z = GameConfig.Zonas[zona]
	local t = tamanos[tamano]
	return suerteJugador * (if z then z.Suerte else 1) * (if t then t.Suerte else 1)
end

function Reglas.vidaGeoda(zona: number, tamano: string): number
	local z = GameConfig.Zonas[zona]
	local t = tamanos[tamano]
	if not z or not t then
		return 1
	end
	return math.max(1, math.floor(t.Vida * z.Dureza))
end

-- Gemas que te llevás al romper una geoda de ese tamaño con ese modificador.
function Reglas.unidades(tamano: string, modificador: string): number
	local t = tamanos[tamano]
	local m = modificadores[modificador]
	return (if t then t.Unidades else 1) * (if m then m.Premio else 1)
end

function Reglas.valorGema(id: string): number
	local g = gemas[id]
	if not g then
		return 0
	end
	local z = GameConfig.Zonas[g.Zona]
	local r = rarezas[g.Rareza]
	return (if z then z.Valor else 0) * (if r then r.Valor else 0)
end

-- Chance de que salga cada fila con esa suerte: se prueba de la más rara a la más común y
-- cada una sale si azar < Suerte / UnoEn. La primera fila (UnoEn = 1) se queda con el resto,
-- así que todo suma 1 (100 %). Devuelve Id -> probabilidad.
function Reglas.probabilidades<T>(tabla: { T }, suerte: number): { [string]: number }
	local r = {}
	local queda = 1 -- probabilidad de que todavía no haya salido ninguna más rara
	for i = #tabla, 1, -1 do
		local fila: Tirable = tabla[i] :: any
		local chance = if i == 1 then 1 else math.min(1, suerte / fila.UnoEn)
		r[fila.Id] = queda * chance
		queda *= 1 - chance
	end
	return r
end

-- Tira una vez con la misma regla. `azar` devuelve un número entre 0 y 1 (en el servidor,
-- Random:NextNumber).
function Reglas.tirar<T>(tabla: { T }, suerte: number, azar: () -> number): string
	for i = #tabla, 2, -1 do
		local fila: Tirable = tabla[i] :: any
		if azar() < suerte / fila.UnoEn then
			return fila.Id
		end
	end
	return ((tabla[1] :: any) :: Tirable).Id
end

-- Tamaño de una geoda nueva en un punto común (por peso; el Jefe tiene puntos propios).
function Reglas.tamanoAlAzar(azar: () -> number): string
	local total = 0
	for _, t in GameConfig.Tamanos do
		total += t.Peso
	end
	local x = azar() * total
	for _, t in GameConfig.Tamanos do
		if t.Peso > 0 then
			x -= t.Peso
			if x < 0 then
				return t.Id
			end
		end
	end
	return GameConfig.Tamanos[1].Id
end

-- Zona más alta que se abre con esa Fuerza.
function Reglas.zonaMaxima(fuerza: number): number
	local maxima = 1
	for _, z in GameConfig.Zonas do
		if fuerza >= z.FuerzaParaAbrir then
			maxima = math.max(maxima, z.Numero)
		end
	end
	return maxima
end

return Reglas
