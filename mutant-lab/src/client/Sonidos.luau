--!strict
-- Todos los efectos salen de un solo sample de piano (Config.SonidoNotaId).
-- El tono se cambia con PlaybackSpeed. Para usar sonidos propios, cambiá el ID en Config.

local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)

local Sonidos = {}

-- SONIDO: sample único de piano para todos los efectos de la máquina.
local sonidoBase = Instance.new("Sound")
sonidoBase.Name = "NotaBase"
sonidoBase.SoundId = Config.SonidoNotaId
sonidoBase.Parent = SoundService

task.spawn(function()
	ContentProvider:PreloadAsync({ sonidoBase })
end)

-- Toca una nota: 0 = la nota del sample, 12 = una octava más aguda.
function Sonidos.nota(semitonos: number, volumen: number?)
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

return Sonidos
