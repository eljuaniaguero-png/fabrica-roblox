--!strict
-- Arma la caña del personaje y los cebos listos para usar: los clona de
-- ReplicatedStorage.ModeloCana y ReplicatedStorage.ModelosCebos[Id] (los FBX de arte/fbx que
-- importa Juani) y los pinta por rol. Si todavía no se importaron, arma unos provisorios con
-- piezas básicas y los mismos nombres de rol: cuando lleguen los de verdad no se toca código.
-- Roles (nombre de cada pieza): Cuerpo, Aleta, Ojo, Pupila, Brillo, Detalle, DetalleOscuro.
-- Convenciones (nota "Modelos 3D de cebos y caña"):
--   caña: pivote en el centro del puño, la vara apunta a -Z; la punta es la pieza Brillo (la nota).
--   cebo: pivote arriba, donde entra el anzuelo.
-- Las piezas quedan soldadas al PrimaryPart, sin anclar y sin chocar: el que las usa decide
-- si las ancla (vitrina, tienda) o las suelda a la mano.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Config)
local Estilo = require(script.Parent.Estilo)

local ModeloEquipo = {}

local LARGO_CANA = 6 -- studs, si el modelo no tiene pieza Brillo para ubicar la punta

-- Blender nombra las piezas "<Id>_<Rol>" (CanaPesca_Brillo): el rol es lo que va después del
-- último "_". "Aleta.001" también cuenta como Aleta.
local function rol(nombre: string): string
	local sufijo = string.match(nombre, "_([^_]+)$") or nombre
	return string.match(sufijo, "^%a+") or sufijo
end

local function buscarRol(m: Instance, r: string): BasePart?
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and rol(d.Name) == r then
			return d
		end
	end
	return nil
end

local function pieza(m: Model, nombre: string, forma: Enum.PartType, tam: Vector3, cf: CFrame): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Shape = forma
	p.Size = tam
	p.CFrame = cf
	p.Parent = m
	return p
end

local A_LO_LARGO = CFrame.Angles(0, math.pi / 2, 0) -- el eje del cilindro (X) pasa a Z

-- Provisoria: puño, vara, carrete y la nota de la punta. Pivote en el puño, apunta a -Z.
local function canaProvisoria(): Model
	local m = Instance.new("Model")
	local puno = pieza(m, "Detalle", Enum.PartType.Cylinder, Vector3.new(1, 0.32, 0.32), A_LO_LARGO)
	pieza(m, "Cuerpo", Enum.PartType.Cylinder, Vector3.new(5.2, 0.16, 0.16), CFrame.new(0, 0, -3.1) * A_LO_LARGO)
	pieza(m, "Aleta", Enum.PartType.Cylinder, Vector3.new(0.25, 0.6, 0.6), CFrame.new(0, -0.35, -0.15))
	pieza(m, "DetalleOscuro", Enum.PartType.Block, Vector3.new(0.3, 0.1, 0.1), CFrame.new(0.25, -0.35, -0.15))
	pieza(m, "Brillo", Enum.PartType.Ball, Vector3.one * 0.45, CFrame.new(0, 0.12, -5.8))
	m.PrimaryPart = puno
	-- con PrimaryPart, Roblox ignora WorldPivot: el pivote sale de PivotOffset
	puno.PivotOffset = puno.CFrame:Inverse()
	return m
end

-- Provisorio: bola con ojos enormes colgando del pivote (arriba). Mira a -Z.
local function ceboProvisorio(): Model
	local m = Instance.new("Model")
	local cuerpo = pieza(m, "Cuerpo", Enum.PartType.Ball, Vector3.one * 0.7, CFrame.new(0, -0.45, 0))
	for _, x in { -0.15, 0.15 } do
		pieza(m, "Ojo", Enum.PartType.Ball, Vector3.one * 0.3, CFrame.new(x, -0.35, -0.25))
		pieza(m, "Pupila", Enum.PartType.Ball, Vector3.one * 0.15, CFrame.new(x * 1.1, -0.35, -0.38))
	end
	m.PrimaryPart = cuerpo
	cuerpo.PivotOffset = cuerpo.CFrame:Inverse() -- pivote arriba, en el origen
	return m
end

local function clonar(molde: Instance?, provisorio: () -> Model): Model
	local m = if molde and molde:IsA("Model") then molde:Clone() else provisorio()
	if not m.PrimaryPart then
		local cuerpo = buscarRol(m, "Cuerpo") or m:FindFirstChildWhichIsA("BasePart", true)
		if cuerpo then
			local pivote = m:GetPivot() -- el del FBX (puño / anzuelo): que no se pierda al elegir PrimaryPart
			m.PrimaryPart = cuerpo
			cuerpo.PivotOffset = cuerpo.CFrame:ToObjectSpace(pivote)
		end
	end
	return m
