--!strict
-- Menú principal editorial (PC y celular): portada, espacios, árbol de poderes, ajustes y resumen.
-- Se abre al entrar y con M (o el botón discreto "M · MENÚ" arriba a la izquierda).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local H = Config.Hud
local P = Config.Poderes
local IM = H.Imagenes
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
	Vector2.new(120, 38)
)
local abrirMenuBtn = Instance.new("TextButton")
abrirMenuBtn.Size = UDim2.fromScale(1, 1)
abrirMenuBtn.BackgroundTransparency = 1
abrirMenuBtn.Text = ""
abrirMenuBtn.Parent = esquinaMenu
local txtAbrir = Tema.texto(esquinaMenu, "M  MENÚ", { tam = 15, espaciado = 3 })
txtAbrir.AnchorPoint = Vector2.new(1, 0)
txtAbrir.Position = UDim2.fromScale(1, 0)
local rayaAbrir = Instance.new("Frame")
rayaAbrir.AnchorPoint = Vector2.new(1, 0)
rayaAbrir.Position = UDim2.new(1, 0, 0, 28)
rayaAbrir.Size = UDim2.fromOffset(92, 1)
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
	fondoImg.Size = UDim2.fromScale(1, 1)
	fondoImg.BackgroundTransparency = 1
	fondoImg.ScaleType = Enum.ScaleType.Crop
	fondoImg.Image = IM.Menu.Fondo
	fondoImg.Parent = fondo
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
	local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.52, 1.15)
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
local columna =
	Tema.grupo(contenido, Vector2.new(0, 0.5), UDim2.new(0, 68, 0.5, 0), Vector2.new(540, 560))

local sector = Tema.texto(
	columna,
	Tema.espaciar("PUERTO ÓXIDO  ·  SECTOR PORTUARIO", 3),
	{ tam = 12, letra = Tema.LetraFina, color = GRIS }
)
sector.Position = UDim2.fromOffset(0, 0)

if IM.Menu.Logo ~= "" then
	local logoImg = Instance.new("ImageLabel")
	logoImg.Position = UDim2.fromOffset(-8, 18)
	logoImg.Size = UDim2.fromOffset(420, 92)
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

Tema.ornamento(columna, Vector2.new(175, 114), 350)

-- Botonera principal
local yBase = 166
local paso = 72
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
	fila.Size = UDim2.fromOffset(420, 52)
	fila.BackgroundTransparency = 1
	fila.Parent = columna

	local rombo = Instance.new("Frame")
	rombo.AnchorPoint = Vector2.new(0.5, 0.5)
	rombo.Position = UDim2.fromOffset(10, 18)
	rombo.Size = UDim2.fromOffset(if activo then 13 else 11, if activo then 13 else 11)
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
		tam = if activo then 24 else 20,
		letra = if activo then Tema.Letra else Tema.LetraFina,
		color = if activo then Tema.Hueso else GRIS,
	})
	txt.Position = UDim2.fromOffset(32, 2)

	if iconoId ~= "" then
		local ico = Instance.new("ImageLabel")
		ico.AnchorPoint = Vector2.new(0, 0.5)
		ico.Position = UDim2.fromOffset(296, 18)
		ico.Size = UDim2.fromOffset(20, 20)
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

	btn.MouseEnter:Connect(function()
		txt.TextColor3 = Tema.Hueso
		rombo.BackgroundTransparency = 0.25
	end)
	btn.MouseLeave:Connect(function()
		txt.TextColor3 = if activo then Tema.Hueso else GRIS
		rombo.BackgroundTransparency = if activo then 0 else 1
	end)

	return btn, rombo, txt
end

local btnContinuar, _, txtContinuar = crearItemMenu(yBase, "CONTINUAR", true, "")
botonPrincipalTxt = txtContinuar
subPrincipalTxt = Tema.texto(columna, "", { tam = 13, letra = Tema.LetraFina, color = GRIS })
subPrincipalTxt.Position = UDim2.fromOffset(32, yBase + 34)

