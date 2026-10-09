--!strict
-- Componentes de interfaz de Mutant Lab. Toda la interfaz se arma por código con estas piezas,
-- así todas comparten radio de esquina, contorno, sombra, tipografía y tamaños (Tema.luau),
-- y los colores salen solo de Paleta.luau.
--
-- Piezas: ventana, tarjeta, botón (principal, secundario, peligro, dorado), botón de cerrar,
-- pestañas, contador con ícono, barra de progreso, casillero de criatura, notificación y
-- cartel grande. Más chicas: texto, puntos de generación y punto de elemento.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local Vista = require(script.Parent.Vista)
local Iconos = require(script.Iconos)
local Pantalla = require(script.Pantalla)
local Tema = require(script.Tema)

local UI = {}
UI.Tema = Tema
UI.Iconos = Iconos
UI.Pantalla = Pantalla

---------------------------------------------------------------------------
-- Ayudas
---------------------------------------------------------------------------

function UI.esquina(padre: Instance, radio: number?): UICorner
	local e = Instance.new("UICorner")
	e.CornerRadius = UDim.new(0, radio or Tema.Radio)
	e.Parent = padre
	return e
end

function UI.redondo(padre: Instance): UICorner
	local e = Instance.new("UICorner")
	e.CornerRadius = UDim.new(0.5, 0)
	e.Parent = padre
	return e
end

