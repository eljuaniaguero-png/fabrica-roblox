--!strict
-- La sala (etapa 7b, rehecha el 26/10 con las capturas nuevas de Juani): una celda chica y sucia
-- como CloverPit con toques futuristas de neón como FNAF Security Breach. Todo con partes por
-- código (vive en git); medidas y colores en Config.Sala.
--   - pared norte: la mesa de trabajo con tu máquina arriba (tag "Maquina", atributo Indice; su
--     pantalla con tag "Pantalla"), la banqueta y "E: Jugar"; cosas sobre la mesa; un estante;
--     el cartel de las clavijas pegado en la pared; el ventilador;
--   - pared oeste: la terminal de la tienda (tag "Tienda", "E: Elegir bola");
--   - pared este: la puerta de metal y el tablero LED de récords (tag "Records");
--   - pared sur: el pedestal donde server/Sala pone la estatua de tu avatar;
--   - techo: un tubo fluorescente.
-- Etapa 10c (27/10, sala neón: CloverPit + arcade de los 80): piso damero oscuro que refleja,
-- paneles acústicos en las paredes sur y oeste, flechas de neón que apuntan a la máquina, una
-- espada y un tablerito de neón en la pared sur, columnas de neón en las 4 esquinas, franjas LED
-- magenta al lado de la terminal (su display muestra tu MEJOR: lo escribe server/Sala), la
-- vitrina de reliquias (tag "VitrinaReliquias": server/Sala prende las gemas) y la puerta
-- blindada (tag "Compuerta": se abre al ganar la mazmorra, la anima client/Sala).
-- Caras: la parte frontal de Roblox (NormalId.Front) mira a -Z.

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local GeneradorSala = {}

local S = Config.Sala
local C = S.Colores

