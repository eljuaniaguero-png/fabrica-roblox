--!strict
-- Las piezas de las criaturas, hechas con formas simples (esferas, cilindros, bloques, cuñas).
-- Todas se encastran en los mismos "enchufes" del esqueleto, así cualquier combinación encaja:
--   patas: del piso (y = 0) hasta y = 1.7
--   cuerpo: centrado en (0, 2.5, 0), unos 3 de largo
--   cabeza: centrada en (0, 3.9, -1.7)   (el frente de la criatura mira a -Z)
--   cola: sale de (0, 2.8, 1.55)
--   alas: a los costados del lomo

local Paleta = require(script.Parent.Paleta)

export type Ctx = {
	Modelo: Model,
	Origen: CFrame,
	Color: Color3,
	Manchas: Color3,
	Personalidad: string?, -- cambia los ojos (ver `ojo`)
}

type Constructor = (ctx: Ctx) -> ()

local CENTRO_CUERPO = Vector3.new(0, 2.5, 0)
local CENTRO_CABEZA = Vector3.new(0, 3.9, -1.7)
local BASE_COLA = Vector3.new(0, 2.8, 1.55)

local BLANCO = Paleta.Piezas.Blanco
local NEGRO = Paleta.Piezas.Negro
local CREMA = Paleta.Piezas.Crema -- cara del hongo

local Piezas = {}

---------------------------------------------------------------------------
-- Ayudas para crear partes
---------------------------------------------------------------------------

local function nueva(ctx: Ctx, clase: string, cf: CFrame, tam: Vector3, color: Color3): BasePart
	local p = Instance.new(clase) :: BasePart
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = tam
	p.Color = color
	p.CFrame = ctx.Origen * cf
	p.Parent = ctx.Modelo
	return p
end

local function bola(ctx: Ctx, pos: Vector3, diam: number, color: Color3?): BasePart
	local p = nueva(ctx, "Part", CFrame.new(pos), Vector3.one * diam, color or ctx.Color);
	(p :: Part).Shape = Enum.PartType.Ball
	return p
end

local function bloque(ctx: Ctx, cf: CFrame, tam: Vector3, color: Color3?): BasePart
	return nueva(ctx, "Part", cf, tam, color or ctx.Color)
end

local function cunia(ctx: Ctx, cf: CFrame, tam: Vector3, color: Color3?): BasePart
	return nueva(ctx, "WedgePart", cf, tam, color or ctx.Color)
end

-- Cilindro con su eje en la dirección indicada ("X", "Y" o "Z").
local function cilindro(
	ctx: Ctx,
	cf: CFrame,
	eje: string,
	largo: number,
	diam: number,
	color: Color3?
): BasePart
	local giro = CFrame.identity
	if eje == "Y" then
		giro = CFrame.Angles(0, 0, math.rad(90))
	elseif eje == "Z" then
		giro = CFrame.Angles(0, math.rad(90), 0)
	end
	local p = nueva(ctx, "Part", cf * giro, Vector3.new(largo, diam, diam), color or ctx.Color);
	(p :: Part).Shape = Enum.PartType.Cylinder
	return p
end

local function neon(p: BasePart): BasePart
	p.Material = Enum.Material.Neon
	return p
end

-- Las partes de los ojos llevan nombre para que el generador no las pinte ni las apague.
local function nombrar(p: BasePart, nombre: string): BasePart
	p.Name = nombre
	return p
end

