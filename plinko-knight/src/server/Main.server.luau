--!strict
-- Arranque del servidor de Plinko Knight: la partida de cada jugador, los remotos de los tiros
-- y los de la mazmorra.

require(script.Parent:WaitForChild("Partida"))
require(script.Parent:WaitForChild("Tiros")).iniciar()
require(script.Parent:WaitForChild("Peleas")).iniciar()

print("Plinko Knight: servidor listo")
