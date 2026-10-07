--!strict
-- Cada baldosa nueva que pisás toca la siguiente nota de la melodía y brilla.
-- Es solo efecto local: no toca la lógica del juego.
-- Una baldosa es cualquier BasePart con atributo Baldosa = true.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)

local jugador = Players.LocalPlayer

local ultimaBaldosa: BasePart? = nil
local indiceNota = 0
local coloresOriginales: { [BasePart]: Color3 } = {}
local destellos: { [BasePart]: Tween } = {}

-- SONIDO: sample único de piano para todas las notas (Config.SonidoNotaId). El tono lo da PlaybackSpeed.
local sonidoBase = Instance.new("Sound")
sonidoBase.Name = "NotaBase"
sonidoBase.SoundId = Config.SonidoNotaId
sonidoBase.Volume = Config.VolumenNota
sonidoBase.Parent = SoundService

local function tocarSiguienteNota()
	indiceNota += 1
	local sonido = sonidoBase:Clone()
	sonido.PlaybackSpeed = Notas.velocidadReproduccion(Notas.notaDeMelodia(indiceNota))
	sonido.Parent = SoundService
	sonido:Play()
	Debris:AddItem(sonido, 3)
end

-- SONIDO: nota desafinada al caer (mismo sample, Config.NotaCaidaSemitonos).
local function tocarNotaCaida()
	local sonido = sonidoBase:Clone()
	sonido.PlaybackSpeed = Notas.velocidadReproduccion(Config.NotaCaidaSemitonos)
	sonido.Volume = Config.VolumenNotaCaida
	sonido.Parent = SoundService
	sonido:Play()
	Debris:AddItem(sonido, 3)
end

-- El servidor suma 1 al atributo "Caidas" cada vez que te caés.
jugador:GetAttributeChangedSignal("Caidas"):Connect(function()
	ultimaBaldosa = nil
	tocarNotaCaida()
end)

local function destellar(baldosa: BasePart)
	local original = coloresOriginales[baldosa]
	if not original then
		original = baldosa.Color
		coloresOriginales[baldosa] = original
	end
	local anterior = destellos[baldosa]
	if anterior then
		anterior:Cancel()
	end
	baldosa.Color = Config.ColorDestello
	local destello =
		TweenService:Create(baldosa, TweenInfo.new(Config.DuracionDestello), { Color = original })
	destellos[baldosa] = destello
	destello:Play()
end

local parametros = RaycastParams.new()
parametros.FilterType = Enum.RaycastFilterType.Exclude

RunService.Heartbeat:Connect(function()
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not personaje or not raiz or not raiz:IsA("BasePart") then
		return
	end

	parametros.FilterDescendantsInstances = { personaje }
	local resultado = workspace:Raycast(raiz.Position, Vector3.new(0, -6, 0), parametros)
	if not resultado then
		return -- en el aire: no cambia la última baldosa, así no suena dos veces al caer en la misma
	end

	local parte = resultado.Instance
	if parte:GetAttribute("Baldosa") ~= true or not parte:IsA("BasePart") then
		ultimaBaldosa = nil
		return
	end
	if parte ~= ultimaBaldosa then
		ultimaBaldosa = parte
		tocarSiguienteNota()
		destellar(parte)
	end
end)
