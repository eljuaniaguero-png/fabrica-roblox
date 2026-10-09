--!strict
-- Arranque del servidor: carga los sistemas y conecta la entrada y salida de jugadores.

local Players = game:GetService("Players")

local Remotos = require(script.Parent.Remotos)
local Corrales = require(script.Parent.Corrales)
local Diario = require(script.Parent.Diario)
local Economia = require(script.Parent.Economia)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Metas = require(script.Parent.Metas)
local Misiones = require(script.Parent.Misiones)
local Tablero = require(script.Parent.Tablero)
require(script.Parent.MaquinaFusion)
require(script.Parent.TiendaPistas)
require(script.Parent.Tienda)
require(script.Parent.HerramientasPrueba)

local function alEntrar(jugador: Player)
	local guardados = Guardado.cargar(jugador)
	if not jugador.Parent then
		return -- se fue mientras cargaba
	end
	Jugadores.crear(jugador, guardados)
	Laboratorios.asignar(jugador)
	Corrales.actualizar(jugador)
	local d = Jugadores.obtener(jugador)
	if d then
		Tablero.completar(jugador, d)
		Laboratorios.actualizarTablero(jugador, d.Pedidos)
		Jugadores.publicarPedidos(jugador)
	end
	-- Volver mañana: lo que juntaron sin vos, el premio diario, misiones del día y metas.
	Diario.alEntrar(jugador)
	Misiones.alDia(jugador)
	Metas.publicar(jugador)
	Metas.revisar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	-- Copia los datos en el acto (antes de que se borren abajo) y guarda sin frenar la salida.
	task.spawn(Guardado.salir, jugador)
	Corrales.limpiar(jugador)
	Laboratorios.liberar(jugador)
	Jugadores.quitar(jugador)
end)

Economia.iniciar()
Guardado.iniciar()
Tablero.iniciar()
Diario.iniciar()

-- Cada tanto se fija si cambió el día (lo decide el servidor): misiones nuevas, otro
-- experimento y el premio diario disponible.
task.spawn(function()
	while true do
		task.wait(15)
		for jugador in Jugadores.todos() do
			if Misiones.alDia(jugador) then
				Diario.publicar(jugador)
				Remotos.Aviso:FireClient(
					jugador,
					"¡Nuevo día! Misiones nuevas, otro experimento y tu premio diario.",
					"info"
				)
			end
		end
	end
end)
