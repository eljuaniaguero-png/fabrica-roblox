--!strict
-- Paleta de la guía de estilo (ficha, "Guía de estilo", puntos 2 y 6).
-- Es el único lugar con colores de la interfaz: cambiar un color del juego es cambiar una línea acá.

local CONTORNO = Color3.fromHex("10141C")
local TEXTO = Color3.fromHex("F5F7FA")

local ELEMENTOS = {
	Fuego = Color3.fromHex("FF6A3D"),
	Agua = Color3.fromHex("3DB8FF"),
	Planta = Color3.fromHex("5DDB6A"),
	Electrico = Color3.fromHex("FFE14A"),
	Sombra = Color3.fromHex("8E6BFF"),
}

local Paleta = {
	Fondo = Color3.fromHex("1B2A3A"), -- azul petróleo oscuro: paredes y piso del laboratorio
	Noche = Color3.fromHex("2A1F3D"), -- violeta noche: sombras y cielo
	Metal = Color3.fromHex("5C6B7A"), -- gris azulado: máquinas, estructuras y botones secundarios
	Acento = Color3.fromHex("7CFF4F"), -- verde ácido: ADN, slime, botón de fusionar
	Alerta = Color3.fromHex("FF4FA3"), -- magenta: novedades y alertas
	Dorado = Color3.fromHex("FFC93C"), -- premios, raro, Premium
	Texto = TEXTO, -- blanco frío
	Contorno = CONTORNO, -- casi negro: contorno de interfaz y sombra de texto

	-- Un color por elemento (criaturas, íconos, filtros y pistas).
	Elementos = ELEMENTOS,

	-- Borde de tarjetas y anillo bajo la criatura, según la generación (1, 2 y 3).
	Generaciones = {
		Color3.fromHex("F5F7FA"),
		Color3.fromHex("3DB8FF"),
		Color3.fromHex("B07CFF"),
	},
	Mutante = Color3.fromHex("FFC93C"), -- dorado con brillo

	-- Tonos de interfaz (ventanas, tarjetas y estados).
	Superficie = Color3.fromHex("1B2A3A"), -- fondo de las ventanas (el mismo azul petróleo)
	SuperficieElevada = Color3.fromHex("26394D"), -- tarjetas y casilleros dentro de una ventana
	SuperficieClara = Color3.fromHex("344B63"), -- fondo de las siluetas y de lo resaltado
	Deshabilitado = Color3.fromHex("4A5664"), -- botones que todavía no se pueden usar
	Error = Color3.fromHex("FF5A5F"), -- precios que no alcanzan, avisos de error, cerrar
	Exito = Color3.fromHex("4FE3A0"), -- avisos de que algo salió bien
	Silueta = Color3.fromHex("0B0E14"), -- criaturas sin descubrir
	LuzVista = Color3.fromHex("BEB4C8"), -- luz ambiente de las vistas 3D de la interfaz

	-- Colores de los papelitos de las celebraciones: verde ácido, magenta, dorado y los elementos.
	Papelitos = {
		Color3.fromHex("7CFF4F"),
		Color3.fromHex("FF4FA3"),
		Color3.fromHex("FFC93C"),
		ELEMENTOS.Fuego,
		ELEMENTOS.Agua,
		ELEMENTOS.Planta,
		ELEMENTOS.Electrico,
		ELEMENTOS.Sombra,
	},

	-- Versión oscura de un color (la franja de abajo de los botones).
	oscuro = function(color: Color3, cuanto: number?): Color3
		return color:Lerp(CONTORNO, cuanto or 0.4)
	end,

	-- Versión clara de un color (brillos de los íconos).
	claro = function(color: Color3, cuanto: number?): Color3
		return color:Lerp(TEXTO, cuanto or 0.45)
	end,
}

return Paleta
