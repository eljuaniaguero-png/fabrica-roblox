--!strict
-- Datos de cada jugador mientras está en el servidor. Los carga y guarda Guardado.luau
-- (ProfileStore) con esta misma tabla.
-- Se publican como atributos del Player para que el cliente los lea (solo para mostrar):
--   Monedas, Fuerza (daño por golpe), Suerte (la del jugador, con amuletos), NivelFuerza,
--   Pico (número), Amuletos ("Trebol;Herradura"), GeodasRotas, Mochila (JSON: gema ->
--   cantidad), Indice ("Cuarzo;Jaspe"), Zonas ("1;2"), Exoticas ("Lava;Neon"),
--   Logros ("Picapiedras;Mitica"), Titulo (el que se muestra), Vitrina, JefesDerrotados,
--   MayorDanioJefe, EventosJugados y los ajustes (EfectosReducidos, AnunciarHallazgos,
--   VerAnuncios, VerTitulos).
--   Grupo 3: Museo (JSON: gema -> { cantidad, primera vez }), Rarezas, Llaves ("1;3"),
--   Secretos (puertas abiertas), Cofres, Aura, DisenoPico, EstiloVitrina, Decoracion y
--   BendicionFin (hora del servidor).
--   Grupo 4: Misiones (JSON: las de ahora), MisionesHechas, CambioMision (hora del servidor del
--   último cambio), Renacimientos, Esencia, Ramas (JSON: rama -> nivel), Mascotas (JSON:
--   mascota -> cuántas), MascotasEquipadas (JSON: lista), EfectoPico, BonoFuerza, BonoMonedas,
--   BonoSuerte y LugaresMascota (para mostrar los bonos del Renacer, el árbol y las mascotas).
-- Fuerza y Monedas también van en la tabla de jugadores (leaderstats).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Remotos = require(script.Parent.Remotos)

export type Datos = {
	Monedas: number,
	NivelFuerza: number,
	Pico: number, -- el mejor que compraste (GameConfig.Picos); siempre usás ese
	Amuletos: { [string]: boolean },
	Mochila: { [string]: number }, -- gema -> cantidad sin vender
	Indice: { [string]: boolean }, -- gemas que conseguiste alguna vez
	Zonas: { [number]: boolean }, -- zonas abiertas
	GeodasRotas: number,
	-- Descubrimientos (Grupo 1)
	Exoticas: { [string]: boolean }, -- modificadores de geodas que rompió (con combinaciones)
	Rarezas: { [string]: boolean }, -- rarezas que encontró alguna vez
	Logros: { [string]: boolean }, -- logros y colecciones ya cobrados
	Ajustes: Ajustes,
	-- Eventos y exhibición (Grupos 6 y 7)
	EventosJugados: number,
	JefesDerrotados: number,
	MayorDanioJefe: number, -- récord personal de daño a una Geoda Ancestral
	MejorPuestoJefe: number, -- 0 = nunca
	Titulo: string?, -- el que eligió (nil = el último que desbloqueó)
	Vitrina: string?, -- gema que eligió mostrar (nil = su hallazgo más raro)
	Hallazgos: { Hallazgo }, -- sus mejores hallazgos, del más raro al menos raro
	-- Grupo 3: Museo, secretos y cosméticos
	Museo: { [string]: Ficha }, -- gema -> cuántas encontró en total y cuándo fue la primera
	Llaves: { [number]: boolean }, -- llaves que tiene sin usar (una por bioma)
	Secretos: { [number]: boolean }, -- puertas secretas que abrió
	Cofres: { [string]: boolean }, -- cofres de tesoro que ya abrió
	Equipado: { [string]: string }, -- cosmético elegido por tipo (Aura, Pico, Vitrina, Decoracion)
	BendicionFin: number, -- hasta cuándo dura la bendición del altar (hora del servidor)
	UltimoAltar: number, -- cuándo usó un altar por última vez (hora del servidor)
	-- Grupo 4: misiones, renacer y mascotas
	Misiones: { Reglas.Mision }, -- las de ahora (una por dificultad)
	MisionesHechas: number,
	CambioMision: number, -- cuándo cambió una misión por última vez (hora del servidor)
	Renacimientos: number,
	Esencia: number, -- la que tiene sin gastar
	Ramas: { [string]: number }, -- rama del árbol de Esencia -> nivel
	Mascotas: { [string]: number }, -- mascota -> cuántas tiene
	MascotasEquipadas: { string }, -- las que lo acompañan (puede repetir si tiene copias)
	-- La Forja
	FichasForja: number, -- monedas "?" guardadas (tope GameConfig.Forja.Tope)
	ForjaPendiente: Pendiente?, -- la piedra que está forjando (se entrega una sola vez)
}

