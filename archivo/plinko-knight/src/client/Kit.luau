--!strict
-- Kit de interfaz de Forja Rápida, copiado de forja-rapida/src/client/Estilo.luau (etapa 12a).
-- Letra redonda y gorda, texto blanco con contorno oscuro, botones gordos con brillo, degradés.
-- Las piezas (botones, cabecera, píldora, barras, panel, baldosa, marco, X, globito) son las
-- imágenes de Forja ya subidas (Config.Kit.Gui); los íconos, su hoja (Config.Kit.HojaIconos) o
-- cualquier "rbxassetid://" (monstruos, reliquias y bolas de Plinko). Si una pieza no está, se
-- dibuja con degradé, borde y brillo. Nunca emojis.
-- No reemplaza todavía a client/Estilo: las pantallas se pasan a este kit en los pasos 12b a 12e.
--
-- Ojo: el fondo y el brillo son hijos del objeto, así que los UIListLayout van dentro de un
-- "Contenido" (Kit.contenido), no directo en el botón.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Sonidos = require(script.Parent:WaitForChild("Sonidos"))

local K = Config.Kit

local Kit = {}

Kit.Fuente = (Enum.Font :: any)[K.Fuente] or Enum.Font.FredokaOne
Kit.Oscuro = Color3.fromHex(K.Oscuro)
Kit.Blanco = Color3.new(1, 1, 1)
Kit.Colores = K.Colores
Kit.Rarezas = K.Rarezas

local function degradado(padre: Instance, colores: { Color3 }, rotacion: number?): UIGradient
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

local function hex(lista: { string }): { Color3 }
	local r = {}
	for _, h in lista do
		table.insert(r, Color3.fromHex(h))
	end
	return r
end

-- Degradé de colores (hex) para un texto o un marco.
function Kit.degradado(obj: GuiObject, colores: { string }, rotacion: number?): UIGradient
	if obj:IsA("TextLabel") then
		obj.TextColor3 = Color3.new(1, 1, 1) -- el degradé tiñe el blanco
	end
	return degradado(obj, hex(colores), rotacion)
end

-- Piezas ----------------------------------------------------------------------------------

function Kit.pieza(nombre: string): Config.PiezaGui?
	local p = K.Gui[nombre]
	if p and p.Imagen ~= "" then
		return p
	end
	return nil
end

-- Escala acumulada de los UIScale de los ancestros (el lienzo se achica en celular).
local function escalaDe(obj: Instance): number
	local s = 1
	local a: Instance? = obj.Parent
	while a do
		for _, hijo in a:GetChildren() do
			if hijo:IsA("UIScale") and hijo.Name ~= "Salto" then
				s *= hijo.Scale
			end
		end
		a = a.Parent
	end
	return s
end

-- ImageLabel de la pieza, del tamaño de `obj` y detrás de todo. Con 9-slice, las esquinas van en
-- proporción al alto en pantalla (botones, barras) o fijas con Escala (paneles y baldosas).
local function imagen(p: Config.PiezaGui, obj: GuiObject): ImageLabel
	local img = Instance.new("ImageLabel")
	img.Name = "Fondo"
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromScale(1, 1)
	img.ZIndex = 0
	img.Image = p.Imagen
	local corte = p.Corte
	if corte then
		img.ScaleType = Enum.ScaleType.Slice
		img.SliceCenter = Rect.new(corte[1], corte[2], corte[3], corte[4])
		-- Etapa 12b: SliceScale va en unidades del objeto, antes de los UIScale de arriba (el lienzo
		-- de Plinko escala ×2 en 1080p). Forja multiplicaba por esa escala y las esquinas salían
		-- dobles; acá se usa el tamaño propio del objeto.
		local function ajustar()
			if p.Escala then
				img.SliceScale = p.Escala
			else
				local alto = obj.AbsoluteSize.Y / math.max(escalaDe(obj), 0.01)
				if alto > 0 then
					img.SliceScale = math.clamp(alto / p.Alto, 0.05, 2)
				end
			end
		end
		obj:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajustar)
		task.defer(ajustar)
	else
		img.ScaleType = Enum.ScaleType.Fit
	end
	img.Parent = obj
	return img
end

-- Brillo de vidrio arriba (solo en el dibujo de respaldo; las piezas ya lo traen).
local function brillo(obj: GuiObject, radio: number)
	local b = Instance.new("Frame")
	b.Name = "Brillo"
	b.BackgroundColor3 = Color3.new(1, 1, 1)
	b.BackgroundTransparency = 0.72
	b.BorderSizePixel = 0
	b.Position = UDim2.fromOffset(5, 4)
	b.Size = UDim2.new(1, -10, 0.42, 0)
	b.ZIndex = 0
	Kit.esquinas(b, math.max(4, radio - 3))
	b.Parent = obj
