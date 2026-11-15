--!strict
-- Noche del puerto: todos los valores de luz de la arena. Los aplica client/Clima.client.luau.

return {
	Hora = 21.35,
	-- Valores de la Guía de estilo 1.1 (Puerto Óxido, noche), ajustados el 15 nov 2026:
	-- sombras azul pizarra (nunca negras) y un solo foco cálido en el centro.
	-- La tabla de la Guía quedaba muy oscura en Roblox: más brillo y exposición, mismos tonos.
	Ambiente = "3a4870",
	Exterior = "6478ad",
	Brillo = 2.4,
	Exposicion = 0.45,
	Tinte = "eef0ff",
	Contraste = 0.14,
	Saturacion = -0.02,
	Resplandor = 0.26,
	ResplandorUmbral = 1.65,
	ResplandorTamano = 22,
	-- Niebla: lo lejano se funde con leve tinte eclipse hacia el horizonte.
	Niebla = {
		Densidad = 0.36,
		Desplazamiento = 0.25, -- el horizonte se funde con el cielo pintado
		Bruma = 1.6,
		Color = "2a3550",
		Decaimiento = "2e2232", -- leve tinte del eclipse a lo lejos
		Destello = 0.15,
	},
	RayosSol = { Intensidad = 0.06, Dispersion = 0.42 },
	Eclipse = {
		Color = "f26b3a",
		Tamano = 108,
		Direccion = Vector3.new(-0.18, 0.34, -0.92).Unit,
	},
	-- Luz suave que sigue al personaje para destacar la silueta cómic sin lavar sombras.
	Borde = { Color = "9cc0ff", Brillo = 0.65, Alcance = 18 },
	-- Farolas cálidas y reflectores fríos, colocados por server/ArenaMapa.server.luau.
	-- Angulo chico = cono de luz marcado en el piso, no una mancha pareja.
	Calida = { Color = "f29a3a", Brillo = 9, Alcance = 48, Angulo = 74, Haz = 0.9 },
	Fria = { Color = "8ab8ff", Brillo = 11, Alcance = 68, Angulo = 52, Haz = 0.94 }, -- haz casi invisible: de arriba parecía una ruta
	-- Foco sodio sobre el círculo central: guía la vista a la pelea (Guía 1.1, regla 2).
	Foco = { Altura = 46, Color = "f29a3a", Brillo = 12, Alcance = 80, Angulo = 64, Charco = 34 },
	PisoBrillo = 0.06,
	CharcoBrillo = 0.68,
	-- Noche de verdad: azul casi negro con estrellas tenues pintadas en la textura.
	-- Cielo propio (arte/cielo/): degradé azul noche, nubes con tinta y resplandor sodio del puerto.
	Cielo = {
		Bk = "rbxassetid://129994114880332",
		Dn = "rbxassetid://70751777794900",
		Ft = "rbxassetid://129994114880332",
		Lf = "rbxassetid://129994114880332",
		Rt = "rbxassetid://129994114880332",
		Up = "rbxassetid://101980913952007",
	},
	Estrellas = 900,
	-- De noche Roblox apaga el skybox: la arena lo dibuja con paneles lejanos que siguen
	-- a la cámara (client/CieloArena.client.luau).
	CieloDistancia = 420,
	CieloBrillo = 1,
	Texturas = {
		Piso = "rbxassetid://82415998089554",
		Sombra = "rbxassetid://115998922807089",
		Charco = "rbxassetid://127320075658676",
		Reflejo = "rbxassetid://140017634433020",
	},
	PisoTile = 40,
	-- Rincón de prueba: X y Z son su centro, relativos al centro de la arena.
	Rincon = {
		X = -110,
		Z = -110,
		Tonos = { "#7a4036", "#4a5a6c", "#6c7078" },
		TonoBarril = "#3f5566",
		TonoBita = "#3a4048",
		Ventana = "#c98a45",
		Farola = { X = 2, Z = -8 },
		-- Lámpara chica: la luz la hace el SpotLight, no un cartel amarillo.
		Lampara = { Ancho = 1.6, Alto = 0.5, Largo = 1.6, Tono = "#ffcf8a", Transparencia = 0.25 },
		Reflector = { X = -4, Y = 48, Z = -34, DestinoX = -2, DestinoZ = 4, Inclina = -24 },
		Charcos = {
			{ 2, -2, 16, 10, 12 },
			{ -10, 6, 12, 8, -20 },
			{ 10, -12, 10, 7, 40 },
			{ -8, -12, 14, 7, 0 },
		},
	},
	Galpon = {
		X = 118,
		Z = -92,
		Ventana = "#b87a3a",
		LuzVentana = { Color = "ffb868", Brillo = 1.6, Alcance = 18 },
		LuzPuerta = { Color = "ffb868", Brillo = 3, Alcance = 26 },
	},
	Barco = {
		X = 150,
		Z = -172,
		Luces = { -80, -30, 20 },
		Luz = { Color = "ffe2b0", Brillo = 1.5, Alcance = 22 },
	},
	Roja = { Y = 163, Z = -168, Pausa = 1 },
}
