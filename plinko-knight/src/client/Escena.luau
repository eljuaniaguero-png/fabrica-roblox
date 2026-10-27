--!strict
-- Arma el tablero en Workspace solo para este jugador (lo crea el cliente, así que no se
-- replica) y deja la cámara fija de frente. Pantalla en 3 columnas (ficha): panel a la
-- izquierda (todavía vacío), tablero al centro y el monstruo a la derecha: un cartel plano con
-- su barra de vida arriba. Al lado del lanzador, tu avatar de Roblox (el busto).
-- Etapa 9 (guía "Cripta azul"): piedra azulada, fondo de mazmorra (imagen de ForgeGUI) detrás de
-- todo, 2 velas cian con luz a los costados del tablero, niebla cian abajo, tu avatar como
-- imagen plana (26/10: el caballero salió del juego; el personaje es el del jugador). Todo anclado y sin colisión (CanCollide/CanTouch/CanQuery = false).

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local TableroModulo = require(Shared:WaitForChild("Tablero"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

-- Lejos del lugar donde aparece el personaje, para que no se vea.
local ORIGEN = Vector3.new(0, 500, 0)
local FOV = 20 -- bajo, para que se vea casi plano
local MARGEN = 1.12 -- aire alrededor de lo que tiene que entrar en pantalla
local ANCHO_MONSTRUO, ALTO_MONSTRUO = 10, 12
local BAJADA_MONSTRUO = 2 -- el cartel va un poco más abajo del centro, para que entren barra y TOTAL
local SEPARACION_COLUMNAS = 3

export type Escena = {
	Tablero: TableroModulo.Tablero,
	Clavijas: { [number]: BasePart },
	Halos: { [number]: BasePart }, -- 27/10: aro de luz detrás de cada clavija (se prende al tocarla)
	Bola: BasePart, -- = Bolas[1]
	Bolas: { BasePart }, -- Config.TopeBolas bolas (las de más, para la bola que se divide)
	Puntos: { BasePart },
	AnclaTotal: BasePart, -- ancla del panel FUERZA × MULTI (columna izquierda)
	Cartel: BasePart, -- el monstruo (un cartel plano)
	BarraMonstruo: BasePart, -- arriba del cartel
	Caballero: BasePart,
	golpearCaballero: (golpeado: boolean) -> (), -- el caballero se pone rojo
	sacudir: (fuerza: number, duracion: number) -> (), -- más suave con "efectos reducidos"
	-- De dónde a dónde (y en px de pantalla) queda libre entre las franjas de arriba y de abajo:
	-- la cámara mete todo ahí, así ninguna pantalla tapa el tablero.
	ponerZonaLibre: (zona: () -> (number, number)) -> (),
	activarCamara: (si: boolean) -> (), -- sentado en la máquina: la cámara mira el tablero
	zoom: (cuanto: number) -> (), -- 27/10: la cámara se acerca de golpe y vuelve (fracción)
	aMundo: (x: number, y: number, z: number?) -> Vector3,
	aTablero: (posicionPantalla: Vector2) -> (number, number),
}

local Escena = {}

local function color(hex: string): Color3
	return Color3.fromHex(hex)
end

local function parte(
	nombre: string,
	padre: Instance,
	tamanio: Vector3,
	cframe: CFrame,
	hex: string,
	material: Enum.Material?
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Size = tamanio
	p.CFrame = cframe
	p.Color = color(hex)
	p.Parent = padre
	return p
end

function Escena.armar(): Escena
	local tablero = TableroModulo.generar()
	local modelo = Instance.new("Model")
	modelo.Name = "TableroLocal"
	-- 26/10: el adentro de la máquina, CloverPit + futurista (Config.Pantalla, variante elegida).
	local v = Config.variantePantalla()
	local materialMarco = (Enum.Material :: any)[v.MaterialMarco] or Enum.Material.CorrodedMetal

	local function aMundo(x: number, y: number, z: number?): Vector3
		return ORIGEN + Vector3.new(x, y, z or 0)
	end

	local izq, der = tablero.ParedIzquierda, tablero.ParedDerecha
	local arriba, abajo = tablero.Techo + 2, tablero.Fondo
	local alto = arriba - abajo
	local centroY = (arriba + abajo) / 2

	-- Fondo oscuro detrás de las clavijas, paredes y techo.
	parte(
		"Fondo",
		modelo,
		Vector3.new(der - izq, alto, 0.5),
		CFrame.new(aMundo(0, centroY, -1)),
		v.Tablero,
		Enum.Material.SmoothPlastic
	)
	-- 27/10: grilla de luz tenue sobre el fondo (pantalla futurista).
	do
		local fondo = modelo:FindFirstChild("Fondo") :: BasePart
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.LightInfluence = 0
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 10
		gui.Parent = fondo
		local function linea(vertical: boolean, f: number)
			local l = Instance.new("Frame")
			l.BorderSizePixel = 0
			l.BackgroundColor3 = Color3.fromHex(v.Neon2)
			l.BackgroundTransparency = 0.86
			l.AnchorPoint = Vector2.new(0.5, 0.5)
			l.Position = if vertical then UDim2.fromScale(f, 0.5) else UDim2.fromScale(0.5, f)
			l.Size = if vertical then UDim2.new(0, 2, 1, 0) else UDim2.new(1, 0, 0, 2)
			l.Parent = gui
		end
		local ancho = der - izq
		for k = 1, math.floor(ancho / 2) - 1 do
			linea(true, k * 2 / ancho)
		end
		for k = 1, math.floor(alto / 2) - 1 do
			linea(false, k * 2 / alto)
		end
	end
	local pulsos: { BasePart } = {} -- neón que late (Escena lo anima)
	local remolino: UIGradient? = nil -- etapa 10b: fondo que gira (variante pixel)
	for _, x in { izq - 0.5, der + 0.5 } do
		parte(
			"Pared",
			modelo,
			Vector3.new(1, alto, 1.5),
			CFrame.new(aMundo(x, centroY, 0)),
			v.Marco,
			materialMarco
		)
	end
	parte(
		"Techo",
		modelo,
		Vector3.new(der - izq + 2, 1, 1.5),
		CFrame.new(aMundo(0, arriba + 0.5, 0)),
		v.Marco,
		materialMarco
	)
	-- Filo de neón en el borde de adentro de las paredes y el techo (marco de máquina).
	for i, x in { izq - 0.08, der + 0.08 } do
		table.insert(
			pulsos,
			parte(
				"FiloNeon",
				modelo,
				Vector3.new(0.16, alto, 0.16),
				CFrame.new(aMundo(x, centroY, 0.8)),
				if i == 1 then v.Neon2 else v.Neon1,
				Enum.Material.Neon
			)
		)
	end
	table.insert(
		pulsos,
		parte(
			"FiloNeon",
			modelo,
			Vector3.new(der - izq + 0.3, 0.16, 0.16),
			CFrame.new(aMundo(0, arriba - 0.08, 0.8)),
			v.Neon1,
			Enum.Material.Neon
		)
	)
	-- Piso liso (sin casilleros): la bola lo cruza y termina el tiro.
	parte(
		"Piso",
		modelo,
		Vector3.new(der - izq + 2, 0.6, 1.5),
		CFrame.new(aMundo(0, abajo - 0.3, 0)),
		v.Marco,
		materialMarco
	)
	-- Niebla cian abajo de todo (solo decoración: sin casilleros ni números).
	local niebla = parte(
		"Niebla",
		modelo,
		Vector3.new(der - izq, 1.6, 0.2),
		CFrame.new(aMundo(0, abajo + 0.8, -0.6)),
		v.Neon2,
		Enum.Material.Neon
	)
	niebla.Transparency = 0.82
	-- Luces chiquitas en el piso que corren (Escena las anima).
	local leds: { BasePart } = {}
	do
		local n = math.floor((der - izq) / 1.2)
		for k = 0, n - 1 do
			local x = izq + 0.6 + k * (der - izq - 1.2) / math.max(n - 1, 1)
			local l = parte(
				"LedPiso",
				modelo,
				Vector3.new(0.35, 0.35, 0.35),
				CFrame.new(aMundo(x, abajo - 0.3, 0.8)),
				v.Neon1,
				Enum.Material.Neon
			)
			l.Shape = Enum.PartType.Ball
			table.insert(leds, l)
		end
	end
	-- Lanzador: un bloque arriba, de donde sale la bola.
	-- 27/10: cuerpo de metal, cañón redondo para abajo y un aro de neón en la boca.
	local aroLanzador: BasePart
	do
		local lx, ly = tablero.LanzadorX, tablero.LanzadorY
		parte(
			"Lanzador",
			modelo,
			Vector3.new(3, 1.2, 1.5),
			CFrame.new(aMundo(lx, ly + 2.1, 0)),
			v.Marco,
			Enum.Material.DiamondPlate
		)
		local canio = parte(
			"Canio",
			modelo,
			Vector3.new(1.4, 1.5, 1.5),
			CFrame.new(aMundo(lx, ly + 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			"#1A1A16",
			Enum.Material.Metal
		)
		canio.Shape = Enum.PartType.Cylinder
		aroLanzador = parte(
			"AroLanzador",
			modelo,
			Vector3.new(0.25, 1.75, 1.75),
			CFrame.new(aMundo(lx, ly + 0.45, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			v.Neon2,
			Enum.Material.Neon
		)
		aroLanzador.Shape = Enum.PartType.Cylinder
	end
	-- Tu avatar: el busto de tu personaje de Roblox, plano, a la izquierda del lanzador (una parte
	-- invisible con su SurfaceGui). El campo se sigue llamando Caballero en el código.
	local caballero = parte(
		"Caballero",
		modelo,
		Vector3.new(5.5, 5.5, 0.2),
		CFrame.new(aMundo(tablero.LanzadorX - 4.2, tablero.LanzadorY + 1.6, 0.4)),
		Config.Colores.Caballero
	)
	caballero.Transparency = 1
	local imagenCaballero = Instance.new("ImageLabel")
	do
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back -- la cámara mira hacia -Z
		gui.LightInfluence = 0
		gui.CanvasSize = Vector2.new(400, 400)
		gui.Parent = caballero
		imagenCaballero.BackgroundTransparency = 1
		imagenCaballero.Size = UDim2.fromScale(1, 1)
		imagenCaballero.ScaleType = Enum.ScaleType.Fit
		imagenCaballero.Parent = gui
		task.spawn(function()
			local ok, imagen = pcall(function()
				local yo = Players.LocalPlayer
				return Players:GetUserThumbnailAsync(
					yo.UserId,
					Enum.ThumbnailType.AvatarBust,
					Enum.ThumbnailSize.Size420x420
				)
			end)
			if ok then
				imagenCaballero.Image = imagen
			end
		end)
	end

	-- Monstruo, a la derecha del tablero: un cartel fino (Monstruo.luau le pone color y nombre).
	local xMonstruo = der + SEPARACION_COLUMNAS + ANCHO_MONSTRUO / 2
	local yMonstruo = centroY - BAJADA_MONSTRUO
	local cartel = parte(
		"Cartel",
		modelo,
		Vector3.new(ANCHO_MONSTRUO, ALTO_MONSTRUO, 0.2),
		CFrame.new(aMundo(xMonstruo, yMonstruo, 0)),
		Config.Colores.Gris
	)
	local barraMonstruo = parte(
		"BarraMonstruo",
		modelo,
		Vector3.new(ANCHO_MONSTRUO, 1.3, 0.2),
		CFrame.new(aMundo(xMonstruo, yMonstruo + ALTO_MONSTRUO / 2 + 1.3, 0)),
		Config.Colores.Gris
	)
	barraMonstruo.Transparency = 1

	-- Ancla del panel FUERZA × MULTI: en la columna izquierda, espejo del monstruo (paso 5a).
	local anclaTotal = parte(
		"AnclaTotal",
		modelo,
		Vector3.new(1, 1, 1),
		CFrame.new(aMundo(-xMonstruo, yMonstruo + 1, 1)),
		Config.Colores.Gris
	)
	anclaTotal.Transparency = 1

	-- Clavijas: cilindros mirando a la cámara.
	local clavijas: { [number]: BasePart } = {}
	local halos: { [number]: BasePart } = {}
	for _, c in tablero.Clavijas do
		local p = parte(
			"Clavija",
			modelo,
			Vector3.new(1, c.Radio * 2, c.Radio * 2),
			CFrame.new(aMundo(c.X, c.Y, 0)) * CFrame.Angles(0, math.rad(90), 0),
			Config.Clavijas.gris.Color -- el color de cada tipo lo pone Main.client con el tablero
		)
		p.Shape = Enum.PartType.Cylinder
		p:SetAttribute("Clavija", c.Id)
		clavijas[c.Id] = p
		-- 27/10: zócalo de metal oscuro atrás y un aro de luz que se prende al tocarla.
		local zocalo = parte(
			"Zocalo",
			modelo,
			Vector3.new(0.3, c.Radio * 2 + 0.45, c.Radio * 2 + 0.45),
			CFrame.new(aMundo(c.X, c.Y, -0.55)) * CFrame.Angles(0, math.rad(90), 0),
			"#121210",
			Enum.Material.Metal
		)
		zocalo.Shape = Enum.PartType.Cylinder
		local halo = parte(
			"Halo",
			modelo,
			Vector3.new(0.1, c.Radio * 4.4, c.Radio * 4.4),
			CFrame.new(aMundo(c.X, c.Y, -0.35)) * CFrame.Angles(0, math.rad(90), 0),
			Config.Clavijas.gris.Color,
			Enum.Material.Neon
		)
		halo.Shape = Enum.PartType.Cylinder
		halo.Transparency = 0.95
		halos[c.Id] = halo
	end

	local radio = Config.Bola.Radio
	local bolas: { BasePart } = {}
	for i = 1, Config.TopeBolas do
		local bola = parte(
			"Bola",
			modelo,
			Vector3.new(radio * 2, radio * 2, radio * 2),
			CFrame.new(aMundo(0, 0, 0.6)),
			Config.Colores.Bola
		)
		bola.Shape = Enum.PartType.Ball
		bola.Transparency = 1
		bolas[i] = bola
		-- 27/10: estela que mira a la cámara (ancho = distancia entre los 2 enganches) y luz propia.
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, 0, radio)
		a0.Parent = bola
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, 0, -radio)
		a1.Parent = bola
		local estela = Instance.new("Trail")
		estela.Name = "Estela"
		estela.Attachment0 = a0
		estela.Attachment1 = a1
		estela.FaceCamera = true
		estela.Lifetime = Config.Feel.Estela
		estela.LightEmission = 1
		estela.WidthScale = NumberSequence.new(1, 0)
		estela.Transparency = NumberSequence.new(0.1, 1)
		estela.Enabled = false
		estela.Parent = bola
		local luzBola = Instance.new("PointLight")
		luzBola.Name = "Luz"
		luzBola.Brightness = Config.Feel.LuzBola.Brillo
		luzBola.Range = Config.Feel.LuzBola.Alcance
		luzBola.Shadows = false
		luzBola.Enabled = false
		luzBola.Parent = bola
	end

	local puntos: { BasePart } = {}
	for i = 1, Config.Punteria.PuntosLinea do
		local p = parte(
			"Punto",
			modelo,
			Vector3.new(0.4, 0.4, 0.4),
			CFrame.new(ORIGEN),
			Config.Colores.Bola
		)
		p.Shape = Enum.PartType.Ball
		p.Material = Enum.Material.Neon
		p.Transparency = 1
		puntos[i] = p
	end

	-- Atrás: una pared de metal (o negra brillante, según la variante) más grande que lo que se
	-- ve, con tubos de neón a los costados del tablero y franjas de peligro abajo (CloverPit).
	do
		local ancho = (xMonstruo + ANCHO_MONSTRUO) * 4.2
		local paredFondo = parte(
			"Pared",
			modelo,
			Vector3.new(ancho, ancho * 9 / 16, 0.2),
			CFrame.new(aMundo(0, centroY, -6)),
			v.Pared,
			(Enum.Material :: any)[v.MaterialPared] or Enum.Material.CorrodedMetal
		)
		-- Etapa 10b: remolino lento violeta y cian (degradé que gira) con rayitas, para que se vea
		-- pixelado. Lo anima el Heartbeat de abajo.
		if v.Remolino then
			local gui = Instance.new("SurfaceGui")
			gui.Face = Enum.NormalId.Back
			gui.LightInfluence = 0
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 4
			gui.Parent = paredFondo
			local fondo = Instance.new("Frame")
			fondo.Size = UDim2.fromScale(1, 1)
			fondo.BackgroundColor3 = Color3.new(1, 1, 1)
			fondo.BorderSizePixel = 0
			fondo.Parent = gui
			remolino = Instance.new("UIGradient")
			remolino.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("#1A0F2E")),
				ColorSequenceKeypoint.new(0.3, Color3.fromHex("#4A1E6E")),
				ColorSequenceKeypoint.new(0.5, Color3.fromHex("#14324A")),
				ColorSequenceKeypoint.new(0.7, Color3.fromHex("#4A1E6E")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("#1A0F2E")),
			})
			remolino.Parent = fondo
			for k = 0, 120 do
				local raya = Instance.new("Frame")
				raya.Position = UDim2.fromScale(0, k / 120)
				raya.Size = UDim2.new(1, 0, 0, 2)
				raya.BackgroundColor3 = Color3.new(0, 0, 0)
				raya.BackgroundTransparency = 0.55
				raya.BorderSizePixel = 0
				raya.Parent = fondo
			end
		end
		for i, x in { izq - 1.6, der + 1.6 } do
			local tubo = parte(
				"TuboNeon",
				modelo,
				Vector3.new(0.35, alto + 4, 0.35),
				CFrame.new(aMundo(x, centroY, -0.5)),
				if i == 1 then v.Neon1 else v.Neon2,
				Enum.Material.Neon
			)
			table.insert(pulsos, tubo)
		end
		parte(
			"LineaNeon",
			modelo,
			Vector3.new(der - izq + 3.6, 0.3, 0.3),
			CFrame.new(aMundo(0, arriba + 1.4, -0.5)),
			v.Neon1,
			Enum.Material.Neon
		)
		if v.Franjas then
			local franja = parte(
				"Franjas",
				modelo,
				Vector3.new(der - izq + 2, 1.4, 0.2),
				CFrame.new(aMundo(0, abajo - 1.3, 0.3)),
				"#1C1C1A"
			)
			local gui = Instance.new("SurfaceGui")
			gui.Face = Enum.NormalId.Back
			gui.LightInfluence = 0.3
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 20
			gui.ClipsDescendants = true
			gui.Parent = franja
			for k = -4, 30 do
				local f = Instance.new("Frame")
				f.AnchorPoint = Vector2.new(0.5, 0.5)
				f.Position = UDim2.fromScale(k * 0.05, 0.5)
				f.Size = UDim2.fromScale(0.022, 3)
				f.Rotation = 35
				f.BackgroundColor3 = Color3.fromHex("#E8C21C")
				f.BorderSizePixel = 0
				f.Parent = gui
			end
		end
	end

	-- 2 luces de neón a los costados del tablero (partes invisibles, solo para colgar la luz).
	for i, x in { izq - 2.2, der + 2.2 } do
		local base = parte(
			"Vela",
			modelo,
			Vector3.new(0.8, 2.2, 0.8),
			CFrame.new(aMundo(x, abajo + 1.1, 0)),
			"#D8D2C0",
			Enum.Material.SmoothPlastic
		)
		local llama = parte(
			"Llama",
			modelo,
			Vector3.new(0.5, 0.8, 0.5),
			base.CFrame * CFrame.new(0, 1.5, 0),
			Config.Colores.Magia,
			Enum.Material.Neon
		)
		llama.Shape = Enum.PartType.Ball
		base.Transparency = 1
		llama.Transparency = 1
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromHex(if i == 1 then v.Neon1 else v.Neon2)
		luz.Brightness = Config.Mundo.BrilloVela
		luz.Range = Config.Mundo.AlcanceVela
		luz.Shadows = false
		luz.Parent = llama
	end

	-- Luz oscura del adentro de la máquina (solo en este cliente; también ilumina la sala).
	Lighting.Ambient = Color3.fromHex(v.Ambiente)
	Lighting.OutdoorAmbient = Color3.fromHex(v.Ambiente)
	Lighting.Brightness = 1
	Lighting.ClockTime = 0
	Lighting.GlobalShadows = false
	local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosfera.Density = Config.Mundo.Niebla
	atmosfera.Offset = 0
	atmosfera.Color = Color3.fromHex(v.Ambiente)
	atmosfera.Decay = Color3.fromHex("#08070C")
	atmosfera.Glare = 0
	atmosfera.Haze = 0
	atmosfera.Parent = Lighting

	modelo.Parent = Workspace

	-- Cámara fija: centrada en las 3 columnas, a la distancia justa para que todo entre
	-- (alto del tablero y ancho de las 3 columnas), en compu y en celular horizontal.
	local mitadAncho = (xMonstruo + ANCHO_MONSTRUO / 2) * MARGEN
	local mitadAlto = alto / 2 * MARGEN
	local centro = aMundo(0, centroY, 0)
	local tangente = math.tan(math.rad(FOV / 2))
	local camara = Workspace.CurrentCamera
	-- Temblor: la cámara se corre un poco al azar y se va calmando.
	local temblorFuerza, temblorFin, temblorDuracion = 0, 0, 1
	local zoomFuerza, zoomFin, ZOOM_DURACION = 0, 0, 0.3
	local zonaLibre: (() -> (number, number))? = nil
	local activa = false -- etapa 7b: la cámara del tablero solo manda sentado en la máquina
	RunService:BindToRenderStep("CamaraTablero", Enum.RenderPriority.Last.Value + 10, function()
		if not activa then
			return
		end
		local vista = camara.ViewportSize
		local aspecto = if vista.Y > 0 then vista.X / vista.Y else 16 / 9
		-- Franja libre (en px de la vista): sin franjas, la pantalla entera.
		local arribaLibre, abajoLibre = 0, vista.Y
		local zona = zonaLibre
		if zona then
			local y0, y1 = zona()
			local inset = GuiService:GetGuiInset().Y
			if y1 - y0 > vista.Y * 0.3 then
				arribaLibre, abajoLibre = y0 + inset, y1 + inset
			end
		end
		local fraccion = math.max((abajoLibre - arribaLibre) / math.max(vista.Y, 1), 0.3)
		local distancia =
			math.max(mitadAlto / (tangente * fraccion), mitadAncho / (tangente * aspecto))
		-- Correr la cámara para que el centro de las 3 columnas caiga en el centro de la franja libre.
		local corridoPx = (arribaLibre + abajoLibre) / 2 - vista.Y / 2
		local subir = corridoPx * 2 * distancia * tangente / math.max(vista.Y, 1)
		local corrimiento = Vector3.zero
		local queda = temblorFin - os.clock()
		if queda > 0 then
			local f = temblorFuerza * queda / temblorDuracion
			corrimiento = Vector3.new((math.random() * 2 - 1) * f, (math.random() * 2 - 1) * f, 0)
		end
		camara.CameraType = Enum.CameraType.Scriptable
		camara.FieldOfView = FOV
		local quedaZoom = zoomFin - os.clock()
		if quedaZoom > 0 then
			-- Entra rápido y vuelve suave.
			local f = quedaZoom / ZOOM_DURACION
			distancia *= 1 - zoomFuerza * f * f
		end
		local mira = centro + Vector3.new(0, subir, 0)
		camara.CFrame = CFrame.lookAt(mira + Vector3.new(0, 0, distancia), mira) + corrimiento
	end)

	-- 27/10: el neón late, el aro del lanzador gira de color y las luces del piso corren (solo
	-- sentado en la máquina).
	table.insert(pulsos, aroLanzador)
	local brilloPulsos: { [BasePart]: number } = {}
	for _, p in pulsos do
		brilloPulsos[p] = p.Transparency
	end
	local colorLedA, colorLedB = Color3.fromHex(v.Neon1), Color3.fromHex(v.Neon2)
	RunService.Heartbeat:Connect(function()
		if not activa then
			return
		end
		local t = os.clock()
		local latido = (math.sin(t * math.pi * 2 / Config.Feel.Pulso) + 1) / 2
		for p, base in brilloPulsos do
			p.Transparency = base + latido * 0.35
		end
		-- Etapa 10b: el aro de las clavijas especiales late (si no la tocaron en este tiro).
		for _, h in halos do
			if h:GetAttribute("Especial") and not h:GetAttribute("Tocada") then
				h.Transparency = 0.45 + latido * 0.35
			end
		end
		local r = remolino
		if r then
			r.Rotation = (t * 6) % 360
			r.Offset = Vector2.new(math.sin(t * 0.3) * 0.25, math.cos(t * 0.23) * 0.25)
		end
		local cabeza = (t * 8) % #leds
		for k, l in leds do
			local d = (cabeza - (k - 1)) % #leds
			l.Transparency = math.clamp(d / 5, 0, 0.85)
			l.Color = if d < 1 then colorLedB else colorLedA
		end
	end)

	local function sacudir(fuerza: number, duracion: number)
		temblorFuerza, temblorDuracion = fuerza * Ajustes.factorEfectos(), math.max(duracion, 0.01)
		temblorFin = os.clock() + duracion
	end

	-- De una posición en pantalla (la del mouse o el dedo) al plano del tablero.
	local function aTablero(posicionPantalla: Vector2): (number, number)
		local rayo = camara:ScreenPointToRay(posicionPantalla.X, posicionPantalla.Y)
		local dz = rayo.Direction.Z
		if math.abs(dz) < 1e-6 then
			return 0, -1
		end
		local t = (ORIGEN.Z - rayo.Origin.Z) / dz
		local punto = rayo.Origin + rayo.Direction * t - ORIGEN
		return punto.X, punto.Y
	end

	return {
		Tablero = tablero,
		Clavijas = clavijas,
		Halos = halos,
		Bola = bolas[1],
		Bolas = bolas,
		Puntos = puntos,
		AnclaTotal = anclaTotal,
		Cartel = cartel,
		BarraMonstruo = barraMonstruo,
		Caballero = caballero,
		golpearCaballero = function(golpeado: boolean)
			imagenCaballero.ImageColor3 = if golpeado
				then Color3.fromHex(Config.Colores.Golpe)
				else Color3.new(1, 1, 1)
		end,
		sacudir = sacudir,
		ponerZonaLibre = function(zona: () -> (number, number))
			zonaLibre = zona
		end,
		activarCamara = function(si: boolean)
			activa = si
		end,
		zoom = function(cuanto: number)
			if Ajustes.factorEfectos() <= 0 then
				return
			end
			if zoomFin < os.clock() then
				zoomFuerza = 0
			end
			zoomFuerza = math.max(cuanto, zoomFuerza)
			zoomFin = os.clock() + ZOOM_DURACION
		end,
		aMundo = aMundo,
		aTablero = aTablero,
	}
end

return Escena
