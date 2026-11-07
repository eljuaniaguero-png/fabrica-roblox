--!strict
-- Carteles de neón inventados: son la luz principal de la arena y pintan el piso de color.
-- Datos en shared/Iluminacion.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Luz = require(ReplicatedStorage.Shared.Iluminacion)

local O = Config.Arena.Mapa.Centro
local carpeta = Instance.new("Folder")
carpeta.Name = "ArenaNeon"

local function parte(tamano: Vector3, cf: CFrame, tono: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = tamano
	p.CFrame = cf
	p.Color = tono
	p.Material = material
	p.Parent = carpeta
	return p
end

local function reflejo(cf: CFrame, ancho: number, tono: Color3)
	local largo = Luz.ReflejoLargo
	local piso = parte(
		Vector3.new(ancho * 1.25, 0.05, largo),
		cf * CFrame.new(0, 0, -largo / 2),
		tono,
		Enum.Material.SmoothPlastic
	)
	piso.Transparency = 1
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.LightInfluence = 0
	gui.Brightness = 1.4
	gui.Parent = piso
	local mancha = Instance.new("Frame")
	mancha.Size = UDim2.fromScale(1, 1)
	mancha.BackgroundColor3 = tono
	mancha.BorderSizePixel = 0
	mancha.Parent = gui
	local degrade = Instance.new("UIGradient")
	degrade.Rotation = Luz.ReflejoGiro
	degrade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, Luz.ReflejoFuerza),
		NumberSequenceKeypoint.new(1, 1),
	})
	degrade.Parent = mancha
end

local function cartel(c: any)
	local tono = Color3.fromHex(c.Color)
	local cf = CFrame.new(O + Vector3.new(c.X, 0, c.Z)) * CFrame.Angles(0, math.rad(c.Giro), 0)
	local arriba = cf * CFrame.new(0, c.Altura, 0)
	local base = parte(
		Vector3.new(c.Ancho, c.Alto, 1),
		arriba,
		Color3.fromHex("#0d0f16"),
		Enum.Material.Metal
	)
	for _, lado in { -1, 1 } do
		parte(
			Vector3.new(c.Ancho + 1, 0.5, 0.5),
			arriba * CFrame.new(0, lado * c.Alto / 2, -0.5),
			tono,
			Enum.Material.Neon
		)
		parte(
			Vector3.new(0.5, c.Alto + 1, 0.5),
			arriba * CFrame.new(lado * c.Ancho / 2, 0, -0.5),
			tono,
			Enum.Material.Neon
		)
		parte(
			Vector3.new(1.2, c.Altura, 1.2),
			cf * CFrame.new(lado * c.Ancho * 0.35, c.Altura / 2, 1),
			Color3.fromHex("#2a2d35"),
			Enum.Material.Metal
		)
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Brightness = 2.2
	gui.Parent = base
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(0.94, 0.86)
	texto.Position = UDim2.fromScale(0.03, 0.07)
	texto.BackgroundTransparency = 1
	texto.Font = Enum.Font.GothamBlack
	texto.Text = c.Texto
	texto.TextScaled = true
	texto.TextColor3 = tono
	texto.Parent = gui
	local luz = Instance.new("SurfaceLight")
	luz.Face = Enum.NormalId.Front
	luz.Color = tono
	luz.Brightness = Luz.NeonBrillo
	luz.Range = Luz.NeonAlcance
	luz.Angle = 120
	luz.Shadows = false
	luz.Parent = base
	reflejo(cf * CFrame.new(0, 0.2, -1), c.Ancho, tono)
end

for _, c in Luz.Carteles do
	cartel(c)
end
carpeta.Parent = workspace
