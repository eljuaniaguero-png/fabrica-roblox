--!strict
-- Niveles por pasos totales históricos (nunca bajan). Lo usan el servidor (puertas, subir de nivel)
-- y el cliente (HUD, carteles de las puertas).

local Config = require(script.Parent.Config)

local Niveles = {}

-- Pasos que hacen falta para pasar del nivel `nivel` al siguiente.
function Niveles.pasosDelNivel(nivel: number): number
	local ajustes = Config.Niveles
	return math.max(ajustes.PasosPrimerNivel + ajustes.PasosExtraPorNivel * (nivel - 1), 1)
end

-- Pasos totales que hacen falta para llegar a `nivel` (el nivel 1 es con 0 pasos).
function Niveles.pasosParaLlegar(nivel: number): number
	local total = 0
	for n = 1, nivel - 1 do
		total += Niveles.pasosDelNivel(n)
	end
	return total
end

-- Nivel que dan estos pasos totales, los pasos que llevás dentro de ese nivel
-- y los que pide el nivel para pasar al siguiente.
function Niveles.progreso(pasosTotales: number): (number, number, number)
	local nivel = 1
	local restante = pasosTotales
	while restante >= Niveles.pasosDelNivel(nivel) do
		restante -= Niveles.pasosDelNivel(nivel)
		nivel += 1
	end
	return nivel, restante, Niveles.pasosDelNivel(nivel)
end

function Niveles.nivelDe(pasosTotales: number): number
	local nivel = Niveles.progreso(pasosTotales)
	return nivel
end

return Niveles
