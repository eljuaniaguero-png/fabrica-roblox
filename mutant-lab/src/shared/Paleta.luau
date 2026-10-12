--!strict
-- Paleta del estilo toon (ideas/estilo-toon.md, "Paleta nueva").
-- Es el único lugar con colores del juego: cambiar un color es cambiar una línea acá.
-- `Toon` tiene los colores base de la guía; el resto son nombres por uso que apuntan a ellos.
-- Los nombres por uso no se cambian a la ligera: el código, shared/ArteColores.luau y los scripts
-- de Blender (arte/scripts/comun.py) los buscan por nombre ("Piezas.Negro", "Elementos.Fuego").
-- comun.py lee este archivo como texto: cada color va como Color3.fromHex("...") o como el nombre
-- de un local en mayúsculas; en las listas, siempre Color3.fromHex.

local CONTORNO = Color3.fromHex("241A3A") -- violeta casi negro: contorno de todo
local PUPILA = Color3.fromHex("2B1B4A") -- violeta oscuro: pupilas, narices y bocas
local CIELO_ARRIBA = Color3.fromHex("3B3A9E") -- violeta azulado
local CIELO_ABAJO = Color3.fromHex("7A4FB0") -- violeta rosado
local HORIZONTE = Color3.fromHex("F2A3C7") -- rosa atardecer: horizonte y niebla
local CREMA = Color3.fromHex("FFC9A3") -- crema durazno: pisos claros y pedestales
local ROSA = Color3.fromHex("FF6FA8") -- rosa chicle: anillos y bordes
local AMARILLO = Color3.fromHex("FFC93A") -- amarillo sol
local NARANJA = Color3.fromHex("FF7A2E")
local ROJO = Color3.fromHex("FF3B3B") -- rojo tomate: narices y alertas
local MENTA = Color3.fromHex("5CF0A0") -- verde menta ácido: lo del laboratorio y el ADN
local CELESTE = Color3.fromHex("5CC8FF") -- agua y vidrio
local LILA = Color3.fromHex("9C8FD0") -- lila grisáceo: paredes y metal
local BLANCO = Color3.fromHex("FFFFFF") -- texto e interfaz claro

local TOON = {
	Contorno = CONTORNO,
	Pupila = PUPILA,
	CieloArriba = CIELO_ARRIBA,
	CieloAbajo = CIELO_ABAJO,
	Horizonte = HORIZONTE,
	Crema = CREMA,
	Rosa = ROSA,
	Amarillo = AMARILLO,
	Naranja = NARANJA,
	Rojo = ROJO,
	Menta = MENTA,
	Celeste = CELESTE,
	Lila = LILA,
	Blanco = BLANCO,
}

-- Un color por elemento, un punto más claros y saturados que antes para que lean sobre el violeta.
local ELEMENTOS = {
	Fuego = Color3.fromHex("FF6A2A"),
	Agua = Color3.fromHex("42C4FF"),
	Planta = Color3.fromHex("52E860"),
	Electrico = Color3.fromHex("FFE438"),
	Sombra = Color3.fromHex("A274FF"),
}

