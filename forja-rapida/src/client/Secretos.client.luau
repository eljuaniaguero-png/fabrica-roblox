--!strict
-- Lo que se ve de los secretos y de las puertas de los biomas (Grupo 3 y mapa):
--   Puertas secretas que abriste (atributo Secretos): para vos se vuelven atravesables.
--   Cofres que ya abriste (Cofres): se ven abiertos y sin cartel.
--   Puertas entre biomas (tag "PuertaZona", atributo Zona): si tu Fuerza ya abrió esa zona, se
--   pueden atravesar; si no, muestran cuánta Fuerza piden. (El servidor igual revisa la zona en
--   cada golpe, así que pasar a la fuerza no sirve de nada.)
--   Carteles con atributo Menu (por ejemplo el Museo del mapa): abren esa ventana.
--   Efectos de Remotos.Secreto: destello de color al abrir una puerta, un cofre, un altar o al
--   cruzar un portal (sin destello con "Efectos reducidos").

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Datos = require(script.Parent.Datos)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)
local Ventanas = require(script.Parent.Ventanas)

local yo = Players.LocalPlayer
local Secreto = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Secreto") :: RemoteEvent

-- Hace (o deshace) atravesable una parte y lo que tenga adentro, solo para este jugador.
local function abrir(parte: BasePart, abierta: boolean)
	local lista: { Instance } = { parte }
	for _, d in parte:GetDescendants() do
		table.insert(lista, d)
	end
	for _, p in lista do
		if p:IsA("BasePart") then
			if p:GetAttribute("TransparenciaOriginal") == nil then
				p:SetAttribute("TransparenciaOriginal", p.Transparency)
			end
			p.CanCollide = not abierta
			p.Transparency = if abierta
				then 1
				else p:GetAttribute("TransparenciaOriginal") :: number
		elseif p:IsA("ProximityPrompt") or p:IsA("BillboardGui") then
			(p :: any).Enabled = not abierta
		end
	end
end

-- Puertas secretas y cofres -----------------------------------------------------------------

local function revisarSecretos()
	local abiertas = Datos.conjunto("Secretos")
	for _, p in CollectionService:GetTagged("PuertaSecreta") do
		if p:IsA("BasePart") then
			abrir(p, abiertas[tostring(p:GetAttribute("Zona"))] == true)
		end
	end
	local cofres = Datos.conjunto("Cofres")
	for _, p in CollectionService:GetTagged("Cofre") do
		if p:IsA("BasePart") then
			local abierto = cofres[tostring(p:GetAttribute("Id"))] == true
			local tapa = p:FindFirstChild("Tapa")
			if tapa and tapa:IsA("BasePart") then
				tapa.Transparency = if abierto then 1 else 0
			end
			local prompt = p:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt.Enabled = not abierto
			end
		end
	end
end

-- Puertas entre biomas ----------------------------------------------------------------------

local function cartelPuerta(p: BasePart, zona: GameConfig.Zona)
	if p:FindFirstChild("CartelZona") then
		return
	end
	local b = Instance.new("BillboardGui")
	b.Name = "CartelZona"
	b.Size = UDim2.fromOffset(340, 110)
	b.StudsOffsetWorldSpace = Vector3.new(0, p.Size.Y / 2 + 3, 0)
	b.MaxDistance = 140
	b.LightInfluence = 0
	local col = Estilo.contenido(b :: any, 2, true)
	local n = Estilo.texto(zona.Nombre, 34, Color3.fromHex(zona.ColorCristal))
	n.LayoutOrder = 1
	n.Parent = col
	local f = Estilo.conIconos(
		{ "Fuerza" },
		"Necesitás " .. Formato.corto(zona.FuerzaParaAbrir) .. " de Fuerza",
		26
	)
	f.LayoutOrder = 2
	f.Parent = col
	b.Parent = p
end

local function revisarPuertasZona()
	local zonas = Datos.zonas()
	for _, p in CollectionService:GetTagged("PuertaZona") do
		local n = p:GetAttribute("Zona")
		local zona = if typeof(n) == "number" then GameConfig.Zonas[n] else nil
		if p:IsA("BasePart") and zona then
			cartelPuerta(p, zona)
			abrir(p, zonas[zona.Numero] == true)
		end
	end
end

for _, tag in { "PuertaSecreta", "Cofre" } do
	CollectionService:GetInstanceAddedSignal(tag):Connect(function()
		task.defer(revisarSecretos)
	end)
end
CollectionService:GetInstanceAddedSignal("PuertaZona"):Connect(function()
	task.defer(revisarPuertasZona)
end)
Datos.alCambiar({ "Secretos", "Cofres" }, revisarSecretos)
Datos.alCambiar({ "Zonas" }, revisarPuertasZona)
revisarSecretos()
revisarPuertasZona()

-- Carteles que abren una ventana (el Museo del mapa) -----------------------------------------

ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
	local menu = prompt:GetAttribute("Menu")
	if typeof(menu) == "string" then
		Ventanas.abrir(menu)
	end
end)

-- Efectos -----------------------------------------------------------------------------------

local pantalla = Estilo.pantalla("Secretos", 15)
pantalla.Parent = yo:WaitForChild("PlayerGui")
local COLOR: { [string]: string } =
	{ Puerta = "#C77DFF", Portal = "#9CFBFF", Altar = "#FFE45C", Cofre = "#FFC83D" }

Secreto.OnClientEvent:Connect(function(tipo: unknown)
	if typeof(tipo) ~= "string" then
		return
	end
	-- SONIDO: secreto (puerta, portal, altar o cofre)
	Sonidos.tocar(GameConfig.Sonidos.Secreto, if tipo == "Portal" then 0.8 else 1.1)
	if Efectos.reducidos() then
		return
	end
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = Color3.fromHex(COLOR[tipo] or "#FFFFFF")
	f.BackgroundTransparency = if tipo == "Portal" then 0 else 0.5
	f.BorderSizePixel = 0
	f.Parent = pantalla
	local t = TweenService:Create(
		f,
		TweenInfo.new(if tipo == "Portal" then 0.8 else 0.5),
		{ BackgroundTransparency = 1 }
	)
	t.Completed:Connect(function()
		f:Destroy()
	end)
	t:Play()
end)
