--!strict
-- Freno contra el spam de remotos: cada jugador puede pedir cada acción como mucho una vez
-- cada tantos segundos. El servidor ignora lo que llega antes.

local Players = game:GetService("Players")

local ultimos: { [Player]: { [string]: number } } = {}

local Frecuencia = {}

-- true si `jugador` puede hacer `accion` ahora (y anota la hora); false si la pidió hace menos
-- de `segundos`.
function Frecuencia.permitir(jugador: Player, accion: string, segundos: number): boolean
	local ahora = os.clock()
	local suyos = ultimos[jugador]
	if not suyos then
		suyos = {}
		ultimos[jugador] = suyos
	end
	local antes = (suyos :: { [string]: number })[accion]
	if antes and ahora - antes < segundos then
		return false
	end
	(suyos :: { [string]: number })[accion] = ahora
	return true
end

Players.PlayerRemoving:Connect(function(jugador: Player)
	ultimos[jugador] = nil
end)

return Frecuencia
