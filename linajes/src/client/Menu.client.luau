--!strict
-- Menú principal editorial (PC y celular): portada, espacios, árbol de poderes, ajustes y resumen.
-- Se abre al entrar y con M (o el botón discreto "M · MENÚ" arriba a la izquierda).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local H = Config.Hud
local P = Config.Poderes
local IM = H.Imagenes
local MU = H.MenuUI
local jugador = Players.LocalPlayer
local playerGui = jugador:WaitForChild("PlayerGui")

local GRIS = Color3.fromHex("#9FA7B5")
local APAGADO = Color3.fromHex("#565E6D")
local COFRADIA = Color3.fromHex("#C2213A")
local LIGA = Color3.fromHex("#2F6FDB")
local VIGILANTES = Color3.fromHex("#6B5BA8")

local nombresLinaje: { [string]: string } = {}
for _, o in Config.Ruleta.Opciones do
	nombresLinaje[o.Linaje] = o.Nombre
end

local gui = Tema.pantalla("MenuPrincipal", 10)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Botón discreto arriba a la derecha (junto a RULETA, libre del TopBar).
local botonGui = Tema.pantalla("BotonMenu", 2)
botonGui.ResetOnSpawn = false
local esquinaMenu = Tema.grupo(
	botonGui,
	Vector2.new(1, 0),
	UDim2.new(1, -(H.Margen + 152), 0, 48),
	Vector2.new(150, 46)
)
local abrirMenuBtn = Instance.new("TextButton")
abrirMenuBtn.Size = UDim2.fromScale(1, 1)
abrirMenuBtn.BackgroundTransparency = 1
abrirMenuBtn.Text = ""
abrirMenuBtn.Parent = esquinaMenu
local txtAbrir = Tema.texto(esquinaMenu, "M  MENÚ", { tam = 20, espaciado = 3 })
txtAbrir.AnchorPoint = Vector2.new(1, 0)
txtAbrir.Position = UDim2.fromScale(1, 0)
local rayaAbrir = Instance.new("Frame")
rayaAbrir.AnchorPoint = Vector2.new(1, 0)
rayaAbrir.Position = UDim2.new(1, 0, 0, 34)
rayaAbrir.Size = UDim2.fromOffset(118, 2)
rayaAbrir.BackgroundColor3 = Tema.Hueso
rayaAbrir.BackgroundTransparency = 0.65
rayaAbrir.BorderSizePixel = 0
rayaAbrir.Parent = esquinaMenu
abrirMenuBtn.MouseEnter:Connect(function()
	rayaAbrir.BackgroundTransparency = 0.15
end)
abrirMenuBtn.MouseLeave:Connect(function()
	rayaAbrir.BackgroundTransparency = 0.65
end)

-- Fondo atmosférico + viñeta lateral izquierda.
local fondo = Instance.new("Frame")
fondo.Size = UDim2.fromScale(1, 1)
fondo.BackgroundColor3 = Color3.fromHex("#080A0E")
fondo.BackgroundTransparency = if IM.Menu.Fondo ~= "" then 0 else 1
fondo.BorderSizePixel = 0
fondo.Parent = gui

if IM.Menu.Fondo ~= "" then
	local fondoImg = Instance.new("ImageLabel")
	fondoImg.AnchorPoint = Vector2.new(0.5, 0.5)
	fondoImg.Position = UDim2.fromScale(0.5, 0.5)
	fondoImg.Size = UDim2.fromScale(MU.ZoomFondo, MU.ZoomFondo)
	fondoImg.BackgroundTransparency = 1
	fondoImg.ScaleType = Enum.ScaleType.Crop
	fondoImg.Image = IM.Menu.Fondo
	fondoImg.Parent = fondo
	-- Paneo lento de ida y vuelta: la escena "respira" sin distraer.
	TweenService:Create(
		fondoImg,
		TweenInfo.new(MU.PaneoSegundos, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.fromScale(0.5 - MU.PaneoDistancia, 0.5 + MU.PaneoDistancia * 0.5) }
	):Play()
end

-- El fondo pintado ya trae su eclipse: el suelto va solo si no hay fondo (si no, salen dos).
if IM.Menu.Eclipse ~= "" and IM.Menu.Fondo == "" then
	local eclipseImg = Instance.new("ImageLabel")
	eclipseImg.AnchorPoint = Vector2.new(0.5, 0.5)
	eclipseImg.Position = UDim2.fromScale(0.68, 0.42)
	eclipseImg.Size = UDim2.fromScale(0.46, 0.72)
	eclipseImg.BackgroundTransparency = 1
	eclipseImg.ScaleType = Enum.ScaleType.Fit
	eclipseImg.Image = IM.Menu.Eclipse
	eclipseImg.ImageTransparency = 0.08
	eclipseImg.ZIndex = 2
	eclipseImg.Parent = fondo
end