-- Ojos grandes: lo que más hace "tierna" a una criatura. Esfera blanca, pupila negra y un
-- punto de brillo; el borde oscuro hace que se lean también sobre cabezas blancas.
-- La personalidad los cambia (guía, punto 5): Alegre, arqueados de felicidad; Vaga, párpados
-- a media altura; Peleadora, cejas en ángulo; Miedosa, pupilas chiquitas; Curiosa, un ojo
-- más grande que el otro. `lado` es -1 o 1 (izquierdo o derecho) y 0 para un ojo del medio.
local function ojo(ctx: Ctx, pos: Vector3, tam: number, lado: number)
	local personalidad = ctx.Personalidad
	if personalidad == "Curiosa" and lado ~= 0 then
		tam *= if lado < 0 then 1.25 else 0.85
	end
	local pupila = if personalidad == "Miedosa" then 0.26 else 0.55
	nombrar(bola(ctx, pos + Vector3.new(0, 0, 0.12), tam * 1.14, NEGRO), "Ojo")
	nombrar(bola(ctx, pos, tam, BLANCO), "Ojo")
	nombrar(bola(ctx, pos + Vector3.new(0, 0, -tam * 0.32), tam * pupila, NEGRO), "Ojo")
	nombrar(
		neon(bola(ctx, pos + Vector3.new(tam * 0.12, tam * 0.14, -tam * 0.5), tam * 0.18, BLANCO)),
		"Brillo"
	)
	if personalidad == "Vaga" then
		-- Párpado del color de la cabeza que tapa la mitad de arriba.
		bola(ctx, pos + Vector3.new(0, tam * 0.5, -tam * 0.08), tam * 1.2)
	elseif personalidad == "Alegre" then
		-- Cachete que sube y deja el ojo como un arco.
		bola(ctx, pos + Vector3.new(0, -tam * 0.62, -tam * 0.1), tam * 1.12)
	elseif personalidad == "Peleadora" and lado ~= 0 then
		-- Ceja inclinada hacia el centro de la cara.
		nombrar(
			bloque(
				ctx,
				CFrame.new(pos + Vector3.new(0, tam * 0.66, -tam * 0.4))
					* CFrame.Angles(0, 0, math.rad(lado * 28)),
				Vector3.new(tam * 1.05, tam * 0.24, tam * 0.3),
				NEGRO
			),
			"Ceja"
		)
	end
end

local function ojos(ctx: Ctx, centro: Vector3, radio: number, separacion: number, tam: number)
	for _, s in { -1, 1 } do
		ojo(ctx, centro + Vector3.new(s * separacion, 0.1, -radio * 0.8), tam, s)
	end
end

---------------------------------------------------------------------------
-- Cabezas
---------------------------------------------------------------------------

local cabezas: { Constructor } = {}

-- 1 Glupona: gota con dos ojos grandes
cabezas[1] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.9)
	bola(ctx, c + Vector3.new(0, 0.85, 0.1), 1.05)
	bola(ctx, c + Vector3.new(0, 1.35, 0.15), 0.5)
	ojos(ctx, c, 0.95, 0.42, 0.72)
end

-- 2 Rámulo: óvalo con dos brotes de hojas
cabezas[2] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.7)
	bola(ctx, c + Vector3.new(0, 0.45, 0), 1.5)
	for _, s in { -1, 1 } do
		bloque(
			ctx,
			CFrame.new(c + Vector3.new(s * 0.35, 1.45, 0)) * CFrame.Angles(0, 0, math.rad(-s * 35)),
			Vector3.new(0.18, 0.9, 0.55),
			ctx.Manchas
		)
	end
	ojos(ctx, c, 0.85, 0.38, 0.55)
end

-- 3 Sutomi: sombrero de hongo con lunares
cabezas[3] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.5, CREMA)
	cilindro(ctx, CFrame.new(c + Vector3.new(0, 0.75, 0)), "Y", 0.6, 2.8)
	bola(ctx, c + Vector3.new(0, 1.0, 0), 2.0)
	for _, p in
		{ Vector3.new(0.7, 1.45, 0.2), Vector3.new(-0.6, 1.45, -0.4), Vector3.new(-0.1, 1.75, 0.5) }
	do
		bola(ctx, c + p, 0.5, ctx.Manchas)
	end
	ojos(ctx, c + Vector3.new(0, -0.1, 0), 0.75, 0.3, 0.48)
end

-- 4 Rocote: bloque cuadrado con cejas de piedra
cabezas[4] = function(ctx)
	local c = CENTRO_CABEZA
	bloque(ctx, CFrame.new(c), Vector3.new(1.9, 1.6, 1.7))
	for _, s in { -1, 1 } do
		bloque(
			ctx,
			CFrame.new(c + Vector3.new(s * 0.45, 0.55, -0.9))
				* CFrame.Angles(0, 0, math.rad(s * 12)),
			Vector3.new(0.65, 0.22, 0.25),
			ctx.Manchas
		)
	end
	ojos(ctx, c + Vector3.new(0, 0, 0.05), 0.95, 0.45, 0.5)
end

