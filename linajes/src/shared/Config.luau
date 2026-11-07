--!strict
-- Números de balance y datos de Linajes del Eclipse (todo lo que se ajusta va acá).

local Config = {}

-- Cuerpo propio (el juego no usa el avatar de Roblox). Modelos en arte/exports/cuerpo/.
Config.Cuerpo = {
	-- 10 tonos de piel, de claro a oscuro (los mismos que arte/scripts/personajes/cuerpo.py).
	TonosPiel = {
		Color3.fromHex("f6d7c3"),
		Color3.fromHex("eac0a0"),
		Color3.fromHex("d9a382"),
		Color3.fromHex("c68a62"),
		Color3.fromHex("b0744e"),
		Color3.fromHex("96603f"),
		Color3.fromHex("7d4f33"),
		Color3.fromHex("653e28"),
		Color3.fromHex("4e2f1f"),
		Color3.fromHex("3a2318"),
	},
	-- Contextura: cuánto se ensanchan hombros (torso de arriba) y cadera (torso de abajo).
	Contexturas = {
		Normal = { Hombros = 1, Cadera = 1 },
		Ancha = { Hombros = 1.2, Cadera = 1.06 },
		Delgada = { Hombros = 0.88, Cadera = 0.88 },
	},
	Alturas = { Baja = 0.95, Media = 1, Alta = 1.05 },
	Expresiones = {
		"neutral",
		"enojado",
		"contento",
		"sorprendido",
		"dolor",
		"concentrado",
		"cansado",
		"derrotado",
	},
	Peinados = {
		"Corto",
		"Rapado",
		"Pinchos",
		"Cresta",
		"Melena",
		"Cola",
		"Rodete",
		"DosRodetes",
		"Afro",
		"Flequillo",
		"PeinadoAtras",
		"Trenzas",
	},
	-- IDs de las texturas de cara (decal en el frente de la cabeza): Caras[n][expresion].
	Caras = {
		{
			neutral = "rbxassetid://122387370774736",
			enojado = "rbxassetid://122012616125788",
			contento = "rbxassetid://128457234073539",
			sorprendido = "rbxassetid://106636369301721",
			dolor = "rbxassetid://130651886221936",
			concentrado = "rbxassetid://131146267476123",
			cansado = "rbxassetid://112057996724561",
			derrotado = "rbxassetid://131935077843406",
		},
		{
			neutral = "rbxassetid://130754249584655",
			enojado = "rbxassetid://88131502652177",
			contento = "rbxassetid://138637074610036",
			sorprendido = "rbxassetid://105982609129026",
			dolor = "rbxassetid://129841815826250",
			concentrado = "rbxassetid://98675548896271",
			cansado = "rbxassetid://105104711214343",
			derrotado = "rbxassetid://99575065659793",
		},
		{
			neutral = "rbxassetid://121723781750292",
			enojado = "rbxassetid://106072185264397",
			contento = "rbxassetid://139508127727914",
			sorprendido = "rbxassetid://131357294957277",
			dolor = "rbxassetid://111546955542406",
			concentrado = "rbxassetid://127476461772690",
			cansado = "rbxassetid://75837715279053",
			derrotado = "rbxassetid://121557092434622",
		},
		{
			neutral = "rbxassetid://126162527191760",
			enojado = "rbxassetid://97954684864385",
			contento = "rbxassetid://73648755578234",
			sorprendido = "rbxassetid://90587444963489",
			dolor = "rbxassetid://106836870821863",
			concentrado = "rbxassetid://136399100123990",
			cansado = "rbxassetid://93552982637582",
			derrotado = "rbxassetid://108885439727467",
		},
		{
			neutral = "rbxassetid://106232674516751",
			enojado = "rbxassetid://88254183120085",
			contento = "rbxassetid://121452434699208",
			sorprendido = "rbxassetid://135055791840339",
			dolor = "rbxassetid://135270512880198",
			concentrado = "rbxassetid://128338908687413",
			cansado = "rbxassetid://97862317663416",
			derrotado = "rbxassetid://137819907818819",
		},
		{
			neutral = "rbxassetid://91793580507751",
			enojado = "rbxassetid://116865949271231",
			contento = "rbxassetid://111114427194997",
			sorprendido = "rbxassetid://79333699565526",
			dolor = "rbxassetid://118482644384777",
			concentrado = "rbxassetid://91803336712877",
			cansado = "rbxassetid://99968147071822",
			derrotado = "rbxassetid://95199580649019",
		},
		{
			neutral = "rbxassetid://122993991218408",
			enojado = "rbxassetid://139382022164125",
			contento = "rbxassetid://126853765172585",
			sorprendido = "rbxassetid://108864118217215",
			dolor = "rbxassetid://128085280810654",
			concentrado = "rbxassetid://86080056245274",
			cansado = "rbxassetid://125072496903400",
			derrotado = "rbxassetid://107641586807904",
		},
		{
			neutral = "rbxassetid://89794353848236",
			enojado = "rbxassetid://79309973497106",
			contento = "rbxassetid://100656212757399",
			sorprendido = "rbxassetid://120865333657750",
			dolor = "rbxassetid://104209407707158",
			concentrado = "rbxassetid://110386072174897",
			cansado = "rbxassetid://77471777673677",
			derrotado = "rbxassetid://103003734621859",
		},
		{
			neutral = "rbxassetid://87455375689508",
			enojado = "rbxassetid://106257925043053",
			contento = "rbxassetid://106912659668045",
			sorprendido = "rbxassetid://139439428801609",
			dolor = "rbxassetid://99272233783133",
			concentrado = "rbxassetid://77540114133369",
			cansado = "rbxassetid://98050240131861",
			derrotado = "rbxassetid://140085397597307",
		},
		{
			neutral = "rbxassetid://105628473006658",
			enojado = "rbxassetid://129891462404778",
			contento = "rbxassetid://98684075152888",
			sorprendido = "rbxassetid://125897699985625",
			dolor = "rbxassetid://108492318969983",
			concentrado = "rbxassetid://140115983183654",
			cansado = "rbxassetid://122579755317072",
			derrotado = "rbxassetid://76142044099535",
		},
		{
			neutral = "rbxassetid://94113810656835",
			enojado = "rbxassetid://102252143623178",
			contento = "rbxassetid://115902579765871",
			sorprendido = "rbxassetid://83446297580969",
			dolor = "rbxassetid://137883289310184",
			concentrado = "rbxassetid://136880386416004",
			cansado = "rbxassetid://122229686476155",
			derrotado = "rbxassetid://115761775105577",
		},
		{
			neutral = "rbxassetid://118406421835615",
			enojado = "rbxassetid://138919388041040",
			contento = "rbxassetid://88095744275121",
			sorprendido = "rbxassetid://84414735598185",
			dolor = "rbxassetid://123864619738950",
			concentrado = "rbxassetid://139680577987901",
			cansado = "rbxassetid://127164536730846",
			derrotado = "rbxassetid://97580067848009",
		},
	},
	-- Cicatrices y marcas (segundo decal encima de la cara).
	Marcas = {
		"rbxassetid://114839720509084",
		"rbxassetid://120660914770060",
		"rbxassetid://96766852472716",
		"rbxassetid://71969688412861",
		"rbxassetid://81798824683215",
		"rbxassetid://131778420915567",
	},
}

