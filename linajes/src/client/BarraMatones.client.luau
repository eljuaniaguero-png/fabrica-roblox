--!strict
-- Barra de vida sobre cada matón. Se dibuja en el cliente: solo muestra.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

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
	cartel.Size = UDim2.fromOffset(90, 9)
	cartel.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	cartel.AlwaysOnTop = true
	cartel.MaxDistance = 80
	cartel.ResetOnSpawn = false
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
	fondo.BorderSizePixel = 0
	fondo.Parent = cartel
	local lleno = Instance.new("Frame")
	lleno.BackgroundColor3 = Color3.fromRGB(210, 58, 74)
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