-- Fila 2: ESPACIOS < 1 / 3 >
local _, _, _ = crearItemMenu(yBase + paso, "ESPACIOS", false, "")
local espacioActual = 1
local totalEspacios = 3
local textoEspacio = Tema.texto(columna, "1 / 3", {
	tam = 16,
	letra = Tema.Letra,
	color = Tema.Hueso,
	alineado = Enum.TextXAlignment.Center,
})
textoEspacio.AutomaticSize = Enum.AutomaticSize.None
textoEspacio.Position = UDim2.fromOffset(244, yBase + paso + 4)
textoEspacio.Size = UDim2.fromOffset(66, 26)
local notaEspacio = Tema.texto(columna, "", { tam = 12, letra = Tema.LetraFina, color = APAGADO })
notaEspacio.Position = UDim2.fromOffset(32, yBase + paso + 32)

local function crearFlecha(x: number, rotacion: number, textoAlt: string): TextButton
	local fbtn = Instance.new("TextButton")
	fbtn.Position = UDim2.fromOffset(x, yBase + paso + 2)
	fbtn.Size = UDim2.fromOffset(32, 32)
	fbtn.BackgroundTransparency = 1
	fbtn.Text = if IM.Menu.Flecha == "" then textoAlt else ""
	fbtn.TextColor3 = Tema.Hueso
	fbtn.FontFace = Tema.Letra
	fbtn.TextSize = 18
	fbtn.Parent = columna
	if IM.Menu.Flecha ~= "" then
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Size = UDim2.fromOffset(18, 18)
		img.Rotation = rotacion
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = IM.Menu.Flecha
		img.ImageColor3 = Tema.Hueso
		img.Parent = fbtn
	end
	return fbtn
end

local btnEspAnt = crearFlecha(212, 180, "‹")
local btnEspSig = crearFlecha(310, 0, "›")

local function refrescarEspacios()
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
local cajon = Instance.new("Frame")
cajon.AnchorPoint = Vector2.new(1, 0)
cajon.Position = UDim2.new(1, -68, 0, 74)
cajon.Size = UDim2.fromOffset(420, 300)
cajon.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
cajon.BackgroundTransparency = 0.1
cajon.BorderSizePixel = 0
cajon.Visible = false
cajon.Parent = contenido
local bordeCajon = Instance.new("UIStroke")
bordeCajon.Color = Tema.Hueso
bordeCajon.Transparency = 0.8
bordeCajon.Parent = cajon

local cajonTitulo = Tema.texto(cajon, "", { tam = 18, espaciado = 3 })
cajonTitulo.Position = UDim2.fromOffset(22, 18)

local cerrarCajon = Instance.new("TextButton")
cerrarCajon.AnchorPoint = Vector2.new(1, 0)
cerrarCajon.Position = UDim2.new(1, -12, 0, 12)
cerrarCajon.Size = UDim2.fromOffset(30, 30)
cerrarCajon.BackgroundTransparency = 1
cerrarCajon.Text = "×"
cerrarCajon.TextColor3 = GRIS
cerrarCajon.FontFace = Tema.LetraFina
cerrarCajon.TextSize = 22
cerrarCajon.Parent = cajon

