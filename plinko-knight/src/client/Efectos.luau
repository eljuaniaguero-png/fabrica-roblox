--!strict
-- Sensación (etapa 10): lo que hace que cada tiro se sienta. Números en Config.Feel.
--   chispas(pos, color)  chispitas que vuelan de una clavija tocada
--   aplastar(parte)      la clavija se aplasta y vuelve
--   bordeRojo()          borde rojo en la pantalla cuando te pegan
--   entradaJefe(nombre)  pantalla oscura con el nombre del jefe
-- Con "Efectos reducidos" (Ajustes) salen la mitad de las chispas; los temblores y el hit-stop los
-- apaga quien los usa (Ajustes.factorEfectos() = 0).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))
local Estilo = require(script.Parent:WaitForChild("Estilo"))

local Efectos = {}

local F = Config.Feel

local carpeta = Instance.new("Folder")
carpeta.Name = "Efectos"
carpeta.Parent = Workspace

function Efectos.chispas(pos: Vector3, color: Color3)
	local cantidad = F.Chispas
	if Ajustes.efectosReducidos() then
		cantidad = math.ceil(cantidad / 2)
	end
	for i = 1, cantidad do
		local c = Instance.new("Part")
		c.Name = "Chispa"
		c.Shape = Enum.PartType.Ball
		c.Size = Vector3.new(0.35, 0.35, 0.35)
		c.Material = Enum.Material.Neon
		c.Color = color
		c.Anchored = true
		c.CanCollide = false
		c.CanTouch = false
		c.CanQuery = false
		c.CastShadow = false
		c.Position = pos + Vector3.new(0, 0, 0.8)
		c.Parent = carpeta
		local angulo = (i / cantidad) * math.pi * 2 + math.random() * 0.8
		local destino = c.Position
			+ Vector3.new(math.cos(angulo), math.sin(angulo), 0) * F.ChispasDistancia * (0.6 + math.random() * 0.6)
		local t = TweenService:Create(
			c,
			TweenInfo.new(F.ChispasDuracion, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = destino, Size = Vector3.new(0.05, 0.05, 0.05), Transparency = 0.6 }
		)
		t:Play()
		t.Completed:Once(function()
			c:Destroy()
		end)
	end
end

-- La clavija se achica de golpe y vuelve (una sola vez aunque la toquen seguido).
local aplastando: { [BasePart]: Vector3 } = {}
function Efectos.aplastar(parte: BasePart)
	local original = aplastando[parte] or parte.Size
	aplastando[parte] = original
	parte.Size = original * F.AplastarCuanto
	local t = TweenService:Create(
		parte,
		TweenInfo.new(F.Aplastar, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = original }
	)
	t:Play()
	t.Completed:Once(function()
		if parte.Size == original then
			aplastando[parte] = nil
		end
	end)
end

-- Pantallas: borde rojo y entrada del jefe (arriba de todo, sin márgenes).
local gui = Instance.new("ScreenGui")
gui.Name = "Efectos"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ScreenInsets = Enum.ScreenInsets.None
gui.DisplayOrder = 45
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local borde = Instance.new("Frame")
borde.Name = "BordeRojo"
borde.Size = UDim2.fromScale(1, 1)
borde.BackgroundTransparency = 1
borde.Parent = gui
local trazo = Instance.new("UIStroke")
trazo.Thickness = 28
trazo.Color = Color3.fromHex(Config.Colores.Golpe)
trazo.Transparency = 1
trazo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
trazo.Parent = borde

function Efectos.bordeRojo()
	trazo.Transparency = 0.15
	TweenService:Create(trazo, TweenInfo.new(F.BordeRojo), { Transparency = 1 }):Play()
end

local oscuro = Estilo.velo(gui, 1)
oscuro.Name = "EntradaJefe"
oscuro.Active = false
local lienzo = Instance.new("Frame")
lienzo.Size = UDim2.fromScale(1, 1)
lienzo.BackgroundTransparency = 1
lienzo.Parent = gui
local nombreJefe = Estilo.texto(lienzo, "", Estilo.Texto.Titulo)
nombreJefe.AnchorPoint = Vector2.new(0.5, 0.5)
nombreJefe.Position = UDim2.fromScale(0.5, 0.45)
nombreJefe.Size = UDim2.fromScale(0.9, 0.2)
nombreJefe.TextScaled = true
nombreJefe.TextColor3 = Color3.fromHex(Config.Colores.Golpe)
nombreJefe.TextTransparency = 1
nombreJefe.TextStrokeTransparency = 1
local escalaJefe = Instance.new("UIScale")
escalaJefe.Parent = nombreJefe

