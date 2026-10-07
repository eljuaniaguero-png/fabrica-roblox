--!strict
-- Generador de La Espiral: arma la torre entera a partir de Config.Torre y Config.Zonas.
-- No corre solo en el juego: se usa desde Studio para construir el mapa (queda guardado en el
-- lugar) y se puede volver a correr para regenerarlo. Sumar una zona = sumar una canción.
--
--   local Generador = require(ServerScriptService.Server.GeneradorTorre)
--   Generador.construir(Config, ServerStorage.Plantillas)
--
-- La pista es una espiral de radio fijo. Cada zona es una vuelta: la vuelta se reparte entre las
-- notas de su canción (una baldosa por nota, en orden). Entre zona y zona: tramo plano con la
-- puerta, escalera que atraviesa la capa de nubes y descanso con el checkpoint y su tubo de luz.
--
-- Plantillas (ServerStorage.Plantillas): Puerta, Candado (Model), Checkpoint, Bruma,
-- DoblePaso, Escudo, Tienda (Model, mira a -Z), Portal (Model, mira a -Z).

local Workspace = game:GetService("Workspace")

local GeneradorTorre = {}

type Tramo = {
	indice: number,
	notas: number,
	anguloInicio: number, -- radianes
	alturaInicio: number, -- altura del piso donde se camina
	anguloFin: number,
	alturaFin: number,
}

local MADERA = Color3.fromRGB(107, 66, 38)
local MADERA_OSCURA = Color3.fromRGB(74, 44, 23)
local BRONCE = Color3.fromRGB(217, 164, 65)
local METAL = Color3.fromRGB(138, 138, 150)
local NEGRO = Color3.fromRGB(27, 27, 31)
local LUZ_CALIDA = Color3.fromRGB(255, 216, 160)
local PIEDRA = Color3.fromRGB(78, 68, 92)
local NUBE = Color3.fromRGB(46, 52, 82) -- azul frío: con luz cálida no se ve marrón
local CIAN = Color3.fromRGB(43, 210, 255)
local ROSA = Color3.fromRGB(255, 60, 172)

-- Pieza simple, anclada. Por defecto no choca ni la atraviesan rayos (decoración).
local function parte(padre: Instance, nombre: string, propiedades: { [string]: any }): BasePart
	local forma = propiedades.Forma
	local p = Instance.new("Part")
	p.Name = nombre
	if forma then
		p.Shape = forma
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for clave, valor in propiedades do
		if clave ~= "Forma" then
			(p :: any)[clave] = valor
		end
	end
	p.Parent = padre
	return p
end

local function carpeta(padre: Instance, nombre: string): Folder
	local f = Instance.new("Folder")
	f.Name = nombre
	f.Parent = padre
	return f
end

