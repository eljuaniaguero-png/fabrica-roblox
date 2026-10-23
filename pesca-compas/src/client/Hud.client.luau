--!strict
-- HUD de pesca (estilo "Toon de playa", shared/Estilo.luau): Escamas, nivel, balde, mejoras, probabilidades y avisos.
-- Se actualiza solo cuando el servidor manda el estado (sin revisar en cada frame).
-- Las probabilidades se muestran siempre, aunque no se pague por ellas (ficha, sección 5).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estilo = require(ReplicatedStorage.Shared:WaitForChild("Estilo"))
local UI = Estilo.UI
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HudGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 4
gui.Parent = jugador:WaitForChild("PlayerGui")

local function etiqueta(padre: Instance, tam: UDim2, pos: UDim2, alineado: Enum.TextXAlignment?): TextLabel
	local t = Instance.new("TextLabel")
	t.Size = tam
	t.Position = pos
	t.BackgroundTransparency = 1
	t.Font = UI.Fuente
	t.TextScaled = true
	t.TextColor3 = UI.Texto
	t.TextXAlignment = alineado or Enum.TextXAlignment.Left
	Estilo.bordeTexto(t)
	t.Parent = padre
	return t
end

local function boton(texto: string, pos: UDim2, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromScale(0.16, 0.06)
	b.Position = pos
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.BackgroundColor3 = color
	b.Font = UI.Fuente
	b.TextScaled = true
	b.TextColor3 = UI.Texto
	b.Text = texto
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, UI.Esquina)
	esquina.Parent = b
	Estilo.borde(b)
	b.Parent = gui
	return b
end

-- arriba a la izquierda
local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.22, 0.16)
panel.Position = UDim2.fromScale(0.01, 0.02)
panel.BackgroundColor3 = UI.PanelOscuro
panel.BackgroundTransparency = 0.1
panel.Parent = gui
local esquinaPanel = Instance.new("UICorner")
esquinaPanel.CornerRadius = UDim.new(0, UI.Esquina)
esquinaPanel.Parent = panel
Estilo.borde(panel)

local tEscamas = etiqueta(panel, UDim2.fromScale(0.9, 0.32), UDim2.fromScale(0.05, 0.04))
tEscamas.TextColor3 = UI.Escamas
local tNivel = etiqueta(panel, UDim2.fromScale(0.9, 0.2), UDim2.fromScale(0.05, 0.4))
local barraXP = Instance.new("Frame")
barraXP.Size = UDim2.fromScale(0.9, 0.08)
barraXP.Position = UDim2.fromScale(0.05, 0.62)
barraXP.BackgroundColor3 = Estilo.Contorno
barraXP.BorderSizePixel = 0
barraXP.Parent = panel
local rellenoXP = Instance.new("Frame")
rellenoXP.Size = UDim2.fromScale(0, 1)
rellenoXP.BackgroundColor3 = UI.XP
rellenoXP.BorderSizePixel = 0
rellenoXP.Parent = barraXP
local tBalde = etiqueta(panel, UDim2.fromScale(0.9, 0.2), UDim2.fromScale(0.05, 0.76))

-- mejoras a la derecha
local bCana = boton("Caña", UDim2.fromScale(0.99, 0.42), UI.BotonCana)
local bBalde = boton("Balde", UDim2.fromScale(0.99, 0.5), UI.BotonBalde)
bCana.Activated:Connect(function()
	Remotos.Mejorar:FireServer("Cana")
end)
bBalde.Activated:Connect(function()
	Remotos.Mejorar:FireServer("Balde")
end)

-- misión arriba a la derecha (la de las referencias: "Visita el océano")
local panelMision = Instance.new("Frame")
panelMision.Size = UDim2.fromScale(0.24, 0.13)
panelMision.Position = UDim2.fromScale(0.99, 0.02)
panelMision.AnchorPoint = Vector2.new(1, 0)
panelMision.BackgroundColor3 = UI.PanelOscuro
panelMision.BackgroundTransparency = 0.1
panelMision.Parent = gui
local esquinaMision = Instance.new("UICorner")
esquinaMision.CornerRadius = UDim.new(0, UI.Esquina)
esquinaMision.Parent = panelMision
Estilo.borde(panelMision)

local tMisionTitulo = etiqueta(panelMision, UDim2.fromScale(0.9, 0.22), UDim2.fromScale(0.05, 0.06))
tMisionTitulo.Text = "📜 MISIÓN"
tMisionTitulo.TextColor3 = UI.Perfecto
local tMision = etiqueta(panelMision, UDim2.fromScale(0.9, 0.3), UDim2.fromScale(0.05, 0.3))
local barraMision = Instance.new("Frame")
barraMision.Size = UDim2.fromScale(0.62, 0.16)
barraMision.Position = UDim2.fromScale(0.05, 0.72)
barraMision.BackgroundColor3 = Estilo.Contorno
barraMision.BorderSizePixel = 0
barraMision.Parent = panelMision
local rellenoMision = Instance.new("Frame")
rellenoMision.Size = UDim2.fromScale(0, 1)
rellenoMision.BackgroundColor3 = UI.XP
rellenoMision.BorderSizePixel = 0
rellenoMision.Parent = barraMision
local tMisionPremio = etiqueta(panelMision, UDim2.fromScale(0.26, 0.22), UDim2.fromScale(0.7, 0.69), Enum.TextXAlignment.Right)
tMisionPremio.TextColor3 = UI.Escamas

