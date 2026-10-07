--!strict
-- Piso que se ilumina: este script solo avisa qué baldosa pisás y muestra lo que decide el
-- servidor (Pisadas.luau). Una baldosa apagada que pisás se enciende con fundido y toca la
-- siguiente nota de la canción de su zona; mientras está prendida no da nada ni suena; se apaga
-- sola (con fundido) a las 10 baldosas o al minuto. Cada jugador ve sus propias baldosas.
-- Una baldosa es cualquier BasePart con atributo Baldosa = true. Su color en el mapa es el del
-- estilo; acá se atenúa con Config.Baldosas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local EfectoPisada = require(script.Parent.EfectoPisada)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local ajustes = Config.Baldosas
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local remotoPisada = remotos:WaitForChild("Pisada") :: RemoteEvent
local remotoBaldosa = remotos:WaitForChild("Baldosa") :: RemoteEvent

type Baldosa = {
	parte: BasePart,
	base: Color3, -- color del estilo, a pleno
	encendida: boolean,
	fundido: Tween?,
}

-- Con streaming, las baldosas llegan y se van mientras jugás. Lo que dice el servidor se guarda
-- por nombre completo (la clave), no por parte, así sobrevive a que la parte se vaya y vuelva.
local baldosas: { [string]: Baldosa } = {}
local prendidas: { [string]: boolean } = {}
local doradaClave: string? = nil -- baldosa dorada actual
local pintarDorada: (baldosa: Baldosa) -> ()
local ultimaBaldosa: BasePart? = nil
local ultimoAviso = 0 -- os.clock() del último aviso al servidor

local function atenuar(color: Color3, brillo: number): Color3
	return Color3.new(color.R * brillo, color.G * brillo, color.B * brillo)
end

local function fundir(baldosa: Baldosa, encendida: boolean)
	if baldosa.encendida == encendida then
		return
	end
	if baldosa.fundido then
		baldosa.fundido:Cancel()
	end
	baldosa.encendida = encendida
	local brillo = if encendida then ajustes.BrilloEncendida else ajustes.BrilloApagada
	if encendida then
		-- Destello: arranca casi blanco y baja a su color (se siente el golpe de la pisada)
		baldosa.parte.Color = Color3.new(1, 1, 1):Lerp(baldosa.base, ajustes.Destello)
	end
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
	if not parte:IsA("BasePart") or parte:GetAttribute("Baldosa") ~= true then
		return
	end
	local clave = parte:GetFullName()
	if baldosas[clave] and baldosas[clave].parte == parte then
		return
	end
	local encendida = prendidas[clave] == true
	baldosas[clave] = { parte = parte, base = parte.Color, encendida = encendida }
	parte.Color =
		atenuar(parte.Color, if encendida then ajustes.BrilloEncendida else ajustes.BrilloApagada)
	if clave == doradaClave then
		pintarDorada(baldosas[clave])
	end
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") and objeto:GetAttribute("Baldosa") == true then
		local clave = objeto:GetFullName()
		if baldosas[clave] and baldosas[clave].parte == objeto then
			baldosas[clave] = nil
		end
	end
end)

-- Baldosa dorada: late en dorado hasta que la pisás (da monedas; lo decide el servidor).
pintarDorada = function(baldosa: Baldosa)
	if baldosa.fundido then
		baldosa.fundido:Cancel()
	end
	baldosa.parte.Color = ajustes.ColorDorada
	local latido = TweenService:Create(
		baldosa.parte,
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Color = atenuar(ajustes.ColorDorada, 0.55) }
	)
	baldosa.fundido = latido
	latido:Play()
end

local function soltarDorada()
	local anterior = if doradaClave then baldosas[doradaClave] else nil
	doradaClave = nil
	if anterior then
		if anterior.fundido then
			anterior.fundido:Cancel()
		end
		local brillo = if anterior.encendida then ajustes.BrilloEncendida else ajustes.BrilloApagada
		anterior.parte.Color = atenuar(anterior.base, brillo)
	end
end

remotoBaldosa.OnClientEvent:Connect(function(accion: string, clave: string, nota: number?)
	if accion == "dorada" then
		soltarDorada()
		doradaClave = clave
		local baldosa = baldosas[clave]
		if baldosa then
			pintarDorada(baldosa)
		end
		return
	end
	if clave == doradaClave then
		soltarDorada()
	end
	local encender = accion == "encender"
	prendidas[clave] = if encender then true else nil
	if encender and nota then
		-- SONIDO: la siguiente nota de la canción de la zona (sample de Config.SonidoNotaId).
		Sonidos.nota(nota, Config.VolumenNota)
	end
	local baldosa = baldosas[clave]
	if baldosa then
		fundir(baldosa, encender)
		if encender then
			EfectoPisada.mostrar(jugador, baldosa.parte, baldosa.base)
		end
	end
end)

-- El servidor suma 1 al atributo "Caidas" cada vez que te caés: la próxima baldosa cuenta de nuevo.
jugador:GetAttributeChangedSignal("Caidas"):Connect(function()
	ultimaBaldosa = nil
end)

local parametros = RaycastParams.new()
parametros.FilterType = Enum.RaycastFilterType.Exclude

-- Avisar al servidor cada vez que pisás una baldosa distinta a la anterior.
RunService.Heartbeat:Connect(function()
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not personaje or not raiz or not raiz:IsA("BasePart") then
		return
	end

	parametros.FilterDescendantsInstances = { personaje }
	local resultado = workspace:Raycast(raiz.Position, Vector3.new(0, -6, 0), parametros)
	if not resultado then
		return -- en el aire: no cambia la última baldosa, así no cuenta dos veces al caer en la misma
	end

	local parte = resultado.Instance
	if parte:GetAttribute("Baldosa") ~= true or not parte:IsA("BasePart") then
		ultimaBaldosa = nil
		return
	end
	local ahora = os.clock()
	if parte ~= ultimaBaldosa then
		-- Baldosa nueva: se avisa siempre (si está usada, el servidor lo cuenta como error del combo).
		ultimaBaldosa = parte
		ultimoAviso = ahora
		remotoPisada:FireServer(parte)
	elseif
		not prendidas[parte:GetFullName()] and ahora - ultimoAviso >= ajustes.ReintentoPisada
	then
		-- Seguís encima y el servidor todavía no la prendió (la red llegó tarde): avisar de nuevo.
		ultimoAviso = ahora
		remotoPisada:FireServer(parte)
	end
end)