-- Contorno de un marco o botón (no del texto).
function UI.contorno(padre: Instance, color: Color3?, grosor: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = color or Paleta.Contorno
	s.Thickness = grosor or Tema.Contorno
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = padre
	return s
end

function UI.relleno(padre: Instance, n: number?)
	local p = Instance.new("UIPadding")
	local r = UDim.new(0, n or Tema.Relleno)
	p.PaddingTop, p.PaddingBottom, p.PaddingLeft, p.PaddingRight = r, r, r, r
	p.Parent = padre
end

function UI.lista(
	padre: Instance,
	horizontal: boolean,
	separacion: number?,
	centrado: boolean?
): UIListLayout
	local l = Instance.new("UIListLayout")
	l.FillDirection = if horizontal
		then Enum.FillDirection.Horizontal
		else Enum.FillDirection.Vertical
	l.Padding = UDim.new(0, separacion or Tema.Separacion)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	if centrado then
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		l.VerticalAlignment = Enum.VerticalAlignment.Center
	end
	l.Parent = padre
	return l
end

-- Un marco vacío y transparente (para acomodar cosas).
function UI.hueco(nombre: string, medida: UDim2, padre: Instance?): Frame
	local f = Instance.new("Frame")
	f.Name = nombre
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.Size = medida
	f.Parent = padre
	return f
end

local function animar(objeto: Instance, info: TweenInfo, metas: { [string]: any }): Tween
	local t = TweenService:Create(objeto, info, metas)
	t:Play()
	return t
end
UI.animar = animar

---------------------------------------------------------------------------
-- Texto
---------------------------------------------------------------------------

export type OpcionesTexto = {
	Texto: string?,
	Letra: number?, -- tamaño de letra en puntos
	Fuente: string?, -- "titulo" (Fredoka One, por defecto), "texto" o "fuerte" (Builder Sans)
	Color: Color3?,
	AlineacionX: Enum.TextXAlignment?,
	Medida: UDim2?,
	Contorno: boolean?, -- contorno oscuro (por defecto sí)
	Nombre: string?,
}

function UI.texto(op: OpcionesTexto): TextLabel
	local letra = op.Letra or Tema.Letra.Normal
	local t = Instance.new("TextLabel")
	t.Name = op.Nombre or "Texto"
	t.BackgroundTransparency = 1
	t.TextSize = letra
	t.FontFace = if op.Fuente == "texto"
		then Tema.Fuentes.Texto
		elseif op.Fuente == "fuerte" then Tema.Fuentes.TextoFuerte
		else Tema.Fuentes.Titulo
	t.TextColor3 = op.Color or Paleta.Texto
	t.Text = op.Texto or ""
	t.TextWrapped = true
	t.TextXAlignment = op.AlineacionX or Enum.TextXAlignment.Center
	t.Size = op.Medida or UDim2.new(1, 0, 0, math.ceil(letra * 1.2))
	if op.Contorno ~= false then
		local s = Instance.new("UIStroke")
		s.Color = Paleta.Contorno
		s.Thickness = if op.Fuente == "texto" or op.Fuente == "fuerte"
			then 1.5
			else Tema.ContornoTexto
		s.LineJoinMode = Enum.LineJoinMode.Round
		s.Parent = t
	end
	return t
end

---------------------------------------------------------------------------
-- Caja: la base de ventanas, tarjetas, casilleros y avisos (sombra + fondo + contorno)
---------------------------------------------------------------------------

export type Caja = {
	Marco: Frame, -- transparente; se le pone tamaño y posición
	Fondo: GuiObject, -- lo que se ve; el contenido va acá adentro
	Borde: UIStroke,
}

export type OpcionesCaja = {
	Color: Color3?,
	Transparencia: number?,
	Borde: Color3?,
	Grosor: number?,
	Boton: boolean?, -- el fondo es un TextButton (para tarjetas que se tocan)
	Radio: number?,
	Sombra: boolean?, -- por defecto sí
	Nombre: string?,
}

function UI.caja(op: OpcionesCaja): Caja
	local marco = UI.hueco(op.Nombre or "Caja", UDim2.fromOffset(200, 200))
	local radio = op.Radio or Tema.Radio
	if op.Sombra ~= false then
		local sombra = Instance.new("Frame")
		sombra.Name = "Sombra"
		sombra.Size = UDim2.fromScale(1, 1)
		sombra.Position = UDim2.fromOffset(0, Tema.Sombra)
		sombra.BackgroundColor3 = Paleta.Contorno
		sombra.BackgroundTransparency = 0.45
		sombra.BorderSizePixel = 0
		UI.esquina(sombra, radio)
		sombra.Parent = marco
	end
	local fondo: GuiObject
	if op.Boton then
		local b = Instance.new("TextButton")
		b.Text = ""
		b.AutoButtonColor = false
		fondo = b
	else
		fondo = Instance.new("Frame")
	end
	fondo.Name = "Fondo"
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = op.Color or Paleta.SuperficieElevada
	fondo.BackgroundTransparency = op.Transparencia or 0
	fondo.BorderSizePixel = 0
	fondo.Active = true -- no deja pasar los toques a lo que está detrás
	UI.esquina(fondo, radio)
	local borde = UI.contorno(fondo, op.Borde, op.Grosor)
	fondo.Parent = marco
	return { Marco = marco, Fondo = fondo, Borde = borde }
end

---------------------------------------------------------------------------
-- Tarjeta
---------------------------------------------------------------------------

export type Tarjeta = Caja

function UI.tarjeta(op: OpcionesCaja?): Tarjeta
	local o = op or {}
	return UI.caja({
		Color = o.Color or Paleta.SuperficieElevada,
		Transparencia = o.Transparencia,
		Borde = o.Borde,
		Grosor = o.Grosor,
		Boton = o.Boton,
		Radio = o.Radio,
		Sombra = o.Sombra,
		Nombre = o.Nombre or "Tarjeta",
	})
end

-- Respuesta al tocar algo que no es un botón (tarjetas, casilleros): se hunde un poco y suena.
function UI.tocable(boton: GuiButton, alTocar: () -> (), achicar: GuiObject?)
	local quien = achicar or boton
	local escala = quien:FindFirstChild("Presion") :: UIScale?
	if not escala then
		local nueva = Instance.new("UIScale")
		nueva.Name = "Presion"
		nueva.Parent = quien
		escala = nueva
	end
	local e = escala :: UIScale
	boton.MouseButton1Down:Connect(function()
		animar(e, Tema.Rapida, { Scale = 0.94 })
	end)
	local function soltar()
		animar(e, Tema.Rebote, { Scale = 1 })
	end
	boton.MouseButton1Up:Connect(soltar)
	boton.MouseLeave:Connect(soltar)
	boton.Activated:Connect(function()
		Sonidos.boton()
		alTocar()
	end)
end

---------------------------------------------------------------------------
-- Botón (con franja oscura abajo que simula profundidad; al apretarlo se hunde)
---------------------------------------------------------------------------

export type OpcionesBoton = {
	Texto: string?,
	Sub: string?, -- segunda línea chica (por ejemplo el precio)
	Icono: string?,
	ColorIcono: Color3?,
	Tipo: string?, -- "principal" (verde ácido), "secundario", "peligro", "dorado", "plano"
	Color: Color3?, -- reemplaza el color del tipo
	Medida: UDim2?,
	Redondo: boolean?,
	Letra: number?,
	LetraSub: number?,
	AlTocar: (() -> ())?,
	Nombre: string?,
}

export type Boton = {
	Marco: Frame,
	Cara: TextButton,
	Base: Frame,
	Texto: TextLabel?,
	Sub: TextLabel?,
	Icono: Frame?,
	Habilitado: boolean,
	AlTocar: (() -> ())?,
	habilitar: (si: boolean) -> (),
	poner: (texto: string?, sub: string?) -> (),
	pintar: (color: Color3) -> (),
	colorSub: (color: Color3) -> (),
}

local COLOR_TIPO: { [string]: Color3 } = {
	principal = Paleta.Acento,
	secundario = Paleta.Metal,
	peligro = Paleta.Error,
	dorado = Paleta.Dorado,
	plano = Paleta.SuperficieElevada,
}

function UI.boton(op: OpcionesBoton): Boton
	local prof = Tema.Profundidad
	local marco = UI.hueco(op.Nombre or "Boton", op.Medida or UDim2.fromOffset(240, Tema.Toque))
	local color = op.Color or COLOR_TIPO[op.Tipo or "secundario"] or Paleta.Metal

	local base = Instance.new("Frame")
	base.Name = "Base"
	base.Size = UDim2.fromScale(1, 1)
	base.BorderSizePixel = 0
	base.Parent = marco

	local cara = Instance.new("TextButton")
	cara.Name = "Cara"
	cara.Text = ""
	cara.AutoButtonColor = false
	cara.BorderSizePixel = 0
	cara.Size = UDim2.new(1, 0, 1, -prof)
	cara.Parent = marco

	if op.Redondo then
		UI.redondo(base)
		UI.redondo(cara)
	else
		UI.esquina(base)
		UI.esquina(cara)
	end
	UI.contorno(base)
	UI.contorno(cara)

	-- Contenido: ícono a la izquierda y una o dos líneas de texto.
	local contenido = UI.hueco("Contenido", UDim2.new(1, -12, 1, -6), cara)
	contenido.AnchorPoint = Vector2.new(0.5, 0.5)
	contenido.Position = UDim2.fromScale(0.5, 0.5)
	UI.lista(contenido, true, 10, true)

	local icono: Frame? = nil
	if op.Icono then
		local alto = (marco.Size.Y.Offset - prof)
		local tam = if op.Texto then math.floor(alto * 0.5) else math.floor(alto * 0.56)
		local i = Iconos.crear(op.Icono, tam, op.ColorIcono or Paleta.Texto)
		i.LayoutOrder = 1
		i.Parent = contenido
		icono = i
	end

	local texto: TextLabel? = nil
	local sub: TextLabel? = nil
	if op.Texto or op.Sub then
		local columna = UI.hueco("Textos", UDim2.new(), contenido)
		columna.AutomaticSize = Enum.AutomaticSize.XY
		columna.LayoutOrder = 2
		UI.lista(columna, false, 0, true)
		local letra = op.Letra or Tema.Letra.Boton
		local t = UI.texto({
			Texto = op.Texto or "",
			Letra = letra,
			Medida = UDim2.fromOffset(0, math.ceil(letra * 1.1)),
		})
		t.AutomaticSize = Enum.AutomaticSize.X
		t.TextWrapped = false
		t.LayoutOrder = 1
		t.Visible = op.Texto ~= nil
		t.Parent = columna
		texto = t
		local letraSub = op.LetraSub or Tema.Letra.Chica
		local s = UI.texto({
			Texto = op.Sub or "",
			Letra = letraSub,
			Medida = UDim2.fromOffset(0, math.ceil(letraSub * 1.1)),
		})
		s.AutomaticSize = Enum.AutomaticSize.X
		s.TextWrapped = false
		s.LayoutOrder = 2
		s.Visible = op.Sub ~= nil
		s.Parent = columna
		sub = s
	end

	local b: Boton
	local function pintarCara()
		local c = if b.Habilitado then color else Paleta.Deshabilitado
		cara.BackgroundColor3 = c
		base.BackgroundColor3 = Paleta.oscuro(c, 0.45)
		if texto then
			texto.TextTransparency = if b.Habilitado then 0 else 0.2
		end
	end

	b = {
		Marco = marco,
		Cara = cara,
		Base = base,
		Texto = texto,
		Sub = sub,
		Icono = icono,
		Habilitado = true,
		AlTocar = op.AlTocar,
		habilitar = function(si: boolean)
			b.Habilitado = si
			pintarCara()
		end,
		poner = function(t: string?, s: string?)
			if texto then
				texto.Text = t or ""
				texto.Visible = t ~= nil
			end
			if sub then
				sub.Text = s or ""
				sub.Visible = s ~= nil
			end
		end,
		pintar = function(c: Color3)
			color = c
			pintarCara()
		end,
		colorSub = function(c: Color3)
			if sub then
				sub.TextColor3 = c
			end
		end,
	}
	pintarCara()

	-- Se hunde al apretarlo y vuelve al soltarlo.
	local function hundir(si: boolean)
		animar(cara, Tema.Rapida, {
			Position = UDim2.fromOffset(0, if si then math.floor(prof * 0.8) else 0),
		})
	end
	cara.MouseButton1Down:Connect(function()
		hundir(true)
	end)
	cara.MouseButton1Up:Connect(function()
		hundir(false)
	end)
	cara.MouseLeave:Connect(function()
		hundir(false)
	end)
	cara.Activated:Connect(function()
		if not b.Habilitado then
			Sonidos.botonApagado()
			return
		end
		Sonidos.boton()
		if b.AlTocar then
			b.AlTocar()
		end
	end)
	return b
end

-- Botón redondo de cerrar (X), siempre del tamaño mínimo de toque.
function UI.botonCerrar(alTocar: (() -> ())?): Boton
	return UI.boton({
		Nombre = "Cerrar",
		Icono = "cerrar",
		Tipo = "peligro",
		Redondo = true,
		Medida = UDim2.fromOffset(Tema.Toque, Tema.Toque),
		AlTocar = alTocar,
	})
end

---------------------------------------------------------------------------
-- Ventana
---------------------------------------------------------------------------

export type OpcionesVentana = {
	Titulo: string,
	Icono: string?,
	ColorIcono: Color3?,
	Ancho: number?, -- parte de la pantalla (0 a 1)
	Alto: number?,
	MaxAncho: number?, -- en puntos
	MaxAlto: number?,
	Nombre: string?,
}

export type Ventana = {
	Marco: Frame,
	Fondo: GuiObject,
	Encabezado: Frame,
	Titulo: TextLabel,
	Cuerpo: Frame,
	Cerrar: Boton,
	Escala: UIScale,
	Tamano: Vector2,
	alAcomodar: (fn: (Vector2) -> ()) -> (),
}

UI.AltoEncabezado = Tema.Toque + 24

function UI.ventana(op: OpcionesVentana): Ventana
	local c = UI.caja({
		Nombre = op.Nombre or "Ventana",
		Color = Paleta.Superficie,
		Transparencia = Tema.TransparenciaVentana,
		Grosor = Tema.Contorno + 1,
	})
	local marco = c.Marco
	marco.AnchorPoint = Vector2.new(0.5, 0.5)
	marco.Position = UDim2.fromScale(0.5, 0.5)
	marco.Visible = false
	local escala = Instance.new("UIScale")
	escala.Parent = marco

	local alto = UI.AltoEncabezado
	local encabezado = UI.hueco("Encabezado", UDim2.new(1, 0, 0, alto), c.Fondo)

	local x = Tema.Relleno
	if op.Icono then
		local circulo = Instance.new("Frame")
		circulo.Name = "Insignia"
		circulo.Size = UDim2.fromOffset(64, 64)
		circulo.AnchorPoint = Vector2.new(0, 0.5)
		circulo.Position = UDim2.new(0, x, 0.5, 0)
		circulo.BackgroundColor3 = Paleta.oscuro(op.ColorIcono or Paleta.Acento, 0.55)
		UI.redondo(circulo)
		UI.contorno(circulo)
		local i = Iconos.crear(op.Icono, 40, op.ColorIcono or Paleta.Acento)
		i.Parent = circulo
		circulo.Parent = encabezado
		x += 64 + Tema.Separacion
	end
	local titulo = UI.texto({
		Nombre = "Titulo",
		Texto = op.Titulo,
		Letra = Tema.Letra.Titulo,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(0, 420, 1, 0),
	})
	titulo.TextWrapped = false
	titulo.Position = UDim2.fromOffset(x, 0)
	titulo.Parent = encabezado

	local cerrar = UI.botonCerrar()
	cerrar.Marco.AnchorPoint = Vector2.new(1, 0.5)
	cerrar.Marco.Position = UDim2.new(1, -Tema.Relleno, 0.5, 0)
	cerrar.Marco.Parent = encabezado

	local cuerpo =
		UI.hueco("Cuerpo", UDim2.new(1, -Tema.Relleno * 2, 1, -alto - Tema.Relleno), c.Fondo)
	cuerpo.Position = UDim2.fromOffset(Tema.Relleno, alto)

	local avisos: { (Vector2) -> () } = {}
	local v: Ventana
	local function acomodar()
		local lienzo = Pantalla.lienzo()
		local w = math.min(lienzo.X * (op.Ancho or 0.9), op.MaxAncho or 1200)
		local h = math.min(lienzo.Y * (op.Alto or 0.9), op.MaxAlto or 800)
		marco.Size = UDim2.fromOffset(math.floor(w), math.floor(h))
		v.Tamano = Vector2.new(math.floor(w), math.floor(h))
		for _, fn in avisos do
			fn(v.Tamano)
		end
	end

	v = {
		Marco = marco,
		Fondo = c.Fondo,
		Encabezado = encabezado,
		Titulo = titulo,
		Cuerpo = cuerpo,
		Cerrar = cerrar,
		Escala = escala,
		Tamano = Vector2.zero,
		alAcomodar = function(fn: (Vector2) -> ())
			table.insert(avisos, fn)
			fn(v.Tamano)
		end,
	}
	acomodar()
	Pantalla.Cambio:Connect(acomodar)
	return v
end

---------------------------------------------------------------------------
-- Pestañas
---------------------------------------------------------------------------

export type DatosPestana = {
	Clave: string,
	Texto: string,
	Icono: string?,
	ColorIcono: Color3?,
}

export type Pestanas = {
	Marco: Frame,
	Botones: { [string]: Boton },
	Actual: string?,
	elegir: (clave: string) -> (),
}

function UI.pestanas(datos: { DatosPestana }, alCambiar: (string) -> ()): Pestanas
	local marco = UI.hueco("Pestanas", UDim2.new(1, 0, 0, Tema.Toque))
	UI.lista(marco, true, Tema.Separacion)
	local n = #datos
	local botones: { [string]: Boton } = {}
	local p: Pestanas
	p = {
		Marco = marco,
		Botones = botones,
		Actual = nil,
		elegir = function(clave: string)
			p.Actual = clave
			for k, b in botones do
				b.pintar(if k == clave then Paleta.Acento else Paleta.SuperficieClara)
			end
			alCambiar(clave)
		end,
	}
	for i, d in datos do
		local b = UI.boton({
			Nombre = d.Clave,
			Texto = d.Texto,
			Icono = d.Icono,
			ColorIcono = d.ColorIcono,
			Color = Paleta.SuperficieClara,
			Letra = Tema.Letra.Subtitulo,
			Medida = UDim2.new(1 / n, -Tema.Separacion * (n - 1) / n, 1, 0),
			AlTocar = function()
				p.elegir(d.Clave)
			end,
		})
		b.Marco.LayoutOrder = i
		b.Marco.Parent = marco
		botones[d.Clave] = b
	end
	return p
end

---------------------------------------------------------------------------
-- Contador con ícono (ADN del HUD, ADN de la tienda)
---------------------------------------------------------------------------

export type OpcionesContador = {
	Icono: string,
	Color: Color3,
	Texto: string?,
	Sub: string?,
	Ancho: number?,
	Alto: number?,
}

export type Contador = {
	Marco: Frame,
	Fondo: GuiObject,
	Valor: TextLabel,
	Sub: TextLabel?,
	Escala: UIScale,
	rebotar: (fuerza: number?) -> (),
}

function UI.contador(op: OpcionesContador): Contador
	local alto = op.Alto or 96
	local c = UI.caja({ Nombre = "Contador", Color = Paleta.Superficie, Transparencia = 0.05 })
	c.Marco.Size = UDim2.fromOffset(op.Ancho or 300, alto)
	local escala = Instance.new("UIScale")
	escala.Parent = c.Marco

	local lado = alto - 20
	local circulo = Instance.new("Frame")
	circulo.Name = "Insignia"
	circulo.Size = UDim2.fromOffset(lado, lado)
	circulo.AnchorPoint = Vector2.new(0, 0.5)
	circulo.Position = UDim2.new(0, 10, 0.5, 0)
	circulo.BackgroundColor3 = Paleta.oscuro(op.Color, 0.55)
	UI.redondo(circulo)
	UI.contorno(circulo, Paleta.Contorno, 2)
	Iconos.crear(op.Icono, math.floor(lado * 0.66), op.Color).Parent = circulo
	circulo.Parent = c.Fondo

	local x = lado + 22
	local conSub = op.Sub ~= nil
	local valor = UI.texto({
		Nombre = "Valor",
		Texto = op.Texto or "0",
		Letra = Tema.Letra.Numero,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -x - 12, 0, if conSub then alto * 0.56 else alto),
	})
	valor.TextWrapped = false
	valor.TextScaled = false
	valor.Position = UDim2.fromOffset(x, if conSub then 6 else 0)
	valor.Parent = c.Fondo

	local sub: TextLabel? = nil
	if conSub then
		local s = UI.texto({
			Nombre = "Sub",
			Texto = op.Sub,
			Letra = Tema.Letra.Chica,
			Color = op.Color,
			AlineacionX = Enum.TextXAlignment.Left,
			Medida = UDim2.new(1, -x - 12, 0, alto * 0.32),
		})
		s.Position = UDim2.new(0, x, 0.58, 0)
		s.Parent = c.Fondo
		sub = s
	end

	return {
		Marco = c.Marco,
		Fondo = c.Fondo,
		Valor = valor,
		Sub = sub,
		Escala = escala,
		rebotar = function(fuerza: number?)
			escala.Scale = 1 + (fuerza or 0.15)
			animar(escala, Tema.Rebote, { Scale = 1 })
		end,
	}