-- Lo que tiene un jugador nuevo. Hasta que exista el creador de personaje, el servidor elige al
-- azar (fijo para cada UserId) para que cada uno se vea distinto.
Config.Cuerpo.Inicial = {
	Contextura = "Normal",
	Altura = "Media",
	Tono = 4,
	Cara = 1,
	Peinado = "Corto",
	ColorPelo = "1c1714",
	Marca = 0, -- 0 = sin marca
}
-- Ropa base (el cuerpo es el de Roblox): remera de manga corta y pantalón como ropa clásica
-- (plantillas blancas de arte/scripts/ropa.py, el color lo pone Color3). Las piezas toman el
-- color de su grupo: los brazos son piel (la manga los tapa arriba) y las piernas, zapatillas
-- (el pantalón las tapa hasta el tobillo).
Config.Cuerpo.Ropa = {
	Remera = "rbxassetid://93586573652795",
	Pantalon = "rbxassetid://77536036337624",
	Colores = {
		Remera = Color3.fromHex("6f7f9e"),
		Pantalon = Color3.fromHex("3c4250"),
		Zapatos = Color3.fromHex("22252c"),
	},
	Partes = {
		Head = "Piel",
		UpperTorso = "Remera",
		LowerTorso = "Pantalon",
		LeftUpperArm = "Piel",
		RightUpperArm = "Piel",
		LeftLowerArm = "Piel",
		RightLowerArm = "Piel",
		LeftHand = "Piel",
		RightHand = "Piel",
		LeftUpperLeg = "Zapatos",
		RightUpperLeg = "Zapatos",
		LeftLowerLeg = "Zapatos",
		RightLowerLeg = "Zapatos",
		LeftFoot = "Zapatos",
		RightFoot = "Zapatos",
	},
}
-- Cuerpo oficial cómic urbano: piezas en ServerStorage.CuerpoComic (arte/scripts/personajes/cuerpo_comic.py).
Config.Cuerpo.Comic = {
	Piezas = { "Cuerpo", "Remera", "Campera", "Cinturon", "Pantalon", "Zapatillas" },
	Peinados = { "PeloPuntas", "PeloCorto", "PeloFlequillo" },
	ColorPelo = Color3.fromHex("#4468AE"), -- por defecto; el creador deja elegir otro
	Texturas = { Pelo = "rbxassetid://93286191132215", Zapatillas = "rbxassetid://117152327461014" },
	Caras = {
		"rbxassetid://131546855294230",
		"rbxassetid://112533320464128",
		"rbxassetid://130513753581230",
	},
}
-- Diferencia mínima de color (0 a 1,7) entre pelo y piel cuando el pelo sale al azar.
Config.Cuerpo.ContrastePelo = 0.3
Config.Cuerpo.ColoresPelo = {
	"1c1714",
	"3a2a20",
	"6b4426",
	"a8743a",
	"d8b878",
	"8a2c1c",
	"e8e4dc",
	"2f6fdb",
	"6b5ba8",
	"c2213a",
	"3fc1b0",
	"f2652b",
}

