--!strict
-- Mascotas (Grupo 4). Dos pestañas:
--   Ruleta:        la Ruleta de Mascotas. Cada porción mide lo mismo que su chance (Común 30 %
--                  ocupa 30 % de la rueda; la Mítica, una rayita), y al lado están todas las
--                  chances en % (suman 100) y lo que da cada mascota. Se paga solo con Monedas.
--   Mis mascotas:  las que tenés (con cuántas copias), cuáles te acompañan y sus bonos.
-- Solo pide (Remotos.GirarRuleta / EquiparMascota); el servidor cobra, tira y decide
-- (server/Mascotas.luau). Cuando avisa qué salió (Remotos.Ruleta), la rueda gira hasta esa
-- porción. Exporta MenuMascotas.dibujo(mascota, tamaño) para dibujar una mascota en la UI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Avisos = require(script.Parent.Avisos)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)
local Ventanas = require(script.Parent.Ventanas)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local GirarRuleta = remotos:WaitForChild("GirarRuleta") :: RemoteEvent
local Ruleta = remotos:WaitForChild("Ruleta") :: RemoteEvent
local EquiparMascota = remotos:WaitForChild("EquiparMascota") :: RemoteEvent

local MASCOTAS = GameConfig.Mascotas.Lista
local GIRO = GameConfig.Mascotas.Ruleta.Espera - 0.3 -- lo que tarda en frenar

local MenuMascotas = {}

-- Dibujos -----------------------------------------------------------------------------------

local function circulo(color: Color3, tam: UDim2, pos: UDim2, padre: Instance, z: number): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = tam
	f.Position = pos
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.ZIndex = z
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	f.Parent = padre
	return f
end

local function rombo(
	color: Color3,
	tam: UDim2,
	pos: UDim2,
	padre: Instance,
	z: number,
	giro: number?
): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = tam
	f.Position = pos
	f.Rotation = giro or 45
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.ZIndex = z
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.2, 0)
	c.Parent = f
	f.Parent = padre
	return f
end

