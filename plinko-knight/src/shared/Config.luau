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
	Zona: number, -- 1, 2 o 3
	EsJefe: boolean?,
}

local Config = {}

-- Etapa 11: el nombre que se ve en el juego (carteles de la sala, la máquina y la pantalla de
-- inicio). "Plinko" es marca registrada y además es un juego de casinos online: hay que cambiarlo
-- antes de publicar. Cambiándolo acá se cambia en todos lados.
Config.NombreJuego = "Plinko Knight"

-- Versión de los datos guardados: se sube (con su migración) cada vez que cambia lo que se guarda.
Config.VERSION = 2 -- 2: se suman los Ajustes (etapa 7)

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

-- Golpe = Fuerza × Multi (paso 5a, estilo roguelike). Cada tiro arranca con Fuerza 0 y Multi 1;
-- cada clavija suma a una de las dos cajas según su tipo (Config.Clavijas). Cada clavija cuenta
-- una vez por bola y por tiro.
Config.Danio = {
	FuerzaInicial = 0,
	MultiInicial = 1,
}

-- Tu vida (la del jugador): al empezar la mazmorra y cuánto se cura al ganar cada pelea.
Config.VidaCaballero = 50
Config.CuraEntrePeleas = 10

-- Paso 5d: 3 zonas de 3 peleas (2 monstruos y un jefe con maña). La vida crece mucho de zona en
-- zona porque las combinaciones crecen mucho (como en Balatro). Nombres de prueba hasta el arte.
-- Ajustados con lune run plinko-knight/pruebas/mazmorra (ver la ficha, paso 5d): la ficha decía
-- 60/110/200 · 450/800/1500 · 3500/6000/12000 y así nadie pasaba la zona 2.
Config.Zonas = { "Cloacas", "Catacumbas", "Trono de Hueso" }
Config.Monstruos = {
	{ Id = "rata", Nombre = "Rata de Cloaca", Zona = 1, Vida = 50, Golpe = 4, Color = "#8A6E5A" },
	{ Id = "slime", Nombre = "Slime Verde", Zona = 1, Vida = 90, Golpe = 5, Color = "#5FBF4A" },
	{
		Id = "reyRata",
		Nombre = "Rey Rata",
		Zona = 1,
		Vida = 140,
		Golpe = 7,
		Color = "#6B4A3A",
		EsJefe = true,
	},
	{
		Id = "murcielago",
		Nombre = "Murciélago",
		Zona = 2,
		Vida = 250,
		Golpe = 7,
		Color = "#7A5AA8",
	},
	{ Id = "esqueleto", Nombre = "Esqueleto", Zona = 2, Vida = 420, Golpe = 9, Color = "#E6E0CC" },
	{
		Id = "goblin",
		Nombre = "Goblin con Lanza",
		Zona = 2,
		Vida = 750,
		Golpe = 11,
		Color = "#3E8C6E",
		EsJefe = true,
	},
	{
		Id = "golem",
		Nombre = "Gólem de Piedra",
		Zona = 3,
		Vida = 1500,
		Golpe = 11,
		Color = "#6E7A8A",
	},
	{
		Id = "hueco",
		Nombre = "Caballero Hueco",
		Zona = 3,
		Vida = 2600,
		Golpe = 13,
		Color = "#4A4F66",
	},
	{
		Id = "jefe",
		Nombre = "Rey de los Huesos",
		Zona = 3,
		Vida = 4500,
		Golpe = 14,
		Color = "#C9A227",
		EsJefe = true,
	},
} :: { Monstruo }

-- Etapa 11: la primera partida de un jugador nuevo arranca con este monstruo (piso 0). Tiene poca
-- vida, no pega y no cuenta como piso: al matarlo se pasa directo a la pelea 1, sin tienda ni oro.
Config.Practica = {
	Id = "practica",
	Nombre = "Slime de Práctica",
	Zona = 1,
	Vida = 12,
	Golpe = 0,
	Color = "#5FBF4A",
} :: Monstruo

-- Etapa 11: el primer minuto. Un jugador nuevo (0 partidas jugadas) se sienta solo en la máquina
-- y una mano le muestra cómo tirar hasta que tira la primera bola.
Config.Tutorial = {
	EsperaSentarse = 0.5, -- segundos desde que llega el progreso hasta sentarlo
	Recorrido = 70, -- píxeles que la mano va y viene arrastrando
	Vuelta = 1.6, -- segundos de una ida y vuelta de la mano
	Texto = "ARRASTRÁ Y SOLTÁ",
}

-- Etapa 11: analítica (AnalyticsService). El embudo de los primeros pasos va en este orden; cada
-- paso se manda una vez por jugador (Roblox ignora los repetidos).
Config.Analitica = {
	Embudo = {
		"Entró",
		"Primer tiro",
		"Ganó la pelea 1",
		"Eligió una mejora",
		"Llegó al piso 3",
		"Llegó al piso 5",
		"Llegó al jefe final",
		"Volvió a bajar",
	},
	Camino = "Mazmorra", -- nombre del recorrido de pisos (empezó, pasó o cayó en cada piso)
	Moneda = "Oro",
}

