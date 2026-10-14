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
	Color: string, -- color del brillo y del texto del cartel
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

export type Pico = {
	Id: string,
	Nombre: string,
	Multiplicador: number,
	Precio: number,
}

export type Amuleto = {
	Id: string,
	Nombre: string,
	Suerte: number, -- se suma a la suerte del jugador (x1 + esto)
	Precio: number,
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
	Modificadores = {
		{ Id = "Normal", Nombre = "Normal", UnoEn = 1, Premio = 1, Color = "#FFFFFF" },
		{ Id = "Lava", Nombre = "Exótica de Lava", UnoEn = 10, Premio = 3, Color = "#FF6A1A" },
		{ Id = "Neon", Nombre = "Exótica Neón", UnoEn = 40, Premio = 5, Color = "#2EF2FF" },
		{ Id = "Midas", Nombre = "Exótica Dorada", UnoEn = 150, Premio = 10, Color = "#FFD23F" },
		{
			Id = "Vacio",
			Nombre = "Exótica del Vacío",
			UnoEn = 1000,
			Premio = 25,
			Color = "#9B4DFF",
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
			ColorRoca = "#3B2A2F",
			ColorCristal = "#FF2E4D",
		},
		{
			Numero = 5,
			Nombre = "Abismo Estelar",
			FuerzaParaAbrir = 40000,
			Dureza = 8000,
			Valor = 50000,
			Suerte = 7,
			ColorRoca = "#26224A",
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

	-- Sonidos (los usa el cliente; cada uso está marcado con "-- SONIDO:"). Vacíos = sin sonido.
	-- Para cambiar el tono de un mismo sample se usa PlaybackSpeed (CLAUDE.md, Audio).
	Sonidos = {
		Golpe = "",
		Romper = "",
		Revelacion = "",
		Vender = "",
		Comprar = "",
	},

	-- Modelos de Blender (forja-rapida/arte). Mientras estén vacíos, el servidor arma las
	-- geodas con partes simples (greybox). Al importarlas, los modelos van en
	-- ServerStorage > Modelos > Geodas > <Id del tamaño>, con las partes Roca, Cristales y Base.
	Modelos = {
		Carpeta = "Modelos",
	},
}

return GameConfig
