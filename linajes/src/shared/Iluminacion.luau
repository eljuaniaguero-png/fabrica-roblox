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
	Niebla = { Densidad = 0.3, Bruma = 1.2, Color = "7f8aa3" },
	-- Luz suave que sigue al personaje para que nunca se pierda.
	Borde = { Color = "a9c4ff", Brillo = 0.75, Alcance = 16 },
	-- Farolas cálidas y reflectores fríos, colocados por server/ArenaMapa.server.luau.
	Calida = { Color = "ffa64d", Brillo = 3.5, Alcance = 55, Angulo = 115 },
	Fria = { Color = "a9c8ff", Brillo = 6, Alcance = 60, Angulo = 90 },
	PisoBrillo = 0.06,
	CharcoBrillo = 0.55,
}
