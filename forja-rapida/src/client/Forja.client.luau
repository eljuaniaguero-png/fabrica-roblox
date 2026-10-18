--!strict
-- La Forja (escena del cliente; la demo aprobada es ideas/la-forja-animacion.html).
-- Al romper una geoda Rara o mejor, el servidor manda Remotos.Forja("Empieza"): aparece una
-- silueta negra que se acerca girando y cambia entre las piedras de la zona. Abajo, las monedas
-- "?" y el botón verde "¡Intentar!": cada toque pide un intento al servidor (Remotos.ForjaIntentar),
-- la silueta gira con suspenso y, cuando llega el "Resultado", se festeja (subió, efecto o nada).
-- Sin monedas (o con "Listo"), la silueta gira cada vez más rápido, destello, y sale la tarjeta
-- de la gema (Revelacion.client espera mientras el atributo EnForja del jugador está en true).
-- El cliente nunca tira: solo muestra lo que contesta el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local RemotoForja = remotos:WaitForChild("Forja") :: RemoteEvent
local Intentar = remotos:WaitForChild("ForjaIntentar") :: RemoteEvent
local Listo = remotos:WaitForChild("ForjaListo") :: RemoteEvent

type Estado = {
	Id: number,
	Gema: string,
	Rareza: string,
	Efecto: string?,
	Quedan: number,
	Guardadas: number,
	UnoEn: number,
	Zona: number,
	Resultado: string?,
}

local rng = Random.new()
local S = GameConfig.Sonidos

-- Pantalla --------------------------------------------------------------------------------

local pantalla = Estilo.pantalla("Forja", 14)
pantalla.Enabled = false
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local fondo = Instance.new("Frame")
fondo.Size = UDim2.fromScale(1, 1)
fondo.BackgroundColor3 = Color3.fromHex("#0B0816")
fondo.BackgroundTransparency = 0.35
fondo.BorderSizePixel = 0
fondo.Parent = pantalla

local destello = Instance.new("Frame")
destello.Size = UDim2.fromScale(1, 1)
destello.BackgroundColor3 = Color3.new(1, 1, 1)
destello.BackgroundTransparency = 1
destello.BorderSizePixel = 0
destello.ZIndex = 20
destello.Parent = pantalla

-- todo lo demás, diseñado a 1280x720 y escalado a la pantalla
local lienzo = Instance.new("Frame")
lienzo.AnchorPoint = Vector2.new(0.5, 0.5)
lienzo.Position = UDim2.fromScale(0.5, 0.5)
lienzo.Size = UDim2.fromOffset(1280, 720)
lienzo.BackgroundTransparency = 1
lienzo.Parent = pantalla
Estilo.escalar(lienzo)
local CENTRO = UDim2.fromOffset(640, 300)

-- rayos que giran detrás
local rayos = Instance.new("Frame")
rayos.AnchorPoint = Vector2.new(0.5, 0.5)
rayos.Position = CENTRO
rayos.Size = UDim2.fromOffset(10, 10)
rayos.BackgroundTransparency = 1
rayos.Parent = lienzo
local listaRayos: { Frame } = {}
for i = 1, 14 do
	local r = Instance.new("Frame")
	r.AnchorPoint = Vector2.new(0.5, 1)
	r.Position = UDim2.fromScale(0.5, 0.5)
	r.Size = UDim2.fromOffset(70, 620)
	r.Rotation = i * 360 / 14
	r.BorderSizePixel = 0
	r.BackgroundTransparency = 0.9
	local deg = Instance.new("UIGradient")
	deg.Rotation = 90
	deg.Transparency = NumberSequence.new(1, 0)
	deg.Parent = r
	r.Parent = rayos
	table.insert(listaRayos, r)
end

