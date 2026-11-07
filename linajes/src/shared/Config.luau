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

-- Animaciones de nuestro Animate (src/character/Animate.client.luau).
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
		Quieto = "rbxassetid://99949285202495",
		Caminar = "rbxassetid://76578209242080",
		Correr = "rbxassetid://124891162063727",
		CorrerRapido = "rbxassetid://86379296914238", -- Velocista y Reflejos
		SaltarInicio = "rbxassetid://120016621591002",
		SaltarAire = "rbxassetid://133941918605722",
		SaltarCaer = "rbxassetid://74377813132853",
		Trepar = "rbxassetid://118357290428607",
		VolarQuieto = "rbxassetid://82495017672119",
		VolarAvanzando = "rbxassetid://103610213581729",
		Nadar = "rbxassetid://138733509877221",
		Flotar = "rbxassetid://119656681494266",
		-- Combate con Puños (P26-02). Prioridad Action, sin loop salvo Bloqueo y Aturdido.
		-- Marcador "Impacto" (el daño, el efecto y el sonido salen de ahí): Golpe1 y Golpe2 en el
		-- cuadro 6, Golpe3 en el 8, Golpe4 y GolpeAire en el 12, Parry en el 3.
		Golpe1 = "rbxassetid://133686566945344", -- jab derecho
		Golpe2 = "rbxassetid://122244932851180", -- cross izquierdo
		Golpe3 = "rbxassetid://101680833752326", -- gancho ascendente
		Golpe4 = "rbxassetid://102197700629923", -- patada giratoria
		GolpeAire = "rbxassetid://74369993682946", -- ataque desde arriba
		BloqueoInicio = "rbxassetid://103232878605410",
		Bloqueo = "rbxassetid://84309745016925",
		Parry = "rbxassetid://81961752475488",
		DashAdelante = "rbxassetid://134725239036426",
		DashAtras = "rbxassetid://102925445348654",
		DashIzquierda = "rbxassetid://133824666075643",
		DashDerecha = "rbxassetid://74280413120367",
		GolpeLiviano = "rbxassetid://112287255919817",
		GolpeFuerte = "rbxassetid://130947098767449",
		Aturdido = "rbxassetid://98638901247402",
		Derrota = "rbxassetid://119935981736480",
		Levantarse = "rbxassetid://113046535730775",
	},
	-- Fuerza Bruta (P27-01), hecha con arte/scripts/animaciones/linaje-fuerzabruta.py. Embestida y Cargar
	-- van en piezas: inicio, loop y frenada. Marcadores: Impacto en Puño, GolpePiso y EmbestidaFrenada.
	linaje_fuerzabruta = {
		PunoSismico = "rbxassetid://98115806880348",
		GolpePiso = "rbxassetid://118246801340832",
		EmbestidaInicio = "rbxassetid://111963141629338",
		EmbestidaCarrera = "rbxassetid://82375231487944",
		EmbestidaFrenada = "rbxassetid://76562140317323",
		CargarInicio = "rbxassetid://82574390662886",
		CargarLoop = "rbxassetid://101325236228868",
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
