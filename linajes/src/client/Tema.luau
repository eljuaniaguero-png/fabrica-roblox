--!strict
-- Estilo del HUD: colores, letra, escala y piezas comunes (textos espaciados, barras finas, rombos).
-- Solo dibuja. Los números salen de Config.Hud.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local H = Config.Hud
local Tema = {}

Tema.Hueso = Color3.fromHex(H.Colores.Hueso)
Tema.Vida = Color3.fromHex(H.Colores.Vida)
Tema.Danio = Color3.fromHex(H.Colores.Danio)
Tema.Xp = Color3.fromHex(H.Colores.Xp)
Tema.Fondo = Color3.fromHex(H.Colores.Fondo)

local OSWALD = "rbxasset://fonts/families/Oswald.json"
Tema.Letra = Font.new(OSWALD, Enum.FontWeight.Regular)
Tema.LetraFina = Font.new(OSWALD, Enum.FontWeight.Light)
Tema.LetraGruesa = Font.new(OSWALD, Enum.FontWeight.SemiBold)

local HAIR = utf8.char(0x200A) -- espacio finito entre letras (Roblox no tiene interletrado)

-- "RULETA" -> "R U L E T A" con espacios finitos; las palabras quedan bien separadas.
function Tema.espaciar(texto: string, veces: number?): string
	local separador = string.rep(HAIR, veces or 2)
	local letras = {}
	for _, codigo in utf8.codes(texto) do
		local c = utf8.char(codigo)
		table.insert(letras, if c == " " then "  " else c)
	end
	return table.concat(letras, separador)
end

function Tema.color(linaje: unknown): Color3
	local c = typeof(linaje) == "string" and (Config.Poderes.Colores :: any)[linaje]
	return c or Tema.Hueso
end

function Tema.pantalla(nombre: string, orden: number?): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = nombre
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = orden or 0
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return gui
end

-- Grupo pegado a un borde, medido en píxeles de 1080p y escalado al alto real de la pantalla.
function Tema.grupo(padre: Instance, ancla: Vector2, posicion: UDim2, tam: Vector2): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = ancla
	f.Position = posicion
	f.Size = UDim2.fromOffset(tam.X, tam.Y)
	f.BackgroundTransparency = 1
	local escala = Instance.new("UIScale")
	escala.Parent = f
	local function ajustar()
		local camara = workspace.CurrentCamera
		local alto = if camara then camara.ViewportSize.Y else H.AltoBase
		escala.Scale = math.clamp(alto / H.AltoBase, H.EscalaMin, H.EscalaMax)
	end
	ajustar()
	local camara = workspace.CurrentCamera
	if camara then
		camara:GetPropertyChangedSignal("ViewportSize"):Connect(ajustar)
	end
	f.Parent = padre
	return f
end

export type OpcionesTexto = {
	tam: number?,
	letra: Font?,
	color: Color3?,
	transparencia: number?,
	alineado: Enum.TextXAlignment?,
	espaciado: number?,
}

function Tema.texto(padre: Instance, texto: string, opciones: OpcionesTexto?): TextLabel
	local o: OpcionesTexto = opciones or {}
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.FontFace = o.letra or Tema.Letra
	t.TextSize = o.tam or 15
	t.TextColor3 = o.color or Tema.Hueso
	t.TextTransparency = o.transparencia or 0
	t.TextXAlignment = o.alineado or Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.Text = if o.espaciado then Tema.espaciar(texto, o.espaciado) else texto
	-- Sombra suave en vez de contorno duro: se lee sobre cualquier fondo sin verse "Roblox".
	t.TextStrokeColor3 = Tema.Fondo
	t.TextStrokeTransparency = 0.55
	t.Size = UDim2.fromOffset(0, (o.tam or 15) + 6)
	t.AutomaticSize = Enum.AutomaticSize.X
	t.Parent = padre
	return t
end

