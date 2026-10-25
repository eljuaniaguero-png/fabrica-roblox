--!strict
-- Estilo visual de Pesca al Compás: "Toon de playa" (opción A, la de Mutant Lab, pasada a sol
-- de mediodía). Colores planos y saturados, contorno grueso azul marino, nada de reflejos.
-- Todos los colores del mundo y de la UI salen de acá: si se cambia el estilo, se cambia este
-- archivo y nada más. Nota de diseño: Obsidian > Juegos/Pesca al Compás/Estilo visual.md

local Estilo = {}

-- El contorno de todo: mundo (Highlight) y UI (UIStroke). Azul muy oscuro en vez de negro,
-- que en celular se ve menos sucio sobre el celeste.
Estilo.Contorno = Color3.fromRGB(27, 31, 59)

-- Mundo, Isla 1 · Muelle Pastel
Estilo.Mundo = {
	Arena = Color3.fromRGB(255, 226, 160),
	ArenaMojada = Color3.fromRGB(240, 196, 130),
	Madera = Color3.fromRGB(214, 140, 76),
	MaderaOscura = Color3.fromRGB(160, 96, 52),
	Agua = Color3.fromRGB(40, 210, 225),
	Tronco = Color3.fromRGB(190, 120, 70),
	Hojas = Color3.fromRGB(90, 220, 110),
	HojasClaro = Color3.fromRGB(150, 245, 120),
	Toldo = Color3.fromRGB(255, 95, 120),
	ToldoClaro = Color3.fromRGB(255, 245, 235),
	Puesto = Color3.fromRGB(60, 180, 255),
	PuntoPesca = Color3.fromRGB(255, 225, 70),
	Boya = Color3.fromRGB(255, 80, 80),
	-- pueblo pesquero: paredes pastel y techos fuertes, para que cada casa se distinga de lejos
	ParedCoral = Color3.fromRGB(255, 175, 150),
	ParedMenta = Color3.fromRGB(160, 235, 205),
	TechoAzul = Color3.fromRGB(70, 120, 215),
	TechoRojo = Color3.fromRGB(235, 90, 80),
	Ventana = Color3.fromRGB(150, 225, 255),
	Red = Color3.fromRGB(250, 245, 230),
	Pescado = Color3.fromRGB(120, 200, 255),
	-- guías para el jugador nuevo (sacadas de las referencias): todo Neon, así el bloom los marca
	ZonaPesca = Color3.fromRGB(110, 255, 120), -- columna y aro de "¡PESCÁ ACÁ!"
	Flecha = Color3.fromRGB(255, 215, 50), -- flechas del camino al muelle
	Farol = Color3.fromRGB(255, 225, 150),
	Dorado = Color3.fromRGB(240, 200, 95), -- filo de los tablones
	Metal = Color3.fromRGB(70, 75, 95),
	PisoVenta = Color3.fromRGB(255, 200, 60), -- piso brillante de cada tienda, un color por tienda
	PisoCebo = Color3.fromRGB(80, 245, 210),
	PisoMuseo = Color3.fromRGB(190, 110, 255),
}

-- Peces 3D (arte/fbx): cada MeshPart se llama como su rol y se pinta por código. El Cuerpo
-- usa Config.Peces[i].Color; el resto sale de acá. Ver ModeloPez.luau.
Estilo.Pez = {
	Aleta = 0.3, -- cuánto se oscurece el color del cuerpo hacia el contorno
	Detalle = 0.45, -- cuánto se aclara hacia blanco
	Ojo = Color3.new(1, 1, 1),
	Pupila = Color3.fromRGB(27, 31, 59),
	Brillo = Color3.new(1, 1, 1),
	DetalleOscuro = Color3.fromRGB(70, 75, 95),
	Afinado = Color3.fromRGB(255, 215, 60), -- contorno dorado del pez Afinado
	Silueta = Color3.fromRGB(45, 60, 120), -- pez que todavía no sacaste, en la vitrina
}

-- Caña del personaje y cebos (arte/fbx): se pintan por rol como los peces. Ver ModeloEquipo.luau.
-- El carrete (rol Aleta) toma el color del nivel de caña: cada mejora se ve en la mano sin
-- modelar 10 cañas. Desde NeonDesde el carrete brilla (el bloom solo agarra Neon).
Estilo.Cana = {
	Madera = Color3.fromRGB(190, 120, 70),
	Corcho = Color3.fromRGB(235, 200, 150),
	Metal = Color3.fromRGB(70, 75, 95),
	Nota = Color3.fromRGB(255, 225, 70), -- la nota de la punta, en Neon
	Linea = Color3.fromRGB(250, 245, 230), -- línea de pesca: clara, se lee sobre el agua
	Carrete = {
		Color3.fromRGB(255, 110, 90), -- 1 coral
		Color3.fromRGB(255, 170, 60), -- 2 naranja
		Color3.fromRGB(255, 225, 70), -- 3 amarillo
		Color3.fromRGB(110, 230, 110), -- 4 verde
		Color3.fromRGB(60, 200, 255), -- 5 celeste
		Color3.fromRGB(80, 120, 255), -- 6 azul
		Color3.fromRGB(170, 100, 255), -- 7 violeta
		Color3.fromRGB(255, 90, 200), -- 8 rosa
		Color3.fromRGB(230, 235, 255), -- 9 plateado
		Color3.fromRGB(255, 205, 50), -- 10 dorado
	},
	NeonDesde = 9,
	-- Pase "Carrete Dorado": en cualquier nivel. El nivel 10 ya es dorado, así que el del pase
	-- además suelta destellos: el que pagó se reconoce de lejos.
	CarreteDorado = Color3.fromRGB(255, 190, 30),
	Destello = Color3.fromRGB(255, 245, 180),
}

