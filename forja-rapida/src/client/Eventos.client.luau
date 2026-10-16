--!strict
-- Lo que se ve de los eventos del mundo (Grupo 6). Todo sale de ReplicatedStorage.EstadoMundo
-- (lo pone el servidor), así lo que se ve es lo que pasa:
--   Cartel arriba al centro: "Se viene: ..." con cuenta regresiva, y durante el evento su
--   nombre, tiempo que queda y progreso (meta de la Fiebre o vida del Jefe Ancestral).
--   Ambiente: un tinte de luz propio de cada evento (aparte del ColorCorrection de la base).
--   Extras: cristales de la lluvia que caen y giran, bombas de lava que caen en la Erupción,
--   relámpagos de colores en la Tormenta Neón y motas violetas en el Eclipse.
-- Con "Efectos reducidos": sin relámpagos, sin bombas y tinte más suave.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local estado = ReplicatedStorage:WaitForChild("EstadoMundo")
local rng = Random.new()

local ICONO: { [string]: string } = {
	LluviaCristales = "Cristal",
	Erupcion = "Lava",
	TormentaNeon = "Neon",
	EclipseVacio = "Vacio",
	FiebreMineria = "Trofeo",
	JefeAncestral = "Jefe",
}

-- Tinte de cada evento: { color, brillo, contraste, saturación }.
local TINTE: { [string]: { Color: string, Brillo: number, Contraste: number, Saturacion: number } } =
	{
		LluviaCristales = { Color = "#E6FBFF", Brillo = 0.03, Contraste = 0, Saturacion = 0.05 },
		Erupcion = { Color = "#FFD6B8", Brillo = 0, Contraste = 0.08, Saturacion = 0.15 },
		TormentaNeon = { Color = "#E9DEFF", Brillo = -0.03, Contraste = 0.1, Saturacion = 0.2 },
		EclipseVacio = { Color = "#C7B4FF", Brillo = -0.18, Contraste = 0.12, Saturacion = -0.1 },
		FiebreMineria = { Color = "#FFF0D0", Brillo = 0.04, Contraste = 0, Saturacion = 0.1 },
		JefeAncestral = { Color = "#FFF4C7", Brillo = 0, Contraste = 0.06, Saturacion = 0.05 },
	}

local function atributo(nombre: string): any
	return estado:GetAttribute(nombre)
end

local function reloj(segundos: number): string
	segundos = math.max(0, math.floor(segundos))
	return ("%d:%02d"):format(segundos // 60, segundos % 60)
end

-- Cartel del evento ---------------------------------------------------------------------------

local pantalla = Estilo.pantalla("Evento", 8)
pantalla.Parent = jugador:WaitForChild("PlayerGui")

-- El cartel no se agranda solo: su alto copia el de `contenido` (que sí se agranda con el
-- texto). Si el cartel tuviera AutomaticSize, las rayas (3 veces su alto) lo harían crecer sin
-- fin (llegó a medir 132.000 píxeles y tapaba la pantalla).
local ANCHO_CARTEL = 560
local cartel = Instance.new("Frame")
cartel.Name = "CartelEvento"
cartel.AnchorPoint = Vector2.new(0.5, 0)
cartel.Position = UDim2.new(0.5, 0, 0, 150)
cartel.Size = UDim2.fromOffset(ANCHO_CARTEL, 0)
cartel.BackgroundColor3 = Color3.new(1, 1, 1)
cartel.ClipsDescendants = true
cartel.Visible = false
Estilo.esquinas(cartel, 18)
Estilo.borde(cartel, 4)
local fondoCartel = Estilo.degradado(cartel, { "#FFFFFF", "#FFFFFF" }, 0)
cartel.Parent = pantalla
-- rayas diagonales de luz (como las cabeceras de las capturas)
for i = 1, 4 do
	local raya = Instance.new("Frame")
	raya.BackgroundColor3 = Color3.new(1, 1, 1)
	raya.BackgroundTransparency = 0.82
	raya.BorderSizePixel = 0
	raya.Size = UDim2.new(0, 26, 3, 0)
	raya.AnchorPoint = Vector2.new(0.5, 0.5)
	raya.Position = UDim2.fromScale(0.55 + i * 0.07, 0.5)
	raya.Rotation = 25
	raya.ZIndex = 0
	raya.Parent = cartel
end
local contenido = Instance.new("Frame")
contenido.Name = "Contenido"
contenido.BackgroundTransparency = 1
contenido.Size = UDim2.fromScale(1, 0)
contenido.AutomaticSize = Enum.AutomaticSize.Y
contenido.ZIndex = 1
contenido.Parent = cartel
local relleno = Instance.new("UIPadding")
relleno.PaddingLeft, relleno.PaddingRight = UDim.new(0, 16), UDim.new(0, 16)
relleno.PaddingTop, relleno.PaddingBottom = UDim.new(0, 8), UDim.new(0, 12)
relleno.Parent = contenido
local listaCartel = Instance.new("UIListLayout")
listaCartel.HorizontalAlignment = Enum.HorizontalAlignment.Center
listaCartel.SortOrder = Enum.SortOrder.LayoutOrder
listaCartel.Padding = UDim.new(0, 4)
listaCartel.Parent = contenido
-- AbsoluteSize viene con la escala de pantalla aplicada: se pasa a píxeles de diseño con el
-- ancho, que es fijo.
local function ajustarAlto()
	local escala = cartel.AbsoluteSize.X / ANCHO_CARTEL
	if escala > 0 then
		cartel.Size = UDim2.fromOffset(ANCHO_CARTEL, math.ceil(contenido.AbsoluteSize.Y / escala))
	end
end
contenido:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajustarAlto)
cartel:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajustarAlto)