-- Combate cuerpo a cuerpo (server/Combate.server.luau). Impacto y Espera en segundos, ya con la
-- velocidad de VelocidadGolpes aplicada.
Config.Combate = {
	Vida = 400,
	Energia = 100,
	EnergiaPorSegundo = 8,
	Golpes = {
		{ Danio = 8, Impacto = 0.27, Espera = 0.45, Tipo = "Normal", Recarga = 0 },
		{ Danio = 8, Impacto = 0.27, Espera = 0.45, Tipo = "Normal", Recarga = 0 },
		{ Danio = 10, Impacto = 0.36, Espera = 0.55, Tipo = "Normal", Recarga = 0 },
		{ Danio = 14, Impacto = 0.53, Espera = 0.8, Tipo = "Lanza", Recarga = 1.4 },
	},
	-- Variantes: Aire (clic en el aire), Arriba (S + clic en el 4.º golpe), Dash (clic justo después del dash).
	Variantes = {
		Aire = {
			Danio = 16,
			Impacto = 0.53,
			Espera = 0.8,
			Tipo = "Piso",
			Recarga = 1.2,
			Anim = "GolpeAire",
		},
		Arriba = {
			Danio = 12,
			Impacto = 0.36,
			Espera = 0.6,
			Tipo = "Arriba",
			Recarga = 0.5,
			Anim = "Golpe3",
		},
		Dash = {
			Danio = 10,
			Impacto = 0.27,
			Espera = 0.45,
			Tipo = "Normal",
			Recarga = 0,
			Anim = "Golpe1",
		},
	},
	VentanaDash = 0.45, -- tiempo después del dash para el golpe de dash
	AlturaAire = 1.2, -- el servidor cuenta aire desde esta altura sobre el piso
	SubeArriba = 62,
	BajaPiso = 70,
	VelocidadGolpes = 0.75,
	ReinicioCombo = 1.1, -- desde el último pedido de golpe
	Proteccion = 1.2, -- el lanzado no recibe daño ni freno al levantarse
	DesgasteFreno = 0.8, -- cada golpe seguido frena menos
	VentanaDesgaste = 2.5,
	Tolerancia = 0.75, -- el servidor acepta el golpe antes: tapa la demora de la red
	Alcance = 9,
	AlcancePatada = 11,
	ConoGolpe = 0, -- 1 es justo adelante, 0 es todo el frente
	Empuje = 12, -- retroceso de los golpes 1 a 3
	Lanza = 58, -- el 4.º golpe lanza
	LanzaArriba = 26,
	Freno = 0.55, -- segundos que el golpeado no puede actuar
	FrenoLanzado = 1.1,
	Asistencia = 12, -- distancia a la que el golpe busca al rival
	Avance = 42, -- velocidad del paso al golpear
	AvanceTiempo = 0.12,
	Cercania = 3.6, -- no avanza más cerca que esto
	ColorChispas = Color3.fromHex("#3fe0f0"), -- después sale del Linaje
	Sacudida = 0.35,
	SacudidaFuerte = 0.9,
	ContadorDura = 1.6,
	FrenaBloqueo = 0.7,
	EnergiaBloqueo = 10,
	VentanaParry = 0.2,
	AturdeParry = 1,
	DashDistancia = 20,
	DashTiempo = 0.2,
	DashRecarga = 1.5,
	DashInvulnerable = 0.25,
	ColaTeclas = 0.15,
	PedidosPorSegundo = 10,
	HitStop = 0.07,
	HitStopParry = 0.12,
	Destello = 0.12,
	ManiquiDistancia = 38,
	ManiquiSemilla = 7,
	ManiquiPausa = 3,
	ManiquiAtaca = 9, -- pega si hay un jugador a esta distancia
	ManiquiAviso = 0.6,
	ManiquiDanio = 12,
	ManiquiVuelve = 3,
	-- Matones de práctica: se mueven, avisan y pegan. Puntos relativos al centro de la arena.
	Matones = {
		Puntos = { { -20, -92 }, { 100, 30 }, { 24, 92 } },
		Vida = 180,
		Velocidad = 18,
		Detecta = 110,
		Golpea = 7,
		SinPiezas = { Maton_Panuelo = true, Maton_Cadena = true },
		Embestida = { Desde = 14, Hasta = 40, Rapidez = 70, Dura = 0.28, Recarga = 4 },
		Bloqueo = { Chance = 0.35, Dura = 0.8, Recarga = 3 },
		Pausa = 0.9,
		Aviso = 0.3,
		Danio = 10,
		Vuelve = 6,
		Xp = 60,
		Semilla = 21,
		Gorros = { "Maton_Gorro", "Maton_Gorro_Gris", "Maton_Gorro_Verde" },
	},
}

-- Arena libre. Nadie pega ni recibe daño dentro de la zona segura.
Config.Arena = {
	ZonaCentro = Vector3.new(-430, 0, 1120),
	ZonaRadio = 22,
	ProteccionAparecer = 4,
	Reaparicion = 2,
	-- Plano de la arena (server/ArenaMapa.server.luau). Posiciones relativas a Centro.
	Mapa = {
		Centro = Vector3.new(-330, 0, 1035),
		Ancho = 288,
		Largo = 260,
		RadioCirculo = 26,
		TorreX = 92,
		Porticos = { -50, 90 },
		Reflectores = { { 60, -112 } },
		Grupos = { { -72, -66 }, { 72, -66 }, { -60, 66 }, { 72, 66 } },
		Charcos = {},
		Faroles = {
			{ 122, 96, 1 },
			{ -122, 40, 1 },
			{ -44, 44, 1 },
			{ 44, -44, 1 },
			{ 0, 108, 1 },
			{ 100, 10, 1 },
			{ -100, -60, 1 },
		},
		TonosContenedor = { "Rojo", "Azul", "Verde", "Gris" },
		Colores = {
			Asfalto = "#23262f",
			Hormigon = "#3c404b",
			Linea = "#b9902c",
			Charco = "#141820",
			Acero = "#4a505c",
			Oxido = "#6e3b2e",
			Madera = "#6b4a2f",
			Sodio = "#e8a33c",
			Acento = "#b9902c",
			Rojo = "#a8342c",
			Azul = "#2c5f92",
			Verde = "#35785c",
			Gris = "#7c838c",
			BarrilAzul = "#2f6288",
			Reflector = "#cfe0ff",
		},
	},
}

-- Guardado (server/Perfiles.luau).
Config.Guardado = { Almacen = "Linajes_v1", Version = 1 }

