--!strict
-- HUD siempre visible: ADN, progreso de la Mutadex (12 / 50) y avisos cortos del servidor.
-- HUD (ScreenGui armado en Studio) > ADN (Frame con UIScale "Escala") > Valor (TextLabel)
--                                 > Progreso (TextButton con UIScale "Escala") > Texto, Barra > Relleno
--                                 > Aviso (TextLabel)
-- Tocar Progreso abre la Mutadex (lo maneja Mutadex.client.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local caja = hud:WaitForChild("ADN") :: Frame
local valor = caja:WaitForChild("Valor") :: TextLabel
local escala = caja:WaitForChild("Escala") :: UIScale
local progreso = hud:WaitForChild("Progreso") :: TextButton
local textoProgreso = progreso:WaitForChild("Texto") :: TextLabel
local relleno = progreso:WaitForChild("Barra"):WaitForChild("Relleno") :: Frame
local escalaProgreso = progreso:WaitForChild("Escala") :: UIScale
local aviso = hud:WaitForChild("Aviso") :: TextLabel
local remotos = ReplicatedStorage:WaitForChild("Remotos")

local TOTAL = #Fusion.todas()

local function saltito(e: UIScale)
	e.Scale = 1.15
	TweenService:Create(e, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

local adnAnterior: number? = nil

local function actualizarADN()
	local adn = (jugador:GetAttribute("ADN") :: number?) or 0
	valor.Text = Formato.numero(adn) .. " ADN"
	if adnAnterior and adn ~= adnAnterior then
		saltito(escala)
	end
	adnAnterior = adn
end

local cantidadAnterior: number? = nil

local function actualizarProgreso()
	local n = 0
	for _ in Formato.conjunto(jugador:GetAttribute("Especies") :: string?) do
		n += 1
	end
	textoProgreso.Text = n .. " / " .. TOTAL
	TweenService:Create(relleno, TweenInfo.new(0.4), { Size = UDim2.fromScale(n / TOTAL, 1) })
		:Play()
	if cantidadAnterior and n ~= cantidadAnterior then
		saltito(escalaProgreso)
	end
	cantidadAnterior = n
end

local numeroAviso = 0

local function mostrarAviso(texto: string)
	numeroAviso += 1
	local este = numeroAviso
	aviso.Text = texto
	aviso.Visible = true
	task.delay(2.5, function()
		if numeroAviso == este then
			aviso.Visible = false
		end
	end)
end

jugador:GetAttributeChangedSignal("ADN"):Connect(actualizarADN)
jugador:GetAttributeChangedSignal("Especies"):Connect(actualizarProgreso)
local eventoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent
eventoAviso.OnClientEvent:Connect(mostrarAviso)
actualizarADN()
actualizarProgreso()
