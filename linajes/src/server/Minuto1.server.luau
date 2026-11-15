--!strict
-- Guía interactiva de Minuto 1 (server-authoritative): sigue los 5 hitos reales del jugador
-- nuevo y entrega una sola vez la recompensa inicial al completarlos (guardado en ProfileStore).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Perfiles = require(script.Parent.Perfiles)

local M = Config.Minuto1
local HITOS = { "Despertar", "Combate", "Defensa", "Poder", "Maton" }

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Minuto1"
remoto.Parent = ReplicatedStorage

local hitoEv = Instance.new("BindableEvent")
hitoEv.Name = "Minuto1Hito"
hitoEv.Parent = script.Parent

local ultimoPedido: { [Player]: number } = {}

local function sincronizarAtributos(jugador: Player)
	local d = Perfiles.datos(jugador)
	if not d then
		return
	end
	local hecho = d.TutorialHecho == true
	for _, h in HITOS do
		if hecho then
			jugador:SetAttribute("M1_" .. h, true)
		elseif h == "Despertar" then
			jugador:SetAttribute("M1_Despertar", typeof(jugador:GetAttribute("Linaje")) == "string")
		else
			jugador:SetAttribute("M1_" .. h, false)
		end
	end
end

local function revisarCompleto(jugador: Player)
	local d = Perfiles.datos(jugador)
	if not d or d.TutorialHecho == true then
		return
	end
	for _, h in HITOS do
		if jugador:GetAttribute("M1_" .. h) ~= true then
			return
		end
	end
	d.TutorialHecho = true
	Perfiles.cambiar(jugador, {
		Chatarra = d.Chatarra + M.RecompensaChatarra,
		TutorialHecho = true,
	})
	Perfiles.sumarXp(jugador, M.RecompensaXp)
	remoto:FireClient(jugador, "Completado", M.RecompensaChatarra, M.RecompensaXp)
end

local function marcar(jugador: Player, hito: string)
	if not table.find(HITOS, hito) then
		return
	end
	local d = Perfiles.datos(jugador)
	if not d or d.TutorialHecho == true then
		return
	end
	if jugador:GetAttribute("M1_" .. hito) ~= true then
		jugador:SetAttribute("M1_" .. hito, true)
		revisarCompleto(jugador)
	end
end

hitoEv.Event:Connect(function(jugador: Player, hito: string)
	if typeof(jugador) == "Instance" and jugador:IsA("Player") and typeof(hito) == "string" then
		marcar(jugador, hito)
	end
end)

local function conectarJugador(jugador: Player)
	local function alListo()
		if jugador:GetAttribute("DatosListos") == true then
			sincronizarAtributos(jugador)
		end
	end
	jugador:GetAttributeChangedSignal("DatosListos"):Connect(alListo)
	jugador:GetAttributeChangedSignal("Linaje"):Connect(function()
		if typeof(jugador:GetAttribute("Linaje")) == "string" then
			marcar(jugador, "Despertar")
		end
	end)
	alListo()
end

Players.PlayerAdded:Connect(conectarJugador)
for _, j in Players:GetPlayers() do
	task.spawn(conectarJugador, j)
end

Players.PlayerRemoving:Connect(function(jugador)
	ultimoPedido[jugador] = nil
end)

remoto.OnServerEvent:Connect(function(jugador: Player, pedido: unknown)
	if typeof(pedido) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < 0.25 then
		return
	end
	ultimoPedido[jugador] = ahora

	local d = Perfiles.datos(jugador)
	if not d then
		return
	end
	if pedido == "Saltar" then
		if d.TutorialHecho ~= true then
			Perfiles.cambiar(jugador, { TutorialHecho = true })
			sincronizarAtributos(jugador)
		end
	elseif pedido == "Reiniciar" then
		if RunService:IsStudio() then
			Perfiles.cambiar(jugador, { TutorialHecho = false })
			sincronizarAtributos(jugador)
		end
	end
end)
