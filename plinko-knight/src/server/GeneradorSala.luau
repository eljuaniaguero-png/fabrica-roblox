--!strict
-- La sala arcade en bloques grises (etapa 7b-1), generada por código para que viva en git.
-- Sala de Config.Sala.Ancho × Largo studs centrada en el origen, sobre la Baseplate:
--   - pared norte (z negativo): tu máquina Plinko Knight al centro (tag "Maquina", atributo Indice)
--     con su pantalla (tag "Pantalla"), su banqueta y su ProximityPrompt "Jugar", y 4 máquinas de
--     fondo a los costados. La sala es en solitario: servidores de 1 jugador;
--   - pared oeste: 3 máquinas de fondo más (no se juegan; pantalla de demo, tag "PantallaDemo");
--   - pared este: el mostrador de la sala (tag "Tienda", ProximityPrompt "Ver bolas");
--   - pared sur: entrada con molinete y la pared de récords (tag "Records");
--   - al centro, el pedestal donde server/Sala pone la estatua de tu avatar.
-- Todo anclado; la decoración sin CanTouch/CanQuery. Los carteles con texto son SurfaceGui.
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
	solida: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Anchored = true
	p.Size = tamanio
	p.CFrame = cframe
	p.Color = Color3.fromHex(hex)
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	-- Lo que no es piso, pared o mueble no choca ni se toca.
	p.CanCollide = solida == true
	p.CanTouch = false
	p.CanQuery = solida == true
	p.Parent = padre
	return p
end

-- Cartel con texto sobre una cara de una parte.
local function cartel(en: BasePart, cara: Enum.NormalId, texto: string, hex: string?): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = en
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.fromHex(hex or C.Cartel)
	t.Text = texto
	t.Parent = gui
	return t
end

local function maquina(padre: Instance, indice: number, x: number, z: number): Model
	local m = Instance.new("Model")
	m.Name = "Maquina" .. indice
	local t = S.MaquinaTamanio
	local cuerpo = parte("Cuerpo", m, t, CFrame.new(x, t.Y / 2, z), C.Maquina, true)
	m.PrimaryPart = cuerpo
	-- Cartel de arriba (sin texto en el modelo de la IA; acá, para ubicarse en gris).
	local arriba = parte(
		"Cartel",
		m,
		Vector3.new(t.X, 1, 0.4),
		CFrame.new(x, t.Y + 0.5, z + t.Z / 2 - 0.2),
		C.Fondo
	)
	cartel(arriba, Enum.NormalId.Back, "PLINKO KNIGHT")
	-- Pantalla (en la cara que mira a la sala, +Z).
	local p = S.PantallaTamanio
	local pantalla =
		parte("Pantalla", m, p, CFrame.new(x, t.Y * 0.68, z + t.Z / 2 + p.Z / 2), C.Pantalla)
	pantalla.Material = Enum.Material.Neon
	CollectionService:AddTag(pantalla, "Pantalla")
	-- Botonera.
	parte(
		"Botonera",
		m,
		Vector3.new(t.X, 0.4, 1.2),
		CFrame.new(x, t.Y * 0.42, z + t.Z / 2 + 0.6),
		C.Fondo,
		true
	)
	-- Banqueta delante.
	local banqueta = parte(
		"Banqueta",
		m,
		Vector3.new(2.5, 1.6, 1.6),
		CFrame.new(x, 1.25, z + t.Z / 2 + 2.6) * CFrame.Angles(0, 0, math.rad(90)),
		C.Fondo,
		true
	)
	banqueta.Shape = Enum.PartType.Cylinder

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Jugar"
	prompt.ActionText = "Jugar"
	prompt.ObjectText = "Plinko Knight"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = S.DistanciaJugar
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false -- se prende solo para el dueño (lo hace el cliente)
	prompt.Parent = cuerpo

	m:SetAttribute("Indice", indice)
	m:SetAttribute("Dueno", 0)
	CollectionService:AddTag(m, "Maquina")
	m.Parent = padre
	return m
end

-- Máquina de fondo (no se juega): `cf` es el centro de la base mirando a la sala (LookVector).
-- tipo: 1 naves, 2 autos, 3 laberinto (más baja).
local function maquinaFondo(padre: Instance, indice: number, tipo: number, cf: CFrame)
	local m = Instance.new("Model")
	m.Name = "MaquinaFondo" .. indice
	local t = Vector3.new(3.6, if tipo == 3 then 5 else 7, 3)
	parte("Cuerpo", m, t, cf * CFrame.new(0, t.Y / 2, 0), C.Fondo, true)
	local pantalla = parte(
		"Pantalla",
		m,
		Vector3.new(2.8, 2, 0.1),
		cf * CFrame.new(0, t.Y * 0.65, -(t.Z / 2 + 0.05)),
		C.Pantalla
	)
	pantalla.Material = Enum.Material.Neon
	CollectionService:AddTag(pantalla, "PantallaDemo")
	m.Parent = padre
end

