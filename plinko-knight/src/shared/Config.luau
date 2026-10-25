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
Config.Tablero = {
	Columnas = 7,
	Filas = 8,
}

-- Física de la bola (shared/Simulacion.luau, etapa 2). Arranque: se ajustan probando con Lune.
Config.Simulacion = {
	Paso = 1 / 120, -- segundos por paso fijo
	Restitucion = 0.65, -- cuánto rebota (1 = sin perder nada)
	TiempoMaximo = 15, -- segundos: tope por tiro
	TiempoTraba = 2, -- segundos casi sin bajar antes de un empujón
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
}

return Config
