--!strict
-- Números de balance y de aspecto de Mutant Lab. Todo lo ajustable va acá.

local Config = {
	-- Fusión
	TamanioRueda = 10, -- cantidad de especies base en la rueda
	DistanciaMaxima = 3, -- base + base reaccionan si están a 1, 2 o 3 lugares
	ProbabilidadMutante = 1 / 40, -- solo estética (se usa en la Parte 2)

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
