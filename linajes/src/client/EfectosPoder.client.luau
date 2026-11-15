--!strict
-- Efectos visuales de las habilidades. Solo se ven: no deciden nada. Colores en Config.Poderes.Colores.
-- Regla: ningún efecto tapa a los peleadores y todo se borra solo.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local CamaraCombate = require(script.Parent:WaitForChild("CamaraCombate"))
local EfectosGolpe = require(script.Parent:WaitForChild("EfectosGolpe"))
local Fuego = require(script.Parent:WaitForChild("Fuego"))
local Niveles = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Niveles"))
local remoto = ReplicatedStorage:WaitForChild("Poderes") :: RemoteEvent

local P = Config.Poderes
local EB = Config.Efectos.Beta
local POLVO = P.Colores.FuerzaBruta
local REFLEJO = P.Colores.Reflejos
local FUEGO = P.Colores.Piroquinesis
local ELECTRO = P.Colores.Electro
local CRIO = P.Colores.Criogenia
local TELE = P.Colores.Telequinesis
local HUESO = Color3.fromHex(Config.Hud.Colores.Hueso)
local TINTA = Color3.fromHex(Config.Hud.Colores.Fondo)
local ESCOMBRO = Color3.fromHex(Config.Efectos.ColorEscombro)

local escalaActual = 1

local function anillo(centro: Vector3, radio: number, color: Color3)
	EfectosGolpe.onda(centro, radio * escalaActual, color)
end

-- Cuñas de piso en 3 siluetas poligonales con borde de tinta cómic (GUIA-ESTILO §3.1 Capa 3).
local MOLDES_ESCOMBRO = {
	Vector3.new(0.45, 0.25, 1.35), -- laja de asfalto
	Vector3.new(0.55, 1.35, 0.65), -- diente anguloso
	Vector3.new(0.95, 0.85, 1.05), -- bloque facetado
}

local function escombros(centro: Vector3, cantidad: number, fuerza: number, colorTinta: Color3?)
	local grupo = Instance.new("Model")
	grupo.Name = "EscombrosComic"
	local hl = Instance.new("Highlight")
	hl.FillTransparency = 1
	hl.OutlineColor = colorTinta or Color3.fromHex("#2A1F17")
	hl.OutlineTransparency = 0.12
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Parent = grupo
	grupo.Parent = workspace

	for i = 1, cantidad do
		local p = Instance.new("WedgePart")
		local molde = MOLDES_ESCOMBRO[(i - 1) % #MOLDES_ESCOMBRO + 1]
		p.Size = molde * (0.75 + math.random() * 0.5)
		p.Color = ESCOMBRO:Lerp(TINTA, math.random() * 0.35)
		p.Material = Enum.Material.Slate
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CFrame = CFrame.new(centro + Vector3.new(math.random(-4, 4), 0.5, math.random(-4, 4)))
			* CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
		p.Parent = grupo
		p.AssemblyLinearVelocity =
			Vector3.new(math.random(-20, 20), fuerza + math.random(0, 20), math.random(-20, 20))
		p.AssemblyAngularVelocity =
			Vector3.new(math.random(-9, 9), math.random(-9, 9), math.random(-9, 9))
		task.delay(0.65, function()
			if p.Parent then
				TweenService
					:Create(p, TweenInfo.new(0.4), { Size = Vector3.one * 0.08, Transparency = 1 })
					:Play()
			end
		end)
	end
	Debris:AddItem(grupo, 1.15)
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
	local nucleo, tintaLinaje = EfectosGolpe.coloresCapa(color)
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
				copia.Color = if paso == 0 then nucleo else color
				copia.Material = Enum.Material.SmoothPlastic
				copia.TextureID = ""
				copia.Transparency = 0.46 + paso * 0.16
				copia.CFrame = parte.CFrame + atras * (paso * 1.6 + 0.4)
				copia.Parent = grupo
				TweenService:Create(copia, TweenInfo.new(0.35 + paso * 0.05), { Transparency = 1 })
					:Play()
			end
		end
		local tinta = Instance.new("Highlight")
		tinta.FillColor = color
		tinta.FillTransparency = 0.68 + paso * 0.1
		tinta.OutlineColor = if paso == 0 then nucleo else tintaLinaje
		tinta.OutlineTransparency = 0.18 + paso * 0.25
		tinta.DepthMode = Enum.HighlightDepthMode.Occluded
		tinta.Parent = grupo
		grupo.Parent = workspace
		Debris:AddItem(grupo, 0.5)
	end
end

local function aura(personaje: Model, color: Color3, dura: number)
	local _, tintaLinaje = EfectosGolpe.coloresCapa(color)
	local luz = Instance.new("Highlight")
	luz.Adornee = personaje
	luz.FillTransparency = 0.72
	luz.FillColor = color
	luz.OutlineColor = color:Lerp(tintaLinaje, 0.25)
	luz.OutlineTransparency = 0.12
	luz.Parent = personaje
	Debris:AddItem(luz, dura)
end

local function piso(r: BasePart): Vector3
	return r.Position - Vector3.new(0, 2.8, 0)
end

local function parteBrillo(
	cf: CFrame,
	tam: Vector3,
	color: Color3,
	mat: Enum.Material?,
	tr: number?
): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = tam
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Neon
	p.Transparency = tr or 0
	p.Parent = workspace
	return p
end

local function emitirSprite(
	soporte: BasePart,
	textura: string,
	color: Color3,
	tam: number,
	cantidad: number,
	vida: number,
	rapidez: number
)
	local nucleo = EfectosGolpe.coloresCapa(color)
	local e = Instance.new("ParticleEmitter")
	e.Texture = textura
	e.Color = ColorSequence.new(nucleo, color)
	e.LightEmission = 0.65
	e.LightInfluence = 0
	e.Lifetime = NumberRange.new(vida * 0.65, vida)
	e.Speed = NumberRange.new(rapidez * 0.4, rapidez)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, tam * 0.55),
		NumberSequenceKeypoint.new(0.5, tam),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Rotation = NumberRange.new(0, 359)
	e.RotSpeed = NumberRange.new(-90, 90)
	e.Drag = 4
	e.Rate = 0
	e.Parent = soporte
	e:Emit(cantidad)
end

-- Estela continua para proyectiles rápidos (LightEmission = 0.65 sin blanco puro).
local function estelaParte(soporte: BasePart, color: Color3, ancho: number, vida: number)
	local nucleo = EfectosGolpe.coloresCapa(color)
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, ancho * 0.5, 0)
	a0.Parent = soporte
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -ancho * 0.5, 0)
	a1.Parent = soporte
	local t = Instance.new("Trail")
	t.Attachment0 = a0
	t.Attachment1 = a1
	t.Lifetime = vida
	t.LightEmission = 0.65
	t.FaceCamera = true
	t.Color = ColorSequence.new(nucleo, color)
	t.Transparency = NumberSequence.new(0.05, 1)
	t.Parent = soporte
end