-- Ruleta (server/Ruleta.server.luau). Peso: % del plan de lanzamiento. Los no Disponibles no salen
-- ni se muestran; los % visibles se recalculan. Las Fichas solo se ganan jugando.
Config.Ruleta = {
	BajasPorFicha = 5,
	Espera = 3,
	Opciones = {
		{
			Linaje = "FuerzaBruta",
			Nombre = "Fuerza Bruta",
			Rareza = "Común",
			Peso = 21.67,
			Disponible = true,
		},
		{
			Linaje = "Reflejos",
			Nombre = "Reflejos",
			Rareza = "Común",
			Peso = 21.67,
			Disponible = true,
		},
		{
			Linaje = "Piroquinesis",
			Nombre = "Piroquinesis",
			Rareza = "Común",
			Peso = 21.66,
			Disponible = true,
		},
		{
			Linaje = "Electro",
			Nombre = "Electro",
			Rareza = "Poco común",
			Peso = 11.67,
			Disponible = false,
		},
		{
			Linaje = "Criogenia",
			Nombre = "Criogenia",
			Rareza = "Poco común",
			Peso = 11.67,
			Disponible = false,
		},
		{
			Linaje = "Telequinesis",
			Nombre = "Telequinesis",
			Rareza = "Poco común",
			Peso = 11.66,
			Disponible = false,
		},
	},
}

-- Habilidades de los Linajes (server/Poderes.server.luau). Números de las notas de la bóveda.
-- Impacto: segundos desde que se aprieta hasta que el servidor resuelve la habilidad.
Config.Poderes = {
	CambioLibre = true, -- T cambia de Linaje; se apaga cuando esté la ruleta
	Orden = { "FuerzaBruta", "Reflejos", "Piroquinesis" },
	MargenRecarga = 0.2,
	MargenRed = 4,
	QuemaVeces = 3,
	QuemaDanio = 4,
	BolaVelocidad = 90,
	MuroDura = 4,
	MuroGrosor = 3,
	Colores = {
		FuerzaBruta = Color3.fromHex("#f2a23a"),
		Reflejos = Color3.fromHex("#3fe0f0"),
		Piroquinesis = Color3.fromHex("#f2652b"),
	},
	Linajes = {
		FuerzaBruta = {
			Z = {
				Nombre = "Puño sísmico",
				Accion = "PunoSismico",
				Danio = 30,
				Recarga = 6,
				Energia = 20,
				Alcance = 8,
				Impacto = 0.4,
			},
			X = {
				Nombre = "Golpe al piso",
				Accion = "GolpePiso",
				Danio = 25,
				Recarga = 9,
				Energia = 25,
				Alcance = 10,
				Impacto = 0.53,
			},
			C = {
				Nombre = "Embestida",
				Accion = "Embestida",
				Danio = 20,
				Recarga = 12,
				Energia = 20,
				Alcance = 14,
				Impacto = 0.45,
			},
		},
		Reflejos = {
			Z = {
				Nombre = "Contragolpe",
				Accion = "Contragolpe",
				Danio = 10,
				Golpes = 3,
				Dura = 0.6,
				Recarga = 7,
				Energia = 15,
				Impacto = 0,
			},
			X = {
				Nombre = "Paso fantasma",
				Accion = "PasoFantasma",
				Danio = 25,
				Recarga = 8,
				Energia = 20,
				Alcance = 12,
				Impacto = 0.2,
			},
			C = {
				Nombre = "Lluvia de golpes",
				Accion = "LluviaGolpes",
				Danio = 5,
				Golpes = 6,
				Recarga = 10,
				Energia = 25,
				Alcance = 7,
				Impacto = 0.1,
			},
		},
		Piroquinesis = {
			Z = {
				Nombre = "Bola de fuego",
				Accion = "BolaFuego",
				Danio = 22,
				Recarga = 5,
				Energia = 15,
				Alcance = 40,
				Impacto = 0.4,
			},
			X = {
				Nombre = "Chorro",
				Accion = "Chorro",
				Danio = 5,
				Golpes = 6,
				Dura = 1.5,
				Recarga = 9,
				Energia = 25,
				Alcance = 12,
				Impacto = 0.2,
			},
			C = {
				Nombre = "Muro de fuego",
				Accion = "MuroFuego",
				Danio = 8,
				Recarga = 12,
				Energia = 25,
				Alcance = 10,
				Impacto = 0.6,
			},
		},
	},
}

-- Animaciones de nuestro Animate (src/character/Animate.client.luau).
-- Teclas de prueba (client/PruebaTeclas): solo visuales. Apagar antes de publicar.
Config.PruebaTeclas = {
	Activas = true,
	Caminar = 16, -- se corre por defecto
	Correr = 22,
	CorrerRapido = 28,
	Dash = 70,
	DashTiempo = 0.18,
	Embestida = 34,
	PausaCombo = 1.4,
	EsperaCombo = 0.75, -- parte del golpe que tiene que pasar antes del siguiente
	VelocidadCombo = 0.75, -- 1 es la velocidad original
	SaltoAire = 38,
	Cartel = "Click: combo   S + click en el 4.º: levanta   Click en el aire: martillazo   Click tras el dash: golpe de dash\nQ + WASD: dash   F: bloqueo (justo antes del golpe: parry)   Z X C: poderes   T: cambia Linaje\nShift: correr más   Ctrl: rápido   Y: vuelo",
}