end

---------------------------------------------------------------------------
-- Barra de progreso
---------------------------------------------------------------------------

export type Barra = {
	Marco: Frame,
	Relleno: Frame,
	poner: (fraccion: number, animada: boolean?) -> (),
}

function UI.barra(color: Color3?, alto: number?): Barra
	local marco = Instance.new("Frame")
	marco.Name = "Barra"
	marco.Size = UDim2.new(1, 0, 0, alto or 18)
	marco.BackgroundColor3 = Paleta.Contorno
	marco.BackgroundTransparency = 0.15
	marco.BorderSizePixel = 0
	UI.redondo(marco)
	UI.contorno(marco, Paleta.Contorno, 2)
	local relleno = Instance.new("Frame")
	relleno.Name = "Relleno"
	relleno.Size = UDim2.fromScale(0, 1)
	relleno.BackgroundColor3 = color or Paleta.Acento
	relleno.BorderSizePixel = 0
	UI.redondo(relleno)
	relleno.Parent = marco
	return {
		Marco = marco,
		Relleno = relleno,
		poner = function(fraccion: number, animada: boolean?)
			local f = math.clamp(fraccion, 0, 1)
			-- Con muy poco relleno la esquina redonda se ve rara: se muestra un mínimo.
			local meta = UDim2.fromScale(if f > 0 then math.max(f, 0.04) else 0, 1)
			if animada then
				animar(relleno, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { Size = meta })
			else
				relleno.Size = meta
			end
		end,
	}