-- 5 Chisparo: triangular con cuernitos de brasa
cabezas[5] = function(ctx)
	local c = CENTRO_CABEZA
	bloque(ctx, CFrame.new(c), Vector3.new(1.5, 1.15, 1.5))
	cunia(ctx, CFrame.new(c + Vector3.new(0, -0.12, -1.15)), Vector3.new(1.3, 0.9, 0.8))
	for _, s in { -1, 1 } do
		neon(
			cunia(
				ctx,
				CFrame.new(c + Vector3.new(s * 0.45, 0.85, 0.2)),
				Vector3.new(0.3, 0.6, 0.5),
				Paleta.Piezas.Naranja
			)
		)
	end
	ojos(ctx, c + Vector3.new(0, 0.2, 0), 0.95, 0.42, 0.45)
end

-- 6 Dunaqui: hocico largo y orejas enormes
cabezas[6] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.6)
	cilindro(ctx, CFrame.new(c + Vector3.new(0, -0.2, -1.0)), "Z", 1.0, 0.7)
	bola(ctx, c + Vector3.new(0, -0.2, -1.55), 0.4, NEGRO)
	for _, s in { -1, 1 } do
		local oreja = CFrame.new(c + Vector3.new(s * 0.6, 1.1, 0.1))
			* CFrame.Angles(0, 0, math.rad(-s * 22))
		bloque(ctx, oreja, Vector3.new(0.2, 1.4, 0.8))
		bloque(ctx, oreja * CFrame.new(0, 0, -0.06), Vector3.new(0.22, 1.0, 0.5), ctx.Manchas)
	end
	ojos(ctx, c + Vector3.new(0, 0.25, 0), 0.8, 0.36, 0.45)
end

-- 7 Zoplito: pico redondo con penacho
cabezas[7] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.7)
	cunia(
		ctx,
		CFrame.new(c + Vector3.new(0, -0.15, -1.05)),
		Vector3.new(0.65, 0.45, 0.6),
		Paleta.Piezas.Naranja
	)
	for i, x in { -0.18, 0, 0.18 } do
		bloque(
			ctx,
			CFrame.new(c + Vector3.new(x, 1.0 + (i == 2 and 0.15 or 0), 0.15))
				* CFrame.Angles(math.rad(-20), 0, math.rad(-x * 120)),
			Vector3.new(0.12, 0.8, 0.35),
			ctx.Manchas
		)
	end
	ojos(ctx, c + Vector3.new(0, 0.2, 0), 0.85, 0.38, 0.5)
end

-- 8 Brinoza: redonda con cuernos de carámbano
cabezas[8] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.8)
	for _, s in { -1, 1 } do
		local cuerno = bloque(
			ctx,
			CFrame.new(c + Vector3.new(s * 0.6, 0.95, 0)) * CFrame.Angles(0, 0, math.rad(-s * 22)),
			Vector3.new(0.32, 1.0, 0.32),
			ctx.Manchas
		)
		cuerno.Material = Enum.Material.Glass
		cuerno.Transparency = 0.15
	end
	ojos(ctx, c, 0.9, 0.4, 0.5)
end

-- 9 Fotina: alargada con antenas de bombita
cabezas[9] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.5)
	bola(ctx, c + Vector3.new(0, -0.35, -0.2), 1.3)
	for _, s in { -1, 1 } do
		cilindro(
			ctx,
			CFrame.new(c + Vector3.new(s * 0.38, 1.15, 0)) * CFrame.Angles(0, 0, math.rad(-s * 15)),
			"Y",
			1.0,
			0.12,
			NEGRO
		)
		neon(bola(ctx, c + Vector3.new(s * 0.52, 1.7, 0), 0.45, ctx.Manchas))
	end
	ojos(ctx, c, 0.75, 0.32, 0.5)
end

-- 10 Nerulo: tres ojitos y orejas puntiagudas
cabezas[10] = function(ctx)
	local c = CENTRO_CABEZA
	bola(ctx, c, 1.7)
	for _, s in { -1, 1 } do
		cunia(ctx, CFrame.new(c + Vector3.new(s * 0.55, 0.95, 0.1)), Vector3.new(0.28, 0.85, 0.6))
	end
	ojo(ctx, c + Vector3.new(-0.38, 0.05, -0.68), 0.4, -1)
	ojo(ctx, c + Vector3.new(0.38, 0.05, -0.68), 0.4, 1)
	ojo(ctx, c + Vector3.new(0, 0.45, -0.7), 0.4, 0)