-- Una mascota dibujada (cara redonda con ojos y lo que la distingue). Para la UI.
function MenuMascotas.dibujo(m: GameConfig.Mascota, tam: number): Frame
	local caja = Instance.new("Frame")
	caja.Name = "Mascota" .. m.Id
	caja.BackgroundTransparency = 1
	caja.Size = UDim2.fromOffset(tam, tam)
	local c1, c2 = Color3.fromHex(m.Colores[1]), Color3.fromHex(m.Colores[2])
	local oscuro = Estilo.Oscuro
	local forma = m.Forma
	-- orejas, cuernos o cristal (atrás de la cara)
	if forma == "Zorro" or forma == "Gato" then
		rombo(c1, UDim2.fromScale(0.3, 0.3), UDim2.fromScale(0.28, 0.24), caja, 1)
		rombo(c1, UDim2.fromScale(0.3, 0.3), UDim2.fromScale(0.72, 0.24), caja, 1)
	elseif forma == "Dragon" then
		rombo(c2, UDim2.fromScale(0.14, 0.3), UDim2.fromScale(0.32, 0.18), caja, 1, -20)
		rombo(c2, UDim2.fromScale(0.14, 0.3), UDim2.fromScale(0.68, 0.18), caja, 1, 20)
	elseif forma == "Golem" or forma == "Cristal" then
		rombo(c2, UDim2.fromScale(0.26, 0.26), UDim2.fromScale(0.5, 0.16), caja, 1)
	elseif forma == "Topo" then
		circulo(c1, UDim2.fromScale(0.24, 0.24), UDim2.fromScale(0.26, 0.28), caja, 1)
		circulo(c1, UDim2.fromScale(0.24, 0.24), UDim2.fromScale(0.74, 0.28), caja, 1)
	end
	local cara = if forma == "Golem" or forma == "Cristal"
		then rombo(c1, UDim2.fromScale(0.62, 0.62), UDim2.fromScale(0.5, 0.56), caja, 2, 0)
		else circulo(c1, UDim2.fromScale(0.74, 0.7), UDim2.fromScale(0.5, 0.56), caja, 2)
	local borde = Instance.new("UIStroke")
	borde.Thickness = math.max(2, tam / 20)
	borde.Color = oscuro
	borde.Parent = cara
	-- panza o caparazón
	if forma == "Pinguino" or forma == "Dragon" or forma == "Zorro" then
		circulo(c2, UDim2.fromScale(0.42, 0.32), UDim2.fromScale(0.5, 0.74), caja, 3)
	elseif forma == "Tortuga" then
		local cap = circulo(c2, UDim2.fromScale(0.8, 0.32), UDim2.fromScale(0.5, 0.86), caja, 3)
		cap.BackgroundTransparency = 0.1
	end
	-- ojos
	for _, x in { 0.36, 0.64 } do
		circulo(Color3.new(1, 1, 1), UDim2.fromScale(0.17, 0.19), UDim2.fromScale(x, 0.52), caja, 4)
		circulo(oscuro, UDim2.fromScale(0.09, 0.11), UDim2.fromScale(x + 0.015, 0.53), caja, 5)
	end
	-- nariz / pico
	if forma == "Pinguino" then
		rombo(
			Color3.fromHex("#FFB04D"),
			UDim2.fromScale(0.12, 0.12),
			UDim2.fromScale(0.5, 0.63),
			caja,
			5
		)
	elseif forma == "Topo" then
		circulo(c2, UDim2.fromScale(0.14, 0.12), UDim2.fromScale(0.5, 0.64), caja, 5)
	else
		circulo(oscuro, UDim2.fromScale(0.07, 0.05), UDim2.fromScale(0.5, 0.65), caja, 5)
	end
	-- brillo de las míticas
	if m.Rareza == "Mitico" then
		rombo(c2, UDim2.fromScale(0.12, 0.12), UDim2.fromScale(0.86, 0.2), caja, 6)
		rombo(c2, UDim2.fromScale(0.08, 0.08), UDim2.fromScale(0.12, 0.34), caja, 6)
	end
	return caja
end

-- "+5 % monedas · +0,05 suerte"
function MenuMascotas.bono(m: GameConfig.Mascota): string
	local partes = {}
	if m.Monedas then
		table.insert(partes, ("+%d %% monedas"):format(math.floor(m.Monedas * 100 + 0.5)))
	end
	if m.Suerte then
		table.insert(partes, "+" .. Formato.suerte(m.Suerte):sub(2) .. " suerte")
	end
	if m.Velocidad then
		table.insert(partes, ("+%d %% velocidad"):format(math.floor(m.Velocidad * 100 + 0.5)))
	end
	return table.concat(partes, " · ")
end

local function chance(x: number): string
	local t = ("%.1f"):format(x):gsub("%.0$", ""):gsub("%.", ",")
	return t .. " %"
end

-- Ángulos de cada porción (en grados, desde arriba y en el sentido del reloj).
local desde: { [string]: number } = {}
local hasta: { [string]: number } = {}
do
	local a = 0
	for _, m in MASCOTAS do
		desde[m.Id] = a
		a += m.Chance * 3.6
		hasta[m.Id] = a
	end
end

