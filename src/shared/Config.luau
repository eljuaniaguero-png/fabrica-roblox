--!strict
-- Números de balance del juego. Todo lo ajustable va acá.

export type Consumible = {
	Nombre: string,
	Precio: number,
	Descripcion: string,
	Usable: boolean, -- false = se usa solo (como el Escudo)
	Duracion: number?,
	Factor: number?,
	AlturaSalto: number?,
}

local consumibles: { [string]: Consumible } = {
	Turbo = {
		Nombre = "Turbo",
		Precio = 60,
		Descripcion = "x2 velocidad ganada por 30 s",
		Usable = true,
		Duracion = 30,
		Factor = 2,
	},
	Resorte = {
		Nombre = "Resorte",
		Precio = 40,
		Descripcion = "Salto alto por 30 s",
		Usable = true,
		Duracion = 30,
		AlturaSalto = 16,
	},
	Escudo = {
		Nombre = "Escudo",
		Precio = 50,
		Descripcion = "Tu próxima caída no te quita velocidad",
		Usable = false,
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
	UmbralesPuertas = { 100, 300 },

	-- Caídas
	AlturaCaida = 20, -- por debajo de esta altura volvés al último checkpoint
	PenalizacionCaida = 0.1, -- parte de la velocidad que perdés al caer (0.1 = 10%)

	-- Rebirth
	CostoRebirth = 500,
	MultiplicadorPorRebirth = 1, -- multiplicador = 1 + rebirths * esto
	EsperaRebirth = 1, -- segundos mínimos entre pedidos

	-- Economía
	TasaConversion = 1, -- monedas por cada punto de velocidad convertido
	MinimoConversion = 10, -- velocidad mínima para poder convertir
	EsperaCompra = 0.2, -- segundos mínimos entre pedidos a la tienda

	-- Tienda: consumibles
	Consumibles = consumibles,
	OrdenConsumibles = { "Turbo", "Resorte", "Escudo" },
	InventarioMaximo = 9,
	ReaparicionConsumible = 30, -- segundos hasta que reaparece un consumible del mapa

	-- Tienda: mejora permanente
	Zapatillas = {
		Nombre = "Zapatillas",
		Descripcion = "+25% de velocidad por paso",
		PrecioBase = 100,
		FactorPrecio = 1.6, -- cada nivel cuesta esto por el anterior
		NivelMaximo = 10,
		BonusPorNivel = 0.25,
	},

	-- Sonido de las baldosas: un solo sample de piano, el tono cambia con PlaybackSpeed.
	-- Reemplazá el ID por tu sample (formato "rbxassetid://123456").
	SonidoNotaId = "rbxassetid://96243649310055", -- "Piano Note C4", gratis en la Creator Store
	SemitonoDelSample = 0, -- qué nota es el sample, en semitonos desde Do (Do = 0)
	VolumenNota = 0.6,
	Melodia = melodia,
	-- Nota desafinada al caer: mismo sample, tono "entre teclas" (medio semitono corrido) y más grave.
	NotaCaidaSemitonos = -6.5,
	VolumenNotaCaida = 0.8,
	DuracionDestello = 0.25,
	ColorDestello = Color3.new(1, 1, 1),

	-- Guardado
	NombreDataStore = "PisadaSonora_v1",
}

return Config
