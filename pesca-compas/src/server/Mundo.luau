--!strict
-- Muelle de la Isla 1 en estilo "Toon de playa" (shared/Estilo.luau): colores planos y un
-- Highlight azul marino por modelo (muelle, playa, puesto, palmeras), que es el contorno grueso.
-- Se arma solo si en Workspace no hay una carpeta "Muelle", así no pisa nada que se haya
-- construido a mano en Studio. Las medidas y posiciones son las mismas del prototipo gris.
-- Marca con tags: "PuntoPesca" (desde donde se tira; su LookVector apunta al agua) y
-- "Vendedor" (tiene el ProximityPrompt de vender).

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Estilo = require(ReplicatedStorage.Shared.Estilo)

local M = Estilo.Mundo

local Mundo = {}

local function parte(padre: Instance, nombre: string, tam: Vector3, cf: CFrame, color: Color3): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Reflectance = 0
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = padre
	return p
end

local function bola(padre: Instance, nombre: string, diametro: number, pos: Vector3, color: Color3): Part
	local p = parte(padre, nombre, Vector3.one * diametro, CFrame.new(pos), color)
	p.Shape = Enum.PartType.Ball
	return p
end

-- Modelo con contorno toon: un Highlight solo de borde, que se ve únicamente donde el modelo
-- no está tapado (Occluded), como la raya de un dibujo.
local function modelo(padre: Instance, nombre: string): Model
	local m = Instance.new("Model")
	m.Name = nombre
	local h = Instance.new("Highlight")
	h.Name = "Contorno"
	h.FillTransparency = 1
	h.OutlineColor = Estilo.Contorno
	h.OutlineTransparency = Estilo.Highlight.Transparencia
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = m
	m.Parent = padre
	return m
end

local function palmera(padre: Instance, nombre: string, base: Vector3, inclinacion: number)
	local m = modelo(padre, nombre)
	-- tronco en tres tramos que se van corriendo: la curva de caricatura
	local punta = base
	for i = 1, 3 do
		local siguiente = punta + Vector3.new(inclinacion, 4, 0)
		local medio = (punta + siguiente) / 2
		local tramo = parte(
			m,
			"Tronco" .. i,
			Vector3.new(1.8 - i * 0.2, 4.4, 1.8 - i * 0.2),
			CFrame.lookAt(medio, siguiente) * CFrame.Angles(math.rad(90), 0, 0),
			if i % 2 == 0 then M.Tronco else M.MaderaOscura
		)
		tramo.CanCollide = i == 1
		punta = siguiente
	end
	-- copa: cinco hojas aplastadas alrededor de una bola
	bola(m, "Coco", 2.2, punta, M.MaderaOscura)
	for i = 0, 4 do
		local angulo = i * math.pi * 2 / 5
		local dir = Vector3.new(math.cos(angulo), 0, math.sin(angulo))
		local hoja = parte(
			m,
			"Hoja" .. i,
			Vector3.new(1.6, 0.5, 6),
			CFrame.lookAt(punta + dir * 2.6, punta + dir * 6 - Vector3.new(0, 1.6, 0)),
			if i % 2 == 0 then M.Hojas else M.HojasClaro
		)
		hoja.CanCollide = false
	end
end

local function cuna(padre: Instance, nombre: string, tam: Vector3, cf: CFrame, color: Color3): WedgePart
	local w = Instance.new("WedgePart")
	w.Name = nombre
	w.Size = tam
	w.CFrame = cf
	w.Color = color
	w.Material = Enum.Material.SmoothPlastic
	w.Anchored = true
	w.Parent = padre
	return w
end

-- Tabla con texto de dibujo animado (letra redonda blanca con contorno azul marino).
local function cartel(padre: Instance, tam: Vector2, cf: CFrame, texto: string, fondo: Color3)
	local tabla = parte(padre, "Cartel", Vector3.new(tam.X, tam.Y, 0.4), cf, fondo)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = tabla
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Estilo.UI.Fuente
	t.Text = texto
	t.TextScaled = true
	t.TextColor3 = Estilo.UI.Texto
	t.Parent = gui
	local margen = Instance.new("UIPadding")
	margen.PaddingTop = UDim.new(0.12, 0)
	margen.PaddingBottom = UDim.new(0.12, 0)
	margen.PaddingLeft = UDim.new(0.05, 0)
	margen.PaddingRight = UDim.new(0.05, 0)
	margen.Parent = t
	Estilo.bordeTexto(t)
