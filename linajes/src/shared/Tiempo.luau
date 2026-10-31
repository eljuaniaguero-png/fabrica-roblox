--!strict
-- Hora del juego (0 a 24) igual en servidor y clientes, sacada del reloj del servidor.

local Config = require(script.Parent.Config)

local Tiempo = {}

function Tiempo.hora(): number
	local segundosPorDia = Config.Mundo.MinutosPorDia * 60
	return (workspace:GetServerTimeNow() % segundosPorDia) / segundosPorDia * 24
end

function Tiempo.esDeNoche(hora: number?): boolean
	local h = hora or Tiempo.hora()
	return h < 6 or h >= 19
end

return Tiempo
