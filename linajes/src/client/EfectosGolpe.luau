--!strict
-- Golpe por capas + geometría 3D cómic: tajos, anillos inclinados, luz dinámica, escudo, parry y dash.
-- Sin blanco puro: el núcleo es Hueso y la tinta oscura define la silueta para que el Bloom no queme la forma.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local E = Config.Efectos
local EB = E.Beta
local NUCLEO = Color3.fromHex(Config.Hud.Colores.Hueso)
local TINTA = Color3.fromHex("#0E1016")

-- Matriz cromática de 3 capas por Linaje (GUIA-ESTILO §3.3: primario -> núcleo cálido/frío + tinta cómic).
local PALETA_COMIC = {
	{
		base = Config.Poderes.Colores.FuerzaBruta,
		nucleo = Color3.fromHex("#FFF1D0"),
		tinta = Color3.fromHex("#2A1F17"),
	},
	{
		base = Config.Poderes.Colores.Reflejos,
		nucleo = Color3.fromHex("#E8FCFF"),
		tinta = Color3.fromHex("#132638"),
	},
	{
		base = Config.Poderes.Colores.Piroquinesis,
		nucleo = Color3.fromHex("#FFD56B"),
		tinta = Color3.fromHex("#161218"),
	},
	{
		base = Config.Poderes.Colores.Electro,
		nucleo = Color3.fromHex("#F0FAFF"),
		tinta = Color3.fromHex("#101B2E"),
	},
	{
		base = Config.Poderes.Colores.Criogenia,
		nucleo = Color3.fromHex("#F2FCFF"),
		tinta = Color3.fromHex("#1D3A4F"),
	},
	{
		base = Config.Poderes.Colores.Telequinesis,
		nucleo = Color3.fromHex("#F3E6FF"),
		tinta = Color3.fromHex("#1E132B"),
	},
}

local function coloresCapa(color: Color3): (Color3, Color3)
	for _, item in PALETA_COMIC do
		local dr = math.abs(color.R - item.base.R)
		local dg = math.abs(color.G - item.base.G)
		local db = math.abs(color.B - item.base.B)
		if dr + dg + db < 0.08 then
			return item.nucleo, item.tinta
		end
	end
	return NUCLEO, TINTA
end

local EfectosGolpe = {}
EfectosGolpe.coloresCapa = coloresCapa

