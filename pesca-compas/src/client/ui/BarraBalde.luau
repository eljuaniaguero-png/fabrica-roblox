--!strict
-- Barra del balde, abajo al centro (sacada de las referencias): una casilla por pez con su
-- color de rareza, el kg y una estrella si es Afinado; a la derecha el total que vale el balde.
-- Cuando se llena, el contador late en rojo y dice adónde ir. Solo muestra: el precio real lo
-- calcula el servidor al vender (Economia.vender); acá se usa la misma fórmula (Ritmo.precio).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Estilo = require(Shared:WaitForChild("Estilo"))
local Ritmo = require(Shared:WaitForChild("Ritmo"))
local Tokens = require(script.Parent.Tokens)
local UI = Estilo.UI
local T = Tokens.Balde

export type PezBalde = { Id: string, Peso: number, Afinado: boolean }

export type BarraBalde = {
	actualizar: (cubeta: { PezBalde }, capacidad: number) -> (),
	destruir: () -> (),
}

local BarraBalde = {}

local function texto(padre: Instance, tam: UDim2, pos: UDim2, alineado: Enum.TextXAlignment?): TextLabel
	local t = Instance.new("TextLabel")
	t.Size = tam
	t.Position = pos
	t.BackgroundTransparency = 1
	t.Font = UI.Fuente
	t.TextScaled = true
	t.TextColor3 = UI.Texto
	t.TextXAlignment = alineado or Enum.TextXAlignment.Center
	Estilo.bordeTexto(t)
	t.Parent = padre
	return t
end

local function esquina(gui: GuiObject, radio: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radio)
	c.Parent = gui
end

local function casilla(padre: Instance, p: PezBalde, orden: number): Frame
	local pez = Ritmo.pezPorId(p.Id)
	local rareza = if pez then Ritmo.rareza(pez.Rareza) else nil
	local c = Instance.new("Frame")
	c.Name = "Pez" .. orden
	c.LayoutOrder = orden
	c.Size = UDim2.fromOffset(T.Casilla, T.Casilla)
	c.BackgroundColor3 = if rareza then rareza.Color else UI.PanelOscuro
	esquina(c, UI.Esquina - 4)
	Estilo.borde(c, if p.Afinado then UI.Borde + 1 else UI.Borde - 1).Color = if p.Afinado
		then Estilo.Pez.Afinado
		else Estilo.Contorno
	local cuadrada = Instance.new("UIAspectRatioConstraint")
	cuadrada.AspectRatio = 1
	cuadrada.Parent = c

	-- mancha del color del pez, como un ícono redondo arriba
	local icono = Instance.new("Frame")
	icono.Size = UDim2.fromScale(0.46, 0.46)
	icono.Position = UDim2.fromScale(0.5, 0.08)
	icono.AnchorPoint = Vector2.new(0.5, 0)
	icono.BackgroundColor3 = if pez then pez.Color else UI.Texto
	esquina(icono, 999)
	Estilo.borde(icono, 2)
	local aspecto = Instance.new("UIAspectRatioConstraint")
	aspecto.AspectRatio = 1
	aspecto.Parent = icono
	icono.Parent = c

	local kg = texto(c, UDim2.fromScale(0.92, 0.34), UDim2.fromScale(0.04, 0.6))
	kg.Text = ("%.1f kg"):format(p.Peso)
	if p.Afinado then
		local estrella = texto(c, UDim2.fromScale(0.36, 0.36), UDim2.fromScale(0.66, -0.08))
		estrella.Text = "★"
		estrella.TextColor3 = Estilo.Pez.Afinado
	end
	c.Parent = padre
	return c
end

