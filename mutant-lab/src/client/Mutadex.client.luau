--!strict
-- La Mutadex (ficha, "Guía de estilo", 6, "Mutadex"), armada por código con los componentes de UI:
--   encabezado con el título, "12 / 50", la barra de progreso y el ADN;
--   pestañas Gen 1, Gen 2, Gen 3 y Extras (las especies especiales);
--   grilla de tarjetas (4 por fila en computadora, 3 en celular): las descubiertas con la
--   criatura, el nombre, el punto de elemento y el borde de su generación (estrella dorada si
--   la tenés mutante); las demás, silueta negra con "?" en una esquina (la forma es la pista);
--   ficha de la especie tocada (al costado en computadora, encima en celular): la criatura
--   grande girando, nombre, generación, elemento, personalidad, receta si ya la descubriste y
--   el botón de pista para las siluetas.
-- Se abre con el progreso o el botón Mutadex del HUD, a través de UI/Menus.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Elementos = require(ReplicatedStorage.Shared.Elementos)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Pistas = require(ReplicatedStorage.Shared.Pistas)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)
local Vista = require(script.Parent.Vista)

local Tema = UI.Tema
local T = Tema.Mutadex
local V = Tema.Ventana
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local comprarPista = remotos:WaitForChild("ComprarPista") :: RemoteEvent
local compra = remotos:WaitForChild("Compra") :: RemoteEvent
local pasear = remotos:WaitForChild("Pasear") :: RemoteEvent

local TODAS = Fusion.todas()
-- Extras (no cuentan en las 50): la especial del premio diario y las 10 de equipo.
local EXTRAS = table.clone(Fusion.especiales())
for _, c in Fusion.deEquipo() do
	table.insert(EXTRAS, c)
end
local NOTA_EXTRAS =
	"Especiales: Estrellín sale el día 7 del premio diario y las de equipo, solo en la máquina de equipo de la plaza."

-- ¿Ya la conseguiste? (las especiales se anotan aparte)
local function conocida(
	e: { Tengo: { [string]: boolean }, Especiales: { [string]: boolean } },
	c: Fusion.Criatura
): boolean
	return if c.Especial then e.Especiales[c.Clave] == true else e.Tengo[c.Clave] == true
end

-- En qué pestaña va.
local function paginaDe(c: Fusion.Criatura): string
	return if c.Especial then "Extras" else tostring(c.Gen)
end

-- La regla de cada generación, arriba de su grilla (ayuda mucho a saber qué combinar).
local NOTAS = {
	"La rueda: las bases están en ronda (después de la 10 vuelve la 1). Las vecinas, hasta 3 lugares, se fusionan.",
	"Base + base: dos bases cercanas en la rueda.",
	"Gen 2 + base: las tres bases tienen que quedar seguidas en la rueda.",
}

local AYUDA = "Tocá una especie para ver su ficha.\n\n"
	.. "Las siluetas negras son las que te faltan: su forma es una pista.\n\n"
	.. "Si te trabás, comprá una pista con ADN."

type Estado = {
	Tengo: { [string]: boolean },
	Especiales: { [string]: boolean }, -- Extras: la del premio diario y las de equipo
	Mutantes: { [string]: boolean },
	Pistas: { [string]: number },
	Compradas: number,
	ADN: number,
}

type Tarjeta = {
	Cas: UI.Casillero,
	Criatura: Fusion.Criatura,
	Marca: string?, -- lo último que mostró ("D", "DM" o "S"); la vista se rearma solo si cambia
}

type Pagina = {
	Marco: Frame,
	Grilla: UIGridLayout?,
	Grupo: VistasVisibles.Grupo?,
}

local function estado(): Estado
	return {
		Tengo = Formato.conjunto(jugador:GetAttribute("Especies") :: string?),
		Especiales = Formato.conjunto(jugador:GetAttribute("Especiales") :: string?),
		Mutantes = Formato.conjunto(jugador:GetAttribute("Mutantes") :: string?),
		Pistas = Pistas.leer(jugador:GetAttribute("Pistas") :: string?),
		Compradas = (jugador:GetAttribute("PistasCompradas") :: number?) or 0,
		ADN = (jugador:GetAttribute("ADN") :: number?) or 0,
	}
end

local tarjetas: { [string]: Tarjeta } = {}
local paginas: { [string]: Pagina } = {}
local seleccionada: string? = nil
local paginaActual = "1"
local celular = false

