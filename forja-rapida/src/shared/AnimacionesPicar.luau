--!strict
-- Animaciones de picar del personaje (pedido B2, 25/10/2026), para R15. Como en
-- AnimacionesCorrer: las poses clave son datos y crear(nombre) arma la KeyframeSequence, así la
-- animación vive en git.
--   GolpeA    de derecha a izquierda (el pico baja desde arriba del hombro derecho).
--   GolpeB    de izquierda a derecha (revés: el pico sale de arriba del hombro izquierdo).
--   GolpeC    el fuerte: se agacha, salta chiquito con el pico arriba de la cabeza y las dos manos
--             y cae con todo el cuerpo.
--   Guardia   pose con el pico en la mano (solo de la cintura para arriba, en bucle): respira y
--             el pico se mueve apenas. Reemplaza la de sostener la herramienta de Roblox.
--   Descanso  al soltar después de picar mucho: se apoya el pico en el hombro (0,6 s), se queda
--             un rato y vuelve a la guardia (solo de la cintura para arriba).
-- Los golpes tienen 4 tiempos: carga (anticipación, el peso pasa al pie de atrás), golpe (rápido,
-- el cuerpo baja, el peso pasa al pie de adelante), contacto (unos cuadros quietos, el "hit-stop",
-- y el pico rebota) y vuelta a la guardia con superposición (brazo, después pico, después cabeza).
-- Markers: "Golpe" cuando arranca la bajada (prende la estela) e "Impacto" en el contacto.
-- Cada pose es { rx, ry, rz, px, py, pz } como en AnimacionesCorrer (grados y studs sobre la unión
-- de esa parte con su padre). En R15: rx positivo lleva brazos y piernas para adelante y el torso
-- para atrás; ry positivo gira hacia la izquierda; rz positivo levanta el lado derecho.
-- Cada clave puede tener "desfase" por parte: esa parte llega a la pose un poco antes o después
-- (así no frenan todas a la vez).
-- El pico se agarra como una espada (el mango sigue al antebrazo); la muñeca (RightHand) lo
-- inclina para que quede como un pico de verdad.

type Valores = { number }
type Pose = { [string]: Valores }
type Curva = { any } -- { Enum.PoseEasingStyle, Enum.PoseEasingDirection }
type Clave = {
	t: number, -- segundos
	pose: Pose,
	curva: Curva?, -- curva desde esta pose hasta la siguiente (todas las partes)
	desfase: { [string]: number }?,
	marcas: { string }?,
}
type Datos = {
	claves: { Clave },
	bucle: boolean,
	prioridad: Enum.AnimationPriority,
	partes: { string }, -- qué partes anima
}

local AnimacionesPicar = {}

AnimacionesPicar.Nombres = { "GolpeA", "GolpeB", "GolpeC", "Guardia", "Descanso" }

local CUBIC = Enum.PoseEasingStyle.CubicV2
local LINEAR = Enum.PoseEasingStyle.Linear
local IN = Enum.PoseEasingDirection.In
local OUT = Enum.PoseEasingDirection.Out
local INOUT = Enum.PoseEasingDirection.InOut

-- Árbol de R15: parte -> padre.
local PADRE: { [string]: string } = {
	LowerTorso = "HumanoidRootPart",
	UpperTorso = "LowerTorso",
	Head = "UpperTorso",
	LeftUpperArm = "UpperTorso",
	LeftLowerArm = "LeftUpperArm",
	LeftHand = "LeftLowerArm",
	RightUpperArm = "UpperTorso",
	RightLowerArm = "RightUpperArm",
	RightHand = "RightLowerArm",
	LeftUpperLeg = "LowerTorso",
	LeftLowerLeg = "LeftUpperLeg",
	LeftFoot = "LeftLowerLeg",
	RightUpperLeg = "LowerTorso",
	RightLowerLeg = "RightUpperLeg",
	RightFoot = "RightLowerLeg",
}
local TODO = {
	"LowerTorso",
	"UpperTorso",
	"Head",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}
local ARRIBA = {
	"UpperTorso",
	"Head",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
}

-- Copia una pose cambiando algunas partes.
local function con(base: Pose, cambios: Pose): Pose
	local r = table.clone(base)
	for n, v in cambios do
		r[n] = v
	end
	return r
end