end

-- Casita sin interior: paredes macizas, techo a dos aguas y cartel. "base" es el centro del piso
-- y su LookVector es hacia dónde mira la puerta.
local function casa(padre: Instance, nombre: string, base: CFrame, pared: Color3, techo: Color3, letrero: string)
	local ancho, fondo, alto = 10, 8, 7
	local m = Instance.new("Model")
	m.Name = nombre
	m.Parent = padre
	parte(m, "Zocalo", Vector3.new(ancho + 0.4, 1.2, fondo + 0.4), base, M.MaderaOscura)
	parte(m, "Paredes", Vector3.new(ancho, alto, fondo), base * CFrame.new(0, alto / 2, 0), pared)
	-- la cuña tiene la cara alta atrás (+Z): la de adelante sube hacia la cumbrera tal cual y la
	-- de atrás va girada 180°
	local sube, ala = 3.5, fondo / 2 + 0.6
	cuna(m, "TechoFrente", Vector3.new(ancho + 1.2, sube, ala), base * CFrame.new(0, alto + sube / 2, -ala / 2), techo)
	cuna(
		m,
		"TechoAtras",
		Vector3.new(ancho + 1.2, sube, ala),
		base * CFrame.new(0, alto + sube / 2, ala / 2) * CFrame.Angles(0, math.pi, 0),
		techo
	)
	local frente = -fondo / 2 - 0.15
	parte(m, "Puerta", Vector3.new(2.4, 4, 0.3), base * CFrame.new(0, 2.6, frente), M.MaderaOscura)
	bola(m, "Picaporte", 0.4, (base * CFrame.new(0.8, 2.6, frente - 0.2)).Position, M.PuntoPesca)
	for _, x in { -3.2, 3.2 } do
		parte(m, "Ventana", Vector3.new(2, 2, 0.3), base * CFrame.new(x, 3.6, frente), M.Ventana)
		parte(m, "Alfeizar", Vector3.new(2.6, 0.4, 0.6), base * CFrame.new(x, 2.4, frente - 0.1), M.Madera)
	end
	cartel(m, Vector2.new(8, 1.6), base * CFrame.new(0, 6, frente - 0.1), letrero, M.Madera)
end

-- Pueblo pesquero (opción C): dos casitas, una red secándose con boyas, un barril con cañas y
-- cajas de pescado junto al puesto. Todo en un modelo "Pueblo" con UN solo Highlight (Roblox
-- dibuja como mucho 31 por cliente). Las casitas son decorado: cuando existan la tienda y el
-- museo, sus ProximityPrompt van en la puerta de cada una. Con PUEBLO = false no se arma.
local PUEBLO = true

-- las dos casas a los costados de la playa, mirando a la mitad del muelle: el recorrido que más
-- se repite es volver del muelle a vender, y así los carteles se leen de frente sin que los
-- tapen las palmeras (mirando al camino del spawn quedaban detrás de ellas)
local CASA_CEBO = CFrame.lookAt(Vector3.new(-36, 1, 26), Vector3.new(0, 1, -40))
local CASA_MUSEO = CFrame.lookAt(Vector3.new(39, 1, 27), Vector3.new(0, 1, -40))

