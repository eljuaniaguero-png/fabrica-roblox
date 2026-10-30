--!strict
-- Animaciones de correr del personaje (pedido B1, 25/10/2026). Estilo caricatura de juego de
-- plataformas, para R15. Acá están las poses clave como datos y la función que arma cada
-- KeyframeSequence; así la animación vive en git.
--   Correr      ciclo de 0,55 s (12 poses + la de cierre), con Pisada_Der y Pisada_Izq.
--   CorrerPico  el mismo ciclo con el brazo derecho más quieto (lleva el pico).
--   Arranque    anticipación + 3 pasos que aceleran, cuerpo más inclinado. Termina en la
--               pisada izquierda, que es la mitad del ciclo de Correr (se sigue desde ahí).
--   Frenada     derrape corto: pierna adelante, cuerpo atrás, brazos para equilibrar.
--   Salto       salto desde correr: rodilla arriba, brazo contrario arriba. En el marker Fin
--               el cliente la congela hasta tocar el piso.
-- Cada pose es { rx, ry, rz, px, py, pz } en grados y studs, sobre la unión de esa parte con su
-- padre (como el Transform de la unión). En R15: rx positivo lleva piernas y brazos para
-- adelante y el torso para atrás; ry positivo gira hacia la izquierda (el lado derecho va
-- adelante); rz positivo levanta el lado derecho. El ciclo se escribe para medio paso
-- (pisa la derecha) y la otra mitad sale en espejo.
-- Para probar en Studio: KeyframeSequenceProvider:RegisterKeyframeSequence(crear(nombre)).
-- Para el juego publicado hay que publicarlas y anotar los IDs en GameConfig.Animaciones.

type Valores = { number }
type Pose = { [string]: Valores }
type Clave = {
	t: number, -- segundos
	pose: Pose,
	piernas: { Enum.PoseEasingStyle | Enum.PoseEasingDirection }?, -- curva de piernas y cadera
	marcas: { string }?,
}

local AnimacionesCorrer = {}

AnimacionesCorrer.Nombres = { "Correr", "CorrerPico", "Arranque", "Frenada", "Salto" }
AnimacionesCorrer.Ciclo = 0.55 -- segundos de un ciclo de Correr (dos pasos)

