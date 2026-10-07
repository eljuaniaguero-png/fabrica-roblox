--!strict
-- Precios que dependen del progreso. Lo usan el servidor (para cobrar) y el cliente (para mostrar).

local Config = require(script.Parent.Config)

local Precios = {}

function Precios.zapatillas(nivelActual: number): number
	local z = Config.Zapatillas
	return math.floor(z.PrecioBase * z.FactorPrecio ^ nivelActual)
end

return Precios
