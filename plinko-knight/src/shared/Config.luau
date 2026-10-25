--!strict
-- Números de balance de Plinko Knight (ideas/plinko-knight.md). Todo lo ajustable va acá.
-- No tiene requires ni tipos de Roblox (los colores van en hex) para que también lo puedan leer
-- las pruebas con Lune (plinko-knight/pruebas).

export type Monstruo = {
	Id: string,
	Nombre: string,
	Vida: number,
	Golpe: number, -- daño que te hace cuando contraataca
	Color: string, -- graybox: el rectángulo del cartel (hex)
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

-- El caballero: vida al empezar la mazmorra y cuánto se cura al ganar cada pelea.
Config.VidaCaballero = 50
Config.CuraEntrePeleas = 10

-- Las 6 peleas y el jefe, en orden (nombres de prueba hasta el arte final).
-- Etapa 5 (25/10): con mejoras, los números de la etapa 4 daban 98 % de mazmorras ganadas
-- eligiendo cartas al azar. Con estos (lune run plinko-knight/pruebas/mazmorra): al azar se gana
-- ~30 % y casi todos caen en las peleas 5 a 7; eligiendo siempre la misma, en la 5 o la 6.
Config.Monstruos = {
	{ Id = "rata", Nombre = "Rata de Cloaca", Vida = 40, Golpe = 4, Color = "#8A6E5A" },
	{ Id = "slime", Nombre = "Slime Verde", Vida = 60, Golpe = 6, Color = "#5FBF4A" }, -- era 60/5
	{ Id = "murcielago", Nombre = "Murciélago", Vida = 100, Golpe = 7, Color = "#7A5AA8" }, -- 85/6
	{ Id = "esqueleto", Nombre = "Esqueleto", Vida = 150, Golpe = 9, Color = "#E6E0CC" }, -- 115/7
	{ Id = "goblin", Nombre = "Goblin con Lanza", Vida = 210, Golpe = 10, Color = "#3E8C6E" }, -- 150/8
	{ Id = "golem", Nombre = "Gólem de Piedra", Vida = 280, Golpe = 12, Color = "#6E7A8A" }, -- 190/9
	{
		Id = "jefe",
		Nombre = "Rey de los Huesos",
		Vida = 380, -- etapa 4: 320/11 → 240/8 (sin mejoras no se ganaba); etapa 5: 380/12
		Golpe = 12,
		Color = "#C9A227",
		EsJefe = true,
	},
} :: { Monstruo }

-- Mejoras (1 de 3 entre peleas, etapa 5). "Repetida" = qué cambia cada vez que la elegís de
-- nuevo. Todo lo que cambia el tiro lo calcula shared/Simulacion (así el servidor lo repite).
Config.OrdenMejoras = { "Fuego", "Duplica", "Divide" } -- las que existen, en el orden de las cartas
Config.MejorasPorPantalla = 3 -- cartas que se ofrecen al ganar una pelea
Config.Mejoras = {
	Fuego = {
		Nombre = "Bola de fuego",
		-- +1 por clavija desde el nivel 1, y no sube al repetirla: con el ×2 de las rojas se
		-- disparaba (eligiendo siempre fuego se ganaba el 74 %; lune, 25/10).
		DanioExtraPorClavija = 1,
		Quemadura = 3, -- daño por turno al monstruo (nivel 1)
		QuemaduraPorNivel = 3, -- repetida: la quemadura sube 3 (nivel 2 = 6, nivel 3 = 9)
		TurnosQuemadura = 2, -- cada tiro con fuego lo vuelve a prender por estos turnos
	},
	Duplica = {
		Nombre = "Clavija que duplica",
		ClavijasRojas = 2, -- nivel 1; repetida: una clavija roja más
		ClavijasRojasPorNivel = 1,
		Factor = 2, -- el daño del tiro hasta ese momento se multiplica por esto
		-- Filas donde pueden caer (1 = la de arriba): ni la primera (sería ×2 de casi nada) ni la
		-- última (casi no se llega a ver el efecto).
		FilaMinima = 3,
		FilaMaxima = 7,
	},
	Divide = {
		Nombre = "Bola que se divide",
		ToquesParaDividir = { 5, 4, 3 }, -- 1.ª vez, 2.ª vez, 3.ª vez o más
		Partes = 2,
		-- Grados entre las dos bolas al partirse: AnguloDivision ± AnguloAzar (con la semilla).
		AnguloDivision = 24,
		AnguloAzar = 8,
	},
}

-- Topes del tiro, para que las tres mejoras juntas no exploten (Simulacion).
Config.TopeBolas = 4
Config.TopeDanioTiro = 999

-- Bolas que se desbloquean y se guardan.
Config.Bolas = {
	{ Id = "hierro", Nombre = "Hierro", Desbloqueo = "inicio" },
	{ Id = "fuego", Nombre = "Fuego", Desbloqueo = "piso4" },
	{ Id = "partida", Nombre = "Partida", Desbloqueo = "jefe" },
}

-- Revisión del servidor (etapa 3, server/Tiros.luau).
Config.Servidor = {
	MargenDanio = 0.05, -- si el daño que vio el cliente difiere más que esto (5 %), se avisa
	TopeDanioPorTiro = 2000, -- por si algo sale mal
	TiempoMinimoEntreTiros = 1, -- segundos entre dos tiros del mismo jugador
	TiempoMinimoVolver = 0.5, -- segundos entre dos "Volver a bajar" del mismo jugador
}

-- Animación del turno (cliente, etapa 4).
Config.Turno = {
	VueloTotal = 0.3, -- segundos que tarda la bolita de luz del TOTAL al cartel
	Sacudida = 0.35, -- segundos que se sacude el monstruo al recibir el golpe
	BajadaBarra = 0.4, -- segundos que tarda en bajar una barra de vida
	Agrandar = 1.2, -- tamaño del cartel cuando contraataca (1 = normal)
	DuracionAtaque = 0.35, -- segundos de ida y vuelta del contraataque
	TemblorPantalla = 0.35, -- studs: cuánto se mueve la cámara (apenas)
	DuracionTemblor = 0.25,
	CartelPiso = 1.2, -- segundos que se ve "¡Piso N!"
}

-- Números que saltan en pantalla (cliente).
Config.Numeros = {
	Duracion = 0.5, -- segundos que tarda un "+2" en subir y desvanecerse
	Subida = 2.5, -- studs que sube
	PopTotal = 1.25, -- tamaño del TOTAL en el "pop" de cada toque (1 = normal)
	DuracionPop = 0.12,
	DuracionDuplica = 1.2, -- segundos que se ve el "×2" grande del TOTAL (con 0,7 casi no se leía)
}

-- Colores del graybox (hasta la etapa 8).
Config.Colores = {
	Clavija = "#C8C8C8",
	ClavijaDuplica = "#D23232",
	Bola = "#FFFFFF",
	BolaFuego = "#FF4A00", -- la bola con la mejora de fuego (con Neon brilla: más oscuro se ve naranja)
	Quemadura = "#FF8A1F", -- el número de la quemadura sobre el monstruo
	Duplica = "#FF3B3B", -- el "×2" grande del TOTAL
	Carta = "#4A4A4A", -- graybox de las cartas de mejora
	Gris = "#808080",
	Fondo = "#3A3A3A",
	Brillo = "#FFF6B0", -- clavija tocada
	Numero = "#FFF200", -- amarillo de prueba de los "+2" y el TOTAL
	Caballero = "#5A78B4",
	Golpe = "#E2323F", -- el caballero se pone de este color cuando lo golpean
	VidaMonstruo = "#E2323F",
	VidaCaballero = "#4CC46A",
	FondoBarra = "#202020",
}

return Config
