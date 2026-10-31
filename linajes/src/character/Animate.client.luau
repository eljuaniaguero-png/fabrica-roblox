--!strict
-- Nuestro Animate: reemplaza al de Roblox (no usa paquetes de animación ni gestos del avatar).
-- Elige la animación según el estado del Humanoid. IDs en Config.Animaciones.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local personaje = script.Parent
local humanoid = personaje:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator
local A = Config.Animaciones

local pistas: { [string]: AnimationTrack } = {}
for _, nombre in { "Quieto", "Caminar", "Correr", "Saltar", "Caer", "Trepar" } do
	local anim = Instance.new("Animation")
	anim.AnimationId = A[nombre]
	local pista = animator:LoadAnimation(anim)
	pista.Looped = nombre ~= "Saltar"
	pista.Priority = if nombre == "Quieto"
		then Enum.AnimationPriority.Idle
		else Enum.AnimationPriority.Movement
	pistas[nombre] = pista
end

local actual: string? = nil
local function tocar(nombre: string, fundido: number?)
	if actual == nombre then
		return
	end
	if actual then
		pistas[actual]:Stop(fundido or 0.2)
	end
	actual = nombre
	pistas[nombre]:Play(fundido or 0.2)
end

local function segunVelocidad(v: number): string
	if v < 0.5 then
		return "Quieto"
	elseif v < A.VelocidadCorrer then
		return "Caminar"
	end
	return "Correr"
end

local velocidad = 0
humanoid.Running:Connect(function(v)
	velocidad = v
	local estado = humanoid:GetState()
	if
		estado == Enum.HumanoidStateType.Running
		or estado == Enum.HumanoidStateType.RunningNoPhysics
	then
		tocar(segunVelocidad(v))
	end
end)

humanoid.StateChanged:Connect(function(_, estado)
	if estado == Enum.HumanoidStateType.Jumping then
		tocar("Saltar", 0.1)
	elseif estado == Enum.HumanoidStateType.Freefall then
		tocar("Caer", 0.3)
	elseif estado == Enum.HumanoidStateType.Climbing then
		tocar("Trepar", 0.1)
	elseif estado == Enum.HumanoidStateType.Landed or estado == Enum.HumanoidStateType.Running then
		tocar(segunVelocidad(velocidad))
	end
end)

tocar("Quieto", 0)
