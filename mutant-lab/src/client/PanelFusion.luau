--!strict
-- Panel de la máquina de fusión (ficha, "Guía de estilo", 6, "Menú de fusión"), armado por
-- código con los componentes de UI:
--   arriba, los casilleros de los padres (izquierda verde ácido, derecha magenta) con un "+"
--   entre ellos y, sobre el "+", el del catalizador (con candado hasta Config.Residuos.RanuraDesde
--   especies; tocarlo pasa por los catalizadores que tenés);
--   después del "=", la vista previa: el resultado si ya lo tenés, "?" si no;
--   a la derecha, qué va a pasar y el botón "¡FUSIONAR!" con el costo;
--   abajo, tus criaturas en casilleros con el borde de su generación, filtrables por elemento.
-- Tocar una criatura la hace saltar al casillero libre; tocar un casillero lleno lo vacía.
-- Se abre con la consola de la máquina (Maquina.client) y se abre y cierra con UI/Menus.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Elementos = require(ReplicatedStorage.Shared.Elementos)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local Notificaciones = require(script.Parent.UI.Notificaciones)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)
local Vista = require(script.Parent.Vista)

-- Una criatura elegida: su especie y su personalidad (la cría hereda la personalidad).
export type Eleccion = { Clave: string, Personalidad: string? }

export type Eventos = {
	AlElegir: (lado: string, eleccion: Eleccion?) -> (),
	AlCatalizador: (clave: string?) -> (),
	AlConfirmar: (a: Eleccion, b: Eleccion, catalizador: string?) -> (),
}

type Item = {
	Cas: UI.Casillero,
	Criatura: Fusion.Criatura,
	Personalidad: string?,
	Mutante: boolean,
}

local Tema = UI.Tema
local T = Tema.Fusion
local jugador = Players.LocalPlayer

local COLOR_LADO: { [string]: Color3 } = { A = Paleta.Acento, B = Paleta.Alerta }
local ALTO_BOTON_FILTRO = T.Filtro + Tema.Profundidad

local seleccion: { [string]: Eleccion } = {}
local items: { [string]: Item } = {} -- "especie|personalidad" -> tarjeta
local eventos: Eventos? = nil
local ocupada = false
local avisoServidor: string? = nil
local filtro: string? = nil -- elemento elegido (nil = todos)
local catElegido: string? = nil -- catalizador puesto en la ranura (nil = ninguno)

local function conjunto(atributo: string): { [string]: boolean }
	return Formato.conjunto(jugador:GetAttribute(atributo) :: string?)
end

local function adn(): number
	return (jugador:GetAttribute("ADN") :: number?) or 0
end

