--!strict
-- Estilo de la UI de Forja Rápida (como las capturas de referencia y el diseño de Figma):
-- letra redonda y gorda, texto blanco con contorno oscuro, esquinas redondeadas, degradés.
-- Íconos: imágenes (GameConfig.Iconos), nunca emojis. Si un ícono todavía no está subido, se
-- dibuja una insignia redonda de su color con un brillo, para que nada quede vacío.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)

local Estilo = {}

Estilo.Fuente = Enum.Font.FredokaOne
Estilo.Oscuro = Color3.fromHex("#1B1F3B")
Estilo.Blanco = Color3.new(1, 1, 1)
Estilo.Verde = Color3.fromHex("#7CFF3C")
Estilo.VerdeOscuro = Color3.fromHex("#2DBA2D")

-- Color de la insignia de cada ícono mientras no haya imagen.
local COLOR_ICONO: { [string]: { string } } = {
	Lava = { "#FFE14D", "#FF5A00" },
	Neon = { "#7CF5FF", "#B04DFF" },
	Midas = { "#FFF3B0", "#F5A300" },
	Vacio = { "#B97BFF", "#2B1060" },
	Trebol = { "#9CFF4A", "#22A83A" },
	Moneda = { "#FFE07A", "#E89B12" },
	Fuerza = { "#FF8A94", "#D62839" },
	Chispa = { "#FFFFFF", "#7CC8FF" },
	Trofeo = { "#FFE07A", "#F5A300" },
	Corona = { "#D9B8FF", "#7A2FE0" },
	Reloj = { "#C9F0FF", "#1C7FE0" },
	Jefe = { "#FFD23F", "#7A2FE0" },
	Cristal = { "#C9FFFF", "#3FA9FF" },
	Gema = { "#FFFFFF", "#B04DFF" },
}

local function degradado(padre: Instance, colores: { Color3 }, rotacion: number?)
	local g = Instance.new("UIGradient")
	local puntos = {}
	for i, c in colores do
		table.insert(puntos, ColorSequenceKeypoint.new((i - 1) / math.max(1, #colores - 1), c))
	end
	if #puntos == 1 then
		table.insert(puntos, ColorSequenceKeypoint.new(1, colores[1]))
	end
	g.Color = ColorSequence.new(puntos)
	g.Rotation = rotacion or 90
	g.Parent = padre
	return g
end

-- Degradé de colores (hex) para un texto o un marco (los títulos, "¡MÍTICO!", etc.).
function Estilo.degradado(obj: GuiObject, colores: { string }, rotacion: number?): UIGradient
	local lista = {}
	for _, h in colores do
		table.insert(lista, Color3.fromHex(h))
	end
	if obj:IsA("TextLabel") then
		obj.TextColor3 = Color3.new(1, 1, 1) -- el degradé tiñe el blanco
	end
	return degradado(obj, lista, rotacion)
end

-- Ícono por nombre (ver GameConfig.Iconos). Devuelve un ImageLabel o la insignia de color.
function Estilo.icono(nombre: string, tamano: number): GuiObject
	local id = (GameConfig.Iconos :: { [string]: string })[nombre]
	if id and id ~= "" then
		local img = Instance.new("ImageLabel")
		img.Name = "Icono" .. nombre
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromOffset(tamano, tamano)
		img.Image = id
		img.ScaleType = Enum.ScaleType.Fit
		return img
	end
	local colores = COLOR_ICONO[nombre] or { "#FFFFFF", "#8D939C" }
	local f = Instance.new("Frame")
	f.Name = "Icono" .. nombre
	f.Size = UDim2.fromOffset(tamano, tamano)
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(1, 0)
	esquina.Parent = f
	degradado(f, { Color3.fromHex(colores[1]), Color3.fromHex(colores[2]) })
	local borde = Instance.new("UIStroke")
	borde.Thickness = math.max(2, tamano / 12)
	borde.Color = Estilo.Oscuro
	borde.Parent = f
	-- brillo: un rombo blanco arriba a la izquierda
	local brillo = Instance.new("Frame")
	brillo.Size = UDim2.fromScale(0.28, 0.28)
	brillo.Position = UDim2.fromScale(0.22, 0.18)
	brillo.Rotation = 45
	brillo.BackgroundColor3 = Color3.new(1, 1, 1)
	brillo.BackgroundTransparency = 0.25
	brillo.BorderSizePixel = 0
	brillo.Parent = f
	return f
end

-- Íconos de un modificador (una combinación tiene dos).
function Estilo.iconosModificador(modificador: string): { string }
	return Reglas.partes(modificador)
end

function Estilo.esquinas(obj: GuiObject, radio: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radio)
	c.Parent = obj
end

function Estilo.borde(obj: GuiObject, grosor: number, color: Color3?)
	local s = Instance.new("UIStroke")
	s.Thickness = grosor
	s.Color = color or Estilo.Oscuro
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
end

-- Texto blanco (o del color pedido) con contorno oscuro, fondo transparente.
function Estilo.texto(texto: string, tamano: number, color: Color3?, grosor: number?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Estilo.Fuente
	t.Text = texto
	t.TextSize = tamano
	t.TextColor3 = color or Estilo.Blanco
	t.AutomaticSize = Enum.AutomaticSize.XY
	t.Size = UDim2.fromOffset(0, 0)
	local s = Instance.new("UIStroke")
	s.Thickness = grosor or math.max(2, tamano / 9)
	s.Color = Estilo.Oscuro
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = t
	return t
end

-- Fila horizontal (sin fondo) con sus hijos centrados verticalmente.
function Estilo.fila(espacio: number): Frame
	local f = Instance.new("Frame")
	f.BackgroundTransparency = 1
	f.AutomaticSize = Enum.AutomaticSize.XY
	f.Size = UDim2.fromOffset(0, 0)
	local l = Instance.new("UIListLayout")
	l.FillDirection = Enum.FillDirection.Horizontal
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, espacio)
	l.Parent = f
	return f
end

-- Íconos + texto en fila (ej.: los dos íconos de una combinación y su nombre).
function Estilo.conIconos(iconos: { string }, texto: string, tamano: number, color: Color3?): Frame
	local f = Estilo.fila(4)
	for i, nombre in iconos do
		local ic = Estilo.icono(nombre, math.floor(tamano * 1.1))
		ic.LayoutOrder = i
		ic.Parent = f
	end
	local t = Estilo.texto(texto, tamano, color)
	t.LayoutOrder = #iconos + 1
	t.Parent = f
	return f
end

function Estilo.pantalla(nombre: string, orden: number): ScreenGui
	local g = Instance.new("ScreenGui")
	g.Name = nombre
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = orden
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return g
end

return Estilo
