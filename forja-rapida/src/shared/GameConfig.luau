--!strict
-- Números de balance y datos de Forja Rápida (ideas/forja-rapida.md). Todo lo ajustable va acá.
-- Es el Config.luau de este juego. No tiene requires ni tipos de Roblox (los colores van en
-- hex) para que también lo puedan leer las pruebas con Lune (forja-rapida/pruebas).
--
-- Cómo se calcula todo (las fórmulas están en shared/Reglas.luau):
--   Fuerza (daño por golpe) = (Fuerza.Base + nivel x Fuerza.PorNivel) x (1 + Fuerza.Extra) ^ nivel
--                             x multiplicador del pico (redondeado para abajo)
--   Vida de una geoda       = Vida del tamaño x Dureza de la zona
--   Suerte de una geoda     = (1 + suerte de tus amuletos) x Suerte de la zona x Suerte del tamaño
--   Gema que sale           = se tira de la más rara a la más común: cada rareza sale si
--                             azar < Suerte / UnoEn (con Suerte x2, "1 en 400" pasa a "1 en 200")
--   Unidades que te llevás  = Unidades del tamaño x Premio del modificador exótico
--   Monedas al vender       = unidades x Valor de la zona x Valor de la rareza
--   Grupo 4: la Fuerza y las Monedas al vender se multiplican por los bonos del Renacer, del
--   árbol de Esencia y de las mascotas (Reglas.bonos); la suerte les suma lo suyo.

export type Rareza = {
	Id: string,
	Nombre: string,
	UnoEn: number, -- sale 1 vez cada UnoEn con suerte x1 (la común tiene 1: es lo que queda)
	Valor: number, -- multiplica el valor de la zona
	Color: string,
}

export type Modificador = {
	Id: string,
	Nombre: string,
	UnoEn: number, -- probabilidad de que una geoda nazca así (la Normal tiene 1: es lo que queda)
	Premio: number, -- multiplica las unidades de la gema
	Color: string, -- grietas, cristales, brillo y texto del cartel
	Color2: string?, -- combinaciones: color de la segunda grieta
	Partes: { string }?, -- combinaciones: los dos modificadores que junta
	ColorRoca: string?, -- si cambia el color de la roca (si no, el de la zona)
	MaterialRoca: string?, -- nombre de un Enum.Material ("Basalt", "Foil"...)
	Textura: string, -- rbxassetid de la textura de la roca (forja-rapida/arte/texturas); "" = sin
	Sonido: string, -- SONIDO: aura que suena cerca de la geoda; "" = sin sonido
	Anunciar: boolean?, -- avisa a todo el servidor cuando nace una
}

export type Tamano = {
	Id: string,
	Nombre: string,
	Vida: number, -- en la zona 1; se multiplica por la Dureza de cada zona
	Unidades: number, -- gemas que da al romperse (antes del modificador)
	Suerte: number, -- multiplica la suerte del que la rompe
	Escala: number, -- tamaño del modelo (1 = la pequeña)
	Peso: number, -- qué tan seguido aparece en los puntos comunes (el Jefe tiene su propio punto)
	Reaparicion: number, -- segundos hasta que nace otra en el mismo punto
	-- Grupo 3: geodas de zonas ocultas. Con 1 en UnoEnSecreta dan la gema secreta (GemaSecreta, o
	-- la de su zona si no dice) en vez de tirar la rareza.
	UnoEnSecreta: number?,
	GemaSecreta: string?,
}

export type Zona = {
	Numero: number,
	Nombre: string,
	FuerzaParaAbrir: number, -- Fuerza (daño por golpe) que hay que tener; no se gasta
	Dureza: number,
	Valor: number, -- monedas que vale una gema común de esta zona
	Suerte: number,
	ColorRoca: string,
	ColorCristal: string,
	-- Grupo 4: las 3 rocas del bioma (la primera es la de siempre). Cada geoda nace con una al
	-- azar; solo cambia cómo se ve (forma, colores y material), no lo que da.
	Variantes: { Variante },
}

-- Una roca de un bioma (Grupo 4). En Blender: Geodas_Zona<N>.fbx, con los tamaños "Pequena",
-- "Mediana"... (la 1) y "Pequena_2", "Mediana_2"... (las otras; el Jefe usa la forma de la 1).
export type Variante = {
	Id: string,
	Nombre: string, -- se ve en el cartel de la geoda ("Geoda Musgosa")
	ColorRoca: string,
	ColorCristal: string,
	MaterialRoca: string?, -- nombre de un Enum.Material (Slate si no dice)
}

export type Gema = {
	Id: string, -- lo que se guarda en la mochila; no cambiarlo una vez publicado
	Nombre: string,
	Zona: number,
	Rareza: string,
	Color: string,
	Secreta: boolean?, -- Grupo 3: solo sale en vetas ocultas, nunca en una geoda común
	Lugar: string?, -- de dónde sale, si no es el bioma de su zona (el Museo lo muestra)
}

export type Logro = {
	Id: string, -- lo que se guarda; no cambiarlo una vez publicado
	Nombre: string,
	Descripcion: string,
	Necesita: {
		Tipo: string,
		Zona: number?,
		Ids: { string }?,
		Cuantos: number?,
		Id: string?,
		Cuantas: number?,
	},
	Premio: { Monedas: number?, Suerte: number?, Cosmetico: { Tipo: string, Id: string }? },
	-- Grupo 3: las que tienen Museo = true son colecciones y se ven en el Museo, con su dificultad
	-- ("Facil", "Media", "Dificil" o "Leyenda").
	Museo: boolean?,
	Dificultad: string?,
}

-- Grupo 3: cosméticos que se ganan con colecciones del Museo (Premio.Cosmetico).
-- Grupo 4: también las evoluciones del pico (tipo "Efecto"), con logros de progreso,
-- colecciones, misiones, eventos y renacer.
export type Cosmetico = {
	Id: string,
	Nombre: string,
	Colores: { string }, -- aura y decoración: sus colores; pico: { cabeza, mango }; vitrina: { color }
	Material: string?, -- nombre de un Enum.Material (picos y vitrinas)
	-- auras: "Destellos", "Chispas" u "Orbita"; evoluciones del pico: "Metalico", "Cristales",
	-- "Runas", "Fuego", "Rayos" o "Cosmico"
	Forma: string?,
}

-- Grupo 4: una misión posible. Al tocar una, se elige la meta entre Meta[1] y Meta[2] y el
-- Texto se completa con la meta (%d) y, si hace falta, el nombre de la zona o colección (%s).
--   Tipo "Geodas"     romper geodas (Tamano: solo de ese tamaño; EnZona: en tu mejor zona)
--   Tipo "Rareza"     encontrar gemas de esa Rareza o más raras
--   Tipo "Exotica"    romper geodas exóticas
--   Tipo "Jefe"       llevarte gema de una Geoda Jefe o Ancestral
--   Tipo "Accion"     hacer algo en el mapa (Accion: "Altar", "Puerta", "Portal" o "Cofre")
--   Tipo "Nuevo"      encontrar minerales que todavía no tenías en el Museo
--   Tipo "Coleccion"  completar la colección del Museo que tenés más avanzada
-- Necesita: "Secreto" (abriste alguna puerta secreta), "PuertaCerrada" (hay una puerta
-- secreta sin abrir en tus zonas) o "Zona2" (tenés las Dunas). ZonaMinima: tu mejor zona.
export type PlantillaMision = {
	Id: string,
	Tipo: string,
	Dificultad: string, -- "Facil", "Media", "Dificil" o "Prestigio" (desde el primer Renacer)
	Meta: { number },
	Texto: string,
	Tamano: string?,
	Rareza: string?,
	Accion: string?,
	EnZona: boolean?,
	Necesita: string?,
	ZonaMinima: number?,
}

-- Grupo 4: una rama del árbol de Esencia (se compra con la Esencia que da cada Renacer).
--   Bono "Fuerza" / "Monedas": +Valor por nivel (0,05 = +5 %); "Suerte": +Valor a la suerte;
--   "Llaves": las llaves salen Valor más seguido por nivel; "NivelInicial": empezás cada
--   renacer con Valor niveles de Fuerza por nivel; "Lugares": Valor lugares más de mascota.
export type Rama = {
	Id: string,
	Nombre: string,
	Descripcion: string,
	Bono: string,
	Valor: number,
	Costos: { number }, -- Esencia de cada nivel (cuántos hay = cuántos niveles tiene)
	Renacer: number, -- renaceres que hacen falta para que aparezca
}

-- Grupo 4: una mascota de la ruleta. Chance en % (todas suman 100). Solo con Monedas.
export type Mascota = {
	Id: string,
	Nombre: string,
	Rareza: string,
	Chance: number,
	Monedas: number?, -- +% de monedas al vender (0,05 = +5 %)
	Suerte: number?, -- se suma a tu suerte
	Forma: string, -- cómo se arma: "Topo", "Golem", "Zorro", "Tortuga", "Cristal", "Pinguino", "Dragon" o "Gato"
	Colores: { string }, -- { cuerpo, detalle }
}

-- Un evento del mundo (Grupo 6). Lo que no se pone, no cambia.
export type Evento = {
	Id: string,
	Nombre: string,
	Descripcion: string,
	Duracion: number, -- segundos
	Peso: number, -- qué tan seguido sale comparado con los demás
	Color: string,
	Color2: string,
	Modificadores: { [string]: number }?, -- multiplica la chance de nacer con ese modificador
	Unidades: { [string]: number }?, -- multiplica las gemas de las geodas con ese modificador
	UnidadesTodas: number?, -- multiplica las gemas de todas las geodas
	Suerte: number?, -- multiplica la suerte de todas las revelaciones
	Renovar: number?, -- parte de las geodas sanas que vuelven a nacer al empezar (con las chances nuevas)
	Cristales: { Cada: number, Radio: number, Duran: number, Premio: number, Maximo: number }?,
	Meta: { PorJugador: number, Minimo: number, Premio: number }?,
	Jefe: { VidaPorFuerza: number, VidaMinima: number, SuerteModificador: number }?,
}

-- Un título que se muestra arriba de la cabeza y en la vitrina (Grupo 7).
export type Titulo = {
	Id: string,
	Texto: string,
	Colores: { string }, -- degradé del texto (uno solo = color liso)
	Requiere: string?, -- logro que lo desbloquea (nil = lo tiene todo el mundo)
}