-- Agua del Terrain: casi opaca y sin reflejo, para que se lea como color plano.
Estilo.Agua = {
	Color = Estilo.Mundo.Agua,
	Transparencia = 0.25,
	Reflejo = 0.05,
	Olas = 0.12,
	VelocidadOlas = 8,
}

-- Luz: mediodía con sol alto (sombras cortas bajo los personajes), ambiente alto para que nada
-- quede oscuro, colores saturados y un bloom chico que solo agarra el Neon (notas, aro).
Estilo.Luz = {
	Hora = 13,
	Latitud = 20,
	Brillo = 2.6,
	Exposicion = 0.1,
	Ambiente = Color3.fromRGB(150, 150, 170),
	Exterior = Color3.fromRGB(170, 175, 200),
	Sol = Color3.fromRGB(255, 245, 225),
	Difusa = 0.4,
	Suavidad = 0.15,
	Saturacion = 0.3,
	Contraste = 0.08,
	BrilloCorreccion = 0.03,
	Bloom = { Intensidad = 0.6, Tamano = 20, Umbral = 1.6 },
	Atmosfera = {
		Densidad = 0.25,
		Desplazamiento = 0.2,
		Bruma = 0.3,
		Resplandor = 0,
		Color = Color3.fromRGB(190, 235, 255),
		Lejos = Color3.fromRGB(120, 200, 255),
	},
}

-- Highlight por modelo: el borde de afuera de cada cosa. Roblox dibuja como mucho 31 por
-- cliente, así que se usan para lo grande (muelle, puesto, palmeras) y nunca por pieza.
Estilo.Highlight = {
	-- los que usa hoy la Isla 1 (mapa a mano + pueblo + detalles) más 2 locales de cada cliente:
	-- el pez en la mano y la vitrina del museo. El tope es 31
	Maximo = 17,
	Transparencia = 0,
}

-- UI: paneles crema con borde grueso azul marino (como carteles de dibujo animado), texto
-- blanco con contorno. Nada de paneles negros semitransparentes.
Estilo.UI = {
	Fuente = Enum.Font.FredokaOne,
	Panel = Color3.fromRGB(255, 248, 230),
	PanelOscuro = Color3.fromRGB(45, 60, 120), -- carril de ritmo y barras vacías
	Borde = 4, -- grosor del UIStroke de paneles y botones (px)
	BordeTexto = 3,
	Texto = Color3.new(1, 1, 1),
	TextoOscuro = Color3.fromRGB(27, 31, 59),
	Escamas = Color3.fromRGB(70, 220, 255),
	XP = Color3.fromRGB(120, 255, 150),
	Carga = Color3.fromRGB(255, 220, 70),
	Nota = Color3.fromRGB(255, 110, 200),
	Perfecto = Color3.fromRGB(255, 230, 70),
	Bien = Color3.fromRGB(140, 225, 255),
	Error = Color3.fromRGB(255, 85, 85),
	TensionBien = Color3.fromRGB(90, 230, 110),
	TensionMal = Color3.fromRGB(255, 130, 70),
	BotonCana = Color3.fromRGB(255, 150, 50),
	BotonBalde = Color3.fromRGB(50, 170, 255),
	BotonNeutro = Color3.fromRGB(150, 110, 255),
	BotonRobux = Color3.fromRGB(0, 180, 110), -- verde Robux: se distingue de los botones de Escamas
	BotonPase = Color3.fromRGB(235, 175, 40), -- dorado del Carrete Dorado
	Esquina = 14,
}

-- Le pone el borde toon a un GuiObject (panel, botón o barra).
function Estilo.borde(gui: GuiObject, grosor: number?)
	local s = Instance.new("UIStroke")
	s.Color = Estilo.Contorno
	s.Thickness = grosor or Estilo.UI.Borde
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = gui
	-- Roblox dibuja un solo UIStroke por objeto, así que en botones el texto no puede llevar
	-- otro: usa el contorno clásico de texto, que es aparte (sin esto, letra blanca sobre
	-- naranja casi no se lee en celular).
	if gui:IsA("TextButton") or gui:IsA("TextLabel") then
		local t = gui :: any -- --!strict no siempre refina con IsA
		t.TextStrokeColor3 = Estilo.Contorno
		t.TextStrokeTransparency = 0
	end
	return s
end

-- Contorno de texto (letras blancas con raya azul marino).
function Estilo.bordeTexto(t: TextLabel | TextButton)
	local s = Instance.new("UIStroke")
	s.Color = Estilo.Contorno
	s.Thickness = Estilo.UI.BordeTexto
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = t
	return s
end

return Estilo
