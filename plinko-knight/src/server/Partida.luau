--!strict
-- La partida de cada jugador, en el servidor: la mazmorra (piso, vidas, fase, mejoras y
-- clavijas rojas, todo en Estado) y el tiro en curso. Por ahora no se guarda (etapa 6).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local TableroModulo = require(Shared:WaitForChild("Tablero"))

export type Partida = {
	Estado: Mazmorra.Estado,
	NumeroTiro: number, -- el último tiro pedido (no vuelve a 0 al reiniciar la mazmorra)
	Semilla: number?, -- semilla del tiro pedido; nil si no hay uno pendiente
	UltimoTiro: number, -- os.clock() del último tiro aceptado
	UltimoVolver: number, -- os.clock() del último "Volver a bajar"
}

local Partida = {}

local partidas: { [Player]: Partida } = {}
local tablero = TableroModulo.generar()
local azar = Random.new()

-- Pelea nueva: las clavijas rojas salen de una semilla nueva y quedan fijas toda la pelea.
function Partida.nuevaPelea(p: Partida)
	Mazmorra.empezarPelea(p.Estado, tablero, azar:NextInteger(1, 2 ^ 31 - 1))
end

-- Semilla para elegir qué cartas salen al ganar una pelea.
function Partida.semilla(): number
	return azar:NextInteger(1, 2 ^ 31 - 1)
end

function Partida.de(jugador: Player): Partida?
	return partidas[jugador]
end

function Partida.iniciar(jugador: Player): Partida
	local p: Partida = {
		Estado = Mazmorra.nueva(),
		NumeroTiro = 0,
		Semilla = nil,
		UltimoTiro = -math.huge,
		UltimoVolver = -math.huge,
	}
	Partida.nuevaPelea(p)
	partidas[jugador] = p
	return p
end

-- Mazmorra nueva desde el piso 1: se pierden las mejoras y el tiro pendiente.
function Partida.reiniciar(p: Partida)
	p.Estado = Mazmorra.nueva()
	p.Semilla = nil
	Partida.nuevaPelea(p)
end

Players.PlayerAdded:Connect(Partida.iniciar)
for _, jugador in Players:GetPlayers() do
	if not partidas[jugador] then
		Partida.iniciar(jugador)
	end
end
Players.PlayerRemoving:Connect(function(jugador: Player)
	partidas[jugador] = nil
end)

return Partida