-- Clavijas especiales (paso 5a). El tablero es de la partida: empieza todo gris y las cartas
-- (después, la tienda) convierten clavijas. "Nivel" lo suben los pergaminos (paso 5b); por
-- ahora todas arrancan en 1. Cada valor: el de nivel 1 + PorNivel × (nivel - 1).
Config.OrdenClavijas = { "roja", "azul", "dorada", "verde", "violeta" } -- las que salen en cartas
Config.Clavijas = {
	-- Etapa 9 (Cripta azul): la normal es dorada #F5C542 (Neon); la "Dorada" especial pasa a
	-- naranja, para no confundirlas.
	gris = { Nombre = "Gris", Fuerza = 2, FuerzaPorNivel = 1, Color = "#F5C542" },
	-- Roja: +2 Multi (era +3: eligiéndola siempre se ganaba el 60 %, el resto 5 a 18 %; lune, 25/10).
	roja = { Nombre = "Roja", Plural = "rojas", Multi = 2, MultiPorNivel = 2, Color = "#E2323F" },
	azul = {
		Nombre = "Azul",
		Plural = "azules",
		PorMulti = 2, -- multiplica el Multi (con ×1,5 y la rotura casi no servía: 2 % de mazmorras ganadas)
		PorMultiPorNivel = 0.5,
		Rotura = 0.25, -- chance de romperse al tocarla (con la semilla): queda hueco
		Color = "#3C8CFF",
	},
	dorada = {
		Nombre = "Dorada",
		Plural = "doradas",
		Fuerza = 6,
		Oro = 1,
		OroPorNivel = 1,
		Color = "#FF5A00", -- naranja que brilla (la normal ya es dorada)
	},
	verde = {
		Nombre = "Verde",
		Plural = "verdes",
		Fuerza = 10,
		FuerzaPorNivel = 5,
		Impulso = 16, -- studs/s que le suma a la bola hacia afuera de la clavija (resorte)
		Color = "#3CC864",
	},
	violeta = {
		Nombre = "Violeta",
		Plural = "violetas",
		Fuerza = 2, -- como una gris, para que nunca sea peor elegirla (sola sumaba menos)
		Eco = 2, -- la próxima clavija que toque esa bola cuenta estas veces
		EcoPorNivel = 1,
		Color = "#A050E6",
	},
	hueco = { Nombre = "Hueco", Color = "#2F3B57" }, -- azul rota: la bola pasa derecho
}

-- Oro (paso 5b): se gana al matar un monstruo y se gasta en la tienda. Es del juego, se pierde al
-- terminar la partida y NUNCA se vende por Robux.
Config.Oro = {
	PorMonstruo = 3,
	PorJefe = 5,
	BonusUnTiro = 2, -- si lo mataste en 1 tiro
	BonusDosTiros = 1, -- si fue en 2
	InteresCada = 5, -- +1 de interés por cada 5 que tengas al entrar a la tienda...
	InteresTope = 5, -- ...hasta 5 (la reliquia Bolsa de Cuero lo sube a Config.Reliquias.bolsa)
	Inicial = 0,
}

-- Tienda entre peleas (paso 5b). Lo que sale lo elige el servidor con la semilla de la partida.
-- Las reliquias se suman en el paso 5c.
Config.Tienda = {
	Reliquias = 2, -- cuántas reliquias ofrece (paso 5c)
	MejorasDeClavija = 2, -- cuántas mejoras de clavija ofrece
	Pergaminos = 1, -- cuántos pergaminos ofrece
	-- Convertir 1 clavija que elijas en ese tipo. A 3 (con 3 de oro por monstruo) comprando al
	-- azar se ganaba el 3 %; a 2, el 21 % (lune, 25/10).
	PrecioClavija = 2,
	PrecioPergamino = 3,
	Renovar = 2, -- y cada vez que renovás en la misma tienda cuesta 1 más
	RenovarSube = 1,
}

-- Pergaminos (paso 5b): se compran en la tienda y se usan cuando querés (entre tiros o en la
-- tienda). Hay 2 lugares. Peso = qué tan seguido sale en la tienda (la chance se ve en
-- "¿Qué puede salir?"). Los "nivel:" suben un tipo de clavija y los "forja:" convierten 2.
-- Reliquias (paso 5c): hasta LugaresReliquia a la vez. Las que actúan "al final del tiro" se
-- aplican de izquierda a derecha (primero conviene lo que suma Multi, después lo que lo
-- multiplica); las demás cambian cada toque o la partida. Se compran en la tienda (precio según la
-- rareza) y se venden por la mitad. Las "crece" guardan un contador. Desbloqueo: "inicio" = está
-- desde el principio; el resto se desbloquea con un logro cuando llegue el guardado (etapa 6).
-- Por ahora todas pueden salir en la tienda.
Config.LugaresReliquia = 5