-- Decora cada MuroHielo o PistaHelada que crea el servidor con prismas 3D cel-shaded (#1D3A4F tinta).
local function decorarHielo(parte: Instance)
	if not parte:IsA("BasePart") then
		return
	end
	local nucleoCrio, tintaCrio = EfectosGolpe.coloresCapa(CRIO)
	local dec = Instance.new("Model")
	dec.Name = "CristalesHielo_" .. parte.Name
	local tinta = Instance.new("Highlight")
	tinta.FillTransparency = 1
	tinta.OutlineColor = tintaCrio
	tinta.OutlineTransparency = 0.15
	tinta.DepthMode = Enum.HighlightDepthMode.Occluded
	tinta.Parent = dec

	local tam = parte.Size
	local cf = parte.CFrame
	if parte.Name == "MuroHielo" then
		local mitadY = tam.Y * 0.5
		local pasos = 7
		for i = 1, pasos do
			local frac = (i - 1) / (pasos - 1) - 0.5
			local pico = Instance.new("WedgePart")
			pico.Anchored = true
			pico.CanCollide = false
			pico.CanQuery = false
			pico.CanTouch = false
			pico.Material = Enum.Material.Ice
			pico.Color = CRIO:Lerp(nucleoCrio, if i % 2 == 0 then 0.42 else 0.14)
			pico.Transparency = 0.12
			local alto = tam.Y * (0.75 + ((i * 37) % 10) * 0.045)
			pico.Size = Vector3.new(tam.X / pasos * 1.45, alto, tam.Z * 1.15)
			local finCF = cf
				* CFrame.new(frac * (tam.X * 0.88), (alto - tam.Y) * 0.5, ((i % 3) - 1) * 0.32)
				* CFrame.Angles(math.rad(((i % 2) * 2 - 1) * 7), math.rad((i % 3 - 1) * 14), 0)
			pico.CFrame = finCF - Vector3.new(0, mitadY, 0)
			pico.Parent = dec
			TweenService:Create(
				pico,
				TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ CFrame = finCF }
			):Play()
		end
		EfectosGolpe.grieta(cf.Position - Vector3.new(0, mitadY, 0), tam.X * 0.95, 2.2, tintaCrio)
		emitirSprite(parte, EB.HieloEscarcha, CRIO, 1.9, 14, 0.5, 10)
	elseif parte.Name == "PistaHelada" then
		local cant = 8
		for i = 1, cant do
			local lado = if i % 2 == 0 then 1 else -1
			local avance = ((i - 1) / (cant - 1) - 0.5) * tam.Z * 0.88
			local g = Instance.new("WedgePart")
			g.Anchored = true
			g.CanCollide = false
			g.CanQuery = false
			g.CanTouch = false
			g.Material = Enum.Material.Ice
			g.Color = CRIO:Lerp(nucleoCrio, 0.35)
			g.Transparency = 0.18
			g.Size = Vector3.new(0.85, 1.5, 1.3)
			g.CFrame = cf
				* CFrame.new(lado * (tam.X * 0.48), 0.55, avance)
				* CFrame.Angles(
					0,
					if lado > 0 then math.pi * 0.5 else -math.pi * 0.5,
					math.rad(-25 * lado)
				)
			g.Parent = dec
		end
		-- Cinta continua de escarcha sobre la pista (GUIA-ESTILO §3.3 Criogenia)
		local attIni = Instance.new("Attachment")
		attIni.Position = Vector3.new(0, tam.Y * 0.5 + 0.06, -tam.Z * 0.48)
		attIni.Parent = parte
		local attFin = Instance.new("Attachment")
		attFin.Position = Vector3.new(0, tam.Y * 0.5 + 0.06, tam.Z * 0.48)
		attFin.Parent = parte
		local cintaHielo = Instance.new("Beam")
		cintaHielo.Attachment0 = attIni
		cintaHielo.Attachment1 = attFin
		cintaHielo.Texture = EB.HieloEscarcha
		cintaHielo.TextureLength = 6
		cintaHielo.TextureSpeed = 1.5
		cintaHielo.LightEmission = 0.55
		cintaHielo.LightInfluence = 0
		cintaHielo.Color = ColorSequence.new(nucleoCrio, CRIO)
		cintaHielo.Width0 = tam.X * 0.85
		cintaHielo.Width1 = tam.X * 0.85
		cintaHielo.Transparency = NumberSequence.new(0.18)
		cintaHielo.Parent = parte
	end

	dec.Parent = workspace
	parte.Destroying:Once(function()
		if dec.Parent then
			dec:Destroy()
		end
	end)
end

CollectionService:GetInstanceAddedSignal("HieloCriogenia"):Connect(decorarHielo)
for _, inst in CollectionService:GetTagged("HieloCriogenia") do
	decorarHielo(inst)
end

-- Decora MuroFuego con grietas incandescentes y cuñas volcánicas al brotar.
local function decorarMuroFuego(parte: Instance)
	if not parte:IsA("BasePart") then
		return
	end
	local basePos = parte.Position - Vector3.new(0, parte.Size.Y * 0.45, 0)
	EfectosGolpe.grieta(basePos, math.max(parte.Size.X * 0.6, 8), 1.4, Color3.fromHex("#161218"))
	EfectosGolpe.fragmentos3D(
		basePos + Vector3.new(0, 0.8, 0),
		7,
		FUEGO,
		Vector3.new(0.8, 1.8, 0.9),
		18,
		Enum.Material.Slate,
		true
	)
end

CollectionService:GetInstanceAddedSignal("MuroFuego"):Connect(decorarMuroFuego)
for _, inst in CollectionService:GetTagged("MuroFuego") do
	decorarMuroFuego(inst)
end

-- Beam de 3 capas (tinta cómic oscura + primario Linaje + núcleo Hueso, LightEmission <= 0.68).
local function trazarHaz(
	soporte: Instance,
	nodos: { Vector3 },
	color: Color3,
	grosor: number,
	haces: { Beam }
)
	local nucleo, tintaLinaje = EfectosGolpe.coloresCapa(color)
	local adjuntos: { Attachment } = {}
	for i, pos in nodos do
		local att = Instance.new("Attachment")
		att.WorldPosition = pos
		att.Parent = soporte
		adjuntos[i] = att
	end
	for i = 1, #adjuntos - 1 do
		for capa = 1, 3 do
			local b = Instance.new("Beam")
			b.Texture = EB.RayoTira
			b.TextureSpeed = if capa == 1 then 4 elseif capa == 2 then 6 else 9
			b.TextureLength = 5
			b.FaceCamera = true
			b.LightEmission = if capa == 1 then 0 elseif capa == 2 then 0.68 else 0.58
			b.LightInfluence = 0
			b.Color = ColorSequence.new(
				if capa == 1 then tintaLinaje elseif capa == 2 then color else nucleo
			)
			b.Width0 = (if capa == 1 then 2.8 elseif capa == 2 then 2.1 else 0.72) * grosor
			b.Width1 = (if capa == 1 then 2.0 elseif capa == 2 then 1.5 else 0.48) * grosor
			b.Transparency =
				NumberSequence.new(if capa == 1 then 0.18 elseif capa == 2 then 0.06 else 0)
			b.Attachment0 = adjuntos[i]
			b.Attachment1 = adjuntos[i + 1]
			b.Parent = soporte
			table.insert(haces, b)
		end
	end