local function parteVfx(
	cf: CFrame,
	tam: Vector3,
	color: Color3,
	material: Enum.Material?,
	transparencia: number?
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
	p.Material = material or Enum.Material.Neon
	p.Transparency = transparencia or 0
	p.Parent = workspace
	return p
end

local function tween(
	obj: Instance,
	dura: number,
	estilo: Enum.EasingStyle,
	props: { [string]: any }
)
	TweenService:Create(obj, TweenInfo.new(dura, estilo, Enum.EasingDirection.Out), props):Play()
end

-- Destello puntual sobre el suelo/entorno en cada impacto o habilidad.
function EfectosGolpe.luz(
	punto: Vector3,
	color: Color3,
	brillo: number,
	alcance: number,
	dura: number
)
	local soporte =
		parteVfx(CFrame.new(punto), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	local luz = Instance.new("PointLight")
	luz.Color = color
	luz.Brightness = brillo
	luz.Range = alcance
	luz.Shadows = false
	luz.Parent = soporte
	tween(luz, dura, Enum.EasingStyle.Quad, { Brightness = 0, Range = alcance * 1.25 })
	Debris:AddItem(soporte, dura + 0.05)
end

-- Anillo geométrico 3D inclinado: se lee nitidamente desde cualquier ángulo.
function EfectosGolpe.anillo3D(
	cf: CFrame,
	radioInicio: number,
	radioFin: number,
	color: Color3,
	dura: number,
	grosor: number?
)
	local segs = 10
	local g = grosor or 0.22
	local grupo = Instance.new("Model")
	grupo.Name = "Anillo3D"
	grupo.Parent = workspace

	local ladoIni = 2 * radioInicio * math.sin(math.pi / segs) * 1.06
	local ladoFin = 2 * radioFin * math.sin(math.pi / segs) * 1.06

	for i = 1, segs do
		local ang = (i / segs) * math.pi * 2
		local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
		local seg = Instance.new("Part")
		seg.Anchored = true
		seg.CanCollide = false
		seg.CanQuery = false
		seg.CanTouch = false
		seg.CastShadow = false
		seg.Material = Enum.Material.Neon
		seg.Color = color
		seg.Size = Vector3.new(g, g * 0.7, ladoIni)
		seg.CFrame = cf
			* CFrame.lookAt(dir * radioInicio, Vector3.zero)
			* CFrame.Angles(0, math.pi / 2, 0)
		seg.Parent = grupo
		local destino = cf
			* CFrame.lookAt(dir * radioFin, Vector3.zero)
			* CFrame.Angles(0, math.pi / 2, 0)
		tween(seg, dura, Enum.EasingStyle.Quad, {
			CFrame = destino,
			Size = Vector3.new(g * 0.15, g * 0.15, ladoFin),
			Transparency = 1,
		})
	end
	Debris:AddItem(grupo, dura + 0.05)
end

local function emisorCapa(
	soporte: BasePart,
	textura: string,
	tam: number,
	color: Color3,
	vida: number,
	brillo: number,
	giro: number?,
	profundidad: number?,
	flipbook: boolean?,
	horizontal: boolean?,
	influenciaLuz: number?
)
	local e = Instance.new("ParticleEmitter")
	e.Texture = textura
	if flipbook then
		e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
		e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	end
	if horizontal then
		e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		e.EmissionDirection = Enum.NormalId.Top
	end
	e.Color = ColorSequence.new(color)
	e.LightEmission = math.clamp(brillo, 0, 0.7)
	e.LightInfluence = influenciaLuz or 0
	e.Lifetime = NumberRange.new(vida)
	e.Speed = NumberRange.new(if horizontal then 0.01 else 0)
	e.Size = if horizontal
		then NumberSequence.new({
			NumberSequenceKeypoint.new(0, tam * 0.25),
			NumberSequenceKeypoint.new(0.45, tam * 0.9),
			NumberSequenceKeypoint.new(1, tam),
		})
		else NumberSequence.new(tam)
	e.Transparency = if horizontal
		then NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(0.7, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		})
		else NumberSequence.new(0)
	e.Rotation = NumberRange.new(giro or math.random(0, 359))
	e.ZOffset = profundidad or 2
	e.Rate = 0
	e.Parent = soporte
	e:Emit(1)
end

-- Media luna 3D de tajo cómic (Regla de las 3 Capas: núcleo cálido/frío + color Linaje + filo de tinta oscura).
function EfectosGolpe.tajo(
	origenCf: CFrame,
	inclinacionDeg: number,
	color: Color3,
	escala: number?,
	fuerte: boolean?
)
	local nucleo, tintaLinaje = coloresCapa(color)
	local s = (escala or 1) * (if fuerte then 1.25 else 1)
	local plano = origenCf
		* CFrame.new(0, 0.2 * s, -0.8 * s)
		* CFrame.Angles(0, 0, math.rad(inclinacionDeg))

	local segs = 7
	local radioIni = 2.6 * s
	local radioFin = 4.5 * s
	local dura = if fuerte then 0.24 else 0.17

	local grupo = Instance.new("Model")
	grupo.Name = "Tajo3D"
	grupo.Parent = workspace

	for i = 1, segs do
		local u = (i - 1) / (segs - 1)
		local ang = math.rad(-82 + u * 164)
		local campana = math.sin(u * math.pi)
		local grosor = (0.14 + campana * 0.42) * s
		local largo = (0.95 + campana * 0.55) * s
		local posIni = Vector3.new(math.cos(ang) * radioIni, 0, math.sin(ang) * -radioIni)
		local posFin = Vector3.new(math.cos(ang) * radioFin, 0, math.sin(ang) * -radioFin)
		local tang = CFrame.Angles(0, ang, 0)

		local brilloPart = Instance.new("Part")
		brilloPart.Anchored = true
		brilloPart.CanCollide = false
		brilloPart.CanQuery = false
		brilloPart.CanTouch = false
		brilloPart.CastShadow = false
		brilloPart.Material = Enum.Material.Neon
		brilloPart.Color = if i % 2 == 0 then nucleo else color
		brilloPart.Size = Vector3.new(grosor, 0.12 * s, largo)
		brilloPart.CFrame = plano * CFrame.new(posIni) * tang
		brilloPart.Parent = grupo
		tween(brilloPart, dura, Enum.EasingStyle.Quad, {
			CFrame = plano * CFrame.Angles(0, math.rad(16), 0) * CFrame.new(posFin) * tang,
			Size = Vector3.new(0.05, 0.05, largo * 1.15),
			Transparency = 1,
		})

		-- Capa 2: trazo de tinta cómic debajo para contraste en Puerto Óxido.
		local tintaPart = brilloPart:Clone()
		tintaPart.Material = Enum.Material.SmoothPlastic
		tintaPart.Color = tintaLinaje
		tintaPart.Transparency = 0.18
		tintaPart.Size = Vector3.new(grosor * 1.5, 0.08 * s, largo * 1.08)
		tintaPart.CFrame = plano * CFrame.new(posIni * 0.92 + Vector3.new(0, -0.06, 0)) * tang
		tintaPart.Parent = grupo
		tween(tintaPart, dura, Enum.EasingStyle.Quad, {
			CFrame = plano * CFrame.Angles(0, math.rad(16), 0) * CFrame.new(
				posFin * 0.94 + Vector3.new(0, -0.06, 0)
			) * tang,
			Size = Vector3.new(0.06, 0.05, largo * 1.1),
			Transparency = 1,
		})
	end
	Debris:AddItem(grupo, dura + 0.06)

	local soporteTajo = parteVfx(
		plano * CFrame.new(0, 0, -2.8 * s),
		Vector3.one * 0.2,
		color,
		Enum.Material.SmoothPlastic,
		1
	)
	emisorCapa(soporteTajo, EB.TajoArco, 6.4 * s, tintaLinaje, dura * 0.9, 0, inclinacionDeg, 1)
	emisorCapa(soporteTajo, EB.TajoArco, 5.5 * s, color, dura, 0.65, inclinacionDeg, 2)
	emisorCapa(soporteTajo, EB.TajoArco, 3.8 * s, nucleo, dura * 0.75, 0.55, inclinacionDeg, 3)
	Debris:AddItem(soporteTajo, dura + 0.08)
end

-- Grieta cómic en el asfalto bajo impactos fuertes o rupturas de guardia (Capa 3).
function EfectosGolpe.grieta(punto: Vector3, tamano: number, dura: number?, colorTinta: Color3?)
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	filtro.FilterDescendantsInstances = CollectionService:GetTagged("Combatiente")
	local hit = workspace:Raycast(punto + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0), filtro)
	if not hit then
		return
	end
	local t = dura or 1.4
	local tinta = colorTinta or TINTA
	local orient = CFrame.lookAlong(hit.Position + hit.Normal * 0.04, hit.Normal)
		* CFrame.Angles(-math.pi / 2, 0, 0)
		* CFrame.Angles(0, math.random() * 6.28, 0)
	local placa =
		parteVfx(orient, Vector3.new(tamano, 0.08, tamano), tinta, Enum.Material.SmoothPlastic, 1)
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Top
	decal.Texture = EB.GrietaPiso
	decal.Color3 = tinta
	decal.Transparency = 0.06
	decal.Parent = placa
	task.delay(t * 0.55, function()
		if decal.Parent then
			tween(decal, t * 0.45, Enum.EasingStyle.Quad, { Transparency = 1 })
		end
	end)
	Debris:AddItem(placa, t + 0.06)