-- la silueta: el dibujo de la piedra en negro, con un borde de luz del color de su rareza
local luz = Instance.new("ImageLabel")
luz.AnchorPoint = Vector2.new(0.5, 0.5)
luz.Position = CENTRO
luz.Size = UDim2.fromOffset(300, 300)
luz.BackgroundTransparency = 1
luz.ScaleType = Enum.ScaleType.Fit
luz.ImageTransparency = 0.25
luz.Parent = lienzo
local silueta = luz:Clone()
silueta.Size = UDim2.fromOffset(270, 270)
silueta.ImageColor3 = Color3.new(0, 0, 0)
silueta.ImageTransparency = 0
silueta.Parent = lienzo

local cartel = Estilo.texto("", 40)
cartel.AnchorPoint = Vector2.new(0.5, 0)
cartel.Position = UDim2.fromOffset(640, 40)
cartel.Parent = lienzo

local aviso = Estilo.texto("", 64)
aviso.AnchorPoint = Vector2.new(0.5, 0.5)
aviso.Position = UDim2.fromOffset(640, 500)
aviso.Visible = false
aviso.Parent = lienzo
local escalaAviso = Instance.new("UIScale")
escalaAviso.Parent = aviso

local monedas = Instance.new("Frame")
monedas.AnchorPoint = Vector2.new(0.5, 0)
monedas.Position = UDim2.fromOffset(640, 560)
monedas.Size = UDim2.fromOffset(600, 54)
monedas.BackgroundTransparency = 1
monedas.Parent = lienzo
local filaMonedas = Instance.new("UIListLayout")
filaMonedas.FillDirection = Enum.FillDirection.Horizontal
filaMonedas.HorizontalAlignment = Enum.HorizontalAlignment.Center
filaMonedas.VerticalAlignment = Enum.VerticalAlignment.Center
filaMonedas.Padding = UDim.new(0, 10)
filaMonedas.Parent = monedas

local boton = Estilo.boton({ Texto = "¡Intentar!", Color = "Verde", Ancho = 300, Alto = 84 })
boton.AnchorPoint = Vector2.new(0.5, 0)
boton.Position = UDim2.fromOffset(640, 626)
boton.Parent = lienzo
local escalaBoton = Instance.new("UIScale")
escalaBoton.Parent = boton

local listo = Estilo.boton({ Texto = "Listo", Color = "Gris", Ancho = 150, Alto = 64 })
listo.AnchorPoint = Vector2.new(0, 0)
listo.Position = UDim2.fromOffset(820, 636)
listo.Parent = lienzo

-- Partículas de pantalla (cuadraditos y puntos) -------------------------------------------

type Chispa = { Obj: Frame, X: number, Y: number, VX: number, VY: number, Vida: number }
local chispas: { Chispa } = {}

local function soltarChispas(cantidad: number, color: Color3, fuerza: number)
	if Efectos.reducidos() then
		cantidad = math.ceil(cantidad / 3)
	end
	for _ = 1, cantidad do
		local f = Instance.new("Frame")
		local tam = rng:NextInteger(8, 18)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = UDim2.fromOffset(tam, tam)
		f.BackgroundColor3 = if rng:NextNumber() < 0.3 then Color3.new(1, 1, 1) else color
		f.BorderSizePixel = 0
		f.Rotation = rng:NextNumber(0, 90)
		f.ZIndex = 10
		f.Parent = lienzo
		local a = rng:NextNumber(0, math.pi * 2)
		local v = fuerza * rng:NextNumber(0.3, 1)
		table.insert(chispas, {
			Obj = f,
			X = 640,
			Y = 300,
			VX = math.cos(a) * v,
			VY = math.sin(a) * v - fuerza * 0.4,
			Vida = 1,
		})
	end
end

-- Estado de la escena ---------------------------------------------------------------------

local actual: Estado? = nil
local fase = "nada" -- "acerca" | "espera" | "tirando" | "final"
local tFase = 0
local giro = 0
local velocidad = 2
local formas: { string } = {} -- dibujos de las piedras de la zona (para cambiar de silueta)
local forma = 1
local pendiente: Estado? = nil -- resultado que llegó mientras gira el suspenso
local temblor = 0