local cabecera = Estilo.fila(8)
cabecera.LayoutOrder = 1
cabecera.Parent = contenido
local iconoEvento: GuiObject? = nil
local tituloEvento = Estilo.texto("", 32)
tituloEvento.LayoutOrder = 2
tituloEvento.Parent = cabecera
local tiempo = Estilo.texto("", 32, Color3.fromHex("#FFF15C"))
tiempo.LayoutOrder = 3
tiempo.Parent = cabecera
local descripcion = Estilo.texto("", 18)
descripcion.LayoutOrder = 2
descripcion.Parent = contenido
local barra = Instance.new("Frame")
barra.LayoutOrder = 3
barra.Size = UDim2.fromOffset(500, 30)
barra.BackgroundColor3 = Estilo.Oscuro
Estilo.esquinas(barra, 15)
Estilo.borde(barra, 3)
barra.Parent = contenido
local llenoBarra = Instance.new("Frame")
llenoBarra.Size = UDim2.fromScale(0, 1)
llenoBarra.BackgroundColor3 = Color3.new(1, 1, 1)
Estilo.esquinas(llenoBarra, 15)
Estilo.degradado(llenoBarra, { "#FFF15C", "#FF9B3D" })
llenoBarra.Parent = barra
local textoBarra = Estilo.texto("", 20)
textoBarra.AnchorPoint = Vector2.new(0.5, 0.5)
textoBarra.Position = UDim2.fromScale(0.5, 0.5)
textoBarra.ZIndex = 2
textoBarra.Parent = barra

local ultimoId = ""
local function pintarCartel(id: string, proximo: boolean)
	local ev = Reglas.evento(id)
	if not ev then
		return
	end
	if id .. tostring(proximo) ~= ultimoId then
		ultimoId = id .. tostring(proximo)
		if iconoEvento then
			iconoEvento:Destroy()
		end
		local ic = Estilo.icono(ICONO[id] or "Reloj", 38)
		ic.LayoutOrder = 1
		ic.Parent = cabecera
		iconoEvento = ic
		fondoCartel.Color = ColorSequence.new(Color3.fromHex(ev.Color), Color3.fromHex(ev.Color2))
		tituloEvento.Text = if proximo then "Se viene: " .. ev.Nombre else ev.Nombre
		descripcion.Text = ev.Descripcion
		descripcion.Visible = not proximo
	end
end

-- Barra grande del Jefe Ancestral y podio al terminar.
local barraJefe = Instance.new("Frame")
barraJefe.AnchorPoint = Vector2.new(0.5, 0)
barraJefe.Position = UDim2.new(0.5, 0, 0, 300)
barraJefe.Size = UDim2.fromOffset(640, 0)
barraJefe.AutomaticSize = Enum.AutomaticSize.Y
barraJefe.BackgroundTransparency = 1
barraJefe.Visible = false
barraJefe.Parent = pantalla
local podio = Estilo.texto("", 22, Color3.fromHex("#FFF15C"))
podio.AnchorPoint = Vector2.new(0.5, 0)
podio.Position = UDim2.new(0.5, 0, 0, 300)
podio.Visible = false
podio.Parent = pantalla