end

-- Arcos quebrados en articulaciones que cambian de vértice cada 2 frames (GUIA-ESTILO §3.3 Electro).
local PARES_ARCO = {
	{ "UpperTorso", "RightHand" },
	{ "UpperTorso", "LeftHand" },
	{ "UpperTorso", "RightFoot" },
	{ "UpperTorso", "LeftFoot" },
}

local function arcoCuerpo(personaje: Model, dura: number)
	local r = raizDe(personaje)
	if not r then
		return
	end
	local soporte = parteBrillo(
		CFrame.new(r.Position),
		Vector3.one * 0.2,
		ELECTRO,
		Enum.Material.SmoothPlastic,
		1
	)
	local tramos: { { a: BasePart, b: BasePart, a0: Attachment, mid: Attachment, a1: Attachment } } =
		{}

	for _, par in PARES_ARCO do
		local pa = personaje:FindFirstChild(par[1])
		local pb = personaje:FindFirstChild(par[2])
		if pa and pa:IsA("BasePart") and pb and pb:IsA("BasePart") then
			local a0 = Instance.new("Attachment")
			a0.WorldPosition = pa.Position
			a0.Parent = soporte
			local mid = Instance.new("Attachment")
			mid.WorldPosition = pa.Position:Lerp(pb.Position, 0.5)
			mid.Parent = soporte
			local a1 = Instance.new("Attachment")
			a1.WorldPosition = pb.Position
			a1.Parent = soporte
			table.insert(tramos, { a = pa, b = pb, a0 = a0, mid = mid, a1 = a1 })

			for _, parAtt in { { a0, mid }, { mid, a1 } } do
				local haz = Instance.new("Beam")
				haz.Attachment0 = parAtt[1]
				haz.Attachment1 = parAtt[2]
				haz.Texture = EB.RayoTira
				haz.TextureLength = 3
				haz.TextureSpeed = 8
				haz.FaceCamera = true
				haz.LightEmission = 0.68
				haz.LightInfluence = 0
				haz.Color = ColorSequence.new(HUESO, ELECTRO)
				haz.Width0 = 0.85
				haz.Width1 = 0.55
				haz.Parent = soporte
			end
		end
	end

	task.spawn(function()
		local fin = os.clock() + dura
		while os.clock() < fin and soporte.Parent do
			for _, tr in tramos do
				if tr.a.Parent and tr.b.Parent then
					tr.a0.WorldPosition = tr.a.Position
					tr.a1.WorldPosition = tr.b.Position
					tr.mid.WorldPosition = tr.a.Position:Lerp(tr.b.Position, 0.5)
						+ Vector3.new(
							(math.random() - 0.5) * 1.5,
							(math.random() - 0.5) * 1.5,
							(math.random() - 0.5) * 1.5
						)
				end
			end
			task.wait(0.04) -- 2 frames a 60fps
		end
	end)
	Debris:AddItem(soporte, dura + 0.06)
end

-- Anillos concéntricos con muescas rotando en 3 ejes (GUIA-ESTILO §3.3 Telequinesis).
local function anillosOrbitando(centroCf: CFrame, radio: number, dura: number, color: Color3)
	for i = 1, 3 do
		local incl = centroCf
			* CFrame.Angles(math.rad(i * 52 - 40), math.rad(i * 35), math.rad(i * 28))
		local r = radio * (0.72 + i * 0.18)
		EfectosGolpe.runa3D(incl, r * 0.75, r * 1.15, color, dura, EB.AnilloTelequinesis)
	end
end

-- Piedras poligonales levitando + espiral de viento en carga (GUIA-ESTILO §3.3 FuerzaBruta / Piroquinesis).
local function espiralCarga(r: BasePart, color: Color3, dura: number)
	local base = piso(r)
	local _, tintaLinaje = EfectosGolpe.coloresCapa(color)
	local grupo = Instance.new("Model")
	grupo.Name = "PiedrasCarga"
	local hl = Instance.new("Highlight")
	hl.FillTransparency = 1
	hl.OutlineColor = tintaLinaje
	hl.OutlineTransparency = 0.15
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Parent = grupo
	grupo.Parent = workspace

	for i = 1, 6 do
		local ang = (i / 6) * math.pi * 2
		local dist = 2.4 + (i % 2) * 1.1
		local iniPos = base + Vector3.new(math.cos(ang) * dist, 0.2, math.sin(ang) * dist)
		local p = Instance.new("WedgePart")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Material = Enum.Material.Slate
		p.Color = if i % 2 == 0 then ESCOMBRO:Lerp(color, 0.35) else ESCOMBRO
		p.Size = Vector3.new(0.42, 0.55, 0.65)
		p.CFrame = CFrame.new(iniPos) * CFrame.Angles(i, ang, i * 0.7)
		p.Parent = grupo
		TweenService
			:Create(p, TweenInfo.new(dura, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(iniPos + Vector3.new(0, 2.8 + (i % 3) * 0.6, 0))
					* CFrame.Angles(i + 3, ang + 2, i),
				Transparency = 0.85,
			})
			:Play()
	end
	EfectosGolpe.anillo3D(CFrame.new(base + Vector3.new(0, 0.6, 0)), 4.6, 1.4, color, dura, 0.18)
	Debris:AddItem(grupo, dura + 0.08)
end

