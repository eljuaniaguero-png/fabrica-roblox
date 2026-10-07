--!strict
-- Al cruzar una puerta abierta: destello en pantalla, chispas en la puerta y un sonido.
-- Es solo visual y lo ves vos. Quién pasa lo decide el servidor (Puertas.luau).
--
-- HUD > Destello (Frame blanco a pantalla completa, transparente)

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local destello = hud:WaitForChild("Destello") :: Frame
local ajustes = Config.CruzarPuerta
local CHISPA = "rbxasset://textures/particles/sparkles_main.dds"

-- Con streaming, las puertas llegan y se van: se guardan por parte.
local puertas: { [BasePart]: number } = {} -- parte -> índice de la puerta
local ladoAnterior: { [BasePart]: number } = {}

local function registrar(parte: Instance)
	local indice = parte:GetAttribute("PuertaIndice")
	if parte:IsA("BasePart") and typeof(indice) == "number" then
		puertas[parte] = indice
	end
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		puertas[objeto] = nil
		ladoAnterior[objeto] = nil
	end
end)

local function chispas(puerta: BasePart, punto: Vector3)
	local ancla = Instance.new("Attachment")
	ancla.Name = "ChispasPuerta"
	ancla.Parent = workspace.Terrain
	ancla.WorldPosition = punto

	local abierta = puerta:GetAttribute("ColorAbierta")
	local color = if typeof(abierta) == "Color3" then abierta else Config.Paleta.Cian
	local emisor = Instance.new("ParticleEmitter")
	emisor.Texture = CHISPA
	emisor.Rate = 0
	emisor.LightEmission = 1
	emisor.Color = ColorSequence.new(color, Config.Paleta.Amarillo)
	emisor.Size = NumberSequence.new(0.9, 0)
	emisor.Lifetime = NumberRange.new(0.5, 0.9)
	emisor.Speed = NumberRange.new(8, 16)
	emisor.SpreadAngle = Vector2.new(180, 180)
	emisor.Drag = 3
	emisor.Parent = ancla
	emisor:Emit(ajustes.Particulas)
	Debris:AddItem(ancla, 2)
end

local function alCruzar(puerta: BasePart, punto: Vector3)
	-- SONIDO: cruzar una puerta (Config.Efectos.Puerta)
	Sonidos.efecto("Puerta")
	destello.BackgroundTransparency = ajustes.Destello
	TweenService:Create(
		destello,
		TweenInfo.new(ajustes.DuracionDestello, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	):Play()
	chispas(puerta, punto)
end

local function miNivel(): number
	local pasos = jugador:GetAttribute("PasosTotales")
	return Niveles.nivelDe(if typeof(pasos) == "number" then pasos else 0)
end

-- Cruzar = pasar de un lado al otro del plano de la puerta, estando dentro del marco.
RunService.Heartbeat:Connect(function()
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not raiz or not raiz:IsA("BasePart") then
		return
	end
	for puerta, indice in puertas do
		local relativo = puerta.CFrame:PointToObjectSpace(raiz.Position)
		local mitad = puerta.Size / 2
		local dentroDelMarco = math.abs(relativo.X) <= mitad.X + 1
			and math.abs(relativo.Y) <= mitad.Y + 3
			and math.abs(relativo.Z) <= 4
		if not dentroDelMarco then
			ladoAnterior[puerta] = nil
			continue
		end
		local lado = if relativo.Z >= 0 then 1 else -1
		local antes = ladoAnterior[puerta]
		ladoAnterior[puerta] = lado
		if antes and antes ~= lado and miNivel() >= (Config.NivelPuertas[indice] or 0) then
			alCruzar(puerta, raiz.Position)
		end
	end
end)
