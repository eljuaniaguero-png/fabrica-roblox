--!strict
-- La tienda del laboratorio (ficha, "Guía de estilo", 6, "Tienda"), armada por código con los
-- componentes de UI: pestañas Especies, Mejoras, Catalizadores y Premium. Cada artículo va en
-- una tarjeta con su vista 3D o ícono, nombre, efecto, nivel (las mejoras, con puntos) y un
-- botón con el precio. Lo que no alcanza: botón apagado con el precio en rojo. Lo Premium:
-- borde dorado. Al comprar: destello sobre la tarjeta, sonido y el ADN del encabezado rebota.
-- Se abre con el mostrador de tu laboratorio o con el botón Tienda del HUD (UI/Menus).
-- El servidor valida y cobra (server/Tienda.luau); si sale bien avisa con el remoto Compra.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Elementos = require(ReplicatedStorage.Shared.Elementos)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local MiLab = require(script.Parent.MiLab)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)

local Tema = UI.Tema
local T = Tema.Tienda
local V = Tema.Ventana
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local comprar = remotos:WaitForChild("Comprar") :: RemoteEvent
local compra = remotos:WaitForChild("Compra") :: RemoteEvent

-- Ícono y color de cada mejora (antes eran emojis).
local MEJORAS: { [string]: { Icono: string, Color: Color3 } } = {
	Corrales = { Icono = "corral", Color = Paleta.Elementos.Agua },
	Rapida = { Icono = "rapida", Color = Paleta.Elementos.Electrico },
	Nutrientes = { Icono = "gota", Color = Paleta.Acento },
}

-- Ícono de cada pase Premium (Config.Premium).
local PREMIUM: { [string]: string } = {
	ADNx2 = "adn",
	Instantanea = "rapida",
	CorralesExtra = "corral",
	Recoleccion = "mas",
	PistasDia = "lupa",
	VIP = "estrella",
	Todo = "rombo",
}

type Articulo = {
	Tarjeta: UI.Tarjeta,
	Media: Frame,
	Nombre: TextLabel,
	Efecto: TextLabel,
	Nivel: UI.Nivel?,
	TextoNivel: TextLabel?,
	Boton: UI.Boton,
}

type Pagina = {
	Marco: Frame,
	Grilla: UIGridLayout?,
}

local function numero(atributo: string): number
	return (jugador:GetAttribute(atributo) :: number?) or 0
end

---------------------------------------------------------------------------
-- Ventana, encabezado y pestañas
---------------------------------------------------------------------------

local ventana = UI.ventana({
	Titulo = "Tienda",
	Icono = "carrito",
	ColorIcono = Paleta.Dorado,
	Ancho = V.Ancho,
	Alto = V.Alto,
	MaxAncho = V.MaxAncho,
	MaxAlto = V.MaxAlto,
})

local contadorADN = UI.contador({
	Icono = "adn",
	Color = Paleta.Acento,
	Texto = "0",
	Ancho = Tema.ContadorVentana.X,
	Alto = Tema.ContadorVentana.Y,
})
contadorADN.Marco.AnchorPoint = Vector2.new(1, 0.5)
contadorADN.Marco.Position = UDim2.new(1, -(Tema.Relleno + Tema.Toque + Tema.Separacion), 0.5, 0)
contadorADN.Marco.Parent = ventana.Encabezado

local paginas: { [string]: Pagina } = {}
local paginaActual = "Especies"
local grupoEspecies: VistasVisibles.Grupo

local function mostrarPagina(clave: string)
	paginaActual = clave
	for k, p in paginas do
		p.Marco.Visible = k == clave
	end
	if clave == "Especies" and grupoEspecies then
		grupoEspecies.actualizar()
	end
end

local pestanas = UI.pestanas({
	{
		Clave = "Especies",
		Texto = "Especies",
		Icono = "criatura",
		ColorIcono = Paleta.Elementos.Agua,
	},
	{ Clave = "Mejoras", Texto = "Mejoras", Icono = "flecha", ColorIcono = Paleta.Texto },
	{
		Clave = "Catalizadores",
		Texto = "Catalizadores",
		Icono = "frasco",
		ColorIcono = Paleta.Alerta,
	},
	{ Clave = "Premium", Texto = "Premium", Icono = "rombo", ColorIcono = Paleta.Dorado },
}, mostrarPagina)
pestanas.Marco.Parent = ventana.Cuerpo

local arriba = Tema.Toque + Tema.Separacion
local contenido = UI.hueco("Contenido", UDim2.new(1, 0, 1, -arriba), ventana.Cuerpo)
contenido.Position = UDim2.fromOffset(0, arriba)

