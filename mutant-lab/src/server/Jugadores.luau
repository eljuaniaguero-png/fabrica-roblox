--!strict
-- Datos de cada jugador mientras está en el servidor (el guardado llega en la Parte 5).
-- Se publican como atributos del Player para que el cliente los lea:
--   ADN (número), Especies y Mutantes (claves separadas por ";").

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

export type Datos = {
	ADN: number,
	Especies: { [string]: boolean },
	Mutantes: { [string]: boolean },
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

function Jugadores.cantidadEspecies(d: Datos): number
	local n = 0
	for _ in d.Especies do
		n += 1
	end
	return n
end

function Jugadores.publicar(jugador: Player)
	local d = datos[jugador]
	if not d then
		return
	end
	jugador:SetAttribute("ADN", d.ADN)
	jugador:SetAttribute("Especies", unir(d.Especies))
	jugador:SetAttribute("Mutantes", unir(d.Mutantes))
end

local function alEntrar(jugador: Player)
	local d: Datos = {
		ADN = Config.Economia.ADNInicial,
		Especies = {},
		Mutantes = {},
		OcupadoHasta = 0,
	}
	for _, n in Config.Economia.BasesIniciales do
		d.Especies[tostring(n)] = true
	end
	-- Modo prueba: las 10 bases y ADN de sobra.
	if Config.Prueba.Activo then
		d.ADN = Config.Prueba.ADN
		for n = 1, Config.TamanioRueda do
			d.Especies[tostring(n)] = true
		end
	end
	datos[jugador] = d
	Jugadores.publicar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
Players.PlayerRemoving:Connect(function(jugador)
	datos[jugador] = nil
end)
for _, jugador in Players:GetPlayers() do
	alEntrar(jugador)
end

return Jugadores
