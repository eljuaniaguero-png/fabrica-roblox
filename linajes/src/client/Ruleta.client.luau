--!strict
-- Pantalla de la ruleta del sandbox: se abre al elegir un modo en el menú (tirada gratis).
-- Si no te gustó: otra tirada por Chatarra, o comprar un Linaje directo por una vida.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))
local remoto = ReplicatedStorage:WaitForChild("Ruleta") :: RemoteEvent

local H = Config.Hud
local R = Config.Ruleta
local S = Config.Sandbox
local jugador = Players.LocalPlayer
local ORO = Color3.fromHex("#ffd34d")
local GRIS = Color3.fromHex("#9fa7b5")
local NOMBRE_MODO: { [string]: string } = { FFA = "FREE FOR ALL", Duelo = "1 V 1" }

local gui = Tema.pantalla("Ruleta", 5)

-- Arriba a la derecha: botón editorial + Chatarra.
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

local iconoChatarra = Instance.new("ImageLabel")
iconoChatarra.AnchorPoint = Vector2.new(1, 0)
iconoChatarra.Position = UDim2.new(1, 0, 0, 38)
iconoChatarra.Size = UDim2.fromOffset(22, 22)
iconoChatarra.BackgroundTransparency = 1
iconoChatarra.ScaleType = Enum.ScaleType.Fit
iconoChatarra.Image = H.Imagenes.Monedas.Chatarra
iconoChatarra.Visible = H.Imagenes.Monedas.Chatarra ~= ""
iconoChatarra.Parent = esquina

local monedasTexto =
	Tema.texto(esquina, "", { tam = 16, letra = Tema.LetraFina, transparencia = 0.3 })
monedasTexto.AnchorPoint = Vector2.new(1, 0)
monedasTexto.Position = UDim2.new(1, if iconoChatarra.Visible then -28 else 0, 0, 39)

abrir.MouseEnter:Connect(function()
	raya.BackgroundTransparency = 0.1
end)
abrir.MouseLeave:Connect(function()
	raya.BackgroundTransparency = 0.6
end)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(600, 470)
panel.BackgroundColor3 = Tema.Fondo
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local escalaPanel = Instance.new("UIScale")
escalaPanel.Parent = panel
local bordePanel = Instance.new("UIStroke")
bordePanel.Color = Tema.Hueso
bordePanel.Transparency = 0.65
bordePanel.Parent = panel

local function ajustarEscala()
	local cam = workspace.CurrentCamera
	if cam then
		local v = cam.ViewportSize
		escalaPanel.Scale = math.clamp(math.min(v.X / 680, v.Y / 520), 0.55, 1.4)
	end
end
ajustarEscala()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
end

local encabezado = Tema.texto(panel, Tema.espaciar("RULETA DEL ECLIPSE", 3), {
	tam = 21,
	letra = Tema.LetraGruesa,
})
encabezado.Position = UDim2.fromOffset(24, 16)

local subSeguro = Tema.texto(panel, "", {
	tam = 12,
	letra = Tema.LetraFina,
	color = GRIS,
})
subSeguro.Position = UDim2.fromOffset(24, 42)

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

-- Rueda / rombo del resultado arriba a la izquierda.
local rueda = Instance.new("ImageLabel")
rueda.AnchorPoint = Vector2.new(0.5, 0.5)
rueda.Position = UDim2.fromOffset(66, 104)
rueda.Size = UDim2.fromOffset(72, 72)
rueda.BackgroundTransparency = 1
rueda.ScaleType = Enum.ScaleType.Fit
rueda.Image = H.Imagenes.Menu.RuedaRuleta
rueda.Visible = H.Imagenes.Menu.RuedaRuleta ~= ""
rueda.Parent = panel

local puntero = Instance.new("Frame")
puntero.AnchorPoint = Vector2.new(0.5, 0.5)
puntero.Position = UDim2.fromOffset(66, 66)
puntero.Size = UDim2.fromOffset(9, 9)
puntero.Rotation = 45
puntero.BackgroundColor3 = ORO
puntero.BorderSizePixel = 0
puntero.ZIndex = 5
puntero.Parent = panel