-- Árbol de R15: parte -> padre (la pose de cada parte va adentro de la de su padre).
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
local PARTES = {
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
local PIERNAS = {
	LowerTorso = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

local function espejoNombre(n: string): string
	if n:sub(1, 4) == "Left" then
		return "Right" .. n:sub(5)
	elseif n:sub(1, 5) == "Right" then
		return "Left" .. n:sub(6)
	end
	return n
end

-- Espejo izquierda/derecha: se cambian los lados y se invierten los giros en y, z y el x.
local function espejo(p: Pose): Pose
	local r: Pose = {}
	for n, v in p do
		r[espejoNombre(n)] =
			{ v[1] or 0, -(v[2] or 0), -(v[3] or 0), -(v[4] or 0), v[5] or 0, v[6] or 0 }
	end
	return r
end

-- Mezcla de dos poses (para el arranque y el brazo del pico).
local function escalar(p: Pose, f: { [string]: number }, extra: Pose?): Pose
	local r: Pose = {}
	for n, v in p do
		local k = f[n] or 1
		local e = extra and extra[n] or {}
		r[n] = {}
		for i = 1, 6 do
			r[n][i] = (v[i] or 0) * k + (e[i] or 0)
		end
	end
	return r
end

-- Ciclo de correr: medio ciclo (pisa la derecha), 6 poses ------------------------------------
-- 1 contacto (talón adelante), 2 amortigua (la cadera baja, la pierna se aplasta), 3 medio
-- apoyo, 4 empuje (la pierna se estira), 5 vuelo alto, 6 cae hacia la otra pisada. Los brazos
-- llegan a su punto máximo una pose después que las piernas (superposición), y la cabeza
-- cabecea con retraso.
local MEDIO: { Pose } = {
	{ -- 1 contacto derecho
		LowerTorso = { -12, 8, 0, 0, -0.2 },
		UpperTorso = { -5, -14, 0 },
		Head = { 13, 6, 0 },
		RightUpperLeg = { 53, 0, 0 },
		RightLowerLeg = { -12, 0, 0 },
		RightFoot = { 12, 0, 0 },
		LeftUpperLeg = { -19, 0, 0 },
		LeftLowerLeg = { -55, 0, 0 },
		LeftFoot = { -25, 0, 0 },
		RightUpperArm = { -46, -6, 16 },
		RightLowerArm = { 65, 0, 0 },
		RightHand = { -10, 0, 0 },
		LeftUpperArm = { 60, -12, -8 },
		LeftLowerArm = { 100, 0, 0 },
		LeftHand = { 8, 0, 0 },
	},
	{ -- 2 amortigua: punto más bajo, pierna de apoyo aplastada
		LowerTorso = { -14, 6, 3, 0, -0.24 },
		UpperTorso = { -7, -12, -3 },
		Head = { 14, 6, 0 },
		RightUpperLeg = { 31, 0, 0 },
		RightLowerLeg = { -38, 0, 0, 0, 0.08 },
		RightFoot = { -2, 0, 0 },
		LeftUpperLeg = { -5, 0, 0 },
		LeftLowerLeg = { -100, 0, 0 },
		LeftFoot = { -15, 0, 0 },
		RightUpperArm = { -55, -6, 17 },
		RightLowerArm = { 60, 0, 0 },
		RightHand = { -5, 0, 0 },
		LeftUpperArm = { 71, -15, -8 },
		LeftLowerArm = { 105, 0, 0 },
		LeftHand = { 12, 0, 0 },
	},
	{ -- 3 medio apoyo (la otra pierna pasa doblada)
		LowerTorso = { -13, 2, 2, 0, -0.14 },
		UpperTorso = { -6, -5, -2 },
		Head = { 11, 3, 0 },
		RightUpperLeg = { 11, 0, 0 },
		RightLowerLeg = { -32, 0, 0, 0, 0.04 },
		RightFoot = { 5, 0, 0 },
		LeftUpperLeg = { 21, 0, 0 },
		LeftLowerLeg = { -115, 0, 0 },
		LeftFoot = { -5, 0, 0 },
		RightUpperArm = { -32, -2, 14 },
		RightLowerArm = { 70, 0, 0 },
		RightHand = { 0, 0, 0 },
		LeftUpperArm = { 46, -8, -10 },
		LeftLowerArm = { 95, 0, 0 },
		LeftHand = { 5, 0, 0 },
	},
	{ -- 4 empuje: la pierna de apoyo se estira y la punta empuja
		LowerTorso = { -11, -3, 0, 0, -0.02 },
		UpperTorso = { -4, 5, 0 },
		Head = { 13, -2, 0 },
		RightUpperLeg = { -17, 0, 0 },
		RightLowerLeg = { -8, 0, 0, 0, -0.08 },
		RightFoot = { -28, 0, 0 },
		LeftUpperLeg = { 45, 0, 0 },
		LeftLowerLeg = { -85, 0, 0 },
		LeftFoot = { 0, 0, 0 },
		RightUpperArm = { 6, 3, 12 },
		RightLowerArm = { 85, 0, 0 },
		RightHand = { 5, 0, 0 },
		LeftUpperArm = { 6, 0, -12 },
		LeftLowerArm = { 85, 0, 0 },
		LeftHand = { 0, 0, 0 },
	},
	{ -- 5 vuelo: punto más alto
		LowerTorso = { -11, -6, -1, 0, 0.3 },
		UpperTorso = { -4, 11, 1 },
		Head = { 15, -5, 0 },
		RightUpperLeg = { -25, 0, 0 },
		RightLowerLeg = { -30, 0, 0 },
		RightFoot = { -30, 0, 0 },
		LeftUpperLeg = { 55, 0, 0 },
		LeftLowerLeg = { -40, 0, 0 },
		LeftFoot = { 5, 0, 0 },
		RightUpperArm = { 40, 10, 9 },
		RightLowerArm = { 95, 0, 0 },
		RightHand = { 10, 0, 0 },
		LeftUpperArm = { -32, 5, -15 },
		LeftLowerArm = { 72, 0, 0 },
		LeftHand = { -8, 0, 0 },
	},
	{ -- 6 cae: la pierna izquierda se estira hacia la pisada
		LowerTorso = { -11.5, -8, 0, 0, 0.2 },
		UpperTorso = { -5, 14, 0 },
		Head = { 14, -6, 0 },
		RightUpperLeg = { -25, 0, 0 },
		RightLowerLeg = { -45, 0, 0 },
		RightFoot = { -28, 0, 0 },
		LeftUpperLeg = { 56, 0, 0 },
		LeftLowerLeg = { -14, 0, 0 },
		LeftFoot = { 12, 0, 0 },
		RightUpperArm = { 57, 12, 8 },
		RightLowerArm = { 100, 0, 0 },
		RightHand = { 8, 0, 0 },
		LeftUpperArm = { -46, 6, -16 },
		LeftLowerArm = { 65, 0, 0 },
		LeftHand = { -10, 0, 0 },
	},
}

-- Curva de piernas y cadera desde cada pose hasta la siguiente: el apoyo y el empuje van parejos
-- (Linear) para que el pie no patine, el vuelo flota arriba y la caída acelera.
local CURVAS: { { any } } = {
	{ Enum.PoseEasingStyle.Linear, Enum.PoseEasingDirection.In },
	{ Enum.PoseEasingStyle.Linear, Enum.PoseEasingDirection.In },
	{ Enum.PoseEasingStyle.Linear, Enum.PoseEasingDirection.In },
	{ Enum.PoseEasingStyle.CubicV2, Enum.PoseEasingDirection.Out },
	{ Enum.PoseEasingStyle.CubicV2, Enum.PoseEasingDirection.InOut },
	{ Enum.PoseEasingStyle.CubicV2, Enum.PoseEasingDirection.In },
}

-- En qué parte de cada medio ciclo cae cada pose (0 a 1). El apoyo es corto (la pierna toca el
-- piso un cuarto del paso) y el vuelo largo, como en un juego de plataformas: así el pie recorre
-- lo mismo que avanza el cuerpo sin que el ciclo pase de 0,55 s.
local MOMENTOS = { 0, 0.08, 0.16, 0.24, 0.58, 0.82 }

local function cicloCompleto(): { Pose }
	local r = {}
	for _, p in MEDIO do
		table.insert(r, p)
	end
	for _, p in MEDIO do
		table.insert(r, espejo(p))
	end
	return r
end

local function clavesCiclo(poses: { Pose }): { Clave }
	local T = AnimacionesCorrer.Ciclo
	local n = #poses
	local claves: { Clave } = {}
	for i, p in poses do
		local marcas = if i == 1
			then { "Pisada_Der" }
			elseif i == n / 2 + 1 then { "Pisada_Izq" }
			else nil
		table.insert(claves, {
			t = (math.floor((i - 1) / 6) + MOMENTOS[(i - 1) % 6 + 1]) * T / 2,
			pose = p,
			piernas = CURVAS[(i - 1) % 6 + 1],
			marcas = marcas,
		})
	end
	table.insert(claves, { t = T, pose = poses[1] }) -- cierre del bucle
	return claves
end

-- Brazo derecho con el pico: se mueve un tercio y queda doblado adelante (el pico se balancea
-- con retraso desde el cliente, que mueve el agarre).
local function conPico(p: Pose): Pose
	local a = p.RightUpperArm
	local r = table.clone(p)
	r.RightUpperArm = { 15 + a[1] * 0.3, 0, 8 + (a[3] - 8) * 0.3 }
	r.RightLowerArm = { 70 + (p.RightLowerArm[1] - 80) * 0.2, 0, 0 }
	r.RightHand = { -10, 0, 0 }
	return r
end

-- Arranque: anticipación (se agacha y carga) y 3 pasos que van de más cortos e inclinados a
-- los del ciclo. Termina con la pose de la pisada izquierda del ciclo.
local function clavesArranque(): { Clave }
	local ciclo = cicloCompleto()
	local claves: { Clave } = {}
	table.insert(claves, {
		t = 0,
		pose = {
			LowerTorso = { -16, 0, 0, 0, -0.45 },
			UpperTorso = { -10, -8, 0 },
			Head = { 18, 4, 0 },
			RightUpperLeg = { 30, 0, 0 },
			RightLowerLeg = { -50, 0, 0, 0, 0.08 },
			RightFoot = { 10, 0, 0 },
			LeftUpperLeg = { 10, 0, 0 },
			LeftLowerLeg = { -40, 0, 0 },
			LeftFoot = { 15, 0, 0 },
			RightUpperArm = { -55, 0, 14 },
			RightLowerArm = { 50, 0, 0 },
			RightHand = { -10, 0, 0 },
			LeftUpperArm = { 40, -10, -6 },
			LeftLowerArm = { 95, 0, 0 },
			LeftHand = { 10, 0, 0 },
		},
		piernas = { Enum.PoseEasingStyle.CubicV2, Enum.PoseEasingDirection.Out },
	})
	-- pasos: duración de medio ciclo y cuánto de más se inclina y bombea
	local pasos = { { 0.2, 1 }, { 0.24, 0.6 }, { 0.26, 0.25 } }
	local t = 0.1
	for paso, datos in pasos do
		local dura, fuerza = datos[1], datos[2]
		local desde = if paso % 2 == 1 then 0 else 6 -- paso 1 y 3 pisa la derecha
		for k = 1, 6 do
			local base = ciclo[desde + k]
			local extra: Pose = {
				LowerTorso = { -10 * fuerza, 0, 0, 0, -0.15 * fuerza },
				UpperTorso = { -6 * fuerza, 0, 0 },
				Head = { 14 * fuerza, 0, 0 },
				-- las piernas se compensan para que la inclinación no las lleve para atrás
				LeftUpperLeg = { 10 * fuerza, 0, 0 },
				RightUpperLeg = { 10 * fuerza, 0, 0 },
			}
			local brazos = 1 + 0.25 * fuerza
			local pose = escalar(base, {
				LeftUpperArm = brazos,
				RightUpperArm = brazos,
				-- vuelo más bajo al principio
				LowerTorso = 1,
			}, extra)
			pose.LowerTorso[5] = base.LowerTorso[5] * (1 - 0.5 * fuerza) - 0.15 * fuerza
			local marcas = if k == 1
				then { if desde == 0 then "Pisada_Der" else "Pisada_Izq" }
				else nil
			table.insert(
				claves,
				{ t = t + MOMENTOS[k] * dura, pose = pose, piernas = CURVAS[k], marcas = marcas }
			)
		end
		t += dura
	end
	table.insert(claves, { t = t, pose = ciclo[7], marcas = { "Pisada_Izq", "Fin" } })
	return claves
end

-- Frenada: clava la pierna derecha adelante y derrapa con el cuerpo para atrás, los brazos se
-- abren para no caerse, rebota un poco para adelante y queda parado.
local function clavesFrenada(): { Clave }
	local C = Enum.PoseEasingStyle.CubicV2
	local D = Enum.PoseEasingDirection
	return {
		{ t = 0, pose = MEDIO[5], piernas = { C, D.Out } },
		{
			t = 0.08,
			pose = {
				LowerTorso = { 24, 12, 0, 0, -0.45, -0.3 },
				UpperTorso = { 8, -6, 0 },
				Head = { -16, -4, 0 },
				RightUpperLeg = { 35, 0, 0 },
				RightLowerLeg = { -8, 0, 0, 0, -0.06 },
				RightFoot = { 25, 0, 0 },
				LeftUpperLeg = { -42, 0, 0 },
				LeftLowerLeg = { -85, 0, 0, 0, 0.06 },
				LeftFoot = { -20, 0, 0 },
				RightUpperArm = { 55, 0, 40 },
				RightLowerArm = { 40, 0, 0 },
				RightHand = { 15, 0, 0 },
				LeftUpperArm = { 80, 0, -30 },
				LeftLowerArm = { 30, 0, 0 },
				LeftHand = { 15, 0, 0 },
			},
			piernas = { Enum.PoseEasingStyle.Linear, D.In },
			marcas = { "Derrape" },
		},
		{
			t = 0.24,
			pose = {
				LowerTorso = { 20, 10, 0, 0, -0.5, -0.9 },
				UpperTorso = { 2, -4, 0 },
				Head = { -14, -3, 0 },
				RightUpperLeg = { 32, 0, 0 },
				RightLowerLeg = { -14, 0, 0 },
				RightFoot = { 22, 0, 0 },
				LeftUpperLeg = { -32, 0, 0 },
				LeftLowerLeg = { -95, 0, 0, 0, 0.08 },
				LeftFoot = { -18, 0, 0 },
				RightUpperArm = { 40, 0, 48 },
				RightLowerArm = { 35, 0, 0 },
				RightHand = { 10, 0, 0 },
				LeftUpperArm = { 65, 0, -42 },
				LeftLowerArm = { 30, 0, 0 },
				LeftHand = { 10, 0, 0 },
			},
			piernas = { C, D.InOut },
		},
		{
			t = 0.36,
			pose = { -- rebote para adelante (sigue de largo y vuelve)
				LowerTorso = { -5, 3, 0, 0, -0.15, -0.6 },
				UpperTorso = { -6, 0, 0 },
				Head = { 6, 0, 0 },
				RightUpperLeg = { 18, 0, 0 },
				RightLowerLeg = { -20, 0, 0 },
				RightFoot = { 4, 0, 0 },
				LeftUpperLeg = { 5, 0, 0 },
				LeftLowerLeg = { -25, 0, 0 },
				LeftFoot = { 10, 0, 0 },
				RightUpperArm = { 10, 0, 18 },
				RightLowerArm = { 30, 0, 0 },
				RightHand = { 0, 0, 0 },
				LeftUpperArm = { 15, 0, -18 },
				LeftLowerArm = { 30, 0, 0 },
				LeftHand = { 0, 0, 0 },
			},
			piernas = { C, D.Out },
		},
		{
			t = 0.5,
			pose = {
				LowerTorso = { 0, 0, 0, 0, 0, -0.5 },
				RightUpperArm = { 0, 0, 5 },
				LeftUpperArm = { 0, 0, -5 },
			},
			marcas = { "Fin" },
		},
	}
end

-- Salto desde correr: sale empujando con la izquierda, la rodilla derecha sube, el brazo
-- izquierdo va arriba y el derecho atrás; en el aire se abre un poco y queda así hasta caer.
local function clavesSalto(): { Clave }
	local C = Enum.PoseEasingStyle.CubicV2
	local D = Enum.PoseEasingDirection
	local claves: { Clave } = {
		{ t = 0, pose = MEDIO[4], piernas = { C, D.Out } },
		{
			t = 0.12,
			pose = {
				LowerTorso = { -12, 6, 0, 0, 0.2 },
				UpperTorso = { -4, -8, 0 },
				Head = { 8, 2, 0 },
				RightUpperLeg = { 80, 0, 0 },
				RightLowerLeg = { -95, 0, 0 },
				RightFoot = { -10, 0, 0 },
				LeftUpperLeg = { -25, 0, 0 },
				LeftLowerLeg = { -15, 0, 0, 0, -0.06 },
				LeftFoot = { -35, 0, 0 },
				RightUpperArm = { -45, 0, 20 },
				RightLowerArm = { 55, 0, 0 },
				RightHand = { -10, 0, 0 },
				LeftUpperArm = { 140, 0, -10 },
				LeftLowerArm = { 35, 0, 0 },
				LeftHand = { 10, 0, 0 },
			},
			piernas = { C, D.InOut },
		},
		{
			t = 0.32,
			pose = {
				LowerTorso = { -6, 4, 0, 0, 0.1 },
				UpperTorso = { -2, -5, 0 },
				Head = { 4, 1, 0 },
				RightUpperLeg = { 65, 0, 0 },
				RightLowerLeg = { -80, 0, 0 },
				RightFoot = { 0, 0, 0 },
				LeftUpperLeg = { -5, 0, 0 },
				LeftLowerLeg = { -40, 0, 0 },
				LeftFoot = { -20, 0, 0 },
				RightUpperArm = { -25, 0, 35 },
				RightLowerArm = { 45, 0, 0 },
				RightHand = { 0, 0, 0 },
				LeftUpperArm = { 115, 0, -25 },
				LeftLowerArm = { 40, 0, 0 },
				LeftHand = { 5, 0, 0 },
			},
			marcas = { "Fin" },
		},
	}
	-- la misma pose un rato más: el marker Fin queda antes del final y la pista no se apaga sola
	table.insert(claves, { t = 0.45, pose = claves[3].pose })
	return claves
end

local function claves(nombre: string): ({ Clave }, boolean)
	if nombre == "Correr" then
		return clavesCiclo(cicloCompleto()), true
	elseif nombre == "CorrerPico" then
		local poses = {}
		for _, p in cicloCompleto() do
			table.insert(poses, conPico(p))
		end
		return clavesCiclo(poses), true
	elseif nombre == "Arranque" then
		return clavesArranque(), false
	elseif nombre == "Frenada" then
		return clavesFrenada(), false
	elseif nombre == "Salto" then
		return clavesSalto(), false
	end
	error("Animación desconocida: " .. nombre)
end

local function cframe(v: Valores?): CFrame
	if not v then
		return CFrame.identity
	end
	local rx, ry, rz = math.rad(v[1] or 0), math.rad(v[2] or 0), math.rad(v[3] or 0)
	return CFrame.new(v[4] or 0, v[5] or 0, v[6] or 0) * CFrame.fromOrientation(rx, ry, rz)
end

-- Arma la KeyframeSequence (Priority Movement). Los brazos y la cabeza van con curvas suaves
-- (CubicV2 InOut) y las piernas con la curva de cada pose.
function AnimacionesCorrer.crear(nombre: string): KeyframeSequence
	local lista, bucle = claves(nombre)
	local ks = Instance.new("KeyframeSequence")
	ks.Name = nombre
	ks.Loop = bucle
	ks.Priority = Enum.AnimationPriority.Movement
	for _, c in lista do
		local kf = Instance.new("Keyframe")
		kf.Time = c.t
		local raiz = Instance.new("Pose")
		raiz.Name = "HumanoidRootPart"
		raiz.Weight = 0
		raiz.Parent = kf
		local poses: { [string]: Instance } = { HumanoidRootPart = raiz }
		for _, parte in PARTES do
			local p = Instance.new("Pose")
			p.Name = parte
			p.CFrame = cframe(c.pose[parte])
			p.Weight = 1
			local curva = c.piernas
			if PIERNAS[parte] and curva then
				p.EasingStyle = curva[1] :: Enum.PoseEasingStyle
				p.EasingDirection = curva[2] :: Enum.PoseEasingDirection
			else
				p.EasingStyle = Enum.PoseEasingStyle.CubicV2
				p.EasingDirection = Enum.PoseEasingDirection.InOut
			end
			poses[parte] = p
		end
		for _, parte in PARTES do
			poses[parte].Parent = poses[PADRE[parte]]
		end
		for _, m in c.marcas or {} do
			local marca = Instance.new("KeyframeMarker")
			marca.Name = m
			kf:AddMarker(marca)
		end
		kf.Parent = ks
	end
	return ks
end

return AnimacionesCorrer
