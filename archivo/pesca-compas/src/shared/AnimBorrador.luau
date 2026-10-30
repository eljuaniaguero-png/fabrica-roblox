--!strict
-- Borrador de las 5 animaciones de pesca, escritas como datos (rig R15). Sirve para dos cosas:
--   1. Probar en Studio sin publicar nada: AnimPesca usa idTemporal() cuando el Id de
--      shared/Animaciones está vacío (KeyframeSequenceProvider, solo funciona en Studio).
--   2. Publicarlas: arte/animaciones/guardar_para_publicar.luau las deja como KeyframeSequence
--      en ServerStorage; clic derecho > "Save to Roblox" y se pega el id en Animaciones.luau.
-- No se hacen en Blender a propósito: el FBX necesita la pose de reposo exacta del R15 y los
-- marcadores ("Agarrar", "VFX"...) no viajan en el FBX. Acá van adentro de la animación.
--
-- Ángulos en grados, {x, y, z}, sobre el Transform de cada Motor6D (el nombre es la Part1):
--   brazos/codos +x = adelante y arriba · UpperTorso +x = se echa atrás, -x = se encorva
--   Head -x = mira abajo, y = gira (niega) · brazo derecho +z = hacia afuera, izquierdo -z.
-- Solo animan del torso para arriba: LowerTorso va con peso 0, así se puede caminar.

local Animaciones = require(script.Parent:WaitForChild("Animaciones"))

type Rot = { number }
type Poses = { [string]: Rot }
type Cuadro = {
	T: number,
	Poses: Poses,
	Estilo: Enum.PoseEasingStyle?, -- cómo se llega a este cuadro desde el anterior
	Marcas: { string }?,
}
export type Datos = {
	Loop: boolean,
	Prioridad: Enum.AnimationPriority,
	Cuadros: { Cuadro },
}

-- Part1 -> Part0 (cadena R15 de la cintura para arriba)
local PADRE: { [string]: string } = {
	LowerTorso = "HumanoidRootPart",
	UpperTorso = "LowerTorso",
	Head = "UpperTorso",
	RightUpperArm = "UpperTorso",
	RightLowerArm = "RightUpperArm",
	RightHand = "RightLowerArm",
	LeftUpperArm = "UpperTorso",
	LeftLowerArm = "LeftUpperArm",
	LeftHand = "LeftLowerArm",
}
local SIN_PESO = { HumanoidRootPart = true, LowerTorso = true }

local function con(base: Poses, cambios: Poses): Poses
	local p = table.clone(base)
	for k, v in cambios do
		p[k] = v
	end
	return p
end

-- Pose base: la caña imaginaria agarrada con las dos manos, apuntando al agua
local CANA: Poses = {
	UpperTorso = { -5, 0, 0 },
	Head = { -8, 0, 0 },
	RightUpperArm = { 55, 0, -28 },
	RightLowerArm = { 35, 0, 0 },
	RightHand = { -20, 0, 0 },
	LeftUpperArm = { 40, 0, 38 },
	LeftLowerArm = { 40, 0, 0 },
}
local SUELTO: Poses = {} -- todo en reposo

local S = Enum.PoseEasingStyle
local A, B, F = Animaciones.AGARRAR, Animaciones.BAJAR, Animaciones.FIN

-- Levantar: brazos arriba con el pez, mirando arriba y echado para atrás
local ARRIBA: Poses = {
	UpperTorso = { 8, 0, 0 },
	Head = { 15, 0, 0 },
	RightUpperArm = { 160, 0, -14 },
	RightLowerArm = { 15, 0, 0 },
	LeftUpperArm = { 160, 0, 14 },
	LeftLowerArm = { 15, 0, 0 },
}