local velo = Instance.new("Frame")
velo.Size = UDim2.fromScale(1, 1)
velo.BackgroundColor3 = Color3.fromHex("#080A0E")
velo.BorderSizePixel = 0
velo.ZIndex = 3
velo.Parent = fondo
local grad = Instance.new("UIGradient")
grad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.1),
	NumberSequenceKeypoint.new(0.45, 0.45),
	NumberSequenceKeypoint.new(1, 0.86),
})
grad.Parent = velo

-- Banda de niebla que se desplaza de costado.
-- Va dentro de un CanvasGroup con degradé vertical: así se esfuma arriba y no deja un borde recto.
local nieblaCaja = Instance.new("CanvasGroup")
nieblaCaja.AnchorPoint = Vector2.new(0, 1)
nieblaCaja.Position = UDim2.fromScale(0, 1)
nieblaCaja.Size = UDim2.fromScale(1, 0.45)
nieblaCaja.BackgroundTransparency = 1
nieblaCaja.ZIndex = 3
nieblaCaja.Parent = fondo
local nieblaAlto = Instance.new("UIGradient")
nieblaAlto.Rotation = 90
nieblaAlto.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0.3),
})
nieblaAlto.Parent = nieblaCaja
local niebla = Instance.new("Frame")
niebla.Size = UDim2.fromScale(1, 1)
niebla.BackgroundColor3 = Color3.fromHex("#9FB4CC")
niebla.BackgroundTransparency = 0
niebla.BorderSizePixel = 0
niebla.ZIndex = 3
niebla.Parent = nieblaCaja
local nieblaGrad = Instance.new("UIGradient")
nieblaGrad.Rotation = 0
nieblaGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.25, 0.93),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(0.75, 0.9),
	NumberSequenceKeypoint.new(1, 1),
})
nieblaGrad.Offset = Vector2.new(-0.5, 0)
nieblaGrad.Parent = niebla
TweenService:Create(
	nieblaGrad,
	TweenInfo.new(MU.NieblaSegundos, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{ Offset = Vector2.new(0.5, 0) }
):Play()

-- Telón negro para el fundido de entrada (arriba de todo el fondo).
local telon = Instance.new("Frame")
telon.Size = UDim2.fromScale(1, 1)
telon.BackgroundColor3 = Color3.fromHex("#080A0E")
telon.BackgroundTransparency = 1
telon.BorderSizePixel = 0
telon.ZIndex = 9
telon.Parent = fondo

-- Brasas: chispas chicas que suben desde abajo, se mecen y se apagan.
local capaBrasas = Instance.new("Frame")
capaBrasas.Size = UDim2.fromScale(1, 1)
capaBrasas.BackgroundTransparency = 1
capaBrasas.ZIndex = 4
capaBrasas.Parent = fondo
local COLORES_BRASA =
	{ Color3.fromHex("#F2A23A"), Color3.fromHex("#F2652B"), Color3.fromHex("#FFD58A") }

local function lanzarBrasa()
	local b = Instance.new("Frame")
	local lado = math.random(3, 6)
	b.AnchorPoint = Vector2.new(0.5, 0.5)
	b.Size = UDim2.fromOffset(lado, lado)
	b.Rotation = 45
	b.BackgroundColor3 = COLORES_BRASA[math.random(1, #COLORES_BRASA)]
	b.BackgroundTransparency = 0.15
	b.BorderSizePixel = 0
	b.ZIndex = 4
	local x = math.random(30, 100) / 100
	b.Position = UDim2.fromScale(x, 1.02)
	b.Parent = capaBrasas
	local dura = math.random(60, 110) / 10
	local deriva = math.random(-8, 8) / 100
	TweenService:Create(b, TweenInfo.new(dura, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(x + deriva, math.random(15, 55) / 100),
		Rotation = 45 + math.random(-180, 180),
		BackgroundTransparency = 1,
	}):Play()
	task.delay(dura, function()
		b:Destroy()
	end)
end

if IM.Vineta ~= "" then
	local vin = Instance.new("ImageLabel")
	vin.Size = UDim2.fromScale(1, 1)
	vin.BackgroundTransparency = 1
	vin.Image = IM.Vineta
	vin.ImageTransparency = 0.18
	vin.ZIndex = 4
	vin.Parent = fondo
end

-- Contenedor lógico responsivo (1280x720 de referencia con UIScale proporcional).
local contenido = Instance.new("Frame")
contenido.AnchorPoint = Vector2.new(0.5, 0.5)
contenido.Position = UDim2.fromScale(0.5, 0.5)
contenido.Size = UDim2.fromScale(1, 1)
contenido.BackgroundTransparency = 1
contenido.ZIndex = 10
contenido.Parent = gui

local escalaUI = Instance.new("UIScale")
escalaUI.Parent = contenido

local function ajustarEscala()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local v = cam.ViewportSize
	local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.52, 1.15) * MU.Zoom
	escalaUI.Scale = s
	contenido.Size = UDim2.fromScale(1 / s, 1 / s)
end

local function conectarCamara()
	local cam = workspace.CurrentCamera
	if cam then
		ajustarEscala()
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
	end
end
conectarCamara()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(conectarCamara)

-- Columna izquierda editorial
-- CanvasGroup: se puede fundir entera al abrir. Sin Tema.grupo: ese escalaba por segunda vez
-- y dejaba todo al 67 % (por eso se veía chiquito).
local columna = Instance.new("CanvasGroup")
columna.AnchorPoint = Vector2.new(0, 0.5)
columna.Position = UDim2.new(0, 68, 0.5, 0)
columna.Size = UDim2.fromOffset(560, 600)
columna.BackgroundTransparency = 1
columna.Parent = contenido

local sector = Tema.texto(
	columna,
	Tema.espaciar("PUERTO ÓXIDO  ·  SECTOR PORTUARIO", 3),
	{ tam = 15, letra = Tema.LetraFina, color = GRIS }
)
sector.Position = UDim2.fromOffset(0, 0)

if IM.Menu.Logo ~= "" then
	local logoImg = Instance.new("ImageLabel")
	logoImg.Position = UDim2.fromOffset(-8, 22)
	logoImg.Size = UDim2.fromOffset(470, 104)
	logoImg.BackgroundTransparency = 1
	logoImg.ScaleType = Enum.ScaleType.Fit
	logoImg.Image = IM.Menu.Logo
	logoImg.Parent = columna
else
	local titulo = Tema.texto(
		columna,
		Tema.espaciar("LINAJES DEL ECLIPSE", 3),
		{ tam = 40, letra = Tema.LetraGruesa, color = Tema.Hueso }
	)
	titulo.Position = UDim2.fromOffset(0, 26)
end

Tema.ornamento(columna, Vector2.new(200, 136), 400)

-- Botonera principal
local yBase = 176
local paso = 82
local filasMenu: { Frame } = {}
local romboActivo: Frame? = nil
local RAPIDO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tween(obj: Instance, info: TweenInfo, props: { [string]: any })
	TweenService:Create(obj, info, props):Play()
end
local botonPrincipalTxt: TextLabel
local subPrincipalTxt: TextLabel

local function crearItemMenu(
	filaY: number,
	etiqueta: string,
	activo: boolean,
	iconoId: string
): (TextButton, Frame, TextLabel)
	local fila = Instance.new("Frame")
	fila.Position = UDim2.fromOffset(0, filaY)
	fila.Size = UDim2.fromOffset(470, 60)
	fila.BackgroundTransparency = 1
	fila.Parent = columna
	table.insert(filasMenu, fila)

	local rombo = Instance.new("Frame")
	rombo.AnchorPoint = Vector2.new(0.5, 0.5)
	rombo.Position = UDim2.fromOffset(12, 22)
	rombo.Size = UDim2.fromOffset(if activo then 17 else 14, if activo then 17 else 14)
	rombo.Rotation = 45
	rombo.BackgroundColor3 = Tema.Hueso
	rombo.BackgroundTransparency = if activo then 0 else 1
	rombo.BorderSizePixel = 0
	rombo.Parent = fila
	local bordeR = Instance.new("UIStroke")
	bordeR.Color = if activo then Tema.Hueso else GRIS
	bordeR.Thickness = 1.4
	bordeR.Parent = rombo

	local txt = Tema.texto(fila, Tema.espaciar(etiqueta, 3), {
		tam = if activo then 32 else 26,
		letra = if activo then Tema.Letra else Tema.LetraFina,
		color = if activo then Tema.Hueso else GRIS,
	})
	txt.Position = UDim2.fromOffset(38, 2)

	-- Raya que crece debajo del texto al pasar el mouse.
	local raya = Instance.new("Frame")
	raya.Position = UDim2.fromOffset(38, 44)
	raya.Size = UDim2.fromOffset(0, 2)
	raya.BackgroundColor3 = Tema.Hueso
	raya.BorderSizePixel = 0
	raya.Parent = fila

	if iconoId ~= "" then
		local ico = Instance.new("ImageLabel")
		ico.AnchorPoint = Vector2.new(0, 0.5)
		ico.Position = UDim2.fromOffset(400, 22)
		ico.Size = UDim2.fromOffset(28, 28)
		ico.BackgroundTransparency = 1
		ico.ScaleType = Enum.ScaleType.Fit
		ico.Image = iconoId
		ico.ImageColor3 = GRIS
		ico.ImageTransparency = 0.25
		ico.Parent = fila
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = fila

	local function encender()
		-- SONIDO: pasar por un botón del menú (Config.Sonidos)
		tween(txt, RAPIDO, { TextColor3 = Tema.Hueso, Position = UDim2.fromOffset(50, 2) })
		tween(rombo, RAPIDO, { BackgroundTransparency = 0.25, Rotation = 135 })
		tween(
			raya,
			RAPIDO,
			{ Size = UDim2.fromOffset(txt.AbsoluteSize.X / math.max(escalaUI.Scale, 0.01), 2) }
		)
	end
	local function apagar()
		tween(txt, RAPIDO, {
			TextColor3 = if activo then Tema.Hueso else GRIS,
			Position = UDim2.fromOffset(38, 2),
		})
		tween(rombo, RAPIDO, { BackgroundTransparency = if activo then 0 else 1, Rotation = 45 })
		tween(raya, RAPIDO, { Size = UDim2.fromOffset(0, 2) })
	end
	btn.MouseEnter:Connect(encender)
	btn.SelectionGained:Connect(encender)
	btn.MouseLeave:Connect(apagar)
	btn.SelectionLost:Connect(apagar)
	btn.Activated:Connect(function()
		-- SONIDO: tocar un botón del menú
		rombo.Size += UDim2.fromOffset(8, 8)
		tween(rombo, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.fromOffset(if activo then 17 else 14, if activo then 17 else 14),
		})
	end)
	if activo then
		romboActivo = rombo
	end

	return btn, rombo, txt
end

local btnContinuar, _, txtContinuar = crearItemMenu(yBase, "CONTINUAR", true, "")
botonPrincipalTxt = txtContinuar
subPrincipalTxt = Tema.texto(columna, "", { tam = 17, letra = Tema.LetraFina, color = GRIS })
subPrincipalTxt.Position = UDim2.fromOffset(38, yBase + 44)

-- Fila 2: ESPACIOS < 1 / 3 >
local _, _, _ = crearItemMenu(yBase + paso, "ESPACIOS", false, "")
local espacioActual = 1
local totalEspacios = 3
local textoEspacio = Tema.texto(columna, "1 / 3", {
	tam = 22,
	letra = Tema.Letra,
	color = Tema.Hueso,
	alineado = Enum.TextXAlignment.Center,
})
textoEspacio.AutomaticSize = Enum.AutomaticSize.None
textoEspacio.Position = UDim2.fromOffset(318, yBase + paso + 6)
textoEspacio.Size = UDim2.fromOffset(84, 32)
local notaEspacio = Tema.texto(columna, "", { tam = 16, letra = Tema.LetraFina, color = APAGADO })
notaEspacio.Position = UDim2.fromOffset(38, yBase + paso + 44)

local function crearFlecha(x: number, rotacion: number, textoAlt: string): TextButton
	local fbtn = Instance.new("TextButton")
	fbtn.Position = UDim2.fromOffset(x, yBase + paso)
	fbtn.Size = UDim2.fromOffset(44, 44)
	fbtn.BackgroundTransparency = 1
	fbtn.Text = if IM.Menu.Flecha == "" then textoAlt else ""
	fbtn.TextColor3 = Tema.Hueso
	fbtn.FontFace = Tema.Letra
	fbtn.TextSize = 26
	fbtn.Parent = columna
	if IM.Menu.Flecha ~= "" then
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Size = UDim2.fromOffset(26, 26)
		img.Rotation = rotacion
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = IM.Menu.Flecha
		img.ImageColor3 = Tema.Hueso
		img.Parent = fbtn
	end
	return fbtn
end

local btnEspAnt = crearFlecha(272, 180, "‹")
local btnEspSig = crearFlecha(404, 0, "›")

local function refrescarEspacios()
	textoEspacio.TextTransparency = 1
	tween(textoEspacio, RAPIDO, { TextTransparency = 0 })
	textoEspacio.Text = string.format("%d / %d", espacioActual, totalEspacios)
	notaEspacio.Text = if espacioActual == 1
		then "Ranura activa"
		else "Ranura vacía  ·  Próximamente"
end
btnEspAnt.Activated:Connect(function()
	espacioActual = if espacioActual <= 1 then totalEspacios else espacioActual - 1
	refrescarEspacios()
end)
btnEspSig.Activated:Connect(function()
	espacioActual = if espacioActual >= totalEspacios then 1 else espacioActual + 1
	refrescarEspacios()
end)
refrescarEspacios()

local btnArbol = crearItemMenu(yBase + paso * 2, "ÁRBOL Y PODERES", false, IM.Menu.Arbol)
local btnAjustes = crearItemMenu(yBase + paso * 3, "AJUSTES", false, IM.Menu.Ajustes)
local btnCreditos = crearItemMenu(yBase + paso * 4, "CRÉDITOS", false, "")

-- Panel derecho secundario (Árbol / Ajustes / Créditos)
local cajon = Instance.new("CanvasGroup")
cajon.AnchorPoint = Vector2.new(1, 0)
cajon.Position = UDim2.new(1, -68, 0, 74)
cajon.Size = UDim2.fromOffset(500, 360)
cajon.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
cajon.BackgroundTransparency = 0.1
cajon.BorderSizePixel = 0
cajon.Visible = false
cajon.Parent = contenido
local bordeCajon = Instance.new("UIStroke")
bordeCajon.Color = Tema.Hueso
bordeCajon.Transparency = 0.8
bordeCajon.Parent = cajon

local cajonTitulo = Tema.texto(cajon, "", { tam = 22, espaciado = 3 })
cajonTitulo.Position = UDim2.fromOffset(22, 18)

local cerrarCajon = Instance.new("TextButton")
cerrarCajon.AnchorPoint = Vector2.new(1, 0)
cerrarCajon.Position = UDim2.new(1, -12, 0, 12)
cerrarCajon.Size = UDim2.fromOffset(40, 40)
cerrarCajon.BackgroundTransparency = 1
cerrarCajon.Text = "×"
cerrarCajon.TextColor3 = GRIS
cerrarCajon.FontFace = Tema.LetraFina
cerrarCajon.TextSize = 30
cerrarCajon.Parent = cajon

local cajonCuerpo = Instance.new("Frame")
cajonCuerpo.Position = UDim2.fromOffset(22, 64)
cajonCuerpo.Size = UDim2.new(1, -44, 1, -76)
cajonCuerpo.BackgroundTransparency = 1
cajonCuerpo.Parent = cajon
local cajonLista = Instance.new("UIListLayout")
cajonLista.Padding = UDim.new(0, 8)
cajonLista.Parent = cajonCuerpo

local panelActivo: string? = nil
cerrarCajon.Activated:Connect(function()
	cajon.Visible = false
	panelActivo = nil
end)

local function limpiarCajon()
	for _, h in cajonCuerpo:GetChildren() do
		if h:IsA("GuiObject") then
			h:Destroy()
		end
	end
end

local function agregarFilaCajon(
	tituloTxt: string,
	detalleTxt: string,
	iconoId: string,
	color: Color3?
): TextButton
	local fila = Instance.new("TextButton")
	fila.Size = UDim2.new(1, 0, 0, 60)
	fila.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	fila.BackgroundTransparency = 0.45
	fila.BorderSizePixel = 0
	fila.Text = ""
	fila.AutoButtonColor = false
	fila.Parent = cajonCuerpo

	if iconoId ~= "" then
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0, 0.5)
		img.Position = UDim2.new(0, 12, 0.5, 0)
		img.Size = UDim2.fromOffset(32, 32)
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = iconoId
		img.ImageColor3 = color or Tema.Hueso
		img.Parent = fila
	end

	local offsetX = if iconoId ~= "" then 56 else 14
	local t1 = Tema.texto(fila, tituloTxt, { tam = 18, color = color or Tema.Hueso })
	t1.Position = UDim2.fromOffset(offsetX, 6)
	local t2 = Tema.texto(fila, detalleTxt, { tam = 15, letra = Tema.LetraFina, color = GRIS })
	t2.Position = UDim2.fromOffset(offsetX, 32)
	fila.MouseEnter:Connect(function()
		tween(fila, RAPIDO, { BackgroundTransparency = 0.2 })
	end)
	fila.MouseLeave:Connect(function()
		tween(fila, RAPIDO, { BackgroundTransparency = 0.45 })
	end)
	-- Las filas entran una detrás de otra.
	local orden = #cajonCuerpo:GetChildren()
	fila.BackgroundTransparency = 1
	t1.TextTransparency = 1
	t2.TextTransparency = 1
	task.delay(orden * 0.05, function()
		tween(fila, RAPIDO, { BackgroundTransparency = 0.45 })
		tween(t1, RAPIDO, { TextTransparency = 0 })
		tween(t2, RAPIDO, { TextTransparency = 0 })
	end)
	return fila