-- Barra fina: fondo apenas visible y relleno. Devuelve el relleno (se maneja con Size en escala).
function Tema.barra(
	padre: Instance,
	pos: Vector2,
	ancho: number,
	alto: number,
	color: Color3
): (Frame, Frame)
	local fondo = Instance.new("Frame")
	fondo.Position = UDim2.fromOffset(pos.X, pos.Y)
	fondo.Size = UDim2.fromOffset(ancho, alto)
	fondo.BackgroundColor3 = Tema.Hueso
	fondo.BackgroundTransparency = 0.88
	fondo.BorderSizePixel = 0
	fondo.Parent = padre
	local lleno = Instance.new("Frame")
	lleno.Size = UDim2.fromScale(1, 1)
	lleno.BackgroundColor3 = color
	lleno.BorderSizePixel = 0
	lleno.ZIndex = 3
	lleno.Parent = fondo
	return fondo, lleno
end

-- Rombo: la imagen de Gemini si ya está subida; si no, un cuadrado girado con borde fino.
function Tema.rombo(padre: Instance, centro: Vector2, tam: number, conFondo: boolean): Frame
	local caja = Instance.new("Frame")
	caja.AnchorPoint = Vector2.new(0.5, 0.5)
	caja.Position = UDim2.fromOffset(centro.X, centro.Y)
	caja.Size = UDim2.fromOffset(tam, tam)
	caja.BackgroundTransparency = 1
	caja.Parent = padre
	local lado = tam * 0.62
	if conFondo then
		local fondo = Instance.new("Frame")
		fondo.Name = "Fondo"
		fondo.AnchorPoint = Vector2.new(0.5, 0.5)
		fondo.Position = UDim2.fromScale(0.5, 0.5)
		fondo.Size = UDim2.fromOffset(lado, lado)
		fondo.Rotation = 45
		fondo.BackgroundColor3 = Tema.Fondo
		fondo.BackgroundTransparency = 0.45
		fondo.BorderSizePixel = 0
		fondo.Parent = caja
	end
	if H.Imagenes.MarcoRombo ~= "" then
		local marco = Instance.new("ImageLabel")
		marco.Name = "Marco"
		marco.BackgroundTransparency = 1
		marco.Size = UDim2.fromScale(1, 1)
		marco.Image = H.Imagenes.MarcoRombo
		marco.ImageColor3 = Tema.Hueso
		marco.ZIndex = 4
		marco.Parent = caja
	else
		local marco = Instance.new("Frame")
		marco.Name = "Marco"
		marco.AnchorPoint = Vector2.new(0.5, 0.5)
		marco.Position = UDim2.fromScale(0.5, 0.5)
		marco.Size = UDim2.fromOffset(lado, lado)
		marco.Rotation = 45
		marco.BackgroundTransparency = 1
		marco.ZIndex = 4
		marco.Parent = caja
		local borde = Instance.new("UIStroke")
		borde.Color = Tema.Hueso
		borde.Thickness = 1.5
		borde.Parent = marco
	end
	return caja
end

-- Línea fina con un rombito al medio (o la imagen del ornamento si está subida).
function Tema.ornamento(padre: Instance, centro: Vector2, ancho: number): GuiObject
	if H.Imagenes.Ornamento ~= "" then
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromOffset(centro.X, centro.Y)
		img.Size = UDim2.fromOffset(ancho, ancho / 4)
		img.BackgroundTransparency = 1
		img.Image = H.Imagenes.Ornamento
		img.ImageColor3 = Tema.Hueso
		img.ImageTransparency = 0.25
		img.Parent = padre
		return img
	end
	local linea = Instance.new("Frame")
	linea.AnchorPoint = Vector2.new(0.5, 0.5)
	linea.Position = UDim2.fromOffset(centro.X, centro.Y)
	linea.Size = UDim2.fromOffset(ancho, 1)
	linea.BackgroundColor3 = Tema.Hueso
	linea.BorderSizePixel = 0
	linea.Parent = padre
	local degrade = Instance.new("UIGradient")
	degrade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(1, 1),
	})
	degrade.Parent = linea
	local punta = Instance.new("Frame")
	punta.AnchorPoint = Vector2.new(0.5, 0.5)
	punta.Position = UDim2.fromScale(0.5, 0.5)
	punta.Size = UDim2.fromOffset(7, 7)
	punta.Rotation = 45
	punta.BackgroundTransparency = 1
	punta.Parent = linea
	local borde = Instance.new("UIStroke")
	borde.Color = Tema.Hueso
	borde.Transparency = 0.3
	borde.Parent = punta
	return linea
end

return Tema