local function colorRareza(id: string): Color3
	local r = Reglas.rareza(id)
	return Color3.fromHex(if r then r.Color else "#FFFFFF")
end

local function dibujo(id: string): string
	return (GameConfig.IconosGemas :: { [string]: string })[id] or ""
end

local function pintarMonedas(e: Estado)
	for _, h in monedas:GetChildren() do
		if h:IsA("GuiObject") then
			h:Destroy()
		end
	end
	for i = 1, e.Quedan do
		local m = Estilo.texto("?", 34, Color3.fromHex("#5A3D00"))
		m.Size = UDim2.fromOffset(50, 50)
		m.BackgroundTransparency = 0
		m.BackgroundColor3 = Color3.fromHex("#FFCF3F")
		Estilo.esquinas(m, 25)
		Estilo.borde(m, 3, Color3.fromHex("#7A5A00"))
		m.LayoutOrder = i
		m.Parent = monedas
	end
	if e.Guardadas > 0 then
		local g = Estilo.texto("+" .. e.Guardadas .. " guardadas", 26, Color3.fromHex("#FFE14D"))
		g.LayoutOrder = 99
		g.Parent = monedas
	end
	local puede = e.Quedan + e.Guardadas > 0 and fase == "espera"
	Estilo.colorBoton(boton, if puede then "Verde" else "Gris")
	boton.Active = puede
end

local function ponerCartel(e: Estado)
	local r = Reglas.rareza(e.Rareza)
	local ef = if e.Efecto then Reglas.efectoForja(e.Efecto) else nil
	cartel.Text = (if r then r.Nombre else e.Rareza)
		.. (if ef then " · " .. ef.Nombre else "")
		.. " · "
		.. Formato.unoEn(e.UnoEn)
	cartel.TextColor3 = colorRareza(e.Rareza)
	luz.ImageColor3 = if ef then Color3.fromHex(ef.Color) else colorRareza(e.Rareza)
	for _, r2 in listaRayos do
		r2.BackgroundColor3 = luz.ImageColor3
	end
end

