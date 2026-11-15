--!strict
-- Creador de personaje editorial cómic: 4 pestañas (Cuerpo, Rostro, Ropa, Estilos),
-- muestras de color visuales, caras/marcas/bandos ilustrados y cámara orbital 360°.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local remoto = ReplicatedStorage:WaitForChild("Creador") :: RemoteEvent
local jugador = Players.LocalPlayer
local playerGui = jugador:WaitForChild("PlayerGui")

local CR = Config.Cuerpo.Creador
local CC = Config.Cuerpo.Comic
local H = Config.Hud.Imagenes

local ACENTO = Color3.fromHex("#f2652b")
local ACENTO_BORDE = Color3.fromHex("#ffb088")
local SUPERFICIE = Color3.fromHex("#161a24")
local TARJETA = Color3.fromHex("#1e2433")
local GRIS = Color3.fromHex("#9fa7b5")
local RAPIDO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local HUD =
	{ "Estado", "Poderes", "Combate", "Ruleta", "PruebaTeclas", "BotonMenu", "Vineta", "Minuto1" }

local CAMPOS = {
	"Piel",
	"Cara",
	"Peinado",
	"Pelo",
	"Marca",
	"Contextura",
	"Altura",
	"Campera",
	"Acento",
	"Remera",
	"Pantalon",
	"Zapatillas",
	"Bando",
}

local gui = Tema.pantalla("Creador", 20)
gui.Enabled = false

local contenido = Instance.new("Frame")
contenido.Size = UDim2.fromScale(1, 1)
contenido.BackgroundTransparency = 1
contenido.Parent = gui
local escala = Instance.new("UIScale")
escala.Parent = contenido

local function ajustarEscala()
	local cam = workspace.CurrentCamera
	if cam then
		local v = cam.ViewportSize
		local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.54, 1.15) * 1.05
		escala.Scale = s
		contenido.Size = UDim2.fromScale(1 / s, 1 / s)
	end
end
ajustarEscala()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local cam = workspace.CurrentCamera
	if cam then
		ajustarEscala()
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
	end
end)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
end

-- Velo lateral izquierdo que separa el panel editorial del personaje 3D a la derecha.
local velo = Instance.new("Frame")
velo.Size = UDim2.fromScale(0.56, 1)
velo.BackgroundColor3 = Tema.Fondo
velo.BorderSizePixel = 0
velo.Parent = contenido

local grad = Instance.new("UIGradient")
grad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.7, 0.14),
	NumberSequenceKeypoint.new(1, 1),
})
grad.Parent = velo

local panel = Instance.new("CanvasGroup")
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 42, 0.5, 0)
panel.Size = UDim2.fromOffset(510, 620)
panel.BackgroundColor3 = SUPERFICIE
panel.BackgroundTransparency = 0.16
panel.BorderSizePixel = 0
panel.Parent = contenido

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromHex("#2f384b")
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

-- Cabecera.
local marcaTop = Tema.rombo(panel, Vector2.new(26, 26), 14, true)
marcaTop.BackgroundColor3 = ACENTO

local titulo = Tema.texto(panel, Tema.espaciar("CREA TU PELEADOR", 3), {
	tam = 25,
	letra = Tema.LetraGruesa,
})
titulo.Position = UDim2.fromOffset(48, 13)

local subtitulo = Tema.texto(panel, "EDITÁ CUERPO, ROSTRO, ROPA Y PARCHE DE BANDO", {
	tam = 12,
	letra = Tema.LetraFina,
	color = GRIS,
})
subtitulo.Position = UDim2.fromOffset(48, 43)

-- Barra de 4 pestañas.
local PESTANAS = { "CUERPO", "ROSTRO", "ROPA", "ESTILOS" }
local barraTabs = Instance.new("Frame")
barraTabs.Position = UDim2.fromOffset(20, 72)
barraTabs.Size = UDim2.fromOffset(470, 38)
barraTabs.BackgroundColor3 = TARJETA
barraTabs.BorderSizePixel = 0
barraTabs.Parent = panel
local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 6)
tabCorner.Parent = barraTabs