end

---------------------------------------------------------------------------
-- Cuerpos (devuelven nada; las flores del rasgo 2 se apoyan en ALTURA_LOMO)
---------------------------------------------------------------------------

local cuerpos: { Constructor } = {}

-- Altura del lomo de cada cuerpo, para apoyar cosas arriba.
Piezas.AlturaLomo = { 3.95, 3.95, 3.6, 3.7, 3.45, 3.6, 3.8, 3.95, 3.45, 3.25 }

-- 1 bola gelatinosa translúcida
cuerpos[1] = function(ctx)
	local p = bola(ctx, CENTRO_CUERPO, 2.9)
	p.Transparency = 0.25
	p.Material = Enum.Material.Glass
	bola(ctx, CENTRO_CUERPO, 1.3, ctx.Manchas)
end

-- 2 tronco corto cubierto de musgo
cuerpos[2] = function(ctx)
	cilindro(ctx, CFrame.new(CENTRO_CUERPO), "Z", 3.0, 2.3)
	bloque(
		ctx,
		CFrame.new(CENTRO_CUERPO + Vector3.new(0, 1.0, 0)),
		Vector3.new(1.7, 0.4, 2.6),
		ctx.Manchas
	)
end

-- 3 tallo petiso y gordito
cuerpos[3] = function(ctx)
	cilindro(ctx, CFrame.new(CENTRO_CUERPO), "Y", 2.2, 2.5)
	cilindro(ctx, CFrame.new(CENTRO_CUERPO + Vector3.new(0, 0, -1.22)), "Z", 0.1, 1.4, ctx.Manchas)
end

-- 4 caparazón de lajas
cuerpos[4] = function(ctx)
	bloque(ctx, CFrame.new(CENTRO_CUERPO), Vector3.new(2.4, 1.9, 3.0))
	for _, s in { -1, 1 } do
		bloque(
			ctx,
			CFrame.new(CENTRO_CUERPO + Vector3.new(0, 1.05, s * 0.7))
				* CFrame.Angles(math.rad(s * 10), 0, 0),
			Vector3.new(2.1, 0.28, 1.4),
			ctx.Manchas
		)
	end
end

-- 5 torso de lagarto con escamas
cuerpos[5] = function(ctx)
	cilindro(ctx, CFrame.new(CENTRO_CUERPO), "Z", 2.4, 1.9)
	for _, z in { -1.2, 1.2 } do
		bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0, z), 1.9)
	end
	for _, z in { -0.8, 0, 0.8 } do
		cunia(
			ctx,
			CFrame.new(CENTRO_CUERPO + Vector3.new(0, 1.05, z)),
			Vector3.new(0.3, 0.45, 0.6),
			ctx.Manchas
		)
	end
end

-- 6 cuerpo con joroba
cuerpos[6] = function(ctx)
	bloque(ctx, CFrame.new(CENTRO_CUERPO + Vector3.new(0, -0.3, 0)), Vector3.new(2.2, 1.5, 3.0))
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0.5, 0.2), 2.1)
	for _, s in { -1, 1 } do
		bola(ctx, CENTRO_CUERPO + Vector3.new(s * 1.0, 0.1, 0.4), 0.7, ctx.Manchas)
	end
end

-- 7 cuerpo de plumas, liviano
cuerpos[7] = function(ctx)
	bola(ctx, CENTRO_CUERPO, 2.6)
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, -0.15, -0.55), 1.9, ctx.Manchas)
	for _, s in { -1, 1 } do
		cunia(
			ctx,
			CFrame.new(CENTRO_CUERPO + Vector3.new(s * 1.1, 0.2, 0.7))
				* CFrame.Angles(0, math.rad(180), 0),
			Vector3.new(0.25, 0.8, 1.0)
		)
	end
end

-- 8 pelaje esponjoso
cuerpos[8] = function(ctx)
	for _, x in { -0.55, 0.55 } do
		for _, z in { -0.6, 0.6 } do
			bola(ctx, CENTRO_CUERPO + Vector3.new(x, 0, z), 1.9)
		end
	end
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0.75, 0), 1.7)
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, -0.1, -1.1), 1.1, ctx.Manchas)
end

