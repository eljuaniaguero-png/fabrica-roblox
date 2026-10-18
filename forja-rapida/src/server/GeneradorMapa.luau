--!strict
-- Arma el mapa al arrancar el servidor desde MapaDatos.luau (que sale del diseño en Blender:
-- forja-rapida/arte/scripts/mapa.py). Así el mapa vive en git y no hace falta subir mallas.
--   Bloques    cajas de terreno ya juntadas (pocas partes), ancladas, con su material.
--   Marcadores lugares con función: les pone su tag y sus atributos y les arma su aspecto
--              (vitrinas, tableros, puertas de los biomas, puertas secretas, cofres, altares,
--              portales, el cartel del Museo y luces de las cámaras secretas).
--              Grupo 4: la Ruleta de Mascotas, la puerta del Santuario del Renacer y los
--              carteles que abren un menú (Misiones, Renacer).
--   Deco       piezas de Blender (Deco_Comun y Deco_Zona1..5 en ServerStorage.Modelos.Deco):
--              árboles, cactus, paredes de ladrillo, riscos, volcán... pintadas con DecoColores.
-- Si ya hay un workspace.Mapa (por ejemplo armado a mano en Studio), no hace nada.

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local DecoColores = require(script.Parent.DecoColores)
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
	Ruleta = "Ruleta",
	PuertaRenacer = "PuertaRenacer",
}

-- Colores de los 8 gajos de la ruleta (los mismos que dibuja el menú).
local GAJOS =
	{ "#FF4D5E", "#FFC93C", "#4CD964", "#2EC8FF", "#9B4DFF", "#FF8C42", "#FF6FD8", "#7CF5FF" }

-- Cartel flotante de un lugar (Museo, Ruleta, Banco...). Solo marca la parte: lo dibuja
-- Letreros.client con Estilo.cartelLugar, así todos los carteles se ven iguales.
local function letrero(p: BasePart, texto: string, color: string, alto: number, icono: string)
	p:SetAttribute("LetreroTexto", texto)
	p:SetAttribute("LetreroColor", color)
	p:SetAttribute("LetreroAlto", alto)
	p:SetAttribute("LetreroIcono", icono)
	CollectionService:AddTag(p, "Letrero")
end

-- ProximityPrompt que abre un menú en el cliente (lo abre Secretos.client por el atributo Menu).
local function abreMenu(p: BasePart, menu: string, accion: string, objeto: string)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = accion
	prompt.ObjectText = objeto
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("Menu", menu)
	prompt.Parent = p
end

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

-- Un MaterialVariant "Studs_<Zona>" por textura (es textura, no geometría: no suma partes).
-- Viven en MaterialService del place (un script no puede crearlos): se arman en Studio con
-- BaseMaterial Plastic, ColorMap = GameConfig.Pisos.Texturas y StudsPerTile de GameConfig.
local SIN_STUDS = { Glass = true, Neon = true, Foil = true, Ice = true, ForceField = true }

