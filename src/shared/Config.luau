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

-- Oda a la Alegría (Beethoven, 1824, dominio público). Semitonos desde Do: Do=0 Re=2 Mi=4 Fa=5 Sol=7.
-- stylua: ignore
local melodia = {
	4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 4, 2, 2,
	4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 2, 0, 0,
	2, 2, 4, 0, 2, 4, 5, 4, 0, 2, 4, 5, 4, 2, 0, 2, -5,
	4, 4, 5, 7, 7, 5, 4, 2, 0, 0, 2, 4, 2, 0, 0,
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
	DistanciaPorPaso = 4, -- studs recorridos que cuentan como un paso
	PuntosPorPaso = 1,
	IntervaloMedicion = 0.2, -- segundos entre mediciones del servidor
	ToleranciaTeletransporte = 1.5, -- si se mueve más que tope * intervalo * esto, no cuenta

	-- Niveles: salen de los pasos totales históricos, así que nunca bajan (Niveles.luau).
	-- Para pasar del nivel n al n+1 hacen falta PasosPrimerNivel + PasosExtraPorNivel * (n - 1) pasos.
	Niveles = {
		PasosPrimerNivel = 50,
		PasosExtraPorNivel = 25,
	},

	-- Puertas: nivel mínimo para pasar cada una, en orden. Detrás de cada una hay un checkpoint.
	-- Los checkpoints con número más alto que la cantidad de puertas (los del parkour) no piden nivel.
	NivelPuertas = { 3, 5 },

	-- Subir de nivel: efecto alrededor del personaje y cartel en pantalla.
	SubirNivel = {
		DuracionCartel = 2.5, -- segundos que se ve el cartel antes de desvanecerse
		Particulas = 50,
		RadioAnillo = 9, -- studs hasta donde se abre el anillo de luz
		DuracionAnillo = 0.8,
	},

	-- Caídas
	AlturaCaida = 20, -- por debajo de esta altura volvés al último checkpoint
	PenalizacionCaida = 0.1, -- parte de la velocidad que perdés al caer (0.1 = 10%)

	-- Rebirth (en el portal del mapa): convierte toda la velocidad en monedas y sube el multiplicador.
	CostoRebirth = 150, -- velocidad mínima para hacer rebirth
	TasaConversion = 1, -- monedas por cada punto de velocidad
	MultiplicadorPorRebirth = 0.5, -- multiplicador = 1 + rebirths * esto
	EsperaRebirth = 1, -- segundos mínimos entre pedidos

	-- Tienda (puestos en el mapa)
	EsperaCompra = 0.3, -- segundos mínimos entre compras
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
	Melodia = melodia,
	Efectos = efectos,

	-- Baldosas: el color del estilo vive en cada baldosa del mapa; el código lo atenúa.
	-- Brillo = parte del color que se ve (0 = negro, 1 = color pleno).
	-- Arrancan apagadas, se encienden al pisarlas y se apagan solas un rato después.
	Baldosas = {
		BrilloApagada = 0.22,
		BrilloEncendida = 0.5,
		FundidoEncendido = 0.5, -- segundos del fundido al encenderse
		FundidoApagado = 2.5, -- segundos del fundido al apagarse
		TiempoEncendida = 300, -- segundos desde la última pisada hasta que se apaga (5 minutos)
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