end

local vinetaActiva = true
local nivelesVolumen = { 1, 0.5, 0 }
local etiquetasVolumen = { "100%", "50%", "SILENCIO" }
local idxVolumen = 1

local function abrirSeccion(nombre: string)
	if panelActivo == nombre and cajon.Visible then
		cajon.Visible = false
		panelActivo = nil
		return
	end
	local estabaCerrado = not cajon.Visible
	panelActivo = nombre
	cajon.Visible = true
	if estabaCerrado then
		cajon.GroupTransparency = 1
		cajon.Position = UDim2.new(1, -28, 0, 74)
		tween(cajon, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.new(1, -68, 0, 74),
		})
	end
	limpiarCajon()

	if nombre == "Arbol" then
		cajonTitulo.Text = Tema.espaciar("ÁRBOL Y PODERES", 3)
		local l = jugador:GetAttribute("Linaje")
		local datos = if typeof(l) == "string" then (P.Linajes :: any)[l] else nil
		local c = Tema.color(l)
		if datos then
			for _, tecla in { "Z", "X", "C" } do
				local d = datos[tecla]
				if d then
					local id = (IM.Iconos :: any)[d.Accion] or ""
					agregarFilaCajon(
						string.format("%s  ·  %s", tecla, string.upper(d.Nombre)),
						string.format(
							"Daño %d  ·  Energía %d  ·  Recarga %ds",
							d.Danio,
							d.Energia,
							d.Recarga
						),
						id,
						c
					)
				end
			end
			agregarFilaCajon(
				"G  ·  GANCHO TÁCTICO",
				"Bloqueado · Desbloqueo próximo en el Taller",
				IM.Controles.Gancho,
				APAGADO
			)
		else
			agregarFilaCajon(
				"SIN LINAJE DESPERTADO",
				"Tocá JUGAR para girar la Ruleta gratis y obtener un Linaje.",
				IM.Menu.RuedaRuleta,
				Tema.Xp
			)
		end
	elseif nombre == "Ajustes" then
		cajonTitulo.Text = Tema.espaciar("AJUSTES", 3)
		local fVineta = agregarFilaCajon(
			"VIÑETA CINEMATOGRÁFICA: " .. if vinetaActiva then "ACTIVADA" else "DESACTIVADA",
			"Sombra editorial en los bordes de la pantalla",
			"",
			nil
		)
		fVineta.Activated:Connect(function()
			vinetaActiva = not vinetaActiva
			local vGui = playerGui:FindFirstChild("Vineta")
			if vGui and vGui:IsA("ScreenGui") then
				vGui.Enabled = vinetaActiva
			end
			abrirSeccion("") -- fuerza recarga visual limpia
			abrirSeccion("Ajustes")
		end)

		local fAudio = agregarFilaCajon(
			"VOLUMEN GENERAL: " .. etiquetasVolumen[idxVolumen],
			"Efectos de combate y ambiente portuario",
			"",
			nil
		)
		fAudio.Activated:Connect(function()
			idxVolumen = idxVolumen % #nivelesVolumen + 1
			local vol = nivelesVolumen[idxVolumen]
			jugador:SetAttribute("VolumenHud", vol)
			for _, obj in SoundService:GetDescendants() do
				if obj:IsA("SoundGroup") then
					obj.Volume = vol
				end
			end
			abrirSeccion("")
			abrirSeccion("Ajustes")
		end)

		agregarFilaCajon(
			"ATAJOS PC Y MÓVIL",
			"LMB Golpe · Q Dash · F Bloqueo · Z/X/C Poderes · M Menú",
			IM.Controles.Ataque,
			GRIS
		)
	elseif nombre == "Creditos" then
		cajonTitulo.Text = Tema.espaciar("CRÉDITOS", 3)
		agregarFilaCajon(
			"LINAJES DEL ECLIPSE",
			"Combate urbano en Puerto Óxido",
			IM.Menu.Eclipse,
			nil
		)
		agregarFilaCajon(
			"IDENTIDAD VISUAL",
			"Cómic Portuario Atmosférico · R15",
			IM.Menu.Taller,
			GRIS
		)
		agregarFilaCajon("SISTEMA BASE", "Combate, Ruleta y Progresión de Linajes", "", GRIS)
	end
