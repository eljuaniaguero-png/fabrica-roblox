--!strict
-- La partida de cada jugador, en el servidor: la mazmorra (piso, vidas, fase), las mejoras y el
-- tiro en curso. Por ahora no se guarda (el guardado llega en la etapa 6).

local Players = game:GetService("Players")

local Mazmorra =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Mazmorra"))

export type Partida = {
	Estado: Mazmorra.Estado,
	Mejoras: { [string]: number }, -- nombre de la mejora -> cuántas veces la elegiste
	NumeroTiro: number, -- el último tiro pedido (no vuelve a 0 al reiniciar la mazmorra)
	Semilla: number?, -- semilla del tiro pedido; nil si no hay uno pendiente
	UltimoTiro: number, -- os.clock() del último tiro aceptado
	UltimoVolver: number, -- os.clock() del último "Volver a bajar"
}

local Partida = {}

local partidas: { [Player]: Partida } = {}

function Partida.de(jugador: Player): Partida?
	return partidas[jugador]
end

function Partida.iniciar(jugador: Player): Partida
	local p: Partida = {
		Estado = Mazmorra.nueva(),
		Mejoras = {},
		NumeroTiro = 0,
		Semilla = nil,
		UltimoTiro = -math.huge,
		UltimoVolver = -math.huge,
	}
	partidas[jugador] = p
	return p
end

-- Mazmorra nueva desde el piso 1: se pierden las mejoras y el tiro pendiente.
function Partida.reiniciar(p: Partida)
	p.Estado = Mazmorra.nueva()
	p.Mejoras = {}
	p.Semilla = nil
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