-- Cofre del jefe (paso 5d): al ganarle a un jefe (menos el último) se abre un cofre con 3
-- reliquias que no tenés; te llevás 1 gratis (o ninguna). Se elige en la tienda que viene después.
Config.Cofre = { Reliquias = 3 }

-- Mañas de jefe (paso 5d): el servidor sortea una por jefe al empezar la partida (con la semilla
-- de la partida) y se ve antes de pelear (en la tienda de antes y en un cartel en la pelea).
Config.OrdenManias = {
	"sangreFria",
	"cristalMaldito",
	"paredesVivas",
	"avaricia",
	"coraza",
	"silencio",
	"viento",
	"rabia",
}
Config.Manias = {
	sangreFria = { Nombre = "Sangre fría", Texto = "Las clavijas rojas no suman" },
	cristalMaldito = { Nombre = "Cristal maldito", Texto = "Las azules se rompen siempre" },
	paredesVivas = { Nombre = "Paredes vivas", Texto = "Las clavijas de los costados no cuentan" },
	avaricia = { Nombre = "Avaricia", Texto = "Te saca %d de oro en cada tiro", Oro = 1 },
	coraza = {
		Nombre = "Coraza",
		Texto = "Solo le hacen daño los golpes de %s o más",
		Minimo = { 40, 250, 1200 },
	},
	silencio = { Nombre = "Silencio", Texto = "Tu reliquia de la izquierda no funciona" },
	viento = {
		Nombre = "Viento",
		Texto = "La bola sale más rápida y se desvía más",
		Velocidad = 1.3,
		Desvio = 3, -- veces el desvío normal en cada rebote
	},
	rabia = { Nombre = "Rabia", Texto = "Si no lo matás, te pega el doble", Factor = 2 },
}
Config.Rarezas = {
	comun = { Nombre = "Común", Peso = 70, Precio = 4, Color = "#B8B8B8" },
	rara = { Nombre = "Rara", Peso = 25, Precio = 7, Color = "#4FA8FF" },
	legendaria = { Nombre = "Legendaria", Peso = 5, Precio = 12, Color = "#F5C542" },
}
Config.OrdenRarezas = { "comun", "rara", "legendaria" }
Config.OrdenReliquias = {
	"brasa",
	"rubi",
	"martillo",
	"cadena",
	"gemela",
	"enjambre",
	"hoja",
	"bolsa",
	"avaro",
	"toqueOro",
	"trofeo",
	"callo",
	"racha",
	"yesca",
	"vidrio",
	"aliento",
	"paciencia",
	"corona",
	"ecoInfinito",
	"midas",
}
Config.Reliquias = {
	brasa = { Nombre = "Brasa", Rareza = "comun", Desbloqueo = "inicio", MultiPorRoja = 2 }, -- era 1 (paso 5d),
	rubi = { Nombre = "Corazón de Rubí", Rareza = "rara", Desbloqueo = "inicio", Factor = 2 },
	martillo = {
		Nombre = "Martillo Pesado",
		Rareza = "comun",
		Desbloqueo = "inicio",
		Fuerza = 30,
		Clavijas = 15,
	},
	cadena = { Nombre = "Cadena", Rareza = "comun", Desbloqueo = "inicio", Multi = 2, Cada = 5 },
	gemela = { Nombre = "Gemela", Rareza = "comun", Desbloqueo = "inicio", Toque = 6 },
	enjambre = {
		Nombre = "Enjambre",
		Rareza = "rara",
		Desbloqueo = "logro",
		Logro = "Tené 4 bolas en juego en un tiro",
		PorBola = 1.5,
	},
	hoja = { Nombre = "Hoja Afilada", Rareza = "comun", Desbloqueo = "inicio", Factor = 2 },
	bolsa = { Nombre = "Bolsa de Cuero", Rareza = "comun", Desbloqueo = "inicio", InteresTope = 10 },
	avaro = {
		Nombre = "Avaro",
		Rareza = "rara",
		Desbloqueo = "logro",
		Logro = "Terminá una zona con 20 de oro o más",
		Multi = 1,
		Cada = 2,
	},
	toqueOro = { Nombre = "Toque de Oro", Rareza = "comun", Desbloqueo = "inicio", PorMulti = 1.5 },
	trofeo = { Nombre = "Trofeo", Rareza = "rara", Desbloqueo = "inicio", Multi = 1 },
	callo = { Nombre = "Callo", Rareza = "comun", Desbloqueo = "inicio", Fuerza = 3 },
	racha = {
		Nombre = "Racha",
		Rareza = "rara",
		Desbloqueo = "logro",
		Logro = "Ganá 3 peleas seguidas sin que te peguen",
		PorPelea = 0.25,
	},
	yesca = {
		Nombre = "Yesca",
		Rareza = "rara",
		Desbloqueo = "logro",
		Logro = "Ganale a un jefe con la bola de fuego",
	},
	-- Vidrio: la azul ya es ×2 (paso 5a), así que con Vidrio pasa a ×3 y se rompe 1 de cada 2.
	vidrio = {
		Nombre = "Vidrio Frágil",
		Rareza = "rara",
		Desbloqueo = "inicio",
		PorMulti = 3,
		Rotura = 0.5,
	},
	aliento = {
		Nombre = "Último Aliento",
		Rareza = "rara",
		Desbloqueo = "logro",
		Logro = "Ganá una pelea con menos de 10 de vida",
		Vida = 15,
		Factor = 3,
	},
	paciencia = { Nombre = "Paciencia", Rareza = "rara", Desbloqueo = "inicio", Factor = 4 },
	corona = {
		Nombre = "Corona del Rey Caído",
		Rareza = "legendaria",
		Desbloqueo = "logro",
		Logro = "Hacé un golpe de 10.000 o más",
		Factor = 2,
	},
	ecoInfinito = {
		Nombre = "Eco Infinito",
		Rareza = "legendaria",
		Desbloqueo = "logro",
		Logro = "Hacé que una clavija cuente 3 veces",
		Veces = 4,
	},
	midas = {
		Nombre = "Mano de Midas",
		Rareza = "legendaria",
		Desbloqueo = "logro",
		Logro = "Juntá 40 de oro en una partida",
		Oro = 1,
	},
}

