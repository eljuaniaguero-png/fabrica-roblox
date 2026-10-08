--!strict
-- Datos de cada jugador mientras está en el servidor (el guardado llega en la Parte 5).
-- Se publican como atributos del Player para que el cliente los lea:
--   ADN (número entero), Especies y Mutantes (claves separadas por ";"),
--   Pistas ("clave:cantidad;...") y PistasCompradas (número),
--   MejoraCorrales, MejoraRapida, MejoraNutrientes (niveles), FactorFusion y Tope.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Pistas = require(ReplicatedStorage.Shared.Pistas)

export type Datos = {
	ADN: number, -- puede tener decimales (los Nutrientes suman de a 0,25); se muestra redondeado
	Especies: { [string]: boolean },
	Mutantes: { [string]: boolean },
	Pistas: { [string]: number }, -- cuántas pistas compraste de cada silueta
	PistasCompradas: number,
	GeneracionesPremiadas: { [number]: boolean },
	Mejoras: Mejoras.Niveles,
	OcupadoHasta: number, -- la máquina está trabajando hasta este os.clock()
}

local datos: { [Player]: Datos } = {}

local Jugadores = {}

local function unir(conjunto: { [string]: boolean }): string
	local lista = {}
	for clave in conjunto do
		table.insert(lista, clave)
	end
	table.sort(lista)
	return table.concat(lista, ";")
end

function Jugadores.obtener(jugador: Player): Datos?
	return datos[jugador]
end

function Jugadores.todos(): { [Player]: Datos }
	return datos
end

function Jugadores.cantidadEspecies(d: Datos): number
	local n = 0
	for _ in d.Especies do
		n += 1
	end
	return n
end

function Jugadores.cantidadBases(d: Datos): number
	local n = 0
	for b = 1, Config.TamanioRueda do
		if d.Especies[tostring(b)] then
			n += 1
		end
	end
	return n
end

function Jugadores.publicar(jugador: Player)
	local d = datos[jugador]
	if not d then
		return
	end
	jugador:SetAttribute("ADN", math.floor(d.ADN))
	jugador:SetAttribute("Especies", unir(d.Especies))
	jugador:SetAttribute("Mutantes", unir(d.Mutantes))
	jugador:SetAttribute("Pistas", Pistas.escribir(d.Pistas))
	jugador:SetAttribute("PistasCompradas", d.PistasCompradas)
	jugador:SetAttribute("MejoraCorrales", d.Mejoras.Corrales)
	jugador:SetAttribute("MejoraRapida", d.Mejoras.Rapida)
	jugador:SetAttribute("MejoraNutrientes", d.Mejoras.Nutrientes)
	jugador:SetAttribute("FactorFusion", Mejoras.factorRapidez(d.Mejoras.Rapida))
	jugador:SetAttribute("Tope", Mejoras.tope(d.Mejoras.Corrales))
end

-- Crea los datos de un jugador que entra.
function Jugadores.crear(jugador: Player)
	local d: Datos = {
		ADN = Config.Economia.ADNInicial,
		Especies = {},
		Mutantes = {},
		Pistas = {},
		PistasCompradas = 0,
		GeneracionesPremiadas = {},
		Mejoras = Mejoras.iniciales(),
		OcupadoHasta = 0,
	}
	for _, n in Config.Economia.BasesIniciales do
		d.Especies[tostring(n)] = true
	end
	-- Modo prueba: las 10 bases y ADN de sobra (la gen 1 no paga premio porque viene regalada).
	if Config.Prueba.Activo then
		d.ADN = Config.Prueba.ADN
		for n = 1, Config.TamanioRueda do
			d.Especies[tostring(n)] = true
		end
		d.GeneracionesPremiadas[1] = true
	end
	datos[jugador] = d
	Jugadores.publicar(jugador)
end

function Jugadores.quitar(jugador: Player)
	datos[jugador] = nil
end

return Jugadores
