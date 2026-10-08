--!strict
-- Arranque del servidor: carga los sistemas y conecta la entrada y salida de jugadores.

local Players = game:GetService("Players")

require(script.Parent.Remotos)
local Corrales = require(script.Parent.Corrales)
local Economia = require(script.Parent.Economia)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
require(script.Parent.MaquinaFusion)
require(script.Parent.TiendaPistas)
require(script.Parent.Tienda)
require(script.Parent.HerramientasPrueba)

local function alEntrar(jugador: Player)
	Jugadores.crear(jugador)
	Laboratorios.asignar(jugador)
	Corrales.actualizar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	Corrales.limpiar(jugador)
	Laboratorios.liberar(jugador)
	Jugadores.quitar(jugador)
end)

Economia.iniciar()