---------------------------------------------------------------------------
-- Ventana y encabezado
---------------------------------------------------------------------------

local ventana = UI.ventana({
	Titulo = "Mutadex",
	Icono = "libro",
	ColorIcono = Paleta.Generaciones[3],
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

local progreso = UI.hueco(
	"Progreso",
	UDim2.fromOffset(T.AnchoProgreso, Tema.ContadorVentana.Y),
	ventana.Encabezado
)
progreso.AnchorPoint = Vector2.new(1, 0.5)
progreso.Position = UDim2.new(
	1,
	-(Tema.Relleno + Tema.Toque + Tema.Separacion * 2 + Tema.ContadorVentana.X),
	0.5,
	0
)
local textoProgreso = UI.texto({
	Nombre = "Contador",
	Texto = "0 / " .. #TODAS,
	Letra = Tema.Letra.Numero,
	Medida = UDim2.new(1, 0, 1, -Tema.Separacion * 2),
})
textoProgreso.Parent = progreso
local barra = UI.barra(Paleta.Acento)
barra.Marco.AnchorPoint = Vector2.new(0, 1)
barra.Marco.Position = UDim2.fromScale(0, 1)
barra.Marco.Parent = progreso

---------------------------------------------------------------------------
-- Pestañas y páginas
---------------------------------------------------------------------------

local mostrarPagina: (clave: string) -> ()

local pestanas = UI.pestanas({
	{ Clave = "1", Texto = "Gen 1" },
	{ Clave = "2", Texto = "Gen 2" },
	{ Clave = "3", Texto = "Gen 3" },
	{ Clave = "Extras", Texto = "Extras", Icono = "rombo", ColorIcono = Paleta.Dorado },
}, function(clave: string)
	mostrarPagina(clave)
end)
pestanas.Marco.Parent = ventana.Cuerpo

local arriba = Tema.Toque + Tema.Separacion
local contenido = UI.hueco("Contenido", UDim2.new(1, 0, 1, -arriba), ventana.Cuerpo)
contenido.Position = UDim2.fromOffset(0, arriba)
local paginasMarco = UI.hueco("Paginas", UDim2.fromScale(1, 1), contenido)

-- Una página por generación y Extras (las especiales: no cuentan en las 50 y no se compran).
for _, clave in { "1", "2", "3", "Extras" } do
	local gen = tonumber(clave)
	local marco = UI.hueco(if gen then "Gen" .. gen else clave, UDim2.fromScale(1, 1), paginasMarco)
	marco.Visible = false
	local nota = UI.texto({
		Nombre = "Nota",
		Texto = if gen then NOTAS[gen] else NOTA_EXTRAS,
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica,
		Color = if gen then Paleta.Generaciones[gen] else Paleta.Dorado,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, 0, 0, T.AltoNota),
	})
	nota.Parent = marco
	local scroll = UI.desplazable("Lista", marco)
	scroll.Position = UDim2.fromOffset(0, T.AltoNota)
	scroll.Size = UDim2.new(1, 0, 1, -T.AltoNota)
	paginas[clave] = {
		Marco = marco,
		Grilla = UI.grilla(scroll, Vector2.new(T.AltoTarjeta.Minimo, T.AltoTarjeta.Minimo)),
		Grupo = VistasVisibles.nueva(scroll),
	}
end

---------------------------------------------------------------------------
-- Ficha de la especie
---------------------------------------------------------------------------

local ficha = UI.tarjeta({ Nombre = "Ficha" })
ficha.Marco.Parent = contenido
local fichaLista = UI.desplazable("Datos", ficha.Fondo)
local listaFicha = UI.lista(fichaLista, false, Tema.Separacion)
listaFicha.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function fila(nombre: string, orden: number): (Frame, Frame, TextLabel)
	local f = UI.hueco(nombre, UDim2.new(1, 0, 0, T.FilaFicha), fichaLista)
	f.LayoutOrder = orden
	local l = UI.lista(f, true, Tema.Separacion)
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	local icono = UI.hueco("Icono", UDim2.fromOffset(0, T.FilaFicha), f)
	icono.AutomaticSize = Enum.AutomaticSize.X
	icono.LayoutOrder = 1
	UI.lista(icono, true, 4).VerticalAlignment = Enum.VerticalAlignment.Center
	local t = UI.texto({
		Nombre = "Texto",
		Fuente = "fuerte",
		Letra = Tema.Letra.Normal,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -T.FilaFicha * 2, 1, 0),
	})
	t.TextWrapped = false
	t.LayoutOrder = 2
	t.Parent = f
	return f, icono, t
