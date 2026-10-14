--!strict
-- Estilo de la UI de Forja Rápida (como las capturas de referencia y el diseño de Figma):
-- letra redonda y gorda, texto blanco con contorno oscuro, esquinas redondeadas.

local Estilo = {}

Estilo.Fuente = Enum.Font.FredokaOne
Estilo.Oscuro = Color3.fromHex("#1B1F3B")
Estilo.Blanco = Color3.new(1, 1, 1)
Estilo.Verde = Color3.fromHex("#7CFF3C")
Estilo.VerdeOscuro = Color3.fromHex("#2DBA2D")

-- Ícono de cada modificador simple; las combinaciones juntan los de sus partes.
local ICONOS: { [string]: string } = {
	Lava = "🔥",
	Neon = "⚡",
	Midas = "🌟",
	Vacio = "🌌",
}

function Estilo.icono(partes: { string }): string
	local r = ""
	for _, p in partes do
		r ..= ICONOS[p] or ""
	end
	return r
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