-- Una página con un renglón de ayuda arriba (opcional) y una grilla que se desplaza.
local function pagina(clave: string, info: string?): (Pagina, ScrollingFrame, TextLabel?)
	local marco = UI.hueco(clave, UDim2.fromScale(1, 1), contenido)
	marco.Visible = false
	local alto = if info then T.AltoInfo else 0
	local texto: TextLabel? = nil
	if info then
		local t = UI.texto({
			Nombre = "Info",
			Texto = info,
			Fuente = "fuerte",
			Letra = Tema.Letra.Chica,
			AlineacionX = Enum.TextXAlignment.Left,
			Medida = UDim2.new(1, 0, 0, alto),
		})
		t.Parent = marco
		texto = t
	end
	local scroll = UI.desplazable("Lista", marco)
	scroll.Position = UDim2.fromOffset(0, alto)
	scroll.Size = UDim2.new(1, 0, 1, -alto)
	local p = { Marco = marco, Grilla = UI.grilla(scroll, Vector2.new(T.AltoMedia, T.AltoTarjeta)) }
	paginas[clave] = p
	return p, scroll, texto
end

-- Página de "Próximamente": un ícono grande y un texto.
local function proximamente(clave: string, icono: string, color: Color3, texto: string)
	local marco = UI.hueco(clave, UDim2.fromScale(1, 1), contenido)
	marco.Visible = false
	local insignia = UI.insignia(icono, color, Tema.Mutadex.InsigniaExtras)
	insignia.AnchorPoint = Vector2.new(0.5, 1)
	insignia.Position = UDim2.fromScale(0.5, 0.45)
	insignia.Parent = marco
	local t = UI.texto({
		Texto = texto,
		Letra = Tema.Letra.Subtitulo,
		Medida = UDim2.new(1, 0, 0, Tema.Toque),
	})
	t.Position = UDim2.new(0, 0, 0.45, Tema.Separacion)
	t.Parent = marco
	paginas[clave] = { Marco = marco }
end

---------------------------------------------------------------------------
-- Tarjeta de un artículo
---------------------------------------------------------------------------

local function articulo(
	nombre: string,
	orden: number,
	padre: Instance,
	borde: Color3?,
	conNivel: boolean?
): Articulo
	local t = UI.tarjeta({
		Nombre = nombre,
		Borde = borde,
		Grosor = if borde then Tema.Contorno + 1 else nil,
	})
	t.Marco.LayoutOrder = orden
	t.Marco.Parent = padre
	local fondo = t.Fondo
	UI.relleno(fondo, Tema.Separacion)

	local media = UI.hueco("Media", UDim2.new(1, 0, 0, T.AltoMedia), fondo)
	local y = T.AltoMedia
	local titulo = UI.texto({
		Nombre = "Nombre",
		Letra = Tema.Letra.Subtitulo,
		Medida = UDim2.new(1, 0, 0, T.AltoNombre),
	})
	titulo.TextWrapped = false
	titulo.TextScaled = true -- los nombres largos se achican en vez de salirse
	local tope = Instance.new("UITextSizeConstraint")
	tope.MaxTextSize = Tema.Letra.Subtitulo
	tope.Parent = titulo
	titulo.Position = UDim2.fromOffset(0, y)
	titulo.Parent = fondo
	y += T.AltoNombre
	local efecto = UI.texto({
		Nombre = "Efecto",
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica,
		Color = Paleta.Texto,
		Medida = UDim2.new(1, 0, 0, T.AltoEfecto),
	})
	efecto.TextYAlignment = Enum.TextYAlignment.Top
	efecto.Position = UDim2.fromOffset(0, y)
	efecto.Parent = fondo
	y += T.AltoEfecto

	local nivel: UI.Nivel? = nil
	local textoNivel: TextLabel? = nil
	if conNivel then
		local filaNivel = UI.hueco("Nivel", UDim2.new(1, 0, 0, T.AltoNivel), fondo)
		filaNivel.Position = UDim2.fromOffset(0, y)
		local l = UI.lista(filaNivel, true, Tema.Separacion)
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		l.VerticalAlignment = Enum.VerticalAlignment.Center
		local tn = UI.texto({
			Nombre = "Texto",
			Letra = Tema.Letra.Chica,
			Medida = UDim2.fromOffset(0, T.AltoNivel),
		})
		tn.AutomaticSize = Enum.AutomaticSize.X
		tn.TextWrapped = false
		tn.LayoutOrder = 1
		tn.Parent = filaNivel
		local n = UI.nivel(T.PuntoNivel)
		n.Marco.LayoutOrder = 2
		n.Marco.Parent = filaNivel
		nivel = n
		textoNivel = tn
	end

	local boton = UI.boton({
		Nombre = "Comprar",
		Texto = "",
		Icono = "adn",
		ColorIcono = Paleta.Contorno,
		Tipo = "principal",
		Medida = UDim2.new(1, 0, 0, Tema.Toque),
	})
	boton.Marco.AnchorPoint = Vector2.new(0, 1)
	boton.Marco.Position = UDim2.fromScale(0, 1)
	boton.Marco.Parent = fondo

	return {
		Tarjeta = t,
		Media = media,
		Nombre = titulo,
		Efecto = efecto,
		Nivel = nivel,
		TextoNivel = textoNivel,
		Boton = boton,
	}