end

-- Pinta el fondo de `obj` con la primera pieza de `piezas` (si es blanca, teñida con `colores`)
-- o, si no hay ninguna, con degradé, borde oscuro y brillo.
function Kit.superficie(
	obj: GuiObject,
	piezas: { string },
	colores: { string },
	radio: number,
	grosor: number?,
	sinBrillo: boolean?
)
	for _, nombre in piezas do
		local p = Kit.pieza(nombre)
		if p then
			obj.BackgroundTransparency = 1
			local img = imagen(p, obj)
			if p.Tinte then
				degradado(img, hex(colores))
			end
			return
		end
	end
	obj.BackgroundTransparency = 0
	obj.BackgroundColor3 = Color3.new(1, 1, 1)
	obj.BorderSizePixel = 0
	Kit.esquinas(obj, radio)
	if (grosor or 4) > 0 then
		Kit.borde(obj, grosor or 4)
	end
	degradado(obj, hex(colores))
	if not sinBrillo then
		brillo(obj, radio)
	end
end

-- Marco transparente que ocupa todo `padre`, con una fila o columna centrada adentro.
function Kit.contenido(padre: GuiObject, espacio: number, vertical: boolean?): Frame
	local c = Instance.new("Frame")
	c.Name = "Contenido"
	c.BackgroundTransparency = 1
	c.Size = UDim2.fromScale(1, 1)
	c.ZIndex = 2
	local l = Instance.new("UIListLayout")
	l.FillDirection = if vertical
		then Enum.FillDirection.Vertical
		else Enum.FillDirection.Horizontal
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, espacio)
	l.Parent = c
	c.Parent = padre
	return c
end

-- Se achica al apretarlo y crece un poco al pasar el mouse.
function Kit.presionable(b: GuiButton)
	local escala = Instance.new("UIScale")
	escala.Parent = b
	local function ir(valor: number, t: number)
		TweenService:Create(escala, TweenInfo.new(t, Enum.EasingStyle.Back), { Scale = valor })
			:Play()
	end
	local encima = false
	local function soltar()
		ir(if encima then 1.05 else 1, 0.15)
	end
	b.MouseEnter:Connect(function()
		-- en celular el dedo "entra" al tocar y a veces nunca "sale": ahí no se agranda
		if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
			return
		end
		encima = true
		ir(1.05, 0.12)
	end)
	b.MouseLeave:Connect(function()
		encima = false
		ir(1, 0.12)
	end)
	b.MouseButton1Down:Connect(function()
		ir(0.9, 0.06)
	end)
	b.MouseButton1Up:Connect(soltar)
	b.InputEnded:Connect(function(input)
		local tipo = input.UserInputType
		if tipo == Enum.UserInputType.Touch or tipo == Enum.UserInputType.MouseButton1 then
			soltar()
		end
	end)
	b.Activated:Connect(function()
		Sonidos.tocar("Boton") -- SONIDO: tocar un botón
	end)
end

export type OpcionesBoton = {
	Texto: string?,
	Color: string?, -- nombre de Kit.Colores (Verde por defecto)
	Icono: string?, -- nombre de la hoja de íconos o "rbxassetid://..."
	Ancho: number,
	Alto: number,
	TamanoTexto: number?,
}

-- Botón gordo: pieza de su color (o la blanca teñida) con ícono y texto. Devuelve el botón y su
-- texto (para cambiarlo después).
function Kit.boton(o: OpcionesBoton): (TextButton, TextLabel?)
	local b = Instance.new("TextButton")
	b.Name = "Boton" .. (o.Texto or o.Icono or "")
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = UDim2.fromOffset(o.Ancho, o.Alto)
	local color = o.Color or "Verde"
	Kit.superficie(
		b,
		{ "Boton" .. color, "BotonBlanco" },
		Kit.Colores[color] or Kit.Colores.Verde,
		math.floor(o.Alto * 0.3),
		math.max(3, math.floor(o.Alto / 12))
	)
	local c = Kit.contenido(b, 6)
	if o.Icono then
		local ic = Kit.icono(o.Icono, math.floor(o.Alto * (if o.Texto then 0.66 else 0.8)))
		ic.LayoutOrder = 1
		ic.Parent = c
	end
	local etiqueta: TextLabel? = nil
	if o.Texto then
		local t = Kit.texto(o.Texto, o.TamanoTexto or math.floor(o.Alto * 0.42))
		t.Name = "Texto"
		t.LayoutOrder = 2
		t.Parent = c
		etiqueta = t
	end
	Kit.presionable(b)
	return b, etiqueta
