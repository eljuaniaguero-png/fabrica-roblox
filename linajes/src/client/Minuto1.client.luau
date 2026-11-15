--!strict
-- Onboarding no bloqueante del Minuto 1: bienvenida del Eclipse, lista de 5 hitos en vivo,
-- baliza hacia el maniquí/matón en la Arena y aviso de recompensa al completar.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local remoto = ReplicatedStorage:WaitForChild("Minuto1") :: RemoteEvent
local jugador = Players.LocalPlayer
local playerGui = jugador:WaitForChild("PlayerGui")

local H = Config.Hud.Imagenes
local ACENTO = Color3.fromHex("#f2652b")
local ORO = Color3.fromHex("#ffd34d")
local GRIS = Color3.fromHex("#9fa7b5")
local FONDO_TARJETA = Color3.fromHex("#131722")
local RAPIDO = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local PASOS = {
	{ clave = "Despertar", texto = "Despertá tu Linaje (Ruleta)" },
	{ clave = "Combate", texto = "Conectá un golpe (LMB / E)" },
	{ clave = "Defensa", texto = "Usá Dash o Bloqueo (Q / F)" },
	{ clave = "Poder", texto = "Lanzá un poder (Z / X / C)" },
	{ clave = "Maton", texto = "Desafiá a un Matón del puerto" },
}

local gui = Tema.pantalla("Minuto1", 4)

-- Panel Tracker compacto arriba a la izquierda.
local tracker = Instance.new("CanvasGroup")
tracker.Position = UDim2.fromOffset(22, 82)
tracker.Size = UDim2.fromOffset(330, 250)
-- Escala con la pantalla, igual que el resto del HUD (Tema.grupo).
local escalaTracker = Instance.new("UIScale")
escalaTracker.Parent = tracker
local function ajustarTracker()
	local cam = workspace.CurrentCamera
	local alto = if cam then cam.ViewportSize.Y else Config.Hud.AltoBase
	escalaTracker.Scale =
		math.clamp(alto / Config.Hud.AltoBase, Config.Hud.EscalaMin, Config.Hud.EscalaMax)
end
ajustarTracker()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarTracker)
end
tracker.BackgroundColor3 = FONDO_TARJETA
tracker.BackgroundTransparency = 0.14
tracker.BorderSizePixel = 0
tracker.Visible = false
tracker.Parent = gui

local trCorner = Instance.new("UICorner")
trCorner.CornerRadius = UDim.new(0, 2)
trCorner.Parent = tracker
local trStroke = Instance.new("UIStroke")
trStroke.Color = Tema.Hueso
trStroke.Transparency = 0.82
trStroke.Thickness = 1
trStroke.Parent = tracker

local rombo = Tema.rombo(tracker, Vector2.new(20, 22), 11, true)
rombo.BackgroundColor3 = ACENTO

local trTitulo = Tema.texto(tracker, Tema.espaciar("PRIMEROS PASOS", 2), {
	tam = 16,
	letra = Tema.LetraGruesa,
})
trTitulo.Position = UDim2.fromOffset(36, 13)

local btnSaltar = Instance.new("TextButton")
btnSaltar.AnchorPoint = Vector2.new(1, 0)
btnSaltar.Position = UDim2.new(1, -10, 0, 10)
btnSaltar.Size = UDim2.fromOffset(64, 22)
btnSaltar.BackgroundColor3 = Color3.fromHex("#1f2636")
btnSaltar.Text = "SALTAR"
btnSaltar.TextColor3 = GRIS
btnSaltar.FontFace = Tema.Letra
btnSaltar.TextSize = 11
btnSaltar.Parent = tracker
local skCorner = Instance.new("UICorner")
skCorner.CornerRadius = UDim.new(0, 2)
skCorner.Parent = btnSaltar

local _, barraProgreso = Tema.barra(tracker, Vector2.new(14, 44), 302, 4, ACENTO)

local filas: { [string]: { mark: TextLabel, label: TextLabel } } = {}
for i, paso in PASOS do
	local y = 58 + (i - 1) * 30
	local mark = Tema.texto(tracker, "○", { tam = 17, letra = Tema.LetraGruesa, color = GRIS })
	mark.Position = UDim2.fromOffset(14, y)
	local label = Tema.texto(tracker, paso.texto, {
		tam = 16,
		letra = Tema.LetraFina,
		color = Tema.Hueso,
	})
	label.Position = UDim2.fromOffset(36, y + 1)
	filas[paso.clave] = { mark = mark, label = label }
end

local trPremio = Tema.texto(
	tracker,
	string.format(
		"PREMIO: +%d CHATARRA  ·  +%d XP",
		Config.Minuto1.RecompensaChatarra,
		Config.Minuto1.RecompensaXp
	),
	{ tam = 13, letra = Tema.Letra, color = ORO }
)
trPremio.Position = UDim2.fromOffset(14, 216)

