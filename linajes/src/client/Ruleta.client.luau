--!strict
-- Pantalla de la ruleta: rueda animada, íconos por Linaje, probabilidades y giro por 1 Ficha.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))
local remoto = ReplicatedStorage:WaitForChild("Ruleta") :: RemoteEvent

local H = Config.Hud
local R = Config.Ruleta
local jugador = Players.LocalPlayer

local gui = Tema.pantalla("Ruleta", 5)

-- Arriba a la derecha: botón editorial + Ficha Eclipse si existe el ícono.
local esquina =
	Tema.grupo(gui, Vector2.new(1, 0), UDim2.new(1, -H.Margen, 0, 42), Vector2.new(250, 74))
local abrir = Instance.new("TextButton")
abrir.Size = UDim2.fromScale(1, 1)
abrir.BackgroundTransparency = 1
abrir.Text = ""
abrir.Parent = esquina
local titulo = Tema.texto(esquina, "RULETA", { tam = 20, espaciado = 4 })
titulo.AnchorPoint = Vector2.new(1, 0)
titulo.Position = UDim2.fromScale(1, 0)
local raya = Instance.new("Frame")
raya.AnchorPoint = Vector2.new(1, 0)
raya.Position = UDim2.new(1, 0, 0, 32)
raya.Size = UDim2.fromOffset(146, 2)
raya.BackgroundColor3 = Tema.Hueso
raya.BackgroundTransparency = 0.6
raya.BorderSizePixel = 0
raya.Parent = esquina

local iconoFicha = Instance.new("ImageLabel")
iconoFicha.AnchorPoint = Vector2.new(1, 0)
iconoFicha.Position = UDim2.new(1, 0, 0, 38)
iconoFicha.Size = UDim2.fromOffset(22, 22)
iconoFicha.BackgroundTransparency = 1
iconoFicha.ScaleType = Enum.ScaleType.Fit
iconoFicha.Image = H.Imagenes.Monedas.FichaEclipse
iconoFicha.Visible = H.Imagenes.Monedas.FichaEclipse ~= ""
iconoFicha.Parent = esquina

local fichasTexto =
	Tema.texto(esquina, "", { tam = 16, letra = Tema.LetraFina, transparencia = 0.3 })
fichasTexto.AnchorPoint = Vector2.new(1, 0)
fichasTexto.Position = UDim2.new(1, if iconoFicha.Visible then -28 else 0, 0, 39)

abrir.MouseEnter:Connect(function()
	raya.BackgroundTransparency = 0.1
end)
abrir.MouseLeave:Connect(function()
	raya.BackgroundTransparency = 0.6
end)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(510, 446)
panel.BackgroundColor3 = Tema.Fondo
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local bordePanel = Instance.new("UIStroke")
bordePanel.Color = Tema.Hueso
bordePanel.Transparency = 0.65
bordePanel.Parent = panel

local encabezado = Tema.texto(panel, Tema.espaciar("RULETA DEL ECLIPSE", 3), { tam = 21 })
encabezado.Position = UDim2.fromOffset(24, 18)

local cerrar = Instance.new("TextButton")
cerrar.AnchorPoint = Vector2.new(1, 0)
cerrar.Position = UDim2.new(1, -12, 0, 10)
cerrar.Size = UDim2.fromOffset(38, 38)
cerrar.BackgroundTransparency = 1
cerrar.Text = "×"
cerrar.TextColor3 = Tema.Hueso
cerrar.FontFace = Tema.LetraFina
cerrar.TextSize = 28
cerrar.Parent = panel
cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Rueda central / visual superior
local rueda = Instance.new("ImageLabel")
rueda.AnchorPoint = Vector2.new(0.5, 0.5)
rueda.Position = UDim2.fromOffset(66, 94)
rueda.Size = UDim2.fromOffset(74, 74)
rueda.BackgroundTransparency = 1
rueda.ScaleType = Enum.ScaleType.Fit
rueda.Image = H.Imagenes.Menu.RuedaRuleta
rueda.Visible = H.Imagenes.Menu.RuedaRuleta ~= ""
rueda.Parent = panel

local romboResultado = if not rueda.Visible
	then Tema.rombo(panel, Vector2.new(66, 94), 52, true)
	else nil

local resIcono = Instance.new("ImageLabel")
resIcono.AnchorPoint = Vector2.new(0, 0.5)
resIcono.Position = UDim2.fromOffset(118, 94)
resIcono.Size = UDim2.fromOffset(36, 36)
resIcono.BackgroundTransparency = 1
resIcono.ScaleType = Enum.ScaleType.Fit
resIcono.Visible = false
resIcono.Parent = panel

local resultado = Instance.new("TextLabel")
resultado.Position = UDim2.fromOffset(118, 68)
resultado.Size = UDim2.new(1, -140, 0, 52)
resultado.BackgroundTransparency = 1
resultado.TextColor3 = Tema.Xp
resultado.FontFace = Tema.LetraGruesa
resultado.TextSize = 32
resultado.TextXAlignment = Enum.TextXAlignment.Left
resultado.Text = "LISTA PARA GIRAR"
resultado.Parent = panel

