--!strict
-- Las mejoras de la etapa 5, sin Instances (las usan Simulacion, el servidor, el cliente y las
-- pruebas con Lune): cuánto vale cada una según su nivel, qué clavijas son rojas en una pelea,
-- qué cartas se ofrecen y el texto de cada carta. Los números están en Config.Mejoras.
-- Nivel = cuántas veces la elegiste en esta mazmorra (0 = no la tenés).

local Azar = require(script.Parent.Azar)
local Config = require(script.Parent.Config)
local TableroModulo = require(script.Parent.Tablero)

export type Niveles = { [string]: number }

local Mejoras = {}

function Mejoras.existe(id: any): boolean
	return typeof(id) == "string" and table.find(Config.OrdenMejoras, id) ~= nil
end

function Mejoras.nivel(niveles: Niveles?, id: string): number
	return if niveles then niveles[id] or 0 else 0
end

-- Bola de fuego: daño de cada clavija y quemadura por turno.
function Mejoras.danioPorClavija(nivelFuego: number): number
	local extra = if nivelFuego > 0 then Config.Mejoras.Fuego.DanioExtraPorClavija else 0
	return Config.Danio.PorClavija + extra
end

function Mejoras.quemadura(nivelFuego: number): number
	local f = Config.Mejoras.Fuego
	return if nivelFuego > 0 then f.Quemadura + (nivelFuego - 1) * f.QuemaduraPorNivel else 0
end

-- Clavija que duplica: cuántas rojas hay.
function Mejoras.cantidadRojas(nivelDuplica: number): number
	local d = Config.Mejoras.Duplica
	return if nivelDuplica > 0
		then d.ClavijasRojas + (nivelDuplica - 1) * d.ClavijasRojasPorNivel
		else 0
end

-- Bola que se divide: en qué toque se parte (nil si no la tenés).
function Mejoras.toquesParaDividir(nivelDivide: number): number?
	local lista = Config.Mejoras.Divide.ToquesParaDividir
	return if nivelDivide > 0 then lista[math.min(nivelDivide, #lista)] else nil
end

-- Las clavijas rojas de una pelea: salen de la semilla de la pelea, así no se mueven mientras
-- dura. Solo entre las filas FilaMinima y FilaMaxima. Devuelve los Id, ordenados.
function Mejoras.rojas(tablero: TableroModulo.Tablero, semilla: number, nivel: number): { number }
	local d = Config.Mejoras.Duplica
	local candidatas: { number } = {}
	for _, c in tablero.Clavijas do
		if c.Fila >= d.FilaMinima and c.Fila <= d.FilaMaxima then
			table.insert(candidatas, c.Id)
		end
	end
	Azar.mezclar(candidatas, Azar.nuevo(semilla))
	local elegidas: { number } = {}
	for i = 1, math.min(Mejoras.cantidadRojas(nivel), #candidatas) do
		table.insert(elegidas, candidatas[i])
	end
	table.sort(elegidas)
	return elegidas
end

-- Las cartas que aparecen al ganar una pelea (con 3 mejoras, siempre las 3, en orden).
function Mejoras.ofrecer(semilla: number): { string }
	local todas = table.clone(Config.OrdenMejoras)
	local cantidad = Config.MejorasPorPantalla
	if #todas <= cantidad then
		return todas
	end
	Azar.mezclar(todas, Azar.nuevo(semilla))
	local elegidas: { string } = {}
	for i = 1, cantidad do
		table.insert(elegidas, todas[i])
	end
	return elegidas
end

-- Nombre y frase de una carta, con los números del nivel que tendría al elegirla.
function Mejoras.describir(id: string, nivel: number): (string, string)
	local m = Config.Mejoras
	if id == "Fuego" then
		return m.Fuego.Nombre,
			("+%d de daño por clavija y el monstruo se quema %d por turno"):format(
				m.Fuego.DanioExtraPorClavija,
				Mejoras.quemadura(nivel)
			)
	elseif id == "Duplica" then
		return m.Duplica.Nombre,
			("%d clavijas rojas: al tocar una, el daño del tiro ×%d"):format(
				Mejoras.cantidadRojas(nivel),
				m.Duplica.Factor
			)
	elseif id == "Divide" then
		return m.Divide.Nombre,
			("En el toque %d la bola se parte en %d y suman todas"):format(
				Mejoras.toquesParaDividir(nivel) or 0,
				m.Divide.Partes
			)
	end
	return id, ""
end

-- Nombre corto para la fila de mejoras de abajo.
function Mejoras.nombreCorto(id: string): string
	if id == "Fuego" then
		return "Fuego"
	elseif id == "Duplica" then
		return "×2"
	elseif id == "Divide" then
		return "Divide"
	end
	return id
end

return Mejoras
