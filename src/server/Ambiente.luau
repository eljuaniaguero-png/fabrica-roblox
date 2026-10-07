--!strict
-- Aplica la luz del ambiente (Config.Ambiente) al arrancar, así los números viven en Config.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Ambiente = {}

function Ambiente.aplicar()
	local ambiente = Config.Ambiente
	Lighting.Brightness = ambiente.Brillo
	Lighting.ExposureCompensation = ambiente.Exposicion
	Lighting.Ambient = ambiente.LuzAmbiente
	Lighting.OutdoorAmbient = ambiente.LuzExterior

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Intensity = ambiente.BloomIntensidad
		bloom.Size = ambiente.BloomTamano
		bloom.Threshold = ambiente.BloomUmbral
	end
end

return Ambiente
