--!strict
-- Revelación de la gema (Grupo 1): llega del servidor cuando rompés una geoda, con la gema ya
-- guardada en tu mochila. Según qué tan especial es:
--   Común (y geoda normal): un cartelito corto abajo, sin cortar el juego.
--   Rara o mejor, o geoda exótica: la geoda tiembla, destello blanco, temblor de cámara y la
--   gema en grande con rayos, su rareza, cuántas son, el cartel de suerte ("🍀 x2,06 Suerte ·
--   1 en 194") y "¡NUEVA!" si es la primera vez.
--   Después, en fila: colecciones y logros que se completaron con esa gema (descubrimiento en
--   cadena), cada uno con su premio.
-- Con "Efectos reducidos" no hay destello ni temblor y la tarjeta es más simple.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Avisos = require(script.Parent.Avisos)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local RemotoRevelacion = remotos:WaitForChild("Revelacion") :: RemoteEvent
local E = GameConfig.Efectos
local rng = Random.new()

local pantalla = Estilo.pantalla("Revelacion", 15)
pantalla.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local blanco = Instance.new("Frame")
blanco.Name = "Destello"
blanco.Size = UDim2.fromScale(1, 1)
blanco.BackgroundColor3 = Color3.new(1, 1, 1)
blanco.BackgroundTransparency = 1
blanco.ZIndex = 10
blanco.Parent = pantalla

local function indiceRareza(id: string): number
	for i, r in GameConfig.Rarezas do
		if r.Id == id then
			return i
		end
	end
	return 1
end

-- Lo que llega del servidor (GeodeServerService.Revelacion).
type Hito = {
	Nombre: string,
	Descripcion: string,
	Monedas: number?,
	Suerte: number?,
	Coleccion: boolean,
}
type Datos = {
	Geoda: Model?,
	Gema: string,
	Rareza: string,
	Unidades: number,
	Modificador: string,
	Suerte: number,
	UnoEn: number,
	Nueva: boolean,
	Hitos: { Hito }?,
}

-- Efectos de pantalla -----------------------------------------------------------------------

local function temblarGeoda(geoda: Model?, duracion: number)
	if not geoda or not geoda.Parent then
		return
	end
	local original = geoda:GetPivot()
	local fin = os.clock() + duracion
	while os.clock() < fin and geoda.Parent do
		local fuerza = 0.05 + 0.25 * (1 - (fin - os.clock()) / duracion)
		geoda:PivotTo(
			original
				* CFrame.new(rng:NextNumber(-fuerza, fuerza), 0, rng:NextNumber(-fuerza, fuerza))
		)
		RunService.RenderStepped:Wait()
	end
	if geoda.Parent then
		geoda:PivotTo(original)
	end
end

local function destelloBlanco()
	blanco.BackgroundTransparency = 1
	TweenService:Create(blanco, TweenInfo.new(0.12), { BackgroundTransparency = 0.05 }):Play()
	task.delay(0.2, function()
		TweenService:Create(blanco, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
	end)
	local luz = Instance.new("ColorCorrectionEffect")
	luz.Brightness = 0.35
	luz.Parent = Lighting
	TweenService:Create(luz, TweenInfo.new(0.8), { Brightness = 0 }):Play()
	task.delay(0.9, function()
		luz:Destroy()
	end)
end

local function temblarCamara(duracion: number, fuerza: number)
	local fin = os.clock() + duracion
	local nombre = "TemblorRevelacion"
	RunService:BindToRenderStep(nombre, Enum.RenderPriority.Camera.Value + 1, function()
		local camara = Workspace.CurrentCamera
		local queda = fin - os.clock()
		if not camara or queda <= 0 then
			RunService:UnbindFromRenderStep(nombre)
			return
		end
		local f = fuerza * queda / duracion
		camara.CFrame *= CFrame.new(rng:NextNumber(-f, f), rng:NextNumber(-f, f), 0)
	end)
end

-- Tarjeta de la gema --------------------------------------------------------------------------

local function chip(texto: string, color: Color3): Frame
	local f = Instance.new("Frame")
	f.AutomaticSize = Enum.AutomaticSize.XY
	f.Size = UDim2.fromOffset(0, 0)
	f.BackgroundColor3 = color
	Estilo.esquinas(f, 14)
	Estilo.borde(f, 3)
	local relleno = Instance.new("UIPadding")
	relleno.PaddingLeft, relleno.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
	relleno.PaddingTop, relleno.PaddingBottom = UDim.new(0, 4), UDim.new(0, 6)
	relleno.Parent = f
	Estilo.texto(texto, 24).Parent = f
	return f
end

local function tarjeta(d: Datos, reducidos: boolean)
	local gema = Reglas.gema(d.Gema)
	local rareza = Reglas.rareza(d.Rareza)
	local mod = Reglas.modificador(d.Modificador)
	if not gema or not rareza then
		return
	end
	local colorRareza = Color3.fromHex(rareza.Color)
	local colorGema = Color3.fromHex(gema.Color)
	local mitica = d.Rareza == "Mitico"

	local raiz = Instance.new("Frame")
	raiz.AnchorPoint = Vector2.new(0.5, 0.5)
	raiz.Position = UDim2.fromScale(0.5, 0.45)
	raiz.Size = UDim2.fromOffset(520, 520)
	raiz.BackgroundTransparency = 1
	raiz.Parent = pantalla
	local escala = Instance.new("UIScale")
	escala.Scale = 0.2
	escala.Parent = raiz

	-- rayos que giran detrás de la gema (arcoíris para las míticas)
	local rayos = Instance.new("Frame")
	rayos.AnchorPoint = Vector2.new(0.5, 0.5)
	rayos.Position = UDim2.fromScale(0.5, 0.38)
	rayos.Size = UDim2.fromOffset(460, 460)
	rayos.BackgroundTransparency = 1
	rayos.Parent = raiz
	for i = 1, if reducidos then 0 else 10 do
		local r = Instance.new("Frame")
		r.AnchorPoint = Vector2.new(0.5, 0.5)
		r.Position = UDim2.fromScale(0.5, 0.5)
		r.Size = UDim2.fromOffset(46, 460)
		r.Rotation = i * 18
		r.BackgroundColor3 = if mitica then Color3.fromHSV(i / 10, 0.7, 1) else colorRareza
		r.BackgroundTransparency = 0.55
		r.BorderSizePixel = 0
		local degradado = Instance.new("UIGradient")
		degradado.Rotation = 90
		degradado.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		degradado.Parent = r
		r.Parent = rayos
	end

	-- la gema: un rombo del color de la gema, con brillo y borde
	local piedra = Instance.new("Frame")
	piedra.AnchorPoint = Vector2.new(0.5, 0.5)
	piedra.Position = UDim2.fromScale(0.5, 0.38)
	piedra.Size = UDim2.fromOffset(150, 150)
	piedra.Rotation = 45
	piedra.BackgroundColor3 = colorGema
	Estilo.esquinas(piedra, 22)
	Estilo.borde(piedra, 6)
	local brillo = Instance.new("UIGradient")
	brillo.Rotation = -45
	brillo.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.35, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.36, Color3.fromHex("#DDDDDD")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#888888")),
	})
	brillo.Parent = piedra
	piedra.Parent = raiz

	-- textos
	local lista = Instance.new("Frame")
	lista.AnchorPoint = Vector2.new(0.5, 0)
	lista.Position = UDim2.fromScale(0.5, 0.66)
	lista.AutomaticSize = Enum.AutomaticSize.XY
	lista.Size = UDim2.fromOffset(0, 0)
	lista.BackgroundTransparency = 1
	lista.Parent = raiz
	local orden = Instance.new("UIListLayout")
	orden.HorizontalAlignment = Enum.HorizontalAlignment.Center
	orden.SortOrder = Enum.SortOrder.LayoutOrder
	orden.Padding = UDim.new(0, 6)
	orden.Parent = lista
	local titulo = Estilo.texto(
		"¡" .. rareza.Nombre:upper() .. "!",
		if mitica then 72 else 60,
		colorRareza,
		6
	)
	titulo.LayoutOrder = 1
	titulo.Parent = lista
	local nombre = Estilo.texto(gema.Nombre .. "  x" .. Formato.corto(d.Unidades), 36)
	nombre.LayoutOrder = 2
	nombre.Parent = lista
	local fila = Instance.new("Frame")
	fila.LayoutOrder = 3
	fila.AutomaticSize = Enum.AutomaticSize.XY
	fila.Size = UDim2.fromOffset(0, 0)
	fila.BackgroundTransparency = 1
	local enFila = Instance.new("UIListLayout")
	enFila.FillDirection = Enum.FillDirection.Horizontal
	enFila.Padding = UDim.new(0, 10)
	enFila.Parent = fila
	fila.Parent = lista
	chip(
		"🍀 " .. Formato.suerte(d.Suerte) .. " Suerte · " .. Formato.unoEn(d.UnoEn),
		Color3.fromHex("#2DBA2D")
	).Parent =
		fila
	if mod and Reglas.esExotica(mod.Id) then
		local texto = Estilo.icono(Reglas.partes(mod.Id)) .. " " .. mod.Nombre .. " x" .. mod.Premio
		chip(texto, Color3.fromHex(mod.Color)).Parent = fila
	end
	if d.Nueva then
		local nueva = chip("¡NUEVA EN EL ÍNDICE!", Color3.fromHex("#FFC93C"))
		nueva.LayoutOrder = 4
		nueva.Parent = lista
	end

	-- aparece de golpe, gira los rayos y se va
	TweenService:Create(
		escala,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	local girar = RunService.RenderStepped:Connect(function(dt: number)
		rayos.Rotation += dt * 40
	end)
	local duracion = E.DuracionRevelacion + (if mitica then 1 else 0)
	task.wait(duracion)
	TweenService:Create(escala, TweenInfo.new(0.2), { Scale = 0 }):Play()
	task.wait(0.22)
	girar:Disconnect()
	raiz:Destroy()
end

-- La común: un cartelito abajo que sube y se va.
local function cartelito(d: Datos)
	local gema = Reglas.gema(d.Gema)
	if not gema then
		return
	end
	local t = Estilo.texto(
		"+" .. Formato.corto(d.Unidades) .. " " .. gema.Nombre,
		34,
		Color3.fromHex(gema.Color)
	)
	t.AnchorPoint = Vector2.new(0.5, 1)
	t.Position = UDim2.fromScale(0.5, 0.78)
	t.Parent = pantalla
	TweenService:Create(t, TweenInfo.new(E.DuracionComun, Enum.EasingStyle.Quad), {
		Position = UDim2.fromScale(0.5, 0.7),
		TextTransparency = 1,
	}):Play()
	local trazo = t:FindFirstChildOfClass("UIStroke")
	if trazo then
		TweenService:Create(trazo, TweenInfo.new(E.DuracionComun), { Transparency = 1 }):Play()
	end
	task.delay(E.DuracionComun + 0.1, function()
		t:Destroy()
	end)
end

-- Hitos de la cadena: colecciones y logros, en fila después de la gema.
local function hitos(lista: { Hito })
	for _, h in lista do
		local premio = {}
		if h.Monedas then
			table.insert(premio, "+" .. Formato.corto(h.Monedas) .. " Monedas")
		end
		if h.Suerte then
			table.insert(premio, "+" .. Formato.suerte(h.Suerte):sub(2) .. " Suerte para siempre")
		end
		-- SONIDO: logro o colección completada
		Sonidos.tocar(GameConfig.Sonidos.Logro, if h.Coleccion then 1.1 else 1)
		Avisos.mostrar({
			Titulo = if h.Coleccion then "¡Colección completa!" else "¡Logro desbloqueado!",
			Texto = h.Nombre .. " · " .. table.concat(premio, " · "),
			Color = Color3.fromHex(if h.Coleccion then "#B04DFF" else "#FFC93C"),
			Duracion = 3,
		})
	end
end

local cola: { Datos } = {}
local ocupado = false

local function procesar(d: Datos)
	local reducidos = Efectos.reducidos()
	local nivel = indiceRareza(d.Rareza)
	local exotica = Reglas.esExotica(d.Modificador)
	local grande = exotica or nivel >= indiceRareza(E.DestelloDesde)
	-- SONIDO: revelación (más agudo cuanto más rara)
	Sonidos.tocar(GameConfig.Sonidos.Revelacion, 0.9 + nivel * 0.1)
	if not grande then
		cartelito(d)
		task.wait(0.15) -- si se juntan varias comunes, salen escalonadas
	else
		if not reducidos then
			temblarGeoda(d.Geoda, 0.35)
			destelloBlanco()
			temblarCamara(0.4, E.TemblorCamara * (if nivel >= 4 then 1.6 else 1))
		end
		if nivel >= indiceRareza("Epico") then
			-- SONIDO: extra para Épica o mejor
			Sonidos.tocar(GameConfig.Sonidos.RevelacionRara, 1)
		end
		tarjeta(d, reducidos)
	end
	if d.Hitos and #d.Hitos > 0 then
		hitos(d.Hitos)
	end
end

RemotoRevelacion.OnClientEvent:Connect(function(d: Datos)
	if typeof(d) ~= "table" then
		return
	end
	table.insert(cola, d)
	if ocupado then
		return
	end
	ocupado = true
	task.spawn(function()
		while #cola > 0 do
			procesar(table.remove(cola, 1) :: Datos)
		end
		ocupado = false
	end)
end)
