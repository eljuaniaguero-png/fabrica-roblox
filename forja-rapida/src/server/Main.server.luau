--!strict
-- Arranque del servidor de Forja Rápida: carga los sistemas y conecta la entrada y salida de
-- jugadores.

local Players = game:GetService("Players")

local CampoPrueba = require(script.Parent.CampoPrueba)
local GeodeServerService = require(script.Parent.GeodeServerService)
local Jugadores = require(script.Parent.Jugadores)

Players.PlayerAdded:Connect(Jugadores.crear)
for _, jugador in Players:GetPlayers() do
	task.spawn(Jugadores.crear, jugador)
end
Players.PlayerRemoving:Connect(Jugadores.quitar)

Jugadores.iniciar()
GeodeServerService.iniciar()
CampoPrueba.armarSiFalta()
