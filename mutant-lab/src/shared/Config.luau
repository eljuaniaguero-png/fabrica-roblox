--!strict
-- Números de balance y de aspecto de Mutant Lab. Todo lo ajustable va acá.

local Config = {
	-- Fusión
	TamanioRueda = 10, -- cantidad de especies base en la rueda
	DistanciaMaxima = 3, -- base + base reaccionan si están a 1, 2 o 3 lugares
	ProbabilidadMutante = 1 / 40, -- solo estética

	-- Economía (ficha, punto 6)
	Economia = {
		ADNInicial = 50,
		BasesIniciales = { 1, 2, 3 },
		CostoGen2 = 20,
		SubaPorEspecie = 1.1, -- el costo sube un 10 % por cada especie que ya tenés...
		EspeciesSinSuba = 3, -- ...a partir de las 3 del arranque
		MultiplicadorGen3 = 5,
	},

	-- Premios de la Mutadex (ficha, Parte 3)
	Premios = {
		MultiplicadorDescubrir = 0.5, -- descubrir una especie nueva devuelve la mitad de lo que costó la fusión...
		MinimoDescubrir = 25, -- ...y como mínimo esto
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

	-- Modo prueba (Parte 2): todas las bases, ADN de sobra y más mutantes para verlos.
	-- Apagarlo (Activo = false) antes de la Parte 5.
	Prueba = {
		Activo = true,
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
	},

	-- Guía de estilo: Laboratorio caramelo (versión saturada)
	Estilo = {
		Piso = Color3.fromHex("FFF4E0"),
		Menta = Color3.fromHex("3EE6B5"),
		Rosa = Color3.fromHex("FF5FA2"),
		Amarillo = Color3.fromHex("FFD23F"),
		Violeta = Color3.fromHex("4B2C83"),
	},
}

return Config