local function luz(padre: BasePart, color: Color3, alcance: number, brillo: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = alcance
	l.Brightness = brillo
	l.Shadows = false
	l.Parent = padre
end

local function polar(angulo: number, radio: number, y: number): Vector3
	return Vector3.new(math.cos(angulo) * radio, y, math.sin(angulo) * radio)
end

-- Dirección de avance de la espiral (ángulo creciente).
local function tangente(angulo: number): Vector3
	return Vector3.new(-math.sin(angulo), 0, math.cos(angulo))
end

-- CFrame en la espiral mirando hacia adelante (-Z = avance), con X hacia afuera de la torre.
local function enPista(angulo: number, radio: number, y: number, pendiente: number?): CFrame
	local pos = polar(angulo, radio, y)
	local cf = CFrame.lookAt(pos, pos + tangente(angulo))
	return if pendiente then cf * CFrame.Angles(pendiente, 0, 0) else cf
end

-- CFrame mirando hacia el centro de la torre.
local function mirandoAlCentro(pos: Vector3): CFrame
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

-- Disco horizontal (cilindro con el eje vertical).
local function disco(
	padre: Instance,
	nombre: string,
	centro: Vector3,
	diametro: number,
	grosor: number,
	props: { [string]: any }
): BasePart
	props.Forma = Enum.PartType.Cylinder
	props.Size = Vector3.new(grosor, diametro, diametro)
	props.CFrame = CFrame.new(centro) * CFrame.Angles(0, 0, math.rad(90))
	return parte(padre, nombre, props)
end

-- Dónde empieza y termina cada zona (también las que todavía no se construyen).
function GeneradorTorre.trazado(Config: any): { Tramo }
	local t = Config.Torre
	local tramos: { Tramo } = {}
	local angulo = math.rad(t.AnguloInicio)
	local altura = t.AlturaPlaza
	local transicion = (t.LargoPuerta + t.Escalones * t.LargoEscalon + t.LargoDescanso) / t.Radio
	for indice, zona in Config.Zonas do
		local tramo: Tramo = {
			indice = indice,
			notas = #zona.Cancion.Notas,
			anguloInicio = angulo,
			alturaInicio = altura,
			anguloFin = angulo + math.pi * 2,
			alturaFin = altura + t.SubidaPorVuelta,
		}
		table.insert(tramos, tramo)
		angulo = tramo.anguloFin + transicion
		altura = tramo.alturaFin + t.Escalones -- escalones de 1 stud
	end
	return tramos
end

-- Decoración por tema, al costado de afuera de la pista. Devuelve nada; arma en `padre`.
local decoraciones: { [string]: (padre: Instance, cf: CFrame, cual: number) -> () } = {}

-- Sala de ensayo: lámparas cálidas, atriles y parlantes, sobre un estante de madera.
decoraciones.Ensayo = function(padre, cf, cual)
	parte(padre, "Estante", {
		Size = Vector3.new(5, 0.6, 5),
		CFrame = cf * CFrame.new(0, -0.3, 0),
		Color = MADERA_OSCURA,
		Material = Enum.Material.WoodPlanks,
	})
	local tipo = cual % 3
	if tipo == 0 then
		-- Lámpara de pie con luz cálida
		parte(padre, "Pie", {
			Size = Vector3.new(0.35, 7, 0.35),
			CFrame = cf * CFrame.new(0, 3.5, 0),
			Color = NEGRO,
		})
		local pantalla = parte(padre, "Pantalla", {
			Forma = Enum.PartType.Cylinder,
			Size = Vector3.new(1.6, 2.8, 2.8),
			CFrame = cf * CFrame.new(0, 7.4, 0) * CFrame.Angles(0, 0, math.rad(90)),
			Color = LUZ_CALIDA,
			Material = Enum.Material.Neon,
		})
		luz(pantalla, Color3.fromRGB(255, 190, 120), 18, 1.3)
	elseif tipo == 1 then
		-- Atril con partitura, inclinado hacia la pista
		parte(padre, "Vara", {
			Size = Vector3.new(0.25, 4, 0.25),
			CFrame = cf * CFrame.new(0, 2, 0),
			Color = METAL,
			Material = Enum.Material.Metal,
		})
		local atril = cf * CFrame.new(0, 4.3, 0) * CFrame.Angles(math.rad(25), 0, 0)
		parte(padre, "Atril", {
			Size = Vector3.new(3, 2.2, 0.15),
			CFrame = atril,
			Color = METAL,
			Material = Enum.Material.Metal,
		})
		parte(padre, "Partitura", {
			Size = Vector3.new(2.6, 1.8, 0.05),
			CFrame = atril * CFrame.new(0, 0, -0.1),
			Color = Color3.fromRGB(245, 238, 220),
		})
	else
		-- Parlante con dos conos mirando a la pista
		parte(
			padre,
			"Caja",
			{ Size = Vector3.new(3, 5, 2.6), CFrame = cf * CFrame.new(0, 2.5, 0), Color = NEGRO }
		)
		for _, datos in { { 3.6, 2.2 }, { 1.5, 1.4 } } do
			parte(padre, "Cono", {
				Forma = Enum.PartType.Cylinder,
				Size = Vector3.new(0.3, datos[2], datos[2]),
				CFrame = cf * CFrame.new(0, datos[1], -1.35) * CFrame.Angles(0, math.rad(90), 0),
				Color = Color3.fromRGB(58, 58, 66),
			})
		end
		parte(padre, "Led", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * 0.35,
			CFrame = cf * CFrame.new(1, 0.5, -1.35),
			Color = Color3.fromRGB(255, 179, 71),
			Material = Enum.Material.Neon,
		})
	end
end

local CONCRETO = Color3.fromRGB(46, 46, 58)
local NUBE_BLANCA = Color3.fromRGB(232, 230, 245)
local VIOLETA = Color3.fromRGB(123, 47, 247)
local AMARILLO = Color3.fromRGB(255, 228, 94)

