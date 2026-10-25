--!strict
-- Pantallas en graybox: la barra de arriba (vida del caballero, oro y piso), el cartel
-- "¡Piso N!", las pantallas de perder y de ganar la mazmorra con un botón grande y la fila de
-- abajo con tu bola y tus clavijas especiales (paso 5a). La tienda está en TiendaVista.
-- Etapa 6: la pantalla de inicio (antes de cada partida): tu mejor zona y elegir la bola entre las
-- desbloqueadas; las bloqueadas dicen cómo se consiguen.
-- Las pantallas lindas llegan en la etapa 7.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Progreso = require(Shared:WaitForChild("Progreso"))

export type Pantallas = {
	ponerEstado: (estado: Mazmorra.Estado) -> (),
	ponerVida: (vida: number, maxima: number) -> (),
	anunciar: (texto: string) -> (),
	mostrarFinal: (titulo: string, boton: string, alTocar: () -> ()) -> (),
	ocultarFinal: () -> (),
	ponerTablero: (estado: Mazmorra.Estado) -> (), -- la fila de abajo y el oro
	-- Inicio: elegir bola. alElegir recibe el Id de la bola.
	mostrarInicio: (progreso: Progreso.Datos, alElegir: (string) -> ()) -> (),
	ocultarInicio: () -> (),
	hayFinal: () -> boolean, -- final o inicio abiertos: mientras tanto no se tira
	finalCerrado: () -> number, -- os.clock() de la última vez que se cerró la pantalla final
}

local Pantallas = {}

local function texto(padre: Instance, valor: string): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Text = valor
	t.Parent = padre
	return t
end

