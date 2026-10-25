--!strict
-- Conecta el ciclo de pesca del servidor con las animaciones del personaje (AnimPesca).
-- Lanzar se dispara en Pesca.client al soltar (sin esperar al servidor, así se siente al toque);
-- Levantar lo dispara Captura.client, que es el que sabe cuándo llega el pez a la mano.
-- Acá: Esperar con la boya en el agua, Recoger durante el ritmo y Fallar si se escapa.
-- Si un stun corta el loop (salto, caída), se retoma al aterrizar si la pesca sigue.
-- Recoger va al tempo del pez: cada tirón cae en un pulso, desde la cuenta regresiva (así el
-- jugador siente el ritmo antes de la primera nota) y también cuando un mítico acelera.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimPesca = require(script.Parent:WaitForChild("AnimPesca"))
local Animaciones = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Animaciones"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local jugador = Players.LocalPlayer

type Fase = "Libre" | "Esperando" | "Ritmo"
local fase: Fase = "Libre"

-- tempo de la pesca actual: Origen = os.clock() de la primera nota (cae en pulso)
type Tempo = { Origen: number, Bpm: number, BpmFinal: number?, Cambio: number? }
local tempo: Tempo? = nil
local turno = 0 -- invalida las re-sincronizaciones pendientes de una pesca anterior

-- bpm vigente en el instante t y desde dónde contar los pulsos
local function tempoEn(t: number): (number, number)
	local tp = tempo :: Tempo
	if tp.BpmFinal and tp.Cambio and t >= tp.Origen + tp.Cambio then
		return tp.BpmFinal, tp.Origen + tp.Cambio
	end
	return tp.Bpm, tp.Origen
end

-- Pone el loop a la velocidad del pez y en fase: el Golpe del tirón cae justo en el pulso.
local function sincronizar(track: AnimationTrack, intentos: number?)
	local datos = Animaciones.Lista.Recoger
	if not tempo or not datos.Pulsos then
		return
	end
	local largo = track.Length
	if largo <= 0 then
		-- todavía no cargó el asset: reintenta un par de veces
		local n = intentos or 0
		local mio = turno
		if n < 10 then
			task.delay(0.1, function()
				if mio == turno and fase == "Ritmo" and track.IsPlaying then
					sincronizar(track, n + 1)
				end
			end)
		end
		return
	end
	local ahora = os.clock()
	local bpm, origen = tempoEn(ahora)
	local velocidad = largo * bpm / (60 * datos.Pulsos)
	track:AdjustSpeed(velocidad)
	track.TimePosition = ((datos.Golpe or 0) + (ahora - origen) * velocidad) % largo
end

local function recoger()
	local track = AnimPesca.reproducir("Recoger")
	if track then
		sincronizar(track)
	end
end

local function retomar()
	if fase == "Esperando" then
		AnimPesca.reproducir("Esperar")
	elseif fase == "Ritmo" then
		recoger()
	end
end

-- Arma el tempo con los datos del "Pico". BpmFinal arranca en la nota de la mitad (Ritmo.patron).
local function empezarTempo(datos: any)
	turno += 1
	tempo = nil
	if typeof(datos) ~= "table" or typeof(datos.Bpm) ~= "number" or typeof(datos.Cuenta) ~= "number" then
		return -- servidor viejo: Recoger queda a velocidad normal
	end
	local cambio: number? = nil
	if typeof(datos.BpmFinal) == "number" and typeof(datos.Tiempos) == "table" then
		cambio = datos.Tiempos[math.ceil(#datos.Tiempos / 2)]
	end
	tempo = {
		Origen = os.clock() + datos.Cuenta,
		Bpm = datos.Bpm,
		BpmFinal = datos.BpmFinal,
		Cambio = cambio,
	}
	if cambio then
		local mio = turno
		task.delay(datos.Cuenta + cambio, function()
			if mio == turno and fase == "Ritmo" then
				recoger() -- ya está sonando: solo cambia velocidad y re-fasea
			end
		end)
	end
end

local function terminarTempo()
	turno += 1
	tempo = nil
end

Remotos:WaitForChild("Pesca").OnClientEvent:Connect(function(tipo: string, datos: any)
	if tipo == "Lanzado" then
		-- Esperar (Action) entra por debajo del Lanzar (Action2): cuando el tiro se apaga, ya está
		fase = "Esperando"
		AnimPesca.reproducir("Esperar")
	elseif tipo == "Pico" then
		fase = "Ritmo"
		empezarTempo(datos)
		recoger()
	elseif tipo == "Resultado" then
		fase = "Libre"
		terminarTempo()
		AnimPesca.pararLoops()
		if not (datos and datos.Sacado) then
			AnimPesca.reproducir("Fallar")
		end
	elseif tipo == "Cancelado" then
		fase = "Libre"
		terminarTempo()
		AnimPesca.pararLoops()
	end
end)

local function alPersonaje(personaje: Model)
	fase = "Libre" -- personaje nuevo: no retomar loops de la vida anterior
	terminarTempo()
	local humanoide = personaje:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoide then
		return
	end
	humanoide.StateChanged:Connect(function(_, nuevo)
		if nuevo == Enum.HumanoidStateType.Landed or nuevo == Enum.HumanoidStateType.Running then
			retomar()
		end
	end)
end

if jugador.Character then
	task.spawn(alPersonaje, jugador.Character)
end
jugador.CharacterAdded:Connect(alPersonaje)
