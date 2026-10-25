--!strict
-- Tokens de interfaz que no son colores: tamaños, márgenes y animaciones de la UI.
-- Los colores, la fuente y el borde siguen saliendo de shared/Estilo.luau (Estilo.UI), así
-- un cambio de estilo se hace en un solo lugar. Acá va lo que solo usa el cliente.

local Tokens = {}

-- Márgenes fijos en px (Offset): no cambian con la pantalla para que nada quede pegado al borde.
Tokens.Margen = 12
Tokens.Separacion = 8
Tokens.Relleno = 8 -- UIPadding interno de paneles y casillas

-- Botones: escala que se suma o resta al tamaño base en cada estado.
Tokens.Boton = {
	Encima = 1.06, -- MouseEnter
	Apretado = 0.92, -- MouseButton1Down
	Bloqueado = 0.5, -- BackgroundTransparency cuando no alcanza la plata
}

-- Barra del balde (abajo al centro, la de las referencias con los kg de cada pez).
Tokens.Balde = {
	Ancho = 0.46, -- Scale del ancho de pantalla
	Alto = 74, -- px: las casillas no se achican en celular
	Abajo = 0.93, -- borde inferior de la barra (Scale), deja lugar a las probabilidades
	Casilla = 62, -- px, casillas cuadradas
	Lado = 150, -- px, columna del contador y el valor (con 120 el texto quedaba diminuto)
	Visibles = 8, -- el resto entra con scroll horizontal
}

-- Ventanitas 3D (ViewportFrame) con el modelo de un cebo o un pez, en tarjetas e indicadores.
Tokens.Vista = {
	Fov = 30,
	Margen = 1.15, -- aire alrededor del modelo para que no toque el borde de la tarjeta
	AnguloInicial = math.rad(35), -- de 3/4: el camarón de frente parece una bola (nota de C)
	Giro = math.rad(50), -- por segundo, solo mientras el panel está abierto
	Ambiente = Color3.fromRGB(190, 190, 200), -- alto: colores planos, casi sin sombra (toon)
	Luz = Color3.fromRGB(255, 250, 240),
	DireccionLuz = Vector3.new(-0.5, -1, 0.7), -- de arriba y de frente a la cámara
}

-- Franja de ofertas con Robux al pie de la tienda de cebo (solo si hay productos con Id ~= 0).
Tokens.Robux = {
	Alto = 0.11, -- Scale del alto del panel (con 0.15 el texto le ganaba a los botones de cebo)
	AltoTarjetasSin = 0.68, -- alto de la fila de cebos sin franja
	AltoTarjetasCon = 0.55, -- y con franja (los cebos se achican un poco, el texto sigue entrando)
	Moneda = "R$", -- el ícono de Robux no está en FredokaOne: sale un cuadradito
}

-- Animaciones
Tokens.Tween = {
	Encima = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Apretar = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Soltar = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Entrar = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Latido = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
}

return Tokens
