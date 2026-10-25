--!strict
-- Estilo de la UI de Forja Rápida (como las capturas de referencia y el diseño de Figma):
-- letra redonda y gorda, texto blanco con contorno oscuro, botones gordos con brillo, degradés.
-- Las piezas (botones, ventanas, barras, marcos e íconos) son imágenes hechas con ForgeGUI
-- (GameConfig.Gui y GameConfig.Iconos). Mientras una pieza no esté subida, se dibuja con
-- degradé, borde y brillo, así todo anda igual. Nunca emojis.
--
-- Ojo al armar cosas con estas piezas: el fondo y el brillo son hijos del objeto, así que los
-- UIListLayout van dentro de un "Contenido" (Estilo.contenido), no directo en el botón.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Sonidos = require(script.Parent.Sonidos)

local Estilo = {}

Estilo.Fuente = Enum.Font.FredokaOne
Estilo.Oscuro = Color3.fromHex("#1B1F3B")
Estilo.Blanco = Color3.new(1, 1, 1)
Estilo.Verde = Color3.fromHex("#7CFF3C")
Estilo.VerdeOscuro = Color3.fromHex("#2DBA2D")

-- Colores de botones, cabeceras y píldoras (arriba, abajo).
Estilo.Colores = {
	Verde = { "#8CFF5A", "#1FA33A" },
	Amarillo = { "#FFE45C", "#F59E00" },
	Azul = { "#6CCBFF", "#1673E0" },
	Rojo = { "#FF7A86", "#D11F3A" },
	Violeta = { "#C99BFF", "#6E22D6" },
	Rosa = { "#FF9ED8", "#E0308F" },
	Gris = { "#D5DAE1", "#8D939C" },
	Naranja = { "#FFB04D", "#E8590C" },
	Cian = { "#9CFBFF", "#14B8D9" },
	Oscuro = { "#353B63", "#1E2240" },
	Noche = { "#2E3358", "#1E2240" },
}

-- Colores de cada rareza para baldosas y textos (claro, oscuro).
Estilo.Rarezas = {
	Comun = { "#E3E8F2", "#8D939C" },
	Raro = { "#8FD3FF", "#1673E0" },
	Epico = { "#D9A8FF", "#7A2FE0" },
	Legendario = { "#FFE45C", "#E8890C" },
	Mitico = { "#FF9ED8", "#9B4DFF" },
	Celestial = { "#F2FFFF", "#2EC8FF" },
}

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
	Tienda = { "#B8FF6A", "#1FA33A" },
	Mochila = { "#FFC27A", "#C0661E" },
	Libro = { "#FF9ED8", "#B0206F" },
	Engranaje = { "#E3E8F2", "#6E7487" },
	Banco = { "#FFF3B0", "#C99A12" },
	Pico = { "#D8DEE6", "#7A8494" },
	Candado = { "#FFE07A", "#C98A00" },
	Amuleto = { "#B8FF6A", "#E8A317" },
	Mascota = { "#FFC2E6", "#E0308F" },
	Mision = { "#B8FF6A", "#1C7FE0" },
	Renacer = { "#FFF3B0", "#FF6A3D" },
	Esencia = { "#FFE45C", "#C2185B" },
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

local function hex(lista: { string }): { Color3 }
	local r = {}
	for _, h in lista do
		table.insert(r, Color3.fromHex(h))
	end
	return r
end

-- Degradé de colores (hex) para un texto o un marco (los títulos, "¡MÍTICO!", etc.).
function Estilo.degradado(obj: GuiObject, colores: { string }, rotacion: number?): UIGradient
	if obj:IsA("TextLabel") then
		obj.TextColor3 = Color3.new(1, 1, 1) -- el degradé tiñe el blanco
	end
	return degradado(obj, hex(colores), rotacion)
end

-- Piezas de ForgeGUI ------------------------------------------------------------------------

-- La pieza si ya está subida (si no, nil y se usa el dibujo de respaldo).
function Estilo.pieza(nombre: string): GameConfig.PiezaGui?
	local p = GameConfig.Gui[nombre]
	if p and p.Imagen ~= "" then
		return p
	end
	return nil
end

