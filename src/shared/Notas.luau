--!strict
-- Notas de las canciones (en semitonos desde Do) y su velocidad de reproducción en el sample.

local Config = require(script.Parent.Config)

local Notas = {}

function Notas.velocidadReproduccion(semitonos: number): number
	return 2 ^ ((semitonos - Config.SemitonoDelSample) / 12)
end

-- Canción de una zona (si la zona no existe, la de la zona 1).
function Notas.cancionDe(zona: number): Config.Cancion
	local datos = Config.Zonas[zona] or Config.Zonas[1]
	return datos.Cancion
end

-- Nota número `indice` de la canción de la zona (da la vuelta al llegar al final).
function Notas.notaDeZona(zona: number, indice: number): number
	local notas = Notas.cancionDe(zona).Notas
	return notas[(indice - 1) % #notas + 1]
end

return Notas
