--!strict
-- Las 10 especies base, en el orden de la rueda.
-- Cada pieza se identifica con el número de la base que la trae
-- (Cabeza = 3 quiere decir "la cabeza de Sutomi"). Los colores están en Paleta.Especies.

local Paleta = require(script.Parent.Paleta)

export type Base = {
	Numero: number,
	Nombre: string,
	Silabas: { string }, -- siempre 3, se usan para armar los nombres
	Tema: string,
	Elemento: string, -- clave de Paleta.Elementos (provisorio: 2 bases por elemento)
	Color: Color3,
	Manchas: Color3, -- color secundario propio (solo se ve en la base pura)
	Rasgo: string,
	Pista: string, -- cómo la describe una pista ("Viene de una criatura que ...")
}

local bases: { Base } = {
	{
		Numero = 1,
		Nombre = "Glupona",
		Silabas = { "Glu", "po", "na" },
		Tema = "Agua",
		Elemento = "Agua",
		Color = Paleta.Especies[1].Color,
		Manchas = Paleta.Especies[1].Manchas,
		Rasgo = "Burbujas",
		Pista = "vive en el agua",
	},
	{
		Numero = 2,
		Nombre = "Rámulo",
		Silabas = { "Ra", "mu", "lo" },
		Tema = "Musgo",
		Elemento = "Planta",
		Color = Paleta.Especies[2].Color,
		Manchas = Paleta.Especies[2].Manchas,
		Rasgo = "Flores",
		Pista = "tiene hojas en la cabeza",
	},
	{
		Numero = 3,
		Nombre = "Sutomi",
		Silabas = { "Su", "to", "mi" },
		Tema = "Hongo",
		Elemento = "Planta",
		Color = Paleta.Especies[3].Color,
		Manchas = Paleta.Especies[3].Manchas,
		Rasgo = "Esporas",
		Pista = "es un hongo",
	},
	{
		Numero = 4,
		Nombre = "Rocote",
		Silabas = { "Ro", "co", "te" },
		Tema = "Roca",
		Elemento = "Sombra",
		Color = Paleta.Especies[4].Color,
		Manchas = Paleta.Especies[4].Manchas,
		Rasgo = "Rueda",
		Pista = "es de piedra",
	},
	{
		Numero = 5,
		Nombre = "Chisparo",
		Silabas = { "Chis", "pa", "ro" },
		Tema = "Fuego",
		Elemento = "Fuego",
		Color = Paleta.Especies[5].Color,
		Manchas = Paleta.Especies[5].Manchas,
		Rasgo = "Chispas",
		Pista = "echa chispas de fuego",
	},
	{
		Numero = 6,
		Nombre = "Dunaqui",
		Silabas = { "Du", "na", "qui" },
		Tema = "Arena",
		Elemento = "Fuego",
		Color = Paleta.Especies[6].Color,
		Manchas = Paleta.Especies[6].Manchas,
		Rasgo = "SeEntierra",
		Pista = "vive en la arena",
	},
	{
		Numero = 7,
		Nombre = "Zoplito",
		Silabas = { "Zo", "pli", "to" },
		Tema = "Viento",
		Elemento = "Electrico",
		Color = Paleta.Especies[7].Color,
		Manchas = Paleta.Especies[7].Manchas,
		Rasgo = "Flota",
		Pista = "tiene pico y vuela",
	},
	{
		Numero = 8,
		Nombre = "Brinoza",
		Silabas = { "Bri", "no", "za" },
		Tema = "Hielo",
		Elemento = "Agua",
		Color = Paleta.Especies[8].Color,
		Manchas = Paleta.Especies[8].Manchas,
		Rasgo = "Escarcha",
		Pista = "es de hielo",
	},
	{
		Numero = 9,
		Nombre = "Fotina",
		Silabas = { "Fo", "ti", "na" },
		Tema = "Luz",
		Elemento = "Electrico",
		Color = Paleta.Especies[9].Color,
		Manchas = Paleta.Especies[9].Manchas,
		Rasgo = "Brilla",
		Pista = "brilla y vuela",
	},
	{
		Numero = 10,
		Nombre = "Nerulo",
		Silabas = { "Ne", "ru", "lo" },
		Tema = "Noche",
		Elemento = "Sombra",
		Color = Paleta.Especies[10].Color,
		Manchas = Paleta.Especies[10].Manchas,
		Rasgo = "Transparente",
		Pista = "tiene tres ojos y vuela",
	},
}

return bases
