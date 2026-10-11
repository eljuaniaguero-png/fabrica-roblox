--!strict
-- Medidas y tipografía de toda la interfaz (ficha, "Guía de estilo", punto 6).
-- Todo se mide en "puntos de diseño": la pantalla se escala entera con un UIScale
-- (ver Pantalla.luau), así una medida vale lo mismo en computadora y en celular.

local Tema = {
	-- Escala de la pantalla: la altura de referencia es ALTO_REFERENCIA puntos.
	-- En celular la escala no baja de EscalaMinima, así 80 puntos siempre dan 44 píxeles o más.
	AltoReferencia = 760,
	AnchoReferencia = 1300,
	EscalaMinima = 0.55,
	EscalaMaxima = 1,

	Toque = 80, -- tamaño mínimo de todo lo que se toca (80 × 0,55 = 44 píxeles)
	Margen = 18, -- separación desde los bordes de la pantalla
	Separacion = 12, -- entre piezas dentro de una ventana
	Relleno = 18, -- borde interno de ventanas y tarjetas

	Radio = 14, -- esquinas de todo (ventanas, tarjetas, botones)
	RadioChico = 10,
	Contorno = 3, -- grosor del contorno casi negro
	Profundidad = 6, -- franja oscura de abajo de los botones
	Sombra = 6, -- cuánto baja la sombra de ventanas y tarjetas
	TransparenciaVentana = 0.04,
	TransparenciaFondo = 0.45, -- oscurece el juego detrás de un menú abierto

	-- Tipografía: Fredoka One para títulos, números y botones (siempre sin negrita: con
	-- negrita no carga); Builder Sans para los textos chicos.
	Fuentes = {
		Titulo = Font.fromEnum(Enum.Font.FredokaOne),
		Texto = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
		TextoFuerte = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
	},
	Letra = {
		Gigante = 64, -- carteles grandes
		Titulo = 44, -- títulos de ventanas
		Numero = 40, -- contadores
		Boton = 32,
		Subtitulo = 30,
		Normal = 26,
		Chica = 22, -- lo más chico que se usa (12 píxeles en celular)
	},
	ContornoTexto = 2.5, -- contorno oscuro de los textos blancos

	-- Animaciones
	Abrir = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Cerrar = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	Rapida = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Rebote = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Destello = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	BarraDesplazar = 10, -- grosor de la barra de las listas que se desplazan
	MarcaChica = 44, -- estrella de mutante, "?" de silueta y punto de elemento en las tarjetas

	-- Ventanas grandes (fusión, Mutadex y tienda): parte de la pantalla y tope en puntos.
	Ventana = { Ancho = 0.94, Alto = 0.92, MaxAncho = 1250, MaxAlto = 820 },
	-- Ventanas chicas (misiones y ajustes).
	VentanaChica = { Ancho = 0.6, Alto = 0.62, MaxAncho = 720, MaxAlto = 480 },
	ContadorVentana = Vector2.new(230, 72), -- ADN en el encabezado de las ventanas

	-- Panel de fusión
	Fusion = {
		Padre = Vector2.new(190, 228), -- casilleros de los padres y de la vista previa
		Catalizador = Vector2.new(124, 104),
		Signo = 56, -- "+" e "=" entre casilleros
		Columna = 124, -- columna del medio (catalizador y "+")
		AltoMaquina = 250,
		AnchoBoton = 330,
		AltoBoton = 100,
		Criatura = Vector2.new(132, 158), -- casilleros de la lista de criaturas
		Filtro = 64, -- botones redondos de elemento
		AnchoTodos = 120,
		Salto = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	},

	-- Mutadex
	Mutadex = {
		Columnas = 4,
		ColumnasCelular = 3,
		AltoTarjeta = { Minimo = 190, Maximo = 230, Proporcion = 1.15 },
		AnchoFicha = 400,
		VistaFicha = 230,
		Giro = 0.9, -- radianes por segundo de la criatura grande de la ficha
		AnchoProgreso = 260,
		AltoNota = 56, -- nota de la regla arriba de cada generación
		FilaFicha = 36, -- filas de generación, elemento y personalidad de la ficha
		InsigniaExtras = 120,
	},

	-- Ficha de una criatura de otro jugador (abajo al centro)
	FichaAjena = { Ancho = 640, Alto = 172 },

	-- Tablero de pedidos
	Pedidos = {
		AltoInfo = 40,
		Cliente = 76, -- muñequito del cliente
		AltoEncabezado = 84,
		AltoGlobo = 150, -- globo con lo que pide
		AltoPremio = 44,
		Opcion = Vector2.new(150, 176), -- casilleros para elegir qué criatura entregar
		Despedida = 1.6, -- segundos de la animación de despedida
		ContadorHUD = Vector2.new(290, 76),
	},

	-- Tienda
	Tienda = {
		Columnas = 4,
		ColumnasCelular = 3,
		AltoTarjeta = 372,
		AltoMedia = 120, -- vista 3D o ícono de arriba de cada tarjeta
		AltoNombre = 38,
		AltoEfecto = 78, -- tres renglones de letra chica
		AltoNivel = 26,
		AltoInfo = 44, -- renglón de ayuda arriba de la grilla
		Insignia = 104, -- círculo con el ícono de las mejoras y lo Premium
		PuntoNivel = 18,
	},
}

return Tema
