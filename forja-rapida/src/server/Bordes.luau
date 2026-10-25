--!strict
-- Bordes del mapa (pedido E1): si un jugador se cae o termina arriba de la meseta de afuera
-- (arriba de las paredes), vuelve al último lugar seguro donde estuvo parado. Las paredes
-- invisibles (Barrera de mapa.py) ya impiden salir; esto es la red de seguridad.
-- Los números están en GameConfig.Bordes (copian las medidas de arte/scripts/mapa.py).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Bordes = {}

local seguro: { [Player]: CFrame } = {}

-- Altura del piso de la zona donde está esa z (el lobby y la zona 1 en 0).
local function pisoEn(z: number): number
	local B = GameConfig.Bordes
	local zona = math.clamp(math.floor((z - B.InicioZona1) / B.LargoZona) + 1, 1, B.Zonas)
	return (zona - 1) * B.Suba
end

local function estaAfuera(p: Vector3): boolean
	local B = GameConfig.Bordes
	if p.Y < B.CaidaY then
		return true
	end
	-- arriba de la meseta: más allá de las paredes y a la altura de su tapa
	local arriba = p.Y > pisoEn(p.Z) + B.AltoPared - 4
	return arriba and (math.abs(p.X) > B.XMax + 3 or p.Z < B.ZFondoLobby)
end

local function revisar(jugador: Player)
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not (raiz and humanoide) or humanoide.Health <= 0 then
		return
	end
	if estaAfuera(raiz.Position) then
		local volver = seguro[jugador]
		if volver then
			raiz.AssemblyLinearVelocity = Vector3.zero
			personaje:PivotTo(volver)
		end
	elseif humanoide.FloorMaterial ~= Enum.Material.Air then
		seguro[jugador] = raiz.CFrame + Vector3.new(0, 1, 0)
	end
end

function Bordes.iniciar()
	Players.PlayerRemoving:Connect(function(jugador)
		seguro[jugador] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(GameConfig.Bordes.Intervalo)
			for _, jugador in Players:GetPlayers() do
				revisar(jugador)
			end
		end
	end)
end

return Bordes
