--!strict
-- Despertar del sandbox: con 5 bajas seguidas sin caer se habilita con G. Mientras dura, pega más
-- (Combate.server) y recarga más rápido (Poderes.server). Cada 5 bajas más se habilita otra vez.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local DE = Config.Sandbox.Despertar

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Despertar"
remoto.Parent = ReplicatedStorage

local usos: { [Player]: number } = {}

local function racha(jugador: Player): number
	local r = jugador:GetAttribute("Racha")
	return if typeof(r) == "number" then r else 0
end

-- DespertarListo para el HUD: cuántas bajas faltan (0 = listo).
local function actualizar(jugador: Player)
	if racha(jugador) == 0 then
		usos[jugador] = 0
	end
	local meta = DE.Racha * ((usos[jugador] or 0) + 1)
	jugador:SetAttribute("DespertarFalta", math.max(meta - racha(jugador), 0))
end

local function conectar(jugador: Player)
	usos[jugador] = 0
	jugador:GetAttributeChangedSignal("Racha"):Connect(function()
		actualizar(jugador)
	end)
	actualizar(jugador)
end
Players.PlayerAdded:Connect(conectar)
for _, j in Players:GetPlayers() do
	conectar(j)
end
Players.PlayerRemoving:Connect(function(jugador)
	usos[jugador] = nil
end)

remoto.OnServerEvent:Connect(function(jugador: Player, pedido: unknown)
	if pedido ~= "Activar" or jugador:GetAttribute("DespertarFalta") ~= 0 then
		return
	end
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not (personaje and h and h.Health > 0) or personaje:GetAttribute("Despierto") == true then
		return
	end
	usos[jugador] = (usos[jugador] or 0) + 1
	actualizar(jugador)
	personaje:SetAttribute("Despierto", true)
	remoto:FireAllClients("Despierta", personaje, DE.Dura)
	task.delay(DE.Dura, function()
		if personaje.Parent then
			personaje:SetAttribute("Despierto", false)
		end
	end)
end)