end

-- Botón con precio en ADN: apagado y con el precio en rojo si no alcanza.
local function precioADN(b: UI.Boton, precio: number, adn: number, sub: string?)
	local alcanza = adn >= precio
	b.poner(Formato.numero(precio), sub)
	b.colorTexto(if alcanza then Paleta.Texto else Paleta.Error)
	if b.Icono then
		b.Icono.Visible = true
	end
	b.habilitar(alcanza)
end

-- Botón sin precio ("La tenés", "Máximo", "Próximamente").
local function sinPrecio(b: UI.Boton, texto: string)
	b.poner(texto)
	b.colorTexto(Paleta.Texto)
	if b.Icono then
		b.Icono.Visible = false
	end
	b.habilitar(false)
end

---------------------------------------------------------------------------
-- Especies base
---------------------------------------------------------------------------

local _, listaEspecies, infoEspecies = pagina("Especies", "")
grupoEspecies = VistasVisibles.nueva(listaEspecies)
local especies: { Articulo } = {}
local efectos: { string } = {}

for n, base in Especies do
	local a = articulo("Base" .. n, n, listaEspecies)
	local c = Fusion.base(n)
	a.Nombre.Text = base.Nombre
	-- Elemento y una frase de cómo es ("Vive en el agua").
	efectos[n] = "Elemento "
		.. (Elementos.Nombres[base.Elemento] or base.Elemento)
		.. ".\n"
		.. base.Pista:sub(1, 1):upper()
		.. base.Pista:sub(2)
		.. "."
	a.Efecto.Text = efectos[n]
	local punto = UI.puntoElemento(Generador.colorElemento(c), math.floor(Tema.MarcaChica / 2))
	punto.AnchorPoint = Vector2.zero
	punto.Position = UDim2.new()
	punto.ZIndex = 3
	punto.Parent = a.Media
	grupoEspecies.agregar(a.Tarjeta.Marco, a.Media, { Clave = c.Clave })
	a.Boton.AlTocar = function()
		comprar:FireServer("Base", n)
	end
	especies[n] = a
end

---------------------------------------------------------------------------
-- Mejoras
---------------------------------------------------------------------------

local _, listaMejoras = pagina("Mejoras")
local mejoras: { [string]: Articulo } = {}

for i, nombre in Mejoras.Orden do
	local def = (Config.Mejoras :: any)[nombre]
	local estilo = MEJORAS[nombre]
	local a = articulo(nombre, i, listaMejoras, nil, true)
	local insignia = UI.insignia(estilo.Icono, estilo.Color, T.Insignia)
	insignia.AnchorPoint = Vector2.new(0.5, 0.5)
	insignia.Position = UDim2.fromScale(0.5, 0.5)
	insignia.Parent = a.Media
	a.Nombre.Text = def.Nombre
	a.Boton.AlTocar = function()
		comprar:FireServer("Mejora", nombre)
	end
	mejoras[nombre] = a
end

-- Lo que hace ahora la mejora, en una línea corta.
local function ahora(nombre: string, nivel: number): string
	if nombre == "Corrales" then
		return "Ahora trabajan " .. numero("Activas") .. " de " .. numero("Tope") .. "."
	elseif nombre == "Rapida" then
		return "Ahora la fusión dura el "
			.. math.round(Mejoras.factorRapidez(nivel) * 100)
			.. " %."
	end
	return "Ahora: +" .. math.round((Mejoras.multiplicadorADN(nivel) - 1) * 100) .. " % de ADN."
end

---------------------------------------------------------------------------
-- Catalizadores (Parte 3) y Premium (Parte 6)
---------------------------------------------------------------------------

proximamente("Catalizadores", "frasco", Paleta.Alerta, "Los catalizadores llegan pronto.")

local _, listaPremium = pagina("Premium", "Con Robux. Todavía no están a la venta: muy pronto.")
for i, p in Config.Premium do
	local a = articulo(p.Clave, i, listaPremium, Paleta.Dorado)
	local insignia = UI.insignia(PREMIUM[p.Clave] or "rombo", Paleta.Dorado, T.Insignia)
	insignia.AnchorPoint = Vector2.new(0.5, 0.5)
	insignia.Position = UDim2.fromScale(0.5, 0.5)
	insignia.Parent = a.Media
	a.Nombre.Text = p.Nombre
	a.Efecto.Text = p.Efecto
	-- Sin ID todavía: el botón muestra el precio y "Próximamente", y no hace nada.
	a.Boton.pintar(Paleta.Dorado)
	a.Boton.poner("R$ " .. p.Robux, "Próximamente")
	if a.Boton.Icono then
		a.Boton.Icono.Visible = false
	end
	a.Boton.habilitar(false)
