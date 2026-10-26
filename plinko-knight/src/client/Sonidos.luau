--!strict
-- Sonidos y música (etapa 9). Los IDs están en Config.Sonidos; cada sonido va en el SoundGroup
-- de Ajustes (Efectos o Musica), así "Sonido no" y "Música no" los apagan.
-- tocar("Toque", n): el tono sube con cada clavija del mismo tiro (como una escala).
-- musica("pelea" | "jefe" | nil): cambia de tema con un fundido corto.

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
require(script.Parent:WaitForChild("Ajustes")) -- crea los SoundGroup

local Sonidos = {}

local efectos = SoundService:WaitForChild("Efectos") :: SoundGroup
local grupoMusica = SoundService:WaitForChild("Musica") :: SoundGroup

-- Un Sound por nombre, reusado (con PlayOnRemove no se puede cambiar el tono antes).
local cache: { [string]: Sound } = {}
local function sonido(nombre: string): Sound?
	local d = (Config.Sonidos :: any)[nombre]
	if not d or d.Id == "" then
		return nil
	end
	local s = cache[nombre]
	if not s then
		local nuevo = Instance.new("Sound")
		nuevo.Name = nombre
		nuevo.SoundId = d.Id
		nuevo.Volume = d.Volumen
		nuevo.SoundGroup = efectos
		nuevo.Parent = SoundService
		cache[nombre] = nuevo
		s = nuevo
	end
	return s
end

-- toque: número de toque en el tiro (solo para "Toque": sube el tono).
function Sonidos.tocar(nombre: string, toque: number?)
	local base = sonido(nombre)
	if not base then
		return
	end
	-- Un clon por vez, así se pueden encimar (muchos toques seguidos).
	local s = base:Clone()
	if toque then
		local tono = Config.Sonidos.TonoToque
		s.PlaybackSpeed = math.min(tono[1] + (toque - 1) * 0.05, tono[2])
	end
	s.Parent = SoundService
	s:Play()
	s.Ended:Once(function()
		s:Destroy()
	end)
end

local actual: Sound? = nil
local temaActual: string? = nil
function Sonidos.musica(tema: string?)
	if tema == temaActual then
		return
	end
	temaActual = tema
	local viejo = actual
	if viejo then
		local t = TweenService:Create(viejo, TweenInfo.new(0.6), { Volume = 0 })
		t:Play()
		t.Completed:Once(function()
			viejo:Destroy()
		end)
		actual = nil
	end
	local d = if tema == "jefe"
		then Config.Sonidos.MusicaJefe
		elseif tema == "pelea" then Config.Sonidos.MusicaPelea
		else nil
	if not d or d.Id == "" then
		return
	end
	local s = Instance.new("Sound")
	s.Name = "Musica"
	s.SoundId = d.Id
	s.Looped = true
	s.Volume = 0
	s.SoundGroup = grupoMusica
	s.Parent = SoundService
	s:Play()
	TweenService:Create(s, TweenInfo.new(0.8), { Volume = d.Volumen }):Play()
	actual = s
end

return Sonidos