Config.Animaciones = {
	VelocidadCorrer = 12, -- studs/s: desde acá pasa de caminar a correr
	VelocidadCorrerRapido = 24, -- studs/s: desde acá usa CorrerRapido (Velocista, Reflejos)
	VelocidadVolar = 2, -- studs/s: volando, desde acá pasa de VolarQuieto a VolarAvanzando
	-- Velocidad del personaje a la que cada animación va a velocidad normal: más rápido la
	-- acelera y más lento la frena (así los pies patinan menos). Tope de 0,7 a 1,8 veces.
	Referencia = { Caminar = 8, Correr = 16, CorrerRapido = 28 },
	TopeVelocidad = { 0.7, 1.8 },
	-- Locomoción propia (P26-01), hecha con arte/scripts/animaciones/base.py. Loop en todas menos
	-- SaltarInicio y SaltarCaer; prioridad Core en Quieto y Movement en el resto. Caminar, Correr y
	-- CorrerRapido tienen marcadores "Paso" (polvo y sonido de pisada).
	base = {
		Quieto = "rbxassetid://89944914954631",
		Caminar = "rbxassetid://88356842303752",
		Correr = "rbxassetid://106850877934413",
		CorrerRapido = "rbxassetid://114971458302373", -- Velocista y Reflejos
		SaltarInicio = "rbxassetid://127510848550318",
		SaltarAire = "rbxassetid://130351075419572",
		SaltarCaer = "rbxassetid://87298594021701",
		Trepar = "rbxassetid://106396530746894",
		VolarQuieto = "rbxassetid://138806002896514",
		VolarAvanzando = "rbxassetid://80881764642372",
		Nadar = "rbxassetid://137741739612149",
		Flotar = "rbxassetid://103898599870719",
		-- Combate con Puños (P26-02). Prioridad Action, sin loop salvo Bloqueo y Aturdido.
		-- Marcador "Impacto" (el daño, el efecto y el sonido salen de ahí): Golpe1 y Golpe2 en el
		-- cuadro 6, Golpe3 en el 8, Golpe4 y GolpeAire en el 12, Parry en el 3.
		Golpe1 = "rbxassetid://124490545010999", -- jab derecho
		Golpe2 = "rbxassetid://136367059016439", -- cross izquierdo
		Golpe3 = "rbxassetid://102236631709002", -- gancho de costado
		Golpe4 = "rbxassetid://116334348414128", -- patada giratoria
		GolpeAire = "rbxassetid://117764910626942", -- ataque desde arriba
		BloqueoInicio = "rbxassetid://90977026835987",
		Bloqueo = "rbxassetid://90842853618125",
		Parry = "rbxassetid://74732296763320",
		DashAdelante = "rbxassetid://100155623254154",
		DashAtras = "rbxassetid://114909466999172",
		DashIzquierda = "rbxassetid://119984320402589",
		DashDerecha = "rbxassetid://96272898271683",
		GolpeLiviano = "rbxassetid://100186185692926",
		GolpeFuerte = "rbxassetid://96263197602089",
		Aturdido = "rbxassetid://73655937150525",
		Derrota = "rbxassetid://85197090039101",
		Levantarse = "rbxassetid://74779451597081",
		-- Solo de la cintura para arriba: se usan al moverse, y las piernas siguen caminando.
		Golpe1Torso = "rbxassetid://139023511235294",
		Golpe2Torso = "rbxassetid://84773377193523",
		Golpe3Torso = "rbxassetid://103930499788159",
		BloqueoInicioTorso = "rbxassetid://99465234209472",
		BloqueoTorso = "rbxassetid://101911376174368",
		ParryTorso = "rbxassetid://78764778298793",
		-- Interacción (P26-03): publicadas, sin usar todavía en el código.
		Banco = "rbxassetid://118422749305884",
		Celebrar = "rbxassetid://87787355391951",
		Hablar = "rbxassetid://95409874266176",
		Recoger = "rbxassetid://98691000300195",
		Saludar = "rbxassetid://108354307810686",
	},
	-- Fuerza Bruta (P27-01), hecha con arte/scripts/animaciones/linaje-fuerzabruta.py. Embestida y Cargar
	-- van en piezas: inicio, loop y frenada. Marcadores: Impacto en Puño, GolpePiso y EmbestidaFrenada.
	-- Reflejos (P27-02), hecha con arte/scripts/animaciones/linaje-reflejos.py. Marcadores: Impacto en
	-- Contragolpe y en cada piña de Lluvia; Desaparece y Aparece en PasoFantasma (ahí va el efecto).
	linaje_reflejos = {
		Contragolpe = "rbxassetid://133853485880035",
		PasoFantasma = "rbxassetid://86385013535898",
		LluviaGolpes = "rbxassetid://125343911488522",
		CargarInicio = "rbxassetid://72086404050001",
		CargarLoop = "rbxassetid://100169266387602",
	},
	-- Piroquinesis (P27-03), hecha con arte/scripts/animaciones/linaje-piroquinesis.py. Marcadores:
	-- Enciende y Lanza en BolaFuego, Enciende en ChorroInicio, Impacto en MuroFuego.
	linaje_piroquinesis = {
		BolaFuego = "rbxassetid://73899188252872",
		ChorroInicio = "rbxassetid://128292249326676",
		ChorroLoop = "rbxassetid://131380095550558",
		ChorroFin = "rbxassetid://96398977781364",
		MuroFuego = "rbxassetid://128169833720239",
		CargarInicio = "rbxassetid://131965854869947",
		CargarLoop = "rbxassetid://87000928657902",
	},
	-- Remache (P28-01), hecha con arte/scripts/animaciones/remache.py. Publicada y sin usar: el jefe
	-- vuelve en el evento de la semana 4. Faltan importar el modelo y programarlo.
	jefe_remache = {
		Entrada = "rbxassetid://125922233015465",
		Quieto = "rbxassetid://131122330439514",
		Caminar = "rbxassetid://73955414675145",
		RecibirGolpe = "rbxassetid://132284113150173",
		Aturdido = "rbxassetid://72920279603229",
		CambioFase = "rbxassetid://105515250041535",
		Derrota = "rbxassetid://134547056528273",
		Martillazo = "rbxassetid://130108324798220",
		CargaInicio = "rbxassetid://117911039438817",
		CargaCarrera = "rbxassetid://139137804608398",
		CargaFrenada = "rbxassetid://132329831457405",
		Contenedor = "rbxassetid://93000774808385",
	},
	linaje_fuerzabruta = {
		PunoSismico = "rbxassetid://92821448797182",
		GolpePiso = "rbxassetid://77792023879204",
		EmbestidaInicio = "rbxassetid://70565357213088",
		EmbestidaCarrera = "rbxassetid://114871342098278",
		EmbestidaFrenada = "rbxassetid://112711315454919",
		CargarInicio = "rbxassetid://77164726952378",
		CargarLoop = "rbxassetid://93045599704287",
	},
}