local function mascotaEn(angulo: number): GameConfig.Mascota
	local a = angulo % 360
	for _, m in MASCOTAS do
		if a >= desde[m.Id] and a < hasta[m.Id] then
			return m
		end
	end
	return MASCOTAS[#MASCOTAS]
end

-- La rueda: un CanvasGroup (gira entero) con 360 rayos de 1 grado pintados según la porción.
local function rueda(radio: number): (Frame, CanvasGroup)
	local marco = Instance.new("Frame")
	marco.Name = "Ruleta"
	marco.BackgroundTransparency = 1
	marco.Size = UDim2.fromOffset(radio * 2 + 40, radio * 2 + 60)
	local fondo = circulo(
		Estilo.Oscuro,
		UDim2.fromOffset(radio * 2 + 22, radio * 2 + 22),
		UDim2.new(0.5, 0, 0, radio + 40),
		marco,
		1
	)
	local aro = Instance.new("UIStroke")
	aro.Thickness = 6
	aro.Color = Color3.fromHex("#FFC83D")
	aro.Parent = fondo
	local g = Instance.new("CanvasGroup")
	g.Name = "Rueda"
	g.AnchorPoint = Vector2.new(0.5, 0.5)
	g.Position = UDim2.new(0.5, 0, 0, radio + 40)
	g.Size = UDim2.fromOffset(radio * 2, radio * 2)
	g.BackgroundTransparency = 1
	g.ZIndex = 2
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(1, 0)
	esquina.Parent = g
	local ancho = math.max(3, math.ceil(radio * 2 * math.sin(math.rad(0.5)) * 1.9))
	for grado = 0, 359 do
		local m = mascotaEn(grado + 0.5)
		local rayo = Instance.new("Frame")
		rayo.AnchorPoint = Vector2.new(0.5, 0.5)
		rayo.Position = UDim2.fromScale(0.5, 0.5)
		rayo.Size = UDim2.fromOffset(ancho, radio * 2)
		rayo.Rotation = grado + 0.5
		rayo.BorderSizePixel = 0
		rayo.BackgroundColor3 = Color3.new(1, 1, 1)
		-- solo la mitad de arriba se ve (la de abajo es transparente)
		local gr = Instance.new("UIGradient")
		gr.Rotation = 90
		gr.Color = ColorSequence.new(Color3.fromHex(m.Colores[1]))
		gr.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.501, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		gr.Parent = rayo
		rayo.Parent = g
	end
	-- líneas entre porciones y las caras de las mascotas grandes
	for _, m in MASCOTAS do
		local linea = Instance.new("Frame")
		linea.AnchorPoint = Vector2.new(0.5, 0.5)
		linea.Position = UDim2.fromScale(0.5, 0.5)
		linea.Size = UDim2.fromOffset(3, radio * 2)
		linea.Rotation = desde[m.Id]
		linea.BorderSizePixel = 0
		linea.BackgroundColor3 = Estilo.Oscuro
		local gr = Instance.new("UIGradient")
		gr.Rotation = 90
		gr.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.501, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		gr.Parent = linea
		linea.ZIndex = 2
		linea.Parent = g
		if m.Chance >= 4 then
			local medio = math.rad((desde[m.Id] + hasta[m.Id]) / 2)
			local d = MenuMascotas.dibujo(m, math.floor(radio * 0.3))
			d.AnchorPoint = Vector2.new(0.5, 0.5)
			d.Position =
				UDim2.new(0.5, math.sin(medio) * radio * 0.66, 0.5, -math.cos(medio) * radio * 0.66)
			d.Rotation = math.deg(medio)
			d.ZIndex = 3
			d.Parent = g
		end
	end
	local centro = circulo(
		Color3.fromHex("#FFC83D"),
		UDim2.fromOffset(radio * 0.26, radio * 0.26),
		UDim2.fromScale(0.5, 0.5),
		g,
		4
	)
	local cb = Instance.new("UIStroke")
	cb.Thickness = 4
	cb.Color = Estilo.Oscuro
	cb.Parent = centro
	g.Parent = marco
	-- puntero arriba (no gira)
	local puntero =
		rombo(Color3.new(1, 1, 1), UDim2.fromOffset(34, 34), UDim2.new(0.5, 0, 0, 28), marco, 6)
	local pb = Instance.new("UIStroke")
	pb.Thickness = 4
	pb.Color = Estilo.Oscuro
	pb.Parent = puntero
	return marco, g
end

-- Menú --------------------------------------------------------------------------------------

function MenuMascotas.crear()
	local v = Ventanas.crear("Mascotas", "Mascotas", "Mascota", Estilo.Colores.Rosa, 1160, 690)
	local W, H = v.Ancho, v.Alto
	local AH = H - 84
	local actual = "Ruleta"
	local girando = false
	local rotacion = 0
	local ruedaActual: CanvasGroup? = nil

	-- la rueda se arma una sola vez (son muchos rayos) y se vuelve a poner en su lugar
	local RADIO = math.floor(math.min(250, (AH - 140) / 2))
	local marcoRueda, canvas = rueda(RADIO)
	ruedaActual = canvas

	local area = Instance.new("Frame")
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 84)
	area.Size = UDim2.fromOffset(W, AH)
	area.Parent = v.Cuerpo

	local function pestanaRuleta()
		marcoRueda.Position = UDim2.fromOffset(20, 0)
		marcoRueda.Parent = area
		local precio = Reglas.precioRuleta(Datos.zonas())
		local alcanza = Datos.numero("Monedas") >= precio
		local b = Estilo.boton({
			Texto = if girando then "Girando..." else "Girar · " .. Formato.corto(precio),
			Icono = "Moneda",
			Color = if alcanza and not girando then "Rosa" else "Gris",
			Ancho = 340,
			Alto = 74,
			TamanoTexto = 28,
		})
		b.AnchorPoint = Vector2.new(0.5, 1)
		b.Position = UDim2.fromOffset(20 + marcoRueda.Size.X.Offset / 2, AH - 4)
		b.Parent = area
		b.Activated:Connect(function()
			if not girando then
				GirarRuleta:FireServer()
			end
		end)

		-- chances
		local x0 = marcoRueda.Size.X.Offset + 50
		local cab = Estilo.texto("Probabilidades", 32)
		Estilo.degradado(cab, { "#FFC2E6", "#FF6FD8" })
		cab.Position = UDim2.fromOffset(x0, 0)
		cab.Parent = area
		local lista = Ventanas.desplazable(W - x0, AH - 120, nil, 6)
		lista.Position = UDim2.fromOffset(x0, 44)
		lista.Parent = area
		local total = 0
		for i, m in MASCOTAS do
			total += m.Chance
			local fila = Ventanas.panel(W - x0 - 30, 54, { "#353B63", "#262B4F" })
			fila.LayoutOrder = i
			local d = MenuMascotas.dibujo(m, 44)
			d.Position = UDim2.fromOffset(10, 5)
			d.ZIndex = 3
			d.Parent = fila
			local nombre = Estilo.texto(m.Nombre, 22)
			nombre.Position = UDim2.fromOffset(64, 3)
			nombre.ZIndex = 3
			nombre.Parent = fila
			local r = Reglas.rareza(m.Rareza)
			local rz = Estilo.texto(if r then r.Nombre else m.Rareza, 17)
			Estilo.degradado(rz, Estilo.Rarezas[m.Rareza] or { "#FFFFFF" })
			rz.Position = UDim2.fromOffset(64, 30)
			rz.ZIndex = 3
			rz.Parent = fila
			local bono = Estilo.texto(MenuMascotas.bono(m), 17, Color3.fromHex("#C9F0FF"))
			bono.Position = UDim2.fromOffset(186, 30)
			bono.ZIndex = 3
			bono.Parent = fila
			local pc = Estilo.texto(chance(m.Chance), 26, Color3.fromHex("#FFE45C"))
			pc.AnchorPoint = Vector2.new(1, 0.5)
			pc.Position = UDim2.new(1, -14, 0.5, 0)
			pc.ZIndex = 3
			pc.Parent = fila
			fila.Parent = lista
		end
		local nota = Estilo.parrafo(
			("Total: %s. Cada tirada da una mascota. Se paga solo con Monedas del juego, nunca con Robux."):format(
				chance(total)
			),
			19,
			W - x0,
			Color3.fromHex("#C9D6EE")
		)
		nota.Position = UDim2.fromOffset(x0, AH - 66)
		nota.Parent = area
	end

	local function pestanaMias()
		local tenidas: { [string]: number } = {}
		for id, n in Datos.json("Mascotas") do
			if typeof(id) == "string" and typeof(n) == "number" then
				tenidas[id] = n
			end
		end
		local equipadas: { string } = {}
		for _, id in Datos.json("MascotasEquipadas") do
			if typeof(id) == "string" then
				table.insert(equipadas, id)
			end
		end
		local lugares = Datos.bonos().Lugares
		local soloMascotas =
			Reglas.bonos({ Renacimientos = 0, Ramas = {}, MascotasEquipadas = equipadas })
		local cab = Estilo.texto(("Te acompañan: %d / %d"):format(#equipadas, lugares), 32)
		Estilo.degradado(cab, { "#FFC2E6", "#FF6FD8" })
		cab.Parent = area
		local bonos = Estilo.texto(
			("Bonos de tus mascotas: monedas %s · suerte +%s"):format(
				Formato.suerte(soloMascotas.Monedas),
				Formato.suerte(soloMascotas.Suerte):sub(2)
			),
			22,
			Color3.fromHex("#C9F0FF")
		)
		bonos.Position = UDim2.fromOffset(0, 44)
		bonos.Parent = area
		local grilla = Ventanas.desplazable(W, AH - 84, Vector2.new(210, 270), 14)
		grilla.Position = UDim2.fromOffset(0, 80)
		grilla.Parent = area
		local alguna = false
		for i, m in MASCOTAS do
			local n = tenidas[m.Id] or 0
			if n <= 0 then
				continue
			end
			alguna = true
			local usadas = 0
			for _, id in equipadas do
				if id == m.Id then
					usadas += 1
				end
			end
			local f = Ventanas.panel(
				210,
				270,
				if usadas > 0 then { "#5BD94A", "#1E8A2E" } else { "#4A5080", "#353B63" }
			)
			f.LayoutOrder = i
			local d = MenuMascotas.dibujo(m, 96)
			d.AnchorPoint = Vector2.new(0.5, 0)
			d.Position = UDim2.new(0.5, 0, 0, 10)
			d.ZIndex = 3
			d.Parent = f
			local col = Instance.new("Frame")
			col.BackgroundTransparency = 1
			col.Position = UDim2.fromOffset(8, 110)
			col.Size = UDim2.fromOffset(194, 90)
			col.ZIndex = 3
			local l = Instance.new("UIListLayout")
			l.HorizontalAlignment = Enum.HorizontalAlignment.Center
			l.SortOrder = Enum.SortOrder.LayoutOrder
			l.Parent = col
			local nombre = Estilo.texto(("%s  x%d"):format(m.Nombre, n), 22)
			nombre.LayoutOrder = 1
			nombre.Parent = col
			local r = Reglas.rareza(m.Rareza)
			local rz = Estilo.texto(if r then r.Nombre else m.Rareza, 17)
			Estilo.degradado(rz, Estilo.Rarezas[m.Rareza] or { "#FFFFFF" })
			rz.LayoutOrder = 2
			rz.Parent = col
			local bono = Estilo.texto(MenuMascotas.bono(m), 16, Color3.fromHex("#C9F0FF"))
			bono.LayoutOrder = 3
			bono.Parent = col
			col.Parent = f
			local fila = Estilo.fila(6)
			fila.AnchorPoint = Vector2.new(0.5, 1)
			fila.Position = UDim2.new(0.5, 0, 1, -10)
			fila.ZIndex = 3
			if Reglas.puedeEquipar(equipadas, m.Id, tenidas, lugares) then
				local llevar = Estilo.boton({
					Texto = "Llevar",
					Color = "Verde",
					Ancho = 92,
					Alto = 48,
					TamanoTexto = 19,
				})
				llevar.LayoutOrder = 1
				llevar.Activated:Connect(function()
					EquiparMascota:FireServer(m.Id, true)
				end)
				llevar.Parent = fila
			end
			if usadas > 0 then
				local dejar = Estilo.boton({
					Texto = "Dejar",
					Color = "Rojo",
					Ancho = 92,
					Alto = 48,
					TamanoTexto = 19,
				})
				dejar.LayoutOrder = 2
				dejar.Activated:Connect(function()
					EquiparMascota:FireServer(m.Id, false)
				end)
				dejar.Parent = fila
			end
			fila.Parent = f
			f.Parent = grilla
		end
		if not alguna then
			local nada = Estilo.parrafo(
				"Todavía no tenés mascotas. ¡Girá la Ruleta de Mascotas de la plaza!",
				26,
				W - 40
			)
			nada.Parent = grilla
		end
	end

	local function dibujar()
		marcoRueda.Parent = nil
		Ventanas.vaciar(area)
		if actual == "Ruleta" then
			pestanaRuleta()
		else
			pestanaMias()
		end
	end

	local fila, elegir = Ventanas.pestanas(
		{
			{ Id = "Ruleta", Texto = "Ruleta", Icono = "Moneda", Color = "Rosa" },
			{ Id = "Mias", Texto = "Mis mascotas", Icono = "Mascota", Color = "Violeta" },
		},
		300,
		64,
		function(id: string)
			actual = id
			dibujar()
		end,
		24
	)
	fila.Parent = v.Cuerpo
	elegir("Ruleta")

	-- Salió una mascota: la rueda gira hasta su porción (a un lugar al azar adentro de ella).
	Ruleta.OnClientEvent:Connect(function(id: unknown)
		local m = if typeof(id) == "string" then Reglas.mascota(id) else nil
		local g = ruedaActual
		if not m or not g then
			return
		end
		girando = true
		if Ventanas.abierta() == "Mascotas" and actual == "Ruleta" then
			dibujar()
		end
		local margen = math.min(0.4, (hasta[m.Id] - desde[m.Id]) * 0.3)
		local destino = desde[m.Id]
			+ margen
			+ math.random() * (hasta[m.Id] - desde[m.Id] - 2 * margen)
		local base = rotacion + 5 * 360
		local final = base + ((-destino - base) % 360)
		local anterior = mascotaEn(-rotacion).Id
		local seguir = RunService.RenderStepped:Connect(function()
			local ahora = mascotaEn(-g.Rotation).Id
			if ahora ~= anterior then
				anterior = ahora
				-- SONIDO: "tic" de la ruleta al pasar de porción
				Sonidos.tocar(GameConfig.Sonidos.Ruleta, 1 + math.random() * 0.2, 0.5)
			end
		end)
		local t = TweenService:Create(
			g,
			TweenInfo.new(GIRO, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Rotation = final }
		)
		t.Completed:Connect(function()
			seguir:Disconnect()
			rotacion = final % 360
			g.Rotation = rotacion
			girando = false
			-- SONIDO: mascota nueva
			Sonidos.tocar(GameConfig.Sonidos.Mascota)
			local r = Reglas.rareza(m.Rareza)
			Avisos.mostrar({
				Titulo = ("¡Te salió %s!"):format(m.Nombre),
				Texto = ("%s · %s"):format(if r then r.Nombre else m.Rareza, MenuMascotas.bono(m)),
				Color = Color3.fromHex(m.Colores[1]),
				Duracion = 3,
				Icono = "Mascota",
			})
			if Ventanas.abierta() == "Mascotas" then
				dibujar()
			end
		end)
		g.Rotation = rotacion
		t:Play()
	end)

	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar(
		{ "Mascotas", "MascotasEquipadas", "Monedas", "Zonas", "LugaresMascota" },
		function()
			if Ventanas.abierta() == "Mascotas" and not girando then
				dibujar()
			end
		end
	)
end

return MenuMascotas
