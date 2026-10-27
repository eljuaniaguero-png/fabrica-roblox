--!strict
-- Estilo de todas las pantallas (etapa 7): colores, fuentes, tamaños y las piezas comunes
-- (lienzo con escala, textos, botones, paneles). Es el ÚNICO lugar donde se elige cómo se ven las
-- pantallas: el arte de la etapa 9 se cambia acá.
--
-- Escala: todo se diseña en un lienzo de Diseno (960 × 480 "unidades") y un UIScale lo agranda o
-- achica para que entre en la pantalla (compu, tablet o celular horizontal). El lienzo siempre
-- tiene al menos 960 de ancho y 480 de alto, así nada se sale. Con la escala de un celular
-- horizontal (~0,7) un botón de 64 queda en unos 45 px y el texto más chico (22) en unos 15.
-- Graybox hasta la etapa 8: grises, con color solo para distinguir cosas.

local Estilo = {}

Estilo.Diseno = Vector2.new(960, 480)

-- Paleta y fuentes: las de la variante elegida de la pantalla de juego (Config.Pantalla, 26/10:
-- CloverPit + futurista). Cambiar de variante cambia todas las pantallas.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local variante = Config.variantePantalla()

Estilo.Colores = table.clone(variante.Hud)
Estilo.Colores.BordePanel = variante.BordePanel

-- Etapa 10b (variante "D · Pixel"): marcos e íconos pixel de ForgeGUI (Config.Assets.Hud).
Estilo.Pixel = variante.Pixel == true
Estilo.Hud = Config.Assets.Hud

Estilo.Fuentes = {
	Titulo = (Enum.Font :: any)[variante.Fuente] or Enum.Font.Oswald, -- mayúsculas angostas, como CloverPit
	Texto = (Enum.Font :: any)[variante.FuenteTexto] or Enum.Font.GothamBold,
}

-- Tamaños de texto en unidades del lienzo (nada más chico que Chico). La letra pixel es más ancha:
-- con ella todo va un poco más chico.
Estilo.Texto = if Estilo.Pixel
	then { Chico = 18, Normal = 22, Grande = 28, Enorme = 44, Titulo = 60 }
	else { Chico = 22, Normal = 26, Grande = 34, Enorme = 52, Titulo = 72 }

Estilo.Medidas = {
	Boton = 64, -- alto mínimo de cualquier botón (≈ 45 px en celular)
	BotonGrande = 84,
	BarraArriba = 68, -- franja de arriba en la pelea (vida, pelea, ajustes)
	BarraAbajo = 70, -- franja de abajo en la pelea (bola, pergaminos, reliquias)
	Margen = 10,
	Esquina = variante.Esquina,
	Borde = 3,
}

Estilo.Transparencia = {
	Velo = 0.3,
	Panel = 0.1,
}

function Estilo.color(nombre: string): Color3
	return Color3.fromHex((Estilo.Colores :: any)[nombre] or nombre)
end

-- Escala actual (la del último lienzo que se acomodó): para saber cuántos px mide algo.
local escalaActual = 1
function Estilo.escala(): number
	return escalaActual
end

-- Lienzo de diseño dentro de un ScreenGui: un Frame del tamaño de Diseno (o más) con un UIScale
-- que lo ajusta a la pantalla. Todo lo que se dibuja va adentro, en unidades de diseño.
function Estilo.lienzo(gui: ScreenGui): Frame
	local lienzo = Instance.new("Frame")
	lienzo.Name = "Lienzo"
	lienzo.AnchorPoint = Vector2.new(0.5, 0.5)
	lienzo.Position = UDim2.fromScale(0.5, 0.5)
	lienzo.BackgroundTransparency = 1
	lienzo.Parent = gui
	local escala = Instance.new("UIScale")
	escala.Parent = lienzo
	local function acomodar()
		local real = gui.AbsoluteSize
		if real.X <= 0 or real.Y <= 0 then
			return
		end
		local s = math.min(real.X / Estilo.Diseno.X, real.Y / Estilo.Diseno.Y)
		escala.Scale = s
		escalaActual = s
		lienzo.Size = UDim2.fromOffset(real.X / s, real.Y / s)
	end
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(acomodar)
	acomodar()
	return lienzo
end

local function redondear(objeto: GuiObject, radio: number?)
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, radio or Estilo.Medidas.Esquina)
	esquina.Parent = objeto
end
Estilo.redondear = redondear