local indicadorTab = Instance.new("Frame")
indicadorTab.Size = UDim2.new(0.25, -4, 1, -4)
indicadorTab.Position = UDim2.fromOffset(2, 2)
indicadorTab.BackgroundColor3 = ACENTO
indicadorTab.BorderSizePixel = 0
indicadorTab.ZIndex = 2
indicadorTab.Parent = barraTabs
local indCorner = Instance.new("UICorner")
indCorner.CornerRadius = UDim.new(0, 5)
indCorner.Parent = indicadorTab

local botonesTab: { TextButton } = {}
local paginas: { ScrollingFrame } = {}

local cuerpoPanel = Instance.new("Frame")
cuerpoPanel.Position = UDim2.fromOffset(20, 120)
cuerpoPanel.Size = UDim2.fromOffset(470, 424)
cuerpoPanel.BackgroundTransparency = 1
cuerpoPanel.ClipsDescendants = true
cuerpoPanel.Parent = panel

for i, nombre in PESTANAS do
	local anchoFrac = 1 / #PESTANAS
	local btn = Instance.new("TextButton")
	btn.Position = UDim2.fromScale((i - 1) * anchoFrac, 0)
	btn.Size = UDim2.fromScale(anchoFrac, 1)
	btn.BackgroundTransparency = 1
	btn.Text = nombre
	btn.FontFace = Tema.Letra
	btn.TextSize = 13
	btn.TextColor3 = if i == 1 then Tema.Hueso else GRIS
	btn.ZIndex = 3
	btn.Parent = barraTabs
	table.insert(botonesTab, btn)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = ACENTO
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new()
	page.Visible = i == 1
	page.Parent = cuerpoPanel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = page

	table.insert(paginas, page)
end

-- Estado espejo del servidor y refrescos UI.
local valores: { [string]: number } = {}
local refrescos: { [string]: { () -> () } } = {}
for _, c in CAMPOS do
	refrescos[c] = {}
end

local function valorActual(campo: string): number
	local v = jugador:GetAttribute("Ap_" .. campo)
	if typeof(v) == "number" then
		return v
	end
	return (CR.Inicial :: any)[campo] or 1
end

local function refrescarCampo(campo: string)
	valores[campo] = valorActual(campo)
	local lista = refrescos[campo]
	if lista then
		for _, fn in lista do
			fn()
		end
	end
end

local function pedir(campo: string, valor: number)
	valores[campo] = valor
	local lista = refrescos[campo]
	if lista then
		for _, fn in lista do
			fn()
		end
	end
	remoto:FireServer(campo, valor)
end

for _, c in CAMPOS do
	jugador:GetAttributeChangedSignal("Ap_" .. c):Connect(function()
		refrescarCampo(c)
	end)
end

-- Cámara orbital 360° + presets Cuerpo / Rostro / Espalda.
local abierto = false
local confirmado = false
local modoVista: "Cuerpo" | "Rostro" | "Espalda" = "Cuerpo"
local yaw = 0
local distancia = 7.6
local alturaFoco = 0.35
local desplazamientoX = 2.35
local arrastrando = false
local ultimoPuntero: Vector2? = nil
local luzCreador: PointLight? = nil
local soporteLuzCreador: Attachment? = nil
local indicadorVista: Frame? = nil
local botonesVista: { { modo: string, boton: TextButton, idx: number } } = {}

local function ponerModoVista(modo: "Cuerpo" | "Rostro" | "Espalda")
	modoVista = modo
	if modo == "Rostro" then
		yaw = 0
		distancia = 4.2
		alturaFoco = 1.6
		desplazamientoX = 1.15
	elseif modo == "Espalda" then
		yaw = math.pi
		distancia = 6.2
		alturaFoco = 0.65
		desplazamientoX = 1.85
	else
		yaw = 0.12
		distancia = 7.6
		alturaFoco = 0.35
		desplazamientoX = 2.35
	end
	for _, entry in botonesVista do
		local activo = entry.modo == modo
		entry.boton.TextColor3 = if activo then Tema.Hueso else GRIS
		if activo and indicadorVista then
			TweenService:Create(indicadorVista, RAPIDO, {
				Position = UDim2.new((entry.idx - 1) / 3, 3, 0, 3),
			}):Play()
		end
	end