end

---------------------------------------------------------------------------
-- Puntos de generación y de elemento
---------------------------------------------------------------------------

-- Tantos puntos como la generación, del color de la generación.
function UI.puntosGen(gen: number, tam: number?): Frame
	local t = tam or 14
	local marco = UI.hueco("Generacion", UDim2.fromOffset(t * gen + 4 * (gen - 1), t))
	UI.lista(marco, true, 4)
	for i = 1, gen do
		local p = Iconos.crear("punto", t, Paleta.Generaciones[gen] or Paleta.Texto)
		p.LayoutOrder = i
		UI.contorno(p:FindFirstChildOfClass("Frame") :: Frame, Paleta.Contorno, 1.5)
		p.Parent = marco
	end
	return marco
end

function UI.puntoElemento(color: Color3, tam: number?): Frame
	local p = Iconos.crear("punto", tam or 18, color)
	p.Name = "Elemento"
	UI.contorno(p:FindFirstChildOfClass("Frame") :: Frame, Paleta.Contorno, 2)
	return p
end

---------------------------------------------------------------------------
-- Casillero de criatura (ranuras de la máquina, tarjetas de criaturas)
---------------------------------------------------------------------------

export type OpcionesCasillero = {
	Medida: UDim2,
	Borde: Color3?,
	Signo: string?, -- lo que se ve vacío: "+" o "?"
	Titulo: string?, -- texto chico de abajo cuando está vacío
	Candado: boolean?,
	ConNombre: boolean?, -- franja con el nombre abajo (por defecto sí)
	Nombre: string?,
}

