--!strict
-- La sala (etapa 7b, rehecha el 26/10): chica, mezcla de CloverPit (metal gastado, franjas de
-- peligro, displays LED naranja, botón rojo y palanca) con algo futurista como FNAF Security
-- Breach (tubos de neón magenta y cian, piso negro brillante con grilla de neón). Todo armado con
-- partes por código, así vive en git. Config.Sala tiene medidas y colores.
--   - pared norte: tu máquina (tag "Maquina", atributo Indice) con pantalla (tag "Pantalla"),
--     banqueta y "E: Jugar"; a los costados, 2 máquinas apagadas en demo (tag "PantallaDemo");
--   - pared oeste: la terminal de la tienda (tag "Tienda", "E: Elegir bola");
--   - pared sur: puerta y el tablero LED de récords (tag "Records");
--   - un costado: el pedestal donde server/Sala pone la estatua de tu avatar.
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

local function neon(
	nombre: string,
	padre: Instance,
	tamanio: Vector3,
	cframe: CFrame,
	hex: string,
	luz: boolean?
): Part
	local p = parte(nombre, padre, tamanio, cframe, hex, Enum.Material.Neon)
	if luz then
		local l = Instance.new("PointLight")
		l.Color = Color3.fromHex(hex)
		l.Brightness = S.LuzNeon.Brillo
		l.Range = S.LuzNeon.Alcance
		l.Shadows = false
		l.Parent = p
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
	t.TextStrokeColor3 = Color3.fromHex(hex or C.Led)
	t.TextStrokeTransparency = 0.7
	t.Text = texto
	t.Parent = gui
	return t
end

-- Franjas de peligro amarillas y negras en una cara (diagonales).
local function peligro(en: BasePart, cara: Enum.NormalId)
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
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
	for i = -6, 12 do
		local franja = Instance.new("Frame")
		franja.AnchorPoint = Vector2.new(0.5, 0.5)
		franja.Position = UDim2.fromScale(i * 0.12, 0.5)
		franja.Size = UDim2.fromScale(0.06, 3)
		franja.Rotation = 35
		franja.BackgroundColor3 = Color3.fromHex(C.Peligro)
		franja.BorderSizePixel = 0
		franja.Parent = fondo
	end
end