end

btnArbol.Activated:Connect(function()
	abrirSeccion("Arbol")
end)
btnAjustes.Activated:Connect(function()
	abrirSeccion("Ajustes")
end)
btnCreditos.Activated:Connect(function()
	abrirSeccion("Creditos")
end)

-- Tarjeta resumen abajo a la derecha (bando, linaje activo, monedas)
local tarjeta = Instance.new("CanvasGroup")
tarjeta.AnchorPoint = Vector2.new(1, 1)
tarjeta.Position = UDim2.new(1, -68, 1, -56)
tarjeta.Size = UDim2.fromOffset(470, 280)
tarjeta.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
tarjeta.BackgroundTransparency = 0.12
tarjeta.BorderSizePixel = 0
tarjeta.Parent = contenido
local bordeTarjeta = Instance.new("UIStroke")
bordeTarjeta.Color = Tema.Hueso
bordeTarjeta.Transparency = 0.82
bordeTarjeta.Parent = tarjeta

local acentoBando = Instance.new("Frame")
acentoBando.Size = UDim2.new(0, 3, 1, 0)
acentoBando.BackgroundColor3 = COFRADIA
acentoBando.BorderSizePixel = 0
acentoBando.Parent = tarjeta

local icoBando = Instance.new("ImageLabel")
icoBando.Position = UDim2.fromOffset(22, 20)
icoBando.Size = UDim2.fromOffset(58, 58)
icoBando.BackgroundTransparency = 1
icoBando.ScaleType = Enum.ScaleType.Fit
icoBando.Parent = tarjeta