end

local function chispas(soporte: BasePart, color: Color3, cantidad: number, velocidad: number?)
	local nucleo = coloresCapa(color)
	local v = velocidad or 65
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(nucleo, color)
	e.LightEmission = 0.68
	e.LightInfluence = 0
	e.Orientation = Enum.ParticleOrientation.VelocityParallel
	e.Lifetime = NumberRange.new(0.16, 0.36)
	e.Speed = NumberRange.new(v * 0.65, v * 1.25)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.44),
		NumberSequenceKeypoint.new(0.5, 0.26),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Squash = NumberSequence.new(3.2)
	e.Drag = 8
	e.ZOffset = 2
	e.Rate = 0
	e.Parent = soporte
	e:Emit(cantidad)
end

function EfectosGolpe.reproducir(punto: Vector3, fuerte: boolean, color: Color3, escala: number?)
	local nucleo, tintaLinaje = coloresCapa(color)
	local s = (if fuerte then E.EscalaFuerte else 1) * (escala or 1)
	local soporte =
		parteVfx(CFrame.new(punto), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	-- Capa 2: silueta de tinta cómic detrás del estallido
	emisorCapa(
		soporte,
		EB.ImpactoFlipbook4x4,
		E.TamDestello * 1.55 * s,
		tintaLinaje,
		0.18,
		0,
		nil,
		1,
		true
	)
	-- Capa 1: estallido primario + núcleo Hueso (LightEmission <= 0.70)
	emisorCapa(
		soporte,
		EB.ImpactoFlipbook4x4,
		E.TamDestello * 1.25 * s,
		color,
		0.22,
		0.68,
		nil,
		2,
		true
	)
	emisorCapa(soporte, EB.DestelloParry, E.TamDestello * 0.82 * s, nucleo, 0.14, 0.58, nil, 3)
	emisorCapa(soporte, E.Anillo, E.TamAnillo * s, color, 0.24, 0.65, nil, 2, true)
	emisorCapa(soporte, E.Arco, E.TamArco * s, nucleo, 0.16, 0.55, nil, 3, true)
	chispas(soporte, color, if fuerte then 32 else 16, if fuerte then 78 else 58)

	local inclinado = CFrame.new(punto)
		* CFrame.Angles(math.random() * 1.4 - 0.7, math.random() * 6.28, math.random() * 1.4 - 0.7)
	EfectosGolpe.anillo3D(
		inclinado,
		1.1 * s,
		5.2 * s,
		color,
		if fuerte then 0.24 else 0.17,
		0.24 * s
	)
	EfectosGolpe.luz(
		punto,
		color,
		if fuerte then 6.5 else 4.0,
		if fuerte then 24 else 16,
		if fuerte then 0.2 else 0.14
	)

	if fuerte then
		emisorCapa(soporte, EB.OndaChoque, E.TamAnillo * 1.35 * s, tintaLinaje, 0.26, 0, 0, 1)
		emisorCapa(soporte, EB.OndaChoque, E.TamAnillo * 1.22 * s, color, 0.28, 0.68, 0, 2)
		emisorCapa(
			soporte,
			E.Lineas,
			E.TamLineas * s / E.EscalaFuerte,
			color,
			0.25,
			0.65,
			nil,
			2,
			true
		)
		-- Humo cómic mate (GUIA-ESTILO §3.1: LightInfluence = 0.25, LightEmission = 0)
		emisorCapa(
			soporte,
			E.Humo,
			E.TamHumo * s / E.EscalaFuerte,
			tintaLinaje:Lerp(Color3.fromHex("#8d90a0"), 0.45),
			0.55,
			0,
			nil,
			1,
			true,
			false,
			0.25
		)
		local cruzado = CFrame.new(punto)
			* CFrame.Angles(math.rad(-35), math.random() * 6.28, math.rad(28))
		EfectosGolpe.anillo3D(cruzado, 1.6 * s, 7.4 * s, nucleo, 0.28, 0.18 * s)
		EfectosGolpe.grieta(punto, 7.5 * s, 1.35, tintaLinaje)
	end
	Debris:AddItem(soporte, 0.85)
end

-- Estallido radial de parry: destello cómic 3 capas + doble anillo cruzado + púas.
function EfectosGolpe.parry(punto: Vector3, color: Color3)
	local nucleo, tintaLinaje = coloresCapa(color)
	EfectosGolpe.reproducir(punto, true, color, 1.15)
	local estrellaSoporte =
		parteVfx(CFrame.new(punto), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 11.8, tintaLinaje, 0.22, 0, 0, 2)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 9.6, color, 0.26, 0.68, 0, 3)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 5.8, nucleo, 0.18, 0.58, 0, 4)
	Debris:AddItem(estrellaSoporte, 0.4)
	local cfBase = CFrame.new(punto)
	EfectosGolpe.anillo3D(
		cfBase * CFrame.Angles(math.rad(38), 0, math.rad(25)),
		1.4,
		9.5,
		color,
		0.3,
		0.3
	)
	EfectosGolpe.anillo3D(
		cfBase * CFrame.Angles(math.rad(-42), 0, math.rad(-30)),
		1.2,
		8.2,
		nucleo,
		0.26,
		0.24
	)
	for i = 1, 6 do
		local rot = CFrame.Angles(math.random() * 3.14, math.random() * 6.28, i * 1.04)
		local pua = parteVfx(cfBase * rot, Vector3.new(0.22, 0.22, 1.8), nucleo)
		tween(pua, 0.22, Enum.EasingStyle.Quad, {
			CFrame = cfBase * rot * CFrame.new(0, 0, -4.5),
			Size = Vector3.new(0.05, 0.05, 6.5),
			Transparency = 1,
		})
		Debris:AddItem(pua, 0.26)
	end
