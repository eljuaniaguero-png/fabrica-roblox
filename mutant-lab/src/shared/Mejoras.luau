--!strict
-- Cuentas de las mejoras y de la economía del laboratorio (las usan servidor y cliente).

local Config = require(script.Parent.Config)
local Fusion = require(script.Parent.Fusion)

local M = Config.Mejoras

export type Niveles = { Corrales: number, Rapida: number, Nutrientes: number }

local Mejoras = {}

Mejoras.Orden = { "Corrales", "Rapida", "Nutrientes" } -- orden en la tienda

function Mejoras.iniciales(): Niveles
	return {
		Corrales = M.Corrales.Inicial,
		Rapida = M.Rapida.Inicial,
		Nutrientes = M.Nutrientes.Inicial,
	}
end

function Mejoras.maximo(nombre: string): number
	local def = (M :: any)[nombre]
	return def.Inicial + #def.Precios
end

-- Precio para subir al próximo nivel, o nil si ya está al máximo.
function Mejoras.precio(nombre: string, nivel: number): number?
	local def = (M :: any)[nombre]
	return def.Precios[nivel - def.Inicial + 1]
end

-- Cuántas criaturas pueden trabajar a la vez.
function Mejoras.tope(nivelCorrales: number): number
	return nivelCorrales * Config.Corrales.PorCorral
end

-- Cuánto dura la fusión (1 = normal, 0.5 = la mitad).
function Mejoras.factorRapidez(nivel: number): number
	return M.Rapida.Factores[nivel + 1] or 1
end

function Mejoras.multiplicadorADN(nivel: number): number
	return 1 + M.Nutrientes.Bonus * nivel
end

-- Precio de la próxima especie base, según cuántas bases tenés; nil si ya están todas.
function Mejoras.precioBase(basesQueTenes: number): number?
	return Config.Tienda.PreciosBases[basesQueTenes - #Config.Economia.BasesIniciales + 1]
end

-- Las criaturas que trabajan en los corrales: las de mayor generación, hasta el tope.
function Mejoras.activas(
	especies: { [string]: boolean },
	nivelCorrales: number
): { Fusion.Criatura }
	local lista = {}
	for _, c in Fusion.todas() do
		if especies[c.Clave] then
			table.insert(lista, c)
		end
	end
	-- Fusion.todas() ya viene ordenada por generación; se dan vuelta para que primero vayan las más altas.
	local ordenada = {}
	for i = #lista, 1, -1 do
		table.insert(ordenada, lista[i])
	end
	local tope = Mejoras.tope(nivelCorrales)
	while #ordenada > tope do
		table.remove(ordenada)
	end
	return ordenada
end

-- ADN por segundo que generan las criaturas activas.
function Mejoras.porSegundo(activas: { Fusion.Criatura }, nivelNutrientes: number): number
	local total = 0
	for _, c in activas do
		total += Config.Economia.ADNPorGen[c.Gen]
	end
	return total * Mejoras.multiplicadorADN(nivelNutrientes)
end

return Mejoras