-- tarjeta de premio (misión cumplida o premio diario), una por vez y en fila
local tarjeta = Instance.new("Frame")
tarjeta.Size = UDim2.fromScale(0.3, 0.14)
tarjeta.Position = UDim2.fromScale(0.5, -0.2)
tarjeta.AnchorPoint = Vector2.new(0.5, 0)
tarjeta.BackgroundColor3 = UI.PanelOscuro
tarjeta.Parent = gui
local esquinaTarjeta = Instance.new("UICorner")
esquinaTarjeta.CornerRadius = UDim.new(0, UI.Esquina)
esquinaTarjeta.Parent = tarjeta
Estilo.borde(tarjeta)
local aspecto = Instance.new("UIAspectRatioConstraint")
aspecto.AspectRatio = 3.2
aspecto.Parent = tarjeta
local tTarjetaTitulo = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.28), UDim2.fromScale(0.05, 0.08), Enum.TextXAlignment.Center)
tTarjetaTitulo.TextColor3 = UI.Perfecto
local tTarjetaTexto = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.26), UDim2.fromScale(0.05, 0.38), Enum.TextXAlignment.Center)
local tTarjetaEscamas = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.26), UDim2.fromScale(0.05, 0.66), Enum.TextXAlignment.Center)
tTarjetaEscamas.TextColor3 = UI.Escamas

local ARRIBA = UDim2.fromScale(0.5, 0.24)
local AFUERA = UDim2.fromScale(0.5, -0.2)
local fila: { { Tipo: string, Datos: any } } = {}
local mostrando = false

local function mostrarSiguiente()
	if mostrando or #fila == 0 then
		return
	end
	mostrando = true
	local p = table.remove(fila, 1) :: { Tipo: string, Datos: any }
	tTarjetaTitulo.Text = if p.Tipo == "Diario" then "🎁 ¡PREMIO DIARIO!" else "✅ ¡MISIÓN CUMPLIDA!"
	tTarjetaTexto.Text = p.Datos.Texto
	tTarjetaEscamas.Text = ("+%d 🐟 Escamas"):format(p.Datos.Escamas)
	tarjeta.Position = AFUERA
	local entra = TweenService:Create(tarjeta, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = ARRIBA })
	entra:Play()
	task.delay(2.8, function()
		local sale = TweenService:Create(tarjeta, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = AFUERA })
		sale:Play()
		sale.Completed:Wait()
		mostrando = false
		mostrarSiguiente()
	end)
end

Remotos.Premio.OnClientEvent:Connect(function(tipo: string, datos: any)
	if typeof(datos) ~= "table" then
		return
	end
	table.insert(fila, { Tipo = tipo, Datos = datos })
	mostrarSiguiente()
end)

-- probabilidades abajo a la izquierda
local partes = {}
for _, r in Config.Rarezas do
	table.insert(partes, ('<font color="#%s">%s %g%%</font>'):format(r.Color:ToHex(), r.Id, r.Chance * 100))
end
local tProbs = etiqueta(gui, UDim2.fromScale(0.45, 0.03), UDim2.fromScale(0.01, 0.95))
tProbs.RichText = true
tProbs.Text = "Probabilidades: " .. table.concat(partes, " · ")

-- aviso arriba al centro
local tAviso = etiqueta(gui, UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.25, 0.18), Enum.TextXAlignment.Center)
tAviso.TextTransparency = 1
local avisoId = 0
Remotos.Aviso.OnClientEvent:Connect(function(texto: string)
	avisoId += 1
	local id = avisoId
	tAviso.Text = texto
	tAviso.TextTransparency = 0
	task.delay(2.5, function()
		if id == avisoId then
			TweenService:Create(tAviso, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		end
	end)
end)

local escamasAntes: number? = nil
Remotos.Estado.OnClientEvent:Connect(function(e: any)
	tEscamas.Text = ("🐟 %d Escamas"):format(e.Escamas)
	if escamasAntes and e.Escamas > escamasAntes then
		tEscamas.Size = UDim2.fromScale(1, 0.38)
		TweenService:Create(tEscamas, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Size = UDim2.fromScale(0.9, 0.32) })
			:Play()
	end
	escamasAntes = e.Escamas
	tNivel.Text = ("Nivel %d"):format(e.Nivel)
	rellenoXP:TweenSize(UDim2.fromScale(e.XPNivel / e.XPSiguiente, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	tBalde.Text = ("Balde %d/%d"):format(e.EnBalde, e.Capacidad)
	tBalde.TextColor3 = if e.EnBalde >= e.Capacidad then UI.Error else UI.Texto
	bCana.Text = if e.PrecioCana then ("Caña %d → %d · %d 🐟"):format(e.Cana, e.Cana + 1, e.PrecioCana) else "Caña MÁX"
	bBalde.Text = if e.PrecioBalde then ("Balde %d → %d · %d 🐟"):format(e.Balde, e.Balde + 1, e.PrecioBalde) else "Balde MÁX"
	bCana.AutoButtonColor = e.PrecioCana ~= nil and e.Escamas >= e.PrecioCana
	bCana.BackgroundTransparency = if bCana.AutoButtonColor then 0 else 0.5
	bBalde.AutoButtonColor = e.PrecioBalde ~= nil and e.Escamas >= e.PrecioBalde
	bBalde.BackgroundTransparency = if bBalde.AutoButtonColor then 0 else 0.5
	local m = e.Mision
	if m then
		tMision.Text = m.Texto
		tMisionPremio.Text = ("+%d 🐟"):format(m.Premio)
		local avance = math.clamp(m.Progreso / math.max(m.Meta, 1), 0, 1)
		rellenoMision:TweenSize(UDim2.fromScale(avance, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	end
end)
Remotos.Estado:FireServer()
