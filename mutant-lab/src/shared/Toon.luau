--!strict
-- Estilo toon (ideas/estilo-toon.md): material plano, colores de la paleta y contorno grueso.
-- Todo lo que tenga que verse toon pasa por acá; nada de contornos sueltos en otros archivos.
--
-- Contorno por casco invertido: a cada pieza se le pega una copia un poco más grande, del color
-- Contorno y con las caras dadas vuelta. Roblox dibuja solo la parte de atrás de esa copia, que
-- asoma alrededor de la pieza como el borde de un dibujo animado (también entre piezas: la pata
-- delante del cuerpo lleva su raya). Las copias salen de cuatro mallas (esfera, caja, cilindro y
-- cuña) que se importan una vez a ReplicatedStorage > Arte > Toon
-- (arte/export/Toon/_PaqueteToon.obj). Mientras falten, se arman por código con EditableMesh
-- (anda en Studio; en el juego publicado solo con "Enable Mesh / Image APIs" prendido), y si
-- tampoco se puede, el modelo lleva un Highlight (borde finito, máximo Config.Toon.MaxHighlights).
--
-- Los cascos los pone cada cliente (client/Contornos.client.luau) en lo marcado con el tag
-- "Toon": no viajan por la red y, con StreamingEnabled, solo existen cerca del jugador.
-- El servidor usa Toon.aplicar o Toon.marcar; el cliente y Studio pueden llamar a Toon.contorno.