-- Ciudad de noche: terrazas de edificios (la pista pasa por arriba), antenas y carteles de neón.
decoraciones.Ciudad = function(padre, cf, cual)
	local alto = 14 + (cual % 3) * 3
	parte(padre, "Edificio", {
		Size = Vector3.new(11, alto, 11),
		CFrame = cf * CFrame.new(0, -0.4 - alto / 2, 0),
		Color = CONCRETO,
		Material = Enum.Material.Concrete,
		CanCollide = true,
		CanQuery = true,
	})
	-- Ventanas: franjas de luz en la cara de afuera
	for k = -1, 1 do
		parte(padre, "Ventanas", {
			Size = Vector3.new(1, alto - 4, 0.3),
			CFrame = cf * CFrame.new(k * 3, -alto / 2 - 1, 5.6),
			Color = if k == 0 then CIAN else Color3.fromRGB(255, 214, 140),
			Material = Enum.Material.Neon,
			Transparency = 0.35,
		})
	end
	local tipo = cual % 2
	if tipo == 0 then
		-- Antena con luz roja que titila (Parpadeo.client.luau)
		parte(padre, "Antena", {
			Size = Vector3.new(0.3, 9, 0.3),
			CFrame = cf * CFrame.new(2, 4.1, 2),
			Color = METAL,
			Material = Enum.Material.Metal,
		})
		local foco = parte(padre, "LuzAntena", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * 0.9,
			CFrame = cf * CFrame.new(2, 8.8, 2),
			Color = Color3.fromRGB(255, 40, 60),
			Material = Enum.Material.Neon,
		})
		foco:SetAttribute("Parpadeo", 1.2)
	else
		-- Cartel de neón sobre la terraza, mirando a la pista
		local color = if (cual // 2) % 2 == 0 then ROSA else CIAN
		local cartel = cf * CFrame.new(0, 5, 2.5)
		for _, lado in { -1, 1 } do
			parte(padre, "PosteCartel", {
				Size = Vector3.new(0.3, 5, 0.3),
				CFrame = cf * CFrame.new(lado * 3, 2.3, 2.5),
				Color = NEGRO,
			})
			parte(padre, "Marco", {
				Size = Vector3.new(0.3, 3, 0.3),
				CFrame = cartel * CFrame.new(lado * 3.5, 0, 0),
				Color = color,
				Material = Enum.Material.Neon,
			})
			parte(padre, "Marco", {
				Size = Vector3.new(7.3, 0.3, 0.3),
				CFrame = cartel * CFrame.new(0, lado * 1.5, 0),
				Color = color,
				Material = Enum.Material.Neon,
			})
		end
		parte(padre, "Fondo", {
			Size = Vector3.new(7, 3, 0.2),
			CFrame = cartel * CFrame.new(0, 0, 0.2),
			Color = NEGRO,
		})
		parte(padre, "Letras", {
			Size = Vector3.new(4.5, 0.5, 0.25),
			CFrame = cartel,
			Color = VIOLETA,
			Material = Enum.Material.Neon,
		})
	end
end

-- Sobre las nubes: nubes chatas, plataformas pastel flotando y farolitos.
decoraciones.Nubes = function(padre, cf, cual)
	local tipo = cual % 3
	if tipo == 0 or tipo == 2 then
		for k = 1, 3 do
			local d = 8 + k * 2.5
			disco(
				padre,
				"Nube",
				(cf * CFrame.new((k - 2) * 4, -3 - k * 0.6, k * 1.5)).Position,
				d,
				2.5,
				{
					Color = NUBE_BLANCA,
					Transparency = 0.05,
				}
			)
		end
	end
	if tipo == 1 then
		local plataforma = cf
			* CFrame.new(0, 4 + (cual % 4), 10)
			* CFrame.Angles(0, math.rad(cual * 23), 0)
		parte(padre, "Plataforma", {
			Size = Vector3.new(7, 0.8, 7),
			CFrame = plataforma,
			Color = Color3.fromRGB(255, 200, 221),
		})
		parte(padre, "Borde", {
			Size = Vector3.new(7.4, 0.2, 7.4),
			CFrame = plataforma * CFrame.new(0, -0.5, 0),
			Color = Color3.fromRGB(160, 231, 255),
			Material = Enum.Material.Neon,
		})
	end
	if tipo == 2 then
		local farol = parte(padre, "Farolito", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * 1.4,
			CFrame = cf * CFrame.new(0, 3, 0),
			Color = Color3.fromRGB(200, 182, 255),
			Material = Enum.Material.Neon,
		})
		farol:SetAttribute("Parpadeo", 2.5)
	end
end

-- Espacio: planetas con anillo y estrellas sueltas.
decoraciones.Espacio = function(padre, cf, cual)
	local azar = Random.new(cual * 7 + 3)
	if cual % 2 == 0 then
		local planeta = cf
			* CFrame.new(azar:NextNumber(-6, 6), azar:NextNumber(4, 16), azar:NextNumber(18, 34))
		local colores = {
			Color3.fromRGB(255, 122, 89),
			Color3.fromRGB(43, 210, 255),
			Color3.fromRGB(200, 182, 255),
			AMARILLO,
		}
		local tam = azar:NextNumber(5, 10)
		parte(padre, "Planeta", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * tam,
			CFrame = planeta,
			Color = colores[cual % #colores + 1],
		})
		parte(padre, "AnilloPlaneta", {
			Forma = Enum.PartType.Cylinder,
			Size = Vector3.new(0.2, tam * 1.9, tam * 1.9),
			CFrame = planeta * CFrame.Angles(math.rad(70), 0, math.rad(20)),
			Color = Color3.new(1, 1, 1),
			Material = Enum.Material.Neon,
			Transparency = 0.5,
		})
	end
	for _ = 1, 3 do
		local estrella = parte(padre, "Estrella", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * azar:NextNumber(0.5, 1.1),
			CFrame = cf * CFrame.new(
				azar:NextNumber(-12, 12),
				azar:NextNumber(-10, 18),
				azar:NextNumber(8, 40)
			),
			Color = Color3.new(1, 1, 1),
			Material = Enum.Material.Neon,
		})
		estrella:SetAttribute("Parpadeo", azar:NextNumber(1.5, 3.5))
	end
end

-- Piezas grandes que van una sola vez por zona (luna, anillos de luz).
local ambientes: { [string]: (padre: Instance, centro: number, t: any) -> () } = {}

