--!strict
-- Números de balance de Plinko Knight (ideas/plinko-knight.md). Todo lo ajustable va acá.
-- No tiene requires ni tipos de Roblox (los colores van en hex) para que también lo puedan leer
-- las pruebas con Lune (plinko-knight/pruebas).

export type Monstruo = {
	Id: string,
	Nombre: string,
	Vida: number,
	Golpe: number, -- daño que te hace cuando contraataca
	EsJefe: boolean?,
}

local Config = {}

-- Versión de los datos guardados: se sube (con su migración) cada vez que cambia lo que se guarda.
Config.VERSION = 1

-- Tablero: filas alternadas (una de Columnas clavijas, la siguiente de Columnas - 1).
-- Medidas en studs, en el plano del tablero: x hacia la derecha, y hacia arriba, el lanzador en
-- (0, 0) y las clavijas hacia abajo (y negativo). shared/Tablero.luau arma las clavijas.
Config.Tablero = {
	Columnas = 7,
	Filas = 8,
	SeparacionX = 3.25, -- entre clavijas de una misma fila (con 4 tocaba solo 6,6 por tiro)
	SeparacionY = 3.5, -- entre filas
	PrimeraFila = -4, -- y de la fila de arriba
	MargenAbajo = 3.5, -- de la última fila al borde de abajo (donde termina el tiro)
	RadioClavija = 0.7,
	HuecoPared = 1.3, -- espacio libre entre la clavija de la punta y la pared (más que la bola)
}

-- La bola de hierro (la de siempre).
Config.Bola = {
	Radio = 0.6,
	Velocidad = 18, -- studs/s al salir del lanzador
}

-- Puntería: abanico hacia abajo, en grados desde la vertical (0 = derecho para abajo).
Config.Punteria = {
	AnguloMaximo = 60,
	DuracionLinea = 0.22, -- segundos de vuelo que muestra la línea de puntos (solo el primer tramo)
	PuntosLinea = 8,
}

-- Física de la bola (shared/Simulacion.luau). Ajustada el 25/10 con
-- lune run plinko-knight/pruebas/simulacion: con estas medidas un tiro toca 14 clavijas de
-- promedio (de 5 a 21) y dura unos 5 s. Más radio de clavija o de bola = más toques.
Config.Simulacion = {
	Paso = 1 / 120, -- segundos por paso fijo
	Gravedad = 60, -- studs/s²
	Restitucion = 0.65, -- cuánto rebota (1 = sin perder nada)
	Friccion = 0.04, -- parte de la velocidad de costado que se pierde en cada rebote
	Desvio = 4, -- grados: desvío al azar (con la semilla) en cada rebote contra una clavija
	VelocidadMaxima = 45, -- studs/s
	TiempoMaximo = 15, -- segundos: tope por tiro
	TiempoTraba = 2, -- segundos casi sin bajar antes de un empujón
	BajadaMinima = 1, -- studs que tiene que bajar en ese tiempo para no contar como trabada
	Empujon = 6, -- studs/s hacia abajo del empujón (más un poco de costado al azar)
	BrilloClavija = 0.15, -- segundos que brilla una clavija tocada (cliente)
}

Config.Danio = {
	PorClavija = 2, -- cada clavija cuenta una sola vez por tiro
}

Config.Caballero = {
	Vida = 50,
	CuraEntrePeleas = 10,
}

-- Las 6 peleas y el jefe, en orden.
Config.Monstruos = {
	{ Id = "rata", Nombre = "Rata de cloaca", Vida = 40, Golpe = 4 },
	{ Id = "slime", Nombre = "Slime", Vida = 60, Golpe = 5 },
	{ Id = "murcielago", Nombre = "Murciélago", Vida = 85, Golpe = 6 },
	{ Id = "esqueleto", Nombre = "Esqueleto", Vida = 115, Golpe = 7 },
	{ Id = "goblin", Nombre = "Goblin", Vida = 150, Golpe = 8 },
	{ Id = "golem", Nombre = "Gólem", Vida = 190, Golpe = 9 },
	{ Id = "jefe", Nombre = "Rey de los Huesos", Vida = 320, Golpe = 11, EsJefe = true },
} :: { Monstruo }

-- Mejoras (1 de 3 entre peleas). "Repetida" = qué cambia cada vez que la elegís de nuevo.
Config.Mejoras = {
	Fuego = {
		DanioExtraPorClavija = 1, -- repetida: +1 más
		Quemadura = 3, -- daño por turno al monstruo
		TurnosQuemadura = 2,
	},
	Duplica = {
		ClavijasRojas = 2, -- repetida: una clavija roja más
		Factor = 2, -- el daño del tiro hasta ese momento se multiplica por esto
	},
	Divide = {
		ToquesParaDividir = { 5, 4, 3 }, -- 1.ª vez, 2.ª vez, 3.ª vez o más
		Partes = 2,
	},
}

-- Bolas que se desbloquean y se guardan.
Config.Bolas = {
	{ Id = "hierro", Nombre = "Hierro", Desbloqueo = "inicio" },
	{ Id = "fuego", Nombre = "Fuego", Desbloqueo = "piso4" },
	{ Id = "partida", Nombre = "Partida", Desbloqueo = "jefe" },
}

-- Revisión del servidor (etapa 3).
Config.Servidor = {
	MargenDanio = 2, -- diferencia aceptada entre el daño del cliente y el del servidor
	TopeDanioPorTiro = 2000,
	TirosPorSegundo = 2, -- límite de frecuencia por jugador
}

-- Colores del graybox (hasta la etapa 8).
Config.Colores = {
	Clavija = "#C8C8C8",
	ClavijaDuplica = "#D23232",
	Bola = "#FFFFFF",
	Gris = "#808080",
	Fondo = "#3A3A3A",
	Brillo = "#FFF6B0", -- clavija tocada
}

return Config
