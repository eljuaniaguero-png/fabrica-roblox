--!strict
-- Precios y cuentas que dependen del progreso. Lo usan el servidor (para cobrar) y el cliente (para mostrar).

local Config = require(script.Parent.Config)

local Precios = {}

-- Precio del próximo nivel de una mejora, o nil si no existe o ya está al máximo.
function Precios.mejora(nombre: string, nivelActual: number): number?
	local mejora = Config.Mejoras[nombre]
	if not mejora or nivelActual >= mejora.NivelMaximo then
		return nil
	end
	return math.floor(mejora.PrecioBase * mejora.FactorPrecio ^ nivelActual)
end

-- Monedas que da un rebirth con esta velocidad y este nivel de Bolsillo.
function Precios.monedasPorRebirth(velocidad: number, nivelBolsillo: number): number
	local bonus = 1 + nivelBolsillo * Config.Mejoras.Bolsillo.BonusPorNivel
	return math.floor(velocidad * Config.TasaConversion * bonus)
end

return Precios