local function terreno(carpeta: Instance)
	local mats = {}
	for i, m in MapaDatos.Materiales do
		local base = material(m.Material)
		local zona = GameConfig.Pisos.PorMaterial[m.Nombre]
		local variante = if zona
			then "Studs_" .. zona
			elseif SIN_STUDS[m.Material] then nil
			else "Studs_Liso"
		mats[i] = {
			-- con textura de zona el color ya viene en la imagen: la parte va blanca
			Color = if zona then Color3.new(1, 1, 1) else Color3.fromHex(m.Color),
			Material = if variante then Enum.Material.Plastic else base,
			Variante = variante,
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
			if m.Variante then
				p.MaterialVariant = m.Variante
			end
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
		-- anillo de 8 tramos y un disco que brilla (el que se toca). En mapa.py el portal mira
		-- hacia el Z del marcador (las columnas del marco van a los costados, en su X, y el
		-- destino queda adelante): el anillo y el disco se arman mirando hacia el X de `frente`,
		-- que es el Z del marcador. El disco es un cilindro parado (su eje es su X), así se cruza
		-- caminando y nunca queda acostado arriba de las cabezas.
		local frente = cf * CFrame.Angles(0, math.pi / 2, 0)
		for k = 0, 7 do
			local ang = k / 8 * math.pi * 2
			local tramo = parte(
				"Aro",
				Vector3.new(1, 4.2, 1.2),
				frente
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
			frente,
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
	elseif m.Tipo == "Ruleta" then
		-- Grupo 4: rueda vertical de 8 gajos (de los dos lados) con un puntero arriba. Gira
		-- alrededor del eje Z del marcador; la hace girar cada cliente (Mascotas.client).
		local radio = math.max(tam.X, tam.Y) / 2
		p = parte(
			"Ruleta",
			Vector3.new(1, radio * 2, radio * 2),
			cf * CFrame.Angles(0, math.pi / 2, 0),
			"#1B1F3B",
			Enum.Material.SmoothPlastic,
			carpeta
		)
		local disco = p :: Part
		disco.Shape = Enum.PartType.Cylinder
		local rueda = Instance.new("Model")
		rueda.Name = "Rueda"
		local eje = parte(
			"Eje",
			Vector3.new(radio * 0.3, radio * 0.3, 2.6),
			cf,
			"#FFC83D",
			Enum.Material.Foil,
			rueda
		)
		decorativa(eje)
		for _, lado in { -1, 1 } do
			for k = 1, 8 do
				local ang = (k - 0.5) / 8 * math.pi * 2
				local gajo = parte(
					"Gajo",
					Vector3.new(radio * 0.62, radio * 0.7, 0.4),
					cf * CFrame.Angles(0, 0, ang) * CFrame.new(0, radio * 0.5, lado * 0.7),
					GAJOS[k],
					Enum.Material.SmoothPlastic,
					rueda
				)
				decorativa(gajo)
			end
		end
		rueda.PrimaryPart = eje
		rueda.Parent = p
		local puntero = parte(
			"Puntero",
			Vector3.new(1.4, 1.4, 2.8),
			cf * CFrame.new(0, radio + 0.4, 0) * CFrame.Angles(0, 0, math.pi / 4),
			"#FFFFFF",
			Enum.Material.Neon,
			p
		)
		decorativa(puntero)
		abreMenu(p, "Mascotas", "Girar", "Ruleta de Mascotas")
		letrero(p, "RULETA DE MASCOTAS", "#FF9ED8", radio + 3, "Ruleta")
	elseif m.Tipo == "PuertaRenacer" then
		-- Grupo 4: portón dorado del Santuario; se abre para los que renacieron (Secretos.client)
		p = parte("PuertaRenacer", tam, cf, "#FFD23F", Enum.Material.ForceField, carpeta)
		p.Transparency = 0.15
		p.CastShadow = false
	elseif m.Tipo == "Cartel" then
		p = parte("Cartel", tam, cf, "#2E3358", Enum.Material.SmoothPlastic, carpeta)
		local marco = parte(
			"Marco",
			tam + Vector3.new(0.6, 0.6, -0.2),
			cf * CFrame.new(0, 0, 0.2),
			"#FFC83D",
			Enum.Material.Foil,
			p
		)
		decorativa(marco)
		if a.SinPoste ~= true then -- los carteles de dificultad van pegados al muro
			local poste = parte(
				"Poste",
				Vector3.new(0.8, cf.Position.Y, 0.8),
				CFrame.new(cf.Position.X, cf.Position.Y / 2, cf.Position.Z),
				"#8A5A2B",
				Enum.Material.Wood,
				p
			)
			poste.CanCollide = false
		end
		local menu = if typeof(a.Menu) == "string" then a.Menu else ""
		local texto = if typeof(a.Texto) == "string" then a.Texto else menu
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Front
		sg.PixelsPerStud = 40
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.Text = texto
		t.TextColor3 = Color3.fromHex("#FFE45C")
		t.TextStrokeTransparency = 0
		t.Parent = sg
		sg.Parent = p
		local sg2 = sg:Clone()
		sg2.Face = Enum.NormalId.Back
		sg2.Parent = p
		if menu ~= "" then
			abreMenu(p, menu, "Abrir", texto)
		end
	elseif m.Tipo == "Museo" then
		p = parte("CartelMuseo", tam, cf, "#FFC83D", Enum.Material.Foil, carpeta)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Entrar"
		prompt.ObjectText = "Museo de Minerales"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("Menu", "Museo") -- lo abre el cliente (Secretos.client)
		prompt.Parent = p
		letrero(p, "MUSEO DE MINERALES", "#FFE45C", 5, "Gema")
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

-- Piezas del lobby (Lobby.fbx) --------------------------------------------------------------

-- Pedestal de cada lugar de la parcela (como el render de lobby.py).
local function versionPedestal(n: number): string
	return if n % 5 == 0
		then "Pedestal_Cristal"
		elseif n % 5 >= 3 then "Pedestal_Piedra"
		else "Pedestal_Madera"
end

-- Lugares de los 10 pedestales en la parcela (lobby.py: LUGARES_X y LUGARES_Y; Blender y = -z).
local LUGARES_X = 12
local LUGARES_Z = { 11, 5, -1, -7, -13 }

-- Copia una pieza, la agranda y la apoya en el piso del marcador. Todas las piezas tienen el
-- pivote en el centro de su base y el frente hacia -Z.
local function copiarPieza(
	molde: Instance,
	nombre: string,
	cf: CFrame,
	padre: Instance,
	escala: number
): Model?
	local m = molde:FindFirstChild(nombre)
	if not (m and m:IsA("Model")) then
		return nil
	end
	local copia = m:Clone()
	copia:ScaleTo(copia:GetScale() * GameConfig.Modelos.EscalaLobby * escala)
	copia:PivotTo(cf)
	local colores = GameConfig.Modelos.ColoresLobby[nombre] or {}
	for _, d in copia:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			-- "Tienda_Forja_Techo.001" -> "Techo"; "Pico_1_Cabeza" -> "Cabeza"
			local malla = d.Name:gsub("%.%d+$", "")
			malla = malla:gsub("^" .. nombre .. "_", "")
			malla = malla:gsub("^Pico_%d_", "")
			local color = colores[malla]
			if color then
				d.Color = Color3.fromHex(color)
				d.Material = Enum.Material.SmoothPlastic
			end
			if GameConfig.Modelos.BrillanLobby[malla] then
				d.Material = Enum.Material.Neon
				d.Transparency = if malla == "AlfombraBorde" then 0.4 else 0
				d.CastShadow = false
			end
		end
	end
	copia.Parent = padre
	return copia
end

local function alfombraConMenu(m: Model, menu: string, texto: string)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Name:match("_Alfombra$") then
			abreMenu(d, menu, "Abrir", texto)
			return
		end
	end
end

-- Letrero flotante arriba del cartel de la pieza (el cartel de Blender viene sin texto).
local function cartelPieza(m: Model, texto: string, color: string, alto: number, icono: string)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Name:match("_Cartel") then
			letrero(d, texto, color, alto, icono)
			return
		end
	end
end

local function armarPieza(m: Marcador, molde: Instance, carpeta: Instance)
	local nombre = m.Atributos.Nombre
	if typeof(nombre) ~= "string" then
		return
	end
	local cf = CFrame.new(m.Pos[1], m.Pos[2], m.Pos[3]) * CFrame.Angles(0, math.rad(m.Giro), 0)
	local escala = if typeof(m.Atributos.Escala) == "number" then m.Atributos.Escala else 1
	local p = copiarPieza(molde, nombre, cf, carpeta, escala)
	if not p then
		return
	end
	for k, v in m.Atributos do
		p:SetAttribute(k, v)
	end
	if nombre == "Puesto_Vender" then
		alfombraConMenu(p, "Mochila", "Banco")
		cartelPieza(p, "BANCO", "#FFE45C", 3, "Banco")
	elseif nombre == "Tienda_Forja" then
		alfombraConMenu(p, "Tienda", "Tienda")
		cartelPieza(p, "TIENDA", "#B8FF6A", 3, "Tienda")
	elseif nombre == "Ruleta_Mascotas" then
		-- la rueda que gira la arma el marcador Ruleta en el mismo lugar
		local rueda = p:FindFirstChild("Rueda")
		if rueda then
			rueda:Destroy()
		end
	elseif nombre == "Parcela_Exhibicion" then
		CollectionService:AddTag(p, "Parcela")
		for i = 1, 10 do
			local lado = if i <= 5 then -1 else 1
			local z = LUGARES_Z[(i - 1) % 5 + 1]
			local lugar = cf
				* CFrame.new(lado * LUGARES_X * escala, escala, z * escala)
				* CFrame.Angles(0, lado * math.pi / 2, 0)
			local ped = copiarPieza(molde, versionPedestal(i), lugar, p, escala)
			if ped then
				ped.Name = ("Pedestal%02d"):format(i)
				ped:SetAttribute("Lugar", i)
			end
		end
	end
end

-- Decoración (Deco_Comun y Deco_Zona1..5) ------------------------------------------------------

-- Busca la pieza por nombre en la carpeta Deco (el paquete puede traer grupos intermedios).
local function moldeDeco(carpeta: Instance, nombre: string): Model?
	local m = carpeta:FindFirstChild(nombre, true)
	return if m and m:IsA("Model") then m else nil
end

-- Copia la pieza, la agranda, la apoya con el centro de su base en el marcador y la pinta.
local function armarDeco(m: Marcador, carpetaDeco: Instance, padre: Instance)
	local nombre = m.Atributos.Nombre
	if typeof(nombre) ~= "string" then
		return
	end
	local molde = moldeDeco(carpetaDeco, nombre)
	if not molde then
		return
	end
	local escala = if typeof(m.Atributos.Escala) == "number" then m.Atributos.Escala else 1
	local choca = m.Atributos.Choca == true
	local copia = molde:Clone()
	copia:ScaleTo(copia:GetScale() * GameConfig.Modelos.EscalaDeco * escala)
	-- el FBX llega acostado: se para girándolo en x (lo de arriba queda en +z de la pieza)
	copia:PivotTo(CFrame.new())
	local caja, tam = copia:GetBoundingBox()
	local base = Vector3.new(caja.X, caja.Y, caja.Z + tam.Z / 2)
	local parar = CFrame.Angles(math.rad(GameConfig.Modelos.GiroDeco), 0, 0)
	local cf = CFrame.new(m.Pos[1], m.Pos[2], m.Pos[3]) * CFrame.Angles(0, math.rad(m.Giro), 0)
	copia:PivotTo(cf * parar * CFrame.new(-base))
	for _, d in copia:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = choca
			d.CanTouch = false
			d.CanQuery = choca
			local c = DecoColores[(d.Name:gsub("%.%d+$", ""))]
			if c then
				d.Color = Color3.fromHex(c.Color)
				d.Material = if c.Neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
				d.Transparency = c.Transparencia
				if c.Neon or c.Transparencia > 0 then
					d.CastShadow = false
				end
			end
		end
	end
	if nombre:match("^Nube") or nombre:match("^Arcoiris") then -- el cielo no hace sombra
		for _, d in copia:GetDescendants() do
			if d:IsA("BasePart") then
				d.CastShadow = false
			end
		end
	end
	copia.Name = nombre
	copia.Parent = padre
end

-- Si están las piezas, el Spawn queda invisible arriba de la plataforma y la ruleta usa la
-- flecha de la pieza en vez del puntero.
local function ajustarConPiezas(lugares: Instance, piezas: Instance)
	local spawn = lugares:FindFirstChild("Spawn")
	if spawn and spawn:IsA("SpawnLocation") then -- sin adorno: el spawn no se ve
		spawn.Transparency = 1
		spawn.CFrame = CFrame.new(spawn.Position.X, 2.5, spawn.Position.Z)
		for _, d in spawn:GetChildren() do
			if d:IsA("Decal") then
				d:Destroy()
			end
		end
	end
	local ruleta = lugares:FindFirstChild("Ruleta")
	if ruleta and piezas:FindFirstChild("Ruleta_Mascotas") then
		local puntero = ruleta:FindFirstChild("Puntero")
		if puntero then
			puntero:Destroy()
		end
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
	local modelos = ServerStorage:FindFirstChild(GameConfig.Modelos.Carpeta)
	local molde = modelos and modelos:FindFirstChild(GameConfig.Modelos.Lobby)
	local piezas = Instance.new("Folder")
	piezas.Name = "Piezas"
	piezas.Parent = mapa
	local carpetaDeco = modelos and modelos:FindFirstChild(GameConfig.Modelos.Deco)
	local deco = Instance.new("Folder")
	deco.Name = "Deco"
	deco.Parent = mapa
	for i, m in MapaDatos.Marcadores :: { Marcador } do
		if m.Tipo == "Deco" then
			if carpetaDeco then
				armarDeco(m, carpetaDeco, deco)
			end
		elseif m.Tipo ~= "Pieza" then
			armarMarcador(m, lugares)
		elseif molde then
			armarPieza(m, molde, piezas)
		end
		if i % 200 == 0 then
			task.wait() -- que el servidor no se trabe armando cientos de piezas
		end
	end
	ajustarConPiezas(lugares, piezas)
	mapa.Parent = Workspace
	return true
end

return GeneradorMapa