-- Beam eléctrico fractal multicapa + bifurcaciones secundarias + corona RelampagoArco.
local function rayoSegmentos(
	puntos: { Vector3 },
	color: Color3,
	dura: number?,
	marcarImpactos: boolean?
)
	if #puntos < 2 then
		return
	end
	local t = dura or 0.28
	local nodos = { puntos[1] }
	local ramas: { { Vector3 } } = {}
	for i = 1, #puntos - 1 do
		local a, b = puntos[i], puntos[i + 1]
		local largo = (b - a).Magnitude
		local pasos = if largo > 10 then 4 elseif largo > 4 then 2 else 1
		for p = 1, pasos - 1 do
			local frac = p / pasos
			local escalaJitter = math.clamp(largo * 0.14, 0.7, 2.4)
			local puntoMedio = a:Lerp(b, frac)
				+ Vector3.new(
					(math.random() * 2 - 1) * escalaJitter,
					(math.random() * 1.4 - 0.5) * escalaJitter,
					(math.random() * 2 - 1) * escalaJitter
				)
			table.insert(nodos, puntoMedio)
			if p == math.ceil(pasos * 0.5) and largo > 5 then
				local desvio = Vector3.new(
					(math.random() * 2 - 1) * 4.2,
					(math.random() - 0.3) * 3.0,
					(math.random() * 2 - 1) * 4.2
				)
				table.insert(ramas, { puntoMedio, puntoMedio + desvio })
			end
		end
		table.insert(nodos, b)
	end
	local soporte =
		parteBrillo(CFrame.new(puntos[1]), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	local haces: { Beam } = {}
	trazarHaz(soporte, nodos, color, 1, haces)
	for _, rama in ramas do
		trazarHaz(soporte, rama, color, 0.5, haces)
	end
	local toca = marcarImpactos ~= false
	for i = 2, #puntos do
		EfectosGolpe.luz(puntos[i], color, 6, 20, t)
		if toca and (i < #puntos or #puntos > 2) then
			EfectosGolpe.reproducir(puntos[i], false, color, 0.78)
			EfectosGolpe.runa3D(
				CFrame.new(puntos[i]) * CFrame.Angles(math.pi / 2, math.random() * 3, 0),
				1.6,
				4.8,
				color,
				0.26,
				EB.RelampagoArco
			)
		elseif not toca and i == #puntos then
			emitirSprite(soporte, EB.RelampagoArco, color, 1.8, 4, 0.22, 6)
		end
	end
	task.delay(t * 0.5, function()
		for _, h in haces do
			if h.Parent then
				h.Transparency = NumberSequence.new(0.68)
			end
		end
	end)
	Debris:AddItem(soporte, t + 0.08)
end

local proyectiles: { [string]: { { caja: Model, fin: number } } } = {}

local function lanzarProyectil(
	tipo: string,
	pos: Vector3,
	frente: Vector3,
	alcance: number,
	velocidad: number
)
	local dura = math.max(alcance / math.max(velocidad, 1), 0.08)
	local dir = if frente.Magnitude > 0.01 then frente.Unit else Vector3.zAxis
	local orient = CFrame.lookAt(pos, pos + dir)
	local caja = Instance.new("Model")
	caja.Name = "Proy_" .. tipo
	if tipo == "LanzaHielo" then
		local nucleoCrio, tintaCrio = EfectosGolpe.coloresCapa(CRIO)
		local hl = Instance.new("Highlight")
		hl.FillTransparency = 1
		hl.OutlineColor = tintaCrio
		hl.OutlineTransparency = 0.15
		hl.DepthMode = Enum.HighlightDepthMode.Occluded
		hl.Parent = caja

		local punta =
			parteBrillo(orient, Vector3.new(0.55, 0.55, 4.4), CRIO, Enum.Material.Ice, 0.08)
		local nucleo =
			parteBrillo(orient, Vector3.new(0.22, 0.22, 3.9), nucleoCrio, Enum.Material.Neon, 0.04)
		punta.Parent = caja
		nucleo.Parent = caja
		local piezas: { BasePart } = { punta, nucleo }

		-- 4 púas prismáticas inclinadas hacia atrás (gemini/anim-linaje-criogenia/habilidades.png)
		for i = 1, 4 do
			local ang = (i - 1) * (math.pi * 0.5) + math.pi * 0.25
			local barb = Instance.new("WedgePart")
			barb.Anchored = true
			barb.CanCollide = false
			barb.CanQuery = false
			barb.CanTouch = false
			barb.CastShadow = false
			barb.Material = Enum.Material.Ice
			barb.Color = CRIO:Lerp(nucleoCrio, 0.35)
			barb.Transparency = 0.12
			barb.Size = Vector3.new(0.28, 0.65, 1.8)
			barb.CFrame = orient
				* CFrame.Angles(0, 0, ang)
				* CFrame.new(0, 0.36, 0.65)
				* CFrame.Angles(math.rad(-18), 0, 0)
			barb.Parent = caja
			table.insert(piezas, barb)
		end

		estelaParte(punta, CRIO, 1.5, 0.26)
		emitirSprite(punta, EB.HieloEscarcha, CRIO, 1.6, 8, 0.34, 8)
		caja.PrimaryPart = punta
		caja.Parent = workspace
		for _, p in piezas do
			TweenService:Create(p, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
				CFrame = p.CFrame + dir * alcance,
			}):Play()
		end
	else
		local _, tintaTele = EfectosGolpe.coloresCapa(TELE)
		local pesado = tipo == "LanzarPesado"
		local tam = if pesado then Vector3.new(2.5, 2.2, 2.5) else Vector3.new(1.5, 1.35, 1.5)
		local roca = parteBrillo(orient, tam, ESCOMBRO, Enum.Material.Slate, 0)
		roca.Parent = caja
		local halo = Instance.new("Highlight")
		halo.Adornee = caja
		halo.FillColor = TELE
		halo.FillTransparency = 0.62
		halo.OutlineColor = tintaTele
		halo.OutlineTransparency = 0.12
		halo.Parent = caja
		local satelites: { BasePart } = {}
		for i = 1, 3 do
			local ang = (i / 3) * math.pi * 2
			local off = Vector3.new(math.cos(ang) * 1.4, math.sin(ang) * 0.9, (i - 2) * 0.4)
			local sPart = Instance.new("WedgePart")
			sPart.Anchored = true
			sPart.CanCollide = false
			sPart.CanQuery = false
			sPart.CanTouch = false
			sPart.Material = Enum.Material.Slate
			sPart.Color = ESCOMBRO:Lerp(TELE, 0.35)
			sPart.Size = tam * 0.42
			sPart.CFrame = orient * CFrame.new(off)
			sPart.Parent = caja
			table.insert(satelites, sPart)
		end
		estelaParte(roca, TELE, if pesado then 2.8 else 1.8, 0.28)
		emitirSprite(roca, EB.AnilloTelequinesis, TELE, if pesado then 3.4 else 2.4, 6, 0.35, 5)
		caja.PrimaryPart = roca
		caja.Parent = workspace
		local finPos = pos + dir * alcance
		TweenService:Create(roca, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(finPos) * CFrame.Angles(4, 6, 3),
		}):Play()
		for i, sp in satelites do
			local ang = (i / 3) * math.pi * 2 + math.pi
			local off = Vector3.new(math.cos(ang) * 1.3, math.sin(ang) * 0.85, (2 - i) * 0.4)
			TweenService:Create(sp, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(finPos + off) * CFrame.Angles(-5, 3, 2),
			}):Play()
		end
	end
	local lista = proyectiles[tipo] or {}
	proyectiles[tipo] = lista
	table.insert(lista, { caja = caja, fin = os.clock() + dura })
	Debris:AddItem(caja, dura + 0.12)
end