end

-- Destello de ruptura de guardia: grieta en asfalto + onda radial + fragmentos angulares.
function EfectosGolpe.rupturaGuardia(punto: Vector3, color: Color3)
	local nucleo, tintaLinaje = coloresCapa(color)
	EfectosGolpe.reproducir(punto, true, color, 1.3)
	EfectosGolpe.grieta(punto, 10, 2.0, tintaLinaje)
	local cfBase = CFrame.new(punto)
	EfectosGolpe.anillo3D(cfBase * CFrame.Angles(math.rad(90), 0, 0), 1.4, 8.8, color, 0.3, 0.34)
	for i = 1, 8 do
		local cuna = Instance.new("WedgePart")
		cuna.Anchored = false
		cuna.CanCollide = false
		cuna.CanQuery = false
		cuna.CanTouch = false
		cuna.Color = if i % 2 == 0 then nucleo else color
		cuna.Material = Enum.Material.Neon
		cuna.Size = Vector3.new(0.45, 0.7, 0.25)
		cuna.CFrame = cfBase
			* CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
		cuna.Parent = workspace
		cuna.AssemblyLinearVelocity =
			Vector3.new(math.random(-28, 28), math.random(10, 32), math.random(-28, 28))
		cuna.AssemblyAngularVelocity =
			Vector3.new(math.random(-12, 12), math.random(-12, 12), math.random(-12, 12))
		tween(cuna, 0.45, Enum.EasingStyle.Quad, { Transparency = 1 })
		Debris:AddItem(cuna, 0.5)
	end