end

local function vaciar(contenedor: Instance)
	for _, h in contenedor:GetChildren() do
		if h:IsA("GuiObject") then
			h:Destroy()
		end
	end
end

-- La criatura grande va arriba en computadora y a la izquierda en celular (ver el acomodo).
local vistaHueco = UI.hueco("Criatura", UDim2.new(1, 0, 0, T.VistaFicha), ficha.Fondo)
local fichaVista = Instance.new("ViewportFrame")
fichaVista.Name = "Vista"
fichaVista.BackgroundTransparency = 1
fichaVista.Size = UDim2.fromScale(1, 1)
fichaVista.Parent = vistaHueco
local signoFicha = UI.Iconos.crear("pregunta", Tema.MarcaChica + Tema.Separacion, Paleta.Texto)
signoFicha.AnchorPoint = Vector2.new(1, 0)
signoFicha.Position = UDim2.fromScale(1, 0)
signoFicha.Parent = vistaHueco
local estrellaFicha = UI.Iconos.crear("estrella", Tema.MarcaChica + Tema.Separacion, Paleta.Mutante)
estrellaFicha.AnchorPoint = Vector2.new(1, 0)
estrellaFicha.Position = UDim2.fromScale(1, 0)
estrellaFicha.Parent = vistaHueco

local fichaNombre = UI.texto({
	Nombre = "Nombre",
	Letra = Tema.Letra.Titulo,
	Medida = UDim2.new(1, 0, 0, Tema.Letra.Titulo + Tema.Separacion),
})
fichaNombre.LayoutOrder = 2
fichaNombre.Parent = fichaLista

local filaGen, iconoGen, textoGen = fila("Generacion", 3)
local filaElemento, iconoElemento, textoElemento = fila("Elemento", 4)
local filaPersonalidad, iconoPersonalidad, textoPersonalidad = fila("Personalidad", 5)
-- Los sellos ocupan el ancho: el texto es solo "3/8".
textoPersonalidad.Size = UDim2.new(0, T.FilaFicha * 2, 1, 0)
local personalidadesFicha = ""
-- Variantes: un ícono por catalizador, de su color si ya la conseguiste.
local filaVariantes, iconoVariantes, textoVariantes = fila("Variantes", 6)
textoVariantes.Size = UDim2.new(0, T.FilaFicha * 2, 1, 0)
local variantesFicha = ""

local fichaDetalle = UI.texto({
	Nombre = "Detalle",
	Fuente = "fuerte",
	Letra = Tema.Letra.Chica,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.fromScale(1, 0),
})
fichaDetalle.AutomaticSize = Enum.AutomaticSize.Y
fichaDetalle.LayoutOrder = 8
fichaDetalle.Parent = fichaLista

local botonPista = UI.boton({
	Nombre = "Pista",
	Texto = "Comprar pista",
	Sub = "",
	Icono = "lupa",
	Tipo = "principal",
	Letra = Tema.Letra.Subtitulo,
	Medida = UDim2.new(1, 0, 0, Tema.Toque + Tema.Profundidad),
})
botonPista.Marco.LayoutOrder = 9
botonPista.Marco.Parent = fichaLista

-- Sacar a pasear (Parte 9): una criatura de esta especie te sigue por el mapa y la ven todos.
local botonPaseo = UI.boton({
	Nombre = "Paseo",
	Texto = "Sacar a pasear",
	Sub = "Te sigue y la ven todos",
	Icono = "criatura",
	Tipo = "secundario",
	Letra = Tema.Letra.Subtitulo,
	Medida = UDim2.new(1, 0, 0, Tema.Toque + Tema.Profundidad),
})
botonPaseo.Marco.LayoutOrder = 7 -- arriba del detalle (que es largo), así se ve sin desplazar
botonPaseo.Marco.Parent = fichaLista

local ayuda = UI.texto({
	Nombre = "Ayuda",
	Texto = AYUDA,
	Fuente = "fuerte",
	Letra = Tema.Letra.Normal,
	Color = Paleta.Texto,
	Medida = UDim2.fromScale(1, 0),
})
ayuda.AutomaticSize = Enum.AutomaticSize.Y
ayuda.LayoutOrder = 10
ayuda.Parent = fichaLista