-- 9 cuerpo de insecto en segmentos
cuerpos[9] = function(ctx)
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0, -1.0), 1.5)
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0.1, 0), 1.7, ctx.Manchas)
	bola(ctx, CENTRO_CUERPO + Vector3.new(0, 0, 1.1), 1.9)
end

-- 10 cuerpo largo y flexible
cuerpos[10] = function(ctx)
	local c = CENTRO_CUERPO + Vector3.new(0, -0.1, 0)
	cilindro(ctx, CFrame.new(c), "Z", 2.8, 1.6)
	for _, z in { -1.4, 1.4 } do
		bola(ctx, c + Vector3.new(0, 0, z), 1.6)
	end
	bloque(ctx, CFrame.new(c + Vector3.new(0, 0.72, 0)), Vector3.new(0.6, 0.25, 2.6), ctx.Manchas)
end

---------------------------------------------------------------------------
-- Patas
---------------------------------------------------------------------------

local patas: { Constructor } = {}

local CUATRO = {
	Vector3.new(-0.8, 0, -0.9),
	Vector3.new(0.8, 0, -0.9),
	Vector3.new(-0.8, 0, 0.9),
	Vector3.new(0.8, 0, 0.9),
}

-- 1 cuatro patitas de ventosa
patas[1] = function(ctx)
	for _, p in CUATRO do
		cilindro(ctx, CFrame.new(p + Vector3.new(0, 1.05, 0)), "Y", 1.3, 0.5)
		bola(ctx, p + Vector3.new(0, 0.35, 0), 0.75, ctx.Manchas)
	end
end

-- 2 seis raíces cortas
patas[2] = function(ctx)
	for _, s in { -1, 1 } do
		for _, z in { -0.9, 0, 0.9 } do
			cilindro(
				ctx,
				CFrame.new(Vector3.new(s * 0.95, 0.85, z)) * CFrame.Angles(0, 0, math.rad(s * 20)),
				"Y",
				1.9,
				0.32,
				ctx.Manchas
			)
		end
	end
end

-- 3 dos patas gruesas
patas[3] = function(ctx)
	for _, s in { -1, 1 } do
		cilindro(ctx, CFrame.new(Vector3.new(s * 0.65, 0.95, 0)), "Y", 1.6, 1.0)
		bloque(
			ctx,
			CFrame.new(Vector3.new(s * 0.65, 0.18, -0.15)),
			Vector3.new(1.1, 0.36, 1.4),
			ctx.Manchas
		)
	end
end

-- 4 cuatro patas cortas tipo columna
patas[4] = function(ctx)
	for _, p in CUATRO do
		bloque(ctx, CFrame.new(p + Vector3.new(0, 0.85, 0)), Vector3.new(0.85, 1.7, 0.85))
		bloque(
			ctx,
			CFrame.new(p + Vector3.new(0, 0.12, 0)),
			Vector3.new(1.0, 0.24, 1.0),
			ctx.Manchas
		)
	end
end

-- 5 cuatro patas de lagartija (abiertas hacia los costados)
patas[5] = function(ctx)
	for _, p in CUATRO do
		local s = math.sign(p.X)
		bloque(ctx, CFrame.new(Vector3.new(s * 1.15, 1.45, p.Z)), Vector3.new(0.9, 0.38, 0.38))
		bloque(ctx, CFrame.new(Vector3.new(s * 1.5, 0.75, p.Z)), Vector3.new(0.38, 1.4, 0.38))
		bola(ctx, Vector3.new(s * 1.55, 0.22, p.Z - 0.15), 0.5, ctx.Manchas)
	end
end

-- 6 patas anchas en forma de pala
patas[6] = function(ctx)
	for _, p in CUATRO do
		cilindro(ctx, CFrame.new(p + Vector3.new(0, 0.95, 0)), "Y", 1.6, 0.6)
		bloque(
			ctx,
			CFrame.new(p + Vector3.new(0, 0.13, -0.15)),
			Vector3.new(1.0, 0.26, 1.1),
			ctx.Manchas
		)
	end
end

