--!strict
-- GENERADO por arte/scripts/mascotas.py: no editar a mano, cambiar el script y volver a correrlo.
--
-- Articulaciones y animación en bucle de las mascotas importadas (arte/fbx/Mascota_<Id>.fbx).
-- Todo en studs y ejes de Roblox (frente -Z, arriba Y), al tamaño original de Blender:
--   Lado    lado más largo de la mascota entera (para escalar: factor = tamaño real / Lado)
--   Centro  centro de su caja; corresponde al centro de Model:GetBoundingBox()
--   Pivote  articulación de cada pieza (MeshPart con ese nombre). Posición en el modelo:
--           cajaCFrame * CFrame.new((Pivote - Centro) * factor)
--   Rebota  la pieza sigue al Rebote (cuerpo); si es false queda en el piso (patas)
--
-- Cada movimiento, con t = (tiempo / Periodo) % 1:
--   Onda    Amplitud * sin(2π (t * Veces + Fase))  (Rot en radianes, Pos en studs)
--   Salto   Amplitud * |sin(π t Veces)| en Y (studs)
--   Vuelta  Amplitud * t (una vuelta entera por Periodo)
--   Escala  tamaño en X y Z = 1 + Amplitud * sin(2π t)
-- Rot y Pos son relativos al pivote de la pieza. Las posiciones se multiplican por el factor.

export type Mov = {
	Tipo: string,
	Canal: string,
	Eje: string,
	Amplitud: number,
	Fase: number,
	Veces: number,
}

export type Pieza = {
	Pivote: Vector3,
	Rebota: boolean,
	Movs: { Mov },
}

export type Rig = {
	Lado: number,
	Centro: Vector3,
	Rebote: { Mov },
	Piezas: { [string]: Pieza },
}

