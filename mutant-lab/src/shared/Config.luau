--!strict
-- Números de balance y de aspecto de Mutant Lab. Todo lo ajustable va acá.

local Config = {
	-- Fusión
	TamanioRueda = 10, -- cantidad de especies base en la rueda
	DistanciaMaxima = 3, -- base + base reaccionan si están a 1, 2 o 3 lugares
	ProbabilidadMutante = 1 / 40, -- solo estética

	-- Economía (ficha, punto 6)
	Economia = {
		ADNInicial = 30, -- el jugador nuevo arranca con poco ADN...
		BasesIniciales = { 1, 2 }, -- ...y dos bases vecinas (Glupona y Rámulo), así la primera fusión sale enseguida
		CostoGen2 = 20,
		SubaPorEspecie = 1.1, -- el costo sube un 10 % por cada especie que ya tenés...
		EspeciesSinSuba = 3, -- ...a partir de la tercera
		MultiplicadorGen3 = 5,
		ADNPorGen = { 1, 2, 6 }, -- ADN por segundo de cada criatura activa en un corral, según su generación
	},

	-- Tienda de especies base: el precio depende de cuántas bases ya tenés.
	-- PreciosBases[1] es lo que cuesta la primera que comprás (la 3.ª base), y así.
	Tienda = {
		PreciosBases = { 50, 120, 300, 800, 2000, 5000, 12000, 30000 },
	},

	-- Corrales: solo las criaturas que están en un corral generan ADN.
	Corrales = {
		PorCorral = 4, -- criaturas por corral
		Maximo = 4, -- corrales que tiene cada laboratorio
	},

	-- Mejoras que se compran con ADN en la tienda.
	-- Precios[i] es lo que cuesta pasar al nivel siguiente; Inicial es el nivel con el que arrancás.
	Mejoras = {
		Corrales = {
			Nombre = "Más corrales",
			Descripcion = "Abre un corral: +4 criaturas trabajando",
			Inicial = 1,
			Precios = { 150, 1500, 8000 },
		},
		Rapida = {
			Nombre = "Fusión rápida",
			Descripcion = "La máquina trabaja más rápido",
			Inicial = 0,
			Precios = { 250, 1500, 6000 },
			Factores = { 1, 0.8, 0.65, 0.5 }, -- duración de la fusión en cada nivel (0 a 3)
		},
		Nutrientes = {
			Nombre = "Nutrientes",
			Descripcion = "+25 % de ADN por segundo",
			Inicial = 0,
			Precios = { 200, 800, 3000, 10000, 30000 },
			Bonus = 0.25, -- por nivel
		},
	},

	-- Laboratorios: uno por jugador. El servidor los genera al arrancar, clonando el molde
	-- ServerStorage > Moldes > Laboratorio alrededor de la plaza.
	-- El servidor debería ser de 6 jugadores como máximo (se cambia en la configuración del juego).
	CantidadLaboratorios = 6,
	Mapa = {
		CentroPlaza = Vector3.new(0, 0, 0),
		DistanciaLaboratorios = 80, -- del centro de la plaza al centro de cada laboratorio
		AnguloInicial = 0, -- el Lab1 queda hacia +Z; los demás siguen cada 60 grados
	},

	-- Premios de la Mutadex (ficha, Parte 3)
	Premios = {
		MultiplicadorDescubrir = 0.5, -- descubrir una especie nueva devuelve la mitad de lo que costó la fusión...
		MinimoDescubrir = 10, -- ...y como mínimo esto
		PorGeneracion = { 1000, 10000, 25000 }, -- premio grande por completar la gen 1, 2 y 3
	},

	-- Pistas de las siluetas
	Pistas = {
		CostoBase = 100, -- cada pista cuesta CostoBase x (pistas que ya compraste + 1)
	},

	-- Máquina de fusión
	Maquina = {
		Espera = 4, -- segundos que la máquina queda ocupada después de una fusión (servidor)
		EsperaNoReacciona = 1.5,
		TiempoRevelacion = 2.5, -- cuánto queda el cartel de la especie en pantalla
		EscalaEnCapsula = 0.5, -- tamaño de las criaturas dentro de las cápsulas
	},

	-- Modo prueba (Partes 2 y 3): todas las bases, ADN de sobra y más mutantes para verlos.
	-- Desde la Parte 4 está apagado: el jugador arranca como uno nuevo.
	Prueba = {
		Activo = false,
		ADN = 100000,
		ProbabilidadMutante = 1 / 4,
	},

	-- Sonido: un solo sample de piano, el tono cambia con PlaybackSpeed.
	-- Reemplazá el ID por tu sample (formato "rbxassetid://123456").
	SonidoNotaId = "rbxassetid://96243649310055", -- "Piano Note C4", gratis en la Creator Store
	VolumenEfectos = 0.5,

	-- Animación de las criaturas (la misma para todas)
	Animacion = {
		PeriodoSalto = 0.7, -- segundos por saltito
		AlturaSalto = 0.55,
		Bamboleo = 0.09, -- inclinación de lado a lado (radianes)
		AlturaFlotar = 0.9, -- rasgo "flota"
		CadaCuantoRueda = 5, -- rasgo "rueda": segundos entre vueltas
		CadaCuantoSeEntierra = 6, -- rasgo "se entierra"
		ProfundidadEntierro = 1.6,
		VelocidadPaseo = 3.5, -- studs por segundo cuando caminan por el corral
		PausaPaseo = { 0.6, 3 }, -- segundos que se quedan quietas entre paseo y paseo (mínimo, máximo)
		Tornasol = false, -- mutantes con colores que cambian (la guía de estilo los quiere dorados)
	},

	-- Forma de las criaturas (guía de estilo, punto 5): estilo chibi, la cabeza ocupa la
	-- mitad de la altura. Las piezas se arman como siempre y después el generador achica
	-- el cuerpo desde el piso y agranda la cabeza alrededor de su centro.
	Criaturas = {
		EscalaCuerpo = 0.78, -- cuerpo, patas, cola y alas
		EscalaCabeza = 1.45,
		CentroCabeza = Vector3.new(0, 3.45, -1.05), -- adónde va el centro de la cabeza agrandada
		Escala = 0.85, -- escala final de toda la criatura (mediana: unos 4,5 studs)
		Gema = 0.75, -- diámetro de la gema de Neon con el color del elemento
		GemaMutante = 1.15,
		Anillo = 3.8, -- diámetro del anillo de luz bajo los pies
		DistanciaIcono = 20, -- el ícono de personalidad se ve a menos de esto
	},

	-- Estilo anterior (Laboratorio caramelo). Los colores nuevos están en Paleta.luau;
	-- esto se va cuando la guía nueva esté aplicada a todo el juego.
	Estilo = {
		Piso = Color3.fromHex("FFF4E0"),
		Menta = Color3.fromHex("3EE6B5"),
		Rosa = Color3.fromHex("FF5FA2"),
		Amarillo = Color3.fromHex("FFD23F"),
		Violeta = Color3.fromHex("4B2C83"),
	},
}

return Config
