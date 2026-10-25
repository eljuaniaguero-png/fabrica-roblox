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

-- "+2" sobre una clavija: sube y se desvanece.
function Numeros.saltar(clavija: BasePart, danio: number)
	local n = Config.Numeros
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Numero"
	cartel.Size = UDim2.fromScale(3, 1.6) -- studs
	cartel.StudsOffsetWorldSpace = Vector3.new(0, 1, 2.5)
	cartel.LightInfluence = 0
	cartel.Adornee = clavija
	local t = etiqueta(cartel, "+" .. danio)
	cartel.Parent = clavija

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
}

-- TOTAL grande, colgado de una parte invisible (la pone Escena arriba del monstruo).
function Numeros.crearTotal(ancla: BasePart): Total
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Total"
	cartel.Size = UDim2.fromScale(12, 5) -- studs
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
	}
end

return Numeros