-- Civiles de la calle viva (ficha 0e). Ropa en ServerStorage.Civiles.<Tipo>.<Pieza> (kit de
-- arte/scripts/civiles.py): cada malla tiene los atributos Hueso, Canal (C1, C2 o fijo) y Desfase.
-- Un civil = 1 de arriba + 1 de abajo + 1 de cabeza + a veces 1 accesorio (≤ 6.000 triángulos).
Config.Civiles = {
	Arriba = {
		"CamperaJean",
		"SacoOficina",
		"BuzoCapucha",
		"CamisaCuadros",
		"PilotoLargo",
		"ChalecoObra",
		"RemeraEstampa",
		"UniformeEnfermeria",
	},
	Abajo = { "Jean", "PantalonVestir", "Pollera", "Jogging", "Bermuda", "Mameluco" },
	Cabeza = {
		"Gorra",
		"GorroLana",
		"PeloCorto",
		"PeloLargoAtado",
		"Rulos",
		"PeladoBarba",
		"Sombrero",
		"Auriculares",
	},
	Accesorio = { "Maletin", "BolsaCompras", "Mochila", "ParaguasCerrado", "Cafe", "CorreaPerro" },
	-- El paraguas abierto sale solo cuando llueve (evento de clima) en vez del cerrado.
	ParaguasLluvia = "ParaguasAbierto",
	ChanceAccesorio = 0.6,
	-- Pelos: Color1 de PaletaPelo y Color2 (hebilla, gomita, anteojos) de PaletaAccesorioPelo,
	-- colores vivos que nunca se confunden con el pelo.
	Pelos = { PeloCorto = true, PeloLargoAtado = true, Rulos = true, PeladoBarba = true },
	PaletaRopa = {
		"2c3546",
		"3a3f4b",
		"6e3b2e",
		"8a5a2e",
		"2f5d8c",
		"4a6a90",
		"c2213a",
		"3d6b3f",
		"6b5ba8",
		"c9c6c0",
		"e9e7e2",
		"1b1f2a",
		"a3312a",
		"d9a441",
		"4ed68a",
		"7a7d84",
	},
	PaletaPelo = { "1a1410", "3a2a20", "6e4a35", "b08a5a", "c9c6c0" },
	PaletaAccesorioPelo = { "f2a23a", "3fe0f0", "ff4d6d", "4ed68a", "e9e7e2", "a15cf0" },
	-- Color2 fijo de algunas piezas (el chaleco de obra siempre es flúor).
	Color2Fijo = { ChalecoObra = "e8f04a" },
	-- Costuras, dobladillos y bolsillos (canal C1o) van en un tono del Color1: más oscuro, o más
	-- claro si la prenda ya es muy oscura (brillo menor a TonoOscuroMinimo), así siempre contrastan.
	Oscuro = 0.55,
	Claro = 0.35,
	TonoOscuroMinimo = 0.22,
	-- Civiles especiales: piezas del kit + sus props (carpeta Especial.<Nombre>) con colores fijos.
	Especiales = {
		Diarero = {
			Piezas = { "CamisaCuadros", "Jean", "Gorra" },
			Colores = {
				CamisaCuadros = { "2f5d8c", "c9c6c0" },
				Jean = { "2c3546", "3a2a20" },
				Gorra = { "1b1f2a", "f2652b" },
				Diarero = { "2f6fdb", "e9e7e2" },
			},
		},
		Vendedor = {
			Piezas = { "RemeraEstampa", "PantalonVestir", "Gorra" },
			Colores = {
				RemeraEstampa = { "e9e7e2", "c2213a" },
				PantalonVestir = { "3a3f4b", "121216" },
				Gorra = { "c2213a", "e9e7e2" },
				Vendedor = { "c0c4cc", "f2a23a" },
			},
		},
		Musico = {
			Piezas = { "CamperaJean", "Jogging", "GorroLana" },
			Colores = {
				CamperaJean = { "4a6a90", "b8bcc6" },
				Jogging = { "1b1f2a", "e9e7e2" },
				GorroLana = { "6b5ba8", "e9e7e2" },
				Musico = { "8a5a2e", "2a2018" },
			},
		},
	},
	-- Partes con tag "PuntoCivil" en el mapa: ahí aparece un civil (atributo Especial = nombre para
	-- uno especial). Tope de civiles por servidor, para el celular.
	MaximoPorServidor = 40,
}

