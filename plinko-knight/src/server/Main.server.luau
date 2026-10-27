--!strict
-- Arranque del servidor de Plinko Knight: los remotos de los tiros y de la mazmorra, y la entrada
-- y salida de cada jugador. Al entrar se carga su progreso (server/Guardado); recién con eso se
-- arma su partida (fase "inicio": elegir bola). Al salir se guarda y se borra la partida.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Guardado = require(script.Parent:WaitForChild("Guardado"))
local Partida = require(script.Parent:WaitForChild("Partida"))
local Peleas = require(script.Parent:WaitForChild("Peleas"))
local Analitica = require(script.Parent:WaitForChild("Analitica"))
require(script.Parent:WaitForChild("Tiros")).iniciar()
Peleas.iniciar()
require(script.Parent:WaitForChild("Sala")).iniciar() -- etapa 7b-1: la sala arcade

Guardado.alGuardar(function(jugador: Player)
	local p = Partida.de(jugador)
	return if p then p.Progreso else nil
end)
Guardado.iniciar()

local function entrar(jugador: Player)
	local datos = Guardado.cargar(jugador) -- espera; nil = no se pudo y ya lo sacó
	if not datos or jugador.Parent ~= Players then
		return
	end
	Partida.iniciar(jugador, datos)
	Analitica.paso(jugador, "Entró")
	Peleas.avisarProgreso(jugador, {}) -- primero el progreso: la pantalla de inicio lo usa
	Peleas.avisar(jugador)
end

Players.PlayerAdded:Connect(entrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(entrar, jugador)
end
Players.PlayerRemoving:Connect(function(jugador: Player)
	Guardado.alSalir(jugador)
	Partida.quitar(jugador)
end)

-- Comando de prueba, solo en Studio (tecla L): hace lo mismo que salir y volver a entrar (cierra
-- la sesión guardando y la vuelve a cargar del almacén), para probar el guardado sin publicar.
if RunService:IsStudio() then
	local prueba =
		game:GetService("ReplicatedStorage"):WaitForChild("Remotos"):WaitForChild("Prueba")
	local recargando: { [Player]: boolean } = {}
	prueba.OnServerEvent:Connect(function(jugador: Player, comando: any)
		if comando ~= "recargar" or recargando[jugador] then
			return
		end
		recargando[jugador] = true
		Guardado.alSalir(jugador)
		Partida.quitar(jugador)
		task.wait(1)
		print("[Guardado] Prueba: volviendo a cargar a " .. jugador.Name)
		entrar(jugador)
		recargando[jugador] = nil
	end)
end

print("Plinko Knight: servidor listo")