-- Guardia -------------------------------------------------------------------------------------
-- Pie izquierdo adelante, cadera girada a la derecha, un poco agachado. El pico adelante con la
-- punta para arriba y la mano izquierda cerca del mango.
local PIERNAS_GUARDIA: Pose = {
	LowerTorso = { 0, -15, 0, 0, -0.15 },
	LeftUpperLeg = { 22, 8, 0 },
	LeftLowerLeg = { -30, 0, 0 },
	LeftFoot = { 8, 0, 0 },
	RightUpperLeg = { -8, 8, 0 },
	RightLowerLeg = { -18, 0, 0 },
	RightFoot = { 26, 0, 0 },
}
local GUARDIA: Pose = con(PIERNAS_GUARDIA, {
	UpperTorso = { -6, 12, 0 },
	Head = { 4, 4, 0 },
	RightUpperArm = { 25, 15, 10 },
	RightLowerArm = { 75, 0, 0 },
	RightHand = { 40, 0, 0 },
	LeftUpperArm = { 35, -25, -5 },
	LeftLowerArm = { 70, 0, 0 },
	LeftHand = { 10, 0, 0 },
})
-- respira: el pecho sube, los hombros acompañan y el pico cabecea apenas
local GUARDIA_AIRE: Pose = con(GUARDIA, {
	UpperTorso = { -4, 12, 0, 0, 0.04 },
	Head = { 2, 4, 0 },
	RightUpperArm = { 27, 15, 11 },
	RightHand = { 46, 0, 0 },
	LeftUpperArm = { 37, -25, -6 },
})

-- vuelta a la guardia: el brazo llega primero, después el pico, la cabeza al final
local SUPERPONE = {
	RightUpperArm = -0.04,
	RightLowerArm = -0.02,
	RightHand = 0.01,
	LeftUpperArm = 0.02,
	LeftLowerArm = 0.03,
	Head = 0.05,
	UpperTorso = -0.01,
}

-- Golpe A: de derecha a izquierda --------------------------------------------------------------
local A_CARGA: Pose = {
	LowerTorso = { 0, -32, 0, 0, -0.1, 0.18 },
	UpperTorso = { 6, -28, -6 },
	Head = { 0, 48, 0 },
	RightUpperArm = { 160, -20, 35 },
	RightLowerArm = { 70, 0, 0 },
	RightHand = { -15, 0, 0 },
	LeftUpperArm = { 70, 35, -10 },
	LeftLowerArm = { 20, 0, 0 },
	LeftHand = { 0, 0, 0 },
	LeftUpperLeg = { 22, 8, 0 },
	LeftLowerLeg = { -22, 0, 0 },
	LeftFoot = { 0, 0, 0 },
	RightUpperLeg = { -12, 8, 0 },
	RightLowerLeg = { -18, 0, 0 },
	RightFoot = { 40, 0, 0 },
}
local A_TENSION: Pose = con(A_CARGA, {
	UpperTorso = { 8, -34, -7 },
	Head = { 0, 52, 0 },
	RightUpperArm = { 170, -24, 38 },
	RightLowerArm = { 78, 0, 0 },
	RightHand = { -40, 0, 0 },
})
local A_IMPACTO: Pose = {
	LowerTorso = { 0, 20, 0, 0, -0.42, -0.22 },
	UpperTorso = { -22, 25, 4 },
	Head = { 12, -32, 0 },
	RightUpperArm = { 55, 35, 0 },
	RightLowerArm = { 8, 0, 0 },
	RightHand = { 35, 0, 0 },
	LeftUpperArm = { -25, 0, -35 },
	LeftLowerArm = { 40, 0, 0 },
	LeftHand = { 10, 0, 0 },
	LeftUpperLeg = { 42, -10, 0 },
	LeftLowerLeg = { -58, 0, 0 },
	LeftFoot = { 16, 0, 0 },
	RightUpperLeg = { -4, -10, 0 },
	RightLowerLeg = { -46, 0, 0 },
	RightFoot = { 30, 0, 0 },
}
local A_REBOTE: Pose = con(A_IMPACTO, {
	LowerTorso = { 0, 14, 0, 0, -0.32, -0.15 },
	UpperTorso = { -15, 20, 3 },
	RightUpperArm = { 82, 30, 5 },
	RightLowerArm = { 28, 0, 0 },
	RightHand = { 15, 0, 0 },
	LeftUpperArm = { -15, 0, -28 },
})

