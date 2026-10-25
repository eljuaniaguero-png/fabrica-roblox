--!strict
-- Velocidad al caminar: Paso Ligero (árbol de Esencia) y Brasita (mascota) la suben, con tope
-- GameConfig.Velocidad.Maxima (Reglas.bonos). Jugadores.publicar deja el valor en el atributo
-- "Velocidad" del jugador y acá se le pone al Humanoid, también cada vez que reaparece.
-- Si está corriendo (atributo "Corriendo", Correr.luau) se multiplica por
-- GameConfig.Correr.Multiplicador, con tope GameConfig.Correr.Maxima. La que queda se publica en
-- el atributo "VelocidadPermitida" (la usa el control de Correr.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Correr = require(script.Parent.Correr)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Velocidad = {}

local function aplicar(jugador: Player)
	local caminar = tonumber(jugador:GetAttribute("Velocidad")) or GameConfig.Velocidad.Base
	local velocidad = caminar
	if jugador:GetAttribute("Corriendo") == true then
		local C = GameConfig.Correr
		velocidad = math.max(caminar, math.min(caminar * C.Multiplicador, C.Maxima))
	end
	jugador:SetAttribute("VelocidadPermitida", velocidad)
	Correr.permitida(jugador, velocidad)
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide.WalkSpeed = velocidad
	end
end

local function alEntrar(jugador: Player)
	jugador:GetAttributeChangedSignal("Velocidad"):Connect(function()
		aplicar(jugador)
	end)
	jugador:GetAttributeChangedSignal("Corriendo"):Connect(function()
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
