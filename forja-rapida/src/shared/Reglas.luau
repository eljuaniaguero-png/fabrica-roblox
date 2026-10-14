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
type Logro = GameConfig.Logro
type Evento = GameConfig.Evento
type Titulo = GameConfig.Titulo
type Pico = GameConfig.Pico
type Amuleto = GameConfig.Amuleto

-- Lo que hace falta para revisar los logros de un jugador (Reglas.logrosNuevos).
export type EstadoLogros = {
	Indice: { [string]: boolean }, -- gemas conseguidas
	Exoticas: { [string]: boolean }, -- modificadores de geodas que rompió
	Rarezas: { [string]: boolean }, -- rarezas que encontró
	GeodasRotas: number,
	JefesDerrotados: number, -- Geodas Ancestrales que ayudó a romper
	EventosJugados: number,
	Logros: { [string]: boolean }, -- los que ya cobró
}

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
local logros: { [string]: Logro } = {}
for _, l in GameConfig.Logros do
	logros[l.Id] = l
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

function Reglas.logro(id: string): Logro?
	return logros[id]
end

-- true si la geoda tiene algún modificador exótico (o una combinación).
function Reglas.esExotica(modificador: string): boolean
	return modificadores[modificador] ~= nil and modificador ~= "Normal"
end

-- Los modificadores simples que forman uno: { "Lava" } o, en una combinación, { "Vacio", "Midas" }.
function Reglas.partes(modificador: string): { string }
	local m = modificadores[modificador]
	if m and m.Partes then
		return m.Partes
	end
	return { modificador }
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

-- Suerte propia del jugador: x1 más lo que suman sus amuletos y los logros que cobró.
function Reglas.suerteJugador(
	amuletos: { [string]: boolean },
	cobrados: { [string]: boolean }?
): number
	local s = 1
	for _, a in GameConfig.Amuletos do
		if amuletos[a.Id] then
			s += a.Suerte
		end
	end
	if cobrados then
		for _, l in GameConfig.Logros do
			if cobrados[l.Id] and l.Premio.Suerte then
				s += l.Premio.Suerte
			end
		end
	end
	return s
end

local function cumple(l: Logro, e: EstadoLogros): boolean
	local n = l.Necesita
	if n.Tipo == "Gemas" then
		for _, g in GameConfig.Gemas do
			if g.Zona == n.Zona and not e.Indice[g.Id] then
				return false
			end
		end
		return true
	elseif n.Tipo == "Modificadores" then
		local cuantos = 0
		local lista: { string } = n.Ids or {}
		for _, id in lista do
			if e.Exoticas[id] then
				cuantos += 1
			end
		end
		return cuantos >= (n.Cuantos or 1)
	elseif n.Tipo == "Rareza" then
		return n.Id ~= nil and e.Rarezas[n.Id] == true
	elseif n.Tipo == "Geodas" then
		return e.GeodasRotas >= (n.Cuantas or math.huge)
	elseif n.Tipo == "Jefes" then
		return e.JefesDerrotados >= (n.Cuantos or math.huge)
	elseif n.Tipo == "Eventos" then
		return e.EventosJugados >= (n.Cuantos or math.huge)
	end
	return false
end

-- Logros que el jugador ya cumple y todavía no cobró, en el orden de GameConfig.Logros.
function Reglas.logrosNuevos(e: EstadoLogros): { Logro }
	local nuevos = {}
	for _, l in GameConfig.Logros do
		if not e.Logros[l.Id] and cumple(l, e) then
			table.insert(nuevos, l)
		end
	end
	return nuevos
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
-- `bonos` (opcional, eventos) multiplica la suerte de algunas filas: { Lava = 4 }.
function Reglas.probabilidades<T>(
	tabla: { T },
	suerte: number,
	bonos: { [string]: number }?
): { [string]: number }
	local r = {}
	local queda = 1 -- probabilidad de que todavía no haya salido ninguna más rara
	for i = #tabla, 1, -1 do
		local fila: Tirable = tabla[i] :: any
		local extra = if bonos then bonos[fila.Id] or 1 else 1
		local chance = if i == 1 then 1 else math.min(1, suerte * extra / fila.UnoEn)
		r[fila.Id] = queda * chance
		queda *= 1 - chance
	end
	return r
end

-- Tira una vez con la misma regla. `azar` devuelve un número entre 0 y 1 (en el servidor,
-- Random:NextNumber).
function Reglas.tirar<T>(
	tabla: { T },
	suerte: number,
	azar: () -> number,
	bonos: { [string]: number }?
): string
	for i = #tabla, 2, -1 do
		local fila: Tirable = tabla[i] :: any
		local extra = if bonos then bonos[fila.Id] or 1 else 1
		if azar() < suerte * extra / fila.UnoEn then
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

-- Eventos del mundo ---------------------------------------------------------------------------

function Reglas.evento(id: string): Evento?
	for _, e in GameConfig.Eventos.Lista do
		if e.Id == id then
			return e
		end
	end
	return nil
