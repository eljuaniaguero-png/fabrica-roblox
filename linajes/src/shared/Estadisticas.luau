--!strict
-- Árbol de estadísticas (bóveda: 06 Linajes/Estadísticas y movimiento). Cuentas compartidas:
-- el servidor las usa para daño, vida, energía y recarga; el cliente para mostrar y para la velocidad.
-- Los niveles de cada estadística llegan como atributos del Player (St_Vida, St_Fuerza...).

local Players = game:GetService("Players")

local Config = require(script.Parent.Config)

local E = Config.Estadisticas

local Estadisticas = {}

function Estadisticas.nivel(jugador: Player?, stat: string): number
	if not E.Activas then
		return 0 -- sandbox sin árbol: todos pelean con las mismas estadísticas
	end
	local v = jugador and jugador:GetAttribute("St_" .. stat)
	return if typeof(v) == "number" then v else 0
end

-- Cuánto suma la estadística de un personaje (0 si no es de un jugador: matones y maniquí).
local function suma(personaje: Model?, stat: string): number
	local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
	return Estadisticas.nivel(jugador, stat) * (E.Stats :: any)[stat].PorNivel
end

function Estadisticas.vidaMax(personaje: Model?): number
	return Config.Combate.Vida + suma(personaje, "Vida")
end

function Estadisticas.energiaMax(personaje: Model?): number
	return Config.Combate.Energia + suma(personaje, "Energia")
end

function Estadisticas.fuerza(personaje: Model?): number
	return 1 + suma(personaje, "Fuerza")
end

function Estadisticas.defensa(personaje: Model?): number
	return 1 - suma(personaje, "Defensa")
end

function Estadisticas.recarga(personaje: Model?): number
	return 1 - suma(personaje, "Recarga")
end

-- Solo cliente: velocidad a pie del jugador local.
function Estadisticas.velocidad(base: number): number
	return base
		* (1 + Estadisticas.nivel(Players.LocalPlayer, "Velocidad") * E.Stats.Velocidad.PorNivel)
end

function Estadisticas.gastados(jugador: Player): number
	local total = 0
	for _, stat in E.Orden do
		total += Estadisticas.nivel(jugador, stat)
	end
	return total
end

function Estadisticas.libres(jugador: Player): number
	local nivel = jugador:GetAttribute("Nivel")
	local ganados = ((if typeof(nivel) == "number" then nivel else 1) - 1) * E.PuntosPorNivel
	return math.max(math.min(ganados, E.MaxTotal) - Estadisticas.gastados(jugador), 0)
end

-- ¿Se puede subir esta estadística? Lo usan el servidor (para validar) y el menú (para mostrar).
function Estadisticas.puede(jugador: Player, stat: string): (boolean, string)
	local actual = Estadisticas.nivel(jugador, stat)
	local nivel = jugador:GetAttribute("Nivel")
	if actual >= E.MaxPorStat then
		return false, "Al máximo"
	elseif Estadisticas.libres(jugador) <= 0 then
		return false, "Sin puntos: subí de nivel"
	elseif actual == E.MaxPorStat - 1 and (typeof(nivel) ~= "number" or nivel < E.NivelUltimo) then
		return false, string.format("El último nivel pide nivel %d", E.NivelUltimo)
	end
	return true, "Tocá para subir"
end

return Estadisticas
