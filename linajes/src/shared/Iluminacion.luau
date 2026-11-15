--!strict
-- Noche del puerto: todos los valores de luz de la arena. Los aplica client/Clima.client.luau.

return {
	Hora = 21.35,
	Ambiente = "1f283d",
	Exterior = "4c6294",
	Brillo = 1.35,
	Exposicion = 0.24,
	Tinte = "e8eeff",
	Contraste = 0.26,
	Saturacion = 0.04,
	Resplandor = 0.48,
	ResplandorUmbral = 1.65,
	ResplandorTamano = 22,
	-- Niebla: lo lejano se funde con leve tinte eclipse hacia el horizonte.
	Niebla = {
		Densidad = 0.28,
		Bruma = 0.52,
		Color = "23314d",
		Decaimiento = "4a242c",
		Destello = 0.12,
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
	Calida = { Color = "f29a3a", Brillo = 9, Alcance = 48, Angulo = 74, Haz = 0.84 },
	Fria = { Color = "8ab8ff", Brillo = 11, Alcance = 68, Angulo = 52, Haz = 0.82 },
	PisoBrillo = 0.06,
	CharcoBrillo = 0.68,
	-- Noche de verdad: azul casi negro con estrellas tenues pintadas en la textura.
	Cielo = {
		Bk = "rbxassetid://137180182185044",
		Dn = "rbxassetid://70751777794900",
		Ft = "rbxassetid://137180182185044",
		Lf = "rbxassetid://137180182185044",
		Rt = "rbxassetid://137180182185044",
		Up = "rbxassetid://89737934447295",
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