end

-- El próximo evento, al azar por Peso, sin repetir el anterior (si hay más de uno).
function Reglas.eventoAlAzar(azar: () -> number, anterior: string?): Evento
	local lista = {}
	local total = 0
	for _, e in GameConfig.Eventos.Lista do
		if e.Id ~= anterior or #GameConfig.Eventos.Lista == 1 then
			table.insert(lista, e)
			total += e.Peso
		end
	end
	local x = azar() * total
	for _, e in lista do
		x -= e.Peso
		if x < 0 then
			return e
		end
	end
	return lista[#lista]
end

-- Vida de la Geoda Ancestral: crece con la Fuerza de todos los que están jugando.
function Reglas.vidaAncestral(fuerzas: { number }): number
	local def = Reglas.evento("JefeAncestral")
	local jefe = if def then def.Jefe else nil
	local vidaPorFuerza = if jefe then jefe.VidaPorFuerza else 250
	local minima = if jefe then jefe.VidaMinima else 3000
	local suma = 0
	for _, f in fuerzas do
		suma += f
	end
	return math.max(minima, math.floor(suma * vidaPorFuerza))
end

-- Exhibición social ---------------------------------------------------------------------------

-- Semana de la clasificación ("S2961"): cambia los lunes a las 00:00 UTC.
-- (El 1/1/1970 fue jueves y el primer lunes, el 5: se cuenta desde ahí.)
function Reglas.semana(segundos: number): string
	return "S" .. tostring(math.floor((segundos - 4 * 86400) / 604800))
end

function Reglas.titulo(id: string): Titulo?
	for _, t in GameConfig.Titulos do
		if t.Id == id then
			return t
		end
	end
	return nil
end

function Reglas.tituloDisponible(id: string, cobrados: { [string]: boolean }): boolean
	local t = Reglas.titulo(id)
	return t ~= nil and (t.Requiere == nil or cobrados[t.Requiere] == true)
end

-- Títulos que tiene un jugador, en el orden de GameConfig.Titulos.
function Reglas.titulosDe(cobrados: { [string]: boolean }): { Titulo }
	local r = {}
	for _, t in GameConfig.Titulos do
		if t.Requiere == nil or cobrados[t.Requiere] then
			table.insert(r, t)
		end
	end
	return r
end

-- La zona abierta más alta de un jugador.
function Reglas.mejorZona(zonas: { [number]: boolean }): number
	local mejor = 1
	for n, abierta in zonas do
		if abierta and GameConfig.Zonas[n] then
			mejor = math.max(mejor, n)
		end
	end
	return mejor
end

-- Monedas que vale una gema común de esa zona (base de los premios de eventos).
function Reglas.valorComun(zona: number): number
	local z = GameConfig.Zonas[zona]
	return if z then z.Valor else 1
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

-- Tienda y Banco (sistema 3) -----------------------------------------------------------------

-- Cuántos niveles de Fuerza se pueden comprar desde `nivel` con `monedas` (hasta `tope`
-- niveles; sin tope = todos los que alcancen) y cuánto cuestan en total.
function Reglas.nivelesFuerza(nivel: number, monedas: number, tope: number?): (number, number)
	local niveles, costo = 0, 0
	while tope == nil or niveles < tope do
		local precio = Reglas.precioFuerza(nivel + niveles)
		if not precio or costo + precio > monedas then
			break
		end
		costo += precio
		niveles += 1
	end
	return niveles, costo
end

-- El pico que sigue al que tenés (nil si ya tenés el mejor). Se compran en orden.
function Reglas.siguientePico(pico: number): (Pico?, number)
	local n = pico + 1
	return GameConfig.Picos[n], n
end

-- El primer amuleto que todavía no tenés (se compran en orden).
function Reglas.siguienteAmuleto(amuletos: { [string]: boolean }): Amuleto?
	for _, a in GameConfig.Amuletos do
		if not amuletos[a.Id] then
			return a
		end
	end
	return nil
end

-- Monedas que da vender toda la mochila (gema -> cantidad).
function Reglas.valorMochila(mochila: { [string]: number }): number
	local total = 0
	for id, cantidad in mochila do
		total += Reglas.valorGema(id) * math.max(0, math.floor(cantidad))
	end
	return total
end

-- Zonas que se abren con esa Fuerza y que todavía no estaban abiertas (en orden).
function Reglas.zonasNuevas(zonas: { [number]: boolean }, fuerza: number): { number }
	local lista = {}
	for _, z in GameConfig.Zonas do
		if not zonas[z.Numero] and fuerza >= z.FuerzaParaAbrir then
			table.insert(lista, z.Numero)
		end
	end
	return lista
end

-- La próxima zona cerrada (para la barra "Próxima zona" del HUD), o nil si están todas.
function Reglas.proximaZona(zonas: { [number]: boolean }): Zona?
	for _, z in GameConfig.Zonas do
		if not zonas[z.Numero] then
			return z
		end
	end
	return nil
end

return Reglas
