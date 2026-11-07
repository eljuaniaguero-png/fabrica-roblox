--!strict
-- Efectos visuales de las habilidades. Solo se ven: no deciden nada. Colores en Config.Poderes.Colores.
-- Regla: ningún efecto tapa a los peleadores y todo se borra solo.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local EfectosGolpe = require(script.Parent:WaitForChild("EfectosGolpe"))
local Fuego = require(script.Parent:WaitForChild("Fuego"))
local remoto = ReplicatedStorage:WaitForChild("Poderes") :: RemoteEvent

local P = Config.Poderes
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

local anillo = EfectosGolpe.onda

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

local function estallido(centro: Vector3, color: Color3, cantidad: number, _rapidez: number)
	EfectosGolpe.reproducir(centro, cantidad >= 30, color)
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
		Fuego.chorro(r, d.Dura)
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
	elseif tipo == "Carga" then
		Fuego.carga(a, b.Impacto)
	elseif tipo == "Explota" then
		Fuego.explosion(a)
		-- SONIDO: explosión de fuego
	end
end)
