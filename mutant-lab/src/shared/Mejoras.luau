--!strict
-- Cuentas de las mejoras y de la economía del laboratorio (las usan servidor y cliente).

local Config = require(script.Parent.Config)
local Costos = require(script.Parent.Costos)
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

-- Lo que cuesta ahora una fusión de gen 2: la unidad de todos los precios de la tienda.
function Mejoras.fusion(cantidadEspecies: number): number
	return Costos.fusion(1, 1, cantidadEspecies) or 0
end

-- Precio para subir al próximo nivel, o nil si ya está al máximo.
function Mejoras.precio(nombre: string, nivel: number, cantidadEspecies: number): number?
	local def = (M :: any)[nombre]
	local factor = def.Precios[nivel - def.Inicial + 1]
	if not factor then
		return nil
	end
	return math.max(1, math.round(factor * Mejoras.fusion(cantidadEspecies)))
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

-- Precio de la próxima especie base; nil si ya están todas.
function Mejoras.precioBase(basesQueTenes: number, cantidadEspecies: number): number?
	if basesQueTenes >= Config.TamanioRueda then
		return nil
	end
	return math.max(1, math.round(Config.Tienda.FactorBase * Mejoras.fusion(cantidadEspecies)))
end

-- Una criatura del laboratorio que trabaja en un corral.
export type Activa = {
	Criatura: Fusion.Criatura,
	Id: number,
	Mutante: boolean,
}

-- Las criaturas que trabajan en los corrales: las de mayor generación, hasta el tope
-- (a igual generación, las que llegaron primero).
function Mejoras.activas(
	criaturas: { { Id: number, Clave: string, Mutante: boolean } },
	nivelCorrales: number
): { Activa }
	local lista: { Activa } = {}
	for _, u in criaturas do
		local c = Fusion.porClave(u.Clave)
		if c then
			table.insert(lista, { Criatura = c, Id = u.Id, Mutante = u.Mutante })
		end
	end
	table.sort(lista, function(a, b)
		if a.Criatura.Gen ~= b.Criatura.Gen then
			return a.Criatura.Gen > b.Criatura.Gen
		end
		return a.Id < b.Id
	end)
	local tope = Mejoras.tope(nivelCorrales)
	while #lista > tope do
		table.remove(lista)
	end
	return lista
end

-- ADN por segundo que generan las criaturas activas.
function Mejoras.porSegundo(activas: { Activa }, nivelNutrientes: number): number
	local total = 0
	for _, a in activas do
		total += Config.Economia.ADNPorGen[a.Criatura.Gen]
	end
	return total * Mejoras.multiplicadorADN(nivelNutrientes)
end

-- Lo que cuesta otra copia de una base que ya descubriste.
function Mejoras.precioCopia(cantidadEspecies: number): number
	return math.max(1, math.round(Mejoras.fusion(cantidadEspecies) * Config.Tienda.FactorCopia))
end

return Mejoras
