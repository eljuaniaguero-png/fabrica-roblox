--!strict
-- Barra de vida sobre cada matón: línea fina de 86 x 4 px con el estilo editorial de Tema.
-- Se dibuja en el cliente: solo muestra.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local B = Config.Hud.BarraMaton
local gui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function ponerBarra(m: Instance)
	if not (m:IsA("Model") and m:GetAttribute("Maton")) then
		return
	end
	local raiz = m:WaitForChild("HumanoidRootPart", 5)
	local h = m:WaitForChild("Humanoid", 5)
	if not (raiz and raiz:IsA("BasePart") and h and h:IsA("Humanoid")) then
		return
	end
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "BarraMaton"
	cartel.Adornee = raiz
	cartel.Size = UDim2.fromOffset(B.Ancho, B.Alto)
	cartel.StudsOffsetWorldSpace = Vector3.new(0, B.Altura, 0)
	cartel.AlwaysOnTop = true
	cartel.MaxDistance = B.Distancia
	cartel.ResetOnSpawn = false
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Tema.Fondo
	fondo.BackgroundTransparency = 0.25
	fondo.BorderSizePixel = 0
	fondo.Parent = cartel
	local borde = Instance.new("UIStroke")
	borde.Color = Tema.Hueso
	borde.Transparency = 0.82
	borde.Thickness = 1
	borde.Parent = fondo
	local lleno = Instance.new("Frame")
	lleno.BackgroundColor3 = Tema.Vida
	lleno.BorderSizePixel = 0
	lleno.Parent = fondo
	local function actualizar()
		lleno.Size = UDim2.fromScale(math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1), 1)
		cartel.Enabled = h.Health > 0
	end
	h.HealthChanged:Connect(actualizar)
	h:GetPropertyChangedSignal("MaxHealth"):Connect(actualizar)
	actualizar()
	cartel.Parent = gui
	m.Destroying:Once(function()
		cartel:Destroy()
	end)
end

CollectionService:GetInstanceAddedSignal("Combatiente"):Connect(ponerBarra)
for _, m in CollectionService:GetTagged("Combatiente") do
	task.spawn(ponerBarra, m)
end
