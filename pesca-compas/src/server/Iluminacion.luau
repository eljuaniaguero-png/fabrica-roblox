--!strict
-- Luz y agua del estilo "Toon de playa". Todos los números están en shared/Estilo.luau.
-- Reusa los efectos que ya haya en Lighting (por nombre) en vez de duplicarlos.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Estilo = require(ReplicatedStorage.Shared.Estilo)

local Iluminacion = {}

local function efecto(clase: string, nombre: string): Instance
	local e = Lighting:FindFirstChild(nombre)
	if not e or e.ClassName ~= clase then
		e = Instance.new(clase)
		e.Name = nombre;
		(e :: Instance).Parent = Lighting
	end
	return e :: Instance
end

function Iluminacion.aplicar()
	local L = Estilo.Luz
	Lighting.ClockTime = L.Hora
	Lighting.GeographicLatitude = L.Latitud
	Lighting.Brightness = L.Brillo
	Lighting.ExposureCompensation = L.Exposicion
	Lighting.Ambient = L.Ambiente
	Lighting.OutdoorAmbient = L.Exterior
	Lighting.ColorShift_Top = L.Sol
	Lighting.ColorShift_Bottom = Color3.new()
	Lighting.EnvironmentDiffuseScale = L.Difusa
	Lighting.EnvironmentSpecularScale = 0
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = L.Suavidad

	local cc = efecto("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	cc.Brightness = L.BrilloCorreccion
	cc.Contrast = L.Contraste
	cc.Saturation = L.Saturacion
	cc.TintColor = Color3.new(1, 1, 1)
	cc.Enabled = true

	local bloom = efecto("BloomEffect", "Bloom") :: BloomEffect
	bloom.Intensity = L.Bloom.Intensidad
	bloom.Size = L.Bloom.Tamano
	bloom.Threshold = L.Bloom.Umbral
	bloom.Enabled = true

	local A = L.Atmosfera
	local atm = efecto("Atmosphere", "Atmosphere") :: Atmosphere
	atm.Density = A.Densidad
	atm.Offset = A.Desplazamiento
	atm.Haze = A.Bruma
	atm.Glare = A.Resplandor
	atm.Color = A.Color
	atm.Decay = A.Lejos

	-- Un Sky nuevo trae el cielo de fábrica de Roblox: celeste con nubes de dibujo, que ya es toon.
	if not Lighting:FindFirstChildOfClass("Sky") then
		efecto("Sky", "Cielo")
	end

	local agua = Estilo.Agua
	local terreno = Workspace.Terrain
	terreno.WaterColor = agua.Color
	terreno.WaterTransparency = agua.Transparencia
	terreno.WaterReflectance = agua.Reflejo
	terreno.WaterWaveSize = agua.Olas
	terreno.WaterWaveSpeed = agua.VelocidadOlas
	-- El plástico mate de Mutant Lab (MaterialVariant con RoughnessMap) queda para cuando
	-- importemos esa textura acá; sin ella, EnvironmentSpecularScale = 0 ya saca casi todo el brillo.
end

return Iluminacion