-- En celular la ficha tapa la grilla: se cierra con su propia X.
local cerrarFicha = UI.botonCerrar()
cerrarFicha.Marco.AnchorPoint = Vector2.new(1, 0)
cerrarFicha.Marco.Position = UDim2.new(1, -Tema.Separacion, 0, Tema.Separacion)
cerrarFicha.Marco.ZIndex = 5
cerrarFicha.Marco.Parent = ficha.Fondo

local modeloFicha: Model? = nil
local marcaFicha: string? = nil
local angulo = 0
local giro: RBXScriptConnection? = nil

-- Con qué bases se arma, en palabras.
local function receta(c: Fusion.Criatura): string
	local nombres = {}
	for _, b in c.Bases do
		table.insert(nombres, Especies[b].Nombre)
	end
	if c.Equipo then
		return "Receta (en equipo): "
			.. nombres[1]
			.. " + "
			.. nombres[2]
			.. ", una de cada jugador."
	elseif c.Especial then
		return "Premio del día 7 del premio diario. No se fusiona."
	end
	if c.Gen == 1 then
		return "Especie base n.º "
			.. c.Bases[1]
			.. " de la rueda ("
			.. Especies[c.Bases[1]].Tema
			.. ")."
	elseif c.Gen == 2 then
		return "Receta: " .. nombres[1] .. " + " .. nombres[2] .. "."
	end
	return "Receta: mezcla de " .. nombres[1] .. ", " .. nombres[2] .. " y " .. nombres[3] .. "."
end