-- Golpe B: de izquierda a derecha (revés) -------------------------------------------------------
local B_CARGA: Pose = {
	LowerTorso = { 0, 12, 0, 0, -0.1, 0.12 },
	UpperTorso = { 5, 36, 5 },
	Head = { 0, -42, 0 },
	RightUpperArm = { 150, 60, -10 },
	RightLowerArm = { 95, 0, 0 },
	RightHand = { -45, 0, 0 },
	LeftUpperArm = { 20, -10, -40 },
	LeftLowerArm = { 50, 0, 0 },
	LeftHand = { 0, 0, 0 },
	LeftUpperLeg = { 20, -6, 0 },
	LeftLowerLeg = { -24, 0, 0 },
	LeftFoot = { 4, 0, 0 },
	RightUpperLeg = { -10, -6, 0 },
	RightLowerLeg = { -26, 0, 0 },
	RightFoot = { 36, 0, 0 },
}
local B_TENSION: Pose = con(B_CARGA, {
	UpperTorso = { 7, 42, 6 },
	Head = { 0, -46, 0 },
	RightUpperArm = { 160, 66, -10 },
	RightLowerArm = { 100, 0, 0 },
	RightHand = { -55, 0, 0 },
})
local B_IMPACTO: Pose = {
	LowerTorso = { 0, -28, 0, 0, -0.42, -0.22 },
	UpperTorso = { -22, -25, -4 },
	Head = { 12, 36, 0 },
	RightUpperArm = { 55, -25, 25 },
	RightLowerArm = { 10, 0, 0 },
	RightHand = { 35, 0, 0 },
	LeftUpperArm = { 30, 30, -10 },
	LeftLowerArm = { 60, 0, 0 },
	LeftHand = { 10, 0, 0 },
	LeftUpperLeg = { 42, 14, 0 },
	LeftLowerLeg = { -58, 0, 0 },
	LeftFoot = { 16, 0, 0 },
	RightUpperLeg = { -4, 14, 0 },
	RightLowerLeg = { -46, 0, 0 },
	RightFoot = { 30, 0, 0 },
}
local B_REBOTE: Pose = con(B_IMPACTO, {
	LowerTorso = { 0, -20, 0, 0, -0.32, -0.15 },
	UpperTorso = { -15, -20, -3 },
	RightUpperArm = { 82, -22, 22 },
	RightLowerArm = { 28, 0, 0 },
	RightHand = { 15, 0, 0 },
	LeftUpperArm = { 20, 25, -12 },
})

-- Golpe C: el fuerte, por arriba de la cabeza con las dos manos y un salto chiquito ------------
local C_AGACHA: Pose = { -- aplasta: junta fuerza para saltar
	LowerTorso = { 0, -5, 0, 0, -0.5, 0.05 },
	UpperTorso = { -16, 4, 0 },
	Head = { 10, 0, 0 },
	RightUpperArm = { 20, 10, 12 },
	RightLowerArm = { 40, 0, 0 },
	RightHand = { 60, 0, 0 },
	LeftUpperArm = { 25, -22, -6 },
	LeftLowerArm = { 45, 0, 0 },
	LeftHand = { 10, 0, 0 },
	LeftUpperLeg = { 50, 6, 0 },
	LeftLowerLeg = { -78, 0, 0 },
	LeftFoot = { 28, 0, 0 },
	RightUpperLeg = { 30, 6, 0 },
	RightLowerLeg = { -72, 0, 0 },
	RightFoot = { 42, 0, 0 },
}
local C_ARRIBA: Pose = { -- estira: en el aire, arqueado, el pico detrás de la cabeza
	LowerTorso = { 0, 0, 0, 0, 0.45, 0.1 },
	UpperTorso = { 18, 0, 0 },
	Head = { -10, 0, 0 },
	RightUpperArm = { 185, 10, 6 },
	RightLowerArm = { 60, 0, 0 },
	RightHand = { -35, 0, 0 },
	LeftUpperArm = { 185, -16, -6 },
	LeftLowerArm = { 60, 0, 0 },
	LeftHand = { 20, 0, 0 },
	LeftUpperLeg = { 18, 4, 0 },
	LeftLowerLeg = { -40, 0, 0 },
	LeftFoot = { -12, 0, 0 },
	RightUpperLeg = { 8, 4, 0 },
	RightLowerLeg = { -30, 0, 0 },
	RightFoot = { -16, 0, 0 },
}
local C_TENSION: Pose = con(C_ARRIBA, {
	UpperTorso = { 22, 0, 0 },
	RightUpperArm = { 192, 10, 6 },
	LeftUpperArm = { 192, -16, -6 },
	RightHand = { -42, 0, 0 },
	LowerTorso = { 0, 0, 0, 0, 0.5, 0.12 },
})
local C_IMPACTO: Pose = {
	LowerTorso = { 0, 0, 0, 0, -0.62, -0.3 },
	UpperTorso = { -35, 0, 0 },
	Head = { 22, 0, 0 },
	RightUpperArm = { 45, 15, 2 },
	RightLowerArm = { 5, 0, 0 },
	RightHand = { 30, 0, 0 },
	LeftUpperArm = { 50, -22, 0 },
	LeftLowerArm = { 15, 0, 0 },
	LeftHand = { 20, 0, 0 },
	LeftUpperLeg = { 48, 0, -10 },
	LeftLowerLeg = { -70, 0, 0 },
	LeftFoot = { 22, 0, 10 },
	RightUpperLeg = { 18, 0, 10 },
	RightLowerLeg = { -62, 0, 0 },
	RightFoot = { 44, 0, -10 },
}
local C_REBOTE: Pose = con(C_IMPACTO, {
	LowerTorso = { 0, 0, 0, 0, -0.4, -0.2 },
	UpperTorso = { -22, 0, 0 },
	RightUpperArm = { 85, 12, 4 },
	RightLowerArm = { 25, 0, 0 },
	RightHand = { 20, 0, 0 },
	LeftUpperArm = { 80, -20, 0 },
	LeftLowerArm = { 30, 0, 0 },
})

