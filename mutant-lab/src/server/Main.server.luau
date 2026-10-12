--!strict
-- Arranque del servidor: carga los sistemas y conecta la entrada y salida de jugadores.

local Players = game:GetService("Players")

local Remotos = require(script.Parent.Remotos)
local Corrales = require(script.Parent.Corrales)
local Diario = require(script.Parent.Diario)
local Economia = require(script.Parent.Economia)
local Equipo = require(script.Parent.Equipo)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Metas = require(script.Parent.Metas)
local Misiones = require(script.Parent.Misiones)
local Paseos = require(script.Parent.Paseos)
local Social = require(script.Parent.Social)
local Tablero = require(script.Parent.Tablero)
require(script.Parent.MaquinaFusion)
require(script.Parent.TiendaPistas)
require(script.Parent.Tienda)
require(script.Parent.HerramientasPrueba)

local function alEntrar(jugador: Player)
	local guardados, ok = Guardado.cargar(jugador)
	if not ok or not jugador.Parent then
		return -- se fue mientras cargaba, o no se pudo cargar (ya salió con un aviso)
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
	-- Jugar con otros: "me gusta" y posiciones.
	Social.publicar(jugador)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	-- Pasa los datos al perfil en el acto (antes de que se borren abajo) y cierra la sesión.
	Guardado.salir(jugador)
	Corrales.limpiar(jugador)
	Laboratorios.liberar(jugador)
	Jugadores.quitar(jugador)
end)

Economia.iniciar()
Guardado.iniciar()
Tablero.iniciar()
Diario.iniciar()
Social.iniciar()
Paseos.iniciar()
Equipo.iniciar()

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
