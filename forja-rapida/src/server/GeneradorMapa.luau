--!strict
-- Arma el mapa al arrancar el servidor desde MapaDatos.luau (que sale del diseño en Blender:
-- forja-rapida/arte/scripts/mapa.py). Así el mapa vive en git y no hace falta subir mallas.
--   Bloques    cajas de terreno ya juntadas (pocas partes), ancladas, con su material.
--   Marcadores lugares con función: les pone su tag y sus atributos y les arma su aspecto
--              (vitrinas, tableros, puertas de los biomas, puertas secretas, cofres, altares,
--              portales, el cartel del Museo y luces de las cámaras secretas).
-- Si ya hay un workspace.Mapa (por ejemplo armado a mano en Studio), no hace nada.

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local MapaDatos = require(script.Parent.MapaDatos)

local GeneradorMapa = {}

type Marcador = {
	Tipo: string,
	Pos: { number },
	Tam: { number },
	Giro: number,
	Atributos: { [string]: any },
}

local TAGS: { [string]: string } = {
	PuntoGeoda = "PuntoGeoda",
	PuntoAncestral = "PuntoAncestral",
	Vitrina = "Vitrina",
	Tablero = "TableroClasificacion",
	PuertaZona = "PuertaZona",
	PuertaSecreta = "PuertaSecreta",
	Cofre = "Cofre",
	Altar = "Altar",
	Portal = "Portal",
	DestinoPortal = "DestinoPortal",
}

local function material(nombre: string): Enum.Material
	local ok, m = pcall(function()
		return (Enum.Material :: any)[nombre]
	end)
	return if ok and typeof(m) == "EnumItem"
		then m :: Enum.Material
		else Enum.Material.SmoothPlastic
end

