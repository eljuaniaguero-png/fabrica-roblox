--!strict
-- Panel de la máquina de fusión (ficha, "Guía de estilo", 6, "Menú de fusión"), armado por
-- código con los componentes de UI:
--   arriba, los casilleros de los padres (izquierda verde ácido, derecha magenta) con un "+"
--   entre ellos y, sobre el "+", el del catalizador (con candado hasta que se desbloquee);
--   después del "=", la vista previa: el resultado si ya lo tenés, "?" si no;
--   a la derecha, qué va a pasar y el botón "¡FUSIONAR!" con el costo;
--   abajo, tus criaturas en casilleros con el borde de su generación, filtrables por elemento.
-- Tocar una criatura la hace saltar al casillero libre; tocar un casillero lleno lo vacía.
-- Se abre con la consola de la máquina (Maquina.client) y se abre y cierra con UI/Menus.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Elementos = require(ReplicatedStorage.Shared.Elementos)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local Notificaciones = require(script.Parent.UI.Notificaciones)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)
local Vista = require(script.Parent.Vista)

export type Eventos = {
	AlElegir: (lado: string, clave: string?) -> (),
	AlConfirmar: (a: string, b: string) -> (),
}

type Item = {
	Cas: UI.Casillero,
	Criatura: Fusion.Criatura,
	Mutante: boolean,
}

local Tema = UI.Tema
local T = Tema.Fusion
local jugador = Players.LocalPlayer

local COLOR_LADO: { [string]: Color3 } = { A = Paleta.Acento, B = Paleta.Alerta }
local ALTO_BOTON_FILTRO = T.Filtro + Tema.Profundidad

local seleccion: { [string]: string } = {}
local items: { [string]: Item } = {}
local eventos: Eventos? = nil
local ocupada = false
local avisoServidor: string? = nil
local filtro: string? = nil -- elemento elegido (nil = todos)

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
-- Estado: vista previa, texto y botón
---------------------------------------------------------------------------

local function actualizar()
	-- Cuántos residuos juntaste (con Config.Residuos.ParaCatalizador se arma un catalizador).
	local residuos = jugador:GetAttribute("Residuos") :: string?
	local cuantos = if residuos and residuos ~= "" then #string.split(residuos, ";") else 0
	if catalizador.Nombre then
		catalizador.Nombre.Text = "Residuos " .. cuantos .. "/" .. Config.Residuos.ParaCatalizador
	end
	contadorADN.Valor.Text = Formato.numero(adn())
	local a, b = seleccion.A, seleccion.B
	local ca = if a then Fusion.porClave(a) else nil
	local cb = if b then Fusion.porClave(b) else nil
	local texto = ""
	local color = Paleta.Texto
	local listo = false

	previa.elemento(nil)
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
			color = Paleta.Alerta
			boton.poner("¡FUSIONAR!", "Sale un residuo (gratis)")
			boton.colorSub(Paleta.Texto)
			listo = true
		else
			local tengo = conjunto("Especies")
			local costo = Costos.fusion(ca.Gen, cb.Gen, cantidad(tengo)) or 0
			if tengo[hijo.Clave] then
				-- Conocida: se muestra el resultado (no adelanta especies nuevas).
				previa.poner(hijo.Clave, hijo.Nombre, conjunto("Mutantes")[hijo.Clave])
				previa.elemento(Generador.colorElemento(hijo))
				previa.Borde.Color = Paleta.Generaciones[hijo.Gen]
				texto = "Ya la tenés: sale otro "
					.. hijo.Nombre
					.. " para tus pedidos (y quizás sale mutante)."
				color = Paleta.Alerta
			else
				previa.poner(nil, "¡Nueva!")
				previa.Signo.Text = "?"
				previa.Signo.TextColor3 = Paleta.Acento
				previa.Borde.Color = Paleta.Acento
				texto = "¡Reaccionan! Va a salir una especie que todavía no tenés."
				color = Paleta.Acento
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
	for clave, it in items do
		local lado = if seleccion.A == clave then "A" elseif seleccion.B == clave then "B" else nil
		it.Cas.Borde.Color = if lado then COLOR_LADO[lado] else Paleta.Generaciones[it.Criatura.Gen]
		it.Cas.Borde.Thickness = if lado then Tema.Contorno + 3 else Tema.Contorno + 1
	end
end

local function mostrarPadre(lado: string)
	local clave = seleccion[lado]
	local c = if clave then Fusion.porClave(clave) else nil
	local cas = padres[lado]
	cas.poner(
		if c then c.Clave else nil,
		if c then c.Nombre else nil,
		if c then conjunto("Mutantes")[c.Clave] else nil
	)
	cas.elemento(if c then Generador.colorElemento(c) else nil)
