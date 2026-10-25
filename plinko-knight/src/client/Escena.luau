--!strict
-- Arma el tablero en Workspace solo para este jugador (lo crea el cliente, así que no se
-- replica) y deja la cámara fija de frente. Pantalla en 3 columnas (ficha): panel a la
-- izquierda (todavía vacío), tablero al centro y el monstruo a la derecha: un cartel plano con
-- su barra de vida arriba. El caballero es un bloque al lado del lanzador.
-- Graybox: partes grises ancladas y sin colisión.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local TableroModulo = require(Shared:WaitForChild("Tablero"))

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
	AnclaTotal: BasePart,
	Cartel: BasePart, -- el monstruo (un cartel plano)
	BarraMonstruo: BasePart, -- arriba del cartel
	Caballero: BasePart,
	sacudir: (fuerza: number, duracion: number) -> (),
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
	hex: string
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
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
		Config.Colores.Fondo
	)
	for _, x in { izq - 0.5, der + 0.5 } do
		parte(
			"Pared",
			modelo,
			Vector3.new(1, alto, 1.5),
			CFrame.new(aMundo(x, centroY, 0)),
			Config.Colores.Gris
		)
	end
	parte(
		"Techo",
		modelo,
		Vector3.new(der - izq + 2, 1, 1.5),
		CFrame.new(aMundo(0, arriba + 0.5, 0)),
		Config.Colores.Gris
	)
	-- Piso liso (sin casilleros): la bola lo cruza y termina el tiro.
	parte(
		"Piso",
		modelo,
		Vector3.new(der - izq + 2, 0.6, 1.5),
		CFrame.new(aMundo(0, abajo - 0.3, 0)),
		Config.Colores.Gris
	)
	-- Lanzador: un bloque arriba, de donde sale la bola.
	parte(
		"Lanzador",
		modelo,
		Vector3.new(2.4, 1.6, 1.5),
		CFrame.new(aMundo(tablero.LanzadorX, tablero.LanzadorY + 1.6, 0)),
		Config.Colores.Gris
	)
	-- Caballero: un bloque a la izquierda del lanzador.
	local caballero = parte(
		"Caballero",
		modelo,
		Vector3.new(1.8, 2.6, 1.5),
		CFrame.new(aMundo(tablero.LanzadorX - 3.2, tablero.LanzadorY + 1.9, 0)),
		Config.Colores.Caballero
	)

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

	-- Ancla del TOTAL, arriba de la barra (entre las columnas no entra: hay 3 studs).
	local anclaTotal = parte(
		"AnclaTotal",
		modelo,
		Vector3.new(1, 1, 1),
		CFrame.new(aMundo(xMonstruo, yMonstruo + ALTO_MONSTRUO / 2 + 5.5, 1)),
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
			if c.Tipo == "duplica" then Config.Colores.ClavijaDuplica else Config.Colores.Clavija
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
	RunService:BindToRenderStep("CamaraTablero", Enum.RenderPriority.Last.Value + 10, function()
		local vista = camara.ViewportSize
		local aspecto = if vista.Y > 0 then vista.X / vista.Y else 16 / 9
		local distancia = math.max(mitadAlto / tangente, mitadAncho / (tangente * aspecto))
		local corrimiento = Vector3.zero
		local queda = temblorFin - os.clock()
		if queda > 0 then
			local f = temblorFuerza * queda / temblorDuracion
			corrimiento = Vector3.new((math.random() * 2 - 1) * f, (math.random() * 2 - 1) * f, 0)
		end
		camara.CameraType = Enum.CameraType.Scriptable
		camara.FieldOfView = FOV
		camara.CFrame = CFrame.lookAt(centro + Vector3.new(0, 0, distancia), centro) + corrimiento
	end)

	local function sacudir(fuerza: number, duracion: number)
		temblorFuerza, temblorDuracion = fuerza, math.max(duracion, 0.01)
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
		sacudir = sacudir,
		aMundo = aMundo,
		aTablero = aTablero,
	}
end

return Escena
