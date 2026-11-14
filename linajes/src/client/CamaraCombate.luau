--!strict
-- Cámara de combate: sacudida direccional amortiguada, pulso de FOV e impact-frame limpio.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local CamaraCombate = {}

local jugador = Players.LocalPlayer
local conectado = false

local sacudidaAmp = 0
local sacudidaDir = Vector3.zero
local fovExtra = 0
local fovVel = 0

local correccionImpacto: ColorCorrectionEffect? = nil
local impactoTicket = 0

local function obtenerCorreccion(): ColorCorrectionEffect
	local actual = correccionImpacto
	if actual and actual.Parent then
		return actual
	end
	local existente = Lighting:FindFirstChild("ImpactoLuz")
	if existente and existente:IsA("ColorCorrectionEffect") then
		correccionImpacto = existente
		return existente
	end
	local nueva = Instance.new("ColorCorrectionEffect")
	nueva.Name = "ImpactoLuz"
	nueva.Enabled = false
	nueva.Parent = Lighting
	correccionImpacto = nueva
	return nueva
end

function CamaraCombate.sacudir(fuerza: number, dir: Vector3?)
	sacudidaAmp = math.min(sacudidaAmp + fuerza, 2.2)
	if dir and dir.Magnitude > 0.05 then
		sacudidaDir = dir.Unit
	else
		sacudidaDir = Vector3.new(math.random(-10, 10), math.random(-5, 8), 0).Unit
	end
end

function CamaraCombate.zoom(deltaFov: number)
	fovExtra = math.clamp(fovExtra + deltaFov, -14, 14)
end

-- Micro flash de contraste en impacto crítico o parry (no pelea con Clima.client).
function CamaraCombate.destelloImpacto(intenso: boolean)
	local fx = obtenerCorreccion()
	impactoTicket += 1
	local ticket = impactoTicket
	fx.Brightness = if intenso then 0.1 else 0.04
	fx.Contrast = if intenso then 0.65 else 0.35
	fx.Saturation = if intenso then -0.45 else -0.2
	fx.TintColor = if intenso then Color3.fromHex("#F0FAFF") else Color3.fromHex("#FFE8DF")
	fx.Enabled = true
	task.delay(if intenso then 0.065 else 0.04, function()
		if impactoTicket == ticket and fx.Parent then
			fx.Enabled = false
		end
	end)
end

function CamaraCombate.conectar()
	if conectado then
		return
	end
	conectado = true
	local fase = 0
	RunService.RenderStepped:Connect(function(dt: number)
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		if jugador:GetAttribute("MenuAbierto") == true then
			return
		end

		local dtLim = math.min(dt, 0.05)
		fase += dtLim * 52

		-- Resorte de FOV que vuelve suave al FOV base.
		local rigidez = 140
		local amortiguacion = 18
		local aceleracion = -rigidez * fovExtra - amortiguacion * fovVel
		fovVel += aceleracion * dtLim
		fovExtra += fovVel * dtLim
		if math.abs(fovExtra) < 0.02 and math.abs(fovVel) < 0.05 then
			fovExtra = 0
			fovVel = 0
		end
		cam.FieldOfView = Config.Mundo.Camara.FOV + fovExtra

		local p = jugador.Character
		local h = p and p:FindFirstChildOfClass("Humanoid")
		if h then
			if sacudidaAmp > 0.01 then
				local onda = math.sin(fase) * sacudidaAmp
				local jitter = Vector3.new(
					(math.random() - 0.5) * sacudidaAmp * 0.6,
					(math.random() - 0.5) * sacudidaAmp * 0.5,
					0
				)
				h.CameraOffset = Vector3.new(sacudidaDir.X * onda * 0.45, math.abs(onda) * 0.25, 0)
					+ jitter
				sacudidaAmp *= math.exp(-16 * dtLim)
			else
				sacudidaAmp = 0
				if h.CameraOffset ~= Vector3.zero then
					h.CameraOffset = Vector3.zero
				end
			end
		end
	end)
end

return CamaraCombate
