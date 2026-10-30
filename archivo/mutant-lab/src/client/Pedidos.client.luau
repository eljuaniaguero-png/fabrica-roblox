--!strict
-- El tablero de pedidos (ficha, "Pedidos"), armado con los componentes de UI.
-- Una tarjeta por pedido: el cliente, lo que pide, el premio y cuántas criaturas tuyas sirven.
-- "Entregar" abre la lista de las que sirven para elegir; "Descartar" deja el lugar vacío un
-- rato. Al entregar, la criatura se despide: salta dos veces y se va con el cliente.
-- Se abre con el tablero del laboratorio o con el contador de pedidos del HUD (UI/Menus).
-- El servidor valida todo (server/Tablero.luau); acá solo se elige.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local MiLab = require(script.Parent.MiLab)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)
local Vista = require(script.Parent.Vista)

local Tema = UI.Tema
local T = Tema.Pedidos
local V = Tema.Ventana
local P = Config.Pedidos
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local entregarRemoto = remotos:WaitForChild("EntregarPedido") :: RemoteEvent
local descartarRemoto = remotos:WaitForChild("DescartarPedido") :: RemoteEvent
local entregaRemoto = remotos:WaitForChild("Entrega") :: RemoteEvent

type Lugar = { Pedido: Pedidos.Pedido?, Espera: number? }

-- Una clase de criatura tuya que sirve (especie, tipo, personalidad y variante) y cuántas hay.
type Opcion = {
	Clave: string,
	Mutante: boolean,
	Personalidad: string?,
	Variante: string?,
	Disponibles: number,
}

type Tarjeta = {
	Caja: UI.Tarjeta,
	Contenido: Frame,
	Avatar: Frame,
	Cliente: TextLabel,
	Nuevo: Frame,
	Globo: Frame,
	Texto: TextLabel,
	Premio: TextLabel,
	Pista: Frame,
	Catalizador: Frame, -- "+1 Hielo" (algunos pedidos pagan un catalizador)
	IconoCatalizador: Frame,
	TextoCatalizador: TextLabel,
	Sirven: TextLabel,
	Entregar: UI.Boton,
	Descartar: UI.Boton,
	Espera: TextLabel,
}

local tarjetas: { Tarjeta } = {}
local entregando: { [number]: boolean } = {} -- lugares con una entrega en camino o animándose

---------------------------------------------------------------------------
-- Datos
---------------------------------------------------------------------------

local function lugares(): { Lugar }
	local texto = jugador:GetAttribute("Pedidos") :: string?
	if not texto then
		return {}
	end
	local ok, datos = pcall(function()
		return HttpService:JSONDecode(texto)
	end)
	return if ok and typeof(datos) == "table" then datos else {}
end

local function inventario(): { Formato.Grupo }
	return Formato.grupos(jugador:GetAttribute("Grupos") :: string?)
end

-- Las criaturas tuyas que sirven para el pedido, separadas por tipo, personalidad y variante,
-- en el orden de la Mutadex.
local function opciones(r: Pedidos.Requisito, inv: { Formato.Grupo }): { Opcion }
	local lista: { Opcion } = {}
	for _, g in inv do
		if g.Cantidad > 0 and Pedidos.sirve(r, g) then
			table.insert(lista, {
				Clave = g.Clave,
				Mutante = g.Mutante,
				Personalidad = g.Personalidad,
				Variante = g.Variante,
				Disponibles = g.Cantidad,
			})
		end
	end
	local orden = {}
	for i, c in Fusion.todas() do
		orden[c.Clave] = i
	end
	table.sort(lista, function(x, y)
		if x.Clave ~= y.Clave then
			return (orden[x.Clave] or 0) < (orden[y.Clave] or 0)
		end
		local px = table.find(Personalidades.Orden, x.Personalidad or "") or 0
		local py = table.find(Personalidades.Orden, y.Personalidad or "") or 0
		if px ~= py then
			return px < py
		end
		if x.Mutante ~= y.Mutante then
			return not x.Mutante
		end
		return (x.Variante or "") < (y.Variante or "")
	end)
	return lista