Config.LugaresPergamino = 2
Config.Pergaminos = {
	nivel = { Nombre = "Pergamino", Peso = 1 }, -- uno por tipo de clavija (6 en total)
	forja = { Nombre = "Forja", Peso = 1, Clavijas = 2 }, -- uno por tipo especial (5 en total)
	martillo = { Nombre = "Martillo", Peso = 2 }, -- borra 1 clavija (queda hueco)
	vendaje = { Nombre = "Vendaje", Peso = 2, Cura = 15 },
	furia = { Nombre = "Furia", Peso = 2, PorMulti = 2 }, -- el próximo tiro: ×2 Multi al final
}

-- Bolas para elegir al empezar (la pantalla de elegir llega en la etapa 7; en Studio, tecla Z).
-- La de fuego y la partida son las mejoras de la etapa 5 convertidas.
Config.OrdenBolas = { "hierro", "fuego", "partida" }
Config.Bolas = {
	hierro = { Nombre = "Hierro", Desbloqueo = "inicio", Descripcion = "La de siempre" },
	fuego = {
		Nombre = "Fuego",
		Descripcion = "+1 Fuerza por clavija y el monstruo se quema",
		Desbloqueo = "zona2",
		Logro = "Llegá a la zona 2",
		FuerzaExtra = 1, -- por cada clavija tocada
		Quemadura = 3, -- daño por turno al monstruo
		TurnosQuemadura = 2, -- cada tiro lo vuelve a prender por estos turnos
	},
	partida = {
		Nombre = "Partida",
		Descripcion = "Se parte en 2 en el toque 5",
		Desbloqueo = "jefe",
		Logro = "Ganale a un jefe",
		ToqueParaDividir = 5,
		Partes = 2,
		-- Grados entre las dos bolas al partirse: AnguloDivision ± AnguloAzar (con la semilla).
		AnguloDivision = 24,
		AnguloAzar = 8,
	},
}

-- Topes del tiro, para que las combinaciones no exploten (Simulacion).
Config.TopeBolas = 4
Config.TopeDanioTiro = 10000000
Config.TopeMulti = 1000000

-- Logros (etapa 6): los números de lo que desbloquea cada bola y cada reliquia (ver Desbloqueo y
-- Logro en Config.Bolas y Config.Reliquias). Los revisa el servidor (shared/Progreso).
Config.Logros = {
	ZonaFuego = 2, -- llegar a esta zona desbloquea la bola de fuego
	EnjambreBolas = 4,
	AvaroOro = 20,
	RachaPeleas = 3,
	AlientoVida = 10,
	CoronaGolpe = 10000,
	EcoVeces = 3,
	MidasOro = 40,
}

-- Guardado (etapa 6, server/Guardado): nombre del DataStore de ProfileStore. Cambiarlo borra
-- todo lo guardado (es otro almacén), así que solo se cambia a propósito.
Config.Guardado = {
	Almacen = "PlinkoKnight_Jugadores_v1",
}