local function parte(
	nombre: string,
	tam: Vector3,
	cf: CFrame,
	color: string,
	mat: Enum.Material,
	padre: Instance
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Color = Color3.fromHex(color)
	p.Material = mat
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

local function decorativa(p: BasePart)
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.CastShadow = false
end

-- Terreno -----------------------------------------------------------------------------------

local function terreno(carpeta: Instance)
	local mats = {}
	for i, m in MapaDatos.Materiales do
		mats[i] = {
			Color = Color3.fromHex(m.Color),
			Material = material(m.Material),
			Transparencia = m.Transparencia,
			Choca = m.Choca,
		}
	end
	for bloque in MapaDatos.Bloques:gmatch("[^;]+") do
		local v = {}
		for n in bloque:gmatch("[^,]+") do
			table.insert(v, tonumber(n) or 0)
		end
		local m = mats[v[1]]
		if m and #v == 7 then
			local tam = Vector3.new(v[5], v[6], v[7])
			local p = Instance.new("Part")
			p.Name = "Bloque"
			p.Size = tam
			p.Position = Vector3.new(v[2], v[3], v[4]) + tam / 2
			p.Anchored = true
			p.Color = m.Color
			p.Material = m.Material
			p.Transparency = m.Transparencia
			p.CanCollide = m.Choca
			p.CanTouch = false
			p.TopSurface = Enum.SurfaceType.Smooth
			p.BottomSurface = Enum.SurfaceType.Smooth
			p.Parent = carpeta
		end
	end
end

-- Marcadores --------------------------------------------------------------------------------

local function armarMarcador(m: Marcador, carpeta: Instance)
	local pos = Vector3.new(m.Pos[1], m.Pos[2], m.Pos[3])
	local tam = Vector3.new(m.Tam[1], m.Tam[2], m.Tam[3])
	local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(m.Giro), 0)
	local a = m.Atributos
	local p: BasePart

	if m.Tipo == "Spawn" then
		local s = Instance.new("SpawnLocation")
		s.Name = "Spawn"
		s.Size = tam
		s.CFrame = cf
		s.Anchored = true
		s.Neutral = true
		s.Duration = 0
		s.Color = Color3.fromHex("#FFFFFF")
		s.Material = Enum.Material.Pavement
		s.Parent = carpeta
		return
	elseif m.Tipo == "Luz" then
		local ancla =
			parte("Luz", Vector3.new(1, 1, 1), cf, "#FFFFFF", Enum.Material.SmoothPlastic, carpeta)
		ancla.Transparency = 1
		decorativa(ancla)
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromHex(a.Color or "#FFFFFF")
		luz.Range = 22
		luz.Brightness = 1.5
		luz.Shadows = false
		luz.Parent = ancla
		return
	elseif m.Tipo == "Vitrina" then
		p = parte(
			"Vitrina",
			Vector3.new(2, 5, 5),
			CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
			"#2A2F4F",
			Enum.Material.SmoothPlastic,
			carpeta
		)
		local cilindro = p :: Part
		cilindro.Shape = Enum.PartType.Cylinder
	elseif m.Tipo == "Tablero" then
		p = parte("Tablero", tam, cf, "#1B1F3B", Enum.Material.SmoothPlastic, carpeta)
		local marco = parte(
			"Marco",
			tam + Vector3.new(1, 1, -0.4),
			cf * CFrame.new(0, 0, 0.4),
			"#7A2FE0",
			Enum.Material.SmoothPlastic,
			p
		)
		decorativa(marco)
	elseif m.Tipo == "PuertaZona" then
		p = parte("PuertaZona", tam, cf, "#9CFBFF", Enum.Material.ForceField, carpeta)
		p.Transparency = 0.2
		p.CastShadow = false
	elseif m.Tipo == "PuertaSecreta" then
		-- una pared del color del risco con grietas que brillan apenas
		p = parte(
			"PuertaSecreta",
			tam,
			cf,
			a.Color or "#8D939C",
			material(a.Material or "Slate"),
			carpeta
		)
		for k = 0, 2 do
			local g = parte(
				"Grieta",
				Vector3.new(0.3, 2.6, 0.4),
				cf
					* CFrame.new(-tam.X / 2 - 0.1, -3 + k * 3, -3 + k * 3)
					* CFrame.Angles(0.5 * (k % 2 * 2 - 1), 0, 0),
				"#C77DFF",
				Enum.Material.Neon,
				p
			)
			g.Transparency = 0.3
			decorativa(g)
		end
	elseif m.Tipo == "Cofre" then
		p = parte("Cofre", tam, cf, "#8A5A2B", Enum.Material.Wood, carpeta)
		local tapa = parte(
			"Tapa",
			Vector3.new(tam.X + 0.2, 0.8, tam.Z + 0.2),
			cf * CFrame.new(0, tam.Y / 2 + 0.4, 0),
			"#FFC83D",
			Enum.Material.Foil,
			p
		)
		decorativa(tapa)
		local brillo = Instance.new("PointLight")
		brillo.Color = Color3.fromHex("#FFC83D")
		brillo.Range = 10
		brillo.Parent = p
	elseif m.Tipo == "Altar" then
		p = parte("Altar", tam, cf, "#B9C2CC", Enum.Material.Slate, carpeta)
		local orbe = parte(
			"Orbe",
			Vector3.new(2.2, 2.2, 2.2),
			cf * CFrame.new(0, tam.Y / 2 + 1.4, 0),
			"#FFE45C",
			Enum.Material.Neon,
			p
		)
		orbe.Shape = Enum.PartType.Ball
		decorativa(orbe)
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromHex("#FFE45C")
		luz.Range = 14
		luz.Parent = orbe
	elseif m.Tipo == "Portal" then
		-- anillo de 8 tramos y un disco que brilla (el que se toca)
		for k = 0, 7 do
			local ang = k / 8 * math.pi * 2
			local tramo = parte(
				"Aro",
				Vector3.new(1, 4.2, 1.2),
				cf
					* CFrame.new(0, math.cos(ang) * 5.2, math.sin(ang) * 5.2)
					* CFrame.Angles(-ang, 0, 0),
				"#C99BFF",
				Enum.Material.Neon,
				carpeta
			)
			decorativa(tramo)
		end
		p = parte(
			"Portal",
			Vector3.new(0.6, 9.4, 9.4),
			cf * CFrame.Angles(0, 0, math.pi / 2),
			"#9CFBFF",
			Enum.Material.Neon,
			carpeta
		)
		local cilindro = p :: Part
		cilindro.Shape = Enum.PartType.Cylinder
		p.Transparency = 0.35
		p.CanCollide = false
		p.CanTouch = true
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromHex("#C99BFF")
		luz.Range = 18
		luz.Parent = p
	elseif m.Tipo == "Museo" then
		p = parte("CartelMuseo", tam, cf, "#FFC83D", Enum.Material.Foil, carpeta)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Entrar"
		prompt.ObjectText = "Museo de Minerales"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("Menu", "Museo") -- lo abre el cliente (Secretos.client)
		prompt.Parent = p
		local b = Instance.new("BillboardGui")
		b.Size = UDim2.fromOffset(320, 60)
		b.StudsOffset = Vector3.new(0, 5, 0)
		b.MaxDistance = 90
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.Text = "MUSEO DE MINERALES"
		t.TextColor3 = Color3.fromHex("#FFE45C")
		t.TextStrokeTransparency = 0
		t.Parent = b
		b.Parent = p
	else
		-- puntos y destinos: invisibles
		p = parte(m.Tipo, tam, cf, "#FFFFFF", Enum.Material.SmoothPlastic, carpeta)
		p.Transparency = 1
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	end

	for k, v in a do
		p:SetAttribute(k, v)
	end
	local tag = TAGS[m.Tipo]
	if tag then
		CollectionService:AddTag(p, tag)
	end
end

-- Arma el mapa si no hay uno. Devuelve true si lo armó.
function GeneradorMapa.armar(): boolean
	if Workspace:FindFirstChild("Mapa") then
		return false
	end
	local mapa = Instance.new("Folder")
	mapa.Name = "Mapa"
	local terrenoCarpeta = Instance.new("Folder")
	terrenoCarpeta.Name = "Terreno"
	terrenoCarpeta.Parent = mapa
	terreno(terrenoCarpeta)
	local lugares = Instance.new("Folder")
	lugares.Name = "Lugares"
	lugares.Parent = mapa
	for _, m in MapaDatos.Marcadores :: { Marcador } do
		armarMarcador(m, lugares)
	end
	mapa.Parent = Workspace
	return true
end

return GeneradorMapa
