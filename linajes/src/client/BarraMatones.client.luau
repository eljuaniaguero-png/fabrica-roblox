--!strict
-- Barra de vida sobre cada matón (GUIA-ESTILO §5.1): nombre Oswald Light 12 px en Hueso #EDE6D6,
-- barra 86 x 4 px (#080A0E 65% / #B8343A) + rastro de daño #E8C9A0 (0.45 s), visible a < 35 studs o tras golpe.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local B = Config.Hud.BarraMaton
local ESPERA_RASTRO = Config.Hud.DanioEspera
local DIST_CERCA = 35
local ANCHO_BARRA = 86
local ALTO_BARRA = 4
local ANCHO_CARTEL = 136
local ALTO_CARTEL = 24
local TWEEN_VIDA = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_RASTRO = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local jugador = Players.LocalPlayer
local gui = jugador:WaitForChild("PlayerGui")

local registros: {
	[Model]: {
		cartel: BillboardGui,
		raiz: BasePart,
		hum: Humanoid,
		ultimoGolpe: number,
	},
} =
	{}

local function nombreVisible(m: Model): string
	local n = m:GetAttribute("Nombre")
	if typeof(n) == "string" and n ~= "" then
		return string.upper(n)
	end
	if m.Name == "Maton" then
		return "MATÓN DEL PUERTO"
	end
	return string.upper(m.Name)
end

local function ponerBarra(m: Instance)
	if not (m:IsA("Model") and m:GetAttribute("Maton")) then
		return
	end
	local raiz = m:WaitForChild("HumanoidRootPart", 5)
	local h = m:WaitForChild("Humanoid", 5)
	if not (raiz and raiz:IsA("BasePart") and h and h:IsA("Humanoid")) or registros[m] then
		return
	end

	local cartel = Instance.new("BillboardGui")
	cartel.Name = "BarraMaton"
	cartel.Adornee = raiz
	cartel.Size = UDim2.fromOffset(ANCHO_CARTEL, ALTO_CARTEL)
	cartel.StudsOffsetWorldSpace = Vector3.new(0, B.Altura, 0)
	cartel.AlwaysOnTop = true
	cartel.LightInfluence = 0
	cartel.MaxDistance = B.Distancia
	cartel.ResetOnSpawn = false
	cartel.Enabled = false

	local etiqueta = Tema.texto(cartel, Tema.espaciar(nombreVisible(m), 2), {
		tam = 12,
		letra = Tema.LetraFina,
		color = Tema.Hueso,
		alineado = Enum.TextXAlignment.Center,
	})
	etiqueta.AnchorPoint = Vector2.new(0.5, 0)
	etiqueta.Position = UDim2.fromScale(0.5, 0)

	local xBarra = math.floor((ANCHO_CARTEL - ANCHO_BARRA) * 0.5)
	local fondo, lleno =
		Tema.barra(cartel, Vector2.new(xBarra, 17), ANCHO_BARRA, ALTO_BARRA, Tema.Vida)
	fondo.BackgroundTransparency = 0.35

	local rastro = Instance.new("Frame")
	rastro.Size = UDim2.fromScale(1, 1)
	rastro.BackgroundColor3 = Tema.Danio
	rastro.BackgroundTransparency = 0.12
	rastro.BorderSizePixel = 0
	rastro.ZIndex = 2
	rastro.Parent = fondo
	lleno.ZIndex = 3

	local info = {
		cartel = cartel,
		raiz = raiz,
		hum = h,
		ultimoGolpe = 0,
	}
	registros[m] = info

	local vidaAntes = h.Health
	local tokenRastro = 0

	local function actualizar()
		local max = math.max(h.MaxHealth, 1)
		local actual = math.clamp(h.Health, 0, max)
		local frac = actual / max
		TweenService:Create(lleno, TWEEN_VIDA, { Size = UDim2.fromScale(frac, 1) }):Play()

		if actual < vidaAntes then
			info.ultimoGolpe = os.clock()
			tokenRastro += 1
			local turno = tokenRastro
			task.delay(ESPERA_RASTRO, function()
				if tokenRastro == turno and rastro.Parent then
					TweenService:Create(rastro, TWEEN_RASTRO, { Size = UDim2.fromScale(frac, 1) })
						:Play()
				end
			end)
		elseif actual > vidaAntes then
			rastro.Size = UDim2.fromScale(frac, 1)
		end
		vidaAntes = actual
	end

	h.HealthChanged:Connect(actualizar)
	h:GetPropertyChangedSignal("MaxHealth"):Connect(actualizar)
	actualizar()
	cartel.Parent = gui
	m.Destroying:Once(function()
		registros[m] = nil
		cartel:Destroy()
	end)
end

RunService.Heartbeat:Connect(function()
	local miPersonaje = jugador.Character
	local miRaiz = miPersonaje and miPersonaje:FindFirstChild("HumanoidRootPart")
	local miPos = if miRaiz and miRaiz:IsA("BasePart") then miRaiz.Position else nil
	local ahora = os.clock()

	for _, info in registros do
		if info.hum.Health <= 0 then
			info.cartel.Enabled = false
		else
			local herido = info.hum.Health < info.hum.MaxHealth
			local golpeReciente = (ahora - info.ultimoGolpe) < 4.5
			local dist = if miPos then (info.raiz.Position - miPos).Magnitude else 999
			info.cartel.Enabled = (dist <= DIST_CERCA)
				or ((herido or golpeReciente) and dist <= B.Distancia)
		end
	end
end)

CollectionService:GetInstanceAddedSignal("Combatiente"):Connect(ponerBarra)
for _, m in CollectionService:GetTagged("Combatiente") do
	task.spawn(ponerBarra, m)
end
