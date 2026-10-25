--!strict
-- Números de daño en pantalla: el "+2" que salta sobre cada clavija tocada y el TOTAL grande
-- arriba del lugar del monstruo, que sube con cada toque con un "pop" de tamaño.
-- Son BillboardGui con tamaño en studs, así acompañan al tablero en cualquier pantalla.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
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

export type Total = {
	poner: (valor: number, pop: boolean) -> (),
	duplicar: () -> (), -- "×2" grande al lado del TOTAL (clavija roja)
}

-- TOTAL grande, colgado de una parte invisible (la pone Escena arriba del monstruo).
function Numeros.crearTotal(ancla: BasePart): Total
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Total"
	cartel.Size = UDim2.fromScale(12, 5) -- studs
	cartel.ClipsDescendants = false -- el "×2" sale un poco del cartel
	cartel.LightInfluence = 0
	cartel.Adornee = ancla
	local escala = Instance.new("UIScale")
	escala.Parent = cartel

	local titulo = etiqueta(cartel, "TOTAL")
	titulo.Size = UDim2.fromScale(1, 0.35)
	local valor = etiqueta(cartel, "0")
	valor.Position = UDim2.fromScale(0, 0.35)
	valor.Size = UDim2.fromScale(1, 0.65)
	cartel.Parent = ancla

	-- "×2" grande, a la derecha del número (fuera del cartel: ClipsDescendants está apagado).
	local por = etiqueta(cartel, ("×%d"):format(Config.Mejoras.Duplica.Factor))
	por.AnchorPoint = Vector2.new(0, 0.5)
	por.Position = UDim2.fromScale(0.78, 0.6)
	por.Size = UDim2.fromScale(0.55, 0.8)
	por.TextColor3 = Color3.fromHex(Config.Colores.Duplica)
	por.TextTransparency = 1
	por.TextStrokeTransparency = 1
	local escalaPor = Instance.new("UIScale")
	escalaPor.Parent = por
	local duplicados = 0

	local info =
		TweenInfo.new(Config.Numeros.DuracionPop, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	return {
		poner = function(n: number, pop: boolean)
			valor.Text = tostring(n)
			if pop then
				escala.Scale = Config.Numeros.PopTotal
				TweenService:Create(escala, info, { Scale = 1 }):Play()
			end
		end,
		duplicar = function()
			duplicados += 1
			local marca = duplicados
			por.TextTransparency = 0
			por.TextStrokeTransparency = 0
			escalaPor.Scale = 1.8
			TweenService:Create(escalaPor, info, { Scale = 1 }):Play()
			escala.Scale = Config.Numeros.PopTotal * 1.2
			TweenService:Create(escala, info, { Scale = 1 }):Play()
			task.delay(Config.Numeros.DuracionDuplica, function()
				if duplicados == marca then
					TweenService:Create(
						por,
						TweenInfo.new(0.25),
						{ TextTransparency = 1, TextStrokeTransparency = 1 }
					):Play()
				end
			end)
		end,
	}
end

return Numeros
