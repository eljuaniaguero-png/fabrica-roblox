--!strict
-- Toca un sonido corto. Los IDs están en GameConfig.Sonidos (y en cada modificador); si un ID
-- está vacío no suena nada. Cada lugar que toca un sonido está marcado con "-- SONIDO:".

local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local Sonidos = {}

function Sonidos.tocar(id: string, velocidad: number?, volumen: number?, en: Instance?)
	if id == "" then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.PlaybackSpeed = velocidad or 1
	s.Volume = volumen or 0.6
	s.Parent = en or SoundService
	s:Play()
	Debris:AddItem(s, 8)
end

-- Sonido que se repite mientras exista `en` (aura de una geoda exótica). Devuelve el Sound.
function Sonidos.bucle(id: string, en: Instance, volumen: number?): Sound?
	if id == "" then
		return nil
	end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Looped = true
	s.Volume = volumen or 0.35
	s.RollOffMaxDistance = 60
	s.Parent = en
	s:Play()
	return s
end

return Sonidos
