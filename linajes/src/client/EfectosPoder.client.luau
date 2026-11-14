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
local EB = Config.Efectos.Beta
local POLVO = P.Colores.FuerzaBruta
local REFLEJO = P.Colores.Reflejos
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
	local e = Instance.new("ParticleEmitter")
	e.Texture = textura
	e.Color = ColorSequence.new(HUESO, color)
	e.LightEmission = 0.9
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

-- Beam eléctrico bicapa (núcleo Hueso + halo Electro) con un quiebre orgánico por tramo.
local function rayoSegmentos(puntos: { Vector3 }, color: Color3, dura: number?)
	if #puntos < 2 then
		return
	end
	local t = dura or 0.24
	local nodos = { puntos[1] }
	for i = 1, #puntos - 1 do
		local a, b = puntos[i], puntos[i + 1]
		local largo = (b - a).Magnitude
		if largo > 4 then
			local medio = (a + b) * 0.5
				+ Vector3.new(
					math.random(-14, 14) / 10,
					math.random(-6, 10) / 10,
					math.random(-14, 14) / 10
				)
			table.insert(nodos, medio)
		end
		table.insert(nodos, b)
	end
	local soporte =
		parteBrillo(CFrame.new(puntos[1]), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	local adjuntos: { Attachment } = {}
	for i, pos in nodos do
		local att = Instance.new("Attachment")
		att.WorldPosition = pos
		att.Parent = soporte
		adjuntos[i] = att
	end
	local haces: { Beam } = {}
	for i = 1, #adjuntos - 1 do
		for capa = 1, 2 do
			local b = Instance.new("Beam")
			b.Texture = EB.RayoTira
			b.TextureSpeed = if capa == 1 then 4 else 6
			b.TextureLength = 6
			b.FaceCamera = true
			b.LightEmission = 1
			b.LightInfluence = 0
			b.Color = ColorSequence.new(if capa == 1 then color else HUESO)
			b.Width0 = if capa == 1 then 2.4 else 0.7
			b.Width1 = if capa == 1 then 1.8 else 0.5
			b.Transparency = NumberSequence.new(if capa == 1 then 0.1 else 0)
			b.Attachment0 = adjuntos[i]
			b.Attachment1 = adjuntos[i + 1]
			b.Parent = soporte
			table.insert(haces, b)
		end
	end
	for i = 2, #puntos do
		EfectosGolpe.luz(puntos[i], color, 5.5, 18, t)
		if i < #puntos or #puntos > 2 then
			EfectosGolpe.reproducir(puntos[i], false, color, 0.72)
		end
	end
	task.delay(t * 0.55, function()
		for _, h in haces do
			if h.Parent then
				h.Transparency = NumberSequence.new(0.65)
			end
		end
	end)
	Debris:AddItem(soporte, t + 0.06)
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
		local punta =
			parteBrillo(orient, Vector3.new(0.45, 0.45, 3.6), CRIO, Enum.Material.Ice, 0.12)
		local nucleo =
			parteBrillo(orient, Vector3.new(0.18, 0.18, 3.2), HUESO, Enum.Material.Neon, 0.05)
		punta.Parent = caja
		nucleo.Parent = caja
		emitirSprite(punta, EB.HieloEscarcha, CRIO, 1.3, 8, 0.3, 6)
		caja.PrimaryPart = punta
		caja.Parent = workspace
		TweenService:Create(punta, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
			CFrame = orient + dir * alcance,
		}):Play()
		TweenService:Create(nucleo, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
			CFrame = orient + dir * alcance,
		}):Play()
	else
		local pesado = tipo == "LanzarPesado"
		local tam = if pesado then Vector3.new(2.2, 1.9, 2.2) else Vector3.new(1.3, 1.15, 1.3)
		local roca = parteBrillo(orient, tam, ESCOMBRO, Enum.Material.Slate, 0)
		roca.Parent = caja
		local halo = Instance.new("Highlight")
		halo.Adornee = roca
		halo.FillColor = TELE
		halo.FillTransparency = 0.72
		halo.OutlineColor = TELE
		halo.Parent = roca
		emitirSprite(roca, EB.AnilloTelequinesis, TELE, if pesado then 3.2 else 2.2, 4, 0.35, 3)
		caja.PrimaryPart = roca
		caja.Parent = workspace
		TweenService:Create(roca, TweenInfo.new(dura, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(pos + dir * alcance) * CFrame.Angles(4, 6, 3),
		}):Play()
	end
	local lista = proyectiles[tipo] or {}
	proyectiles[tipo] = lista
	table.insert(lista, { caja = caja, fin = os.clock() + dura })
	Debris:AddItem(caja, dura + 0.1)
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
		EfectosGolpe.reproducir(pos, true, CRIO, 0.95)
		local s =
			parteBrillo(CFrame.new(pos), Vector3.one * 0.2, CRIO, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 1.8, 16, 0.42, 18)
		Debris:AddItem(s, 0.55)
	else
		local pesado = tipo == "LanzarPesado"
		EfectosGolpe.reproducir(pos, true, TELE, if pesado then 1.35 else 1.05)
		escombros(pos, if pesado then 10 else 6, if pesado then 34 else 24)
		local s =
			parteBrillo(CFrame.new(pos), Vector3.one * 0.2, TELE, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.AnilloTelequinesis, TELE, if pesado then 4.2 else 3.0, 5, 0.35, 6)
		Debris:AddItem(s, 0.5)
	end
