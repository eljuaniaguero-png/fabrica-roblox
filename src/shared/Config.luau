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
}

local Config = {
	NombreDelJuego = "Pisada Sonora",

	-- Velocidad
	WalkSpeedBase = 16,
	WalkSpeedPorPunto = 0.05, -- cuánto WalkSpeed suma cada punto de velocidad
	WalkSpeedTope = 50,
	AlturaSaltoBase = 7.2,
	DistanciaPorPaso = 4, -- studs recorridos que cuentan como un paso
	PuntosPorPaso = 1,
	IntervaloMedicion = 0.2, -- segundos entre mediciones del servidor
	ToleranciaTeletransporte = 1.5, -- si se mueve más que tope * intervalo * esto, no cuenta

	-- Puertas: velocidad mínima para pasar cada una, en orden. Detrás de cada una hay un checkpoint.
	-- Los checkpoints con número más alto que la cantidad de puertas (los del parkour) no piden velocidad.
	UmbralesPuertas = { 100, 300 },

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
	},

	-- Sonido: un solo sample de piano, el tono cambia con PlaybackSpeed.
	-- Reemplazá el ID por tu sample (formato "rbxassetid://123456").
	SonidoNotaId = "rbxassetid://96243649310055", -- "Piano Note C4", gratis en la Creator Store
	SemitonoDelSample = 0, -- qué nota es el sample, en semitonos desde Do (Do = 0)
	VolumenNota = 1,
	VolumenEfectos = 0.8,
	Melodia = melodia,
	Efectos = efectos,
	DuracionDestello = 0.25,
	ColorDestello = Color3.new(1, 1, 1),

	-- Guardado
	NombreDataStore = "PisadaSonora_v1",
}

return Config
