--!strict
-- Metas largas (ficha, "Parte 8"): siempre a la vista en el menú Misiones, cada una con su
-- premio y un trofeo que queda en el estante del laboratorio (9 metas, 9 lugares).
-- Las de completar una generación ya pagan su festejo (Coleccion.luau): solo dan el trofeo.
-- Se publican en el atributo "Metas" (JSON: Clave, Texto, Progreso, Meta, Cumplida).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Remotos = require(script.Parent.Remotos)

local C = Config.Metas

type Meta = {
	Clave: string,
	Texto: string,
	Corto: string, -- el que va en el trofeo
	Meta: number,
	Premio: number, -- fusiones de gen 2
	Color: Color3,
	progreso: (d: Jugadores.Datos) -> number,
}

local function especiesDeGen(d: Jugadores.Datos, gen: number): number
	local n = 0
	for clave in d.Especies do
		local c = Fusion.porClave(clave)
		if c and c.Gen == gen and not c.Especial then
			n += 1
		end
	end
	return n
end

local function totalDeGen(gen: number): number
	local n = 0
	for _, c in Fusion.todas() do
		if c.Gen == gen then
			n += 1
		end
	end
	return n
end

local function cantidad(t: { [string]: any }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

local METAS: { Meta } = {
	{
		Clave = "Gen1",
		Texto = "Descubrí todas las especies base",
		Corto = "Bases",
		Meta = totalDeGen(1),
		Premio = 0,
		Color = Paleta.Generaciones[1],
		progreso = function(d)
			return especiesDeGen(d, 1)
		end,
	},
	{
		Clave = "Gen2",
		Texto = "Descubrí todas las de generación 2",
		Corto = "Generación 2",
		Meta = totalDeGen(2),
		Premio = 0,
		Color = Paleta.Generaciones[2],
		progreso = function(d)
			return especiesDeGen(d, 2)
		end,
	},
	{
		Clave = "Gen3",
		Texto = "Descubrí todas las de generación 3",
		Corto = "Generación 3",
		Meta = totalDeGen(3),
		Premio = 0,
		Color = Paleta.Generaciones[3],
		progreso = function(d)
			return especiesDeGen(d, 3)
		end,
	},
	{
		Clave = "Fusiones",
		Texto = "Hacé " .. C.Fusiones .. " fusiones",
		Corto = C.Fusiones .. " fusiones",
		Meta = C.Fusiones,
		Premio = C.Premio,
		Color = Paleta.Acento,
		progreso = function(d)
			return d.Fusiones
		end,
	},
	{
		Clave = "Pedidos",
		Texto = "Entregá " .. C.Pedidos .. " pedidos",
		Corto = C.Pedidos .. " pedidos",
		Meta = C.Pedidos,
		Premio = C.Premio,
		Color = Paleta.Dorado,
		progreso = function(d)
			return d.Entregados
		end,
	},
	{
		Clave = "Variantes",
		Texto = "Conseguí las " .. #Catalizadores.Lista .. " variantes de una especie",
		Corto = "Variantes",
		Meta = #Catalizadores.Lista,
		Premio = C.Premio,
		Color = Paleta.Catalizadores.Hielo,
		progreso = function(d)
			local mejor = 0
			for _, vistas in d.Variantes do
				mejor = math.max(mejor, cantidad(vistas))
			end
			return mejor
		end,
	},
	{
		Clave = "Personalidades",
		Texto = "Conseguí las " .. #Personalidades.Orden .. " personalidades",
		Corto = "Personalidades",
		Meta = #Personalidades.Orden,
		Premio = C.Premio,
		Color = Paleta.Alerta,
		progreso = function(d)
			local vistas = {}
			for _, sellos in d.Sellos do
				for p in sellos do
					vistas[p] = true
				end
			end
			return cantidad(vistas)
		end,
	},
	{
		Clave = "Mutantes",
		Texto = "Conseguí " .. C.Mutantes .. " especies mutantes",
		Corto = "Mutantes",
		Meta = C.Mutantes,
		Premio = C.Premio,
		Color = Paleta.Mutante,
		progreso = function(d)
			return cantidad(d.Mutantes)
		end,
	},
	{
		Clave = "Especial",
		Texto = "Conseguí una especie especial (día 7 del premio diario)",
		Corto = "Especial",
		Meta = 1,
		Premio = C.Premio,
		Color = Paleta.Elementos.Electrico,
		progreso = function(d)
			return cantidad(d.Especiales)
		end,
	},
}

local Metas = {}

-- Publica la lista y pone los trofeos en el estante.
function Metas.publicar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local lista = {}
	local trofeos: { Laboratorios.Trofeo } = {}
	for i, m in METAS do
		local cumplida = d.Metas[m.Clave] == true
		table.insert(lista, {
			Clave = m.Clave,
			Texto = m.Texto,
			Progreso = math.min(m.progreso(d), m.Meta),
			Meta = m.Meta,
			Cumplida = cumplida,
			Premio = m.Premio,
		})
		if cumplida then
			table.insert(trofeos, { Lugar = i, Color = m.Color, Texto = m.Corto })
		end
	end
	jugador:SetAttribute("Metas", HttpService:JSONEncode(lista))
	Laboratorios.actualizarTrofeos(jugador, trofeos)
end

-- Marca las metas que se cumplieron, paga el premio y avisa con un cartel (cada una).
function Metas.revisar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local nuevas = {}
	for _, m in METAS do
		if not d.Metas[m.Clave] and m.progreso(d) >= m.Meta then
			d.Metas[m.Clave] = true
			local premio = math.round(m.Premio * Mejoras.fusion(Jugadores.cantidadEspecies(d)))
			d.ADN += premio
			table.insert(nuevas, { Meta = m, Premio = premio })
		end
	end
	if #nuevas == 0 then
		return
	end
	Jugadores.publicar(jugador)
	Metas.publicar(jugador)
	for _, n in nuevas do
		Remotos.Celebracion:FireClient(jugador, {
			Gen = 0,
			Premio = n.Premio,
			Completo = false,
			Titulo = "¡META CUMPLIDA!",
			Texto = n.Meta.Corto,
			Detalle = (if n.Premio > 0 then "+" .. Formato.numero(n.Premio) .. " ADN · " else "")
				.. "Nuevo trofeo en tu laboratorio",
		})
	end
end

return Metas
