--!strict
-- Cuánto ADN cuesta una fusión (ficha, punto 6). Lo usan el servidor (para cobrar)
-- y el cliente (para mostrar el precio antes de confirmar).

local Config = require(script.Parent.Config)

local E = Config.Economia

local Costos = {}

-- Generación que saldría de juntar esas dos generaciones, o nil si nunca reaccionan.
function Costos.genResultado(genA: number, genB: number): number?
	if genA == 1 and genB == 1 then
		return 2
	elseif genA + genB == 3 then
		return 3
	end
	return nil
end

-- `cantidadEspecies` = cuántas especies tiene el jugador antes de fusionar.
function Costos.fusion(genA: number, genB: number, cantidadEspecies: number): number?
	local gen = Costos.genResultado(genA, genB)
	if not gen then
		return nil
	end
	-- Sube fuerte al principio (las primeras especies salen rápido) y suave después.
	local fuerte = math.clamp(
		cantidadEspecies - E.EspeciesSinSuba,
		0,
		E.EspeciesSubaTardia - E.EspeciesSinSuba
	)
	local suave = math.max(0, cantidadEspecies - E.EspeciesSubaTardia)
	local costo = E.CostoGen2 * E.SubaPorEspecie ^ fuerte * E.SubaTardia ^ suave
	if gen == 3 then
		costo *= E.MultiplicadorGen3
	end
	return math.round(costo)
end

return Costos