-- Banner superior no bloqueante (Entrada del Eclipse o Celebración al completar).
local banner = Instance.new("CanvasGroup")
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 120) -- debajo de la barra del rival
banner.Size = UDim2.fromOffset(540, 86)
banner.BackgroundColor3 = FONDO_TARJETA
banner.BackgroundTransparency = 0.08
banner.BorderSizePixel = 0
banner.Visible = false
banner.Parent = gui
local bnCorner = Instance.new("UICorner")
bnCorner.CornerRadius = UDim.new(0, 2)
bnCorner.Parent = banner
local bnStroke = Instance.new("UIStroke")
bnStroke.Color = ACENTO
bnStroke.Thickness = 2
bnStroke.Parent = banner

local bnImg = Instance.new("ImageLabel")
bnImg.Position = UDim2.fromOffset(16, 16)
bnImg.Size = UDim2.fromOffset(52, 52)
bnImg.BackgroundTransparency = 1
bnImg.ScaleType = Enum.ScaleType.Fit
bnImg.Image = H.Menu.Eclipse
bnImg.Parent = banner

local bnTitulo = Tema.texto(banner, "", { tam = 18, letra = Tema.LetraGruesa })
bnTitulo.Position = UDim2.fromOffset(82, 14)
local bnDetalle = Tema.texto(banner, "", {
	tam = 13,
	letra = Tema.LetraFina,
	color = GRIS,
})
bnDetalle.Position = UDim2.fromOffset(82, 42)
bnDetalle.AutomaticSize = Enum.AutomaticSize.None
bnDetalle.Size = UDim2.fromOffset(365, 36)
bnDetalle.TextWrapped = true

local bnCerrar = Instance.new("TextButton")
bnCerrar.AnchorPoint = Vector2.new(1, 0.5)
bnCerrar.Position = UDim2.new(1, -12, 0.5, 0)
bnCerrar.Size = UDim2.fromOffset(74, 30)
bnCerrar.BackgroundColor3 = ACENTO
bnCerrar.Text = "OK"
bnCerrar.TextColor3 = Tema.Hueso
bnCerrar.FontFace = Tema.LetraGruesa
bnCerrar.TextSize = 13
bnCerrar.Parent = banner
local bcCorner = Instance.new("UICorner")
bcCorner.CornerRadius = UDim.new(0, 2)
bcCorner.Parent = bnCerrar

local tokenBanner = 0
local function mostrarBanner(
	tituloTxt: string,
	detalleTxt: string,
	icono: string,
	color: Color3,
	dura: number
)
	tokenBanner += 1
	local turno = tokenBanner
	bnTitulo.Text = Tema.espaciar(tituloTxt, 2)
	bnTitulo.TextColor3 = color
	bnDetalle.Text = detalleTxt
	bnImg.Image = icono
	bnStroke.Color = color
	banner.GroupTransparency = 1
	banner.Visible = true
	TweenService:Create(banner, RAPIDO, { GroupTransparency = 0 }):Play()
	task.delay(dura, function()
		if tokenBanner == turno and banner.Visible then
			local tw = TweenService:Create(banner, RAPIDO, { GroupTransparency = 1 })
			tw:Play()
			tw.Completed:Once(function()
				if tokenBanner == turno then
					banner.Visible = false
				end
			end)
		end
	end)
end

bnCerrar.Activated:Connect(function()
	tokenBanner += 1
	banner.Visible = false
end)

btnSaltar.Activated:Connect(function()
	remoto:FireServer("Saltar")
	tracker.Visible = false
	banner.Visible = false
end)

-- Baliza guía en 3D que señala al Maniquí o al Matón más cercano hasta cumplir los pasos.
local pinGui = Instance.new("BillboardGui")
pinGui.Name = "BalizaMinuto1"
pinGui.Size = UDim2.fromOffset(190, 52)
pinGui.StudsOffset = Vector3.new(0, 6.2, 0)
pinGui.AlwaysOnTop = true
pinGui.Enabled = false

local pinMarco = Instance.new("Frame")
pinMarco.Size = UDim2.fromScale(1, 1)
pinMarco.BackgroundColor3 = FONDO_TARJETA
pinMarco.BackgroundTransparency = 0.15
pinMarco.Parent = pinGui
local pmCorner = Instance.new("UICorner")
pmCorner.CornerRadius = UDim.new(0, 2)
pmCorner.Parent = pinMarco
local pmStroke = Instance.new("UIStroke")
pmStroke.Color = ACENTO
pmStroke.Thickness = 2
pmStroke.Parent = pinMarco

local pinTxt = Tema.texto(pinMarco, "ENTRENÁ ACÁ", {
	tam = 13,
	letra = Tema.LetraGruesa,
	color = ORO,
	alineado = Enum.TextXAlignment.Center,
})
pinTxt.AutomaticSize = Enum.AutomaticSize.None
pinTxt.Size = UDim2.new(1, -10, 0, 22)
pinTxt.Position = UDim2.fromOffset(5, 5)

