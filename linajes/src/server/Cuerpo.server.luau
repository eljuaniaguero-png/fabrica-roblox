--!strict
-- Cada personaje que aparece (StarterCharacter = cuerpo propio, nunca el avatar de Roblox) se
-- arma con la apariencia del jugador.

local Players = game:GetService("Players")

local CuerpoComic = require(script.Parent.CuerpoComic)

local function alAparecer(jugador: Player, personaje: Model)
	-- Más adelante sale de los datos guardados (creador de personaje); por ahora, al azar fijo.
	CuerpoComic.vestir(personaje, jugador)
end

local function alEntrar(jugador: Player)
	jugador.CharacterAdded:Connect(function(personaje)
		alAparecer(jugador, personaje)
	end)
	if jugador.Character then
		alAparecer(jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