end

-- Adorno que se mueve: sin anclar, sin chocar, sin raycasts ni Touched, sin peso para el
-- personaje y soldado al PrimaryPart (los FBX importados llegan como piezas sueltas).
local function prepararPiezas(m: Model)
	local principal = m.PrimaryPart
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			d.CastShadow = false
			d.Massless = true
			d.Material = Enum.Material.SmoothPlastic
			d.Reflectance = 0
			if principal and d ~= principal then
				local w = Instance.new("WeldConstraint")
				w.Part0 = principal
				w.Part1 = d
				w.Parent = d
			end
		end
	end
end

local function nivelCarrete(nivel: number): number
	return math.clamp(nivel, 1, #Estilo.Cana.Carrete)
end

local DESTELLO = "DestelloDorado"

local function destello(parte: BasePart): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = DESTELLO
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Estilo.Cana.Destello)
	e.LightEmission = 1
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Lifetime = NumberRange.new(0.4, 0.7)
	e.Rate = 5 -- pocos: lo lleva cada jugador con el pase y se ve en todo el server
	e.Speed = NumberRange.new(0.5, 1.2)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Parent = parte
	return e
end

-- Pinta el carrete con el color del nivel de caña (se llama de nuevo al mejorar).
-- dorado = el jugador tiene el pase Carrete Dorado: pisa el color del nivel y suma destellos.
function ModeloEquipo.pintarCarrete(m: Model, nivel: number, dorado: boolean?)
	local n = nivelCarrete(nivel)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and rol(d.Name) == "Aleta" then
			local brillo = dorado or n >= Estilo.Cana.NeonDesde
			d.Color = if dorado then Estilo.Cana.CarreteDorado else Estilo.Cana.Carrete[n]
			d.Material = if brillo then Enum.Material.Neon else Enum.Material.SmoothPlastic
			local e = d:FindFirstChild(DESTELLO)
			if dorado and not e then
				destello(d)
			elseif not dorado and e then
				e:Destroy()
			end
		end
	end
end

function ModeloEquipo.cana(nivel: number, dorado: boolean?): Model
	local m = clonar(ReplicatedStorage:FindFirstChild("ModeloCana"), canaProvisoria)
	m.Name = "Cana"
	prepararPiezas(m)
	local C = Estilo.Cana
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			local r = rol(d.Name)
			if r == "Cuerpo" then
				d.Color = C.Madera
			elseif r == "Detalle" then
				d.Color = C.Corcho
			elseif r == "DetalleOscuro" then
				d.Color = C.Metal
			elseif r == "Brillo" then
				d.Color = C.Nota
				d.Material = Enum.Material.Neon -- la nota de la punta brilla: la firma del juego
			end
		end
	end
	ModeloEquipo.pintarCarrete(m, nivel, dorado)
	return m
end

-- Dónde termina la caña (para atar la línea), en el espacio del PrimaryPart.
function ModeloEquipo.puntaLocal(cana: Model): CFrame
	local principal = cana.PrimaryPart :: BasePart
	local nota = buscarRol(cana, "Brillo")
	local punta = if nota
		then CFrame.new(nota.Position)
		else cana:GetPivot() * CFrame.new(0, 0, -LARGO_CANA)
	return principal.CFrame:ToObjectSpace(punta)
end

local function ceboPorId(id: string): Config.Cebo?
	for _, c in Config.Cebos do
		if c.Id == id then
			return c
		end
	end
	return nil
end

-- alto: studs de alto del cebo; nil = tamaño original.
function ModeloEquipo.cebo(id: string, alto: number?): Model
	local carpeta = ReplicatedStorage:FindFirstChild("ModelosCebos")
	local m = clonar(carpeta and carpeta:FindFirstChild(id), ceboProvisorio)
	m.Name = "Cebo_" .. id
	prepararPiezas(m)
	local info = ceboPorId(id)
	local base = if info then info.Color else Estilo.Pez.Silueta
	local P = Estilo.Pez
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			local r = rol(d.Name)
			d.Color = if r == "Aleta"
				then base:Lerp(Estilo.Contorno, P.Aleta)
				elseif r == "Detalle" then base:Lerp(Color3.new(1, 1, 1), P.Detalle)
				elseif r == "DetalleOscuro" then P.DetalleOscuro
				elseif r == "Ojo" then P.Ojo
				elseif r == "Pupila" then P.Pupila
				elseif r == "Brillo" then P.Brillo
				else base
		end
	end
	if alto then
		local tam = m:GetExtentsSize()
		if tam.Y > 0 then
			m:ScaleTo(m:GetScale() * alto / tam.Y)
		end
	end
	return m
end

return ModeloEquipo
