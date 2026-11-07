--!strict
-- Noche del puerto: todos los valores de luz de la arena. Los aplica client/Clima.client.luau.

return {
	Hora = 1,
	Ambiente = "27304a",
	Exterior = "3a4768",
	Brillo = 0.9,
	Exposicion = 0.2,
	Tinte = "eef0fa",
	Contraste = 0.22,
	Saturacion = -0.14,
	Resplandor = 0.5,
	ResplandorUmbral = 1.7,
	ResplandorTamano = 18,
	Niebla = { Densidad = 0.14, Bruma = 0.6, Color = "2a3550" },
	-- Luz suave que sigue al personaje para que nunca se pierda.
	Borde = { Color = "a9c4ff", Brillo = 0.4, Alcance = 16 },
	-- Farolas cálidas y reflectores fríos, colocados por server/ArenaMapa.server.luau.
	Calida = { Color = "f29a3a", Brillo = 4, Alcance = 42, Angulo = 125, Haz = 0.86 },
	Fria = { Color = "cfe3ff", Brillo = 9, Alcance = 60, Angulo = 60, Haz = 0.82 },
	PisoBrillo = 0.06,
	CharcoBrillo = 0.55,
	Cielo = {
		Bk = "rbxassetid://117073989322194",
		Dn = "rbxassetid://127885275680103",
		Ft = "rbxassetid://117073989322194",
		Lf = "rbxassetid://117073989322194",
		Rt = "rbxassetid://117073989322194",
		Up = "rbxassetid://127885275680103",
	},
	Texturas = {
		Piso = "rbxassetid://75033065340692",
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
		Reflector = { X = -4, Y = 48, Z = -34, DestinoX = -2, DestinoZ = 4, Inclina = -24 },
		Charcos = {
			{ 2, -2, 16, 10, 12 },
			{ -10, 6, 12, 8, -20 },
			{ 10, -12, 10, 7, 40 },
			{ -8, -12, 14, 7, 0 },
		},
	},
	CieloDistancia = 420,
	CieloBrillo = 2.2,
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
