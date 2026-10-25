--!strict
-- Reproduce las animaciones del ciclo de pesca en el personaje local (Animator:LoadAnimation).
-- Los ids y prioridades están en shared/Animaciones. Lo usan Animaciones.client (lanzar,
-- esperar, recoger, fallar) y Captura.client (levantar el pez, sincronizado por marcador).
--
-- Capas: Esperar/Recoger van en Action y solo mueven torso y brazos; Lanzar, Levantar y Fallar
-- van en Action2 por encima, así al terminar se ve de nuevo el loop de abajo sin cortes.
-- Cortes (stun): caer, tropezar, ragdoll, sentarse o morir frena todo con un fade corto.
-- Sin id publicado: en Studio se usa el borrador de shared/AnimBorrador (id temporal); en el
-- juego publicado Levantar cae a una pose procedural en los hombros (solo R15, solo se ve local).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Animaciones = require(Shared:WaitForChild("Animaciones"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local AnimBorrador = require(Shared:WaitForChild("AnimBorrador"))

local jugador = Players.LocalPlayer

local LOOPS = { "Esperar", "Recoger" }
local CORTE_RAPIDO = 0.1
local CORTAN: { [Enum.HumanoidStateType]: boolean } = {
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
	[Enum.HumanoidStateType.Ragdoll] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.Seated] = true,
	[Enum.HumanoidStateType.Dead] = true,
}

local AnimPesca = {}

local porPersonaje = Limpieza.nueva() -- se suelta en cada respawn
local procedural = Limpieza.nueva() -- la pose de respaldo de Levantar
local tracks: { [string]: AnimationTrack } = {}
local ultimo: { [string]: number } = {}
local motores: { [string]: Motor6D } = {}
local cortes = 0 -- cuántas veces se cortó por stun (para no avisar de marcadores faltantes)

local function idValido(id: string): string?
	if id == "" then
		return nil
	end
	return if string.find(id, "^rbxassetid://") then id else "rbxassetid://" .. id
end

local function cargar(personaje: Model)
	porPersonaje:limpiar()
	procedural:limpiar()
	table.clear(tracks)
	table.clear(motores)
	local humanoide = personaje:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoide then
		return
	end
	local animator = humanoide:WaitForChild("Animator", 10) :: Animator?
	if not animator or personaje ~= jugador.Character then
		return
	end

	for nombre, datos in Animaciones.Lista do
		local id = idValido(datos.Id)
		if not id and RunService:IsStudio() then
			id = AnimBorrador.idTemporal(nombre) -- sin publicar: se prueba con el borrador
		end
		if id then
			local anim = porPersonaje:dar(Instance.new("Animation"))
			anim.AnimationId = id
			local track = animator:LoadAnimation(anim)
			track.Priority = datos.Prioridad
			track.Looped = datos.Loop
			tracks[nombre] = track
			porPersonaje:dar(function()
				track:Stop(0)
				track:Destroy()
			end)
		end
	end

	-- motores para la pose de respaldo (nombres R15)
	for _, nombre in { "RightShoulder", "LeftShoulder", "RightElbow", "LeftElbow", "Waist" } do
		local m = personaje:FindFirstChild(nombre, true)
		if m and m:IsA("Motor6D") then
			motores[nombre] = m
		end
	end

	porPersonaje:dar(humanoide.StateChanged:Connect(function(_, nuevo)
		if CORTAN[nuevo] then
			AnimPesca.cortar()
		end
	end))
end

-- Arranca una animación. Devuelve el track, o nil si no hay id o está en enfriamiento.
function AnimPesca.reproducir(nombre: Animaciones.Nombre): AnimationTrack?
	local datos = Animaciones.Lista[nombre]
	local track = tracks[nombre]
	if not datos or not track then
		return nil
	end
	local ahora = os.clock()
	if ahora - (ultimo[nombre] or -math.huge) < datos.Enfriamiento then
		return nil
	end
	ultimo[nombre] = ahora
	if datos.Loop then
		-- Esperar y Recoger se excluyen: cambiar de uno al otro es un crossfade
		for _, otro in LOOPS do
			if otro ~= nombre then
				AnimPesca.parar(otro :: Animaciones.Nombre)
			end
		end
		if track.IsPlaying then
			return track
		end
	end
	track:Play(datos.Entrada)
	return track
end

function AnimPesca.parar(nombre: Animaciones.Nombre, salida: number?)
	local track = tracks[nombre]
	if track and track.IsPlaying then
		track:Stop(salida or Animaciones.Lista[nombre].Salida)
	end
end

function AnimPesca.pararLoops()
	for _, nombre in LOOPS do
		AnimPesca.parar(nombre :: Animaciones.Nombre)
	end
end

-- Stun: todo afuera con fade corto, incluida la pose de respaldo.
function AnimPesca.cortar()
	cortes += 1
	for _, track in tracks do
		if track.IsPlaying then
			track:Stop(CORTE_RAPIDO)
		end
	end
	procedural:limpiar()
end

-- Pose de respaldo: brazos arriba con Back Out hasta AGARRAR, un rebote al agarrar, sostener y
-- bajar con Quad Out. La curva es la misma línea de tiempo que la animación real, así que
-- "Agarrar" y "VFX" salen en el mismo instante que saldría el marcador.
local function levantarProcedural(alAgarrar: () -> (), alVFX: () -> ()): boolean
	local hombroD, hombroI = motores.RightShoulder, motores.LeftShoulder
	if not hombroD or not hombroI then
		return false -- R6 o rig custom: sin respaldo
	end
	procedural:limpiar()
	local inicio = os.clock()
	local agarro = false
	local function soltar()
		for _, m in motores do
			if m.Parent then
				m.Transform = CFrame.identity
			end
		end
	end
	procedural:dar(soltar)
	-- PreSimulation corre después del Animator: el Transform que pongamos acá es el que se dibuja
	procedural:dar(RunService.PreSimulation:Connect(function()
		local t = os.clock() - inicio
		if t >= Animaciones.FIN then
			procedural:limpiar()
			return
		end
		if not agarro and t >= Animaciones.AGARRAR then
			agarro = true
			alAgarrar()
			alVFX()
		end
		local subir = TweenService:GetValue(math.clamp(t / Animaciones.AGARRAR, 0, 1), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local bajar = if t > Animaciones.BAJAR
			then TweenService:GetValue((t - Animaciones.BAJAR) / (Animaciones.FIN - Animaciones.BAJAR), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			else 0
		local k = subir * (1 - bajar)
		-- al agarrar el peso "hunde" los brazos y rebota (se asienta en ~0.3 s)
		local h = math.max(0, t - Animaciones.AGARRAR)
		local hundir = if agarro then 0.35 * math.exp(-h * 10) * math.cos(h * 22) else 0
		local brazo = math.rad(165) * k - hundir
		hombroD.Transform = CFrame.Angles(0, 0, 0.15 * k) * CFrame.Angles(brazo, 0, 0)
		hombroI.Transform = CFrame.Angles(0, 0, -0.15 * k) * CFrame.Angles(brazo, 0, 0)
		local codoD, codoI, cintura = motores.RightElbow, motores.LeftElbow, motores.Waist
		if codoD then
			codoD.Transform = CFrame.Angles(math.rad(25) * k, 0, 0)
		end
		if codoI then
			codoI.Transform = CFrame.Angles(math.rad(25) * k, 0, 0)
		end
		if cintura then
			cintura.Transform = CFrame.Angles(math.rad(8) * k + hundir * 0.3, 0, 0) -- se echa para atrás
		end
	end))
	return true
end

-- Levantar el pez. alAgarrar = el pez llega a las manos (marcador "Agarrar"), alVFX = salpicadura
-- (marcador "VFX"). Devuelve la función para pararlo y si hay animación (real o de respaldo);
-- si es false, el que llama tiene que sincronizar por su cuenta.
function AnimPesca.levantar(alAgarrar: () -> (), alVFX: () -> ()): (() -> (), boolean)
	AnimPesca.pararLoops()
	AnimPesca.parar("Fallar", CORTE_RAPIDO)
	local track = AnimPesca.reproducir("Levantar")
	if not track then
		if tracks.Levantar then
			-- en enfriamiento (dos peces casi juntos): sin animación esta vez
			return function() end, false
		end
		local ok = levantarProcedural(alAgarrar, alVFX)
		return function()
			procedural:limpiar()
		end, ok
	end
	local marcas = Limpieza.nueva()
	local agarro = false
	local cortesAntes = cortes
	marcas:dar(track:GetMarkerReachedSignal("Agarrar"):Connect(function()
		agarro = true
		alAgarrar()
	end))
	marcas:dar(track:GetMarkerReachedSignal("VFX"):Connect(alVFX))
	marcas:dar(track.Stopped:Once(function()
		-- si terminó sola sin pasar por el marcador, al animador le faltó ponerlo
		if not agarro and cortes == cortesAntes then
			warn('[AnimPesca] Levantar terminó sin el marcador "Agarrar": revisar la animación')
		end
		marcas:limpiar()
	end))
	return function()
		marcas:limpiar()
		AnimPesca.parar("Levantar")
	end, true
end

if jugador.Character then
	task.spawn(cargar, jugador.Character)
end
jugador.CharacterAdded:Connect(cargar)
jugador.CharacterRemoving:Connect(function()
	porPersonaje:limpiar()
	procedural:limpiar()
	table.clear(tracks)
	table.clear(motores)
end)

return AnimPesca