local function cantidad(t: { [string]: boolean }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

local function llave(e: Eleccion): string
	return e.Clave .. "|" .. (e.Personalidad or "")
end

---------------------------------------------------------------------------
-- Ventana y encabezado
---------------------------------------------------------------------------

local V = Tema.Ventana
local ventana = UI.ventana({
	Titulo = "Máquina de fusión",
	Icono = "adn",
	ColorIcono = Paleta.Acento,
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

local cuerpo = ventana.Cuerpo

---------------------------------------------------------------------------
-- La máquina: padres, catalizador, vista previa, estado y botón
---------------------------------------------------------------------------

local maquina = UI.hueco("Maquina", UDim2.new(1, 0, 0, T.AltoMaquina), cuerpo)

local function casilleroPadre(lado: string): UI.Casillero
	local c = UI.casillero({
		Nombre = "Padre" .. lado,
		Medida = UDim2.fromOffset(T.Padre.X, T.Padre.Y),
		Borde = COLOR_LADO[lado],
		Signo = "+",
		Titulo = "Elegí una",
	})
	c.Signo.TextColor3 = COLOR_LADO[lado]
	c.Marco.AnchorPoint = Vector2.new(0, 1)
	c.Marco.Parent = maquina
	return c
end

local padres: { [string]: UI.Casillero } = { A = casilleroPadre("A"), B = casilleroPadre("B") }

local catalizador = UI.casillero({
	Nombre = "Catalizador",
	Medida = UDim2.fromOffset(T.Catalizador.X, T.Catalizador.Y),
	Borde = Paleta.Metal,
	Titulo = "Catalizador",
	Candado = true,
})
catalizador.Marco.AnchorPoint = Vector2.new(0.5, 0)
catalizador.Marco.Parent = maquina
if catalizador.Nombre then
	-- "Residuos 3/5" entra en el casillero chico.
	catalizador.Nombre.TextScaled = true
	local tope = Instance.new("UITextSizeConstraint")
	tope.MaxTextSize = Tema.Letra.Chica
	tope.Parent = catalizador.Nombre
end

local mas = UI.Iconos.crear("mas", T.Signo, Paleta.Texto)
mas.Parent = maquina
local igual = UI.Iconos.crear("igual", T.Signo, Paleta.Texto)
igual.Parent = maquina

local previa = UI.casillero({
	Nombre = "Previa",
	Medida = UDim2.fromOffset(T.Padre.X, T.Padre.Y),
	Borde = Paleta.Metal,
	Signo = "?",
	Titulo = "Resultado",
})
previa.Marco.AnchorPoint = Vector2.new(0, 1)
previa.Marco.Parent = maquina
-- La gota del residuo (cuando la pareja no reacciona), del color mezclado de los dos.
local gotaResiduo = UI.Iconos.crear("gota", T.Padre.X * 0.5, Paleta.Residuo)
gotaResiduo.Visible = false
gotaResiduo.Parent = previa.Hueco

-- Columna de la derecha: qué va a pasar y el botón.
local derecha = UI.hueco("Derecha", UDim2.new(), maquina)
local estado = UI.texto({
	Nombre = "Estado",
	Fuente = "fuerte",
	Letra = Tema.Letra.Normal,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(1, 0, 1, -T.AltoBoton - Tema.Separacion - (T.AltoMaquina - T.Padre.Y)),
})
estado.TextYAlignment = Enum.TextYAlignment.Top
estado.Position = UDim2.fromOffset(0, T.AltoMaquina - T.Padre.Y)
estado.Parent = derecha

local boton = UI.boton({
	Nombre = "Fusionar",
	Texto = "¡FUSIONAR!",
	Sub = "Elegí 2 criaturas",
	Tipo = "principal",
	Letra = Tema.Letra.Titulo,
	LetraSub = Tema.Letra.Chica,
	Medida = UDim2.fromOffset(T.AnchoBoton, T.AltoBoton),
})
boton.Marco.AnchorPoint = Vector2.new(0, 1)
boton.Marco.Position = UDim2.fromScale(0, 1)
boton.Marco.Parent = derecha

-- Todo en una fila, medido desde la izquierda.
do
	local x = 0
	padres.A.Marco.Position = UDim2.new(0, x, 1, 0)
	x += T.Padre.X + Tema.Separacion
	catalizador.Marco.Position = UDim2.fromOffset(x + T.Columna / 2, 0)
	mas.Position = UDim2.new(0, x + T.Columna / 2, 1, -T.Padre.Y / 2)
	x += T.Columna + Tema.Separacion
	padres.B.Marco.Position = UDim2.new(0, x, 1, 0)
	x += T.Padre.X + Tema.Separacion
	igual.Position = UDim2.new(0, x + T.Signo / 2, 1, -T.Padre.Y / 2)
	x += T.Signo + Tema.Separacion
	previa.Marco.Position = UDim2.new(0, x, 1, 0)
	x += T.Padre.X + Tema.Relleno
	derecha.Position = UDim2.fromOffset(x, 0)
	derecha.Size = UDim2.new(1, -x, 1, 0)
end

---------------------------------------------------------------------------
-- Tus criaturas: filtros por elemento y lista
---------------------------------------------------------------------------

local filaFiltros = UI.hueco("Filtros", UDim2.new(1, 0, 0, ALTO_BOTON_FILTRO), cuerpo)
filaFiltros.Position = UDim2.fromOffset(0, T.AltoMaquina + Tema.Separacion)
local listaFiltros = UI.lista(filaFiltros, true, Tema.Separacion)
listaFiltros.VerticalAlignment = Enum.VerticalAlignment.Center

local tituloLista = UI.texto({
	Nombre = "Titulo",
	Texto = "Tus criaturas",
	Letra = Tema.Letra.Subtitulo,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(0, T.Padre.X * 2, 1, 0),
})
tituloLista.TextWrapped = false
tituloLista.LayoutOrder = 0
tituloLista.Parent = filaFiltros

local arribaLista = T.AltoMaquina + Tema.Separacion * 2 + ALTO_BOTON_FILTRO
local lista = UI.desplazable("Criaturas", cuerpo)
lista.Position = UDim2.fromOffset(0, arribaLista)
lista.Size = UDim2.new(1, 0, 1, -arribaLista)
UI.grilla(lista, T.Criatura)
local grupo = VistasVisibles.nueva(lista)

local vacio = UI.texto({
	Nombre = "Vacio",
	Texto = "No tenés criaturas de este elemento todavía.",
	Fuente = "fuerte",
	Letra = Tema.Letra.Normal,
	Color = Paleta.Metal,
	Medida = UDim2.new(1, 0, 0, T.Criatura.Y),
})
vacio.Position = UDim2.fromOffset(0, arribaLista)
vacio.Visible = false
vacio.Parent = cuerpo

local botonesFiltro: { [string]: UI.Boton } = {}

local function aplicarFiltro()
	local hay = 0
	for _, it in items do
		local ve = filtro == nil or Elementos.tiene(it.Criatura, filtro :: string)
		it.Cas.Marco.Visible = ve
		if ve then
			hay += 1
		end
	end
	vacio.Visible = hay == 0
	for clave, b in botonesFiltro do
		b.resaltar(clave == (filtro or "Todos"))
	end
	grupo.actualizar()
end

local function botonFiltro(clave: string?, orden: number)
	local b = UI.boton({
		Nombre = clave or "Todos",
		Texto = if clave then nil else "Todos",
		Color = if clave then Paleta.Elementos[clave] else Paleta.Metal,
		Redondo = clave ~= nil,
		Letra = Tema.Letra.Chica,
		Medida = UDim2.fromOffset(if clave then T.Filtro else T.AnchoTodos, ALTO_BOTON_FILTRO),
		AlTocar = function()
			filtro = clave
			aplicarFiltro()
		end,
	})
	b.Marco.LayoutOrder = orden
	b.Marco.Parent = filaFiltros
	botonesFiltro[clave or "Todos"] = b
end

botonFiltro(nil, 1)
for i, e in Elementos.Orden do
	botonFiltro(e, i + 1)
end

---------------------------------------------------------------------------
-- La ranura de catalizador
---------------------------------------------------------------------------

local function ranuraAbierta(): boolean
	return cantidad(conjunto("Especies")) >= Config.Residuos.RanuraDesde
end

local function tusCatalizadores(): { [string]: number }
	return Catalizadores.leer(jugador:GetAttribute("Catalizadores") :: string?)
end

local iconoCatalizador: Frame? = nil

-- Con candado hasta Config.Residuos.RanuraDesde especies; después, el catalizador elegido (o
-- un "+") y cuántos tenés. Sin catalizador elegido, cuántos residuos llevás para el próximo.
local function pintarRanura()
	local abierta = ranuraAbierta()
	local tus = tusCatalizadores()
	if catElegido and (not abierta or (tus[catElegido] or 0) < 1) then
		catElegido = nil
		if eventos then
			eventos.AlCatalizador(nil)
		end
	end
	catalizador.bloquear(not abierta)
	local cat = Catalizadores.porClave(catElegido)
	if iconoCatalizador and iconoCatalizador.Name ~= (catElegido or "") then
		iconoCatalizador:Destroy()
		iconoCatalizador = nil
	end
	if cat and not iconoCatalizador then
		local i = UI.Iconos.crear(cat.Icono, math.floor(T.Catalizador.Y * 0.42), cat.Color)
		i.Name = cat.Clave
		i.Parent = catalizador.Hueco
		iconoCatalizador = i
	end
	catalizador.Signo.Visible = abierta and cat == nil
	catalizador.Borde.Color = if cat
		then cat.Color
		elseif abierta then Paleta.Acento
		else Paleta.Metal
	local residuos = jugador:GetAttribute("Residuos") :: string?
	local cuantos = if residuos and residuos ~= "" then #string.split(residuos, ";") else 0
	if catalizador.Nombre then
		catalizador.Nombre.Text = if cat
			then cat.Nombre .. " ×" .. (tus[cat.Clave] or 0)
			else "Residuos " .. cuantos .. "/" .. Config.Residuos.ParaCatalizador
	end
end

---------------------------------------------------------------------------
-- Estado: vista previa, texto y botón
---------------------------------------------------------------------------

local function actualizar()
	pintarRanura()
	local cat = Catalizadores.porClave(catElegido)
	contadorADN.Valor.Text = Formato.numero(adn())
	local a, b = seleccion.A, seleccion.B
	local ca = if a then Fusion.porClave(a.Clave) else nil
	local cb = if b then Fusion.porClave(b.Clave) else nil
	local texto = ""
	local color = Paleta.Texto
	local listo = false

	previa.elemento(nil)
	previa.personalidad(nil)
	gotaResiduo.Visible = false
	if not ca or not cb then
		previa.poner(nil, "Resultado")
		previa.Signo.Text = "?"
		previa.Signo.TextColor3 = Paleta.Metal
		previa.Borde.Color = Paleta.Metal
		texto = if ca or cb
			then "Elegí una criatura más."
			else "Tocá dos criaturas de abajo para ponerlas en la máquina."
		boton.poner("¡FUSIONAR!", "Elegí 2 criaturas")
		boton.colorSub(Paleta.Texto)
	else
		local hijo = Fusion.fusionar(ca, cb)
		if not hijo then
			-- Se avisa antes de apretar: esa pareja nunca reacciona.
			-- No reaccionan: se dice por qué, y fusionar igual hace un residuo (gratis).
			previa.poner(nil, "Residuo")
			previa.Signo.Visible = false
			gotaResiduo.Visible = true
			local mezcla = ca.Color:Lerp(cb.Color, 0.5):Lerp(Paleta.Residuo, 0.35)
			for _, f in gotaResiduo:GetDescendants() do
				if f:IsA("Frame") and f.ZIndex == 1 then
					f.BackgroundColor3 = mezcla
				end
			end
			previa.Borde.Color = Paleta.Error
			texto = (Fusion.motivo(ca, cb) or "No reaccionan.")
				.. " Igual sale un residuo: con "
				.. Config.Residuos.ParaCatalizador
				.. " se arma un catalizador."
				.. (if cat then " El catalizador no se gasta." else "")
			color = Paleta.Alerta
			boton.poner("¡FUSIONAR!", "Sale un residuo (gratis)")
			boton.colorSub(Paleta.Texto)
			listo = true
		else
			local tengo = conjunto("Especies")
			local costo = Costos.fusion(ca.Gen, cb.Gen, cantidad(tengo)) or 0
			-- La personalidad de la cría sale de la de los padres (tabla fija de la ficha);
			-- algunos catalizadores la cambian.
			local clavePersonalidad = (cat and cat.Personalidad)
				or Personalidades.heredar(a and a.Personalidad, b and b.Personalidad)
			local hereda = Personalidades.Datos[clavePersonalidad or ""]
			if tengo[hijo.Clave] then
				-- Conocida: se muestra el resultado (no adelanta especies nuevas), con su
				-- personalidad y, si hay catalizador, como variante.
				local mutante = conjunto("Mutantes")[hijo.Clave]
				local nombre = Catalizadores.nombre(hijo.Nombre, catElegido)
				previa.poner(hijo.Clave, nombre, mutante)
				if previa.Vista and (cat or clavePersonalidad) then
					Vista.mostrar(
						previa.Vista,
						hijo.Clave,
						mutante,
						nil,
						clavePersonalidad,
						catElegido
					)
				end
				previa.elemento(Generador.colorElemento(hijo))
				previa.personalidad(clavePersonalidad)
				previa.Borde.Color = if cat then cat.Color else Paleta.Generaciones[hijo.Gen]
				local variantes = conjunto("Variantes")
				if cat and not variantes[hijo.Clave .. "|" .. cat.Clave] then
					texto = "¡Variante nueva! Sale el primer " .. nombre .. "."
					color = Paleta.Acento
				else
					texto = "Ya la tenés: sale otro " .. nombre .. " (quizás mutante)."
					color = Paleta.Alerta
				end
			else
				previa.poner(nil, "¡Nueva!")
				previa.Signo.Text = "?"
				previa.Signo.TextColor3 = Paleta.Acento
				previa.Borde.Color = Paleta.Acento
				texto = "¡Reaccionan! Va a salir una especie que todavía no tenés"
					.. (if cat then " (variante " .. cat.Apellido .. ")." else ".")
				color = Paleta.Acento
			end
			if hereda then
				-- "Las demás..." pasa a "las demás..." (solo la primera letra: "Líder" queda igual).
				local efecto = hereda.Efecto:sub(1, 1):lower() .. hereda.Efecto:sub(2)
				texto ..= "\nVa a ser " .. hereda.Nombre .. ": " .. efecto .. "."
			end
			local falta = costo - adn()
			if falta > 0 then
				boton.poner("¡FUSIONAR!", "Te faltan " .. Formato.numero(falta) .. " ADN")
				boton.colorSub(Paleta.Error)
			else
				boton.poner("¡FUSIONAR!", Formato.numero(costo) .. " ADN")
				boton.colorSub(Paleta.Texto)
				listo = true
			end
		end
	end
	if ocupada then
		boton.poner("¡FUSIONAR!", "Trabajando...")
		boton.colorSub(Paleta.Texto)
		listo = false
	end
	if avisoServidor then
		texto = avisoServidor :: string
		color = Paleta.Error
	end
	boton.habilitar(listo)
	estado.Text = texto
	estado.TextColor3 = color
end

---------------------------------------------------------------------------
-- Elegir criaturas
---------------------------------------------------------------------------

local function pintarItems()
	for k, it in items do
		local lado = if seleccion.A and llave(seleccion.A) == k
			then "A"
			elseif seleccion.B and llave(seleccion.B) == k then "B"
			else nil
		it.Cas.Borde.Color = if lado then COLOR_LADO[lado] else Paleta.Generaciones[it.Criatura.Gen]
		it.Cas.Borde.Thickness = if lado then Tema.Contorno + 3 else Tema.Contorno + 1
	end
end

local function mostrarPadre(lado: string)
	local e = seleccion[lado]
	local c = if e then Fusion.porClave(e.Clave) else nil
	local cas = padres[lado]
	cas.poner(
		if c then c.Clave else nil,
		if c then c.Nombre else nil,
		if c then conjunto("Mutantes")[c.Clave] else nil
	)
	cas.elemento(if c then Generador.colorElemento(c) else nil)
	cas.personalidad(if c and e then e.Personalidad else nil)
end

-- La criatura salta desde su casillero de la lista hasta el de la máquina.
local function saltar(desde: GuiObject, lado: string, e: Eleccion)
	local marco = ventana.Marco
	local hacia = padres[lado]
	if marco.Size.X.Offset <= 0 or marco.AbsoluteSize.X <= 0 then
		mostrarPadre(lado)
		return
	end
	local factor = marco.AbsoluteSize.X / marco.Size.X.Offset
	local inicio = (desde.AbsolutePosition - marco.AbsolutePosition) / factor
	local tamInicio = desde.AbsoluteSize / factor
	local fin = (hacia.Hueco.AbsolutePosition - marco.AbsolutePosition) / factor
	local tamFin = hacia.Hueco.AbsoluteSize / factor

	hacia.poner(nil, "")
	hacia.Signo.Visible = false
	hacia.personalidad(nil)
	local vuelo = Instance.new("ViewportFrame")
	vuelo.Name = "Vuelo"
	vuelo.BackgroundTransparency = 1
	vuelo.Position = UDim2.fromOffset(inicio.X, inicio.Y)
	vuelo.Size = UDim2.fromOffset(tamInicio.X, tamInicio.Y)
	vuelo.ZIndex = 30
	vuelo.Parent = ventana.Fondo
	Vista.mostrar(vuelo, e.Clave, conjunto("Mutantes")[e.Clave], nil, e.Personalidad)
	local t = UI.animar(vuelo, T.Salto, {
		Position = UDim2.fromOffset(fin.X, fin.Y),
		Size = UDim2.fromOffset(tamFin.X, tamFin.Y),
	})
	t.Completed:Once(function()
		vuelo:Destroy()
		if seleccion[lado] == e then
			mostrarPadre(lado)
			hacia.rebotar(0.12)
			-- SONIDO: la criatura cae en el casillero (nota corta)
			Sonidos.nota(if lado == "A" then 4 else 7, 0.35)
		end
	end)
end

local function poner(lado: string, e: Eleccion?, desde: GuiObject?)
	seleccion[lado] = e
	avisoServidor = nil
	if e and desde then
		saltar(desde, lado, e)
	else
		mostrarPadre(lado)
	end
	pintarItems()
	actualizar()
	if eventos then
		eventos.AlElegir(lado, e)
	end
end

local function elegir(e: Eleccion, desde: GuiObject)
	if ocupada then
		return
	end
	local k = llave(e)
	if seleccion.A and llave(seleccion.A) == k then
		poner("A", nil)
	elseif seleccion.B and llave(seleccion.B) == k then
		poner("B", nil)
	elseif not seleccion.A then
		poner("A", e, desde)
	else
		poner("B", e, desde)
	end
end

for lado, cas in padres do
	UI.tocable(cas.Fondo, function()
		if seleccion[lado] and not ocupada then
			poner(lado, nil)
			cas.rebotar(-0.08)
		end
	end, cas.Marco)
end

-- Cada toque en la ranura pone el siguiente catalizador que tenés; después del último, queda
-- vacía.
UI.tocable(catalizador.Fondo, function()
	if ocupada then
		return
	end
	if not ranuraAbierta() then
		Notificaciones.mostrar(
			"La ranura de catalizador se abre con "
				.. Config.Residuos.RanuraDesde
				.. " especies descubiertas.",
			"info"
		)
		return
	end
	local tus = tusCatalizadores()
	local tenes = {}
	for _, c in Catalizadores.Lista do
		if (tus[c.Clave] or 0) > 0 then
			table.insert(tenes, c.Clave)
		end
	end
	if #tenes == 0 then
		Notificaciones.mostrar(
			"No tenés catalizadores: se arman con "
				.. Config.Residuos.ParaCatalizador
				.. " residuos (las fusiones que no reaccionan).",
			"info"
		)
		return
	end
	local i = if catElegido then table.find(tenes, catElegido) else nil
	catElegido = if i then tenes[i + 1] else tenes[1]
	avisoServidor = nil
	catalizador.rebotar(0.1)
	-- SONIDO: el catalizador entra en la ranura (nota corta aguda)
	Sonidos.nota(if catElegido then 9 else 2, 0.35)
	actualizar()
	if eventos then
		eventos.AlCatalizador(catElegido)
	end
end, catalizador.Marco)

-- Una tarjeta por especie y personalidad de las criaturas que tenés, en el orden de la
-- Mutadex, con cuántas hay ("×2"), su sello de personalidad y la estrella si alguna es
-- mutante (para fusionar da igual la variante: no se hereda).
local function armarLista()
	local cuentas: { [string]: { N: number, Mutante: boolean } } = {}
	for _, g in Formato.grupos(jugador:GetAttribute("Grupos") :: string?) do
		local k = llave({ Clave = g.Clave, Personalidad = g.Personalidad })
		local cuenta = cuentas[k] or { N = 0, Mutante = false }
		cuenta.N += g.Cantidad
		cuenta.Mutante = cuenta.Mutante or g.Mutante
		cuentas[k] = cuenta
	end
	for k, it in items do
		if not cuentas[k] then
			grupo.quitar(it.Cas.Marco)
			it.Cas.Marco:Destroy()
			items[k] = nil
		end
	end
	-- Si ya no tenés la criatura de un casillero (la entregaste), el casillero se vacía.
	local sinCriatura = {}
	for lado, e in seleccion do
		if not cuentas[llave(e)] then
			table.insert(sinCriatura, lado)
		end
	end
	for _, lado in sinCriatura do
		poner(lado, nil)
	end
	local total = 0
	for orden, c in Fusion.todas() do
		for orden2, p in Personalidades.Orden do
			local e: Eleccion = { Clave = c.Clave, Personalidad = p }
			local k = llave(e)
			local cuenta = cuentas[k]
			if cuenta then
				total += cuenta.N
				local mutante = cuenta.Mutante
				local nombre = if cuenta.N > 1 then c.Nombre .. " ×" .. cuenta.N else c.Nombre
				local datos = { Clave = c.Clave, Mutante = mutante, Personalidad = p }
				local it = items[k]
				if not it then
					local cas = UI.casillero({
						Nombre = k,
						Medida = UDim2.fromOffset(T.Criatura.X, T.Criatura.Y),
						Borde = Paleta.Generaciones[c.Gen],
						Prestada = true,
					})
					cas.Marco.LayoutOrder = orden * 10 + orden2
					cas.elemento(Generador.colorElemento(c))
					cas.personalidad(p)
					cas.Marco.Parent = lista
					UI.tocable(cas.Fondo, function()
						elegir(e, cas.Marco)
					end, cas.Marco)
					grupo.agregar(cas.Marco, cas.Hueco, datos)
					it = { Cas = cas, Criatura = c, Personalidad = p, Mutante = mutante }
					items[k] = it
				elseif it.Mutante ~= mutante then
					it.Mutante = mutante
					grupo.cambiar(it.Cas.Marco, datos)
				end
				local item = it :: Item
				item.Cas.poner(c.Clave, nombre, mutante)
			end
		end
	end
	tituloLista.Text = "Tus criaturas (" .. total .. ")"
	aplicarFiltro()
	pintarItems()
end

boton.AlTocar = function()
	local a, b = seleccion.A, seleccion.B
	if ocupada or not a or not b or not eventos then
		return
	end
	(eventos :: Eventos).AlConfirmar(a, b, catElegido)
end

Menus.registrar("Fusion", ventana, function()
	armarLista()
	actualizar()
	grupo.actualizar()
end)

---------------------------------------------------------------------------
-- Lo que usa Maquina.client
---------------------------------------------------------------------------

local Panel = {}

function Panel.iniciar(e: Eventos)
	eventos = e
	jugador:GetAttributeChangedSignal("Grupos"):Connect(function()
		armarLista()
		actualizar()
	end)
	jugador:GetAttributeChangedSignal("Especies"):Connect(actualizar)
	jugador:GetAttributeChangedSignal("ADN"):Connect(actualizar)
	for _, atributo in { "Residuos", "Catalizadores", "Variantes" } do
		jugador:GetAttributeChangedSignal(atributo):Connect(actualizar)
	end
	armarLista()
	mostrarPadre("A")
	mostrarPadre("B")
	actualizar()
end

function Panel.abrir()
	Menus.abrir("Fusion")
end

function Panel.cerrar()
	Menus.cerrar("Fusion")
end

function Panel.limpiar()
	poner("A", nil)
	poner("B", nil)
	-- El catalizador no queda puesto para la próxima (así no se gasta sin querer).
	if catElegido then
		catElegido = nil
		actualizar()
		if eventos then
			eventos.AlCatalizador(nil)
		end
	end
end

-- Aviso del servidor (por ejemplo "Te falta ADN"): queda hasta que cambie la elección.
function Panel.aviso(texto: string)
	avisoServidor = if texto ~= "" then texto else nil
	actualizar()
end

function Panel.ocupada(valor: boolean)
	ocupada = valor
	actualizar()
end

return Panel