local txtBando = Tema.texto(tarjeta, "", { tam = 21, espaciado = 2 })
txtBando.Position = UDim2.fromOffset(94, 22)
local txtStats = Tema.texto(tarjeta, "", { tam = 15, letra = Tema.LetraFina, color = GRIS })
txtStats.Position = UDim2.fromOffset(94, 54)

local divisor = Instance.new("Frame")
divisor.Position = UDim2.fromOffset(22, 98)
divisor.Size = UDim2.new(1, -44, 0, 1)
divisor.BackgroundColor3 = Tema.Hueso
divisor.BackgroundTransparency = 0.85
divisor.BorderSizePixel = 0
divisor.Parent = tarjeta

local icoLinajeCard = Instance.new("ImageLabel")
icoLinajeCard.Position = UDim2.fromOffset(24, 114)
icoLinajeCard.Size = UDim2.fromOffset(50, 50)
icoLinajeCard.BackgroundTransparency = 1
icoLinajeCard.ScaleType = Enum.ScaleType.Fit
icoLinajeCard.Parent = tarjeta

local txtLinajeCard = Tema.texto(tarjeta, "", { tam = 20, espaciado = 2 })
txtLinajeCard.Position = UDim2.fromOffset(88, 114)
local txtPoderesCard = Tema.texto(tarjeta, "", { tam = 15, letra = Tema.LetraFina, color = GRIS })
txtPoderesCard.Position = UDim2.fromOffset(88, 144)