local romboResultado = if not rueda.Visible
	then Tema.rombo(panel, Vector2.new(66, 104), 52, true)
	else nil

local resIcono = Instance.new("ImageLabel")
resIcono.AnchorPoint = Vector2.new(0, 0.5)
resIcono.Position = UDim2.fromOffset(118, 104)
resIcono.Size = UDim2.fromOffset(36, 36)
resIcono.BackgroundTransparency = 1
resIcono.ScaleType = Enum.ScaleType.Fit
resIcono.Visible = false
resIcono.Parent = panel

local resultado = Instance.new("TextLabel")
resultado.Position = UDim2.fromOffset(118, 78)
resultado.Size = UDim2.new(1, -140, 0, 52)
resultado.BackgroundTransparency = 1
resultado.TextColor3 = Tema.Xp
resultado.FontFace = Tema.LetraGruesa
resultado.TextSize = 30
resultado.TextXAlignment = Enum.TextXAlignment.Left
resultado.TextScaled = false
resultado.Text = "LISTA PARA GIRAR"
resultado.Parent = panel

-- Tabla de probabilidades + compra por una vida.
local listaMarco = Instance.new("Frame")
listaMarco.Position = UDim2.fromOffset(24, 150)
listaMarco.Size = UDim2.new(1, -48, 0, 220)
listaMarco.BackgroundTransparency = 1
listaMarco.Parent = panel
local ordenLista = Instance.new("UIListLayout")
ordenLista.Padding = UDim.new(0, 5)
ordenLista.Parent = listaMarco

local nombres: { [string]: string } = {}
local filasLinaje: { [string]: { borde: UIStroke, comprar: TextButton } } = {}

-- string.upper no pasa a mayúscula las letras con tilde ("Común" quedaba "COMúN").
local function mayus(texto: string): string
	local t = string.upper(texto)
	for chica, grande in
		{ ["á"] = "Á", ["é"] = "É", ["í"] = "Í", ["ó"] = "Ó", ["ú"] = "Ú", ["ñ"] = "Ñ" }
	do
		t = string.gsub(t, chica, grande)
	end
	return t
end

local function colorDe(linaje: string, variante: boolean): Color3
	local hex = variante and (S.Variante.Colores :: any)[linaje]
	return if typeof(hex) == "string" then Color3.fromHex(hex) else Tema.color(linaje)
end

do
	local total = 0
	for _, o in R.Opciones do
		nombres[o.Linaje] = o.Nombre
		if o.Disponible then
			total += o.Peso
		end
	end
	for _, o in R.Opciones do
		if not o.Disponible then
			continue
		end
		local fila = Instance.new("Frame")
		fila.Size = UDim2.new(1, 0, 0, 32)
		fila.BackgroundColor3 = Color3.fromRGB(16, 20, 29)
		fila.BackgroundTransparency = 0.35
		fila.BorderSizePixel = 0
		fila.Parent = listaMarco

		local colorLinaje = Tema.color(o.Linaje)
		local bordeFila = Instance.new("UIStroke")
		bordeFila.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bordeFila.Color = Tema.Hueso
		bordeFila.Transparency = 0.86
		bordeFila.Parent = fila

		local barraIzq = Instance.new("Frame")
		barraIzq.Size = UDim2.new(0, 3, 1, 0)
		barraIzq.BackgroundColor3 = colorLinaje
		barraIzq.BorderSizePixel = 0
		barraIzq.Parent = fila

		local idIco = (H.Imagenes.Linajes :: any)[o.Linaje] or ""
		if idIco ~= "" then
			local ico = Instance.new("ImageLabel")
			ico.AnchorPoint = Vector2.new(0, 0.5)
			ico.Position = UDim2.new(0, 12, 0.5, 0)
			ico.Size = UDim2.fromOffset(20, 20)
			ico.BackgroundTransparency = 1
			ico.ScaleType = Enum.ScaleType.Fit
			ico.Image = idIco
			ico.ImageColor3 = colorLinaje
			ico.Parent = fila
		end

		local txt = Tema.texto(
			fila,
			string.format("%s  ·  %s", mayus(o.Nombre), mayus(o.Rareza)),
			{ tam = 15 }
		)
		txt.Position = UDim2.fromOffset(40, 6)

		local pct = Tema.texto(fila, string.format("%.2f%%", o.Peso / total * 100), {
			tam = 15,
			letra = Tema.LetraGruesa,
			color = colorLinaje,
			alineado = Enum.TextXAlignment.Right,
		})
		pct.AnchorPoint = Vector2.new(1, 0)
		pct.Position = UDim2.new(1, -156, 0, 6)

		local precio = (S.PrecioLinajeVida :: any)[o.Rareza] or 0
		local comprar = Instance.new("TextButton")
		comprar.AnchorPoint = Vector2.new(1, 0.5)
		comprar.Position = UDim2.new(1, -4, 0.5, 0)
		comprar.Size = UDim2.fromOffset(142, 24)
		comprar.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
		comprar.Text = string.format("1 VIDA  ·  %d CHATARRA", precio)
		comprar.TextColor3 = Tema.Hueso
		comprar.FontFace = Tema.LetraFina
		comprar.TextSize = 12
		comprar.Parent = fila
		local bordeComprar = Instance.new("UIStroke")
		bordeComprar.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bordeComprar.Color = colorLinaje
		bordeComprar.Transparency = 0.45
		bordeComprar.Parent = comprar
		comprar.Activated:Connect(function()
			-- SONIDO: comprar
			remoto:FireServer("Comprar", o.Linaje)
		end)
		filasLinaje[o.Linaje] = { borde = bordeFila, comprar = comprar }
	end
	subSeguro.Text = Tema.espaciar(
		string.format(
			"VARIANTE: %d%% EN CUALQUIER LINAJE  ·  COMPRAR = SOLO UNA VIDA",
			math.round(S.Variante.Chance * 100)
		),
		1
	)