function GeneradorSala.generar(): Folder
	local vieja = Workspace:FindFirstChild("Sala")
	if vieja then
		vieja:Destroy()
	end
	local sala = Instance.new("Folder")
	sala.Name = "Sala"
	local medioX, medioZ = S.Ancho / 2, S.Largo / 2

	-- Piso, techo y paredes (con un hueco de entrada en la pared sur).
	parte("Piso", sala, Vector3.new(S.Ancho, 1, S.Largo), CFrame.new(0, -0.45, 0), C.Piso, true) -- apenas arriba de la Baseplate
	parte(
		"Techo",
		sala,
		Vector3.new(S.Ancho, 1, S.Largo),
		CFrame.new(0, S.Alto + 0.5, 0),
		C.Pared,
		true
	)
	parte(
		"ParedNorte",
		sala,
		Vector3.new(S.Ancho, S.Alto, 1),
		CFrame.new(0, S.Alto / 2, -medioZ - 0.5),
		C.Pared,
		true
	)
	for _, lado in { -1, 1 } do
		parte(
			"ParedLado",
			sala,
			Vector3.new(1, S.Alto, S.Largo),
			CFrame.new(lado * (medioX + 0.5), S.Alto / 2, 0),
			C.Pared,
			true
		)
		-- Pared sur, a los dos lados de la entrada (8 studs de ancho).
		local anchoTramo = medioX - 4
		parte(
			"ParedSur",
			sala,
			Vector3.new(anchoTramo, S.Alto, 1),
			CFrame.new(lado * (4 + anchoTramo / 2), S.Alto / 2, medioZ + 0.5),
			C.Pared,
			true
		)
	end
	local dintel = parte(
		"Dintel",
		sala,
		Vector3.new(8, S.Alto - 8, 1),
		CFrame.new(0, 8 + (S.Alto - 8) / 2, medioZ + 0.5),
		C.Pared,
		true
	)
	cartel(dintel, Enum.NormalId.Front, "ARCADE")

	-- Molinete de entrada.
	parte("Molinete", sala, Vector3.new(1, 3, 1), CFrame.new(-1.5, 1.5, medioZ - 2), C.Fondo, true)
	parte("Molinete", sala, Vector3.new(1, 3, 1), CFrame.new(1.5, 1.5, medioZ - 2), C.Fondo, true)

	-- Pedestal al centro: la estatua es tu avatar en grande (la pone server/Sala al entrar).
	parte("Pedestal", sala, Vector3.new(5, 2, 5), CFrame.new(0, 1, 1), C.Fondo, true)

	-- Pared norte: tu máquina Plinko Knight al centro (la sala es solo tuya: servidores de 1
	-- jugador) y 2 máquinas de fondo a cada lado, mirando a la sala.
	local maquinas = Instance.new("Folder")
	maquinas.Name = "Maquinas"
	maquinas.Parent = sala
	local zMaquina = -medioZ + S.MaquinaTamanio.Z / 2 + 0.5
	for i = 1, S.Maquinas do
		local x = (i - (S.Maquinas + 1) / 2) * S.SeparacionMaquinas
		maquina(maquinas, i, x, zMaquina)
	end
	for i, x in { -2, -1, 1, 2 } do
		local pos = Vector3.new(x * S.SeparacionMaquinas, 0, zMaquina)
		maquinaFondo(sala, 3 + i, (i - 1) % 3 + 1, CFrame.lookAt(pos, pos + Vector3.new(0, 0, 1)))
	end
	local tituloFila = parte(
		"CartelFila",
		sala,
		Vector3.new(24, 2.5, 0.2),
		CFrame.new(0, S.Alto - 2.5, -medioZ + 0.2),
		C.Pared
	)
	cartel(tituloFila, Enum.NormalId.Back, "PLINKO KNIGHT")

	-- 3 máquinas de fondo contra la pared oeste (naves, autos, laberinto): no se juegan.
	for i, z in { -4, 2, 8 } do
		local pos = Vector3.new(-S.Ancho / 2 + 2, 0, z)
		maquinaFondo(sala, i, i, CFrame.lookAt(pos, pos + Vector3.new(1, 0, 0)))
	end

	-- Mostrador de la sala contra la pared este, mirando a la sala (-X).
	local mostrador = parte(
		"Mostrador",
		sala,
		Vector3.new(3, 3.5, 10),
		CFrame.new(medioX - 3.5, 1.75, 2),
		C.Maquina,
		true
	)
	CollectionService:AddTag(mostrador, "Tienda")
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "VerBolas"
	prompt.ActionText = "Elegir bola"
	prompt.ObjectText = "Mostrador"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = S.DistanciaJugar
	prompt.RequiresLineOfSight = false
	prompt.Parent = mostrador
	local cartelTienda = parte(
		"CartelTienda",
		sala,
		Vector3.new(0.2, 2.5, 10),
		CFrame.new(medioX - 0.4, 8, 2),
		C.Pared
	)
	cartel(cartelTienda, Enum.NormalId.Left, "TIENDA")

	-- Pared de récords: en la pared sur, a la izquierda de la entrada, mirando a la sala (-Z).
	local records = parte(
		"Records",
		sala,
		Vector3.new(16, 9, 0.4),
		CFrame.new(-16, 6, medioZ - 0.3),
		C.Pantalla
	)
	CollectionService:AddTag(records, "Records")

	-- Aparecer adentro, al lado de la entrada.
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		spawn.CFrame = CFrame.new(0, 0.6, medioZ - 6) -- mirando a las máquinas (-Z)
		spawn.Size = Vector3.new(6, 1, 6)
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