-- Una máquina industrial (base en `cf`, frente hacia cf.LookVector). `jugable`: la tuya (con
-- prompt, cartel y botonera completa); si no, una de fondo apagada con demo.
local function maquina(padre: Instance, nombre: string, cf: CFrame, jugable: boolean): Model
	local m = Instance.new("Model")
	m.Name = nombre
	local t = S.MaquinaTamanio
	local escala = if jugable then 1 else 0.85
	local w, h, d = t.X * escala, t.Y * escala, t.Z * escala
	local frente = -(d / 2)
	local cuerpo = parte(
		"Cuerpo",
		m,
		Vector3.new(w, h, d),
		cf * CFrame.new(0, h / 2, 0),
		C.Metal,
		Enum.Material.CorrodedMetal,
		true
	)
	m.PrimaryPart = cuerpo
	-- Franjas de peligro a los costados (de la mitad para abajo).
	for _, lado in { -1, 1 } do
		local panel = parte(
			"Franja",
			m,
			Vector3.new(0.1, h * 0.35, d * 0.9),
			cf * CFrame.new(lado * (w / 2 + 0.05), h * 0.2, 0),
			C.MetalOscuro
		)
		peligro(panel, if lado < 0 then Enum.NormalId.Left else Enum.NormalId.Right)
	end
	-- Marco negro de la pantalla y la pantalla (que mira a la sala).
	local alto = h * 0.62
	parte(
		"Marco",
		m,
		Vector3.new(w * 0.88, h * 0.42, 0.3),
		cf * CFrame.new(0, alto, frente - 0.15),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	local p = S.PantallaTamanio * escala
	local pantalla = parte(
		"Pantalla",
		m,
		p,
		cf * CFrame.new(0, alto, frente - 0.35),
		C.Pantalla,
		Enum.Material.Neon
	)
	-- Bordes de neón del frente (lo futurista).
	for _, lado in { -1, 1 } do
		neon(
			"Borde",
			m,
			Vector3.new(0.18, h, 0.18),
			cf * CFrame.new(lado * (w / 2 + 0.02), h / 2, frente - 0.05),
			if lado < 0 then C.Magenta else C.Cian
		)
	end
	neon(
		"Borde",
		m,
		Vector3.new(w, 0.18, 0.18),
		cf * CFrame.new(0, h + 0.02, frente - 0.05),
		C.Magenta
	)
	-- Display LED arriba.
	local cartel = parte(
		"Cartel",
		m,
		Vector3.new(w * 0.9, h * 0.13, 0.5),
		cf * CFrame.new(0, h * 0.9, frente - 0.25),
		"#050505",
		Enum.Material.SmoothPlastic
	)
	-- Botonera inclinada con un botón rojo grande.
	local botonera = parte(
		"Botonera",
		m,
		Vector3.new(w * 0.9, 0.4, 1.4),
		cf * CFrame.new(0, h * 0.4, frente - 0.6) * CFrame.Angles(math.rad(-15), 0, 0),
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	local boton = parte(
		"Boton",
		m,
		Vector3.new(0.35, 0.9, 0.9),
		botonera.CFrame * CFrame.new(w * 0.15, 0.3, 0) * CFrame.Angles(0, 0, math.rad(90)),
		C.Boton,
		Enum.Material.SmoothPlastic
	)
	boton.Shape = Enum.PartType.Cylinder
	for i, hex in { C.Peligro, C.Cian } do
		local chico = parte(
			"BotonChico",
			m,
			Vector3.new(0.25, 0.5, 0.5),
			botonera.CFrame
				* CFrame.new(-w * 0.05 - i * 0.6, 0.25, 0)
				* CFrame.Angles(0, 0, math.rad(90)),
			hex
		)
		chico.Shape = Enum.PartType.Cylinder
	end
	if jugable then
		led(cartel, Enum.NormalId.Front, "PLINKO KNIGHT")
		-- Palanca al costado derecho, con bocha roja (como en CloverPit).
		local base = cf * CFrame.new(w / 2 + 0.35, h * 0.5, frente + 0.8)
		parte(
			"Palanca",
			m,
			Vector3.new(0.25, 2.6, 0.25),
			base * CFrame.new(0, 1.2, 0) * CFrame.Angles(math.rad(-20), 0, 0),
			"#B8B8B8",
			Enum.Material.Metal
		)
		local bocha =
			parte("Bocha", m, Vector3.new(0.8, 0.8, 0.8), base * CFrame.new(0, 2.5, 0.45), C.Boton)
		bocha.Shape = Enum.PartType.Ball
		-- Lo que se ve en la pantalla mientras no estás sentado: el logo y clavijas.
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.LightInfluence = 0
		gui.CanvasSize = Vector2.new(380, 280)
		gui.Parent = pantalla
		local titulo = Instance.new("TextLabel")
		titulo.BackgroundTransparency = 1
		titulo.Position = UDim2.fromScale(0.05, 0.06)
		titulo.Size = UDim2.fromScale(0.9, 0.22)
		titulo.Font = Enum.Font.Arcade
		titulo.TextScaled = true
		titulo.TextColor3 = Color3.fromHex(C.Led)
		titulo.Text = "PLINKO KNIGHT"
		titulo.Parent = gui
		for fila = 0, 4 do
			for col = 0, 6 - fila % 2 do
				local punto = Instance.new("Frame")
				punto.AnchorPoint = Vector2.new(0.5, 0.5)
				punto.Position =
					UDim2.fromScale(0.14 + col * 0.12 + (fila % 2) * 0.06, 0.38 + fila * 0.12)
				punto.Size = UDim2.fromOffset(9, 9)
				punto.BackgroundColor3 = Color3.fromHex(Config.Colores.Oro)
				punto.BorderSizePixel = 0
				punto.Parent = gui
				local r = Instance.new("UICorner")
				r.CornerRadius = UDim.new(0.5, 0)
				r.Parent = punto
			end
		end
		CollectionService:AddTag(pantalla, "Pantalla")
		-- Banqueta: asiento redondo con caño y base (lo que toca la cámara es "Banqueta").
		local asiento = cf * CFrame.new(0, 0, frente - 2.8)
		parte(
			"Pie",
			m,
			Vector3.new(1.8, 0.2, 1.8),
			asiento * CFrame.new(0, 0.1, 0),
			C.MetalOscuro,
			Enum.Material.Metal,
			true
		)
		parte(
			"Cano",
			m,
			Vector3.new(0.3, 2, 0.3),
			asiento * CFrame.new(0, 1.1, 0),
			"#B8B8B8",
			Enum.Material.Metal,
			true
		)
		local banqueta = parte(
			"Banqueta",
			m,
			Vector3.new(0.5, 1.8, 1.8),
			asiento * CFrame.new(0, 2.3, 0) * CFrame.Angles(0, 0, math.rad(90)),
			"#3A1530",
			Enum.Material.Fabric,
			true
		)
		banqueta.Shape = Enum.PartType.Cylinder
		neon(
			"Aro",
			m,
			Vector3.new(0.15, 1.95, 1.95),
			asiento * CFrame.new(0, 2.05, 0) * CFrame.Angles(0, 0, math.rad(90)),
			C.Magenta
		).Shape =
			Enum.PartType.Cylinder
		-- Lámpara cálida colgada arriba (en CloverPit la máquina está bajo una luz amarilla).
		local lampara = neon(
			"Lampara",
			m,
			Vector3.new(1.2, 0.3, 1.2),
			cf * CFrame.new(0, S.Alto - 0.6, frente - 1.5),
			C.Lampara
		)
		local luz = Instance.new("SpotLight")
		luz.Face = Enum.NormalId.Bottom
		luz.Color = Color3.fromHex(C.Lampara)
		luz.Brightness = 3
		luz.Range = 16
		luz.Angle = 70
		luz.Parent = lampara

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
	else
		led(cartel, Enum.NormalId.Front, "- - -", C.Cian)
		CollectionService:AddTag(pantalla, "PantallaDemo")
	end
	m.Parent = padre
	return m
end

function GeneradorSala.generar(): Folder
	local vieja = Workspace:FindFirstChild("Sala")
	if vieja then
		vieja:Destroy()
	end
	local sala = Instance.new("Folder")
	sala.Name = "Sala"
	local medioX, medioZ = S.Ancho / 2, S.Largo / 2

	-- Piso negro brillante con grilla de neón (FNAF Security Breach).
	local piso = parte(
		"Piso",
		sala,
		Vector3.new(S.Ancho, 1, S.Largo),
		CFrame.new(0, -0.45, 0),
		C.Piso,
		Enum.Material.SmoothPlastic,
		true
	)
	piso.Reflectance = S.ReflejoPiso
	local g = S.Grilla
	for x = -medioX + g, medioX - g, g do
		local l = neon(
			"Grilla",
			sala,
			Vector3.new(0.12, 0.06, S.Largo),
			CFrame.new(x, 0.08, 0),
			C.GrillaB
		)
		l.Transparency = 0.25
	end
	for z = -medioZ + g, medioZ - g, g do
		local l = neon(
			"Grilla",
			sala,
			Vector3.new(S.Ancho, 0.06, 0.12),
			CFrame.new(0, 0.09, z),
			C.GrillaA
		)
		l.Transparency = 0.25
	end

	-- Techo y paredes de metal gastado, con una puerta en la pared sur.
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
		Enum.Material.CorrodedMetal,
		true
	)
	for _, lado in { -1, 1 } do
		parte(
			"ParedLado",
			sala,
			Vector3.new(1, S.Alto, S.Largo),
			CFrame.new(lado * (medioX + 0.5), S.Alto / 2, 0),
			C.Pared,
			Enum.Material.CorrodedMetal,
			true
		)
		local tramo = medioX - 3
		parte(
			"ParedSur",
			sala,
			Vector3.new(tramo, S.Alto, 1),
			CFrame.new(lado * (3 + tramo / 2), S.Alto / 2, medioZ + 0.5),
			C.Pared,
			Enum.Material.CorrodedMetal,
			true
		)
		-- Marco de neón de la puerta.
		neon(
			"MarcoPuerta",
			sala,
			Vector3.new(0.25, 7, 0.25),
			CFrame.new(lado * 3, 3.5, medioZ - 0.1),
			C.Cian,
			true
		)
	end
	parte(
		"Dintel",
		sala,
		Vector3.new(6, S.Alto - 7, 1),
		CFrame.new(0, 7 + (S.Alto - 7) / 2, medioZ + 0.5),
		C.Pared,
		Enum.Material.CorrodedMetal,
		true
	)
	neon("MarcoPuerta", sala, Vector3.new(6.25, 0.25, 0.25), CFrame.new(0, 7, medioZ - 0.1), C.Cian)

	-- Tubos de neón: verticales en las esquinas, banda arriba en todas las paredes.
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			neon(
				"Tubo",
				sala,
				Vector3.new(0.3, S.Alto, 0.3),
				CFrame.new(x * (medioX - 0.3), S.Alto / 2, z * (medioZ - 0.3)),
				if x == z then C.Magenta else C.Cian,
				true
			)
		end
	end
	local banda = S.Alto - 1.2
	neon(
		"Banda",
		sala,
		Vector3.new(S.Ancho, 0.25, 0.2),
		CFrame.new(0, banda, -medioZ + 0.1),
		C.Magenta
	)
	neon(
		"Banda",
		sala,
		Vector3.new(S.Ancho, 0.25, 0.2),
		CFrame.new(0, banda, medioZ - 0.1),
		C.Magenta
	)
	neon(
		"Banda",
		sala,
		Vector3.new(0.2, 0.25, S.Largo),
		CFrame.new(-medioX + 0.1, banda, 0),
		C.Cian
	)
	neon("Banda", sala, Vector3.new(0.2, 0.25, S.Largo), CFrame.new(medioX - 0.1, banda, 0), C.Cian)

	-- Tu máquina al centro de la pared norte, mirando a la sala (+Z); 2 apagadas a los costados.
	local maquinas = Instance.new("Folder")
	maquinas.Name = "Maquinas"
	maquinas.Parent = sala
	local zMaquina = -medioZ + S.MaquinaTamanio.Z / 2 + 0.6
	local mira = Vector3.new(0, 0, 1)
	maquina(
		maquinas,
		"Maquina1",
		CFrame.lookAt(Vector3.new(0, 0, zMaquina), Vector3.new(0, 0, zMaquina) + mira),
		true
	)
	for i, x in { -7.5, 7.5 } do
		local pos = Vector3.new(x, 0, zMaquina)
		maquina(sala, "MaquinaFondo" .. i, CFrame.lookAt(pos, pos + mira), false)
	end

	-- Terminal de la tienda contra la pared oeste, mirando a la sala (+X): caja de metal con
	-- pantalla LED, ranura y botón (como la máquina de tiques de CloverPit, sin dinero).
	local posTienda = Vector3.new(-medioX + 1.6, 0, 2)
	local cfTienda = CFrame.lookAt(posTienda, posTienda + Vector3.new(1, 0, 0))
	local tienda = parte(
		"Tienda",
		sala,
		Vector3.new(3.4, 6.5, 2.2),
		cfTienda * CFrame.new(0, 3.25, 0),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	CollectionService:AddTag(tienda, "Tienda")
	local pantallaTienda = parte(
		"PantallaTienda",
		sala,
		Vector3.new(2.6, 1.4, 0.2),
		cfTienda * CFrame.new(0, 4.9, -1.15),
		"#050505"
	)
	led(pantallaTienda, Enum.NormalId.Front, "TIENDA")
	local franjaTienda = parte(
		"FranjaTienda",
		sala,
		Vector3.new(3.4, 0.9, 0.1),
		cfTienda * CFrame.new(0, 0.9, -1.15),
		C.MetalOscuro
	)
	peligro(franjaTienda, Enum.NormalId.Front)
	parte(
		"Ranura",
		sala,
		Vector3.new(1.8, 0.25, 0.25),
		cfTienda * CFrame.new(0, 3.3, -1.15),
		"#050505"
	)
	neon(
		"BordeTienda",
		sala,
		Vector3.new(3.6, 0.15, 0.15),
		cfTienda * CFrame.new(0, 6.55, -1.1),
		C.Cian,
		true
	)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "VerBolas"
	prompt.ActionText = "Elegir bola"
	prompt.ObjectText = "Tienda"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = S.DistanciaJugar
	prompt.RequiresLineOfSight = false
	prompt.Parent = tienda

	-- Tablero LED de récords en la pared sur, a la izquierda de la puerta, mirando a la sala (-Z).
	local records = parte(
		"Records",
		sala,
		Vector3.new(8, 4.5, 0.3),
		CFrame.new(-8.5, 5, medioZ - 0.25),
		"#050505",
		Enum.Material.SmoothPlastic
	)
	CollectionService:AddTag(records, "Records")
	for _, dy in { -2.35, 2.35 } do
		neon(
			"BordeRecords",
			sala,
			Vector3.new(8.3, 0.15, 0.15),
			CFrame.new(-8.5, 5 + dy, medioZ - 0.4),
			C.Magenta
		)
	end

	-- Pedestal de la estatua de tu avatar, a la derecha, con un aro de neón.
	local pedestal = parte(
		"Pedestal",
		sala,
		Vector3.new(4, 1.2, 4),
		CFrame.new(9, 0.6, 4),
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	neon(
		"AroPedestal",
		sala,
		Vector3.new(0.15, 4.4, 4.4),
		pedestal.CFrame * CFrame.new(0, 0.62, 0) * CFrame.Angles(0, 0, math.rad(90)),
		C.Magenta,
		true
	).Shape =
		Enum.PartType.Cylinder

	-- Aparecer adentro, al lado de la puerta, mirando a la máquina (-Z).
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		spawn.CFrame = CFrame.new(0, 0.6, medioZ - 4)
		spawn.Size = Vector3.new(4, 1, 4)
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
