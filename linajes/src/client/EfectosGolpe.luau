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
local TINTA = Color3.fromHex(Config.Hud.Colores.Fondo)

local EfectosGolpe = {}

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
	horizontal: boolean?
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
	e.LightEmission = brillo
	e.LightInfluence = 0
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

-- Media luna 3D de tajo cómic: centro claro/Linaje y filo de tinta detrás.
function EfectosGolpe.tajo(
	origenCf: CFrame,
	inclinacionDeg: number,
	color: Color3,
	escala: number?,
	fuerte: boolean?
)
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
		brilloPart.Color = if i % 2 == 0 then NUCLEO else color
		brilloPart.Size = Vector3.new(grosor, 0.12 * s, largo)
		brilloPart.CFrame = plano * CFrame.new(posIni) * tang
		brilloPart.Parent = grupo
		tween(brilloPart, dura, Enum.EasingStyle.Quad, {
			CFrame = plano * CFrame.Angles(0, math.rad(16), 0) * CFrame.new(posFin) * tang,
			Size = Vector3.new(0.05, 0.05, largo * 1.15),
			Transparency = 1,
		})

		-- Trazo de tinta debajo para contraste en Puerto Óxido.
		local tintaPart = brilloPart:Clone()
		tintaPart.Material = Enum.Material.SmoothPlastic
		tintaPart.Color = TINTA
		tintaPart.Transparency = 0.25
		tintaPart.Size = Vector3.new(grosor * 1.45, 0.08 * s, largo * 1.05)
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
	emisorCapa(soporteTajo, EB.TajoArco, 6.2 * s, TINTA, dura * 0.85, 0, inclinacionDeg, 1)
	emisorCapa(soporteTajo, EB.TajoArco, 5.4 * s, color, dura, 0.95, inclinacionDeg, 2)
	Debris:AddItem(soporteTajo, dura + 0.08)
end

-- Grieta cómic en el asfalto bajo impactos fuertes o rupturas de guardia.
function EfectosGolpe.grieta(punto: Vector3, tamano: number, dura: number?)
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	filtro.FilterDescendantsInstances = CollectionService:GetTagged("Combatiente")
	local hit = workspace:Raycast(punto + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0), filtro)
	if not hit then
		return
	end
	local t = dura or 1.4
	local orient = CFrame.lookAlong(hit.Position + hit.Normal * 0.04, hit.Normal)
		* CFrame.Angles(-math.pi / 2, 0, 0)
		* CFrame.Angles(0, math.random() * 6.28, 0)
	local placa =
		parteVfx(orient, Vector3.new(tamano, 0.08, tamano), TINTA, Enum.Material.SmoothPlastic, 1)
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Top
	decal.Texture = EB.GrietaPiso
	decal.Color3 = TINTA
	decal.Transparency = 0.08
	decal.Parent = placa
	task.delay(t * 0.55, function()
		if decal.Parent then
			tween(decal, t * 0.45, Enum.EasingStyle.Quad, { Transparency = 1 })
		end
	end)
	Debris:AddItem(placa, t + 0.06)
end

local function chispas(soporte: BasePart, color: Color3, cantidad: number, velocidad: number?)
	local v = velocidad or 65
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(NUCLEO, color)
	e.LightEmission = 1
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
	local s = (if fuerte then E.EscalaFuerte else 1) * (escala or 1)
	local soporte =
		parteVfx(CFrame.new(punto), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	emisorCapa(
		soporte,
		EB.ImpactoFlipbook4x4,
		E.TamDestello * 1.5 * s,
		TINTA,
		0.16,
		0,
		nil,
		1,
		true
	)
	emisorCapa(
		soporte,
		EB.ImpactoFlipbook4x4,
		E.TamDestello * 1.25 * s,
		color,
		0.22,
		1,
		nil,
		2,
		true
	)
	emisorCapa(soporte, EB.DestelloParry, E.TamDestello * 0.8 * s, NUCLEO, 0.14, 0.75, nil, 3)
	emisorCapa(soporte, E.Anillo, E.TamAnillo * s, color, 0.24, 1, nil, 2, true)
	emisorCapa(soporte, E.Arco, E.TamArco * s, NUCLEO, 0.16, 0.65, nil, 3, true)
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
		if fuerte then 7 else 4.2,
		if fuerte then 24 else 16,
		if fuerte then 0.2 else 0.14
	)

	if fuerte then
		emisorCapa(soporte, EB.OndaChoque, E.TamAnillo * 1.25 * s, color, 0.28, 0.9, 0, 2)
		emisorCapa(
			soporte,
			E.Lineas,
			E.TamLineas * s / E.EscalaFuerte,
			color,
			0.25,
			1,
			nil,
			2,
			true
		)
		emisorCapa(
			soporte,
			E.Humo,
			E.TamHumo * s / E.EscalaFuerte,
			Color3.fromHex("#8d90a0"),
			0.55,
			0,
			nil,
			1,
			true
		)
		local cruzado = CFrame.new(punto)
			* CFrame.Angles(math.rad(-35), math.random() * 6.28, math.rad(28))
		EfectosGolpe.anillo3D(cruzado, 1.6 * s, 7.4 * s, NUCLEO, 0.28, 0.18 * s)
		EfectosGolpe.grieta(punto, 7.5 * s, 1.35)
	end
	Debris:AddItem(soporte, 0.85)
