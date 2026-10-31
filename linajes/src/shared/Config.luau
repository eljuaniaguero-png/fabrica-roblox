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

-- Animaciones de nuestro Animate. Por ahora son las de base de Roblox para R15 (el mismo
-- esqueleto); se cambian por las nuestras cuando estén hechas en Blender (arte/animaciones/).
Config.Animaciones = {
	Quieto = "rbxassetid://507766388",
	Caminar = "rbxassetid://507777826",
	Correr = "rbxassetid://507767714",
	Saltar = "rbxassetid://507765000",
	Caer = "rbxassetid://507767968",
	Trepar = "rbxassetid://507765644",
	VelocidadCorrer = 12, -- studs/s: desde acá pasa de caminar a correr
}

return Config
