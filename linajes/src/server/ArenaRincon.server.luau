--!strict
-- Rincón lindo: 40 x 40 studs del muelle, pulido para probar la dirección de arte.
-- Si a Juani le gusta, esta receta se repite en el resto del mapa. Valores en shared/Iluminacion.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Luz = require(ReplicatedStorage.Shared.Iluminacion)

local O = Config.Arena.Mapa.Centro
local R = Luz.Rincon
local kit = ServerStorage:WaitForChild("ArenaKit")
local carpeta = Instance.new("Folder")
carpeta.Name = "ArenaRincon"

local function en(x: number, y: number, z: number): CFrame
	return CFrame.new(O + Vector3.new(R.X + x, y, R.Z + z))
end

local function poner(nombre: string, cf: CFrame, tono: string?, escala: number?)
	local molde = kit:FindFirstChild(nombre, true) :: MeshPart
	local p = molde:Clone()
	p.Anchored = true
	if escala then
		p.Size *= escala
	end
	p.CFrame = cf * (molde.CFrame - molde.CFrame.Position)
	local capa = p:FindFirstChildOfClass("SurfaceAppearance")
	if capa and tono then
		capa.Color = Color3.fromHex(tono)
	end
	p.Parent = carpeta
end

local function suelta(tam: Vector3, cf: CFrame, hex: string, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = tam
	p.CFrame = cf
	p.Color = Color3.fromHex(hex)
	p.Material = material
	p.Parent = carpeta
	return p
end

-- Imagen acostada en el piso: charco o reflejo de una luz.
local function calco(
	cf: CFrame,
	ancho: number,
	largo: number,
	imagen: string,
	tono: string,
	fuerza: number
)
	local p = suelta(Vector3.new(ancho, 0.05, largo), cf, "#000000", Enum.Material.SmoothPlastic)
	p.Transparency = 1
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.LightInfluence = 0
	gui.Parent = p
	local foto = Instance.new("ImageLabel")
	foto.Size = UDim2.fromScale(1, 1)
	foto.BackgroundTransparency = 1
	foto.Image = imagen
	foto.ImageColor3 = Color3.fromHex(tono)
	foto.ImageTransparency = 1 - fuerza
	foto.Parent = gui
end

-- Haz de luz en la niebla: dos cintas cruzadas que se apagan al bajar.
local function haz(
	desde: Vector3,
	hasta: Vector3,
	anchoArriba: number,
	anchoAbajo: number,
	datos: any
)
	local base =
		suelta(Vector3.one * 0.2, CFrame.new(desde), "#000000", Enum.Material.SmoothPlastic)
	base.Transparency = 1
	local a0 = Instance.new("Attachment")
	a0.Parent = base
	local a1 = Instance.new("Attachment")
	a1.WorldPosition = hasta
	a1.Parent = base
	for _, giro in { 0, 90 } do
		local b = Instance.new("Beam")
		b.Attachment0 = a0
		b.Attachment1 = a1
		b.Width0 = anchoArriba
		b.Width1 = anchoAbajo
		b.Color = ColorSequence.new(Color3.fromHex(datos.Color))
		b.LightEmission = 1
		b.LightInfluence = 0
		b.Transparency = NumberSequence.new(datos.Haz, 1)
		b.FaceCamera = giro == 0
		b.Segments = 1
		b.Parent = base
	end
end

local function foco(cf: CFrame, datos: any)
	local p = suelta(Vector3.new(4, 1, 2), cf, datos.Color, Enum.Material.Neon)
	local l = Instance.new("SpotLight")
	l.Face = Enum.NormalId.Bottom
	l.Color = Color3.fromHex(datos.Color)
	l.Brightness = datos.Brillo
	l.Range = datos.Alcance
	l.Angle = datos.Angulo
	l.Shadows = true
	l.Parent = p
end

-- Pila de contenedores contra el fondo, en tonos apagados.
poner("Contenedor", en(6, 4.5, 15) * CFrame.Angles(0, math.rad(4), 0), R.Tonos[1])
poner("Contenedor", en(-13, 4.5, 15) * CFrame.Angles(0, math.rad(-3), 0), R.Tonos[2])
poner("Contenedor", en(-3, 13.5, 15) * CFrame.Angles(0, math.rad(8), 0), R.Tonos[3])

poner("Prop_Cajones", en(15, 4.1, 2) * CFrame.Angles(0, math.rad(24), 0))
poner("Prop_Barril", en(9, 1.65, -3), R.TonoBarril)
poner("Prop_Barril", en(12, 1.65, -6) * CFrame.Angles(0, 0, math.rad(90)), R.TonoBarril)
poner("Prop_Bita", en(-6, 1.1, -19), R.TonoBita)
poner("Prop_Bita", en(14, 1.1, -19), R.TonoBita)

-- Pared de galpón con ventana cálida.
for i = -1, 1 do
	poner("Galpon_Pared", en(-20, 9, 2 + i * 12), nil, 1.5)
end
local ventana = suelta(Vector3.new(0.3, 4.5, 6), en(-19, 11, 2), R.Ventana, Enum.Material.Neon)
local calida = Instance.new("SurfaceLight")
calida.Face = Enum.NormalId.Right
calida.Color = Color3.fromHex(R.Ventana)
calida.Brightness = 4
calida.Range = 22
calida.Angle = 120
calida.Parent = ventana

-- Farola de sodio: cono naranja y charco de luz.
local fx, fz = R.Farola.X, R.Farola.Z
poner("Prop_Farola", en(fx, 11, fz), nil, 1.5)
foco(en(fx, 20.5, fz), Luz.Calida)
haz(
	O + Vector3.new(R.X + fx, 20, R.Z + fz),
	O + Vector3.new(R.X + fx, 0.3, R.Z + fz),
	2,
	22,
	Luz.Calida
)

-- Reflector de la grúa: luz fría que cruza la niebla en diagonal.
local rf = R.Reflector
foco(en(rf.X, rf.Y, rf.Z) * CFrame.Angles(math.rad(rf.Inclina), 0, 0), Luz.Fria)
haz(
	O + Vector3.new(R.X + rf.X, rf.Y, R.Z + rf.Z),
	O + Vector3.new(R.X + rf.DestinoX, 0.3, R.Z + rf.DestinoZ),
	3,
	24,
	Luz.Fria
)

-- Charcos y reflejos alargados de cada luz.
for _, c in R.Charcos do
	calco(
		en(c[1], 0.17, c[2]) * CFrame.Angles(0, math.rad(c[5]), 0),
		c[3],
		c[4],
		Luz.Texturas.Charco,
		"#ffffff",
		0.9
	)
end
calco(en(fx, 0.2, fz + 7), 8, 18, Luz.Texturas.Reflejo, Luz.Calida.Color, 0.6)
calco(en(rf.DestinoX, 0.2, rf.DestinoZ), 10, 18, Luz.Texturas.Reflejo, Luz.Fria.Color, 0.45)
calco(en(-13, 0.2, 2), 18, 6, Luz.Texturas.Reflejo, R.Ventana, 0.4)

-- Agua del puerto: oscura, con brillo, delante del borde del muelle.
local agua = suelta(
	Vector3.new(900, 1, 420),
	CFrame.new(O + Vector3.new(0, -3, -340)),
	"#16243a",
	Enum.Material.Glass
)
agua.Reflectance = 0.3
agua.Transparency = 0.05
carpeta.Parent = workspace