local Paleta = {
	Toon = TOON,

	Fondo = CIELO_ARRIBA, -- fondo de sellos e íconos redondos
	Noche = CIELO_ARRIBA, -- fondo de los renders de Blender (arte/scripts/comun.py)
	Metal = LILA, -- máquinas, estructuras y botones secundarios
	Acento = MENTA, -- ADN, slime, botón de fusionar
	Alerta = ROSA, -- novedades y alertas
	Dorado = AMARILLO, -- premios, raro, Premium
	Texto = BLANCO,
	Contorno = CONTORNO, -- contorno de las piezas, de la interfaz y sombra de texto

	-- Un color por elemento (criaturas, íconos, filtros y pistas).
	Elementos = ELEMENTOS,

	-- Borde de tarjetas y anillo bajo la criatura, según la generación (1, 2 y 3).
	Generaciones = {
		Color3.fromHex("FFFFFF"),
		Color3.fromHex("5CC8FF"),
		Color3.fromHex("B98CFF"),
	},
	Mutante = AMARILLO, -- amarillo sol con brillo

	-- Tonos de interfaz (ventanas, tarjetas y estados): violetas del cielo, con texto blanco.
	Superficie = CIELO_ARRIBA, -- fondo de las ventanas
	SuperficieElevada = Color3.fromHex("534FAA"), -- tarjetas y casilleros (cielo con 25 % de lila)
	SuperficieClara = Color3.fromHex("6C64B7"), -- siluetas y lo resaltado (cielo con 50 % de lila)
	Deshabilitado = Color3.fromHex("72669B"), -- botones que todavía no se pueden usar
	Error = ROJO, -- precios que no alcanzan, avisos de error, cerrar
	Exito = MENTA, -- avisos de que algo salió bien
	Silueta = Color3.fromHex("1A1230"), -- criaturas sin descubrir
	LuzVista = Color3.fromHex("E6DCF5"), -- luz ambiente de las vistas 3D de la interfaz

	-- Colores de los papelitos de las celebraciones: menta, rosa, amarillo y los elementos.
	Papelitos = {
		Color3.fromHex("5CF0A0"),
		Color3.fromHex("FF6FA8"),
		Color3.fromHex("FFC93A"),
		Color3.fromHex("FF6A2A"),
		Color3.fromHex("42C4FF"),
		Color3.fromHex("52E860"),
		Color3.fromHex("FFE438"),
		Color3.fromHex("A274FF"),
	},

	-- Catalizadores (shared/Catalizadores.luau): el color que le dan a la variante.
	Catalizadores = {
		Rayo = Color3.fromHex("FFE438"),
		Hielo = Color3.fromHex("C4F4FF"),
		Slime = MENTA,
		Lava = NARANJA,
		Sombra = Color3.fromHex("A274FF"),
	},
	Residuo = Color3.fromHex("7A6352"), -- se mezcla con los colores de los padres

	-- Color del cuerpo y de las manchas de cada especie base, en el orden de la rueda
	-- (shared/Especies.luau). Las fusiones mezclan estos colores pieza por pieza.
	-- Pendiente del pedido T1 (criaturas toon): revisarlos sobre el piso y el cielo nuevos.
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
		Blanco = BLANCO, -- ojos
		Negro = PUPILA, -- pupilas, narices y siluetas oscuras en el mundo
		Crema = CREMA, -- cara del hongo
		Naranja = NARANJA, -- picos, cuernos de brasa, patas de ave y chispas
		Llama = ROJO, -- llama de la cola
		Amarillo = AMARILLO, -- punta de la llama y centro de las flores
		Burbujas = Color3.fromHex("C4F0FF"),
		Flores = ROSA,
		Esporas = Color3.fromHex("FF9AD0"),
		Nieve = BLANCO,
		Luz = Color3.fromHex("FFE680"), -- luz propia de la especie que brilla
		Aura = Color3.fromHex("FFF3B0"), -- aura de la generación 3
	},

	-- Laboratorio (server/Laboratorios.luau): corrales abiertos y cerrados.
	Laboratorio = {
		PisoAbierto = CREMA,
		PisoCerrado = Color3.fromHex("786CA3"), -- lila con 30 % de contorno
		CupulaAbierta = Color3.fromHex("CFF6FF"),
		CupulaCerrada = Color3.fromHex("665A8C"), -- lila con 45 % de contorno
	},

	-- Luz del mundo (Toon.iluminar): ambiente lila, sol rosado y niebla del atardecer.
	-- Los colores del cielo están "horneados" en sus imágenes (arte/scripts/toon_base.py).
	Luz = {
		Ambiente = Color3.fromHex("ACA2C8"), -- adentro y a la sombra
		Exterior = Color3.fromHex("C4BADB"), -- afuera
		Sol = Color3.fromHex("FFF2F7"), -- tinte de lo que da al sol
		Niebla = HORIZONTE, -- color de la Atmosphere cerca del horizonte
		Lejos = CIELO_ABAJO, -- color de la Atmosphere lejos del sol
	},

	-- Versión oscura de un color (la franja de abajo de los botones).
	oscuro = function(color: Color3, cuanto: number?): Color3
		return color:Lerp(CONTORNO, cuanto or 0.4)
	end,

	-- Versión clara de un color (brillos de los íconos).
	claro = function(color: Color3, cuanto: number?): Color3
		return color:Lerp(BLANCO, cuanto or 0.45)
	end,
}

return Paleta
