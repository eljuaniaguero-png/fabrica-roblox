--!strict
-- Efectos visuales de las habilidades. Solo se ven: no deciden nada. Colores en Config.Poderes.Colores.
-- Regla: ningún efecto tapa a los peleadores y todo se borra solo.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Poderes") :: RemoteEvent

local P = Config.Poderes
local FUEGO = P.Colores.Piroquinesis
local POLVO = P.Colores.FuerzaBruta
local REFLEJO = P.Colores.Reflejos

local function suelta(tamano: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Size = tamano
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	return p
end

-- Onda que se abre en el piso.
local function anillo(centro: Vector3, radio: number, color: Color3)
	local p = suelta(Vector3.new(0.4, 2, 2), color, Enum.Material.Neon)
	p.Shape = Enum.PartType.Cylinder
	p.CFrame = CFrame.new(centro) * CFrame.Angles(0, 0, math.pi / 2)
	p.Transparency = 0.45
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, radio * 2, radio * 2),
		Transparency = 1,
	}):Play()
	Debris:AddItem(p, 0.4)
end

-- Bloques de piso que saltan.
local function escombros(centro: Vector3, cantidad: number, fuerza: number)
	for _ = 1, cantidad do
		local t = math.random(5, 14) / 10
		local p = suelta(Vector3.new(t, t, t), Color3.fromHex("#3a3f4b"), Enum.Material.Concrete)
		p.Anchored = false
		p.CFrame = CFrame.new(centro + Vector3.new(math.random(-4, 4), 0.5, math.random(-4, 4)))
		p.Parent = workspace
		p.AssemblyLinearVelocity =
			Vector3.new(math.random(-20, 20), fuerza + math.random(0, 20), math.random(-20, 20))
		p.AssemblyAngularVelocity =
			Vector3.new(math.random(-9, 9), math.random(-9, 9), math.random(-9, 9))
		Debris:AddItem(p, 1.1)
	end
end

local function particulas(
	padre: Instance,
	color: Color3,
	rapidez: number,
	vida: number,
	tam: number
): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(Color3.new(1, 0.95, 0.75), color)
	e.LightEmission = 0.8
	e.Lifetime = NumberRange.new(vida * 0.6, vida)
	e.Speed = NumberRange.new(rapidez * 0.6, rapidez)
	e.Size = NumberSequence.new(tam, 0)
	e.Transparency = NumberSequence.new(0.1, 1)
	e.Rate = 0
	e.Parent = padre
	return e
end

local function estallido(centro: Vector3, color: Color3, cantidad: number, rapidez: number)
	local p = suelta(Vector3.one, color, Enum.Material.Air)
	p.Transparency = 1
	p.Position = centro
	p.Parent = workspace
	local e = particulas(p, color, rapidez, 0.45, 1.3)
	e.SpreadAngle = Vector2.new(180, 180)
	e:Emit(cantidad)
	Debris:AddItem(p, 0.8)
end

local function raizDe(personaje: Model): BasePart?
	local r = personaje:FindFirstChild("HumanoidRootPart")
	return if r and r:IsA("BasePart") then r else nil
end

-- Figura fantasma en el lugar donde estaba el cuerpo.
local function fantasma(personaje: Model, color: Color3)
	for _, parte in personaje:GetChildren() do
		if parte:IsA("MeshPart") and parte.Transparency < 1 and parte.Size.Magnitude > 0.8 then
			local copia = suelta(parte.Size, color, Enum.Material.Neon)
			copia.CFrame = parte.CFrame
			copia.Transparency = 0.45
			copia.Parent = workspace
			TweenService:Create(copia, TweenInfo.new(0.4), { Transparency = 1 }):Play()
			Debris:AddItem(copia, 0.45)
		end
	end
end

local function aura(personaje: Model, color: Color3, dura: number)
	local luz = Instance.new("Highlight")
	luz.Adornee = personaje
	luz.FillTransparency = 0.8
	luz.FillColor = color
	luz.OutlineColor = color
	luz.Parent = personaje
	Debris:AddItem(luz, dura)
end

local function piso(r: BasePart): Vector3
	return r.Position - Vector3.new(0, 2.8, 0)
end

local efectos: { [string]: (Model, BasePart, any) -> () } = {
	PunoSismico = function(_p, r)
		local punto = piso(r) + r.CFrame.LookVector * 6
		anillo(punto, 9, POLVO)
		escombros(punto, 7, 28)
		estallido(punto, POLVO, 30, 34)
	end,
	GolpePiso = function(_p, r)
		anillo(piso(r), 12, POLVO)
		task.delay(0.08, function()
			anillo(piso(r), 8, Color3.new(1, 1, 1))
		end)
		escombros(piso(r), 14, 36)
		estallido(piso(r), POLVO, 40, 42)
	end,
	Embestida = function(_p, r)
		anillo(piso(r), 8, POLVO)
		estallido(r.Position, POLVO, 30, 30)
		escombros(piso(r), 6, 24)
	end,
	Contragolpe = function(p, _r, d)
		aura(p, REFLEJO, d.Dura)
	end,
	PasoFantasma = function(p, r)
		fantasma(p, REFLEJO)
		estallido(r.Position, REFLEJO, 30, 36)
	end,
	LluviaGolpes = function(p, r, d)
		aura(p, REFLEJO, 1)
		task.spawn(function()
			for _ = 1, d.Golpes do
				if not p.Parent then
					return
				end
				estallido(r.Position + r.CFrame.LookVector * 5, REFLEJO, 10, 26)
				task.wait(1 / d.Golpes)
			end
		end)
	end,
	Chorro = function(_p, r, d)
		local punto = Instance.new("Attachment")
		punto.Position = Vector3.new(0, 0.5, -2.5)
		punto.Orientation = Vector3.new(-90, 0, 0)
		punto.Parent = r
		local e = particulas(punto, FUEGO, 42, 0.4, 2)
		e.SpreadAngle = Vector2.new(16, 16)
		e.Rate = 70
		e.Acceleration = Vector3.new(0, 6, 0)
		Debris:AddItem(punto, d.Dura + 0.5)
		task.delay(d.Dura, function()
			e.Rate = 0
		end)
	end,
}

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any)
	if tipo == "Efecto" then
		local datos = b
		local hacer = efectos[datos.Accion]
		local r = raizDe(a)
		if hacer and r then
			hacer(a, r, datos)
		end
	elseif tipo == "Explota" then
		anillo(a - Vector3.new(0, 2.8, 0), 6, FUEGO)
		estallido(a, FUEGO, 22, 24)
		-- SONIDO: explosión de fuego
	end
end)
