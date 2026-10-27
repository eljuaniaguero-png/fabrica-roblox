--!strict
-- Elegir clavijas tocándolas en el tablero (paso 5b): la usan la tienda (mejora de clavija) y los
-- pergaminos (forja, martillo). Muestra un cartel arriba con lo que hay que hacer y un botón
-- "Cancelar"; cada clavija tocada se marca. elegir() espera hasta que se tocan las que hacen
-- falta (devuelve sus Id) o hasta que se cancela (devuelve nil). El servidor vuelve a validar.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Estilo = require(script.Parent:WaitForChild("Estilo"))

export type Seleccion = {
	elegir: (cantidad: number, texto: string, valida: (id: number) -> boolean) -> { number }?,
	activa: () -> boolean,
}

local Seleccion = {}

-- Cuánto más lejos que el radio de la clavija vale el toque (con el dedo se erra un poco).
local MARGEN_TOQUE = 1.8

function Seleccion.crear(escena: any): Seleccion
	-- El cartel va en la franja de arriba (tapa "Pelea N de 9" mientras elegís): el tablero queda
	-- libre para tocar.
	local gui = Estilo.pantalla("Seleccion", 12, Players.LocalPlayer:WaitForChild("PlayerGui"))
	local lienzo = Estilo.lienzo(gui)
	local cartel = Estilo.panel(lienzo)
	cartel.AnchorPoint = Vector2.new(0.5, 0)
	cartel.Position = UDim2.fromScale(0.5, 0)
	cartel.Size = UDim2.fromOffset(600, Estilo.Medidas.BarraArriba)
	cartel.BackgroundTransparency = 0
	cartel.Visible = false
	Estilo.borde(cartel, "Oro")
	local texto = Estilo.texto(cartel, "", Estilo.Texto.Normal, Estilo.Fuentes.Texto)
	texto.TextXAlignment = Enum.TextXAlignment.Left
	texto.Position = UDim2.fromOffset(14, 4)
	texto.Size = UDim2.new(1, -200, 1, -8)
	local cancelar = Estilo.boton(cartel, "Cancelar", "Peligro", Estilo.Texto.Normal)
	cancelar.Name = "Cancelar"
	cancelar.AnchorPoint = Vector2.new(1, 0.5)
	cancelar.Position = UDim2.new(1, -6, 0.5, 0)
	cancelar.Size = UDim2.fromOffset(170, Estilo.Medidas.Boton)

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
		elegir = function(cantidad: number, valorTexto: string, valida: (id: number) -> boolean): { number }?
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