-- 7 dos patas finas de ave
patas[7] = function(ctx)
	local naranja = Paleta.Piezas.Naranja
	for _, s in { -1, 1 } do
		cilindro(ctx, CFrame.new(Vector3.new(s * 0.5, 0.9, 0)), "Y", 1.7, 0.24, naranja)
		for _, a in { -30, 0, 30 } do
			bloque(
				ctx,
				CFrame.new(Vector3.new(s * 0.5, 0.06, 0))
					* CFrame.Angles(0, math.rad(a), 0)
					* CFrame.new(0, 0, -0.25),
				Vector3.new(0.14, 0.12, 0.55),
				naranja
			)
		end
	end
end

-- 8 patas peludas con garritas
patas[8] = function(ctx)
	for _, p in CUATRO do
		cilindro(ctx, CFrame.new(p + Vector3.new(0, 1.0, 0)), "Y", 1.4, 0.85)
		bola(ctx, p + Vector3.new(0, 0.42, -0.05), 0.95)
		for _, x in { -0.22, 0, 0.22 } do
			bloque(
				ctx,
				CFrame.new(p + Vector3.new(x, 0.12, -0.5)),
				Vector3.new(0.12, 0.2, 0.25),
				ctx.Manchas
			)
		end
	end
end

-- 9 seis patitas de insecto
patas[9] = function(ctx)
	for _, s in { -1, 1 } do
		for _, z in { -0.9, 0.1, 1.1 } do
			cilindro(
				ctx,
				CFrame.new(Vector3.new(s * 0.95, 0.8, z)) * CFrame.Angles(0, 0, math.rad(s * 35)),
				"Y",
				1.9,
				0.2,
				NEGRO
			)
		end
	end
end

-- 10 cuatro patas largas y sigilosas
patas[10] = function(ctx)
	for _, p in CUATRO do
		local q = Vector3.new(p.X * 0.85, 0, p.Z * 1.1)
		cilindro(ctx, CFrame.new(q + Vector3.new(0, 0.95, 0)), "Y", 1.7, 0.34)
		bola(ctx, q + Vector3.new(0, 0.2, -0.05), 0.45, ctx.Manchas)
	end
end

---------------------------------------------------------------------------
-- Colas y alas
---------------------------------------------------------------------------

local extremidades: { Constructor } = {}

-- Una cola enroscada hecha de bolitas que se achican.
local function rulo(ctx: Ctx, centro: Vector3, radio: number, vueltas: number, plano: string)
	local cantidad = 8
	for i = 0, cantidad do
		local t = i / cantidad
		local a = math.pi - t * vueltas * 2 * math.pi
		local r = radio * (1 - t * 0.55)
		local desplazamiento
		if plano == "YZ" then
			desplazamiento = Vector3.new(0, math.sin(a) * r, math.cos(a) * r)
		else
			desplazamiento =
				Vector3.new(math.sin(a) * r, math.cos(a) * r * 0.3 + t * 0.9, math.cos(a) * r)
		end
		bola(
			ctx,
			centro + desplazamiento,
			0.62 - t * 0.3,
			i == cantidad and ctx.Manchas or ctx.Color
		)
	end
end

-- 1 cola de renacuajo
extremidades[1] = function(ctx)
	local aleta = bloque(
		ctx,
		CFrame.new(BASE_COLA + Vector3.new(0, 0.1, 1.0)) * CFrame.Angles(math.rad(-12), 0, 0),
		Vector3.new(0.25, 1.1, 2.1)
	)
	aleta.Transparency = 0.15
	bloque(
		ctx,
		CFrame.new(BASE_COLA + Vector3.new(0, 0.3, 1.9)) * CFrame.Angles(math.rad(-12), 0, 0),
		Vector3.new(0.27, 0.7, 0.4),
		ctx.Manchas
	)
end

-- 2 cola de enredadera enrollada
extremidades[2] = function(ctx)
	rulo(ctx, BASE_COLA + Vector3.new(0, 0, 0.75), 0.75, 0.85, "YZ")
end

-- 3 cola corta en bolita de esporas
extremidades[3] = function(ctx)
	cilindro(ctx, CFrame.new(BASE_COLA + Vector3.new(0, 0, 0.3)), "Z", 0.6, 0.5)
	bola(ctx, BASE_COLA + Vector3.new(0, 0.1, 0.85), 1.15, ctx.Manchas)
	for _, p in
		{ Vector3.new(0.35, 0.4, 0.95), Vector3.new(-0.3, 0.3, 1.1), Vector3.new(0, -0.2, 1.3) }
	do
		neon(bola(ctx, BASE_COLA + p, 0.22, ctx.Color))
	end