end

local function activarTab(idx: number)
	TweenService:Create(indicadorTab, RAPIDO, {
		Position = UDim2.new((idx - 1) * 0.25, 2, 0, 2),
	}):Play()
	for i, page in paginas do
		page.Visible = i == idx
		botonesTab[i].TextColor3 = if i == idx then Tema.Hueso else GRIS
	end
	if idx == 2 then
		ponerModoVista("Rostro")
	elseif modoVista == "Rostro" then
		ponerModoVista("Cuerpo")
	end
end

for i, btn in botonesTab do
	btn.Activated:Connect(function()
		activarTab(i)
	end)
end

-- Constructores de controles modulares.
local ordenAuto = 0
local function crearSeccion(pagina: ScrollingFrame, nombre: string): Frame
	ordenAuto += 1
	local caja = Instance.new("Frame")
	caja.Size = UDim2.fromScale(1, 0)
	caja.AutomaticSize = Enum.AutomaticSize.Y
	caja.BackgroundColor3 = TARJETA
	caja.BackgroundTransparency = 0.35
	caja.BorderSizePixel = 0
	caja.LayoutOrder = ordenAuto
	caja.Parent = pagina

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = caja

	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 10)
	p.PaddingBottom = UDim.new(0, 10)
	p.PaddingLeft = UDim.new(0, 12)
	p.PaddingRight = UDim.new(0, 12)
	p.Parent = caja

	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 8)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = caja

	local lbl = Tema.texto(caja, Tema.espaciar(nombre, 2), {
		tam = 12,
		letra = Tema.LetraGruesa,
		color = GRIS,
	})
	lbl.LayoutOrder = 0
	return caja
end

local function crearGrillaColores(
	pagina: ScrollingFrame,
	tituloSeccion: string,
	campo: string,
	coloresLista: { Color3 }
)
	local sec = crearSeccion(pagina, tituloSeccion)
	local grid = Instance.new("Frame")
	grid.Size = UDim2.fromScale(1, 0)
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.BackgroundTransparency = 1
	grid.LayoutOrder = 1
	grid.Parent = sec

	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.fromOffset(36, 36)
	gl.CellPadding = UDim2.fromOffset(8, 8)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid

	local bordes: { UIStroke } = {}
	for i, col in coloresLista do
		local b = Instance.new("TextButton")
		b.Text = ""
		b.BackgroundColor3 = col
		b.AutoButtonColor = false
		b.LayoutOrder = i
		b.Parent = grid

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(0, 6)
		cr.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Thickness = 2
		st.Color = Tema.Hueso
		st.Transparency = 0.85
		st.Parent = b
		table.insert(bordes, st)

		b.Activated:Connect(function()
			pedir(campo, i)
		end)
	end

	table.insert(refrescos[campo], function()
		local sel = valores[campo]
		for i, st in bordes do
			local activo = i == sel
			st.Color = if activo then ACENTO_BORDE else Tema.Hueso
			st.Thickness = if activo then 3 else 1.5
			st.Transparency = if activo then 0 else 0.78
		end
	end)
end

local function hexAColor3(hexes: { string }): { Color3 }
	local out = {}
	for _, h in hexes do
		table.insert(out, Color3.fromHex(h))
	end
	return out
end

