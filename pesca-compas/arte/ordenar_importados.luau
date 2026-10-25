--!strict
-- Pegar en la Command Bar de Studio DESPUÉS de importar los FBX de arte/fbx con Import 3D
-- (File Dimensions: Meters). Busca en Workspace los modelos importados y los deja donde el
-- código los busca:
--   peces  → ReplicatedStorage.ModelosPeces[<Id>]   (MojarraGlobo, SardinaMaraca, …)
--   cebos  → ReplicatedStorage.ModelosCebos[<Id>]   (CeboLombriz.fbx → "Lombriz", …)
--   caña   → ReplicatedStorage.ModeloCana            (CanaPesca.fbx)
-- Además renombra cada pieza a su rol ("MojarraGlobo_Cuerpo" → "Cuerpo"), pone el Cuerpo como
-- PrimaryPart, deja todo de adorno (sin chocar) y avisa si un modelo salió con la escala mal.
-- Se puede correr las veces que haga falta: si un modelo ya estaba ordenado, lo reemplaza.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")) :: any

type Destino = { Fbx: string, Carpeta: string?, Nombre: string, Largo: number }

local destinos: { Destino } = {}
-- Largo esperado (studs del lado más largo) según la nota "Modelos 3D de los peces".
local LARGO_PEZ: { [string]: number } = {
	MojarraGlobo = 2.5,
	SardinaMaraca = 2.5,
	PejerreyFlauta = 3.6,
	CangrejoCastanuela = 3.2,
	GloboBombo = 3.3,
	AnguilaTeclado = 4.6,
	PulpoDJ = 3.5,
	BallenaBandoneon = 10.5,
}
for _, p in Config.Peces do
	table.insert(destinos, { Fbx = p.Id, Carpeta = "ModelosPeces", Nombre = p.Id, Largo = LARGO_PEZ[p.Id] or 3 })
end
for _, c in Config.Cebos do
	table.insert(destinos, { Fbx = "Cebo" .. c.Id, Carpeta = "ModelosCebos", Nombre = c.Id, Largo = 1.5 })
end
table.insert(destinos, { Fbx = "CanaPesca", Carpeta = nil, Nombre = "ModeloCana", Largo = 6 })

local ROLES = { Cuerpo = true, Aleta = true, Ojo = true, Pupila = true, Brillo = true, Detalle = true, DetalleOscuro = true }

local function rol(nombre: string): string?
	local sufijo = string.match(nombre, "_([^_]+)$") or nombre
	local r = string.match(sufijo, "^%a+")
	return if r and ROLES[r] then r else nil
end

local function carpeta(nombre: string): Folder
	local f = ReplicatedStorage:FindFirstChild(nombre)
	if not f then
		f = Instance.new("Folder")
		f.Name = nombre
		f.Parent = ReplicatedStorage
	end
	return f :: Folder
end

local informe: { string } = {}
local faltan: { string } = {}

for _, d in destinos do
	local m = workspace:FindFirstChild(d.Fbx)
	if not (m and m:IsA("Model")) then
		table.insert(faltan, d.Fbx)
		continue
	end
	local cuerpo: BasePart? = nil
	local sinRol: { string } = {}
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			local r = rol(p.Name)
			if r then
				p.Name = r
			else
				table.insert(sinRol, p.Name)
			end
			if r == "Cuerpo" and not cuerpo then
				cuerpo = p
			end
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			if p:IsA("MeshPart") then
				pcall(function()
					p.CollisionFidelity = Enum.CollisionFidelity.Box
				end)
			end
		end
	end
	if cuerpo then
		local pivote = m:GetPivot() -- el del FBX (centro, puño o anzuelo): que no se pierda
		m.PrimaryPart = cuerpo
		cuerpo.PivotOffset = cuerpo.CFrame:ToObjectSpace(pivote)
	end

	local tam = m:GetExtentsSize()
	local largo = math.max(tam.X, tam.Y, tam.Z)
	local ratio = largo / d.Largo
	local aviso = ""
	if ratio > 3 or ratio < 1 / 3 then
		aviso = string.format("  ⚠ ESCALA: mide %.2f y debería medir ~%.1f. Reimportá con File Dimensions: Meters.", largo, d.Largo)
	end
	if not cuerpo then
		aviso ..= "  ⚠ sin pieza Cuerpo"
	end
	if #sinRol > 0 then
		aviso ..= "  ⚠ piezas sin rol: " .. table.concat(sinRol, ", ")
	end

	local padre: Instance = if d.Carpeta then carpeta(d.Carpeta) else ReplicatedStorage
	local viejo = padre:FindFirstChild(d.Nombre)
	if viejo then
		viejo:Destroy()
	end
	m.Name = d.Nombre
	m:PivotTo(CFrame.new())
	m.Parent = padre
	table.insert(informe, string.format("✔ %s → %s.%s (%.2f studs)%s", d.Fbx, padre.Name, d.Nombre, largo, aviso))
end

print("— Ordenar modelos importados —")
for _, linea in informe do
	print(linea)
end
if #faltan > 0 then
	warn("No encontré en Workspace: " .. table.concat(faltan, ", "))
end
print(string.format("Listo: %d de %d. Guardá con Ctrl+S.", #informe, #destinos))
