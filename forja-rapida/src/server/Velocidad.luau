--!strict
-- Velocidad al caminar: Paso Ligero (árbol de Esencia) y Chispa (mascota) la suben, con tope
-- GameConfig.Velocidad.Maxima (Reglas.bonos). Jugadores.publicar deja el valor en el atributo
-- "Velocidad" del jugador y acá se le pone al Humanoid, también cada vez que reaparece.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Velocidad = {}

local function aplicar(jugador: Player)
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide.WalkSpeed = tonumber(jugador:GetAttribute("Velocidad"))
			or GameConfig.Velocidad.Base
	end
end

local function alEntrar(jugador: Player)
	jugador:GetAttributeChangedSignal("Velocidad"):Connect(function()
		aplicar(jugador)
	end)
	jugador.CharacterAdded:Connect(function(personaje: Model)
		personaje:WaitForChild("Humanoid", 10)
		aplicar(jugador)
	end)
	aplicar(jugador)
end

function Velocidad.iniciar()
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
end

return Velocidad