end

local function boton(texto: string, colorFondo: Color3, colorBorde: Color3): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = colorFondo
	b.BackgroundTransparency = 0.1
	b.Text = texto
	b.TextColor3 = Tema.Hueso
	b.FontFace = Tema.LetraGruesa
	b.TextSize = 17
	b.Parent = panel
	local borde = Instance.new("UIStroke")
	borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borde.Color = colorBorde
	borde.Thickness = 1.5
	borde.Parent = b
	return b
end

local tirar = boton("", Color3.fromRGB(22, 27, 38), Tema.Hueso)
local pelear = boton("", Color3.fromHex("#f2652b"), ORO)

-- Abajo: antes de la primera tirada, solo TIRAR (ancho). Después, OTRA TIRADA | IR A PELEAR.
local function acomodarBotones(hayResultado: boolean)
	if hayResultado then
		tirar.Position = UDim2.new(0, 24, 1, -70)
		tirar.Size = UDim2.new(0.5, -30, 0, 50)
		pelear.Position = UDim2.new(0.5, 6, 1, -70)
		pelear.Size = UDim2.new(0.5, -30, 0, 50)
	else
		tirar.Position = UDim2.new(0, 24, 1, -70)
		tirar.Size = UDim2.new(1, -48, 0, 50)
	end
	pelear.Visible = hayResultado
end

local modoActual = "FFA"
local hayResultado = false

local function resaltarFila(activo: unknown, variante: boolean)
	for clave, item in filasLinaje do
		local es = clave == activo
		item.borde.Color = if es then colorDe(clave, variante) else Tema.Hueso
		item.borde.Transparency = if es then 0.1 else 0.86
		item.borde.Thickness = if es then 1.5 else 1
		item.comprar.Visible = not es
	end
end

local function mostrarResultado(
	idLinaje: string,
	etiqueta: string,
	color: Color3,
	variante: boolean
)
	local img = (H.Imagenes.Linajes :: any)[idLinaje] or ""
	resIcono.Image = img
	resIcono.ImageColor3 = color
	resIcono.Visible = img ~= ""
	resultado.Position = UDim2.fromOffset(if resIcono.Visible then 162 else 118, 78)
	resultado.Size = UDim2.new(1, if resIcono.Visible then -182 else -140, 0, 52)
	resultado.Text = etiqueta
	resultado.TextColor3 = color
	resaltarFila(idLinaje, variante)
