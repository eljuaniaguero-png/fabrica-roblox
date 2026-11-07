--!strict
-- Pantalla de la ruleta: probabilidades siempre a la vista y botón con texto antes de tirar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Ruleta") :: RemoteEvent

local R = Config.Ruleta
local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Ruleta"
gui.ResetOnSpawn = false

local abrir = Instance.new("TextButton")
abrir.AnchorPoint = Vector2.new(1, 0)
abrir.Position = UDim2.new(1, -16, 0, 60)
abrir.Size = UDim2.fromOffset(170, 40)
abrir.BackgroundColor3 = Color3.fromRGB(242, 101, 43)
abrir.TextColor3 = Color3.new(1, 1, 1)
abrir.Font = Enum.Font.GothamBold
abrir.TextSize = 15
abrir.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(380, 330)
panel.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local lista = Instance.new("TextLabel")
lista.Position = UDim2.fromOffset(20, 14)
lista.Size = UDim2.new(1, -40, 0, 180)
lista.BackgroundTransparency = 1
lista.TextColor3 = Color3.fromRGB(238, 240, 244)
lista.Font = Enum.Font.GothamMedium
lista.TextSize = 17
lista.TextXAlignment = Enum.TextXAlignment.Left
lista.TextYAlignment = Enum.TextYAlignment.Top
lista.Parent = panel

local resultado = Instance.new("TextLabel")
resultado.Position = UDim2.fromOffset(20, 200)
resultado.Size = UDim2.new(1, -40, 0, 46)
resultado.BackgroundTransparency = 1
resultado.TextColor3 = Color3.fromRGB(255, 179, 71)
resultado.Font = Enum.Font.GothamBlack
resultado.TextScaled = true
resultado.Text = ""
resultado.Parent = panel

local tirar = Instance.new("TextButton")
tirar.Position = UDim2.new(0, 20, 1, -70)
tirar.Size = UDim2.new(1, -40, 0, 54)
tirar.BackgroundColor3 = Color3.fromRGB(242, 101, 43)
tirar.TextColor3 = Color3.new(1, 1, 1)
tirar.Font = Enum.Font.GothamBold
tirar.TextSize = 18
tirar.Parent = panel

local nombres: { [string]: string } = {}
do
	local total = 0
	for _, o in R.Opciones do
		nombres[o.Linaje] = o.Nombre
		if o.Disponible then
			total += o.Peso
		end
	end
	local filas = { "Probabilidades" }
	for _, o in R.Opciones do
		if o.Disponible then
			table.insert(
				filas,
				string.format("%s (%s): %.2f %%", o.Nombre, o.Rareza, o.Peso / total * 100)
			)
		end
	end
	lista.Text = table.concat(filas, "\n")
end

local function actualizar()
	local fichas = jugador:GetAttribute("Fichas")
	local linaje = jugador:GetAttribute("Linaje")
	local n = if typeof(fichas) == "number" then fichas else 0
	abrir.Text = string.format("Ruleta · %d Fichas", n)
	tirar.Text = if linaje == nil
		then "Tirar gratis"
		else string.format("Tirar por 1 Ficha (tenés %d)", n)
	if linaje == nil and jugador:GetAttribute("DatosListos") == true then
		panel.Visible = true
	end
end

abrir.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)
tirar.Activated:Connect(function()
	remoto:FireServer("Tirar")
end)
remoto.OnClientEvent:Connect(function(linaje: string)
	local visibles = {}
	for _, o in R.Opciones do
		if o.Disponible then
			table.insert(visibles, o.Nombre)
		end
	end
	for i = 1, 18 do
		resultado.Text = visibles[i % #visibles + 1]
		task.wait(0.04 + i * 0.008)
	end
	resultado.Text = "¡" .. (nombres[linaje] or linaje) .. "!"
	-- SONIDO: resultado de la ruleta
end)

for _, atributo in { "Fichas", "Linaje", "DatosListos" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizar)
end
actualizar()
gui.Parent = jugador:WaitForChild("PlayerGui")
