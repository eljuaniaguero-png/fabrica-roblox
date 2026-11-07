--!strict
-- Arena del sandbox en Puerto Óxido, generada por código para que el mapa viva en git.
-- Plano: zona segura en la esquina, cuatro grupos de contenedores, círculo central y pasarela alta.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local M = Config.Arena.Mapa
local O = M.Centro
local MEDIO_X, MEDIO_Z = M.Ancho / 2, M.Largo / 2
local LARGO_C, ALTO_C, ANCHO_C = 20, 9, 8

local carpeta = Instance.new("Folder")
carpeta.Name = "Arena"

local function color(nombre: string): Color3
	return Color3.fromHex((M.Colores :: any)[nombre])
end

local function pieza(
	padre: Instance,
	tamano: Vector3,
	cf: CFrame,
	tono: string,
	material: Enum.Material,
	solido: boolean?
): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.Size = tamano
	p.CFrame = cf
	p.Color = color(tono)
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = solido ~= false
	p.CanTouch = false
	p.CanQuery = solido ~= false
	p.CastShadow = solido ~= false
	p.Parent = padre
	return p
end

local function en(x: number, y: number, z: number): CFrame
	return CFrame.new(O + Vector3.new(x, y, z))
end

-- Contenedor apoyado en y: cuerpo que choca, nervios y puertas de adorno.
local function contenedor(x: number, z: number, nivel: number, giro: number, tono: string)
	local m = Instance.new("Model")
	m.Name = "Contenedor"
	local cf = en(x, nivel * ALTO_C + ALTO_C / 2, z) * CFrame.Angles(0, math.rad(giro), 0)
	local cuerpo = pieza(m, Vector3.new(LARGO_C, ALTO_C, ANCHO_C), cf, tono, Enum.Material.Metal)
	m.PrimaryPart = cuerpo
	for _, lado in { -1, 1 } do
		for i = -2, 2 do
			pieza(
				m,
				Vector3.new(1.1, ALTO_C - 1, 0.3),
				cf * CFrame.new(i * 3.8, 0, lado * (ANCHO_C / 2 + 0.1)),
				tono,
				Enum.Material.Metal,
				false
			)
		end
		pieza(
			m,
			Vector3.new(0.4, ALTO_C, ANCHO_C),
			cf * CFrame.new(lado * (LARGO_C / 2 + 0.15), 0, 0),
			"Oxido",
			Enum.Material.CorrodedMetal,
			false
		)
	end
	m.Parent = carpeta
end