-- Revisión del servidor (etapa 3, server/Tiros.luau).
Config.Servidor = {
	MargenDanio = 0.05, -- si el daño que vio el cliente difiere más que esto (5 %), se avisa
	TopeDanioPorTiro = 10000000, -- por si algo sale mal (= Config.TopeDanioTiro)
	TiempoMinimoEntreTiros = 1, -- segundos entre dos tiros del mismo jugador
	TiempoMinimoVolver = 0.5, -- segundos entre dos "Volver a bajar" del mismo jugador
	TiempoMinimoAccion = 0.15, -- segundos entre dos compras o pergaminos del mismo jugador
	TiempoMinimoAjustes = 0.3, -- segundos entre dos cambios de Ajustes del mismo jugador
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
	DuracionPopMulti = 0.2, -- el MULTI se agranda un poco más cuando lo multiplica una azul
}

-- Colores del mundo (etapa 9, guía de estilo "Cripta azul" de la ficha). Las pantallas usan
-- client/Estilo.luau.
Config.Colores = {
	Bola = "#FFFFFF",
	BolaFuego = "#FF4A00", -- la bola con la mejora de fuego (con Neon brilla: más oscuro se ve naranja)
	Quemadura = "#FF8A1F", -- el número de la quemadura sobre el monstruo
	Fuerza = "#3C8CFF", -- caja de FUERZA del panel
	Multi = "#E2323F", -- caja de MULTI del panel
	Oro = "#F5C542",
	Carta = "#2F3B57",
	Gris = "#2F3B57", -- piedra: paredes, techo, piso, lanzador
	Fondo = "#151B2E", -- detrás de las clavijas
	Brillo = "#FFFBE0", -- clavija tocada
	Numero = "#E8FF3A", -- amarillo flúor de los "+2" y el golpe
	BordeNumero = "#151B2E",
	Caballero = "#5A78B4",
	Golpe = "#E2323F", -- tu avatar se pone de este color cuando te golpean
	VidaMonstruo = "#E2323F",
	VidaCaballero = "#4CC46A",
	FondoBarra = "#151B2E",
	Magia = "#4FE3F0", -- velas, cristales y niebla
}

-- Mundo de la etapa 9: materiales y luz.
Config.Mundo = {
	MaterialClavija = "Neon", -- "Neon" (brilla) o "Metal": con la luz cian el metal dorado se ve verde
	BrilloVela = 0.7, -- PointLight de las 2 velas cian
	AlcanceVela = 22,
	Niebla = 0.1, -- densidad de la Atmosphere (más alto tapa todo: la cámara está a 170 studs)
}

-- Imágenes (etapa 9, ForgeGUI, estilo "Plinko Knight - Cripta azul"), subidas a la cuenta de Juani.
Config.Assets = {
	-- Etapa 10b: HUD pixel de ForgeGUI (estilo "Plinko Knight - Pixel mazmorra"), limpiado con
	-- modelos/scripts/limpiar_hud.py (íconos sin fondo, marcos con el centro hueco, 256 px).
	Hud = {
		Panel = "rbxassetid://138945775857831",
		Casillero = "rbxassetid://100244443496769",
		Corazon = "rbxassetid://129853496528485",
		Moneda = "rbxassetid://97289009429732",
		Engranaje = "rbxassetid://91125595300717",
		Puerta = "rbxassetid://89100178839447",
		Espada = "rbxassetid://88779764970340",
		Llama = "rbxassetid://94788486250427",
		CortePanel = 30, -- px del borde de los marcos (9-slice, en la imagen de 256)
	},
	Fondo = "rbxassetid://87670022073361",
	Monstruos = {
		rata = "rbxassetid://80675382037335",
		slime = "rbxassetid://109145942201870",
		practica = "rbxassetid://109145942201870", -- etapa 11: el mismo dibujo que el slime
		reyRata = "rbxassetid://116157565396353",
		murcielago = "rbxassetid://87724255448664",
		esqueleto = "rbxassetid://77030035121515",
		goblin = "rbxassetid://71269429801541",
		golem = "rbxassetid://110798881890684",
		hueco = "rbxassetid://102128709585550",
		jefe = "rbxassetid://99368063328605",
	},
	Bolas = {
		hierro = "rbxassetid://110340102452154",
		fuego = "rbxassetid://128791166541987",
		partida = "rbxassetid://121566479434441",
	},
	Reliquias = {
		brasa = "rbxassetid://75069185725559",
		rubi = "rbxassetid://112989603036364",
		martillo = "rbxassetid://102599983685498",
		cadena = "rbxassetid://94255213419577",
		gemela = "rbxassetid://90260039639804",
		enjambre = "rbxassetid://116223729669319",
		hoja = "rbxassetid://136726061890392",
		bolsa = "rbxassetid://101397062754426",
		avaro = "rbxassetid://72011929348355",
		toqueOro = "rbxassetid://80871627468378",
		trofeo = "rbxassetid://103833117883642",
		callo = "rbxassetid://75852312493601",
		racha = "rbxassetid://78802874503070",
		yesca = "rbxassetid://75658194741614",
		vidrio = "rbxassetid://78167273329363",
		aliento = "rbxassetid://126368591832705",
		paciencia = "rbxassetid://124319147882952",
		corona = "rbxassetid://127230860035006",
		ecoInfinito = "rbxassetid://121321327583276",
		midas = "rbxassetid://125474119435854",
	},
}

