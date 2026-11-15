--!strict
-- Objetos sueltos de la arena (cajas y barriles) para la Telequinesis: tag "Suelto". Cuando uno
-- se usa (Poderes.server lo destruye) aparece otro en otro lugar al rato. Números en Config.Arena.Sueltos.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local S = Config.Arena.Sueltos
local M = Config.Arena.Mapa
local azar = Random.new()

local carpeta = Instance.new("Folder")
carpeta.Name = "Sueltos"
carpeta.Parent = workspace

local filtro = RaycastParams.new()
filtro.FilterDescendantsInstances = { carpeta }
filtro.FilterType = Enum.RaycastFilterType.Exclude

-- Un lugar al azar sobre el piso de la arena, lejos de la zona segura y no arriba de contenedores.
local function lugar(): Vector3?
	for _ = 1, 30 do
		local x = M.Centro.X + azar:NextNumber(-1, 1) * (M.Ancho / 2 - S.Borde)
		local z = M.Centro.Z + azar:NextNumber(-1, 1) * (M.Largo / 2 - S.Borde)
		local plano = Vector3.new(x, 0, z)
		if (plano - Config.Arena.ZonaCentro).Magnitude > Config.Arena.ZonaRadio + 6 then
			local golpe = workspace:Raycast(Vector3.new(x, 80, z), Vector3.new(0, -120, 0), filtro)
			if golpe and golpe.Position.Y <= S.AlturaPiso then
				return golpe.Position
			end
		end
	end
	return nil
end

local function crear()
	local pos = lugar()
	if not pos then
		return
	end
	local barril = azar:NextNumber() < S.ProporcionBarriles
	local p = Instance.new("Part")
	if barril then
		p.Name = "Barril"
		p.Shape = Enum.PartType.Cylinder
		p.Size = S.Barril.Tam
		p.Material = Enum.Material.Metal
		p.Color = Color3.fromHex(S.Barril.Color)
		p.CustomPhysicalProperties = PhysicalProperties.new(S.Barril.Densidad, 0.4, 0.2)
		p.CFrame = CFrame.new(pos + Vector3.new(0, S.Barril.Tam.X / 2, 0))
			* CFrame.Angles(0, 0, math.rad(90))
	else
		p.Name = "Caja"
		p.Size = S.Caja.Tam
		p.Material = Enum.Material.WoodPlanks
		p.Color = Color3.fromHex(S.Caja.Color)
		p.CustomPhysicalProperties = PhysicalProperties.new(S.Caja.Densidad, 0.5, 0.2)
		p.CFrame = CFrame.new(pos + Vector3.new(0, S.Caja.Tam.Y / 2, 0))
			* CFrame.Angles(0, azar:NextNumber(0, math.pi * 2), 0)
	end
	p.Anchored = false
	p:AddTag("Suelto")
	p.Parent = carpeta
	p.Destroying:Once(function()
		task.delay(S.Vuelve, crear)
	end)
end

-- El mapa se arma al arrancar: se espera a que exista para tirar los rayos al piso.
workspace:WaitForChild("Arena", 30)
task.wait(1)
for _ = 1, S.Cantidad do
	crear()
end

-- Si alguno se cae del mapa, vuelve.
while true do
	task.wait(5)
	for _, o in CollectionService:GetTagged("Suelto") do
		if o:IsA("BasePart") and o.Position.Y < -50 then
			o:Destroy()
		end
	end
end
