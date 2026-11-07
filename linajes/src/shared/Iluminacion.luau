--!strict
-- Noche del puerto: todos los valores de luz de la arena. Los aplica client/Clima.client.luau.

return {
	Hora = 1,
	Ambiente = "2e3850",
	Exterior = "445380",
	Brillo = 1.1,
	Exposicion = 0.2,
	Tinte = "e4e9ff",
	Contraste = 0.18,
	Saturacion = -0.08,
	Resplandor = 0.7,
	ResplandorUmbral = 1.3,
	ResplandorTamano = 22,
	Niebla = { Densidad = 0.18, Bruma = 0.4, Color = "7f8aa3" },
	-- Luz suave que sigue al personaje para que nunca se pierda.
	Borde = { Color = "a9c4ff", Brillo = 0.75, Alcance = 16 },
	-- Farolas cálidas y reflectores fríos, colocados por server/ArenaMapa.server.luau.
	Calida = { Color = "ff9a3c", Brillo = 7, Alcance = 42, Angulo = 125 },
	Fria = { Color = "c4d8ff", Brillo = 9, Alcance = 60, Angulo = 70 },
	PisoBrillo = 0.06,
	CharcoBrillo = 0.55,
	Cielo = {
		Bk = "rbxassetid://79523488749061",
		Dn = "rbxassetid://73769727771919",
		Ft = "rbxassetid://76506551755697",
		Lf = "rbxassetid://79523488749061",
		Rt = "rbxassetid://110437939502254",
		Up = "rbxassetid://123732981660928",
	},
	CieloDistancia = 900,
	CieloBrillo = 1,
	Galpon = {
		X = 118,
		Z = -92,
		Ventana = "#b87a3a",
		LuzVentana = { Color = "ffb868", Brillo = 1.6, Alcance = 18 },
		LuzPuerta = { Color = "ffb868", Brillo = 3, Alcance = 26 },
	},
	Barco = {
		X = -40,
		Z = -172,
		Luces = { -80, -30, 20 },
		Luz = { Color = "ffe2b0", Brillo = 1.5, Alcance = 22 },
	},
	Roja = { Y = 163, Z = -168, Pausa = 1 },
}