local function crearMoneda(idx: number, imgId: string, etiquetaDef: string): TextLabel
	local cx = 24 + (idx - 1) * 146
	if imgId ~= "" then
		local mImg = Instance.new("ImageLabel")
		mImg.Position = UDim2.fromOffset(cx, 204)
		mImg.Size = UDim2.fromOffset(32, 32)
		mImg.BackgroundTransparency = 1
		mImg.ScaleType = Enum.ScaleType.Fit
		mImg.Image = imgId
		mImg.Parent = tarjeta
	end
	local val = Tema.texto(tarjeta, "0", { tam = 20, espaciado = 1 })
	val.Position = UDim2.fromOffset(cx + (if imgId ~= "" then 40 else 0), 200)
	local nom = Tema.texto(tarjeta, etiquetaDef, { tam = 13, letra = Tema.LetraFina, color = GRIS })
	nom.Position = UDim2.fromOffset(cx + (if imgId ~= "" then 40 else 0), 228)
	return val
end

local valChatarra = crearMoneda(1, IM.Monedas.Chatarra, "CHATARRA")
local valChips = crearMoneda(2, IM.Monedas.Chip, "CHIPS")
local valFichas = crearMoneda(3, IM.Monedas.FichaEclipse, "FICHAS")

local function numeroAtributo(nombre: string): number
	local v = jugador:GetAttribute(nombre)
	return if typeof(v) == "number" then v else 0