-- Escala acumulada de los UIScale de los ancestros (el HUD se achica en celular).
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

-- ImageLabel de la pieza, del tamaño de `obj` y detrás de todo lo demás. Con 9-slice, las
-- esquinas van en proporción al alto en pantalla (botones, barras) o fijas con Escala
-- (ventanas y baldosas), achicadas junto con el HUD.
local function imagen(p: GameConfig.PiezaGui, obj: GuiObject): ImageLabel
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
		local function ajustar()
			if p.Escala then
				img.SliceScale = p.Escala * escalaDe(obj)
			else
				local alto = obj.AbsoluteSize.Y
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
	Estilo.esquinas(b, math.max(4, radio - 3))
	b.Parent = obj
end

-- Pinta el fondo de `obj`: con la primera pieza de `piezas` que esté subida (si es blanca, se
-- tiñe con `colores`) o, si ninguna está, con degradé, borde oscuro y brillo.
function Estilo.superficie(
	obj: GuiObject,
	piezas: { string },
	colores: { string },
	radio: number,
	grosor: number?,
	sinBrillo: boolean?
)
	for _, nombre in piezas do
		local p = Estilo.pieza(nombre)
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
	Estilo.esquinas(obj, radio)
	if (grosor or 4) > 0 then
		Estilo.borde(obj, grosor or 4)
	end
	degradado(obj, hex(colores))
	if not sinBrillo then
		brillo(obj, radio)
	end
end

-- Marco transparente que ocupa todo `padre`, con una fila o columna centrada adentro.
function Estilo.contenido(padre: GuiObject, espacio: number, vertical: boolean?): Frame
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

-- Se achica al apretarlo y crece un poco al pasar el mouse (se siente "jugoso").
function Estilo.presionable(b: GuiButton)
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
	-- si se suelta fuera del botón (dedo que se desliza), MouseButton1Up no llega
	b.InputEnded:Connect(function(input)
		local tipo = input.UserInputType
		if tipo == Enum.UserInputType.Touch or tipo == Enum.UserInputType.MouseButton1 then
			soltar()
		end
	end)
	b.Activated:Connect(function()
		-- SONIDO: tocar un botón
		Sonidos.tocar(GameConfig.Sonidos.Click, 1 + math.random() * 0.1)
	end)
end

export type OpcionesBoton = {
	Texto: string?,
	Color: string?, -- nombre de Estilo.Colores (Verde por defecto)
	Icono: string?, -- nombre de GameConfig.Iconos
	Ancho: number,
	Alto: number,
	TamanoTexto: number?,
}

-- Botón gordo: pieza de ForgeGUI de su color (o la blanca teñida) con ícono y texto.
-- Devuelve el botón y su texto (para cambiarlo después).
function Estilo.boton(o: OpcionesBoton): (TextButton, TextLabel?)
	local b = Instance.new("TextButton")
	b.Name = "Boton" .. (o.Texto or o.Icono or "")
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = UDim2.fromOffset(o.Ancho, o.Alto)
	local color = o.Color or "Verde"
	Estilo.superficie(
		b,
		{ "Boton" .. color, "BotonBlanco" },
		Estilo.Colores[color] or Estilo.Colores.Verde,
		math.floor(o.Alto * 0.3),
		math.max(3, math.floor(o.Alto / 12))
	)
	local c = Estilo.contenido(b, 6)
	if o.Icono then
		local ic = Estilo.icono(o.Icono, math.floor(o.Alto * (if o.Texto then 0.66 else 0.8)))
		ic.LayoutOrder = 1
		ic.Parent = c
	end
	local etiqueta: TextLabel? = nil
	if o.Texto then
		local t = Estilo.texto(o.Texto, o.TamanoTexto or math.floor(o.Alto * 0.42))
		t.Name = "Texto"
		t.LayoutOrder = 2
		t.Parent = c
		etiqueta = t
	end
	Estilo.presionable(b)
	return b, etiqueta
end

