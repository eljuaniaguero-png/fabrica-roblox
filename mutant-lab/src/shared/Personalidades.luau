--!strict
-- Personalidades (ficha, "Personalidades"): 4 positivas y 4 negativas. Cada criatura tiene
-- una: cambia sus ojos, el ícono sobre su cabeza (borde verde si es positiva, magenta si es
-- negativa) y el ADN que dan ella y las demás de su corral (números en Config.Personalidades).
-- Una criatura nueva hereda la personalidad de sus padres con la tabla fija de abajo; las
-- bases que se compran y las criaturas de antes salen con la de su especie (deEspecie).
-- Algunos catalizadores la cambian (shared/Catalizadores.luau).

local Config = require(script.Parent.Config)

export type Personalidad = {
	Nombre: string, -- para mostrar (con tilde)
	Dibujo: string, -- ícono (shared/Dibujos.luau)
	Positiva: boolean,
	Efecto: string, -- qué hace, en una línea
}

local Personalidades = {}

Personalidades.Datos = {
	Alegre = {
		Nombre = "Alegre",
		Dibujo = "corazon",
		Positiva = true,
		Efecto = "Las demás de su corral dan +10 %",
	},
	Curiosa = { Nombre = "Curiosa", Dibujo = "pregunta", Positiva = true, Efecto = "Da +20 %" },
	Lider = {
		Nombre = "Líder",
		Dibujo = "estrella",
		Positiva = true,
		Efecto = "Las demás de su corral dan +15 %",
	},
	Trabajadora = {
		Nombre = "Trabajadora",
		Dibujo = "martillo",
		Positiva = true,
		Efecto = "Da +35 %",
	},
	Vaga = {
		Nombre = "Vaga",
		Dibujo = "zzz",
		Positiva = false,
		Efecto = "Da la mitad, pero las demás de su corral dan +10 %",
	},
	Peleadora = {
		Nombre = "Peleadora",
		Dibujo = "rayo",
		Positiva = false,
		Efecto = "Da +80 %, pero las demás de su corral dan -20 %",
	},
	Miedosa = {
		Nombre = "Miedosa",
		Dibujo = "gota",
		Positiva = false,
		Efecto = "Da -30 %, pero con una Líder en su corral da +50 %",
	},
	Glotona = {
		Nombre = "Glotona",
		Dibujo = "cubierto",
		Positiva = false,
		Efecto = "Da +60 %, pero las demás de su corral dan -10 %",
	},
} :: { [string]: Personalidad }

Personalidades.Orden = {
	"Alegre",
	"Curiosa",
	"Lider",
	"Trabajadora",
	"Vaga",
	"Peleadora",
	"Miedosa",
	"Glotona",
}

-- Herencia: qué personalidad sale de cada par (no importa el orden). Mismo con mismo da lo
-- mismo, salvo dos Líderes, que se pelean.
local HERENCIA: { [string]: string } = {
	["Alegre|Alegre"] = "Alegre",
	["Alegre|Curiosa"] = "Curiosa",
	["Alegre|Lider"] = "Lider",
	["Alegre|Trabajadora"] = "Alegre",
	["Alegre|Vaga"] = "Alegre",
	["Alegre|Peleadora"] = "Peleadora",
	["Alegre|Miedosa"] = "Alegre",
	["Alegre|Glotona"] = "Glotona",
	["Curiosa|Curiosa"] = "Curiosa",
	["Curiosa|Lider"] = "Curiosa",
	["Curiosa|Trabajadora"] = "Trabajadora",
	["Curiosa|Vaga"] = "Curiosa",
	["Curiosa|Peleadora"] = "Peleadora",
	["Curiosa|Miedosa"] = "Miedosa",
	["Curiosa|Glotona"] = "Curiosa",
	["Lider|Lider"] = "Peleadora",
	["Lider|Trabajadora"] = "Lider",
	["Lider|Vaga"] = "Trabajadora",
	["Lider|Peleadora"] = "Lider",
	["Lider|Miedosa"] = "Miedosa",
	["Lider|Glotona"] = "Lider",
	["Trabajadora|Trabajadora"] = "Trabajadora",
	["Trabajadora|Vaga"] = "Vaga",
	["Trabajadora|Peleadora"] = "Trabajadora",
	["Trabajadora|Miedosa"] = "Trabajadora",
	["Trabajadora|Glotona"] = "Glotona",
	["Vaga|Vaga"] = "Vaga",
	["Vaga|Peleadora"] = "Vaga",
	["Vaga|Miedosa"] = "Miedosa",
	["Vaga|Glotona"] = "Glotona",
	["Peleadora|Peleadora"] = "Peleadora",
	["Peleadora|Miedosa"] = "Peleadora",
	["Peleadora|Glotona"] = "Glotona",
	["Miedosa|Miedosa"] = "Miedosa",
	["Miedosa|Glotona"] = "Vaga",
	["Glotona|Glotona"] = "Glotona",
}

local function par(a: string, b: string): string
	local ia = table.find(Personalidades.Orden, a) or 0
	local ib = table.find(Personalidades.Orden, b) or 0
	return if ia <= ib then a .. "|" .. b else b .. "|" .. a
end

-- La personalidad que sale de dos padres (nil si a alguno le falta).
function Personalidades.heredar(a: string?, b: string?): string?
	if not a or not b then
		return nil
	end
	return HERENCIA[par(a, b)]
end

-- Personalidad fija de una especie, a partir de sus bases (siempre la misma): la de las bases
-- que se compran, la de las criaturas de antes de las personalidades y la de reserva.
function Personalidades.deEspecie(bases: { number }): string
	local suma = #bases
	for i, b in bases do
		suma += b * (2 * i - 1)
	end
	return Personalidades.Orden[suma % #Personalidades.Orden + 1]
end

-- Multiplicador del ADN de cada criatura de un corral, según las personalidades de todas
-- (en el mismo orden). 1 = normal; nunca baja de 0.
function Personalidades.multiplicadores(corral: { string? }): { number }
	local P = Config.Personalidades :: any
	local hayLider = table.find(corral, "Lider") ~= nil
	local r = {}
	for i, propia in corral do
		local m = 1
		local datos = if propia then P[propia] else nil
		if datos then
			m += if propia == "Miedosa" and hayLider then datos.ConLider else datos.Propia
		end
		for j, otra in corral do
			local d2 = if j ~= i and otra then P[otra] else nil
			if d2 then
				m += d2.Vecinas
			end
		end
		r[i] = math.max(0, m)
	end
	return r
end

return Personalidades