end

-- 4 cola de maza (bola de piedra)
extremidades[4] = function(ctx)
	cilindro(ctx, CFrame.new(BASE_COLA + Vector3.new(0, -0.15, 0.7)), "Z", 1.4, 0.45)
	bola(ctx, BASE_COLA + Vector3.new(0, -0.15, 1.5), 1.15, ctx.Manchas)
end

-- 5 cola con una llama en la punta
extremidades[5] = function(ctx)
	local giro = CFrame.new(BASE_COLA) * CFrame.Angles(math.rad(30), 0, 0)
	cilindro(ctx, giro * CFrame.new(0, 0, 0.8), "Z", 1.6, 0.5)
	local punta = (giro * CFrame.new(0, 0, 1.7)).Position
	neon(bola(ctx, punta, 0.85, Paleta.Piezas.Llama))
	neon(bola(ctx, punta + Vector3.new(0, 0.35, 0.05), 0.5, Paleta.Piezas.Amarillo))
end

-- 6 cola en espiral
extremidades[6] = function(ctx)
	rulo(ctx, BASE_COLA + Vector3.new(0, -0.1, 0.65), 0.65, 1.4, "XZ")
end

-- 7 alas grandes y redondas
extremidades[7] = function(ctx)
	for _, s in { -1, 1 } do
		local base = CFrame.new(Vector3.new(s * 1.35, 3.35, 0.1))
			* CFrame.Angles(0, 0, math.rad(s * 25))
		cilindro(ctx, base, "X", 0.16, 2.1)
		cilindro(ctx, base * CFrame.new(s * 0.05, 0, 0), "X", 0.16, 1.2, ctx.Manchas)
	end
end

-- 8 cola de cristales de hielo
extremidades[8] = function(ctx)
	for i, a in { -25, 0, 25 } do
		local cristal = bloque(
			ctx,
			CFrame.new(BASE_COLA + Vector3.new(0, 0, 0.3))
				* CFrame.Angles(0, math.rad(a), 0)
				* CFrame.Angles(math.rad(55), 0, 0)
				* CFrame.new(0, i == 2 and 0.8 or 0.6, 0),
			Vector3.new(0.38, i == 2 and 1.6 or 1.2, 0.38),
			ctx.Manchas
		)
		cristal.Material = Enum.Material.Glass
		cristal.Transparency = 0.15
	end
end

-- 9 alas transparentes (dos pares)
extremidades[9] = function(ctx)
	for _, s in { -1, 1 } do
		for i, z in { 0.2, 1.0 } do
			local ala = bloque(
				ctx,
				CFrame.new(Vector3.new(s * 0.9, 3.65 - i * 0.15, z))
					* CFrame.Angles(0, math.rad(s * (i == 1 and 15 or 35)), math.rad(-s * 60))
					* CFrame.new(0, 0.9, 0),
				Vector3.new(0.08, 1.9, 0.85),
				ctx.Manchas
			)
			ala.Material = Enum.Material.Neon
			ala.Transparency = 0.25
		end
	end
end

-- 10 alas de membrana
extremidades[10] = function(ctx)
	-- Abanico de tres "dedos" de membrana, abiertos hacia los costados y de frente
	-- (si el ala queda de canto a la cámara, desde adelante no se ve).
	for _, s in { -1, 1 } do
		local hombro = Vector3.new(s * 0.7, 3.4, 0.5)
		for i, a in { 15, 40, 65 } do
			local brazo = CFrame.new(hombro) * CFrame.Angles(0, 0, math.rad(s * a))
			bloque(
				ctx,
				brazo * CFrame.new(s * 0.95, 0, 0),
				Vector3.new(1.9 - i * 0.15, 0.75, 0.1),
				ctx.Manchas
			)
		end
		cilindro(
			ctx,
			CFrame.new(hombro)
				* CFrame.Angles(0, 0, math.rad(s * 75))
				* CFrame.new(s * 1.0, 0, -0.06),
			"X",
			2.0,
			0.18,
			NEGRO
		)
	end
end

---------------------------------------------------------------------------
-- Rasgos especiales (solo visuales; los de movimiento los hace Animacion)
---------------------------------------------------------------------------

