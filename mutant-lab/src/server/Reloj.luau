--!strict
-- La hora del juego la decide el servidor, nunca el reloj del jugador (ficha, "Parte 8").
-- Se usa la hora UTC: el día cambia a las 0:00 UTC. En Studio, las herramientas de prueba
-- pueden adelantarla (Desfase) para simular el paso de los días.

local Reloj = {}

Reloj.Desfase = 0 -- segundos que se suman a la hora real (solo pruebas)

function Reloj.ahora(): number
	return os.time() + Reloj.Desfase
end

-- Número de día (días desde 1970, en UTC).
function Reloj.dia(t: number?): number
	return (t or Reloj.ahora()) // 86400
end

-- Segundos que faltan para que cambie el día.
function Reloj.faltaParaManana(): number
	return 86400 - Reloj.ahora() % 86400
end

return Reloj
