--!strict
-- Pantallas de los pasos 5b a 5d, con el estilo de la etapa 7 (client/Estilo):
-- - Franja de abajo de la pelea: los 2 lugares de pergaminos (al lado de tu bola) y las 5
--   reliquias (a la derecha, en el orden en que se aplican). Tocar una reliquia abre su ficha; en
--   la tienda, ahí se vende o se mueve.
-- - La tienda (etapa 10b): una pantalla aparte, como en Balatro: cartas grandes en fila (se
--   deslizan si no entran), Renovar y ¿Qué sale? abajo a la izquierda y BAJAR enorme abajo a la
--   derecha. Si hay que tocar clavijas, se corre (apartar) y vuelve.
-- - El cofre del jefe (la pantalla de mejoras): 3 cartas grandes, se elige con un toque, sin
--   confirmar. "Más tarde" la cierra y el botón Cofre de la tienda la vuelve a abrir.
-- Solo dibuja y avisa qué se tocó: lo demás lo hace Main.client con el servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Reliquias = require(Shared:WaitForChild("Reliquias"))
local TiendaModulo = require(Shared:WaitForChild("Tienda"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Estilo = require(script.Parent:WaitForChild("Estilo"))
local Sonidos = require(script.Parent:WaitForChild("Sonidos"))

export type Acciones = {
	comprar: (indice: number) -> (),
	tomarCofre: (indice: number) -> (), -- reliquia del cofre del jefe
	renovar: () -> (),
	bajar: () -> (),
	usar: (lugar: number) -> (), -- pergamino
	vender: (lugar: number) -> (), -- reliquia
	mover: (desde: number, hacia: number) -> (), -- reliquia
}

export type TiendaVista = {
	mostrar: (estado: Mazmorra.Estado) -> (),
	ocultar: () -> (),
	ponerPergaminos: (estado: Mazmorra.Estado) -> (),
	ponerReliquias: (estado: Mazmorra.Estado) -> (),
	activar: (lugar: number, texto: string) -> (), -- la reliquia salta y muestra lo que hizo
	apartar: (si: boolean) -> (), -- etapa 10b: la tienda se corre mientras tocás clavijas
	abierta: () -> boolean, -- cofre, ficha o chances abiertos (tapan la pantalla)
	mostrarHud: (si: boolean) -> (), -- etapa 7b: solo se ve sentado en la máquina
}

local TiendaVista = {}

local T = Estilo.Texto
local M = Estilo.Medidas

local ajustar = Estilo.ajustar

function TiendaVista.crear(acciones: Acciones): TiendaVista
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = Estilo.pantalla("PantallaTienda", 8, playerGui)
	local lienzo = Estilo.lienzo(gui)

	-- ── Franja de abajo: pergaminos y reliquias ────────────────────────────────────────────────
	local altoFranja = M.BarraAbajo - 10
	local lugares = Instance.new("Frame")
	lugares.Name = "Pergaminos"
	lugares.AnchorPoint = Vector2.new(0, 1)
	lugares.Position = UDim2.new(0, M.Margen + 128, 1, -10)
	lugares.Size = UDim2.fromOffset(270, altoFranja)
	lugares.BackgroundTransparency = 1
	lugares.Parent = lienzo
	Estilo.lista(lugares, true, 8)
	local botonesLugar: { TextButton } = {}
	for lugar = 1, Config.LugaresPergamino do
		local b = Estilo.boton(lugares, "", "Sombra", T.Chico)
		b.Name = "Lugar" .. lugar
		b.Size = UDim2.fromOffset(130, altoFranja)
		Estilo.marco(b, "Casillero")
		b.LayoutOrder = lugar
		ajustar(b, T.Chico, 16)
		b.Activated:Connect(function()
			acciones.usar(lugar)
		end)
		botonesLugar[lugar] = b
	end

	local filaReliquias = Instance.new("Frame")
	filaReliquias.Name = "Reliquias"
	filaReliquias.AnchorPoint = Vector2.new(1, 1)
	filaReliquias.Position = UDim2.new(1, -(M.Margen + 8), 1, -10)
	filaReliquias.Size = UDim2.fromOffset(5 * 92 + 4 * 6, altoFranja)
	filaReliquias.BackgroundTransparency = 1
	filaReliquias.Parent = lienzo
	local ordenFila = Estilo.lista(filaReliquias, true, 6)
	ordenFila.HorizontalAlignment = Enum.HorizontalAlignment.Right

	-- ── La tienda: pantalla aparte (etapa 10b) ─────────────────────────────────────────────────
	local panel = Estilo.panel(lienzo)
	panel.Name = "Tienda"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, M.Margen)
	panel.Size = UDim2.new(1, -2 * M.Margen, 1, -(M.BarraAbajo + 2 * M.Margen + 8))
	panel.BackgroundTransparency = 0
	panel.Visible = false
	local titulo = Estilo.texto(panel, "TIENDA", T.Enorme)
	titulo.TextXAlignment = Enum.TextXAlignment.Left
	titulo.TextColor3 = Estilo.color("Oro")
	titulo.Position = UDim2.fromOffset(24, 12)
	titulo.Size = UDim2.fromOffset(190, 48)
	local monedaTienda = Estilo.iconoHud(panel, "Moneda")
	monedaTienda.Position = UDim2.fromOffset(226, 22)
	monedaTienda.Size = UDim2.fromOffset(28, 28)
	local ganado = Estilo.texto(panel, "", T.Normal, Estilo.Fuentes.Texto)
	ganado.TextXAlignment = Enum.TextXAlignment.Left
	ganado.TextColor3 = Estilo.color("Oro")
	ganado.Position = UDim2.fromOffset(262, 22)
	ganado.Size = UDim2.new(1, -470, 0, 28)
	ajustar(ganado, T.Normal, 14)
	local botonCofre = Estilo.boton(panel, "Cofre", "Oro", T.Grande)
	botonCofre.Name = "Cofre"
	botonCofre.AnchorPoint = Vector2.new(1, 0)
	botonCofre.Position = UDim2.new(1, -24, 0, 12)
	botonCofre.Size = UDim2.fromOffset(170, M.Boton)
	botonCofre.TextColor3 = Estilo.color("TextoPrincipal")
	botonCofre.TextStrokeTransparency = 1
	botonCofre.Visible = false

	-- Cartas en venta, en fila (se deslizan si no entran).
	local lista = Instance.new("ScrollingFrame")
	lista.Name = "Lista"
	lista.Position = UDim2.fromOffset(20, 66)
	lista.Size = UDim2.new(1, -40, 1, -(66 + M.BotonGrande + 30))
	lista.BackgroundTransparency = 1
	lista.BorderSizePixel = 0
	lista.ScrollBarThickness = 6
	lista.AutomaticCanvasSize = Enum.AutomaticSize.X
	lista.CanvasSize = UDim2.new()
	lista.ScrollingDirection = Enum.ScrollingDirection.X
	lista.ClipsDescendants = true
	lista.Parent = panel
	local ordenLista = Estilo.lista(lista, true, 16)
	ordenLista.HorizontalAlignment = Enum.HorizontalAlignment.Left
	local margenLista = Instance.new("UIPadding")
	margenLista.PaddingTop = UDim.new(0, 20)
	margenLista.PaddingLeft = UDim.new(0, 10)
	margenLista.PaddingRight = UDim.new(0, 10)
	margenLista.Parent = lista
	-- Qué viene después (y la maña si es un jefe), arriba de los botones.
	local proximo = Estilo.texto(panel, "", T.Chico, Estilo.Fuentes.Texto)
	proximo.Name = "Proximo"
	proximo.TextXAlignment = Enum.TextXAlignment.Left
	proximo.TextWrapped = true
	proximo.AnchorPoint = Vector2.new(0, 1)
	proximo.Position = UDim2.new(0, 400, 1, -18)
	proximo.Size = UDim2.new(1, -(400 + 300 + 48), 0, M.BotonGrande)
	ajustar(proximo, T.Chico, 13)

	-- Botones de abajo: Renovar y ¿Qué sale? a la izquierda; BAJAR enorme a la derecha.
	local renovar = Estilo.boton(panel, "", "Boton", T.Normal)
	renovar.Name = "Renovar"
	renovar.AnchorPoint = Vector2.new(0, 1)
	renovar.Position = UDim2.new(0, 24, 1, -18)
	renovar.Size = UDim2.fromOffset(180, M.BotonGrande)
	renovar.Activated:Connect(acciones.renovar)
	local info = Estilo.boton(panel, "¿Qué sale?", "PanelClaro", T.Normal)
	info.Name = "Info"
	info.AnchorPoint = Vector2.new(0, 1)
	info.Position = UDim2.new(0, 214, 1, -18)
	info.Size = UDim2.fromOffset(170, M.BotonGrande)
	local bajar = Estilo.boton(panel, "BAJAR", "Principal", T.Enorme)
	bajar.Name = "Bajar"
	bajar.AnchorPoint = Vector2.new(1, 1)
	bajar.Position = UDim2.new(1, -24, 1, -18)
	bajar.Size = UDim2.fromOffset(300, M.BotonGrande)
	bajar.Activated:Connect(acciones.bajar)
	local escalaBajar = Instance.new("UIScale")
	escalaBajar.Parent = bajar

	-- Las cartas se balancean apenas (cada una a su ritmo) y el BAJAR late (etapa 10b).
	local cartasTienda: { GuiObject } = {}
	game:GetService("RunService").Heartbeat:Connect(function()
		if not panel.Visible then
			return
		end
		local t = os.clock()
		for k, c in cartasTienda do
			if c.Parent then
				c.Rotation = math.sin(t * 1.6 + k * 1.3) * 1.5
			end
		end
		escalaBajar.Scale = 1 + math.sin(t * 4) * 0.025
	end)

	-- ── Ventanas que tapan todo (en su propio ScreenGui, con velo) ─────────────────────────────
	local guiVentanas = Estilo.pantalla("VentanasTienda", 9, playerGui)
	guiVentanas.Enabled = false
	Estilo.velo(guiVentanas)
	local ventanas = Estilo.lienzo(guiVentanas)
	local function ventana(nombre: string): Frame
		local f = Instance.new("Frame")
		f.Name = nombre
		f.Size = UDim2.fromScale(1, 1)
		f.BackgroundTransparency = 1
		f.Visible = false
		f.Parent = ventanas
		return f
	end
	local function actualizarVentanas()
		local alguna = false
		for _, hijo in ventanas:GetChildren() do
			if hijo:IsA("Frame") and hijo.Visible then
				alguna = true
			end
		end
		guiVentanas.Enabled = alguna
	end
	local function abrir(f: Frame, si: boolean)
		f.Visible = si
		actualizarVentanas()
	end

	-- "¿Qué sale?": las chances de todo lo que puede salir (sección 6 de la GUIA).
	local chances = ventana("Chances")
	local cajaChances = Estilo.panel(chances)
	cajaChances.AnchorPoint = Vector2.new(0.5, 0.5)
	cajaChances.Position = UDim2.fromScale(0.5, 0.5)
	cajaChances.Size = UDim2.new(0, 560, 1, -40)
	cajaChances.BackgroundTransparency = 0
	local tituloChances = Estilo.texto(cajaChances, "Lo que puede salir en la tienda", T.Grande)
	tituloChances.Position = UDim2.fromOffset(16, 10)
	tituloChances.Size = UDim2.new(1, -32, 0, 40)
	local textoChances = Instance.new("ScrollingFrame")
	textoChances.Position = UDim2.fromOffset(16, 56)
	textoChances.Size = UDim2.new(1, -32, 1, -(56 + M.Boton + 20))
	textoChances.BackgroundTransparency = 1
	textoChances.BorderSizePixel = 0
	textoChances.ScrollBarThickness = 6
	textoChances.AutomaticCanvasSize = Enum.AutomaticSize.Y
	textoChances.CanvasSize = UDim2.new()
	textoChances.Parent = cajaChances
	local lineas = Estilo.texto(
		textoChances,
		table.concat(TiendaModulo.chances(), "\n"),
		T.Chico,
		Estilo.Fuentes.Texto
	)
	lineas.TextXAlignment = Enum.TextXAlignment.Left
	lineas.TextYAlignment = Enum.TextYAlignment.Top
	lineas.TextStrokeTransparency = 1
	lineas.Size = UDim2.new(1, -10, 0, 0)
	lineas.AutomaticSize = Enum.AutomaticSize.Y
	local cerrarChances = Estilo.boton(cajaChances, "Cerrar", "Boton", T.Normal)
	cerrarChances.AnchorPoint = Vector2.new(0.5, 1)
	cerrarChances.Position = UDim2.new(0.5, 0, 1, -10)
	cerrarChances.Size = UDim2.fromOffset(220, M.Boton)
	info.Activated:Connect(function()
		abrir(chances, true)
	end)
	cerrarChances.Activated:Connect(function()
		abrir(chances, false)
	end)

	-- Ficha de una reliquia (al tocarla): qué hace y, en la tienda, vender o mover.
	local ficha = ventana("FichaReliquia")
	local cajaFicha = Estilo.panel(ficha)
	cajaFicha.AnchorPoint = Vector2.new(0.5, 0.5)
	cajaFicha.Position = UDim2.fromScale(0.5, 0.5)
	cajaFicha.Size = UDim2.fromOffset(520, 340)
	cajaFicha.BackgroundTransparency = 0
	local bordeFicha = Estilo.borde(cajaFicha, "Borde", 4)
	local fNombre = Estilo.texto(cajaFicha, "", T.Grande)
	fNombre.Position = UDim2.fromOffset(16, 14)
	fNombre.Size = UDim2.new(1, -32, 0, 40)
	local fRareza = Estilo.texto(cajaFicha, "", T.Chico, Estilo.Fuentes.Texto)
	fRareza.Position = UDim2.fromOffset(16, 56)
	fRareza.Size = UDim2.new(1, -32, 0, 26)
	local fTexto = Estilo.texto(cajaFicha, "", T.Normal, Estilo.Fuentes.Texto)
	fTexto.Position = UDim2.fromOffset(24, 88)
	fTexto.Size = UDim2.new(1, -48, 0, 84)
	ajustar(fTexto, T.Normal, T.Chico)
	local function botonFicha(valor: string, color: string, x: number, y: number): TextButton
		local b = Estilo.boton(cajaFicha, valor, color, T.Chico)
		b.Position = UDim2.new(x, if x == 0 then 16 else 4, 0, y)
		b.Size = UDim2.new(0.5, -20, 0, M.Boton)
		return b
	end
	local fIzquierda = botonFicha("◀ Mover", "Boton", 0, 184)
	local fDerecha = botonFicha("Mover ▶", "Boton", 0.5, 184)
	local fVender = botonFicha("", "Peligro", 0, 258)
	local fCerrar = botonFicha("Cerrar", "PanelClaro", 0.5, 258)
	local lugarFicha = 0
	fCerrar.Activated:Connect(function()
		abrir(ficha, false)
	end)
	fIzquierda.Activated:Connect(function()
		abrir(ficha, false)
		acciones.mover(lugarFicha, lugarFicha - 1)
	end)
	fDerecha.Activated:Connect(function()
		abrir(ficha, false)
		acciones.mover(lugarFicha, lugarFicha + 1)
	end)
	fVender.Activated:Connect(function()
		abrir(ficha, false)
		acciones.vender(lugarFicha)
	end)

	local ultimoEstado: Mazmorra.Estado? = nil
	local function abrirFicha(lugar: number)
		local e = ultimoEstado
		local r = if e then e.Reliquias[lugar] else nil
		if not e or not r then
			return
		end
		lugarFicha = lugar
		local rareza = Reliquias.rareza(r.Id)
		fNombre.Text = Reliquias.datos(r.Id).Nombre
		fRareza.Text = rareza.Nombre .. (" · lugar %d de %d"):format(lugar, #e.Reliquias)
		fRareza.TextColor3 = Color3.fromHex(rareza.Color)
		bordeFicha.Color = Color3.fromHex(rareza.Color)
		fTexto.Text = Reliquias.describir(r.Id, r.Contador)
		local enTienda = e.Fase == "tienda"
		fIzquierda.Visible = enTienda and lugar > 1
		fDerecha.Visible = enTienda and lugar < #e.Reliquias
		fVender.Visible = enTienda
		fVender.Text = ("Vender · +%d oro"):format(Reliquias.venta(r))
		abrir(ficha, true)
	end

	-- Lugares de reliquia.
	local lugaresReliquia: { TextButton } = {}
	local escalas: { UIScale } = {}
	local avisos: { TextLabel } = {}
	local bordes: { UIStroke } = {}
	for lugar = 1, Config.LugaresReliquia do
		local b = Estilo.boton(filaReliquias, "", "Sombra", T.Chico)
		b.Name = "Reliquia" .. lugar
		Estilo.marco(b, "Casillero")
		b.LayoutOrder = lugar
		b.Size = UDim2.fromOffset(92, altoFranja)
		b.Font = Estilo.Fuentes.Texto
		ajustar(b, T.Chico, 14)
		local borde = Estilo.borde(b, "Borde")
		local icono = Estilo.icono(b, nil)
		icono.AnchorPoint = Vector2.new(0.5, 0.5)
		icono.Position = UDim2.fromScale(0.5, 0.5)
		icono.Size = UDim2.new(1, -8, 1, -8)
		local escala = Instance.new("UIScale")
		escala.Parent = b
		-- Lo que sumó al final del tiro: salta arriba de la reliquia.
		local aviso = Estilo.texto(b, "", T.Normal)
		aviso.TextColor3 = Color3.fromHex(Config.Colores.Numero)
		aviso.AnchorPoint = Vector2.new(0.5, 1)
		aviso.Position = UDim2.new(0.5, 0, 0, -4)
		aviso.Size = UDim2.fromOffset(150, 34)
		aviso.TextTransparency = 1
		aviso.TextStrokeTransparency = 1
		b.Activated:Connect(function()
			abrirFicha(lugar)
		end)
		lugaresReliquia[lugar] = b
		escalas[lugar] = escala
		avisos[lugar] = aviso
		bordes[lugar] = borde
	end

	local function ponerReliquias(e: Mazmorra.Estado)
		ultimoEstado = e
		for lugar, b in lugaresReliquia do
			local r = e.Reliquias[lugar]
			if r then
				local d = Reliquias.datos(r.Id)
				local crece = r.Id == "trofeo" or r.Id == "callo" or r.Id == "racha"
				-- Con ícono: solo el contador (si crece); sin ícono, el nombre.
				local idIcono = (Config.Assets.Reliquias :: any)[r.Id] or ""
				local icono = b:FindFirstChild("Icono") :: ImageLabel
				icono.Image = idIcono
				icono.Visible = idIcono ~= ""
				b.TextYAlignment = if idIcono ~= ""
					then Enum.TextYAlignment.Bottom
					else Enum.TextYAlignment.Center
				b.Text = if idIcono ~= ""
					then (if crece then tostring(r.Contador) else "")
					elseif crece then ("%s (%d)"):format(d.Nombre, r.Contador)
					else d.Nombre
				b.TextColor3 = Estilo.color("Texto")
				b.BackgroundTransparency = Estilo.Transparencia.Panel
				bordes[lugar].Color = Color3.fromHex(Reliquias.rareza(r.Id).Color)
				bordes[lugar].Transparency = 0
			else
				local icono = b:FindFirstChild("Icono") :: ImageLabel
				icono.Visible = false
				b.TextYAlignment = Enum.TextYAlignment.Center
				b.Text = "Libre"
				b.TextColor3 = Estilo.color("Apagado")
				b.BackgroundTransparency = 0.5
				bordes[lugar].Transparency = 1
			end
		end
		if ficha.Visible then
			abrirFicha(lugarFicha)
		end
	end

	local avisosActivos: { [number]: number } = {}
	local function activar(lugar: number, valor: string)
		local escala, aviso = escalas[lugar], avisos[lugar]
		if not escala then
			return
		end
		escala.Scale = 1.3
		TweenService:Create(
			escala,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
		aviso.Text = valor
		aviso.TextTransparency = 0
		aviso.TextStrokeTransparency = 0
		local marca = (avisosActivos[lugar] or 0) + 1
		avisosActivos[lugar] = marca
		task.delay(1.2, function()
			if avisosActivos[lugar] == marca then
				aviso.TextTransparency = 1
				aviso.TextStrokeTransparency = 1
			end
		end)
	end

	-- Etapa 10: una copia del ícono vuela (girando y achicándose) hasta un lugar de la fila; al
	-- llegar, el lugar da un saltito. Va en una capa propia, arriba de todo.
	local capaVuelo = Instance.new("ScreenGui")
	capaVuelo.Name = "VueloReliquia"
	capaVuelo.ResetOnSpawn = false
	capaVuelo.IgnoreGuiInset = gui.IgnoreGuiInset
	capaVuelo.ScreenInsets = gui.ScreenInsets
	capaVuelo.DisplayOrder = 50
	capaVuelo.Parent = playerGui
	local function volar(origen: GuiObject, destino: GuiObject)
		local copia = Instance.new("ImageLabel")
		copia.BackgroundTransparency = 1
		copia.Image = if origen:IsA("ImageLabel") then origen.Image else ""
		copia.ScaleType = Enum.ScaleType.Fit
		copia.AnchorPoint = Vector2.new(0.5, 0.5)
		copia.Size = UDim2.fromOffset(origen.AbsoluteSize.X, origen.AbsoluteSize.Y)
		copia.Position = UDim2.fromOffset(
			origen.AbsolutePosition.X + origen.AbsoluteSize.X / 2,
			origen.AbsolutePosition.Y + origen.AbsoluteSize.Y / 2
		)
		copia.Parent = capaVuelo
		local llegada = destino.AbsolutePosition + destino.AbsoluteSize / 2
		local lado = math.min(destino.AbsoluteSize.X, destino.AbsoluteSize.Y)
		local vuelo = TweenService:Create(
			copia,
			TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Position = UDim2.fromOffset(llegada.X, llegada.Y),
				Size = UDim2.fromOffset(lado, lado),
				Rotation = 360,
			}
		)
		vuelo:Play()
		vuelo.Completed:Once(function()
			copia:Destroy()
			Sonidos.tocar("Comprar") -- SONIDO
			local escala = destino:FindFirstChildOfClass("UIScale")
			if escala then
				escala.Scale = 1.35
				TweenService:Create(
					escala,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
		end)
	end

	-- Cofre del jefe: la pantalla de mejoras, 3 cartas, un toque y listo.
	local cofre = ventana("PantallaCofre")
	local tituloCofre = Estilo.texto(cofre, "¡Cofre del jefe! Elegí una reliquia", T.Enorme)
	tituloCofre.AnchorPoint = Vector2.new(0.5, 0)
	tituloCofre.Position = UDim2.new(0.5, 0, 0, 20)
	tituloCofre.Size = UDim2.fromOffset(900, 64)
	tituloCofre.TextColor3 = Estilo.color("Oro")
	local mesa = Instance.new("Frame")
	mesa.AnchorPoint = Vector2.new(0.5, 0)
	mesa.Position = UDim2.new(0.5, 0, 0, 100)
	mesa.Size = UDim2.fromOffset(900, 280)
	mesa.BackgroundTransparency = 1
	mesa.Parent = cofre
	local ordenMesa = Estilo.lista(mesa, true, 24)
	ordenMesa.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local masTarde = Estilo.boton(cofre, "Más tarde", "Boton", T.Normal)
	masTarde.Name = "MasTarde"
	masTarde.AnchorPoint = Vector2.new(0.5, 0)
	masTarde.Position = UDim2.new(0.5, 0, 0, 398)
	masTarde.Size = UDim2.fromOffset(240, M.Boton)
	masTarde.Activated:Connect(function()
		abrir(cofre, false)
	end)
	-- Etapa 10: las cartas entran una por una con un "whoosh".
	local escalasCartas: { UIScale } = {}
	local function abrirCofre()
		abrir(cofre, true)
		for i, escala in escalasCartas do
			escala.Scale = 0
			task.delay((i - 1) * Config.Feel.CartasEntrada, function()
				Sonidos.tocar("Whoosh") -- SONIDO
				TweenService:Create(
					escala,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end)
		end
	end
	botonCofre.Activated:Connect(abrirCofre)

	local function ponerCofre(e: Mazmorra.Estado)
		table.clear(escalasCartas)
		for _, hijo in mesa:GetChildren() do
			if hijo:IsA("GuiButton") then
				hijo:Destroy()
			end
		end
		for indice, id in e.Tienda.Cofre do
			local nombre, frase, hex = TiendaModulo.describir("reliquia", id, e)
			local carta = Estilo.boton(mesa, "", "Carta")
			carta.Name = "Carta" .. indice
			carta.LayoutOrder = indice
			carta.Size = UDim2.fromOffset(270, 280)
			local borde = Estilo.borde(carta, hex, 5)
			local escala = Instance.new("UIScale")
			escala.Parent = carta
			table.insert(escalasCartas, escala)
			-- La que tenés debajo del mouse (o del dedo) brilla más y se agranda.
			carta.MouseEnter:Connect(function()
				escala.Scale = 1.05
				borde.Thickness = 8
			end)
			carta.MouseLeave:Connect(function()
				escala.Scale = 1
				borde.Thickness = 5
			end)
			local icono = Estilo.icono(carta, (Config.Assets.Reliquias :: any)[id])
			icono.AnchorPoint = Vector2.new(0.5, 0)
			icono.Position = UDim2.new(0.5, 0, 0, 10)
			icono.Size = UDim2.fromOffset(96, 96)
			local tNombre = Estilo.texto(carta, nombre, T.Grande)
			tNombre.Position = UDim2.fromOffset(12, 108)
			tNombre.Size = UDim2.new(1, -24, 0, 44)
			ajustar(tNombre, T.Grande, T.Chico)
			local tRareza =
				Estilo.texto(carta, Reliquias.rareza(id).Nombre, T.Chico, Estilo.Fuentes.Texto)
			tRareza.TextColor3 = Color3.fromHex(hex)
			tRareza.Position = UDim2.fromOffset(12, 152)
			tRareza.Size = UDim2.new(1, -24, 0, 26)
			local tFrase = Estilo.texto(carta, frase, T.Normal, Estilo.Fuentes.Texto)
			tFrase.TextStrokeTransparency = 1
			tFrase.Position = UDim2.fromOffset(16, 182)
			tFrase.Size = UDim2.new(1, -32, 1, -190)
			tFrase.TextYAlignment = Enum.TextYAlignment.Top
			ajustar(tFrase, T.Chico, 16)
			carta.Activated:Connect(function()
				-- La elegida se agranda y brilla un instante antes de cerrar (etapa 10).
				if borde.Thickness >= 10 then
					return -- ya se eligió (doble toque)
				end
				borde.Thickness = 10
				TweenService:Create(
					escala,
					TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1.2 }
				):Play()
				-- Etapa 10: el ícono vuela de la carta a su lugar en la fila de reliquias.
				local destino = lugaresReliquia[#lugaresReliquia]
				for _, lugarLibre in lugaresReliquia do
					if lugarLibre.Text == "Libre" then
						destino = lugarLibre
						break
					end
				end
				volar(icono, destino)
				task.delay(0.22, function()
					abrir(cofre, false)
					acciones.tomarCofre(indice)
				end)
			end)
		end
	end

	-- Una cosa en venta (etapa 10b): carta alta con el precio arriba, el dibujo (ícono de la
	-- reliquia o un bloque del color de la cosa), el nombre y lo que hace. Crece al pasar el mouse.
	local function itemTienda(e: Mazmorra.Estado, indice: number, item: Mazmorra.ItemTienda)
		local nombre, frase, hex = TiendaModulo.describir(item.Clase, item.Id, e)
		local b = Estilo.boton(lista, "", "Carta")
		b.Name = "Item" .. indice
		b.LayoutOrder = indice
		b.Size = UDim2.new(0, 172, 1, -28)
		b.AutoButtonColor = false
		local borde = Estilo.borde(b, hex, 3)
		local escala = Instance.new("UIScale")
		escala.Parent = b
		table.insert(cartasTienda, b)
		-- Una reliquia que ya tenés (por ejemplo, la sacaste del cofre) no se puede comprar.
		local laTenes = item.Clase == "reliquia" and Reliquias.tiene(e.Reliquias, item.Id)
		local apagado = item.Vendido or laTenes
		-- Precio arriba, en una etiqueta dorada.
		local etiquetaPrecio = Instance.new("Frame")
		etiquetaPrecio.AnchorPoint = Vector2.new(0.5, 0.5)
		etiquetaPrecio.Position = UDim2.fromScale(0.5, 0)
		etiquetaPrecio.Size = UDim2.fromOffset(110, 32)
		etiquetaPrecio.BackgroundColor3 = Estilo.color("Sombra")
		etiquetaPrecio.BorderSizePixel = 0
		etiquetaPrecio.ZIndex = 3
		etiquetaPrecio.Parent = b
		Estilo.redondear(etiquetaPrecio)
		Estilo.borde(etiquetaPrecio, "Oro", 2)
		local tPrecio = Estilo.texto(
			etiquetaPrecio,
			if item.Vendido
				then "Vendido"
				elseif laTenes then "La tenés"
				else ("%d oro"):format(item.Precio),
			T.Chico
		)
		tPrecio.Size = UDim2.fromScale(1, 1)
		tPrecio.ZIndex = 3
		tPrecio.TextColor3 = if apagado
			then Estilo.color("Apagado")
			elseif e.Oro >= item.Precio then Estilo.color("Oro")
			else Estilo.color("Peligro")
		-- Dibujo.
		local idIcono = if item.Clase == "reliquia"
			then (Config.Assets.Reliquias :: any)[item.Id]
			else nil
		if idIcono and idIcono ~= "" then
			local icono = Estilo.icono(b, idIcono)
			icono.AnchorPoint = Vector2.new(0.5, 0)
			icono.Position = UDim2.new(0.5, 0, 0, 22)
			icono.Size = UDim2.fromOffset(66, 66)
		else
			local bloque = Instance.new("Frame")
			bloque.AnchorPoint = Vector2.new(0.5, 0)
			bloque.Position = UDim2.new(0.5, 0, 0, 26)
			bloque.Size = UDim2.fromOffset(56, 56)
			bloque.BackgroundColor3 = Color3.fromHex(hex)
			bloque.BorderSizePixel = 0
			bloque.Parent = b
			local redondo = Instance.new("UICorner")
			redondo.CornerRadius = UDim.new(0.5, 0)
			redondo.Parent = bloque
			Estilo.borde(bloque, "Sombra", 3)
		end
		local tNombre = Estilo.texto(b, nombre, T.Normal)
		tNombre.Position = UDim2.fromOffset(8, 92)
		tNombre.Size = UDim2.new(1, -16, 0, 30)
		ajustar(tNombre, T.Normal, 14)
		local tFrase = Estilo.texto(b, frase, T.Chico, Estilo.Fuentes.Texto)
		tFrase.TextYAlignment = Enum.TextYAlignment.Top
		tFrase.TextColor3 = Estilo.color("Apagado")
		tFrase.Position = UDim2.fromOffset(10, 124)
		tFrase.Size = UDim2.new(1, -20, 1, -130)
		ajustar(tFrase, T.Chico, 12)
		if apagado then
			b.BackgroundTransparency = 0.6
			borde.Transparency = 0.6
		else
			b.MouseEnter:Connect(function()
				TweenService
					:Create(escala, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.07 })
					:Play()
			end)
			b.MouseLeave:Connect(function()
				TweenService:Create(escala, TweenInfo.new(0.12), { Scale = 1 }):Play()
			end)
			b.Activated:Connect(function()
				acciones.comprar(indice)
			end)
		end
	end

	local apartada = false -- la tienda se corrió para tocar clavijas

	local function ponerPergaminos(e: Mazmorra.Estado)
		for lugar, b in botonesLugar do
			local id = e.Pergaminos[lugar]
			if id then
				local nombre, _, hex = TiendaModulo.describir("pergamino", id, e)
				b.Text = nombre
				b.BackgroundColor3 = Color3.fromHex(hex)
				b.BackgroundTransparency = 0.15
				-- Fondo claro: texto oscuro; fondo oscuro: texto blanco con borde.
				local c = Color3.fromHex(hex)
				local claro = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B > 0.6
				b.TextColor3 = if claro
					then Estilo.color("TextoPrincipal")
					else Estilo.color("Texto")
				b.TextStrokeTransparency = if claro then 1 else 0
			else
				b.Text = "Pergamino"
				b.TextColor3 = Estilo.color("Apagado")
				b.BackgroundColor3 = Estilo.color("Panel")
				b.BackgroundTransparency = 0.5
			end
		end
	end

	return {
		mostrar = function(e: Mazmorra.Estado)
			for _, hijo in lista:GetChildren() do
				if hijo:IsA("GuiButton") then
					hijo:Destroy()
				end
			end
			table.clear(cartasTienda)
			for indice, item in e.Tienda.Items do
				itemTienda(e, indice, item)
			end
			if not panel.Visible then
				lista.CanvasPosition = Vector2.zero -- tienda nueva: desde la primera carta
			end
			local o = e.UltimoOro
			local partes = { ("+%d por ganar"):format(o.Pelea) }
			if o.Bonus > 0 then
				table.insert(partes, ("+%d rápido"):format(o.Bonus))
			end
			if o.Interes > 0 then
				table.insert(partes, ("+%d interés"):format(o.Interes))
			end
			ganado.Text = ("%d oro (%s)"):format(e.Oro, table.concat(partes, ", "))
			local precio = TiendaModulo.precioRenovar(e)
			renovar.Text = ("Renovar · %d"):format(precio)
			renovar.TextColor3 = if e.Oro >= precio
				then Estilo.color("Texto")
				else Estilo.color("Peligro")
			-- Próxima pelea (y la maña, si es un jefe), para decidir qué comprar.
			local m = Mazmorra.monstruo(e.Piso)
			local maniaProxima = if m.EsJefe then e.ManiasJefes[m.Zona] else nil
			proximo.Text = ("Próximo: %s (%s de vida)%s"):format(
				m.Nombre,
				Clavijas.numeroCorto(m.Vida),
				if maniaProxima then " · " .. Mazmorra.textoMania(maniaProxima, m.Zona) else ""
			)
			proximo.TextColor3 = if m.EsJefe
				then Estilo.color("Peligro")
				else Estilo.color("Apagado")
			-- Cofre: se abre solo la primera vez que entrás con un cofre nuevo.
			local hayCofre = #e.Tienda.Cofre > 0 and not e.Tienda.CofreTomado
			local cofreNuevo = hayCofre and not panel.Visible
			botonCofre.Visible = hayCofre
			if hayCofre then
				ponerCofre(e)
				if cofreNuevo then
					abrirCofre()
				end
			else
				abrir(cofre, false)
			end
			panel.Visible = not apartada
			ponerPergaminos(e)
		end,
		ocultar = function()
			abrir(cofre, false)
			abrir(chances, false)
			panel.Visible = false
			apartada = false
		end,
		apartar = function(si: boolean)
			if si and panel.Visible then
				apartada = true
				panel.Visible = false
			elseif not si and apartada then
				apartada = false
				panel.Visible = true
			end
		end,
		ponerPergaminos = ponerPergaminos,
		ponerReliquias = ponerReliquias,
		activar = activar,
		abierta = function(): boolean
			return guiVentanas.Enabled
		end,
		mostrarHud = function(si: boolean)
			gui.Enabled = si
			if si then
				actualizarVentanas()
			else
				guiVentanas.Enabled = false
			end
		end,
	}
end

return TiendaVista
