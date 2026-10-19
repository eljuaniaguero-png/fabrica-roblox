--!strict
-- Carteles de los lugares (Banco, Tienda, Ruleta, Museo...). El servidor (GeneradorMapa) solo
-- marca la parte con el tag "Letrero" y sus atributos; acá se dibuja con Estilo.cartelLugar.
-- Abajo, en el piso, un aro de luz del color del lugar que late (como las referencias).

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)

local filtroPiso = RaycastParams.new()
filtroPiso.FilterType = Enum.RaycastFilterType.Include

local function aro(p: BasePart, color: Color3)
	local mapa = Workspace:FindFirstChild("Mapa")
	local terreno = mapa and mapa:FindFirstChild("Terreno")
	if not terreno then
		return
	end
	filtroPiso.FilterDescendantsInstances = { terreno }
	local r = Workspace:Raycast(p.Position, Vector3.new(0, -60, 0), filtroPiso)
	if not r then
		return
	end
	local disco = Instance.new("Part")
	disco.Name = "AroLugar"
	disco.Shape = Enum.PartType.Cylinder
	disco.Size = Vector3.new(0.15, 16, 16)
	disco.CFrame = CFrame.new(r.Position + Vector3.new(0, 0.1, 0))
		* CFrame.Angles(0, 0, math.pi / 2)
	disco.Anchored = true
	disco.CanCollide, disco.CanTouch, disco.CanQuery = false, false, false
	disco.CastShadow = false
	disco.Material = Enum.Material.Neon
	disco.Color = color
	disco.Transparency = 0.55
	disco.Parent = p
	if not Efectos.reducidos() then
		TweenService:Create(
			disco,
			TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.85 }
		):Play()
	end
end

local function dibujar(p: Instance)
	if not p:IsA("BasePart") or p:FindFirstChild("CartelLugar") then
		return
	end
	local texto = p:GetAttribute("LetreroTexto")
	local color = p:GetAttribute("LetreroColor")
	local alto = p:GetAttribute("LetreroAlto")
	local icono = p:GetAttribute("LetreroIcono")
	if typeof(texto) ~= "string" then
		return
	end
	local b = Estilo.cartelLugar(
		p,
		if typeof(alto) == "number" then alto else 4,
		texto,
		if typeof(icono) == "string" then icono else nil,
		if typeof(color) == "string" then Color3.fromHex(color) else nil
	)
	b.Parent = p
	aro(p, if typeof(color) == "string" then Color3.fromHex(color) else Color3.fromHex("#FFD93D"))
end

CollectionService:GetInstanceAddedSignal("Letrero"):Connect(dibujar)
for _, p in CollectionService:GetTagged("Letrero") do
	dibujar(p)
end