function Pantallas.crear(): Pantallas
	local gui = Instance.new("ScreenGui")
	gui.Name = "Pantallas"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Barra de arriba: vida a la izquierda, piso al centro.
	local vidaCaja = Instance.new("Frame")
	vidaCaja.Position = UDim2.fromOffset(12, 8)
	vidaCaja.Size = UDim2.new(0.22, 0, 0, 40)
	vidaCaja.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	vidaCaja.BorderSizePixel = 0
	vidaCaja.Parent = gui
	local vidaRelleno = Instance.new("Frame")
	vidaRelleno.Size = UDim2.fromScale(1, 1)
	vidaRelleno.BackgroundColor3 = Color3.fromHex(Config.Colores.VidaCaballero)
	vidaRelleno.BorderSizePixel = 0
	vidaRelleno.Parent = vidaCaja
	local vidaTexto = texto(vidaCaja, "")
	vidaTexto.Size = UDim2.fromScale(1, 1)
	vidaTexto.ZIndex = 2

	local oro = texto(gui, "")
	oro.Name = "Oro"
	oro.Position = UDim2.fromOffset(12, 52)
	oro.Size = UDim2.new(0.22, 0, 0, 30)
	oro.TextXAlignment = Enum.TextXAlignment.Left
	oro.TextColor3 = Color3.fromHex(Config.Colores.Oro)

	local piso = texto(gui, "")
	piso.AnchorPoint = Vector2.new(0.5, 0)
	piso.Position = UDim2.new(0.5, 0, 0, 8)
	piso.Size = UDim2.new(0.26, 0, 0, 40)

	-- Cartel de la maña del jefe (paso 5d): debajo del piso, en rojo.
	local mania = texto(gui, "")
	mania.Name = "Mania"
	mania.AnchorPoint = Vector2.new(0.5, 0)
	mania.Position = UDim2.new(0.5, 0, 0, 50)
	mania.Size = UDim2.new(0.3, 0, 0, 30)
	mania.BackgroundTransparency = 0.15
	mania.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	mania.Font = Enum.Font.GothamBold
	mania.TextColor3 = Color3.fromHex(Config.Colores.Golpe)
	mania.Visible = false

	-- Cartel grande en el medio ("¡Piso 2!", "¡Nueva bola: Fuego!"). En su propia capa, arriba de
	-- todo: si no, el cofre (que se abre al mismo tiempo) tapaba los avisos de desbloqueo.
	local guiAvisos = Instance.new("ScreenGui")
	guiAvisos.Name = "Avisos"
	guiAvisos.ResetOnSpawn = false
	guiAvisos.DisplayOrder = 30
	guiAvisos.Parent = gui.Parent
	local anuncio = texto(guiAvisos, "")
	anuncio.AnchorPoint = Vector2.new(0.5, 0.5)
	anuncio.Position = UDim2.fromScale(0.5, 0.45)
	anuncio.Size = UDim2.fromScale(0.6, 0.18)
	anuncio.TextColor3 = Color3.fromHex(Config.Colores.Numero)
	anuncio.TextTransparency = 1
	anuncio.TextStrokeTransparency = 1

	-- Pantalla de final (perder o ganar): fondo oscuro, título y botón grande. Va en su propio
	-- ScreenGui, sin márgenes, para tapar la pantalla entera (también la franja de arriba).
	local guiFinal = Instance.new("ScreenGui")
	guiFinal.Name = "PantallaFinal"
	guiFinal.ResetOnSpawn = false
	guiFinal.IgnoreGuiInset = true
	guiFinal.ScreenInsets = Enum.ScreenInsets.None
	guiFinal.DisplayOrder = 10
	guiFinal.Parent = gui.Parent
	local final = Instance.new("Frame")
	final.Name = "Final"
	final.Size = UDim2.fromScale(1, 1)
	final.BackgroundColor3 = Color3.new(0, 0, 0)
	final.BackgroundTransparency = 0.35
	final.Visible = false
	final.ZIndex = 10
	final.Parent = guiFinal
	local titulo = texto(final, "")
	titulo.AnchorPoint = Vector2.new(0.5, 0.5)
	titulo.Position = UDim2.fromScale(0.5, 0.35)
	titulo.Size = UDim2.fromScale(0.8, 0.16)
	titulo.ZIndex = 11
	local boton = Instance.new("TextButton")
	boton.AnchorPoint = Vector2.new(0.5, 0.5)
	boton.Position = UDim2.fromScale(0.5, 0.62)
	boton.Size = UDim2.fromScale(0.4, 0.16)
	boton.BackgroundColor3 = Color3.fromHex(Config.Colores.VidaCaballero)
	boton.BorderSizePixel = 0
	boton.Font = Enum.Font.GothamBlack
	boton.TextScaled = true
	boton.TextColor3 = Color3.new(1, 1, 1)
	boton.TextStrokeTransparency = 0
	boton.ZIndex = 11
	boton.Name = "Boton"
	boton.Parent = final
	local minimo = Instance.new("UISizeConstraint") -- botón de 44 px o más en cualquier pantalla
	minimo.MinSize = Vector2.new(200, 60)
	minimo.Parent = boton
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0.2, 0)
	esquinas.Parent = boton

	-- Fila de abajo: tu bola y cuántas clavijas especiales tenés de cada tipo (con su nivel).
	local fila = Instance.new("Frame")
	fila.Name = "FilaTablero"
	fila.AnchorPoint = Vector2.new(0.5, 1)
	fila.Position = UDim2.new(0.5, 0, 1, -8)
	fila.Size = UDim2.new(0.8, 0, 0, 36)
	fila.BackgroundTransparency = 1
	fila.Parent = gui
	local filaOrden = Instance.new("UIListLayout")
	filaOrden.FillDirection = Enum.FillDirection.Horizontal
	filaOrden.HorizontalAlignment = Enum.HorizontalAlignment.Center
	filaOrden.Padding = UDim.new(0, 8)
	filaOrden.SortOrder = Enum.SortOrder.LayoutOrder
	filaOrden.Parent = fila

	local function etiquetaFila(valor: string, hex: string?, orden: number)
		local caja = Instance.new("Frame")
		caja.LayoutOrder = orden
		caja.Size = UDim2.new(0, 120, 1, 0)
		caja.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
		caja.BackgroundTransparency = 0.2
		caja.BorderSizePixel = 0
		caja.Parent = fila
		local redondeo = Instance.new("UICorner")
		redondeo.CornerRadius = UDim.new(0.25, 0)
		redondeo.Parent = caja
		local t = texto(caja, valor)
		t.Size = UDim2.fromScale(0.9, 0.8)
		t.Position = UDim2.fromScale(0.05, 0.1)
		if hex then
			t.TextColor3 = Color3.fromHex(hex)
		end
	end

	local function ponerTablero(e: Mazmorra.Estado)
		oro.Text = ("Oro %d"):format(e.Oro)
		for _, hijo in fila:GetChildren() do
			if hijo:IsA("GuiObject") then
				hijo:Destroy()
			end
		end
		local bola = (Config.Bolas :: any)[e.Bola]
		etiquetaFila(
			"Bola " .. (if bola then bola.Nombre else e.Bola),
			if e.Bola == "fuego" then Config.Colores.BolaFuego else nil,
			0
		)
		local cuenta = Clavijas.contar(e.Tablero)
		for orden, tipo in Config.OrdenClavijas do
			local n = cuenta[tipo] or 0
			if n > 0 then
				local nivel = Clavijas.nivel(e.Niveles, tipo)
				local nombre = (Config.Clavijas :: any)[tipo].Nombre
				etiquetaFila(
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
			etiquetaFila(("%d rotas"):format(huecos), nil, 99)
		end
	end

	-- Pantalla de inicio (etapa 6): en el mismo ScreenGui que la final, tapando todo.
	local inicio = Instance.new("Frame")
	inicio.Name = "Inicio"
	inicio.Size = UDim2.fromScale(1, 1)
	inicio.BackgroundColor3 = Color3.new(0, 0, 0)
	inicio.BackgroundTransparency = 0.25
	inicio.Visible = false
	inicio.ZIndex = 10
	inicio.Parent = guiFinal
	local tituloInicio = texto(inicio, "Plinko Knight")
	tituloInicio.AnchorPoint = Vector2.new(0.5, 0)
	tituloInicio.Position = UDim2.fromScale(0.5, 0.08)
	tituloInicio.Size = UDim2.fromScale(0.6, 0.14)
	tituloInicio.ZIndex = 11
	local mejor = texto(inicio, "")
	mejor.AnchorPoint = Vector2.new(0.5, 0)
	mejor.Position = UDim2.fromScale(0.5, 0.23)
	mejor.Size = UDim2.fromScale(0.6, 0.06)
	mejor.Font = Enum.Font.GothamBold
	mejor.TextColor3 = Color3.fromHex(Config.Colores.Oro)
	mejor.ZIndex = 11
	local elegi = texto(inicio, "Elegí con qué bola bajás")
	elegi.AnchorPoint = Vector2.new(0.5, 0)
	elegi.Position = UDim2.fromScale(0.5, 0.31)
	elegi.Size = UDim2.fromScale(0.5, 0.07)
	elegi.ZIndex = 11
	local mesaBolas = Instance.new("Frame")
	mesaBolas.AnchorPoint = Vector2.new(0.5, 0)
	mesaBolas.Position = UDim2.fromScale(0.5, 0.42)
	mesaBolas.Size = UDim2.fromScale(0.8, 0.45)
	mesaBolas.BackgroundTransparency = 1
	mesaBolas.ZIndex = 11
	mesaBolas.Parent = inicio
	local ordenBolas = Instance.new("UIListLayout")
	ordenBolas.FillDirection = Enum.FillDirection.Horizontal
	ordenBolas.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ordenBolas.Padding = UDim.new(0.03, 0)
	ordenBolas.SortOrder = Enum.SortOrder.LayoutOrder
	ordenBolas.Parent = mesaBolas
	local alElegirBola: ((string) -> ())? = nil

	local function mostrarInicio(progreso: Progreso.Datos, alElegir: (string) -> ())
		for _, hijo in mesaBolas:GetChildren() do
			if hijo:IsA("GuiButton") then
				hijo:Destroy()
			end
		end
		mejor.Text = if progreso.MejorPiso > 0
			then ("Tu mejor: pelea %d de %d · jefes vencidos: %d · partidas ganadas: %d"):format(
				progreso.MejorPiso,
				#Config.Monstruos,
				progreso.JefesVencidos,
				progreso.PartidasGanadas
			)
			else "Bajá a la mazmorra y llegá lo más lejos que puedas"
		for orden, id in Config.OrdenBolas do
			local d = (Config.Bolas :: any)[id]
			local tiene = Progreso.tieneBola(progreso, id)
			local carta = Instance.new("TextButton")
			carta.Name = "Bola" .. id
			carta.LayoutOrder = orden
			carta.Size = UDim2.fromScale(0.3, 1)
			carta.BackgroundColor3 = Color3.fromHex(Config.Colores.Carta)
			carta.BackgroundTransparency = if tiene then 0 else 0.5
			carta.BorderSizePixel = 0
			carta.AutoButtonColor = tiene
			carta.Text = ""
			carta.ZIndex = 11
			carta.Parent = mesaBolas
			local redondeo = Instance.new("UICorner")
			redondeo.CornerRadius = UDim.new(0.06, 0)
			redondeo.Parent = carta
			local borde = Instance.new("UIStroke")
			borde.Thickness = if id == progreso.BolaElegida then 5 else 2
			borde.Color = if id == progreso.BolaElegida
				then Color3.fromHex(Config.Colores.Oro)
				else Color3.fromRGB(120, 120, 120)
			borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			borde.Parent = carta
			local muestra = Instance.new("Frame")
			muestra.AnchorPoint = Vector2.new(0.5, 0)
			muestra.Position = UDim2.fromScale(0.5, 0.08)
			muestra.Size = UDim2.fromScale(0.25, 0.25)
			muestra.SizeConstraint = Enum.SizeConstraint.RelativeXX
			muestra.BackgroundColor3 = Color3.fromHex(
				if id == "fuego" then Config.Colores.BolaFuego else Config.Colores.Bola
			)
			muestra.BackgroundTransparency = if tiene then 0 else 0.6
			muestra.BorderSizePixel = 0
			muestra.ZIndex = 12
			muestra.Parent = carta
			local circulo = Instance.new("UICorner")
			circulo.CornerRadius = UDim.new(0.5, 0)
			circulo.Parent = muestra
			local nombre = texto(carta, d.Nombre)
			nombre.Position = UDim2.fromScale(0.06, 0.42)
			nombre.Size = UDim2.fromScale(0.88, 0.18)
			nombre.ZIndex = 12
			local detalle = texto(carta, if tiene then d.Descripcion else "Bloqueada: " .. d.Logro)
			detalle.Font = Enum.Font.GothamBold
			detalle.TextWrapped = true
			detalle.TextStrokeTransparency = 1
			detalle.TextColor3 = if tiene
				then Color3.new(1, 1, 1)
				else Color3.fromRGB(170, 170, 170)
			detalle.Position = UDim2.fromScale(0.08, 0.64)
			detalle.Size = UDim2.fromScale(0.84, 0.3)
			detalle.ZIndex = 12
			local limite = Instance.new("UITextSizeConstraint")
			limite.MaxTextSize = 26
			limite.Parent = detalle
			if tiene then
				carta.Activated:Connect(function()
					local accion = alElegirBola
					if accion then
						alElegirBola = nil -- un solo toque
						accion(id)
					end
				end)
			end
		end
		alElegirBola = alElegir
		final.Visible = false
		inicio.Visible = true
	end

	local alTocarBoton: (() -> ())? = nil
	boton.Activated:Connect(function()
		local accion = alTocarBoton
		if accion then
			alTocarBoton = nil
			accion()
		end
	end)

	local function ponerVida(vida: number, maxima: number)
		vidaTexto.Text = ("Vida %d/%d"):format(vida, maxima)
		vidaRelleno.Size = UDim2.fromScale(math.clamp(vida / math.max(maxima, 1), 0, 1), 1)
	end

	local cerrado = -math.huge
	local anuncios = 0
	return {
		ponerEstado = function(e: Mazmorra.Estado)
			ponerVida(e.Vida, e.VidaMaxima)
			local m = Mazmorra.monstruo(e.Piso)
			local porZona = #Config.Monstruos / #Config.Zonas
			local enZona = (e.Piso - 1) % porZona + 1
			local zona = ("Zona %d · %s"):format(m.Zona, Config.Zonas[m.Zona] or "")
			piso.Text = if m.EsJefe
				then ("Jefe · %s"):format(zona)
				else ("%s · Pelea %d de %d"):format(zona, enZona, porZona)
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
		mostrarFinal = function(valorTitulo: string, valorBoton: string, alTocar: () -> ())
			titulo.Text = valorTitulo
			boton.Text = valorBoton
			alTocarBoton = alTocar
			final.Visible = true
		end,
		ocultarFinal = function()
			alTocarBoton = nil
			if final.Visible then
				cerrado = os.clock()
			end
			final.Visible = false
		end,
		ponerTablero = ponerTablero,
		mostrarInicio = mostrarInicio,
		ocultarInicio = function()
			alElegirBola = nil
			if inicio.Visible then
				cerrado = os.clock()
			end
			inicio.Visible = false
		end,
		hayFinal = function(): boolean
			return final.Visible or inicio.Visible
		end,
		finalCerrado = function(): number
			return cerrado
		end,
	}
end

return Pantallas
