--!strict
-- Cada tanto, sobre cada criatura que trabaja en tus corrales sube un "+N" (el ADN que generó).
-- Es solo visual: el ADN lo suma el servidor cada segundo.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local MiLab = require(script.Parent.MiLab)

local CADA = 3 -- segundos entre "+N"

local jugador = Players.LocalPlayer
local corrales = MiLab.obtener():WaitForChild("Corrales")

local function flotar(modelo: Model, cantidad: number)
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = modelo:GetPivot().Position + Vector3.new(0, 6, 0)
	ancla.Parent = workspace.Terrain
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(3, 1.2)
	cartel.LightInfluence = 0
	cartel.MaxDistance = 80
	cartel.Parent = ancla
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Font = Enum.Font.FredokaOne
	texto.TextScaled = true
	texto.Text = "+" .. cantidad
	texto.TextColor3 = Paleta.Acento
	local borde = Instance.new("UIStroke")
	borde.Color = Paleta.Contorno
	borde.Thickness = 2
	borde.Parent = texto
	texto.Parent = cartel
	TweenService:Create(cartel, TweenInfo.new(1.4), { StudsOffset = Vector3.new(0, 2.5, 0) }):Play()
	TweenService
		:Create(texto, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		})
		:Play()
	TweenService
		:Create(borde, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
		})
		:Play()
	Debris:AddItem(ancla, 1.5)
end

while true do
	task.wait(CADA)
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
				local cantidad = if porSegundo then math.floor(porSegundo * CADA) else 0
				if modelo:IsA("Model") and cantidad > 0 then
					-- Escalonados, para que no salgan todos juntos.
					task.delay(i * 0.15, flotar, modelo, cantidad)
				end
			end
		end
	end
end