end

-- Escudo geométrico de bloqueo frente al personaje.
function EfectosGolpe.bloqueo(raiz: BasePart, color: Color3, impactoBloqueado: boolean)
	local frente = raiz.CFrame * CFrame.new(0, 0.3, -2.1) * CFrame.Angles(0, 0, math.pi / 4)
	local placa = parteVfx(
		frente,
		Vector3.new(3.2, 3.2, 0.14),
		if impactoBloqueado then color else Color3.fromRGB(115, 175, 255),
		Enum.Material.ForceField,
		if impactoBloqueado then 0.25 else 0.48
	)
	local dura = if impactoBloqueado then 0.2 else 0.16
	tween(placa, dura, Enum.EasingStyle.Quad, {
		Size = Vector3.new(4.3, 4.3, 0.08),
		Transparency = 1,
	})
	Debris:AddItem(placa, dura + 0.04)
	if impactoBloqueado then
		EfectosGolpe.anillo3D(
			raiz.CFrame * CFrame.new(0, 0.3, -2.1) * CFrame.Angles(math.pi / 2, 0, 0),
			1.0,
			4.8,
			color,
			0.22,
			0.22
		)
		EfectosGolpe.luz(frente.Position, color, 5, 16, 0.16)
	end
end

-- Estela de velocidad al hacer Dash (GUIA-ESTILO §3.1 + combate/01-dash-rayo-flechas-aviso):
-- 3 clones reales de CuerpoComic con Highlight + cinta de piso (Beam) + bocanadas de polvo mate.
function EfectosGolpe.dash(personaje: Model, raiz: BasePart, rumbo: Vector3, color: Color3)
	local nucleo, tintaLinaje = coloresCapa(color)
	local dir = if rumbo.Magnitude > 0.01 then rumbo.Unit else raiz.CFrame.LookVector
	local orient = CFrame.lookAt(raiz.Position, raiz.Position + dir)
		* CFrame.Angles(math.pi / 2, 0, 0)
	EfectosGolpe.anillo3D(orient, 1.5, 4.6, color, 0.22, 0.22)
	EfectosGolpe.luz(raiz.Position, color, 3.8, 15, 0.18)

	-- Cinta de piso (Beam) de 2 capas (tinta + color Linaje) + polvo mate al despegar.
	local pisoIni = raiz.Position - Vector3.new(0, 2.6, 0)
	local pisoFin = pisoIni + dir * 11.5
	local soporteCinta =
		parteVfx(CFrame.new(pisoIni), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	local att0 = Instance.new("Attachment")
	att0.WorldPosition = pisoIni
	att0.Parent = soporteCinta
	local att1 = Instance.new("Attachment")
	att1.WorldPosition = pisoFin
	att1.Parent = soporteCinta

	for capa = 1, 2 do
		local cinta = Instance.new("Beam")
		cinta.Attachment0 = att0
		cinta.Attachment1 = att1
		cinta.Texture = EB.RayoTira
		cinta.TextureSpeed = if capa == 1 then 4 else 7
		cinta.TextureLength = 6
		cinta.FaceCamera = true
		cinta.LightEmission = if capa == 1 then 0 else 0.65
		cinta.LightInfluence = 0
		cinta.Color = ColorSequence.new(if capa == 1 then tintaLinaje else color, nucleo)
		cinta.Width0 = if capa == 1 then 2.8 else 1.8
		cinta.Width1 = if capa == 1 then 0.9 else 0.45
		cinta.Transparency = NumberSequence.new(if capa == 1 then 0.2 else 0.05, 1)
		cinta.Parent = soporteCinta
	end
	emisorCapa(
		soporteCinta,
		E.Humo,
		4.2,
		tintaLinaje:Lerp(Color3.fromHex("#8d90a0"), 0.5),
		0.35,
		0,
		nil,
		1,
		true,
		false,
		0.25
	)
	Debris:AddItem(soporteCinta, 0.36)

	for paso = 0, 2 do
		local grupo = Instance.new("Model")
		grupo.Name = "EstelaDash"
		for _, parte in personaje:GetChildren() do
			if parte:IsA("MeshPart") and parte.Transparency < 1 and parte.Size.Magnitude > 0.7 then
				local copia = parte:Clone()
				copia:ClearAllChildren()
				copia.Anchored = true
				copia.CanCollide = false
				copia.CanQuery = false
				copia.CanTouch = false
				copia.Color = if paso == 0 then nucleo else color
				copia.Material = Enum.Material.SmoothPlastic
				copia.TextureID = ""
				copia.Transparency = 0.48 + paso * 0.16
				copia.CFrame = parte.CFrame - dir * (paso * 1.45 + 0.45)
				copia.Parent = grupo
				tween(copia, 0.22 + paso * 0.06, Enum.EasingStyle.Quad, { Transparency = 1 })
			end
		end
		local silueta = Instance.new("Highlight")
		silueta.FillColor = color
		silueta.FillTransparency = 0.65 + paso * 0.1
		silueta.OutlineColor = if paso == 0 then nucleo else tintaLinaje
		silueta.OutlineTransparency = 0.18 + paso * 0.25
		silueta.DepthMode = Enum.HighlightDepthMode.Occluded
		silueta.Parent = grupo
		grupo.Parent = workspace
		Debris:AddItem(grupo, 0.36)
	end
end

-- Telégrafo de peligro (GUIA-ESTILO §3.2 + ref-animaciones-vfx-poco-comunes):
-- Proyecta en el suelo (+0.05 studs) relleno #D6333A (72% transp.), borde #FF6B5B (vfx-aviso-suelo)
-- y onda interna que crece del centro al borde (0 -> 100%) en 0.4 s (12 frames), más destello de parry arriba.
function EfectosGolpe.aviso(objetivo: Model, radioOpc: number?, duraOpc: number?)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	local dura = duraOpc or 0.4
	local diam = (radioOpc or 4.2) * 2
	local rojoRelleno = Color3.fromHex("#D6333A")
	local rojoBorde = Color3.fromHex("#FF6B5B")

	-- 1. Proyección en el suelo (+0.05 studs sobre la normal del piso frente al atacante)
	local centroAdelante = r.Position + r.CFrame.LookVector * 2.6
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	filtro.FilterDescendantsInstances = CollectionService:GetTagged("Combatiente")
	local hit =
		workspace:Raycast(centroAdelante + Vector3.new(0, 3, 0), Vector3.new(0, -10, 0), filtro)
	local pisoPos = if hit
		then hit.Position + hit.Normal * 0.05
		else centroAdelante - Vector3.new(0, 2.75, 0)
	local normalPiso = if hit then hit.Normal else Vector3.yAxis
	local cfPiso = CFrame.lookAlong(pisoPos, normalPiso) * CFrame.Angles(-math.pi / 2, 0, 0)

	local disco = parteVfx(
		cfPiso * CFrame.Angles(0, 0, math.pi / 2),
		Vector3.new(0.04, diam * 0.92, diam * 0.92),
		rojoRelleno,
		Enum.Material.Neon,
		0.72
	)
	disco.Shape = Enum.PartType.Cylinder

	local placaBorde =
		parteVfx(cfPiso, Vector3.new(diam, 0.05, diam), rojoBorde, Enum.Material.SmoothPlastic, 1)
	local decTinta = Instance.new("Decal")
	decTinta.Face = Enum.NormalId.Top
	decTinta.Texture = EB.AvisoSuelo
	decTinta.Color3 = TINTA
	decTinta.Transparency = 0.25
	decTinta.Parent = placaBorde
	local decBorde = Instance.new("Decal")
	decBorde.Face = Enum.NormalId.Top
	decBorde.Texture = EB.AvisoSuelo
	decBorde.Color3 = rojoBorde
	decBorde.Transparency = 0.04
	decBorde.Parent = placaBorde

	local placaOnda = parteVfx(
		cfPiso + normalPiso * 0.01,
		Vector3.new(diam * 0.15, 0.05, diam * 0.15),
		rojoBorde,
		Enum.Material.SmoothPlastic,
		1
	)
	local decOnda = Instance.new("Decal")
	decOnda.Face = Enum.NormalId.Top
	decOnda.Texture = EB.AvisoSuelo
	decOnda.Color3 = NUCLEO:Lerp(rojoBorde, 0.5)
	decOnda.Transparency = 0.1
	decOnda.Parent = placaOnda

	TweenService:Create(
		placaOnda,
		TweenInfo.new(dura, Enum.EasingStyle.Linear),
		{ Size = Vector3.new(diam, 0.05, diam) }
	):Play()
	task.delay(dura * 0.82, function()
		if decBorde.Parent then
			decBorde.Color3 = NUCLEO
			tween(decBorde, 0.12, Enum.EasingStyle.Quad, { Transparency = 1 })
			tween(decTinta, 0.12, Enum.EasingStyle.Quad, { Transparency = 1 })
			tween(decOnda, 0.12, Enum.EasingStyle.Quad, { Transparency = 1 })
			tween(disco, 0.12, Enum.EasingStyle.Quad, { Transparency = 1 })
		end
	end)
	Debris:AddItem(disco, dura + 0.14)
	Debris:AddItem(placaBorde, dura + 0.14)
	Debris:AddItem(placaOnda, dura + 0.14)

	-- 2. Destello de ventana de parry a la altura del torso
	local pos = r.Position + Vector3.new(0, 1.7, 0) + r.CFrame.LookVector * 0.85
	local soporte =
		parteVfx(CFrame.new(pos), Vector3.one * 0.2, rojoBorde, Enum.Material.SmoothPlastic, 1)
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(4.2, 4.2)
	cartel.LightInfluence = 0
	cartel.Parent = soporte
	local img = Instance.new("ImageLabel")
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromScale(1, 1)
	img.BackgroundTransparency = 1
	img.Image = EB.AvisoSuelo
	img.ImageColor3 = rojoBorde
	img.Parent = cartel
	tween(img, dura * 0.75, Enum.EasingStyle.Back, {
		Size = UDim2.fromScale(0.65, 0.65),
		ImageTransparency = 1,
	})
	EfectosGolpe.anillo3D(
		CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0),
		3.4,
		0.6,
		rojoBorde,
		dura * 0.75,
		0.2
	)
	Debris:AddItem(soporte, dura + 0.05)
