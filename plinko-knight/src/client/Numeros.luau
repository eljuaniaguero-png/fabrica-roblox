--!strict
-- Números en pantalla: lo que suma cada clavija tocada (salta sobre ella) y el panel de la
-- izquierda, FUERZA × MULTI = GOLPE, que sube con cada toque con un "pop" de tamaño.
-- Son BillboardGui con tamaño en studs, así acompañan al tablero en cualquier pantalla.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Config = require(Shared:WaitForChild("Config"))

local Numeros = {}

local amarillo = Color3.fromHex(Config.Colores.Numero)

local function etiqueta(padre: Instance, texto: string): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = amarillo
	t.TextStrokeTransparency = 0
	t.Text = texto
	t.Parent = padre
	return t
end

-- "+2" sobre una clavija (o el texto que se pase, por ejemplo la quemadura sobre el monstruo):
-- sube y se desvanece. tamanio: en studs (por defecto 3 × 1,6).
function Numeros.saltar(
	parte: BasePart,
	danio: number,
	texto: string?,
	color: Color3?,
	tamanio: Vector2?
)
	local n = Config.Numeros
	local medida = tamanio or Vector2.new(3, 1.6)
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Numero"
	cartel.Size = UDim2.fromScale(medida.X, medida.Y) -- studs
	cartel.StudsOffsetWorldSpace = Vector3.new(0, 1, 2.5)
	cartel.LightInfluence = 0
	cartel.Adornee = parte
	local t = etiqueta(cartel, texto or ("+" .. danio))
	if color then
		t.TextColor3 = color
	end
	cartel.Parent = parte

	local info = TweenInfo.new(n.Duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(cartel, info, { StudsOffsetWorldSpace = Vector3.new(0, 1 + n.Subida, 2.5) })
		:Play()
	-- Se ve entero la primera mitad y se desvanece en la segunda (si no, casi no se llega a leer).
	local desvanecer = TweenInfo.new(
		n.Duracion / 2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In,
		0,
		false,
		n.Duracion / 2
	)
	TweenService:Create(t, desvanecer, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(n.Duracion, function()
		cartel:Destroy()
	end)
end

export type Panel = {
	-- Pone las dos cajas. pop: "fuerza", "multi", "por" (la azul multiplicó) o nil.
	poner: (fuerza: number, multi: number, pop: string?) -> (),
	golpe: (valor: number) -> (), -- muestra "= GOLPE" grande al caer la bola
	limpiar: () -> (), -- tiro nuevo: Fuerza 0, Multi 1 y sin golpe
}

-- Panel de la columna izquierda: FUERZA (azul) × MULTI (rojo) y abajo el GOLPE. Colgado de una
-- parte invisible (la pone Escena a la izquierda del tablero), en studs, como el resto.
function Numeros.crearPanel(ancla: BasePart): Panel
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Panel"
	cartel.Size = UDim2.fromScale(11, 10) -- studs
	cartel.LightInfluence = 0
	cartel.Adornee = ancla

	local function caja(titulo: string, hex: string, x: number): (TextLabel, UIScale)
		local fondo = Instance.new("Frame")
		fondo.Position = UDim2.fromScale(x, 0)
		fondo.Size = UDim2.fromScale(0.42, 0.5)
		fondo.BackgroundColor3 = Color3.fromHex(hex)
		fondo.BorderSizePixel = 0
		fondo.Parent = cartel
		local esquinas = Instance.new("UICorner")
		esquinas.CornerRadius = UDim.new(0.12, 0)
		esquinas.Parent = fondo
		local escala = Instance.new("UIScale")
		escala.Parent = fondo
		local t = etiqueta(fondo, titulo)
		t.TextColor3 = Color3.new(1, 1, 1)
		t.Position = UDim2.fromScale(0.05, 0.04)
		t.Size = UDim2.fromScale(0.9, 0.3)
		local valor = etiqueta(fondo, "0")
		valor.TextColor3 = Color3.new(1, 1, 1)
		valor.Position = UDim2.fromScale(0.05, 0.36)
		valor.Size = UDim2.fromScale(0.9, 0.58)
		return valor, escala
	end

	local fuerza, escalaFuerza = caja("FUERZA", Config.Colores.Fuerza, 0)
	local multi, escalaMulti = caja("MULTI", Config.Colores.Multi, 0.58)
	local por = etiqueta(cartel, "×")
	por.TextColor3 = Color3.new(1, 1, 1)
	por.Position = UDim2.fromScale(0.42, 0.1)
	por.Size = UDim2.fromScale(0.16, 0.3)
	local golpe = etiqueta(cartel, "")
	golpe.Position = UDim2.fromScale(0, 0.55)
	golpe.Size = UDim2.fromScale(1, 0.45)
	local escalaGolpe = Instance.new("UIScale")
	escalaGolpe.Parent = golpe
	cartel.Parent = ancla

	local info =
		TweenInfo.new(Config.Numeros.DuracionPop, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local function saltar(escala: UIScale, tamanio: number)
		escala.Scale = tamanio
		TweenService:Create(escala, info, { Scale = 1 }):Play()
	end

	return {
		poner = function(f: number, m: number, pop: string?)
			fuerza.Text = Clavijas.numeroCorto(f)
			multi.Text = Clavijas.numeroCorto(m)
			if pop == "fuerza" then
				saltar(escalaFuerza, Config.Numeros.PopTotal)
			elseif pop == "multi" then
				saltar(escalaMulti, Config.Numeros.PopTotal)
			elseif pop == "por" then
				saltar(escalaMulti, Config.Numeros.PopTotal * 1.3)
			end
		end,
		golpe = function(valor: number)
			golpe.Text = "= " .. Clavijas.numeroCorto(valor)
			saltar(escalaGolpe, 1.6)
		end,
		limpiar = function()
			fuerza.Text = Clavijas.numeroCorto(Config.Danio.FuerzaInicial)
			multi.Text = Clavijas.numeroCorto(Config.Danio.MultiInicial)
			golpe.Text = ""
		end,
	}
end

return Numeros