end

-- Cambia el color de un botón de Kit.boton (por ejemplo, "Comprar" en gris si no alcanza).
function Kit.colorBoton(b: GuiObject, color: string)
	for _, hijo in b:GetChildren() do
		if
			hijo.Name == "Fondo"
			or hijo.Name == "Brillo"
			or hijo:IsA("UIGradient")
			or hijo:IsA("UIStroke")
			or hijo:IsA("UICorner")
		then
			hijo:Destroy()
		end
	end
	Kit.superficie(
		b,
		{ "Boton" .. color, "BotonBlanco" },
		Kit.Colores[color] or Kit.Colores.Verde,
		math.floor(b.Size.Y.Offset * 0.3),
		math.max(3, math.floor(b.Size.Y.Offset / 12))
	)
end

-- Borde blanco de "elegido".
function Kit.marcar(obj: GuiObject, si: boolean, radio: number)
	local marca = obj:FindFirstChild("Marca")
	local borde = if marca and marca:IsA("UIStroke")
		then marca
		else obj:FindFirstChildOfClass("UIStroke")
	if not borde then
		if not si then
			return
		end
		if not obj:FindFirstChildOfClass("UICorner") then
			Kit.esquinas(obj, radio)
		end
		local nuevo = Instance.new("UIStroke")
		nuevo.Name = "Marca"
		nuevo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		nuevo.Parent = obj
		borde = nuevo
	end
	local b = borde :: UIStroke
	if b.Name == "Marca" then
		b.Enabled = si
		b.Color = Color3.new(1, 1, 1)
		b.Thickness = 4
	else
		b.Color = if si then Color3.new(1, 1, 1) else Kit.Oscuro
	end
end

-- Marco dorado "Destacado" alrededor de `obj` (la reliquia legendaria).
function Kit.destacado(obj: GuiObject): ImageLabel?
	local p = Kit.pieza("MarcoDestacado")
	if not p then
		return nil
	end
	local img = imagen(p, obj)
	img.Name = "Destacado"
	img.ZIndex = 4
	img.Position = UDim2.fromOffset(-10, -10)
	img.Size = UDim2.new(1, 20, 1, 20)
	return img
end

-- X roja para cerrar ventanas.
function Kit.cerrar(tam: number): GuiButton
	local p = Kit.pieza("Cerrar")
	if p then
		local b = Instance.new("ImageButton")
		b.Name = "Cerrar"
		b.BackgroundTransparency = 1
		b.Size = UDim2.fromOffset(tam, tam)
		b.Image = p.Imagen
		b.ScaleType = Enum.ScaleType.Fit
		Kit.presionable(b)
		return b
	end
	local b = Kit.boton({ Texto = "X", Color = "Rojo", Ancho = tam, Alto = tam })
	b.Name = "Cerrar"
	return b
end

-- Barra de progreso. Devuelve el marco y poner(parte 0..1, texto?).
function Kit.barra(
	ancho: number,
	alto: number,
	colores: { string }
): (Frame, (parte: number, texto: string?) -> ())
	local marco = Instance.new("Frame")
	marco.Name = "Barra"
	marco.Size = UDim2.fromOffset(ancho, alto)
	Kit.superficie(marco, { "BarraFondo" }, { "#1B1F3B", "#2E3358" }, math.floor(alto / 2), 4, true)
	local relleno = Instance.new("Frame")
	relleno.Name = "Relleno"
	relleno.ZIndex = 1
	relleno.Position = UDim2.fromOffset(3, 3)
	relleno.Size = UDim2.new(0, alto, 1, -6)
	Kit.superficie(relleno, { "BarraRelleno" }, colores, math.floor(alto / 2) - 3, 0)
	relleno.Parent = marco
	local texto = Kit.texto("", math.floor(alto * 0.6))
	texto.AnchorPoint = Vector2.new(0.5, 0.5)
	texto.Position = UDim2.fromScale(0.5, 0.5)
	texto.ZIndex = 3
	texto.Parent = marco
	local function poner(parte: number, t: string?)
		parte = math.clamp(if parte == parte then parte else 0, 0, 1)
		relleno.Visible = parte > 0
		TweenService:Create(relleno, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, math.max(alto - 6, math.floor((ancho - 6) * parte)), 1, -6),
		}):Play()
		texto.Text = t or ""
	end
	return marco, poner
end