end

-- Onda plana en el piso + anillo 3D nítido (+ grieta cómic en impactos grandes).
function EfectosGolpe.onda(centro: Vector3, radio: number, color: Color3)
	local nucleo, tintaLinaje = coloresCapa(color)
	local soporte = parteVfx(
		CFrame.new(centro + Vector3.new(0, 0.3, 0)),
		Vector3.one * 0.2,
		color,
		Enum.Material.SmoothPlastic,
		1
	)
	emisorCapa(soporte, EB.OndaChoque, radio * 2.42, tintaLinaje, 0.3, 0, 0, 1, false, true)
	emisorCapa(soporte, EB.OndaChoque, radio * 2.25, color, 0.32, 0.68, 0, 2, false, true)
	emisorCapa(soporte, EB.OndaChoque, radio * 1.45, nucleo, 0.22, 0.58, 45, 3, false, true)
	EfectosGolpe.anillo3D(
		CFrame.new(centro + Vector3.new(0, 0.35, 0)),
		radio * 0.25,
		radio * 1.15,
		color,
		0.3,
		0.28
	)
	if radio >= 10 then
		EfectosGolpe.grieta(centro, radio * 0.9, 1.5, tintaLinaje)
	end
	Debris:AddItem(soporte, 0.7)
end

-- Sello cómic rotante en 3D (top + bottom Decal + capa de tinta oscura debajo) para anticipación, aura o despertar.
function EfectosGolpe.runa3D(
	cf: CFrame,
	tamInicio: number,
	tamFin: number,
	color: Color3,
	dura: number,
	textura: string?
)
	local _, tintaLinaje = coloresCapa(color)
	local tex = textura or EB.RunaEclipse
	local placa =
		parteVfx(cf, Vector3.new(tamInicio, 0.06, tamInicio), color, Enum.Material.SmoothPlastic, 1)
	local placaTinta = parteVfx(
		cf * CFrame.new(0, -0.02, 0),
		Vector3.new(tamInicio * 1.09, 0.06, tamInicio * 1.09),
		tintaLinaje,
		Enum.Material.SmoothPlastic,
		1
	)
	local caras: { Decal } = {}
	for _, cara in { Enum.NormalId.Top, Enum.NormalId.Bottom } do
		local dt = Instance.new("Decal")
		dt.Face = cara
		dt.Texture = tex
		dt.Color3 = tintaLinaje
		dt.Transparency = 0.18
		dt.Parent = placaTinta
		table.insert(caras, dt)

		local d = Instance.new("Decal")
		d.Face = cara
		d.Texture = tex
		d.Color3 = color
		d.Transparency = 0.06
		d.Parent = placa
		table.insert(caras, d)
	end
	tween(placa, dura, Enum.EasingStyle.Quad, {
		Size = Vector3.new(tamFin, 0.06, tamFin),
		CFrame = cf * CFrame.Angles(0, math.rad(150), 0),
	})
	tween(placaTinta, dura, Enum.EasingStyle.Quad, {
		Size = Vector3.new(tamFin * 1.09, 0.06, tamFin * 1.09),
		CFrame = cf * CFrame.new(0, -0.02, 0) * CFrame.Angles(0, math.rad(150), 0),
	})
	task.delay(dura * 0.45, function()
		for _, d in caras do
			if d.Parent then
				tween(d, dura * 0.55, Enum.EasingStyle.Quad, { Transparency = 1 })
			end
		end
	end)
	Debris:AddItem(placa, dura + 0.06)
	Debris:AddItem(placaTinta, dura + 0.06)