local function mostrarAviso(texto: string, color: Color3)
	aviso.Text = texto
	aviso.TextColor3 = color
	aviso.Visible = true
	escalaAviso.Scale = 0.3
	TweenService:Create(
		escalaAviso,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	task.delay(1.2, function()
		if aviso.Text == texto then
			aviso.Visible = false
		end
	end)
end

local function flash(color: Color3, fuerza: number)
	destello.BackgroundColor3 = color
	destello.BackgroundTransparency = 1 - (if Efectos.reducidos() then fuerza * 0.3 else fuerza)
	TweenService:Create(destello, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
end

local function cerrar()
	pantalla.Enabled = false
	fase = "nada"
	actual = nil
	pendiente = nil
	for _, c in chispas do
		c.Obj:Destroy()
	end
	chispas = {}
	jugador:SetAttribute("EnForja", false)
end

local function irAlFinal()
	if fase == "final" or not actual then
		return
	end
	fase = "final"
	tFase = 0
	boton.Visible = false
	listo.Visible = false
	cartel.Text = "¡Forjando!"
end

-- El resultado que mandó el servidor, mostrado cuando termina el suspenso.
local function festejar(e: Estado)
	local anterior = actual
	actual = e
	ponerCartel(e)
	if e.Resultado == "Sube" then
		local r = Reglas.rareza(e.Rareza)
		local c = colorRareza(e.Rareza)
		-- SONIDO: la piedra sube de rareza
		Sonidos.tocar(S.ForjaSube, 1)
		flash(c, 0.8)
		temblor = 16
		soltarChispas(50, c, 900)
		mostrarAviso("¡SUBIÓ A " .. string.upper(if r then r.Nombre else e.Rareza) .. "!", c)
	elseif e.Resultado == "Efecto" and e.Efecto then
		local ef = Reglas.efectoForja(e.Efecto)
		local c = if ef then Color3.fromHex(ef.Color) else Color3.new(1, 1, 1)
		-- SONIDO: la piedra gana un efecto
		Sonidos.tocar(S.ForjaEfecto, 1)
		flash(c, 0.7)
		temblor = 12
		soltarChispas(45, c, 800)
		mostrarAviso("¡EFECTO " .. string.upper(if ef then ef.Nombre else e.Efecto) .. "!", c)
	else
		mostrarAviso("Casi…", Color3.fromHex("#A99CC4"))
	end
	fase = "espera"
	tFase = 0
	pintarMonedas(e)
	if e.Quedan + e.Guardadas <= 0 then
		task.delay(1.1, function()
			if actual == e and fase == "espera" then
				irAlFinal()
			end
		end)
	end
	if anterior and anterior.Gema ~= e.Gema then
		silueta.Image = dibujo(e.Gema)
		luz.Image = silueta.Image
	end
end

local function empezar(e: Estado)
	actual = e
	jugador:SetAttribute("EnForja", true)
	formas = {}
	for _, r in GameConfig.Rarezas do
		for _, g in Reglas.gemasDe(e.Zona, r.Id) do
			local img = dibujo(g.Id)
			if img ~= "" then
				table.insert(formas, img)
			end
		end
	end
	if #formas == 0 then
		formas = { dibujo(e.Gema) }
	end
	silueta.Image = dibujo(e.Gema)
	luz.Image = silueta.Image
	ponerCartel(e)
	aviso.Visible = false
	boton.Visible = false
	listo.Visible = false
	monedas.Visible = false
	fase = "acerca"
	tFase = 0
	giro = 0
	-- espera que la geoda se infle y explote (Geodas.client) antes de mostrarse
	task.delay(if Efectos.reducidos() then 0.2 else GameConfig.Efectos.InflaDuracion, function()
		if actual == e then
			pantalla.Enabled = true
			flash(Color3.new(1, 1, 1), 0.9)
			-- SONIDO: la geoda explota
			Sonidos.tocar(S.ForjaExplota, 1)
			soltarChispas(60, Color3.new(1, 1, 1), 1100)
			tFase = 0
		end
	end)
end

boton.Activated:Connect(function()
	local e = actual
	if not e or fase ~= "espera" or e.Quedan + e.Guardadas <= 0 then
		return
	end
	Intentar:FireServer(e.Id)
	fase = "tirando"
	tFase = 0
	pendiente = nil
	velocidad = if Efectos.reducidos() then 6 else 18
	escalaBoton.Scale = 0.85
	TweenService:Create(escalaBoton, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 })
		:Play()
	-- la moneda que se gasta salta y se va
	local primera = monedas:FindFirstChildWhichIsA("TextLabel")
	if primera then
		primera:Destroy()
	end
	soltarChispas(14, Color3.fromHex("#FFCF3F"), 500)
	-- SONIDO: apretar "¡Intentar!"
	Sonidos.tocar(S.ForjaIntento, 1.2)
	Estilo.colorBoton(boton, "Gris")
end)

listo.Activated:Connect(irAlFinal)

RemotoForja.OnClientEvent:Connect(function(tipo: string, e: Estado)
	if typeof(e) ~= "table" then
		return
	end
	if tipo == "Empieza" then
		empezar(e)
	elseif tipo == "Resultado" then
		if actual and actual.Id == e.Id then
			pendiente = e
		end
	elseif tipo == "Fin" then
		-- el servidor ya la entregó (venció o se rompió otra): si quedaba algo, se cierra
		if actual and actual.Id == e.Id and fase ~= "final" then
			cerrar()
		end
	end
end)

-- Un solo bucle para animar todo ----------------------------------------------------------

RunService.RenderStepped:Connect(function(dt: number)
	if not pantalla.Enabled then
		return
	end
	tFase += dt
	local reducidos = Efectos.reducidos()
	local escala = 1
	if fase == "acerca" then
		-- se acerca girando y cambiando de forma
		local u = math.min(1, tFase / 1.3)
		escala = 0.15 + 0.85 * (1 - (1 - u) ^ 3)
		giro += dt * (10 - 6 * u)
		local n = math.floor(tFase * 7) % #formas + 1
		if n ~= forma then
			forma = n
			silueta.Image = formas[n]
			luz.Image = formas[n]
		end
		if u >= 1 and actual then
			silueta.Image = dibujo(actual.Gema)
			luz.Image = silueta.Image
			fase = "espera"
			tFase = 0
			monedas.Visible = true
			boton.Visible = true
			listo.Visible = true
			temblor = 8
			pintarMonedas(actual)
		end
	elseif fase == "espera" then
		velocidad += (1.6 - velocidad) * math.min(1, dt * 3)
		giro += dt * velocidad
		escala = 1 + 0.04 * math.sin(os.clock() * 4)
		escalaBoton.Scale = 1 + 0.05 * math.sin(os.clock() * 6)
	elseif fase == "tirando" then
		-- suspenso: gira rápido y cambia de forma cada vez más lento
		local u = math.min(1, tFase / 1.2)
		velocidad = (if reducidos then 6 else 18) * (1 - u) + 1.5
		giro += dt * velocidad
		local n = math.floor(tFase * (14 - 10 * u)) % #formas + 1
		if n ~= forma then
			forma = n
			silueta.Image = formas[n]
			-- SONIDO: tic del suspenso (sube de tono)
			Sonidos.tocar(S.ForjaIntento, 0.8 + u * 0.8, 0.3)
		end
		escala = 1.05 + 0.1 * u
		if u >= 1 and pendiente then
			local e = pendiente
			pendiente = nil
			silueta.Image = dibujo(e.Gema)
			festejar(e)
		end
	elseif fase == "final" then
		-- gira cada vez más rápido, se agranda y se aclara; destello y sale la tarjeta
		local u = math.min(1, tFase / 1.6)
		giro += dt * (3 + (if reducidos then 12 else 45) * u * u)
		escala = 1 + 0.25 * u
		silueta.ImageColor3 = Color3.new(u * u, u * u, u * u)
		if u >= 1 and actual then
			local e = actual
			flash(colorRareza(e.Rareza), 1)
			soltarChispas(80, colorRareza(e.Rareza), 1300)
			Listo:FireServer(e.Id)
			silueta.ImageColor3 = Color3.new(0, 0, 0)
			task.delay(0.15, cerrar)
			fase = "cerrando"
		end
	end
	-- girar = achicar el ancho con el coseno (como una moneda)
	local ancho = math.abs(math.cos(giro))
	silueta.Size = UDim2.fromOffset(270 * escala * ancho, 270 * escala)
	luz.Size = UDim2.fromOffset(300 * escala * ancho, 300 * escala)
	rayos.Rotation += dt * (if fase == "tirando" or fase == "final" then 90 else 20)
	-- temblor del lienzo
	if temblor > 0.3 and not reducidos then
		lienzo.Position = UDim2.new(
			0.5,
			rng:NextNumber(-temblor, temblor),
			0.5,
			rng:NextNumber(-temblor, temblor)
		)
		temblor *= 0.86
	else
		lienzo.Position = UDim2.fromScale(0.5, 0.5)
	end
	-- chispas
	for i = #chispas, 1, -1 do
		local c = chispas[i]
		c.X += c.VX * dt
		c.Y += c.VY * dt
		c.VY += 1400 * dt
		c.Vida -= dt * 1.4
		c.Obj.Position = UDim2.fromOffset(c.X, c.Y)
		c.Obj.BackgroundTransparency = 1 - math.max(0, c.Vida)
		c.Obj.Rotation += dt * 300
		if c.Vida <= 0 then
			c.Obj:Destroy()
			table.remove(chispas, i)
		end
	end
end)
