--!strict
-- Golpe por capas: destello, anillo, arco, chispas y, si es fuerte, humo y líneas.
-- Texturas propias (arte/scripts/efectos). Solo se ve: no decide nada.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local E = Config.Efectos
local BLANCO = Color3.new(1, 1, 1)

local EfectosGolpe = {}

local function capa(
	soporte: BasePart,
	textura: string,
	tam: number,
	color: Color3,
	vida: number,
	brillo: number,
	giro: number?
)
	local e = Instance.new("ParticleEmitter")
	e.Texture = textura
	e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	e.Color = ColorSequence.new(color)
	e.LightEmission = brillo
	e.LightInfluence = 0
	e.Lifetime = NumberRange.new(vida)
	e.Speed = NumberRange.new(0)
	e.Size = NumberSequence.new(tam)
	e.Rotation = NumberRange.new(giro or math.random(0, 359))
	e.ZOffset = 2
	e.Rate = 0
	e.Parent = soporte
	e:Emit(1)
end

local function chispas(soporte: BasePart, color: Color3, cantidad: number)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(BLANCO, color)
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Orientation = Enum.ParticleOrientation.VelocityParallel
	e.Lifetime = NumberRange.new(0.18, 0.4)
	e.Speed = NumberRange.new(35, 75)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new(0.28, 0)
	e.Squash = NumberSequence.new(2.4)
	e.Drag = 7
	e.ZOffset = 2
	e.Rate = 0
	e.Parent = soporte
	e:Emit(cantidad)
end

function EfectosGolpe.reproducir(punto: Vector3, fuerte: boolean, color: Color3)
	local s = if fuerte then E.EscalaFuerte else 1
	local soporte = Instance.new("Part")
	soporte.Anchored = true
	soporte.CanCollide = false
	soporte.CanQuery = false
	soporte.CanTouch = false
	soporte.Transparency = 1
	soporte.Size = Vector3.one * 0.2
	soporte.Position = punto
	soporte.Parent = workspace
	capa(soporte, E.Destello, E.TamDestello * 1.35 * s, color, 0.2, 1)
	capa(soporte, E.Destello, E.TamDestello * s, BLANCO, 0.14, 1)
	capa(soporte, E.Anillo, E.TamAnillo * s, color, 0.26, 1)
	capa(soporte, E.Arco, E.TamArco * s, BLANCO, 0.17, 1)
	chispas(soporte, color, if fuerte then 26 else 12)
	if fuerte then
		capa(soporte, E.Lineas, E.TamLineas, color, 0.24, 1)
		capa(soporte, E.Humo, E.TamHumo, Color3.fromHex("#8d90a0"), 0.55, 0)
	end
	Debris:AddItem(soporte, 0.8)
end

-- Onda plana en el piso: mira hacia arriba, no a la cámara.
function EfectosGolpe.onda(centro: Vector3, radio: number, color: Color3)
	local soporte = Instance.new("Part")
	soporte.Anchored = true
	soporte.CanCollide = false
	soporte.CanQuery = false
	soporte.CanTouch = false
	soporte.Transparency = 1
	soporte.Size = Vector3.one * 0.2
	soporte.Position = centro + Vector3.new(0, 0.3, 0)
	soporte.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Texture = E.Anillo
	e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
	e.EmissionDirection = Enum.NormalId.Top
	e.Color = ColorSequence.new(color)
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Lifetime = NumberRange.new(0.32)
	e.Speed = NumberRange.new(0.01)
	e.Size = NumberSequence.new(radio * 2.3)
	e.Rate = 0
	e.Parent = soporte
	e:Emit(1)
	Debris:AddItem(soporte, 0.7)
end

return EfectosGolpe
