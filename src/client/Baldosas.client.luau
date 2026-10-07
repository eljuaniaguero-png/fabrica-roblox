--!strict
-- Piso que se ilumina: las baldosas arrancan apagadas, al pisar una se enciende con un fundido
-- y toca la siguiente nota de la melodía. Se apaga sola un rato después de la última pisada.
-- Es solo efecto local (cada jugador ve sus baldosas): no toca la lógica del juego.
-- Una baldosa es cualquier BasePart con atributo Baldosa = true. Su color en el mapa es el del
-- estilo; acá se atenúa con Config.Baldosas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local ajustes = Config.Baldosas

type Baldosa = {
	parte: BasePart,
	base: Color3, -- color del estilo, a pleno
	clave: string,
	encendida: boolean,
	fundido: Tween?,
}

local ultimaBaldosa: BasePart? = nil
local indiceNota = 0
-- Con streaming, las baldosas llegan y se van mientras jugás. Lo que tiene que durar
-- (hasta cuándo queda encendida) se guarda por nombre completo, no por parte.
local baldosas: { [BasePart]: Baldosa } = {}
local encendidaHasta: { [string]: number } = {}

local function atenuar(color: Color3, brillo: number): Color3
	return Color3.new(color.R * brillo, color.G * brillo, color.B * brillo)
end

local function fundir(baldosa: Baldosa, encendida: boolean)
	if baldosa.fundido then
		baldosa.fundido:Cancel()
	end
	baldosa.encendida = encendida
	local brillo = if encendida then ajustes.BrilloEncendida else ajustes.BrilloApagada
	local duracion = if encendida then ajustes.FundidoEncendido else ajustes.FundidoApagado
	local fundido = TweenService:Create(
		baldosa.parte,
		TweenInfo.new(duracion, Enum.EasingStyle.Sine),
		{ Color = atenuar(baldosa.base, brillo) }
	)
	baldosa.fundido = fundido
	fundido:Play()
end

local function registrar(parte: Instance)
	if not parte:IsA("BasePart") or parte:GetAttribute("Baldosa") ~= true or baldosas[parte] then
		return
	end
	local clave = parte:GetFullName()
	local encendida = (encendidaHasta[clave] or 0) > os.clock()
	baldosas[parte] = { parte = parte, base = parte.Color, clave = clave, encendida = encendida }
	parte.Color =
		atenuar(parte.Color, if encendida then ajustes.BrilloEncendida else ajustes.BrilloApagada)
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		baldosas[objeto] = nil
	end
end)

-- Encender (o mantener encendida) y empezar de nuevo la cuenta para apagarse.
local function encender(baldosa: Baldosa)
	encendidaHasta[baldosa.clave] = os.clock() + ajustes.TiempoEncendida
	if not baldosa.encendida then
		fundir(baldosa, true)
	end
end

-- Apagar las que ya cumplieron su tiempo.
task.spawn(function()
	while true do
		task.wait(1)
		local ahora = os.clock()
		for clave, hasta in encendidaHasta do
			if hasta <= ahora then
				encendidaHasta[clave] = nil
			end
		end
		for _, baldosa in baldosas do
			if baldosa.encendida and not encendidaHasta[baldosa.clave] then
				fundir(baldosa, false)
			end
		end
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
	local baldosa = if parte:IsA("BasePart") then baldosas[parte] else nil
	if not baldosa then
		ultimaBaldosa = nil
		return
	end
	if parte ~= ultimaBaldosa then
		ultimaBaldosa = baldosa.parte
		tocarSiguienteNota()
		encender(baldosa)
	end
end)