-- Descanso: el pico al hombro --------------------------------------------------------------------
local HOMBRO: Pose = {
	UpperTorso = { 4, -6, 0 },
	Head = { -4, 10, 0 },
	RightUpperArm = { 95, -5, 30 },
	RightLowerArm = { 115, 0, 0 },
	RightHand = { 30, 0, 0 },
	LeftUpperArm = { -6, 0, -8 },
	LeftLowerArm = { 18, 0, 0 },
	LeftHand = { 0, 0, 0 },
}
local HOMBRO_AIRE: Pose = con(HOMBRO, {
	UpperTorso = { 6, -6, 0, 0, 0.04 },
	Head = { -6, 10, 0 },
	RightUpperArm = { 97, -5, 31 },
})

-- Golpe de un lado (A o B): carga, tensión, golpe, contacto quieto, rebote y vuelta.
local function golpe(carga: Pose, tension: Pose, impacto: Pose, rebote: Pose): { Clave }
	return {
		{ t = 0, pose = GUARDIA, curva = { CUBIC, OUT } },
		{ t = 0.06, pose = carga, curva = { CUBIC, INOUT } },
		{ t = 0.095, pose = tension, curva = { CUBIC, IN }, marcas = { "Golpe" } },
		{ t = 0.14, pose = impacto, curva = { LINEAR, IN }, marcas = { "Impacto" } },
		{ t = 0.18, pose = impacto, curva = { CUBIC, OUT } }, -- hit-stop
		{ t = 0.23, pose = rebote, curva = { CUBIC, INOUT } },
		{ t = 0.38, pose = GUARDIA, desfase = SUPERPONE },
	}
end

local function datos(nombre: string): Datos
	if nombre == "GolpeA" then
		return {
			claves = golpe(A_CARGA, A_TENSION, A_IMPACTO, A_REBOTE),
			bucle = false,
			prioridad = Enum.AnimationPriority.Action,
			partes = TODO,
		}
	elseif nombre == "GolpeB" then
		return {
			claves = golpe(B_CARGA, B_TENSION, B_IMPACTO, B_REBOTE),
			bucle = false,
			prioridad = Enum.AnimationPriority.Action,
			partes = TODO,
		}
	elseif nombre == "GolpeC" then
		return {
			claves = {
				{ t = 0, pose = GUARDIA, curva = { CUBIC, OUT } },
				{ t = 0.07, pose = C_AGACHA, curva = { CUBIC, OUT } },
				{ t = 0.17, pose = C_ARRIBA, curva = { CUBIC, INOUT } },
				{ t = 0.2, pose = C_TENSION, curva = { CUBIC, IN }, marcas = { "Golpe" } },
				{ t = 0.25, pose = C_IMPACTO, curva = { LINEAR, IN }, marcas = { "Impacto" } },
				{ t = 0.31, pose = C_IMPACTO, curva = { CUBIC, OUT } }, -- hit-stop más largo
				{ t = 0.37, pose = C_REBOTE, curva = { CUBIC, INOUT } },
				{ t = 0.56, pose = GUARDIA, desfase = SUPERPONE },
			},
			bucle = false,
			prioridad = Enum.AnimationPriority.Action,
			partes = TODO,
		}
	elseif nombre == "Guardia" then
		return {
			claves = {
				{ t = 0, pose = GUARDIA, curva = { CUBIC, INOUT } },
				{
					t = 1.2,
					pose = GUARDIA_AIRE,
					curva = { CUBIC, INOUT },
					desfase = { Head = 0.15 },
				},
				{ t = 2.4, pose = GUARDIA },
			},
			bucle = true,
			prioridad = Enum.AnimationPriority.Idle,
			partes = ARRIBA,
		}
	elseif nombre == "Descanso" then
		return {
			claves = {
				{ t = 0, pose = GUARDIA, curva = { CUBIC, IN } },
				{
					t = 0.6,
					pose = HOMBRO,
					curva = { CUBIC, INOUT },
					desfase = { RightHand = 0.06, Head = 0.1 },
				},
				{ t = 1.1, pose = HOMBRO_AIRE, curva = { CUBIC, INOUT } },
				{ t = 1.6, pose = HOMBRO, curva = { CUBIC, INOUT }, marcas = { "Fin" } },
				{ t = 2.0, pose = GUARDIA, desfase = SUPERPONE },
			},
			bucle = false,
			prioridad = Enum.AnimationPriority.Action,
			partes = ARRIBA,
		}
	end
	error("Animación desconocida: " .. nombre)
