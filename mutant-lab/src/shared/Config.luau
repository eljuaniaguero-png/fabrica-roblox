--!strict
-- Números de balance y de aspecto de Mutant Lab. Todo lo ajustable va acá.

local Config = {
	-- Fusión
	TamanioRueda = 10, -- cantidad de especies base en la rueda
	DistanciaMaxima = 3, -- base + base reaccionan si están a 1, 2 o 3 lugares
	ProbabilidadMutante = 1 / 40, -- solo estética

	-- Economía (ficha, punto 6). Balance de la Parte 5: una especie nueva por minuto más o
	-- menos, unas 10 a los 10 minutos y nunca más de 3 minutos sin una fusión nueva posible.
	-- Los tiempos medidos están en la ficha ("Notas de la Parte 5").
	Economia = {
		ADNInicial = 100, -- justo lo que cuesta la primera fusión...
		BasesIniciales = { 1, 2 }, -- ...con dos bases vecinas (Glupona y Rámulo): sale en el segundo 1
		CostoGen2 = 100,
		SubaPorEspecie = 1.3, -- el costo sube un 30 % por cada especie que ya tenés...
		EspeciesSinSuba = 3, -- ...a partir de la tercera
		MultiplicadorGen3 = 3,
		ADNPorGen = { 1, 2, 6 }, -- ADN por segundo de cada criatura activa en un corral, según su generación
	},

	-- Tienda de especies base: el precio depende de cuántas bases ya tenés.
	-- PreciosBases[1] es lo que cuesta la primera que comprás (la 3.ª base), y así.
	-- Cada base nueva abre de 3 a 5 fusiones: estos precios son los que marcan el ritmo.
	Tienda = {
		PreciosBases = { 450, 1350, 3200, 6800, 16000, 36000, 80000, 180000 },
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
			Precios = { 300, 5000, 25000 }, -- el primero es barato: si no, frena la 4.ª base
		},
		Rapida = {
			Nombre = "Fusión rápida",
			Descripcion = "La máquina trabaja más rápido",
			Inicial = 0,
			Precios = { 500, 3000, 12000 },
			Factores = { 1, 0.8, 0.65, 0.5 }, -- duración de la fusión en cada nivel (0 a 3)
		},
		Nutrientes = {
			Nombre = "Nutrientes",
			Descripcion = "+25 % de ADN por segundo",
			Inicial = 0,
			Precios = { 600, 2500, 8000, 25000, 70000 },
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
		-- Rendimiento: solo se animan las criaturas a menos de esto de la cámara. Con 6
		-- laboratorios llenos hay casi 100 criaturas; las de los demás quedan quietas de lejos.
		DistanciaAnimar = 80,
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

	-- Interfaz: tiempos de los avisos y carteles (los colores están en Paleta.luau,
	-- las medidas en client/UI/Tema.luau).
	Interfaz = {
		DuracionNotificacion = 3.5, -- segundos que queda cada notificación
		MaximoNotificaciones = 3, -- se apilan hasta esta cantidad
		DuracionCartel = 3, -- el cartel grande se va solo a los 3 segundos (o al tocarlo)
		DuracionFestejo = 4, -- el de generación completa queda un poco más
		Papelitos = { 90, 60 }, -- papelitos de cada tanda del festejo (la segunda sale después)
	},

	-- Guardado en el servidor (DataStore). Cambiar el nombre empieza todo de cero.
	Guardado = {
		Almacen = "MutantLab_v1",
		CadaCuanto = 60, -- segundos entre guardados automáticos
		Intentos = 3, -- reintentos si Roblox no responde
	},

	-- Guía del jugador nuevo: flecha y cartel hasta la máquina, hasta que la usa por primera vez.
	Guia = {
		Texto = "¡Seguí la flecha hasta la máquina y fusioná 2 criaturas!",
		AlturaFlecha = 9, -- studs sobre la consola de la máquina
	},

	-- Efectos de la interfaz (Parte 5)
	Efectos = {
		NumeroADNMinimo = 1, -- el "+N" junto al contador sale cuando sumás al menos esto
		NumeroADNGrande = 50, -- desde acá el "+N" sale más grande y dorado (premios, ventas)
	},

	-- Premium (ficha de monetización, "Mutant Lab"). Los IDs van vacíos: los crea el usuario en el
	-- panel de Roblox. Sin ID, el botón dice "Próximamente" y no hace nada.
	Premium = {
		{
			Clave = "ADNx2",
			Nombre = "ADN x2",
			Efecto = "Doble de ADN por segundo",
			Robux = 149,
			Id = 0,
		},
		{
			Clave = "Instantanea",
			Nombre = "Fusión instantánea",
			Efecto = "Sin espera entre fusiones",
			Robux = 99,
			Id = 0,
		},
		{
			Clave = "CorralesExtra",
			Nombre = "Corrales extra",
			Efecto = "+5 criaturas trabajando",
			Robux = 149,
			Id = 0,
		},
		{
			Clave = "Recoleccion",
			Nombre = "Recolección automática",
			Efecto = "Junta el ADN de los corrales solo",
			Robux = 99,
			Id = 0,
		},
		{
			Clave = "PistasDia",
			Nombre = "Pistas del día",
			Efecto = "3 pistas gratis por día",
			Robux = 99,
			Id = 0,
		},
		{
			Clave = "VIP",
			Nombre = "VIP",
			Efecto = "Aura, etiqueta y +10 % de ADN",
			Robux = 399,
			Id = 0,
		},
		{
			Clave = "Todo",
			Nombre = "Bundle Todo",
			Efecto = "Todos los pases juntos",
			Robux = 799,
			Id = 0,
		},
	},
}

return Config
