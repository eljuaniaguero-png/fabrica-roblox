--!strict
-- Pantalla de la ruleta: probabilidades siempre a la vista y botón con texto antes de tirar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))
local remoto = ReplicatedStorage:WaitForChild("Ruleta") :: RemoteEvent

local R = Config.Ruleta
local jugador = Players.LocalPlayer

local gui = Tema.pantalla("Ruleta", 5)

-- Arriba a la derecha: solo texto y una línea, sin caja.
local esquina = Tema.grupo(
	gui,
	Vector2.new(1, 0),
	UDim2.new(1, -Config.Hud.Margen, 0, 48),
	Vector2.new(200, 64)
)
local abrir = Instance.new("TextButton")
abrir.Size = UDim2.fromScale(1, 1)
abrir.BackgroundTransparency = 1
abrir.Text = ""
abrir.Parent = esquina
local titulo = Tema.texto(esquina, "RULETA", { tam = 16, espaciado = 4 })
titulo.AnchorPoint = Vector2.new(1, 0)
titulo.Position = UDim2.fromScale(1, 0)
local raya = Instance.new("Frame")
raya.AnchorPoint = Vector2.new(1, 0)
raya.Position = UDim2.new(1, 0, 0, 28)
raya.Size = UDim2.fromOffset(120, 1)
raya.BackgroundColor3 = Tema.Hueso
raya.BackgroundTransparency = 0.6
raya.BorderSizePixel = 0
raya.Parent = esquina
local fichasTexto =
	Tema.texto(esquina, "", { tam = 13, letra = Tema.LetraFina, transparencia = 0.4 })
fichasTexto.AnchorPoint = Vector2.new(1, 0)
fichasTexto.Position = UDim2.new(1, 0, 0, 34)
abrir.MouseEnter:Connect(function()
	raya.BackgroundTransparency = 0.1
end)
abrir.MouseLeave:Connect(function()
	raya.BackgroundTransparency = 0.6
end)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(380, 330)
panel.BackgroundColor3 = Tema.Fondo
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local bordePanel = Instance.new("UIStroke")
bordePanel.Color = Tema.Hueso
bordePanel.Transparency = 0.7
bordePanel.Parent = panel

local lista = Instance.new("TextLabel")
lista.Position = UDim2.fromOffset(20, 14)
lista.Size = UDim2.new(1, -40, 0, 180)
lista.BackgroundTransparency = 1
lista.TextColor3 = Tema.Hueso
lista.FontFace = Tema.LetraFina
lista.TextSize = 18
lista.TextXAlignment = Enum.TextXAlignment.Left
lista.TextYAlignment = Enum.TextYAlignment.Top
lista.Parent = panel

local resultado = Instance.new("TextLabel")
resultado.Position = UDim2.fromOffset(20, 200)
resultado.Size = UDim2.new(1, -40, 0, 46)
resultado.BackgroundTransparency = 1
resultado.TextColor3 = Tema.Xp
resultado.FontFace = Tema.LetraGruesa
resultado.TextScaled = true
resultado.Text = ""
resultado.Parent = panel

local tirar = Instance.new("TextButton")
tirar.Position = UDim2.new(0, 20, 1, -70)
tirar.Size = UDim2.new(1, -40, 0, 54)
tirar.BackgroundTransparency = 1
tirar.TextColor3 = Tema.Hueso
tirar.FontFace = Tema.Letra
tirar.TextSize = 18
tirar.Parent = panel
local bordeTirar = Instance.new("UIStroke")
bordeTirar.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bordeTirar.Color = Tema.Hueso
bordeTirar.Transparency = 0.4
bordeTirar.Parent = tirar

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
	fichasTexto.Text =
		Tema.espaciar(string.format("%d %s", n, if n == 1 then "FICHA" else "FICHAS"), 2)
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