local function chocarProyectil(tipo: string, pos: Vector3)
	local lista = proyectiles[tipo]
	if lista and lista[1] then
		local item = table.remove(lista, 1)
		if item and item.caja.Parent then
			item.caja:Destroy()
		end
	end
	if tipo == "LanzaHielo" then
		EfectosGolpe.reproducir(pos, true, CRIO, 1.05)
		EfectosGolpe.runa3D(
			CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0),
			1.5,
			6.0,
			CRIO,
			0.32,
			EB.CristalHielo
		)
		EfectosGolpe.fragmentos3D(
			pos,
			8,
			CRIO,
			Vector3.new(0.45, 1.25, 0.45),
			24,
			Enum.Material.Ice,
			true
		)
		local s =
			parteBrillo(CFrame.new(pos), Vector3.one * 0.2, CRIO, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 2.0, 14, 0.44, 18)
		Debris:AddItem(s, 0.55)
	else
		local pesado = tipo == "LanzarPesado"
		local sc = if pesado then 1.4 else 1.1
		EfectosGolpe.reproducir(pos, true, TELE, sc)
		anillosOrbitando(CFrame.new(pos), 3.6 * sc, 0.34, TELE)
		escombros(
			pos,
			if pesado then 12 else 7,
			if pesado then 36 else 24,
			Color3.fromHex("#1E132B")
		)
		local s =
			parteBrillo(CFrame.new(pos), Vector3.one * 0.2, TELE, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.AnilloTelequinesis, TELE, if pesado then 4.5 else 3.2, 6, 0.36, 8)
		Debris:AddItem(s, 0.5)
	end
end

local function mostrarCongelado(objetivo: Model, dura: number)
	local r = raizDe(objetivo)
	if not r then
		return
	end
	local nucleoCrio, tintaCrio = EfectosGolpe.coloresCapa(CRIO)
	local auraHielo = Instance.new("Highlight")
	auraHielo.FillColor = CRIO
	auraHielo.FillTransparency = 0.4
	auraHielo.OutlineColor = nucleoCrio
	auraHielo.Parent = objetivo
	Debris:AddItem(auraHielo, dura)

	local bloque = Instance.new("Model")
	bloque.Name = "HieloEncierro"
	local ink = Instance.new("Highlight")
	ink.FillTransparency = 1
	ink.OutlineColor = tintaCrio
	ink.OutlineTransparency = 0.15
	ink.Parent = bloque
	for i = 1, 6 do
		local ang = (i / 6) * math.pi * 2
		local p = Instance.new("WedgePart")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Material = Enum.Material.Ice
		p.Color = if i % 2 == 0 then CRIO:Lerp(nucleoCrio, 0.35) else CRIO
		p.Transparency = 0.26
		p.Size = Vector3.new(2.0, 5.2, 2.0)
		p.CFrame = r.CFrame * CFrame.Angles(0, ang, math.rad(16))
		p.Parent = bloque
	end
	bloque.Parent = workspace
	emitirSprite(r, EB.CristalHielo, CRIO, 2.6, 12, 0.48, 16)
	EfectosGolpe.runa3D(
		CFrame.new(piso(r) + Vector3.new(0, 0.15, 0)),
		2.2,
		8.2,
		CRIO,
		0.45,
		EB.CristalHielo
	)
	EfectosGolpe.onda(piso(r), 8, CRIO)
	Debris:AddItem(bloque, dura)
	task.delay(dura, function()
		if r.Parent then
			EfectosGolpe.fragmentos3D(
				r.Position,
				8,
				CRIO,
				Vector3.new(0.5, 1.4, 0.5),
				22,
				Enum.Material.Ice,
				true
			)
		end
	end)
end

local function mostrarLevitar(objetivo: Model, dura: number)
	local r = raizDe(objetivo)
	if not r then
		return
	end
	aura(objetivo, TELE, dura)
	anillosOrbitando(r.CFrame, 4.2, dura, TELE)

	local soporte =
		parteBrillo(CFrame.new(r.Position), Vector3.one * 0.2, TELE, Enum.Material.SmoothPlastic, 1)
	local topAtt = Instance.new("Attachment")
	topAtt.WorldPosition = r.Position + Vector3.new(0, 18, 0)
	topAtt.Parent = soporte
	local botAtt = Instance.new("Attachment")
	botAtt.WorldPosition = r.Position - Vector3.new(0, 2, 0)
	botAtt.Parent = soporte
	local haz = Instance.new("Beam")
	haz.Attachment0 = topAtt
	haz.Attachment1 = botAtt
	haz.FaceCamera = true
	haz.LightEmission = 0.65
	haz.Width0 = 3.2
	haz.Width1 = 5.4
	haz.Color = ColorSequence.new(TELE, HUESO)
	haz.Transparency = NumberSequence.new(0.45)
	haz.Parent = soporte
	Debris:AddItem(soporte, dura + 0.08)

	local anilloP = parteBrillo(
		CFrame.new(r.Position - Vector3.new(0, 2.2, 0)),
		Vector3.new(7.4, 0.08, 7.4),
		TELE,
		Enum.Material.SmoothPlastic,
		1
	)
	local dec = Instance.new("Decal")
	dec.Face = Enum.NormalId.Top
	dec.Texture = EB.AnilloTelequinesis
	dec.Color3 = TELE
	dec.Parent = anilloP
	TweenService:Create(
		anilloP,
		TweenInfo.new(dura, Enum.EasingStyle.Linear),
		{ CFrame = anilloP.CFrame * CFrame.Angles(0, math.pi * 4, 0) }
	):Play()
	Debris:AddItem(anilloP, dura + 0.05)
	task.delay(dura, function()
		if r.Parent then
			local base = piso(r)
			EfectosGolpe.onda(base, 11, TELE)
			EfectosGolpe.runa3D(
				CFrame.new(base + Vector3.new(0, 0.16, 0)),
				2.5,
				11,
				TELE,
				0.42,
				EB.RunaEclipse
			)
			escombros(base, 8, 28, Color3.fromHex("#1E132B"))
			EfectosGolpe.reproducir(base, true, TELE, 1.15)
		end
	end)
end

local function pisoSello(r: BasePart): CFrame
	return CFrame.new(piso(r) + Vector3.new(0, 0.16, 0))
end

