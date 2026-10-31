--!strict
-- Ciclo de día y noche y niebla según la ciudad donde estás (partes con tag "Barrio" y atributo
-- Ciudad). Va en el cliente para que Vórtice tenga noche eterna sin cambiarle la hora a los demás.

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Tiempo = require(ReplicatedStorage.Shared.Tiempo)

local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosfera.Parent = Lighting

local function ciudadEn(pos: Vector3): string
	for _, area in CollectionService:GetTagged("Barrio") do
		if area:IsA("BasePart") then
			local local_ = area.CFrame:PointToObjectSpace(pos)
			local m = area.Size / 2
			if math.abs(local_.X) <= m.X and math.abs(local_.Z) <= m.Z then
				return area:GetAttribute("Ciudad") or "Bahia"
			end
		end
	end
	return "Bahia"
end

local ciudadActual = ""

local function ponerNiebla(ciudad: string)
	local n = Config.Mundo.Niebla[ciudad] or Config.Mundo.Niebla.Bahia
	TweenService:Create(atmosfera, TweenInfo.new(3), {
		Density = n.Densidad,
		Haze = n.Bruma,
		Color = Color3.fromHex(n.Color),
	}):Play()
end

local acumulado = 0
RunService.RenderStepped:Connect(function(dt)
	local personaje = Players.LocalPlayer.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	acumulado += dt
	if raiz and raiz:IsA("BasePart") and acumulado > 1 then
		acumulado = 0
		local ciudad = ciudadEn(raiz.Position)
		if ciudad ~= ciudadActual then
			ciudadActual = ciudad
			ponerNiebla(ciudad)
		end
	end
	if ciudadActual == "CiudadVortice" then
		Lighting.ClockTime = Config.Mundo.HoraNocheEterna
	else
		Lighting.ClockTime = Tiempo.hora()
	end
end)