export type Casillero = {
	Marco: Frame,
	Fondo: TextButton,
	Borde: UIStroke,
	Vista: ViewportFrame,
	Signo: TextLabel,
	Nombre: TextLabel?,
	Candado: Frame?,
	Clave: string?,
	poner: (clave: string?, nombre: string?, mutante: boolean?, silueta: boolean?) -> (),
	bloquear: (si: boolean) -> (),
}

function UI.casillero(op: OpcionesCasillero): Casillero
	local c = UI.caja({
		Nombre = op.Nombre or "Casillero",
		Color = Paleta.SuperficieElevada,
		Borde = op.Borde,
		Grosor = Tema.Contorno + 1,
		Boton = true,
	})
	c.Marco.Size = op.Medida
	local fondo = c.Fondo :: TextButton
	local conNombre = op.ConNombre ~= false
	local altoNombre = if conNombre then 40 else 0

	local vista = Instance.new("ViewportFrame")
	vista.Name = "Vista"
	vista.BackgroundTransparency = 1
	vista.Size = UDim2.new(1, -8, 1, -altoNombre - 8)
	vista.Position = UDim2.fromOffset(4, 4)
	vista.Parent = fondo

	local signo = UI.texto({
		Nombre = "Signo",
		Texto = op.Signo or "+",
		Letra = Tema.Letra.Gigante + 32,
		Color = Paleta.Metal,
		Medida = UDim2.new(1, 0, 1, -altoNombre),
	})
	signo.Parent = fondo

	local nombre: TextLabel? = nil
	if conNombre then
		local n = UI.texto({
			Nombre = "Nombre",
			Texto = op.Titulo or "",
			Letra = Tema.Letra.Chica,
			Medida = UDim2.new(1, -8, 0, altoNombre),
		})
		n.AnchorPoint = Vector2.new(0.5, 1)
		n.Position = UDim2.new(0.5, 0, 1, -4)
		n.TextScaled = false
		n.Parent = fondo
		nombre = n
	end

	local candado: Frame? = nil
	local cas: Casillero
	cas = {
		Marco = c.Marco,
		Fondo = fondo,
		Borde = c.Borde,
		Vista = vista,
		Signo = signo,
		Nombre = nombre,
		Candado = nil,
		Clave = nil,
		poner = function(clave: string?, texto: string?, mutante: boolean?, silueta: boolean?)
			cas.Clave = clave
			Vista.mostrar(vista, clave, mutante, silueta)
			signo.Visible = clave == nil or silueta == true
			if nombre then
				nombre.Text = texto or (if clave then "" else op.Titulo or "")
			end
		end,
		bloquear = function(si: boolean)
			if si and not candado then
				local fondoCandado = Instance.new("Frame")
				fondoCandado.Name = "Candado"
				fondoCandado.Size = UDim2.fromScale(1, 1)
				fondoCandado.BackgroundTransparency = 1
				local i = Iconos.crear("candado", 44, Paleta.Metal)
				i.Position = UDim2.new(0.5, 0, 0.5, -altoNombre / 2)
				i.Parent = fondoCandado
				fondoCandado.Parent = fondo
				candado = fondoCandado
				cas.Candado = fondoCandado
			end
			if candado then
				candado.Visible = si
			end
			signo.Visible = not si and cas.Clave == nil
		end,
	}
	if op.Candado then
		cas.bloquear(true)
	end
	return cas
