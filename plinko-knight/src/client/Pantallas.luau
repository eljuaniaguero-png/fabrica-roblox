--!strict
-- Pantallas de las etapas 4 y 5, en graybox: la barra de arriba (vida del caballero y piso), el
-- cartel "¡Piso N!", las pantallas de perder y de ganar la mazmorra con un botón grande, las 3
-- cartas de mejora al ganar una pelea y la fila de abajo con las mejoras que tenés.
-- Las pantallas lindas llegan en la etapa 7.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Mejoras = require(Shared:WaitForChild("Mejoras"))

export type Pantallas = {
	ponerEstado: (estado: Mazmorra.Estado) -> (),
	ponerVida: (vida: number, maxima: number) -> (),
	anunciar: (texto: string) -> (),
	mostrarFinal: (titulo: string, boton: string, alTocar: () -> ()) -> (),
	ocultarFinal: () -> (),
	-- Cartas de mejora: alElegir recibe el id de la carta tocada.
	mostrarMejoras: (
		ofrecidas: { string },
		niveles: Mejoras.Niveles,
		alElegir: (string) -> ()
	) -> (),
	ocultarMejoras: () -> (),
	ponerMejoras: (niveles: Mejoras.Niveles) -> (), -- la fila de abajo
	hayFinal: () -> boolean, -- también con las cartas abiertas: mientras tanto no se tira
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

	local piso = texto(gui, "")
	piso.AnchorPoint = Vector2.new(0.5, 0)
	piso.Position = UDim2.new(0.5, 0, 0, 8)
	piso.Size = UDim2.new(0.3, 0, 0, 40)

	-- Cartel grande en el medio ("¡Piso 2!").
	local anuncio = texto(gui, "")
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

	-- Fila de abajo: las mejoras que tenés, con su nivel.
	local fila = Instance.new("Frame")
	fila.Name = "FilaMejoras"
	fila.AnchorPoint = Vector2.new(0.5, 1)
	fila.Position = UDim2.new(0.5, 0, 1, -8)
	fila.Size = UDim2.new(0.6, 0, 0, 36)
	fila.BackgroundTransparency = 1
	fila.Parent = gui
	local filaOrden = Instance.new("UIListLayout")
	filaOrden.FillDirection = Enum.FillDirection.Horizontal
	filaOrden.HorizontalAlignment = Enum.HorizontalAlignment.Center
	filaOrden.Padding = UDim.new(0, 8)
	filaOrden.SortOrder = Enum.SortOrder.LayoutOrder
	filaOrden.Parent = fila

	local function ponerMejoras(niveles: Mejoras.Niveles)
		for _, hijo in fila:GetChildren() do
			if hijo:IsA("GuiObject") then
				hijo:Destroy()
			end
		end
		for orden, id in Config.OrdenMejoras do
			local nivel = Mejoras.nivel(niveles, id)
			if nivel > 0 then
				local caja = Instance.new("Frame")
				caja.LayoutOrder = orden
				caja.Size = UDim2.new(0, 130, 1, 0)
				caja.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
				caja.BackgroundTransparency = 0.2
				caja.BorderSizePixel = 0
				caja.Parent = fila
				local redondeo = Instance.new("UICorner")
				redondeo.CornerRadius = UDim.new(0.25, 0)
				redondeo.Parent = caja
				local t = texto(caja, ("%s · Nv %d"):format(Mejoras.nombreCorto(id), nivel))
				t.Size = UDim2.fromScale(0.9, 0.8)
				t.Position = UDim2.fromScale(0.05, 0.1)
				if id == "Fuego" then
					t.TextColor3 = Color3.fromHex(Config.Colores.BolaFuego)
				elseif id == "Duplica" then
					t.TextColor3 = Color3.fromHex(Config.Colores.Duplica)
				end
			end
		end
	end

	-- Cartas de mejora: en su propio ScreenGui, tapando la pelea (como la pantalla final).
	local guiCartas = Instance.new("ScreenGui")
	guiCartas.Name = "PantallaMejoras"
	guiCartas.ResetOnSpawn = false
	guiCartas.IgnoreGuiInset = true
	guiCartas.ScreenInsets = Enum.ScreenInsets.None
	guiCartas.DisplayOrder = 9
	guiCartas.Parent = gui.Parent
	local cartas = Instance.new("Frame")
	cartas.Name = "Cartas"
	cartas.Size = UDim2.fromScale(1, 1)
	cartas.BackgroundColor3 = Color3.new(0, 0, 0)
	cartas.BackgroundTransparency = 0.35
	cartas.Visible = false
	cartas.Parent = guiCartas
	local tituloCartas = texto(cartas, "¡Ganaste! Elegí una mejora")
	tituloCartas.AnchorPoint = Vector2.new(0.5, 0)
	tituloCartas.Position = UDim2.fromScale(0.5, 0.06)
	tituloCartas.Size = UDim2.fromScale(0.7, 0.11)
	local mesa = Instance.new("Frame")
	mesa.AnchorPoint = Vector2.new(0.5, 0)
	mesa.Position = UDim2.fromScale(0.5, 0.22)
	mesa.Size = UDim2.fromScale(0.86, 0.68)
	mesa.BackgroundTransparency = 1
	mesa.Parent = cartas
	local mesaOrden = Instance.new("UIListLayout")
	mesaOrden.FillDirection = Enum.FillDirection.Horizontal
	mesaOrden.HorizontalAlignment = Enum.HorizontalAlignment.Center
	mesaOrden.VerticalAlignment = Enum.VerticalAlignment.Center
	mesaOrden.Padding = UDim.new(0.025, 0)
	mesaOrden.SortOrder = Enum.SortOrder.LayoutOrder
	mesaOrden.Parent = mesa

	local alElegirCarta: ((string) -> ())? = nil

	local function carta(id: string, nivelNuevo: number, orden: number)
		local nombre, frase = Mejoras.describir(id, nivelNuevo)
		local tarjeta = Instance.new("TextButton")
		tarjeta.Name = "Carta" .. id
		tarjeta.LayoutOrder = orden
		tarjeta.Size = UDim2.fromScale(0.3, 1)
		tarjeta.BackgroundColor3 = Color3.fromHex(Config.Colores.Carta)
		tarjeta.BorderSizePixel = 0
		tarjeta.AutoButtonColor = true
		tarjeta.Text = ""
		tarjeta.Parent = mesa
		local redondeo = Instance.new("UICorner")
		redondeo.CornerRadius = UDim.new(0.06, 0)
		redondeo.Parent = tarjeta
		local borde = Instance.new("UIStroke")
		borde.Thickness = 3
		borde.Color = Color3.new(1, 1, 1)
		borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		borde.Parent = tarjeta
		local tNombre = texto(tarjeta, nombre)
		tNombre.Position = UDim2.fromScale(0.07, 0.08)
		tNombre.Size = UDim2.fromScale(0.86, 0.2)
		local tFrase = texto(tarjeta, frase)
		tFrase.Font = Enum.Font.GothamBold
		tFrase.TextWrapped = true
		tFrase.TextStrokeTransparency = 1
		tFrase.Position = UDim2.fromScale(0.08, 0.34)
		tFrase.Size = UDim2.fromScale(0.84, 0.38)
		local limite = Instance.new("UITextSizeConstraint")
		limite.MaxTextSize = 28
		limite.Parent = tFrase
		local tNivel =
			texto(tarjeta, if nivelNuevo > 1 then ("Nivel %d"):format(nivelNuevo) else "Nueva")
		tNivel.Position = UDim2.fromScale(0.2, 0.8)
		tNivel.Size = UDim2.fromScale(0.6, 0.12)
		tNivel.TextColor3 = Color3.fromHex(Config.Colores.Numero)
		tarjeta.Activated:Connect(function()
			local accion = alElegirCarta
			if accion then
				alElegirCarta = nil -- un solo toque: el servidor contesta y se cierran
				accion(id)
			end
		end)
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
			local total = #Config.Monstruos
			piso.Text = if e.Piso >= total
				then ("Jefe · Pelea %d de %d"):format(e.Piso, total)
				else ("Pelea %d de %d"):format(e.Piso, total)
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
		mostrarMejoras = function(
			ofrecidas: { string },
			niveles: Mejoras.Niveles,
			alElegir: (string) -> ()
		)
			for _, hijo in mesa:GetChildren() do
				if hijo:IsA("GuiButton") then
					hijo:Destroy()
				end
			end
			for orden, id in ofrecidas do
				carta(id, Mejoras.nivel(niveles, id) + 1, orden)
			end
			alElegirCarta = alElegir
			cartas.Visible = true
		end,
		ocultarMejoras = function()
			alElegirCarta = nil
			if cartas.Visible then
				cerrado = os.clock()
			end
			cartas.Visible = false
		end,
		ponerMejoras = ponerMejoras,
		hayFinal = function(): boolean
			return final.Visible or cartas.Visible
		end,
		finalCerrado = function(): number
			return cerrado
		end,
	}
end

return Pantallas
