--!strict
-- Muestra el ADN del jugador (atributo "ADN" que publica el servidor).
-- HUD (ScreenGui armado en Studio) > ADN (Frame con UIScale "Escala") > Valor (TextLabel)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local caja = hud:WaitForChild("ADN") :: Frame
local valor = caja:WaitForChild("Valor") :: TextLabel
local escala = caja:WaitForChild("Escala") :: UIScale

-- 100000 -> "100.000"
local function conPuntos(n: number): string
	local texto = tostring(math.floor(n))
	local resultado = texto:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if resultado:sub(1, 1) == "." then
		resultado = resultado:sub(2)
	end
	return resultado
end

local anterior: number? = nil

local function actualizar()
	local adn = (jugador:GetAttribute("ADN") :: number?) or 0
	valor.Text = conPuntos(adn) .. " ADN"
	if anterior and adn ~= anterior then
		escala.Scale = 1.15
		TweenService:Create(escala, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	anterior = adn
end

jugador:GetAttributeChangedSignal("ADN"):Connect(actualizar)
actualizar()
