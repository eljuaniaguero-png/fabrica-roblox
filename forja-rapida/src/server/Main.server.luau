--!strict
-- Arranque del servidor de Forja Rápida: carga los sistemas y conecta la entrada y salida de
-- jugadores.

local Players = game:GetService("Players")

local CampoPrueba = require(script.Parent.CampoPrueba)
local Cosmeticos = require(script.Parent.Cosmeticos)
local Economia = require(script.Parent.Economia)
local Eventos = require(script.Parent.Eventos)
local GeneradorMapa = require(script.Parent.GeneradorMapa)
local GeodeServerService = require(script.Parent.GeodeServerService)
local HerramientasPrueba = require(script.Parent.HerramientasPrueba)
local Iluminacion = require(script.Parent.Iluminacion)
local Jugadores = require(script.Parent.Jugadores)
local Mascotas = require(script.Parent.Mascotas)
local Misiones = require(script.Parent.Misiones)
local Renacer = require(script.Parent.Renacer)
local Secretos = require(script.Parent.Secretos)
local Social = require(script.Parent.Social)
local Forja = require(script.Parent.Forja)
local Viajes = require(script.Parent.Viajes)
local Dash = require(script.Parent.Dash)
local Velocidad = require(script.Parent.Velocidad)
local Guardado = require(script.Parent.Guardado)
local Analitica = require(script.Parent.Analitica)

Iluminacion.aplicar()
GeneradorMapa.armar() -- antes que todo lo que busca puntos, vitrinas y puertas del mapa

local function alEntrar(jugador: Player)
	local datos = Guardado.cargar(jugador) -- espera; nil = no se pudo y ya lo sacó
	if not datos then
		return
	end
	Jugadores.crear(jugador, datos)
	Analitica.paso(jugador, Analitica.Pasos.Entro)
	Social.alEntrar(jugador)
	Misiones.alEntrar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
Players.PlayerRemoving:Connect(function(jugador: Player)
	Social.alSalir(jugador) -- antes de borrar sus datos (sube sus puntos de la semana)
	Forja.alSalir(jugador) -- la piedra que estaba forjando entra a la mochila
	Guardado.alSalir(jugador) -- guardado final (antes de borrar los datos)
	Jugadores.quitar(jugador)
end)

Jugadores.iniciar()
Economia.iniciar()
CampoPrueba.armarSiFalta()
GeodeServerService.iniciar()
Forja.iniciar()
Social.iniciar()
Eventos.iniciar()
Secretos.iniciar()
Cosmeticos.iniciar()
Misiones.iniciar()
Renacer.iniciar()
Mascotas.iniciar()
Viajes.iniciar()
Dash.iniciar()
Velocidad.iniciar()
HerramientasPrueba.iniciar() -- solo en Studio
