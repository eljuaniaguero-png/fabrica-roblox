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
		{ Danio = 8, Impacto = 0.27, Espera = 0.45, Empuja = false },
		{ Danio = 8, Impacto = 0.27, Espera = 0.45, Empuja = false },
		{ Danio = 10, Impacto = 0.36, Espera = 0.55, Empuja = false },
		{ Danio = 14, Impacto = 0.53, Espera = 0.8, Empuja = true },
	},
	VelocidadGolpes = 0.75,
	ReinicioCombo = 0.8,
	Alcance = 7.5,
	ConoGolpe = 0.3, -- 1 es justo adelante, 0 es a los costados
	Empuje = 45,
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
	HitStop = 0.05,
	HitStopParry = 0.12,
	Destello = 0.12,
	ManiquiDistancia = 10,
	ManiquiSemilla = 7,
	ManiquiPausa = 3,
	ManiquiAtaca = 9, -- pega si hay un jugador a esta distancia
	ManiquiAviso = 0.6,
	ManiquiDanio = 12,
	ManiquiVuelve = 3,
}

-- Animaciones de nuestro Animate (src/character/Animate.client.luau).
-- Teclas de prueba (client/PruebaTeclas): solo visuales. Apagar antes de publicar.
Config.PruebaTeclas = {
	Activas = true,
	Caminar = 8,
	Correr = 16,
	CorrerRapido = 28,
	Dash = 70,
	DashTiempo = 0.18,
	Embestida = 34,
	PausaCombo = 1.4,
	EsperaCombo = 0.75, -- parte del golpe que tiene que pasar antes del siguiente
	VelocidadCombo = 0.75, -- 1 es la velocidad original
	SaltoAire = 38,
	Cartel = "Click: combo   Q + WASD: dash   F: bloqueo (justo antes del golpe: parry)\nR: salta y martillazo\nShift: correr   Ctrl: rápido   Y: vuelo\nZ: puño sísmico   X: golpe al piso   C: embestida   V: cargar\nReflejos: J contragolpe   K paso fantasma   L lluvia (mantener)   P cargar (mantener)\nPiroquinesis: U bola   I chorro (mantener)   O muro   H cargar (mantener)\n1 saludar  2 celebrar  3 recoger  4 hablar  5 banco\n6 aturdido  7 derrota  8 levantarse  9 recibe liviano  0 recibe fuerte",
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
	-- Velocidades para medir recorridos (studs por segundo).
	VelocidadPie = 16,
	VelocidadVuelo = 80,
}

return Config