local function armarPueblo(carpeta: Instance)
	if not PUEBLO or carpeta:FindFirstChild("Pueblo") then
		return
	end
	local pueblo = modelo(carpeta, "Pueblo")

	casa(pueblo, "CeboYCanas", CASA_CEBO, M.ParedCoral, M.TechoAzul, "CEBO & CAÑAS")
	casa(pueblo, "MuseoMarino", CASA_MUSEO, M.ParedMenta, M.TechoRojo, "MUSEO MARINO")

	-- red colgada entre dos palos, con boyas de colores abajo. En la punta izquierda y de costado:
	-- más al centro tapaba el cartel de la casa de cebo
	local red = Instance.new("Model")
	red.Name = "RedSecando"
	red.Parent = pueblo
	local origen = CFrame.new(-40, 0.7, 8) * CFrame.Angles(0, math.rad(90), 0)
	for _, x in { -4.5, 4.5 } do
		parte(red, "Palo", Vector3.new(0.6, 6, 0.6), origen * CFrame.new(x, 3, 0), M.MaderaOscura)
	end
	parte(red, "Travesano", Vector3.new(9.6, 0.4, 0.4), origen * CFrame.new(0, 5.8, 0), M.MaderaOscura)
	for i = 0, 6 do
		local hilo = parte(red, "Hilo", Vector3.new(0.15, 4, 0.15), origen * CFrame.new(-3 + i, 3.6, 0), M.Red)
		hilo.CanCollide = false
	end
	for j = 0, 3 do
		local hilo = parte(red, "Hilo", Vector3.new(7, 0.15, 0.15), origen * CFrame.new(0, 2 + j * 1.1, 0), M.Red)
		hilo.CanCollide = false
	end
	for i, x in { -3, -1, 1, 3 } do
		bola(red, "Boya", 0.9, (origen * CFrame.new(x, 1.5, 0)).Position, if i % 2 == 0 then M.Boya else M.PuntoPesca)
	end

	-- barril con cañas al lado del cajón del puesto
	local barril = Instance.new("Model")
	barril.Name = "BarrilCanas"
	barril.Parent = pueblo
	local b = parte(barril, "Barril", Vector3.new(2.6, 2.4, 2.4), CFrame.new(22.5, 2.2, 10) * CFrame.Angles(0, 0, math.rad(90)), M.Madera)
	b.Shape = Enum.PartType.Cylinder
	for i, giro in { -12, 4, 16 } do
		local tope = Vector3.new(22.5 + math.sin(math.rad(giro)) * 1.6, 7.2, 10 + (i - 2) * 0.6)
		local abajo = Vector3.new(22.5 + (i - 2) * 0.4, 2.8, 10 + (i - 2) * 0.4)
		local cana = parte(barril, "Cana", Vector3.new(0.25, 0.25, (tope - abajo).Magnitude), CFrame.lookAt((tope + abajo) / 2, tope), M.MaderaOscura)
		cana.CanCollide = false
		bola(barril, "Punta", 0.5, tope, if i == 2 then M.Boya else M.Puesto)
	end

	-- cajas de pescado del otro lado del puesto, con un pescadito arriba de cada una
	local cajas = Instance.new("Model")
	cajas.Name = "CajasPescado"
	cajas.Parent = pueblo
	for i, pos in { Vector3.new(8.5, 1.8, 9.5), Vector3.new(7.8, 1.8, 6.6), Vector3.new(8.2, 3.6, 8) } do
		parte(cajas, "Caja", Vector3.new(2.4, 1.6, 2.4), CFrame.new(pos) * CFrame.Angles(0, math.rad(i * 17), 0), M.Madera)
		local cuerpo = parte(cajas, "Pescado", Vector3.new(0.6, 0.5, 1.3), CFrame.new(pos + Vector3.new(0, 1.05, 0)) * CFrame.Angles(0, math.rad(i * 50), 0), M.Pescado)
		cuerpo.CanCollide = false
		local cola = cuna(cajas, "Cola", Vector3.new(0.15, 0.6, 0.5), cuerpo.CFrame * CFrame.new(0, 0, 0.85), M.Pescado)
		cola.CanCollide = false
	end
end

-- Pieza que brilla y no estorba: ni choca, ni la toca el mouse, ni tapa la cámara, ni da sombra.
local function brillo(padre: Instance, nombre: string, tam: Vector3, cf: CFrame, color: Color3, transparencia: number): Part
	local p = parte(padre, nombre, tam, cf, color)
	p.Material = Enum.Material.Neon
	p.Transparency = transparencia
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	return p
end

-- Altura del piso en (x, z), para que las flechas del camino no floten: en el mapa hecho a mano
-- el camino es de tablones (y = 1.35); en el generado por código es arena (y = 1).
local function alPiso(x: number, z: number, ignorar: { Instance }): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignorar
	local hit = Workspace:Raycast(Vector3.new(x, 40, z), Vector3.new(0, -60, 0), params)
	return if hit then hit.Position.Y + 0.05 else 1.05