local function actualizarFicha(e: Estado)
	local c = if seleccionada then Fusion.porClave(seleccionada) else nil
	ficha.Marco.Visible = c ~= nil or not celular
	ayuda.Visible = c == nil
	if not celular then
		-- Sin especie elegida, la ayuda sube al lugar de la criatura.
		local alto = if c then T.VistaFicha else 0
		fichaLista.Position = UDim2.fromOffset(0, alto)
		fichaLista.Size = UDim2.new(1, 0, 1, -alto)
	end
	for _, x in
		{
			vistaHueco,
			fichaNombre,
			filaGen,
			filaElemento,
			filaPersonalidad,
			filaVariantes,
			fichaDetalle,
		} :: { GuiObject }
	do
		x.Visible = c ~= nil
	end
	botonPista.Marco.Visible = false
	botonPaseo.Marco.Visible = false
	if not c then
		marcaFicha = nil
		modeloFicha = Vista.mostrar(fichaVista, nil)
		return
	end

	local descubierta = conocida(e, c)
	local mutante = descubierta and e.Mutantes[c.Clave] == true
	local marca = c.Clave .. (if descubierta then "D" else "S") .. (if mutante then "M" else "")
	if marcaFicha ~= marca then
		marcaFicha = marca
		angulo = 0
		modeloFicha = Vista.mostrar(fichaVista, c.Clave, mutante, not descubierta)
		fichaLista.CanvasPosition = Vector2.zero
	end
	signoFicha.Visible = not descubierta
	estrellaFicha.Visible = mutante
	fichaNombre.Text = if descubierta then c.Nombre else "???"

	vaciar(iconoGen)
	UI.puntosGen(c.Gen, 20).Parent = iconoGen
	textoGen.Text = "Generación " .. c.Gen

	vaciar(iconoElemento)
	vaciar(iconoPersonalidad)
	if descubierta then
		UI.puntoElemento(Generador.colorElemento(c), 24).Parent = iconoElemento
		textoElemento.Text = Elementos.texto(c)
		-- Sellos: las personalidades que ya conseguiste de esta especie.
		local sellos = Formato.conjunto(jugador:GetAttribute("Sellos") :: string?)
		local nombres = {}
		for _, p in Personalidades.Orden do
			if sellos[c.Clave .. "|" .. p] then
				table.insert(nombres, Personalidades.Datos[p].Nombre)
				local s = UI.selloPersonalidad(p, T.FilaFicha - 4)
				if s then
					s.LayoutOrder = #nombres
					s.Parent = iconoPersonalidad
				end
			end
		end
		textoPersonalidad.Text = #nombres .. "/" .. #Personalidades.Orden
		personalidadesFicha = if #nombres > 0
			then "\nPersonalidades: " .. table.concat(nombres, ", ") .. "."
			else ""
	else
		UI.Iconos.crear("pregunta", T.FilaFicha, Paleta.Metal).Parent = iconoElemento
		textoElemento.Text = "Elemento: ???"
		UI.Iconos.crear("pregunta", T.FilaFicha, Paleta.Metal).Parent = iconoPersonalidad
		textoPersonalidad.Text = "???"
	end

	vaciar(iconoVariantes)
	variantesFicha = ""
	if descubierta then
		local conseguidas = Formato.conjunto(jugador:GetAttribute("Variantes") :: string?)
		local nombres = {}
		for orden, cat in Catalizadores.Lista do
			local tiene = conseguidas[c.Clave .. "|" .. cat.Clave] == true
			if tiene then
				table.insert(nombres, Catalizadores.nombre(c.Nombre, cat.Clave))
			end
			local i = UI.Iconos.crear(
				cat.Icono,
				T.FilaFicha - 6,
				if tiene then cat.Color else Paleta.Metal
			)
			i.LayoutOrder = orden
			i.Parent = iconoVariantes
		end
		textoVariantes.Text = #nombres .. "/" .. #Catalizadores.Lista
		if #nombres > 0 then
			variantesFicha = "\nVariantes: " .. table.concat(nombres, ", ") .. "."
		end
	else
		UI.Iconos.crear("pregunta", T.FilaFicha, Paleta.Metal).Parent = iconoVariantes
		textoVariantes.Text = "???"
	end

	if descubierta then
		local cuenta = Formato.inventario(jugador:GetAttribute("Criaturas") :: string?)[c.Clave]
		local cuantas = if cuenta then cuenta.Normales + cuenta.Mutantes else 0
		fichaDetalle.Text = receta(c)
			.. "\nEn tu laboratorio: "
			.. cuantas
			.. personalidadesFicha
			.. variantesFicha
			.. (if mutante then "\n¡La tenés mutante!" else "")
		fichaDetalle.TextColor3 = if mutante then Paleta.Dorado else Paleta.Texto
		-- Sacar a pasear una de las tuyas (o guardarla si ya está paseando).
		botonPaseo.Marco.Visible = cuantas > 0
		if jugador:GetAttribute("Paseo") == c.Clave then
			botonPaseo.poner("Guardarla", "Vuelve a tu laboratorio")
		else
			botonPaseo.poner("Sacar a pasear", "Te sigue y la ven todos")
		end
		return
	end
	fichaDetalle.TextColor3 = Paleta.Texto
	if c.Equipo then
		fichaDetalle.Text =
			"Todavía no la descubriste. Especie de equipo: solo sale en la máquina de equipo de la plaza, con una criatura tuya y una de otro jugador."
		return
	elseif c.Especial then
		fichaDetalle.Text =
			"Todavía no la tenés. Es la especie especial del día 7 del premio diario (menú Misiones)."
		return
	end
	if c.Gen == 1 then
		fichaDetalle.Text = "Todavía no la tenés. Las especies base se compran en la tienda."
		return
	end

	-- Silueta: las pistas compradas y el botón para la siguiente.
	local n = e.Pistas[c.Clave] or 0
	local maximo = Pistas.maximo(c)
	local lineas = {}
	for i = 1, n do
		table.insert(lineas, "Pista " .. i .. ": " .. Pistas.texto(c, i))
	end
	if n == 0 then
		table.insert(
			lineas,
			"Todavía no la descubriste. Mirá la forma de la silueta o comprá una pista."
		)
	end
	fichaDetalle.Text = table.concat(lineas, "\n")
	botonPista.Marco.Visible = true
	if n >= maximo then
		botonPista.poner("Sin más pistas", n .. " de " .. maximo)
		botonPista.colorSub(Paleta.Texto)
		botonPista.habilitar(false)
	elseif ((jugador:GetAttribute("PistasGratis") :: number?) or 0) > 0 then
		-- Pistas que ganaste con pedidos: no se cobran.
		botonPista.poner("Pista " .. (n + 1) .. " de " .. maximo, "Gratis (premio de pedido)")
		botonPista.colorSub(Paleta.Dorado)
		botonPista.habilitar(true)
	else
		local costo = Pistas.costo(e.Compradas)
		local alcanza = e.ADN >= costo
		botonPista.poner("Pista " .. (n + 1) .. " de " .. maximo, Formato.numero(costo) .. " ADN")
		botonPista.colorSub(if alcanza then Paleta.Texto else Paleta.Error)
		botonPista.habilitar(alcanza)
	end
