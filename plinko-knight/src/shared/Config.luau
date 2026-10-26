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

-- El caballero: vida al empezar la mazmorra y cuánto se cura al ganar cada pelea.
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
	Golpe = "#E2323F", -- el caballero se pone de este color cuando lo golpean
	VidaMonstruo = "#E2323F",
	VidaCaballero = "#4CC46A",
	FondoBarra = "#151B2E",
	Magia = "#4FE3F0", -- velas, cristales y niebla
}

-- Mundo de la etapa 9: materiales y luz.
Config.Mundo = {
	MaterialClavija = "Neon", -- "Neon" (brilla) o "Metal": con la luz cian el metal dorado se ve verde
	BrilloVela = 1.6, -- PointLight de las 2 velas cian
	AlcanceVela = 22,
	Niebla = 0.1, -- densidad de la Atmosphere (más alto tapa todo: la cámara está a 170 studs)
}

-- Imágenes (etapa 9, ForgeGUI, estilo "Plinko Knight - Cripta azul"), subidas a la cuenta de Juani.
Config.Assets = {
	Fondo = "rbxassetid://87670022073361",
	Caballero = "rbxassetid://78494523251389",
	Monstruos = {
		rata = "rbxassetid://80675382037335",
		slime = "rbxassetid://109145942201870",
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
	TonoToque = { 1, 1.8 }, -- PlaybackSpeed del primer toque y tope (sube con cada toque del tiro)
}

-- Etapa 7b-1: la sala arcade (en gris; los modelos de la IA llegan en 7b-2). Studs.
Config.Sala = {
	Ancho = 60, -- x
	Largo = 40, -- z
	Alto = 14,
	Maquinas = 1, -- la sala es en solitario (servidores de 1 jugador): solo tu máquina
	SeparacionMaquinas = 7,
	MaquinaTamanio = Vector3.new(4, 7, 3),
	PantallaTamanio = Vector3.new(3.2, 2.4, 0.1),
	DistanciaJugar = 8, -- studs para que aparezca "E: Jugar"
	TiempoCamara = 0.8, -- segundos que tarda la cámara en meterse en la pantalla
	TiempoFundido = 0.2, -- fundido al entrar o salir de la pantalla
	TiempoMinimoBola = 0.3, -- segundos entre dos "elegir bola" en el mostrador (servidor)
	-- Colores de la sala en gris (la paleta de neón llega en 7b-3).
	Colores = {
		Piso = "#3A3A3A",
		Pared = "#2A2A2A",
		Maquina = "#6A6A6A",
		Pantalla = "#151B2E",
		Fondo = "#4A4A4A", -- máquinas de fondo, molinete, banquetas
		Cartel = "#E0E0E0",
		Borde = "#FFE600", -- contorno amarillo de lo que se puede tocar (como CloverPit)
	},
}

return Config