end

-- Flecha en el piso apuntando a -Z (hacia el agua): dos tiras en V.
local function flecha(padre: Instance, centro: Vector3)
	local puntaFlecha = centro + Vector3.new(0, 0, -0.8)
	for _, lado in { -1, 1 } do
		local cola = centro + Vector3.new(lado * 1.4, 0, 0.6)
		brillo(padre, "Flecha", Vector3.new(0.45, 0.08, (cola - puntaFlecha).Magnitude + 0.4), CFrame.lookAt((cola + puntaFlecha) / 2, puntaFlecha), M.Flecha, 0.05)
	end
end

-- Aro hexagonal plano (radio = distancia del centro a cada vértice).
local function hexagono(padre: Instance, centro: Vector3, radio: number, grosor: number, transparencia: number)
	for i = 0, 5 do
		local a1, a2 = math.rad(i * 60), math.rad(i * 60 + 60)
		local v1 = centro + Vector3.new(math.cos(a1), 0, math.sin(a1)) * radio
		local v2 = centro + Vector3.new(math.cos(a2), 0, math.sin(a2)) * radio
		brillo(padre, "Aro", Vector3.new(grosor, 0.15, radio + grosor), CFrame.lookAt((v1 + v2) / 2, v2), M.ZonaPesca, transparencia)
	end
end

local function farol(padre: Instance, base: Vector3)
	local m = Instance.new("Model")
	m.Name = "Farol"
	m.Parent = padre
	parte(m, "Palo", Vector3.new(0.5, 7, 0.5), CFrame.new(base + Vector3.new(0, 3.5, 0)), M.Metal)
	local luz = brillo(m, "Luz", Vector3.new(1.2, 1.6, 1.2), CFrame.new(base + Vector3.new(0, 7.6, 0)), M.Farol, 0)
	luz.CanQuery = true
	parte(m, "Tapa", Vector3.new(1.7, 0.4, 1.7), CFrame.new(base + Vector3.new(0, 8.6, 0)), M.Metal)
	local l = Instance.new("PointLight")
	l.Color = M.Farol
	l.Range = 16
	l.Brightness = 1.2
	l.Parent = luz
end

