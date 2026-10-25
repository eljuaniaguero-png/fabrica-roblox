--!strict
-- Arranque del servidor de Pesca al Compás: arma el muelle, carga los sistemas y conecta la
-- entrada y salida de jugadores.

local Players = game:GetService("Players")

local Economia = require(script.Parent.Economia)
local Equipo = require(script.Parent.Equipo)
local Guardado = require(script.Parent.Guardado)
local Iluminacion = require(script.Parent.Iluminacion)
local Jugadores = require(script.Parent.Jugadores)
local Misiones = require(script.Parent.Misiones)
local Monetizacion = require(script.Parent.Monetizacion)
local Mundo = require(script.Parent.Mundo)
local Pesca = require(script.Parent.Pesca)
local Remotos = require(script.Parent.Remotos)
local Tienda = require(script.Parent.Tienda)

Iluminacion.aplicar() -- estilo "Toon de playa" (shared/Estilo.luau)
Mundo.armarSiFalta() -- antes que todo lo que busca PuntoPesca y Vendedor

local function alEntrar(jugador: Player)
	local datos = Guardado.cargar(jugador) -- espera; nil = no se pudo y ya lo sacó
	if not datos then
		return
	end
	Jugadores.crear(jugador, datos)
	Misiones.premioDiario(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
local ultimoPedido: { [Player]: number } = {}

Players.PlayerRemoving:Connect(function(jugador: Player)
	ultimoPedido[jugador] = nil
	Pesca.alSalir(jugador) -- el pez a medio sacar se escapa, la boya se borra
	Tienda.alSalir(jugador)
	Equipo.alSalir(jugador)
	Guardado.alSalir(jugador) -- guardado final (antes de borrar los datos)
	Jugadores.quitar(jugador)
end)

Pesca.iniciar()
Economia.iniciar()
Equipo.iniciar() -- caña en la mano y cebo colgando, para todos los jugadores
Tienda.iniciar() -- después de Mundo.armarSiFalta: busca la casa de cebo en el mapa
Monetizacion.iniciar() -- Robux: productos y pases (los que tienen Id = 0 quedan apagados)
-- el cliente pide el estado al arrancar (si sus datos todavía cargan, se lo manda Jugadores.crear)
-- como mucho un pedido por segundo por jugador, para que spamearlo no gaste red del servidor
Remotos.Estado.OnServerEvent:Connect(function(jugador: Player)
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or -math.huge) < 1 then
		return
	end
	ultimoPedido[jugador] = ahora
	Jugadores.enviar(jugador)
end)
