--!strict
-- La luz del juego: día brillante, cielo celeste, sombras marcadas y colores saturados.
-- Todos los números están en GameConfig.Luz. Los eventos le suman sus propios efectos en el
-- cliente (TinteEvento, destellos) sin tocar los de acá.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Iluminacion = {}

-- Devuelve el efecto con ese nombre y clase; si no existe, lo crea.
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
	local L = GameConfig.Luz

	local base = L.Lighting
	Lighting.ClockTime = base.ClockTime
	Lighting.Brightness = base.Brightness
	Lighting.Ambient = Color3.fromHex(base.Ambient)
	Lighting.OutdoorAmbient = Color3.fromHex(base.OutdoorAmbient)
	Lighting.EnvironmentDiffuseScale = base.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = base.EnvironmentSpecularScale
	Lighting.GlobalShadows = base.GlobalShadows
	Lighting.ShadowSoftness = base.ShadowSoftness
	Lighting.ExposureCompensation = base.ExposureCompensation

	local cc = efecto("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	cc.Brightness = L.ColorCorrection.Brillo
	cc.Contrast = L.ColorCorrection.Contraste
	cc.Saturation = L.ColorCorrection.Saturacion
	cc.TintColor = Color3.fromHex(L.ColorCorrection.Color)
	cc.Enabled = true

	local bloom = efecto("BloomEffect", "Bloom") :: BloomEffect
	bloom.Intensity = L.Bloom.Intensity
	bloom.Size = L.Bloom.Size
	bloom.Threshold = L.Bloom.Threshold
	bloom.Enabled = true

	local atm = efecto("Atmosphere", "Atmosphere") :: Atmosphere
	atm.Density = L.Atmosphere.Density
	atm.Offset = L.Atmosphere.Offset
	atm.Color = Color3.fromHex(L.Atmosphere.Color)
	atm.Decay = Color3.fromHex(L.Atmosphere.Decay)
	atm.Glare = L.Atmosphere.Glare
	atm.Haze = L.Atmosphere.Haze

	local rayos = efecto("SunRaysEffect", "SunRays") :: SunRaysEffect
	rayos.Intensity = L.SunRays.Intensity
	rayos.Spread = L.SunRays.Spread
	rayos.Enabled = true

	if L.CieloDeFabrica then
		-- Un Sky nuevo trae las texturas de fábrica de Roblox: celeste con nubes de dibujo.
		for _, s in Lighting:GetChildren() do
			if s:IsA("Sky") and s.Name ~= "CieloForja" then
				s:Destroy()
			end
		end
		efecto("Sky", "CieloForja")
	end
end

return Iluminacion