ambientes.Nubes = function(padre, centro, t)
	parte(padre, "Luna", {
		Forma = Enum.PartType.Ball,
		Size = Vector3.one * 34,
		CFrame = CFrame.new(polar(math.rad(40), t.Radio + 170, centro + 55)),
		Color = Color3.fromRGB(245, 243, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.05,
	})
end

ambientes.Espacio = function(padre, centro, t)
	-- Dos anillos de luz inclinados alrededor de la torre, hechos de tramos rectos
	for k, datos in { { 30, CIAN, 12 }, { 42, VIOLETA, -9 } } do
		local radio, color, inclinacion = t.Radio + datos[1], datos[2], math.rad(datos[3])
		local segmentos = 32
		local giro = CFrame.new(0, centro + (k - 1.5) * 6, 0)
			* CFrame.Angles(inclinacion, 0, inclinacion / 2)
		for s = 1, segmentos do
			local angulo = (s - 0.5) / segmentos * math.pi * 2
			local largo = 2 * math.pi * radio / segmentos + 0.4
			local punto = giro * CFrame.new(polar(angulo, radio, 0))
			parte(padre, "AnilloLuz", {
				Size = Vector3.new(0.5, 0.5, largo),
				CFrame = CFrame.lookAt(
					punto.Position,
					punto.Position + (giro.Rotation * tangente(angulo))
				),
				Color = color,
				Material = Enum.Material.Neon,
				Transparency = 0.2,
			})
		end
	end
end

-- Material y color de la base de las baldosas y de la baranda según el tema
-- (sin Baranda = pista abierta: te podés caer a la vuelta de abajo).
type Estilo = {
	Material: Enum.Material,
	Color: Color3,
	Baranda: Color3?,
	MaterialBaranda: Enum.Material?,
	Pasamanos: Color3?,
	MaterialPasamanos: Enum.Material?,
}
local bases: { [string]: Estilo } = {
	Ensayo = {
		Material = Enum.Material.WoodPlanks,
		Color = MADERA,
		Baranda = MADERA_OSCURA,
		MaterialBaranda = Enum.Material.WoodPlanks,
		Pasamanos = BRONCE,
		MaterialPasamanos = Enum.Material.Metal,
	},
	Ciudad = {
		Material = Enum.Material.Concrete,
		Color = CONCRETO,
		Baranda = Color3.fromRGB(62, 62, 76),
		MaterialBaranda = Enum.Material.Concrete,
		Pasamanos = ROSA,
		MaterialPasamanos = Enum.Material.Neon,
	},
	Nubes = { Material = Enum.Material.SmoothPlastic, Color = NUBE_BLANCA },
	Espacio = { Material = Enum.Material.Glass, Color = Color3.fromRGB(20, 18, 40) },
}

local function construirZona(Config: any, tramo: Tramo, destino: Instance, plantillas: Instance)
	local t = Config.Torre
	local zona = Config.Zonas[tramo.indice]
	local estilo = bases[zona.Tema] or bases.Espacio
	local modelo = Instance.new("Model")
	modelo.Name = `Zona{tramo.indice}`
	modelo.Parent = destino
	local baldosas = carpeta(modelo, "Baldosas")
	local apoyos = carpeta(modelo, "Bases")
	local deco = carpeta(modelo, "Decoracion")

	local n = tramo.notas
	local paso = math.pi * 2 / n
	local largo = t.Radio * paso
	local subida = t.SubidaPorVuelta / n
	local pendiente = math.atan2(subida, largo)
	local afuera = t.Radio + t.AnchoPista / 2

	local saltos = zona.Saltos
	for i = 1, n do
		local angulo = tramo.anguloInicio + (i - 0.5) * paso
		local y = tramo.alturaInicio + subida * (i - 0.5)
		local cf = enPista(angulo, t.Radio, y - 0.5, pendiente)
		-- Salto: esta baldosa se acorta por delante y deja un hueco hasta la siguiente.
		local recorte = if saltos and i % saltos.Cada == 0 and i < n then saltos.Hueco else 0
		cf *= CFrame.new(0, 0, recorte / 2)
		local baldosa = parte(baldosas, `Baldosa{tramo.indice}_{i}`, {
			Size = Vector3.new(t.AnchoPista, 1, largo - t.Hueco - recorte),
			CFrame = cf,
			Color = if i % 2 == 1 then zona.Principal else zona.Secundario,
			Material = Enum.Material.Neon,
			CanCollide = true,
			CanQuery = true,
		})
		baldosa:SetAttribute("Baldosa", true)
		baldosa:SetAttribute("Zona", tramo.indice)
		baldosa:SetAttribute("Nota", i)
		parte(apoyos, "Base", {
			Size = Vector3.new(t.AnchoPista + 1.2, 0.8, largo + 0.05 - recorte),
			CFrame = cf * CFrame.new(0, -0.85, 0),
			Color = estilo.Color,
			Material = estilo.Material,
			CanCollide = true,
			CanQuery = true,
		})

		-- Baranda de afuera (una cada dos baldosas): no te deja caer al vacío.
		if estilo.Baranda and i % 2 == 1 then
			local medio = tramo.alturaInicio + subida * i
			local cfBaranda =
				enPista(tramo.anguloInicio + i * paso, afuera + 0.9, medio + 1.25, pendiente)
			parte(deco, "Baranda", {
				Size = Vector3.new(0.5, 2.5, largo * 2),
				CFrame = cfBaranda,
				Color = estilo.Baranda,
				Material = estilo.MaterialBaranda or Enum.Material.SmoothPlastic,
				CanCollide = true,
				CanQuery = true,
			})
			parte(deco, "Pasamanos", {
				Size = Vector3.new(0.7, 0.3, largo * 2),
				CFrame = cfBaranda * CFrame.new(0, 1.35, 0),
				Color = estilo.Pasamanos or BRONCE,
				Material = estilo.MaterialPasamanos or Enum.Material.Metal,
			})
		end

		-- Decoración del tema, del lado de afuera
		local decorar = decoraciones[zona.Tema]
		if decorar and i % t.DecoracionCada == 3 then
			local pos = polar(angulo, afuera + 4.5, y)
			decorar(deco, mirandoAlCentro(pos), i // t.DecoracionCada)
		end
	end

	local ambiente = ambientes[zona.Tema]
	if ambiente then
		ambiente(deco, tramo.alturaInicio + t.SubidaPorVuelta / 2, t)
	end

	-- Consumibles del mapa sobre la pista (a un tercio y a dos tercios de la vuelta)
	for k, nombre in { "DoblePaso", "Escudo" } do
		local plantilla = plantillas:FindFirstChild(nombre)
		if plantilla and plantilla:IsA("BasePart") then
			local i = math.floor(n * k / 3)
			local angulo = tramo.anguloInicio + (i - 0.5) * paso
			local copia = plantilla:Clone()
			copia.CFrame = CFrame.new(polar(angulo, t.Radio, tramo.alturaInicio + subida * i + 3))
			copia.Parent = modelo
		end
	end
end

-- Puerta, escalera entre nubes, descanso con checkpoint y tubo, y la capa de nubes (bloqueo).
local function construirTransicion(
	Config: any,
	tramo: Tramo,
	destino: Instance,
	plantillas: Instance
)
	local t = Config.Torre
	local zona = Config.Zonas[tramo.indice]
	local estilo = bases[zona.Tema] or bases.Espacio
	local k = tramo.indice
	local modelo = Instance.new("Model")
	modelo.Name = `Transicion{k}`
	modelo.Parent = destino
	local R = t.Radio
	local y = tramo.alturaFin
	local inicio = tramo.anguloFin

	-- Tramo plano con la puerta
	local mitad = inicio + (t.LargoPuerta / 2) / R
	local cfPiso = enPista(mitad, R, y - 0.5)
	parte(modelo, "PisoPuerta", {
		Size = Vector3.new(t.AnchoPista + 1.2, 1, t.LargoPuerta),
		CFrame = cfPiso,
		Color = estilo.Color,
		Material = estilo.Material,
		CanCollide = true,
		CanQuery = true,
	})
	local pos = polar(mitad, R, y + t.AltoPuerta / 2)
	local haciaAtras = CFrame.lookAt(pos, pos - tangente(mitad)) -- mira al que llega
	local plantillaPuerta = plantillas:FindFirstChild("Puerta")
	if plantillaPuerta and plantillaPuerta:IsA("BasePart") then
		local puerta = plantillaPuerta:Clone()
		puerta.Name = `Puerta{k}`
		puerta.Size = Vector3.new(t.AnchoPista + 1, t.AltoPuerta, 1)
		puerta.CFrame = haciaAtras
		puerta:SetAttribute("PuertaIndice", k)
		puerta.Parent = modelo
	end
	for _, lado in { -1, 1 } do
		parte(modelo, "Poste", {
			Size = Vector3.new(0.8, t.AltoPuerta + 1, 0.8),
			CFrame = haciaAtras * CFrame.new(lado * (t.AnchoPista / 2 + 0.9), 0.5, 0),
			Color = ROSA,
			Material = Enum.Material.Neon,
		})
	end
	parte(modelo, "Dintel", {
		Size = Vector3.new(t.AnchoPista + 2.6, 0.8, 0.8),
		CFrame = haciaAtras * CFrame.new(0, t.AltoPuerta / 2 + 0.6, 0),
		Color = ROSA,
		Material = Enum.Material.Neon,
	})

	-- Escalera (escalones de 1 stud)
	local escalera = carpeta(modelo, "Escalera")
	local base = inicio + t.LargoPuerta / R
	for j = 1, t.Escalones do
		local angulo = base + ((j - 0.5) * t.LargoEscalon) / R
		parte(escalera, "Escalon", {
			Size = Vector3.new(t.AnchoPista, 1.2, t.LargoEscalon + 0.05),
			CFrame = enPista(angulo, R, y + j - 0.6),
			Color = estilo.Color,
			Material = estilo.Material,
			CanCollide = true,
			CanQuery = true,
		})
	end

	-- Descanso con checkpoint (más ancho hacia adentro, para el tubo de luz)
	local arriba = y + t.Escalones
	local anguloDescanso = base + (t.Escalones * t.LargoEscalon + t.LargoDescanso / 2) / R
	local plantillaCheckpoint = plantillas:FindFirstChild("Checkpoint")
	if plantillaCheckpoint and plantillaCheckpoint:IsA("BasePart") then
		local checkpoint = plantillaCheckpoint:Clone()
		checkpoint.Name = `Checkpoint{k}`
		checkpoint.Size = Vector3.new(t.AnchoPista + 8, 1, t.LargoDescanso)
		checkpoint.CFrame = enPista(anguloDescanso, R - 4, arriba - 0.5)
		checkpoint.Material = Enum.Material.SmoothPlastic -- piso oscuro: el neón encandila
		checkpoint.Color = Color3.fromRGB(24, 58, 74)
		checkpoint:SetAttribute("CheckpointIndice", k)
		checkpoint.Parent = modelo
		-- Filo de luz cian alrededor del descanso
		local tam = checkpoint.Size
		for _, lado in { -1, 1 } do
			parte(modelo, "Filo", {
				Size = Vector3.new(0.3, 0.2, tam.Z),
				CFrame = checkpoint.CFrame * CFrame.new(lado * (tam.X / 2 - 0.15), 0.55, 0),
				Color = CIAN,
				Material = Enum.Material.Neon,
			})
			parte(modelo, "Filo", {
				Size = Vector3.new(tam.X, 0.2, 0.3),
				CFrame = checkpoint.CFrame * CFrame.new(0, 0.55, lado * (tam.Z / 2 - 0.15)),
				Color = CIAN,
				Material = Enum.Material.Neon,
			})
		end
	end
	GeneradorTorre.tubo(modelo, polar(anguloDescanso, R - 9.5, arriba), "Bajar")

	-- Capa de nubes: tapa todo lo de arriba hasta que abrís la puerta (Bloqueos.client.luau)
	local bloqueo = Instance.new("Model")
	bloqueo.Name = `Bloqueo{k}`
	bloqueo.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	bloqueo:SetAttribute("BloqueoPuerta", k)
	bloqueo.Parent = modelo
	local alturaNubes = y + t.AlturaNubes
	disco(
		bloqueo,
		"Niebla",
		Vector3.new(0, alturaNubes, 0),
		t.RadioNubes * 2,
		t.GrosorNubes,
		{ Color = NUBE }
	)
	local azar = Random.new(k * 31)
	-- Panza de la nube: discos chatos a distintas alturas (desde abajo se ve despareja, no lisa)
	for _ = 1, 26 do
		local diametro = azar:NextNumber(30, 70)
		local centro = polar(
			azar:NextNumber(0, math.pi * 2),
			azar:NextNumber(10, t.RadioNubes - diametro / 2),
			alturaNubes - t.GrosorNubes / 2 - azar:NextNumber(0.5, 3)
		)
		disco(bloqueo, "Nube", centro, diametro, azar:NextNumber(2, 4), {
			Color = NUBE:Lerp(Color3.new(1, 1, 1), azar:NextNumber(0, 0.08)),
		})
	end
	local plantillaBruma = plantillas:FindFirstChild("Bruma")
	if plantillaBruma and plantillaBruma:IsA("BasePart") then
		local bruma = plantillaBruma:Clone()
		bruma.Size = Vector3.new(R * 2 + 30, 1, R * 2 + 30)
		bruma.CFrame = CFrame.new(0, alturaNubes - t.GrosorNubes / 2 - 3, 0)
		bruma.Parent = bloqueo
	end
	local plantillaCandado = plantillas:FindFirstChild("Candado")
	if plantillaCandado and plantillaCandado:IsA("Model") then
		local candado = plantillaCandado:Clone()
		candado.Name = "Candado"
		candado:PivotTo(haciaAtras * CFrame.new(0, t.AltoPuerta / 2 + 4.6, -0.6))
		candado.Parent = bloqueo
	end
end

-- Cima: después de la última zona, un descanso con checkpoint, tubo para bajar y una estrella.
local function construirCima(Config: any, tramo: Tramo, destino: Instance, plantillas: Instance)
	local t = Config.Torre
	local R = t.Radio
	local modelo = Instance.new("Model")
	modelo.Name = "Cima"
	modelo.Parent = destino
	local angulo = tramo.anguloFin + (t.LargoDescanso / 2) / R
	local y = tramo.alturaFin
	local plantilla = plantillas:FindFirstChild("Checkpoint")
	if plantilla and plantilla:IsA("BasePart") then
		local checkpoint = plantilla:Clone()
		checkpoint.Name = `Checkpoint{tramo.indice}`
		checkpoint.Size = Vector3.new(t.AnchoPista + 8, 1, t.LargoDescanso)
		checkpoint.CFrame = enPista(angulo, R - 4, y - 0.5)
		checkpoint.Material = Enum.Material.SmoothPlastic
		checkpoint.Color = Color3.fromRGB(60, 50, 20)
		checkpoint:SetAttribute("CheckpointIndice", tramo.indice)
		checkpoint.Parent = modelo
	end
	GeneradorTorre.tubo(modelo, polar(angulo, R - 9.5, y), "Bajar")
	-- Estrella: dos cruces de neón amarillo que giran (Parpadeo hace que brille)
	local centro = CFrame.new(polar(angulo, R - 1, y + 9))
	for k = 0, 3 do
		parte(modelo, "Estrella", {
			Size = Vector3.new(1, 9, 1),
			CFrame = centro * CFrame.Angles(0, math.rad(90) * (k % 2), math.rad(45) * k),
			Color = AMARILLO,
			Material = Enum.Material.Neon,
		})
	end
	local nucleo = parte(modelo, "NucleoEstrella", {
		Forma = Enum.PartType.Ball,
		Size = Vector3.one * 3,
		CFrame = centro,
		Color = Color3.new(1, 1, 1),
		Material = Enum.Material.Neon,
	})
	nucleo:SetAttribute("Parpadeo", 0.8)
	luz(nucleo, AMARILLO, 24, 2)
end

-- Tubo de luz: "Bajar" (en cada checkpoint, te lleva a la plaza) o "Subir" (en la plaza, te
-- devuelve a tu checkpoint). Lo maneja Tubos.luau.
function GeneradorTorre.tubo(padre: Instance, piso: Vector3, tipo: string)
	local modelo = Instance.new("Model")
	modelo.Name = `Tubo{tipo}`
	modelo.Parent = padre
	local cuerpo = parte(modelo, "Tubo", {
		Forma = Enum.PartType.Cylinder,
		Size = Vector3.new(12, 6, 6),
		CFrame = CFrame.new(piso + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = CIAN,
		Material = Enum.Material.Neon,
		Transparency = 0.75,
	})
	cuerpo:SetAttribute("Tubo", tipo)
	parte(modelo, "Nucleo", {
		Forma = Enum.PartType.Cylinder,
		Size = Vector3.new(12, 1, 1),
		CFrame = cuerpo.CFrame,
		Color = Color3.new(1, 1, 1),
		Material = Enum.Material.Neon,
		Transparency = 0.4,
	})
	disco(
		modelo,
		"Aro",
		piso + Vector3.new(0, 0.1, 0),
		7,
		0.2,
		{ Color = CIAN, Material = Enum.Material.Neon }
	)
	local aviso = Instance.new("ProximityPrompt")
	aviso.ActionText = if tipo == "Bajar" then "Bajar a la plaza" else "Volver al checkpoint"
	aviso.ObjectText = "Tubo de luz"
	aviso.HoldDuration = 0
	aviso.MaxActivationDistance = 9
	aviso.RequiresLineOfSight = false
	aviso.Parent = cuerpo
end

local function construirPlaza(Config: any, destino: Instance, plantillas: Instance)
	local t = Config.Torre
	local y = t.AlturaPlaza
	local inicio = math.rad(t.AnguloInicio)
	local plaza = Instance.new("Model")
	plaza.Name = "Plaza"
	plaza.Parent = destino

	local piso = disco(plaza, "Piso", Vector3.new(0, y - 1, 0), t.RadioPlaza * 2, 2, {
		Color = PIEDRA,
		Material = Enum.Material.Slate,
		CanCollide = true,
		CanQuery = true,
	})
	piso.CastShadow = true
	disco(plaza, "Filo", Vector3.new(0, y - 0.2, 0), t.RadioPlaza * 2 + 0.8, 0.3, {
		Color = Color3.fromRGB(255, 179, 71),
		Material = Enum.Material.Neon,
	})
	-- Círculo de luz en el piso alrededor del tambor
	disco(plaza, "Circulo", Vector3.new(0, y + 0.02, 0), (t.RadioTambor + 8) * 2 + 0.6, 0.04, {
		Color = Color3.fromRGB(255, 179, 71),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
	})
	disco(
		plaza,
		"CirculoInterior",
		Vector3.new(0, y + 0.05, 0),
		(t.RadioTambor + 8) * 2 - 0.6,
		0.04,
		{
			Color = PIEDRA,
			Material = Enum.Material.Slate,
		}
	)

	-- Tambor gigante: la base de la torre
	local RT, AT = t.RadioTambor, t.AltoTambor
	local tambor = Instance.new("Model")
	tambor.Name = "Tambor"
	tambor.Parent = plaza
	disco(tambor, "Cuerpo", Vector3.new(0, y + AT / 2, 0), RT * 2, AT, {
		Color = Color3.fromRGB(150, 40, 75),
		CanCollide = true,
		CanQuery = true,
	})
	disco(tambor, "Parche", Vector3.new(0, y + AT + 0.2, 0), RT * 2 - 0.4, 0.4, {
		Color = Color3.fromRGB(233, 216, 180),
		CanCollide = true,
	})
	for _, alto in { 0.5, AT - 0.1 } do
		disco(tambor, "Aro", Vector3.new(0, y + alto, 0), RT * 2 + 0.8, 1, {
			Color = BRONCE,
			Material = Enum.Material.Metal,
		})
	end
	for k = 1, 12 do
		local angulo = k / 12 * math.pi * 2
		parte(tambor, "Tensor", {
			Size = Vector3.new(0.45, AT - 1.4, 0.45),
			CFrame = CFrame.new(polar(angulo, RT + 0.35, y + AT / 2)),
			Color = BRONCE,
			Material = Enum.Material.Metal,
		})
	end
	for _, giro in { 25, -25 } do
		local palillo = CFrame.new(0, y + AT + 1, 0) * CFrame.Angles(0, math.rad(giro), 0)
		parte(tambor, "Palillo", {
			Forma = Enum.PartType.Cylinder,
			Size = Vector3.new(20, 1, 1),
			CFrame = palillo,
			Color = Color3.fromRGB(200, 155, 109),
			Material = Enum.Material.Wood,
		})
		parte(tambor, "Punta", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * 1.6,
			CFrame = palillo * CFrame.new(10, 0, 0),
			Color = Color3.fromRGB(233, 216, 180),
		})
	end

	-- Inicio (cerca de donde arranca la zona 1)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Inicio"
	spawn.Size = Vector3.new(8, 0.2, 8)
	spawn.CFrame = mirandoAlCentro(polar(inicio - math.rad(18), 34, y + 0.1))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(255, 179, 71)
	spawn.Transparency = 0.8
	spawn.TopSurface = Enum.SurfaceType.Smooth
	for _, hijo in spawn:GetChildren() do
		hijo:Destroy()
	end
	spawn.Parent = plaza

	-- Vendedor y portal de rebirth (plantillas del mapa anterior), mirando al centro
	local function ubicar(nombre: string, angulo: number, radio: number)
		local plantilla = plantillas:FindFirstChild(nombre)
		if plantilla and plantilla:IsA("Model") then
			local copia = plantilla:Clone()
			local pos = polar(angulo, radio, y)
			local cf = mirandoAlCentro(pos)
			copia:PivotTo(cf)
			copia.Parent = plaza
		end
	end
	ubicar("Tienda", inicio + math.rad(140), 32)
	ubicar("Portal", inicio + math.rad(220), 33)
	GeneradorTorre.tubo(plaza, polar(inicio + math.rad(60), 34, y), "Subir")

	-- Faroles cálidos en la plaza
	for _, grados in { 25, 100, 180, 290 } do
		local pos = polar(inicio + math.rad(grados), 41, y)
		parte(plaza, "Farol", {
			Size = Vector3.new(0.5, 8, 0.5),
			CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)),
			Color = NEGRO,
		})
		local foco = parte(plaza, "Foco", {
			Forma = Enum.PartType.Ball,
			Size = Vector3.one * 1.6,
			CFrame = CFrame.new(pos + Vector3.new(0, 8.4, 0)),
			Color = LUZ_CALIDA,
			Material = Enum.Material.Neon,
		})
		luz(foco, Color3.fromRGB(255, 190, 120), 28, 1.6)
	end