-- Tabla de probabilidades por Linaje
local listaMarco = Instance.new("Frame")
listaMarco.Position = UDim2.fromOffset(24, 148)
listaMarco.Size = UDim2.new(1, -48, 0, 214)
listaMarco.BackgroundTransparency = 1
listaMarco.Parent = panel
local ordenLista = Instance.new("UIListLayout")
ordenLista.Padding = UDim.new(0, 5)
ordenLista.Parent = listaMarco

local nombres: { [string]: string } = {}
do
	local total = 0
	for _, o in R.Opciones do
		nombres[o.Linaje] = o.Nombre
		if o.Disponible then
			total += o.Peso
		end
	end
	for _, o in R.Opciones do
		local fila = Instance.new("Frame")
		fila.Size = UDim2.new(1, 0, 0, 31)
		fila.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		fila.BackgroundTransparency = if o.Disponible then 0.5 else 0.76
		fila.BorderSizePixel = 0
		fila.Parent = listaMarco

		local colorLinaje = if o.Disponible then Tema.color(o.Linaje) else Color3.fromHex("#565E6D")

		local idIco = (H.Imagenes.Linajes :: any)[o.Linaje] or ""
		if not o.Disponible and H.Imagenes.Menu.Candado ~= "" then
			idIco = H.Imagenes.Menu.Candado
		end
		if idIco ~= "" then
			local ico = Instance.new("ImageLabel")
			ico.AnchorPoint = Vector2.new(0, 0.5)
			ico.Position = UDim2.new(0, 8, 0.5, 0)
			ico.Size = UDim2.fromOffset(20, 20)
			ico.BackgroundTransparency = 1
			ico.ScaleType = Enum.ScaleType.Fit
			ico.Image = idIco
			ico.ImageColor3 = colorLinaje
			ico.ImageTransparency = if o.Disponible then 0 else 0.4
			ico.Parent = fila
		else
			local punto = Instance.new("Frame")
			punto.AnchorPoint = Vector2.new(0, 0.5)
			punto.Position = UDim2.new(0, 12, 0.5, 0)
			punto.Size = UDim2.fromOffset(9, 9)
			punto.Rotation = 45
			punto.BackgroundColor3 = colorLinaje
			punto.BorderSizePixel = 0
			punto.Parent = fila
		end

		local txt = Tema.texto(fila, string.format("%s  ·  %s", o.Nombre, o.Rareza), {
			tam = 16,
			letra = if o.Disponible then Tema.Letra else Tema.LetraFina,
			color = if o.Disponible then Tema.Hueso else Color3.fromHex("#7D8594"),
		})
		txt.Position = UDim2.fromOffset(38, 5)

		local pctTexto = if o.Disponible and total > 0
			then string.format("%.2f%%", o.Peso / total * 100)
			else "PRONTO"
		local pct = Tema.texto(fila, pctTexto, {
			tam = 15,
			letra = Tema.LetraFina,
			color = colorLinaje,
			alineado = Enum.TextXAlignment.Right,
		})
		pct.AnchorPoint = Vector2.new(1, 0)
		pct.Position = UDim2.new(1, -12, 0, 6)
	end
end

local tirar = Instance.new("TextButton")
tirar.Position = UDim2.new(0, 24, 1, -70)
tirar.Size = UDim2.new(1, -48, 0, 50)
tirar.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
tirar.BackgroundTransparency = 0.16
tirar.TextColor3 = Tema.Hueso
tirar.FontFace = Tema.Letra
tirar.TextSize = 19
tirar.Parent = panel
local bordeTirar = Instance.new("UIStroke")
bordeTirar.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bordeTirar.Color = Tema.Hueso
bordeTirar.Transparency = 0.35
bordeTirar.Parent = tirar

local function mostrarResultado(idLinaje: string, etiqueta: string, color: Color3)
	local img = (H.Imagenes.Linajes :: any)[idLinaje] or ""
	resIcono.Image = img
	resIcono.ImageColor3 = color
	resIcono.Visible = img ~= ""
	resultado.Position = UDim2.fromOffset(if resIcono.Visible then 162 else 118, 68)
	resultado.Size = UDim2.new(1, if resIcono.Visible then -182 else -140, 0, 52)
	resultado.Text = etiqueta
	resultado.TextColor3 = color
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
			table.insert(visibles, o)
		end
	end
	for i = 1, 18 do
		local cand = visibles[i % #visibles + 1]
		mostrarResultado(cand.Linaje, cand.Nombre, Tema.color(cand.Linaje))
		if rueda.Visible then
			rueda.Rotation = (rueda.Rotation + 32) % 360
		elseif romboResultado then
			romboResultado.Rotation = (romboResultado.Rotation + 30) % 360
		end
		task.wait(0.04 + i * 0.008)
	end
	mostrarResultado(linaje, "¡" .. (nombres[linaje] or linaje) .. "!", Tema.color(linaje))
	-- SONIDO: resultado de la ruleta
end)

for _, atributo in { "Fichas", "Linaje", "DatosListos" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizar)
end
actualizar()
gui.Parent = jugador:WaitForChild("PlayerGui")
