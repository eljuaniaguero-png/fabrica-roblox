--!strict
-- Convierte una nota de la melodía (en semitonos desde Do) en la velocidad de reproducción del sample.

local Config = require(script.Parent.Config)

local Notas = {}

function Notas.velocidadReproduccion(semitonos: number): number
	return 2 ^ ((semitonos - Config.SemitonoDelSample) / 12)
end

-- Devuelve la nota número `indice` de la melodía (da la vuelta al llegar al final).
function Notas.notaDeMelodia(indice: number): number
	local melodia = Config.Melodia
	return melodia[(indice - 1) % #melodia + 1]
end

return Notas