end

-- Eje central: un tramo por zona, que se prende al completar su canción (EjeCentral.client.luau).
local function construirEje(Config: any, tramos: { Tramo }, destino: Instance)
	local t = Config.Torre
	local eje = Instance.new("Model")
	eje.Name = "Eje"
	eje.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	eje.Parent = destino
	local abajo = t.AlturaPlaza + t.AltoTambor + 0.4
	for indice, tramo in tramos do
		local siguiente = tramos[indice + 1]
		local techo = if siguiente then siguiente.alturaInicio else tramo.alturaFin + 12
		local desde = if indice == 1 then abajo else tramo.alturaInicio
		local pieza = parte(eje, `Tramo{indice}`, {
			Forma = Enum.PartType.Cylinder,
			Size = Vector3.new(techo - desde - 0.6, t.RadioEje * 2, t.RadioEje * 2),
			CFrame = CFrame.new(0, (desde + techo) / 2, 0) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(70, 60, 110),
			Material = Enum.Material.SmoothPlastic,
		})
		pieza:SetAttribute("Zona", indice)
		-- Anillos tenues del color de la zona: el eje se ve aunque esté apagado
		local zona = Config.Zonas[indice]
		for y = desde + 4, techo - 2, 8 do
			disco(eje, "Marca", Vector3.new(0, y, 0), t.RadioEje * 2 + 0.3, 0.4, {
				Color = zona.Principal,
				Material = Enum.Material.Neon,
				Transparency = 0.55,
			})
		end
		disco(eje, "Anillo", Vector3.new(0, techo, 0), t.RadioEje * 2 + 1.2, 0.6, {
			Color = BRONCE,
			Material = Enum.Material.Metal,
		})
	end
end

-- Arma (o rearma) Workspace.Torre. Devuelve un resumen para el registro.
function GeneradorTorre.construir(Config: any, plantillas: Instance): string
	local viejo = Workspace:FindFirstChild("Torre")
	if viejo then
		viejo:Destroy()
	end
	local torre = Instance.new("Folder")
	torre.Name = "Torre"

	local tramos = GeneradorTorre.trazado(Config)
	local construidas = math.min(Config.Torre.ZonasConstruidas, #tramos)
	construirPlaza(Config, torre, plantillas)
	for indice = 1, construidas do
		construirZona(Config, tramos[indice], torre, plantillas)
		if indice < #tramos then
			construirTransicion(Config, tramos[indice], torre, plantillas)
		else
			construirCima(Config, tramos[indice], torre, plantillas)
		end
	end
	construirEje(Config, tramos, torre)
	torre.Parent = Workspace

	local partes, luces = 0, 0
	for _, objeto in torre:GetDescendants() do
		if objeto:IsA("BasePart") then
			partes += 1
		elseif objeto:IsA("PointLight") then
			luces += 1
		end
	end
	return `Torre: {construidas} zona(s), {partes} piezas, {luces} luces`
end

return GeneradorTorre
