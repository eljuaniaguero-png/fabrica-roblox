--!strict
-- Cada baldosa nueva que pisás toca la siguiente nota de la melodía y brilla.
-- Es solo efecto local: no toca la lógica del juego.
-- Una baldosa es cualquier BasePart con atributo Baldosa = true. Su color en el mapa es el del
-- estilo; acá se atenúa con Config.Baldosas para que no encandile.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer

local ultimaBaldosa: BasePart? = nil
local indiceNota = 0
-- Con streaming, las baldosas llegan y se van mientras jugás: todo se guarda por parte.
local coloresBase: { [BasePart]: Color3 } = {}
local destellos: { [BasePart]: Tween } = {}

local function atenuar(color: Color3, brillo: number): Color3
	return Color3.new(color.R * brillo, color.G * brillo, color.B * brillo)
end

local function registrar(parte: Instance)
	if not parte:IsA("BasePart") or parte:GetAttribute("Baldosa") ~= true or coloresBase[parte] then
		return
	end
	coloresBase[parte] = parte.Color
	parte.Color = atenuar(parte.Color, Config.Baldosas.BrilloEncendida)
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		coloresBase[objeto] = nil
		destellos[objeto] = nil
	end
end)

-- SONIDO: la siguiente nota de la melodía (sample de piano de Config.SonidoNotaId).
local function tocarSiguienteNota()
	indiceNota += 1
	Sonidos.nota(Notas.notaDeMelodia(indiceNota), Config.VolumenNota)
end

-- El servidor suma 1 al atributo "Caidas" cada vez que te caés (la nota desafinada llega con el aviso).
jugador:GetAttributeChangedSignal("Caidas"):Connect(function()
	ultimaBaldosa = nil
end)

local function destellar(baldosa: BasePart)
	local base = coloresBase[baldosa]
	if not base then
		return
	end
	local anterior = destellos[baldosa]
	if anterior then
		anterior:Cancel()
	end
	baldosa.Color = Config.ColorDestello
	local destello = TweenService:Create(
		baldosa,
		TweenInfo.new(Config.DuracionDestello),
		{ Color = atenuar(base, Config.Baldosas.BrilloEncendida) }
	)
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
