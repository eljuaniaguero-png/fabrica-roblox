--!strict
-- La Mutadex del lado del servidor: suma especies, paga el premio por descubrir
-- y el premio grande por completar una generación (una sola vez cada una).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Jugadores = require(script.Parent.Jugadores)

local P = Config.Premios

local Coleccion = {}

-- Premio en ADN por descubrir una especie con una fusión que costó `costo`.
function Coleccion.premioDescubrir(costo: number): number
	return math.max(P.MinimoDescubrir, math.round(costo * P.MultiplicadorDescubrir))
end

-- Suma la especie. Devuelve true si es la primera vez que la tenés.
function Coleccion.agregar(d: Jugadores.Datos, clave: string): boolean
	local nueva = not d.Especies[clave]
	d.Especies[clave] = true
	return nueva
end

-- Paga el premio grande de cada generación que se acaba de completar.
-- Devuelve las celebraciones para avisarle al cliente (después de la animación de fusión).
function Coleccion.revisarGeneraciones(d: Jugadores.Datos): { Fusion.Celebracion }
	local total, tengo = { 0, 0, 0 }, { 0, 0, 0 }
	for _, c in Fusion.todas() do
		total[c.Gen] += 1
		if d.Especies[c.Clave] then
			tengo[c.Gen] += 1
		end
	end
	local completo = tengo[1] == total[1] and tengo[2] == total[2] and tengo[3] == total[3]
	local celebraciones = {}
	for gen = 1, 3 do
		if tengo[gen] == total[gen] and not d.GeneracionesPremiadas[gen] then
			d.GeneracionesPremiadas[gen] = true
			local premio = P.PorGeneracion[gen]
			d.ADN += premio
			table.insert(celebraciones, { Gen = gen, Premio = premio, Completo = completo })
		end
	end
	return celebraciones
end

return Coleccion
