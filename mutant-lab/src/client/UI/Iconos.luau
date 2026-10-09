--!strict
-- Íconos dibujados con formas simples (círculos, barras y rombos), sin emojis.
-- Cada ícono es un Frame cuadrado y transparente; las piezas se ubican en proporciones
-- de 0 a 1, así el mismo ícono sirve en cualquier tamaño. Siempre de un color de la paleta.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Tema = require(script.Parent.Tema)

type Dibujo = (lienzo: Frame, color: Color3, tamano: number) -> ()

-- Una pieza: centro (x, y), tamaño (an, al), `redondo` de 0 a 0,5 y giro en grados.
local function forma(
	padre: Instance,
	x: number,
	y: number,
	an: number,
	al: number,
	color: Color3,
	redondo: number?,
	giro: number?,
	z: number?
): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(x, y)
	f.Size = UDim2.fromScale(an, al)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Rotation = giro or 0
	f.ZIndex = z or 1
	if redondo then
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(redondo, 0)
		esquina.Parent = f
	end
	f.Parent = padre
	return f
end

-- Un aro (círculo hueco) con un grosor en puntos.
local function aro(
	padre: Instance,
	x: number,
	y: number,
	an: number,
	al: number,
	grosor: number,
	color: Color3,
	z: number?
): Frame
	local f = forma(padre, x, y, an, al, color, 0.5, 0, z)
	f.BackgroundTransparency = 1
	local trazo = Instance.new("UIStroke")
	trazo.Thickness = grosor
	trazo.Color = color
	trazo.Parent = f
	return f
end

-- Una letra o signo grande con la tipografía de títulos (por ejemplo "?" o "★"). Solo signos
-- que la fuente dibuja de un color: los emojis no se usan.
local function letra(padre: Instance, texto: string, color: Color3): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = "Letra"
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.FontFace = Tema.Fuentes.Titulo
	t.TextScaled = true
	t.Text = texto
	t.TextColor3 = color
	local trazo = Instance.new("UIStroke")
	trazo.Color = Paleta.Contorno
	trazo.Thickness = Tema.ContornoTexto
	trazo.Parent = t
	t.Parent = padre
	return t
end