local function fila(
	x: number,
	z: number,
	pasoX: number,
	pasoZ: number,
	cantidad: number,
	giro: number
)
	for i = 0, cantidad - 1 do
		local tono = M.TonosContenedor[i % #M.TonosContenedor + 1]
		local otro = M.TonosContenedor[(i + 2) % #M.TonosContenedor + 1]
		contenedor(x + i * pasoX, z + i * pasoZ, 0, giro, tono)
		contenedor(x + i * pasoX, z + i * pasoZ, 1, giro, otro)
	end
end

local function caja(x: number, z: number, lado: number, y: number?)
	pieza(
		carpeta,
		Vector3.one * lado,
		en(x, (y or 0) + lado / 2, z) * CFrame.Angles(0, math.rad(math.random(-12, 12)), 0),
		"Madera",
		Enum.Material.WoodPlanks
	)
end

local function barriles(x: number, z: number)
	for i = 0, 3 do
		local p = pieza(
			carpeta,
			Vector3.new(4.4, 2.8, 2.8),
			en(x + (i % 2) * 3.1, 2.2, z + math.floor(i / 2) * 3.1)
				* CFrame.Angles(0, 0, math.pi / 2),
			if i == 2 then "Rojo" else "Oxido",
			Enum.Material.CorrodedMetal
		)
		p.Shape = Enum.PartType.Cylinder
	end
end

local function farol(x: number, z: number, con: boolean)
	pieza(carpeta, Vector3.new(0.9, 22, 0.9), en(x, 11, z), "Acero", Enum.Material.Metal)
	pieza(carpeta, Vector3.new(6, 0.6, 0.9), en(x, 22, z), "Acero", Enum.Material.Metal)
	local bulbo =
		pieza(carpeta, Vector3.new(3, 0.5, 1.2), en(x, 21.6, z), "Sodio", Enum.Material.Neon, false)
	if con then
		local luz = Instance.new("SpotLight")
		luz.Face = Enum.NormalId.Bottom
		luz.Color = color("Sodio")
		luz.Brightness = 6
		luz.Range = 55
		luz.Angle = 110
		luz.Parent = bulbo
	end
end

local function piso()
	pieza(
		carpeta,
		Vector3.new(M.Ancho, 0.2, M.Largo),
		en(0, 0, 0),
		"Asfalto",
		Enum.Material.Asphalt
	)
	for i = -2, 2 do
		pieza(
			carpeta,
			Vector3.new(M.Ancho, 0.05, 0.8),
			en(0, 0.12, i * 50),
			"Linea",
			Enum.Material.SmoothPlastic,
			false
		)
	end
	for _, c in M.Charcos do
		local p = pieza(
			carpeta,
			Vector3.new(c[3], 0.04, c[4]),
			en(c[1], 0.13, c[2]),
			"Charco",
			Enum.Material.Glass,
			false
		)
		p.Reflectance = 0.25
		p.Transparency = 0.15
	end
end

-- Círculo del centro: marca el lugar del futuro Rey del muelle.
local function circulo()
	local anillo = pieza(
		carpeta,
		Vector3.new(0.1, M.RadioCirculo * 2, M.RadioCirculo * 2),
		en(0, 0.16, 0) * CFrame.Angles(0, 0, math.pi / 2),
		"Acento",
		Enum.Material.Neon,
		false
	)
	anillo.Shape = Enum.PartType.Cylinder
	local adentro = pieza(
		carpeta,
		Vector3.new(0.1, M.RadioCirculo * 2 - 2, M.RadioCirculo * 2 - 2),
		en(0, 0.2, 0) * CFrame.Angles(0, 0, math.pi / 2),
		"Hormigon",
		Enum.Material.Concrete,
		false
	)
	adentro.Shape = Enum.PartType.Cylinder
	for i = 0, 3 do
		local a = math.rad(45 + i * 90)
		local d = M.RadioCirculo + 12
		pieza(
			carpeta,
			Vector3.new(14, 3.4, 3),
			en(math.cos(a) * d, 1.7, math.sin(a) * d) * CFrame.Angles(0, -a + math.pi / 2, 0),
			"Hormigon",
			Enum.Material.Concrete
		)
	end
end

-- Dos torres, rampas y una pasarela que cruza por encima del círculo.
local function pasarela()
	local alto = ALTO_C * 2
	local x = M.TorreX
	for _, lado in { -1, 1 } do
		contenedor(lado * x, -6, 0, 0, "Azul")
		contenedor(lado * x, 2, 0, 0, "Verde")
		contenedor(lado * x, -6, 1, 0, "Rojo")
		contenedor(lado * x, 2, 1, 0, "Gris")
		local largo = 46
		local rampa = Instance.new("WedgePart")
		rampa.Anchored = true
		rampa.Size = Vector3.new(16, alto, largo)
		rampa.CFrame = en(lado * x, alto / 2, 6 + largo / 2) * CFrame.Angles(0, math.pi, 0)
		rampa.Color = color("Acero")
		rampa.Material = Enum.Material.DiamondPlate
		rampa.CanTouch = false
		rampa.Parent = carpeta
	end
	pieza(
		carpeta,
		Vector3.new(x * 2 - LARGO_C, 1, 10),
		en(0, alto - 0.5, -2),
		"Acero",
		Enum.Material.DiamondPlate
	)
	for _, lado in { -1, 1 } do
		pieza(
			carpeta,
			Vector3.new(x * 2 - LARGO_C, 0.4, 0.4),
			en(0, alto + 3, -2 + lado * 5),
			"Sodio",
			Enum.Material.Metal
		)
		for i = -3, 3 do
			pieza(
				carpeta,
				Vector3.new(0.4, 3, 0.4),
				en(i * (x / 3.5), alto + 1.5, -2 + lado * 5),
				"Acero",
				Enum.Material.Metal,
				false
			)
		end
	end
	for _, px in { -M.TorreX / 2, M.TorreX / 2 } do
		pieza(
			carpeta,
			Vector3.new(2, alto, 2),
			en(px, alto / 2, -2),
			"Oxido",
			Enum.Material.CorrodedMetal
		)
	end
end

-- Paredes altas e invisibles: nadie se cae del mapa. El lado del mar se deja ver con baranda.
local function bordes()
	fila(-MEDIO_X + 11, MEDIO_Z - 4, 22, 0, 13, 0)
	fila(-MEDIO_X + 4, -MEDIO_Z + 40, 0, 22, 9, 90)
	fila(MEDIO_X - 4, -MEDIO_Z + 40, 0, 22, 9, 90)
	for x = -MEDIO_X, MEDIO_X, 14 do
		pieza(
			carpeta,
			Vector3.new(1.6, 3.4, 1.6),
			en(x, 1.7, -MEDIO_Z + 1),
			"Sodio",
			Enum.Material.Metal
		)
	end
	pieza(
		carpeta,
		Vector3.new(M.Ancho, 0.5, 0.5),
		en(0, 3, -MEDIO_Z + 1),
		"Sodio",
		Enum.Material.Metal
	)
	local muros = {
		{ Vector3.new(M.Ancho, 90, 2), 0, -MEDIO_Z },
		{ Vector3.new(M.Ancho, 90, 2), 0, MEDIO_Z },
		{ Vector3.new(2, 90, M.Largo), -MEDIO_X, 0 },
		{ Vector3.new(2, 90, M.Largo), MEDIO_X, 0 },
	}
	for _, d in muros do
		local p = pieza(carpeta, d[1], en(d[2], 45, d[3]), "Asfalto", Enum.Material.SmoothPlastic)
		p.Transparency = 1
		p.CastShadow = false
		p.CanQuery = false
	end
end

local function zonaSegura()
	local c = Config.Arena.ZonaCentro - O
	pieza(
		carpeta,
		Vector3.new(30, 0.1, 30),
		en(c.X, 0.17, c.Z),
		"Hormigon",
		Enum.Material.Concrete,
		false
	)
	local inicio = workspace:FindFirstChild("SpawnLocation")
	if inicio and inicio:IsA("BasePart") then
		inicio.Position = Config.Arena.ZonaCentro + Vector3.new(0, 0.5, 0)
	end
end

local function letrero()
	local base = pieza(
		carpeta,
		Vector3.new(44, 7, 1),
		en(0, 26, MEDIO_Z - 8.5),
		"Asfalto",
		Enum.Material.Metal
	)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = base
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Font = Enum.Font.GothamBlack
	texto.Text = "PUERTO ÓXIDO"
	texto.TextScaled = true
	texto.TextColor3 = color("Acento")
	texto.Parent = gui
end

piso()
circulo()
pasarela()
bordes()
zonaSegura()
letrero()

for _, g in M.Grupos do
	local x, z = g[1], g[2]
	local sx, sz = if x < 0 then 1 else -1, if z < 0 then 1 else -1
	contenedor(x, z, 0, 0, "Rojo")
	contenedor(x + sx * 15, z + sz * 14, 0, 90, "Azul")
	contenedor(x, z, 1, 0, "Gris")
	caja(x - sx * 14, z, 4.5)
	caja(x - sx * 14, z + sz * 5, 3)
	barriles(x + sx * 4, z + sz * 16)
end

for _, f in M.Faroles do
	farol(f[1], f[2], f[3] == 1)
end

carpeta.Parent = workspace