end

local function mostrarCongelado(objetivo: Model, dura: number)
	local r = raizDe(objetivo)
	if not r then
		return
	end
	local auraHielo = Instance.new("Highlight")
	auraHielo.FillColor = CRIO
	auraHielo.FillTransparency = 0.45
	auraHielo.OutlineColor = HUESO
	auraHielo.Parent = objetivo
	Debris:AddItem(auraHielo, dura)

	local bloque = Instance.new("Model")
	bloque.Name = "HieloEncierro"
	for i = 1, 4 do
		local p = Instance.new("WedgePart")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Material = Enum.Material.Ice
		p.Color = CRIO
		p.Transparency = 0.32
		p.Size = Vector3.new(2.2, 4.6, 2.2)
		p.CFrame = r.CFrame * CFrame.Angles(0, (i / 4) * math.pi * 2, math.rad(14))
		p.Parent = bloque
	end
	bloque.Parent = workspace
	emitirSprite(r, EB.HieloEscarcha, CRIO, 2.2, 18, 0.45, 14)
	EfectosGolpe.onda(piso(r), 7, CRIO)
	Debris:AddItem(bloque, dura)
end

local function mostrarLevitar(objetivo: Model, dura: number)
	local r = raizDe(objetivo)
	if not r then
		return
	end
	aura(objetivo, TELE, dura)
	local anilloP = parteBrillo(
		CFrame.new(r.Position - Vector3.new(0, 2.2, 0)),
		Vector3.new(6.5, 0.08, 6.5),
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
			EfectosGolpe.onda(piso(r), 10, TELE)
			EfectosGolpe.reproducir(piso(r), true, TELE, 1.05)
		end
	end)
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
	Descarga = function(_p, r)
		local centro = r.Position
		anillo(piso(r), 10, ELECTRO)
		EfectosGolpe.reproducir(centro, true, ELECTRO, escalaActual)
		for i = 1, 4 do
			local ang = (i / 4) * math.pi * 2 + 0.35
			local punta = piso(r) + Vector3.new(math.cos(ang) * 9, 0.3, math.sin(ang) * 9)
			rayoSegmentos({ centro, punta }, ELECTRO, 0.25)
		end
		CamaraCombate.sacudir(1.05, Vector3.new(0, 1, 0))
	end,
	SaltoCable = function(p, r)
		fantasma(p, ELECTRO)
		EfectosGolpe.anillo3D(
			r.CFrame * CFrame.Angles(math.pi / 2, 0, 0),
			1.5,
			6.8,
			ELECTRO,
			0.22,
			0.24
		)
		CamaraCombate.zoom(6)
	end,
	MuroHielo = function(_p, r)
		local frente = piso(r) + r.CFrame.LookVector * Config.Poderes.MuroHielo.Distancia
		anillo(frente, 10, CRIO)
		local s = parteBrillo(
			CFrame.new(frente + Vector3.new(0, 1, 0)),
			Vector3.one * 0.2,
			CRIO,
			Enum.Material.SmoothPlastic,
			1
		)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 2.2, 22, 0.5, 18)
		EfectosGolpe.luz(frente, CRIO, 5.5, 22, 0.35)
		Debris:AddItem(s, 0.65)
		CamaraCombate.sacudir(0.75, Vector3.new(0, 1, 0))
	end,
	PistaHelada = function(_p, r, d)
		local centro = piso(r) + r.CFrame.LookVector * (d.Alcance * 0.5)
		anillo(centro, 10, CRIO)
		local s =
			parteBrillo(CFrame.new(centro), Vector3.one * 0.2, CRIO, Enum.Material.SmoothPlastic, 1)
		emitirSprite(s, EB.HieloEscarcha, CRIO, 2.0, 20, 0.55, 20)
		EfectosGolpe.luz(centro, CRIO, 4.5, 20, 0.35)
		Debris:AddItem(s, 0.7)
	end,
	Onda = function(_p, r)
		anillo(piso(r) + r.CFrame.LookVector * 4, 12, TELE)
		EfectosGolpe.tajo(r.CFrame, 0, TELE, escalaActual * 1.45, true)
		local s = parteBrillo(
			CFrame.new(r.Position + r.CFrame.LookVector * 3),
			Vector3.one * 0.2,
			TELE,
			Enum.Material.SmoothPlastic,
			1
		)
		emitirSprite(s, EB.AnilloTelequinesis, TELE, 3.8, 6, 0.35, 14)
		Debris:AddItem(s, 0.5)
		CamaraCombate.sacudir(0.95, r.CFrame.LookVector)
		CamaraCombate.zoom(-5)
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
		Fuego.carga(a, b.Impacto)
	elseif tipo == "Explota" then
		Fuego.explosion(a, b)
		-- SONIDO: explosión de fuego
	elseif tipo == "Rayo" and typeof(a) == "table" then
		rayoSegmentos(a, ELECTRO)
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