function Estilo.borde(objeto: GuiObject, color: string, grosor: number?): UIStroke
	local b = Instance.new("UIStroke")
	b.Thickness = grosor or Estilo.Medidas.Borde
	b.Color = Estilo.color(color)
	b.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	b.Parent = objeto
	return b
end

-- Texto sin fondo. tamanio: uno de Estilo.Texto (por defecto Normal). Con contorno oscuro, así se
-- lee sobre el tablero.
function Estilo.texto(
	padre: Instance,
	valor: string,
	tamanio: number?,
	fuente: Enum.Font?
): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = fuente or Estilo.Fuentes.Titulo
	t.TextSize = tamanio or Estilo.Texto.Normal
	t.TextWrapped = true
	t.TextColor3 = Estilo.color("Texto")
	t.TextStrokeTransparency = 0.4
	if Estilo.Pixel then
		-- Contorno duro y oscuro, como en los juegos pixel.
		t.TextStrokeColor3 = Estilo.color("Sombra")
		t.TextStrokeTransparency = 0
	end
	t.Text = valor
	t.Parent = padre
	return t
end

-- Marco pixel de ForgeGUI encima de un objeto (9-slice, el centro es hueco: el texto y el fondo
-- del objeto se ven a través). cual: "Panel" o "Casillero". Sin variante pixel, no hace nada.
function Estilo.marco(objeto: GuiObject, cual: string?, grosor: number?): ImageLabel?
	if not Estilo.Pixel then
		return nil
	end
	local id = (Estilo.Hud :: any)[cual or "Panel"]
	if typeof(id) ~= "string" or id == "" then
		return nil
	end
	local corte = Estilo.Hud.CortePanel
	local m = Instance.new("ImageLabel")
	m.Name = "Marco"
	m.BackgroundTransparency = 1
	m.Image = id
	m.ScaleType = Enum.ScaleType.Slice
	m.SliceCenter = Rect.new(corte, corte, 256 - corte, 256 - corte)
	m.SliceScale = (grosor or 10) / corte
	m.ResampleMode = Enum.ResamplerMode.Pixelated
	m.Size = UDim2.new(1, 4, 1, 4)
	m.AnchorPoint = Vector2.new(0.5, 0.5)
	m.Position = UDim2.fromScale(0.5, 0.5)
	m.ZIndex = 0 -- debajo de los hijos del objeto (texto, íconos)
	m.Active = false
	m.Parent = objeto
	return m
end

-- Ícono pixel del HUD (Config.Assets.Hud: Corazon, Moneda, Engranaje, Puerta, Espada, Llama).
function Estilo.iconoHud(padre: Instance, nombre: string): ImageLabel
	local i = Instance.new("ImageLabel")
	i.Name = "Icono" .. nombre
	i.BackgroundTransparency = 1
	i.ScaleType = Enum.ScaleType.Fit
	i.ResampleMode = Enum.ResamplerMode.Pixelated
	i.Image = (Estilo.Hud :: any)[nombre] or ""
	i.Parent = padre
	return i
end

-- Texto que se achica de a 1 solo si no entra (nombres largos), nunca por debajo de `minimo`.
-- (TextScaled con UIScale deja el texto mucho más chico de lo debido: por eso se hace a mano.)
function Estilo.ajustar(t: TextLabel | TextButton, maximo: number, minimo: number)
	t.TextScaled = false
	t.TextWrapped = true
	local function medir()
		local tamanio = maximo
		t.TextSize = tamanio
		while not t.TextFits and tamanio > minimo do
			tamanio -= 1
			t.TextSize = tamanio
		end
	end
	t:GetPropertyChangedSignal("Text"):Connect(medir)
	t:GetPropertyChangedSignal("AbsoluteSize"):Connect(medir)
	medir()
end

