--!strict
-- Lo que se ve de la exhibición social (Grupo 7):
--   Títulos arriba de la cabeza de cada jugador, con su degradé (se pueden ocultar en Ajustes).
--   Vitrinas: la estatua gira y flota; el cartel dice de quién es, su título, la gema con el
--   degradé de su rareza y "1 en N" (como los carteles de las capturas).
--   Tableros de la clasificación semanal (parte con tag "TableroClasificacion" y atributo
--   Tabla): se arman con ReplicatedStorage.Clasificaciones.

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)

local yo = Players.LocalPlayer

local ARCOIRIS = { "#FF4D5E", "#FFC93C", "#4CD964", "#2EF2FF", "#9B4DFF" }

local function verTitulos(): boolean
	return yo:GetAttribute("VerTitulos") ~= false
end

-- Títulos -----------------------------------------------------------------------------------------

local carteles: { [Player]: BillboardGui } = {}

local function ponerTitulo(j: Player)
	local viejo = carteles[j]
	if viejo then
		viejo:Destroy()
		carteles[j] = nil
	end
	local cabeza = j.Character and j.Character:FindFirstChild("Head")
	local t = Reglas.titulo(tostring(j:GetAttribute("Titulo") or ""))
	if not cabeza or not cabeza:IsA("BasePart") or not t or not verTitulos() then
		return
	end
	local b = Instance.new("BillboardGui")
	b.Name = "Titulo"
	b.Adornee = cabeza
	b.Size = UDim2.fromOffset(260, 30)
	b.StudsOffset = Vector3.new(0, 2.4, 0)
	b.MaxDistance = 60
	b.LightInfluence = 0
	local texto = Estilo.texto(t.Texto, 22)
	texto.AnchorPoint = Vector2.new(0.5, 0.5)
	texto.Position = UDim2.fromScale(0.5, 0.5)
	texto.Parent = b
	Estilo.degradado(texto, t.Colores, 0)
	b.Parent = cabeza
	carteles[j] = b
end

local function seguir(j: Player)
	j.CharacterAdded:Connect(function(personaje: Model)
		personaje:WaitForChild("Head", 10)
		ponerTitulo(j)
	end)
	j:GetAttributeChangedSignal("Titulo"):Connect(function()
		ponerTitulo(j)
	end)
	if j.Character then
		task.spawn(ponerTitulo, j)
	end
end
Players.PlayerAdded:Connect(seguir)
for _, j in Players:GetPlayers() do
	seguir(j)
end
Players.PlayerRemoving:Connect(function(j: Player)
	carteles[j] = nil
end)
yo:GetAttributeChangedSignal("VerTitulos"):Connect(function()
	for _, j in Players:GetPlayers() do
		ponerTitulo(j)
	end
end)

-- Vitrinas ----------------------------------------------------------------------------------------

local estatuas: { [BasePart]: CFrame } = {}

local function cartelVitrina(m: Model)
	local estatua = m:FindFirstChild("Estatua")
	local gema = Reglas.gema(tostring(m:GetAttribute("Gema") or ""))
	local adorno = if estatua and estatua:IsA("BasePart") then estatua else m.Parent
	if not adorno or not adorno:IsA("BasePart") then
		return
	end
	local b = Instance.new("BillboardGui")
	b.Name = "CartelVitrina"
	b.Adornee = adorno
	b.Size = UDim2.fromOffset(300, 150)
	b.StudsOffsetWorldSpace = Vector3.new(0, adorno.Size.Y / 2 + 3.2, 0)
	b.MaxDistance = 70
	b.LightInfluence = 0
	local lista = Instance.new("UIListLayout")
	lista.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lista.VerticalAlignment = Enum.VerticalAlignment.Bottom
	lista.SortOrder = Enum.SortOrder.LayoutOrder
	lista.Parent = b
	local dueno = Estilo.texto(tostring(m:GetAttribute("Dueno") or ""), 26)
	dueno.LayoutOrder = 1
	dueno.Parent = b
	local uid = tonumber(m:GetAttribute("UserId")) or 0
	local duenoJugador = Players:GetPlayerByUserId(uid)
	local t = duenoJugador and Reglas.titulo(tostring(duenoJugador:GetAttribute("Titulo") or ""))
	if t then
		local titulo = Estilo.texto(t.Texto, 20)
		titulo.LayoutOrder = 2
		titulo.Parent = b
		Estilo.degradado(titulo, t.Colores, 0)
	end
	if gema then
		local r = Reglas.rareza(gema.Rareza)
		local nombre = Estilo.texto(gema.Nombre, 30)
		nombre.LayoutOrder = 3
		nombre.Parent = b
		if r then
			local rareza = Estilo.texto(r.Nombre, 26)
			rareza.LayoutOrder = 4
			rareza.Parent = b
			Estilo.degradado(
				rareza,
				if gema.Rareza == "Mitico" then ARCOIRIS else { "#FFFFFF", r.Color },
				0
			)
		end
		local unoEn = tonumber(m:GetAttribute("UnoEn")) or 0
		if unoEn > 0 then
			local suerte = Estilo.texto(Formato.unoEn(unoEn), 26, Color3.fromHex("#7CFF3C"))
			suerte.LayoutOrder = 5
			suerte.Parent = b
		end
	else
		local vacia = Estilo.texto("Todavía sin hallazgos", 20, Color3.fromHex("#C2C8D0"))
		vacia.LayoutOrder = 3
		vacia.Parent = b
	end
	b.Parent = m
	if estatua and estatua:IsA("BasePart") then
		estatuas[estatua] = estatua.CFrame
		estatua.Destroying:Connect(function()
			estatuas[estatua] = nil
		end)
	end