local pinSub = Tema.texto(pinMarco, "", {
	tam = 11,
	letra = Tema.LetraFina,
	color = Tema.Hueso,
	alineado = Enum.TextXAlignment.Center,
})
pinSub.AutomaticSize = Enum.AutomaticSize.None
pinSub.Size = UDim2.new(1, -10, 0, 18)
pinSub.Position = UDim2.fromOffset(5, 28)

pinGui.Parent = playerGui

local introMostrada = false

local function visibleMinuto1(): boolean
	return jugador:GetAttribute("DatosListos") == true
		and jugador:GetAttribute("TutorialHecho") == false
		and jugador:GetAttribute("MenuAbierto") ~= true
		and jugador:GetAttribute("EnCreador") ~= true
		and jugador:GetAttribute("AbrirCreador") ~= true
		and jugador:GetAttribute("AparienciaCreada") ~= false
end

local function actualizar()
	local mostrar = visibleMinuto1()
	tracker.Visible = mostrar
	if not mostrar then
		pinGui.Enabled = false
		return
	end
	if not introMostrada then
		introMostrada = true
		mostrarBanner(
			"NOCHE DEL ECLIPSE  ·  PUERTO ÓXIDO",
			"Despertá tu Linaje en la Ruleta del Eclipse o salí del círculo celeste para entrenar.",
			H.Menu.Eclipse,
			ACENTO,
			5.5
		)
	end
	local colorLinaje = Tema.color(jugador:GetAttribute("Linaje"))
	local hechos = 0
	for _, paso in PASOS do
		local ok = jugador:GetAttribute("M1_" .. paso.clave) == true
		local fila = filas[paso.clave]
		if ok then
			hechos += 1
			fila.mark.Text = "✓"
			fila.mark.TextColor3 = if paso.clave == "Despertar" then colorLinaje else ORO
			fila.label.TextTransparency = 0.38
		else
			fila.mark.Text = "○"
			fila.mark.TextColor3 = GRIS
			fila.label.TextTransparency = 0
		end
	end
	barraProgreso.BackgroundColor3 = colorLinaje
	TweenService:Create(barraProgreso, RAPIDO, { Size = UDim2.fromScale(hechos / #PASOS, 1) })
		:Play()
end

jugador:GetAttributeChangedSignal("TutorialHecho"):Connect(function()
	if jugador:GetAttribute("TutorialHecho") == false then
		introMostrada = false
	end
	actualizar()
end)

for _, attr in
	{
		"DatosListos",
		"MenuAbierto",
		"EnCreador",
		"AbrirCreador",
		"AparienciaCreada",
		"Linaje",
		"M1_Despertar",
		"M1_Combate",
		"M1_Defensa",
		"M1_Poder",
		"M1_Maton",
	}
do
	jugador:GetAttributeChangedSignal(attr):Connect(actualizar)
end

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any)
	if tipo == "Completado" then
		tracker.Visible = false
		pinGui.Enabled = false
		local chat = if typeof(a) == "number" then a else Config.Minuto1.RecompensaChatarra
		local xp = if typeof(b) == "number" then b else Config.Minuto1.RecompensaXp
		mostrarBanner(
			"¡LISTO PARA EL PUERTO!",
			string.format(
				"+%d Chatarra · +%d XP. Subiste de nivel: gastá tu punto en M → ÁRBOL Y PODERES.",
				chat,
				xp
			),
			H.Menu.Estrella,
			ORO,
			6.0
		)
	end
end)

local ultimoBuscado = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - ultimoBuscado < 0.35 then
		return
	end
	ultimoBuscado = os.clock()
	if not visibleMinuto1() or jugador:GetAttribute("M1_Maton") == true then
		pinGui.Enabled = false
		return
	end
	local p = jugador.Character
	local miRaiz = p and p:FindFirstChild("HumanoidRootPart")
	if not (miRaiz and miRaiz:IsA("BasePart")) then
		pinGui.Enabled = false
		return
	end
	local buscaMaton = jugador:GetAttribute("M1_Combate") == true
	local mejorParte: BasePart? = nil
	local mejorDist = 180
	for _, m in CollectionService:GetTagged("Combatiente") do
		if m ~= p and m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
			local esMaton = m:GetAttribute("Maton") == true
			if (buscaMaton and esMaton) or (not buscaMaton and not esMaton) then
				local h = m:FindFirstChildOfClass("Humanoid")
				local r = m:FindFirstChild("HumanoidRootPart")
				if h and h.Health > 0 and r and r:IsA("BasePart") then
					local d = (r.Position - miRaiz.Position).Magnitude
					if d < mejorDist then
						mejorDist = d
						mejorParte = r
					end
				end
			end
		end
	end
	if mejorParte and mejorDist > 12 then
		pinGui.Adornee = mejorParte
		pinTxt.Text = if buscaMaton then "OBJETIVO: MATÓN" else "PROBÁ TUS GOLPES"
		pinSub.Text = string.format("A %.0f m · Salí de la zona celeste", mejorDist)
		pinGui.Enabled = true
	else
		pinGui.Enabled = false
	end
end)

actualizar()
gui.Parent = playerGui