-- Cambia el color de un botón hecho con Estilo.boton (por ejemplo, "Comprar" en gris si no
-- alcanza). Rehace solo el fondo.
function Estilo.colorBoton(b: GuiObject, color: string)
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
	Estilo.superficie(
		b,
		{ "Boton" .. color, "BotonBlanco" },
		Estilo.Colores[color] or Estilo.Colores.Verde,
		math.floor(b.Size.Y.Offset * 0.3),
		math.max(3, math.floor(b.Size.Y.Offset / 12))
	)
end

-- Borde blanco de "elegido" (el menú abierto, la gema de la vitrina). Sirve igual si el
-- objeto tiene pieza de imagen (le agrega su propio borde) o está dibujado (usa el suyo).
function Estilo.marcar(obj: GuiObject, si: boolean, radio: number)
	local marca = obj:FindFirstChild("Marca")
	local borde = if marca and marca:IsA("UIStroke")
		then marca
		else obj:FindFirstChildOfClass("UIStroke")
	if not borde then
		if not si then
			return
		end
		if not obj:FindFirstChildOfClass("UICorner") then
			Estilo.esquinas(obj, radio)
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
		b.Color = if si then Color3.new(1, 1, 1) else Estilo.Oscuro
	end
end

-- X roja para cerrar ventanas.
function Estilo.cerrar(tam: number): GuiButton
	local p = Estilo.pieza("Cerrar")
	if p then
		local b = Instance.new("ImageButton")
		b.Name = "Cerrar"
		b.BackgroundTransparency = 1
		b.Size = UDim2.fromOffset(tam, tam)
		b.Image = p.Imagen
		b.ScaleType = Enum.ScaleType.Fit
		Estilo.presionable(b)
		return b
	end
	local b = Estilo.boton({ Texto = "X", Color = "Rojo", Ancho = tam, Alto = tam })
	b.Name = "Cerrar"
	return b
end

-- Barra de progreso. Devuelve el marco y una función poner(parte 0..1, texto?).
function Estilo.barra(
	ancho: number,
	alto: number,
	colores: { string }
): (Frame, (parte: number, texto: string?) -> ())
	local marco = Instance.new("Frame")
	marco.Name = "Barra"
	marco.Size = UDim2.fromOffset(ancho, alto)
	Estilo.superficie(
		marco,
		{ "BarraFondo" },
		{ "#1B1F3B", "#2E3358" },
		math.floor(alto / 2),
		4,
		true
	)
	local relleno = Instance.new("Frame")
	relleno.Name = "Relleno"
	relleno.ZIndex = 1
	relleno.Position = UDim2.fromOffset(3, 3)
	relleno.Size = UDim2.new(0, alto, 1, -6)
	Estilo.superficie(relleno, { "BarraRelleno" }, colores, math.floor(alto / 2) - 3, 0)
	relleno.Parent = marco
	local texto = Estilo.texto("", math.floor(alto * 0.6))
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

-- Píldora del HUD (monedas, suerte, fuerza): ícono grande que sobresale a la izquierda y el
-- número. Devuelve el marco y el texto.
function Estilo.pildora(
	icono: string,
	colores: { string },
	ancho: number,
	alto: number
): (Frame, TextLabel)
	local f = Instance.new("Frame")
	f.Name = "Pildora" .. icono
	f.Size = UDim2.fromOffset(ancho, alto)
	Estilo.superficie(f, { "Pildora" }, colores, math.floor(alto / 2), 4)
	local ic = Estilo.icono(icono, math.floor(alto * 1.25))
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.new(0, math.floor(alto * 0.3), 0.5, 0)
	ic.ZIndex = 3
	ic.Parent = f
	local t = Estilo.texto("0", math.floor(alto * 0.6))
	t.Name = "Texto"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.new(0.5, math.floor(alto * 0.4), 0.5, 0)
	t.ZIndex = 3
	t.Parent = f
	return f, t
end

-- Baldosa cuadrada (gemas, picos, títulos): pieza blanca teñida o degradé.
function Estilo.baldosa(colores: { string }, tam: number): Frame
	local f = Instance.new("Frame")
	f.Name = "Baldosa"
	f.Size = UDim2.fromOffset(tam, tam)
	Estilo.superficie(f, { "Baldosa" }, colores, math.floor(tam * 0.14), 4)
	return f
end

