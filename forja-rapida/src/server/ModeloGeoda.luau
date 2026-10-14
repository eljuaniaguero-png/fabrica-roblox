--!strict
-- Arma el modelo de una geoda y le da el aspecto de su zona y de su modificador exótico.
-- Si existe ServerStorage > Modelos > Geodas > <Id del tamaño> (las mallas de Blender, ya a su
-- tamaño real y con el pivote en la base), se clona eso. Si no, se arma con partes simples
-- (greybox) y se escala con GameConfig.Tamanos[..].Escala.
-- Partes que se pintan (por nombre):
--   "Roca"       la piedra: color de la zona, o el del modificador; en las exóticas, su textura
--                (rayas de lava, cuadritos neón, oro, vacío) si ya está subida.
--   "Cristales"  lo que asoma arriba: Neon y del color del modificador en las exóticas.
--   "Grietas"    grietas que brillan (Grupo 1): solo se ven en las exóticas, del Color.
--   "Grietas2"   la segunda grieta: solo en las combinaciones, del Color2.
--   "Base"       el nido de escombros.
--   "Runas"      el cinturón de runas de la Geoda Ancestral (dorado, brilla).
-- Acá solo va lo que tiene que ver todo el mundo igual (colores, materiales, textura). Las
-- partículas, luces, el anillo de lava y las animaciones las pone cada cliente
-- (client/Geodas.client.luau), así cada uno puede pedir "efectos reducidos".

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
	-- Grietas: tiras finas en zigzag sobre dos caras de la roca (de frente y al costado).
	local tramos: { { Nombre: string, Cf: CFrame } } = {
		{ Nombre = "Grietas", Cf = CFrame.new(-0.4, 2.4, -1.52) * CFrame.Angles(0, 0, 0.5) },
		{ Nombre = "Grietas", Cf = CFrame.new(0.25, 1.6, -1.52) * CFrame.Angles(0, 0, -0.6) },
		{ Nombre = "Grietas2", Cf = CFrame.new(1.52, 2.2, 0.3) * CFrame.Angles(0.55, 0, 0) },
		{ Nombre = "Grietas2", Cf = CFrame.new(1.52, 1.4, -0.35) * CFrame.Angles(-0.5, 0, 0) },
	}
	for _, t in tramos do
		local g = parte(t.Nombre, Vector3.new(0.14, 1.1, 0.14), t.Cf, m)
		g.CanCollide = false
		g.CanQuery = false
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

local function material(nombre: string?, porDefecto: Enum.Material): Enum.Material
	if not nombre then
		return porDefecto
	end
	local ok, m = pcall(function()
		return (Enum.Material :: any)[nombre]
	end)
	return if ok and typeof(m) == "EnumItem" then m :: Enum.Material else porDefecto
end

-- Pinta la geoda según su zona y su modificador.
local function pintar(m: Model, zona: number, modificador: string)
	local z = Reglas.zona(zona) or GameConfig.Zonas[1]
	local mod = Reglas.modificador(modificador) or GameConfig.Modificadores[1]
	local exotica = Reglas.esExotica(modificador)
	local colorRoca = Color3.fromHex(mod.ColorRoca or z.ColorRoca)
	local materialRoca = material(mod.MaterialRoca, Enum.Material.Slate)
	local colorCristal = if exotica
		then Color3.fromHex(mod.Color)
		else Color3.fromHex(z.ColorCristal)
	local colorGrieta2 = Color3.fromHex(mod.Color2 or mod.Color)

	for _, p in m:GetDescendants() do
		if not p:IsA("BasePart") then
			continue
		end
		if p.Name == "Roca" then
			p.Color, p.Material = colorRoca, materialRoca
			if exotica and mod.Textura ~= "" and p:IsA("MeshPart") then
				p.TextureID = mod.Textura
			end
		elseif p.Name == "Cristales" then
			p.Color = colorCristal
			p.Material = if exotica then Enum.Material.Neon else Enum.Material.SmoothPlastic
			p.Reflectance = if exotica then 0 else 0.15
		elseif p.Name == "Grietas" or p.Name == "Grietas2" then
			-- Grietas2 solo en las combinaciones (tienen dos colores)
			local ver = exotica and (p.Name == "Grietas" or mod.Partes ~= nil)
			p.Color = if p.Name == "Grietas" then colorCristal else colorGrieta2
			p.Material = Enum.Material.Neon
			p.Transparency = if ver then 0 else 1
			p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
			p.CastShadow = false
		elseif p.Name == "Base" then
			p.Color, p.Material = COLOR_BASE, Enum.Material.Ground
		elseif p.Name == "Runas" then
			-- cinturón de runas de la Geoda Ancestral: siempre dorado y brillante
			p.Color, p.Material = Color3.fromHex("#FFD23F"), Enum.Material.Neon
			p.CanCollide, p.CanQuery = false, false
		end
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
