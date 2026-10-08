--!strict
-- Pistas de las siluetas de la Mutadex. Cada pista cuenta algo de una de las bases
-- que forman la especie, sin decir su nombre: "Viene de una criatura que vuela".
-- Una gen 2 tiene 2 pistas y una gen 3 tiene 3. Las bases no tienen pistas (se compran).

local Config = require(script.Parent.Config)
local Especies = require(script.Parent.Especies)
local Fusion = require(script.Parent.Fusion)

local Pistas = {}

function Pistas.maximo(c: Fusion.Criatura): number
	if c.Gen == 1 then
		return 0
	end
	return #c.Bases
end

-- Texto de la pista número i (empieza en 1).
function Pistas.texto(c: Fusion.Criatura, i: number): string
	local base = Especies[c.Bases[i]]
	return "Viene de una criatura que " .. base.Pista .. "."
end

-- Precio de la próxima pista, según cuántas compraste en total.
function Pistas.costo(compradas: number): number
	return Config.Pistas.CostoBase * (compradas + 1)
end

-- "1-2:1;3-6:2" -> { ["1-2"] = 1, ["3-6"] = 2 }
function Pistas.leer(texto: string?): { [string]: number }
	local r = {}
	for clave, n in (texto or ""):gmatch("([^;:]+):(%d+)") do
		r[clave] = tonumber(n) or 0
	end
	return r
end

function Pistas.escribir(pistas: { [string]: number }): string
	local partes = {}
	for clave, n in pistas do
		table.insert(partes, clave .. ":" .. n)
	end
	table.sort(partes)
	return table.concat(partes, ";")
end

return Pistas