-- Lo que sale de las referencias (juegos de pesca que pegan en Roblox): una columna de luz con
-- "¡PESCÁ ACÁ!" que se ve desde el spawn, flechas en el piso que llevan al muelle, faroles,
-- un piso brillante de color delante de cada tienda, el cartel que explica cómo tirar, un
-- telescopio que mira a las islas y el tablero de récords. Lo sólido va en el modelo
-- "Detalles" (un Highlight más: 15 en total); lo que brilla va en "Guias", sin contorno, porque
-- el Highlight sobre Neon transparente se ve como un bloque sucio.
local function armarGuias(carpeta: Instance)
	if carpeta:FindFirstChild("Guias") then
		return
	end
	local guias = Instance.new("Folder")
	guias.Name = "Guias"
	local detalles = modelo(guias, "Detalles")

	-- zona de pesca: columna verde transparente y dos aros en el agua, delante de la punta.
	-- CanQuery = false, así la cámara la atraviesa y no se acerca de golpe al personaje
	local zona = Vector3.new(0, 0, -65)
	local columna = brillo(guias, "Columna", Vector3.new(30, 18, 18), CFrame.new(zona + Vector3.new(0, 15, 0)) * CFrame.Angles(0, 0, math.rad(90)), M.ZonaPesca, 0.72)
	columna.Shape = Enum.PartType.Cylinder
	hexagono(guias, zona + Vector3.new(0, 0.1, 0), 8.5, 0.8, 0.1)
	hexagono(guias, zona + Vector3.new(0, 0.1, 0), 5.5, 0.5, 0.3)
	local ancla = parte(guias, "AnclaCartel", Vector3.one, CFrame.new(zona + Vector3.new(0, 24, 0)), M.ZonaPesca)
	ancla.Transparency = 1
	ancla.CanCollide = false
	ancla.CanQuery = false
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(28, 11) -- en studs: se agranda con la distancia como el resto del mundo
	bb.LightInfluence = 0
	bb.MaxDistance = 300
	bb.Parent = ancla
	local titulo = Instance.new("TextLabel")
	titulo.Size = UDim2.fromScale(1, 0.62)
	titulo.BackgroundTransparency = 1
	titulo.Font = Estilo.UI.Fuente
	titulo.Text = "¡PESCÁ ACÁ!"
	titulo.TextScaled = true
	titulo.TextColor3 = Estilo.UI.Texto
	titulo.Parent = bb
	Estilo.bordeTexto(titulo)
	local abajo = Instance.new("TextLabel")
	abajo.Size = UDim2.fromScale(1, 0.38)
	abajo.Position = UDim2.fromScale(0, 0.62)
	abajo.BackgroundTransparency = 1
	abajo.Font = Estilo.UI.Fuente
	abajo.Text = "▼"
	abajo.TextScaled = true
	abajo.TextColor3 = M.ZonaPesca
	abajo.Parent = bb
	Estilo.bordeTexto(abajo)

	-- flechas: sobre las baldosas del camino del spawn y sobre los tablones del muelle
	for _, z in { 12, 4.8, -2.4 } do
		flecha(guias, Vector3.new(0, alPiso(0, z, { guias }), z))
	end
	for _, z in { -16, -24, -32, -40, -48 } do
		flecha(guias, Vector3.new(0, 2.55, z))
	end

	-- filo dorado del muelle: los bordes de la pasarela, las juntas y el frente de la punta
	for _, x in { -3.85, 3.85 } do
		parte(guias, "Filo", Vector3.new(0.3, 0.1, 40), CFrame.new(x, 2.55, -30), M.Dorado).CanCollide = false
	end
	for z = -14, -46, -4 do
		parte(guias, "Junta", Vector3.new(7.4, 0.1, 0.2), CFrame.new(0, 2.55, z), M.Dorado).CanCollide = false
	end
	parte(guias, "Filo", Vector3.new(23.4, 0.1, 0.3), CFrame.new(0, 2.55, -57.75), M.Dorado).CanCollide = false

	-- piso brillante delante de cada tienda: el jugador aprende "piso de color = acá se hace algo"
	brillo(guias, "PisoVenta", Vector3.new(9, 0.08, 6), CFrame.new(14, 1.04, 0.6), M.PisoVenta, 0.35)
	brillo(guias, "PisoCebo", Vector3.new(9, 0.08, 5), CASA_CEBO * CFrame.new(0, 0.04, -7.2), M.PisoCebo, 0.35)
	brillo(guias, "PisoMuseo", Vector3.new(9, 0.08, 5), CASA_MUSEO * CFrame.new(0, 0.04, -7.2), M.PisoMuseo, 0.35)
	-- la tienda de cebo todavía no existe: el piso de color promete algo, así que se avisa
	-- "¡PRONTO!" arriba para que nadie se pare ahí esperando un menú (y queda la intriga).
	-- El museo ya tiene su vitrina (client/Vitrina.client.luau), que es local de cada jugador.
	for _, cf in { CASA_CEBO } do
		local ancla = brillo(guias, "AnclaPronto", Vector3.one, cf * CFrame.new(0, 12.5, -2), M.Flecha, 1)
		local cartelPronto = Instance.new("BillboardGui")
		cartelPronto.Name = "Pronto"
		cartelPronto.Size = UDim2.fromScale(7, 2.2)
		cartelPronto.LightInfluence = 0
		cartelPronto.MaxDistance = 90
		cartelPronto.Parent = ancla
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Estilo.UI.Fuente
		t.Text = "¡PRONTO!"
		t.TextScaled = true
		t.TextColor3 = M.Flecha
		t.Parent = cartelPronto
		Estilo.bordeTexto(t)
	end

	-- faroles sobre los postes de la pasarela y en las esquinas de la punta
	for _, z in { -26, -38 } do
		for _, x in { -4.5, 4.5 } do
			farol(detalles, Vector3.new(x, 2.4, z))
		end
	end
	for _, x in { -11.7, 11.7 } do
		farol(detalles, Vector3.new(x, 2.5, -57.8))
	end

	-- cartel de cómo se tira, en la entrada de la punta, de cara a quien llega
	local posCartel = Vector3.new(-9.8, 5.3, -50.9)
	parte(detalles, "PaloCartel", Vector3.new(0.5, 4.4, 0.5), CFrame.new(posCartel.X, 4.7, posCartel.Z - 0.4), M.MaderaOscura)
	cartel(detalles, Vector2.new(4, 2.2), CFrame.lookAt(posCartel, posCartel + Vector3.zAxis), "¡Hacé clic o tocá\npara tirar la caña!", M.Madera)

	-- telescopio en la esquina derecha, apuntando a las islas del horizonte
	local tele = Instance.new("Model")
	tele.Name = "Telescopio"
	tele.Parent = detalles
	local cabeza = Vector3.new(10.4, 5.2, -51.6)
	for i = 0, 2 do
		local a = math.rad(i * 120 + 30)
		local pie = Vector3.new(10.4 + math.cos(a) * 1.1, 2.5, -51.6 + math.sin(a) * 1.1)
		parte(tele, "Pata", Vector3.new(0.25, 0.25, (cabeza - pie).Magnitude), CFrame.lookAt((cabeza + pie) / 2, cabeza), M.Metal).CanCollide = false
	end
	local mira = CFrame.lookAt(cabeza + Vector3.new(0, 0.4, 0), Vector3.new(30, 12, -240))
	local tubo = parte(tele, "Tubo", Vector3.new(4, 0.8, 0.8), mira * CFrame.Angles(0, math.rad(90), 0), M.Arena)
	tubo.Shape = Enum.PartType.Cylinder
	local lente = brillo(tele, "Lente", Vector3.new(0.2, 0.9, 0.9), mira * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(90), 0), M.Ventana, 0)
	lente.Shape = Enum.PartType.Cylinder

	-- tablero de récords al costado del camino, de cara al spawn. Queda vacío: las filas se llaman
	-- Fila1..Fila3 para que el código de récords las complete cuando exista
	local tablero = Instance.new("Model")
	tablero.Name = "TableroRecords"
	tablero.Parent = detalles
	local centroTablero = Vector3.new(-17, 5.2, 4) -- más al centro tapaba el cartel del muelle
	local cfTablero = CFrame.lookAt(centroTablero, Vector3.new(0, 5.2, 18))
	for _, x in { -2.6, 2.6 } do
		parte(tablero, "Pata", Vector3.new(0.6, 8.4, 0.6), cfTablero * CFrame.new(x, -0.2, 0.4), M.MaderaOscura)
	end
	local tabla = parte(tablero, "Tabla", Vector3.new(6.4, 4.4, 0.4), cfTablero, M.Madera)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = tabla
	local lista = Instance.new("UIListLayout")
	lista.SortOrder = Enum.SortOrder.LayoutOrder
	lista.Parent = gui
	local filas = { "PECES MÁS PESADOS", "1.  ---", "2.  ---", "3.  ---" }
	for i, texto in filas do
		local t = Instance.new("TextLabel")
		t.Name = if i == 1 then "Titulo" else "Fila" .. (i - 1)
		t.LayoutOrder = i
		t.Size = UDim2.fromScale(1, if i == 1 then 0.31 else 0.23)
		t.BackgroundTransparency = 1
		t.Font = Estilo.UI.Fuente
		t.Text = texto
		t.TextScaled = true
		t.TextColor3 = if i == 1 then M.Flecha else Estilo.UI.Texto
		t.Parent = gui
		Estilo.bordeTexto(t)
	end

	guias.Parent = carpeta