-- Píldora del HUD (vida, oro, pelea): ícono grande que sobresale a la izquierda y el número.
function Kit.pildora(
	icono: string,
	colores: { string },
	ancho: number,
	alto: number
): (Frame, TextLabel)
	local f = Instance.new("Frame")
	f.Name = "Pildora"
	f.Size = UDim2.fromOffset(ancho, alto)
	Kit.superficie(f, { "Pildora" }, colores, math.floor(alto / 2), 4)
	local ic = Kit.icono(icono, math.floor(alto * 1.25))
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.new(0, math.floor(alto * 0.3), 0.5, 0)
	ic.ZIndex = 3
	ic.Parent = f
	local t = Kit.texto("0", math.floor(alto * 0.6))
	t.Name = "Texto"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.new(0.5, math.floor(alto * 0.4), 0.5, 0)
	t.ZIndex = 3
	t.Parent = f
	return f, t
end

-- Baldosa cuadrada (reliquias, cartas): pieza blanca teñida o degradé.
function Kit.baldosa(colores: { string }, tam: number): Frame
	local f = Instance.new("Frame")
	f.Name = "Baldosa"
	f.Size = UDim2.fromOffset(tam, tam)
	Kit.superficie(f, { "Baldosa" }, colores, math.floor(tam * 0.14), 4)
	return f
end

-- Etapa 12a: panel de Forja (borde celeste con brillo) con el centro oscuro "Noche", el clima de
-- la mazmorra (el Panel entero es celeste y queda pesado). Lo de adentro va encima (ZIndex 2).
function Kit.panel(obj: GuiObject, borde: number?)
	Kit.superficie(obj, { "Panel" }, Kit.Colores.Noche, 18, 5, true)
	local b = borde or 9
	local centro = Instance.new("Frame")
	centro.Name = "Centro"
	centro.Position = UDim2.fromOffset(b, b)
	centro.Size = UDim2.new(1, -2 * b, 1, -2 * b)
	centro.BackgroundColor3 = Color3.new(1, 1, 1)
	centro.BorderSizePixel = 0
	centro.ZIndex = 0
	Kit.esquinas(centro, 12)
	degradado(centro, hex(Kit.Colores.Noche))
	centro.Parent = obj
end

-- Globito rojo de aviso ("!" o un número) para la esquina de un botón.
function Kit.globito(texto: string, tam: number): Frame
	local f = Instance.new("Frame")
	f.Name = "Globito"
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(tam, tam)
	f.ZIndex = 5
	local p = Kit.pieza("Globito")
	if p then
		f.BackgroundTransparency = 1
		imagen(p, f)
	else
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(1, 0)
		esquina.Parent = f
		Kit.borde(f, 3)
		degradado(f, hex({ "#FF7A86", "#FF3B4E" }))
	end
	local t = Kit.texto(texto, math.floor(tam * 0.62), nil, 2)
	t.Name = "Texto"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromScale(0.5, 0.5)
	t.ZIndex = 6
	t.Parent = f
	return f
end

-- Rayas diagonales de luz (cabeceras y cintas).
function Kit.rayas(obj: GuiObject, opacidad: number?)
	local v = Instance.new("Frame")
	v.Name = "Rayas"
	v.BackgroundColor3 = Color3.new(1, 1, 1)
	v.BorderSizePixel = 0
	v.Size = UDim2.fromScale(1, 1)
	v.ZIndex = 1
	local op = 1 - (opacidad or 0.22)
	local puntos = { NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 1) }
	for i = 0, 3 do
		local x = 0.52 + i * 0.12
		local ancho = if i % 2 == 0 then 0.05 else 0.025
		table.insert(puntos, NumberSequenceKeypoint.new(x, 1))
		table.insert(puntos, NumberSequenceKeypoint.new(x + 0.001, op))
		table.insert(puntos, NumberSequenceKeypoint.new(x + ancho, op))
		table.insert(puntos, NumberSequenceKeypoint.new(x + ancho + 0.001, 1))
	end
	table.insert(puntos, NumberSequenceKeypoint.new(1, 1))
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new(puntos)
	g.Rotation = -25
	g.Parent = v
	local radio = obj:FindFirstChildOfClass("UICorner")
	if radio then
		radio:Clone().Parent = v
	else
		-- con pieza de imagen: que no pise el borde oscuro ni se salga de las esquinas
		v.Position = UDim2.fromOffset(5, 5)
		v.Size = UDim2.new(1, -10, 1, -10)
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0.3, 0)
		esquina.Parent = v
	end
	v.Parent = obj
end

-- Íconos ----------------------------------------------------------------------------------