end

local function actualizarMenu()
	local l = jugador:GetAttribute("Linaje")
	local bandoRaw = jugador:GetAttribute("Bando")
	local bando = if typeof(bandoRaw) == "string" then bandoRaw else "Neutral"
	local nivel = math.max(1, numeroAtributo("Nivel"))
	local bajas = numeroAtributo("Bajas")
	local racha = numeroAtributo("Racha")
	local fichas = numeroAtributo("Fichas")
	local chatarra = numeroAtributo("Chatarra")
	local chips = numeroAtributo("Chips")

	local tieneLinaje = typeof(l) == "string"
	local nombreL = if tieneLinaje
		then (nombresLinaje[l :: string] or (l :: string))
		else "SIN LINAJE"
	botonPrincipalTxt.Text = Tema.espaciar(if tieneLinaje then "CONTINUAR" else "JUGAR", 3)
	subPrincipalTxt.Text = string.format(
		"%s  ·  %s  ·  %s  ·  NIVEL %d",
		string.upper(jugador.DisplayName),
		string.upper(nombreL),
		string.upper(bando),
		nivel
	)

	local coloresBando: { [string]: Color3 } = {
		Cofradia = COFRADIA,
		Liga = LIGA,
		Vigilantes = VIGILANTES,
		Neutral = GRIS,
	}
	acentoBando.BackgroundColor3 = coloresBando[bando] or COFRADIA
	local bandoImg = (IM.Bandos :: any)[bando] or IM.Bandos.Neutral
	icoBando.Image = bandoImg
	icoBando.Visible = bandoImg ~= ""
	local xBando = if icoBando.Visible then 94 else 24
	txtBando.Position = UDim2.fromOffset(xBando, 22)
	txtStats.Position = UDim2.fromOffset(xBando, 54)

	local nombresBando: { [string]: string } = {
		Cofradia = "COFRADÍA CARMESÍ",
		Liga = "LIGA DEL ALBA",
		Vigilantes = "VIGILANTES",
		Neutral = "ERRANTE · NEUTRAL",
	}
	txtBando.Text = nombresBando[bando] or string.upper(bando)
	txtStats.Text = string.format("NIVEL %d  ·  %d BAJAS  ·  RACHA %d", nivel, bajas, racha)

	local colorL = Tema.color(l)
	local linImg = if tieneLinaje
		then ((IM.Linajes :: any)[l :: string] or "")
		else IM.Menu.RuedaRuleta
	icoLinajeCard.Image = linImg
	icoLinajeCard.ImageColor3 = if tieneLinaje then colorL else GRIS
	icoLinajeCard.Visible = linImg ~= ""
	local xLin = if icoLinajeCard.Visible then 88 else 24
	txtLinajeCard.Position = UDim2.fromOffset(xLin, 114)
	txtPoderesCard.Position = UDim2.fromOffset(xLin, 144)
	txtLinajeCard.Text = string.upper(nombreL)
	txtLinajeCard.TextColor3 = if tieneLinaje then colorL else Tema.Hueso
	txtPoderesCard.Text = if tieneLinaje
		then "Z / X / C ACTIVOS  ·  GANCHO EN TALLER"
		else "RULETA DISPONIBLE AL ENTRAR"

	valChatarra.Text = tostring(chatarra)
	valChips.Text = tostring(chips)
	valFichas.Text = tostring(fichas)