local function parte(
	nombre: string,
	padre: Instance,
	tamanio: Vector3,
	cframe: CFrame,
	hex: string,
	material: Enum.Material?,
	solida: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Anchored = true
	p.Size = tamanio
	p.CFrame = cframe
	p.Color = Color3.fromHex(hex)
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = false
	p.CanCollide = solida == true
	p.CanTouch = false
	p.CanQuery = solida == true
	p.Parent = padre
	return p
end

local function luz(en: BasePart, hex: string, brillo: number, alcance: number)
	local l = Instance.new("PointLight")
	l.Color = Color3.fromHex(hex)
	l.Brightness = brillo
	l.Range = alcance
	l.Shadows = false
	l.Parent = en
end

local function neon(
	nombre: string,
	padre: Instance,
	tamanio: Vector3,
	cframe: CFrame,
	hex: string,
	conLuz: boolean?
): Part
	local p = parte(nombre, padre, tamanio, cframe, hex, Enum.Material.Neon)
	if conLuz then
		luz(p, hex, S.LuzNeon.Brillo, S.LuzNeon.Alcance)
	end
	return p
end

-- Texto de display LED naranja (CloverPit) en una cara.
local function led(en: BasePart, cara: Enum.NormalId, texto: string, hex: string?): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = en
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.fromScale(0.05, 0.1)
	t.Size = UDim2.fromScale(0.9, 0.8)
	t.Font = Enum.Font.Arcade
	t.TextScaled = true
	t.TextColor3 = Color3.fromHex(hex or C.Led)
	t.Text = texto
	t.Parent = gui
	return t
end

-- Franjas de peligro amarillas y negras en una cara (diagonales).
local function peligro(en: BasePart, cara: Enum.NormalId)
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.LightInfluence = 1
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.ClipsDescendants = true
	gui.Parent = en
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.fromHex(C.MetalOscuro)
	fondo.BorderSizePixel = 0
	fondo.ClipsDescendants = true
	fondo.Parent = gui
	for i = -6, 16 do
		local franja = Instance.new("Frame")
		franja.AnchorPoint = Vector2.new(0.5, 0.5)
		franja.Position = UDim2.fromScale(i * 0.09, 0.5)
		franja.Size = UDim2.fromScale(0.045, 3)
		franja.Rotation = 35
		franja.BackgroundColor3 = Color3.fromHex(C.Peligro)
		franja.BorderSizePixel = 0
		franja.Parent = fondo
	end
end

-- Cartel de papel pegado en la pared (como los de CloverPit) con un título y renglones.
-- renglones: { { texto, colorHex? } }.
local function cartelPapel(
	padre: Instance,
	cf: CFrame,
	tamanio: Vector2,
	titulo: string,
	renglones: { { string } }
)
	local p = parte(
		"Cartel",
		padre,
		Vector3.new(tamanio.X, tamanio.Y, 0.1),
		cf,
		C.Papel,
		Enum.Material.Fabric
	)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- el cartel está en la pared norte: la cara de atrás mira a la sala
	gui.LightInfluence = 0.8
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.Parent = p
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.fromScale(0.05, 0.03)
	t.Size = UDim2.fromScale(0.9, 0.14)
	t.Font = Enum.Font.Oswald
	t.TextScaled = true
	t.TextColor3 = Color3.fromHex("#2A2418")
	t.Text = titulo
	t.Parent = gui
	local alto = 0.78 / math.max(#renglones, 1)
	for i, r in renglones do
		local punto = Instance.new("Frame")
		punto.AnchorPoint = Vector2.new(0.5, 0.5)
		punto.Position = UDim2.fromScale(0.1, 0.2 + (i - 0.5) * alto)
		punto.Size = UDim2.fromScale(0.07, alto * 0.55)
		punto.SizeConstraint = Enum.SizeConstraint.RelativeYY
		punto.BackgroundColor3 = Color3.fromHex(r[2] or "#2A2418")
		punto.BorderSizePixel = 0
		punto.Visible = r[2] ~= nil
		punto.Parent = gui
		local redondo = Instance.new("UICorner")
		redondo.CornerRadius = UDim.new(0.5, 0)
		redondo.Parent = punto
		local renglon = Instance.new("TextLabel")
		renglon.BackgroundTransparency = 1
		renglon.Position = UDim2.fromScale(0.17, 0.2 + (i - 1) * alto)
		renglon.Size = UDim2.fromScale(0.8, alto)
		renglon.Font = Enum.Font.Oswald
		renglon.TextScaled = true
		renglon.TextXAlignment = Enum.TextXAlignment.Left
		renglon.TextColor3 = Color3.fromHex("#2A2418")
		renglon.Text = r[1]
		renglon.Parent = gui
	end
	return p
end

-- Cartel iluminado (27/10): fondo con degradé de dos colores y texto blanco con borde.
local function cartelLuz(
	en: BasePart,
	cara: Enum.NormalId,
	texto: string,
	hexA: string,
	hexB: string
)
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.Parent = en
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.new(1, 1, 1)
	fondo.BorderSizePixel = 0
	fondo.Parent = gui
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Color3.fromHex(hexA), Color3.fromHex(hexB))
	degrade.Parent = fondo
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.fromScale(0.04, 0.12)
	t.Size = UDim2.fromScale(0.92, 0.76)
	t.Font = Enum.Font.Michroma
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeColor3 = Color3.fromHex("#140A1E")
	t.TextStrokeTransparency = 0
	t.Text = texto
	t.Parent = fondo
	-- Rayitas horizontales encima, como un cartel de tubos.
	for k = 1, 7 do
		local r = Instance.new("Frame")
		r.Position = UDim2.fromScale(0, k / 8)
		r.Size = UDim2.new(1, 0, 0, 2)
		r.BackgroundColor3 = Color3.new(0, 0, 0)
		r.BackgroundTransparency = 0.8
		r.BorderSizePixel = 0
		r.ZIndex = 2
		r.Parent = fondo
	end
end

-- Rejilla de parlante o ventilación: agujeritos redondos en una cara.
local function rejilla(en: BasePart, cara: Enum.NormalId)
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.LightInfluence = 1
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = en
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.fromHex(C.MetalOscuro)
	fondo.BorderSizePixel = 0
	fondo.Parent = gui
	local rejas = Instance.new("UIGridLayout")
	rejas.CellSize = UDim2.fromOffset(4, 4)
	rejas.CellPadding = UDim2.fromOffset(4, 4)
	rejas.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rejas.VerticalAlignment = Enum.VerticalAlignment.Center
	rejas.Parent = fondo
	for _ = 1, 120 do
		local a = Instance.new("Frame")
		a.BackgroundColor3 = Color3.fromHex("#030303")
		a.BorderSizePixel = 0
		a.Parent = fondo
		local r = Instance.new("UICorner")
		r.CornerRadius = UDim.new(0.5, 0)
		r.Parent = a
	end
end

-- Botón de arcade: aro negro y cúpula de color. cf: centro de la base, mirando hacia arriba (Y).
local function botonArcade(
	padre: Instance,
	nombre: string,
	cf: CFrame,
	diametro: number,
	hex: string
)
	local aro = parte(
		nombre .. "Aro",
		padre,
		Vector3.new(0.12, diametro * 1.3, diametro * 1.3),
		cf * CFrame.Angles(0, 0, math.rad(90)),
		"#0A0A0C",
		Enum.Material.SmoothPlastic
	)
	aro.Shape = Enum.PartType.Cylinder
	local cupula = parte(
		nombre,
		padre,
		Vector3.new(diametro, diametro * 0.75, diametro),
		cf * CFrame.new(0, 0.08, 0),
		hex,
		Enum.Material.SmoothPlastic
	)
	cupula.Shape = Enum.PartType.Ball
	cupula.Reflectance = 0.2
	return cupula
end

-- Remaches en las esquinas de una cara (cilindros chiquitos).
local function remaches(padre: Instance, centro: CFrame, ancho: number, alto: number)
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			local r = parte(
				"Remache",
				padre,
				Vector3.new(0.06, 0.14, 0.14),
				centro
					* CFrame.new(x * ancho / 2, y * alto / 2, 0)
					* CFrame.Angles(0, math.rad(90), 0),
				"#8A8A80",
				Enum.Material.Metal
			)
			r.Shape = Enum.PartType.Cylinder
		end
	end
end

-- Tu máquina (27/10, "modelos más lindos"): un gabinete arcade de mesa. Base de chapa con
-- franjas y "JUGAR" en LED, laterales negros brillantes con filo de neón y remaches, tablero de
-- botones inclinado (joystick, 3 botones chicos y el grande rojo), pantalla hundida en un bisel y
-- marquesina iluminada arriba. Base en `cf`, frente hacia cf.LookVector (-Z local).
local function maquina(padre: Instance, cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "Maquina1"
	local t = S.MaquinaTamanio
	local w, h, d = t.X, t.Y, t.Z
	local frente = -(d / 2)
	local function L(x: number, y: number, z: number): CFrame
		return cf * CFrame.new(x, y, z)
	end

	-- Base (con el "E: Jugar").
	local cuerpo = parte(
		"Cuerpo",
		m,
		Vector3.new(w - 0.3, 1.2, d),
		L(0, 0.6, 0),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	m.PrimaryPart = cuerpo
	local zocalo = parte(
		"Franja",
		m,
		Vector3.new(w - 0.3, 0.32, 0.05),
		L(0, 0.18, frente - 0.03),
		C.MetalOscuro
	)
	peligro(zocalo, Enum.NormalId.Front)
	local cartelJugar =
		parte("CartelJugar", m, Vector3.new(1.8, 0.42, 0.05), L(0, 0.72, frente - 0.03), "#050505")
	led(cartelJugar, Enum.NormalId.Front, "- JUGAR -")
	for _, x in { -1.45, 1.45 } do
		local parlante = parte(
			"Parlante",
			m,
			Vector3.new(0.7, 0.55, 0.05),
			L(x, 0.72, frente - 0.03),
			C.MetalOscuro
		)
		rejilla(parlante, Enum.NormalId.Front)
	end

	-- Parte de arriba, un poco más atrás (ahí va la pantalla).
	parte(
		"Gabinete",
		m,
		Vector3.new(w - 0.3, h - 1.2, d * 0.6),
		L(0, 1.2 + (h - 1.2) / 2, d * 0.2),
		C.Metal,
		Enum.Material.Metal
	)

	-- Laterales negros brillantes, con filo de neón adelante y remaches.
	for _, lado in { -1, 1 } do
		local x = lado * (w / 2 - 0.075)
		local lateral = parte(
			"Lateral",
			m,
			Vector3.new(0.15, h, d),
			L(x, h / 2, 0),
			"#141416",
			Enum.Material.SmoothPlastic,
			true
		)
		lateral.Reflectance = 0.12
		neon(
			"Borde",
			m,
			Vector3.new(0.18, h, 0.08),
			L(x, h / 2, frente - 0.02),
			if lado < 0 then C.Magenta else C.Cian
		)
		remaches(
			m,
			L(lado * (w / 2 + 0.005), h / 2, 0) * CFrame.Angles(0, math.rad(90), 0),
			d - 0.5,
			h - 0.5
		)
	end

	-- Tablero de botones, inclinado hacia vos.
	local deck = L(0, 1.42, frente + 0.72) * CFrame.Angles(math.rad(-15), 0, 0)
	parte(
		"Botonera",
		m,
		Vector3.new(w - 0.3, 0.2, 1.45),
		deck,
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	neon(
		"FiloBotonera",
		m,
		Vector3.new(w - 0.3, 0.07, 0.07),
		deck * CFrame.new(0, -0.02, -0.74),
		C.Magenta
	)
	local arribaDeck = deck * CFrame.new(0, 0.1, 0)
	botonArcade(m, "Boton", arribaDeck * CFrame.new(1.25, 0, 0.05), 0.75, C.Boton)
	for k, hex in { C.Peligro, C.Cian, C.Magenta } do
		botonArcade(
			m,
			"BotonChico",
			arribaDeck * CFrame.new(-0.75 + (k - 1) * 0.55, 0, 0.15),
			0.4,
			hex
		)
	end
	do
		local base = arribaDeck * CFrame.new(-1.5, 0, 0)
		local placa = parte(
			"BaseJoystick",
			m,
			Vector3.new(0.1, 0.55, 0.55),
			base * CFrame.Angles(0, 0, math.rad(90)),
			"#0A0A0C"
		)
		placa.Shape = Enum.PartType.Cylinder
		parte(
			"Joystick",
			m,
			Vector3.new(0.09, 0.55, 0.09),
			base * CFrame.new(0, 0.3, 0),
			"#9A9A90",
			Enum.Material.Metal
		)
		local bola = parte(
			"BolaJoystick",
			m,
			Vector3.new(0.38, 0.38, 0.38),
			base * CFrame.new(0, 0.6, 0),
			C.Boton
		)
		bola.Shape = Enum.PartType.Ball
		bola.Reflectance = 0.2
	end

	-- Pantalla hundida en un bisel negro.
	local alto = 2.62
	local zPantalla = d * 0.2 - d * 0.3 -- cara de adelante del gabinete
	local pw, ph = S.PantallaTamanio.X, S.PantallaTamanio.Y
	parte(
		"Marco",
		m,
		Vector3.new(pw + 0.4, ph + 0.4, 0.1),
		L(0, alto, zPantalla - 0.05),
		"#08080A",
		Enum.Material.Metal
	)
	for _, lado in { -1, 1 } do
		parte(
			"Bisel",
			m,
			Vector3.new(pw + 0.4, 0.16, 0.3),
			L(0, alto + lado * (ph / 2 + 0.12), zPantalla - 0.2),
			"#0A0A0C",
			Enum.Material.Metal
		)
		parte(
			"Bisel",
			m,
			Vector3.new(0.16, ph + 0.4, 0.3),
			L(lado * (pw / 2 + 0.12), alto, zPantalla - 0.2),
			"#0A0A0C",
			Enum.Material.Metal
		)
	end
	local pantalla = parte(
		"Pantalla",
		m,
		S.PantallaTamanio,
		L(0, alto, zPantalla - 0.12),
		C.Pantalla,
		Enum.Material.Neon
	)
	CollectionService:AddTag(pantalla, "Pantalla")
	luz(pantalla, C.Cian, 0.8, 7)
	-- Lo que muestra mientras no estás sentado: el logo, las clavijas y rayitas de monitor viejo.
	do
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.LightInfluence = 0
		gui.CanvasSize = Vector2.new(320, 210)
		gui.Parent = pantalla
		local titulo = Instance.new("TextLabel")
		titulo.BackgroundTransparency = 1
		titulo.Position = UDim2.fromScale(0.05, 0.06)
		titulo.Size = UDim2.fromScale(0.9, 0.24)
		titulo.Font = Enum.Font.Arcade
		titulo.TextScaled = true
		titulo.TextColor3 = Color3.fromHex(C.Led)
		titulo.Text = "PLINKO KNIGHT"
		titulo.Parent = gui
		for fila = 0, 3 do
			for col = 0, 6 - fila % 2 do
				local punto = Instance.new("Frame")
				punto.Name = "Punto"
				punto.AnchorPoint = Vector2.new(0.5, 0.5)
				punto.Position =
					UDim2.fromScale(0.14 + col * 0.12 + (fila % 2) * 0.06, 0.42 + fila * 0.15)
				punto.Size = UDim2.fromOffset(8, 8)
				punto.BackgroundColor3 = Color3.fromHex(Config.Colores.Oro)
				punto.BorderSizePixel = 0
				punto.Parent = gui
				local r = Instance.new("UICorner")
				r.CornerRadius = UDim.new(0.5, 0)
				r.Parent = punto
			end
		end
		for k = 0, 34 do
			local raya = Instance.new("Frame")
			raya.Position = UDim2.fromOffset(0, k * 6)
			raya.Size = UDim2.new(1, 0, 0, 2)
			raya.BackgroundColor3 = Color3.new(0, 0, 0)
			raya.BackgroundTransparency = 0.75
			raya.BorderSizePixel = 0
			raya.ZIndex = 3
			raya.Parent = gui
		end
	end

	-- Marquesina iluminada arriba, con tubos de neón arriba y abajo.
	parte(
		"Marquesina",
		m,
		Vector3.new(w + 0.1, 0.95, 1.2),
		L(0, h + 0.47, -0.2),
		"#0A0A0C",
		Enum.Material.Metal
	)
	local cartel =
		parte("Cartel", m, Vector3.new(w - 0.2, 0.72, 0.05), L(0, h + 0.47, -0.82), "#050505")
	cartelLuz(cartel, Enum.NormalId.Front, "PLINKO KNIGHT", C.Magenta, "#7A2CF5")
	luz(cartel, C.Magenta, 1, 8)
	neon("TuboMarquesina", m, Vector3.new(w + 0.1, 0.08, 0.08), L(0, h + 0.02, -0.84), C.Cian)
	neon("TuboMarquesina", m, Vector3.new(w + 0.1, 0.08, 0.08), L(0, h + 0.92, -0.84), C.Cian)

	-- Palanca al costado derecho, con bocha roja.
	local base = cf * CFrame.new(w / 2 + 0.25, h * 0.45, frente + 0.8)
	parte(
		"Eje",
		m,
		Vector3.new(0.3, 0.5, 0.5),
		base * CFrame.new(-0.1, 0, 0),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	parte(
		"Palanca",
		m,
		Vector3.new(0.16, 2, 0.16),
		base * CFrame.new(0, 0.9, 0) * CFrame.Angles(math.rad(-20), 0, 0),
		"#9A9A90",
		Enum.Material.Metal
	)
	local bocha =
		parte("Bocha", m, Vector3.new(0.6, 0.6, 0.6), base * CFrame.new(0, 1.9, 0.35), C.Boton)
	bocha.Shape = Enum.PartType.Ball
	bocha.Reflectance = 0.2

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Jugar"
	prompt.ActionText = "Jugar"
	prompt.ObjectText = "Plinko Knight"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = S.DistanciaJugar
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false -- se prende solo para el dueño (lo hace el cliente)
	prompt.Parent = cuerpo
	m:SetAttribute("Indice", 1)
	m:SetAttribute("Dueno", 0)
	CollectionService:AddTag(m, "Maquina")
	m.Parent = padre
	return m
end

-- Renglones del cartel de clavijas, con los números de Config (nivel 1).
local function renglonesClavijas(): { { string } }
	local K = Config.Clavijas
	return {
		{ ("DORADA  +%d FUERZA"):format(K.gris.Fuerza), K.gris.Color },
		{ ("ROJA  +%d MULTI"):format(K.roja.Multi), K.roja.Color },
		{ ("AZUL  x%d MULTI (SE PUEDE ROMPER)"):format(K.azul.PorMulti), K.azul.Color },
		{ ("NARANJA  +%d FUERZA  +%d ORO"):format(K.dorada.Fuerza, K.dorada.Oro), K.dorada.Color },
		{ ("VERDE  +%d FUERZA Y REBOTA"):format(K.verde.Fuerza), K.verde.Color },
		{ ("VIOLETA  LA PROXIMA CUENTA x%d"):format(K.violeta.Eco), K.violeta.Color },
		{ "GOLPE = FUERZA x MULTI" },
	}
end

function GeneradorSala.generar(): Folder
	local vieja = Workspace:FindFirstChild("Sala")
	if vieja then
		vieja:Destroy()
	end
	local sala = Instance.new("Folder")
	sala.Name = "Sala"
	local medioX, medioZ = S.Ancho / 2, S.Largo / 2

	-- Piso de concreto sucio con una grilla de neón apagada (lo futurista).
	local piso = parte(
		"Piso",
		sala,
		Vector3.new(S.Ancho, 1, S.Largo),
		CFrame.new(0, -0.45, 0),
		C.Piso,
		Enum.Material.Concrete,
		true
	)
	piso.Reflectance = S.ReflejoPiso
	-- Etapa 10c: baldosas oscuras en damero que reflejan un poco el neón.
	local ladoBaldosa = S.Baldosa
	for i = 0, S.Ancho / ladoBaldosa - 1 do
		for j = 0, S.Largo / ladoBaldosa - 1 do
			local b = parte(
				"Baldosa",
				sala,
				Vector3.new(ladoBaldosa - 0.04, 0.05, ladoBaldosa - 0.04),
				CFrame.new(
					-medioX + (i + 0.5) * ladoBaldosa,
					0.075,
					-medioZ + (j + 0.5) * ladoBaldosa
				),
				if (i + j) % 2 == 0 then C.DameroA else C.DameroB
			)
			b.Reflectance = S.ReflejoDamero
		end
	end

	-- Paredes de concreto oscuro y techo de chapa.
	parte(
		"Techo",
		sala,
		Vector3.new(S.Ancho, 1, S.Largo),
		CFrame.new(0, S.Alto + 0.5, 0),
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	parte(
		"ParedNorte",
		sala,
		Vector3.new(S.Ancho, S.Alto, 1),
		CFrame.new(0, S.Alto / 2, -medioZ - 0.5),
		C.Pared,
		Enum.Material.Concrete,
		true
	)
	parte(
		"ParedSur",
		sala,
		Vector3.new(S.Ancho, S.Alto, 1),
		CFrame.new(0, S.Alto / 2, medioZ + 0.5),
		C.Pared,
		Enum.Material.Concrete,
		true
	)
	parte(
		"ParedOeste",
		sala,
		Vector3.new(1, S.Alto, S.Largo),
		CFrame.new(-medioX - 0.5, S.Alto / 2, 0),
		C.Pared,
		Enum.Material.Concrete,
		true
	)
	parte(
		"ParedEste",
		sala,
		Vector3.new(1, S.Alto, S.Largo),
		CFrame.new(medioX + 0.5, S.Alto / 2, 0),
		C.Pared,
		Enum.Material.Concrete,
		true
	)
	-- Zócalo de metal abajo de todo.
	for _, z in { -medioZ + 0.05, medioZ - 0.05 } do
		parte(
			"Zocalo",
			sala,
			Vector3.new(S.Ancho, 1, 0.1),
			CFrame.new(0, 0.5, z),
			C.MetalOscuro,
			Enum.Material.DiamondPlate
		)
	end

	-- Tubo fluorescente en el techo (la luz principal de la celda) y tubos de neón en dos esquinas.
	local tubo = neon(
		"Fluorescente",
		sala,
		Vector3.new(4, 0.2, 0.35),
		CFrame.new(0, S.Alto - 0.25, -1),
		C.Fluor
	)
	luz(tubo, C.Fluor, 1.1, 20)
	parte(
		"Soporte",
		sala,
		Vector3.new(4.4, 0.15, 0.6),
		CFrame.new(0, S.Alto - 0.08, -1),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	neon(
		"Tubo",
		sala,
		Vector3.new(0.25, S.Alto, 0.25),
		CFrame.new(-medioX + 0.25, S.Alto / 2, -medioZ + 0.25),
		C.Magenta,
		true
	)
	neon(
		"Tubo",
		sala,
		Vector3.new(0.25, S.Alto, 0.25),
		CFrame.new(medioX - 0.25, S.Alto / 2, -medioZ + 0.25),
		C.Cian,
		true
	)

	for _, x in { -medioX + 0.25, medioX - 0.25 } do
		neon(
			"Tubo",
			sala,
			Vector3.new(0.25, S.Alto, 0.25),
			CFrame.new(x, S.Alto / 2, medioZ - 0.25),
			if x < 0 then C.Cian else C.Magenta,
			true
		)
	end

	-- Etapa 10c: paneles acústicos oscuros (pared sur entera y pared oeste sin la terminal).
	local function panelAcustico(cf: CFrame, k: number)
		local pa = parte(
			"PanelAcustico",
			sala,
			Vector3.new(1.8, 1.8, 0.16),
			cf,
			if k % 2 == 0 then C.PanelA else C.PanelB,
			Enum.Material.Fabric
		)
		pa.CastShadow = false
	end
	local cuenta = 0
	for x = -medioX + 1, medioX - 1, 2 do
		for y = 1.5, S.Alto - 1.5, 2 do
			cuenta += 1
			panelAcustico(CFrame.new(x, y, medioZ - 0.08), cuenta)
		end
	end
	for z = -medioZ + 1, medioZ - 1, 2 do
		if z > -2 and z < 4 then
			continue -- ahí va la terminal de la tienda
		end
		for y = 1.5, S.Alto - 1.5, 2 do
			cuenta += 1
			panelAcustico(
				CFrame.new(-medioX + 0.08, y, z) * CFrame.Angles(0, math.rad(90), 0),
				cuenta
			)
		end
	end

	-- Flechas de neón en las paredes oeste y este que apuntan a la máquina (hacia -Z).
	local function flecha(base: CFrame, hex: string)
		neon("Flecha", sala, Vector3.new(0.12, 0.12, 2.4), base, hex)
		local punta = base * CFrame.new(0, 0, -1.2)
		neon(
			"Flecha",
			sala,
			Vector3.new(0.12, 0.12, 0.9),
			punta * CFrame.Angles(math.rad(-45), 0, 0) * CFrame.new(0, 0, 0.42),
			hex
		)
		neon(
			"Flecha",
			sala,
			Vector3.new(0.12, 0.12, 0.9),
			punta * CFrame.Angles(math.rad(45), 0, 0) * CFrame.new(0, 0, 0.42),
			hex
		)
	end
	flecha(CFrame.new(-medioX + 0.22, 7.6, -4.6), C.Cian)
	flecha(CFrame.new(medioX - 0.22, 8.4, -3.5), C.Magenta)

	-- Siluetas de neón en la pared sur: una espada y un tablerito con su bola.
	do
		local zs = medioZ - 0.2
		neon("Silueta", sala, Vector3.new(0.16, 3, 0.08), CFrame.new(-1.6, 6.3, zs), C.Magenta)
		neon("Silueta", sala, Vector3.new(1.5, 0.16, 0.08), CFrame.new(-1.6, 4.75, zs), C.Magenta)
		neon("Silueta", sala, Vector3.new(0.16, 0.8, 0.08), CFrame.new(-1.6, 4.25, zs), C.Magenta)
		neon("Silueta", sala, Vector3.new(0.35, 0.35, 0.08), CFrame.new(-1.6, 3.75, zs), C.Magenta)
		for fila = 0, 2 do
			for col = 0, fila do
				local d = neon(
					"Silueta",
					sala,
					Vector3.new(0.3, 0.3, 0.3),
					CFrame.new(1.6 + (col - fila / 2) * 0.7, 6.6 - fila * 0.7, zs),
					C.Cian
				)
				d.Shape = Enum.PartType.Ball
			end
		end
		local bolaSilueta =
			neon("Silueta", sala, Vector3.new(0.4, 0.4, 0.4), CFrame.new(1.6, 7.5, zs), C.Peligro)
		bolaSilueta.Shape = Enum.PartType.Ball
	end

	-- Mesa de trabajo contra la pared norte, con tu máquina arriba.
	local zMesa = -medioZ + 2.2
	parte(
		"Mesa",
		sala,
		Vector3.new(10, 0.35, 4),
		CFrame.new(0, S.AltoMesa, zMesa),
		C.Madera,
		Enum.Material.WoodPlanks,
		true
	)
	for _, x in { -4.6, 4.6 } do
		for _, z in { -1.7, 1.7 } do
			parte(
				"Pata",
				sala,
				Vector3.new(0.35, S.AltoMesa, 0.35),
				CFrame.new(x, S.AltoMesa / 2, zMesa + z),
				C.MetalOscuro,
				Enum.Material.Metal,
				true
			)
		end
	end
	parte(
		"Estante",
		sala,
		Vector3.new(9.6, 0.25, 3.6),
		CFrame.new(0, 0.8, zMesa),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	neon(
		"BordeMesa",
		sala,
		Vector3.new(10, 0.12, 0.12),
		CFrame.new(0, S.AltoMesa - 0.12, zMesa + 2.02),
		C.Magenta
	)
	local arribaMesa = S.AltoMesa + 0.175
	local maquinas = Instance.new("Folder")
	maquinas.Name = "Maquinas"
	maquinas.Parent = sala
	local posMaquina = Vector3.new(0, arribaMesa, zMesa - 0.3)
	local m = maquina(maquinas, CFrame.lookAt(posMaquina, posMaquina + Vector3.new(0, 0, 1)))
	-- Lámpara cálida colgando sobre la máquina.
	parte(
		"Cable",
		sala,
		Vector3.new(0.08, 1.3, 0.08),
		CFrame.new(0, S.Alto - 0.65, zMesa + 2),
		"#111111"
	)
	local lampara = neon(
		"Lampara",
		sala,
		Vector3.new(1.2, 0.35, 1.2),
		CFrame.new(0, S.Alto - 1.4, zMesa + 2),
		C.Lampara
	)
	local foco = Instance.new("SpotLight")
	foco.Face = Enum.NormalId.Bottom
	foco.Color = Color3.fromHex(C.Lampara)
	foco.Brightness = 2.5
	foco.Range = 12
	foco.Angle = 75
	foco.Parent = lampara
	-- Cosas sobre la mesa: botellas, una lata, una caja y un contador LED.
	for i, x in { -4, -3.4 } do
		local botella = parte(
			"Botella",
			sala,
			Vector3.new(0.5, 1.4, 0.5),
			CFrame.new(x, arribaMesa + 0.7, zMesa + 0.9 - i * 0.4),
			if i == 1 then "#7A2A10" else "#2F5A1E",
			Enum.Material.Glass
		)
		botella.Transparency = 0.15
	end
	parte(
		"Caja",
		sala,
		Vector3.new(1.4, 0.8, 1),
		CFrame.new(3.7, arribaMesa + 0.4, zMesa - 0.6) * CFrame.Angles(0, math.rad(15), 0),
		"#6A5034",
		Enum.Material.Cardboard
	)
	local contador = parte(
		"Contador",
		sala,
		Vector3.new(1.4, 0.7, 0.6),
		CFrame.new(3.5, arribaMesa + 0.35, zMesa + 1.1),
		"#050505"
	)
	led(contador, Enum.NormalId.Back, "0 / 9")
	-- Banqueta delante de la mesa.
	local asiento = CFrame.new(0, 0, zMesa + 3.6)
	parte(
		"Pie",
		m,
		Vector3.new(1.6, 0.2, 1.6),
		asiento * CFrame.new(0, 0.1, 0),
		C.MetalOscuro,
		Enum.Material.Metal,
		true
	)
	parte(
		"Cano",
		m,
		Vector3.new(0.3, 1.8, 0.3),
		asiento * CFrame.new(0, 1, 0),
		"#8A8A82",
		Enum.Material.Metal,
		true
	)
	local banqueta = parte(
		"Banqueta",
		m,
		Vector3.new(0.45, 1.7, 1.7),
		asiento * CFrame.new(0, 2.1, 0) * CFrame.Angles(0, 0, math.rad(90)),
		"#3A1530",
		Enum.Material.Fabric,
		true
	)
	banqueta.Shape = Enum.PartType.Cylinder

	-- Estante de metal a la derecha de la mesa, con cajas.
	local xEstante = 7.6
	for _, y in { 1.5, 3.3, 5.1 } do
		parte(
			"Repisa",
			sala,
			Vector3.new(3, 0.15, 1.6),
			CFrame.new(xEstante, y, -medioZ + 0.9),
			C.Metal,
			Enum.Material.Metal
		)
	end
	for _, x in { xEstante - 1.4, xEstante + 1.4 } do
		parte(
			"Parante",
			sala,
			Vector3.new(0.15, 5.5, 0.15),
			CFrame.new(x, 2.75, -medioZ + 0.9),
			C.MetalOscuro,
			Enum.Material.Metal
		)
	end
	parte(
		"CajaEstante",
		sala,
		Vector3.new(1.2, 1, 1.1),
		CFrame.new(xEstante - 0.6, 2.1, -medioZ + 0.9),
		"#6A5034",
		Enum.Material.Cardboard
	)
	parte(
		"CajaEstante",
		sala,
		Vector3.new(0.9, 0.7, 0.9),
		CFrame.new(xEstante + 0.7, 3.75, -medioZ + 0.9),
		"#4A4A3A",
		Enum.Material.Metal
	)

	-- Cartel de las clavijas pegado en la pared, a la izquierda de la mesa (como el de símbolos
	-- de CloverPit), y el ventilador arriba a la derecha.
	cartelPapel(
		sala,
		CFrame.new(-7, 5.4, -medioZ + 0.06),
		Vector2.new(4.6, 4),
		"CLAVIJAS",
		renglonesClavijas()
	)
	local ventilador = parte(
		"Ventilador",
		sala,
		Vector3.new(0.4, 2.6, 2.6),
		CFrame.new(6.5, 8, -medioZ + 0.25) * CFrame.Angles(0, math.rad(90), 0),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	ventilador.Shape = Enum.PartType.Cylinder
	for k = 0, 3 do
		parte(
			"Aspa",
			sala,
			Vector3.new(0.1, 1.1, 0.35),
			CFrame.new(6.5, 8, -medioZ + 0.5)
				* CFrame.Angles(0, 0, math.rad(k * 90))
				* CFrame.new(0, 0.5, 0),
			"#5A5A50",
			Enum.Material.Metal
		)
	end

	-- Terminal de la tienda contra la pared oeste, mirando a la sala (+X). 27/10: un kiosco con
	-- marquesina iluminada, vitrina con 3 bolas que flotan (las mueve el cliente), display LED,
	-- ranura, botón de arcade y bandeja, laterales negros con filo de neón (sin dinero).
	local posTienda = Vector3.new(-medioX + 1.2, 0, 1)
	local cfTienda = CFrame.lookAt(posTienda, posTienda + Vector3.new(1, 0, 0))
	local function T(x: number, y: number, z: number): CFrame
		return cfTienda * CFrame.new(x, y, z)
	end
	parte(
		"ZocaloTienda",
		sala,
		Vector3.new(3.2, 0.4, 2),
		T(0, 0.2, 0),
		C.MetalOscuro,
		Enum.Material.Metal,
		true
	)
	local patada =
		parte("FranjaTienda", sala, Vector3.new(3.2, 0.36, 0.05), T(0, 0.2, -1.02), C.MetalOscuro)
	peligro(patada, Enum.NormalId.Front)
	local tienda = parte(
		"Tienda",
		sala,
		Vector3.new(3, 5.2, 1.8),
		T(0, 3, 0),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	CollectionService:AddTag(tienda, "Tienda")
	for _, lado in { -1, 1 } do
		local lateral = parte(
			"LateralTienda",
			sala,
			Vector3.new(0.15, 5.2, 1.9),
			T(lado * 1.57, 3, 0),
			"#141416",
			Enum.Material.SmoothPlastic,
			true
		)
		lateral.Reflectance = 0.12
		neon("BordeTienda", sala, Vector3.new(0.18, 5.2, 0.08), T(lado * 1.57, 3, -0.97), C.Cian)
	end
	remaches(sala, T(0, 3, -0.91), 2.7, 4.9)
	-- Marquesina.
	parte(
		"MarquesinaTienda",
		sala,
		Vector3.new(3.45, 0.95, 2.1),
		T(0, 6.05, -0.1),
		"#0A0A0C",
		Enum.Material.Metal
	)
	local cartelTienda =
		parte("PantallaTienda", sala, Vector3.new(3.15, 0.72, 0.05), T(0, 6.05, -1.17), "#050505")
	cartelLuz(cartelTienda, Enum.NormalId.Front, "TIENDA", C.Cian, "#7A2CF5")
	neon("TuboTienda", sala, Vector3.new(3.45, 0.08, 0.08), T(0, 5.6, -1.18), C.Magenta, true)
	-- Vitrina con 3 bolas: una caja de vidrio que sale del frente.
	local yVitrina = 4.3
	parte("FondoVitrina", sala, Vector3.new(2.6, 1.8, 0.05), T(0, yVitrina, -0.93), "#08080A")
	for _, lado in { -1, 1 } do
		parte(
			"MarcoVitrina",
			sala,
			Vector3.new(2.8, 0.12, 0.45),
			T(0, yVitrina + lado * 0.96, -1.15),
			"#0A0A0C",
			Enum.Material.Metal
		)
		parte(
			"MarcoVitrina",
			sala,
			Vector3.new(0.12, 2.04, 0.45),
			T(lado * 1.34, yVitrina, -1.15),
			"#0A0A0C",
			Enum.Material.Metal
		)
	end
	parte(
		"RepisaVitrina",
		sala,
		Vector3.new(2.6, 0.08, 0.4),
		T(0, yVitrina - 0.75, -1.15),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	local luzVitrina = neon(
		"LuzVitrina",
		sala,
		Vector3.new(2.5, 0.06, 0.06),
		T(0, yVitrina + 0.85, -1.15),
		"#FFF6E0"
	)
	luz(luzVitrina, "#FFF6E0", 0.8, 4)
	local vidrio = parte(
		"Vidrio",
		sala,
		Vector3.new(2.6, 1.8, 0.04),
		T(0, yVitrina, -1.38),
		"#BFE8FF",
		Enum.Material.Glass
	)
	vidrio.Transparency = 0.8
	vidrio.Reflectance = 0.2
	for k, hex in { Config.Colores.Bola, Config.Colores.BolaFuego, C.Cian } do
		local x = (k - 2) * 0.8
		local pie = parte(
			"PieVitrina",
			sala,
			Vector3.new(0.15, 0.5, 0.5),
			T(x, yVitrina - 0.63, -1.15) * CFrame.Angles(0, 0, math.rad(90)),
			C.Metal,
			Enum.Material.Metal
		)
		pie.Shape = Enum.PartType.Cylinder
		local bola = parte(
			"BolaVitrina",
			sala,
			Vector3.new(0.6, 0.6, 0.6),
			T(x, yVitrina - 0.15, -1.15),
			hex,
			Enum.Material.Neon
		)
		bola.Shape = Enum.PartType.Ball
		bola:SetAttribute("Fase", k)
	end
	-- Display, ranura, botón y bandeja.
	local display =
		parte("DisplayTienda", sala, Vector3.new(2.4, 0.5, 0.05), T(0, 3.05, -0.93), "#050505")
	led(display, Enum.NormalId.Front, "TU BOLA")
	CollectionService:AddTag(display, "ProgresoTienda") -- server/Sala escribe tu MEJOR
	for _, ladoFranja in { -1, 1 } do
		neon(
			"FranjaLed",
			sala,
			Vector3.new(0.14, 6.2, 0.14),
			T(ladoFranja * 1.95, 3.4, 0.6),
			C.Magenta,
			true
		)
	end
	parte("Ranura", sala, Vector3.new(1.1, 0.18, 0.06), T(-0.55, 2.3, -0.93), "#050505")
	neon("LabioRanura", sala, Vector3.new(1.2, 0.05, 0.05), T(-0.55, 2.15, -0.95), C.Led)
	botonArcade(
		sala,
		"BotonTienda",
		T(0.85, 2.3, -0.9) * CFrame.Angles(math.rad(-90), 0, 0),
		0.6,
		C.Boton
	)
	parte("Bandeja", sala, Vector3.new(1.6, 0.6, 0.05), T(0, 1.3, -0.93), "#050505")
	parte(
		"LabioBandeja",
		sala,
		Vector3.new(1.7, 0.1, 0.3),
		T(0, 1.02, -1.05),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	neon("LuzBandeja", sala, Vector3.new(1.5, 0.05, 0.05), T(0, 1.58, -0.95), C.Magenta)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "VerBolas"
	prompt.ActionText = "Elegir bola"
	prompt.ObjectText = "Tienda"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = S.DistanciaJugar
	prompt.RequiresLineOfSight = false
	prompt.Parent = tienda

	-- Pared este: puerta blindada (compuerta con franjas, marco de franjas iluminado por detrás y
	-- dos luces de aviso rojas) y el tablero de récords. Al ganar la mazmorra, client/Sala sube la
	-- compuerta y pone las luces verdes (atributo "Abierta", lo pone server/Sala).
	local compuerta = parte(
		"Compuerta",
		sala,
		Vector3.new(0.4, 6.4, 3.6),
		CFrame.new(medioX - 0.25, 3.2, 3.5),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	peligro(compuerta, Enum.NormalId.Left)
	compuerta:SetAttribute("Abierta", false)
	CollectionService:AddTag(compuerta, "Compuerta")
	for _, z in { 3.5 - 2.05, 3.5 + 2.05 } do
		local lateralPuerta = parte(
			"MarcoPuerta",
			sala,
			Vector3.new(0.5, 7, 0.5),
			CFrame.new(medioX - 0.25, 3.5, z),
			C.MetalOscuro,
			Enum.Material.Metal
		)
		peligro(lateralPuerta, Enum.NormalId.Left)
	end
	local dintel = parte(
		"MarcoPuerta",
		sala,
		Vector3.new(0.5, 0.6, 4.6),
		CFrame.new(medioX - 0.25, 6.7, 3.5),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	peligro(dintel, Enum.NormalId.Left)
	-- Caja de metal arriba del marco: ahí se guarda la compuerta cuando sube.
	parte(
		"CajaPuerta",
		sala,
		Vector3.new(0.7, S.Alto - 7, 4.6),
		CFrame.new(medioX - 0.3, 7 + (S.Alto - 7) / 2, 3.5),
		C.MetalOscuro,
		Enum.Material.DiamondPlate
	)
	-- Atrás de la compuerta: un pasillo oscuro con una luz verde en el piso (se ve al abrirse).
	parte(
		"Pasillo",
		sala,
		Vector3.new(0.04, 6.4, 3.6),
		CFrame.new(medioX - 0.02, 3.2, 3.5),
		"#030306"
	)
	neon(
		"LuzPasillo",
		sala,
		Vector3.new(0.06, 0.12, 3.4),
		CFrame.new(medioX - 0.06, 0.25, 3.5),
		"#4CC46A"
	)
	-- Luz de atrás del marco (ámbar) y las luces de aviso.
	neon(
		"LuzMarco",
		sala,
		Vector3.new(0.08, 0.1, 4.7),
		CFrame.new(medioX - 0.05, 7.05, 3.5),
		C.Peligro,
		true
	)
	for _, z in { 3.5 - 1.5, 3.5 + 1.5 } do
		local aviso = neon(
			"LuzPuerta",
			sala,
			Vector3.new(0.4, 0.4, 0.4),
			CFrame.new(medioX - 0.85, 7.6, z),
			C.Alarma
		)
		aviso.Shape = Enum.PartType.Ball
		luz(aviso, C.Alarma, 1.2, 6)
	end
	local records = parte(
		"Records",
		sala,
		Vector3.new(0.3, 3.4, 5.6),
		CFrame.new(medioX - 0.15, 5.2, -3.5),
		"#050505"
	)
	CollectionService:AddTag(records, "Records")
	records:SetAttribute("Cara", "Left") -- mira a la sala (-X): server/Sala escribe en esa cara
	neon(
		"BordeRecords",
		sala,
		Vector3.new(0.12, 0.12, 5.9),
		CFrame.new(medioX - 0.3, 6.95, -3.5),
		C.Magenta
	)

	-- Vitrina de reliquias (pared sur, a la derecha): una mesa con una caja de vidrio con luz por
	-- cada lugar de reliquia; adentro, una gema del color de la rareza de la reliquia que tenés en
	-- ese lugar (la prende server/Sala; client/Sala la hace girar).
	do
		local xV, zV = 6, medioZ - 0.95
		local mesaV = parte(
			"MesaReliquias",
			sala,
			Vector3.new(5.8, 0.25, 1.6),
			CFrame.new(xV, 2.6, zV),
			C.MetalOscuro,
			Enum.Material.Metal,
			true
		)
		CollectionService:AddTag(mesaV, "VitrinaReliquias")
		parte(
			"FrenteReliquias",
			sala,
			Vector3.new(5.8, 2.45, 0.1),
			CFrame.new(xV, 1.25, zV - 0.75),
			C.Metal,
			Enum.Material.DiamondPlate,
			true
		)
		neon(
			"FiloReliquias",
			sala,
			Vector3.new(5.8, 0.08, 0.08),
			CFrame.new(xV, 2.45, zV - 0.82),
			C.Magenta
		)
		local n = Config.LugaresReliquia
		for lugar = 1, n do
			local x = xV + (lugar - (n + 1) / 2) * 1.08
			local baseCaja = neon(
				"BaseCaja",
				sala,
				Vector3.new(0.86, 0.05, 0.86),
				CFrame.new(x, 2.75, zV),
				"#FFF6E0"
			)
			luz(baseCaja, "#FFF6E0", 0.5, 3)
			local caja = parte(
				"CajaReliquia",
				sala,
				Vector3.new(0.9, 0.95, 0.9),
				CFrame.new(x, 3.25, zV),
				"#BFE8FF",
				Enum.Material.Glass
			)
			caja.Transparency = 0.6
			caja.Reflectance = 0.3
			-- Parantes de metal en las 4 esquinas, así se ve que es una caja.
			for _, dx in { -0.43, 0.43 } do
				for _, dz in { -0.43, 0.43 } do
					parte(
						"ParanteCaja",
						sala,
						Vector3.new(0.06, 0.95, 0.06),
						CFrame.new(x + dx, 3.25, zV + dz),
						"#8A8FA8",
						Enum.Material.Metal
					)
				end
			end
			parte(
				"TapaCaja",
				sala,
				Vector3.new(0.92, 0.05, 0.92),
				CFrame.new(x, 3.74, zV),
				"#5D637E",
				Enum.Material.Metal
			)
			local gema = parte(
				"GemaReliquia",
				sala,
				Vector3.new(0.38, 0.38, 0.38),
				CFrame.new(x, 3.25, zV) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
				"#FFFFFF",
				Enum.Material.Neon
			)
			gema.Transparency = 1
			gema:SetAttribute("Lugar", lugar)
		end
		local cartelV = parte(
			"CartelReliquias",
			sala,
			Vector3.new(4.6, 0.6, 0.1),
			CFrame.new(xV, 4.4, medioZ - 0.3),
			"#050505"
		)
		led(cartelV, Enum.NormalId.Front, "TUS RELIQUIAS")
	end

	-- Pedestal de la estatua de tu avatar, contra la pared sur.
	local pedestal = parte(
		"Pedestal",
		sala,
		Vector3.new(3, 0.8, 3),
		CFrame.new(-5, 0.4, medioZ - 2),
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	neon(
		"AroPedestal",
		sala,
		Vector3.new(0.12, 3.3, 3.3),
		pedestal.CFrame * CFrame.new(0, 0.42, 0) * CFrame.Angles(0, 0, math.rad(90)),
		C.Magenta,
		true
	).Shape =
		Enum.PartType.Cylinder

	-- Aparecer adentro, frente a la mesa.
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		spawn.CFrame = CFrame.new(2, 0.6, medioZ - 3)
		spawn.Size = Vector3.new(3, 1, 3)
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.Neutral = true
	end

	-- Todo arriba de la Baseplate (en este place su cara de arriba está en y = 10).
	local base = Workspace:FindFirstChild("Baseplate")
	local altura = if base and base:IsA("BasePart") then base.Position.Y + base.Size.Y / 2 else 0
	if altura ~= 0 then
		for _, p in sala:GetDescendants() do
			if p:IsA("BasePart") then
				p.CFrame += Vector3.new(0, altura, 0)
			end
		end
		if spawn then
			spawn.CFrame += Vector3.new(0, altura, 0)
		end
	end
	sala:SetAttribute("Altura", altura)

	sala.Parent = Workspace
	return sala
end

return GeneradorSala
