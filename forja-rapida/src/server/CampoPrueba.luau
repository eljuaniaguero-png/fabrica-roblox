--!strict
-- Solo para probar en Studio mientras no exista el mapa: si no hay ningún "PuntoGeoda",
-- arma un piso y 9 puntos de la zona 1 (uno de Jefe) cerca del origen, el lugar del Jefe
-- Ancestral, 4 vitrinas y 2 tableros de clasificación. En el juego publicado
-- no hace nada. Se borra cuando el mapa se genere por código (GeneradorMapa, ver la ficha).

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local CampoPrueba = {}

function CampoPrueba.armarSiFalta()
	if not RunService:IsStudio() or #CollectionService:GetTagged("PuntoGeoda") > 0 then
		return
	end
	warn("[CampoPrueba] no hay PuntoGeoda en el mapa: armo un campo de prueba de la zona 1")
	local carpeta = Instance.new("Folder")
	carpeta.Name = "CampoPrueba"

	local piso = Instance.new("Part")
	piso.Name = "Piso"
	piso.Anchored = true
	piso.Size = Vector3.new(120, 2, 120)
	piso.Position = Vector3.new(0, -1, 40)
	piso.Color = Color3.fromHex("#7ED957")
	piso.TopSurface = Enum.SurfaceType.Studs
	piso.Parent = carpeta

	local function punto(x: number, z: number, jefe: boolean)
		local p = Instance.new("Part")
		p.Name = "PuntoGeoda"
		p.Anchored = true
		p.Size = Vector3.new(2, 0.2, 2)
		p.Position = Vector3.new(x, 0.1, z)
		p:SetAttribute("Zona", 1)
		if jefe then
			p:SetAttribute("Jefe", true)
		end
		p.Parent = carpeta
		CollectionService:AddTag(p, "PuntoGeoda")
	end

	for fila = 0, 1 do
		for columna = -2, 1 do
			punto(columna * 14 + 7, 25 + fila * 14, false)
		end
	end
	punto(0, 75, true)

	-- Grupo 6: lugar del Jefe Ancestral. Grupo 7: 4 vitrinas y 2 tableros de clasificación.
	local ancestral = Instance.new("Part")
	ancestral.Name = "PuntoAncestral"
	ancestral.Anchored = true
	ancestral.Size = Vector3.new(4, 0.2, 4)
	ancestral.Position = Vector3.new(-40, 0.1, 75)
	ancestral.Parent = carpeta
	CollectionService:AddTag(ancestral, "PuntoAncestral")
	for i = 1, 4 do
		local v = Instance.new("Part")
		v.Name = "Vitrina"
		v.Anchored = true
		v.Shape = Enum.PartType.Cylinder
		v.Size = Vector3.new(2, 5, 5)
		v.CFrame = CFrame.new(-30 + i * 12, 1, -10) * CFrame.Angles(0, 0, math.pi / 2)
		v.Color = Color3.fromHex("#2A2F4F")
		v.Material = Enum.Material.SmoothPlastic
		v:SetAttribute("Numero", i)
		v.Parent = carpeta
		CollectionService:AddTag(v, "Vitrina")
	end
	for i, tabla in { "Geodas", "Hallazgo" } do
		local t = Instance.new("Part")
		t.Name = "Tablero" .. tabla
		t.Anchored = true
		t.Size = Vector3.new(14, 10, 1)
		t.CFrame = CFrame.new(-34 + i * 22, 6, -22) * CFrame.Angles(0, math.pi, 0) -- de frente al spawn
		t.Color = Color3.fromHex("#1B1F3B")
		t:SetAttribute("Tabla", tabla)
		t.Parent = carpeta
		CollectionService:AddTag(t, "TableroClasificacion")
	end
	carpeta.Parent = workspace
end

return CampoPrueba