end

---------------------------------------------------------------------------
-- Notificación (las apila Notificaciones.luau)
---------------------------------------------------------------------------

local ESTILO_AVISO: { [string]: { Color: Color3, Icono: string } } = {
	exito = { Color = Paleta.Exito, Icono = "check" },
	error = { Color = Paleta.Error, Icono = "exclamacion" },
	info = { Color = Paleta.Alerta, Icono = "exclamacion" },
	adn = { Color = Paleta.Acento, Icono = "adn" },
	premio = { Color = Paleta.Dorado, Icono = "rombo" },
}

UI.AnchoNotificacion = 460
UI.AltoNotificacion = 88

function UI.notificacion(texto: string, tipo: string?): Caja
	local estilo = ESTILO_AVISO[tipo or "info"] or ESTILO_AVISO.info
	local c = UI.caja({
		Nombre = "Notificacion",
		Color = Paleta.Superficie,
		Transparencia = 0.04,
		Borde = estilo.Color,
	})
	c.Marco.Size = UDim2.fromOffset(UI.AnchoNotificacion, UI.AltoNotificacion)
	local circulo = Instance.new("Frame")
	circulo.Size = UDim2.fromOffset(60, 60)
	circulo.AnchorPoint = Vector2.new(0, 0.5)
	circulo.Position = UDim2.new(0, 14, 0.5, 0)
	circulo.BackgroundColor3 = estilo.Color
	UI.redondo(circulo)
	UI.contorno(circulo, Paleta.Contorno, 2)
	Iconos.crear(estilo.Icono, 36, Paleta.Contorno).Parent = circulo
	circulo.Parent = c.Fondo
	local t = UI.texto({
		Texto = texto,
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica + 2,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -100, 1, -12),
	})
	t.Position = UDim2.fromOffset(88, 6)
	t.Parent = c.Fondo
	return c
