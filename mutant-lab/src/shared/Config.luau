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
	-- Pedidos (versión 9): las fusiones cuestan más y los precios de la tienda se miden en
	-- fusiones, así el ADN no se junta sin uso (simulado con Prueba.Simular, ver la ficha).
	Economia = {
		ADNInicial = 150, -- justo lo que cuesta la primera fusión...
		BasesIniciales = { 1, 2 }, -- ...con dos bases vecinas (Glupona y Rámulo): sale en el segundo 1
		CostoGen2 = 150,
		SubaPorEspecie = 1.4, -- el costo sube un 40 % por cada especie que ya tenés...
		EspeciesSinSuba = 3, -- ...a partir de la tercera
		MultiplicadorGen3 = 2,
		ADNPorGen = { 1, 2, 6 }, -- ADN por segundo de cada criatura activa en un corral, según su generación
	},

	-- Todo lo que se compra con ADN cuesta "fusiones": un número x lo que cuesta ahora una
	-- fusión de gen 2. Así los precios crecen junto con el juego y nunca hace falta juntar más
	-- del triple de una fusión (pedidos, punto 7: "que el ADN sea el límite").
	Tienda = {
		FactorBase = 2.5, -- una especie base nueva (cada una abre de 3 a 5 fusiones)
		-- Otra copia de una base que ya descubriste (para pedidos o si entregaste la tuya).
		FactorCopia = 0.6,
	},

	-- Corrales: solo las criaturas que están en un corral generan ADN.
	Corrales = {
		PorCorral = 4, -- criaturas por corral
		Maximo = 4, -- corrales que tiene cada laboratorio
	},

	-- Mejoras que se compran con ADN en la tienda.
	-- Precios[i] es lo que cuesta pasar al nivel siguiente, en fusiones de gen 2 (ver Tienda);
	-- Inicial es el nivel con el que arrancás.
	Mejoras = {
		Corrales = {
			Nombre = "Más corrales",
			Descripcion = "Abre un corral: +4 criaturas trabajando",
			Inicial = 1,
			Precios = { 2, 2.5, 3 },
		},
		Rapida = {
			Nombre = "Fusión rápida",
			Descripcion = "La máquina trabaja más rápido",
			Inicial = 0,
			Precios = { 1.5, 2, 2.5 },
			Factores = { 1, 0.8, 0.65, 0.5 }, -- duración de la fusión en cada nivel (0 a 3)
		},
		Nutrientes = {
			Nombre = "Nutrientes",
			Descripcion = "+25 % de ADN por segundo",
			Inicial = 0,
			Precios = { 1, 1.5, 2, 2.5, 3 },
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

	-- Pedidos de los clientes (ficha, "Pedidos"): 3 a la vez en el tablero del laboratorio.
	-- Entregar una criatura la saca de tu laboratorio (la Mutadex no se pierde) y paga ADN.
	Pedidos = {
		Activos = 3,
		Nuevos = 1, -- de los activos, cuántos piden una especie que todavía no descubriste
		EsperaDescarte = 120, -- segundos hasta que llega otro pedido después de descartar uno
		-- Premio en ADN = lo que cuesta ahora una fusión de gen 2 x este factor.
		Premio = {
			Facil = 0.9, -- especies base
			Media = 1.2, -- generación 2, dos criaturas, o una base que todavía no descubriste
			Dificil = 2, -- generación 3, o una gen 2 nueva
			Mutante = 4,
		},
		ExtraPorCantidad = 1.2, -- los que piden dos criaturas pagan un poco más
		PremioMinimo = 40,
		ProbabilidadPista = 0.3, -- los que no son fáciles a veces traen una pista gratis
		ProbabilidadDescubierta = 0.75, -- los comunes casi siempre piden especies que ya tenés
		ProbabilidadMutante = 0.08, -- un pedido común puede ser "cualquier mutante"...
		MutanteDesde = 8, -- ...cuando ya descubriste esta cantidad de especies
		Hito = 10, -- cada 10 pedidos entregados, un premio extra...
		PremioHito = 2, -- ...de esto x el costo de una fusión de gen 2
		-- Clientes: nombres inventados (el color del muñequito sale de Paleta.Papelitos).
		Clientes = {
			"Doña Burbuja",
			"Profe Tornillo",
			"Tía Gelatina",
			"Don Pepino",
			"Capitana Grumo",
			"Lola Chispitas",
			"Tito Pegote",
			"Señor Calcetín",
			"Abuela Fideo",
			"Mister Pompón",
			"Chef Albóndiga",
			"Baronesa Merengue",
		},
	},

	-- Personalidades (ficha, "Personalidades"): cuánto cambian el ADN por segundo de la criatura
	-- (Propia) y el de las demás de su corral (Vecinas). 0,1 = 10 %. Las negativas pierden algo
	-- pero tienen una ventaja: conviene ubicarlas bien (el corral las acomoda solo).
	Personalidades = {
		Alegre = { Propia = 0, Vecinas = 0.1 },
		Curiosa = { Propia = 0.2, Vecinas = 0 },
		Lider = { Propia = 0, Vecinas = 0.15 },
		Trabajadora = { Propia = 0.35, Vecinas = 0 },
		Vaga = { Propia = -0.5, Vecinas = 0.1 }, -- da la mitad, pero tranquiliza a las demás
		Peleadora = { Propia = 0.8, Vecinas = -0.2 }, -- da mucho más, pero molesta a las demás
		Miedosa = { Propia = -0.3, Vecinas = 0, ConLider = 0.5 }, -- con una Líder al lado, +50 %
		Glotona = { Propia = 0.6, Vecinas = -0.1 }, -- se come la comida de las demás
		AvisoDesde = 5, -- especies descubiertas para el cartel que las explica
	},

	-- Fracasos útiles: si una pareja no reacciona, la máquina igual hace un residuo (gratis).
	Residuos = {
		ParaCatalizador = 5, -- con esta cantidad se arma un catalizador al azar de los que conocés
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
		-- Jugador automático (server/Robot.luau): segundos que tarda en cada cosa, como una
		-- persona que mira las animaciones y camina hasta la tienda.
		Robot = {
			Pensar = 3, -- mirar una pareja en el panel o no hacer nada
			Fusion = 7, -- animación entera y volver al panel
			Residuo = 5, -- una pareja que no reacciona (animación corta)
			Entrega = 5, -- abrir el tablero, elegir y ver la despedida
			Compra = 6, -- caminar hasta el mostrador y comprar
			Descarte = 3,
			Trabado = 150, -- descarta un pedido que lleva esto sin poder cumplirse
			SinSaber = 30, -- segundos seguidos sin nada útil para contarlo como "sin saber qué hacer"
		},
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