end

-- Estallido radial de parry: destello cómic 3 capas + doble anillo cruzado + púas.
function EfectosGolpe.parry(punto: Vector3, color: Color3)
	EfectosGolpe.reproducir(punto, true, color, 1.15)
	local estrellaSoporte =
		parteVfx(CFrame.new(punto), Vector3.one * 0.2, color, Enum.Material.SmoothPlastic, 1)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 11.5, TINTA, 0.22, 0, 0, 2)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 9.5, color, 0.26, 1, 0, 3)
	emisorCapa(estrellaSoporte, EB.DestelloParry, 5.8, NUCLEO, 0.18, 0.85, 0, 4)
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
		NUCLEO,
		0.26,
		0.24
	)
	for i = 1, 6 do
		local rot = CFrame.Angles(math.random() * 3.14, math.random() * 6.28, i * 1.04)
		local pua = parteVfx(cfBase * rot, Vector3.new(0.22, 0.22, 1.8), NUCLEO)
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
	EfectosGolpe.reproducir(punto, true, color, 1.3)
	EfectosGolpe.grieta(punto, 10, 2.0)
	local cfBase = CFrame.new(punto)
	EfectosGolpe.anillo3D(cfBase * CFrame.Angles(math.rad(90), 0, 0), 1.4, 8.8, color, 0.3, 0.34)
	for _ = 1, 8 do
		local cuna = Instance.new("WedgePart")
		cuna.Anchored = false
		cuna.CanCollide = false
		cuna.CanQuery = false
		cuna.CanTouch = false
		cuna.Color = color
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

-- Estela y anillo de velocidad al hacer Dash.
function EfectosGolpe.dash(personaje: Model, raiz: BasePart, rumbo: Vector3, color: Color3)
	local orient = CFrame.lookAt(raiz.Position, raiz.Position + rumbo)
		* CFrame.Angles(math.pi / 2, 0, 0)
	EfectosGolpe.anillo3D(orient, 1.5, 4.4, color, 0.2, 0.2)
	EfectosGolpe.luz(raiz.Position, color, 3.5, 14, 0.15)
	for paso = 0, 1 do
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
				copia.Color = color
				copia.Material = Enum.Material.SmoothPlastic
				copia.TextureID = ""
				copia.Transparency = 0.58 + paso * 0.16
				copia.CFrame = parte.CFrame - rumbo * (paso * 1.3 + 0.5)
				copia.Parent = grupo
				tween(copia, 0.22 + paso * 0.06, Enum.EasingStyle.Quad, { Transparency = 1 })
			end
		end
		grupo.Parent = workspace
		Debris:AddItem(grupo, 0.32)
	end
end

-- Destello y retícula cómic de aviso para leer ataques enemigos (ventana de parry).
function EfectosGolpe.aviso(objetivo: Model)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	local pos = r.Position + Vector3.new(0, 1.7, 0) + r.CFrame.LookVector * 0.85
	local rojo = Color3.fromRGB(255, 58, 58)
	local soporte =
		parteVfx(CFrame.new(pos), Vector3.one * 0.2, rojo, Enum.Material.SmoothPlastic, 1)
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(4.4, 4.4)
	cartel.LightInfluence = 0
	cartel.Parent = soporte
	local img = Instance.new("ImageLabel")
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromScale(1, 1)
	img.BackgroundTransparency = 1
	img.Image = EB.AvisoSuelo
	img.ImageColor3 = rojo
	img.Parent = cartel
	tween(img, 0.26, Enum.EasingStyle.Back, {
		Size = UDim2.fromScale(0.65, 0.65),
		ImageTransparency = 1,
	})
	EfectosGolpe.anillo3D(
		CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0),
		3.6,
		0.6,
		rojo,
		0.26,
		0.2
	)
	Debris:AddItem(soporte, 0.3)
end

-- Onda plana en el piso + anillo 3D nítido (+ grieta cómic en impactos grandes).
function EfectosGolpe.onda(centro: Vector3, radio: number, color: Color3)
	local soporte = parteVfx(
		CFrame.new(centro + Vector3.new(0, 0.3, 0)),
		Vector3.one * 0.2,
		color,
		Enum.Material.SmoothPlastic,
		1
	)
	emisorCapa(soporte, EB.OndaChoque, radio * 2.25, color, 0.32, 1, 0, 2, false, true)
	emisorCapa(soporte, EB.OndaChoque, radio * 1.45, NUCLEO, 0.22, 0.75, 45, 3, false, true)
	EfectosGolpe.anillo3D(
		CFrame.new(centro + Vector3.new(0, 0.35, 0)),
		radio * 0.25,
		radio * 1.15,
		color,
		0.3,
		0.28
	)
	if radio >= 10 then
		EfectosGolpe.grieta(centro, radio * 0.9, 1.5)
	end
	Debris:AddItem(soporte, 0.7)
end

return EfectosGolpe