end

---------------------------------------------------------------------------
-- Cartel grande (lo maneja Carteles.luau: uno a la vez, en cola)
---------------------------------------------------------------------------

export type Cartel = {
	Marco: Frame,
	Fondo: TextButton,
	Borde: UIStroke,
	Escala: UIScale,
	Etiqueta: TextLabel,
	Arcoiris: UIGradient,
	Titulo: TextLabel,
	Texto: TextLabel,
	Detalle: TextLabel,
}

function UI.cartelGrande(): Cartel
	local c = UI.caja({
		Nombre = "Cartel",
		Color = Paleta.Superficie,
		Transparencia = 0.03,
		Grosor = Tema.Contorno + 2,
		Boton = true,
	})
	c.Marco.AnchorPoint = Vector2.new(0.5, 0.5)
	c.Marco.Position = UDim2.fromScale(0.5, 0.42)
	c.Marco.Size = UDim2.fromOffset(660, 260)
	c.Marco.Visible = false
	local escala = Instance.new("UIScale")
	escala.Parent = c.Marco
	local fondo = c.Fondo :: TextButton
	UI.relleno(fondo, 16)
	UI.lista(fondo, false, 4, true)

	local etiqueta = UI.texto({
		Nombre = "Etiqueta",
		Texto = "¡MUTANTE!",
		Letra = Tema.Letra.Subtitulo,
		Color = Paleta.Texto,
	})
	etiqueta.LayoutOrder = 1
	etiqueta.Visible = false
	etiqueta.Parent = fondo
	local arcoiris = Instance.new("UIGradient")
	arcoiris.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Paleta.Dorado),
		ColorSequenceKeypoint.new(0.33, Paleta.Alerta),
		ColorSequenceKeypoint.new(0.66, Paleta.Acento),
		ColorSequenceKeypoint.new(1, Paleta.Dorado),
	})
	arcoiris.Parent = etiqueta

	local titulo = UI.texto({
		Nombre = "Titulo",
		Letra = Tema.Letra.Gigante,
		Color = Paleta.Acento,
		Medida = UDim2.new(1, 0, 0, 80),
	})
	titulo.TextScaled = true
	titulo.LayoutOrder = 2
	titulo.Parent = fondo
	local texto = UI.texto({
		Nombre = "Nombre",
		Letra = Tema.Letra.Titulo,
		Medida = UDim2.new(1, 0, 0, 56),
	})
	texto.LayoutOrder = 3
	texto.Parent = fondo
	local detalle = UI.texto({
		Nombre = "Detalle",
		Fuente = "fuerte",
		Letra = Tema.Letra.Normal,
		Medida = UDim2.new(1, 0, 0, 40),
	})
	detalle.LayoutOrder = 4
	detalle.Parent = fondo

	return {
		Marco = c.Marco,
		Fondo = fondo,
		Borde = c.Borde,
		Escala = escala,
		Etiqueta = etiqueta,
		Arcoiris = arcoiris,
		Titulo = titulo,
		Texto = texto,
		Detalle = detalle,
	}
end

return UI
