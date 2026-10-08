--!strict
-- Personalidades: el ícono que se ve sobre la cabeza y si es positiva o negativa
-- (borde verde o magenta). Provisorio hasta diseñar las Variantes: por ahora solo cambian
-- el aspecto (ojos e ícono), no la producción de ADN.

export type Personalidad = {
	Icono: string,
	Positiva: boolean,
}

local Personalidades: { [string]: Personalidad } = {
	Alegre = { Icono = "♥", Positiva = true },
	Curiosa = { Icono = "?", Positiva = true },
	Lider = { Icono = "★", Positiva = true },
	Trabajadora = { Icono = "🔨", Positiva = true },
	Vaga = { Icono = "Zzz", Positiva = false },
	Peleadora = { Icono = "⚡", Positiva = false },
	Miedosa = { Icono = "💧", Positiva = false },
	Glotona = { Icono = "🍴", Positiva = false },
}

return Personalidades