-- Botón con texto, de Medidas.Boton de alto como mínimo.
function Estilo.boton(padre: Instance, valor: string, color: string?, tamanio: number?): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Estilo.color(color or "Boton")
	b.BorderSizePixel = 0
	b.Font = Estilo.Fuentes.Titulo
	b.TextSize = tamanio or Estilo.Texto.Normal
	b.TextWrapped = true
	b.TextColor3 = Estilo.color("Texto")
	b.TextStrokeTransparency = 0.5
	b.Text = valor
	if color == "Principal" then
		b.TextColor3 = Estilo.color("TextoPrincipal")
		b.TextStrokeTransparency = 1
	end
	b.Size = UDim2.fromOffset(200, Estilo.Medidas.Boton)
	if Estilo.Pixel then
		-- Botón pixel: contorno oscuro y un labio de sombra abajo (se ve "apretable").
		b.TextStrokeColor3 = Estilo.color("Sombra")
		b.TextStrokeTransparency = if color == "Principal" then 1 else 0
		local contorno = Instance.new("UIStroke")
		contorno.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		contorno.Color = Estilo.color("Sombra")
		contorno.Thickness = 2
		contorno.Parent = b
		local labio = Instance.new("Frame")
		labio.Name = "Labio"
		labio.BackgroundColor3 = Estilo.color("Sombra")
		labio.BorderSizePixel = 0
		labio.Position = UDim2.new(0, 2, 1, -2)
		labio.Size = UDim2.new(1, -4, 0, 6)
		labio.ZIndex = 0
		labio.Parent = b
		redondear(labio)
	end
	-- SONIDO: click de botón (Config.Sonidos.Boton). Se pide recién al tocar: Sonidos usa Estilo.
	b.Activated:Connect(function()
		local ok, sonidos = pcall(require, script.Parent:FindFirstChild("Sonidos") :: any)
		if ok and sonidos then
			sonidos.tocar("Boton")
		end
	end)
	b.Parent = padre
	redondear(b)
	local minimo = Instance.new("UISizeConstraint")
	minimo.MinSize = Vector2.new(Estilo.Medidas.Boton, Estilo.Medidas.Boton)
	minimo.Parent = b
	return b
end

-- Imagen (ícono de ForgeGUI) que entra entera en su caja. Si no hay id, no se ve.
function Estilo.icono(padre: Instance, id: string?): ImageLabel
	local i = Instance.new("ImageLabel")
	i.Name = "Icono"
	i.BackgroundTransparency = 1
	i.ScaleType = Enum.ScaleType.Fit
	i.Image = id or ""
	i.Visible = (id or "") ~= ""
	i.Parent = padre
	return i
end

-- Panel con fondo y esquinas redondeadas.
function Estilo.panel(padre: Instance, color: string?): Frame
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Estilo.color(color or "Panel")
	f.BackgroundTransparency = Estilo.Transparencia.Panel
	f.BorderSizePixel = 0
	f.Parent = padre
	redondear(f)
	Estilo.marco(f, "Panel")
	-- Borde fino de neón (variantes B y C): lo futurista sobre las cajas negras de CloverPit.
	if Estilo.Colores.BordePanel ~= "" then
		local b = Instance.new("UIStroke")
		b.Thickness = 1.5
		b.Color = Color3.fromHex(Estilo.Colores.BordePanel)
		b.Transparency = 0.2
		b.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		b.Parent = f
	end
	return f
end

-- Fondo oscuro que tapa la pantalla entera (también la franja de Roblox de arriba). Va fuera del
-- lienzo, directo en el ScreenGui; el botón del menú de Roblox queda siempre por encima.
function Estilo.velo(gui: ScreenGui, transparencia: number?): Frame
	local v = Instance.new("Frame")
	v.Name = "Velo"
	v.Position = UDim2.fromOffset(-200, -200)
	v.Size = UDim2.new(1, 400, 1, 400)
	v.BackgroundColor3 = Estilo.color("Velo")
	v.BackgroundTransparency = transparencia or Estilo.Transparencia.Velo
	v.BorderSizePixel = 0
	v.Active = true -- los toques en el velo no llegan al tablero
	v.Parent = gui
	return v
end

-- ScreenGui de pantalla del juego (en PlayerGui), respetando los botones de Roblox.
function Estilo.pantalla(nombre: string, orden: number, padre: Instance): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = nombre
	gui.ResetOnSpawn = false
	gui.DisplayOrder = orden
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = padre
	return gui
end

-- Fila o columna automática.
function Estilo.lista(padre: Instance, horizontal: boolean, separacion: number?): UIListLayout
	local l = Instance.new("UIListLayout")
	l.FillDirection = if horizontal
		then Enum.FillDirection.Horizontal
		else Enum.FillDirection.Vertical
	l.Padding = UDim.new(0, separacion or Estilo.Medidas.Margen)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.VerticalAlignment = if horizontal
		then Enum.VerticalAlignment.Center
		else Enum.VerticalAlignment.Top
	l.Parent = padre
	return l
end

return Estilo
