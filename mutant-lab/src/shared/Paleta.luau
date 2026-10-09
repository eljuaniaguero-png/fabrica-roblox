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

	-- Catalizadores (shared/Catalizadores.luau): el color que le dan a la variante.
	Catalizadores = {
		Rayo = Color3.fromHex("FFE14A"),
		Hielo = Color3.fromHex("BDF2FF"),
		Slime = Color3.fromHex("7CFF4F"),
		Lava = Color3.fromHex("FF6A3D"),
		Sombra = Color3.fromHex("8E6BFF"),
	},
	Residuo = Color3.fromHex("6B5A4A"), -- se mezcla con los colores de los padres

	-- Color del cuerpo y de las manchas de cada especie base, en el orden de la rueda
	-- (shared/Especies.luau). Las fusiones mezclan estos colores pieza por pieza.
	Especies = {
		{ Color = Color3.fromHex("38C8FF"), Manchas = Color3.fromHex("E8FAFF") }, -- 1 Glupona
		{ Color = Color3.fromHex("4CCB4A"), Manchas = Color3.fromHex("2E8A3A") }, -- 2 Rámulo
		{ Color = Color3.fromHex("F23DB8"), Manchas = Color3.fromHex("FFFFFF") }, -- 3 Sutomi
		{ Color = Color3.fromHex("7D8A9C"), Manchas = Color3.fromHex("4E5866") }, -- 4 Rocote
		{ Color = Color3.fromHex("FF3B30"), Manchas = Color3.fromHex("FFB020") }, -- 5 Chisparo
		{ Color = Color3.fromHex("E0A040"), Manchas = Color3.fromHex("A86A22") }, -- 6 Dunaqui
		{ Color = Color3.fromHex("B07CFF"), Manchas = Color3.fromHex("FFFFFF") }, -- 7 Zoplito
		{ Color = Color3.fromHex("F2FBFF"), Manchas = Color3.fromHex("8FE3FF") }, -- 8 Brinoza
		{ Color = Color3.fromHex("FFE21F"), Manchas = Color3.fromHex("FF8A00") }, -- 9 Fotina
		{ Color = Color3.fromHex("2F4BD8"), Manchas = Color3.fromHex("8EF0FF") }, -- 10 Nerulo
	},

	-- Detalles fijos de las piezas de las criaturas (shared/Piezas.luau y Generador.luau).
	Piezas = {
		Blanco = Color3.fromHex("FFFFFF"), -- ojos
		Negro = Color3.fromHex("1B1030"), -- pupilas, narices y siluetas negras en el mundo
		Crema = Color3.fromHex("FFE9D2"), -- cara del hongo
		Naranja = Color3.fromHex("FFB020"), -- picos, cuernos de brasa, patas de ave y chispas
		Llama = Color3.fromHex("FF7A00"), -- llama de la cola
		Amarillo = Color3.fromHex("FFE21F"), -- punta de la llama y centro de las flores
		Burbujas = Color3.fromHex("BDF2FF"),
		Flores = Color3.fromHex("FF8FC8"),
		Esporas = Color3.fromHex("FF7BE0"),
		Nieve = Color3.fromHex("FFFFFF"),
		Luz = Color3.fromHex("FFE680"), -- luz propia de la especie que brilla
		Aura = Color3.fromHex("FFF3B0"), -- aura de la generación 3
	},

	-- Laboratorio (server/Laboratorios.luau): corrales abiertos y cerrados.
	Laboratorio = {
		PisoAbierto = Color3.fromHex("2B4763"),
		PisoCerrado = Color3.fromHex("26303C"),
		CupulaAbierta = Color3.fromHex("CFF6FF"),
		CupulaCerrada = Color3.fromHex("3B4654"),
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
