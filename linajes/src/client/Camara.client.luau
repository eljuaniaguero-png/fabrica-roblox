--!strict
-- Campo de visión fijo (Config.Mundo.Camara.FOV): el de fábrica deforma de cerca.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local function poner()
	local camara = workspace.CurrentCamera
	if camara then
		camara.FieldOfView = Config.Mundo.Camara.FOV
	end
end

poner()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(poner)