local AssetService = game:GetService("AssetService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local Paleta = require(script.Parent.Paleta)

local C = Config.Toon

export type Opciones = {
	Grosor: number?, -- studs de contorno (si no, Config.Toon.Grosor)
	Ajustar: boolean?, -- llevar cada color al más parecido de la paleta (decoración, escenario)
	SinContorno: boolean?, -- solo material y colores
}

local Toon = {}

Toon.TAG = "Toon"
Toon.NOMBRE = "Contorno"

-- Colores a los que se puede ajustar una pieza con Opciones.Ajustar.
local COLORES: { Color3 } = {}
for _, color in Paleta.Toon :: { [string]: Color3 } do
	table.insert(COLORES, color)
end
for _, color in Paleta.Elementos :: { [string]: Color3 } do
	table.insert(COLORES, color)
end

-- El color de la paleta más parecido (distancia "redmean", que se parece a cómo lo ve el ojo).
function Toon.colorCercano(color: Color3): Color3
	local mejor, distancia = color, math.huge
	for _, c in COLORES do
		local r = (color.R + c.R) / 2
		local dr, dg, db = color.R - c.R, color.G - c.G, color.B - c.B
		local d = (2 + r) * dr * dr + 4 * dg * dg + (3 - r) * db * db
		if d < distancia then
			mejor, distancia = c, d
		end
	end
	return mejor
end

function Toon.esContorno(parte: Instance): boolean
	return parte:GetAttribute(Toon.NOMBRE) == true
end

-- El modelo marcado más cercano que contiene a `inst` (o nil). Un modelo marcado adentro de otro
-- (una criatura en el laboratorio) se encarga de sus propias piezas, con su grosor.
function Toon.raizDe(inst: Instance): Instance?
	local actual: Instance? = inst
	while actual do
		if CollectionService:HasTag(actual, Toon.TAG) then
			return actual
		end
		actual = actual.Parent
	end
	return nil
end

local function juntar(inst: Instance, lista: { BasePart })
	for _, hijo in inst:GetChildren() do
		if CollectionService:HasTag(hijo, Toon.TAG) or Toon.esContorno(hijo) then
			continue
		end
		if hijo:IsA("BasePart") then
			table.insert(lista, hijo)
		end
		juntar(hijo, lista)
	end
end

-- Las piezas de `raiz`, sin los cascos ni lo que está adentro de otro modelo marcado.
local function partes(raiz: Instance): { BasePart }
	local lista = {}
	if raiz:IsA("BasePart") then
		table.insert(lista, raiz)
	end
	juntar(raiz, lista)
	return lista
end

-- Material plano: SmoothPlastic en todo, sin reflejos. El Neon queda (detalles que brillan) y lo
-- transparente sigue transparente (vidrio).
function Toon.pintarParte(parte: BasePart, opciones: Opciones?)
	if parte.Material ~= Enum.Material.Neon then
		parte.Material = Enum.Material.SmoothPlastic
	end
	parte.MaterialVariant = ""
	parte.Reflectance = 0
	local clave = parte:GetAttribute("ColorToon")
	if typeof(clave) == "string" and (Paleta.Toon :: any)[clave] then
		parte.Color = (Paleta.Toon :: any)[clave]
	elseif opciones and opciones.Ajustar then
		parte.Color = Toon.colorCercano(parte.Color)
	end
end

function Toon.pintar(raiz: Instance, opciones: Opciones?)
	for _, p in partes(raiz) do
		Toon.pintarParte(p, opciones)
	end
end

-- --- Mallas de casco ---

-- Vértices y triángulos de las cuatro mallas, de 1 x 1 x 1 alrededor del origen (las mismas que
-- arte/scripts/toon_base.py escribe en el OBJ). `adentro` les da vuelta las caras al final.
type Malla = { V: { Vector3 }, T: { { number } }, Centro: Vector3 }

local function esfera(): Malla
	local seg, anillos = 16, 12 -- con más vueltas no se nota en el borde y pesa el doble
	local v, t = {}, {}
	for i = 0, anillos do
		local a = math.pi * i / anillos
		for j = 0, seg - 1 do
			local b = 2 * math.pi * j / seg
			table.insert(
				v,
				Vector3.new(math.sin(a) * math.cos(b), math.cos(a), math.sin(a) * math.sin(b)) * 0.5
			)
		end
	end
	for i = 0, anillos - 1 do
		for j = 0, seg - 1 do
			local a, b = i * seg + j + 1, i * seg + (j + 1) % seg + 1
			local c, d = (i + 1) * seg + j + 1, (i + 1) * seg + (j + 1) % seg + 1
			if i > 0 then -- en los polos ese triángulo no tiene superficie
				table.insert(t, { a, b, c })
			end
			if i < anillos - 1 then
				table.insert(t, { b, d, c })
			end
		end
	end
	return { V = v, T = t, Centro = Vector3.zero }
end

local function caja(): Malla
	local v = {}
	for _, x in { -0.5, 0.5 } do
		for _, y in { -0.5, 0.5 } do
			for _, z in { -0.5, 0.5 } do
				table.insert(v, Vector3.new(x, y, z))
			end
		end
	end
	-- Índices: 1 (-,-,-) 2 (-,-,+) 3 (-,+,-) 4 (-,+,+) 5 (+,-,-) 6 (+,-,+) 7 (+,+,-) 8 (+,+,+)
	local t = {}
	for _, q in
		{
			{ 5, 7, 8, 6 },
			{ 1, 2, 4, 3 },
			{ 3, 4, 8, 7 },
			{ 1, 5, 6, 2 },
			{ 2, 6, 8, 4 },
			{ 1, 3, 7, 5 },
		}
	do
		table.insert(t, { q[1], q[2], q[3] })
		table.insert(t, { q[1], q[3], q[4] })
	end
	return { V = v, T = t, Centro = Vector3.zero }
end

local function cilindro(): Malla
	-- Eje en X, como la Part cilíndrica.
	local seg = 24
	local v, t = {}, {}
	for _, x in { -0.5, 0.5 } do
		for j = 0, seg - 1 do
			local b = 2 * math.pi * j / seg
			table.insert(v, Vector3.new(x, 0.5 * math.cos(b), 0.5 * math.sin(b)))
		end
	end
	table.insert(v, Vector3.new(-0.5, 0, 0))
	table.insert(v, Vector3.new(0.5, 0, 0))
	local c0, c1 = 2 * seg + 1, 2 * seg + 2
	for j = 0, seg - 1 do
		local a, b = j + 1, (j + 1) % seg + 1
		local c, d = seg + j + 1, seg + (j + 1) % seg + 1
		table.insert(t, { a, b, c })
		table.insert(t, { b, d, c })
		table.insert(t, { c0, a, b })
		table.insert(t, { c1, c, d })
	end
	return { V = v, T = t, Centro = Vector3.zero }
end

local function cunia(): Malla
	-- Como la WedgePart: alta atrás (+Z) y baja adelante (-Z).
	local v = {
		Vector3.new(-0.5, -0.5, -0.5),
		Vector3.new(0.5, -0.5, -0.5),
		Vector3.new(0.5, -0.5, 0.5),
		Vector3.new(-0.5, -0.5, 0.5),
		Vector3.new(-0.5, 0.5, 0.5),
		Vector3.new(0.5, 0.5, 0.5),
	}
	local t = {
		{ 1, 2, 3 },
		{ 1, 3, 4 },
		{ 4, 3, 6 },
		{ 4, 6, 5 },
		{ 1, 5, 6 },
		{ 1, 6, 2 },
		{ 1, 4, 5 },
		{ 2, 6, 3 },
	}
	return { V = v, T = t, Centro = Vector3.new(0, -1 / 6, 1 / 6) }
end

-- Da vuelta las caras que miran hacia afuera: Roblox muestra el lado desde el que los vértices
-- se ven en sentido antihorario, así que con todas mirando hacia adentro solo se ve el casco
-- de atrás.
local function adentro(m: Malla): Malla
	for _, tri in m.T do
		local a, b, c = m.V[tri[1]], m.V[tri[2]], m.V[tri[3]]
		local n = (b - a):Cross(c - a)
		if n:Dot((a + b + c) / 3 - m.Centro) > 0 then
			tri[2], tri[3] = tri[3], tri[2]
		end
	end
	return m
end

local FORMAS: { [string]: () -> Malla } = {
	CascoEsfera = esfera,
	CascoCaja = caja,
	CascoCilindro = cilindro,
	CascoCunia = cunia,
}

local moldes: { [string]: BasePart }? = nil
local estado = "nuevo" -- "nuevo", "cargando" (armándolas, puede tardar) o "listo"

local function porCodigo(): { [string]: BasePart }?
	local hechos: { [string]: BasePart } = {}
	for nombre, forma in FORMAS do
		local ok, parte = pcall(function()
			local malla = adentro(forma())
			local em = AssetService:CreateEditableMesh()
			local ids = {}
			for i, p in malla.V do
				ids[i] = em:AddVertex(p)
			end
			for _, tri in malla.T do
				em:AddTriangle(ids[tri[1]], ids[tri[2]], ids[tri[3]])
			end
			return AssetService:CreateMeshPartAsync(
				Content.fromObject(em),
				{ CollisionFidelity = Enum.CollisionFidelity.Box }
			)
		end)
		if not ok then
			warn(
				"[Toon] No se pudo armar la malla de contorno " .. nombre .. ": " .. tostring(parte)
			)
			return nil
		end
		hechos[nombre] = parte
	end
	return hechos
end

-- Las cuatro mallas de casco: las importadas o, si faltan, las armadas por código (o nil).
function Toon.moldes(): { [string]: BasePart }?
	while estado == "cargando" do
		task.wait() -- otro las está armando: esperar a que termine
	end
	if estado == "listo" then
		return moldes
	end
	estado = "cargando"
	local arte = ReplicatedStorage:FindFirstChild("Arte")
	local carpeta = arte and arte:FindFirstChild("Toon")
	local importados: { [string]: BasePart } = {}
	for nombre in FORMAS do
		local m = carpeta and carpeta:FindFirstChild(nombre)
		if m and m:IsA("BasePart") then
			importados[nombre] = m
		else
			importados = nil :: any
			break
		end
	end
	moldes = importados or porCodigo()
	estado = "listo"
	return moldes
end

-- Qué malla de casco lleva una pieza y de qué tamaño es la forma que se ve (o nil si ninguna).
local function formaDe(p: BasePart): (string?, Vector3)
	if p:FindFirstChildOfClass("SpecialMesh") or p:IsA("MeshPart") then
		return nil, p.Size -- forma propia: su casco va a venir de Blender
	end
	if p:IsA("WedgePart") then
		return "CascoCunia", p.Size
	end
	if not p:IsA("Part") then
		return nil, p.Size
	end
	local forma = p.Shape
	if forma == Enum.PartType.Ball then
		local d = math.min(p.Size.X, p.Size.Y, p.Size.Z)
		return "CascoEsfera", Vector3.one * d
	elseif forma == Enum.PartType.Cylinder then
		local d = math.min(p.Size.Y, p.Size.Z)
		return "CascoCilindro", Vector3.new(p.Size.X, d, d)
	elseif forma == Enum.PartType.Wedge then
		return "CascoCunia", p.Size
	elseif forma == Enum.PartType.Block then
		return "CascoCaja", p.Size
	end
	return nil, p.Size
end

local function lleva(p: BasePart): boolean
	if Toon.esContorno(p) or p:GetAttribute("SinContorno") or p:FindFirstChild(Toon.NOMBRE) then
		return false
	end
	if p.Transparency > C.Transparencia then
		return false
	end
	return math.max(p.Size.X, p.Size.Y, p.Size.Z) >= C.Minimo
end

-- Pone el casco a una pieza (si le corresponde). Va adentro de la pieza y soldado a ella, así la
-- sigue aunque la muevan sola o con el modelo entero.
function Toon.contornoParte(p: BasePart, grosor: number?): BasePart?
	local lista = Toon.moldes()
	if not lista or not lleva(p) then
		return nil
	end
	local nombre, tam = formaDe(p)
	local molde = nombre and lista[nombre]
	if not molde then
		return nil
	end
	-- Las piezas chicas (ojos, párpados, manchas) llevan una raya más fina que la silueta.
	local medidas = { tam.X, tam.Y, tam.Z }
	table.sort(medidas)
	local g = math.min(grosor or C.Grosor, medidas[2] * C.Proporcion)
	local casco = molde:Clone()
	casco.Name = Toon.NOMBRE
	casco.Size = tam + Vector3.one * (2 * g)
	casco.CFrame = p.CFrame
	casco.Color = Paleta.Contorno
	casco.Material = Enum.Material.SmoothPlastic
	casco.Reflectance = 0
	casco.Transparency = 0
	casco.CastShadow = false
	casco.CanCollide = false
	casco.CanTouch = false
	casco.CanQuery = false
	casco.Massless = true
	casco.Anchored = false
	casco:SetAttribute(Toon.NOMBRE, true)
	local soldadura = Instance.new("WeldConstraint")
	soldadura.Part0 = p
	soldadura.Part1 = casco
	soldadura.Parent = casco
	casco.Parent = p
	return casco
end

-- Highlight cuando no hay mallas de casco: solo el borde de afuera del modelo entero.
local highlights: { [Highlight]: true } = {}

local function resaltar(raiz: Instance)
	if raiz:FindFirstChild(Toon.NOMBRE) then
		return
	end
	local cuantos = 0
	for h in highlights do
		if h.Parent then
			cuantos += 1
		else
			highlights[h] = nil
		end
	end
	if cuantos >= C.MaxHighlights then
		return
	end
	local h = Instance.new("Highlight")
	h.Name = Toon.NOMBRE
	h.FillTransparency = 1
	h.OutlineColor = Paleta.Contorno
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h:SetAttribute(Toon.NOMBRE, true)
	h.Parent = raiz
	highlights[h] = true
end

-- Contorno a todas las piezas de `raiz`. Devuelve cuántos cascos puso.
function Toon.contorno(raiz: Instance, opciones: Opciones?): number
	local grosor = (opciones and opciones.Grosor) or raiz:GetAttribute("ToonGrosor") :: number?
	if not Toon.moldes() then
		resaltar(raiz)
		return 0
	end
	local puestos = 0
	for _, p in partes(raiz) do
		if Toon.contornoParte(p, grosor) then
			puestos += 1
		end
	end
	return puestos
end

function Toon.quitarContorno(raiz: Instance)
	for _, d in raiz:GetDescendants() do
		if Toon.esContorno(d) then
			d:Destroy()
		end
	end
end

-- Marca un modelo para que cada cliente le ponga el contorno (client/Contornos.client.luau).
function Toon.marcar(raiz: Instance, opciones: Opciones?)
	if opciones and opciones.Grosor then
		raiz:SetAttribute("ToonGrosor", opciones.Grosor)
	end
	CollectionService:AddTag(raiz, Toon.TAG)
end

-- Material, colores y contorno. En el servidor el contorno queda marcado para los clientes.
function Toon.aplicar(raiz: Instance, opciones: Opciones?)
	Toon.pintar(raiz, opciones)
	if opciones and opciones.SinContorno then
		return
	end
	if RunService:IsServer() and RunService:IsRunning() then
		Toon.marcar(raiz, opciones)
	else
		Toon.contorno(raiz, opciones)
	end
end

-- --- Luz del mundo ---

local function efecto<T>(clase: string, nombre: string): T
	local e = Lighting:FindFirstChild(nombre)
	if not e or e.ClassName ~= clase then
		e = Instance.new(clase)
		e.Name = nombre
		e.Parent = Lighting
	end
	return e :: any
end

-- Plástico sin brillo: un MaterialVariant "Toon" bien rugoso reemplaza al SmoothPlastic en todo
-- el juego, así no hay reflejos especulares del sol.
local function plasticoMate()
	if not MaterialService:FindFirstChild("Toon") then
		local ok, motivo = pcall(function()
			local v = Instance.new("MaterialVariant")
			v.Name = "Toon"
			v.BaseMaterial = Enum.Material.SmoothPlastic
			v.RoughnessMap = C.Rugoso
			v.Parent = MaterialService
		end)
		if not ok then
			warn("[Toon] No se pudo crear el material Toon: " .. tostring(motivo))
			return
		end
	end
	MaterialService:SetBaseMaterialOverride(Enum.Material.SmoothPlastic, "Toon")
end

-- Atardecer violeta y rosa: cielo con degradé y luna de caricatura, luz ambiente alta, sin
-- reflejos y colores un poco más brillantes y saturados.
function Toon.iluminar()
	plasticoMate()
	local L, P = C.Luz, Paleta.Luz
	Lighting.ClockTime = L.Hora
	Lighting.GeographicLatitude = L.Latitud
	Lighting.Brightness = L.Brillo
	Lighting.ExposureCompensation = L.Exposicion
	Lighting.Ambient = P.Ambiente
	Lighting.OutdoorAmbient = P.Exterior
	Lighting.ColorShift_Top = P.Sol
	Lighting.ColorShift_Bottom = Color3.new()
	Lighting.EnvironmentDiffuseScale = L.Difusa
	Lighting.EnvironmentSpecularScale = 0
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = L.Suavidad

	local cielo = efecto("Sky", "Sky") :: Sky
	cielo.SkyboxUp = C.Cielo.Arriba
	cielo.SkyboxDn = C.Cielo.Abajo
	cielo.SkyboxLf = C.Cielo.Lado
	cielo.SkyboxRt = C.Cielo.Lado
	cielo.SkyboxFt = C.Cielo.Lado
	cielo.SkyboxBk = C.Cielo.Luna
	cielo.CelestialBodiesShown = false -- la luna ya está dibujada en el cielo
	cielo.StarCount = 0

	local A = C.Atmosfera
	local atmosfera = efecto("Atmosphere", "Atmosphere") :: Atmosphere
	atmosfera.Density = A.Densidad
	atmosfera.Offset = A.Desplazamiento
	atmosfera.Haze = A.Bruma
	atmosfera.Glare = A.Resplandor
	atmosfera.Color = P.Niebla
	atmosfera.Decay = P.Lejos

	local CC = C.Correccion
	local correccion = efecto("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	correccion.Brightness = CC.Brillo
	correccion.Contrast = CC.Contraste
	correccion.Saturation = CC.Saturacion
	correccion.TintColor = Color3.new(1, 1, 1)

	local B = C.Bloom
	local bloom = efecto("BloomEffect", "Bloom") :: BloomEffect
	bloom.Intensity = B.Intensidad
	bloom.Size = B.Tamano
	bloom.Threshold = B.Umbral
end

return Toon