end

-- Cuñas 3D cel-shaded (cristal, roca o esquirla de energía) con rebote y desvanecimiento.
function EfectosGolpe.fragmentos3D(
	centro: Vector3,
	cantidad: number,
	color: Color3,
	tamano: Vector3,
	velocidad: number,
	material: Enum.Material?,
	tinta: boolean?
)
	local modelo = Instance.new("Model")
	modelo.Name = "FragmentosComic"
	if tinta then
		local b = Instance.new("Highlight")
		b.FillTransparency = 1
		b.OutlineColor = TINTA
		b.OutlineTransparency = 0.1
		b.DepthMode = Enum.HighlightDepthMode.Occluded
		b.Parent = modelo
	end
	local mat = material or Enum.Material.Slate
	for i = 1, cantidad do
		local ang = (i / cantidad) * math.pi * 2 + (math.random() - 0.5) * 0.55
		local dir = Vector3.new(math.cos(ang), 0.45 + math.random() * 0.85, math.sin(ang)).Unit
		local p = Instance.new("WedgePart")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = mat
		p.Color = if i % 3 == 0 then color:Lerp(NUCLEO, 0.45) else color
		p.Size = tamano * (0.65 + math.random() * 0.6)
		p.CFrame = CFrame.lookAt(centro + dir * 0.8, centro + dir * 3)
			* CFrame.Angles(math.random() * 3, math.random() * 3, math.random() * 3)
		p.Parent = modelo
		local destino = centro
			+ Vector3.new(dir.X, dir.Y * 0.65 - 0.3, dir.Z)
				* (velocidad * (0.28 + math.random() * 0.25))
		tween(p, 0.42, Enum.EasingStyle.Quad, {
			CFrame = CFrame.new(destino) * CFrame.Angles(4, 5, 2),
			Size = Vector3.one * 0.08,
			Transparency = 1,
		})
	end
	modelo.Parent = workspace
	Debris:AddItem(modelo, 0.5)
