--!strict
-- Efectos temporales activos (Doble paso). No se guardan: duran segundos.

local Efectos = {}

local activos: { [Player]: { [string]: number } } = {}

-- Activa un efecto por `duracion` segundos. Si ya estaba activo, suma el tiempo.
function Efectos.activar(jugador: Player, nombre: string, duracion: number): number
	local delJugador = activos[jugador] or {}
	activos[jugador] = delJugador
	local ahora = workspace:GetServerTimeNow()
	local hasta = math.max(delJugador[nombre] or 0, ahora) + duracion
	delJugador[nombre] = hasta
	return hasta
end

function Efectos.activo(jugador: Player, nombre: string): boolean
	local delJugador = activos[jugador]
	local hasta = if delJugador then delJugador[nombre] else nil
	return hasta ~= nil and hasta > workspace:GetServerTimeNow()
end

function Efectos.olvidar(jugador: Player)
	activos[jugador] = nil
end

return Efectos
