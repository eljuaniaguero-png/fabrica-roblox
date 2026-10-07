--!strict
-- Conecta el HUD (StarterGui.HUD, armado en Studio) con los atributos que publica el servidor.
-- HUD > Panel      > Velocidad, Monedas, Rebirths, ProximoRebirth (TextLabel)
-- HUD > Inventario > DoblePaso, Escudo (TextButton)
-- HUD > Aviso (TextLabel)
-- La tienda y el rebirth no están acá: son puestos en el mapa (TiendaFisica.client.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local panel = hud:WaitForChild("Panel")
local etiquetaVelocidad = panel:WaitForChild("Velocidad") :: TextLabel
local etiquetaMonedas = panel:WaitForChild("Monedas") :: TextLabel
local etiquetaRebirths = panel:WaitForChild("Rebirths") :: TextLabel
local etiquetaProximo = panel:WaitForChild("ProximoRebirth") :: TextLabel
local inventario = hud:WaitForChild("Inventario")
local aviso = hud:WaitForChild("Aviso") :: TextLabel

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local usarConsumible = remotos:WaitForChild("UsarConsumible") :: RemoteEvent
local remotoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent

-- Los colores de "listo" y "esperando" los define el estilo, en atributos del HUD.
local function colorDelHud(nombre: string, porDefecto: Color3): Color3
	local valor = hud:GetAttribute(nombre)
	return if typeof(valor) == "Color3" then valor else porDefecto
end
local COLOR_LISTO = colorDelHud("ColorListo", Color3.fromRGB(70, 200, 110))
local COLOR_ESPERA = colorDelHud("ColorEspera", Color3.fromRGB(90, 90, 100))

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

local function actualizarPanel()
	local velocidad = atributoNumero("Velocidad")
	local multiplicador = math.max(atributoNumero("Multiplicador"), 1)

	etiquetaVelocidad.Text = `Velocidad: {math.floor(velocidad)}`
	etiquetaMonedas.Text = `Monedas: {math.floor(atributoNumero("Monedas"))}`
	etiquetaRebirths.Text = `Rebirths: {atributoNumero("Rebirths")}  (x{multiplicador})`

	if velocidad >= Config.CostoRebirth then
		local monedas = Precios.monedasPorRebirth(velocidad, atributoNumero("Mej_Bolsillo"))
		etiquetaProximo.Text = `¡Rebirth listo! Portal: +{monedas} monedas`
		etiquetaProximo.TextColor3 = COLOR_LISTO
	else
		etiquetaProximo.Text = `Rebirth: {math.floor(velocidad)}/{Config.CostoRebirth}`
		etiquetaProximo.TextColor3 = Color3.fromRGB(170, 160, 210)
	end
end

local function actualizarInventario()
	local ahora = workspace:GetServerTimeNow()
	for _, nombre in Config.OrdenConsumibles do
		local boton = inventario:FindFirstChild(nombre)
		if boton and boton:IsA("TextButton") then
			local cantidad = atributoNumero(`Inv_{nombre}`)
			local restante = atributoNumero(`Hasta_{nombre}`) - ahora
			local consumible = Config.Consumibles[nombre]
			if restante > 0 then
				boton.Text = `{consumible.Nombre} {math.ceil(restante)}s`
			else
				boton.Text = `{consumible.Nombre} x{cantidad}`
			end
			boton.BackgroundColor3 = if cantidad > 0 and consumible.Usable
				then COLOR_LISTO
				else COLOR_ESPERA
		end
	end
end

for _, nombre in Config.OrdenConsumibles do
	local boton = inventario:FindFirstChild(nombre)
	if boton and boton:IsA("TextButton") and Config.Consumibles[nombre].Usable then
		boton.Activated:Connect(function()
			usarConsumible:FireServer(nombre)
		end)
	end
end

-- Aviso: aparece un momento y se desvanece. Si trae un efecto, lo toca.
local avisoTween: Tween? = nil
remotoAviso.OnClientEvent:Connect(function(texto: string, sonido: string?)
	if sonido then
		Sonidos.efecto(sonido)
	end
	if avisoTween then
		avisoTween:Cancel()
	end
	aviso.Text = texto
	aviso.Visible = true
	aviso.TextTransparency = 0
	aviso.TextStrokeTransparency = 0.3
	local tween = TweenService:Create(
		aviso,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.4),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)
	avisoTween = tween
	tween:Play()
end)

jugador.AttributeChanged:Connect(function(nombre)
	if nombre == "Rebirths" then
		print("[Cliente] Rebirth")
	elseif nombre == "Caidas" then
		print("[Cliente] Caída")
	elseif nombre == "Checkpoint" then
		print(`[Cliente] Checkpoint {atributoNumero("Checkpoint")}`)
	end
	actualizarPanel()
	actualizarInventario()
end)

actualizarPanel()
actualizarInventario()

-- Cuenta regresiva de los efectos activos.
while true do
	task.wait(0.25)
	actualizarInventario()
end