end

-- Estallido radial de impacto pesado (FuerzaBruta / Rompeguardia / Finisher).
function EfectosGolpe.impactoFuerza(
	cf: CFrame,
	tamInicio: number,
	tamFin: number,
	color: Color3,
	dura: number
)
	EfectosGolpe.runa3D(
		cf * CFrame.Angles(math.pi / 2, 0, 0),
		tamInicio,
		tamFin,
		color,
		dura,
		EB.ImpactoFuerza
	)
	EfectosGolpe.anillo3D(
		cf * CFrame.Angles(math.pi / 2, 0, 0),
		tamInicio * 0.45,
		tamFin * 0.72,
		color,
		dura,
		0.22
	)
end

-- Pilar cómic del Eclipse para Despertar de Linaje y Subida de Nivel.
function EfectosGolpe.columnaDespertar(pisoPos: Vector3, color: Color3, escala: number?)
	local s = escala or 1
	local alto = 38 * s
	local pilar = parteVfx(
		CFrame.new(pisoPos + Vector3.new(0, alto * 0.5, 0)),
		Vector3.new(4.2 * s, alto, 4.2 * s),
		color,
		Enum.Material.Neon,
		0.15
	)
	local nucleo = parteVfx(
		CFrame.new(pisoPos + Vector3.new(0, alto * 0.5, 0)),
		Vector3.new(1.8 * s, alto, 1.8 * s),
		NUCLEO,
		Enum.Material.Neon,
		0.05
	)
	tween(pilar, 0.65, Enum.EasingStyle.Quad, {
		Size = Vector3.new(0.2, alto * 1.15, 0.2),
		Transparency = 1,
	})
	tween(nucleo, 0.45, Enum.EasingStyle.Quad, {
		Size = Vector3.new(0.1, alto, 0.1),
		Transparency = 1,
	})
	Debris:AddItem(pilar, 0.7)
	Debris:AddItem(nucleo, 0.5)

	local sueloCF = CFrame.new(pisoPos + Vector3.new(0, 0.18, 0))
	EfectosGolpe.runa3D(sueloCF, 3 * s, 16 * s, color, 0.75, EB.RunaEclipse)
	EfectosGolpe.runa3D(
		sueloCF * CFrame.Angles(0, math.pi / 4, 0),
		2 * s,
		11 * s,
		NUCLEO,
		0.55,
		EB.ImpactoFuerza
	)
	EfectosGolpe.onda(pisoPos, 13 * s, color)
	EfectosGolpe.fragmentos3D(
		pisoPos + Vector3.new(0, 2, 0),
		12,
		color,
		Vector3.new(0.4, 2.2, 0.4) * s,
		22 * s,
		Enum.Material.Neon,
		false
	)
	EfectosGolpe.luz(pisoPos + Vector3.new(0, 4, 0), color, 8, 32, 0.65)
	for i = 0, 2 do
		task.delay(i * 0.11, function()
			EfectosGolpe.anillo3D(
				CFrame.new(pisoPos + Vector3.new(0, 1.5 + i * 3.8 * s, 0)),
				2.2 * s,
				8.5 * s,
				if i % 2 == 0 then color else NUCLEO,
				0.34,
				0.26
			)
		end)
	end
end

return EfectosGolpe
