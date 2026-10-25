--!strict
-- Elegir clavijas tocándolas en el tablero (paso 5b): la usan la tienda (mejora de clavija) y los
-- pergaminos (forja, martillo). Muestra un cartel arriba con lo que hay que hacer y un botón
-- "Cancelar"; cada clavija tocada se marca. elegir() espera hasta que se tocan las que hacen
-- falta (devuelve sus Id) o hasta que se cancela (devuelve nil). El servidor vuelve a validar.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

export type Seleccion = {
	elegir: (cantidad: number, texto: string, valida: (id: number) -> boolean) -> { number }?,
	activa: () -> boolean,
}

local Seleccion = {}

-- Cuánto más lejos que el radio de la clavija vale el toque (con el dedo se erra un poco).
local MARGEN_TOQUE = 1.8

function Seleccion.crear(escena: any): Seleccion
	local gui = Instance.new("ScreenGui")
	gui.Name = "Seleccion"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 12
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local cartel = Instance.new("Frame")
	cartel.AnchorPoint = Vector2.new(0.5, 0)
	cartel.Position = UDim2.new(0.5, 0, 0, 56)
	cartel.Size = UDim2.new(0.5, 0, 0, 56)
	cartel.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	cartel.BackgroundTransparency = 0.15
	cartel.BorderSizePixel = 0
	cartel.Visible = false
	cartel.Parent = gui
	local redondeo = Instance.new("UICorner")
	redondeo.CornerRadius = UDim.new(0.2, 0)
	redondeo.Parent = cartel
	local texto = Instance.new("TextLabel")
	texto.BackgroundTransparency = 1
	texto.Position = UDim2.fromScale(0.03, 0.1)
	texto.Size = UDim2.fromScale(0.7, 0.8)
	texto.Font = Enum.Font.GothamBold
	texto.TextScaled = true
	texto.TextColor3 = Color3.new(1, 1, 1)
	texto.Parent = cartel
	local cancelar = Instance.new("TextButton")
	cancelar.Name = "Cancelar"
	cancelar.AnchorPoint = Vector2.new(1, 0.5)
	cancelar.Position = UDim2.fromScale(0.98, 0.5)
	cancelar.Size = UDim2.new(0.24, 0, 0, 44) -- 44 px: se toca bien con el dedo
	cancelar.BackgroundColor3 = Color3.fromHex(Config.Colores.Golpe)
	cancelar.BorderSizePixel = 0
	cancelar.Font = Enum.Font.GothamBlack
	cancelar.TextScaled = true
	cancelar.TextColor3 = Color3.new(1, 1, 1)
	cancelar.Text = "Cancelar"
	cancelar.Parent = cartel
	local redondeoBoton = Instance.new("UICorner")
	redondeoBoton.CornerRadius = UDim.new(0.25, 0)
	redondeoBoton.Parent = cancelar

	local activa = false
	local cancelada = false
	local elegidas: { number } = {}
	local marcas: { Instance } = {}
	local hacenFalta = 0
	local validaActual: (id: number) -> boolean = function(_id: number): boolean
		return false
	end

	cancelar.Activated:Connect(function()
		cancelada = true
	end)

	-- La clavija más cercana al toque (si está cerca de verdad).
	local function clavijaEn(pos: Vector2): number?
		local x, y = escena.aTablero(pos)
		local mejor, distancia = nil, math.huge
		for _, c in escena.Tablero.Clavijas do
			local d = math.sqrt((c.X - x) ^ 2 + (c.Y - y) ^ 2)
			if d < distancia then
				mejor, distancia = c.Id, d
			end
		end
		if mejor and distancia <= Config.Tablero.RadioClavija * MARGEN_TOQUE then
			return mejor
		end
		return nil
	end

	UserInputService.InputBegan:Connect(function(input: InputObject, procesado: boolean)
		if not activa or procesado then
			return
		end
		local tipo = input.UserInputType
		if tipo ~= Enum.UserInputType.MouseButton1 and tipo ~= Enum.UserInputType.Touch then
			return
		end
		local id = clavijaEn(Vector2.new(input.Position.X, input.Position.Y))
		if not id or table.find(elegidas, id) or not validaActual(id) then
			return
		end
		table.insert(elegidas, id)
		local parte = escena.Clavijas[id]
		if parte then
			local marca = Instance.new("SelectionBox")
			marca.Adornee = parte
			marca.LineThickness = 0.15
			marca.Color3 = Color3.new(1, 1, 1)
			marca.Parent = parte
			table.insert(marcas, marca)
		end
	end)

	return {
		elegir = function(
			cantidad: number,
			valorTexto: string,
			valida: (id: number) -> boolean
		): { number }?
			activa, cancelada = true, false
			elegidas, hacenFalta, validaActual = {}, cantidad, valida
			texto.Text = valorTexto
			cartel.Visible = true
			while not cancelada and #elegidas < hacenFalta do
				task.wait()
			end
			task.wait(0.15) -- que se vea la marca de la última antes de soltar
			for _, marca in marcas do
				marca:Destroy()
			end
			marcas = {}
			cartel.Visible = false
			activa = false
			return if cancelada then nil else elegidas
		end,
		activa = function(): boolean
			return activa
		end,
	}
end

return Seleccion
