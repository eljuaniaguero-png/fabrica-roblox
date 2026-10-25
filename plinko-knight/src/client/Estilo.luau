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

Estilo.Colores = {
	Velo = "#000000", -- fondo oscurecido de las pantallas que tapan todo
	Panel = "#202020",
	PanelClaro = "#3A3A3A",
	Carta = "#4A4A4A",
	Boton = "#5A5A5A",
	Principal = "#4CC46A", -- el botón importante de cada pantalla ("Bajar", "Volver a bajar")
	Peligro = "#E2323F", -- vender, cancelar, la maña del jefe, sin oro
	Oro = "#F5C542",
	Texto = "#FFFFFF",
	Apagado = "#9A9A9A", -- bloqueado, lugar libre
	Borde = "#808080",
	Vida = "#4CC46A",
	Si = "#4CC46A", -- interruptor prendido
	No = "#5A5A5A", -- interruptor apagado
}

Estilo.Fuentes = {
	Titulo = Enum.Font.GothamBlack,
	Texto = Enum.Font.GothamBold,
}

-- Tamaños de texto en unidades del lienzo (nada más chico que Chico).
Estilo.Texto = {
	Chico = 22,
	Normal = 26,
	Grande = 34,
	Enorme = 52,
	Titulo = 72,
}

Estilo.Medidas = {
	Boton = 64, -- alto mínimo de cualquier botón (≈ 45 px en celular)
	BotonGrande = 84,
	BarraArriba = 68, -- franja de arriba en la pelea (vida, pelea, ajustes)
	BarraAbajo = 70, -- franja de abajo en la pelea (bola, pergaminos, reliquias)
	Margen = 10,
	Esquina = 12,
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
	t.Text = valor
	t.Parent = padre
	return t
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
	b.Size = UDim2.fromOffset(200, Estilo.Medidas.Boton)
	b.Parent = padre
	redondear(b)
	local minimo = Instance.new("UISizeConstraint")
	minimo.MinSize = Vector2.new(Estilo.Medidas.Boton, Estilo.Medidas.Boton)
	minimo.Parent = b
	return b
end

-- Panel con fondo y esquinas redondeadas.
function Estilo.panel(padre: Instance, color: string?): Frame
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Estilo.color(color or "Panel")
	f.BackgroundTransparency = Estilo.Transparencia.Panel
	f.BorderSizePixel = 0
	f.Parent = padre
	redondear(f)
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
