--!strict
-- Arma el rincón del puerto con la dirección de arte del 7 nov (ver boveda/02 Estilo).
-- Lo llama ArenaRincon.server.luau. También se puede correr desde Edit para dejar las
-- piezas en workspace.Rincon y acomodarlas a mano: si al lado de este módulo hay una
-- copia de "Shared", usa esa (en Edit los require viejos quedan en caché).
-- Valores en shared/Iluminacion.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local alLado = script.Parent and script.Parent:FindFirstChild("Shared")
local Shared = (alLado or ReplicatedStorage:WaitForChild("Shared")) :: Instance
local Config = require((Shared:FindFirstChild("Config") :: any) :: ModuleScript) :: any
local Luz = require((Shared:FindFirstChild("Iluminacion") :: any) :: ModuleScript) :: any

local O = Config.Arena.Mapa.Centro
local R = Luz.Rincon
local PISO = 0.12 -- alto de la cara de arriba del piso de la arena

local Modulo = {}

function Modulo.armar(): Folder
	local kit = ServerStorage:WaitForChild("ArenaKit")
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Rincon"

	local function en(x: number, y: number, z: number): CFrame
		return CFrame.new(O + Vector3.new(R.X + x, y, R.Z + z))
	end

	local function suelta(
		tam: Vector3,
		cf: CFrame,
		hex: string,
		material: Enum.Material,
		sombrea: boolean?
	): Part
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = sombrea == true
		p.Size = tam
		p.CFrame = cf
		p.Color = Color3.fromHex(hex)
		p.Material = material
		p.Parent = carpeta
		return p
	end

	-- Imagen acostada en el piso: charco, reflejo de una luz o sombra de contacto.
	local function calco(
		cf: CFrame,
		ancho: number,
		largo: number,
		imagen: string,
		tono: string,
		fuerza: number
	)
		local p =
			suelta(Vector3.new(ancho, 0.05, largo), cf, "#000000", Enum.Material.SmoothPlastic)
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

	-- Mancha oscura debajo de un objeto, para que apoye en el piso y no flote.
	local function sombra(p: BasePart, crece: number, fuerza: number)
		local tam = p.Size
		calco(
			CFrame.new(Vector3.new(p.Position.X, O.Y + PISO + 0.02, p.Position.Z)),
			tam.X * crece,
			tam.Z * crece,
			Luz.Texturas.Sombra,
			"#000000",
			fuerza
		)
	end

	local function poner(nombre: string, cf: CFrame, tono: string?, escala: number?): MeshPart
		local molde = kit:FindFirstChild(nombre, true) :: MeshPart
		local p = molde:Clone()
		p.Anchored = true
		p.CastShadow = true
		if escala then
			p.Size *= escala
		end
		p.CFrame = cf * (molde.CFrame - molde.CFrame.Position)
		local capa = p:FindFirstChildOfClass("SurfaceAppearance")
		if capa and tono then
			capa.Color = Color3.fromHex(tono)
		end
		p.Parent = carpeta
		return p
	end

	-- Haz de luz en la niebla: dos cintas cruzadas que se abren hacia abajo.
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

	-- Lámpara chica que emite un poco; la luz de verdad la hace el SpotLight hacia abajo.
	local function foco(cf: CFrame, datos: any, lampara: boolean): Part
		local L = R.Lampara
		local tam = if lampara
			then Vector3.new(L.Ancho, L.Alto, L.Largo)
			else Vector3.new(2.4, 0.8, 1.4)
		local p = suelta(tam, cf, if lampara then L.Tono else datos.Color, Enum.Material.Neon)
		p.Transparency = if lampara then L.Transparencia else 0.15
		local l = Instance.new("SpotLight")
		l.Face = Enum.NormalId.Bottom
		l.Color = Color3.fromHex(datos.Color)
		l.Brightness = datos.Brillo
		l.Range = datos.Alcance
		l.Angle = datos.Angulo
		l.Shadows = true
		l.Parent = p
		return p
	end

	-- Pila de contenedores contra el fondo, en tonos apagados. Sin ventanas ni luces.
	local pila = {
		{ 6, 4.5, 15, 4, R.Tonos[1] },
		{ -13, 4.5, 15, -3, R.Tonos[2] },
		{ -3, 13.5, 15, 8, R.Tonos[3] },
	}
	for _, c in pila do
		local p =
			poner("Contenedor", en(c[1], c[2], c[3]) * CFrame.Angles(0, math.rad(c[4]), 0), c[5])
		if c[2] < 10 then
			sombra(p, 1.25, 0.8)
		end
	end

	sombra(poner("Prop_Cajones", en(15, 4.1, 2) * CFrame.Angles(0, math.rad(24), 0)), 1.5, 0.75)
	sombra(poner("Prop_Barril", en(9, 1.65, -3), R.TonoBarril), 2.1, 0.7)
	sombra(
		poner("Prop_Barril", en(12, 1.65, -6) * CFrame.Angles(0, 0, math.rad(90)), R.TonoBarril),
		1.8,
		0.7
	)
	sombra(poner("Prop_Bita", en(-6, 1.1, -19), R.TonoBita), 2.4, 0.65)
	sombra(poner("Prop_Bita", en(14, 1.1, -19), R.TonoBita), 2.4, 0.65)

	-- Pared de galpón con una ventana de verdad: marco oscuro, cruz y vidrio cálido.
	for i = -1, 1 do
		poner("Galpon_Pared", en(-20, 9, 2 + i * 12), nil, 1.5)
	end
	local vidrio =
		suelta(Vector3.new(0.3, 4, 5.2), en(-18.9, 10.5, 2), R.Ventana, Enum.Material.Neon)
	vidrio.Transparency = 0.35
	local marco = {
		{ 0, 0, 4.4, 0.35 },
		{ 0, 0, 0.35, 5.6 },
		{ 2.2, 0, 0.4, 5.6 },
		{ -2.2, 0, 0.4, 5.6 },
		{ 0, 2.8, 4.8, 0.4 },
		{ 0, -2.8, 4.8, 0.4 },
	}
	for _, m in marco do
		suelta(
			Vector3.new(0.5, m[3], m[4]),
			en(-18.9, 10.5 + m[1], 2 + m[2]),
			"#1b1f26",
			Enum.Material.Metal
		)
	end
	local calida = Instance.new("SurfaceLight")
	calida.Face = Enum.NormalId.Right
	calida.Color = Color3.fromHex(R.Ventana)
	calida.Brightness = 3
	calida.Range = 20
	calida.Angle = 110
	calida.Parent = vidrio

	-- Farola de sodio: cono naranja en el piso y charco de luz.
	local fx, fz = R.Farola.X, R.Farola.Z
	local poste = poner("Prop_Farola", en(fx, 11, fz), nil, 1.5)
	sombra(poste, 1.4, 0.6)
	foco(en(fx, 20.2, fz), Luz.Calida, true)
	haz(
		O + Vector3.new(R.X + fx, 20, R.Z + fz),
		O + Vector3.new(R.X + fx, O.Y + PISO, R.Z + fz),
		1.2,
		14,
		Luz.Calida
	)

	-- Reflector de la grúa: luz fría que cruza la niebla en diagonal.
	local rf = R.Reflector
	foco(en(rf.X, rf.Y, rf.Z) * CFrame.Angles(math.rad(rf.Inclina), 0, 0), Luz.Fria, false)
	haz(
		O + Vector3.new(R.X + rf.X, rf.Y, R.Z + rf.Z),
		O + Vector3.new(R.X + rf.DestinoX, O.Y + PISO, R.Z + rf.DestinoZ),
		2,
		16,
		Luz.Fria
	)

	-- Charcos y reflejos alargados de cada luz.
	for _, c in R.Charcos do
		calco(
			en(c[1], PISO + 0.05, c[2]) * CFrame.Angles(0, math.rad(c[5]), 0),
			c[3],
			c[4],
			Luz.Texturas.Charco,
			"#ffffff",
			0.9
		)
	end
	calco(en(fx, PISO + 0.08, fz + 7), 8, 18, Luz.Texturas.Reflejo, Luz.Calida.Color, 0.5)
	calco(
		en(rf.DestinoX, PISO + 0.08, rf.DestinoZ),
		10,
		18,
		Luz.Texturas.Reflejo,
		Luz.Fria.Color,
		0.4
	)
	calco(en(-13, PISO + 0.08, 2), 16, 6, Luz.Texturas.Reflejo, R.Ventana, 0.35)

	-- Agua del puerto: ancha y oscura, se funde con la niebla a lo lejos.
	local agua = suelta(
		Vector3.new(2200, 1, 1200),
		CFrame.new(O + Vector3.new(0, -3, -740)),
		"#0a111d",
		Enum.Material.Glass
	)
	agua.Reflectance = 0.08
	agua.Transparency = 0.05

	return carpeta
end

return Modulo
