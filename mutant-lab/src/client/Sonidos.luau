--!strict
-- Todos los efectos salen de un solo sample de piano (Config.SonidoNotaId).
-- El tono se cambia con PlaybackSpeed. Para usar sonidos propios, cambiá el ID en Config.

local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)

local Sonidos = {}

-- Se apaga desde Ajustes (solo para este jugador).
local activos = true

-- SONIDO: sample único de piano para todos los efectos del juego.
local sonidoBase = Instance.new("Sound")
sonidoBase.Name = "NotaBase"
sonidoBase.SoundId = Config.SonidoNotaId
sonidoBase.Parent = SoundService

task.spawn(function()
	ContentProvider:PreloadAsync({ sonidoBase })
end)

-- Toca una nota: 0 = la nota del sample, 12 = una octava más aguda.
function Sonidos.nota(semitonos: number, volumen: number?)
	if not activos then
		return
	end
	local s = sonidoBase:Clone()
	s.PlaybackSpeed = 2 ^ (semitonos / 12)
	s.Volume = volumen or Config.VolumenEfectos
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 4)
end

-- Varias notas a la vez.
function Sonidos.acorde(semitonos: { number }, volumen: number?)
	for _, n in semitonos do
		Sonidos.nota(n, volumen)
	end
end

-- Varias notas una atrás de otra (no frena al que la llama).
function Sonidos.secuencia(semitonos: { number }, separacion: number, volumen: number?)
	task.spawn(function()
		for _, n in semitonos do
			Sonidos.nota(n, volumen)
			task.wait(separacion)
		end
	end)
end

function Sonidos.activar(si: boolean)
	activos = si
end

function Sonidos.estanActivos(): boolean
	return activos
end

---------------------------------------------------------------------------
-- Sonidos de la interfaz
---------------------------------------------------------------------------

function Sonidos.boton()
	-- SONIDO: botón apretado (nota aguda y corta)
	Sonidos.nota(12, 0.18)
end

function Sonidos.botonApagado()
	-- SONIDO: botón que todavía no se puede usar (nota grave y suave)
	Sonidos.nota(-7, 0.15)
end

function Sonidos.abrirMenu()
	-- SONIDO: abrir menú (dos notas que suben)
	Sonidos.secuencia({ 7, 12 }, 0.05, 0.2)
end

function Sonidos.cerrarMenu()
	-- SONIDO: cerrar menú (dos notas que bajan)
	Sonidos.secuencia({ 12, 7 }, 0.05, 0.16)
end

function Sonidos.comprar()
	-- SONIDO: comprar (tres notas que suben)
	Sonidos.secuencia({ 4, 7, 12 }, 0.07, 0.4)
end

function Sonidos.notificacion(tipo: string)
	if tipo == "error" then
		-- SONIDO: aviso de error (dos notas que chocan)
		Sonidos.acorde({ -5, -4 }, 0.2)
	else
		-- SONIDO: aviso (nota que sube)
		Sonidos.secuencia({ 9, 14 }, 0.06, 0.18)
	end
end

return Sonidos
