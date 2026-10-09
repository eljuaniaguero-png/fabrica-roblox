--!strict
-- Personalidades: el ícono que se ve sobre la cabeza y si es positiva o negativa
-- (borde verde o magenta). Provisorio hasta diseñar las Variantes: por ahora solo cambian
-- el aspecto (ojos e ícono), no la producción de ADN.
-- Mientras las criaturas no tengan personalidad propia, cada especie tiene una fija
-- (deEspecie), que es la que muestra la ficha de la Mutadex.

export type Personalidad = {
	Nombre: string, -- para mostrar (con tilde)
	Icono: string, -- texto del cartelito sobre la cabeza
	Dibujo: string, -- ícono de la interfaz (client/UI/Iconos.luau)
	Positiva: boolean,
}

local Personalidades = {}

Personalidades.Datos = {
	Alegre = { Nombre = "Alegre", Icono = "♥", Dibujo = "corazon", Positiva = true },
	Curiosa = { Nombre = "Curiosa", Icono = "?", Dibujo = "pregunta", Positiva = true },
	Lider = { Nombre = "Líder", Icono = "★", Dibujo = "estrella", Positiva = true },
	Trabajadora = { Nombre = "Trabajadora", Icono = "🔨", Dibujo = "martillo", Positiva = true },
	Vaga = { Nombre = "Vaga", Icono = "Zzz", Dibujo = "zzz", Positiva = false },
	Peleadora = { Nombre = "Peleadora", Icono = "⚡", Dibujo = "rayo", Positiva = false },
	Miedosa = { Nombre = "Miedosa", Icono = "💧", Dibujo = "gota", Positiva = false },
	Glotona = { Nombre = "Glotona", Icono = "🍴", Dibujo = "cubierto", Positiva = false },
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

-- Personalidad fija de una especie, a partir de sus bases (siempre la misma).
function Personalidades.deEspecie(bases: { number }): string
	local suma = #bases
	for i, b in bases do
		suma += b * (2 * i - 1)
	end
	return Personalidades.Orden[suma % #Personalidades.Orden + 1]
end

return Personalidades