end

-- La criatura salta desde su casillero de la lista hasta el de la máquina.
local function saltar(desde: GuiObject, lado: string, clave: string)
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
	local vuelo = Instance.new("ViewportFrame")
	vuelo.Name = "Vuelo"
	vuelo.BackgroundTransparency = 1
	vuelo.Position = UDim2.fromOffset(inicio.X, inicio.Y)
	vuelo.Size = UDim2.fromOffset(tamInicio.X, tamInicio.Y)
	vuelo.ZIndex = 30
	vuelo.Parent = ventana.Fondo
	Vista.mostrar(vuelo, clave, conjunto("Mutantes")[clave])
	local t = UI.animar(vuelo, T.Salto, {
		Position = UDim2.fromOffset(fin.X, fin.Y),
		Size = UDim2.fromOffset(tamFin.X, tamFin.Y),
	})
	t.Completed:Once(function()
		vuelo:Destroy()
		if seleccion[lado] == clave then
			mostrarPadre(lado)
			hacia.rebotar(0.12)
			-- SONIDO: la criatura cae en el casillero (nota corta)
			Sonidos.nota(if lado == "A" then 4 else 7, 0.35)
		end
	end)
end

local function poner(lado: string, clave: string?, desde: GuiObject?)
	seleccion[lado] = clave
	avisoServidor = nil
	if clave and desde then
		saltar(desde, lado, clave)
	else
		mostrarPadre(lado)
	end
	pintarItems()
	actualizar()
	if eventos then
		eventos.AlElegir(lado, clave)
	end
end

local function elegir(clave: string, desde: GuiObject)
	if ocupada then
		return
	end
	if seleccion.A == clave then
		poner("A", nil)
	elseif seleccion.B == clave then
		poner("B", nil)
	elseif not seleccion.A then
		poner("A", clave, desde)
	else
		poner("B", clave, desde)
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

UI.tocable(catalizador.Fondo, function()
	Notificaciones.mostrar("Los catalizadores llegan muy pronto.", "info")
end, catalizador.Marco)

-- Una tarjeta por especie de la que tenés criaturas, en el orden de la Mutadex, con cuántas
-- tenés ("×2") y la estrella si alguna es mutante.
local function armarLista()
	local inventario = Formato.inventario(jugador:GetAttribute("Criaturas") :: string?)
	for clave, it in items do
		if not inventario[clave] then
			grupo.quitar(it.Cas.Marco)
			it.Cas.Marco:Destroy()
			items[clave] = nil
		end
	end
	-- Si ya no tenés la criatura de un casillero (la entregaste), el casillero se vacía.
	local sinCriatura = {}
	for lado, clave in seleccion do
		if not inventario[clave] then
			table.insert(sinCriatura, lado)
		end
	end
	for _, lado in sinCriatura do
		poner(lado, nil)
	end
	local total = 0
	for orden, c in Fusion.todas() do
		local cuenta = inventario[c.Clave]
		if cuenta then
			local n = cuenta.Normales + cuenta.Mutantes
			total += n
			local mutante = cuenta.Mutantes > 0
			local nombre = if n > 1 then c.Nombre .. " ×" .. n else c.Nombre
			local it = items[c.Clave]
			if not it then
				local cas = UI.casillero({
					Nombre = c.Clave,
					Medida = UDim2.fromOffset(T.Criatura.X, T.Criatura.Y),
					Borde = Paleta.Generaciones[c.Gen],
					Prestada = true,
				})
				cas.Marco.LayoutOrder = orden
				cas.elemento(Generador.colorElemento(c))
				cas.Marco.Parent = lista
				UI.tocable(cas.Fondo, function()
					elegir(c.Clave, cas.Marco)
				end, cas.Marco)
				grupo.agregar(cas.Marco, cas.Hueco, { Clave = c.Clave, Mutante = mutante })
				it = { Cas = cas, Criatura = c, Mutante = mutante }
				items[c.Clave] = it
			elseif it.Mutante ~= mutante then
				it.Mutante = mutante
				grupo.cambiar(it.Cas.Marco, { Clave = c.Clave, Mutante = mutante })
			end
			local item = it :: Item
			item.Cas.poner(c.Clave, nombre, mutante)
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
	(eventos :: Eventos).AlConfirmar(a, b)
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
	jugador:GetAttributeChangedSignal("Criaturas"):Connect(function()
		armarLista()
		actualizar()
	end)
	jugador:GetAttributeChangedSignal("Especies"):Connect(actualizar)
	jugador:GetAttributeChangedSignal("ADN"):Connect(actualizar)
	jugador:GetAttributeChangedSignal("Residuos"):Connect(actualizar)
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
