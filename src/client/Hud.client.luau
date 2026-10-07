--!strict
-- Conecta el HUD (StarterGui.HUD, armado en Studio) con los atributos que publica el servidor.
-- HUD > Tarjeta (con UIScale) > Nivel, Progreso (TextLabel), Barra > Relleno (Frame)
--                             > Stats > Velocidad, Pasos, Monedas (Frame > Valor)
--                             > Zonas > Zona1, Zona2, Zona3 (Frame > Texto, Candado; UIStroke = estás ahí)
--                             > RebirthListo (TextLabel debajo: solo cuando podés hacer rebirth)
-- HUD > Inventario > DoblePaso, Escudo, Iman, Reinicio (TextButton)
-- HUD > Combo (TextLabel arriba del inventario: combo y errores que aguanta)
-- HUD > Aviso (TextLabel)
-- La tienda está en el vendedor (Vendedor.client.luau) y el rebirth en el portal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local tarjeta = hud:WaitForChild("Tarjeta") :: Frame
local escala = tarjeta:WaitForChild("Escala") :: UIScale
local etiquetaNivel = tarjeta:WaitForChild("Nivel") :: TextLabel
local etiquetaProgreso = tarjeta:WaitForChild("Progreso") :: TextLabel
local relleno = tarjeta:WaitForChild("Barra"):WaitForChild("Relleno") :: Frame
local stats = tarjeta:WaitForChild("Stats")
local valorVelocidad = stats:WaitForChild("Velocidad"):WaitForChild("Valor") :: TextLabel
local valorPasos = stats:WaitForChild("Pasos"):WaitForChild("Valor") :: TextLabel
local valorMonedas = stats:WaitForChild("Monedas"):WaitForChild("Valor") :: TextLabel
local zonas = tarjeta:WaitForChild("Zonas")
local rebirthListo = tarjeta:WaitForChild("RebirthListo") :: TextLabel
local inventario = hud:WaitForChild("Inventario")
local aviso = hud:WaitForChild("Aviso") :: TextLabel
local etiquetaCombo = hud:WaitForChild("Combo") :: TextLabel

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local usarConsumible = remotos:WaitForChild("UsarConsumible") :: RemoteEvent
local remotoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent

-- Los colores de "listo" y "esperando" los define el estilo, en atributos del HUD.
local function colorDelHud(nombre: string, porDefecto: Color3): Color3
	local valor = hud:GetAttribute(nombre)
	return if typeof(valor) == "Color3" then valor else porDefecto
end
local COLOR_LISTO = colorDelHud("ColorListo", Config.Paleta.Cian)
local COLOR_ESPERA = colorDelHud("ColorEspera", Color3.fromRGB(55, 45, 95))
local AMARILLO_HEX = Config.Paleta.Amarillo:ToHex()

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

-- 1250 -> "1.250", 12500 -> "12,5k", 1250000 -> "1,2M": que entre en la tarjeta.
local function formato(numero: number): string
	local n = math.floor(numero)
	if n >= 1000000 then
		return (string.format("%.1fM", n / 1000000):gsub("%.", ","))
	elseif n >= 10000 then
		return (string.format("%.1fk", n / 1000):gsub("%.", ","))
	end
	local texto = tostring(n)
	return (texto:reverse():gsub("(%d%d%d)(%d)", "%1.%2"):reverse())
end

-- Zonas: las bloqueadas muestran candado y el nivel que piden; la zona donde estás, con borde.
local function actualizarZonas(nivel: number)
	local actual = math.max(atributoNumero("Zona"), 1)
	for indice in Config.Zonas do
		local chip = zonas:FindFirstChild(`Zona{indice}`)
		if chip then
			local minimo = if indice == 1 then 0 else Config.NivelPuertas[indice - 1] or 0
			local abierta = nivel >= minimo
			local texto = chip:FindFirstChild("Texto")
			if texto and texto:IsA("TextLabel") then
				texto.Text = if abierta then `ZONA {indice}` else `NIV {minimo}`
				texto.TextColor3 = if abierta
					then Color3.new(1, 1, 1)
					else Color3.fromRGB(170, 160, 210)
			end
			local candado = chip:FindFirstChild("Candado")
			if candado and candado:IsA("GuiObject") then
				candado.Visible = not abierta
			end
			local borde = chip:FindFirstChildOfClass("UIStroke")
			if borde then
				borde.Enabled = abierta and indice == actual
			end
		end
	end
end

local ultimoNivel = 0
local function actualizarTarjeta()
	local nivel, dentro, necesarios = Niveles.progreso(atributoNumero("PasosTotales"))
	etiquetaNivel.Text = `NIVEL <font color="#{AMARILLO_HEX}">{nivel}</font>`
	etiquetaProgreso.Text = `{formato(dentro)} / {formato(necesarios)} pasos`
	local fraccion = math.clamp(dentro / necesarios, 0, 1)
	if nivel ~= ultimoNivel then
		relleno.Size = UDim2.fromScale(fraccion, 1) -- nivel nuevo: la barra arranca de cero, sin animar
		ultimoNivel = nivel
	else
		TweenService:Create(
			relleno,
			TweenInfo.new(Config.Hud.DuracionBarra, Enum.EasingStyle.Quad),
			{ Size = UDim2.fromScale(fraccion, 1) }
		):Play()
	end

	actualizarZonas(nivel)

	local velocidad = atributoNumero("Velocidad")
	valorVelocidad.Text = formato(velocidad)
	valorPasos.Text = formato(atributoNumero("PasosDisponibles"))
	valorMonedas.Text = formato(atributoNumero("Monedas"))

	if velocidad >= Config.CostoRebirth then
		local monedas = Precios.monedasPorRebirth(velocidad, atributoNumero("Mej_Bolsillo"))
		rebirthListo.Text = `Rebirth listo · portal +{formato(monedas)}`
		rebirthListo.Visible = true
	else
		rebirthListo.Visible = false
	end
end

-- Combo: se ve desde 2 pisadas seguidas, con los errores que todavía aguanta (Combo firme).
local function actualizarCombo()
	local combo = atributoNumero("Combo")
	local aguante = atributoNumero("ComboAguante")
	local bonus = math.min(combo * Config.Combo.BonusPorPisada, Config.Combo.BonusMaximo)
	etiquetaCombo.Visible = combo >= 2
	etiquetaCombo.Text = `COMBO x{combo} · +{math.floor(bonus * 100 + 0.5)}%`
		.. if aguante > 0 then ` · aguanta {aguante}` else ""
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

-- La tarjeta se agranda o achica con el alto de la pantalla, así se lee en celular y en PC.
local function ajustarEscala()
	local camara = workspace.CurrentCamera
	if not camara then
		return
	end
	local ajustes = Config.Hud
	escala.Scale = math.clamp(
		camara.ViewportSize.Y / ajustes.AltoReferencia,
		ajustes.EscalaMinima,
		ajustes.EscalaMaxima
	)
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
	actualizarTarjeta()
	actualizarInventario()
	actualizarCombo()
end)

local camara = workspace.CurrentCamera
if camara then
	camara:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
end
ajustarEscala()
actualizarTarjeta()
actualizarInventario()

-- Cuenta regresiva de los efectos activos.
while true do
	task.wait(0.25)
	actualizarInventario()
end
