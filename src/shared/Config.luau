--!strict
-- Números de balance del juego. Todo lo ajustable va acá.

export type Consumible = {
	Nombre: string,
	Precio: number,
	Descripcion: string,
	Usable: boolean, -- false = se usa solo (como el Escudo)
	Duracion: number?,
	Factor: number?,
}

export type Mejora = {
	Nombre: string,
	Descripcion: string,
	PrecioBase: number,
	FactorPrecio: number, -- cada nivel cuesta esto por el anterior
	NivelMaximo: number,
	BonusPorNivel: number,
}

local consumibles: { [string]: Consumible } = {
	DoblePaso = {
		Nombre = "Doble paso",
		Precio = 60,
		Descripcion = "Cada paso vale doble por 30 s",
		Usable = true,
		Duracion = 30,
		Factor = 2,
	},
	Escudo = {
		Nombre = "Escudo",
		Precio = 50,
		Descripcion = "Te perdona una caída",
		Usable = false,
	},
}

local mejoras: { [string]: Mejora } = {
	Zapatillas = {
		Nombre = "Zapatillas",
		Descripcion = "+25% velocidad por paso",
		PrecioBase = 100,
		FactorPrecio = 1.6,
		NivelMaximo = 10,
		BonusPorNivel = 0.25,
	},
	Bolsillo = {
		Nombre = "Bolsillo",
		Descripcion = "+20% monedas en cada rebirth",
		PrecioBase = 150,
		FactorPrecio = 1.7,
		NivelMaximo = 10,
		BonusPorNivel = 0.2,
	},
}

export type Cancion = { Titulo: string, Autor: string, Notas: { number } }

-- Canciones de dominio público (compositores muertos hace más de 100 años), una por zona y cada
-- una más difícil que la anterior. Notas en semitonos desde el Do central: Do=0 Re=2 Mi=4 Fa=5
-- Sol=7 La=9 Si=11, Do de arriba=12; negativos = más grave.
-- stylua: ignore
local canciones: { Cancion } = {
	{
		-- Fácil: notas seguidas, casi sin saltos.
		Titulo = "Oda a la Alegría",
		Autor = "Beethoven",
		Notas = {
			4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 4, 2, 2,
			4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 2, 0, 0,
			2, 2, 4, 0, 2, 4, 5, 4, 0, 2, 4, 5, 4, 2, 0, 2, -5,
			4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 2, 0, 0,
		},
	},
	{
		-- Media: medio tono que va y viene, y saltos más grandes.
		Titulo = "Para Elisa",
		Autor = "Beethoven",
		Notas = {
			16, 15, 16, 15, 16, 11, 14, 12, 9,
			0, 4, 9, 11,
			4, 8, 11, 12,
			4, 16, 15, 16, 15, 16, 11, 14, 12, 9,
			0, 4, 9, 11,
			4, 12, 11, 9,
		},
	},
	{
		-- Difícil: rápida, cromática y con más registro.
		Titulo = "Marcha turca",
		Autor = "Mozart",
		Notas = {
			-1, -3, -4, -3, 0,
			2, 0, -1, 0, 4,
			5, 4, 3, 4, 11, 9, 8, 9, 11, 9, 8, 9, 12,
			9, 12,
			11, 9, 7, 9,
			11, 9, 7, 9,
			11, 9, 7, 6, 4,
		},
	},
}

-- Efectos de sonido: todos con el mismo sample de piano. Cada uno es una lista de notas
-- (semitonos desde Do) que se tocan una tras otra, separadas por `Separacion` segundos.
-- stylua: ignore
local efectos = {
	Checkpoint = { Notas = { 0, 4, 7, 12 }, Separacion = 0.07 },
	Compra = { Notas = { 7, 12 }, Separacion = 0.08 },
	Rebirth = { Notas = { 0, 4, 7, 12, 16, 19, 24 }, Separacion = 0.06 },
	Recoger = { Notas = { 12, 16 }, Separacion = 0.06 },
	Usar = { Notas = { 7, 11, 14, 19 }, Separacion = 0.05 },
	Escudo = { Notas = { 12, 7, 12 }, Separacion = 0.08 },
	Error = { Notas = { -5.5 }, Separacion = 0 }, -- desafinada: no alcanza la plata o la velocidad
	Caida = { Notas = { -6.5 }, Separacion = 0 }, -- desafinada: medio semitono corrido y grave
	Trampolin = { Notas = { 12, 19 }, Separacion = 0.04 },
	SubirNivel = { Notas = { 7, 7, 12, 16, 19, 24 }, Separacion = 0.08 },
	Puerta = { Notas = { 12, 16, 19, 24, 28 }, Separacion = 0.035 },
	Hablar = { Notas = { 4, 7, 12 }, Separacion = 0.06 },
	Vender = { Notas = { 19, 24, 28 }, Separacion = 0.05 },
	Desbloquear = { Notas = { 0, 7, 12, 19, 24 }, Separacion = 0.07 },
}

