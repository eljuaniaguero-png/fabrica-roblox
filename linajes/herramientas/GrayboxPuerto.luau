--!strict
-- Arma en Studio (modo Edit, por MCP) el graybox de Puerto Óxido: piso, calles, galpones, grúas,
-- contenedores, muelles, 5 barrios, estaciones, orígenes y conexiones cortadas. Se puede volver a
-- correr: borra workspace.Mundo.PuertoOxido y lo rearma. Medidas en Config.Mundo.
-- Ejes: +Z es el sur. El mapa va de -2000 a 2000 en X y Z; la bahía está en el centro.

local CollectionService = game:GetService("CollectionService")

local GRIS = Color3.fromHex("8a8f99")
local GRIS_OSCURO = Color3.fromHex("3a3f4b")
local GRIS_CLARO = Color3.fromHex("b8bcc4")
local azar = Random.new(7)

local mundo = workspace:FindFirstChild("Mundo") or Instance.new("Folder")
mundo.Name = "Mundo"
mundo.Parent = workspace
local viejo = mundo:FindFirstChild("PuertoOxido")
if viejo then
	viejo:Destroy()
end
local puerto = Instance.new("Folder")
puerto.Name = "PuertoOxido"

local function bloque(
	padre: Instance,
	nombre: string,
	tam: Vector3,
	pos: Vector3,
	color: Color3?
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Anchored = true
	p.Size = tam
	p.Position = pos
	p.Color = color or GRIS
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

local function carpeta(padre: Instance, nombre: string): Folder
	local f = Instance.new("Folder")
	f.Name = nombre
	f.Parent = padre
	return f
end

local function marca(
	padre: Instance,
	nombre: string,
	tag: string,
	pos: Vector3,
	attrs: { [string]: any }
)
	local p = bloque(padre, nombre, Vector3.new(12, 1, 12), pos, Color3.fromHex("3fe0f0"))
	p.Material = Enum.Material.Neon
	p.CanCollide = false
	for k, v in attrs do
		p:SetAttribute(k, v)
	end
	CollectionService:AddTag(p, tag)
end

-- Piso y calles (grilla cada 100 studs)
bloque(puerto, "Piso", Vector3.new(1200, 8, 1000), Vector3.new(0, -4, 1400), GRIS_OSCURO)
local calles = carpeta(puerto, "Calles")
for x = -500, 500, 100 do
	bloque(
		calles,
		"CalleNS",
		Vector3.new(24, 0.2, 750),
		Vector3.new(x, 0.1, 1525),
		Color3.fromHex("2a2e37")
	)
end
for z = 1150, 1850, 100 do
	bloque(
		calles,
		"CalleEO",
		Vector3.new(1200, 0.2, 24),
		Vector3.new(0, 0.1, z),
		Color3.fromHex("2a2e37")
	)
end

-- Barrios: Part invisible con el área (atributos Ciudad y Barrio, tag "Barrio")
local barrios = {
	{ "Muelles", -300, 1025, 600, 250 },
	{ "Aduana", 300, 1025, 600, 250 },
	{ "Galpones", -350, 1525, 500, 750 },
	{ "MercadoPescado", 100, 1525, 400, 750 },
	{ "LaFeria", 450, 1525, 300, 750 },
}
local carpetasBarrio: { [string]: Folder } = {}
for _, b in barrios do
	local f = carpeta(puerto, b[1])
	carpetasBarrio[b[1]] = f
	local area = bloque(f, "Area", Vector3.new(b[4], 400, b[5]), Vector3.new(b[2], 200, b[3]))
	area.Transparency = 1
	area.CanCollide = false
	area.CanTouch = false
	area.CanQuery = false
	area:SetAttribute("Ciudad", "PuertoOxido")
	area:SetAttribute("Barrio", b[1])
	CollectionService:AddTag(area, "Barrio")
end

-- Galpones bajos: dos por manzana, con un callejón de 16 studs en el medio
local callejones = carpeta(puerto, "Callejones")
for x = -450, -250, 100 do
	for z = 1200, 1800, 100 do
		for _, lado in { -23, 23 } do
			local alto = azar:NextInteger(18, 30)
			bloque(
				carpetasBarrio.Galpones,
				"Galpon",
				Vector3.new(76, alto, 30),
				Vector3.new(x, alto / 2, z + lado),
				GRIS_CLARO
			)
		end
		bloque(
			callejones,
			"Callejon",
			Vector3.new(76, 0.3, 16),
			Vector3.new(x, 0.15, z),
			Color3.fromHex("1b1f2a")
		)
	end
end
-- Mercado de pescado: nave grande y puestos
bloque(
	carpetasBarrio.MercadoPescado,
	"NaveMercado",
	Vector3.new(150, 26, 60),
	Vector3.new(100, 13, 1200),
	GRIS_CLARO
)
for x = -50, 250, 100 do
	for z = 1300, 1800, 100 do
		local alto = azar:NextInteger(16, 40)
		bloque(
			carpetasBarrio.MercadoPescado,
			"Edificio",
			Vector3.new(60, alto, 60),
			Vector3.new(x + 50, alto / 2, z),
			GRIS
		)
	end
end
-- La Feria: plaza, vuelta al mundo (disco) y carpas
local feria = carpetasBarrio.LaFeria
bloque(feria, "Plaza", Vector3.new(260, 0.4, 300), Vector3.new(450, 0.2, 1400), GRIS_CLARO)
local rueda = bloque(feria, "VueltaAlMundo", Vector3.new(4, 90, 90), Vector3.new(450, 50, 1350))
rueda.Shape = Enum.PartType.Cylinder
for i = 0, 3 do
	bloque(feria, "Carpa", Vector3.new(30, 14, 30), Vector3.new(370 + i * 55, 7, 1480), GRIS)
end
for z = 1600, 1800, 100 do
	bloque(feria, "Edificio", Vector3.new(60, 24, 60), Vector3.new(450, 12, z), GRIS)
end

-- Muelles al agua (norte) y grúas
local muelles = carpetasBarrio.Muelles
for i = 0, 5 do
	local x = -550 + i * 110
	bloque(
		muelles,
		"Muelle",
		Vector3.new(36, 4, 140),
		Vector3.new(x, -1, 830),
		Color3.fromHex("6e3b2e")
	)
	local grua = Instance.new("Model")
	grua.Name = "Grua"
	for _, d in
		{ Vector2.new(-14, -10), Vector2.new(14, -10), Vector2.new(-14, 10), Vector2.new(14, 10) }
	do
		bloque(
			grua,
			"Pata",
			Vector3.new(3, 80, 3),
			Vector3.new(x + d.X, 40, 940 + d.Y),
			Color3.fromHex("f2a23a")
		)
	end
	bloque(grua, "Brazo", Vector3.new(6, 6, 140), Vector3.new(x, 82, 900), Color3.fromHex("f2a23a"))
	grua.Parent = muelles
end
-- Aduana: contenedores apilados
local aduana = carpetasBarrio.Aduana
for x = 60, 540, 30 do
	for z = 930, 1110, 45 do
		for piso = 0, azar:NextInteger(0, 3) do
			local c = Color3.fromHSV(azar:NextNumber(), 0.15, azar:NextNumber(0.35, 0.6))
			bloque(
				aduana,
				"Contenedor",
				Vector3.new(10, 10, 40),
				Vector3.new(x, 5 + piso * 10.2, z),
				c
			)
		end
	end
end

-- Conexiones (cortadas por ahora)
local con = carpeta(puerto, "Conexiones")
-- Puente a Corona: sale del este hacia el noreste y se corta sobre el agua
local puente = bloque(con, "PuenteCorona", Vector3.new(40, 4, 400), Vector3.new(0, 30, 0))
puente.CFrame = CFrame.new(Vector3.new(700, 30, 820)) * CFrame.Angles(0, math.rad(-35), 0)
puente:SetAttribute("Cortado", true)
bloque(con, "RampaPuente", Vector3.new(40, 4, 130), Vector3.new(560, 0, 0)).CFrame = CFrame.new(
	560,
	14,
	1000
) * CFrame.Angles(0, math.rad(-35), 0) * CFrame.Angles(math.rad(14), 0, 0)
-- Túnel a Vórtice: boca en el borde oeste, tapiada
bloque(con, "TunelVorticeTecho", Vector3.new(60, 8, 50), Vector3.new(-575, 34, 1300))
bloque(con, "TunelVorticeParedN", Vector3.new(60, 30, 6), Vector3.new(-575, 15, 1278))
bloque(con, "TunelVorticeParedS", Vector3.new(60, 30, 6), Vector3.new(-575, 15, 1322))
bloque(con, "TunelVorticeTapia", Vector3.new(4, 30, 40), Vector3.new(-602, 15, 1300), GRIS_OSCURO):SetAttribute(
	"Cortado",
	true
)
-- Muelle del ferry al penal
bloque(
	con,
	"MuelleFerry",
	Vector3.new(30, 4, 200),
	Vector3.new(0, -1, 800),
	Color3.fromHex("6e3b2e")
)

-- Estaciones (2 de subte + ferry) y orígenes del puerto
marca(
	con,
	"SubteGalpones",
	"Estacion",
	Vector3.new(-350, 0.6, 1650),
	{ Ciudad = "PuertoOxido", Tipo = "Subte" }
)
marca(
	con,
	"SubteFeria",
	"Estacion",
	Vector3.new(450, 0.6, 1850),
	{ Ciudad = "PuertoOxido", Tipo = "Subte" }
)
marca(
	con,
	"FerryPenal",
	"Estacion",
	Vector3.new(0, 1.6, 720),
	{ Ciudad = "PuertoOxido", Tipo = "Ferry" }
)
marca(
	muelles,
	"OrigenEstibador",
	"Origen",
	Vector3.new(-330, 1.6, 830),
	{ Ciudad = "PuertoOxido", Origen = "Estibador" }
)
marca(
	feria,
	"OrigenAcrobata",
	"Origen",
	Vector3.new(450, 1, 1450),
	{ Ciudad = "PuertoOxido", Origen = "Acrobata" }
)

-- Portal cerrado de la Ciudad Hundida, bajo el agua frente al puerto
local portal = Instance.new("Model")
portal.Name = "PortalCiudadHundida"
bloque(portal, "Base", Vector3.new(80, 4, 80), Vector3.new(0, -62, 600), GRIS_OSCURO)
local aro = bloque(
	portal,
	"Aro",
	Vector3.new(4, 50, 50),
	Vector3.new(0, -35, 600),
	Color3.fromHex("3fe0f0")
)
aro.Shape = Enum.PartType.Cylinder
aro.CFrame = CFrame.new(0, -35, 600) * CFrame.Angles(0, math.rad(90), 0)
portal:SetAttribute("Cerrado", true)
portal.Parent = puerto

-- Lugares de la Beta (tag "Lugar", atributo Lugar): taller de Tano, galpón de Remache y almacén del atraco
local lugares = carpeta(puerto, "Lugares")
local function lugar(nombre: string, tam: Vector3, pos: Vector3, color: Color3)
	local p = bloque(lugares, nombre, tam, pos, color)
	p:SetAttribute("Lugar", nombre)
	CollectionService:AddTag(p, "Lugar")
end
lugar("TallerTano", Vector3.new(50, 22, 40), Vector3.new(-150, 11, 1400), Color3.fromHex("4ed68a"))
lugar(
	"GalponRemache",
	Vector3.new(70, 34, 70),
	Vector3.new(-150, 17, 1800),
	Color3.fromHex("ff4d6d")
)
lugar(
	"AlmacenMuelle",
	Vector3.new(60, 20, 40),
	Vector3.new(-120, 10, 1060),
	Color3.fromHex("f2a23a")
)
-- Cortes de la policía en el puente y el túnel
for _, pos in { Vector3.new(600, 6, 1040), Vector3.new(-560, 6, 1300) } do
	local valla = bloque(con, "CortePolicia", Vector3.new(6, 6, 40), pos, Color3.fromHex("2f6fdb"))
	valla:SetAttribute("Cortado", true)
end

puerto.Parent = mundo

-- Agua de la bahía (centro del mapa hasta el puerto) con fondo
local terreno = workspace.Terrain
terreno:FillBlock(CFrame.new(0, -36, 50), Vector3.new(1800, 64, 1700), Enum.Material.Water)
terreno:FillBlock(CFrame.new(0, -72, 50), Vector3.new(1800, 8, 1700), Enum.Material.Mud)
workspace.StreamingEnabled = true
-- StreamingTargetRadius (512) no se puede poner por script: se pone a mano en Workspace.
local base = workspace:FindFirstChild("Baseplate")
if base then
	base:Destroy()
end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then
	spawn.Position = Vector3.new(-330, 0.5, 1000)
end

return "Puerto Óxido armado"