-- Ícono por nombre de la hoja de Forja (Moneda, Engranaje, Tienda, Candado, Cofre, Corona,
-- Trofeo, Jefe, Libro...) o una imagen "rbxassetid://..." (los dibujos de Plinko). Si no hay
-- ninguna, una insignia redonda gris.
function Kit.icono(nombre: string, tamano: number): GuiObject
	local hoja = K.HojaIconos
	local lugar = hoja.Lugar[nombre]
	local propia = string.sub(nombre, 1, 13) == "rbxassetid://"
	if propia or (hoja.Imagen ~= "" and lugar) then
		local img = Instance.new("ImageLabel")
		img.Name = "Icono"
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromOffset(tamano, tamano)
		img.ScaleType = Enum.ScaleType.Fit
		if propia then
			img.Image = nombre
		else
			img.Image = hoja.Imagen
			img.ImageRectOffset = Vector2.new(lugar[1], lugar[2])
			img.ImageRectSize = Vector2.new(hoja.Celda, hoja.Celda)
		end
		return img
	end
	local f = Instance.new("Frame")
	f.Name = "Icono"
	f.Size = UDim2.fromOffset(tamano, tamano)
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(1, 0)
	esquina.Parent = f
	degradado(f, hex({ "#FFFFFF", "#8D939C" }))
	Kit.borde(f, math.max(2, tamano / 12))
	return f
end

-- Básicos ---------------------------------------------------------------------------------

function Kit.esquinas(obj: GuiObject, radio: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radio)
	c.Parent = obj
end

function Kit.borde(obj: GuiObject, grosor: number, color: Color3?)
	local s = Instance.new("UIStroke")
	s.Thickness = grosor
	s.Color = color or Kit.Oscuro
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
end

-- Texto blanco (o del color pedido) con contorno oscuro, fondo transparente.
function Kit.texto(texto: string, tamano: number, color: Color3?, grosor: number?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Kit.Fuente
	t.Text = texto
	t.TextSize = tamano
	t.TextColor3 = color or Kit.Blanco
	t.AutomaticSize = Enum.AutomaticSize.XY
	t.Size = UDim2.fromOffset(0, 0)
	local s = Instance.new("UIStroke")
	s.Thickness = grosor or math.max(2, tamano / 9)
	s.Color = Kit.Oscuro
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = t
	return t
end

-- Texto que se corta en varias líneas dentro de un ancho fijo.
function Kit.parrafo(texto: string, tamano: number, ancho: number, color: Color3?): TextLabel
	local t = Kit.texto(texto, tamano, color, math.max(1.5, tamano / 12))
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.Size = UDim2.fromOffset(ancho, 0)
	t.TextWrapped = true
	t.TextXAlignment = Enum.TextXAlignment.Left
	return t
end

-- Fila horizontal (sin fondo) con sus hijos centrados verticalmente.
function Kit.fila(espacio: number): Frame
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

-- Íconos + texto en fila.
function Kit.conIconos(iconos: { string }, texto: string, tamano: number, color: Color3?): Frame
	local f = Kit.fila(4)
	for i, nombre in iconos do
		local ic = Kit.icono(nombre, math.floor(tamano * 1.1))
		ic.LayoutOrder = i
		ic.Parent = f
	end
	local t = Kit.texto(texto, tamano, color)
	t.LayoutOrder = #iconos + 1
	t.Parent = f
	return f
end

function Kit.pantalla(nombre: string, orden: number): ScreenGui
	local g = Instance.new("ScreenGui")
	g.Name = nombre
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = orden
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return g
end

-- Achica o agranda `obj` según la pantalla (medidas para Config.Kit.Diseno, 1280 × 720). Escala
-- alrededor de su AnchorPoint.
function Kit.escalar(obj: GuiObject, extra: number?)
	local s = Instance.new("UIScale")
	s.Parent = obj
	local conexion: RBXScriptConnection? = nil
	local function actualizar()
		local cam = Workspace.CurrentCamera
		local v = if cam then cam.ViewportSize else Vector2.new(K.Diseno[1], K.Diseno[2])
		s.Scale = math.clamp(math.min(v.X / K.Diseno[1], v.Y / K.Diseno[2]), 0.55, 1.2)
			* (extra or 1)
	end
	local function seguirCamara()
		if conexion then
			conexion:Disconnect()
		end
		local cam = Workspace.CurrentCamera
		if cam then
			conexion = cam:GetPropertyChangedSignal("ViewportSize"):Connect(actualizar)
		end
		actualizar()
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(seguirCamara)
	seguirCamara()
end

return Kit
