--!strict
-- Los 5 elementos (ficha, "Decisiones al aplicar la guía"): orden, nombres y de qué elementos
-- es cada especie. Los colores están en Paleta.Elementos.

local Especies = require(script.Parent.Especies)
local Fusion = require(script.Parent.Fusion)

local Elementos = {}

-- Orden fijo (filtros del panel de fusión, leyendas).
Elementos.Orden = { "Fuego", "Agua", "Planta", "Electrico", "Sombra" }

-- Nombre para mostrar (las claves no llevan tilde).
Elementos.Nombres = {
	Fuego = "Fuego",
	Agua = "Agua",
	Planta = "Planta",
	Electrico = "Eléctrico",
	Sombra = "Sombra",
} :: { [string]: string }

-- Elementos de una especie, sin repetir y en el orden de sus bases.
function Elementos.de(c: Fusion.Criatura): { string }
	local lista = {}
	for _, b in c.Bases do
		local e = Especies[b].Elemento
		if not table.find(lista, e) then
			table.insert(lista, e)
		end
	end
	return lista
end

-- "Agua", "Agua y Planta", "Fuego, Agua y Sombra".
function Elementos.texto(c: Fusion.Criatura): string
	local nombres = {}
	for _, e in Elementos.de(c) do
		table.insert(nombres, Elementos.Nombres[e] or e)
	end
	if #nombres <= 1 then
		return nombres[1] or ""
	end
	local ultimo = table.remove(nombres) :: string
	return table.concat(nombres, ", ") .. " y " .. ultimo
end

function Elementos.tiene(c: Fusion.Criatura, elemento: string): boolean
	for _, b in c.Bases do
		if Especies[b].Elemento == elemento then
			return true
		end
	end
	return false
end

return Elementos