estado:GetAttributeChangedSignal("JefeTop"):Connect(function()
	local texto = atributo("JefeTop")
	if typeof(texto) ~= "string" or texto == "" then
		return
	end
	local ok, top = pcall(HttpService.JSONDecode, HttpService, texto)
	if not ok or typeof(top) ~= "table" then
		return
	end
	local partes = {}
	for i, fila in top :: { { Nombre: string, Danio: number } } do
		table.insert(partes, ("%d° %s (%s)"):format(i, fila.Nombre, Formato.corto(fila.Danio)))
	end
	podio.Text = "Podio del Jefe: " .. table.concat(partes, "   ")
	podio.Visible = true
	task.delay(8, function()
		podio.Visible = false
	end)
end)

-- Ambiente --------------------------------------------------------------------------------------

local tinte = Instance.new("ColorCorrectionEffect")
tinte.Name = "TinteEvento"
tinte.Parent = Lighting

local function ambiente(id: string)
	local t = TINTE[id]
	local suave = if Efectos.reducidos() then 0.5 else 1
	local destino = if t
		then {
			TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromHex(t.Color), suave),
			Brightness = t.Brillo * suave,
			Contrast = t.Contraste * suave,
			Saturation = t.Saturacion * suave,
		}
		else { TintColor = Color3.new(1, 1, 1), Brightness = 0, Contrast = 0, Saturation = 0 }
	TweenService:Create(tinte, TweenInfo.new(2), destino):Play()
end

local function cercaDeMi(radio: number): Vector3?
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	if not raiz or not raiz:IsA("BasePart") then
		return nil
	end
	local a = rng:NextNumber() * math.pi * 2
	local d = rng:NextNumber(8, radio)
	return raiz.Position + Vector3.new(math.cos(a) * d, 0, math.sin(a) * d)
end

-- Erupción: bombas de lava que caen cerca (solo se ven, no hacen daño).
local function bombaLava()
	local pos = cercaDeMi(45)
	if not pos then
		return
	end
	local modelos = ReplicatedStorage:FindFirstChild("Modelos")
	local molde = modelos and modelos:FindFirstChild("BombaLava")
	local p: BasePart
	if molde and molde:IsA("BasePart") then
		p = molde:Clone()
	else
		local parte = Instance.new("Part")
		parte.Size = Vector3.one * rng:NextNumber(1.2, 2.2)
		parte.Material = Enum.Material.Neon
		parte.Color = Color3.fromHex("#FF6A1A")
		p = parte
	end
	p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
	p.Anchored = false
	p.CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-10, 10), 70, rng:NextNumber(-10, 10)))
	p.AssemblyLinearVelocity = Vector3.new(0, -30, 0)
	local fuego = Instance.new("Fire")
	fuego.Size = 4
	fuego.Heat = 8
	fuego.Color = Color3.fromHex("#FF6A1A")
	fuego.SecondaryColor = Color3.fromHex("#FFE14D")
	fuego.Parent = p
	p.Parent = Workspace
	Debris:AddItem(p, 4)
end

-- Tormenta Neón: un relámpago de color cerca y un destello.
local function relampago()
	local pos = cercaDeMi(60)
	if not pos then
		return
	end
	local color = if rng:NextNumber() < 0.5
		then Color3.fromHex("#2EF2FF")
		else Color3.fromHex("#FF4DF0")
	local rayo = Instance.new("Part")
	rayo.Anchored = true
	rayo.CanCollide, rayo.CanQuery, rayo.CanTouch = false, false, false
	rayo.Material = Enum.Material.Neon
	rayo.Color = color
	rayo.Size = Vector3.new(0.6, 120, 0.6)
	rayo.CFrame = CFrame.new(pos + Vector3.new(0, 60, 0))
		* CFrame.Angles(rng:NextNumber(-0.1, 0.1), 0, rng:NextNumber(-0.1, 0.1))
	rayo.Parent = Workspace
	Debris:AddItem(rayo, 0.18)
	local flash = Instance.new("ColorCorrectionEffect")
	flash.TintColor = color
	flash.Brightness = 0.25
	flash.Parent = Lighting
	TweenService
		:Create(flash, TweenInfo.new(0.35), { Brightness = 0, TintColor = Color3.new(1, 1, 1) })
		:Play()
	Debris:AddItem(flash, 0.4)
	-- SONIDO: trueno de la Tormenta Neón
	Sonidos.tocar(GameConfig.Sonidos.Trueno, 0.9 + rng:NextNumber() * 0.3, 0.4)
