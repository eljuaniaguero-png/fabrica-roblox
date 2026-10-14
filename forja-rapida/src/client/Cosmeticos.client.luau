--!strict
-- Lo que se ve de los cosméticos del Museo (Grupo 3):
--   Auras de todos los jugadores (atributo Aura): destellos, chispas o runas que orbitan.
--   Con "Efectos reducidos", menos partículas y sin runas que giran.
--   El pico se sostiene como herramienta: se esconde la barra de herramientas de Roblox.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Efectos = require(script.Parent.Efectos)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

type Aura = { Emisor: ParticleEmitter?, Runas: { BasePart }, Raiz: BasePart }
local auras: { [Player]: Aura } = {}

local carpeta = Instance.new("Folder")
carpeta.Name = "Auras"
carpeta.Parent = Workspace

local function secuencia(colores: { string }): ColorSequence
	local puntos = {}
	for i, h in colores do
		table.insert(
			puntos,
			ColorSequenceKeypoint.new((i - 1) / math.max(1, #colores - 1), Color3.fromHex(h))
		)
	end
	if #puntos == 1 then
		table.insert(puntos, ColorSequenceKeypoint.new(1, Color3.fromHex(colores[1])))
	end
	return ColorSequence.new(puntos)
end

local function quitar(j: Player)
	local a = auras[j]
	if not a then
		return
	end
	if a.Emisor then
		local adjunto = a.Emisor.Parent
		if adjunto then
			adjunto:Destroy()
		end
	end
	for _, r in a.Runas do
		r:Destroy()
	end
	auras[j] = nil
end

local function poner(j: Player)
	quitar(j)
	local c = Reglas.cosmetico("Aura", tostring(j:GetAttribute("Aura") or ""))
	local raiz = j.Character and j.Character:FindFirstChild("HumanoidRootPart")
	if not c or not raiz or not raiz:IsA("BasePart") then
		return
	end
	local reducidos = Efectos.reducidos()
	local adjunto = Instance.new("Attachment")
	adjunto.Name = "Aura"
	adjunto.Parent = raiz
	local e = Instance.new("ParticleEmitter")
	e.Color = secuencia(c.Colores)
	e.LightEmission = 0.8
	e.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
	e.Transparency = NumberSequence.new(0.1, 1)
	e.Lifetime = NumberRange.new(0.8, 1.4)
	e.SpreadAngle = Vector2.new(180, 180)
	if c.Forma == "Chispas" then
		e.Speed = NumberRange.new(2, 4)
		e.Acceleration = Vector3.new(0, 6, 0)
		e.Rate = if reducidos then 6 else 18
	else
		e.Speed = NumberRange.new(0.5, 1.5)
		e.Rate = if reducidos then 3 else 10
	end
	e.Parent = adjunto
	local runas: { BasePart } = {}
	if c.Forma == "Orbita" and not reducidos then
		for i = 1, 3 do
			local p = Instance.new("Part")
			p.Name = "Runa"
			p.Size = Vector3.new(0.5, 0.5, 0.5)
			p.Shape = Enum.PartType.Ball
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromHex(c.Colores[(i - 1) % #c.Colores + 1])
			p.Anchored = true
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
			p.CastShadow = false
			p.Parent = carpeta
			table.insert(runas, p)
		end
	end
	auras[j] = { Emisor = e, Runas = runas, Raiz = raiz }
end

local function seguir(j: Player)
	j.CharacterAdded:Connect(function(personaje: Model)
		personaje:WaitForChild("HumanoidRootPart", 10)
		poner(j)
	end)
	j:GetAttributeChangedSignal("Aura"):Connect(function()
		poner(j)
	end)
	if j.Character then
		task.spawn(poner, j)
	end
end
Players.PlayerAdded:Connect(seguir)
for _, j in Players:GetPlayers() do
	seguir(j)
end
Players.PlayerRemoving:Connect(quitar)
Efectos.alCambiar(function()
	for j in auras do
		poner(j)
	end
end)

-- Runas que orbitan (un solo bucle para todas).
RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for _, a in auras do
		if #a.Runas > 0 and a.Raiz.Parent then
			for i, r in a.Runas do
				local ang = t * 2 + i * (math.pi * 2 / #a.Runas)
				r.CFrame = CFrame.new(
					a.Raiz.Position
						+ Vector3.new(
							math.cos(ang) * 2.4,
							0.6 * math.sin(t * 3 + i),
							math.sin(ang) * 2.4
						)
				)
			end
		end
	end
end)
