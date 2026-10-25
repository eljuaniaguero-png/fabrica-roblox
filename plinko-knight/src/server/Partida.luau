--!strict
-- La partida de cada jugador, en el servidor: piso, vida, mejoras y el tiro en curso.
-- Por ahora no se guarda (el guardado llega en la etapa 6).

local Players = game:GetService("Players")

local Config =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

export type Partida = {
	Piso: number,
	Vida: number,
	Mejoras: { [string]: number }, -- nombre de la mejora -> cuántas veces la elegiste
	NumeroTiro: number, -- el último tiro pedido
	Semilla: number?, -- semilla del tiro pedido; nil si no hay uno pendiente
	UltimoTiro: number, -- os.clock() del último tiro aceptado
}

local Partida = {}

local partidas: { [Player]: Partida } = {}

function Partida.de(jugador: Player): Partida?
	return partidas[jugador]
end

function Partida.iniciar(jugador: Player): Partida
	local p: Partida = {
		Piso = 1,
		Vida = Config.Caballero.Vida,
		Mejoras = {},
		NumeroTiro = 0,
		Semilla = nil,
		UltimoTiro = -math.huge,
	}
	partidas[jugador] = p
	return p
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