end

-- Cristales de la lluvia: caen desde arriba, giran y brillan.
local cristales: { [BasePart]: CFrame } = {}
local function alCristal(p: Instance)
	if not p:IsA("BasePart") then
		return
	end
	local destino = p.CFrame
	cristales[p] = destino
	p.CFrame = destino + Vector3.new(0, 45, 0)
	TweenService:Create(
		p,
		TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ CFrame = destino }
	):Play()
	if not Efectos.reducidos() then
		local l = Instance.new("PointLight")
		l.Color = p.Color
		l.Range = 8
		l.Brightness = 2
		l.Parent = p
		local s = Instance.new("Sparkles")
		s.SparkleColor = p.Color
		s.Parent = p
	end
	p.Destroying:Connect(function()
		cristales[p] = nil
	end)
end
CollectionService:GetInstanceAddedSignal("CristalLluvia"):Connect(alCristal)
CollectionService:GetInstanceRemovedSignal("CristalLluvia"):Connect(function(p: Instance)
	if p:IsA("BasePart") then
		cristales[p] = nil
	end
end)
for _, p in CollectionService:GetTagged("CristalLluvia") do
	alCristal(p)
end

-- Bucle -------------------------------------------------------------------------------------------

local eventoActual = ""
local proximoExtra = 0
local cristalesQuietos = 0

RunService.RenderStepped:Connect(function()
	local t = Workspace:GetServerTimeNow()
	local id = tostring(atributo("Evento") or "")
	local proximo = tostring(atributo("Proximo") or "")
	-- cartel
	if id ~= "" then
		pintarCartel(id, false)
		tiempo.Text = reloj((tonumber(atributo("EventoFin")) or t) - t)
		local metaEv = tonumber(atributo("Meta")) or 0
		local vidaMax = tonumber(atributo("JefeVidaMax")) or 0
		if metaEv > 0 then
			local p = tonumber(atributo("Progreso")) or 0
			llenoBarra.Size = UDim2.fromScale(math.clamp(p / metaEv, 0, 1), 1)
			textoBarra.Text = ("%s / %s geodas"):format(Formato.miles(p), Formato.miles(metaEv))
			barra.Visible = true
		elseif vidaMax > 0 then
			local v = tonumber(atributo("JefeVida")) or 0
			llenoBarra.Size = UDim2.fromScale(math.clamp(v / vidaMax, 0, 1), 1)
			textoBarra.Text = ("Geoda Ancestral: %s / %s PV"):format(
				Formato.corto(v),
				Formato.corto(vidaMax)
			)
			barra.Visible = true
		else
			barra.Visible = false
		end
		cartel.Visible = true
	elseif proximo ~= "" then
		pintarCartel(proximo, true)
		tiempo.Text = reloj((tonumber(atributo("ProximoInicio")) or t) - t)
		barra.Visible = false
		cartel.Visible = true
	else
		cartel.Visible = false
	end
	-- ambiente y extras
	if id ~= eventoActual then
		eventoActual = id
		ambiente(id)
		-- SONIDO: empieza un evento
		if id ~= "" then
			Sonidos.tocar(GameConfig.Sonidos.EventoEmpieza)
		end
	end
	local reducidos = Efectos.reducidos()
	local ahora = os.clock()
	if not reducidos and ahora >= proximoExtra then
		if id == "Erupcion" then
			bombaLava()
			proximoExtra = ahora + rng:NextNumber(0.6, 1.4)
		elseif id == "TormentaNeon" then
			relampago()
			proximoExtra = ahora + rng:NextNumber(2, 5)
		end
	end
	-- cristales que giran y flotan (los que ya terminaron de caer)
	if ahora >= cristalesQuietos then
		cristalesQuietos = ahora + 1 / 30
		for p, base in cristales do
			if p.Parent then
				p.CFrame = base
					* CFrame.new(0, 0.3 * math.sin(ahora * 3), 0)
					* CFrame.Angles(0, ahora * 2, 0)
			end
		end
	end
end)