local cargas: { [string]: (Model, BasePart, number) -> () } = {
	BolaFuego = function(p, _r, d)
		Fuego.carga(p, d)
	end,
	Chorro = function(p, r, d)
		Fuego.carga(p, d)
		espiralCarga(r, FUEGO, d)
		EfectosGolpe.runa3D(pisoSello(r), 5.6, 1.8, FUEGO, d, EB.AvisoSuelo)
	end,
	MuroFuego = function(_p, r, d)
		espiralCarga(r, FUEGO, d)
		EfectosGolpe.runa3D(
			pisoSello(r) * CFrame.new(0, 0, -Config.Efectos.Fuego.MuroDistancia),
			8.0,
			2.6,
			FUEGO,
			d,
			EB.AvisoSuelo
		)
	end,
	PunoSismico = function(p, r, d)
		aura(p, POLVO, d)
		espiralCarga(r, POLVO, d)
		EfectosGolpe.runa3D(pisoSello(r), 6.2, 1.6, POLVO, d, EB.AvisoSuelo)
	end,
	GolpePiso = function(p, r, d)
		aura(p, POLVO, d)
		espiralCarga(r, POLVO, d)
		EfectosGolpe.runa3D(pisoSello(r), 9.0, 2.2, POLVO, d, EB.AvisoSuelo)
	end,
	Embestida = function(p, r, d)
		aura(p, POLVO, d)
		espiralCarga(r, POLVO, d)
		EfectosGolpe.anillo3D(r.CFrame * CFrame.Angles(math.pi / 2, 0, 0), 4.5, 1.2, POLVO, d, 0.18)
	end,
	PasoFantasma = function(p, r, d)
		aura(p, REFLEJO, d)
		EfectosGolpe.runa3D(pisoSello(r), 5.4, 1.2, REFLEJO, d, EB.DestelloParry)
	end,
	LluviaGolpes = function(p, r, d)
		aura(p, REFLEJO, d)
		EfectosGolpe.anillo3D(r.CFrame, 4.8, 1.4, REFLEJO, d, 0.16)
	end,
	RayoCadena = function(p, r, d)
		aura(p, ELECTRO, d)
		arcoCuerpo(p, d + 0.25)
		EfectosGolpe.runa3D(pisoSello(r), 5.8, 1.8, ELECTRO, d, EB.RelampagoArco)
	end,
	Descarga = function(p, r, d)
		aura(p, ELECTRO, d)
		arcoCuerpo(p, d + 0.4)
		EfectosGolpe.runa3D(pisoSello(r), 9.5, 2.5, ELECTRO, d, EB.RelampagoArco)
	end,
	LanzaHielo = function(p, r, d)
		aura(p, CRIO, d)
		EfectosGolpe.runa3D(pisoSello(r), 5.0, 1.5, CRIO, d, EB.CristalHielo)
	end,
	MuroHielo = function(p, r, d)
		aura(p, CRIO, d)
		EfectosGolpe.runa3D(
			pisoSello(r) * CFrame.new(0, 0, -Config.Poderes.MuroHielo.Distancia),
			8.5,
			2.6,
			CRIO,
			d,
			EB.CristalHielo
		)
	end,
	PistaHelada = function(p, r, d)
		aura(p, CRIO, d)
		EfectosGolpe.runa3D(pisoSello(r), 6.0, 2.0, CRIO, d, EB.CristalHielo)
	end,
	Lanzar = function(p, r, d)
		aura(p, TELE, d)
		anillosOrbitando(r.CFrame * CFrame.new(0, 0.5, -2.0), 3.4, d, TELE)
	end,
	Levantar = function(p, r, d)
		aura(p, TELE, d)
		anillosOrbitando(r.CFrame, 4.2, d, TELE)
		EfectosGolpe.runa3D(pisoSello(r), 6.5, 2.0, TELE, d, EB.RunaEclipse)
	end,
	Onda = function(p, r, d)
		aura(p, TELE, d)
		anillosOrbitando(r.CFrame, 4.6, d, TELE)
		EfectosGolpe.runa3D(pisoSello(r), 7.5, 2.0, TELE, d, EB.RunaEclipse)
	end,
}

