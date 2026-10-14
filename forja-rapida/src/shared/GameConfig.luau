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
}

export type Gema = {
	Id: string, -- lo que se guarda en la mochila; no cambiarlo una vez publicado
	Nombre: string,
	Zona: number,
	Rareza: string,
	Color: string,
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
	Premio: { Monedas: number?, Suerte: number? },
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
	HojaIconos = "rbxassetid://118396607568499",
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
	} :: { Gema },

	-- Tienda: los picos se compran en orden y siempre usás el mejor.
	Picos = {
		{ Id = "Madera", Nombre = "Pico de Madera", Multiplicador = 1, Precio = 0 },
		{ Id = "Piedra", Nombre = "Pico de Piedra", Multiplicador = 2, Precio = 25 },
		{ Id = "Hierro", Nombre = "Pico de Hierro", Multiplicador = 4, Precio = 5000 },
		{ Id = "Oro", Nombre = "Pico de Oro", Multiplicador = 8, Precio = 250000 },
		{ Id = "Cosmico", Nombre = "Pico Cósmico", Multiplicador = 16, Precio = 8000000 },
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
			Premio = { Suerte = 0.25 },
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
			Premio = { Suerte = 1 },
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
			Premio = { Monedas = 500, Suerte = 0.1 },
		},
		{
			Id = "Coleccion2",
			Nombre = "Colección de las Dunas",
			Descripcion = "Conseguí las 5 gemas de las Dunas de Ámbar",
			Necesita = { Tipo = "Gemas", Zona = 2 },
			Premio = { Monedas = 8000, Suerte = 0.1 },
		},
		{
			Id = "Coleccion3",
			Nombre = "Colección del Glaciar",
			Descripcion = "Conseguí las 5 gemas del Glaciar de Zafiro",
			Necesita = { Tipo = "Gemas", Zona = 3 },
			Premio = { Monedas = 250000, Suerte = 0.15 },
		},
		{
			Id = "Coleccion4",
			Nombre = "Colección del Volcán",
			Descripcion = "Conseguí las 5 gemas del Volcán de Rubí",
			Necesita = { Tipo = "Gemas", Zona = 4 },
			Premio = { Monedas = 4000000, Suerte = 0.2 },
		},
		{
			Id = "Coleccion5",
			Nombre = "Colección del Abismo",
			Descripcion = "Conseguí las 5 gemas del Abismo Estelar",
			Necesita = { Tipo = "Gemas", Zona = 5 },
			Premio = { Monedas = 60000000, Suerte = 0.3 },
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
			Premio = { Suerte = 0.5 },
		},
		{
			Id = "Eventos5",
			Nombre = "Cazador de Eventos",
			Descripcion = "Jugá 5 eventos del mundo",
			Necesita = { Tipo = "Eventos", Cuantos = 5 },
			Premio = { Suerte = 0.15 },
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
	} :: { Titulo },

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

	-- Hoja con los 22 íconos (arte/gui/listas/HojaIconos.png, de arte/scripts/iconos): una sola
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
