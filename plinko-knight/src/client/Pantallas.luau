--!strict
-- Pantallas (etapa 7, graybox ordenado). Todo sale de client/Estilo (colores, fuentes, tamaños y
-- el lienzo con escala), así se ve igual en compu, tablet y celular horizontal.
--
-- Pelea: franja de arriba con tu vida y oro (izquierda), "Pelea 5 de 9" y la zona (centro) y el
-- botón de Ajustes (derecha); debajo de la vida, cuántas clavijas especiales tenés; la maña del
-- jefe en la columna del monstruo; franja de abajo con tu bola (los pergaminos y las reliquias de
-- esa franja los dibuja TiendaVista). La cámara deja libre el espacio de las dos franjas
-- (zonaLibre), así nada tapa el tablero. Etapa 7b: todo esto se ve solo sentado en la máquina
-- (mostrarHud); "Salir" te levanta. El chat y la lista de jugadores los esconde client/Sala.
-- Inicio: título, tu mejor, elegir bola (las bloqueadas con candado y cómo se consiguen), botón
-- grande "Bajar a la mazmorra" y Ajustes.
-- Final (perder o ganar): cuántas peleas ganaste, tu mejor, lo que desbloqueaste y "Volver a
-- bajar" (un toque y estás jugando, con la misma bola) o "Salir" (te levantás de la máquina).
-- El cofre (elegir 1 de 3), la tienda y las reliquias están en TiendaVista.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Progreso = require(Shared:WaitForChild("Progreso"))
local Estilo = require(script.Parent:WaitForChild("Estilo"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

-- Lo que muestra la pantalla final.
export type Final = {
	Gano: boolean,
	Piso: number, -- la pelea en la que terminó
	MejorAntes: number, -- peleas ganadas récord antes de esta partida
	MejorAhora: number,
	Desbloqueos: { string }, -- nombres de lo que se desbloqueó en esta partida
}

export type Pantallas = {
	ponerEstado: (estado: Mazmorra.Estado) -> (),
	ponerVida: (vida: number, maxima: number) -> (),
	anunciar: (texto: string) -> (),
	mostrarFinal: (final: Final, alVolver: () -> (), alSalir: () -> ()) -> (),
	ocultarFinal: () -> (),
	ponerTablero: (estado: Mazmorra.Estado) -> (), -- tu bola, tus clavijas y el oro
	-- Inicio: elegir bola y bajar. alBajar recibe el Id de la bola.
	mostrarInicio: (progreso: Progreso.Datos, alBajar: (string) -> (), boton: string?) -> (),
	inicioAbierto: () -> boolean,
	mostrarHud: (si: boolean) -> (), -- la pelea se ve solo sentado en la máquina
	alSalir: (f: () -> ()) -> (), -- botón "Salir" de arriba
	ocultarInicio: () -> (),
	hayFinal: () -> boolean, -- final, inicio o ajustes abiertos: mientras tanto no se tira
	finalCerrado: () -> number, -- os.clock() de la última vez que se cerró una pantalla que tapa
	zonaLibre: () -> (number, number), -- y de arriba y de abajo (px de pantalla) libres para el tablero
	formula: Frame, -- etapa 10b: caja de la columna izquierda donde va FUERZA × MULTI
}

local Pantallas = {}

local T = Estilo.Texto
local M = Estilo.Medidas

local function numeroPelea(piso: number): string
	return ("%d de %d"):format(piso, #Config.Monstruos)
end

function Pantallas.crear(): Pantallas
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local cerrado = -math.huge

	-- ── Pelea ──────────────────────────────────────────────────────────────────────────────────
	local gui = Estilo.pantalla("Pantallas", 0, playerGui)
	local hud = Estilo.lienzo(gui)

	-- Etapa 10b (27/10): 3 columnas tipo Balatro. Izquierda: pelea y zona, vida, oro, la fórmula
	-- FUERZA × MULTI (la dibuja Numeros.crearPanel en `formula`) y tus clavijas especiales. Centro:
	-- el tablero (3D). Derecha: el monstruo (3D) con Salir y Ajustes arriba y la maña del jefe.
	-- Abajo, la bandeja: tu bola (acá) y los pergaminos y reliquias (TiendaVista).
	local ANCHO_COLUMNA = 250
	local arriba = Instance.new("Frame")
	arriba.Name = "BarraArriba"
	arriba.Size = UDim2.fromScale(1, 0) -- sin franja: el tablero usa todo el alto
	arriba.BackgroundTransparency = 1
	arriba.Parent = hud

	local izquierda = Instance.new("Frame")
	izquierda.Name = "Izquierda"
	izquierda.Position = UDim2.fromOffset(M.Margen, M.Margen)
	izquierda.Size = UDim2.new(0, ANCHO_COLUMNA, 1, -(M.BarraAbajo + 2 * M.Margen + 4))
	izquierda.BackgroundTransparency = 1
	izquierda.Parent = hud

	-- Pelea y zona.
	local pelea = Estilo.panel(izquierda)
	pelea.Name = "Pelea"
	pelea.Size = UDim2.new(1, 0, 0, 62)
	pelea.BackgroundTransparency = 0
	local peleaTexto = Estilo.texto(pelea, "", T.Grande)
	peleaTexto.Position = UDim2.fromOffset(0, 6)
	peleaTexto.Size = UDim2.new(1, 0, 0, 28)
	local zonaTexto = Estilo.texto(pelea, "", T.Chico, Estilo.Fuentes.Texto)
	zonaTexto.TextColor3 = Estilo.color("Apagado")
	zonaTexto.Position = UDim2.fromOffset(0, 34)
	zonaTexto.Size = UDim2.new(1, 0, 0, 22)

	-- Vida: corazón y barra verde con el número.
	local filaVida = Instance.new("Frame")
	filaVida.Name = "FilaVida"
	filaVida.Position = UDim2.fromOffset(0, 70)
	filaVida.Size = UDim2.new(1, 0, 0, 40)
	filaVida.BackgroundTransparency = 1
	filaVida.Parent = izquierda
	local corazon = Estilo.iconoHud(filaVida, "Corazon")
	corazon.Size = UDim2.fromOffset(40, 40)
	local vidaCaja = Estilo.panel(filaVida, "Sombra")
	vidaCaja.Name = "Vida"
	vidaCaja.Position = UDim2.fromOffset(46, 4)
	vidaCaja.Size = UDim2.new(1, -46, 0, 32)
	vidaCaja.BackgroundTransparency = 0
	local vidaRelleno = Instance.new("Frame")
	vidaRelleno.Size = UDim2.fromScale(1, 1)
	vidaRelleno.BackgroundColor3 = Estilo.color("Vida")
	vidaRelleno.BorderSizePixel = 0
	vidaRelleno.Parent = vidaCaja
	Estilo.redondear(vidaRelleno)
	local vidaTexto = Estilo.texto(vidaCaja, "", T.Normal)
	vidaTexto.Size = UDim2.fromScale(1, 1)
	vidaTexto.ZIndex = 2

	-- Oro: moneda y número dorado.
	local filaOro = Instance.new("Frame")
	filaOro.Name = "FilaOro"
	filaOro.Position = UDim2.fromOffset(0, 114)
	filaOro.Size = UDim2.new(1, 0, 0, 34)
	filaOro.BackgroundTransparency = 1
	filaOro.Parent = izquierda
	local moneda = Estilo.iconoHud(filaOro, "Moneda")
	moneda.Size = UDim2.fromOffset(34, 34)
	moneda.Position = UDim2.fromOffset(3, 0)
	local oro = Estilo.texto(filaOro, "", T.Grande)
	oro.Name = "Oro"
	oro.TextXAlignment = Enum.TextXAlignment.Left
	oro.TextColor3 = Estilo.color("Oro")
	oro.Position = UDim2.fromOffset(46, 0)
	oro.Size = UDim2.new(1, -46, 1, 0)

	-- Fórmula FUERZA × MULTI = GOLPE (la llena Numeros.crearPanel).
	local formula = Estilo.panel(izquierda)
	formula.Name = "Formula"
	formula.Position = UDim2.fromOffset(0, 154)
	formula.Size = UDim2.new(1, 0, 0, 176)
	formula.BackgroundTransparency = 0

	-- Clavijas especiales que tenés.
	local chips = Instance.new("Frame")
	chips.Name = "Clavijas"
	chips.Position = UDim2.fromOffset(0, 338)
	chips.Size = UDim2.new(1, 0, 1, -338)
	chips.BackgroundTransparency = 1
	chips.ClipsDescendants = true
	chips.Parent = izquierda
	local grilla = Instance.new("UIGridLayout")
	grilla.CellSize = UDim2.new(0.5, -3, 0, 26)
	grilla.CellPadding = UDim2.fromOffset(6, 4)
	grilla.SortOrder = Enum.SortOrder.LayoutOrder
	grilla.Parent = chips

	-- Salir y Ajustes, arriba a la derecha, con íconos pixel.
	local function botonIcono(nombre: string, icono: string, texto: string?): TextButton
		local b = Estilo.boton(hud, "", "PanelClaro", T.Normal)
		b.Name = nombre
		b.AnchorPoint = Vector2.new(1, 0)
		local dibujo = Estilo.iconoHud(b, icono)
		dibujo.AnchorPoint = Vector2.new(0, 0.5)
		dibujo.Position = UDim2.new(0, 8, 0.5, 0)
		dibujo.Size = UDim2.fromOffset(40, 40)
		if texto then
			b.Text = texto
			b.TextXAlignment = Enum.TextXAlignment.Right
			local margen = Instance.new("UIPadding")
			margen.PaddingRight = UDim.new(0, 12)
			margen.Parent = b
		end
		return b
	end
	local botonAjustes = botonIcono("Ajustes", "Engranaje")
	botonAjustes.Position = UDim2.new(1, -M.Margen, 0, M.Margen)
	botonAjustes.Size = UDim2.fromOffset(M.Boton, M.Boton)
	local botonSalir = botonIcono("Salir", "Puerta", "Salir")
	botonSalir.Position = UDim2.new(1, -(M.Margen + M.Boton + 10), 0, M.Margen)
	botonSalir.Size = UDim2.fromOffset(130, M.Boton)
	local alSalir: () -> () = function() end
	botonSalir.Activated:Connect(function()
		alSalir()
	end)
	botonAjustes.Activated:Connect(function()
		Ajustes.abrir(function()
			cerrado = os.clock()
		end)
	end)

	-- Maña del jefe: en la columna del monstruo, debajo de Salir y Ajustes.
	local mania = Estilo.texto(hud, "", T.Chico, Estilo.Fuentes.Titulo)
	mania.Name = "Mania"
	mania.AnchorPoint = Vector2.new(1, 0)
	mania.Position = UDim2.new(1, -M.Margen, 0, M.Margen + M.Boton + 12)
	-- Etapa 11: alto fijo y letra que se achica (con alto automático, la segunda línea se cortaba).
	mania.Size = UDim2.fromOffset(ANCHO_COLUMNA, 70)
	Estilo.ajustar(mania, T.Chico, 12)
	mania.BackgroundTransparency = 0.1
	mania.BackgroundColor3 = Estilo.color("Panel")
	mania.TextColor3 = Estilo.color("Peligro")
	mania.Visible = false
	Estilo.redondear(mania)
	local margenMania = Instance.new("UIPadding")
	margenMania.PaddingTop = UDim.new(0, 14)
	margenMania.PaddingBottom = UDim.new(0, 14)
	margenMania.PaddingLeft = UDim.new(0, 16)
	margenMania.PaddingRight = UDim.new(0, 16)
	margenMania.Parent = mania
	Estilo.marco(mania, "Panel")

	-- Bandeja de abajo: un panel de punta a punta; adentro, tu bola (los pergaminos y las
	-- reliquias los pone TiendaVista encima, en sus casilleros).
	local abajo = Estilo.panel(hud)
	abajo.Name = "BarraAbajo"
	abajo.AnchorPoint = Vector2.new(0, 1)
	abajo.Position = UDim2.new(0, M.Margen, 1, -4)
	abajo.Size = UDim2.new(1, -2 * M.Margen, 0, M.BarraAbajo)
	abajo.BackgroundTransparency = 0.05
	local bolaCaja = Instance.new("Frame")
	bolaCaja.Name = "Bola"
	bolaCaja.Position = UDim2.fromOffset(8, 6)
	bolaCaja.Size = UDim2.fromOffset(110, M.BarraAbajo - 12)
	bolaCaja.BackgroundColor3 = Estilo.color("Sombra")
	bolaCaja.BorderSizePixel = 0
	bolaCaja.Parent = abajo
	Estilo.marco(bolaCaja, "Casillero")
	local bolaTitulo = Estilo.texto(bolaCaja, "Bola", T.Chico, Estilo.Fuentes.Texto)
	bolaTitulo.TextColor3 = Estilo.color("Apagado")
	bolaTitulo.Position = UDim2.fromOffset(0, 6)
	bolaTitulo.Size = UDim2.new(1, 0, 0, 20)
	local bolaNombre = Estilo.texto(bolaCaja, "", T.Normal)
	bolaNombre.Position = UDim2.fromOffset(0, 28)
	bolaNombre.Size = UDim2.new(1, 0, 0, 26)

	-- Cartel grande en el medio ("¡Piso 2!", "¡Nueva bola: Fuego!"), arriba de todo.
	local guiAvisos = Estilo.pantalla("Avisos", 30, playerGui)
	local lienzoAvisos = Estilo.lienzo(guiAvisos)
	local anuncio = Estilo.texto(lienzoAvisos, "", T.Enorme)
	anuncio.AnchorPoint = Vector2.new(0.5, 0.5)
	anuncio.Position = UDim2.fromScale(0.5, 0.42)
	anuncio.Size = UDim2.fromOffset(760, 120)
	anuncio.TextColor3 = Color3.fromHex(Config.Colores.Numero)
	anuncio.TextStrokeTransparency = 1
	anuncio.TextTransparency = 1

	-- ── Final (perder o ganar) ─────────────────────────────────────────────────────────────────
	local guiFinal = Estilo.pantalla("PantallaFinal", 10, playerGui)
	guiFinal.Enabled = false
	Estilo.velo(guiFinal)
	local lienzoFinal = Estilo.lienzo(guiFinal)
	local caja = Estilo.panel(lienzoFinal)
	caja.Name = "Final"
	caja.AnchorPoint = Vector2.new(0.5, 0.5)
	caja.Position = UDim2.fromScale(0.5, 0.5)
	caja.Size = UDim2.fromOffset(640, 410)
	caja.BackgroundTransparency = 0
	local bordeFinal = Estilo.borde(caja, "Borde", 4)
	local titulo = Estilo.texto(caja, "", T.Enorme)
	titulo.Position = UDim2.fromOffset(20, 18)
	titulo.Size = UDim2.new(1, -40, 0, 64)
	local ganadas = Estilo.texto(caja, "", T.Grande, Estilo.Fuentes.Texto)
	ganadas.Position = UDim2.fromOffset(20, 96)
	ganadas.Size = UDim2.new(1, -40, 0, 40)
	local mejor = Estilo.texto(caja, "", T.Grande, Estilo.Fuentes.Texto)
	mejor.TextColor3 = Estilo.color("Oro")
	mejor.Position = UDim2.fromOffset(20, 140)
	mejor.Size = UDim2.new(1, -40, 0, 40)
	local desbloqueos = Estilo.texto(caja, "", T.Normal)
	desbloqueos.TextColor3 = Color3.fromHex(Config.Colores.Numero)
	desbloqueos.Position = UDim2.fromOffset(20, 188)
	desbloqueos.Size = UDim2.new(1, -40, 0, 70)
	local volver = Estilo.boton(caja, "Volver a bajar", "Principal", T.Grande)
	volver.Name = "Volver"
	volver.Position = UDim2.fromOffset(20, 300)
	volver.Size = UDim2.new(0.62, -36, 0, M.BotonGrande)
	local cambiar = Estilo.boton(caja, "Salir", "Boton", T.Normal)
	cambiar.Name = "CambiarBola"
	cambiar.AnchorPoint = Vector2.new(1, 0)
	cambiar.Position = UDim2.new(1, -20, 0, 300)
	cambiar.Size = UDim2.new(0.38, -10, 0, M.BotonGrande)

	local alVolver: (() -> ())? = nil
	local alCambiar: (() -> ())? = nil
	local function cerrarFinal()
		alVolver, alCambiar = nil, nil
		if guiFinal.Enabled then
			cerrado = os.clock()
		end
		guiFinal.Enabled = false
	end
	volver.Activated:Connect(function()
		local accion = alVolver
		if accion then
			cerrarFinal()
			accion()
		end
	end)
	cambiar.Activated:Connect(function()
		local accion = alCambiar
		if accion then
			cerrarFinal()
			accion()
		end
	end)

	-- ── Inicio ─────────────────────────────────────────────────────────────────────────────────
	local guiInicio = Estilo.pantalla("PantallaInicio", 11, playerGui)
	guiInicio.Enabled = false
	Estilo.velo(guiInicio, 0.15)
	local inicio = Estilo.lienzo(guiInicio)
	local tituloInicio = Estilo.texto(inicio, Config.NombreJuego, T.Titulo)
	tituloInicio.AnchorPoint = Vector2.new(0.5, 0)
	tituloInicio.Position = UDim2.new(0.5, 0, 0, 14)
	tituloInicio.Size = UDim2.fromOffset(640, 84)
	local mejorInicio = Estilo.texto(inicio, "", T.Normal, Estilo.Fuentes.Texto)
	mejorInicio.TextColor3 = Estilo.color("Oro")
	mejorInicio.AnchorPoint = Vector2.new(0.5, 0)
	mejorInicio.Position = UDim2.new(0.5, 0, 0, 98)
	mejorInicio.Size = UDim2.fromOffset(900, 32)
	Estilo.ajustar(mejorInicio, T.Normal, 18)
	local elegi = Estilo.texto(inicio, "Elegí tu bola", T.Normal)
	elegi.AnchorPoint = Vector2.new(0.5, 0)
	elegi.Position = UDim2.new(0.5, 0, 0, 136)
	elegi.Size = UDim2.fromOffset(400, 30)
	local mesaBolas = Instance.new("Frame")
	mesaBolas.Name = "Bolas"
	mesaBolas.AnchorPoint = Vector2.new(0.5, 0)
	mesaBolas.Position = UDim2.new(0.5, 0, 0, 172)
	mesaBolas.Size = UDim2.fromOffset(720, 196)
	mesaBolas.BackgroundTransparency = 1
	mesaBolas.Parent = inicio
	local ordenBolas = Estilo.lista(mesaBolas, true, 16)
	ordenBolas.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local bajar = Estilo.boton(inicio, "Bajar a la mazmorra", "Principal", T.Grande)
	bajar.Name = "Bajar"
	bajar.AnchorPoint = Vector2.new(0.5, 0)
	bajar.Position = UDim2.new(0.5, 0, 0, 382)
	bajar.Size = UDim2.fromOffset(440, M.BotonGrande)
	local ajustesInicio = Estilo.boton(inicio, "⚙", "PanelClaro", T.Enorme)
	ajustesInicio.Name = "Ajustes"
	ajustesInicio.AnchorPoint = Vector2.new(1, 0)
	ajustesInicio.Position = UDim2.new(1, -M.Margen, 0, M.Margen)
	ajustesInicio.Size = UDim2.fromOffset(M.Boton, M.Boton)
	ajustesInicio.Activated:Connect(function()
		Ajustes.abrir()
	end)

	local alBajar: ((string) -> ())? = nil
	local textoBajar = "Bajar a la mazmorra" -- en el mostrador de la sala: "Elegir"
	local elegida = "hierro"
	local progresoInicio: Progreso.Datos? = nil
	local dibujarInicio: () -> ()

	local function cartaBola(p: Progreso.Datos, orden: number, id: string)
		local d = (Config.Bolas :: any)[id]
		local tiene = Progreso.tieneBola(p, id)
		local esta = id == elegida
		local carta = Instance.new("TextButton")
		carta.Name = "Bola" .. id
		carta.LayoutOrder = orden
		carta.Size = UDim2.fromOffset(226, 196)
		carta.BackgroundColor3 = Estilo.color("Carta")
		carta.BackgroundTransparency = if tiene then 0 else 0.5
		carta.BorderSizePixel = 0
		carta.AutoButtonColor = tiene
		carta.Text = ""
		carta.Parent = mesaBolas
		Estilo.redondear(carta)
		Estilo.borde(carta, if esta then "Oro" else "Borde", if esta then 6 else 2)
		-- Ícono de la bola (ForgeGUI); las bloqueadas, apagadas y con candado.
		local muestra = Estilo.icono(carta, (Config.Assets.Bolas :: any)[id])
		muestra.Visible = true
		muestra.AnchorPoint = Vector2.new(0.5, 0)
		muestra.Position = UDim2.new(0.5, 0, 0, 8)
		muestra.Size = UDim2.fromOffset(64, 64)
		muestra.ImageTransparency = if tiene then 0 else 0.6
		muestra.ImageColor3 = if tiene then Color3.new(1, 1, 1) else Color3.fromRGB(120, 120, 140)
		if not tiene then
			local candado = Estilo.texto(muestra, "🔒", T.Grande)
			candado.Size = UDim2.fromScale(1, 1)
		end
		local nombre = Estilo.texto(carta, d.Nombre, T.Normal)
		nombre.Position = UDim2.fromOffset(8, 72)
		nombre.Size = UDim2.new(1, -16, 0, 30)
		nombre.TextColor3 = if tiene then Estilo.color("Texto") else Estilo.color("Apagado")
		local detalle = Estilo.texto(
			carta,
			if tiene then d.Descripcion else "Se consigue: " .. d.Logro,
			T.Chico,
			Estilo.Fuentes.Texto
		)
		detalle.TextStrokeTransparency = 1
		detalle.TextColor3 = if tiene then Estilo.color("Texto") else Estilo.color("Apagado")
		detalle.TextYAlignment = Enum.TextYAlignment.Top
		detalle.Position = UDim2.fromOffset(10, 106)
		detalle.Size = UDim2.new(1, -20, 1, -112)
		Estilo.ajustar(detalle, T.Chico, 18)
		if tiene then
			carta.Activated:Connect(function()
				elegida = id
				dibujarInicio()
			end)
		end
	end

	dibujarInicio = function()
		local p = progresoInicio
		if not p then
			return
		end
		for _, hijo in mesaBolas:GetChildren() do
			if hijo:IsA("GuiButton") then
				hijo:Destroy()
			end
		end
		mejorInicio.Text = if p.MejorPiso > 0
			then ("Tu mejor: %s peleas · Jefes vencidos: %d · Mazmorras ganadas: %d"):format(
				numeroPelea(p.MejorPiso),
				p.JefesVencidos,
				p.PartidasGanadas
			)
			else "Bajá a la mazmorra y llegá lo más lejos que puedas"
		for orden, id in Config.OrdenBolas do
			cartaBola(p, orden, id)
		end
		local d = (Config.Bolas :: any)[elegida]
		bajar.Text = ("%s · %s"):format(textoBajar, if d then d.Nombre else elegida)
	end

	bajar.Activated:Connect(function()
		local accion = alBajar
		if accion then
			alBajar = nil -- un solo toque
			accion(elegida)
		end
	end)

	local function cerrarInicio()
		alBajar = nil
		if guiInicio.Enabled then
			cerrado = os.clock()
		end
		guiInicio.Enabled = false
	end

	-- ── Partes que se actualizan ───────────────────────────────────────────────────────────────
	local function chip(valor: string, hex: string?, orden: number)
		local c = Instance.new("Frame")
		c.BackgroundColor3 = Estilo.color("Panel")
		c.BorderSizePixel = 0
		c.Parent = chips
		Estilo.redondear(c)
		if hex then
			local borde = Instance.new("UIStroke")
			borde.Color = Color3.fromHex(hex)
			borde.Thickness = 2
			borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			borde.Parent = c
		end
		c.LayoutOrder = orden
		local t = Estilo.texto(c, valor, T.Chico, Estilo.Fuentes.Texto)
		t.Size = UDim2.fromScale(1, 1)
		Estilo.ajustar(t, T.Chico, 11) -- etapa 11: "6 Roja · Nv 4" se cortaba
		if hex then
			t.TextColor3 = Color3.fromHex(hex)
		end
	end

	local function ponerTablero(e: Mazmorra.Estado)
		oro.Text = tostring(e.Oro)
		local bola = (Config.Bolas :: any)[e.Bola]
		bolaNombre.Text = if bola then bola.Nombre else e.Bola
		bolaNombre.TextColor3 = if e.Bola == "fuego"
			then Color3.fromHex(Config.Colores.BolaFuego)
			else Estilo.color("Texto")
		for _, hijo in chips:GetChildren() do
			if hijo:IsA("GuiObject") then
				hijo:Destroy()
			end
		end
		local cuenta = Clavijas.contar(e.Tablero)
		for orden, tipo in Config.OrdenClavijas do
			local n = cuenta[tipo] or 0
			if n > 0 and tipo ~= "gris" then
				local nivel = Clavijas.nivel(e.Niveles, tipo)
				local nombre = (Config.Clavijas :: any)[tipo].Nombre
				chip(
					if nivel > 1
						then ("%d %s · Nv %d"):format(n, nombre, nivel)
						else ("%d %s"):format(n, nombre),
					Clavijas.color(tipo),
					orden
				)
			end
		end
		local huecos = cuenta.hueco or 0
		if huecos > 0 then
			chip(("%d rotas"):format(huecos), nil, 99)
		end
	end

	local function ponerVida(vida: number, maxima: number)
		vidaTexto.Text = ("%d/%d"):format(vida, maxima)
		vidaRelleno.Size = UDim2.fromScale(math.clamp(vida / math.max(maxima, 1), 0, 1), 1)
	end

	local anuncios = 0
	return {
		ponerEstado = function(e: Mazmorra.Estado)
			ponerVida(e.Vida, e.VidaMaxima)
			local m = Mazmorra.monstruo(e.Piso)
			peleaTexto.Text = if e.Piso == 0
				then "PRÁCTICA"
				elseif m.EsJefe then ("JEFE %s"):format(numeroPelea(e.Piso))
				else ("PELEA %s"):format(numeroPelea(e.Piso))
			peleaTexto.TextColor3 = if m.EsJefe
				then Estilo.color("Peligro")
				else Estilo.color("Texto")
			zonaTexto.Text = ("Zona %d · %s"):format(m.Zona, Config.Zonas[m.Zona] or "")
			mania.Visible = e.Mania ~= "" and e.Fase == "peleando"
			mania.Text = if e.Mania ~= "" then Mazmorra.textoMania(e.Mania, m.Zona) else ""
		end,
		ponerVida = ponerVida,
		anunciar = function(valor: string)
			anuncios += 1
			local marca = anuncios
			anuncio.Text = valor
			anuncio.TextTransparency = 0
			anuncio.TextStrokeTransparency = 0
			task.delay(Config.Turno.CartelPiso, function()
				if anuncios == marca then
					TweenService:Create(
						anuncio,
						TweenInfo.new(0.25),
						{ TextTransparency = 1, TextStrokeTransparency = 1 }
					):Play()
				end
			end)
		end,
		mostrarFinal = function(f: Final, cuandoVuelva: () -> (), cuandoCambie: () -> ())
			local ganadasAhora = if f.Gano then #Config.Monstruos else f.Piso - 1
			titulo.Text = if f.Gano
				then "¡Ganaste la mazmorra!"
				else ("Caíste en el piso %d"):format(f.Piso)
			titulo.TextColor3 = if f.Gano then Estilo.color("Oro") else Estilo.color("Texto")
			bordeFinal.Color = if f.Gano then Estilo.color("Oro") else Estilo.color("Peligro")
			ganadas.Text = ("Ganaste %s peleas"):format(numeroPelea(ganadasAhora))
			local record = f.MejorAhora > f.MejorAntes
			mejor.Text = ("Tu mejor: %s%s"):format(
				numeroPelea(f.MejorAhora),
				if record then " · ¡Récord nuevo!" else ""
			)
			desbloqueos.Visible = #f.Desbloqueos > 0
			desbloqueos.Text = "Desbloqueaste: " .. table.concat(f.Desbloqueos, ", ")
			alVolver, alCambiar = cuandoVuelva, cuandoCambie
			guiInicio.Enabled = false
			guiFinal.Enabled = true
		end,
		ocultarFinal = cerrarFinal,
		ponerTablero = ponerTablero,
		mostrarInicio = function(p: Progreso.Datos, cuandoBaje: (string) -> (), boton: string?)
			textoBajar = boton or "Bajar a la mazmorra"
			if progresoInicio == nil or not guiInicio.Enabled then
				elegida = p.BolaElegida -- al abrir, la que eligió la última vez
			end
			if not Progreso.tieneBola(p, elegida) then
				elegida = "hierro"
			end
			progresoInicio = p
			alBajar = cuandoBaje
			dibujarInicio()
			guiFinal.Enabled = false
			guiInicio.Enabled = true
		end,
		ocultarInicio = cerrarInicio,
		inicioAbierto = function(): boolean
			return guiInicio.Enabled
		end,
		mostrarHud = function(si: boolean)
			gui.Enabled = si
		end,
		alSalir = function(f: () -> ())
			alSalir = f
		end,
		hayFinal = function(): boolean
			return guiFinal.Enabled or guiInicio.Enabled or Ajustes.abierto()
		end,
		finalCerrado = function(): number
			return cerrado
		end,
		formula = formula,
		zonaLibre = function(): (number, number)
			local y0 = arriba.AbsolutePosition.Y + arriba.AbsoluteSize.Y
			local y1 = abajo.AbsolutePosition.Y
			return y0, y1
		end,
	}
end

return Pantallas