local efectos: { [string]: (Model, BasePart, any) -> () } = {
	PunoSismico = function(_p, r)
		local punto = piso(r) + r.CFrame.LookVector * 6.5
		anillo(punto, 11.5, POLVO)
		EfectosGolpe.impactoFuerza(
			r.CFrame * CFrame.new(0, 0.4, -3.5),
			2.5,
			9.5 * escalaActual,
			POLVO,
			0.32
		)
		EfectosGolpe.tajo(r.CFrame, 12, POLVO, escalaActual * 1.5, true)
		for paso = 1, 3 do
			local cf = r.CFrame * CFrame.new(0, 0.2, -3 * paso) * CFrame.Angles(math.pi / 2, 0, 0)
			task.delay((paso - 1) * 0.05, function()
				EfectosGolpe.anillo3D(
					cf,
					1.6 * escalaActual,
					(4.2 + paso * 1.4) * escalaActual,
					if paso == 2 then HUESO else POLVO,
					0.24,
					0.25
				)
			end)
		end
		escombros(punto, 12, 34)
		estallido(punto, POLVO, 38, 40)
		CamaraCombate.sacudir(1.05, r.CFrame.LookVector)
		CamaraCombate.zoom(-5.5)
	end,
	GolpePiso = function(_p, r)
		local base = piso(r)
		anillo(base, 14.5, POLVO)
		EfectosGolpe.runa3D(
			CFrame.new(base + Vector3.new(0, 0.16, 0)),
			3.2,
			15.5 * escalaActual,
			POLVO,
			0.48,
			EB.ImpactoFuerza
		)
		-- 8 pilares de roca angulosos con contorno tinta cómic (#2A1F17) que brotan en corona.
		local modelo = Instance.new("Model")
		modelo.Name = "PilaresSismicos"
		local tinta = Instance.new("Highlight")
		tinta.FillTransparency = 1
		tinta.OutlineColor = Color3.fromHex("#2A1F17")
		tinta.OutlineTransparency = 0.12
		tinta.DepthMode = Enum.HighlightDepthMode.Occluded
		tinta.Parent = modelo
		modelo.Parent = workspace
		for i = 1, 8 do
			local ang = (i / 8) * math.pi * 2
			local dist = if i % 2 == 0 then 5.2 else 3.8
			local cf = CFrame.new(
				base + Vector3.new(math.cos(ang) * dist, -1.7, math.sin(ang) * dist)
			) * CFrame.Angles(math.rad(-22), ang, 0)
			local pico = Instance.new("WedgePart")
			pico.Anchored = true
			pico.CanCollide = false
			pico.CanQuery = false
			pico.CanTouch = false
			pico.Material = Enum.Material.Slate
			pico.Color = if i % 2 == 0 then ESCOMBRO:Lerp(POLVO, 0.25) else ESCOMBRO
			pico.Size = Vector3.new(1.5, 4.6, 2.0) * escalaActual
			pico.CFrame = cf
			pico.Parent = modelo
			TweenService:Create(pico, TweenInfo.new(0.14, Enum.EasingStyle.Back), {
				CFrame = cf + Vector3.new(0, 2.5, 0),
			}):Play()
			task.delay(0.3, function()
				TweenService:Create(pico, TweenInfo.new(0.34), {
					CFrame = cf - Vector3.new(0, 1.5, 0),
					Transparency = 1,
				}):Play()
			end)
		end
		Debris:AddItem(modelo, 0.72)
		task.delay(0.08, function()
			anillo(base, 10, HUESO)
		end)
		escombros(base, 16, 42)
		estallido(base, POLVO, 42, 44)
		CamaraCombate.sacudir(1.45, Vector3.new(0, 1, 0))
		CamaraCombate.zoom(-7.5)
	end,
	Embestida = function(p, r)
		anillo(piso(r), 10, POLVO)
		EfectosGolpe.dash(p, r, r.CFrame.LookVector, POLVO)
		for paso = 0, 2 do
			task.delay(paso * 0.13, function()
				if p.Parent and r.Parent then
					EfectosGolpe.anillo3D(
						r.CFrame * CFrame.new(0, 0.4, -2) * CFrame.Angles(math.pi / 2, 0, 0),
						2.0,
						6.8 * escalaActual,
						if paso == 1 then HUESO else POLVO,
						0.25,
						0.28
					)
					EfectosGolpe.grieta(piso(r), 6.5, 1.1, Color3.fromHex("#2A1F17"))
					escombros(piso(r), 5, 22)
				end
			end)
		end
		estallido(r.Position, POLVO, 34, 36)
		CamaraCombate.zoom(6.5)
		CamaraCombate.sacudir(0.85, r.CFrame.LookVector)
	end,
	Contragolpe = function(p, r, d)
		aura(p, REFLEJO, d.Dura)
		EfectosGolpe.anillo3D(r.CFrame, 2.0, 5.8, REFLEJO, 0.3, 0.22)
		EfectosGolpe.runa3D(
			r.CFrame * CFrame.Angles(math.pi / 2, 0, 0),
			2.0,
			5.4,
			REFLEJO,
			0.35,
			EB.DestelloParry
		)
	end,
	PasoFantasma = function(p, r)
		local origen = r.Position
		fantasma(p, REFLEJO)
		EfectosGolpe.dash(p, r, r.CFrame.LookVector, REFLEJO)
		EfectosGolpe.tajo(r.CFrame, 35, REFLEJO, escalaActual * 1.35, true)
		EfectosGolpe.tajo(r.CFrame, -35, HUESO, escalaActual * 1.2, false)
		EfectosGolpe.anillo3D(
			r.CFrame * CFrame.Angles(math.pi / 2, 0, 0),
			1.8,
			7.8,
			REFLEJO,
			0.26,
			0.28
		)
		task.delay(0.11, function()
			if r.Parent then
				local destino = r.Position
				local soporte = parteBrillo(
					CFrame.new(origen),
					Vector3.one * 0.2,
					REFLEJO,
					Enum.Material.SmoothPlastic,
					1
				)
				local haces: { Beam } = {}
				trazarHaz(soporte, { origen, destino }, REFLEJO, 0.85, haces)
				Debris:AddItem(soporte, 0.28)
				EfectosGolpe.impactoFuerza(r.CFrame, 1.8, 6.2, REFLEJO, 0.24)
			end
		end)
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
				local ang = if i % 2 == 0 then 38 else -38
				local ultimo = i == d.Golpes
				EfectosGolpe.tajo(
					r.CFrame,
					ang + math.random(-14, 14),
					if ultimo then HUESO else REFLEJO,
					escalaActual * (if ultimo then 1.45 else 1.15),
					ultimo
				)
				if ultimo then
					EfectosGolpe.impactoFuerza(
						r.CFrame * CFrame.new(0, 0.2, -3.5),
						2.0,
						7.5,
						REFLEJO,
						0.28
					)
				end
				estallido(r.Position + r.CFrame.LookVector * 5, REFLEJO, 14, 28)
				task.wait(1 / d.Golpes)
			end
		end)
	end,
	Chorro = function(p, r, d)
		Fuego.chorro(r, d.Dura, escalaActual)
		EfectosGolpe.runa3D(
			r.CFrame * CFrame.new(0, 0.3, -2.5) * CFrame.Angles(math.pi / 2, 0, 0),
			2.2,
			6.8,
			FUEGO,
			0.35,
			EB.OndaChoque
		)
		task.spawn(function()
			for paso = 1, 4 do
				task.wait(d.Dura / 4)
				if p.Parent and r.Parent then
					EfectosGolpe.anillo3D(
						r.CFrame
							* CFrame.new(0, 0.3, -4 - paso * 1.4)
							* CFrame.Angles(math.pi / 2, 0, 0),
						1.8,
						6.2 * escalaActual,
						FUEGO,
						0.22,
						0.24
					)
				end
			end
		end)
		CamaraCombate.sacudir(0.6, r.CFrame.LookVector)
	end,
	Descarga = function(p, r)
		local centro = r.Position
		local suelo = piso(r)
		arcoCuerpo(p, 0.55)
		anillo(suelo, 12, ELECTRO)
		EfectosGolpe.runa3D(
			CFrame.new(suelo + Vector3.new(0, 0.16, 0)),
			2.6,
			14 * escalaActual,
			ELECTRO,
			0.45,
			EB.RelampagoArco
		)
		-- Domo eléctrico 3D con contorno de tinta #101B2E (gemini/anim-linaje-electro/habilidades.png)
		local domo = parteBrillo(
			CFrame.new(centro),
			Vector3.one * 3.5,
			ELECTRO,
			Enum.Material.ForceField,
			0.25
		)
		domo.Shape = Enum.PartType.Ball
		TweenService:Create(domo, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {
			Size = Vector3.one * (16 * escalaActual),
			Transparency = 1,
		}):Play()
		Debris:AddItem(domo, 0.36)

		EfectosGolpe.reproducir(centro, true, ELECTRO, escalaActual * 1.15)
		-- Pilar de rayo cayendo del cielo + 6 descargas radiales con bifurcaciones.
		rayoSegmentos({ centro + Vector3.new(0, 26, 0), centro }, ELECTRO, 0.34, true)
		for i = 1, 6 do
			local ang = (i / 6) * math.pi * 2 + 0.25
			local punta = suelo + Vector3.new(math.cos(ang) * 10.5, 0.3, math.sin(ang) * 10.5)
			rayoSegmentos({ centro, punta }, ELECTRO, 0.28, true)
		end
		CamaraCombate.sacudir(1.15, Vector3.new(0, 1, 0))
	end,
	SaltoCable = function(p, r)
		local origen = r.Position
		arcoCuerpo(p, 0.45)
		fantasma(p, ELECTRO)
		EfectosGolpe.dash(p, r, r.CFrame.LookVector, ELECTRO)
		EfectosGolpe.runa3D(
			CFrame.new(piso(r) + Vector3.new(0, 0.16, 0)),
			2.0,
			8.5,
			ELECTRO,
			0.32,
			EB.RelampagoArco
		)
		EfectosGolpe.anillo3D(
			r.CFrame * CFrame.Angles(math.pi / 2, 0, 0),
			1.6,
			7.4,
			ELECTRO,
			0.24,
			0.26
		)
		task.delay(0.14, function()
			if r.Parent then
				rayoSegmentos({ origen, r.Position }, ELECTRO, 0.28, true)
			end
		end)
		CamaraCombate.zoom(6.5)
	end,
	LanzaHielo = function(_p, r)
		EfectosGolpe.runa3D(
			r.CFrame * CFrame.new(0, 0.4, -2.6) * CFrame.Angles(math.pi / 2, 0, 0),
			1.5,
			5.4,
			CRIO,
			0.28,
			EB.CristalHielo
		)
		EfectosGolpe.luz(r.Position + r.CFrame.LookVector * 2.5, CRIO, 4.5, 16, 0.24)
	end,
	MuroHielo = function(_p, r)
		local frente = piso(r) + r.CFrame.LookVector * Config.Poderes.MuroHielo.Distancia
		anillo(frente, 11.5, CRIO)
		EfectosGolpe.runa3D(
			CFrame.new(frente + Vector3.new(0, 0.16, 0)),
			2.6,
			11 * escalaActual,
			CRIO,
			0.42,
			EB.CristalHielo
		)
		local s = parteBrillo(
			CFrame.new(frente + Vector3.new(0, 1, 0)),
			Vector3.one * 0.2,
			CRIO,
			Enum.Material.SmoothPlastic,
			1
		)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 2.4, 20, 0.55, 18)
		EfectosGolpe.luz(frente, CRIO, 6, 24, 0.4)
		Debris:AddItem(s, 0.7)
		CamaraCombate.sacudir(0.8, Vector3.new(0, 1, 0))
	end,
	PistaHelada = function(p, r, d)
		local frente = r.CFrame.LookVector
		local centro = piso(r) + frente * (d.Alcance * 0.5)
		fantasma(p, CRIO)
		anillo(centro, 11, CRIO)
		for paso = 1, 3 do
			task.delay((paso - 1) * 0.08, function()
				local pos = piso(r) + frente * (d.Alcance * (paso / 3.2))
				EfectosGolpe.runa3D(
					CFrame.new(pos + Vector3.new(0, 0.14, 0)),
					1.8,
					6.4,
					CRIO,
					0.36,
					EB.CristalHielo
				)
				EfectosGolpe.fragmentos3D(
					pos + Vector3.new(0, 0.5, 0),
					4,
					CRIO,
					Vector3.new(0.3, 0.85, 0.35),
					16,
					Enum.Material.Ice,
					true
				)
			end)
		end
		local s =
			parteBrillo(CFrame.new(centro), Vector3.one * 0.2, CRIO, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 2.2, 20, 0.55, 20)
		EfectosGolpe.luz(centro, CRIO, 5, 22, 0.4)
		Debris:AddItem(s, 0.75)
	end,
	Lanzar = function(_p, r)
		anillosOrbitando(r.CFrame * CFrame.new(0, 0.5, -2.5), 3.6, 0.3, TELE)
	end,
	LanzarPesado = function(_p, r)
		anillosOrbitando(r.CFrame * CFrame.new(0, 0.5, -2.5), 4.8, 0.35, TELE)
	end,
	Levantar = function(_p, r)
		anillosOrbitando(r.CFrame * CFrame.new(0, 0.4, -3), 4.4, 0.38, TELE)
	end,
	Onda = function(_p, r)
		anillo(piso(r) + r.CFrame.LookVector * 4, 13.5, TELE)
		EfectosGolpe.tajo(r.CFrame, 0, TELE, escalaActual * 1.55, true)
		anillosOrbitando(r.CFrame * CFrame.new(0, 0.3, -2.5), 4.2, 0.36, TELE)
		for paso = 1, 3 do
			task.delay((paso - 1) * 0.05, function()
				local cfPaso = r.CFrame
					* CFrame.new(0, 0.3, -3.5 - paso * 3.0)
					* CFrame.Angles(math.pi / 2, 0, 0)
				EfectosGolpe.runa3D(
					cfPaso,
					2.0 + paso * 0.6,
					(6.5 + paso * 2.2) * escalaActual,
					if paso == 2 then HUESO else TELE,
					0.28,
					EB.AnilloTelequinesis
				)
				EfectosGolpe.anillo3D(
					cfPaso,
					2.2,
					(7 + paso * 2.2) * escalaActual,
					if paso == 2 then HUESO else TELE,
					0.26,
					0.26
				)
			end)
		end
		EfectosGolpe.fragmentos3D(
			r.Position + r.CFrame.LookVector * 4,
			8,
			TELE,
			Vector3.new(0.45, 0.95, 0.65),
			26,
			Enum.Material.Slate,
			true
		)
		local s = parteBrillo(
			CFrame.new(r.Position + r.CFrame.LookVector * 3),
			Vector3.one * 0.2,
			TELE,
			Enum.Material.SmoothPlastic,
			1
		)
		emitirSprite(s, EB.AnilloTelequinesis, TELE, 4.0, 8, 0.38, 15)
		Debris:AddItem(s, 0.5)
		CamaraCombate.sacudir(1.0, r.CFrame.LookVector)
		CamaraCombate.zoom(-5.5)
	end,
}

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any, c: any, d: any, e: any)
	if tipo == "Efecto" then
		local datos = b
		local hacer = efectos[datos.Accion]
		local r = raizDe(a)
		if hacer and r then
			escalaActual = Niveles.tamano(a)
			hacer(a, r, datos)
		end
	elseif tipo == "Carga" then
		local datos = b
		local fn = datos and cargas[datos.Accion]
		local r = if typeof(a) == "Instance" and a:IsA("Model") then raizDe(a) else nil
		if fn and r and typeof(datos.Impacto) == "number" then
			fn(a, r, math.max(datos.Impacto, 0.14))
		end
	elseif tipo == "Explota" then
		Fuego.explosion(a, b)
		-- SONIDO: explosión de fuego
	elseif tipo == "Rayo" and typeof(a) == "table" then
		rayoSegmentos(a, ELECTRO, nil, b ~= false)
	elseif tipo == "Congelado" and typeof(a) == "Instance" and a:IsA("Model") then
		mostrarCongelado(a, if typeof(b) == "number" then b else 1.5)
	elseif
		tipo == "Proyectil"
		and typeof(a) == "string"
		and typeof(b) == "Vector3"
		and typeof(c) == "Vector3"
	then
		lanzarProyectil(
			a,
			b,
			c,
			if typeof(d) == "number" then d else 30,
			if typeof(e) == "number" then e else 90
		)
	elseif tipo == "Choca" and typeof(a) == "string" and typeof(b) == "Vector3" then
		chocarProyectil(a, b)
	elseif tipo == "Levitar" and typeof(a) == "Instance" and a:IsA("Model") then
		mostrarLevitar(a, if typeof(b) == "number" then b else 2)
	end
