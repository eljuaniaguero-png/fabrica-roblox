--!strict
-- Cada tanto, sobre cada criatura que trabaja en tus corrales sube un "+N" (el ADN que generó)
-- y después vuela hasta el contador de ADN del HUD. Es solo visual: el ADN lo suma el
-- servidor cada segundo. Para no cargar el celular, vuelan pocos a la vez.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local MiLab = require(script.Parent.MiLab)

local E = Config.Efectos

local jugador = Players.LocalPlayer
local corrales = MiLab.obtener():WaitForChild("Corrales")
local FUENTE = Font.fromEnum(Enum.Font.FredokaOne)

-- Capa para los números que vuelan (mismos bordes de pantalla que el HUD).
local capa = Instance.new("ScreenGui")
capa.Name = "ADNVuela"
capa.ResetOnSpawn = false
capa.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
capa.DisplayOrder = 3
capa.Parent = jugador:WaitForChild("PlayerGui")

local volando = 0

-- El contador de ADN del HUD (o nil si todavía no está).
local function contador(): GuiObject?
	local hud = jugador.PlayerGui:FindFirstChild("HUD")
	local raiz = hud and hud:FindFirstChild("Raiz")
	local marco = raiz and raiz:FindFirstChild("ADN")
	return if marco and marco:IsA("GuiObject") then marco else nil
end

-- El número viaja desde la criatura hasta el contador y se achica al llegar.
local function volar(desde: Vector3, cantidad: number)
	local destino = contador()
	if not destino or volando >= E.MaximoVolando then
		return
	end
	local punto, visible = workspace.CurrentCamera:WorldToScreenPoint(desde)
	if not visible then
		return
	end
	volando += 1
	local t = Instance.new("TextLabel")
	t.Name = "ADN"
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromOffset(punto.X, punto.Y)
	t.Size = UDim2.fromOffset(120, 40)
	t.BackgroundTransparency = 1
	t.FontFace = FUENTE
	t.TextSize = 30
	t.Text = "+" .. cantidad
	t.TextColor3 = Paleta.Acento
	local borde = Instance.new("UIStroke")
	borde.Color = Paleta.Contorno
	borde.Thickness = 2
	borde.Parent = t
	t.Parent = capa
	-- Llega a la izquierda del contador, donde está el ícono de ADN.
	local fin = destino.AbsolutePosition + Vector2.new(40, destino.AbsoluteSize.Y / 2)
	local viaje = TweenService:Create(
		t,
		TweenInfo.new(E.DuracionVuelo, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.fromOffset(fin.X, fin.Y), TextSize = 16 }
	)
	viaje:Play()
	viaje.Completed:Once(function()
		t:Destroy()
		volando -= 1
	end)
end

local function flotar(modelo: Model, cantidad: number)
	local inicio = modelo:GetPivot().Position + Vector3.new(0, 6, 0)
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = inicio
	ancla.Parent = workspace.Terrain
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(3, 1.2)
	cartel.LightInfluence = 0
	cartel.MaxDistance = 80
	cartel.Parent = ancla
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.FontFace = FUENTE
	texto.TextScaled = true
	texto.Text = "+" .. cantidad
	texto.TextColor3 = Paleta.Acento
	local borde = Instance.new("UIStroke")
	borde.Color = Paleta.Contorno
	borde.Thickness = 2
	borde.Parent = texto
	texto.Parent = cartel
	-- Salta hacia arriba; después se va volando al contador.
	TweenService:Create(
		cartel,
		TweenInfo.new(E.DuracionSube, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ StudsOffset = Vector3.new(0, 1.5, 0) }
	):Play()
	task.delay(E.DuracionSube, function()
		ancla:Destroy()
		volar(inicio + Vector3.new(0, 1.5, 0), cantidad)
	end)
	Debris:AddItem(ancla, E.DuracionSube + 0.5)
end

while true do
	task.wait(E.CadaADNFlotante)
	local multiplicador =
		Mejoras.multiplicadorADN((jugador:GetAttribute("MejoraNutrientes") :: number?) or 0)
	for _, corral in corrales:GetChildren() do
		local criaturas = corral:FindFirstChild("Criaturas")
		if criaturas then
			for i, modelo in criaturas:GetChildren() do
				local gen = modelo:GetAttribute("Gen") :: number?
				-- "Produce" lo anota el servidor (con personalidades); si falta, la cuenta común.
				local porSegundo = (modelo:GetAttribute("Produce") :: number?)
					or (if gen then Config.Economia.ADNPorGen[gen] * multiplicador else nil)
				local cantidad = if porSegundo
					then math.floor(porSegundo * E.CadaADNFlotante)
					else 0
				if modelo:IsA("Model") and cantidad > 0 then
					-- Escalonados, para que no salgan todos juntos.
					task.delay(i * 0.15, flotar, modelo, cantidad)
				end
			end
		end
	end
end