end

local HUD_OCULTOS: { [string]: boolean } = {
	Estado = true,
	Poderes = true,
	Combate = true,
	Ruleta = true,
	PruebaTeclas = true,
}

local function aplicarVisibilidadHud(abierto: boolean)
	for _, h in playerGui:GetChildren() do
		if h:IsA("ScreenGui") then
			if HUD_OCULTOS[h.Name] then
				h.Enabled = not abierto
			elseif h.Name == "Vineta" then
				h.Enabled = not abierto and vinetaActiva
			end
		end
	end
end

local function animarEntrada()
	-- SONIDO: abrir el menú (golpe grave suave)
	columna.GroupTransparency = 1
	columna.Position = UDim2.new(0, 28, 0.5, 0)
	tween(
		columna,
		TweenInfo.new(MU.EntradaSegundos, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			GroupTransparency = 0,
			Position = UDim2.new(0, 68, 0.5, 0),
		}
	)
	for i, fila in filasMenu do
		local destino = UDim2.fromOffset(0, fila.Position.Y.Offset) -- todas van en x = 0
		fila.Position = destino - UDim2.fromOffset(60, 0)
		task.delay(MU.Escalonado * i, function()
			tween(
				fila,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = destino }
			)
		end)
	end
	tarjeta.GroupTransparency = 1
	tarjeta.Position = UDim2.new(1, -68, 1, -16)
	task.delay(MU.Escalonado * (#filasMenu + 1), function()
		tween(tarjeta, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.new(1, -68, 1, -56),
		})
	end)
	-- Fundido desde negro.
	telon.BackgroundTransparency = 0
	tween(telon, TweenInfo.new(0.9, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 })
end

local function setAbierto(abierto: boolean)
	gui.Enabled = abierto
	botonGui.Enabled = not abierto
	jugador:SetAttribute("MenuAbierto", abierto)
	aplicarVisibilidadHud(abierto)
	if abierto then
		animarEntrada()
	else
		cajon.Visible = false
		panelActivo = nil
	end
end

-- Latido del rombo de CONTINUAR (invita a tocarlo).
if romboActivo then
	local r = romboActivo
	TweenService:Create(
		r,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Size = UDim2.fromOffset(21, 21) }
	):Play()
end

-- Brasas: solo mientras el menú está abierto.
local proximaBrasa = 0
RunService.RenderStepped:Connect(function()
	if not gui.Enabled then
		return
	end
	local ahora = os.clock()
	if ahora >= proximaBrasa then
		proximaBrasa = ahora + 1 / MU.BrasasPorSegundo
		lanzarBrasa()
	end
end)

playerGui.ChildAdded:Connect(function(hijo)
	if hijo:IsA("ScreenGui") and (HUD_OCULTOS[hijo.Name] or hijo.Name == "Vineta") then
		aplicarVisibilidadHud(gui.Enabled)
	end
end)

btnContinuar.Activated:Connect(function()
	setAbierto(false)
end)
abrirMenuBtn.Activated:Connect(function()
	setAbierto(true)
end)

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.M then
		setAbierto(not gui.Enabled)
	elseif entrada.KeyCode == Enum.KeyCode.Escape and gui.Enabled and cajon.Visible then
		cajon.Visible = false
		panelActivo = nil
	end
end)

for _, atributo in
	{ "Linaje", "Nivel", "Fichas", "Bajas", "Racha", "Bando", "Chatarra", "Chips", "DatosListos" }
do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizarMenu)
end

actualizarMenu()
setAbierto(true)
botonGui.Parent = playerGui
gui.Parent = playerGui