-- La Forja: piedra de una geoda rota que todavía no entró a la mochila (Forja.luau).
export type Pendiente = {
	Id: number,
	Gema: string,
	Rareza: string,
	Efecto: string?,
	Zona: number,
	Secreta: boolean, -- mineral secreto: no sube de rareza
	Unidades: number,
	Quedan: number, -- monedas "?" de esta geoda sin usar
	Usados: number,
	Subio: number, -- cuántas rarezas subió
	Vence: number, -- os.clock() en que se entrega sola
	Ultimo: number, -- os.clock() del último intento
	Geoda: Model?,
	Modificador: string,
	Suerte: number,
}

-- Lo que el Museo guarda de cada mineral.
export type Ficha = {
	Cantidad: number,
	Primera: number, -- os.time() de la primera vez (0 = no se sabe)
}

-- Ajustes del jugador (nil = el valor por defecto).
export type Ajustes = {
	EfectosReducidos: boolean?, -- nil = que decida la calidad gráfica
	AnunciarHallazgos: boolean?, -- nil = sí
	VerAnuncios: boolean?, -- nil = sí (los de hallazgos de otros)
	VerTitulos: boolean?, -- nil = sí (los títulos arriba de las cabezas)
}

export type Hallazgo = {
	Gema: string,
	Rareza: string,
	UnoEn: number,
	Modificador: string,
	Cuando: number,
}

local datosDe: { [Player]: Datos } = {}

local Jugadores = {}

function Jugadores.nuevos(): Datos
	return {
		Monedas = 0,
		NivelFuerza = 0,
		Pico = 1,
		Amuletos = {},
		Mochila = {},
		Indice = {},
		Zonas = { [1] = true },
		GeodasRotas = 0,
		Exoticas = {},
		Rarezas = {},
		Logros = {},
		Ajustes = {},
		EventosJugados = 0,
		JefesDerrotados = 0,
		MayorDanioJefe = 0,
		MejorPuestoJefe = 0,
		Titulo = nil,
		Vitrina = nil,
		Hallazgos = {},
		Museo = {},
		Llaves = {},
		Secretos = {},
		Cofres = {},
		Equipado = {},
		BendicionFin = 0,
		UltimoAltar = 0,
		Misiones = {},
		MisionesHechas = 0,
		CambioMision = 0,
		Renacimientos = 0,
		Esencia = 0,
		Ramas = {},
		Mascotas = {},
		MascotasEquipadas = {},
		FichasForja = 0,
		ForjaPendiente = nil,
	}
end

local function claves<K>(t: { [K]: boolean }): string
	local lista = {}
	for k, si in t do
		if si then
			table.insert(lista, tostring(k))
		end
	end
	table.sort(lista)
	return table.concat(lista, ";")
end

local function valor(carpeta: Instance, nombre: string): NumberValue
	local v = carpeta:FindFirstChild(nombre)
	if v and v:IsA("NumberValue") then
		return v
	end
	local nuevo = Instance.new("NumberValue")
	nuevo.Name = nombre
	nuevo.Parent = carpeta
	return nuevo
end

-- `datos`: los que cargó Guardado (nil = jugador nuevo, para las pruebas).
function Jugadores.crear(jugador: Player, datos: Datos?)
	datosDe[jugador] = datos or Jugadores.nuevos()
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	valor(stats, "Fuerza")
	valor(stats, "Monedas")
	stats.Parent = jugador
	Jugadores.publicar(jugador)
end

