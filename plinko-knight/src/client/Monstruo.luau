--!strict
-- El monstruo en graybox: el cartel plano de Escena con un rectángulo de su color y su nombre,
-- y la barra de vida arriba. Solo dibuja: la vida y los golpes los decide el servidor.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

export type Monstruo = {
	mostrar: (piso: number, vida: number) -> (),
	ponerVida: (vida: number, animado: boolean) -> (),
	recibir: () -> (), -- se sacude con el golpe
	atacar: () -> (), -- se agranda y vuelve
	centro: () -> Vector3,
}

local Monstruo = {}

-- La cámara mira hacia -Z: la cara que se ve de las partes es la de atrás.
local CARA = Enum.NormalId.Back

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

function Monstruo.crear(cartel: BasePart, barra: BasePart): Monstruo
	local base = cartel.CFrame
	local tamanio = cartel.Size
	local t = Config.Turno

	-- Cartel: rectángulo de color y nombre abajo.
	local gui = Instance.new("SurfaceGui")
	gui.Face = CARA
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(500, 600)
	gui.Parent = cartel
	local rectangulo = Instance.new("Frame")
	rectangulo.AnchorPoint = Vector2.new(0.5, 0)
	rectangulo.Position = UDim2.fromScale(0.5, 0.08)
	rectangulo.Size = UDim2.fromScale(0.75, 0.66)
	rectangulo.BorderSizePixel = 0
	rectangulo.Parent = gui
	local nombre = texto(gui, "")
	nombre.Position = UDim2.fromScale(0.05, 0.78)
	nombre.Size = UDim2.fromScale(0.9, 0.16)

	-- Barra de vida.
	local guiBarra = Instance.new("SurfaceGui")
	guiBarra.Face = CARA
	guiBarra.LightInfluence = 0
	guiBarra.CanvasSize = Vector2.new(500, 65)
	guiBarra.Parent = barra
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	fondo.BorderSizePixel = 0
	fondo.Parent = guiBarra
	local relleno = Instance.new("Frame")
	relleno.Size = UDim2.fromScale(1, 1)
	relleno.BackgroundColor3 = Color3.fromHex(Config.Colores.VidaMonstruo)
	relleno.BorderSizePixel = 0
	relleno.Parent = fondo
	local numeros = texto(fondo, "")
	numeros.Size = UDim2.fromScale(1, 1)
	numeros.ZIndex = 2

	local vidaMaxima = 1

	local function ponerVida(vida: number, animado: boolean)
		local fraccion = math.clamp(vida / vidaMaxima, 0, 1)
		numeros.Text = ("%d/%d"):format(vida, vidaMaxima)
		local destino = UDim2.fromScale(fraccion, 1)
		if animado then
			TweenService:Create(
				relleno,
				TweenInfo.new(t.BajadaBarra, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = destino }
			):Play()
		else
			relleno.Size = destino
		end
	end

	local sacudida = 0 -- para cortar una sacudida vieja si empieza otra
	return {
		mostrar = function(piso: number, vida: number)
			local m = Mazmorra.monstruo(piso)
			vidaMaxima = m.Vida
			rectangulo.BackgroundColor3 = Color3.fromHex(m.Color)
			nombre.Text = m.Nombre
			cartel.Size = tamanio
			cartel.CFrame = base
			ponerVida(vida, false)
		end,
		ponerVida = ponerVida,
		recibir = function()
			sacudida += 1
			local marca = sacudida
			task.spawn(function()
				local fin = os.clock() + t.Sacudida
				while os.clock() < fin and sacudida == marca do
					local queda = (fin - os.clock()) / t.Sacudida * Ajustes.factorEfectos()
					cartel.CFrame = base * CFrame.new((math.random() * 2 - 1) * 0.6 * queda, 0, 0)
					task.wait()
				end
				if sacudida == marca then
					cartel.CFrame = base
				end
			end)
		end,
		atacar = function()
			TweenService:Create(
				cartel,
				TweenInfo.new(
					t.DuracionAtaque / 2,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					true
				),
				{ Size = Vector3.new(tamanio.X * t.Agrandar, tamanio.Y * t.Agrandar, tamanio.Z) }
			):Play()
		end,
		centro = function(): Vector3
			return base.Position
		end,
	}
end

return Monstruo
