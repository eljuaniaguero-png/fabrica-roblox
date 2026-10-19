--!strict
-- Dash minero (idea elegida del 19/10/2026). El envión lo hace el cliente (Dash.client.luau),
-- porque el movimiento del personaje es del cliente. Antes de moverse avisa con Remotos.Dash y
-- el servidor revisa la espera (GameConfig.Dash.Espera): si llega antes de tiempo, lo devuelve
-- al lugar donde estaba al pedirlo, para que no se pueda usar como teletransporte.
-- No da golpe gratis ni cambia números: el dash solo mueve.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotos = require(script.Parent.Remotos)

local D = GameConfig.Dash
local TOLERANCIA = 0.5 -- segundos de margen por la latencia

local Dash = {}

local ultimo: { [Player]: number } = {}

local function alDash(jugador: Player)
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return
	end
	local ahora = os.clock()
	if ultimo[jugador] and ahora - ultimo[jugador] < D.Espera - TOLERANCIA then
		local donde = raiz.CFrame
		task.delay(D.Duracion + 0.1, function()
			if raiz.Parent then
				raiz.AssemblyLinearVelocity = Vector3.zero
				raiz.CFrame = donde
			end
		end)
		return
	end
	ultimo[jugador] = ahora
end

function Dash.iniciar()
	Remotos.Dash.OnServerEvent:Connect(alDash)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimo[jugador] = nil
	end)
end

return Dash
