--!strict
-- Efectos visuales de las habilidades. Solo se ven: no deciden nada. Colores en Config.Poderes.Colores.
-- Regla: ningún efecto tapa a los peleadores y todo se borra solo.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local CamaraCombate = require(script.Parent:WaitForChild("CamaraCombate"))
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
		anillo(punto, 10, POLVO)
		EfectosGolpe.tajo(r.CFrame, 12, POLVO, escalaActual * 1.4, true)
		escombros(punto, 10, 32)
		estallido(punto, POLVO, 34, 38)
		CamaraCombate.sacudir(1.0, r.CFrame.LookVector)
		CamaraCombate.zoom(-5)
	end,
	GolpePiso = function(_p, r)
		local base = piso(r)
		anillo(base, 13, POLVO)
		-- Pilares de roca angulosos que brotan en corona alrededor del golpe.
		for i = 1, 6 do
			local ang = (i / 6) * math.pi * 2
			local cf = CFrame.new(
				base + Vector3.new(math.cos(ang) * 4.5, -1.6, math.sin(ang) * 4.5)
			) * CFrame.Angles(math.rad(-22), ang, 0)
			local pico = Instance.new("WedgePart")
			pico.Anchored = true
			pico.CanCollide = false
			pico.CanQuery = false
			pico.CanTouch = false
			pico.Material = Enum.Material.Slate
			pico.Color = ESCOMBRO
			pico.Size = Vector3.new(1.5, 4.2, 2.0) * escalaActual
			pico.CFrame = cf
			pico.Parent = workspace
			TweenService:Create(pico, TweenInfo.new(0.14, Enum.EasingStyle.Back), {
				CFrame = cf + Vector3.new(0, 2.2, 0),
			}):Play()
			task.delay(0.28, function()
				TweenService:Create(pico, TweenInfo.new(0.35), {
					CFrame = cf - Vector3.new(0, 1.5, 0),
					Transparency = 1,
				}):Play()
			end)
			Debris:AddItem(pico, 0.7)
		end
		task.delay(0.08, function()
			anillo(base, 9, HUESO)
		end)
		escombros(base, 16, 40)
		estallido(base, POLVO, 42, 44)
		CamaraCombate.sacudir(1.4, Vector3.new(0, 1, 0))
		CamaraCombate.zoom(-7)
	end,
	Embestida = function(_p, r)
		anillo(piso(r), 9, POLVO)
		EfectosGolpe.anillo3D(
			r.CFrame * CFrame.new(0, 0.4, -2) * CFrame.Angles(math.pi / 2, 0, 0),
			2.2,
			6.5 * escalaActual,
			POLVO,
			0.25,
			0.28
		)
		estallido(r.Position, POLVO, 32, 34)
		escombros(piso(r), 8, 28)
		CamaraCombate.zoom(6)
		CamaraCombate.sacudir(0.8, r.CFrame.LookVector)
	end,
	Contragolpe = function(p, r, d)
		aura(p, REFLEJO, d.Dura)
		EfectosGolpe.anillo3D(r.CFrame, 2.0, 5.2, REFLEJO, 0.28, 0.2)
	end,
	PasoFantasma = function(p, r)
		fantasma(p, REFLEJO)
		EfectosGolpe.anillo3D(
			r.CFrame * CFrame.Angles(math.pi / 2, 0, 0),
			1.8,
			7.2,
			REFLEJO,
			0.25,
			0.26
		)
		estallido(r.Position, REFLEJO, 32, 38)
		CamaraCombate.zoom(7)
	end,
	LluviaGolpes = function(p, r, d)
		aura(p, REFLEJO, 1)
		task.spawn(function()
			for i = 1, d.Golpes do
				if not p.Parent then
					return
				end
				local ang = if i % 2 == 0 then 36 else -36
				EfectosGolpe.tajo(
					r.CFrame,
					ang + math.random(-14, 14),
					REFLEJO,
					escalaActual * 1.15,
					false
				)
				estallido(r.Position + r.CFrame.LookVector * 5, REFLEJO, 12, 28)
				task.wait(1 / d.Golpes)
			end
		end)
	end,
	Chorro = function(_p, r, d)
		Fuego.chorro(r, d.Dura, escalaActual)
		CamaraCombate.sacudir(0.55, r.CFrame.LookVector)
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
