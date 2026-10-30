--!strict
-- Los 5 catalizadores (ficha, "Fracasos útiles, personalidades y catalizadores"), uno por
-- elemento. Van en la tercera ranura de la máquina y crean una variante fija de la especie
-- que sale: otro color, otro elemento, un rasgo especial y un apellido en el nombre.
-- Algunos además cambian la personalidad de la criatura que nace.
-- Para sumar un catalizador alcanza con agregarlo acá (y su color en Paleta.Catalizadores).

local Elementos = require(script.Parent.Elementos)
local Fusion = require(script.Parent.Fusion)
local Paleta = require(script.Parent.Paleta)

export type Catalizador = {
	Clave: string,
	Nombre: string,
	Apellido: string, -- "Glumulo de Hielo"
	Elemento: string, -- clave de Paleta.Elementos: el de la variante
	Color: Color3,
	Rasgo: string, -- efecto especial de la variante (Piezas.variante)
	Icono: string, -- dibujo de shared/Dibujos.luau
	Personalidad: string?, -- si la cambia
}

local Catalizadores = {}

Catalizadores.Lista = {
	{
		Clave = "Rayo",
		Nombre = "Rayo",
		Apellido = "de Rayo",
		Elemento = "Electrico",
		Color = Paleta.Catalizadores.Rayo,
		Rasgo = "Chispas",
		Icono = "rayo",
		Personalidad = "Peleadora",
	},
	{
		Clave = "Hielo",
		Nombre = "Hielo",
		Apellido = "de Hielo",
		Elemento = "Agua",
		Color = Paleta.Catalizadores.Hielo,
		Rasgo = "Escarcha",
		Icono = "copo",
		Personalidad = "Miedosa",
	},
	{
		Clave = "Slime",
		Nombre = "Slime",
		Apellido = "de Slime",
		Elemento = "Planta",
		Color = Paleta.Catalizadores.Slime,
		Rasgo = "Goteo",
		Icono = "gota",
	},
	{
		Clave = "Lava",
		Nombre = "Lava",
		Apellido = "de Lava",
		Elemento = "Fuego",
		Color = Paleta.Catalizadores.Lava,
		Rasgo = "Brasas",
		Icono = "llama",
	},
	{
		Clave = "Sombra",
		Nombre = "Sombra",
		Apellido = "de Sombra",
		Elemento = "Sombra",
		Color = Paleta.Catalizadores.Sombra,
		Rasgo = "Humo",
		Icono = "luna",
		Personalidad = "Vaga",
	},
} :: { Catalizador }

local porClave: { [string]: Catalizador } = {}
for _, c in Catalizadores.Lista do
	porClave[c.Clave] = c
end

function Catalizadores.porClave(clave: string?): Catalizador?
	return if clave then porClave[clave] else nil
end

-- Los catalizadores que conoce un jugador: el de cada elemento del que ya descubrió una
-- especie (Hielo = agua, Slime = planta...) y los que ya tuvo alguna vez.
function Catalizadores.conocidos(
	especies: { [string]: boolean },
	vistos: { [string]: boolean }
): { string }
	local elementos = {}
	for clave in especies do
		local c = Fusion.porClave(clave)
		for _, e in if c then Elementos.de(c) else {} do
			elementos[e] = true
		end
	end
	local conocidos = {}
	for _, c in Catalizadores.Lista do
		if elementos[c.Elemento] or vistos[c.Clave] then
			table.insert(conocidos, c.Clave)
		end
	end
	return conocidos
end

-- "Glumulo de Hielo" (o solo "Glumulo" sin variante).
function Catalizadores.nombre(nombreEspecie: string, variante: string?): string
	local c = Catalizadores.porClave(variante)
	return if c then nombreEspecie .. " " .. c.Apellido else nombreEspecie
end

-- "Rayo:2;Hielo:1" -> { Rayo = 2, Hielo = 1 }
function Catalizadores.leer(texto: string?): { [string]: number }
	local r = {}
	for clave, n in (texto or ""):gmatch("([^;:]+):(%d+)") do
		r[clave] = tonumber(n) or 0
	end
	return r
end

function Catalizadores.escribir(cuentas: { [string]: number }): string
	local partes = {}
	for _, c in Catalizadores.Lista do
		local n = cuentas[c.Clave]
		if n and n > 0 then
			table.insert(partes, c.Clave .. ":" .. n)
		end
	end
	return table.concat(partes, ";")
end

return Catalizadores