local MascotasRig: { Periodo: number, Mascotas: { [string]: Rig } } = {
	Periodo = 1.333,
	Mascotas = {
		Topito = {
			Lado = 5.25,
			Centro = Vector3.new(0, 1.5, -0.225),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.12, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Cavadin_Cabeza = {
					Pivote = Vector3.new(0, 1.6, -0.9),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.175, Fase = 0.25, Veces = 1 },
					},
				},
				Cavadin_Cola = {
					Pivote = Vector3.new(0, 0.95, 1.75),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.524, Fase = 0, Veces = 2 },
					},
				},
				Cavadin_Cuerpo = {
					Pivote = Vector3.new(0, 1, 0),
					Rebota = true,
					Movs = {},
				},
				Cavadin_Garra1 = {
					Pivote = Vector3.new(-0.95, 0.8, -0.95),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.384, Fase = 0, Veces = 1 },
					},
				},
				Cavadin_Garra2 = {
					Pivote = Vector3.new(0.95, 0.8, -0.95),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.384, Fase = 0.5, Veces = 1 },
					},
				},
				Cavadin_Pata1 = {
					Pivote = Vector3.new(-0.8, 0.55, 1.2),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.384, Fase = 0, Veces = 1 },
					},
				},
				Cavadin_Pata2 = {
					Pivote = Vector3.new(0.8, 0.55, 1.2),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.384, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
		Piedrin = {
			Lado = 4.65,
			Centro = Vector3.new(0, 2.325, 0),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.15, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Pedrusco_Brazo1 = {
					Pivote = Vector3.new(-1.3, 2.85, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.524, Fase = 0, Veces = 1 },
					},
				},
				Pedrusco_Brazo2 = {
					Pivote = Vector3.new(1.3, 2.85, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.524, Fase = 0.5, Veces = 1 },
					},
				},
				Pedrusco_Cabeza = {
					Pivote = Vector3.new(0, 3.1, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.175, Fase = 0.25, Veces = 1 },
					},
				},
				Pedrusco_Pierna1 = {
					Pivote = Vector3.new(-0.55, 1.4, 0),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.349, Fase = 0.5, Veces = 1 },
					},
				},
				Pedrusco_Pierna2 = {
					Pivote = Vector3.new(0.55, 1.4, 0),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.349, Fase = 0, Veces = 1 },
					},
				},
				Pedrusco_Torso = {
					Pivote = Vector3.new(0, 1.5, 0),
					Rebota = true,
					Movs = {},
				},
			},
		},
		Chispa = {
			Lado = 5.25,
			Centro = Vector3.new(0, 1.725, 0.225),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.18, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Brasita_Cabeza = {
					Pivote = Vector3.new(0, 1.8, -0.95),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.105, Fase = 0, Veces = 2 },
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.14, Fase = 0.25, Veces = 1 },
					},
				},
				Brasita_Cola = {
					Pivote = Vector3.new(0, 1.55, 1.35),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.524, Fase = 0, Veces = 2 },
					},
				},
				Brasita_Cuerpo = {
					Pivote = Vector3.new(0, 1.25, 0),
					Rebota = true,
					Movs = {},
				},
				Brasita_Pata1 = {
					Pivote = Vector3.new(-0.4, 1, -0.6),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Brasita_Pata2 = {
					Pivote = Vector3.new(0.4, 1, 0.95),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
				Brasita_Pata3 = {
					Pivote = Vector3.new(0.4, 1, -0.6),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Brasita_Pata4 = {
					Pivote = Vector3.new(-0.4, 1, 0.95),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
		Musgo = {
			Lado = 4.35,
			Centro = Vector3.new(0, 1.125, -0.375),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.08, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Jadeita_Cabeza = {
					Pivote = Vector3.new(0, 0.8, -1.3),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Pos", Eje = "Z", Amplitud = -0.18, Fase = 0, Veces = 1 },
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.175, Fase = 0.25, Veces = 1 },
					},
				},
				Jadeita_Caparazon = {
					Pivote = Vector3.new(0, 0.55, 0),
					Rebota = true,
					Movs = {},
				},
				Jadeita_Cola = {
					Pivote = Vector3.new(0, 0.6, 1.4),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.436, Fase = 0, Veces = 2 },
					},
				},
				Jadeita_Pata1 = {
					Pivote = Vector3.new(-1, 0.6, -0.9),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.314, Fase = 0, Veces = 1 },
					},
				},
				Jadeita_Pata2 = {
					Pivote = Vector3.new(1, 0.6, 0.9),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.314, Fase = 0.5, Veces = 1 },
					},
				},
				Jadeita_Pata3 = {
					Pivote = Vector3.new(1, 0.6, -0.9),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.314, Fase = 0, Veces = 1 },
					},
				},
				Jadeita_Pata4 = {
					Pivote = Vector3.new(-1, 0.6, 0.9),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.314, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
		Cuarcito = {
			Lado = 3.75,
			Centro = Vector3.new(-0.375, 1.875, 0),
			Rebote = {
				{ Tipo = "Onda", Canal = "Pos", Eje = "Y", Amplitud = 0.25, Fase = 0, Veces = 1 },
			},
			Piezas = {
				Prismo_Cuerpo = {
					Pivote = Vector3.new(0, 2.2, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.244, Fase = 0, Veces = 1 },
					},
				},
				Prismo_Orbita = {
					Pivote = Vector3.new(0, 2.2, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Vuelta", Canal = "Rot", Eje = "Y", Amplitud = 6.283, Fase = 0, Veces = 1 },
					},
				},
				Prismo_Sombra = {
					Pivote = Vector3.new(0, 0, 0),
					Rebota = false,
					Movs = {
						{ Tipo = "Escala", Canal = "Esc", Eje = "XZ", Amplitud = -0.15, Fase = 0, Veces = 1 },
					},
				},
			},
		},
		Glaciel = {
			Lado = 3.45,
			Centro = Vector3.new(0, 1.725, -0.075),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.15, Fase = 0, Veces = 2 },
				{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = 0.122, Fase = 0, Veces = 1 },
			},
			Piezas = {
				Escarchin_Aleta1 = {
					Pivote = Vector3.new(-0.8, 1.85, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = -0.489, Fase = 0, Veces = 2 },
					},
				},
				Escarchin_Aleta2 = {
					Pivote = Vector3.new(0.8, 1.85, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = 0.489, Fase = 0, Veces = 2 },
					},
				},
				Escarchin_Cabeza = {
					Pivote = Vector3.new(0, 2.05, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.087, Fase = 0, Veces = 2 },
					},
				},
				Escarchin_Cuerpo = {
					Pivote = Vector3.new(0, 0.3, 0),
					Rebota = true,
					Movs = {},
				},
				Escarchin_Pie1 = {
					Pivote = Vector3.new(-0.35, 0.3, -0.2),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.262, Fase = 0, Veces = 1 },
					},
				},
				Escarchin_Pie2 = {
					Pivote = Vector3.new(0.35, 0.3, -0.2),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.262, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
		Magmo = {
			Lado = 5.85,
			Centro = Vector3.new(0, 1.95, 0.225),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.15, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Fraguon_Ala1 = {
					Pivote = Vector3.new(-0.7, 2.2, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = -0.559, Fase = 0, Veces = 2 },
					},
				},
				Fraguon_Ala2 = {
					Pivote = Vector3.new(0.7, 2.2, 0),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = 0.559, Fase = 0, Veces = 2 },
					},
				},
				Fraguon_Cabeza = {
					Pivote = Vector3.new(0, 2, -0.9),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.105, Fase = 0, Veces = 2 },
					},
				},
				Fraguon_Cola = {
					Pivote = Vector3.new(0, 1.35, 1.4),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.436, Fase = 0, Veces = 2 },
					},
				},
				Fraguon_Cuerpo = {
					Pivote = Vector3.new(0, 1.4, 0),
					Rebota = true,
					Movs = {},
				},
				Fraguon_Pata1 = {
					Pivote = Vector3.new(-0.55, 1, -0.5),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Fraguon_Pata2 = {
					Pivote = Vector3.new(0.55, 1, 1),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
				Fraguon_Pata3 = {
					Pivote = Vector3.new(0.55, 1, -0.5),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Fraguon_Pata4 = {
					Pivote = Vector3.new(-0.55, 1, 1),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
		Nebula = {
			Lado = 4.35,
			Centro = Vector3.new(0, 1.575, 0.075),
			Rebote = {
				{ Tipo = "Salto", Canal = "Pos", Eje = "Y", Amplitud = 0.18, Fase = 0, Veces = 2 },
			},
			Piezas = {
				Astralis_Cabeza = {
					Pivote = Vector3.new(0, 1.7, -0.9),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Y", Amplitud = 0.157, Fase = 0.25, Veces = 1 },
					},
				},
				Astralis_Cola = {
					Pivote = Vector3.new(0, 1.45, 1.35),
					Rebota = true,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "Z", Amplitud = 0.314, Fase = 0, Veces = 2 },
					},
				},
				Astralis_Cuerpo = {
					Pivote = Vector3.new(0, 1.2, 0),
					Rebota = true,
					Movs = {},
				},
				Astralis_Pata1 = {
					Pivote = Vector3.new(-0.38, 0.95, -0.55),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Astralis_Pata2 = {
					Pivote = Vector3.new(0.38, 0.95, 0.95),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
				Astralis_Pata3 = {
					Pivote = Vector3.new(0.38, 0.95, -0.55),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0, Veces = 1 },
					},
				},
				Astralis_Pata4 = {
					Pivote = Vector3.new(-0.38, 0.95, 0.95),
					Rebota = false,
					Movs = {
						{ Tipo = "Onda", Canal = "Rot", Eje = "X", Amplitud = -0.489, Fase = 0.5, Veces = 1 },
					},
				},
			},
		},
	},
}

return MascotasRig
