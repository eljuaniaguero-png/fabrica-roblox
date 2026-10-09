--!strict
-- Cuentas de las mejoras y de la economía del laboratorio (las usan servidor y cliente).

local Config = require(script.Parent.Config)
local Costos = require(script.Parent.Costos)
local Fusion = require(script.Parent.Fusion)
local Personalidades = require(script.Parent.Personalidades)

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
	Personalidad: string?,
	Variante: string?,
}

type UnidadCualquiera = {
	Id: number,
	Clave: string,
	Mutante: boolean,
	Personalidad: string?,
	Variante: string?,
}

-- ADN por segundo de cada criatura (sin Nutrientes), en el orden de la lista: los corrales son
-- tramos de Config.Corrales.PorCorral y las personalidades se afectan dentro de cada uno.
local function produccion(lista: { Activa }): { number }
	local r = {}
	local porCorral = Config.Corrales.PorCorral
	for inicio = 1, #lista, porCorral do
		local fin = math.min(#lista, inicio + porCorral - 1)
		local personalidades = {}
		for k = inicio, fin do
			table.insert(personalidades, lista[k].Personalidad or "")
		end
		local mult = Personalidades.multiplicadores(personalidades)
		for k = inicio, fin do
			r[k] = Config.Economia.ADNPorGen[lista[k].Criatura.Gen] * mult[k - inicio + 1]
		end
	end
	return r
end

local function suma(t: { number }): number
	local s = 0
	for _, v in t do
		s += v
	end
	return s
end

-- Las criaturas que trabajan en los corrales: las de mayor generación, hasta el tope (a igual
-- generación, las que llegaron primero). Después se acomodan en los corrales para que rindan
-- más: se prueban cambios de lugar entre corrales mientras el ADN total suba. El orden de la
-- lista es el lugar: las primeras Config.Corrales.PorCorral van al corral 1, y así.
function Mejoras.activas(criaturas: { UnidadCualquiera }, nivelCorrales: number): { Activa }
	local lista: { Activa } = {}
	for _, u in criaturas do
		local c = Fusion.porClave(u.Clave)
		if c then
			table.insert(lista, {
				Criatura = c,
				Id = u.Id,
				Mutante = u.Mutante,
				Personalidad = u.Personalidad,
				Variante = u.Variante,
			})
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
	local porCorral = Config.Corrales.PorCorral
	local mejor = suma(produccion(lista))
	for _ = 1, 20 do
		local mejoro = false
		for i = 1, #lista do
			for j = i + 1, #lista do
				if math.ceil(i / porCorral) ~= math.ceil(j / porCorral) then
					lista[i], lista[j] = lista[j], lista[i]
					local total = suma(produccion(lista))
					if total > mejor + 1e-6 then
						mejor = total
						mejoro = true
					else
						lista[i], lista[j] = lista[j], lista[i]
					end
				end
			end
		end
		if not mejoro then
			break
		end
	end
	return lista
end

-- ADN por segundo que genera cada criatura activa (con Nutrientes), en el orden de la lista.
function Mejoras.porCriatura(activas: { Activa }, nivelNutrientes: number): { number }
	local m = Mejoras.multiplicadorADN(nivelNutrientes)
	local r = produccion(activas)
	for i, v in r do
		r[i] = v * m
	end
	return r
end

-- ADN por segundo que generan las criaturas activas (un corral, si se le pasa solo ese tramo).
function Mejoras.porSegundo(activas: { Activa }, nivelNutrientes: number): number
	return suma(Mejoras.porCriatura(activas, nivelNutrientes))
end

-- Lo que cuesta otra copia de una base que ya descubriste.
function Mejoras.precioCopia(cantidadEspecies: number): number
	return math.max(1, math.round(Mejoras.fusion(cantidadEspecies) * Config.Tienda.FactorCopia))
end

return Mejoras
