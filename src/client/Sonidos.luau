--!strict
-- Todos los sonidos del juego salen de un solo sample de piano (Config.SonidoNotaId).
-- El tono se cambia con PlaybackSpeed. Para usar sonidos propios, cambiá los IDs en Config.

local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)

local Sonidos = {}

-- SONIDO: sample único de piano para todas las notas y efectos.
local sonidoBase = Instance.new("Sound")
sonidoBase.Name = "NotaBase"
sonidoBase.SoundId = Config.SonidoNotaId
sonidoBase.Parent = SoundService

-- Precargar el sample al entrar, así la primera pisada ya suena.
task.spawn(function()
	ContentProvider:PreloadAsync({ sonidoBase })
end)

function Sonidos.nota(semitonos: number, volumen: number)
	local sonido = sonidoBase:Clone()
	sonido.PlaybackSpeed = Notas.velocidadReproduccion(semitonos)
	sonido.Volume = volumen
	sonido.Parent = SoundService
	sonido:Play()
	Debris:AddItem(sonido, 4)
end

-- Toca un efecto de Config.Efectos (por ejemplo "Checkpoint"). Si no existe, no hace nada.
function Sonidos.efecto(nombre: string)
	local efecto = Config.Efectos[nombre]
	if not efecto then
		return
	end
	task.spawn(function()
		for indice, semitonos in efecto.Notas do
			if indice > 1 then
				task.wait(efecto.Separacion)
			end
			Sonidos.nota(semitonos, Config.VolumenEfectos)
		end
	end)
end

return Sonidos
