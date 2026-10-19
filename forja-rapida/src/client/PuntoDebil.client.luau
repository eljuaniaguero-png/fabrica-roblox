--!strict
-- Punto débil (idea elegida del 19/10/2026): dibuja la grieta brillante en el lugar que dice
-- el atributo "PuntoDebil" de cada geoda (lo pone el servidor). Late para que se note; si le
-- pegás ahí, el servidor hace el daño ×2 y la grieta salta a otro lado. Solo muestra: el
-- daño lo decide el servidor (GeodeServerService). Se ve también con "Efectos reducidos",
-- porque es parte del juego y no un adorno.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local P = GameConfig.Golpe.PuntoDebil
local COLOR = Color3.fromHex("#FFF36B")
local DISTANCIA = 120 -- más lejos no se anima

type Grieta = { Parte: BasePart, Tamano: number }
local grietas: { [Model]: Grieta } = {}

local function crear(geoda: Model): Grieta
	-- se mide la roca (el modelo entero incluye el aura y el cartel)
	local roca = geoda:FindFirstChild("Roca", true)
	local medida = if roca and roca:IsA("BasePart") then roca.Size.Magnitude else 8
	local tamano = P.Tamano * math.clamp(medida / 10, 0.8, 2)
	local p = Instance.new("Part")
	p.Name = "PuntoDebil"
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.one * tamano
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false -- el rayo del clic pasa y toca la roca justo detrás
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = COLOR
	local luz = Instance.new("PointLight")
	luz.Color = COLOR
	luz.Range = tamano * 3
	luz.Brightness = 1
	luz.Shadows = false
	luz.Parent = p
	local chispas = Instance.new("ParticleEmitter")
	chispas.Color = ColorSequence.new(COLOR)
	chispas.LightEmission = 1
	chispas.Size = NumberSequence.new(tamano * 0.25, 0)
	chispas.Lifetime = NumberRange.new(0.3, 0.6)
	chispas.Speed = NumberRange.new(2, 5)
	chispas.SpreadAngle = Vector2.new(180, 180)
	chispas.Rate = 12
	chispas.Parent = p
	p.Parent = geoda
	return { Parte = p, Tamano = tamano }
end

local function quitar(geoda: Model)
	local g = grietas[geoda]
	if g then
		g.Parte:Destroy()
		grietas[geoda] = nil
	end
end

local function actualizar(geoda: Model)
	local punto = geoda:GetAttribute("PuntoDebil")
	if typeof(punto) ~= "Vector3" or geoda:GetAttribute("Rota") == true then
		quitar(geoda)
		return
	end
	local g = grietas[geoda] or crear(geoda)
	grietas[geoda] = g
	g.Parte.Position = punto
end

local function vigilar(geoda: Instance)
	if not geoda:IsA("Model") then
		return
	end
	actualizar(geoda)
	geoda:GetAttributeChangedSignal("PuntoDebil"):Connect(function()
		actualizar(geoda)
	end)
	geoda:GetAttributeChangedSignal("Rota"):Connect(function()
		actualizar(geoda)
	end)
end

CollectionService:GetInstanceAddedSignal("Geoda"):Connect(vigilar)
CollectionService:GetInstanceRemovedSignal("Geoda"):Connect(function(geoda)
	if geoda:IsA("Model") then
		quitar(geoda)
	end
end)
for _, g in CollectionService:GetTagged("Geoda") do
	vigilar(g)
end

-- Un solo bucle para todas: laten (crecen y achican) y solo las cercanas a la cámara.
RunService.RenderStepped:Connect(function()
	local camara = Workspace.CurrentCamera
	if not camara then
		return
	end
	local t = os.clock()
	local escala = 1 + 0.25 * math.sin(t * 8)
	for _, g in grietas do
		if (g.Parte.Position - camara.CFrame.Position).Magnitude < DISTANCIA then
			g.Parte.Size = Vector3.one * g.Tamano * escala
			g.Parte.Transparency = 0.15 + 0.15 * math.sin(t * 8)
		end
	end
end)
