--!strict
-- Barra de experiencia debajo de vida y energía. Solo muestra: la experiencia la da el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Niveles = require(Shared:WaitForChild("Niveles"))

local N = Config.Niveles
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "BarraNivel"
gui.ResetOnSpawn = false

local fondo = Instance.new("Frame")
fondo.Position = UDim2.fromOffset(16, 56)
fondo.Size = UDim2.fromOffset(240, 16)
fondo.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
fondo.BorderSizePixel = 0
fondo.Parent = gui

local lleno = Instance.new("Frame")
lleno.Size = UDim2.fromScale(0, 1)
lleno.BackgroundColor3 = Color3.fromHex(N.ColorBarra)
lleno.BorderSizePixel = 0
lleno.Parent = fondo

local texto = Instance.new("TextLabel")
texto.BackgroundTransparency = 1
texto.Size = UDim2.fromScale(1, 1)
texto.Font = Enum.Font.GothamBlack
texto.TextSize = 12
texto.TextColor3 = Color3.new(1, 1, 1)
texto.TextStrokeTransparency = 0.3
texto.ZIndex = 2
texto.Parent = fondo

local function actualizar()
	local nivel = jugador:GetAttribute("Nivel")
	local xp = jugador:GetAttribute("Xp")
	if typeof(nivel) ~= "number" or typeof(xp) ~= "number" then
		fondo.Visible = false
		return
	end
	fondo.Visible = true
	local falta = Niveles.xpPara(nivel)
	local maximo = nivel >= N.Maximo
	texto.Text = if maximo
		then string.format("NIVEL %d (MÁXIMO)", nivel)
		else string.format("NIVEL %d   %d / %d", nivel, xp, falta)
	local parte = if maximo then 1 else math.clamp(xp / falta, 0, 1)
	TweenService:Create(lleno, TweenInfo.new(0.2), { Size = UDim2.fromScale(parte, 1) }):Play()
end

jugador:GetAttributeChangedSignal("Nivel"):Connect(actualizar)
jugador:GetAttributeChangedSignal("Xp"):Connect(actualizar)
actualizar()
gui.Parent = jugador:WaitForChild("PlayerGui")