end)

-- Subir de nivel y Despertar de Linaje: columna cómic del Eclipse.
local jugador = Players.LocalPlayer
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
		EfectosGolpe.columnaDespertar(piso(r), dorado, 0.85)
	end
	nivelVisto = nivel
end)

local linajeVisto = jugador:GetAttribute("Linaje")
local secuenciaDespertar = 0
jugador:GetAttributeChangedSignal("Linaje"):Connect(function()
	local nuevo = jugador:GetAttribute("Linaje")
	if typeof(nuevo) ~= "string" or nuevo == "" or nuevo == linajeVisto then
		linajeVisto = nuevo
		return
	end
	linajeVisto = nuevo
	secuenciaDespertar += 1
	local turno = secuenciaDespertar
	local color = (P.Colores :: any)[nuevo] or HUESO
	task.spawn(function()
		local limite = os.clock() + 3.0
		while jugador:GetAttribute("MenuAbierto") == true and os.clock() < limite do
			task.wait(0.08)
		end
		if turno ~= secuenciaDespertar then
			return
		end
		local personaje = jugador.Character
		local r = personaje and raizDe(personaje)
		if personaje and r then
			EfectosGolpe.columnaDespertar(piso(r), color, Niveles.tamano(personaje))
			aura(personaje, color, 1.3)
			CamaraCombate.zoom(-5)
		end
	end)
end)