-- Mundo abierto (graybox). El día dura MinutosPorDia minutos reales; en Vórtice siempre es de noche.
Config.Mundo = {
	MinutosPorDia = 24,
	HoraNocheEterna = 0,
	-- Niebla por ciudad (Atmosphere). "Bahia" es fuera de toda ciudad.
	Niebla = {
		PuertoOxido = { Densidad = 0.45, Bruma = 0.6, Color = "8a8f99" },
		CiudadVortice = { Densidad = 0.4, Bruma = 0.3, Color = "3a2f4b" },
		DistritoCorona = { Densidad = 0.2, Bruma = 0.1, Color = "c9d6e8" },
		Bahia = { Densidad = 0.3, Bruma = 0.3, Color = "9aa3ad" },
	},
	-- Luz por hora: se mezcla entre un punto y el siguiente (client/Clima.client.luau).
	-- La noche es azul y legible: nunca oscuridad total, porque en la arena hay que ver al rival.
	Luz = {
		{
			Hora = 0,
			Ambiente = "3d4a66",
			Exterior = "6a7ca6",
			Brillo = 1.6,
			Exposicion = 0.35,
			Tinte = "cfdcff",
			Contraste = 0.12,
			Saturacion = 0,
			Resplandor = 0.9,
		},
		{
			Hora = 5.5,
			Ambiente = "3d4a66",
			Exterior = "6a7ca6",
			Brillo = 1.6,
			Exposicion = 0.35,
			Tinte = "cfdcff",
			Contraste = 0.12,
			Saturacion = 0,
			Resplandor = 0.9,
		},
		{
			Hora = 7,
			Ambiente = "6a5a58",
			Exterior = "9a8a86",
			Brillo = 2.2,
			Exposicion = 0.1,
			Tinte = "ffe6d0",
			Contraste = 0.1,
			Saturacion = 0.02,
			Resplandor = 0.5,
		},
		{
			Hora = 10,
			Ambiente = "6a6e78",
			Exterior = "8c929e",
			Brillo = 2.8,
			Exposicion = 0,
			Tinte = "f4f6ff",
			Contraste = 0.1,
			Saturacion = 0,
			Resplandor = 0.35,
		},
		{
			Hora = 15.5,
			Ambiente = "6a6e78",
			Exterior = "8c929e",
			Brillo = 2.8,
			Exposicion = 0,
			Tinte = "f4f6ff",
			Contraste = 0.1,
			Saturacion = 0,
			Resplandor = 0.35,
		},
		{
			Hora = 17.5,
			Ambiente = "786460",
			Exterior = "b8a090",
			Brillo = 2.4,
			Exposicion = 0.1,
			Tinte = "ffe6d4",
			Contraste = 0.14,
			Saturacion = 0.04,
			Resplandor = 0.6,
		},
		{
			Hora = 18.6,
			Ambiente = "3d4a66",
			Exterior = "6a7ca6",
			Brillo = 1.6,
			Exposicion = 0.35,
			Tinte = "cfdcff",
			Contraste = 0.12,
			Saturacion = 0,
			Resplandor = 0.9,
		},
		{
			Hora = 24,
			Ambiente = "3d4a66",
			Exterior = "6a7ca6",
			Brillo = 1.6,
			Exposicion = 0.35,
			Tinte = "cfdcff",
			Contraste = 0.12,
			Saturacion = 0,
			Resplandor = 0.9,
		},
	},
	-- Velocidades para medir recorridos (studs por segundo).
	VelocidadPie = 16,
	VelocidadVuelo = 80,
}

