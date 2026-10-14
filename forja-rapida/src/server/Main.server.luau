--!strict
-- Arranque del servidor de Forja Rápida: carga los sistemas y conecta la entrada y salida de
-- jugadores.

local Players = game:GetService("Players")

local CampoPrueba = require(script.Parent.CampoPrueba)
local Economia = require(script.Parent.Economia)
local Eventos = require(script.Parent.Eventos)
local GeodeServerService = require(script.Parent.GeodeServerService)
local Iluminacion = require(script.Parent.Iluminacion)
local Jugadores = require(script.Parent.Jugadores)
local Social = require(script.Parent.Social)

Iluminacion.aplicar()

local function alEntrar(jugador: Player)
	Jugadores.crear(jugador)
	Social.alEntrar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
Players.PlayerRemoving:Connect(function(jugador: Player)
	Social.alSalir(jugador) -- antes de borrar sus datos (sube sus puntos de la semana)
	Jugadores.quitar(jugador)
end)

Jugadores.iniciar()
Economia.iniciar()
CampoPrueba.armarSiFalta()
GeodeServerService.iniciar()
Social.iniciar()
Eventos.iniciar()