function Jugadores.obtener(jugador: Player): Datos?
	return datosDe[jugador]
end

function Jugadores.quitar(jugador: Player)
	datosDe[jugador] = nil
end

function Jugadores.todos(): { [Player]: Datos }
	return datosDe
end

-- Grupo 4: bonos del Renacer, del árbol de Esencia y de las mascotas que lo acompañan.
function Jugadores.bonos(d: Datos): Reglas.Bonos
	return Reglas.bonos(d)
end

function Jugadores.fuerza(d: Datos): number
	return Reglas.fuerza(d.NivelFuerza, d.Pico, Jugadores.bonos(d).Fuerza)
end

function Jugadores.suerte(d: Datos): number
	return Reglas.suerteJugador(d.Amuletos, d.Logros) + Jugadores.bonos(d).Suerte
end

-- La bendición del altar (Grupo 3): multiplica la suerte mientras dura.
function Jugadores.bendicion(d: Datos): number
	return if Workspace:GetServerTimeNow() < d.BendicionFin
		then GameConfig.Secretos.Altar.Suerte
		else 1
end

-- El título que se muestra: el elegido (si todavía lo tiene) o el último que desbloqueó.
function Jugadores.titulo(d: Datos): string
	if d.Titulo and Reglas.tituloDisponible(d.Titulo, d.Logros) then
		return d.Titulo
	end
	local lista = Reglas.titulosDe(d.Logros)
	return lista[#lista].Id
end

-- Suma gemas a la mochila. Devuelve true si es la primera vez que consigue esa gema (Índice).
-- La Forja: con efecto, en la mochila va como "Id|Efecto" (Museo e Índice cuentan la gema).
function Jugadores.agregarGema(
	jugador: Player,
	gema: string,
	cantidad: number,
	efecto: string?
): boolean
	local d = datosDe[jugador]
	if not d or cantidad <= 0 then
		return false
	end
	local clave = Reglas.claveGema(gema, efecto)
	d.Mochila[clave] = (d.Mochila[clave] or 0) + cantidad
	local nueva = not d.Indice[gema]
	d.Indice[gema] = true
	local ficha = d.Museo[gema]
	if ficha then
		ficha.Cantidad += cantidad
	else
		d.Museo[gema] = { Cantidad = cantidad, Primera = os.time() }
	end
	d.GeodasRotas += 1
	Jugadores.publicar(jugador)
	return nueva
end

function Jugadores.publicar(jugador: Player)
	local d = datosDe[jugador]
	if not d then
		return
	end
	local fuerza = Jugadores.fuerza(d)
	jugador:SetAttribute("Monedas", d.Monedas)
	jugador:SetAttribute("Velocidad", Jugadores.bonos(d).Velocidad) -- la aplica Velocidad.luau
	jugador:SetAttribute("Fuerza", fuerza)
	jugador:SetAttribute("Suerte", Jugadores.suerte(d))
	jugador:SetAttribute("NivelFuerza", d.NivelFuerza)
	jugador:SetAttribute("Pico", d.Pico)
	jugador:SetAttribute("Amuletos", claves(d.Amuletos))
	jugador:SetAttribute("GeodasRotas", d.GeodasRotas)
	jugador:SetAttribute("FichasForja", d.FichasForja)
	jugador:SetAttribute("Mochila", HttpService:JSONEncode(d.Mochila))
	jugador:SetAttribute("Indice", claves(d.Indice))
	jugador:SetAttribute("Zonas", claves(d.Zonas))
	jugador:SetAttribute("Exoticas", claves(d.Exoticas))
	jugador:SetAttribute("Logros", claves(d.Logros))
	jugador:SetAttribute("EfectosReducidos", d.Ajustes.EfectosReducidos)
	jugador:SetAttribute("AnunciarHallazgos", d.Ajustes.AnunciarHallazgos ~= false)
	jugador:SetAttribute("VerAnuncios", d.Ajustes.VerAnuncios ~= false)
	jugador:SetAttribute("VerTitulos", d.Ajustes.VerTitulos ~= false)
	jugador:SetAttribute("Titulo", Jugadores.titulo(d))
	jugador:SetAttribute("Vitrina", d.Vitrina)
	jugador:SetAttribute("EventosJugados", d.EventosJugados)
	jugador:SetAttribute("JefesDerrotados", d.JefesDerrotados)
	jugador:SetAttribute("MayorDanioJefe", d.MayorDanioJefe)
	-- Grupo 3
	local museo = {}
	for id, f in d.Museo do
		museo[id] = { f.Cantidad, f.Primera }
	end
	jugador:SetAttribute("Museo", HttpService:JSONEncode(museo))
	jugador:SetAttribute("Rarezas", claves(d.Rarezas))
	jugador:SetAttribute("Llaves", claves(d.Llaves))
	jugador:SetAttribute("Secretos", claves(d.Secretos))
	jugador:SetAttribute("Cofres", claves(d.Cofres))
	jugador:SetAttribute("Aura", d.Equipado.Aura or "")
	jugador:SetAttribute("DisenoPico", d.Equipado.Pico or "Clasico")
	jugador:SetAttribute("EstiloVitrina", d.Equipado.Vitrina or "Clasica")
	jugador:SetAttribute("Decoracion", d.Equipado.Decoracion or "")
	jugador:SetAttribute("BendicionFin", d.BendicionFin)
	-- Grupo 4
	local misiones = {}
	for _, m in d.Misiones do
		table.insert(misiones, {
			Id = m.Id,
			Texto = m.Texto,
			Dificultad = m.Dificultad,
			Meta = m.Meta,
			Progreso = m.Progreso,
			Monedas = m.Monedas,
			Esencia = m.Esencia,
		})
	end
	local bonos = Jugadores.bonos(d)
	jugador:SetAttribute("Misiones", HttpService:JSONEncode(misiones))
	jugador:SetAttribute("MisionesHechas", d.MisionesHechas)
	jugador:SetAttribute("CambioMision", d.CambioMision)
	jugador:SetAttribute("Renacimientos", d.Renacimientos)
	jugador:SetAttribute("Esencia", d.Esencia)
	jugador:SetAttribute("Ramas", HttpService:JSONEncode(d.Ramas))
	jugador:SetAttribute("Mascotas", HttpService:JSONEncode(d.Mascotas))
	jugador:SetAttribute("MascotasEquipadas", HttpService:JSONEncode(d.MascotasEquipadas))
	jugador:SetAttribute("EfectoPico", d.Equipado.Efecto or "")
	jugador:SetAttribute("BonoFuerza", bonos.Fuerza)
	jugador:SetAttribute("BonoMonedas", bonos.Monedas)
	jugador:SetAttribute("BonoSuerte", bonos.Suerte)
	jugador:SetAttribute("LugaresMascota", bonos.Lugares)
	local stats = jugador:FindFirstChild("leaderstats")
	if stats then
		valor(stats, "Fuerza").Value = fuerza
		valor(stats, "Monedas").Value = d.Monedas
	end
end

-- Ajustes que elige el jugador. El cliente pide; el servidor revisa el nombre, el tipo y la
-- frecuencia y lo publica (y se guarda con el resto).
local AJUSTES = {
	EfectosReducidos = true,
	AnunciarHallazgos = true,
	VerAnuncios = true,
	VerTitulos = true,
}
local ultimoAjuste: { [Player]: number } = {}
local function alPedirAjuste(jugador: Player, nombre: unknown, elegido: unknown)
	local d = datosDe[jugador]
	if
		not d
		or typeof(nombre) ~= "string"
		or not AJUSTES[nombre]
		or typeof(elegido) ~= "boolean"
	then
		return
	end
	local ahora = os.clock()
	if ultimoAjuste[jugador] and ahora - ultimoAjuste[jugador] < 0.5 then
		return
	end
	ultimoAjuste[jugador] = ahora
	local ajustes: any = d.Ajustes
	ajustes[nombre] = elegido
	Jugadores.publicar(jugador)
end

function Jugadores.iniciar()
	Remotos.Ajustes.OnServerEvent:Connect(alPedirAjuste)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimoAjuste[jugador] = nil
	end)
end

return Jugadores
