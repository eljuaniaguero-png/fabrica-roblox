--!strict
-- Las 10 especies base, en el orden de la rueda.
-- Cada pieza se identifica con el número de la base que la trae
-- (Cabeza = 3 quiere decir "la cabeza de Sutomi").

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
		Color = Color3.fromHex("38C8FF"),
		Manchas = Color3.fromHex("E8FAFF"),
		Rasgo = "Burbujas",
		Pista = "vive en el agua",
	},
	{
		Numero = 2,
		Nombre = "Rámulo",
		Silabas = { "Ra", "mu", "lo" },
		Tema = "Musgo",
		Elemento = "Planta",
		Color = Color3.fromHex("4CCB4A"),
		Manchas = Color3.fromHex("2E8A3A"),
		Rasgo = "Flores",
		Pista = "tiene hojas en la cabeza",
	},
	{
		Numero = 3,
		Nombre = "Sutomi",
		Silabas = { "Su", "to", "mi" },
		Tema = "Hongo",
		Elemento = "Planta",
		Color = Color3.fromHex("F23DB8"),
		Manchas = Color3.fromHex("FFFFFF"),
		Rasgo = "Esporas",
		Pista = "es un hongo",
	},
	{
		Numero = 4,
		Nombre = "Rocote",
		Silabas = { "Ro", "co", "te" },
		Tema = "Roca",
		Elemento = "Sombra",
		Color = Color3.fromHex("7D8A9C"),
		Manchas = Color3.fromHex("4E5866"),
		Rasgo = "Rueda",
		Pista = "es de piedra",
	},
	{
		Numero = 5,
		Nombre = "Chisparo",
		Silabas = { "Chis", "pa", "ro" },
		Tema = "Fuego",
		Elemento = "Fuego",
		Color = Color3.fromHex("FF3B30"),
		Manchas = Color3.fromHex("FFB020"),
		Rasgo = "Chispas",
		Pista = "echa chispas de fuego",
	},
	{
		Numero = 6,
		Nombre = "Dunaqui",
		Silabas = { "Du", "na", "qui" },
		Tema = "Arena",
		Elemento = "Fuego",
		Color = Color3.fromHex("E0A040"),
		Manchas = Color3.fromHex("A86A22"),
		Rasgo = "SeEntierra",
		Pista = "vive en la arena",
	},
	{
		Numero = 7,
		Nombre = "Zoplito",
		Silabas = { "Zo", "pli", "to" },
		Tema = "Viento",
		Elemento = "Electrico",
		Color = Color3.fromHex("B07CFF"),
		Manchas = Color3.fromHex("FFFFFF"),
		Rasgo = "Flota",
		Pista = "tiene pico y vuela",
	},
	{
		Numero = 8,
		Nombre = "Brinoza",
		Silabas = { "Bri", "no", "za" },
		Tema = "Hielo",
		Elemento = "Agua",
		Color = Color3.fromHex("F2FBFF"),
		Manchas = Color3.fromHex("8FE3FF"),
		Rasgo = "Escarcha",
		Pista = "es de hielo",
	},
	{
		Numero = 9,
		Nombre = "Fotina",
		Silabas = { "Fo", "ti", "na" },
		Tema = "Luz",
		Elemento = "Electrico",
		Color = Color3.fromHex("FFE21F"),
		Manchas = Color3.fromHex("FF8A00"),
		Rasgo = "Brilla",
		Pista = "brilla y vuela",
	},
	{
		Numero = 10,
		Nombre = "Nerulo",
		Silabas = { "Ne", "ru", "lo" },
		Tema = "Noche",
		Elemento = "Sombra",
		Color = Color3.fromHex("2F4BD8"),
		Manchas = Color3.fromHex("8EF0FF"),
		Rasgo = "Transparente",
		Pista = "tiene tres ojos y vuela",
	},
}

return bases