end

---------------------------------------------------------------------------
-- Actualizar
---------------------------------------------------------------------------

local function actualizar()
	local adn = numero("ADN")
	local tengo = Formato.conjunto(jugador:GetAttribute("Especies") :: string?)
	contadorADN.Valor.Text = Formato.numero(adn)

	local cantidad, descubiertas = 0, 0
	for n = 1, Config.TamanioRueda do
		if tengo[tostring(n)] then
			cantidad += 1
		end
	end
	for _ in tengo do
		descubiertas += 1
	end
	local precio = Mejoras.precioBase(cantidad, descubiertas)
	local copia = Mejoras.precioCopia(descubiertas)
	if infoEspecies then
		infoEspecies.Text = (
			if precio
				then "La próxima especie cuesta "
					.. Formato.numero(precio)
					.. " ADN (mejor una vecina de las tuyas)."
				else "¡Ya tenés las 10 especies base!"
		)
			.. " Otra copia de las que tenés: "
			.. Formato.numero(copia)
			.. " ADN."
	end
	local inventario = Formato.inventario(jugador:GetAttribute("Criaturas") :: string?)
	for n, a in especies do
		local cuenta = inventario[tostring(n)]
		local cuantas = if cuenta then cuenta.Normales + cuenta.Mutantes else 0
		if tengo[tostring(n)] then
			-- Ya la descubriste: se compran copias (para pedidos o si entregaste la tuya).
			a.Efecto.Text = efectos[n] .. "\nTenés " .. cuantas .. " en tu laboratorio."
			precioADN(a.Boton, copia, adn, "Otra copia")
		elseif precio then
			a.Efecto.Text = efectos[n]
			precioADN(a.Boton, precio, adn)
		end
	end

	for nombre, a in mejoras do
		local def = (Config.Mejoras :: any)[nombre]
		local nivel = numero("Mejora" .. nombre)
		local maximo = Mejoras.maximo(nombre)
		a.Efecto.Text = def.Descripcion .. ".\n" .. ahora(nombre, nivel)
		if a.TextoNivel and a.Nivel then
			a.TextoNivel.Text = "Nivel " .. nivel .. " / " .. maximo
			a.Nivel.poner(nivel, maximo)
		end
		local p = Mejoras.precio(nombre, nivel, descubiertas)
		if p then
			precioADN(a.Boton, p, adn)
		else
			sinPrecio(a.Boton, "Máximo")
		end
	end
end

---------------------------------------------------------------------------
-- Acomodo (computadora o celular)
---------------------------------------------------------------------------

ventana.alAcomodar(function(tam: Vector2)
	local celular = UI.Pantalla.esCelular()
	local columnas = if celular then T.ColumnasCelular else T.Columnas
	local ancho = UI.anchoCelda(UI.anchoUtil(tam.X - Tema.Relleno * 2), columnas)
	for _, p in paginas do
		if p.Grilla then
			p.Grilla.CellSize = UDim2.fromOffset(ancho, T.AltoTarjeta)
		end
	end
end)

---------------------------------------------------------------------------
-- Conexiones
---------------------------------------------------------------------------

-- La compra salió bien: destello sobre la tarjeta, sonido y el ADN rebota.
compra.OnClientEvent:Connect(function(tipo: string, id: any)
	if not ventana.Marco.Visible then
		return
	end
	local a: Articulo? = nil
	if tipo == "Base" then
		a = especies[id :: number]
	elseif tipo == "Mejora" then
		a = mejoras[id :: string]
	end
	if a then
		UI.destello(a.Tarjeta.Fondo, Paleta.Acento, a.Tarjeta.Marco)
		Sonidos.comprar()
		contadorADN.rebotar(0.2)
	end
end)

Menus.registrar("Tienda", ventana, function()
	actualizar()
	mostrarPagina(paginaActual)
end)

local prompt = MiLab.obtener()
	:WaitForChild("Tienda")
	:WaitForChild("Mostrador")
	:WaitForChild("Prompt") :: ProximityPrompt
prompt.Triggered:Connect(function()
	Menus.abrir("Tienda")
end)

for _, atributo in
	{
		"ADN",
		"Especies",
		"Criaturas",
		"Activas",
		"Tope",
		"MejoraCorrales",
		"MejoraRapida",
		"MejoraNutrientes",
	}
do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		if ventana.Marco.Visible then
			actualizar()
		end
	end)
end

pestanas.elegir("Especies")
actualizar()
