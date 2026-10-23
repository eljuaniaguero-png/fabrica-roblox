--!strict
-- Arma el modelo 3D de un pez listo para mostrar: lo clona de ReplicatedStorage.ModelosPeces[Id]
-- (los FBX de arte/fbx, importados por Juani) y lo pinta por rol. Si todavía no se importaron,
-- arma uno provisorio con piezas básicas y los mismos nombres de rol, así el juego ya funciona
-- y cuando lleguen los modelos de verdad no hay que tocar código.
-- Roles (nombre de cada MeshPart): Cuerpo, Aleta, Ojo, Pupila, Brillo, Detalle, DetalleOscuro.
-- Convención: la cabeza mira al LookVector del PrimaryPart (Cuerpo).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Config)
local Estilo = require(script.Parent.Estilo)

export type Opciones = {
	Largo: number?, -- studs del lado más largo; nil = tamaño original
	Afinado: boolean?, -- contorno dorado y destellos
	Silueta: boolean?, -- todo de un color: pez que todavía no se sacó
	Contorno: boolean?, -- false = sin Highlight propio (cuando el padre ya tiene uno)
}

local ModeloPez = {}

local function pezPorId(id: string): Config.Pez?
	for _, p in Config.Peces do
		if p.Id == id then
			return p
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

-- Provisorio: bola con cola y ojos enormes. Mira a -Z como los FBX.
local function provisorio(): Model
	local m = Instance.new("Model")
	local cuerpo = pieza(m, "Cuerpo", Enum.PartType.Ball, Vector3.one * 1.8, CFrame.new())
	local cola = Instance.new("WedgePart")
	cola.Name = "Aleta"
	cola.Size = Vector3.new(0.3, 1.4, 1)
	cola.CFrame = CFrame.new(0, 0, 1.2) * CFrame.Angles(0, math.pi, 0)
	cola.Parent = m
	for _, x in { -0.55, 0.55 } do
		pieza(m, "Ojo", Enum.PartType.Ball, Vector3.one * 0.8, CFrame.new(x, 0.3, -0.55))
		pieza(m, "Pupila", Enum.PartType.Ball, Vector3.one * 0.42, CFrame.new(x * 1.12, 0.3, -0.82))
		pieza(m, "Brillo", Enum.PartType.Ball, Vector3.one * 0.16, CFrame.new(x * 1.12 + 0.08, 0.42, -0.98))
	end
	m.PrimaryPart = cuerpo
	return m
end

local function rol(nombre: string): string
	return string.match(nombre, "^%a+") or nombre -- "Cuerpo.001" o "Ojo2" cuentan como su rol
end

local function colorDe(r: string, base: Color3): Color3
	local P = Estilo.Pez
	if r == "Cuerpo" then
		return base
	elseif r == "Aleta" then
		return base:Lerp(Estilo.Contorno, P.Aleta)
	elseif r == "Detalle" then
		return base:Lerp(Color3.new(1, 1, 1), P.Detalle)
	elseif r == "Ojo" then
		return P.Ojo
	elseif r == "Pupila" then
		return P.Pupila
	elseif r == "Brillo" then
		return P.Brillo
	elseif r == "DetalleOscuro" then
		return P.DetalleOscuro
	end
	return base
end

-- Pinta por rol y deja todo de adorno: anclado, sin chocar ni recibir raycasts ni Touched.
function ModeloPez.pintar(m: Model, id: string, silueta: boolean?)
	local pez = pezPorId(id)
	local base = if pez then pez.Color else Estilo.Pez.Silueta
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			d.CastShadow = false
			d.Material = Enum.Material.SmoothPlastic
			d.Reflectance = 0
			d.Color = if silueta then Estilo.Pez.Silueta else colorDe(rol(d.Name), base)
		end
	end
end

function ModeloPez.crear(id: string, opciones: Opciones?): Model
	local op: Opciones = opciones or {}
	local carpeta = ReplicatedStorage:FindFirstChild("ModelosPeces")
	local molde = carpeta and carpeta:FindFirstChild(id)
	local m: Model = if molde and molde:IsA("Model") then molde:Clone() else provisorio()
	m.Name = "Pez_" .. id
	if not m.PrimaryPart then
		local cuerpo = m:FindFirstChild("Cuerpo", true)
		if cuerpo and cuerpo:IsA("BasePart") then
			m.PrimaryPart = cuerpo
		end
	end
	ModeloPez.pintar(m, id, op.Silueta)

	if op.Largo then
		local tam = m:GetExtentsSize()
		local mayor = math.max(tam.X, tam.Y, tam.Z)
		if mayor > 0 then
			m:ScaleTo(m:GetScale() * op.Largo / mayor)
		end
	end

	if op.Contorno ~= false then
		local h = Instance.new("Highlight")
		h.Name = "Contorno"
		h.FillTransparency = 1
		h.OutlineColor = if op.Afinado then Estilo.Pez.Afinado else Estilo.Contorno
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = m
	end

	if op.Afinado and not op.Silueta and m.PrimaryPart then
		local destellos = Instance.new("ParticleEmitter")
		destellos.Name = "Destellos"
		destellos.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		destellos.Color = ColorSequence.new(Estilo.Pez.Afinado)
		destellos.LightEmission = 1
		destellos.Size = NumberSequence.new(0.35, 0)
		destellos.Lifetime = NumberRange.new(0.5, 0.9)
		destellos.Rate = 14
		destellos.Speed = NumberRange.new(1, 2.5)
		destellos.SpreadAngle = Vector2.new(180, 180)
		destellos.Parent = m.PrimaryPart
	end
	return m
end

return ModeloPez