end

local function vigilarVitrina(base: Instance)
	base.ChildAdded:Connect(function(hijo: Instance)
		if hijo:IsA("Model") and hijo.Name == "Exhibicion" then
			task.wait() -- que lleguen sus partes y atributos
			cartelVitrina(hijo)
		end
	end)
	local m = base:FindFirstChild("Exhibicion")
	if m and m:IsA("Model") then
		cartelVitrina(m)
	end
end
CollectionService:GetInstanceAddedSignal("Vitrina"):Connect(vigilarVitrina)
for _, b in CollectionService:GetTagged("Vitrina") do
	vigilarVitrina(b)
end

-- Tableros de la clasificación ---------------------------------------------------------------------

local carpeta = ReplicatedStorage:WaitForChild("Clasificaciones")

local function tituloTabla(id: string): string
	for _, t in GameConfig.Social.Clasificacion.Tablas do
		if t.Id == id then
			return t.Nombre
		end
	end
	return id
end

local function armarTablero(parte: Instance)
	if not parte:IsA("BasePart") then
		return
	end
	local tabla = tostring(parte:GetAttribute("Tabla") or "Geodas")
	local g = Instance.new("SurfaceGui")
	g.Name = "Clasificacion"
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(700, 500)
	g.LightInfluence = 0
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.new(1, 1, 1)
	Estilo.degradado(fondo, { "#2A2F4F", "#1B1F3B" })
	fondo.Parent = g
	local cabecera = Instance.new("Frame")
	cabecera.Size = UDim2.new(1, 0, 0, 80)
	cabecera.BackgroundColor3 = Color3.new(1, 1, 1)
	Estilo.degradado(cabecera, { "#B97BFF", "#7A2FE0" })
	cabecera.Parent = fondo
	local titulo = Estilo.conIconos({ "Trofeo" }, tituloTabla(tabla) .. " · esta semana", 38)
	titulo.AnchorPoint = Vector2.new(0.5, 0.5)
	titulo.Position = UDim2.fromScale(0.5, 0.5)
	titulo.Parent = cabecera
	local filas = Instance.new("Frame")
	filas.Position = UDim2.fromOffset(20, 90)
	filas.Size = UDim2.new(1, -40, 1, -100)
	filas.BackgroundTransparency = 1
	local orden = Instance.new("UIListLayout")
	orden.SortOrder = Enum.SortOrder.LayoutOrder
	orden.Padding = UDim.new(0, 2)
	orden.Parent = filas
	filas.Parent = fondo
	g.Parent = parte

	local function llenar()
		for _, f in filas:GetChildren() do
			if f:IsA("GuiObject") then
				f:Destroy()
			end
		end
		local valor = carpeta:FindFirstChild(tabla)
		local ok, lista = false, nil
		if valor and valor:IsA("StringValue") and valor.Value ~= "" then
			ok, lista = pcall(HttpService.JSONDecode, HttpService, valor.Value)
		end
		if not ok or typeof(lista) ~= "table" or #lista == 0 then
			Estilo.texto(
				"Todavía nadie esta semana. ¡Rompé geodas!",
				28,
				Color3.fromHex("#C2C8D0")
			).Parent =
				filas
			return
		end
		for i, fila in lista :: { { Nombre: string, Valor: number } } do
			local color = if i == 1
				then "#FFD23F"
				elseif i == 2 then "#E3E8F2"
				elseif i == 3 then "#E8854A"
				else "#FFFFFF"
			local valorTexto = if tabla == "Hallazgo"
				then Formato.unoEn(fila.Valor)
				else Formato.corto(fila.Valor)
			local t = Estilo.texto(
				("%d. %s   %s"):format(i, fila.Nombre, valorTexto),
				30,
				Color3.fromHex(color)
			)
			t.LayoutOrder = i
			t.Parent = filas
		end
	end
	llenar()
	carpeta.ChildAdded:Connect(function(hijo: Instance)
		if hijo.Name == tabla and hijo:IsA("StringValue") then
			hijo.Changed:Connect(llenar)
			llenar()
		end
	end)
	local valor = carpeta:FindFirstChild(tabla)
	if valor and valor:IsA("StringValue") then
		valor.Changed:Connect(llenar)
	end
end
CollectionService:GetInstanceAddedSignal("TableroClasificacion"):Connect(armarTablero)
for _, t in CollectionService:GetTagged("TableroClasificacion") do
	armarTablero(t)
end

-- Estatuas que giran y flotan (un solo bucle; quietas con efectos reducidos).
RunService.RenderStepped:Connect(function()
	if Efectos.reducidos() then
		return
	end
	local t = os.clock()
	for p, base in estatuas do
		if p.Parent then
			p.CFrame = base
				* CFrame.new(0, 0.4 * math.sin(t * 1.5), 0)
				* CFrame.Angles(0, t * 0.8, 0)
		end
	end
end)