local cajonCuerpo = Instance.new("Frame")
cajonCuerpo.Position = UDim2.fromOffset(22, 58)
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
	fila.Size = UDim2.new(1, 0, 0, 48)
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
		img.Size = UDim2.fromOffset(26, 26)
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = iconoId
		img.ImageColor3 = color or Tema.Hueso
		img.Parent = fila
	end

	local offsetX = if iconoId ~= "" then 50 else 14
	local t1 = Tema.texto(fila, tituloTxt, { tam = 14, color = color or Tema.Hueso })
	t1.Position = UDim2.fromOffset(offsetX, 6)
	local t2 = Tema.texto(fila, detalleTxt, { tam = 12, letra = Tema.LetraFina, color = GRIS })
	t2.Position = UDim2.fromOffset(offsetX, 25)
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
	panelActivo = nombre
	cajon.Visible = true
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
local tarjeta = Instance.new("Frame")
tarjeta.AnchorPoint = Vector2.new(1, 1)
tarjeta.Position = UDim2.new(1, -68, 1, -56)
tarjeta.Size = UDim2.fromOffset(420, 236)
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
icoBando.Size = UDim2.fromOffset(50, 50)
icoBando.BackgroundTransparency = 1
icoBando.ScaleType = Enum.ScaleType.Fit
icoBando.Parent = tarjeta

local txtBando = Tema.texto(tarjeta, "", { tam = 17, espaciado = 2 })
txtBando.Position = UDim2.fromOffset(86, 22)
local txtStats = Tema.texto(tarjeta, "", { tam = 12, letra = Tema.LetraFina, color = GRIS })
txtStats.Position = UDim2.fromOffset(86, 48)

local divisor = Instance.new("Frame")
divisor.Position = UDim2.fromOffset(22, 88)
divisor.Size = UDim2.new(1, -44, 0, 1)
divisor.BackgroundColor3 = Tema.Hueso
divisor.BackgroundTransparency = 0.85
divisor.BorderSizePixel = 0
divisor.Parent = tarjeta

local icoLinajeCard = Instance.new("ImageLabel")
icoLinajeCard.Position = UDim2.fromOffset(24, 104)
icoLinajeCard.Size = UDim2.fromOffset(42, 42)
icoLinajeCard.BackgroundTransparency = 1
icoLinajeCard.ScaleType = Enum.ScaleType.Fit
icoLinajeCard.Parent = tarjeta

local txtLinajeCard = Tema.texto(tarjeta, "", { tam = 16, espaciado = 2 })
txtLinajeCard.Position = UDim2.fromOffset(80, 104)
local txtPoderesCard = Tema.texto(tarjeta, "", { tam = 12, letra = Tema.LetraFina, color = GRIS })
txtPoderesCard.Position = UDim2.fromOffset(80, 128)

local function crearMoneda(idx: number, imgId: string, etiquetaDef: string): TextLabel
	local cx = 24 + (idx - 1) * 130
	if imgId ~= "" then
		local mImg = Instance.new("ImageLabel")
		mImg.Position = UDim2.fromOffset(cx, 178)
		mImg.Size = UDim2.fromOffset(24, 24)
		mImg.BackgroundTransparency = 1
		mImg.ScaleType = Enum.ScaleType.Fit
		mImg.Image = imgId
		mImg.Parent = tarjeta
	end
	local val = Tema.texto(tarjeta, "0", { tam = 15, espaciado = 1 })
	val.Position = UDim2.fromOffset(cx + (if imgId ~= "" then 32 else 0), 178)
	local nom = Tema.texto(tarjeta, etiquetaDef, { tam = 10, letra = Tema.LetraFina, color = GRIS })
	nom.Position = UDim2.fromOffset(cx + (if imgId ~= "" then 32 else 0), 198)
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
	local xBando = if icoBando.Visible then 86 else 24
	txtBando.Position = UDim2.fromOffset(xBando, 22)
	txtStats.Position = UDim2.fromOffset(xBando, 48)

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
	local xLin = if icoLinajeCard.Visible then 80 else 24
	txtLinajeCard.Position = UDim2.fromOffset(xLin, 104)
	txtPoderesCard.Position = UDim2.fromOffset(xLin, 128)
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

local function setAbierto(abierto: boolean)
	gui.Enabled = abierto
	botonGui.Enabled = not abierto
	jugador:SetAttribute("MenuAbierto", abierto)
	aplicarVisibilidadHud(abierto)
	if not abierto then
		cajon.Visible = false
		panelActivo = nil
	end
end

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