function Efectos.entradaJefe(nombre: string)
	nombreJefe.Text = ("¡%s!"):format(nombre)
	oscuro.BackgroundTransparency = 0.25
	nombreJefe.TextTransparency = 0
	nombreJefe.TextStrokeTransparency = 0
	escalaJefe.Scale = 1.6
	TweenService:Create(escalaJefe, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()
	task.delay(F.JefeOscuro, function()
		local info = TweenInfo.new(0.3)
		TweenService:Create(oscuro, info, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(nombreJefe, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end)
end

-- 27/10 "más dopamina" ----------------------------------------------------------------------

-- Anillo de luz que se abre desde una clavija tocada (un cilindro finito mirando a la cámara).
function Efectos.onda(pos: Vector3, color: Color3, grande: boolean?)
	local tam = F.OndaTamanio * (if grande then 2 else 1)
	local o = Instance.new("Part")
	o.Name = "Onda"
	o.Shape = Enum.PartType.Cylinder
	o.Size = Vector3.new(0.05, 0.6, 0.6)
	o.CFrame = CFrame.new(pos + Vector3.new(0, 0, -0.2)) * CFrame.Angles(0, math.rad(90), 0)
	o.Material = Enum.Material.Neon
	o.Color = color
	o.Transparency = 0.15
	o.Anchored = true
	o.CanCollide = false
	o.CanTouch = false
	o.CanQuery = false
	o.CastShadow = false
	o.Parent = carpeta
	local t = TweenService:Create(
		o,
		TweenInfo.new(F.Onda * (if grande then 1.6 else 1), Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.05, tam, tam), Transparency = 1 }
	)
	t:Play()
	t.Completed:Once(function()
		o:Destroy()
	end)
end

-- Estallido de partículas (confeti, monedas, chispas): un emisor que se usa y se borra.
function Efectos.estallido(pos: Vector3, colores: { Color3 }, cantidad: number, fuerza: number?)
	if Ajustes.efectosReducidos() then
		cantidad = math.ceil(cantidad / 2)
	end
	local ancla = Instance.new("Part")
	ancla.Name = "Estallido"
	ancla.Size = Vector3.new(0.2, 0.2, 0.2)
	ancla.Transparency = 1
	ancla.Anchored = true
	ancla.CanCollide = false
	ancla.CanTouch = false
	ancla.CanQuery = false
	ancla.Position = pos + Vector3.new(0, 0, 1)
	ancla.Parent = carpeta
	local puntos = {}
	for i, c in colores do
		table.insert(puntos, ColorSequenceKeypoint.new((i - 1) / math.max(#colores - 1, 1), c))
	end
	if #puntos == 1 then
		table.insert(puntos, ColorSequenceKeypoint.new(1, colores[1]))
	end
	local f = fuerza or 1
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(puntos)
	e.LightEmission = 1
	e.Brightness = 2
	e.Lifetime = NumberRange.new(0.6, 1.1)
	e.Speed = NumberRange.new(14 * f, 26 * f)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Acceleration = Vector3.new(0, -40 * f, 0)
	e.Drag = 2
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-300, 300)
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.8 * f),
		NumberSequenceKeypoint.new(0.7, 1.4 * f),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Squash = NumberSequence.new(0.3)
	e.Parent = ancla
	e:Emit(cantidad)
	task.delay(1.4, function()
		ancla:Destroy()
	end)
end

-- Destello de toda la pantalla (del color que se pase). Nada con efectos reducidos.
local flash = Instance.new("Frame")
flash.Name = "Destello"
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 0
flash.Parent = gui
function Efectos.destello(color: Color3?, fuerza: number?)
	if Ajustes.efectosReducidos() then
		return
	end
	flash.BackgroundColor3 = color or Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1 - (fuerza or 0.35)
	TweenService:Create(flash, TweenInfo.new(F.Flash), { BackgroundTransparency = 1 }):Play()
end

-- Grito grande arriba del tablero ("¡GENIAL!"): entra girado y gigante, rebota y se va.
local grito = Estilo.texto(lienzo, "", Estilo.Texto.Titulo)
grito.Name = "Grito"
grito.AnchorPoint = Vector2.new(0.5, 0.5)
grito.Position = UDim2.fromScale(0.5, 0.3)
grito.Size = UDim2.fromScale(0.6, 0.14)
grito.TextScaled = true
grito.TextTransparency = 1
grito.TextStrokeTransparency = 1
local escalaGrito = Instance.new("UIScale")
escalaGrito.Parent = grito
local gritos = 0
function Efectos.grito(texto: string, color: Color3)
	gritos += 1
	local marca = gritos
	grito.Text = texto
	grito.TextColor3 = color
	grito.TextTransparency = 0
	grito.TextStrokeTransparency = 0
	grito.Rotation = math.random(-12, 12)
	escalaGrito.Scale = 2.4
	TweenService
		:Create(escalaGrito, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()
	TweenService:Create(grito, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Rotation = 0 }):Play()
	task.delay(0.8, function()
		if gritos ~= marca then
			return
		end
		TweenService:Create(grito, TweenInfo.new(0.25), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		TweenService:Create(escalaGrito, TweenInfo.new(0.25), { Scale = 0.6 }):Play()
	end)
end

-- Contador de combo (toques seguidos en el tiro): abajo a la derecha del tablero, crece con
-- cada toque y cambia de color cuantos más lleva.
local combo = Estilo.texto(lienzo, "", Estilo.Texto.Titulo)
combo.Name = "Combo"
combo.AnchorPoint = Vector2.new(0.5, 0.5)
combo.Position = UDim2.fromScale(0.31, 0.7)
combo.Size = UDim2.fromScale(0.22, 0.07)
combo.TextScaled = true
combo.TextTransparency = 1
combo.TextStrokeTransparency = 1
local escalaCombo = Instance.new("UIScale")
escalaCombo.Parent = combo
local COLORES_COMBO = { "#FFFFFF", "#3FE8FF", "#E8FF3A", "#FF3FD0", "#FF2E4D" }
function Efectos.combo(n: number)
	if n < F.ComboMinimo then
		return
	end
	combo.Text = ("COMBO ×%d"):format(n)
	local nivel = math.clamp(math.floor(n / 5) + 1, 1, #COLORES_COMBO)
	combo.TextColor3 = Color3.fromHex(COLORES_COMBO[nivel])
	combo.TextTransparency = 0
	combo.TextStrokeTransparency = 0
	combo.Rotation = (if n % 2 == 0 then 1 else -1) * math.min(n, 12) * 0.6
	escalaCombo.Scale = 1.35 + math.min(n, 30) * 0.02
	TweenService:Create(
		escalaCombo,
		TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 + math.min(n, 30) * 0.015 }
	):Play()
end
function Efectos.comboFin()
	local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.5)
	TweenService:Create(combo, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
end

return Efectos