end

local function numero(nombre: string): number
	local v = jugador:GetAttribute(nombre)
	return if typeof(v) == "number" then v else 0
end

local function actualizar()
	local chatarra = numero("Chatarra")
	monedasTexto.Text = Tema.espaciar(string.format("%d CHATARRA", chatarra), 2)
	local gratis = jugador:GetAttribute("TiradaGratis") == true
	tirar.Text = if gratis
		then Tema.espaciar("TIRAR GRATIS", 2)
		else string.format("OTRA TIRADA  ·  %d CHATARRA", S.PrecioTirada)
	pelear.Text =
		Tema.espaciar(if modoActual == "Duelo" then "BUSCAR RIVAL 1 V 1" else "IR A PELEAR", 2)
	encabezado.Text =
		Tema.espaciar("RULETA DEL ECLIPSE  ·  " .. (NOMBRE_MODO[modoActual] or "SANDBOX"), 2)
	if not hayResultado then
		resaltarFila(jugador:GetAttribute("Linaje"), jugador:GetAttribute("Variante") == true)
	end
end

-- Cartel corto arriba al centro (avisos de la ruleta y del 1 V 1).
local cartel = Tema.texto(gui, "", { tam = 22, letra = Tema.LetraGruesa, color = ORO })
cartel.AnchorPoint = Vector2.new(0.5, 0)
cartel.Position = UDim2.new(0.5, 0, 0, 150)
cartel.TextStrokeColor3 = Tema.Fondo
cartel.TextStrokeTransparency = 0.2
cartel.ZIndex = 20
cartel.Visible = false
local cartelVersion = 0
local function avisar(texto: string)
	cartelVersion += 1
	local v = cartelVersion
	cartel.Text = texto
	cartel.TextTransparency = 0
	cartel.Visible = true
	task.delay(3.5, function()
		if v == cartelVersion then
			TweenService:Create(cartel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		end
	end)
end

abrir.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		hayResultado = typeof(jugador:GetAttribute("Linaje")) == "string"
		acomodarBotones(hayResultado)
		actualizar()
	end
end)
cerrar.Activated:Connect(function()
	panel.Visible = false
end)
tirar.Activated:Connect(function()
	-- SONIDO: girar la ruleta
	remoto:FireServer("Tirar")
end)
pelear.Activated:Connect(function()
	panel.Visible = false
	remoto:FireServer("Listo")
end)

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any)
	if tipo == "Abrir" and typeof(a) == "string" then
		modoActual = a
		hayResultado = false
		resultado.Text = "LISTA PARA GIRAR"
		resultado.TextColor3 = Tema.Xp
		resIcono.Visible = false
		acomodarBotones(false)
		actualizar()
		panel.Visible = true
	elseif tipo == "Aviso" and typeof(a) == "string" then
		avisar(a)
	elseif tipo == "Resultado" and typeof(a) == "string" then
		local variante = b == true
		local visibles = {}
		for _, o in R.Opciones do
			if o.Disponible then
				table.insert(visibles, o)
			end
		end
		for i = 1, 18 do
			local cand = visibles[i % #visibles + 1]
			mostrarResultado(cand.Linaje, cand.Nombre, Tema.color(cand.Linaje), false)
			if rueda.Visible then
				rueda.Rotation = (rueda.Rotation + 32) % 360
			elseif romboResultado then
				romboResultado.Rotation = (romboResultado.Rotation + 30) % 360
			end
			task.wait(0.04 + i * 0.008)
		end
		local nombre = mayus(nombres[a] or a)
		mostrarResultado(
			a,
			if variante then "¡" .. nombre .. " VARIANTE!" else "¡" .. nombre .. "!",
			colorDe(a, variante),
			variante
		)
		-- SONIDO: resultado de la ruleta (más brillante si es Variante)
		hayResultado = true
		acomodarBotones(true)
		actualizar()
	end
end)

for _, atributo in { "Chatarra", "Linaje", "Variante", "TiradaGratis" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizar)
end
acomodarBotones(false)
actualizar()
gui.Parent = jugador:WaitForChild("PlayerGui")
