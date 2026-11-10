--!nonstrict
-- Arma la grúa de pórtico en Studio (modo Edit, por MCP execute_luau).
-- Antes: insertar el modelo 129983068682562 en ServerStorage con el nombre
-- "GruaPuertoImportada" (insert_asset). Este script:
--   1. lo convierte en ServerStorage.GruaPuerto con SurfaceAppearance, colisiones
--      simples (cajas invisibles) y las luces de cabina (#f2a23a) y punta (roja);
--   2. pone 2 grúas en workspace.Gruas, sobre el borde norte del muelle, en rieles
--      paralelos al borde y con el brazo hacia el agua.
-- Los IDs están en Config.Arena.Mapa.Grua. Después de correrlo, guardar el place.

local SS = game:GetService("ServerStorage")
local T = {
	Grua_Portico = { "123252498966862", "98039254804423", "137975529202976", "102168131760233" },
	Grua_Cuerpo = { "115945904863872", "139558148674191", "81975749861393", "115812068842536" },
	Grua_Brazo = { "130505943673111", "79677112570986", "93250369091722", "98651287206341" },
}
local VIDRIO = "79156351242833"
-- Medidas en studs desde el pivote (base del pórtico), sacadas de medidas.json.
local LUZ_CABINA = { 10.36, 56.61, 8.57 } -- adelante, arriba, derecha
local LUZ_PUNTA = { 59.84, 112.7, 0 }

local viejo = SS:FindFirstChild("GruaPuerto")
if viejo then
	viejo:Destroy()
end
local m = SS:FindFirstChild("GruaPuertoImportada")
assert(m, "Falta insertar el modelo 129983068682562 como ServerStorage.GruaPuertoImportada")
local link = m:FindFirstChildOfClass("PackageLink")
if link then
	link:Destroy()
end
m.Name = "GruaPuerto"

local portico, brazo = m.Grua_Portico, m.Grua_Brazo
local base = portico.Position - Vector3.new(0, portico.Size.Y / 2, 0)
local dir = (brazo.Position - portico.Position) * Vector3.new(1, 0, 1)
local pivote = CFrame.lookAt(base, base + dir.Unit)
m.PrimaryPart = portico
m.WorldPivot = pivote

local function soloVista(p)
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
end

for nombre, ids in T do
	local p = m[nombre]
	soloVista(p)
	p.CastShadow = true
	p.Material = Enum.Material.Metal
	pcall(function()
		p.CollisionFidelity = Enum.CollisionFidelity.Box
	end)
	local sa = Instance.new("SurfaceAppearance")
	sa.ColorMap = "rbxassetid://" .. ids[1]
	sa.NormalMap = "rbxassetid://" .. ids[2]
	sa.RoughnessMap = "rbxassetid://" .. ids[3]
	sa.MetalnessMap = "rbxassetid://" .. ids[4]
	sa.Parent = p
end

-- Vidrio sucio, algo transparente, que deja ver el interior oscuro.
local v = m.Grua_Vidrio
soloVista(v)
v.CastShadow = false
v.Material = Enum.Material.Glass
v.Transparency = 0.25
local sv = Instance.new("SurfaceAppearance")
sv.ColorMap = "rbxassetid://" .. VIDRIO
sv.Parent = v
local interior = m.Grua_Interior
soloVista(interior)
interior.Color = Color3.fromRGB(20, 20, 23)
interior.Material = Enum.Material.SmoothPlastic

local function loc(adelante, arriba, derecha)
	return pivote * CFrame.new(derecha, arriba, -adelante)
end

-- Luz cálida de la cabina.
local lc = Instance.new("Part")
lc.Name = "LuzCabina"
lc.Size = Vector3.new(0.6, 0.6, 0.6)
lc.Transparency = 1
soloVista(lc)
lc.CFrame = loc(LUZ_CABINA[1], LUZ_CABINA[2], LUZ_CABINA[3])
local pl = Instance.new("PointLight")
pl.Color = Color3.fromHex("#f2a23a")
pl.Brightness = 2.2
pl.Range = 22
pl.Shadows = true
pl.Parent = lc
lc.Parent = m

-- Luz roja de posición en la punta del brazo.
local lp = Instance.new("Part")
lp.Name = "LuzPunta"
lp.Shape = Enum.PartType.Ball
lp.Size = Vector3.new(1.4, 1.4, 1.4)
lp.Material = Enum.Material.Neon
lp.Color = Color3.fromRGB(255, 40, 30)
soloVista(lp)
lp.CastShadow = false
lp.CFrame = loc(LUZ_PUNTA[1], LUZ_PUNTA[2], LUZ_PUNTA[3])
local pr = Instance.new("PointLight")
pr.Color = Color3.fromRGB(255, 50, 35)
pr.Brightness = 3
pr.Range = 30
pr.Parent = lp
lp.Parent = m

-- Colisiones simples: cuatro patas y el cuerpo, en cajas invisibles.
local function choque(tam, cf)
	local c = Instance.new("Part")
	c.Name = "Grua_Colision"
	c.Size = tam
	c.CFrame = cf
	c.Transparency = 1
	c.Anchored = true
	c.CanCollide = true
	c.CanTouch = false
	c.CanQuery = true
	c.CastShadow = false
	c.Parent = m
end
for _, sx in { -1, 1 } do
	for _, sz in { -1, 1 } do
		choque(
			Vector3.new(6, 46, 6),
			loc(sx * 11.5, 23, sz * 9.5) * CFrame.Angles(math.rad(sz * 9), 0, math.rad(sx * 8))
		)
	end
end
choque(Vector3.new(24, 20, 30), loc(-2, 57, 0))
m:SetAttribute("Pieza", "GruaPuerto")

-- Dos grúas sobre el borde norte del muelle (de ahí para el norte es agua).
local anterior = workspace:FindFirstChild("Gruas")
if anterior then
	anterior:Destroy()
end
local carpeta = Instance.new("Folder")
carpeta.Name = "Gruas"
local O = Vector3.new(-330, 0, 1035) -- Config.Arena.Mapa.Centro
local centroZ = O.Z - 130 - 23

local function parte(nombre, tam, pos, hex, material, choca)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = pos
	p.Anchored = true
	p.CanCollide = choca ~= false
	p.Color = Color3.fromHex(hex)
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = carpeta
	return p
end
parte(
	"MuelleGruas",
	Vector3.new(288, 1, 46),
	Vector3.new(O.X, -0.4, centroZ),
	"#2b2f36",
	Enum.Material.Concrete
)
for _, dz in { -16.07, 16.07 } do
	parte(
		"Riel",
		Vector3.new(288, 0.5, 1.2),
		Vector3.new(O.X, 0.3, centroZ + dz),
		"#3a3632",
		Enum.Material.CorrodedMetal,
		false
	)
end
for x = -132, 132, 44 do
	parte(
		"Pilote",
		Vector3.new(3, 8, 3),
		Vector3.new(O.X + x, -4.6, centroZ - 21),
		"#3b332b",
		Enum.Material.Wood,
		false
	)
end
for i, x in { -50, 90 } do
	local g = m:Clone()
	g.Name = "GruaPuerto" .. i
	local pos = Vector3.new(O.X + x, 0.1, centroZ)
	g:PivotTo(CFrame.lookAt(pos, pos + Vector3.new(0, 0, -1))) -- brazo hacia el agua
	g.Parent = carpeta
end
carpeta.Parent = workspace
return "Grúa armada: ServerStorage.GruaPuerto y 2 copias en workspace.Gruas"
