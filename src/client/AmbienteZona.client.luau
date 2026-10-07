--!strict
-- Cielo por zona (solo visual, lo ves vos): al entrar a otra zona, la bruma, el horizonte, la luz
-- ambiente y las estrellas pasan con un fundido a los de esa zona (Config.Zonas[n].Cielo).
-- La zona la publica el servidor en el atributo "Zona" del jugador al pisar la primera baldosa.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local jugador = Players.LocalPlayer

local function aplicar(zona: number, duracion: number)
	local datos = Config.Zonas[zona] or Config.Zonas[1]
	local cielo = datos.Cielo
	local info = TweenInfo.new(duracion, Enum.EasingStyle.Sine)

	TweenService:Create(Lighting, info, {
		Ambient = cielo.LuzAmbiente,
		OutdoorAmbient = cielo.LuzAmbiente,
	}):Play()
	local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosfera then
		TweenService:Create(atmosfera, info, {
			Color = cielo.Atmosfera,
			Decay = cielo.Decaimiento,
			Density = cielo.Densidad,
		}):Play()
	end
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then
		sky.StarCount = cielo.Estrellas
	end
end

local function zonaActual(): number
	local valor = jugador:GetAttribute("Zona")
	return if typeof(valor) == "number" then valor else 1
end

jugador:GetAttributeChangedSignal("Zona"):Connect(function()
	aplicar(zonaActual(), Config.DuracionCambioCielo)
end)
aplicar(zonaActual(), 0)
