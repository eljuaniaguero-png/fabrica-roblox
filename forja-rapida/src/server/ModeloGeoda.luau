--!strict
-- Arma el modelo de una geoda y le da el aspecto de su zona y de su modificador exótico.
-- Si existe ServerStorage > Modelos > Geodas > <Id del tamaño> (las mallas de Blender, ya a su
-- tamaño real y con el pivote en la base), se clona eso. Si no, se arma con partes simples
-- (greybox) y se escala con GameConfig.Tamanos[..].Escala.
-- Partes que se pintan: "Roca" (la piedra), "Cristales" (lo que asoma) y "Base" (el nido de
-- escombros). Lo que tenga otro nombre se deja como está.

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)

local COLOR_BASE = Color3.fromHex("#7A5233")

local ModeloGeoda = {}

local function parte(nombre: string, tamano: Vector3, cf: CFrame, padre: Instance): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tamano
	p.CFrame = cf
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

-- Geoda de partes simples, de 1 de escala, con la base apoyada en y = 0.
local function greybox(): Model
	local m = Instance.new("Model")
	local base = parte(
		"Base",
		Vector3.new(0.6, 4.6, 4.6),
		CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, math.pi / 2),
		m
	)
	base.Shape = Enum.PartType.Cylinder
	base.CanCollide = false
	local roca = parte("Roca", Vector3.new(3, 3.4, 3), CFrame.new(0, 2.1, 0), m)
	for i, giro in { -0.5, 0.35, 0.1 } do
		local c = parte(
			"Cristales",
			Vector3.new(0.5, 1.4 - i * 0.2, 0.5),
			CFrame.new((i - 2) * 0.7, 3.9, (i % 2) * 0.6 - 0.3) * CFrame.Angles(0, i, giro),
			m
		)
		c.CanCollide = false
	end
	m.PrimaryPart = roca
	m.WorldPivot = CFrame.new(0, 0, 0)
	return m
end

local function molde(tamano: string): Model?
	local carpeta = ServerStorage:FindFirstChild(GameConfig.Modelos.Carpeta)
	local geodas = carpeta and carpeta:FindFirstChild("Geodas")
	local m = geodas and geodas:FindFirstChild(tamano)
	if m and m:IsA("Model") then
		return m
	end
	return nil
end

local function luz(padre: Instance, color: Color3, alcance: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = alcance
	l.Brightness = 2
	l.Shadows = false
	l.Parent = padre
end

local function chispas(
	padre: Instance,
	color: Color3,
	cantidad: number,
	velocidad: number,
	tamano: number
)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 1
	e.Rate = cantidad
	e.Lifetime = NumberRange.new(0.8, 1.6)
	e.Speed = NumberRange.new(velocidad * 0.5, velocidad)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, tamano),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Parent = padre
end

-- Pinta la geoda según su zona y le pone el aura de su modificador.
local function pintar(m: Model, zona: number, modificador: string)
	local z = Reglas.zona(zona) or GameConfig.Zonas[1]
	local mod = Reglas.modificador(modificador)
	local colorRoca = Color3.fromHex(z.ColorRoca)
	local colorCristal = Color3.fromHex(z.ColorCristal)
	local materialRoca = Enum.Material.Slate
	local materialCristal = Enum.Material.SmoothPlastic
	local colorMod = if mod then Color3.fromHex(mod.Color) else colorCristal

	if modificador == "Lava" then
		colorRoca = Color3.fromHex("#3A2622")
		materialRoca = Enum.Material.Basalt
		colorCristal, materialCristal = colorMod, Enum.Material.Neon
	elseif modificador == "Neon" then
		colorCristal, materialCristal = colorMod, Enum.Material.Neon
	elseif modificador == "Midas" then
		colorRoca, materialRoca = colorMod, Enum.Material.Foil
		colorCristal, materialCristal = Color3.fromHex("#FFF3B0"), Enum.Material.Neon
	elseif modificador == "Vacio" then
		colorRoca, materialRoca = Color3.fromHex("#140C2B"), Enum.Material.Basalt
		colorCristal, materialCristal = colorMod, Enum.Material.Neon
	end

	local roca: BasePart? = nil
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			if p.Name == "Roca" then
				p.Color, p.Material = colorRoca, materialRoca
				roca = p
			elseif p.Name == "Cristales" then
				p.Color, p.Material = colorCristal, materialCristal
				p.Reflectance = if materialCristal == Enum.Material.SmoothPlastic then 0.15 else 0
			elseif p.Name == "Base" then
				p.Color, p.Material = COLOR_BASE, Enum.Material.Ground
			end
		end
	end
	if not roca or modificador == "Normal" then
		return
	end

	-- Aura del modificador, con el tamaño de la roca.
	local r = (roca :: BasePart).Size.Magnitude
	local aura = Instance.new("Attachment")
	aura.Name = "Aura"
	aura.Parent = roca
	if modificador == "Lava" then
		local fuego = Instance.new("Fire")
		fuego.Size = r * 0.9
		fuego.Heat = 6
		fuego.Color = colorMod
		fuego.SecondaryColor = Color3.fromHex("#FFD23F")
		fuego.Parent = aura
		luz(aura, colorMod, r * 3)
	elseif modificador == "Neon" then
		local s = Instance.new("Sparkles")
		s.SparkleColor = colorMod
		s.Parent = aura
		chispas(aura, colorMod, 12, r * 1.5, 0.35)
		luz(aura, colorMod, r * 3)
	elseif modificador == "Midas" then
		chispas(aura, colorMod, 20, r * 0.8, 0.5)
		luz(aura, colorMod, r * 4)
	elseif modificador == "Vacio" then
		chispas(aura, colorMod, 35, r * 0.4, 0.8)
		chispas(aura, Color3.fromHex("#FFFFFF"), 6, r * 0.3, 0.25)
		luz(aura, colorMod, r * 5)
	end
end

-- Crea una geoda nueva (sin padre) para esa zona, tamaño y modificador.
-- Devuelve el modelo y su parte "Roca" (la que se usa para medir distancias).
function ModeloGeoda.crear(zona: number, tamano: string, modificador: string): (Model, BasePart)
	local t = Reglas.tamano(tamano)
	local m: Model
	local deBlender = molde(tamano)
	if deBlender then
		m = deBlender:Clone()
	else
		m = greybox()
		if t and t.Escala ~= 1 then
			m:ScaleTo(t.Escala)
		end
	end
	m.Name = "Geoda"
	m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic -- el cliente la necesita entera
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	pintar(m, zona, modificador)
	local roca = m:FindFirstChild("Roca", true)
	if not roca or not roca:IsA("BasePart") then
		error("la geoda " .. tamano .. " no tiene una parte Roca")
	end
	return m, roca
end

return ModeloGeoda
