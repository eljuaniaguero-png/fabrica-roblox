--!strict
-- Pantallas de la etapa 4, en graybox: la barra de arriba (vida del caballero y piso), el cartel
-- "¡Piso N!" y las pantallas de perder y de ganar la mazmorra, con un botón grande.
-- Las pantallas lindas llegan en la etapa 7.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))

export type Pantallas = {
	ponerEstado: (estado: Mazmorra.Estado) -> (),
	ponerVida: (vida: number, maxima: number) -> (),
	anunciar: (texto: string) -> (),
	mostrarFinal: (titulo: string, boton: string, alTocar: () -> ()) -> (),
	ocultarFinal: () -> (),
	hayFinal: () -> boolean,
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
		hayFinal = function(): boolean
			return final.Visible
		end,
		finalCerrado = function(): number
			return cerrado
		end,
	}
end

return Pantallas
