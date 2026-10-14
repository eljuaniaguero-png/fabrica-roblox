--!strict
-- Datos de cada jugador mientras está en el servidor. Todavía no se guardan: el guardado con
-- ProfileStore es el sistema 6 de la ficha y va a cargar y guardar esta misma tabla.
-- Se publican como atributos del Player para que el cliente los lea (solo para mostrar):
--   Monedas, Fuerza (daño por golpe), Suerte (la del jugador, con amuletos), NivelFuerza,
--   Pico (número), GeodasRotas, Mochila (JSON: gema -> cantidad), Indice ("Cuarzo;Jaspe"),
--   Zonas ("1;2"), Exoticas ("Lava;Neon"), Logros ("Picapiedras;Mitica"), Titulo (el que se
--   muestra), Vitrina, JefesDerrotados, MayorDanioJefe, EventosJugados y los ajustes
--   (EfectosReducidos, AnunciarHallazgos, VerAnuncios, VerTitulos).
-- Fuerza y Monedas también van en la tabla de jugadores (leaderstats).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function nuevos(): Datos
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

function Jugadores.crear(jugador: Player)
	datosDe[jugador] = nuevos()
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

function Jugadores.fuerza(d: Datos): number
	return Reglas.fuerza(d.NivelFuerza, d.Pico)
end

function Jugadores.suerte(d: Datos): number
	return Reglas.suerteJugador(d.Amuletos, d.Logros)
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
function Jugadores.agregarGema(jugador: Player, gema: string, cantidad: number): boolean
	local d = datosDe[jugador]
	if not d or cantidad <= 0 then
		return false
	end
	d.Mochila[gema] = (d.Mochila[gema] or 0) + cantidad
	local nueva = not d.Indice[gema]
	d.Indice[gema] = true
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
	jugador:SetAttribute("Fuerza", fuerza)
	jugador:SetAttribute("Suerte", Jugadores.suerte(d))
	jugador:SetAttribute("NivelFuerza", d.NivelFuerza)
	jugador:SetAttribute("Pico", d.Pico)
	jugador:SetAttribute("GeodasRotas", d.GeodasRotas)
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