function BarraBalde.nueva(padre: Instance): BarraBalde
	local barra = Instance.new("Frame")
	barra.Name = "BarraBalde"
	barra.Size = UDim2.new(T.Ancho, 0, 0, T.Alto)
	barra.Position = UDim2.fromScale(0.5, T.Abajo)
	barra.AnchorPoint = Vector2.new(0.5, 1)
	barra.BackgroundColor3 = UI.PanelOscuro
	barra.BackgroundTransparency = 0.1
	esquina(barra, UI.Esquina)
	Estilo.borde(barra)
	barra.Parent = padre

	-- contador y valor a la derecha, ancho fijo para que no salte
	local lado = Instance.new("Frame")
	lado.Size = UDim2.new(0, T.Lado, 1, 0)
	lado.Position = UDim2.fromScale(1, 0)
	lado.AnchorPoint = Vector2.new(1, 0)
	lado.BackgroundTransparency = 1
	lado.Parent = barra
	local tCuenta = texto(lado, UDim2.fromScale(0.92, 0.44), UDim2.fromScale(0.04, 0.06))
	local tValor = texto(lado, UDim2.fromScale(0.92, 0.4), UDim2.fromScale(0.04, 0.52))
	tValor.TextColor3 = UI.Escamas
	local latido = Instance.new("UIScale")
	latido.Parent = tCuenta
	local tweenLatido = TweenService:Create(latido, Tokens.Tween.Latido, { Scale = 1.15 })

	local lista = Instance.new("ScrollingFrame")
	lista.Name = "Peces"
	lista.Size = UDim2.new(1, -(T.Lado + Tokens.Separacion), 1, 0)
	lista.BackgroundTransparency = 1
	lista.BorderSizePixel = 0
	lista.ScrollingDirection = Enum.ScrollingDirection.X
	lista.ScrollBarThickness = 4
	lista.ScrollBarImageColor3 = UI.Texto
	lista.AutomaticCanvasSize = Enum.AutomaticSize.X
	lista.CanvasSize = UDim2.new()
	lista.Parent = barra
	local relleno = Instance.new("UIPadding")
	relleno.PaddingLeft = UDim.new(0, Tokens.Relleno)
	relleno.PaddingRight = UDim.new(0, Tokens.Relleno)
	relleno.Parent = lista
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, Tokens.Separacion)
	layout.Parent = lista

	local vacio = texto(lista, UDim2.new(0, 320, 0.5, 0), UDim2.new())
	vacio.LayoutOrder = 0
	vacio.Text = "Tu balde está vacío: ¡tirá la caña!"
	vacio.TextXAlignment = Enum.TextXAlignment.Left

	local casillas: { Frame } = {}
	local cantidadAntes = 0

	local function actualizar(cubeta: { PezBalde }, capacidad: number)
		for _, c in casillas do
			c:Destroy()
		end
		table.clear(casillas)
		local total = 0
		-- el más nuevo primero: es el que el jugador acaba de sacar
		for i = #cubeta, 1, -1 do
			local p = cubeta[i]
			table.insert(casillas, casilla(lista, p, #cubeta - i + 1))
			local pez = Ritmo.pezPorId(p.Id)
			if pez then
				total += Ritmo.precio(pez, p.Peso, p.Afinado)
			end
		end
		vacio.Visible = #cubeta == 0
		lista.CanvasPosition = Vector2.zero

		-- el pez nuevo entra con rebote
		if #cubeta > cantidadAntes and casillas[1] then
			local s = Instance.new("UIScale")
			s.Scale = 0.3
			s.Parent = casillas[1]
			TweenService:Create(s, Tokens.Tween.Entrar, { Scale = 1 }):Play()
		end
		cantidadAntes = #cubeta

		local lleno = #cubeta >= capacidad
		-- sin 🪣: es un emoji de 2019 que la fuente de Roblox no dibuja (en Play salía un cuadradito)
		tCuenta.Text = ("BALDE %d/%d"):format(#cubeta, capacidad)
		tCuenta.TextColor3 = if lleno then UI.Error else UI.Texto
		tValor.Text = if lleno then "¡Vendé!" else ("≈%d 🐟"):format(total)
		if lleno then
			tweenLatido:Play()
		else
			tweenLatido:Cancel()
			latido.Scale = 1
		end
	end

	local function destruir()
		tweenLatido:Cancel()
		barra:Destroy()
	end

	return { actualizar = actualizar, destruir = destruir }
end

return BarraBalde