-- Una gema dibujada (rombo con brillo) del color pedido; para las 25 gemas del juego.
function Estilo.gema(color: string, tam: number): Frame
	local caja = Instance.new("Frame")
	caja.Name = "Gema"
	caja.BackgroundTransparency = 1
	caja.Size = UDim2.fromOffset(tam, tam)
	local r = Instance.new("Frame")
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.fromScale(0.5, 0.5)
	r.Size = UDim2.fromScale(0.62, 0.62)
	r.Rotation = 45
	r.BackgroundColor3 = Color3.new(1, 1, 1)
	local c = Color3.fromHex(color)
	degradado(r, { c:Lerp(Color3.new(1, 1, 1), 0.45), c, c:Lerp(Color3.new(0, 0, 0), 0.35) }, 45)
	Estilo.esquinas(r, math.floor(tam * 0.08))
	Estilo.borde(r, math.max(2, math.floor(tam / 16)))
	r.Parent = caja
	local destello = Instance.new("Frame")
	destello.AnchorPoint = Vector2.new(0.5, 0.5)
	destello.Position = UDim2.fromScale(0.36, 0.34)
	destello.Size = UDim2.fromScale(0.14, 0.14)
	destello.Rotation = 45
	destello.BackgroundColor3 = Color3.new(1, 1, 1)
	destello.BorderSizePixel = 0
	destello.Parent = caja
	return caja
end

-- Dibujo de una gema del Índice: su ícono (GameConfig.IconosGemas, render de Blender) si ya
-- está subido; si no, el rombo de su color. Si no la conocés, se ve la silueta oscura.
function Estilo.dibujoGema(g: GameConfig.Gema, tam: number, conocida: boolean): GuiObject
	local id = (GameConfig.IconosGemas :: { [string]: string })[g.Id]
	if not id or id == "" then
		return Estilo.gema(if conocida then g.Color else "#0E1230", tam)
	end
	local img = Instance.new("ImageLabel")
	img.Name = "Gema"
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromOffset(tam, tam)
	img.Image = id
	img.ScaleType = Enum.ScaleType.Fit
	img.ImageColor3 = if conocida then Color3.new(1, 1, 1) else Color3.fromHex("#0E1230")
	return img
end

-- Globito rojo de aviso ("!" o un número) para la esquina de un botón.
function Estilo.globito(texto: string, tam: number): Frame
	local f = Instance.new("Frame")
	f.Name = "Globito"
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(tam, tam)
	f.ZIndex = 5
	local p = Estilo.pieza("Globito")
	if p then
		f.BackgroundTransparency = 1
		imagen(p, f)
	else
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(1, 0)
		esquina.Parent = f
		Estilo.borde(f, 3)
		degradado(f, hex({ "#FF7A86", "#FF3B4E" }))
	end
	local t = Estilo.texto(texto, math.floor(tam * 0.62), nil, 2)
	t.Name = "Texto"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromScale(0.5, 0.5)
	t.ZIndex = 6
	t.Parent = f
	return f
end

-- Rayas diagonales de luz (cabeceras y carteles, como las capturas): un velo blanco con un
-- degradé de transparencia a franjas, sobre la mitad derecha.
function Estilo.rayas(obj: GuiObject, opacidad: number?)
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

-- Ícono por nombre (ver GameConfig.Iconos). Devuelve un ImageLabel o la insignia de color.
-- Primero una imagen propia (GameConfig.Iconos), después la hoja de íconos (GameConfig.HojaIconos).
function Estilo.icono(nombre: string, tamano: number): GuiObject
	local id = (GameConfig.Iconos :: { [string]: string })[nombre]
	local hoja = GameConfig.HojaIconos
	local lugar = hoja.Lugar[nombre]
	if (id and id ~= "") or (hoja.Imagen ~= "" and lugar) then
		local img = Instance.new("ImageLabel")
		img.Name = "Icono" .. nombre
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromOffset(tamano, tamano)
		img.ScaleType = Enum.ScaleType.Fit
		if id and id ~= "" then
			img.Image = id
		else
			img.Image = hoja.Imagen
			img.ImageRectOffset = Vector2.new(lugar[1], lugar[2])
			img.ImageRectSize = Vector2.new(hoja.Celda, hoja.Celda)
		end
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
	local destello = Instance.new("Frame")
	destello.Size = UDim2.fromScale(0.28, 0.28)
	destello.Position = UDim2.fromScale(0.22, 0.18)
	destello.Rotation = 45
	destello.BackgroundColor3 = Color3.new(1, 1, 1)
	destello.BackgroundTransparency = 0.25
	destello.BorderSizePixel = 0
	destello.Parent = f
	return f
