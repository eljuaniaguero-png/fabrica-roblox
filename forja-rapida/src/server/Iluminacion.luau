--!strict
-- La luz que pidió Juani: un ColorCorrection en Lighting con los valores de GameConfig.Luz
-- (brillo 0,05, contraste 0,15, saturación 0,1, color 255, 255, 255). Si ya existe uno con ese
-- nombre se usa ese. Los eventos le suman su propio tinte en el cliente, sin tocar este.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Iluminacion = {}

function Iluminacion.aplicar()
	local L = GameConfig.Luz
	local cc = Lighting:FindFirstChild("ColorCorrection")
	if not cc or not cc:IsA("ColorCorrectionEffect") then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "ColorCorrection"
		cc.Parent = Lighting
	end
	local efecto = cc :: ColorCorrectionEffect
	efecto.Brightness = L.Brillo
	efecto.Contrast = L.Contraste
	efecto.Saturation = L.Saturacion
	efecto.TintColor = Color3.fromHex(L.Color)
	efecto.Enabled = true
end

return Iluminacion