end

function Mundo.armarSiFalta()
	local existente = Workspace:FindFirstChild("Muelle")
	if existente then
		-- mapa hecho a mano en Studio: no se toca, solo se le suma lo que todavía no tenga
		armarPueblo(existente)
		armarGuias(existente)
		return
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Muelle"

	-- agua: superficie en y = 0 (color en server/Iluminacion.luau). El Terrain va en voxeles de 4
	-- studs: con el bloque de -12 a 0 la superficie cae justo en 0; con -11 a 1 subía a 2 y tapaba
	-- la arena. El mapa armado en Studio (carpeta "Muelle") ya trae su agua y esto no corre.
	Workspace.Terrain:FillBlock(CFrame.new(0, -6, -90), Vector3.new(220, 12, 160), Enum.Material.Water)

	local playa = modelo(carpeta, "Playa")
	parte(playa, "Arena", Vector3.new(80, 2, 40), CFrame.new(0, 0, 10), M.Arena)
	parte(playa, "Orilla", Vector3.new(80, 1.6, 4), CFrame.new(0, -0.1, -11), M.ArenaMojada)

	-- muelle: tablones alternando dos tonos (se lee como madera sin usar textura) y postes
	local muelle = modelo(carpeta, "Pasarela")
	for i = 0, 9 do
		parte(
			muelle,
			"Tablon" .. i,
			Vector3.new(8, 1, 4),
			CFrame.new(0, 2, -12 - i * 4),
			if i % 2 == 0 then M.Madera else M.MaderaOscura
		)
	end
	parte(muelle, "Punta", Vector3.new(24, 1, 8), CFrame.new(0, 2, -54), M.Madera)
	for _, z in { -14, -26, -38, -50, -58 } do
		for _, x in { -4.5, 4.5 } do
			local poste = parte(muelle, "Poste", Vector3.new(6, 1.4, 1.4), CFrame.new(x, -0.6, z), M.MaderaOscura)
			poste.Shape = Enum.PartType.Cylinder
			poste.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		end
	end
	for _, x in { -12.5, 12.5 } do
		local poste = parte(muelle, "PosteFinal", Vector3.new(6, 1.4, 1.4), CFrame.new(x, -0.6, -54), M.MaderaOscura)
		poste.Shape = Enum.PartType.Cylinder
		poste.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	end

	-- tres puntos en la punta del muelle: entran varios a la vez (pesca en grupo). Neon para que
	-- el bloom los haga brillar: es lo primero que el jugador nuevo tiene que encontrar.
	for i, x in { -8, 0, 8 } do
		local punto = parte(
			carpeta,
			"PuntoPesca" .. i,
			Vector3.new(3, 0.2, 3),
			CFrame.new(x, 2.6, -56), -- sin rotar mira hacia -Z, que es el agua
			M.PuntoPesca
		)
		punto.Material = Enum.Material.Neon
		punto.CanCollide = false
		punto.Transparency = 0.2
		CollectionService:AddTag(punto, "PuntoPesca")
	end

	-- puesto de venta: mostrador celeste con toldo a rayas
	local puestoModelo = modelo(carpeta, "Puesto")
	local puesto = parte(puestoModelo, "Vendedor", Vector3.new(6, 6, 4), CFrame.new(14, 4, 6), M.Puesto)
	CollectionService:AddTag(puesto, "Vendedor")
	parte(puestoModelo, "Mostrador", Vector3.new(7, 0.6, 5), CFrame.new(14, 7.3, 6), M.ToldoClaro)
	for _, x in { 11.2, 16.8 } do
		parte(puestoModelo, "Palo", Vector3.new(0.6, 5, 0.6), CFrame.new(x, 10, 4.2), M.ToldoClaro)
	end
	for i = 0, 4 do
		local franja = parte(
			puestoModelo,
			"Toldo" .. i,
			Vector3.new(1.6, 0.4, 6),
			CFrame.new(10.8 + i * 1.6, 12.6, 6) * CFrame.Angles(math.rad(-12), 0, 0),
			if i % 2 == 0 then M.Toldo else M.ToldoClaro
		)
		franja.CanCollide = false
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Vender el balde"
	prompt.ObjectText = "Puesto del muelle"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = puesto

	palmera(carpeta, "Palmera1", Vector3.new(-26, 1, 14), 0.8)
	palmera(carpeta, "Palmera2", Vector3.new(-18, 1, 22), -0.6)
	palmera(carpeta, "Palmera3", Vector3.new(28, 1, 18), -0.9)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Inicio"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 1.5, 18)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = M.Arena
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = carpeta

	-- se publica antes de las guías: alPiso hace raycast y necesita la arena en Workspace
	carpeta.Parent = Workspace
	armarPueblo(carpeta)
	armarGuias(carpeta)
end

return Mundo
