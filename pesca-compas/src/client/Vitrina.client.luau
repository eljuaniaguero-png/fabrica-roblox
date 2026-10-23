--!strict
-- Vitrina del Museo Marino: 8 pedestales delante de la casita, uno por pez de la Isla 1. Los que
-- ya sacaste muestran el modelo girando con su nombre; los que no, una silueta azul con "???".
-- Es local: cada jugador ve SU colección (Vistos/Afinados llegan en Remotos.Estado), así que no
-- hace falta guardar nada nuevo ni que el servidor arme nada.
-- Un solo Highlight para toda la vitrina (tope de 31 por cliente, ver Estilo.Highlight).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Estilo = require(Shared:WaitForChild("Estilo"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local ModeloPez = require(Shared:WaitForChild("ModeloPez"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local jugador = Players.LocalPlayer
local M = Estilo.Mundo

-- en el espacio de la casa (Zocalo): -Z es hacia donde mira la puerta. El piso de color va de
-- z -4.7 a -9.7; la fila queda delante, con un hueco al medio para pasar al piso.
-- Probado en Studio: en -11.5 el pedestal de x = -5 atravesaba la Palmera3; en -11 no toca nada.
local FILA_Z = -11
local XS = { -6.6, -5, -3.4, -1.8, 1.8, 3.4, 5, 6.6 }
local ALTO_PEDESTAL = 1.4
local LARGO_PEZ = 1.35
local DISTANCIA_GIRO = 70 -- más lejos no se anima (no se ve)

-- se escucha el Estado desde ya: el mapa puede tardar y la respuesta al pedido de Pesca.client
-- llegaría antes de que la vitrina exista (y el servidor ignora pedidos a menos de 1 s)
local ultimoEstado: any = nil
local alEstado: ((any) -> ())? = nil
Remotos:WaitForChild("Estado").OnClientEvent:Connect(function(estado: any)
	ultimoEstado = estado
	if alEstado then
		alEstado(estado)
	end
end)

local function buscarCasa(): BasePart?
	local muelle = Workspace:WaitForChild("Muelle", 30)
	local pueblo = muelle and muelle:WaitForChild("Pueblo", 15)
	local museo = pueblo and pueblo:WaitForChild("MuseoMarino", 15)
	local zocalo = museo and museo:WaitForChild("Zocalo", 15)
	return if zocalo and zocalo:IsA("BasePart") then zocalo else nil
end

local zocalo = buscarCasa()
if not zocalo then
	return -- mapa sin pueblo (PUEBLO = false en Mundo.luau): no hay museo
end
local base = zocalo.CFrame

-- el "¡PRONTO!" del museo ya no corresponde: se apaga acá también por si el mapa es el armado a
-- mano en Studio (Mundo.luau no lo vuelve a generar si la carpeta Guias ya existe)
local guias = (Workspace :: any).Muelle:FindFirstChild("Guias")
if guias then
	for _, d in guias:GetChildren() do
		if d.Name == "AnclaPronto" and d:IsA("BasePart") and (d.Position - base.Position).Magnitude < 16 then
			local cartel = d:FindFirstChild("Pronto")
			if cartel and cartel:IsA("BillboardGui") then
				cartel.Enabled = false
			end
		end
	end
end

local vitrina = Instance.new("Model")
vitrina.Name = "VitrinaMuseo"
local contorno = Instance.new("Highlight")
contorno.Name = "Contorno"
contorno.FillTransparency = 1
contorno.OutlineColor = Estilo.Contorno
contorno.DepthMode = Enum.HighlightDepthMode.Occluded
contorno.Parent = vitrina

local function bloque(nombre: string, tam: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = vitrina
	return p
end

type Lugar = { Arriba: CFrame, Cartel: TextLabel }
local lugares: { Lugar } = {}

-- el piso del museo está en y = 1 (centro del zócalo); el pedestal apoya ahí
for i, x in XS do
	local cf = base * CFrame.new(x, ALTO_PEDESTAL / 2, FILA_Z)
	bloque("Pedestal", Vector3.new(1.3, ALTO_PEDESTAL, 1.3), cf, M.ParedMenta)
	local tapa = bloque("Tapa", Vector3.new(1.5, 0.2, 1.5), cf * CFrame.new(0, ALTO_PEDESTAL / 2 + 0.1, 0), M.Dorado)
	tapa.CanCollide = false

	local ancla = Instance.new("Attachment")
	ancla.Position = Vector3.new(0, 1.9, 0)
	ancla.Parent = tapa
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(3.2, 0.7)
	gui.LightInfluence = 0
	gui.MaxDistance = 40
	gui.Adornee = ancla
	gui.Parent = ancla
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Estilo.UI.Fuente
	t.TextScaled = true
	t.TextColor3 = Estilo.UI.Texto
	t.Text = "???"
	t.Parent = gui
	Estilo.bordeTexto(t)

	lugares[i] = { Arriba = cf * CFrame.new(0, ALTO_PEDESTAL / 2 + 0.95, 0), Cartel = t }
end

-- cartel de la colección: "MUSEO 3/8", lo que empuja a completar
local anclaTitulo = Instance.new("Attachment")
anclaTitulo.Position = (base * CFrame.new(0, 3.4, FILA_Z)).Position
anclaTitulo.Parent = Workspace.Terrain
local guiTitulo = Instance.new("BillboardGui")
guiTitulo.Size = UDim2.fromScale(8, 1.4)
guiTitulo.LightInfluence = 0
guiTitulo.MaxDistance = 80
guiTitulo.Adornee = anclaTitulo
guiTitulo.Parent = anclaTitulo
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.fromScale(1, 1)
titulo.BackgroundTransparency = 1
titulo.Font = Estilo.UI.Fuente
titulo.TextScaled = true
titulo.TextColor3 = M.PisoMuseo
titulo.Text = ""
titulo.Parent = guiTitulo
Estilo.bordeTexto(titulo)

vitrina.Parent = Workspace

---------------------------------------------------------------- peces

local peces = Limpieza.nueva()
local modelos: { [number]: Model } = {}
local clave = "" -- para no rearmar todo con cada Estado si la colección no cambió

local function rareza(id: string): Config.Rareza?
	for _, r in Config.Rarezas do
		if r.Id == id then
			return r
		end
	end
	return nil
end

local function armar(vistos: { [string]: boolean }, afinados: { [string]: boolean })
	peces:limpiar()
	table.clear(modelos)
	local cuantos = 0
	for i, pez in Config.Peces do
		local lugar = lugares[i]
		if not lugar then
			break
		end
		local visto = vistos[pez.Id] == true
		local m = ModeloPez.crear(pez.Id, {
			Largo = LARGO_PEZ,
			Silueta = not visto,
			Afinado = afinados[pez.Id] == true,
			Contorno = false, -- lo pone el Highlight de la vitrina
		})
		m:PivotTo(lugar.Arriba)
		m.Parent = vitrina
		peces:dar(m)
		modelos[i] = m
		local r = rareza(pez.Rareza)
		lugar.Cartel.Text = if visto then pez.Nombre else "???"
		lugar.Cartel.TextColor3 = if visto and r then r.Color else Estilo.UI.Texto
		if visto then
			cuantos += 1
		end
	end
	titulo.Text = ("MUSEO  %d/%d"):format(cuantos, #Config.Peces)
end

alEstado = function(estado: any)
	if typeof(estado) ~= "table" then
		return
	end
	local vistos = if typeof(estado.Vistos) == "table" then estado.Vistos else {}
	local afinados = if typeof(estado.Afinados) == "table" then estado.Afinados else {}
	local partes = {}
	for _, pez in Config.Peces do
		table.insert(partes, (if vistos[pez.Id] then "1" else "0") .. (if afinados[pez.Id] then "1" else "0"))
	end
	local nueva = table.concat(partes)
	if nueva ~= clave then
		clave = nueva
		armar(vistos, afinados)
	end
end
if ultimoEstado then
	(alEstado :: (any) -> ())(ultimoEstado)
else
	armar({}, {}) -- todo en silueta mientras llega el Estado
	task.delay(1.2, function() -- pasado el límite de 1 s del servidor
		if not ultimoEstado then
			Remotos.Estado:FireServer()
		end
	end)
end

-- giro lento de los peces vistos, solo si el jugador está cerca
RunService.RenderStepped:Connect(function()
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz or (raiz.Position - base.Position).Magnitude > DISTANCIA_GIRO then
		return
	end
	local t = os.clock()
	for i, m in modelos do
		local lugar = lugares[i]
		m:PivotTo(lugar.Arriba * CFrame.new(0, math.sin(t * 2 + i) * 0.12, 0) * CFrame.Angles(0, t * 0.8 + i, 0))
	end
end)