-- Paleta de la guía de estilo (Neón nocturno), para lo que pinta el código.
local paleta = {
	Rosa = Color3.fromRGB(255, 60, 172),
	Cian = Color3.fromRGB(43, 210, 255),
	Violeta = Color3.fromRGB(123, 47, 247),
	Amarillo = Color3.fromRGB(255, 228, 94),
	Fondo = Color3.fromRGB(20, 17, 43),
}

local Config = {
	NombreDelJuego = "Pisada Sonora",
	Paleta = paleta,

	-- Velocidad
	WalkSpeedBase = 16,
	WalkSpeedPorPunto = 0.05, -- cuánto WalkSpeed suma cada punto de velocidad
	WalkSpeedTope = 50,
	AlturaSaltoBase = 7.2,
	-- Pasos y velocidad se ganan solo al pisar una baldosa apagada (Pisadas.luau).
	PasosPorBaldosa = 1, -- pasos que da cada baldosa apagada que pisás
	PuntosPorPaso = 1, -- velocidad que da cada paso (antes de multiplicadores)
	IntervaloMedicion = 0.2, -- segundos entre chequeos de caídas en el servidor

	-- Niveles: salen de los pasos totales históricos, así que nunca bajan (Niveles.luau).
	-- Para pasar del nivel n al n+1 hacen falta PasosPrimerNivel + PasosExtraPorNivel * (n - 1) pasos.
	Niveles = {
		PasosPrimerNivel = 30,
		PasosExtraPorNivel = 15,
	},

	-- Zonas: cada baldosa del mapa tiene un atributo Zona (1, 2, 3). La zona n+1 se abre con la
	-- puerta n (NivelPuertas). Cada zona tiene su canción; al entrar a otra zona arranca de cero.
	Zonas = {
		{ Nombre = "Zona 1", Cancion = canciones[1] },
		{ Nombre = "Zona 2", Cancion = canciones[2] },
		{ Nombre = "Zona 3", Cancion = canciones[3] },
	},

	-- Puertas: nivel mínimo para pasar cada una, en orden. Detrás de cada una hay un checkpoint.
	-- Los checkpoints con número más alto que la cantidad de puertas (los del parkour) no piden nivel.
	NivelPuertas = { 3, 5 },

	-- Zonas bloqueadas (solo visual, por jugador): niebla opaca y candado hasta tener el nivel.
	Bloqueos = {
		SubidaArco = 0.25, -- segundos que tarda el arco del candado en saltar
		AlturaArco = 1.2, -- studs que sube el arco
		GiroArco = 0.35, -- segundos que tarda el arco en girar para abrirse
		AnguloArco = 110, -- grados que gira el arco
		DesvanecerCandado = 0.6, -- segundos que tarda el candado en desaparecer
		DuracionNiebla = 1.8, -- segundos que tarda la niebla en disolverse
		DistanciaAnimacion = 90, -- studs: si se abre más lejos, la animación espera a que te acerques
	},

	-- Subir de nivel: efecto alrededor del personaje y cartel en pantalla.
	SubirNivel = {
		DuracionCartel = 2.5, -- segundos que se ve el cartel antes de desvanecerse
		Particulas = 50,
		RadioAnillo = 9, -- studs hasta donde se abre el anillo de luz
		DuracionAnillo = 0.8,
	},

	-- Sensación de velocidad (solo visual). La rapidez es la del personaje en studs/s.
	Sensacion = {
		RapidezSinEfecto = 16, -- por debajo no cambia nada (es el WalkSpeed base)
		RapidezMaxima = 50, -- efecto a pleno (el tope de WalkSpeed)
		AnimacionExtra = 0.4, -- a rapidez máxima, la animación de correr va 40% más rápida que la normal
		FovBase = 70, -- campo de visión de la cámara parado
		FovExtra = 14, -- grados que se abre la cámara a rapidez máxima
		SuavizadoFov = 5, -- más alto = la cámara se ajusta más rápido
		SuavizadoRapidez = 8,
		Histeresis = 2, -- studs/s de margen para bajar de tramo (evita que la estela parpadee)
		DuracionEstela = 0.35, -- segundos que dura la estela detrás del personaje
		-- Tramos: desde qué rapidez se activa cada uno, color de la estela y de las chispas,
		-- chispas por segundo y tamaño de cada chispa.
		Tramos = {
			{ Desde = 20, Color = paleta.Cian, Particulas = 6, TamanoParticula = 0.35 },
			{ Desde = 28, Color = paleta.Violeta, Particulas = 14, TamanoParticula = 0.45 },
			{ Desde = 36, Color = paleta.Rosa, Particulas = 26, TamanoParticula = 0.55 },
			{ Desde = 44, Color = paleta.Amarillo, Particulas = 45, TamanoParticula = 0.7 },
		},
	},

	-- HUD: la tarjeta se agranda o achica según el alto de la pantalla (legible en celular).
	Hud = {
		AltoReferencia = 720, -- alto de pantalla (en puntos) con escala 1
		EscalaMinima = 0.85,
		EscalaMaxima = 1.25,
		DuracionBarra = 0.25, -- segundos que tarda la barra de nivel en moverse
	},

	-- Cruzar una puerta abierta: destello en pantalla, chispas y sonido (solo visual).
	CruzarPuerta = {
		Destello = 0.55, -- transparencia del destello al empezar (0 = blanco total)
		DuracionDestello = 0.45,
		Particulas = 40,
	},

	-- Caídas
	AlturaCaida = 20, -- por debajo de esta altura volvés al último checkpoint
	PenalizacionCaida = 0.1, -- parte de la velocidad que perdés al caer (0.1 = 10%)

	-- Rebirth (en el portal del mapa): convierte toda la velocidad en monedas y sube el multiplicador.
	CostoRebirth = 150, -- velocidad mínima para hacer rebirth
	TasaConversion = 1, -- monedas por cada punto de velocidad
	MultiplicadorPorRebirth = 0.5, -- multiplicador = 1 + rebirths * esto
	EsperaRebirth = 1, -- segundos mínimos entre pedidos

	-- Tienda: un vendedor en la plaza (modelo con atributo Vendedor = true).
	-- Se le puede vender pasos disponibles y comprar mejoras y consumibles.
	EsperaCompra = 0.3, -- segundos mínimos entre compras o ventas
	PasosPorMoneda = 2, -- pasos disponibles que valen 1 moneda al venderlos
	DistanciaVendedor = 14, -- studs: más lejos, el servidor no acepta compras ni ventas (y se cierra el menú)
	NombreVendedor = "Don Compás",
	Consumibles = consumibles,
	OrdenConsumibles = { "DoblePaso", "Escudo" },
	InventarioMaximo = 9,
	ReaparicionConsumible = 30, -- segundos hasta que reaparece un consumible del mapa
	Mejoras = mejoras,
	OrdenMejoras = { "Zapatillas", "Bolsillo" },

	-- Parkour (lo mueve cada cliente; la lógica que importa sigue en el servidor)
	Parkour = {
		TiempoAntesDeDesaparecer = 0.5, -- segundos desde que la pisás hasta que se va
		TiempoDesaparecida = 2.5, -- segundos hasta que vuelve
		EsperaTrampolin = 0.4,
		EmpujeBarra = 45, -- velocidad de costado con la que te empuja una barra giratoria
		EmpujeBarraArriba = 30, -- y hacia arriba
		EsperaEmpuje = 0.6,
	},

	-- Sonido: un solo sample de piano, el tono cambia con PlaybackSpeed.
	-- Reemplazá el ID por tu sample (formato "rbxassetid://123456").
	SonidoNotaId = "rbxassetid://96243649310055", -- "Piano Note C4", gratis en la Creator Store
	SemitonoDelSample = 0, -- qué nota es el sample, en semitonos desde Do (Do = 0)
	VolumenNota = 1,
	VolumenEfectos = 0.8,
	Efectos = efectos,

	-- Baldosas: el color del estilo vive en cada baldosa del mapa; el código lo atenúa.
	-- Brillo = parte del color que se ve (0 = negro, 1 = color pleno).
	-- Una baldosa pisada queda prendida y usada (no da paso ni suena) hasta que se apaga sola con
	-- lo que pase primero: pisaste BaldosasParaApagar baldosas más, o pasaron SegundosParaApagar.
	-- El estado es de cada jugador y lo lleva el servidor (Pisadas.luau).
	Baldosas = {
		BrilloApagada = 0.22,
		BrilloEncendida = 0.5,
		FundidoEncendido = 0.5, -- segundos del fundido al encenderse
		FundidoApagado = 1.5, -- segundos del fundido al apagarse
		BaldosasParaApagar = 10, -- se apaga después de pisar esta cantidad de baldosas nuevas
		SegundosParaApagar = 60, -- o cuando pasaron estos segundos desde que la pisaste
		EsperaMinimaPisada = 0.08, -- segundos mínimos entre dos pisadas válidas (más rápido no cuenta)
		ToleranciaDistancia = 6, -- studs de margen para aceptar que estás encima de la baldosa
	},

	-- Luz del ambiente. La aplica el servidor al arrancar (Ambiente.luau).
	Ambiente = {
		Brillo = 1.2, -- Lighting.Brightness
		Exposicion = -0.25, -- Lighting.ExposureCompensation
		LuzAmbiente = Color3.fromRGB(70, 60, 105), -- Lighting.Ambient
		LuzExterior = Color3.fromRGB(60, 50, 95), -- Lighting.OutdoorAmbient
		BloomIntensidad = 0.4,
		BloomTamano = 24,
		BloomUmbral = 0.9,
	},

	-- Guardado
	NombreDataStore = "PisadaSonora_v1",
}

return Config
