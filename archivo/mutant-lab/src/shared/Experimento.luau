--!strict
-- Experimento del día (ficha, "Parte 8"): una especie misteriosa, la misma para todos los
-- jugadores, que sale sola del número de día (el que da el servidor). Tiene tres pistas.
-- Quien la hace ese día (fusionándola) gana un premio (Config.Experimento).
-- Lo usan el servidor (para premiar) y el cliente (para mostrar la silueta y las pistas).

local Elementos = require(script.Parent.Elementos)
local Especies = require(script.Parent.Especies)
local Fusion = require(script.Parent.Fusion)
local Rasgos = require(script.Parent.Rasgos)

local Experimento = {}

-- Las que pueden salir: las de generación 2 y 3 (las bases se compran).
local candidatas: { Fusion.Criatura } = {}
for _, c in Fusion.todas() do
	if c.Gen >= 2 then
		table.insert(candidatas, c)
	end
end

-- La especie del día `dia` (días desde 1970, en UTC). Se mezcla el número para que no salgan
-- seguidas en el orden de la Mutadex.
function Experimento.especie(dia: number): Fusion.Criatura
	local mezcla = (dia * 2654435761) % 4294967296
	return candidatas[(mezcla // 65536) % #candidatas + 1]
end

-- Las tres pistas: el elemento, un rasgo de su forma y algo de una de sus bases.
function Experimento.pistas(c: Fusion.Criatura): { string }
	local rasgos = Rasgos.de(c)
	local rasgo = rasgos[#rasgos]
	local base = Especies[c.Bases[#c.Bases]]
	return {
		"Es de tipo " .. Elementos.texto(c):lower() .. ".",
		if rasgo
			then "Es una criatura " .. (Rasgos.Textos[rasgo] or rasgo) .. "."
			else "No tiene alas ni cuernos.",
		"Una de sus bases " .. base.Pista .. ".",
	}
end

return Experimento
