--!strict
-- Efectos visuales de las habilidades. Solo se ven: no deciden nada. Colores en Config.Poderes.Colores.
-- Regla: ningún efecto tapa a los peleadores y todo se borra solo.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local EfectosGolpe = require(script.Parent:WaitForChild("EfectosGolpe"))
local Fuego = require(script.Parent:WaitForChild("Fuego"))
local Niveles = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Niveles"))
local remoto = ReplicatedStorage:WaitForChild("Poderes") :: RemoteEvent

local P = Config.Poderes
local POLVO = P.Colores.FuerzaBruta
local REFLEJO = P.Colores.Reflejos
local HUESO = Color3.fromHex(Config.Hud.Colores.Hueso)
local TINTA = Color3.fromHex(Config.Hud.Colores.Fondo)
local ESCOMBRO = Color3.fromHex(Config.Efectos.ColorEscombro)

local escalaActual = 1

local function anillo(centro: Vector3, radio: number, color: Color3)
	EfectosGolpe.onda(centro, radio * escalaActual, color)
end

-- Cuñas de piso que saltan: escombros angulosos del color del suelo, no cubos lisos.
local function escombros(centro: Vector3, cantidad: number, fuerza: number)
	for _ = 1, cantidad do
		local p = Instance.new("WedgePart")
		p.Size =
			Vector3.new(math.random(3, 9) / 10, math.random(5, 14) / 10, math.random(6, 16) / 10)
		p.Color = ESCOMBRO:Lerp(TINTA, math.random() * 0.4)
		p.Material = Enum.Material.Slate
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CFrame = CFrame.new(centro + Vector3.new(math.random(-4, 4), 0.5, math.random(-4, 4)))
			* CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
		p.Parent = workspace
		p.AssemblyLinearVelocity =
			Vector3.new(math.random(-20, 20), fuerza + math.random(0, 20), math.random(-20, 20))
		p.AssemblyAngularVelocity =
			Vector3.new(math.random(-9, 9), math.random(-9, 9), math.random(-9, 9))
		Debris:AddItem(p, 1.1)
	end
end

local function estallido(centro: Vector3, color: Color3, cantidad: number, _rapidez: number)
	EfectosGolpe.reproducir(centro, cantidad >= 30, color, escalaActual)
end

local function raizDe(personaje: Model): BasePart?
	local r = personaje:FindFirstChild("HumanoidRootPart")
	return if r and r:IsA("BasePart") then r else nil
end

-- Figura fantasma: la silueta real del cuerpo (copias de sus mallas) en 3 trazos que se apagan.
local function fantasma(personaje: Model, color: Color3)
	local raiz = raizDe(personaje)
	local atras = if raiz then -raiz.CFrame.LookVector else Vector3.zero
	for paso = 0, 2 do
		local grupo = Instance.new("Model")
		grupo.Name = "Fantasma"
		for _, parte in personaje:GetChildren() do
			if parte:IsA("MeshPart") and parte.Transparency < 1 and parte.Size.Magnitude > 0.8 then
				local copia = parte:Clone()
				copia:ClearAllChildren()
				copia.Anchored = true
				copia.CanCollide = false
				copia.CanQuery = false
				copia.CanTouch = false
				copia.Color = color
				copia.Material = Enum.Material.SmoothPlastic
				copia.TextureID = ""
				copia.Transparency = 0.5 + paso * 0.15
				copia.CFrame = parte.CFrame + atras * paso * 1.6
				copia.Parent = grupo
				TweenService:Create(copia, TweenInfo.new(0.35 + paso * 0.05), { Transparency = 1 })
					:Play()
			end
		end
		local tinta = Instance.new("Highlight")
		tinta.FillTransparency = 1
		tinta.OutlineColor = TINTA
		tinta.OutlineTransparency = 0.2 + paso * 0.25
		tinta.DepthMode = Enum.HighlightDepthMode.Occluded
		tinta.Parent = grupo
		grupo.Parent = workspace
		Debris:AddItem(grupo, 0.5)
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
			anillo(piso(r), 8, HUESO)
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
		Fuego.chorro(r, d.Dura, escalaActual)
	end,
}

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any)
	if tipo == "Efecto" then
		local datos = b
		local hacer = efectos[datos.Accion]
		local r = raizDe(a)
		if hacer and r then
			escalaActual = Niveles.tamano(a)
			hacer(a, r, datos)
		end
	elseif tipo == "Carga" then
		Fuego.carga(a, b.Impacto)
	elseif tipo == "Explota" then
		Fuego.explosion(a, b)
		-- SONIDO: explosión de fuego
	end
end)

-- Subir de nivel: festejo propio.
local jugador = game:GetService("Players").LocalPlayer
local nivelVisto = jugador:GetAttribute("Nivel")
jugador:GetAttributeChangedSignal("Nivel"):Connect(function()
	local nivel = jugador:GetAttribute("Nivel")
	local personaje = jugador.Character
	local r = personaje and raizDe(personaje)
	if
		r
		and typeof(nivel) == "number"
		and typeof(nivelVisto) == "number"
		and nivel > nivelVisto
	then
		local dorado = Color3.fromHex("#ffd34d")
		EfectosGolpe.reproducir(r.Position, true, dorado)
		EfectosGolpe.onda(piso(r), 10, dorado)
	end
	nivelVisto = nivel
end)