end

-- Íconos de un modificador (una combinación tiene dos).
function Estilo.iconosModificador(modificador: string): { string }
	return Reglas.partes(modificador)
end

-- Básicos ---------------------------------------------------------------------------------

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

-- Texto que se corta en varias líneas dentro de un ancho fijo.
function Estilo.parrafo(texto: string, tamano: number, ancho: number, color: Color3?): TextLabel
	local t = Estilo.texto(texto, tamano, color, math.max(1.5, tamano / 12))
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.Size = UDim2.fromOffset(ancho, 0)
	t.TextWrapped = true
	t.TextXAlignment = Enum.TextXAlignment.Left
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

-- Achica o agranda `obj` según la pantalla (diseñado para 1280×720; en celular queda más
-- chico). Escala alrededor de su AnchorPoint, así lo anclado a una esquina queda en su esquina.
function Estilo.escalar(obj: GuiObject, extra: number?)
	local s = Instance.new("UIScale")
	s.Parent = obj
	local conexion: RBXScriptConnection? = nil
	local function actualizar()
		local cam = Workspace.CurrentCamera
		local v = if cam then cam.ViewportSize else Vector2.new(1280, 720)
		s.Scale = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.55, 1.2) * (extra or 1)
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

-- Carteles del mundo -----------------------------------------------------------------------
-- Tres niveles, para que se lea qué importa y no se encimen:
--   Geoda  chico: nombre blanco y debajo la rareza en su color; solo de cerca.
--   Jefe   grande: ícono (calavera o estrella), nombre y barra de vida o contador; de lejos.
--   Lugar  mediano: ícono y nombre (Banco, Tienda, portones...); siempre visible en el lobby.
-- Cada nivel va a otra altura y con otro alcance, así no se pisan.

Estilo.Carteles = {
	Geoda = { Distancia = 50, Nombre = 28, Rareza = 22, Barra = { 150, 12 } },
	Jefe = { Distancia = 120, Nombre = 36, Icono = 44, Barra = { 280, 26 } },
	Lugar = { Distancia = 110, Nombre = 26, Icono = 34, Detalle = 20 },
}

local function cartelBase(
	adornee: Instance,
	alto: number,
	ancho: number,
	altoPx: number,
	distancia: number
)
	local b = Instance.new("BillboardGui")
	b.Name = "Cartel"
	b.Adornee = adornee
	b.Size = UDim2.fromOffset(ancho, altoPx)
	if adornee:IsA("Model") then
		-- arriba de todo el modelo (aunque crezca o sobresalgan cristales), con la base del
		-- cartel apoyada ahí: el centro sube media altura del cartel
		b.ExtentsOffsetWorldSpace = Vector3.new(0, 1, 0)
		b.SizeOffset = Vector2.new(0, 0.5)
	end
	b.StudsOffsetWorldSpace = Vector3.new(0, alto, 0)
	b.MaxDistance = distancia
	b.LightInfluence = 0
	local lista = Instance.new("UIListLayout")
	lista.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lista.VerticalAlignment = Enum.VerticalAlignment.Bottom
	lista.SortOrder = Enum.SortOrder.LayoutOrder
	lista.Padding = UDim.new(0, 1)
	lista.Parent = b
	return b
end