-- SONIDO: IDs de los sonidos (ForgeGUI, subidos a la cuenta de Juani). Cambialos por los tuyos acá.
Config.Sonidos = {
	Toque = { Id = "rbxassetid://121804059050039", Volumen = 0.35 }, -- cada clavija; el tono sube
	Tirar = { Id = "rbxassetid://87835338037561", Volumen = 0.5 },
	Golpe = { Id = "rbxassetid://110365833201585", Volumen = 0.7 },
	Ataque = { Id = "rbxassetid://138402372413303", Volumen = 0.6 },
	Multi = { Id = "rbxassetid://110380641890734", Volumen = 0.5 }, -- azul (× Multi)
	Oro = { Id = "rbxassetid://122502806374421", Volumen = 0.5 },
	Rotura = { Id = "rbxassetid://112466097779824", Volumen = 0.5 },
	Boton = { Id = "rbxassetid://101783326064996", Volumen = 0.4 },
	Comprar = { Id = "rbxassetid://100338726048736", Volumen = 0.5 },
	GanarPelea = { Id = "rbxassetid://105504200915241", Volumen = 0.5 },
	Perder = { Id = "rbxassetid://100185737362376", Volumen = 0.5 },
	Victoria = { Id = "rbxassetid://95661785992011", Volumen = 0.6 },
	Desbloqueo = { Id = "rbxassetid://113597899831000", Volumen = 0.5 },
	MusicaPelea = { Id = "rbxassetid://107838077520668", Volumen = 0.25 },
	MusicaJefe = { Id = "rbxassetid://85707754733386", Volumen = 0.3 },
	Whoosh = { Id = "rbxassetid://80528866577946", Volumen = 0.5 }, -- cartas del cofre (etapa 10)
	Umbral = { Id = "rbxassetid://74888225212588", Volumen = 0.6 }, -- el golpe pasa 50, 100 o 200
	Jefe = { Id = "rbxassetid://109953782069845", Volumen = 0.7 }, -- entrada del jefe
	Muerte = { Id = "rbxassetid://71720678959465", Volumen = 0.6 }, -- el cartel del monstruo se rompe
	TonoToque = { 1, 1.8 }, -- PlaybackSpeed del primer toque y tope (sube con cada toque del tiro)
}

-- Etapa 10: sensación (cliente). Todo lo que se mueve, brilla o tiembla, para ajustarlo acá.
-- Con "Efectos reducidos" no hay temblores ni hit-stop y salen la mitad de las chispas.
Config.Feel = {
	Aplastar = 0.12, -- segundos que tarda una clavija tocada en aplastarse y volver
	AplastarCuanto = 0.7, -- tamaño al aplastarse (1 = normal)
	Chispas = 4, -- chispas doradas por clavija tocada
	ChispasDuracion = 0.35,
	ChispasDistancia = 1.6, -- studs que vuelan
	Umbrales = { 50, 100, 200 }, -- el golpe crece y cambia de color al pasar estos valores
	UmbralEscala = 0.08, -- cuánto más grande queda el número en cada umbral
	UmbralColores = { "#E8FF3A", "#FFB020", "#FF6A20", "#FF2E4D" }, -- antes y después de cada umbral
	HitStop = 0.08, -- segundos que se congela la bola cuando una azul multiplica
	SacudidaMulti = 0.15, -- studs que tiembla la cámara con la azul
	DanioGrande = 0.9, -- segundos que se ve el número grande sobre el monstruo
	Inclinar = 12, -- grados que se inclina el cartel del monstruo al recibir el golpe
	Destello = 0.12, -- segundos del flash blanco en el cartel
	Pedazos = 6, -- pedazos en que se rompe el cartel al morir el monstruo
	Acercar = 4, -- studs que el cartel se acerca a la cámara al contraatacar
	BordeRojo = 0.4, -- segundos del borde rojo en la pantalla cuando te pegan
	JefeOscuro = 1.4, -- segundos de la entrada del jefe (pantalla oscura y su nombre)
	CartasEntrada = 0.12, -- segundos entre la entrada de una carta del cofre y la siguiente
	-- 27/10 "más dopamina":
	Onda = 0.45, -- segundos del anillo de luz que se abre en cada clavija tocada
	OndaTamanio = 3.4, -- studs que mide el anillo al final
	BrilloApagar = 0.45, -- segundos que tarda una clavija tocada en volver a su color
	Estela = 0.3, -- segundos de la estela de la bola
	LuzBola = { Brillo = 2.2, Alcance = 7 }, -- la bola ilumina las clavijas al pasar
	ComboMinimo = 3, -- desde cuántos toques sale el contador de combo
	Gritos = { "¡BIEN!", "¡GENIAL!", "¡BRUTAL!" }, -- al pasar cada umbral del golpe
	Zoom = 0.05, -- cuánto se acerca la cámara (fracción) en cada umbral; el doble al pegar fuerte
	Flash = 0.18, -- segundos del destello de pantalla
	Confeti = 40, -- partículas al romper el monstruo (la mitad con efectos reducidos)
	ChispasCaida = 14, -- partículas cuando la bola cae abajo
	ConteoGolpe = 0.45, -- segundos que tarda el número de daño en contar hasta su valor
	Respirar = 2.5, -- grados que se balancea el monstruo quieto
	Pulso = 1.6, -- segundos de cada latido de los tubos de neón
}