Config.Efectos = {
	Destello = "rbxassetid://92495499682051",
	Anillo = "rbxassetid://86594022376451",
	Arco = "rbxassetid://73680797455213",
	Humo = "rbxassetid://74115882130548",
	Lineas = "rbxassetid://76247666580830",
	LlamaSuave = "rbxassetid://99334182566198",
	HumoSuave = "rbxassetid://105936420504829",
	TamDestello = 6,
	TamAnillo = 7,
	TamArco = 8,
	TamLineas = 15,
	TamHumo = 9,
	EscalaFuerte = 1.5,
	-- Tope: 150 partículas activas por efecto (Ritmo x Vida de cada capa).
	Fuego = {
		ColorLuz = "#ff8a30",
		LuzRapidez = 9,
		LuzVaria = 0.45,
		Giro = 140,
		EnciendeEn = 7 / 30, -- marcador Enciende de la animación
		BolaEscalaMano = 0.35,
		BolaCrece = 0.28,
		MuroDistancia = 7,
		Bola = {
			Luz = { Brillo = 4, Alcance = 22 },
			Nucleo = {
				Textura = "LlamaSuave",
				Colores = { "#ffffff", "#fff0a0", "#ffc040" },
				Ritmo = 34,
				Vida = { 0.16, 0.26 },
				Rapidez = { 0, 1 },
				Abertura = 180,
				Sube = 0,
				Tam = { 1.6, 3, 1.6 },
				Opacidad = { 0.05, 0.05 },
				Brillo = 0.8,
				Pegado = true,
				Capa = 2,
			},
			Llamas = {
				Textura = "LlamaSuave",
				Colores = { "#ffb030", "#ff6a18", "#c02408" },
				Ritmo = 115,
				Vida = { 0.25, 0.42 },
				Rapidez = { 1, 5 },
				Abertura = 180,
				Sube = 8,
				Tam = { 1.4, 3.2, 0.4 },
				Opacidad = { 0.2, 0.1 },
				Brillo = 0.35,
				Capa = 1,
			},
			Humo = {
				Textura = "HumoSuave",
				Colores = { "#3a2a22", "#1c1a1a" },
				Ritmo = 16,
				Vida = { 0.5, 0.8 },
				Rapidez = { 1, 3 },
				Abertura = 180,
				Sube = 7,
				Tam = { 1.4, 3, 4 },
				Opacidad = { 0.75, 0.55 },
				Brillo = 0,
			},
			Brasas = {
				Colores = { "#fff0b0", "#ff7020" },
				Ritmo = 24,
				Vida = { 0.4, 0.8 },
				Rapidez = { 5, 13 },
				Abertura = 180,
				Sube = 10,
				Tam = { 0.2, 0.2, 0 },
				Opacidad = { 0, 0 },
				Brillo = 1,
				Capa = 2,
			},
		},
		Chorro = {
			Luz = { Brillo = 4, Alcance = 24 },
			Nucleo = {
				Textura = "LlamaSuave",
				Colores = { "#ffffff", "#fff0a0", "#ffb030" },
				Ritmo = 60,
				Vida = { 0.1, 0.18 },
				Rapidez = { 26, 34 },
				Abertura = 7,
				Sube = 0,
				Tam = { 0.7, 1.4, 1 },
				Opacidad = { 0.05, 0.1 },
				Brillo = 0.8,
				Capa = 2,
			},
			Llamas = {
				Textura = "LlamaSuave",
				Colores = { "#ffc040", "#ff6a18", "#b82008" },
				Ritmo = 135,
				Vida = { 0.26, 0.4 },
				Rapidez = { 28, 40 },
				Abertura = 13,
				Sube = 7,
				Tam = { 0.9, 2.6, 3.6 },
				Opacidad = { 0.2, 0.15 },
				Brillo = 0.35,
				Capa = 1,
			},
			Humo = {
				Textura = "HumoSuave",
				Colores = { "#3a2a22", "#1c1a1a" },
				Ritmo = 20,
				Vida = { 0.5, 0.75 },
				Rapidez = { 18, 26 },
				Abertura = 18,
				Sube = 10,
				Tam = { 1.5, 3, 4.5 },
				Opacidad = { 0.8, 0.6 },
				Brillo = 0,
			},
			Brasas = {
				Colores = { "#fff0b0", "#ff7020" },
				Ritmo = 30,
				Vida = { 0.35, 0.6 },
				Rapidez = { 22, 42 },
				Abertura = 24,
				Sube = 6,
				Tam = { 0.2, 0.2, 0 },
				Opacidad = { 0, 0 },
				Brillo = 1,
				Capa = 2,
			},
		},
		Muro = {
			Luz = { Brillo = 4, Alcance = 26 },
			Nucleo = {
				Textura = "LlamaSuave",
				Colores = { "#ffffff", "#fff0a0", "#ffc040" },
				Ritmo = 20,
				Vida = { 0.28, 0.42 },
				Rapidez = { 2, 5 },
				Abertura = 8,
				Sube = 4,
				Tam = { 1.3, 2.2, 0.8 },
				Opacidad = { 0.1, 0.1 },
				Brillo = 0.8,
				Capa = 2,
			},
			Llamas = {
				Textura = "LlamaSuave",
				Colores = { "#ffb030", "#ff6a18", "#b82008" },
				Ritmo = 105,
				Vida = { 0.5, 0.8 },
				Rapidez = { 11, 17 },
				Abertura = 10,
				Sube = 7,
				Tam = { 1.8, 3.6, 0.5 },
				Opacidad = { 0.2, 0.12 },
				Brillo = 0.35,
				Capa = 1,
			},
			Humo = {
				Textura = "HumoSuave",
				Colores = { "#3a2a22", "#1c1a1a" },
				Ritmo = 15,
				Vida = { 0.9, 1.3 },
				Rapidez = { 8, 12 },
				Abertura = 12,
				Sube = 6,
				Tam = { 2, 4, 6 },
				Opacidad = { 0.85, 0.65 },
				Brillo = 0,
			},
			Brasas = {
				Colores = { "#fff0b0", "#ff7020" },
				Ritmo = 20,
				Vida = { 0.7, 1.2 },
				Rapidez = { 7, 15 },
				Abertura = 30,
				Sube = 8,
				Tam = { 0.2, 0.2, 0 },
				Opacidad = { 0, 0 },
				Brillo = 1,
				Capa = 2,
			},
		},
		Explosion = {
			Luz = { Brillo = 6, Alcance = 30 },
			Cantidad = { Nucleo = 14, Llamas = 60, Humo = 18, Brasas = 40 },
			Nucleo = {
				Textura = "LlamaSuave",
				Colores = { "#ffffff", "#fff0a0", "#ffb030" },
				Vida = { 0.14, 0.25 },
				Rapidez = { 4, 12 },
				Abertura = 180,
				Sube = 0,
				Freno = 4,
				Tam = { 2.5, 4.5, 1.5 },
				Opacidad = { 0, 0.1 },
				Brillo = 0.8,
				Capa = 2,
			},
			Llamas = {
				Textura = "LlamaSuave",
				Colores = { "#ffb030", "#ff6a18", "#a81c08" },
				Vida = { 0.28, 0.55 },
				Rapidez = { 14, 34 },
				Abertura = 180,
				Sube = 8,
				Freno = 5,
				Tam = { 2, 4, 0.5 },
				Opacidad = { 0.1, 0.1 },
				Brillo = 0.35,
				Capa = 1,
			},
			Humo = {
				Textura = "HumoSuave",
				Colores = { "#3a2a22", "#1c1a1a" },
				Vida = { 0.7, 1.2 },
				Rapidez = { 6, 16 },
				Abertura = 180,
				Sube = 7,
				Freno = 3,
				Tam = { 2.5, 5, 7 },
				Opacidad = { 0.75, 0.55 },
				Brillo = 0,
			},
			Brasas = {
				Colores = { "#fff0b0", "#ff7020" },
				Vida = { 0.5, 1 },
				Rapidez = { 24, 52 },
				Abertura = 180,
				Sube = -18,
				Freno = 2,
				Tam = { 0.24, 0.24, 0 },
				Opacidad = { 0, 0 },
				Brillo = 1,
				Capa = 2,
			},
		},
	},
}

-- Progresión: cada nivel agranda y refuerza todos los ataques. Se suma a los puntos de la bóveda.
Config.Niveles = {
	Maximo = 100,
	ColorBarra = "#e8b923",
	DanioPorNivel = 0.01, -- nivel 100: doble de daño
	TamanoPorNivel = 0.006, -- nivel 100: 60 % más de tamaño y alcance
	XpBase = 100,
	XpCurva = 1.35,
	XpPorBaja = 60,
}

-- Sonidos del combate (ForgeGUI). Se pueden cambiar por propios.
Config.Sonidos = {
	Variacion = 0.12,
	Golpe = { Id = "rbxassetid://116089304319844", Volumen = 0.7 },
	GolpeFuerte = { Id = "rbxassetid://122802277794974", Volumen = 0.9 },
	Bloqueo = { Id = "rbxassetid://134479353254444", Volumen = 0.7 },
}

return Config
