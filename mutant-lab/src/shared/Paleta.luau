--!strict
-- Paleta de la guía de estilo (ficha, "Guía de estilo", punto 2).
-- Cambiar un color del juego es cambiar una línea acá.

local Paleta = {
	Fondo = Color3.fromHex("1B2A3A"), -- azul petróleo oscuro: paredes y piso del laboratorio
	Noche = Color3.fromHex("2A1F3D"), -- violeta noche: sombras y cielo
	Metal = Color3.fromHex("5C6B7A"), -- gris azulado: máquinas y estructuras
	Acento = Color3.fromHex("7CFF4F"), -- verde ácido: ADN, slime, botón de fusionar
	Alerta = Color3.fromHex("FF4FA3"), -- magenta: novedades y alertas
	Dorado = Color3.fromHex("FFC93C"), -- premios, raro
	Texto = Color3.fromHex("F5F7FA"), -- blanco frío
	Contorno = Color3.fromHex("10141C"), -- casi negro: contorno de interfaz y sombra de texto

	-- Un color por elemento (criaturas, íconos y pistas).
	Elementos = {
		Fuego = Color3.fromHex("FF6A3D"),
		Agua = Color3.fromHex("3DB8FF"),
		Planta = Color3.fromHex("5DDB6A"),
		Electrico = Color3.fromHex("FFE14A"),
		Sombra = Color3.fromHex("8E6BFF"),
	},

	-- Borde de tarjetas y anillo bajo la criatura, según la generación (1, 2 y 3).
	Generaciones = {
		Color3.fromHex("F5F7FA"),
		Color3.fromHex("3DB8FF"),
		Color3.fromHex("B07CFF"),
	},
	Mutante = Color3.fromHex("FFC93C"), -- dorado con brillo
}

return Paleta
