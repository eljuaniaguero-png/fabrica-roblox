--!strict
-- Arma el tablero en Workspace solo para este jugador (lo crea el cliente, así que no se
-- replica) y deja la cámara fija de frente. Pantalla en 3 columnas (ficha): panel a la
-- izquierda (todavía vacío), tablero al centro y el monstruo a la derecha: un cartel plano con
-- su barra de vida arriba. El caballero es un bloque al lado del lanzador.
-- Etapa 9 (guía "Cripta azul"): piedra azulada, fondo de mazmorra (imagen de ForgeGUI) detrás de
-- todo, 2 velas cian con luz a los costados del tablero, niebla cian abajo, el caballero como
-- imagen plana. Todo anclado y sin colisión (CanCollide/CanTouch/CanQuery = false).

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
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
		Config.Colores.Fondo,
		Enum.Material.Slate
	)
	for _, x in { izq - 0.5, der + 0.5 } do
		parte(
			"Pared",
			modelo,
			Vector3.new(1, alto, 1.5),
			CFrame.new(aMundo(x, centroY, 0)),
			Config.Colores.Gris,
			Enum.Material.Cobblestone
		)
	end
	parte(
		"Techo",
		modelo,
		Vector3.new(der - izq + 2, 1, 1.5),
		CFrame.new(aMundo(0, arriba + 0.5, 0)),
		Config.Colores.Gris,
		Enum.Material.Cobblestone
	)
	-- Piso liso (sin casilleros): la bola lo cruza y termina el tiro.
	parte(
		"Piso",
		modelo,
		Vector3.new(der - izq + 2, 0.6, 1.5),
		CFrame.new(aMundo(0, abajo - 0.3, 0)),
		Config.Colores.Gris,
		Enum.Material.Cobblestone
	)
	-- Niebla cian abajo de todo (solo decoración: sin casilleros ni números).
	local niebla = parte(
		"Niebla",
		modelo,
		Vector3.new(der - izq, 1.6, 0.2),
		CFrame.new(aMundo(0, abajo + 0.8, -0.6)),
		Config.Colores.Magia,
		Enum.Material.Neon
	)
	niebla.Transparency = 0.82
	-- Lanzador: un bloque arriba, de donde sale la bola.
	parte(
		"Lanzador",
		modelo,
		Vector3.new(2.4, 1.6, 1.5),
		CFrame.new(aMundo(tablero.LanzadorX, tablero.LanzadorY + 1.6, 0)),
		Config.Colores.Gris,
		Enum.Material.Metal
	)
	-- Caballero: imagen plana a la izquierda del lanzador (una parte invisible con su SurfaceGui).
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
		imagenCaballero.Image = Config.Assets.Caballero
		imagenCaballero.Parent = gui
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

	-- Fondo de mazmorra (imagen de ForgeGUI) bien atrás, más grande que lo que se ve.
	do
		local ancho = (xMonstruo + ANCHO_MONSTRUO) * 4.2
		local fondo = parte(
			"FondoMazmorra",
			modelo,
			Vector3.new(ancho, ancho * 9 / 16, 0.2),
			CFrame.new(aMundo(0, centroY, -20)),
			Config.Colores.Fondo
		)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.LightInfluence = 0
		gui.Brightness = 0.8
		gui.CanvasSize = Vector2.new(1600, 900)
		gui.Parent = fondo
		local imagen = Instance.new("ImageLabel")
		imagen.BackgroundTransparency = 1
		imagen.Size = UDim2.fromScale(1, 1)
		imagen.ScaleType = Enum.ScaleType.Crop
		imagen.Image = Config.Assets.Fondo
		imagen.Parent = gui
	end

	-- 2 luces cian a los costados del tablero (las velas que se ven son las del fondo pintado):
	-- partes invisibles, solo para colgar la luz.
	for _, x in { izq - 2.2, der + 2.2 } do
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
		luz.Color = Color3.fromHex(Config.Colores.Magia)
		luz.Brightness = Config.Mundo.BrilloVela
		luz.Range = Config.Mundo.AlcanceVela
		luz.Shadows = false
		luz.Parent = llama
	end

	-- Luz fría de mazmorra (solo en este cliente).
	Lighting.Ambient = Color3.fromHex("#3A4A6E")
	Lighting.OutdoorAmbient = Color3.fromHex("#2F3B57")
	Lighting.Brightness = 1
	Lighting.ClockTime = 0
	Lighting.GlobalShadows = false
	local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosfera.Density = Config.Mundo.Niebla
	atmosfera.Offset = 0
	atmosfera.Color = Color3.fromHex("#2F3B57")
	atmosfera.Decay = Color3.fromHex("#151B2E")
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
	local zonaLibre: (() -> (number, number))? = nil
	RunService:BindToRenderStep("CamaraTablero", Enum.RenderPriority.Last.Value + 10, function()
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
		local mira = centro + Vector3.new(0, subir, 0)
		camara.CFrame = CFrame.lookAt(mira + Vector3.new(0, 0, distancia), mira) + corrimiento
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
		aMundo = aMundo,
		aTablero = aTablero,
	}
end

return Escena