export type Pico = {
	Id: string,
	Nombre: string,
	Multiplicador: number,
	Precio: number,
	Color: string, -- color de la cabeza del pico que se ve en la mano (diseño Clásico)
}

-- Una pieza de la interfaz hecha con ForgeGUI (forja-rapida/arte/gui), subida a Roblox.
export type PiezaGui = {
	Imagen: string, -- "rbxassetid://..."; "" = todavía no está y se dibuja con degradés
	Ancho: number, -- píxeles de la imagen subida
	Alto: number,
	Corte: { number }?, -- 9-slice: { x0, y0, x1, y1 } de la parte del medio que se estira
	Escala: number?, -- esquinas fijas (SliceScale) en vez de seguir el alto (ventanas, baldosas)
	Tinte: boolean?, -- la pieza es blanca y el código la pinta del color que haga falta
}

export type Amuleto = {
	Id: string,
	Nombre: string,
	Suerte: number, -- se suma a la suerte del jugador (x1 + esto)
	Precio: number,
}

-- IDs de Roblox de las imágenes de la interfaz (subidas el 14/10/2026 a la cuenta de Juani con la
-- conexión de ForgeGUI; todas aprobadas por moderación).
local IMAGEN = {
	BotonVerde = "rbxassetid://122751560070705",
	BotonAmarillo = "rbxassetid://82270336976559",
	BotonAzul = "rbxassetid://126415985605100",
	BotonRojo = "rbxassetid://93266931408925",
	BotonVioleta = "rbxassetid://107217277631497",
	BotonRosa = "rbxassetid://111544531252348",
	BotonNaranja = "rbxassetid://133433902020830",
	BotonCian = "rbxassetid://103023351608085",
	BotonGris = "rbxassetid://98527090618301",
	BotonBlanco = "rbxassetid://81258172353128",
	PanelOscuro = "rbxassetid://100656619903632",
	HojaIconos = "rbxassetid://110338265885099", -- v2 (Grupo 4: Mascota, Mision, Renacer y Esencia)
}