end

-- Momento de cada marker (para el cliente: cuándo puede arrancar el golpe siguiente).
function AnimacionesPicar.momento(nombre: string, marca: string): number?
	for _, c in datos(nombre).claves do
		if c.marcas and table.find(c.marcas, marca) then
			return c.t
		end
	end
	return nil
end

local function cframe(v: Valores?): CFrame
	if not v then
		return CFrame.identity
	end
	local rx, ry, rz = math.rad(v[1] or 0), math.rad(v[2] or 0), math.rad(v[3] or 0)
	return CFrame.new(v[4] or 0, v[5] or 0, v[6] or 0) * CFrame.fromOrientation(rx, ry, rz)
end

type Punto = { pose: Valores, curva: Curva }

-- Arma la KeyframeSequence. Cada parte tiene sus propios momentos (por el desfase): en los
-- cuadros donde una parte no tiene clave va una pose con Weight 0, que solo sostiene a sus hijas.
function AnimacionesPicar.crear(nombre: string): KeyframeSequence
	local d = datos(nombre)
	local porParte: { [string]: { [number]: Punto } } = {}
	local marcas: { [number]: { string } } = {}
	local tiempos: { [number]: boolean } = {}
	local function ms(t: number): number
		return math.floor(t * 1000 + 0.5)
	end
	for _, c in d.claves do
		for _, parte in d.partes do
			local v = c.pose[parte]
			if v then
				local t = ms(math.max(0, c.t + (c.desfase and c.desfase[parte] or 0)))
				porParte[parte] = porParte[parte] or {}
				porParte[parte][t] = { pose = v, curva = c.curva or { CUBIC, INOUT } }
				tiempos[t] = true
			end
		end
		if c.marcas then
			marcas[ms(c.t)] = c.marcas
			tiempos[ms(c.t)] = true
		end
	end
	local orden = {}
	for t in tiempos do
		table.insert(orden, t)
	end
	table.sort(orden)

	local ks = Instance.new("KeyframeSequence")
	ks.Name = nombre
	ks.Loop = d.bucle
	ks.Priority = d.prioridad
	for _, t in orden do
		local kf = Instance.new("Keyframe")
		kf.Time = t / 1000
		local raiz = Instance.new("Pose")
		raiz.Name = "HumanoidRootPart"
		raiz.Weight = 0
		raiz.Parent = kf
		local poses: { [string]: Pose | any } = { HumanoidRootPart = raiz }
		local function poseDe(parte: string): Instance
			local p = poses[parte]
			if p then
				return p
			end
			local nueva = Instance.new("Pose")
			nueva.Name = parte
			nueva.Weight = 0
			nueva.Parent = poseDe(PADRE[parte])
			poses[parte] = nueva
			return nueva
		end
		for _, parte in TODO do
			local punto = porParte[parte] and porParte[parte][t]
			if punto then
				local p = poseDe(parte) :: Pose
				p.CFrame = cframe(punto.pose)
				p.Weight = 1
				p.EasingStyle = punto.curva[1] :: Enum.PoseEasingStyle
				p.EasingDirection = punto.curva[2] :: Enum.PoseEasingDirection
			end
		end
		for _, m in marcas[t] or {} do
			local marca = Instance.new("KeyframeMarker")
			marca.Name = m
			kf:AddMarker(marca)
		end
		kf.Parent = ks
	end
	return ks
end

return AnimacionesPicar
