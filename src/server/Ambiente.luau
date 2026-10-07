--!strict
-- Aplica la luz del ambiente (Config.Ambiente) al arrancar, así los números viven en Config.
-- El color de la bruma y la luz ambiente de cada zona los cambia el cliente (AmbienteZona).

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
	Lighting.EnvironmentDiffuseScale = ambiente.LuzEntorno
	Lighting.EnvironmentSpecularScale = ambiente.ReflejoEntorno

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Intensity = ambiente.BloomIntensidad
		bloom.Size = ambiente.BloomTamano
		bloom.Threshold = ambiente.BloomUmbral
	end

	local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosfera then
		atmosfera.Haze = ambiente.BrumaHaze
		atmosfera.Glare = ambiente.BrumaBrillo
	end

	local correccion = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
		or Instance.new("ColorCorrectionEffect")
	correccion.Name = "Correccion"
	correccion.Parent = Lighting
	correccion.Contrast = ambiente.Contraste
	correccion.Saturation = ambiente.Saturacion
end

return Ambiente
