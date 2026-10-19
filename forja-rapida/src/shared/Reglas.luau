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
type Cosmetico = GameConfig.Cosmetico
type PlantillaMision = GameConfig.PlantillaMision
type Rama = GameConfig.Rama
type Mascota = GameConfig.Mascota

-- Lo que hace falta para revisar los logros de un jugador (Reglas.logrosNuevos).
export type EstadoLogros = {
	Indice: { [string]: boolean }, -- gemas conseguidas
	Exoticas: { [string]: boolean }, -- modificadores de geodas que rompió
	Rarezas: { [string]: boolean }, -- rarezas que encontró
	GeodasRotas: number,
	JefesDerrotados: number, -- Geodas Ancestrales que ayudó a romper
	EventosJugados: number,
	Logros: { [string]: boolean }, -- los que ya cobró
	-- Grupo 4 (nil = 1 pico, 0 misiones, 0 renaceres)
	Pico: number?,
	MisionesHechas: number?,
	Renacimientos: number?,
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
local gemaPorZona: { [number]: { [string]: { Gema } } } = {}
local secretaPorZona: { [number]: Gema } = {}
for _, g in GameConfig.Gemas do
	gemas[g.Id] = g
	if g.Secreta then
		-- las secretas no salen al tirar la rareza (solo en las vetas ocultas)
		if not g.Lugar then
			secretaPorZona[g.Zona] = g
		end
	else
		-- cada zona tiene varias gemas por rareza (hoy 2): al tirar sale una de ellas al azar
		gemaPorZona[g.Zona] = gemaPorZona[g.Zona] or {}
		local lista = gemaPorZona[g.Zona][g.Rareza] or {}
		table.insert(lista, g)
		gemaPorZona[g.Zona][g.Rareza] = lista
	end
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
-- Las gemas de esa zona y rareza (las secretas no cuentan).
function Reglas.gemasDe(zona: number, rareza: string): { Gema }
	local deZona = gemaPorZona[zona]
	return deZona and deZona[rareza] or {}
end

-- Una gema de esa zona y rareza, todas con la misma chance. `azar` da un número en [0, 1);
-- sin azar devuelve la primera.
function Reglas.gemaDe(zona: number, rareza: string, azar: (() -> number)?): Gema?
	local lista = Reglas.gemasDe(zona, rareza)
	if #lista == 0 then
		return nil
	end
	local i = if azar then math.min(#lista, math.floor(azar() * #lista) + 1) else 1
	return lista[i]
end

-- Fuerza = daño por golpe. Es el número grande del HUD y lo que piden las puertas.
-- `bono`: multiplicador del Renacer y del árbol de Esencia (Reglas.bonos(..).Fuerza).
function Reglas.fuerza(nivelFuerza: number, pico: number, bono: number?): number
	local F = GameConfig.Fuerza
	local p = GameConfig.Picos[pico] or GameConfig.Picos[1]
	local base = (F.Base + nivelFuerza * F.PorNivel) * (1 + F.Extra) ^ nivelFuerza
	return math.floor(base * p.Multiplicador * (bono or 1))
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
			if g.Zona == n.Zona and not g.Secreta and not e.Indice[g.Id] then
				return false
			end
		end
		return true
	elseif
		n.Tipo == "Distintas"
		or n.Tipo == "Lista"
		or n.Tipo == "Secretas"
		or n.Tipo == "Rarezas"
	then
		local tiene, total = Reglas.progreso(l, e)
		return total > 0 and tiene >= total
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
	elseif
		n.Tipo == "Pico"
		or n.Tipo == "Colecciones"
		or n.Tipo == "Misiones"
		or n.Tipo == "Renacer"
	then
		local tiene, total = Reglas.progreso(l, e)
		return tiene >= total
	end
	return false
end

-- Colecciones del Museo que ya cobró (para el logro "Colecciones").
local function coleccionesCompletas(cobrados: { [string]: boolean }): number
	local n = 0
	for _, l in GameConfig.Logros do
		if l.Museo and cobrados[l.Id] then
			n += 1
		end
	end
	return n
end

-- Cuánto lleva un jugador de un logro o colección y cuánto pide (para las barras del Museo).
function Reglas.progreso(l: Logro, e: EstadoLogros): (number, number)
	local n = l.Necesita
	if n.Tipo == "Gemas" then
		local tiene, total = 0, 0
		for _, g in GameConfig.Gemas do
			if g.Zona == n.Zona and not g.Secreta then
				total += 1
				if e.Indice[g.Id] then
					tiene += 1
				end
			end
		end
		return tiene, total
	elseif n.Tipo == "Distintas" or n.Tipo == "Secretas" then
		local tiene = 0
		for id, si in e.Indice do
			local g = gemas[id]
			if si and g and (n.Tipo == "Distintas" or g.Secreta) then
				tiene += 1
			end
		end
		local total = n.Cuantas or 1
		return math.min(tiene, total), total
	elseif n.Tipo == "Lista" or n.Tipo == "Rarezas" then
		local lista: { string } = n.Ids or {}
		local tiene = 0
		for _, id in lista do
			if (n.Tipo == "Lista" and e.Indice[id]) or (n.Tipo == "Rarezas" and e.Rarezas[id]) then
				tiene += 1
			end
		end
		return tiene, #lista
	elseif n.Tipo == "Modificadores" then
		local tiene = 0
		local ids: { string } = n.Ids or {}
		for _, id in ids do
			if e.Exoticas[id] then
				tiene += 1
			end
		end
		local total = n.Cuantos or 1
		return math.min(tiene, total), total
	elseif n.Tipo == "Rareza" then
		return if n.Id and e.Rarezas[n.Id] then 1 else 0, 1
	elseif n.Tipo == "Geodas" then
		local total = n.Cuantas or 1
		return math.min(e.GeodasRotas, total), total
	elseif n.Tipo == "Jefes" then
		local total = n.Cuantos or 1
		return math.min(e.JefesDerrotados, total), total
	elseif n.Tipo == "Eventos" then
		local total = n.Cuantos or 1
		return math.min(e.EventosJugados, total), total
	elseif n.Tipo == "Pico" then
		local total = n.Cuantos or 1
		return math.min(e.Pico or 1, total), total
	elseif n.Tipo == "Colecciones" then
		local total = n.Cuantas or 1
		return math.min(coleccionesCompletas(e.Logros), total), total
	elseif n.Tipo == "Misiones" then
		local total = n.Cuantas or 1
		return math.min(e.MisionesHechas or 0, total), total
	elseif n.Tipo == "Renacer" then
		local total = n.Cuantos or 1
		return math.min(e.Renacimientos or 0, total), total
	end
	return 0, 1
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

-- La Forja: en la mochila, una gema con efecto se guarda como "Id|Efecto".
function Reglas.claveGema(id: string, efecto: string?): string
	return if efecto then id .. "|" .. efecto else id
end

function Reglas.separarClave(clave: string): (string, string?)
	local id, efecto = string.match(clave, "^([^|]+)|(.+)$")
	if id then
		return id, efecto
	end
	return clave, nil
end

function Reglas.efectoForja(id: string): {
	Id: string,
	Nombre: string,
	Peso: number,
	Multiplicador: number,
	Color: string,
}?
	for _, e in GameConfig.Forja.Efectos do
		if e.Id == id then
			return e
		end
	end
	return nil
end

-- Monedas "?" que trae una geoda según la rareza que salió, su tamaño y su modificador.
function Reglas.intentosForja(rareza: string, tamano: string, modificador: string): number
	local I = GameConfig.Forja.Intentos
	local n = if rareza == "Comun" then I.Comun else I.Resto
	if tamano == "Jefe" then
		n += I.Jefe
	end
	if modificador ~= "Normal" then
		n += I.Exotica
	end
	return n
end

-- ¿Esta geoda abre la escena de La Forja? Las demás usan sus monedas "?" solas, al toque
-- (la escena dura unos segundos y romper una geoda chica, uno o dos: frenaría la minería).
function Reglas.forjaConEscena(rareza: string, tamano: string): boolean
	local minima = 0
	local actual = 0
	for i, r in GameConfig.Rarezas do
		if r.Id == GameConfig.Forja.EscenaDesde then
			minima = i
		end
		if r.Id == rareza then
			actual = i
		end
	end
	return actual >= minima or tamano == "Jefe" or tamano == "Ancestral"
end

-- Un intento de la forja. Devuelve "Sube", "Efecto" (con su Id) o "Nada".
-- puedeSubir = false para los minerales secretos (no tienen rareza siguiente en su zona).
function Reglas.intentoForja(
	rareza: string,
	conEfecto: boolean,
	puedeSubir: boolean,
	azar: () -> number
): (string, string?)
	local F = GameConfig.Forja
	local sube = (F.Subir :: { [string]: number })[rareza] or 0
	if puedeSubir and azar() < sube then
		return "Sube", nil
	end
	if not conEfecto and azar() < F.ChanceEfecto then
		local total = 0
		for _, e in F.Efectos do
			total += e.Peso
		end
		local x = azar() * total
		for _, e in F.Efectos do
			x -= e.Peso
			if x < 0 then
				return "Efecto", e.Id
			end
		end
		return "Efecto", F.Efectos[#F.Efectos].Id
	end
	return "Nada", nil
end

-- La rareza que sigue (nil si es la última).
function Reglas.rarezaSiguiente(id: string): string?
	for i, r in GameConfig.Rarezas do
		if r.Id == id then
			local s = GameConfig.Rarezas[i + 1]
			return if s then s.Id else nil
		end
	end
	return nil
end

function Reglas.valorGema(clave: string): number
	local id, efecto = Reglas.separarClave(clave)
	local e = if efecto then Reglas.efectoForja(efecto) else nil
	local mult = if e then e.Multiplicador else 1
	local g = gemas[id]
	if not g then
		return 0
	end
	local z = GameConfig.Zonas[g.Zona]
	local r = rarezas[g.Rareza]
	return (if z then z.Valor else 0) * (if r then r.Valor else 0) * mult
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
-- Daño que hace un golpe: la Fuerza, sin pasarse de la vida que queda y, en las geodas
-- grandes, sin pasarse del tope (GameConfig.Golpe.TopePorSegundo repartido en los golpes por segundo).
function Reglas.danioGolpe(
	fuerza: number,
	tamano: string,
	vida: number,
	vidaMax: number,
	debil: boolean?
): number
	local g = GameConfig.Golpe
	-- en el punto débil pega más fuerte (el tope de las grandes se aplica igual)
	local golpe = if debil then fuerza * g.PuntoDebil.Multiplicador else fuerza
	local hecho = math.min(golpe, vida)
	if g.TamanosConTope[tamano] then
		hecho = math.min(hecho, math.max(1, vidaMax * g.TopePorSegundo / g.PorSegundo))
	end
	return hecho
end

-- Monedas que cuesta viajar a una zona desde el menú Viajar (0 = Lobby, gratis).
function Reglas.precioViaje(zona: number): number
	local z = Reglas.zona(zona)
	if zona <= 0 or not z then
		return 0
	end
	return GameConfig.Viajes.PrecioPorValor * z.Valor
end

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

-- Grupo 3: Museo, cosméticos y secretos -------------------------------------------------------

-- El mineral secreto de un bioma (el de su veta oculta).
function Reglas.gemaSecreta(zona: number): Gema?
	return secretaPorZona[zona]
end

-- Si una geoda de ese tamaño puede dar un mineral secreto: cuál y con qué chance (1 en N).
function Reglas.secretaDe(tamano: string, zona: number): (Gema?, number)
	local t = tamanos[tamano]
	if not t or not t.UnoEnSecreta then
		return nil, 0
	end
	local g = if t.GemaSecreta then gemas[t.GemaSecreta] else secretaPorZona[zona]
	return g, t.UnoEnSecreta
end

local LISTAS_COSMETICOS: { [string]: { Cosmetico } } = {
	Aura = GameConfig.Cosmeticos.Auras,
	Pico = GameConfig.Cosmeticos.Picos,
	Vitrina = GameConfig.Cosmeticos.Vitrinas,
	Decoracion = GameConfig.Cosmeticos.Decoraciones,
	Efecto = GameConfig.Cosmeticos.Efectos, -- Grupo 4: evoluciones del pico
}
local POR_DEFECTO: { [string]: string } = { Pico = "Clasico", Vitrina = "Clasica" }

-- Tipos de cosméticos ("Aura", "Pico", "Vitrina", "Decoracion", "Efecto") y su lista.
function Reglas.tiposCosmeticos(): { [string]: { Cosmetico } }
	return LISTAS_COSMETICOS
end

function Reglas.cosmetico(tipo: string, id: string): Cosmetico?
	local lista: { Cosmetico } = LISTAS_COSMETICOS[tipo] or {}
	for _, c in lista do
		if c.Id == id then
			return c
		end
	end
	return nil
end

-- El logro (colección) que da ese cosmético, o nil si es de los que tiene todo el mundo.
function Reglas.logroDeCosmetico(tipo: string, id: string): Logro?
	for _, l in GameConfig.Logros do
		local c = l.Premio.Cosmetico
		if c and c.Tipo == tipo and c.Id == id then
			return l
		end
	end
	return nil
end

-- ¿Lo puede usar? Los clásicos sí; los demás, si cobró la colección que lo da.
function Reglas.tieneCosmetico(tipo: string, id: string, cobrados: { [string]: boolean }): boolean
	if not Reglas.cosmetico(tipo, id) then
		return false
	end
	if POR_DEFECTO[tipo] == id then
		return true
	end
	local l = Reglas.logroDeCosmetico(tipo, id)
	return l ~= nil and cobrados[l.Id] == true
end

-- Las colecciones del Museo, de la más fácil a la más difícil.
local ORDEN_DIFICULTAD = { Facil = 1, Media = 2, Dificil = 3, Leyenda = 4 }
function Reglas.coleccionesMuseo(): { Logro }
	local lista = {}
	for _, l in GameConfig.Logros do
		if l.Museo then
			table.insert(lista, l)
		end
	end
	table.sort(lista, function(a, b)
		local da = ORDEN_DIFICULTAD[a.Dificultad or "Media"] or 2
		local db = ORDEN_DIFICULTAD[b.Dificultad or "Media"] or 2
		if da ~= db then
			return da < db
		end
		return a.Id < b.Id
	end)
	return lista
end

-- Grupo 4: variantes de roca ------------------------------------------------------------------

-- La variante n de una zona (1 = la de siempre). Si no hay, nil.
function Reglas.variante(zona: number, n: number): GameConfig.Variante?
	local z = GameConfig.Zonas[zona]
	return if z then z.Variantes[n] else nil
end

-- Grupo 4: bonos de Renacer, árbol de Esencia y mascotas --------------------------------------

export type EstadoBonos = {
	Renacimientos: number,
	Ramas: { [string]: number }, -- rama -> nivel comprado
	MascotasEquipadas: { string },
}

export type Bonos = {
	Fuerza: number, -- multiplica la Fuerza
	Monedas: number, -- multiplica lo que te dan al vender
	Suerte: number, -- se suma a tu suerte
	Llaves: number, -- multiplica la chance de encontrar llaves
	Lugares: number, -- mascotas que te acompañan a la vez
	NivelInicial: number, -- niveles de Fuerza con los que arrancás cada renacer
	TopeForja: number, -- monedas "?" que podés tener guardadas
}

local mascotas: { [string]: Mascota } = {}
for _, m in GameConfig.Mascotas.Lista do
	mascotas[m.Id] = m
end
local ramas: { [string]: Rama } = {}
for _, r in GameConfig.Renacer.Ramas do
	ramas[r.Id] = r
end

function Reglas.mascota(id: string): Mascota?
	return mascotas[id]
end

function Reglas.rama(id: string): Rama?
	return ramas[id]
end

function Reglas.bonos(e: EstadoBonos): Bonos
	local R = GameConfig.Renacer
	local n = math.min(e.Renacimientos, R.MaximoBonos)
	local b: Bonos = {
		Fuerza = 1 + n * R.BonoFuerza,
		Monedas = 1 + n * R.BonoMonedas,
		Suerte = 0,
		Llaves = 1,
		Lugares = GameConfig.Mascotas.Lugares,
		NivelInicial = 0,
		TopeForja = GameConfig.Forja.Tope,
	}
	for _, r in R.Ramas do
		local nivel = math.min(e.Ramas[r.Id] or 0, #r.Costos)
		local v = r.Valor * nivel
		if r.Bono == "Fuerza" then
			b.Fuerza += v
		elseif r.Bono == "Monedas" then
			b.Monedas += v
		elseif r.Bono == "Suerte" then
			b.Suerte += v
		elseif r.Bono == "Llaves" then
			b.Llaves += v
		elseif r.Bono == "Lugares" then
			b.Lugares += v
		elseif r.Bono == "NivelInicial" then
			b.NivelInicial += v
		elseif r.Bono == "TopeForja" then
			b.TopeForja += v
		end
	end
	-- solo cuentan las que entran en tus lugares
	for i, id in e.MascotasEquipadas do
		local m = mascotas[id]
		if m and i <= b.Lugares then
			b.Monedas += m.Monedas or 0
			b.Suerte += m.Suerte or 0
		end
	end
	return b
end

-- Grupo 4: Renacer ---------------------------------------------------------------------------

-- Zona que hay que tener abierta para el próximo renacer.
function Reglas.zonaParaRenacer(renacimientos: number): number
	local req = GameConfig.Renacer.Requisito
	return req[math.min(renacimientos + 1, #req)]
end

function Reglas.puedeRenacer(zonas: { [number]: boolean }, renacimientos: number): boolean
	return zonas[Reglas.zonaParaRenacer(renacimientos)] == true
end

-- Esencia que da renacer ahora (tu mejor zona menos 1, como mínimo 1).
function Reglas.esenciaRenacer(zonas: { [number]: boolean }): number
	return math.max(1, (Reglas.mejorZona(zonas) - 1) * GameConfig.Renacer.EsenciaPorZona)
end

-- ¿Ya se ve esta rama en el árbol?
function Reglas.ramaDisponible(id: string, renacimientos: number): boolean
	local r = ramas[id]
	return r ~= nil and renacimientos >= r.Renacer
end

-- Esencia que cuesta el próximo nivel de la rama (nil si ya está al máximo o no existe).
function Reglas.costoRama(id: string, nivel: number): number?
	local r = ramas[id]
	return if r then r.Costos[nivel + 1] else nil
end

-- Vida de una Geoda Renacida: la Fuerza del más fuerte que ya renació x GolpesRenacida.
function Reglas.vidaRenacida(fuerzaMaxima: number): number
	local t = tamanos.Renacida
	local minimo = if t then t.Vida else 400
	return math.max(minimo, math.floor(fuerzaMaxima * GameConfig.Renacer.GolpesRenacida))
end

-- Grupo 4: Ruleta de Mascotas -----------------------------------------------------------------

-- Lo que cuesta una tirada: Ruleta.Precio x lo que vale una gema común de tu mejor zona.
function Reglas.precioRuleta(zonas: { [number]: boolean }): number
	return math.floor(
		GameConfig.Mascotas.Ruleta.Precio * Reglas.valorComun(Reglas.mejorZona(zonas))
	)
end

-- Tira la ruleta: azar() en [0, 1) contra las chances en % (suman 100).
function Reglas.tirarRuleta(azar: () -> number): Mascota
	local lista = GameConfig.Mascotas.Lista
	local total = 0
	for _, m in lista do
		total += m.Chance
	end
	local x = azar() * total
	for _, m in lista do
		x -= m.Chance
		if x < 0 then
			return m
		end
	end
	return lista[#lista]
end

-- ¿Puede sumar esta mascota a las que lo acompañan? (la tiene, le queda una copia libre y hay
-- lugar)
function Reglas.puedeEquipar(
	equipadas: { string },
	id: string,
	tenidas: { [string]: number },
	lugares: number
): boolean
	if not mascotas[id] or #equipadas >= lugares then
		return false
	end
	local usadas = 0
	for _, otra in equipadas do
		if otra == id then
			usadas += 1
		end
	end
	return (tenidas[id] or 0) > usadas
end

-- Grupo 4: misiones --------------------------------------------------------------------------

export type Mision = {
	Id: string, -- la plantilla
	Tipo: string,
	Dificultad: string,
	Meta: number,
	Progreso: number,
	Texto: string,
	Monedas: number,
	Esencia: number,
	Zona: number?, -- "Geodas" en una zona
	Tamano: string?,
	Rareza: string?,
	Accion: string?,
	Logro: string?, -- "Coleccion": la colección a completar
	Base: number?, -- "Nuevo": minerales distintos que tenía al empezar
}

-- Lo que hace falta del jugador para elegir y seguir misiones.
export type EstadoMisiones = {
	Indice: { [string]: boolean },
	Exoticas: { [string]: boolean },
	Rarezas: { [string]: boolean },
	GeodasRotas: number,
	JefesDerrotados: number,
	EventosJugados: number,
	Logros: { [string]: boolean },
	Zonas: { [number]: boolean },
	Secretos: { [number]: boolean },
	Pico: number?,
	MisionesHechas: number?,
	Renacimientos: number?,
}

-- Lo que pasó en el juego y puede hacer avanzar una misión.
export type EventoMision = {
	Tipo: string, -- "Geoda" (se rompió y te llevaste gema), "Gema" (te salió) o "Accion"
	Zona: number?,
	Tamano: string?,
	Modificador: string?,
	Rareza: string?,
	Accion: string?,
}

local ordenRareza: { [string]: number } = {}
for i, r in GameConfig.Rarezas do
	ordenRareza[r.Id] = i
end

-- Minerales distintos del Museo que tiene (los que existen).
function Reglas.distintas(indice: { [string]: boolean }): number
	local n = 0
	for id, si in indice do
		if si and gemas[id] then
			n += 1
		end
	end
	return n
end

-- La colección del Museo que conviene pedir: la más avanzada (al menos la mitad) que no sea
-- de Leyenda ni esté completa.
local function coleccionParaMision(e: EstadoMisiones): Logro?
	local mejor: Logro? = nil
	local mejorParte = 0.5
	for _, l in GameConfig.Logros do
		if l.Museo and l.Dificultad ~= "Leyenda" and not e.Logros[l.Id] then
			local tiene, total = Reglas.progreso(l, e)
			local parte = tiene / math.max(1, total)
			if tiene < total and parte >= mejorParte then
				mejor, mejorParte = l, parte
			end
		end
	end
	return mejor
end

local function posible(p: PlantillaMision, e: EstadoMisiones): boolean
	if p.Dificultad == GameConfig.Misiones.LugarPrestigio and (e.Renacimientos or 0) < 1 then
		return false
	end
	if p.ZonaMinima and Reglas.mejorZona(e.Zonas) < p.ZonaMinima then
		return false
	end
	if p.Tipo == "Nuevo" and Reglas.distintas(e.Indice) >= #GameConfig.Gemas then
		return false
	end
	if p.Tipo == "Coleccion" and not coleccionParaMision(e) then
		return false
	end
	if p.Necesita == "Secreto" then
		return next(e.Secretos) ~= nil
	elseif p.Necesita == "PuertaCerrada" then
		for _, z in GameConfig.Zonas do
			if e.Zonas[z.Numero] and not e.Secretos[z.Numero] then
				return true
			end
		end
		return false
	elseif p.Necesita == "Zona2" then
		return e.Zonas[2] == true
	end
	return true
end

-- Una misión nueva de esa dificultad, al azar entre las que se pueden hacer (y que no sean de
-- la misma plantilla que las de `evitar`, si se puede). nil si no hay ninguna posible.
function Reglas.nuevaMision(
	dificultad: string,
	e: EstadoMisiones,
	azar: () -> number,
	evitar: { [string]: boolean }?
): Mision?
	local candidatas: { PlantillaMision } = {}
	local repetidas: { PlantillaMision } = {}
	for _, p in GameConfig.Misiones.Plantillas do
		if p.Dificultad == dificultad and posible(p, e) then
			table.insert(if evitar and evitar[p.Id] then repetidas else candidatas, p)
		end
	end
	if #candidatas == 0 then
		candidatas = repetidas
	end
	if #candidatas == 0 then
		return nil
	end
	local p = candidatas[math.clamp(math.floor(azar() * #candidatas) + 1, 1, #candidatas)]
	local desde, hasta = p.Meta[1], p.Meta[2] or p.Meta[1]
	local meta = math.clamp(desde + math.floor(azar() * (hasta - desde + 1)), desde, hasta)
	local zona = Reglas.mejorZona(e.Zonas)
	local d = GameConfig.Misiones.Dificultades[dificultad]
	local m: Mision = {
		Id = p.Id,
		Tipo = p.Tipo,
		Dificultad = dificultad,
		Meta = meta,
		Progreso = 0,
		Texto = "",
		Monedas = math.floor((if d then d.Monedas else 0) * Reglas.valorComun(zona)),
		Esencia = if d then d.Esencia else 0,
		Tamano = p.Tamano,
		Rareza = p.Rareza,
		Accion = p.Accion,
	}
	if p.Tipo == "Coleccion" then
		local l = coleccionParaMision(e) :: Logro
		m.Logro = l.Id
		m.Meta = 1
		m.Texto = p.Texto:format(l.Nombre)
	elseif p.EnZona then
		m.Zona = zona
		local z = GameConfig.Zonas[zona]
		m.Texto = p.Texto:format(meta, if z then z.Nombre else "")
	else
		m.Texto = p.Texto:format(meta)
	end
	if p.Tipo == "Nuevo" then
		m.Base = Reglas.distintas(e.Indice)
	end
	return m
end

-- Cuánto avanza la misión con lo que pasó (0 si no tiene que ver).
function Reglas.avanceMision(m: Mision, ev: EventoMision): number
	if ev.Tipo == "Geoda" then
		if m.Tipo == "Geodas" then
			local tamanoOk = m.Tamano == nil or m.Tamano == ev.Tamano
			local zonaOk = m.Zona == nil or m.Zona == ev.Zona
			return if tamanoOk and zonaOk then 1 else 0
		elseif m.Tipo == "Exotica" then
			return if ev.Modificador and Reglas.esExotica(ev.Modificador) then 1 else 0
		elseif m.Tipo == "Jefe" then
			return if ev.Tamano == "Jefe" or ev.Tamano == "Ancestral" then 1 else 0
		end
	elseif ev.Tipo == "Gema" and m.Tipo == "Rareza" then
		local pide = ordenRareza[m.Rareza or ""] or math.huge
		return if (ordenRareza[ev.Rareza or ""] or 0) >= pide then 1 else 0
	elseif ev.Tipo == "Accion" and m.Tipo == "Accion" then
		return if ev.Accion == m.Accion then 1 else 0
	end
	return 0
end

-- Progreso de las misiones que dependen del estado del jugador ("Nuevo" y "Coleccion"); las
-- demás devuelven el que ya tienen.
function Reglas.progresoMision(m: Mision, e: EstadoMisiones): number
	if m.Tipo == "Nuevo" then
		return math.max(0, Reglas.distintas(e.Indice) - (m.Base or 0))
	elseif m.Tipo == "Coleccion" then
		return if m.Logro and e.Logros[m.Logro] then 1 else 0
	end
	return m.Progreso
end

return Reglas
