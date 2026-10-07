--!strict
-- Conecta el HUD (StarterGui.HUD, armado en Studio) con los atributos que publica el servidor.
-- HUD > Panel     > Velocidad, Monedas, Rebirths (TextLabel), BotonRebirth, BotonConvertir (TextButton)
-- HUD > Inventario > Turbo, Resorte, Escudo (TextButton)
-- HUD > Aviso (TextLabel)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local panel = hud:WaitForChild("Panel")
local etiquetaVelocidad = panel:WaitForChild("Velocidad") :: TextLabel
local etiquetaMonedas = panel:WaitForChild("Monedas") :: TextLabel
local etiquetaRebirths = panel:WaitForChild("Rebirths") :: TextLabel
local botonRebirth = panel:WaitForChild("BotonRebirth") :: TextButton
local botonConvertir = panel:WaitForChild("BotonConvertir") :: TextButton
local inventario = hud:WaitForChild("Inventario")
local aviso = hud:WaitForChild("Aviso") :: TextLabel

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local pedirRebirth = remotos:WaitForChild("PedirRebirth") :: RemoteEvent
local pedirConversion = remotos:WaitForChild("Convertir") :: RemoteEvent
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

	local listoRebirth = velocidad >= Config.CostoRebirth
	botonRebirth.Text = if listoRebirth
		then "¡REBIRTH!"
		else `Rebirth: {math.floor(velocidad)}/{Config.CostoRebirth}`
	botonRebirth.BackgroundColor3 = if listoRebirth then COLOR_LISTO else COLOR_ESPERA
	botonRebirth.AutoButtonColor = listoRebirth

	local listoConvertir = velocidad >= Config.MinimoConversion
	botonConvertir.Text = `Convertir → {math.floor(velocidad * Config.TasaConversion)} monedas`
	botonConvertir.BackgroundColor3 = if listoConvertir then COLOR_LISTO else COLOR_ESPERA
	botonConvertir.AutoButtonColor = listoConvertir
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

botonRebirth.Activated:Connect(function()
	if atributoNumero("Velocidad") >= Config.CostoRebirth then
		pedirRebirth:FireServer()
	end
end)

botonConvertir.Activated:Connect(function()
	pedirConversion:FireServer()
end)

for _, nombre in Config.OrdenConsumibles do
	local boton = inventario:FindFirstChild(nombre)
	if boton and boton:IsA("TextButton") and Config.Consumibles[nombre].Usable then
		boton.Activated:Connect(function()
			usarConsumible:FireServer(nombre)
		end)
	end
end

-- Aviso: aparece un momento y se desvanece.
local avisoTween: Tween? = nil
remotoAviso.OnClientEvent:Connect(function(texto: string)
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
		-- SONIDO: rebirth hecho
		print("[Cliente] Rebirth")
	elseif nombre == "Caidas" then
		-- La nota desafinada de la caída la toca Baldosas.client.luau
		print("[Cliente] Caída")
	end
	actualizarPanel()
	actualizarInventario()
end)

local checkpointAnterior = atributoNumero("Checkpoint")
jugador:GetAttributeChangedSignal("Checkpoint"):Connect(function()
	local checkpoint = atributoNumero("Checkpoint")
	if checkpoint > checkpointAnterior then
		-- SONIDO: checkpoint alcanzado
		print(`[Cliente] Checkpoint {checkpoint}`)
	end
	checkpointAnterior = checkpoint
end)

actualizarPanel()
actualizarInventario()

-- Cuenta regresiva de los efectos activos.
while true do
	task.wait(0.25)
	actualizarInventario()
end
