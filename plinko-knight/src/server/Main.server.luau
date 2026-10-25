--!strict
-- Arranque del servidor de Plinko Knight: la partida de cada jugador y los remotos de los tiros.

require(script.Parent:WaitForChild("Partida"))
require(script.Parent:WaitForChild("Tiros")).iniciar()

print("Plinko Knight: servidor listo")