local function particulas(
	raiz: BasePart,
	pos: Vector3,
	color: Color3,
	props: { [string]: any }
): ParticleEmitter
	local a = Instance.new("Attachment")
	a.Position = pos
	a.Parent = raiz
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 0.6
	e.Size = NumberSequence.new(0.25)
	e.Transparency = NumberSequence.new(0.2, 1)
	e.Lifetime = NumberRange.new(1, 1.6)
	e.Rate = 4
	e.Speed = NumberRange.new(1, 2)
	e.SpreadAngle = Vector2.new(30, 30)
	for k, v in props do
		(e :: any)[k] = v
	end
	e.Parent = a
	return e
end

local rasgos: { (ctx: Ctx, raiz: BasePart, cuerpo: number) -> () } = {}

rasgos[1] = function(_ctx, raiz)
	particulas(raiz, Vector3.new(0, 2.5, 0), Paleta.Piezas.Burbujas, {
		Size = NumberSequence.new(0.35),
		Acceleration = Vector3.new(0, 1.5, 0),
	})
end

rasgos[2] = function(ctx, _raiz, cuerpo)
	local y = Piezas.AlturaLomo[cuerpo]
	for _, p in { Vector3.new(0.45, 0, 0.5), Vector3.new(-0.5, 0, 0.1), Vector3.new(0.1, 0, -0.4) } do
		bola(ctx, Vector3.new(p.X, y - 0.05, p.Z), 0.45, Paleta.Piezas.Flores)
		bola(ctx, Vector3.new(p.X, y + 0.12, p.Z), 0.22, Paleta.Piezas.Amarillo)
	end
end

rasgos[3] = function(_ctx, raiz)
	particulas(raiz, Vector3.new(0, 3.5, 0), Paleta.Piezas.Esporas, {
		LightEmission = 1,
		Size = NumberSequence.new(0.18),
		Acceleration = Vector3.new(0, 0.8, 0),
		Rate = 6,
	})
end

rasgos[4] = function() end -- rueda: lo hace la animación

rasgos[5] = function(_ctx, raiz)
	particulas(raiz, Vector3.new(0, 0.3, 0), Paleta.Piezas.Naranja, {
		LightEmission = 1,
		Size = NumberSequence.new(0.15),
		Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(70, 70),
		Lifetime = NumberRange.new(0.4, 0.7),
		Rate = 8,
	})
end

rasgos[6] = function() end -- se entierra: lo hace la animación
rasgos[7] = function() end -- flota: lo hace la animación

rasgos[8] = function(_ctx, raiz)
	particulas(raiz, Vector3.new(0, 0.2, 0), Paleta.Piezas.Nieve, {
		Size = NumberSequence.new(0.2),
		Speed = NumberRange.new(0.5, 1.5),
		SpreadAngle = Vector2.new(80, 80),
		Acceleration = Vector3.new(0, -1, 0),
	})
end

rasgos[9] = function(_ctx, raiz)
	local luz = Instance.new("PointLight")
	luz.Color = Paleta.Piezas.Luz
	luz.Range = 10
	luz.Brightness = 2
	luz.Parent = raiz
end

rasgos[10] = function() end -- semitransparente: lo hace la animación

-- Brillo dorado de la versión mutante.
function Piezas.estrellas(raiz: BasePart)
	particulas(raiz, Vector3.new(0, 3, 0), Paleta.Mutante, {
		LightEmission = 1,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.4, 0.55),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Speed = NumberRange.new(1, 2.5),
		SpreadAngle = Vector2.new(180, 180),
		Lifetime = NumberRange.new(0.8, 1.4),
		Rate = 16,
		RotSpeed = NumberRange.new(-90, 90),
	})
end

-- Aura de la generación 3.
function Piezas.aura(raiz: BasePart)
	particulas(raiz, Vector3.new(0, 2.6, 0), Paleta.Piezas.Aura, {
		LightEmission = 1,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.35),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Speed = NumberRange.new(0.3, 0.8),
		SpreadAngle = Vector2.new(180, 180),
		Lifetime = NumberRange.new(1.2, 2),
		Rate = 10,
		Shape = Enum.ParticleEmitterShape.Sphere,
	})
end

Piezas.Cabezas = cabezas
Piezas.Cuerpos = cuerpos
Piezas.Patas = patas
Piezas.Extremidades = extremidades
Piezas.Rasgos = rasgos

return Piezas