local function crearPills(
	pagina: ScrollingFrame,
	tituloSeccion: string,
	campo: string,
	etiquetas: { string },
	onSelect: ((number) -> ())?
)
	local sec = crearSeccion(pagina, tituloSeccion)
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, 0, 0, 34)
	fila.BackgroundTransparency = 1
	fila.LayoutOrder = 1
	fila.Parent = sec

	local fl = Instance.new("UIListLayout")
	fl.FillDirection = Enum.FillDirection.Horizontal
	fl.Padding = UDim.new(0, 6)
	fl.SortOrder = Enum.SortOrder.LayoutOrder
	fl.Parent = fila

	local ancho = math.floor((436 - (#etiquetas - 1) * 6) / #etiquetas)
	local btns: { TextButton } = {}
	local strokes: { UIStroke } = {}

	for i, label in etiquetas do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(ancho, 34)
		b.BackgroundColor3 = Tema.Fondo
		b.Text = string.upper(label)
		b.TextColor3 = Tema.Hueso
		b.FontFace = Tema.Letra
		b.TextSize = 12
		b.LayoutOrder = i
		b.Parent = fila

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(0, 5)
		cr.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Color = GRIS
		st.Thickness = 1.5
		st.Transparency = 0.65
		st.Parent = b

		b.Activated:Connect(function()
			pedir(campo, i)
			if onSelect then
				onSelect(i)
			end
		end)

		table.insert(btns, b)
		table.insert(strokes, st)
	end

	table.insert(refrescos[campo], function()
		local sel = valores[campo]
		for i, b in btns do
			local activo = i == sel
			b.BackgroundColor3 = if activo then ACENTO else Tema.Fondo
			b.TextColor3 = if activo then Tema.Hueso else GRIS
			strokes[i].Color = if activo then ACENTO_BORDE else GRIS
			strokes[i].Transparency = if activo then 0 else 0.72
		end
	end)
end

local function crearGaleriaImagenes(
	pagina: ScrollingFrame,
	tituloSeccion: string,
	campo: string,
	imagenes: { string },
	incluyeNinguno: boolean
)
	local sec = crearSeccion(pagina, tituloSeccion)
	local grid = Instance.new("Frame")
	grid.Size = UDim2.fromScale(1, 0)
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.BackgroundTransparency = 1
	grid.LayoutOrder = 1
	grid.Parent = sec

	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.fromOffset(52, 52)
	gl.CellPadding = UDim2.fromOffset(8, 8)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid

	local strokes: { [number]: UIStroke } = {}
	local inicio = if incluyeNinguno then 0 else 1
	for i = inicio, #imagenes do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(52, 52)
		b.BackgroundColor3 = Color3.fromHex("#252c3d")
		b.Text = if i == 0 then "NO" else ""
		b.FontFace = Tema.Letra
		b.TextSize = 12
		b.TextColor3 = GRIS
		b.LayoutOrder = i + 1
		b.Parent = grid

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(0, 6)
		cr.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Color = GRIS
		st.Thickness = 2
		st.Transparency = 0.75
		st.Parent = b
		strokes[i] = st

		if i >= 1 and imagenes[i] ~= "" then
			local img = Instance.new("ImageLabel")
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.Position = UDim2.fromScale(0.5, 0.5)
			img.Size = UDim2.fromOffset(42, 42)
			img.BackgroundTransparency = 1
			img.ScaleType = Enum.ScaleType.Fit
			img.Image = imagenes[i]
			img.Parent = b
		end

		b.Activated:Connect(function()
			pedir(campo, i)
			if modoVista ~= "Rostro" then
				ponerModoVista("Rostro")
			end
		end)
	end

	table.insert(refrescos[campo], function()
		local sel = valores[campo]
		for i, st in strokes do
			local activo = i == sel
			st.Color = if activo then ACENTO_BORDE else GRIS
			st.Thickness = if activo then 3 else 1.5
			st.Transparency = if activo then 0 else 0.75
		end
	end)
end

-- Poblar Tab 1: CUERPO.
crearGrillaColores(paginas[1], "TONO DE PIEL", "Piel", Config.Cuerpo.TonosPiel)
crearPills(paginas[1], "CONTEXTURA", "Contextura", CR.Contexturas)
crearPills(paginas[1], "ALTURA", "Altura", CR.Alturas)

-- Poblar Tab 2: ROSTRO.
crearPills(paginas[2], "PEINADO", "Peinado", CC.NombresPeinados or CC.Peinados)
crearGrillaColores(paginas[2], "COLOR DE PELO", "Pelo", hexAColor3(Config.Cuerpo.ColoresPelo))
crearGaleriaImagenes(paginas[2], "EXPRESIÓN", "Cara", CC.Caras, false)
crearGaleriaImagenes(paginas[2], "MARCA FACIAL", "Marca", Config.Cuerpo.Marcas, true)

-- Poblar Tab 3: ROPA Y BANDO.
crearGrillaColores(paginas[3], "CAMPERA", "Campera", hexAColor3(CR.Campera))
crearGrillaColores(paginas[3], "ACENTO Y PUÑOS", "Acento", hexAColor3(CR.Acento))
crearGrillaColores(paginas[3], "REMERA", "Remera", hexAColor3(CR.Remera))
crearGrillaColores(paginas[3], "PANTALÓN", "Pantalon", hexAColor3(CR.Pantalon))
crearGrillaColores(paginas[3], "ZAPATILLAS", "Zapatillas", hexAColor3(CR.Zapatillas))

do
	local sec = crearSeccion(paginas[3], "PARCHE DE BANDO (ESPALDA)")
	local grid = Instance.new("Frame")
	grid.Size = UDim2.fromScale(1, 0)
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.BackgroundTransparency = 1
	grid.LayoutOrder = 1
	grid.Parent = sec

	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.fromOffset(214, 52)
	gl.CellPadding = UDim2.fromOffset(8, 8)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid

	local strokesBando: { UIStroke } = {}
	for i, clave in CR.Bandos do
		local hex = (CR.BandoColores :: any)[clave] or "28303d"
		local b = Instance.new("TextButton")
		b.BackgroundColor3 = Tema.Fondo
		b.Text = ""
		b.LayoutOrder = i
		b.Parent = grid

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(0, 6)
		cr.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Color = Color3.fromHex(hex)
		st.Thickness = 2
		st.Transparency = 0.72
		st.Parent = b
		table.insert(strokesBando, st)

		local img = Instance.new("ImageLabel")
		img.Position = UDim2.fromOffset(10, 7)
		img.Size = UDim2.fromOffset(38, 38)
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = (H.Bandos :: any)[clave] or H.Bandos.Neutral
		img.Parent = b

		local nom = (CR.BandoNombres :: any)[clave] or clave
		local lbl = Tema.texto(b, string.upper(nom), { tam = 13, letra = Tema.Letra })
		lbl.Position = UDim2.fromOffset(56, 17)

		b.Activated:Connect(function()
			pedir("Bando", i)
			ponerModoVista("Espalda")
		end)
	end

	table.insert(refrescos.Bando, function()
		local sel = valores.Bando
		for i, st in strokesBando do
			local activo = i == sel
			st.Thickness = if activo then 3 else 1.5
			st.Transparency = if activo then 0 else 0.72
		end
	end)
end

-- Poblar Tab 4: ESTILOS PREDEFINIDOS.
do
	local sec = crearSeccion(paginas[4], "ESTILOS LISTOS PARA PELEAR")
	local grid = Instance.new("Frame")
	grid.Size = UDim2.fromScale(1, 0)
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.BackgroundTransparency = 1
	grid.LayoutOrder = 1
	grid.Parent = sec

	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.fromOffset(214, 96)
	gl.CellPadding = UDim2.fromOffset(8, 8)
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid

	for i, pre in CR.Predefinidos do
		local b = Instance.new("TextButton")
		b.BackgroundColor3 = Tema.Fondo
		b.Text = ""
		b.LayoutOrder = i
		b.Parent = grid

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(0, 6)
		cr.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Color = Color3.fromHex(CR.Acento[pre.Acento])
		st.Thickness = 1.5
		st.Transparency = 0.45
		st.Parent = b

		local bandoClave = CR.Bandos[pre.Bando]
		local icono = Instance.new("ImageLabel")
		icono.Position = UDim2.fromOffset(12, 12)
		icono.Size = UDim2.fromOffset(36, 36)
		icono.BackgroundTransparency = 1
		icono.ScaleType = Enum.ScaleType.Fit
		icono.Image = (H.Bandos :: any)[bandoClave] or H.Bandos.Neutral
		icono.Parent = b

		local nom = Tema.texto(b, Tema.espaciar(pre.Nombre, 2), {
			tam = 16,
			letra = Tema.LetraGruesa,
		})
		nom.Position = UDim2.fromOffset(56, 14)

		local sub =
			Tema.texto(b, CC.NombresPeinados[pre.Peinado] .. " · " .. CR.Alturas[pre.Altura], {
				tam = 11,
				letra = Tema.LetraFina,
				color = GRIS,
			})
		sub.Position = UDim2.fromOffset(56, 36)

		-- Muestra de paleta (Campera, Acento, Remera, Pantalón).
		local paleta = {
			CR.Campera[pre.Campera],
			CR.Acento[pre.Acento],
			CR.Remera[pre.Remera],
			CR.Pantalon[pre.Pantalon],
		}
		for j, hex in paleta do
			local swatch = Instance.new("Frame")
			swatch.Position = UDim2.fromOffset(14 + (j - 1) * 32, 64)
			swatch.Size = UDim2.fromOffset(26, 18)
			swatch.BackgroundColor3 = Color3.fromHex(hex)
			swatch.BorderSizePixel = 0
			swatch.Parent = b
			local sc = Instance.new("UICorner")
			sc.CornerRadius = UDim.new(0, 3)
			sc.Parent = swatch
		end

		b.Activated:Connect(function()
			remoto:FireServer("Predefinido", i)
		end)
	end
end

-- Pie fijo del panel: AZAR + LISTO.
local btnAzar = Instance.new("TextButton")
btnAzar.Position = UDim2.fromOffset(20, 558)
btnAzar.Size = UDim2.fromOffset(148, 46)
btnAzar.BackgroundColor3 = TARJETA
btnAzar.Text = Tema.espaciar("AZAR", 2)
btnAzar.FontFace = Tema.Letra
btnAzar.TextSize = 15
btnAzar.TextColor3 = Tema.Hueso
btnAzar.Parent = panel
local azarCorner = Instance.new("UICorner")
azarCorner.CornerRadius = UDim.new(0, 6)
azarCorner.Parent = btnAzar
local azarStroke = Instance.new("UIStroke")
azarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
azarStroke.Color = GRIS
azarStroke.Transparency = 0.6
azarStroke.Parent = btnAzar

btnAzar.Activated:Connect(function()
	remoto:FireServer("Azar")
end)

local confirmar = Instance.new("TextButton")
confirmar.Position = UDim2.fromOffset(178, 558)
confirmar.Size = UDim2.fromOffset(312, 46)
confirmar.BackgroundColor3 = ACENTO
confirmar.Text = Tema.espaciar("ENTRÁ AL PUERTO", 3)
confirmar.FontFace = Tema.LetraGruesa
confirmar.TextSize = 18
confirmar.TextColor3 = Tema.Hueso
confirmar.Parent = panel
local confCorner = Instance.new("UICorner")
confCorner.CornerRadius = UDim.new(0, 6)
confCorner.Parent = confirmar
local confStroke = Instance.new("UIStroke")
confStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
confStroke.Color = ACENTO_BORDE
confStroke.Thickness = 2
confStroke.Parent = confirmar

-- Controles de cámara orbital 3D arriba a la derecha.
local barraVista = Instance.new("Frame")
barraVista.AnchorPoint = Vector2.new(1, 0)
barraVista.Position = UDim2.new(1, -40, 0, 28)
barraVista.Size = UDim2.fromOffset(330, 42)
barraVista.BackgroundColor3 = SUPERFICIE
barraVista.BackgroundTransparency = 0.16
barraVista.BorderSizePixel = 0
barraVista.Parent = contenido
local bvCorner = Instance.new("UICorner")
bvCorner.CornerRadius = UDim.new(0, 6)
bvCorner.Parent = barraVista
local bvStroke = Instance.new("UIStroke")
bvStroke.Color = Color3.fromHex("#364156")
bvStroke.Parent = barraVista

local iv = Instance.new("Frame")
iv.Position = UDim2.fromOffset(3, 3)
iv.Size = UDim2.new(1 / 3, -6, 1, -6)
iv.BackgroundColor3 = ACENTO
iv.BorderSizePixel = 0
iv.ZIndex = 1
iv.Parent = barraVista
local ivCorner = Instance.new("UICorner")
ivCorner.CornerRadius = UDim.new(0, 5)
ivCorner.Parent = iv
indicadorVista = iv

local modosLista: { "Cuerpo" | "Rostro" | "Espalda" } = { "Cuerpo", "Rostro", "Espalda" }
for i, modo in modosLista do
	local vb = Instance.new("TextButton")
	vb.Position = UDim2.fromScale((i - 1) / 3, 0)
	vb.Size = UDim2.fromScale(1 / 3, 1)
	vb.BackgroundTransparency = 1
	vb.Text = string.upper(modo)
	vb.FontFace = Tema.LetraGruesa
	vb.TextSize = 14
	vb.TextColor3 = if i == 1 then Tema.Hueso else GRIS
	vb.ZIndex = 2
	vb.Parent = barraVista
	table.insert(botonesVista, { modo = modo, boton = vb, idx = i })
	vb.Activated:Connect(function()
		ponerModoVista(modo)
	end)
end

local pillOrbita = Instance.new("Frame")
pillOrbita.AnchorPoint = Vector2.new(1, 1)
pillOrbita.Position = UDim2.new(1, -40, 1, -24)
pillOrbita.Size = UDim2.fromOffset(336, 32)
pillOrbita.BackgroundColor3 = SUPERFICIE
pillOrbita.BackgroundTransparency = 0.2
pillOrbita.BorderSizePixel = 0
pillOrbita.Parent = contenido
local poCorner = Instance.new("UICorner")
poCorner.CornerRadius = UDim.new(0, 6)
poCorner.Parent = pillOrbita
local poStroke = Instance.new("UIStroke")
poStroke.Color = Color3.fromHex("#364156")
poStroke.Parent = pillOrbita

local hintOrbita = Tema.texto(pillOrbita, "ARRASTRÁ EL PERSONAJE PARA GIRARLO 360°", {
	tam = 12,
	letra = Tema.Letra,
	color = Color3.fromHex("#cfd6e3"),
})
hintOrbita.Size = UDim2.fromScale(1, 1)
hintOrbita.TextXAlignment = Enum.TextXAlignment.Center

UserInputService.InputBegan:Connect(function(entrada, usado)
	if not abierto or usado then
		return
	end
	if
		entrada.UserInputType == Enum.UserInputType.MouseButton1
		or entrada.UserInputType == Enum.UserInputType.Touch
	then
		local cam = workspace.CurrentCamera
		local ancho = if cam then cam.ViewportSize.X else 1280
		if entrada.Position.X > ancho * 0.45 then
			arrastrando = true
			ultimoPuntero = Vector2.new(entrada.Position.X, entrada.Position.Y)
		end
	end
end)

UserInputService.InputChanged:Connect(function(entrada)
	if not abierto or not arrastrando or not ultimoPuntero then
		return
	end
	if
		entrada.UserInputType == Enum.UserInputType.MouseMovement
		or entrada.UserInputType == Enum.UserInputType.Touch
	then
		local actual = Vector2.new(entrada.Position.X, entrada.Position.Y)
		local delta = actual - ultimoPuntero
		ultimoPuntero = actual
		yaw -= delta.X * 0.012
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	if
		entrada.UserInputType == Enum.UserInputType.MouseButton1
		or entrada.UserInputType == Enum.UserInputType.Touch
	then
		arrastrando = false
		ultimoPuntero = nil
	end
end)

local velocidadGuardada = 16
local saltoGuardado = 50
local yawActual = 0.12
local distActual = 7.6
local altActual = 0.35
local xActual = 2.35

local function actualizarCamara(dt: number)
	local cam = workspace.CurrentCamera
	local p = jugador.Character
	local raiz = p and p:FindFirstChild("HumanoidRootPart")
	if not (cam and raiz and raiz:IsA("BasePart")) then
		return
	end
	local alpha = math.clamp(dt * 10, 0, 1)
	yawActual += (yaw - yawActual) * alpha
	distActual += (distancia - distActual) * alpha
	altActual += (alturaFoco - altActual) * alpha
	xActual += (desplazamientoX - xActual) * alpha

	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = 48
	local frente = raiz.CFrame
	local rot = CFrame.Angles(0, yawActual, 0)
	local offsetCam = rot:VectorToWorldSpace(Vector3.new(0, altActual + 0.55, -distActual))
	local posCam = (frente * CFrame.new(0, altActual + 0.55, 0)).Position + offsetCam
	local look = CFrame.lookAt(posCam, frente.Position + Vector3.new(0, altActual, 0))
	cam.CFrame = look * CFrame.new(-xActual * 0.45, 0, 0)
	if luzCreador and soporteLuzCreador then
		if soporteLuzCreador.Parent ~= raiz then
			soporteLuzCreador.Parent = raiz
		end
		if luzCreador.Parent ~= soporteLuzCreador then
			luzCreador.Parent = soporteLuzCreador
		end
	end
end

RunService.RenderStepped:Connect(function(dt)
	if abierto then
		actualizarCamara(dt)
	end
end)

local function abrir()
	if abierto then
		return
	end
	abierto = true
	for _, c in CAMPOS do
		refrescarCampo(c)
	end
	for _, nombre in HUD do
		local g = playerGui:FindFirstChild(nombre)
		if g and g:IsA("ScreenGui") then
			g.Enabled = false
		end
	end
	local hum = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		velocidadGuardada, saltoGuardado = hum.WalkSpeed, hum.JumpPower
		hum.WalkSpeed, hum.JumpPower = 0, 0
	end
	if not soporteLuzCreador then
		local att = Instance.new("Attachment")
		att.Name = "SoporteLuzCreador"
		att.Position = Vector3.new(2.2, 2.4, -3.5)
		soporteLuzCreador = att
	end
	if not luzCreador then
		local l = Instance.new("PointLight")
		l.Color = Color3.fromHex("#dbe6ff")
		l.Brightness = 0.65
		l.Range = 16
		l.Shadows = false
		luzCreador = l
	end
	activarTab(1)
	ponerModoVista("Cuerpo")
	jugador:SetAttribute("EnCreador", true)
	gui.Enabled = true
	panel.GroupTransparency = 1
	panel.Position = UDim2.new(0, 12, 0.5, 0)
	TweenService
		:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.new(0, 42, 0.5, 0),
		})
		:Play()
end

local function cerrar()
	abierto = false
	arrastrando = false
	gui.Enabled = false
	if luzCreador then
		luzCreador.Parent = nil
	end
	if soporteLuzCreador then
		soporteLuzCreador.Parent = nil
	end
	jugador:SetAttribute("EnCreador", false)
	jugador:SetAttribute("AbrirCreador", false)
	for _, nombre in HUD do
		local g = playerGui:FindFirstChild(nombre)
		if g and g:IsA("ScreenGui") then
			g.Enabled = true
		end
	end
	local hum = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed, hum.JumpPower = velocidadGuardada, saltoGuardado
	end
	local cam = workspace.CurrentCamera
	if cam then
		if hum then
			cam.CameraSubject = hum
		end
		cam.CameraType = Enum.CameraType.Custom
		cam.FieldOfView = Config.Mundo.Camara.FOV
	end
end

confirmar.Activated:Connect(function()
	-- SONIDO: confirmar el personaje
	confirmado = true
	remoto:FireServer("Confirmar")
	cerrar()
end)

-- Se abre cuando el menú se cierra y: el personaje todavía no se creó, o se pidió desde el menú.
local function revisar()
	if
		abierto
		or jugador:GetAttribute("MenuAbierto") == true
		or not jugador:GetAttribute("DatosListos")
	then
		return
	end
	if
		(jugador:GetAttribute("AparienciaCreada") == false and not confirmado)
		or jugador:GetAttribute("AbrirCreador") == true
	then
		task.defer(abrir)
	end
end

for _, atributo in { "MenuAbierto", "DatosListos", "AparienciaCreada", "AbrirCreador" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(revisar)
end
revisar()

gui.Parent = playerGui
