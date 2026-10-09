--!strict
-- Pantalla de muestra: todos los componentes juntos, para revisar el estilo.
-- Solo para probar: se abre cuando el jugador tiene el atributo "MuestraUI" (ver Hud.client).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local UI = require(script.Parent)
local Carteles = require(script.Parent.Carteles)
local Menus = require(script.Parent.Menus)
local Notificaciones = require(script.Parent.Notificaciones)

local Tema = UI.Tema

local Muestra = {}

local armada = false

local function fila(padre: Instance, alto: number, orden: number): Frame
	local f = UI.hueco("Fila" .. orden, UDim2.new(1, 0, 0, alto), padre)
	f.LayoutOrder = orden
	UI.lista(f, true, Tema.Separacion)
	return f
end

local function etiqueta(padre: Instance, texto: string, orden: number)
	local t = UI.texto({
		Texto = texto,
		Letra = Tema.Letra.Subtitulo,
		Color = Paleta.Acento,
		AlineacionX = Enum.TextXAlignment.Left,
	})
	t.LayoutOrder = orden
	t.Parent = padre
end

local function armar()
	local v = UI.ventana({
		Titulo = "Muestra de componentes",
		Icono = "engranaje",
		ColorIcono = Paleta.Metal,
		Ancho = 0.94,
		Alto = 0.92,
		MaxAncho = 1300,
		MaxAlto = 860,
	})
	Menus.registrar("Muestra", v)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = Paleta.Metal
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Parent = v.Cuerpo
	UI.lista(scroll, false, 16)
	local relleno = Instance.new("UIPadding")
	relleno.PaddingRight = UDim.new(0, 14)
	relleno.PaddingBottom = UDim.new(0, 14)
	relleno.Parent = scroll

	-- Pestañas
	etiqueta(scroll, "Pestañas", 1)
	local pestanas = UI.pestanas({
		{ Clave = "Uno", Texto = "Gen 1" },
		{ Clave = "Dos", Texto = "Gen 2" },
		{ Clave = "Tres", Texto = "Gen 3" },
		{ Clave = "Extras", Texto = "Extras" },
	}, function() end)
	pestanas.Marco.LayoutOrder = 2
	pestanas.Marco.Parent = scroll
	pestanas.elegir("Uno")

	-- Botones
	etiqueta(scroll, "Botones", 3)
	local f1 = fila(scroll, Tema.Toque + 4, 4)
	local principal = UI.boton({
		Texto = "¡FUSIONAR!",
		Sub = "40 ADN",
		Tipo = "principal",
		Medida = UDim2.fromOffset(260, Tema.Toque + 4),
	})
	principal.Marco.Parent = f1
	local sinADN = UI.boton({
		Texto = "¡FUSIONAR!",
		Sub = "Te faltan 25 ADN",
		Tipo = "principal",
		Medida = UDim2.fromOffset(260, Tema.Toque + 4),
	})
	sinADN.habilitar(false)
	sinADN.colorSub(Paleta.Error)
	sinADN.Marco.Parent = f1
	UI.boton({ Texto = "Volver", Tipo = "secundario", Medida = UDim2.fromOffset(180, Tema.Toque) }).Marco.Parent =
		f1
	UI.boton({
		Texto = "R$ 149",
		Icono = "rombo",
		ColorIcono = Paleta.Contorno,
		Tipo = "dorado",
		Medida = UDim2.fromOffset(200, Tema.Toque),
	}).Marco.Parent =
		f1

	local f2 = fila(scroll, Tema.Toque, 5)
	for i, d in
		{
			{ "libro", Paleta.Elementos.Sombra },
			{ "bolsa", Paleta.Dorado },
			{ "misiones", Paleta.Elementos.Agua },
			{ "engranaje", Paleta.Metal },
		}
	do
		local b = UI.boton({
			Icono = d[1],
			Color = d[2],
			Redondo = true,
			Medida = UDim2.fromOffset(Tema.Toque, Tema.Toque),
		})
		b.Marco.LayoutOrder = i
		b.Marco.Parent = f2
	end
	local cerrar = UI.botonCerrar()
	cerrar.Marco.LayoutOrder = 9
	cerrar.Marco.Parent = f2

	-- Contador, barra y tarjeta
	etiqueta(scroll, "Contador, barra y tarjeta", 6)
	local f3 = fila(scroll, 110, 7)
	local adn =
		UI.contador({ Icono = "adn", Color = Paleta.Acento, Texto = "12.450", Sub = "+35/s" })
	adn.Marco.Parent = f3
	local columnaBarra = UI.hueco("Progreso", UDim2.fromOffset(300, 96), f3)
	UI.lista(columnaBarra, false, 8)
	local textoBarra = UI.texto({ Texto = "12 / 50", Letra = Tema.Letra.Numero })
	textoBarra.Parent = columnaBarra
	local barra = UI.barra(Paleta.Acento, 22)
	barra.Marco.LayoutOrder = 2
	barra.Marco.Parent = columnaBarra
	barra.poner(12 / 50)
	local tarjeta = UI.tarjeta()
	tarjeta.Marco.Size = UDim2.fromOffset(380, 96)
	tarjeta.Marco.Parent = f3
	local textoTarjeta = UI.texto({
		Texto = "Tarjeta: fondo elevado, contorno casi negro y sombra.",
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica,
		Medida = UDim2.new(1, -24, 1, 0),
	})
	textoTarjeta.Position = UDim2.fromOffset(12, 0)
	textoTarjeta.Parent = tarjeta.Fondo

	-- Casilleros
	etiqueta(scroll, "Casilleros de criatura", 8)
	local f4 = fila(scroll, 210, 9)
	local vacio = UI.casillero({ Medida = UDim2.fromOffset(170, 200), Titulo = "Elegí una" })
	vacio.Marco.Parent = f4
	local lleno = UI.casillero({
		Medida = UDim2.fromOffset(170, 200),
		Borde = Paleta.Generaciones[2],
	})
	lleno.Marco.Parent = f4
	lleno.poner("1-2", "Glumulo")
	local silueta = UI.casillero({
		Medida = UDim2.fromOffset(170, 200),
		Signo = "?",
		Borde = Paleta.Generaciones[3],
	})
	silueta.Fondo.BackgroundColor3 = Paleta.SuperficieClara
	silueta.Marco.Parent = f4
	silueta.poner("1-2-3", "?", false, true)
	local mutante = UI.casillero({
		Medida = UDim2.fromOffset(170, 200),
		Borde = Paleta.Mutante,
	})
	mutante.Marco.Parent = f4
	mutante.poner("3", "Sutomi", true)
	local candado = UI.casillero({
		Medida = UDim2.fromOffset(120, 140),
		Titulo = "Catalizador",
		Candado = true,
	})
	candado.Marco.Parent = f4

	-- Íconos
	etiqueta(scroll, "Íconos (sin emojis)", 10)
	local f5 = fila(scroll, 64, 11)
	local colores = {
		Paleta.Acento,
		Paleta.Elementos.Sombra,
		Paleta.Dorado,
		Paleta.Elementos.Agua,
		Paleta.Metal,
		Paleta.Error,
		Paleta.Texto,
	}
	local nombres = {
		"adn",
		"libro",
		"bolsa",
		"misiones",
		"engranaje",
		"cerrar",
		"mas",
		"candado",
		"rombo",
		"lupa",
		"rapida",
		"gota",
		"corral",
		"frasco",
		"criatura",
		"flecha",
		"check",
		"exclamacion",
	}
	for i, n in nombres do
		local i2 = UI.Iconos.crear(n, 56, colores[(i - 1) % #colores + 1])
		i2.LayoutOrder = i
		i2.Parent = f5
	end
	local f6 = fila(scroll, 30, 12)
	for gen = 1, 3 do
		UI.puntosGen(gen, 22).Parent = f6
	end
	for _, nombre in { "Fuego", "Agua", "Planta", "Electrico", "Sombra" } do
		UI.puntoElemento(Paleta.Elementos[nombre], 26).Parent = f6
	end

	-- Avisos
	etiqueta(scroll, "Notificaciones y cartel grande", 13)
	local f7 = fila(scroll, Tema.Toque, 14)
	UI.boton({
		Texto = "Probar avisos",
		Medida = UDim2.fromOffset(260, Tema.Toque),
		AlTocar = function()
			Muestra.avisos()
		end,
	}).Marco.Parent =
		f7
	UI.boton({
		Texto = "Probar cartel",
		Medida = UDim2.fromOffset(260, Tema.Toque),
		AlTocar = function()
			Muestra.cartel()
		end,
	}).Marco.Parent =
		f7
end

function Muestra.avisos()
	Notificaciones.mostrar("¡Glupona llegó a tu laboratorio!", "exito")
	task.wait(0.3)
	Notificaciones.mostrar("Te falta ADN para Nutrientes.", "error")
	task.wait(0.3)
	Notificaciones.mostrar("+250 ADN por descubrir una especie", "adn")
end

function Muestra.cartel()
	Carteles.mostrar({
		Titulo = "¡ESPECIE NUEVA!",
		Texto = "Glumulo",
		Detalle = "Generación 2   +25 ADN",
		Mutante = true,
		Duracion = 6,
	})
end

function Muestra.abrir()
	if not armada then
		armada = true
		armar()
	end
	Menus.abrir("Muestra")
end

return Muestra