-- Barra con relleno verde y texto encima (vida o contador).
local function barraCartel(
	ancho: number,
	alto: number,
	color: { string }?
): (Frame, Frame, TextLabel)
	local barra = Instance.new("Frame")
	barra.Size = UDim2.fromOffset(ancho, alto)
	barra.BackgroundColor3 = Estilo.Oscuro
	Estilo.esquinas(barra, alto // 2)
	Estilo.borde(barra, 2)
	local relleno = Instance.new("Frame")
	relleno.Name = "Relleno"
	relleno.Size = UDim2.fromScale(1, 1)
	relleno.BackgroundColor3 = Color3.new(1, 1, 1)
	Estilo.esquinas(relleno, alto // 2)
	local c = color or { "#7CFF3C", "#2DBA2D" }
	degradado(relleno, { Color3.fromHex(c[1]), Color3.fromHex(c[2]) })
	relleno.Parent = barra
	local texto = Estilo.texto("", math.max(11, alto - 6))
	texto.AnchorPoint = Vector2.new(0.5, 0.5)
	texto.Position = UDim2.fromScale(0.5, 0.5)
	texto.ZIndex = 2
	texto.Parent = barra
	return barra, relleno, texto
end

-- Geoda: nombre y rareza (con los íconos del modificador si es exótica) y una barrita de vida.
function Estilo.cartelGeoda(
	adornee: Instance,
	alto: number,
	nombre: string,
	rareza: string,
	colorRareza: Color3,
	iconos: { string }?
): (BillboardGui, Frame, TextLabel)
	local c = Estilo.Carteles.Geoda
	local b = cartelBase(adornee, alto, 320, 74, c.Distancia)
	b.Name = "CartelGeoda"
	local n = Estilo.texto(nombre, c.Nombre)
	n.LayoutOrder = 1
	n.Parent = b
	local r = if iconos and #iconos > 0
		then Estilo.conIconos(iconos, rareza, c.Rareza, colorRareza)
		else Estilo.texto(rareza, c.Rareza, colorRareza)
	r.LayoutOrder = 2
	r.Parent = b
	local barra, relleno, texto = barraCartel(c.Barra[1], c.Barra[2])
	barra.LayoutOrder = 3
	barra.Parent = b
	texto.Visible = false -- tan chica no se lee: alcanza con el relleno
	return b, relleno, texto
end

-- Jefe o evento: ícono grande + nombre, y debajo la barra (vida o contador).
function Estilo.cartelJefe(
	adornee: Instance,
	alto: number,
	nombre: string,
	icono: string,
	color: Color3?
): (BillboardGui, Frame, TextLabel)
	local c = Estilo.Carteles.Jefe
	local b = cartelBase(adornee, alto, 420, 84, c.Distancia)
	b.Name = "CartelJefe"
	local fila = Estilo.fila(6)
	fila.LayoutOrder = 1
	fila.Parent = b
	local ic = Estilo.icono(icono, c.Icono)
	ic.LayoutOrder = 1
	ic.Parent = fila
	local n = Estilo.texto(nombre, c.Nombre, color)
	n.LayoutOrder = 2
	n.Parent = fila
	local barra, relleno, texto = barraCartel(c.Barra[1], c.Barra[2], { "#FF7A86", "#D11F3A" })
	barra.LayoutOrder = 2
	barra.Parent = b
	return b, relleno, texto
end

-- Lugar: ícono + nombre, mediano, visible desde todo el lobby. `detalle` es una segunda línea
-- más chica (ej.: lo que pide un portón), con su propio ícono.
function Estilo.cartelLugar(
	adornee: BasePart,
	alto: number,
	nombre: string,
	icono: string?,
	color: Color3?,
	detalle: string?,
	iconoDetalle: string?
): BillboardGui
	local c = Estilo.Carteles.Lugar
	local b = cartelBase(adornee, alto, 460, if detalle then 76 else 44, c.Distancia)
	b.Name = "CartelLugar"
	b.AlwaysOnTop = true -- que no lo tape el techo del puesto
	local f = if icono
		then Estilo.conIconos({ icono }, nombre, c.Nombre, color)
		else Estilo.texto(nombre, c.Nombre, color)
	f.LayoutOrder = 1
	f.Parent = b
	if detalle then
		local d = if iconoDetalle
			then Estilo.conIconos({ iconoDetalle }, detalle, c.Detalle)
			else Estilo.texto(detalle, c.Detalle)
		d.LayoutOrder = 2
		d.Parent = b
	end
	return b
end

return Estilo