local DATOS: { [string]: Datos } = {
	-- 2.4 s en loop: la punta de la caña sube y baja apenas, el torso se balancea
	Esperar = {
		Loop = true,
		Prioridad = Enum.AnimationPriority.Action,
		Cuadros = {
			{ T = 0, Poses = CANA },
			{ T = 1.2, Poses = con(CANA, { UpperTorso = { -3, 4, 0 }, RightUpperArm = { 50, 0, -10 }, LeftUpperArm = { 41, 0, 25 } }), Estilo = S.Cubic },
			{ T = 2.4, Poses = CANA, Estilo = S.Cubic },
		},
	},
	-- 1.36 s en loop = medio compás a 88 BPM (2 tirones por compás). Tirón seco, vuelta lenta.
	Recoger = {
		Loop = true,
		Prioridad = Enum.AnimationPriority.Action,
		Cuadros = {
			{ T = 0, Poses = CANA },
			{ T = 0.12, Poses = con(CANA, { UpperTorso = { 6, 0, 0 }, RightUpperArm = { 80, 0, -10 }, RightLowerArm = { 55, 0, 0 }, LeftUpperArm = { 65, 0, 25 }, LeftLowerArm = { 55, 0, 0 } }), Estilo = S.Cubic },
			{ T = 0.6, Poses = CANA, Estilo = S.Cubic },
			{ T = 1.36, Poses = CANA, Estilo = S.Linear },
		},
	},
	-- 0.5 s: carga por arriba del hombro derecho y latigazo. "Soltar" = la caña apunta al agua.
	Lanzar = {
		Loop = false,
		Prioridad = Enum.AnimationPriority.Action2,
		Cuadros = {
			{ T = 0, Poses = CANA },
			{ T = 0.18, Poses = con(CANA, { UpperTorso = { 10, -20, 0 }, Head = { 0, -10, 0 }, RightUpperArm = { 170, 0, 5 }, RightLowerArm = { 60, 0, 0 }, LeftUpperArm = { 60, 0, 25 } }), Estilo = S.Cubic },
			{ T = 0.3, Poses = con(CANA, { UpperTorso = { -10, 10, 0 }, Head = { -10, 0, 0 }, RightUpperArm = { 70, 0, -10 }, RightLowerArm = { 10, 0, 0 } }), Estilo = S.Cubic, Marcas = { "Soltar" } },
			{ T = 0.5, Poses = CANA, Estilo = S.Cubic },
		},
	},
	-- 2.8 s: el momento de la foto. "Agarrar" y "VFX" cuando el pez llega a las manos.
	Levantar = {
		Loop = false,
		Prioridad = Enum.AnimationPriority.Action2,
		Cuadros = {
			{ T = 0, Poses = CANA },
			{ T = A - 0.1, Poses = ARRIBA, Estilo = S.Cubic },
			-- el peso del pez hunde los brazos
			{ T = A, Poses = con(ARRIBA, { UpperTorso = { 4, 0, 0 }, RightUpperArm = { 148, 0, -14 }, RightLowerArm = { 30, 0, 0 }, LeftUpperArm = { 148, 0, 14 }, LeftLowerArm = { 30, 0, 0 } }), Estilo = S.Cubic, Marcas = { "Agarrar", "VFX" } },
			{ T = A + 0.25, Poses = ARRIBA, Estilo = S.Bounce },
			-- lo muestra: un vaivén de orgullo
			{ T = 1.6, Poses = con(ARRIBA, { UpperTorso = { 8, 10, 0 }, Head = { 15, 8, 0 } }), Estilo = S.Cubic },
			{ T = B, Poses = con(ARRIBA, { UpperTorso = { 8, -6, 0 }, Head = { 15, -5, 0 } }), Estilo = S.Cubic, Marcas = { "Bajar" } },
			{ T = F, Poses = con(SUELTO, { RightUpperArm = { 40, 0, 0 }, LeftUpperArm = { 40, 0, 0 } }), Estilo = S.Cubic },
		},
	},
	-- 1 s: se escapó. Hombros caídos, se encorva y niega con la cabeza.
	Fallar = {
		Loop = false,
		Prioridad = Enum.AnimationPriority.Action2,
		Cuadros = {
			{ T = 0, Poses = CANA },
			{ T = 0.2, Poses = { UpperTorso = { -15, 0, 0 }, Head = { -20, 0, 0 } }, Estilo = S.Cubic },
			{ T = 0.4, Poses = { UpperTorso = { -15, 0, 0 }, Head = { -18, 20, 0 } }, Estilo = S.Cubic },
			{ T = 0.6, Poses = { UpperTorso = { -15, 0, 0 }, Head = { -18, -20, 0 } }, Estilo = S.Cubic },
			{ T = 0.8, Poses = { UpperTorso = { -14, 0, 0 }, Head = { -18, 14, 0 } }, Estilo = S.Cubic },
			{ T = 1.0, Poses = { UpperTorso = { -10, 0, 0 }, Head = { -15, 0, 0 } }, Estilo = S.Cubic },
		},
	},
}

local AnimBorrador = {}
AnimBorrador.Datos = DATOS

local function rot(r: Rot?): CFrame
	if not r then
		return CFrame.identity
	end
	return CFrame.Angles(math.rad(r[1]), math.rad(r[2]), math.rad(r[3]))
end

-- Arma la KeyframeSequence de una animación (todas las poses en todos los cuadros).
function AnimBorrador.construir(nombre: string): KeyframeSequence?
	local datos = DATOS[nombre]
	if not datos then
		return nil
	end
	local secuencia = Instance.new("KeyframeSequence")
	secuencia.Name = nombre
	secuencia.Loop = datos.Loop
	secuencia.Priority = datos.Prioridad
	for _, cuadro in datos.Cuadros do
		local keyframe = Instance.new("Keyframe")
		keyframe.Time = cuadro.T
		local poses: { [string]: Pose } = {}
		local function pose(parte: string): Pose
			local p = poses[parte]
			if p then
				return p
			end
			p = Instance.new("Pose")
			p.Name = parte
			p.CFrame = rot(cuadro.Poses[parte])
			p.Weight = if SIN_PESO[parte] then 0 else 1
			p.EasingStyle = cuadro.Estilo or S.Linear
			p.EasingDirection = Enum.PoseEasingDirection.Out
			local padre = PADRE[parte]
			p.Parent = if padre then pose(padre) else keyframe
			poses[parte] = p
			return p
		end
		for parte in PADRE do
			pose(parte)
		end
		for _, marca in cuadro.Marcas or {} do
			local m = Instance.new("KeyframeMarker")
			m.Name = marca
			m.Parent = keyframe
		end
		keyframe.Parent = secuencia
	end
	return secuencia
end

local temporales: { [string]: string } = {}

-- Id temporal para probar en Studio sin publicar. Fuera de Studio devuelve nil.
function AnimBorrador.idTemporal(nombre: string): string?
	if temporales[nombre] then
		return temporales[nombre]
	end
	if not game:GetService("RunService"):IsStudio() then
		return nil
	end
	local secuencia = AnimBorrador.construir(nombre)
	if not secuencia then
		return nil
	end
	local ok, id = pcall(function()
		return game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(secuencia)
	end)
	if not ok then
		warn("[AnimBorrador] no se pudo registrar " .. nombre .. ": " .. tostring(id))
		return nil
	end
	temporales[nombre] = id
	return id
end

return AnimBorrador