-- Cómo se ve la pantalla de juego (26/10: CloverPit + futurista). 3 variantes para que Juani
-- elija; manda Variante (en Studio se puede probar otra con el atributo "EstiloPantalla" de
-- Workspace). Cada una tiene la paleta del HUD (client/Estilo) y la del mundo (client/Escena).
Config.Pantalla = {
	Variante = "D",
	Variantes = {
		-- A · CloverPit puro: metal gastado oliva, LED naranja, contorno amarillo, sin neón.
		A = {
			Hud = {
				Velo = "#0A0A08",
				Panel = "#0C0C0A",
				PanelClaro = "#2A2A24",
				Carta = "#1A1A16",
				Boton = "#3A3A30",
				Principal = "#FFE600",
				TextoPrincipal = "#0C0C0A",
				Peligro = "#D8261E",
				Oro = "#FF8A1E",
				Texto = "#F2EFE6",
				Apagado = "#8C887A",
				Borde = "#FFE600",
				Vida = "#6BCB3A",
				Si = "#6BCB3A",
				No = "#3A3A30",
			},
			BordePanel = "", -- sin borde de neón en los paneles
			Fuente = "Oswald",
			FuenteTexto = "Oswald",
			Esquina = 0,
			Pared = "#24231D",
			MaterialPared = "Concrete",
			Marco = "#3F3E35",
			MaterialMarco = "DiamondPlate",
			Tablero = "#0B0B09",
			Neon1 = "#FF8A1E",
			Neon2 = "#FFE600",
			Ambiente = "#1E1C17",
			Franjas = true,
		},
		-- B · Mezcla: lo de A con bordes de neón magenta y cian (lo futurista).
		B = {
			Hud = {
				Velo = "#08070C",
				Panel = "#0C0B10",
				PanelClaro = "#26242C",
				Carta = "#16151C",
				Boton = "#34323C",
				Principal = "#FFE600",
				TextoPrincipal = "#0C0C0A",
				Peligro = "#D8261E",
				Oro = "#FF8A1E",
				Texto = "#F2EFE6",
				Apagado = "#8C8896",
				Borde = "#3FE8FF",
				Vida = "#6BCB3A",
				Si = "#6BCB3A",
				No = "#34323C",
			},
			BordePanel = "#FF3FD0",
			Fuente = "Oswald",
			FuenteTexto = "Oswald",
			Esquina = 4,
			Pared = "#1E1D18",
			MaterialPared = "Concrete",
			Marco = "#3F3E35",
			MaterialMarco = "DiamondPlate",
			Tablero = "#0A0910",
			Neon1 = "#FF3FD0",
			Neon2 = "#3FE8FF",
			Ambiente = "#1C1828",
			Franjas = true,
		},
		-- D · Pixel (27/10, etapa 10b): pixel art tipo Balatro, marcos de ForgeGUI (Config.Assets.Hud),
		-- letra pixel, azul = Fuerza, rojo = Multi, dorado = oro, menta = vida.
		D = {
			Hud = {
				Velo = "#0E0F18",
				Panel = "#1A1C2C",
				PanelClaro = "#3B3F58",
				Carta = "#262A40",
				Boton = "#3B3F58",
				Principal = "#F5C542",
				TextoPrincipal = "#1A1C2C",
				Peligro = "#E2323F",
				Oro = "#F5C542",
				Texto = "#F4F1E8",
				Apagado = "#8A8FA8",
				Borde = "#5D637E",
				Vida = "#4CC46A",
				Si = "#4CC46A",
				No = "#3B3F58",
				Fuerza = "#3C8CFF",
				Multi = "#E2323F",
				Sombra = "#0E0F18",
			},
			BordePanel = "",
			Pixel = true, -- paneles y casilleros con los marcos de Config.Assets.Hud
			Fuente = "Arcade",
			FuenteTexto = "Arcade",
			Esquina = 6,
			Pared = "#14121F",
			MaterialPared = "SmoothPlastic",
			Marco = "#3B3F58",
			MaterialMarco = "Slate",
			Tablero = "#10111C",
			Neon1 = "#FF3FD0",
			Neon2 = "#3FE8FF",
			Ambiente = "#1C1828",
			Franjas = false,
			Remolino = true, -- remolino lento violeta y cian en la pared de atrás del tablero
		},
		-- C · Futurista: paneles negros brillantes, neón por todos lados, naranja solo en números.
		C = {
			Hud = {
				Velo = "#05040A",
				Panel = "#07060C",
				PanelClaro = "#1C1830",
				Carta = "#100E1C",
				Boton = "#241F3C",
				Principal = "#FF3FD0",
				TextoPrincipal = "#FFFFFF",
				Peligro = "#FF3355",
				Oro = "#FF8A1E",
				Texto = "#FFFFFF",
				Apagado = "#7E78A0",
				Borde = "#3FE8FF",
				Vida = "#3FE8FF",
				Si = "#3FE8FF",
				No = "#241F3C",
			},
			BordePanel = "#3FE8FF",
			Fuente = "Michroma",
			FuenteTexto = "GothamBold",
			Esquina = 10,
			Pared = "#0B0A10",
			MaterialPared = "SmoothPlastic",
			Marco = "#14121C",
			MaterialMarco = "SmoothPlastic",
			Tablero = "#05040A",
			Neon1 = "#FF3FD0",
			Neon2 = "#3FE8FF",
			Ambiente = "#12101E",
			Franjas = false,
		},
	},
}