local DIBUJOS: { [string]: Dibujo } = {
	-- Hélice de ADN: escalones que giran, con una bolita en cada punta.
	adn = function(l, c)
		l.Rotation = 18
		for i = 0, 4 do
			local y = 0.1 + i * 0.2
			local dx = 0.3 * math.sin(i * 0.9 + 0.3)
			local escalon = forma(l, 0.5, y, math.abs(dx) * 2 + 0.02, 0.07, c, 0.5)
			escalon.BackgroundTransparency = 0.35
			forma(l, 0.5 + dx, y, 0.2, 0.2, c, 0.5, 0, 2)
			forma(l, 0.5 - dx, y, 0.2, 0.2, Paleta.claro(c), 0.5, 0, 2)
		end
	end,

	-- Mutadex: un libro abierto.
	libro = function(l, c)
		forma(l, 0.3, 0.5, 0.38, 0.72, c, 0.18, -6)
		forma(l, 0.7, 0.5, 0.38, 0.72, c, 0.18, 6)
		forma(l, 0.5, 0.53, 0.08, 0.74, Paleta.oscuro(c), 0.5, 0, 2)
		for i = 0, 2 do
			local y = 0.36 + i * 0.14
			forma(l, 0.29, y, 0.2, 0.06, Paleta.oscuro(c), 0.5, -6, 2)
			forma(l, 0.71, y, 0.2, 0.06, Paleta.oscuro(c), 0.5, 6, 2)
		end
	end,

	-- Tienda: un carrito (una bolsa con manija se confundía con el candado).
	carrito = function(l, c)
		forma(l, 0.14, 0.22, 0.2, 0.1, c, 0.5, 15)
		forma(l, 0.27, 0.4, 0.09, 0.36, c, 0.5, -18)
		forma(l, 0.58, 0.47, 0.62, 0.36, c, 0.2)
		forma(l, 0.55, 0.7, 0.54, 0.08, c, 0.5)
		forma(l, 0.38, 0.85, 0.17, 0.17, c, 0.5)
		forma(l, 0.72, 0.85, 0.17, 0.17, c, 0.5)
		for _, x in { 0.46, 0.6, 0.74 } do
			forma(l, x, 0.47, 0.05, 0.24, Paleta.oscuro(c, 0.5), 0.5, 0, 2)
		end
	end,

	-- Misiones: una tabla con tres renglones.
	misiones = function(l, c)
		forma(l, 0.5, 0.54, 0.7, 0.84, c, 0.14)
		forma(l, 0.5, 0.13, 0.36, 0.14, Paleta.oscuro(c), 0.3, 0, 2)
		for i = 0, 2 do
			local y = 0.38 + i * 0.19
			forma(l, 0.3, y, 0.13, 0.13, Paleta.oscuro(c), 0.5, 0, 2)
			forma(l, 0.6, y, 0.36, 0.07, Paleta.oscuro(c), 0.5, 0, 2)
		end
	end,

	-- Ajustes: un engranaje.
	engranaje = function(l, c)
		for i = 0, 3 do
			forma(l, 0.5, 0.5, 0.24, 0.96, c, 0.25, i * 45)
		end
		forma(l, 0.5, 0.5, 0.72, 0.72, c, 0.5)
		forma(l, 0.5, 0.5, 0.3, 0.3, Paleta.oscuro(c, 0.6), 0.5, 0, 2)
	end,

	cerrar = function(l, c)
		forma(l, 0.5, 0.5, 0.86, 0.2, c, 0.5, 45)
		forma(l, 0.5, 0.5, 0.86, 0.2, c, 0.5, -45)
	end,

	mas = function(l, c)
		forma(l, 0.5, 0.5, 0.86, 0.22, c, 0.5)
		forma(l, 0.5, 0.5, 0.22, 0.86, c, 0.5)
	end,

	candado = function(l, c, t)
		aro(l, 0.5, 0.36, 0.48, 0.56, math.max(2, t * 0.1), c)
		forma(l, 0.5, 0.67, 0.76, 0.52, c, 0.2, 0, 2)
		forma(l, 0.5, 0.63, 0.15, 0.15, Paleta.oscuro(c, 0.6), 0.5, 0, 3)
		forma(l, 0.5, 0.73, 0.07, 0.16, Paleta.oscuro(c, 0.6), 0.3, 0, 3)
	end,

	-- Mutante, raro y Premium: un rombo con brillo.
	rombo = function(l, c)
		forma(l, 0.5, 0.5, 0.66, 0.66, c, 0.12, 45)
		forma(l, 0.4, 0.38, 0.16, 0.16, Paleta.claro(c, 0.6), 0.5, 45, 2)
	end,

	lupa = function(l, c, t)
		aro(l, 0.42, 0.42, 0.56, 0.56, math.max(2, t * 0.11), c)
		forma(l, 0.77, 0.77, 0.14, 0.42, c, 0.5, -45)
	end,

	-- Fusión rápida: dos flechas ">>".
	rapida = function(l, c)
		for _, x in { 0.36, 0.66 } do
			forma(l, x, 0.35, 0.44, 0.15, c, 0.5, 45)
			forma(l, x, 0.65, 0.44, 0.15, c, 0.5, -45)
		end
	end,

	-- Nutrientes: una gota.
	gota = function(l, c)
		forma(l, 0.5, 0.62, 0.62, 0.62, c, 0.5)
		forma(l, 0.5, 0.42, 0.44, 0.44, c, 0.12, 45)
		forma(l, 0.38, 0.64, 0.12, 0.2, Paleta.claro(c, 0.6), 0.5, 20, 2)
	end,

	-- Corrales: una cúpula sobre una base.
	corral = function(l, c)
		local recorte = Instance.new("Frame")
		recorte.AnchorPoint = Vector2.new(0.5, 1)
		recorte.Position = UDim2.fromScale(0.5, 0.7)
		recorte.Size = UDim2.fromScale(0.8, 0.42)
		recorte.BackgroundTransparency = 1
		recorte.ClipsDescendants = true
		recorte.Parent = l
		local cupula = forma(recorte, 0.5, 1, 1, 2, c, 0.5)
		cupula.BackgroundTransparency = 0.15
		forma(l, 0.5, 0.76, 0.96, 0.16, c, 0.4, 0, 2)
		forma(l, 0.38, 0.5, 0.1, 0.14, Paleta.claro(c, 0.6), 0.5, -20, 2)
	end,

	-- Catalizadores: un frasco.
	frasco = function(l, c)
		forma(l, 0.5, 0.65, 0.66, 0.6, c, 0.5)
		forma(l, 0.5, 0.31, 0.26, 0.34, c, 0.2)
		forma(l, 0.5, 0.13, 0.4, 0.1, c, 0.5)
		forma(l, 0.5, 0.7, 0.4, 0.13, Paleta.claro(c, 0.5), 0.5, 0, 2)
	end,

	-- Especies: una carita redonda.
	criatura = function(l, c)
		forma(l, 0.5, 0.56, 0.84, 0.76, c, 0.5)
		for _, x in { 0.36, 0.64 } do
			forma(l, x, 0.5, 0.22, 0.26, Paleta.Texto, 0.5, 0, 2)
			forma(l, x + 0.02, 0.54, 0.1, 0.13, Paleta.Contorno, 0.5, 0, 3)
		end
	end,

	-- Mejoras: una flecha hacia arriba.
	flecha = function(l, c)
		forma(l, 0.34, 0.38, 0.46, 0.17, c, 0.5, -45)
		forma(l, 0.66, 0.38, 0.46, 0.17, c, 0.5, 45)
		forma(l, 0.5, 0.6, 0.17, 0.56, c, 0.5)
	end,

	check = function(l, c)
		forma(l, 0.31, 0.6, 0.34, 0.17, c, 0.5, 45)
		forma(l, 0.6, 0.5, 0.6, 0.17, c, 0.5, -48)
	end,

	exclamacion = function(l, c)
		forma(l, 0.5, 0.38, 0.17, 0.5, c, 0.5)
		forma(l, 0.5, 0.82, 0.18, 0.18, c, 0.5)
	end,

	-- Un punto lleno (elementos y generaciones).
	punto = function(l, c)
		forma(l, 0.5, 0.5, 1, 1, c, 0.5)
	end,

	-- "=" entre los padres y el resultado.
	igual = function(l, c)
		forma(l, 0.5, 0.34, 0.86, 0.2, c, 0.5)
		forma(l, 0.5, 0.66, 0.86, 0.2, c, 0.5)
	end,

	-- Mutante y Líder: la estrella de la fuente (de un solo color).
	estrella = function(l, c)
		letra(l, "★", c)
	end,

	pregunta = function(l, c)
		letra(l, "?", c)
	end,

	-- Personalidades (ficha, "Ícono de personalidad").
	corazon = function(l, c)
		forma(l, 0.5, 0.58, 0.5, 0.5, c, 0.08, 45)
		forma(l, 0.323, 0.403, 0.5, 0.5, c, 0.5)
		forma(l, 0.677, 0.403, 0.5, 0.5, c, 0.5)
		forma(l, 0.32, 0.36, 0.14, 0.14, Paleta.claro(c, 0.6), 0.5, 0, 2)
	end,

	zzz = function(l, c)
		letra(l, "Zzz", c)
	end,

	martillo = function(l, c)
		l.Rotation = -35
		forma(l, 0.5, 0.64, 0.16, 0.66, Paleta.oscuro(c, 0.25), 0.4)
		forma(l, 0.5, 0.24, 0.66, 0.28, c, 0.2, 0, 2)
	end,

	rayo = function(l, c)
		forma(l, 0.56, 0.27, 0.2, 0.5, c, 0.2, 28)
		forma(l, 0.5, 0.5, 0.5, 0.16, c, 0.3, -12)
		forma(l, 0.44, 0.73, 0.2, 0.5, c, 0.2, 28)
	end,

	cubierto = function(l, c)
		forma(l, 0.5, 0.7, 0.16, 0.56, c, 0.5)
		forma(l, 0.5, 0.4, 0.5, 0.14, c, 0.4)
		for _, x in { 0.3, 0.5, 0.7 } do
			forma(l, x, 0.22, 0.11, 0.36, c, 0.5)
		end
	end,
}

local Iconos = {}

-- Crea el ícono `nombre` de `tamano` puntos. Si el nombre no existe, dibuja la primera letra.
function Iconos.crear(nombre: string, tamano: number, color: Color3): Frame
	local lienzo = Instance.new("Frame")
	lienzo.Name = "Icono"
	lienzo.BackgroundTransparency = 1
	lienzo.Size = UDim2.fromOffset(tamano, tamano)
	lienzo.AnchorPoint = Vector2.new(0.5, 0.5)
	lienzo.Position = UDim2.fromScale(0.5, 0.5)
	local dibujo = DIBUJOS[nombre]
	if dibujo then
		dibujo(lienzo, color, tamano)
	else
		letra(lienzo, nombre:sub(1, 1):upper(), color)
	end
	return lienzo
end

Iconos.letra = letra

function Iconos.existe(nombre: string): boolean
	return DIBUJOS[nombre] ~= nil
end

return Iconos
