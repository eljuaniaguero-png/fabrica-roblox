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

-- Tu máquina: una caja industrial compacta arriba de la mesa (base en `cf`, frente hacia
-- cf.LookVector), con pantalla, display LED, botón rojo y palanca.
local function maquina(padre: Instance, cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "Maquina1"
	local t = S.MaquinaTamanio
	local w, h, d = t.X, t.Y, t.Z
	local frente = -(d / 2)
	local cuerpo = parte(
		"Cuerpo",
		m,
		Vector3.new(w, h, d),
		cf * CFrame.new(0, h / 2, 0),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	m.PrimaryPart = cuerpo
	-- Franjas de peligro a los costados.
	for _, lado in { -1, 1 } do
		local panel = parte(
			"Franja",
			m,
			Vector3.new(0.1, h * 0.3, d * 0.9),
			cf * CFrame.new(lado * (w / 2 + 0.05), h * 0.18, 0),
			C.MetalOscuro
		)
		peligro(panel, if lado < 0 then Enum.NormalId.Left else Enum.NormalId.Right)
	end
	-- Marco negro y pantalla (mira a la sala).
	local alto = h * 0.58
	parte(
		"Marco",
		m,
		Vector3.new(w * 0.88, h * 0.66, 0.3),
		cf * CFrame.new(0, alto, frente - 0.15),
		C.MetalOscuro,
		Enum.Material.Metal
	)
	local pantalla = parte(
		"Pantalla",
		m,
		S.PantallaTamanio,
		cf * CFrame.new(0, alto, frente - 0.33),
		C.Pantalla,
		Enum.Material.Neon
	)
	CollectionService:AddTag(pantalla, "Pantalla")
	-- Lo que muestra mientras no estás sentado: el logo y las clavijas.
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
	end
	-- Display LED arriba.
	local cartel = parte(
		"Cartel",
		m,
		Vector3.new(w * 0.7, 0.6, 0.6),
		cf * CFrame.new(0, h + 0.3, frente + 0.4),
		"#050505"
	)
	led(cartel, Enum.NormalId.Front, "PLINKO KNIGHT")
	-- Bordes de neón (lo futurista).
	for _, lado in { -1, 1 } do
		neon(
			"Borde",
			m,
			Vector3.new(0.12, h, 0.12),
			cf * CFrame.new(lado * (w / 2 + 0.02), h / 2, frente - 0.02),
			if lado < 0 then C.Magenta else C.Cian
		)
	end
	-- Botón rojo grande y dos chicos en una repisa al frente.
	local repisa = parte(
		"Botonera",
		m,
		Vector3.new(w * 0.9, 0.3, 0.9),
		cf * CFrame.new(0, 0.35, frente - 0.45),
		C.MetalOscuro,
		Enum.Material.DiamondPlate,
		true
	)
	local boton = parte(
		"Boton",
		m,
		Vector3.new(0.3, 0.75, 0.75),
		repisa.CFrame * CFrame.new(w * 0.2, 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		C.Boton
	)
	boton.Shape = Enum.PartType.Cylinder
	for i, hex in { C.Peligro, C.Cian } do
		local chico = parte(
			"BotonChico",
			m,
			Vector3.new(0.2, 0.4, 0.4),
			repisa.CFrame
				* CFrame.new(-w * 0.05 - i * 0.55, 0.15, 0)
				* CFrame.Angles(0, 0, math.rad(90)),
			hex
		)
		chico.Shape = Enum.PartType.Cylinder
	end
	-- Palanca al costado derecho, con bocha roja.
	local base = cf * CFrame.new(w / 2 + 0.3, h * 0.45, frente + 0.8)
	parte(
		"Palanca",
		m,
		Vector3.new(0.2, 2, 0.2),
		base * CFrame.new(0, 0.9, 0) * CFrame.Angles(math.rad(-20), 0, 0),
		"#9A9A90",
		Enum.Material.Metal
	)
	local bocha =
		parte("Bocha", m, Vector3.new(0.65, 0.65, 0.65), base * CFrame.new(0, 1.9, 0.35), C.Boton)
	bocha.Shape = Enum.PartType.Ball

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
	local g = S.Grilla
	for x = -medioX + g, medioX - g, g do
		local l =
			neon("Grilla", sala, Vector3.new(0.1, 0.06, S.Largo), CFrame.new(x, 0.08, 0), C.GrillaB)
		l.Transparency = 0.45
	end
	for z = -medioZ + g, medioZ - g, g do
		local l =
			neon("Grilla", sala, Vector3.new(S.Ancho, 0.06, 0.1), CFrame.new(0, 0.09, z), C.GrillaA)
		l.Transparency = 0.45
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
				* CFrame.Angles(0, 0, math.rad(k * 45))
				* CFrame.new(0, 0.5, 0),
			"#5A5A50",
			Enum.Material.Metal
		)
	end

	-- Terminal de la tienda contra la pared oeste, mirando a la sala (+X): caja de metal con
	-- pantalla LED, ranura, botón y franjas (como la máquina de tiques de CloverPit, sin dinero).
	local posTienda = Vector3.new(-medioX + 1.2, 0, 1)
	local cfTienda = CFrame.lookAt(posTienda, posTienda + Vector3.new(1, 0, 0))
	local tienda = parte(
		"Tienda",
		sala,
		Vector3.new(3, 6, 1.8),
		cfTienda * CFrame.new(0, 3, 0),
		C.Metal,
		Enum.Material.DiamondPlate,
		true
	)
	CollectionService:AddTag(tienda, "Tienda")
	local pantallaTienda = parte(
		"PantallaTienda",
		sala,
		Vector3.new(2.4, 1.3, 0.2),
		cfTienda * CFrame.new(0, 4.6, -0.95),
		"#050505"
	)
	led(pantallaTienda, Enum.NormalId.Front, "TIENDA")
	local franjaTienda = parte(
		"FranjaTienda",
		sala,
		Vector3.new(3, 0.8, 0.1),
		cfTienda * CFrame.new(0, 0.8, -0.95),
		C.MetalOscuro
	)
	peligro(franjaTienda, Enum.NormalId.Front)
	parte(
		"Ranura",
		sala,
		Vector3.new(1.6, 0.22, 0.22),
		cfTienda * CFrame.new(0, 3, -0.95),
		"#050505"
	)
	local botonTienda = parte(
		"BotonTienda",
		sala,
		Vector3.new(0.25, 0.6, 0.6),
		cfTienda * CFrame.new(0.9, 2.2, -1) * CFrame.Angles(0, math.rad(90), 0),
		C.Boton
	)
	botonTienda.Shape = Enum.PartType.Cylinder
	neon(
		"BordeTienda",
		sala,
		Vector3.new(3.1, 0.12, 0.12),
		cfTienda * CFrame.new(0, 6.05, -0.9),
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

	-- Pared este: puerta de metal con ventanita de rejas y marco de neón, y el tablero de récords.
	local puerta = parte(
		"Puerta",
		sala,
		Vector3.new(0.4, 7, 4),
		CFrame.new(medioX - 0.2, 3.5, 3.5),
		C.Metal,
		Enum.Material.DiamondPlate
	)
	parte(
		"Ventanita",
		sala,
		Vector3.new(0.1, 1.2, 1.4),
		puerta.CFrame * CFrame.new(-0.22, 1.8, 0),
		"#050505"
	)
	for k = -1, 1 do
		parte(
			"Reja",
			sala,
			Vector3.new(0.12, 1.2, 0.1),
			puerta.CFrame * CFrame.new(-0.28, 1.8, k * 0.4),
			"#6A6A60",
			Enum.Material.Metal
		)
	end
	neon(
		"MarcoPuerta",
		sala,
		Vector3.new(0.12, 0.12, 4.3),
		CFrame.new(medioX - 0.15, 7.1, 3.5),
		C.Cian,
		true
	)
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
