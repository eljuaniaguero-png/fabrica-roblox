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
			+ Vector3.new(math.cos(angulo), math.sin(angulo), 0)
				* F.ChispasDistancia
				* (0.6 + math.random() * 0.6)
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
	TweenService:Create(
		escalaJefe,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	task.delay(F.JefeOscuro, function()
		local info = TweenInfo.new(0.3)
		TweenService:Create(oscuro, info, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(nombreJefe, info, { TextTransparency = 1, TextStrokeTransparency = 1 })
			:Play()
	end)
end

return Efectos