local GameConfig = {
	-- Golpes. El servidor ignora lo que no cumpla esto (GeodeServerService).
	Golpe = {
		PorSegundo = 8, -- golpes por segundo que se aceptan, sostenidos...
		Rafaga = 4, -- ...con hasta 4 juntos (los paquetes llegan amontonados por la red)
		Alcance = 12, -- studs desde el borde de la geoda hasta el jugador
		-- Si varios le pegan a la misma geoda, cada uno que hizo al menos este porcentaje de su
		-- vida (o el que la rompió) se lleva su propia revelación, con su propia suerte.
		ParteParaPremio = 0.1,
		ParteParaPremioAncestral = 0.02, -- en la Geoda Ancestral alcanza con menos (son muchos)
	},

	-- Mejoras de Fuerza (Tienda). Cada nivel suma Fuerza.PorNivel a la base y además un
	-- Fuerza.Extra (en %) a toda la Fuerza: así alcanza para las zonas, que piden 10 veces más.
	Fuerza = {
		Base = 1,
		PorNivel = 1,
		Extra = 0.025,
		PrecioInicial = 10, -- lo que cuesta el nivel 1
		Crecimiento = 1.12, -- cada nivel cuesta un 12 % más que el anterior
		NivelMaximo = 200,
	},

	-- Revelación: cuánto dura la animación en el cliente antes de que la geoda desaparezca.
	Revelacion = {
		Duracion = 1.6,
	},

	-- Rarezas de las gemas, de la más común a la más rara.
	Rarezas = {
		{ Id = "Comun", Nombre = "Común", UnoEn = 1, Valor = 1, Color = "#B9C2CC" },
		{ Id = "Raro", Nombre = "Raro", UnoEn = 5, Valor = 3, Color = "#3FA9FF" },
		{ Id = "Epico", Nombre = "Épico", UnoEn = 40, Valor = 12, Color = "#B04DFF" },
		{ Id = "Legendario", Nombre = "Legendario", UnoEn = 400, Valor = 60, Color = "#FFB21E" },
		{ Id = "Mitico", Nombre = "Mítico", UnoEn = 5000, Valor = 500, Color = "#FF3D7F" },
	} :: { Rareza },

	-- Modificadores exóticos: con qué aura puede nacer una geoda (no depende del jugador).
	-- Las combinaciones (Grupo 1) juntan dos y son mucho más raras. Van al final porque la lista
	-- tiene que ir de la más común a la más rara (se tira de la más rara para abajo).
	-- Texturas: subir las de forja-rapida/arte/texturas y pegar acá el "rbxassetid://...".
	Modificadores = {
		{
			Id = "Normal",
			Nombre = "Normal",
			UnoEn = 1,
			Premio = 1,
			Color = "#FFFFFF",
			Textura = "",
			Sonido = "",
		},
		{
			Id = "Lava",
			Nombre = "Exótica de Lava",
			UnoEn = 10,
			Premio = 3,
			Color = "#FF6A1A",
			ColorRoca = "#3A2622",
			MaterialRoca = "Basalt",
			Textura = "",
			Sonido = "",
		},
		{
			Id = "Neon",
			Nombre = "Exótica Neón",
			UnoEn = 40,
			Premio = 5,
			Color = "#2EF2FF",
			Textura = "",
			Sonido = "",
		},
		{
			Id = "Midas",
			Nombre = "Exótica Dorada",
			UnoEn = 150,
			Premio = 10,
			Color = "#FFD23F",
			ColorRoca = "#FFC83D",
			MaterialRoca = "Foil",
			Textura = "",
			Sonido = "",
		},
		{
			Id = "Vacio",
			Nombre = "Exótica del Vacío",
			UnoEn = 1000,
			Premio = 25,
			Color = "#9B4DFF",
			ColorRoca = "#140C2B",
			MaterialRoca = "Basalt",
			Textura = "",
			Sonido = "",
			Anunciar = true,
		},
		{
			Id = "LavaNeon",
			Nombre = "Magma Eléctrico",
			UnoEn = 2500,
			Premio = 15,
			Color = "#FF6A1A",
			Color2 = "#2EF2FF",
			Partes = { "Lava", "Neon" },
			ColorRoca = "#3A2622",
			MaterialRoca = "Basalt",
			Textura = "",
			Sonido = "",
			Anunciar = true,
		},
		{
			Id = "MidasNeon",
			Nombre = "Relámpago Dorado",
			UnoEn = 6000,
			Premio = 50,
			Color = "#FFD23F",
			Color2 = "#2EF2FF",
			Partes = { "Midas", "Neon" },
			ColorRoca = "#FFC83D",
			MaterialRoca = "Foil",
			Textura = "",
			Sonido = "",
			Anunciar = true,
		},
		{
			Id = "VacioLava",
			Nombre = "Eclipse de Lava",
			UnoEn = 15000,
			Premio = 75,
			Color = "#9B4DFF",
			Color2 = "#FF6A1A",
			Partes = { "Vacio", "Lava" },
			ColorRoca = "#140C2B",
			MaterialRoca = "Basalt",
			Textura = "",
			Sonido = "",
			Anunciar = true,
		},
		{
			Id = "VacioMidas",
			Nombre = "Vacío Dorado",
			UnoEn = 40000,
			Premio = 250,
			Color = "#9B4DFF",
			Color2 = "#FFD23F",
			Partes = { "Vacio", "Midas" },
			ColorRoca = "#140C2B",
			MaterialRoca = "Basalt",
			Textura = "",
			Sonido = "",
			Anunciar = true,
		},
	} :: { Modificador },

	-- Tamaños de geoda. Las grandes rinden un poco menos por golpe pero dan más suerte.
	Tamanos = {
		{
			Id = "Pequena",
			Nombre = "Geoda Pequeña",
			Vida = 10,
			Unidades = 1,
			Suerte = 1,
			Escala = 1,
			Peso = 65,
			Reaparicion = 3,
		},
		{
			Id = "Mediana",
			Nombre = "Geoda Mediana",
			Vida = 35,
			Unidades = 3,
			Suerte = 1.25,
			Escala = 1.5,
			Peso = 28,
			Reaparicion = 4,
		},
		{
			Id = "Gigante",
			Nombre = "Geoda Gigante",
			Vida = 130,
			Unidades = 10,
			Suerte = 1.6,
			Escala = 2.3,
			Peso = 7,
			Reaparicion = 6,
		},
		{
			Id = "Jefe",
			Nombre = "GEODA JEFE",
			Vida = 1500,
			Unidades = 80,
			Suerte = 3,
			Escala = 4,
			Peso = 0, -- solo nace en los puntos marcados como Jefe
			Reaparicion = 90,
		},
		{
			-- Solo lo trae el evento "Jefe Ancestral": su vida depende de cuántos juegan y la gema
			-- sale de la mejor zona de cada jugador (así le sirve a todos).
			Id = "Ancestral",
			Nombre = "GEODA ANCESTRAL",
			Vida = 3000, -- mínimo; ver GameConfig.Eventos (Jefe.VidaPorFuerza)
			Unidades = 150,
			Suerte = 5,
			Escala = 6,
			Peso = 0,
			Reaparicion = 0, -- no vuelve a nacer
		},
		-- Grupo 3: solo nacen en los puntos que lo dicen (atributo Tamano del punto)
		{
			Id = "Oculta",
			Nombre = "Geoda Oculta",
			Vida = 60,
			Unidades = 4,
			Suerte = 2,
			Escala = 1.6,
			Peso = 0,
			Reaparicion = 25,
			UnoEnSecreta = 6, -- la gema secreta de su zona
		},
		{
			Id = "Prisma",
			Nombre = "Geoda Prismática",
			Vida = 90,
			Unidades = 6,
			Suerte = 3,
			Escala = 1.9,
			Peso = 0,
			Reaparicion = 30,
			UnoEnSecreta = 8,
			GemaSecreta = "Prismita",
		},
		-- Grupo 4: solo en el Santuario del Renacer (puntos con Renacer = 1). Como la Ancestral,
		-- la gema sale de la mejor zona de cada uno; su vida sigue al más fuerte de los que ya
		-- renacieron (GameConfig.Renacer.GolpesRenacida) y a veces suelta Esencia.
		{
			Id = "Renacida",
			Nombre = "Geoda Renacida",
			Vida = 400, -- mínimo
			Unidades = 12,
			Suerte = 2,
			Escala = 2.3,
			Peso = 0,
			Reaparicion = 20,
		},
	} :: { Tamano },

	-- Biomas, en orden. La zona 1 está abierta desde el principio.
	-- Ritmo medido con `lune run forja-rapida/pruebas/simular` (4 golpes por segundo, sin
	-- parar): Pico de Piedra 1:10, zona 2 a los 2 min, zona 3 a los 12, zona 4 a los 32,
	-- zona 5 a la hora y cuarto y la Corona Cósmica a las 2 h 10 (detalle en la ficha).
	Zonas = {
		{
			Numero = 1,
			Nombre = "Pradera de Cuarzo",
			FuerzaParaAbrir = 0,
			Dureza = 1,
			Valor = 1,
			Suerte = 1,
			ColorRoca = "#6E7487",
			ColorCristal = "#C77DFF",
			Variantes = {
				{
					Id = "Cuarzo",
					Nombre = "Cuarzo",
					ColorRoca = "#6E7487",
					ColorCristal = "#C77DFF",
				},
				{
					Id = "Musgosa",
					Nombre = "Musgosa",
					ColorRoca = "#5E8C4A",
					ColorCristal = "#FF8FD8",
				},
				{
					Id = "Caliza",
					Nombre = "Caliza",
					ColorRoca = "#D8D2C0",
					ColorCristal = "#7CF5FF",
					MaterialRoca = "Limestone",
				},
			},
		},
		{
			Numero = 2,
			Nombre = "Dunas de Ámbar",
			FuerzaParaAbrir = 25,
			Dureza = 8,
			Valor = 10,
			Suerte = 1.5,
			ColorRoca = "#B07A4A",
			ColorCristal = "#FFB627",
			Variantes = {
				{
					Id = "Ambar",
					Nombre = "de Ámbar",
					ColorRoca = "#B07A4A",
					ColorCristal = "#FFB627",
					MaterialRoca = "Sandstone",
				},
				{
					Id = "AreniscaRoja",
					Nombre = "de Arenisca Roja",
					ColorRoca = "#C4553A",
					ColorCristal = "#FFE14D",
					MaterialRoca = "Sandstone",
				},
				{
					Id = "Desertica",
					Nombre = "Desértica",
					ColorRoca = "#E8C98A",
					ColorCristal = "#FF8C42",
					MaterialRoca = "Sand",
				},
			},
		},
		{
			Numero = 3,
			Nombre = "Glaciar de Zafiro",
			FuerzaParaAbrir = 700,
			Dureza = 120,
			Valor = 300,
			Suerte = 2.5,
			ColorRoca = "#7FA6C9",
			ColorCristal = "#3D7BFF",
			Variantes = {
				{
					Id = "Zafiro",
					Nombre = "de Zafiro",
					ColorRoca = "#7FA6C9",
					ColorCristal = "#3D7BFF",
				},
				{
					Id = "Escarcha",
					Nombre = "de Escarcha",
					ColorRoca = "#E8F4FF",
					ColorCristal = "#7CF5FF",
					MaterialRoca = "Glacier",
				},
				{
					Id = "GlaciarProfundo",
					Nombre = "de Glaciar Profundo",
					ColorRoca = "#2F5D8A",
					ColorCristal = "#B8F3FF",
				},
			},
		},
		{
			Numero = 4,
			Nombre = "Volcán de Rubí",
			FuerzaParaAbrir = 6000,
			Dureza = 1100,
			Valor = 4000,
			Suerte = 4,
			ColorRoca = "#4A3338",
			ColorCristal = "#FF2E4D",
			Variantes = {
				{
					Id = "Rubi",
					Nombre = "de Rubí",
					ColorRoca = "#4A3338",
					ColorCristal = "#FF2E4D",
					MaterialRoca = "Basalt",
				},
				{
					Id = "Obsidiana",
					Nombre = "de Obsidiana",
					ColorRoca = "#1E1A24",
					ColorCristal = "#FF7A00",
					MaterialRoca = "Basalt",
				},
				{
					Id = "Azufre",
					Nombre = "de Azufre",
					ColorRoca = "#6B5A2E",
					ColorCristal = "#F5FF4D",
				},
			},
		},
		{
			Numero = 5,
			Nombre = "Abismo Estelar",
			FuerzaParaAbrir = 40000,
			Dureza = 8000,
			Valor = 50000,
			Suerte = 7,
			ColorRoca = "#2E2A5C",
			ColorCristal = "#7CF5FF",
			Variantes = {
				{
					Id = "Estelar",
					Nombre = "Estelar",
					ColorRoca = "#2E2A5C",
					ColorCristal = "#7CF5FF",
				},
				{
					Id = "Nebulosa",
					Nombre = "Nebulosa",
					ColorRoca = "#4B2A6B",
					ColorCristal = "#FF6FD8",
				},
				{
					Id = "Meteorito",
					Nombre = "Meteorito",
					ColorRoca = "#3B3B3B",
					ColorCristal = "#FFB347",
					MaterialRoca = "Basalt",
				},
			},
		},
	} :: { Zona },

	-- Las 25 gemas del Índice: 5 por zona, una por rareza.
	Gemas = {
		{ Id = "Cuarzo", Nombre = "Cuarzo", Zona = 1, Rareza = "Comun", Color = "#E8E3F5" },
		{ Id = "Jaspe", Nombre = "Jaspe", Zona = 1, Rareza = "Raro", Color = "#D9534F" },
		{ Id = "Amatista", Nombre = "Amatista", Zona = 1, Rareza = "Epico", Color = "#A45CFF" },
		{
			Id = "Esmeralda",
			Nombre = "Esmeralda",
			Zona = 1,
			Rareza = "Legendario",
			Color = "#22D07A",
		},
		{
			Id = "CorazonPradera",
			Nombre = "Corazón de la Pradera",
			Zona = 1,
			Rareza = "Mitico",
			Color = "#9DFF3C",
		},

		{ Id = "Ambar", Nombre = "Ámbar", Zona = 2, Rareza = "Comun", Color = "#F2A33A" },
		{ Id = "Citrino", Nombre = "Citrino", Zona = 2, Rareza = "Raro", Color = "#FFD84A" },
		{ Id = "Topacio", Nombre = "Topacio", Zona = 2, Rareza = "Epico", Color = "#FF8C42" },
		{
			Id = "OjoTigre",
			Nombre = "Ojo de Tigre",
			Zona = 2,
			Rareza = "Legendario",
			Color = "#C9852B",
		},
		{
			Id = "SolDunas",
			Nombre = "Sol de las Dunas",
			Zona = 2,
			Rareza = "Mitico",
			Color = "#FFF15C",
		},

		{
			Id = "CristalHielo",
			Nombre = "Cristal de Hielo",
			Zona = 3,
			Rareza = "Comun",
			Color = "#DDF4FF",
		},
		{ Id = "Aguamarina", Nombre = "Aguamarina", Zona = 3, Rareza = "Raro", Color = "#5FE3D6" },
		{ Id = "Zafiro", Nombre = "Zafiro", Zona = 3, Rareza = "Epico", Color = "#2F5BFF" },
		{
			Id = "DiamanteAzul",
			Nombre = "Diamante Azul",
			Zona = 3,
			Rareza = "Legendario",
			Color = "#8FD3FF",
		},
		{
			Id = "LagrimaGlaciar",
			Nombre = "Lágrima del Glaciar",
			Zona = 3,
			Rareza = "Mitico",
			Color = "#B8FFFF",
		},

		{ Id = "Obsidiana", Nombre = "Obsidiana", Zona = 4, Rareza = "Comun", Color = "#3A3340" },
		{ Id = "Granate", Nombre = "Granate", Zona = 4, Rareza = "Raro", Color = "#A3203A" },
		{ Id = "Rubi", Nombre = "Rubí", Zona = 4, Rareza = "Epico", Color = "#FF2E4D" },
		{
			Id = "OpaloFuego",
			Nombre = "Ópalo de Fuego",
			Zona = 4,
			Rareza = "Legendario",
			Color = "#FF7A1F",
		},
		{
			Id = "CorazonVolcan",
			Nombre = "Corazón del Volcán",
			Zona = 4,
			Rareza = "Mitico",
			Color = "#FFE14D",
		},

		{ Id = "Meteorita", Nombre = "Meteorita", Zona = 5, Rareza = "Comun", Color = "#7D7A8C" },
		{
			Id = "OpaloNegro",
			Nombre = "Ópalo Negro",
			Zona = 5,
			Rareza = "Raro",
			Color = "#3D2E6B",
		},
		{
			Id = "CuarzoEstelar",
			Nombre = "Cuarzo Estelar",
			Zona = 5,
			Rareza = "Epico",
			Color = "#7CF5FF",
		},
		{
			Id = "Nebulita",
			Nombre = "Nebulita",
			Zona = 5,
			Rareza = "Legendario",
			Color = "#FF5CE1",
		},
		{
			Id = "NucleoGalactico",
			Nombre = "Núcleo Galáctico",
			Zona = 5,
			Rareza = "Mitico",
			Color = "#FFFFFF",
		},

		-- Grupo 3: minerales de las vetas ocultas (uno por bioma, detrás de su puerta secreta) y
		-- el de la Dimensión Prisma. No salen en las geodas comunes.
		{
			Id = "CuarzoLunar",
			Nombre = "Cuarzo Lunar",
			Zona = 1,
			Rareza = "Legendario",
			Color = "#CFE8FF",
			Secreta = true,
		},
		{
			Id = "AmbarFosil",
			Nombre = "Ámbar Fósil",
			Zona = 2,
			Rareza = "Legendario",
			Color = "#FF9F1C",
			Secreta = true,
		},
		{
			Id = "ZafiroBoreal",
			Nombre = "Zafiro Boreal",
			Zona = 3,
			Rareza = "Legendario",
			Color = "#6BE4FF",
			Secreta = true,
		},
		{
			Id = "RubiMagma",
			Nombre = "Rubí de Magma",
			Zona = 4,
			Rareza = "Mitico",
			Color = "#FF3B1F",
			Secreta = true,
		},
		{
			Id = "OpaloEstelar",
			Nombre = "Ópalo Estelar",
			Zona = 5,
			Rareza = "Mitico",
			Color = "#E9B8FF",
			Secreta = true,
		},
		{
			Id = "Prismita",
			Nombre = "Prismita",
			Zona = 2,
			Rareza = "Mitico",
			Color = "#9CFBFF",
			Secreta = true,
			Lugar = "Dimensión Prisma",
		},
	} :: { Gema },

	-- Tienda: los picos se compran en orden y siempre usás el mejor.
	Picos = {
		{
			Id = "Madera",
			Nombre = "Pico de Madera",
			Multiplicador = 1,
			Precio = 0,
			Color = "#C08A4E",
		},
		{
			Id = "Piedra",
			Nombre = "Pico de Piedra",
			Multiplicador = 2,
			Precio = 25,
			Color = "#8D939C",
		},
		{
			Id = "Hierro",
			Nombre = "Pico de Hierro",
			Multiplicador = 4,
			Precio = 5000,
			Color = "#D8DEE6",
		},
		{
			Id = "Oro",
			Nombre = "Pico de Oro",
			Multiplicador = 8,
			Precio = 250000,
			Color = "#FFC83D",
		},
		{
			Id = "Cosmico",
			Nombre = "Pico Cósmico",
			Multiplicador = 16,
			Precio = 8000000,
			Color = "#9B6BFF",
		},
	} :: { Pico },

	-- Tienda: los amuletos también van en orden y se suman (con los 5: suerte x9,75).
	Amuletos = {
		{ Id = "Trebol", Nombre = "Trébol de Hierro", Suerte = 0.25, Precio = 300 },
		{ Id = "Herradura", Nombre = "Herradura de Cobre", Suerte = 0.5, Precio = 20000 },
		{ Id = "Estrella", Nombre = "Estrella Fugaz", Suerte = 1, Precio = 1500000 },
		{ Id = "Dragon", Nombre = "Ojo de Dragón", Suerte = 2, Precio = 60000000 },
		{ Id = "Corona", Nombre = "Corona Cósmica", Suerte = 5, Precio = 3000000000 },
	} :: { Amuleto },

	-- Logros y colecciones (Grupo 1, "descubrimiento en cadena"). Se cobran una sola vez: el
	-- servidor anota cada uno en los datos del jugador antes de dar el premio.
	-- Necesita:
	--   { Tipo = "Gemas", Zona = n }            todas las gemas de esa zona en el Índice
	--   { Tipo = "Modificadores", Ids = {...}, Cuantos = n }   romper geodas de n de esos modificadores
	--   { Tipo = "Rareza", Id = "Mitico" }      encontrar una gema de esa rareza
	--   { Tipo = "Geodas", Cuantas = n }         romper n geodas en total
	--   { Tipo = "Jefes", Cuantos = n }          ayudar a romper n Geodas Ancestrales
	--   { Tipo = "Eventos", Cuantos = n }        jugar n eventos (romper al menos una geoda durante)
	-- Grupo 4:
	--   { Tipo = "Pico", Cuantos = n }           tener el pico número n (3 = Hierro, 5 = Cósmico)
	--   { Tipo = "Colecciones", Cuantas = n }    completar n colecciones del Museo
	--   { Tipo = "Misiones", Cuantas = n }       cumplir n misiones
	--   { Tipo = "Renacer", Cuantos = n }        renacer n veces
	-- Premio: Monedas (una vez) y/o Suerte (se suma para siempre a la del jugador).
	Logros = {
		{
			Id = "Picapiedras",
			Nombre = "Picapiedras",
			Descripcion = "Rompé 100 geodas",
			Necesita = { Tipo = "Geodas", Cuantas = 100 },
			Premio = { Monedas = 300 },
		},
		{
			Id = "PrimeraExotica",
			Nombre = "¡Brilla!",
			Descripcion = "Rompé tu primera geoda exótica",
			Necesita = {
				Tipo = "Modificadores",
				Ids = {
					"Lava",
					"Neon",
					"Midas",
					"Vacio",
					"LavaNeon",
					"MidasNeon",
					"VacioLava",
					"VacioMidas",
				},
				Cuantos = 1,
			},
			Premio = { Monedas = 200 },
		},
		{
			Id = "ColeccionExotica",
			Nombre = "Coleccionista Exótico",
			Descripcion = "Rompé una geoda de Lava, una Neón, una Dorada y una del Vacío",
			Necesita = {
				Tipo = "Modificadores",
				Ids = { "Lava", "Neon", "Midas", "Vacio" },
				Cuantos = 4,
			},
			Premio = { Suerte = 0.25, Cosmetico = { Tipo = "Decoracion", Id = "Llamas" } },
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "PrimeraCombinacion",
			Nombre = "¡Doble Exótica!",
			Descripcion = "Rompé una geoda con dos modificadores",
			Necesita = {
				Tipo = "Modificadores",
				Ids = { "LavaNeon", "MidasNeon", "VacioLava", "VacioMidas" },
				Cuantos = 1,
			},
			Premio = { Suerte = 0.25 },
		},
		{
			Id = "ColeccionCombinaciones",
			Nombre = "Maestro de las Combinaciones",
			Descripcion = "Rompé las 4 combinaciones exóticas",
			Necesita = {
				Tipo = "Modificadores",
				Ids = { "LavaNeon", "MidasNeon", "VacioLava", "VacioMidas" },
				Cuantos = 4,
			},
			Premio = { Suerte = 1, Cosmetico = { Tipo = "Aura", Id = "Arcoiris" } },
			Museo = true,
			Dificultad = "Leyenda",
		},
		{
			Id = "Legendaria",
			Nombre = "Leyenda",
			Descripcion = "Encontrá una gema Legendaria",
			Necesita = { Tipo = "Rareza", Id = "Legendario" },
			Premio = { Monedas = 1000 },
		},
		{
			Id = "Mitica",
			Nombre = "¡Mítico!",
			Descripcion = "Encontrá una gema Mítica",
			Necesita = { Tipo = "Rareza", Id = "Mitico" },
			Premio = { Suerte = 0.2 },
		},
		{
			Id = "MineroImparable",
			Nombre = "Minero Imparable",
			Descripcion = "Rompé 2.000 geodas",
			Necesita = { Tipo = "Geodas", Cuantas = 2000 },
			Premio = { Suerte = 0.15 },
		},
		{
			Id = "Coleccion1",
			Nombre = "Colección de la Pradera",
			Descripcion = "Conseguí las 5 gemas de la Pradera de Cuarzo",
			Necesita = { Tipo = "Gemas", Zona = 1 },
			Premio = { Monedas = 500, Suerte = 0.1, Cosmetico = { Tipo = "Aura", Id = "Cuarzo" } },
			Museo = true,
			Dificultad = "Facil",
		},
		{
			Id = "Coleccion2",
			Nombre = "Colección de las Dunas",
			Descripcion = "Conseguí las 5 gemas de las Dunas de Ámbar",
			Necesita = { Tipo = "Gemas", Zona = 2 },
			Premio = { Monedas = 8000, Suerte = 0.1, Cosmetico = { Tipo = "Pico", Id = "Ambar" } },
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "Coleccion3",
			Nombre = "Colección del Glaciar",
			Descripcion = "Conseguí las 5 gemas del Glaciar de Zafiro",
			Necesita = { Tipo = "Gemas", Zona = 3 },
			Premio = {
				Monedas = 250000,
				Suerte = 0.15,
				Cosmetico = { Tipo = "Vitrina", Id = "Hielo" },
			},
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "Coleccion4",
			Nombre = "Colección del Volcán",
			Descripcion = "Conseguí las 5 gemas del Volcán de Rubí",
			Necesita = { Tipo = "Gemas", Zona = 4 },
			Premio = {
				Monedas = 4000000,
				Suerte = 0.2,
				Cosmetico = { Tipo = "Aura", Id = "Magma" },
			},
			Museo = true,
			Dificultad = "Dificil",
		},
		{
			Id = "Coleccion5",
			Nombre = "Colección del Abismo",
			Descripcion = "Conseguí las 5 gemas del Abismo Estelar",
			Necesita = { Tipo = "Gemas", Zona = 5 },
			Premio = {
				Monedas = 60000000,
				Suerte = 0.3,
				Cosmetico = { Tipo = "Pico", Id = "Estelar" },
			},
			Museo = true,
			Dificultad = "Leyenda",
		},
		{
			Id = "JefeAncestral1",
			Nombre = "Cazador de Jefes",
			Descripcion = "Ayudá a romper una Geoda Ancestral",
			Necesita = { Tipo = "Jefes", Cuantos = 1 },
			Premio = { Suerte = 0.2 },
		},
		{
			Id = "JefeAncestral10",
			Nombre = "Leyenda de los Jefes",
			Descripcion = "Ayudá a romper 10 Geodas Ancestrales",
			Necesita = { Tipo = "Jefes", Cuantos = 10 },
			Premio = { Suerte = 0.5, Cosmetico = { Tipo = "Efecto", Id = "Rayos" } },
		},
		{
			Id = "Eventos5",
			Nombre = "Cazador de Eventos",
			Descripcion = "Jugá 5 eventos del mundo",
			Necesita = { Tipo = "Eventos", Cuantos = 5 },
			Premio = { Suerte = 0.15, Cosmetico = { Tipo = "Efecto", Id = "Fuego" } },
		},

		-- Grupo 3: colecciones del Museo de minerales (de fáciles a difíciles)
		{
			Id = "Museo3",
			Nombre = "Primeros Hallazgos",
			Descripcion = "Encontrá 3 minerales distintos",
			Necesita = { Tipo = "Distintas", Cuantas = 3 },
			Premio = { Monedas = 50 },
			Museo = true,
			Dificultad = "Facil",
		},
		{
			Id = "PraderaBrillante",
			Nombre = "Pradera Brillante",
			Descripcion = "Encontrá Cuarzo, Jaspe y Amatista",
			Necesita = { Tipo = "Lista", Ids = { "Cuarzo", "Jaspe", "Amatista" } },
			Premio = { Monedas = 150, Cosmetico = { Tipo = "Decoracion", Id = "Flores" } },
			Museo = true,
			Dificultad = "Facil",
		},
		{
			Id = "Museo10",
			Nombre = "Museo en Marcha",
			Descripcion = "Encontrá 10 minerales distintos",
			Necesita = { Tipo = "Distintas", Cuantas = 10 },
			Premio = { Monedas = 2000, Cosmetico = { Tipo = "Decoracion", Id = "Cristalitos" } },
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "CazaRarezas",
			Nombre = "Cazarrarezas",
			Descripcion = "Encontrá un mineral Raro, uno Épico y uno Legendario",
			Necesita = { Tipo = "Rarezas", Ids = { "Raro", "Epico", "Legendario" } },
			Premio = { Monedas = 1500 },
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "PrimerSecreto",
			Nombre = "Explorador",
			Descripcion = "Encontrá un mineral secreto en una veta oculta",
			Necesita = { Tipo = "Secretas", Cuantas = 1 },
			Premio = { Suerte = 0.1, Cosmetico = { Tipo = "Aura", Id = "Arcana" } },
			Museo = true,
			Dificultad = "Media",
		},
		{
			Id = "SecretasTodas",
			Nombre = "Guardián de Secretos",
			Descripcion = "Encontrá los 6 minerales secretos",
			Necesita = { Tipo = "Secretas", Cuantas = 6 },
			Premio = { Suerte = 0.3, Cosmetico = { Tipo = "Vitrina", Id = "Arcana" } },
			Museo = true,
			Dificultad = "Dificil",
		},
		{
			Id = "MuseoCompleto",
			Nombre = "Curador Legendario",
			Descripcion = "Completá el Museo: los 31 minerales",
			Necesita = { Tipo = "Distintas", Cuantas = 31 },
			Premio = { Suerte = 0.5, Cosmetico = { Tipo = "Vitrina", Id = "Dorada" } },
			Museo = true,
			Dificultad = "Leyenda",
		},
		-- Grupo 4: evoluciones del pico, misiones y renacer
		{
			Id = "Forjador",
			Nombre = "Forjador",
			Descripcion = "Conseguí el Pico de Hierro",
			Necesita = { Tipo = "Pico", Cuantos = 3 },
			Premio = { Monedas = 500, Cosmetico = { Tipo = "Efecto", Id = "Metalico" } },
		},
		{
			Id = "ForjaCosmica",
			Nombre = "Forja Cósmica",
			Descripcion = "Conseguí el Pico Cósmico",
			Necesita = { Tipo = "Pico", Cuantos = 5 },
			Premio = { Suerte = 0.2, Cosmetico = { Tipo = "Efecto", Id = "Cosmico" } },
		},
		{
			Id = "BrilloInterior",
			Nombre = "Brillo Interior",
			Descripcion = "Completá 4 colecciones del Museo",
			Necesita = { Tipo = "Colecciones", Cuantas = 4 },
			Premio = { Suerte = 0.1, Cosmetico = { Tipo = "Efecto", Id = "Cristales" } },
		},
		{
			Id = "Misiones3",
			Nombre = "Manos a la Obra",
			Descripcion = "Cumplí 3 misiones",
			Necesita = { Tipo = "Misiones", Cuantas = 3 },
			Premio = { Monedas = 150 },
		},
		{
			Id = "Misiones10",
			Nombre = "Aprendiz de Runas",
			Descripcion = "Cumplí 10 misiones",
			Necesita = { Tipo = "Misiones", Cuantas = 10 },
			Premio = { Suerte = 0.1, Cosmetico = { Tipo = "Efecto", Id = "Runas" } },
		},
		{
			Id = "Misiones40",
			Nombre = "Maestro de Misiones",
			Descripcion = "Cumplí 40 misiones",
			Necesita = { Tipo = "Misiones", Cuantas = 40 },
			Premio = { Suerte = 0.25 },
		},
		{
			Id = "Renacer1",
			Nombre = "Renacido",
			Descripcion = "Renacé por primera vez",
			Necesita = { Tipo = "Renacer", Cuantos = 1 },
			Premio = { Cosmetico = { Tipo = "Aura", Id = "Renacer" } },
		},
		{
			Id = "Renacer2",
			Nombre = "Ave Fénix",
			Descripcion = "Renacé 2 veces",
			Necesita = { Tipo = "Renacer", Cuantos = 2 },
			Premio = { Cosmetico = { Tipo = "Efecto", Id = "Fenix" } },
		},
		{
			Id = "Renacer3",
			Nombre = "Leyenda Renacida",
			Descripcion = "Renacé 3 veces",
			Necesita = { Tipo = "Renacer", Cuantos = 3 },
			Premio = { Cosmetico = { Tipo = "Vitrina", Id = "Renacida" } },
		},
		{
			Id = "Renacer5",
			Nombre = "Eterno",
			Descripcion = "Renacé 5 veces",
			Necesita = { Tipo = "Renacer", Cuantos = 5 },
			Premio = { Cosmetico = { Tipo = "Efecto", Id = "Eclipse" } },
		},
	} :: { Logro },

	-- Avisos a todo el servidor: cuando nace una geoda con Anunciar = true y cuando alguien
	-- encuentra una gema de esta rareza o más.
	-- Para no saturar: como mucho uno cada Minimo segundos y Cola esperando (los demás se
	-- descartan). No van al chat: son carteles. Cada jugador puede no anunciar sus hallazgos y
	-- no ver los de los demás (Ajustes); los avisos de eventos se ven siempre.
	Anuncios = {
		RarezaMinima = "Mitico",
		Minimo = 6,
		Cola = 4,
	},

	-- Luz pedida por Juani: ColorCorrection en Lighting.
	Luz = {
		Brillo = 0.05,
		Contraste = 0.15,
		Saturacion = 0.1,
		Color = "#FFFFFF",
	},

	-- Eventos del mundo (Grupo 6). Uno por vez: se anuncia AvisoPrevio segundos antes, dura su
	-- Duracion y después hay una pausa al azar entre Intervalo[1] e Intervalo[2] segundos.
	-- Para probar en Studio: poné el atributo ForzarEvento (texto, el Id) en Workspace.
	Eventos = {
		Activos = true,
		PrimeraEspera = 240,
		Intervalo = { 420, 720 },
		AvisoPrevio = 20,
		Lista = {
			{
				Id = "LluviaCristales",
				Nombre = "Lluvia de Cristales",
				Descripcion = "¡Caen cristales del cielo! Agarralos antes de que se apaguen",
				Duracion = 90,
				Peso = 30,
				Color = "#7CF5FF",
				Color2 = "#C77DFF",
				-- un cristal cerca de cada jugador cada Cada segundos; vale Premio veces una gema
				-- común de su mejor zona
				Cristales = { Cada = 2.5, Radio = 30, Duran = 12, Premio = 25, Maximo = 60 },
			},
			{
				Id = "Erupcion",
				Nombre = "Erupción Volcánica",
				Descripcion = "Las geodas de Lava salen 4 veces más y dan el doble",
				Duracion = 120,
				Peso = 22,
				Color = "#FF6A1A",
				Color2 = "#FFE14D",
				Modificadores = { Lava = 4, LavaNeon = 3, VacioLava = 3 },
				Unidades = { Lava = 2, LavaNeon = 2, VacioLava = 2 },
				Renovar = 0.35,
			},
			{
				Id = "TormentaNeon",
				Nombre = "Tormenta Neón",
				Descripcion = "Rayos de colores: las geodas Neón salen 4 veces más y dan el doble",
				Duracion = 120,
				Peso = 22,
				Color = "#2EF2FF",
				Color2 = "#FF4DF0",
				Modificadores = { Neon = 4, LavaNeon = 3, MidasNeon = 3 },
				Unidades = { Neon = 2, LavaNeon = 2, MidasNeon = 2 },
				Renovar = 0.35,
			},
			{
				Id = "EclipseVacio",
				Nombre = "Eclipse del Vacío",
				Descripcion = "Se oscurece todo: más geodas del Vacío y +50 % de suerte",
				Duracion = 90,
				Peso = 10,
				Color = "#9B4DFF",
				Color2 = "#140C2B",
				Modificadores = { Vacio = 6, VacioLava = 4, VacioMidas = 4 },
				Suerte = 1.5,
				Renovar = 0.25,
			},
			{
				Id = "FiebreMineria",
				Nombre = "Fiebre de Minería",
				Descripcion = "¡Entre todos! Lleguen a la meta de geodas y todos ganan. Cada geoda da x1,5",
				Duracion = 150,
				Peso = 18,
				Color = "#FFC93C",
				Color2 = "#FF8C42",
				UnidadesTodas = 1.5,
				-- meta = PorJugador x jugadores (como mínimo Minimo); premio = Premio veces una
				-- gema común de la mejor zona de cada uno, para los que rompieron al menos una
				Meta = { PorJugador = 40, Minimo = 60, Premio = 60 },
			},
			{
				Id = "JefeAncestral",
				Nombre = "Jefe Ancestral",
				Descripcion = "Una geoda gigante y antiquísima: ¡rómpanla entre todos antes de que se vaya!",
				Duracion = 180,
				Peso = 12,
				Color = "#FFD23F",
				Color2 = "#9B4DFF",
				-- vida = suma de la Fuerza de los que están jugando x VidaPorFuerza (como mínimo
				-- VidaMinima); su modificador se tira con esta suerte (casi siempre exótico)
				Jefe = { VidaPorFuerza = 250, VidaMinima = 3000, SuerteModificador = 30 },
			},
		} :: { Evento },
	},

	-- Exhibición social (Grupo 7).
	Social = {
		Hallazgos = 5, -- mejores hallazgos que se guardan de cada jugador (por lo raros)
		-- Clasificaciones semanales (OrderedDataStore, la semana empieza el lunes 00:00 UTC).
		-- Solo reconocimiento: no hay premios, así nadie se siente obligado a competir.
		Clasificacion = {
			Almacen = "ForjaSemana",
			Guardar = 60, -- cada cuánto se suben los puntos de cada jugador
			Leer = 120, -- cada cuánto se actualizan los tableros
			Cuantos = 10,
			Tablas = {
				{ Id = "Geodas", Nombre = "Geodas rotas" },
				{ Id = "Exoticas", Nombre = "Exóticas rotas" },
				{ Id = "Jefes", Nombre = "Jefes Ancestrales" },
				{ Id = "Hallazgo", Nombre = "Hallazgo más raro" },
			},
		},
	},

	-- Títulos: se desbloquean con logros y se eligen (arriba de la cabeza y en la vitrina).
	Titulos = {
		{ Id = "Novato", Texto = "Minero Novato", Colores = { "#FFFFFF", "#B9C2CC" } },
		{
			Id = "Picapiedras",
			Texto = "Picapiedras",
			Colores = { "#FFD84A", "#F5A300" },
			Requiere = "Picapiedras",
		},
		{
			Id = "CazaExoticas",
			Texto = "Cazador de Exóticas",
			Colores = { "#FF6A1A", "#2EF2FF" },
			Requiere = "PrimeraExotica",
		},
		{
			Id = "Coleccionista",
			Texto = "Coleccionista Exótico",
			Colores = { "#FF6A1A", "#2EF2FF", "#FFD23F", "#9B4DFF" },
			Requiere = "ColeccionExotica",
		},
		{
			Id = "Combinador",
			Texto = "Maestro de Combinaciones",
			Colores = { "#FF4D5E", "#FFC93C", "#4CD964", "#2EF2FF", "#9B4DFF" },
			Requiere = "ColeccionCombinaciones",
		},
		{
			Id = "Leyenda",
			Texto = "Leyenda",
			Colores = { "#FFB21E", "#FFF15C" },
			Requiere = "Legendaria",
		},
		{
			Id = "Mitico",
			Texto = "Toque Mítico",
			Colores = { "#FF3D7F", "#B04DFF" },
			Requiere = "Mitica",
		},
		{
			Id = "CazaJefes",
			Texto = "Cazador de Jefes",
			Colores = { "#FFD23F", "#9B4DFF" },
			Requiere = "JefeAncestral1",
		},
		{
			Id = "LeyendaJefes",
			Texto = "Leyenda de los Jefes",
			Colores = { "#FFF15C", "#FF3D7F", "#9B4DFF" },
			Requiere = "JefeAncestral10",
		},
		{
			Id = "CazaEventos",
			Texto = "Cazador de Eventos",
			Colores = { "#7CF5FF", "#C77DFF" },
			Requiere = "Eventos5",
		},
		{
			Id = "Imparable",
			Texto = "Minero Imparable",
			Colores = { "#FF4D5E", "#FF9B3D" },
			Requiere = "MineroImparable",
		},
		-- Grupo 3
		{
			Id = "Curioso",
			Texto = "Curioso",
			Colores = { "#B8FF6A", "#22A83A" },
			Requiere = "Museo3",
		},
		{
			Id = "Cazarrarezas",
			Texto = "Cazarrarezas",
			Colores = { "#8FD3FF", "#D9A8FF", "#FFE45C" },
			Requiere = "CazaRarezas",
		},
		{
			Id = "Explorador",
			Texto = "Explorador",
			Colores = { "#9CFBFF", "#9B4DFF" },
			Requiere = "PrimerSecreto",
		},
		{
			Id = "GuardianSecretos",
			Texto = "Guardián de Secretos",
			Colores = { "#2E2A5C", "#9CFBFF", "#9B4DFF" },
			Requiere = "SecretasTodas",
		},
		{
			Id = "Curador",
			Texto = "Curador Legendario",
			Colores = { "#FFF3B0", "#FFC83D", "#FF9ED8" },
			Requiere = "MuseoCompleto",
		},
		-- Grupo 4
		{
			Id = "MaestroMisiones",
			Texto = "Maestro de Misiones",
			Colores = { "#B8FF6A", "#2DBA2D" },
			Requiere = "Misiones40",
		},
		{
			Id = "Renacido",
			Texto = "Renacido",
			Colores = { "#FFF3B0", "#FFD23F", "#FF6A3D" },
			Requiere = "Renacer1",
		},
		{
			Id = "LeyendaRenacida",
			Texto = "Leyenda Renacida",
			Colores = { "#FFD23F", "#FF6A3D", "#C2185B" },
			Requiere = "Renacer3",
		},
		{
			Id = "Eterno",
			Texto = "Eterno",
			Colores = { "#1B1030", "#FF6FD8", "#7CF5FF" },
			Requiere = "Renacer5",
		},
	} :: { Titulo },

	-- Grupo 3: cosméticos que dan las colecciones del Museo. Se eligen en el Museo; los ven todos.
	-- Los "Clasico"/"Clasica" los tiene todo el mundo.
	Cosmeticos = {
		Auras = {
			{
				Id = "Cuarzo",
				Nombre = "Destellos de Cuarzo",
				Colores = { "#FFFFFF", "#C77DFF" },
				Forma = "Destellos",
			},
			{
				Id = "Magma",
				Nombre = "Chispas de Magma",
				Colores = { "#FFE14D", "#FF3B1F" },
				Forma = "Chispas",
			},
			{
				Id = "Arcana",
				Nombre = "Runas Arcanas",
				Colores = { "#9CFBFF", "#9B4DFF" },
				Forma = "Orbita",
			},
			{
				Id = "Arcoiris",
				Nombre = "Arcoíris",
				Colores = { "#FF4D5E", "#FFC93C", "#4CD964", "#2EF2FF", "#9B4DFF" },
				Forma = "Destellos",
			},
			{
				Id = "Renacer",
				Nombre = "Llamas del Renacer",
				Colores = { "#FFD23F", "#FF6A3D" },
				Forma = "Orbita",
			},
		} :: { Cosmetico },
		-- Diseños del pico que se ve en la mano: { cabeza, mango }. El Clásico usa el color del
		-- pico que tenés comprado.
		Picos = {
			{ Id = "Clasico", Nombre = "Clásico", Colores = {}, Material = "Metal" },
			{
				Id = "Ambar",
				Nombre = "Pico de Ámbar",
				Colores = { "#FFB627", "#6B3E1A" },
				Material = "Glass",
			},
			{
				Id = "Estelar",
				Nombre = "Pico Estelar",
				Colores = { "#7CF5FF", "#2E2A5C" },
				Material = "Neon",
			},
		} :: { Cosmetico },
		Vitrinas = {
			{
				Id = "Clasica",
				Nombre = "Clásica",
				Colores = { "#2A2F4F" },
				Material = "SmoothPlastic",
			},
			{
				Id = "Hielo",
				Nombre = "Vitrina de Hielo",
				Colores = { "#A8E6FF" },
				Material = "Ice",
			},
			{
				Id = "Arcana",
				Nombre = "Vitrina Arcana",
				Colores = { "#5A2BD9" },
				Material = "Glass",
			},
			{
				Id = "Dorada",
				Nombre = "Vitrina Dorada",
				Colores = { "#FFC83D" },
				Material = "Foil",
			},
			{
				Id = "Renacida",
				Nombre = "Vitrina Renacida",
				Colores = { "#FFF3E0" },
				Material = "Marble",
			},
		} :: { Cosmetico },
		Decoraciones = {
			{ Id = "Flores", Nombre = "Flores", Colores = { "#FF6FB5", "#FFE14D", "#7ED957" } },
			{ Id = "Cristalitos", Nombre = "Cristalitos", Colores = { "#C77DFF", "#7CF5FF" } },
			{ Id = "Llamas", Nombre = "Llamitas", Colores = { "#FFB300", "#FF3B1F" } },
		} :: { Cosmetico },
		-- Grupo 4: evoluciones del pico. Solo se ven (partículas, estelas y brillos en la cabeza
		-- del pico que tenés en la mano): nunca cambian la Fuerza, que sale del pico comprado.
		Efectos = {
			{
				Id = "Metalico",
				Nombre = "Brillo Metálico",
				Colores = { "#E8EEF5", "#FFFFFF" },
				Forma = "Metalico",
			},
			{
				Id = "Cristales",
				Nombre = "Cristales Luminosos",
				Colores = { "#C77DFF", "#7CF5FF" },
				Forma = "Cristales",
			},
			{
				Id = "Runas",
				Nombre = "Runas Mágicas",
				Colores = { "#9CFBFF", "#9B4DFF" },
				Forma = "Runas",
			},
			{
				Id = "Fuego",
				Nombre = "Estela de Fuego",
				Colores = { "#FFE14D", "#FF3B1F" },
				Forma = "Fuego",
			},
			{
				Id = "Rayos",
				Nombre = "Descargas Eléctricas",
				Colores = { "#E6FBFF", "#2EC8FF" },
				Forma = "Rayos",
			},
			{
				Id = "Cosmico",
				Nombre = "Energía Cósmica",
				Colores = { "#7CF5FF", "#B04DFF" },
				Forma = "Cosmico",
			},
			{
				Id = "Fenix",
				Nombre = "Fénix",
				Colores = { "#FFD23F", "#FF6A3D" },
				Forma = "Fuego",
			},
			{
				Id = "Eclipse",
				Nombre = "Eclipse",
				Colores = { "#FF6FD8", "#1B1030" },
				Forma = "Cosmico",
			},
		} :: { Cosmetico },
	},

	-- Grupo 3: secretos del mapa. Nada de esto hace falta para avanzar.
	Secretos = {
		-- Al romper una geoda, chance de encontrar la llave de su bioma (si no abriste todavía su
		-- puerta secreta y no la tenés ya).
		LlaveUnoEn = 35,
		-- El cofre de cada cámara se abre una vez y da esto x el valor de una gema común del bioma.
		CofreMonedas = 120,
		-- Altar: ofrecés gemas comunes del bioma y te da una bendición de suerte por un rato.
		Altar = { Gemas = 5, Suerte = 1.5, Duracion = 180, Espera = 600 },
		-- Lo que susurra cada altar (una pista para la puerta secreta de su bioma).
		Pistas = {
			"«Detrás de la cascada de cristal, la roca no es roca.»",
			"«Donde la duna más alta da sombra, una pared respira.»",
			"«Entre los picos de hielo, una grieta guarda calor.»",
			"«Bajo el río de lava, la piedra está hueca.»",
			"«Donde no llegan las estrellas, hay una puerta.»",
		},
		PortalEspera = 3, -- segundos entre dos viajes por un portal
		Distancia = 14, -- studs: lo más lejos que se puede usar un cofre, altar, puerta o portal
	},

	-- Grupo 4: misiones dinámicas. Siempre hay una Fácil, una Media y una Difícil; desde el
	-- primer Renacer, también una de Prestigio. Se siguen solas y se pagan solas al cumplirse.
	-- Premio en monedas = Monedas de la dificultad x lo que vale una gema común de tu mejor
	-- zona (así sirve igual en la Pradera que en el Abismo).
	Misiones = {
		Lugares = { "Facil", "Media", "Dificil" },
		LugarPrestigio = "Prestigio",
		Dificultades = {
			Facil = { Nombre = "Fácil", Color = "Verde", Monedas = 40, Esencia = 0 },
			Media = { Nombre = "Media", Color = "Amarillo", Monedas = 150, Esencia = 0 },
			Dificil = { Nombre = "Difícil", Color = "Rojo", Monedas = 500, Esencia = 0 },
			Prestigio = { Nombre = "Prestigio", Color = "Naranja", Monedas = 800, Esencia = 1 },
		} :: {
			[string]: { Nombre: string, Color: string, Monedas: number, Esencia: number },
		},
		Cambiar = 90, -- segundos entre dos cambios de misión (gratis)
		Espera = 2, -- segundos hasta que aparece la misión nueva
		Plantillas = {
			-- Fáciles
			{
				Id = "Geodas",
				Tipo = "Geodas",
				Dificultad = "Facil",
				Meta = { 15, 25 },
				Texto = "Rompé %d geodas",
			},
			{
				Id = "GeodasZona",
				Tipo = "Geodas",
				Dificultad = "Facil",
				Meta = { 10, 15 },
				EnZona = true,
				Texto = "Rompé %d geodas en %s",
			},
			{
				Id = "Raras",
				Tipo = "Rareza",
				Rareza = "Raro",
				Dificultad = "Facil",
				Meta = { 3, 5 },
				Texto = "Encontrá %d gemas Raras o mejores",
			},
			-- Medias
			{
				Id = "Medianas",
				Tipo = "Geodas",
				Tamano = "Mediana",
				Dificultad = "Media",
				Meta = { 8, 12 },
				Texto = "Rompé %d Geodas Medianas",
			},
			{
				Id = "Epica",
				Tipo = "Rareza",
				Rareza = "Epico",
				Dificultad = "Media",
				Meta = { 1, 2 },
				Texto = "Encontrá %d gemas Épicas o mejores",
			},
			{
				Id = "Exotica",
				Tipo = "Exotica",
				Dificultad = "Media",
				Meta = { 1, 1 },
				Texto = "Rompé %d geoda exótica",
			},
			{
				Id = "Jefe",
				Tipo = "Jefe",
				Dificultad = "Media",
				Meta = { 1, 1 },
				Texto = "Llevate gema de %d Geoda Jefe",
			},
			{
				Id = "Altar",
				Tipo = "Accion",
				Accion = "Altar",
				Dificultad = "Media",
				Meta = { 1, 1 },
				Texto = "Hacé %d ofrenda en un altar",
			},
			{
				Id = "Nuevo",
				Tipo = "Nuevo",
				Dificultad = "Media",
				Meta = { 1, 1 },
				Texto = "Descubrí %d mineral nuevo para el Museo",
			},
			{
				Id = "Portal",
				Tipo = "Accion",
				Accion = "Portal",
				Dificultad = "Media",
				Meta = { 1, 1 },
				Necesita = "Zona2",
				Texto = "Cruzá %d vez el portal de las Dunas",
			},
			-- Difíciles
			{
				Id = "Gigantes",
				Tipo = "Geodas",
				Tamano = "Gigante",
				Dificultad = "Dificil",
				Meta = { 3, 5 },
				Texto = "Rompé %d Geodas Gigantes",
			},
			{
				Id = "Legendaria",
				Tipo = "Rareza",
				Rareza = "Legendario",
				Dificultad = "Dificil",
				Meta = { 1, 1 },
				ZonaMinima = 2,
				Texto = "Encontrá %d gema Legendaria o mejor",
			},
			{
				Id = "Exoticas",
				Tipo = "Exotica",
				Dificultad = "Dificil",
				Meta = { 3, 4 },
				Texto = "Rompé %d geodas exóticas",
			},
			{
				Id = "Jefes",
				Tipo = "Jefe",
				Dificultad = "Dificil",
				Meta = { 2, 2 },
				Texto = "Llevate gema de %d Geodas Jefe",
			},
			{
				Id = "Coleccion",
				Tipo = "Coleccion",
				Dificultad = "Dificil",
				Meta = { 1, 1 },
				Texto = "Completá la colección %s",
			},
			{
				Id = "Ocultas",
				Tipo = "Geodas",
				Tamano = "Oculta",
				Dificultad = "Dificil",
				Meta = { 2, 3 },
				Necesita = "Secreto",
				Texto = "Rompé %d Geodas Ocultas en una cámara secreta",
			},
			{
				Id = "Puerta",
				Tipo = "Accion",
				Accion = "Puerta",
				Dificultad = "Dificil",
				Meta = { 1, 1 },
				Necesita = "PuertaCerrada",
				Texto = "Encontrá una llave y abrí %d puerta secreta",
			},
			-- Prestigio (desde el primer Renacer): más largas, dan Esencia
			{
				Id = "PGeodas",
				Tipo = "Geodas",
				Dificultad = "Prestigio",
				Meta = { 200, 300 },
				Texto = "Rompé %d geodas",
			},
			{
				Id = "PLegendarias",
				Tipo = "Rareza",
				Rareza = "Legendario",
				Dificultad = "Prestigio",
				Meta = { 2, 3 },
				Texto = "Encontrá %d gemas Legendarias o mejores",
			},
			{
				Id = "PRenacidas",
				Tipo = "Geodas",
				Tamano = "Renacida",
				Dificultad = "Prestigio",
				Meta = { 5, 8 },
				Texto = "Rompé %d Geodas Renacidas en el Santuario",
			},
			{
				Id = "PJefes",
				Tipo = "Jefe",
				Dificultad = "Prestigio",
				Meta = { 3, 3 },
				Texto = "Llevate gema de %d Geodas Jefe",
			},
			{
				Id = "PExoticas",
				Tipo = "Exotica",
				Dificultad = "Prestigio",
				Meta = { 8, 10 },
				Texto = "Rompé %d geodas exóticas",
			},
		} :: { PlantillaMision },
	},

	-- Grupo 4: Renacer (prestigio). Reinicia una parte del progreso a cambio de Esencia y bonos
	-- que no se pierden nunca. Cada renacer desbloquea algo (Desbloqueos y los logros Renacer*).
	Renacer = {
		-- Zona que hay que tener abierta para el renacer número n (del 3° en adelante, la última).
		Requisito = { 3, 4, 5 },
		-- Esencia que da: tu mejor zona menos 1 (Glaciar = 2, Abismo = 4).
		EsenciaPorZona = 1,
		-- Bonos permanentes por cada renacer (cuentan hasta MaximoBonos renaceres).
		BonoMonedas = 0.1, -- +10 % de monedas al vender
		BonoFuerza = 0.05, -- +5 % de Fuerza
		MaximoBonos = 10,
		-- Geoda Renacida: su vida es la Fuerza del más fuerte que ya renació x esto (~golpes).
		GolpesRenacida = 20,
		EsenciaUnoEn = 25, -- chance de que una Geoda Renacida suelte 1 de Esencia
		Reinicia = {
			"Monedas",
			"Niveles de Fuerza",
			"Picos (volvés al de Madera)",
			"Amuletos",
			"Zonas abiertas",
			"Gemas sin vender",
		},
		Conserva = {
			"Museo, colecciones y logros (con su suerte)",
			"Títulos, cosméticos y evoluciones del pico",
			"Mascotas",
			"Puertas secretas abiertas y llaves",
			"Esencia y ramas del árbol",
			"Récords, vitrina y misiones cumplidas",
		},
		-- Lo que estrena cada renacer (se muestra en el menú).
		Desbloqueos = {
			{
				"Una cuarta misión: Prestigio (da Esencia)",
				"El Santuario del Renacer y sus Geodas Renacidas",
				"El árbol de Esencia: Golpe Firme, Mercader y Buen Ojo",
				"Aura Llamas del Renacer y el título Renacido",
			},
			{ "Evolución del pico: Fénix", "Ramas nuevas: Rastreador e Inicio Rápido" },
			{ "Vitrina Renacida y el título Leyenda Renacida" },
			{ "Rama nueva: Domador (más lugares de mascota)" },
			{ "Evolución del pico: Eclipse y el título Eterno" },
		},
		Ramas = {
			{
				Id = "Golpe",
				Nombre = "Golpe Firme",
				Descripcion = "+5 % de Fuerza por nivel",
				Bono = "Fuerza",
				Valor = 0.05,
				Costos = { 1, 2, 3, 4, 5 },
				Renacer = 1,
			},
			{
				Id = "Mercader",
				Nombre = "Mercader",
				Descripcion = "+8 % de monedas al vender por nivel",
				Bono = "Monedas",
				Valor = 0.08,
				Costos = { 1, 2, 3, 4, 5 },
				Renacer = 1,
			},
			{
				Id = "Ojo",
				Nombre = "Buen Ojo",
				Descripcion = "+0,05 de suerte por nivel",
				Bono = "Suerte",
				Valor = 0.05,
				Costos = { 1, 2, 3, 4, 5 },
				Renacer = 1,
			},
			{
				Id = "Rastreador",
				Nombre = "Rastreador",
				Descripcion = "Las llaves salen 25 % más seguido por nivel",
				Bono = "Llaves",
				Valor = 0.25,
				Costos = { 2, 3, 4 },
				Renacer = 2,
			},
			{
				Id = "Impulso",
				Nombre = "Inicio Rápido",
				Descripcion = "Empezás cada renacer con 5 niveles de Fuerza más por nivel",
				Bono = "NivelInicial",
				Valor = 5,
				Costos = { 1, 2, 3, 4 },
				Renacer = 2,
			},
			{
				Id = "Domador",
				Nombre = "Domador",
				Descripcion = "+1 lugar de mascota por nivel",
				Bono = "Lugares",
				Valor = 1,
				Costos = { 3, 5 },
				Renacer = 4,
			},
		} :: { Rama },
	},

	-- Grupo 4: mascotas. Salen en la Ruleta de Mascotas de la plaza, que se paga solo con
	-- Monedas del juego (las Monedas no se venden por Robux: ideas/monetizacion.md). Cada tirada
	-- da una mascota y las chances se ven siempre en el menú (suman 100 %).
	Mascotas = {
		Lugares = 3, -- mascotas que te acompañan a la vez (la rama Domador suma)
		Ruleta = {
			Precio = 150, -- x lo que vale una gema común de tu mejor zona
			Espera = 3, -- segundos entre dos tiradas (lo que dura la ruleta girando)
		},
		Lista = {
			{
				Id = "Topito",
				Nombre = "Topito",
				Rareza = "Comun",
				Chance = 30,
				Monedas = 0.05,
				Forma = "Topo",
				Colores = { "#8A5A2B", "#FFB3C7" },
			},
			{
				Id = "Piedrin",
				Nombre = "Piedrín",
				Rareza = "Comun",
				Chance = 30,
				Suerte = 0.05,
				Forma = "Golem",
				Colores = { "#8D939C", "#7CF5FF" },
			},
			{
				Id = "Chispa",
				Nombre = "Chispa",
				Rareza = "Raro",
				Chance = 14,
				Monedas = 0.1,
				Forma = "Zorro",
				Colores = { "#FF8C42", "#FFF3E0" },
			},
			{
				Id = "Musgo",
				Nombre = "Musgo",
				Rareza = "Raro",
				Chance = 14,
				Suerte = 0.1,
				Forma = "Tortuga",
				Colores = { "#5E8C4A", "#B07A4A" },
			},
			{
				Id = "Cuarcito",
				Nombre = "Cuarcito",
				Rareza = "Epico",
				Chance = 4.5,
				Monedas = 0.2,
				Forma = "Cristal",
				Colores = { "#C77DFF", "#FFFFFF" },
			},
			{
				Id = "Glaciel",
				Nombre = "Glaciel",
				Rareza = "Epico",
				Chance = 4.5,
				Suerte = 0.2,
				Forma = "Pinguino",
				Colores = { "#2F5D8A", "#E8F4FF" },
			},
			{
				Id = "Magmo",
				Nombre = "Magmo",
				Rareza = "Legendario",
				Chance = 2.6,
				Monedas = 0.35,
				Suerte = 0.2,
				Forma = "Dragon",
				Colores = { "#FF3B1F", "#FFE14D" },
			},
			{
				Id = "Nebula",
				Nombre = "Nébula",
				Rareza = "Mitico",
				Chance = 0.4,
				Monedas = 0.6,
				Suerte = 0.5,
				Forma = "Gato",
				Colores = { "#4B2A6B", "#7CF5FF" },
			},
		} :: { Mascota },
	},

	-- Íconos de la UI (imágenes, no emojis), hechos con ForgeGUI (forja-rapida/arte/gui; los
	-- dibujos de respaldo están en arte/iconos). Pegar acá el "rbxassetid://..." de cada uno.
	-- Mientras estén vacíos, el cliente dibuja una insignia de color.
	Iconos = {
		Lava = "",
		Neon = "",
		Midas = "",
		Vacio = "",
		Trebol = "",
		Moneda = "",
		Fuerza = "",
		Chispa = "",
		Trofeo = "",
		Corona = "",
		Reloj = "",
		Jefe = "",
		Cristal = "",
		Gema = "",
		-- HUD y menús
		Tienda = "",
		Mochila = "",
		Libro = "", -- Índice
		Engranaje = "", -- Ajustes
		Banco = "",
		Pico = "",
		Candado = "",
		Amuleto = "",
		-- Grupo 4
		Mascota = "",
		Mision = "",
		Renacer = "",
		Esencia = "",
	},

	-- Piezas de la interfaz (forja-rapida/arte/gui/listas, armadas por arte/scripts/gui.py a
	-- partir de los botones de ForgeGUI). Mientras una Imagen esté vacía, el cliente la dibuja
	-- con degradés y bordes, así el juego anda igual. Corte = 9-slice (las esquinas no se
	-- estiran); Escala = esquinas fijas; Tinte = pieza blanca que el código pinta.
	Gui = {
		BotonVerde = {
			Imagen = IMAGEN.BotonVerde,
			Ancho = 525,
			Alto = 160,
			Corte = { 51, 64, 474, 96 },
		},
		BotonAmarillo = {
			Imagen = IMAGEN.BotonAmarillo,
			Ancho = 514,
			Alto = 160,
			Corte = { 51, 64, 463, 96 },
		},
		BotonAzul = {
			Imagen = IMAGEN.BotonAzul,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
		},
		BotonRojo = {
			Imagen = IMAGEN.BotonRojo,
			Ancho = 464,
			Alto = 160,
			Corte = { 51, 64, 413, 96 },
		},
		BotonVioleta = {
			Imagen = IMAGEN.BotonVioleta,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
		},
		BotonRosa = {
			Imagen = IMAGEN.BotonRosa,
			Ancho = 464,
			Alto = 160,
			Corte = { 51, 64, 413, 96 },
		},
		BotonNaranja = {
			Imagen = IMAGEN.BotonNaranja,
			Ancho = 514,
			Alto = 160,
			Corte = { 51, 64, 463, 96 },
		},
		BotonCian = {
			Imagen = IMAGEN.BotonCian,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
		},
		BotonGris = {
			Imagen = IMAGEN.BotonGris,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
		},
		BotonBlanco = {
			Imagen = IMAGEN.BotonBlanco,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Tinte = true,
		},
		Cabecera = {
			Imagen = IMAGEN.BotonBlanco,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Tinte = true,
		},
		Pildora = {
			Imagen = IMAGEN.BotonBlanco,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Tinte = true,
		},
		BarraRelleno = {
			Imagen = IMAGEN.BotonBlanco,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Tinte = true,
		},
		Baldosa = {
			Imagen = IMAGEN.BotonBlanco,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Escala = 0.42,
			Tinte = true,
		},
		Panel = {
			Imagen = IMAGEN.PanelOscuro,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
			Escala = 0.55,
		},
		BarraFondo = {
			Imagen = IMAGEN.PanelOscuro,
			Ancho = 472,
			Alto = 160,
			Corte = { 51, 64, 421, 96 },
		},
		-- Todavía dibujadas (hacen falta créditos de ForgeGUI): la X, el globito y el marco dorado.
		Cerrar = { Imagen = "", Ancho = 256, Alto = 256 },
		Globito = { Imagen = "", Ancho = 128, Alto = 128 },
		MarcoDestacado = { Imagen = "", Ancho = 1024, Alto = 220, Corte = { 120, 80, 904, 140 } },
	} :: { [string]: PiezaGui },

	-- Hoja con los 26 íconos (arte/gui/listas/HojaIconos.png, de arte/scripts/iconos): una sola
	-- imagen para todos, cada uno en su celda. Un ícono puesto en Iconos tiene prioridad.
	HojaIconos = {
		Imagen = IMAGEN.HojaIconos,
		Celda = 128,
		Lugar = {
			Moneda = { 0, 0 },
			Fuerza = { 128, 0 },
			Trebol = { 256, 0 },
			Lava = { 384, 0 },
			Neon = { 512, 0 },
			Midas = { 640, 0 },
			Vacio = { 0, 128 },
			Chispa = { 128, 128 },
			Trofeo = { 256, 128 },
			Corona = { 384, 128 },
			Reloj = { 512, 128 },
			Jefe = { 640, 128 },
			Cristal = { 0, 256 },
			Gema = { 128, 256 },
			Tienda = { 256, 256 },
			Mochila = { 384, 256 },
			Libro = { 512, 256 },
			Engranaje = { 640, 256 },
			Banco = { 0, 384 },
			Pico = { 128, 384 },
			Candado = { 256, 384 },
			Amuleto = { 384, 384 },
			Mascota = { 512, 384 },
			Mision = { 640, 384 },
			Renacer = { 0, 512 },
			Esencia = { 128, 512 },
		} :: { [string]: { number } },
	},

	-- Efectos del cliente (Grupo 1, pulido). Con "Efectos reducidos" (botón en pantalla, o solo
	-- si la calidad gráfica de Roblox está en 3 o menos) no hay destello blanco ni temblor de
	-- cámara, hay menos partículas y las auras se ven solo de cerca.
	Efectos = {
		DistanciaAura = 90, -- studs: más lejos, la geoda no anima ni tira partículas
		DistanciaAuraReducida = 40,
		CalidadParaReducir = 3, -- calidad gráfica de Roblox (1 a 10) con la que arranca reducido
		TemblorCamara = 0.6, -- studs que se mueve la cámara al revelar una rara
		DuracionRevelacion = 2.2, -- segundos que se muestra la gema (rara o mejor)
		DuracionComun = 0.9, -- la común solo salta un cartelito
		DestelloDesde = "Raro", -- rareza desde la que hay destello blanco y temblor
		NumerosMaximos = 12, -- números flotantes a la vez
	},

	-- Sonidos (los usa el cliente; cada uso está marcado con "-- SONIDO:"). Vacíos = sin sonido.
	-- Para cambiar el tono de un mismo sample se usa PlaybackSpeed (CLAUDE.md, Audio).
	Sonidos = {
		Golpe = "",
		Romper = "",
		Revelacion = "", -- se sube el tono según la rareza
		RevelacionRara = "", -- extra para Épica o mejor
		Logro = "",
		Anuncio = "",
		EventoEmpieza = "", -- uno por evento estaría bueno; por ahora el mismo con otro tono
		Cristal = "", -- agarrar un cristal de la lluvia
		Trueno = "", -- relámpago de la Tormenta Neón
		JefeAparece = "",
		Vender = "",
		Comprar = "",
		Click = "", -- tocar un botón de la interfaz
		AbrirMenu = "",
		Secreto = "", -- Grupo 3: abrir una puerta secreta, un cofre, un altar o cruzar un portal
		-- Grupo 4
		Mision = "", -- misión cumplida
		Ruleta = "", -- cada "tic" de la ruleta (se sube el tono al frenar)
		Mascota = "", -- mascota nueva
		Renacer = "",
	},

	-- Modelos de Blender (forja-rapida/arte). Mientras no estén, el servidor arma las geodas con
	-- partes simples (greybox). Al importarlas, los modelos van en ServerStorage > Modelos >
	-- Geodas > <Id del tamaño>, con las partes Roca, Cristales, Base, Grietas y Grietas2; y el
	-- anillo de la Lava en ReplicatedStorage > Modelos > Anillo (si no está, el cliente lo arma
	-- con cubitos). Eventos y vitrinas: ServerStorage > Modelos > CristalLluvia (una parte),
	-- Geodas > Ancestral (como las demás geodas) y Estatuas > <rareza> (la gema grande).
	Modelos = {
		Carpeta = "Modelos",
	},
}

return GameConfig