end

local function cuantasSirven(ops: { Opcion }): number
	local n = 0
	for _, o in ops do
		n += o.Disponibles
	end
	return n
end

local function colorCliente(i: number): Color3
	return Paleta.Papelitos[(i - 1) % #Paleta.Papelitos + 1]
end

---------------------------------------------------------------------------
-- Ventana
---------------------------------------------------------------------------

local ventana = UI.ventana({
	Titulo = "Pedidos",
	Icono = "caja",
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

local info = UI.texto({
	Nombre = "Info",
	Fuente = "fuerte",
	Letra = Tema.Letra.Chica,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(1, 0, 0, T.AltoInfo),
})
info.Parent = ventana.Cuerpo

local fila =
	UI.hueco("Tarjetas", UDim2.new(1, 0, 1, -(T.AltoInfo + Tema.Separacion)), ventana.Cuerpo)
fila.Position = UDim2.fromOffset(0, T.AltoInfo + Tema.Separacion)
UI.lista(fila, true, Tema.Separacion)

---------------------------------------------------------------------------
-- Tarjeta de un pedido
---------------------------------------------------------------------------

local abrirSelector: (lugar: number) -> ()

local function crearTarjeta(i: number): Tarjeta
	local caja = UI.tarjeta({ Nombre = "Pedido" .. i })
	caja.Marco.LayoutOrder = i
	caja.Marco.Size = UDim2.new(1 / P.Activos, -Tema.Separacion, 1, -Tema.Sombra)
	caja.Marco.Parent = fila
	local fondo = caja.Fondo
	local contenido =
		UI.hueco("Contenido", UDim2.new(1, -Tema.Relleno * 2, 1, -Tema.Relleno * 2), fondo)
	contenido.Position = UDim2.fromOffset(Tema.Relleno, Tema.Relleno)

	-- Encabezado: el muñequito del cliente, su nombre y "¡Nuevo!".
	local avatar = UI.hueco("Avatar", UDim2.fromOffset(T.Cliente, T.Cliente), contenido)
	local cliente = UI.texto({
		Nombre = "Cliente",
		Letra = Tema.Letra.Subtitulo,
		Color = Paleta.Texto,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -T.Cliente - Tema.Separacion, 0, Tema.Letra.Subtitulo + 8),
	})
	cliente.TextWrapped = false
	cliente.TextScaled = true
	local tope = Instance.new("UITextSizeConstraint")
	tope.MaxTextSize = Tema.Letra.Subtitulo
	tope.Parent = cliente
	cliente.Position = UDim2.fromOffset(T.Cliente + Tema.Separacion, 0)
	cliente.Parent = contenido
	local nuevo = Instance.new("Frame")
	nuevo.Name = "Nuevo"
	nuevo.BackgroundColor3 = Paleta.Alerta
	nuevo.Size = UDim2.fromOffset(150, 34)
	nuevo.Position = UDim2.fromOffset(T.Cliente + Tema.Separacion, Tema.Letra.Subtitulo + 14)
	UI.redondo(nuevo)
	UI.contorno(nuevo, Paleta.Contorno, 2)
	local textoNuevo = UI.texto({
		Texto = "¡Algo nuevo!",
		Letra = Tema.Letra.Chica - 4,
		Medida = UDim2.fromScale(1, 1),
	})
	textoNuevo.Parent = nuevo
	nuevo.Parent = contenido

	-- Globo con lo que pide.
	local y = T.AltoEncabezado + Tema.Separacion
	local globo = Instance.new("Frame")
	globo.Name = "Globo"
	globo.BackgroundColor3 = Paleta.SuperficieClara
	globo.Size = UDim2.new(1, 0, 0, T.AltoGlobo)
	globo.Position = UDim2.fromOffset(0, y)
	UI.esquina(globo)
	UI.contorno(globo, Paleta.Contorno, 2)
	globo.Parent = contenido
	local texto = UI.texto({
		Nombre = "Texto",
		Letra = Tema.Letra.Subtitulo,
		Medida = UDim2.new(1, -Tema.Relleno * 2, 1, -Tema.Separacion),
	})
	texto.AnchorPoint = Vector2.new(0.5, 0.5)
	texto.Position = UDim2.fromScale(0.5, 0.5)
	texto.Parent = globo
	y += T.AltoGlobo + Tema.Separacion

	-- Premio: ADN y, a veces, una pista gratis o un catalizador.
	local filaPremio = UI.hueco("Premio", UDim2.new(1, 0, 0, T.AltoPremio), contenido)
	filaPremio.Position = UDim2.fromOffset(0, y)
	local l = UI.lista(filaPremio, true, Tema.Separacion / 2)
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	local iconoADN = UI.Iconos.crear("adn", T.AltoPremio, Paleta.Acento)
	iconoADN.LayoutOrder = 1
	iconoADN.Parent = filaPremio
	local premio = UI.texto({
		Nombre = "ADN",
		Letra = Tema.Letra.Numero,
		Color = Paleta.Acento,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.fromOffset(0, T.AltoPremio),
	})
	premio.AutomaticSize = Enum.AutomaticSize.X
	premio.TextWrapped = false
	premio.LayoutOrder = 2
	premio.Parent = filaPremio
	local pista = UI.hueco("Pista", UDim2.fromOffset(0, T.AltoPremio), filaPremio)
	pista.AutomaticSize = Enum.AutomaticSize.X
	pista.LayoutOrder = 3
	UI.lista(pista, true, 4).VerticalAlignment = Enum.VerticalAlignment.Center
	local separa = UI.hueco("Separa", UDim2.fromOffset(Tema.Separacion, 1), pista)
	separa.LayoutOrder = 0
	local iconoPista = UI.Iconos.crear("lupa", T.AltoPremio - 8, Paleta.Dorado)
	iconoPista.LayoutOrder = 1
	iconoPista.Parent = pista
	local textoPista = UI.texto({
		Texto = "+1 pista",
		Letra = Tema.Letra.Normal,
		Color = Paleta.Dorado,
		Medida = UDim2.fromOffset(0, T.AltoPremio),
	})
	textoPista.AutomaticSize = Enum.AutomaticSize.X
	textoPista.TextWrapped = false
	textoPista.LayoutOrder = 2
	textoPista.Parent = pista
	-- O un catalizador (en vez de la pista).
	local premioCatalizador = UI.hueco("Catalizador", UDim2.fromOffset(0, T.AltoPremio), filaPremio)
	premioCatalizador.AutomaticSize = Enum.AutomaticSize.X
	premioCatalizador.LayoutOrder = 4
	UI.lista(premioCatalizador, true, 4).VerticalAlignment = Enum.VerticalAlignment.Center
	local separaCatalizador =
		UI.hueco("Separa", UDim2.fromOffset(Tema.Separacion, 1), premioCatalizador)
	separaCatalizador.LayoutOrder = 0
	local iconoCatalizador =
		UI.hueco("Icono", UDim2.fromOffset(T.AltoPremio - 8, T.AltoPremio - 8), premioCatalizador)
	iconoCatalizador.LayoutOrder = 1
	local textoCatalizador = UI.texto({
		Letra = Tema.Letra.Normal,
		Medida = UDim2.fromOffset(0, T.AltoPremio),
	})
	textoCatalizador.AutomaticSize = Enum.AutomaticSize.X
	textoCatalizador.TextWrapped = false
	textoCatalizador.LayoutOrder = 2
	textoCatalizador.Parent = premioCatalizador
	y += T.AltoPremio + Tema.Separacion

	-- Cuántas criaturas tuyas sirven.
	local sirven = UI.texto({
		Nombre = "Sirven",
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, 0, 0, Tema.Letra.Chica * 2 + 8),
	})
	sirven.TextYAlignment = Enum.TextYAlignment.Top
	sirven.Position = UDim2.fromOffset(0, y)
	sirven.Parent = contenido

	-- Botones abajo: Entregar y Descartar.
	local alto = Tema.Toque + Tema.Profundidad
	local entregar = UI.boton({
		Nombre = "Entregar",
		Texto = "Entregar",
		Icono = "caja",
		ColorIcono = Paleta.Contorno,
		Tipo = "principal",
		Medida = UDim2.new(1, -alto - Tema.Separacion, 0, alto),
		AlTocar = function()
			abrirSelector(i)
		end,
	})
	entregar.Marco.AnchorPoint = Vector2.new(0, 1)
	entregar.Marco.Position = UDim2.fromScale(0, 1)
	entregar.Marco.Parent = contenido
	local descartar = UI.boton({
		Nombre = "Descartar",
		Icono = "cerrar",
		Tipo = "secundario",
		Medida = UDim2.fromOffset(alto, alto),
		AlTocar = function()
			-- SONIDO: descartar un pedido (nota grave)
			Sonidos.nota(-5, 0.25)
			descartarRemoto:FireServer(i)
		end,
	})
	descartar.Marco.AnchorPoint = Vector2.new(1, 1)
	descartar.Marco.Position = UDim2.fromScale(1, 1)
	descartar.Marco.Parent = contenido

	-- Lugar vacío (después de descartar): cuenta regresiva.
	local espera = UI.texto({
		Nombre = "Espera",
		Letra = Tema.Letra.Subtitulo,
		Color = Paleta.Metal,
		Medida = UDim2.new(1, -Tema.Relleno * 2, 0, Tema.Toque * 2),
	})
	espera.AnchorPoint = Vector2.new(0.5, 0.5)
	espera.Position = UDim2.fromScale(0.5, 0.5)
	espera.Visible = false
	espera.Parent = fondo

	return {
		Caja = caja,
		Contenido = contenido,
		Avatar = avatar,
		Cliente = cliente,
		Nuevo = nuevo,
		Globo = globo,
		Texto = texto,
		Premio = premio,
		Pista = pista,
		Catalizador = premioCatalizador,
		IconoCatalizador = iconoCatalizador,
		TextoCatalizador = textoCatalizador,
		Sirven = sirven,
		Entregar = entregar,
		Descartar = descartar,
		Espera = espera,
	}
end

for i = 1, P.Activos do
	tarjetas[i] = crearTarjeta(i)
end

local function segundos(n: number): string
	local s = math.max(0, math.ceil(n))
	return string.format("%d:%02d", s // 60, s % 60)
end

local function pintarTarjeta(i: number, lugar: Lugar?, inv: { Formato.Grupo })
	local t = tarjetas[i]
	local p = lugar and lugar.Pedido
	t.Contenido.Visible = p ~= nil
	t.Espera.Visible = p == nil
	if not p then
		local hasta = lugar and lugar.Espera
		t.Espera.Text = if hasta
			then "Llega otro pedido en " .. segundos(hasta - workspace:GetServerTimeNow())
			else "Llega otro pedido en un ratito..."
		return
	end
	-- El muñequito se rearma solo si cambió el cliente.
	if t.Avatar:GetAttribute("Cliente") ~= p.Cliente then
		t.Avatar:ClearAllChildren()
		UI.insignia("criatura", colorCliente(p.Cliente), T.Cliente).Parent = t.Avatar
		t.Avatar:SetAttribute("Cliente", p.Cliente)
	end
	t.Cliente.Text = P.Clientes[p.Cliente] or "?"
	t.Nuevo.Visible = p.Nuevo == true
	t.Texto.Text = p.Texto .. (if Pedidos.cantidad(p.Requisito) > 1 then "" else "")
	t.Premio.Text = "+" .. Formato.numero(p.Premio)
	t.Pista.Visible = p.Pista == true
	local premioCat = Catalizadores.porClave(p.Catalizador)
	t.Catalizador.Visible = premioCat ~= nil
	if premioCat and t.Catalizador:GetAttribute("Clave") ~= premioCat.Clave then
		t.IconoCatalizador:ClearAllChildren()
		UI.Iconos.crear(premioCat.Icono, T.AltoPremio - 8, premioCat.Color).Parent =
			t.IconoCatalizador
		t.TextoCatalizador.Text = "+1 " .. premioCat.Nombre
		t.TextoCatalizador.TextColor3 = premioCat.Color
		t.Catalizador:SetAttribute("Clave", premioCat.Clave)
	end
	t.Caja.Borde.Color = if p.Dificultad == "Mutante" then Paleta.Dorado else Paleta.Contorno

	local ops = opciones(p.Requisito, inv)
	local n = cuantasSirven(ops)
	local hacen = Pedidos.cantidad(p.Requisito)
	if n >= hacen then
		t.Sirven.Text = if n == 1 then "Tenés 1 que sirve." else "Tenés " .. n .. " que sirven."
		t.Sirven.TextColor3 = Paleta.Acento
	elseif p.Nuevo then
		t.Sirven.Text = "Para cumplirlo tenés que descubrir una especie nueva."
		t.Sirven.TextColor3 = Paleta.Alerta
	elseif p.Requisito.Variante then
		local cat = Catalizadores.porClave(p.Requisito.Variante)
		t.Sirven.Text = "Fusionalo con un catalizador de "
			.. (if cat then cat.Nombre else "?")
			.. "."
		t.Sirven.TextColor3 = Paleta.Alerta
	elseif n > 0 then
		t.Sirven.Text = "Tenés " .. n .. " de " .. hacen .. ". Fusioná otra."
		t.Sirven.TextColor3 = Paleta.Texto
	else
		t.Sirven.Text = "Ninguna tuya sirve todavía: fusioná una."
		t.Sirven.TextColor3 = Paleta.Texto
	end
	t.Entregar.habilitar(n >= hacen)
end

local function pintarInfo()
	local entregados = (jugador:GetAttribute("Entregados") :: number?) or 0
	local faltan = P.Hito - entregados % P.Hito
	info.Text = "Entregá criaturas de tu laboratorio (las de la Mutadex no se pierden). Entregados: "
		.. entregados
		.. " · Premio extra en "
		.. faltan
		.. (if faltan == 1 then " pedido." else " pedidos.")
end

local function pintar()
	local ls = lugares()
	local inv = inventario()
	for i = 1, P.Activos do
		if not entregando[i] then
			pintarTarjeta(i, ls[i], inv)
		end
	end
	contadorADN.Valor.Text = Formato.numero((jugador:GetAttribute("ADN") :: number?) or 0)
	pintarInfo()
end

---------------------------------------------------------------------------
-- Elegir qué criatura entregar
---------------------------------------------------------------------------

local selector =
	UI.tarjeta({ Nombre = "Selector", Color = Paleta.Superficie, Grosor = Tema.Contorno + 1 })
selector.Marco.Size = UDim2.fromScale(1, 1)
selector.Marco.ZIndex = 10
selector.Marco.Visible = false
selector.Marco.Parent = ventana.Cuerpo
local tituloSelector = UI.texto({
	Nombre = "Titulo",
	Letra = Tema.Letra.Subtitulo,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(1, -(Tema.Toque + Tema.Relleno * 3), 0, Tema.Toque),
})
tituloSelector.Position = UDim2.fromOffset(Tema.Relleno, Tema.Separacion)
tituloSelector.Parent = selector.Fondo
local cerrarSelector = UI.botonCerrar()
cerrarSelector.Marco.AnchorPoint = Vector2.new(1, 0)
cerrarSelector.Marco.Position = UDim2.new(1, -Tema.Separacion, 0, Tema.Separacion)
cerrarSelector.Marco.Parent = selector.Fondo

local arribaLista = Tema.Toque + Tema.Separacion * 2
local altoAbajo = Tema.Toque + Tema.Profundidad + Tema.Separacion * 2
local listaOpciones = UI.desplazable("Opciones", selector.Fondo)
listaOpciones.Position = UDim2.fromOffset(Tema.Relleno, arribaLista)
listaOpciones.Size = UDim2.new(1, -Tema.Relleno * 2, 1, -(arribaLista + altoAbajo))
UI.grilla(listaOpciones, T.Opcion)
local grupoOpciones = VistasVisibles.nueva(listaOpciones)

local avisoSelector = UI.texto({
	Nombre = "Aviso",
	Fuente = "fuerte",
	Letra = Tema.Letra.Chica,
	Color = Paleta.Alerta,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(1, -(Tema.Fusion.AnchoBoton + Tema.Relleno * 3), 0, Tema.Toque),
})
avisoSelector.AnchorPoint = Vector2.new(0, 1)
avisoSelector.Position = UDim2.new(0, Tema.Relleno, 1, -Tema.Separacion)
avisoSelector.Parent = selector.Fondo
local confirmar = UI.boton({
	Nombre = "Confirmar",
	Texto = "Entregar",
	Icono = "corazon",
	ColorIcono = Paleta.Contorno,
	Tipo = "principal",
	Medida = UDim2.fromOffset(Tema.Fusion.AnchoBoton, Tema.Toque + Tema.Profundidad),
})
confirmar.Marco.AnchorPoint = Vector2.new(1, 1)
confirmar.Marco.Position = UDim2.new(1, -Tema.Relleno, 1, -Tema.Separacion)
confirmar.Marco.Parent = selector.Fondo

local lugarElegido: number? = nil
local pedidoElegido: Pedidos.Pedido? = nil
local elegidas: { Opcion } = {} -- lo que se va a entregar (puede repetir una opción)
local casillas: { [Opcion]: UI.Casillero } = {}

local function cuantasElegidas(o: Opcion): number
	local n = 0
	for _, e in elegidas do
		if e == o then
			n += 1
		end
	end
	return n
end

local function pintarSelector()
	local p = pedidoElegido
	if not p then
		return
	end
	local hacen = Pedidos.cantidad(p.Requisito)
	for o, cas in casillas do
		local n = cuantasElegidas(o)
		cas.Borde.Color = if n > 0
			then Paleta.Acento
			else Paleta.Generaciones[(Fusion.porClave(o.Clave) :: Fusion.Criatura).Gen]
		cas.Borde.Thickness = if n > 0 then Tema.Contorno + 3 else Tema.Contorno + 1
		local c = Fusion.porClave(o.Clave) :: Fusion.Criatura
		local nombre = if n == 0
			then Catalizadores.nombre(c.Nombre, o.Variante) .. " ×" .. o.Disponibles
			elseif n == 1 then "Elegido"
			else "Elegidos: " .. n
		cas.poner(o.Clave, nombre, o.Mutante)
	end
	-- Avisar si te quedás sin ninguna de esa especie (no la podrías usar en la máquina).
	local aviso = ""
	local inv = inventario()
	for o in casillas do
		local n = 0
		for _, e in elegidas do
			if e.Clave == o.Clave then
				n += 1
			end
		end
		local total = 0
		for _, g in inv do
			if g.Clave == o.Clave then
				total += g.Cantidad
			end
		end
		if n > 0 and n >= total then
			aviso = "Te quedás sin "
				.. (Fusion.porClave(o.Clave) :: Fusion.Criatura).Nombre
				.. ": no lo vas a poder usar en la máquina hasta conseguir otro."
		end
	end
	avisoSelector.Text = aviso
	confirmar.habilitar(#elegidas == hacen)
	confirmar.poner(if hacen > 1 then "Entregar " .. #elegidas .. " / " .. hacen else "Entregar")
end

local function cerrarElSelector()
	selector.Marco.Visible = false
	for _, cas in casillas do
		grupoOpciones.quitar(cas.Marco)
		cas.Marco:Destroy()
	end
	casillas = {}
	elegidas = {}
	lugarElegido = nil
	pedidoElegido = nil
end
cerrarSelector.AlTocar = cerrarElSelector

function abrirSelector(i: number)
	local lugar = lugares()[i]
	local p = lugar and lugar.Pedido
	if not p then
		return
	end
	cerrarElSelector()
	lugarElegido = i
	pedidoElegido = p
	local hacen = Pedidos.cantidad(p.Requisito)
	tituloSelector.Text = (P.Clientes[p.Cliente] or "?")
		.. " pide: "
		.. p.Texto
		.. (if hacen > 1 then " (elegí " .. hacen .. ")" else "")
	for orden, o in opciones(p.Requisito, inventario()) do
		local c = Fusion.porClave(o.Clave) :: Fusion.Criatura
		local cas = UI.casillero({
			Nombre = o.Clave
				.. (if o.Mutante then "M" else "")
				.. (o.Personalidad or "")
				.. (o.Variante or ""),
			Medida = UDim2.fromOffset(T.Opcion.X, T.Opcion.Y),
			Borde = Paleta.Generaciones[c.Gen],
			Prestada = true,
		})
		cas.Marco.LayoutOrder = orden
		cas.elemento(Generador.colorElemento(c))
		cas.personalidad(o.Personalidad)
		cas.Marco.Parent = listaOpciones
		grupoOpciones.agregar(cas.Marco, cas.Hueco, {
			Clave = o.Clave,
			Mutante = o.Mutante,
			Personalidad = o.Personalidad,
			Variante = o.Variante,
		})
		UI.tocable(cas.Fondo, function()
			local n = cuantasElegidas(o)
			if #elegidas < hacen and n < o.Disponibles then
				table.insert(elegidas, o)
				cas.rebotar(0.1)
			elseif n > 0 then
				table.remove(elegidas, table.find(elegidas, o) :: number)
			end
			pintarSelector()
		end, cas.Marco)
		casillas[o] = cas
	end
	-- Si hay una sola opción y alcanza, ya queda elegida.
	local unica = next(casillas)
	if unica and not next(casillas, unica) then
		local o = unica :: Opcion
		for _ = 1, math.min(hacen, o.Disponibles) do
			table.insert(elegidas, o)
		end
	end
	selector.Marco.Visible = true
	pintarSelector()
	grupoOpciones.actualizar()
end

confirmar.AlTocar = function()
	local i, p = lugarElegido, pedidoElegido
	if not i or not p or #elegidas ~= Pedidos.cantidad(p.Requisito) then
		return
	end
	local envio = {}
	for _, o in elegidas do
		table.insert(envio, {
			Clave = o.Clave,
			Mutante = o.Mutante,
			Personalidad = o.Personalidad,
			Variante = o.Variante,
		})
	end
	entregando[i] = true
	entregarRemoto:FireServer(i, envio)
	cerrarElSelector()
	-- Si el servidor no contesta (no se pudo entregar), la tarjeta vuelve a la normalidad.
	task.delay(4, function()
		if entregando[i] == true then
			entregando[i] = nil
			pintar()
		end
	end)
end

---------------------------------------------------------------------------
-- Despedida: la criatura salta dos veces y se va con el cliente
---------------------------------------------------------------------------

local SALTO_ARRIBA = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SALTO_ABAJO = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local IRSE = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function despedida(i: number, unidades: { Pedidos.Unidad }, premio: number)
	local t = tarjetas[i]
	t.Contenido.Visible = true
	t.Espera.Visible = false
	t.Texto.Text = "¡Gracias!"
	t.Texto.TextYAlignment = Enum.TextYAlignment.Top -- arriba, así la criatura no lo tapa
	t.Entregar.habilitar(false)
	-- SONIDO: despedida de la criatura (notas alegres que suben)
	Sonidos.secuencia({ 7, 12, 9, 16, 19 }, 0.09, 0.35)
	UI.destello(t.Caja.Fondo, Paleta.Acento, t.Caja.Marco)
	contadorADN.rebotar(0.2)

	local lado = math.floor(T.AltoGlobo * 0.6)
	for k, u in unidades do
		local vista = Instance.new("ViewportFrame")
		vista.Name = "Despedida"
		vista.BackgroundTransparency = 1
		vista.AnchorPoint = Vector2.new(0.5, 1)
		vista.Size = UDim2.fromOffset(lado, lado)
		local x = (k - (#unidades + 1) / 2) * lado * 0.8
		local inicio = UDim2.new(0.5, x, 1, -Tema.Separacion)
		vista.Position = inicio
		vista.ZIndex = 5
		vista.Parent = t.Globo
		Vista.mostrar(vista, u.Clave, u.Mutante, nil, u.Personalidad, u.Variante)
		task.spawn(function()
			for _ = 1, 2 do
				UI.animar(
					vista,
					SALTO_ARRIBA,
					{ Position = inicio - UDim2.fromOffset(0, Tema.Separacion * 2) }
				).Completed
					:Wait()
				UI.animar(vista, SALTO_ABAJO, { Position = inicio }).Completed:Wait()
			end
			-- Se va volando hacia el cliente.
			local destino = t.Avatar.AbsolutePosition + t.Avatar.AbsoluteSize / 2
			local origen = t.Globo.AbsolutePosition
			local factor = if t.Globo.Size.X.Offset > 0
				then t.Globo.AbsoluteSize.X / t.Globo.Size.X.Offset
				else UI.Pantalla.escala()
			local d = (destino - origen) / factor
			UI.animar(vista, IRSE, {
				Position = UDim2.fromOffset(d.X, d.Y),
				Size = UDim2.fromOffset(0, 0),
			}).Completed
				:Wait()
			vista:Destroy()
		end)
	end
	-- Un corazón sale del cliente.
	local corazon = UI.Iconos.crear("corazon", T.Cliente * 0.6, Paleta.Alerta)
	corazon.Position = UDim2.fromScale(0.5, 0)
	corazon.ZIndex = 6
	corazon.Parent = t.Avatar
	task.delay(0.9, function()
		UI.rebotar(corazon, 0.4)
		UI.animar(corazon, TweenInfo.new(0.8), { Position = UDim2.fromScale(0.5, -0.8) })
	end)
	task.delay(T.Despedida, function()
		corazon:Destroy()
		t.Texto.TextYAlignment = Enum.TextYAlignment.Center
		entregando[i] = nil
		pintar()
		UI.rebotar(t.Caja.Marco, 0.08)
	end)
	t.Premio.Text = "+" .. Formato.numero(premio)
end

entregaRemoto.OnClientEvent:Connect(
	function(i: number, p: Pedidos.Pedido, unidades: { Pedidos.Unidad })
		if not tarjetas[i] then
			return
		end
		entregando[i] = "animando" :: any
		despedida(i, unidades, p.Premio)
	end
)

---------------------------------------------------------------------------
-- Abrir, cerrar y mantener al día
---------------------------------------------------------------------------

local abierto = false

Menus.registrar("Pedidos", ventana, function()
	abierto = true
	pintar()
	-- Cuenta regresiva de los lugares vacíos.
	task.spawn(function()
		while abierto do
			task.wait(0.5)
			local ls = lugares()
			for i = 1, P.Activos do
				local l = ls[i]
				if not entregando[i] and l and not l.Pedido then
					pintarTarjeta(i, l, {})
				end
			end
		end
	end)
end, function()
	abierto = false
	cerrarElSelector()
end)

for _, atributo in { "Pedidos", "Grupos", "ADN", "Entregados" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		if abierto then
			pintar()
			if pedidoElegido and selector.Marco.Visible and atributo == "Grupos" then
				abrirSelector(lugarElegido :: number)
			end
		end
	end)
end

local prompt = MiLab.obtener()
	:WaitForChild("Tablero")
	:WaitForChild("Pantalla")
	:WaitForChild("Prompt") :: ProximityPrompt
prompt.Triggered:Connect(function()
	Menus.abrir("Pedidos")
end)

pintar()