end

---------------------------------------------------------------------------
-- Tarjetas
---------------------------------------------------------------------------

local function pintarTarjeta(t: Tarjeta, e: Estado)
	local c = t.Criatura
	local descubierta = conocida(e, c)
	local mutante = descubierta and e.Mutantes[c.Clave] == true
	local marca = (if descubierta then "D" else "S") .. (if mutante then "M" else "")
	local pagina = paginas[paginaDe(c)]
	local grupo = pagina.Grupo :: VistasVisibles.Grupo
	if t.Marca ~= marca then
		local datos = { Clave = c.Clave, Mutante = mutante, Silueta = not descubierta }
		if t.Marca == nil then
			grupo.agregar(t.Cas.Marco, t.Cas.Hueco, datos)
		else
			grupo.cambiar(t.Cas.Marco, datos)
		end
		t.Marca = marca
		t.Cas.elemento(if descubierta then Generador.colorElemento(c) else nil)
	end
	local nombre = c.Nombre
	if not descubierta then
		local n = e.Pistas[c.Clave] or 0
		nombre = if n == 1
			then "??? · 1 pista"
			elseif n > 1 then "??? · " .. n .. " pistas"
			else "???"
	end
	t.Cas.poner(c.Clave, nombre, mutante, not descubierta)
	if seleccionada == c.Clave then
		t.Cas.Borde.Color = Paleta.Acento
		t.Cas.Borde.Thickness = Tema.Contorno + 3
	else
		t.Cas.Borde.Color = if not descubierta
			then Paleta.Metal
			elseif c.Especial then Paleta.Dorado
			else Paleta.Generaciones[c.Gen]
		t.Cas.Borde.Thickness = Tema.Contorno + 1
	end
end

