--!strict
-- Cuentas de nivel: las usan servidor (daño y alcance) y cliente (tamaño de los efectos).

local Players = game:GetService("Players")

local Config = require(script.Parent.Config)

local N = Config.Niveles

local Niveles = {}

local function nivelDe(personaje: Model?): number
	local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
	local nivel = jugador and jugador:GetAttribute("Nivel")
	return if typeof(nivel) == "number" then nivel else 1
end

function Niveles.danio(personaje: Model?): number
	return 1 + (nivelDe(personaje) - 1) * N.DanioPorNivel
end

function Niveles.tamano(personaje: Model?): number
	return 1 + (nivelDe(personaje) - 1) * N.TamanoPorNivel
end

-- Experiencia para pasar del nivel dado al siguiente.
function Niveles.xpPara(nivel: number): number
	return math.round(N.XpBase * nivel ^ N.XpCurva)
end

return Niveles
