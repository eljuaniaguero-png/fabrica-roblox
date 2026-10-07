--!strict
-- Efecto cosmético al prender una baldosa (Config.Cosmeticos de tipo "Pisada"). Solo se ve,
-- no da ventaja. Es una sola pieza de neón o unas chispas que duran menos de un segundo,
-- para que ande fluido en celular.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local EfectoPisada = {}

local CHISPA = "rbxasset://textures/particles/sparkles_main.dds"
local DURACION = 0.6

local function pieza(forma: Enum.PartType, tamano: Vector3, cframe: CFrame, color: Color3): Part
	local parte = Instance.new("Part")
	parte.Shape = forma
	parte.Size = tamano
	parte.CFrame = cframe
	parte.Color = color
	parte.Material = Enum.Material.Neon
	parte.Transparency = 0.2
	parte.Anchored = true
	parte.CanCollide = false
	parte.CanQuery = false
	parte.CanTouch = false
	parte.CastShadow = false
	parte.Parent = workspace
	Debris:AddItem(parte, DURACION + 0.1)
	return parte
end

local function animar(parte: Part, propiedades: { [string]: any })
	TweenService:Create(
		parte,
		TweenInfo.new(DURACION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		propiedades
	):Play()
end

function EfectoPisada.mostrar(jugador: Player, baldosa: BasePart, colorBaldosa: Color3)
	local id = jugador:GetAttribute("EfectoPisada")
	local cosmetico = if typeof(id) == "string" then Config.Cosmeticos[id] else nil
	if not cosmetico or cosmetico.Tipo ~= "Pisada" then
		return
	end
	local color = cosmetico.Colores[1] or colorBaldosa
	local arriba = baldosa.Position + Vector3.new(0, baldosa.Size.Y / 2, 0)

	if id == "PisadaAnillo" then
		-- Disco fino que se abre y se desvanece.
		local disco = pieza(
			Enum.PartType.Cylinder,
			Vector3.new(0.2, 2, 2),
			CFrame.new(arriba) * CFrame.Angles(0, 0, math.rad(90)),
			color
		)
		animar(disco, { Size = Vector3.new(0.2, 12, 12), Transparency = 1 })
	elseif id == "PisadaColumna" then
		-- Columna de luz que sube y se desvanece.
		local columna = pieza(Enum.PartType.Block, Vector3.new(3, 1, 3), CFrame.new(arriba), color)
		animar(columna, {
			Size = Vector3.new(0.6, 14, 0.6),
			CFrame = CFrame.new(arriba + Vector3.new(0, 7, 0)),
			Transparency = 1,
		})
	else
		-- Chispas: una ráfaga corta desde la baldosa.
		local ancla = pieza(Enum.PartType.Block, Vector3.one * 0.2, CFrame.new(arriba), color)
		ancla.Transparency = 1
		local chispas = Instance.new("ParticleEmitter")
		chispas.Texture = CHISPA
		chispas.Color = ColorSequence.new(color)
		chispas.LightEmission = 1
		chispas.Size = NumberSequence.new(0.6, 0)
		chispas.Lifetime = NumberRange.new(0.3, 0.5)
		chispas.Speed = NumberRange.new(8, 14)
		chispas.SpreadAngle = Vector2.new(60, 60)
		chispas.EmissionDirection = Enum.NormalId.Top
		chispas.Acceleration = Vector3.new(0, -20, 0)
		chispas.Rate = 0
		chispas.Parent = ancla
		chispas:Emit(14)
	end
end

return EfectoPisada