local function actualizarTodo()
	local e = estado()
	local total = 0
	local porGen = { 0, 0, 0 }
	local deGen = { 0, 0, 0 }
	for _, c in TODAS do
		deGen[c.Gen] += 1
		if e.Tengo[c.Clave] then
			total += 1
			porGen[c.Gen] += 1
		end
		pintarTarjeta(tarjetas[c.Clave], e)
	end
	local extras = 0
	for _, c in EXTRAS do
		if e.Especiales[c.Clave] then
			extras += 1
		end
		pintarTarjeta(tarjetas[c.Clave], e)
	end
	for gen = 1, 3 do
		pestanas.Botones[tostring(gen)].poner(
			"Gen " .. gen .. " · " .. porGen[gen] .. "/" .. deGen[gen]
		)
	end
	pestanas.Botones.Extras.poner("Extras · " .. extras .. "/" .. #EXTRAS)
	textoProgreso.Text = total .. " / " .. #TODAS
	barra.poner(total / #TODAS)
	contadorADN.Valor.Text = Formato.numero(e.ADN)
	actualizarFicha(e)
end

local function elegir(clave: string)
	-- SONIDO: tocar una tarjeta de la Mutadex (nota corta)
	Sonidos.nota(9, 0.3)
	seleccionada = clave
	actualizarTodo()
end

local lista = table.clone(TODAS)
for _, c in EXTRAS do
	table.insert(lista, c)
end
for orden, c in lista do
	local cas = UI.casillero({
		Nombre = c.Clave,
		Medida = UDim2.fromOffset(T.AltoTarjeta.Minimo, T.AltoTarjeta.Minimo),
		Borde = Paleta.Metal,
		Signo = "?",
		Prestada = true,
	})
	cas.Signo.TextColor3 = Paleta.Texto
	cas.Marco.LayoutOrder = orden
	local pagina = paginas[paginaDe(c)]
	cas.Marco.Parent = pagina.Marco:FindFirstChild("Lista")
	UI.tocable(cas.Fondo, function()
		elegir(c.Clave)
	end, cas.Marco)
	tarjetas[c.Clave] = { Cas = cas, Criatura = c, Marca = nil }
end

function mostrarPagina(clave: string)
	paginaActual = clave
	for k, p in paginas do
		p.Marco.Visible = k == clave
	end
	local p = paginas[clave]
	if p and p.Grupo then
		p.Grupo.actualizar()
	end
end

---------------------------------------------------------------------------
-- Acomodo (computadora o celular)
---------------------------------------------------------------------------

ventana.alAcomodar(function(tam: Vector2)
	celular = UI.Pantalla.esCelular()
	local anchoCuerpo = tam.X - Tema.Relleno * 2
	local anchoPaginas = if celular
		then anchoCuerpo
		else anchoCuerpo - T.AnchoFicha - Tema.Separacion
	paginasMarco.Size = UDim2.new(0, anchoPaginas, 1, 0)
	if celular then
		ficha.Marco.Position = UDim2.new()
		ficha.Marco.Size = UDim2.fromScale(1, 1)
		ficha.Marco.ZIndex = 10
	else
		ficha.Marco.Position = UDim2.fromOffset(anchoPaginas + Tema.Separacion, 0)
		ficha.Marco.Size = UDim2.new(0, T.AnchoFicha, 1, 0)
		ficha.Marco.ZIndex = 1
	end
	cerrarFicha.Marco.Visible = celular
	if celular then
		-- Dos columnas: la criatura a la izquierda y los datos a la derecha (con la X).
		vistaHueco.Position = UDim2.fromOffset(0, 0)
		vistaHueco.Size = UDim2.fromScale(0.42, 1)
		fichaLista.Position = UDim2.fromScale(0.42, 0)
		fichaLista.Size = UDim2.new(0.58, -(Tema.Toque + Tema.Separacion), 1, 0)
	else
		vistaHueco.Position = UDim2.fromOffset(0, 0)
		vistaHueco.Size = UDim2.new(1, 0, 0, T.VistaFicha)
		fichaLista.Position = UDim2.fromOffset(0, T.VistaFicha)
		fichaLista.Size = UDim2.new(1, 0, 1, -T.VistaFicha)
	end
	local columnas = if celular then T.ColumnasCelular else T.Columnas
	local ancho = UI.anchoCelda(UI.anchoUtil(anchoPaginas), columnas)
	local alto = math.clamp(
		math.floor(ancho * T.AltoTarjeta.Proporcion),
		T.AltoTarjeta.Minimo,
		T.AltoTarjeta.Maximo
	)
	for _, p in paginas do
		if p.Grilla then
			p.Grilla.CellSize = UDim2.fromOffset(ancho, alto)
		end
	end
	if ventana.Marco.Visible then
		actualizarTodo()
	end
end)

---------------------------------------------------------------------------
-- Conexiones
---------------------------------------------------------------------------

cerrarFicha.AlTocar = function()
	seleccionada = nil
	actualizarTodo()
end

botonPista.AlTocar = function()
	if seleccionada then
		comprarPista:FireServer(seleccionada)
	end
end

botonPaseo.AlTocar = function()
	if not seleccionada then
		return
	end
	-- SONIDO: sacar a pasear (dos notas que suben) o guardarla
	Sonidos.secuencia({ 0, 7 }, 0.08, 0.3)
	pasear:FireServer(if jugador:GetAttribute("Paseo") == seleccionada then nil else seleccionada)
end

compra.OnClientEvent:Connect(function(tipo: string)
	if tipo == "Pista" and ventana.Marco.Visible then
		-- SONIDO: pista comprada (dos notas que suben)
		Sonidos.secuencia({ 4, 11 }, 0.08, 0.35)
		UI.destello(ficha.Fondo, Paleta.Acento, ficha.Marco)
		contadorADN.rebotar(0.15)
	end
end)

Menus.registrar("Mutadex", ventana, function()
	actualizarTodo()
	mostrarPagina(paginaActual)
	if not giro then
		giro = RunService.RenderStepped:Connect(function(dt: number)
			local m = modeloFicha
			if m and m.Parent then
				angulo += dt * T.Giro
				m:PivotTo(CFrame.Angles(0, angulo, 0))
			end
		end)
	end
end, function()
	if giro then
		giro:Disconnect()
		giro = nil
	end
end)

for _, atributo in
	{
		"Especies",
		"Mutantes",
		"Criaturas",
		"Sellos",
		"Variantes",
		"Especiales",
		"Paseo",
		"Pistas",
		"PistasCompradas",
		"PistasGratis",
		"ADN",
	}
do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		if ventana.Marco.Visible then
			actualizarTodo()
		end
	end)
end

pestanas.elegir("1")
actualizarTodo()