-- La variante que se usa (la de Config, o la del atributo de Workspace para probar en Studio).
function Config.variantePantalla(): any
	local nombre = Config.Pantalla.Variante
	local ok, atributo = pcall(function()
		return workspace:GetAttribute("EstiloPantalla")
	end)
	if ok and typeof(atributo) == "string" and (Config.Pantalla.Variantes :: any)[atributo] then
		nombre = atributo
	end
	return (Config.Pantalla.Variantes :: any)[nombre]
end

-- Sala (etapa 7b, rehecha el 26/10 con las capturas nuevas de Juani): una celda chica y sucia
-- como CloverPit (paredes de concreto, puerta de metal, ventilador, tubo fluorescente, mesa de
-- trabajo con la máquina arriba, estante, cartel de reglas en la pared) con toques futuristas de
-- neón como FNAF Security Breach. Todo armado con partes por código en server/GeneradorSala.
Config.Sala = {
	Ancho = 20, -- x
	Largo = 16, -- z
	Alto = 10,
	Maquinas = 1, -- la sala es en solitario (servidores de 1 jugador): solo tu máquina
	MaquinaTamanio = Vector3.new(4.4, 3.8, 3), -- la máquina, arriba de la mesa
	PantallaTamanio = Vector3.new(3.2, 2.1, 0.1),
	AltoMesa = 3.2,
	DistanciaJugar = 8, -- studs para que aparezca "E: Jugar"
	TiempoCamara = 0.8, -- segundos que tarda la cámara en meterse en la pantalla
	TiempoFundido = 0.2, -- fundido al entrar o salir de la pantalla
	TiempoMinimoBola = 0.3, -- segundos entre dos "elegir bola" en el mostrador (servidor)
	EscalaEstatua = 1, -- tamaño de la estatua de tu avatar (la celda es baja)
	GiroEstatua = 0, -- grados: 0 mira hacia -Z (la estatua está contra la pared sur)
	Grilla = 4, -- studs entre las líneas de neón del piso
	ReflejoPiso = 0.15,
	Baldosa = 2, -- etapa 10c: lado de las baldosas del damero (studs)
	ReflejoDamero = 0.25,
	-- Paleta medida de las capturas (CloverPit + FNAF Security Breach).
	Colores = {
		Piso = "#17160F", -- concreto sucio
		GrillaA = "#5A2160", -- líneas del piso (neón apagado)
		GrillaB = "#164C56",
		Pared = "#2B2A22", -- concreto oscuro, oliva
		Metal = "#3F3E35", -- máquina, terminal, puerta
		MetalOscuro = "#1C1C18",
		Madera = "#3A2A1E", -- mesa de trabajo
		Papel = "#A89F86", -- carteles pegados en la pared
		Peligro = "#D8B41C", -- franjas amarillas y negras
		Led = "#FF8A1E", -- displays naranja
		Boton = "#C8261E",
		Pantalla = "#0E1612",
		Borde = "#FFE600", -- contorno amarillo de lo que se puede tocar (como CloverPit)
		Magenta = "#FF3FD0",
		DameroA = "#120F1C", -- etapa 10c: piso damero
		DameroB = "#221C33",
		PanelA = "#1C1828", -- paneles acústicos
		PanelB = "#241F33",
		Alarma = "#FF2A2A", -- luces de la puerta blindada (verdes al abrir: Vida del HUD)
		Cian = "#3FE8FF",
		Fluor = "#D8F0D0", -- tubo fluorescente
		Lampara = "#FFB060", -- luz cálida sobre la máquina
	},
	LuzNeon = { Brillo = 0.9, Alcance = 12 },
}

return Config
