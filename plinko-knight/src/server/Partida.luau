--!strict
-- La partida de cada jugador, en el servidor: la mazmorra (piso, vidas, fase, tablero de
-- clavijas, bola y oro, todo en Estado) y el tiro en curso. Por ahora no se guarda (etapa 6).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))

export type Partida = {
	Estado: Mazmorra.Estado,
	NumeroTiro: number, -- el último tiro pedido (no vuelve a 0 al reiniciar la mazmorra)
	Semilla: number?, -- semilla del tiro pedido; nil si no hay uno pendiente
	UltimoTiro: number, -- os.clock() del último tiro aceptado
	UltimoVolver: number, -- os.clock() del último "Volver a bajar"
	Bola: string, -- la bola con la que baja (hasta la pantalla de elegir bola, etapa 7)
	UltimaAccion: number, -- os.clock() de la última compra / pergamino (límite de frecuencia)
}

local Partida = {}

local partidas: { [Player]: Partida } = {}
local azar = Random.new()

function Partida.nuevaPelea(p: Partida)
	Mazmorra.empezarPelea(p.Estado)
end

-- Semilla para las cartas que salen y las clavijas que convierte una carta.
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
		Bola = "hierro",
		UltimaAccion = -math.huge,
	}
	Partida.nuevaPelea(p)
	partidas[jugador] = p
	return p
end

-- Mazmorra nueva desde el piso 1: tablero todo gris otra vez y sin el tiro pendiente.
function Partida.reiniciar(p: Partida)
	p.Estado = Mazmorra.nueva(p.Bola)
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
