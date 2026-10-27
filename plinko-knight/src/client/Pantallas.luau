--!strict
-- Pantallas (etapa 7, graybox ordenado). Todo sale de client/Estilo (colores, fuentes, tamaños y
-- el lienzo con escala), así se ve igual en compu, tablet y celular horizontal.
--
-- Pelea: franja de arriba con tu vida y oro (izquierda), "Pelea 5 de 9" y la zona (centro) y el
-- botón de Ajustes (derecha); debajo de la vida, cuántas clavijas especiales tenés (la maña del
-- jefe va en el cartel del monstruo desde la etapa 12b); franja de abajo con tu bola (los pergaminos y las reliquias de
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
local Kit = require(script.Parent:WaitForChild("Kit"))
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

	-- Etapa 12b (kit de Forja): arriba, 3 píldoras que saltan cuando cambian (vida, oro y pelea) y
	-- la zona; después el panel FUERZA × MULTI y tus clavijas especiales como bolitas de color.
	local ANCHO_PILDORA, ALTO_PILDORA = 156, 32
	local function pildora(icono: string, colores: { string }, y: number): (Frame, TextLabel)
		local p, texto = Kit.pildora(icono, colores, ANCHO_PILDORA, ALTO_PILDORA)
		p.Position = UDim2.fromOffset(ALTO_PILDORA * 0.5, y)
		texto.TextSize = 19
		local salto = Instance.new("UIScale")
		salto.Name = "Salto"
		salto.Parent = p
		p.Parent = izquierda
		return p, texto
	end
	local function saltar(p: Frame)
		local salto = p:FindFirstChild("Salto") :: UIScale?
		if salto then
			salto.Scale = 1.18
			TweenService:Create(salto, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 })
				:Play()
		end
	end
	local pildoraVida, vidaTexto = pildora(Config.Assets.Hud.Corazon, Kit.Colores.Rojo, 2)
	local pildoraOro, oro = pildora("Moneda", Kit.Colores.Amarillo, 42)
	local pildoraPelea, peleaTexto = pildora("Corona", Kit.Colores.Violeta, 82)
	local zonaTexto = Kit.texto("", 15, Color3.fromHex("#C9D6EE"), 2)
	zonaTexto.Position = UDim2.fromOffset(ALTO_PILDORA * 0.5 + 4, 118)
	zonaTexto.Parent = izquierda

	-- Fórmula FUERZA × MULTI = GOLPE (la llena Numeros.crearPanel).
	local formula = Instance.new("Frame")
	formula.Name = "Formula"
	formula.Position = UDim2.fromOffset(0, 142)
	formula.Size = UDim2.new(1, 0, 0, 176)
	Kit.panel(formula)
	formula.Parent = izquierda

	-- Clavijas especiales que tenés: una bolita de su color con cuántas hay abajo y, si subió de
	-- nivel, un globito rojo con el nivel.
	local chips = Instance.new("Frame")
	chips.Name = "Clavijas"
	chips.Position = UDim2.fromOffset(0, 326)
	chips.Size = UDim2.new(1, 0, 1, -326)
	chips.BackgroundTransparency = 1
	chips.Parent = izquierda
	local filaChips = Instance.new("UIListLayout")
	filaChips.FillDirection = Enum.FillDirection.Horizontal
	filaChips.Padding = UDim.new(0, 12)
	filaChips.SortOrder = Enum.SortOrder.LayoutOrder
	filaChips.Parent = chips

	-- Salir (rojo, puerta) y Ajustes (gris, engranaje), arriba a la derecha: botones del kit.
	local function botonIcono(nombre: string, icono: string, color: string): TextButton
		local b = Kit.boton({ Icono = icono, Color = color, Ancho = 52, Alto = 46 })
		b.Name = nombre
		b.AnchorPoint = Vector2.new(1, 0)
		b.Parent = hud
		return b
	end
	local botonAjustes = botonIcono("Ajustes", "Engranaje", "Gris")
	botonAjustes.Position = UDim2.new(1, -M.Margen, 0, M.Margen)
	local botonSalir = botonIcono("Salir", Config.Assets.Hud.Puerta, "Rojo")
	botonSalir.Position = UDim2.new(1, -(M.Margen + 52 + 10), 0, M.Margen)
	local alSalir: () -> () = function() end
	botonSalir.Activated:Connect(function()
		alSalir()
	end)
	botonAjustes.Activated:Connect(function()
		Ajustes.abrir(function()
			cerrado = os.clock()
		end)
	end)

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
	local function chip(cuantas: number, hex: string, nivel: number, orden: number)
		local c = Instance.new("Frame")
		c.BackgroundTransparency = 1
		c.Size = UDim2.fromOffset(30, 50)
		c.LayoutOrder = orden
		c.Parent = chips
		local bolita = Instance.new("Frame")
		bolita.AnchorPoint = Vector2.new(0.5, 0)
		bolita.Position = UDim2.fromScale(0.5, 0)
		bolita.Size = UDim2.fromOffset(28, 28)
		bolita.BackgroundColor3 = Color3.fromHex(hex)
		Kit.esquinas(bolita, 14)
		Kit.borde(bolita, 3)
		bolita.Parent = c
		local n = Kit.texto(tostring(cuantas), 17)
		n.AnchorPoint = Vector2.new(0.5, 0)
		n.Position = UDim2.new(0.5, 0, 0, 30)
		n.Parent = c
		if nivel > 1 then
			local g = Kit.globito(tostring(nivel), 18)
			g.Position = UDim2.fromOffset(26, 2)
			g.Parent = c
		end
	end

	local function ponerTablero(e: Mazmorra.Estado)
		if oro.Text ~= tostring(e.Oro) then
			oro.Text = tostring(e.Oro)
			saltar(pildoraOro)
		end
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
				chip(n, Clavijas.color(tipo), Clavijas.nivel(e.Niveles, tipo), orden)
			end
		end
		local huecos = cuenta.hueco or 0
		if huecos > 0 then
			chip(huecos, Clavijas.color("hueco"), 1, 99)
		end
	end

	local function ponerVida(vida: number, maxima: number)
		local texto = ("%d/%d"):format(vida, maxima)
		if vidaTexto.Text ~= texto then
			vidaTexto.Text = texto
			saltar(pildoraVida)
		end
	end

	local anuncios = 0
	return {
		ponerEstado = function(e: Mazmorra.Estado)
			ponerVida(e.Vida, e.VidaMaxima)
			local m = Mazmorra.monstruo(e.Piso)
			local texto = if e.Piso == 0
				then "PRÁCTICA"
				elseif m.EsJefe then ("JEFE %d/%d"):format(e.Piso, #Config.Monstruos)
				else ("PELEA %d/%d"):format(e.Piso, #Config.Monstruos)
			if peleaTexto.Text ~= texto then
				peleaTexto.Text = texto
				saltar(pildoraPelea)
			end
			peleaTexto.TextColor3 = if m.EsJefe
				then Color3.fromHex(Config.Colores.Oro)
				else Color3.new(1, 1, 1)
			zonaTexto.Text = ("Zona %d · %s"):format(m.Zona, Config.Zonas[m.Zona] or "")
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
