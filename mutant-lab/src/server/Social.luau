--!strict
-- Jugar con otros (ficha, "Parte 9"): "me gusta" a los laboratorios, tablas de posiciones y los
-- dos tableros de la plaza (posiciones y experimento del día).
-- "Me gusta": el cartel de la entrada de cada laboratorio tiene la tecla E para los visitantes
-- (el dueño no se da a sí mismo); uno por día a cada laboratorio. Lo valida el servidor.
-- Posiciones: en el servidor (leaderstats, la lista de jugadores de Roblox) y global
-- (OrderedDataStore): más especies descubiertas y más variantes conseguidas.
-- Nadie escribe texto propio: los nombres de las criaturas se arman con sílabas fijas.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Experimento = require(ReplicatedStorage.Shared.Experimento)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Reloj = require(script.Parent.Reloj)
local Remotos = require(script.Parent.Remotos)

local S = Config.Social
local FUENTE = Font.fromEnum(Enum.Font.FredokaOne)

local Social = {}

---------------------------------------------------------------------------
-- Puntajes
---------------------------------------------------------------------------

local function cantidad(t: { [string]: any }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

-- Especies descubiertas (las 50 y las especiales) y variantes conseguidas.
function Social.puntaje(d: Jugadores.Datos): (number, number)
	return Jugadores.cantidadEspecies(d) + cantidad(d.Especiales), #Jugadores.aLista(d.Variantes)
end

-- La tabla del servidor: la lista de jugadores de Roblox (leaderstats).
local function actualizarStats(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local stats = jugador:FindFirstChild("leaderstats")
	if not stats then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		for _, nombre in { "Especies", "Variantes" } do
			local v = Instance.new("IntValue")
			v.Name = nombre
			v.Parent = stats
		end
		stats.Parent = jugador
	end
	local especies, variantes = Social.puntaje(d)
	local valorEspecies = (stats :: Instance):FindFirstChild("Especies") :: IntValue
	local valorVariantes = (stats :: Instance):FindFirstChild("Variantes") :: IntValue
	valorEspecies.Value = especies
	valorVariantes.Value = variantes
end

-- Global: dos OrderedDataStore. Si Studio no tiene acceso, se juega igual sin tabla global.
local globales: { [string]: OrderedDataStore } = {}
do
	local ok = pcall(function()
		globales.Especies = DataStoreService:GetOrderedDataStore(S.TablaEspecies)
		globales.Variantes = DataStoreService:GetOrderedDataStore(S.TablaVariantes)
	end)
	if not ok then
		globales = {}
	end
end

local nombres: { [number]: string } = {}
local function nombreDe(userId: number): string
	local guardado = nombres[userId]
	if guardado then
		return guardado
	end
	local presente = Players:GetPlayerByUserId(userId)
	if presente then
		return presente.DisplayName
	end
	local ok, nombre = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	local n = if ok and typeof(nombre) == "string" then nombre else "Jugador"
	nombres[userId] = n
	return n
end

type Fila = { Nombre: string, Especies: number, Variantes: number }
local topGlobal: { Fila } = {}

local function guardarGlobal()
	if not globales.Especies then
		return
	end
	for jugador, d in Jugadores.todos() do
		-- Los jugadores de prueba de Studio (UserId negativo) no van a la tabla de verdad.
		if jugador.UserId <= 0 then
			continue
		end
		local especies, variantes = Social.puntaje(d)
		local clave = tostring(jugador.UserId)
		pcall(function()
			globales.Especies:SetAsync(clave, especies)
			globales.Variantes:SetAsync(clave, variantes)
		end)
	end
end

local function leerGlobal()
	if not globales.Especies then
		return
	end
	local ok, pagina = pcall(function()
		return globales.Especies:GetSortedAsync(false, S.Mostrar):GetCurrentPage()
	end)
	if not ok then
		return
	end
	local filas: { Fila } = {}
	for _, entrada in pagina :: { any } do
		local userId = tonumber(entrada.key) or 0
		local variantes = 0
		pcall(function()
			variantes = globales.Variantes:GetAsync(entrada.key) or 0
		end)
		table.insert(
			filas,
			{ Nombre = nombreDe(userId), Especies = entrada.value, Variantes = variantes }
		)
	end
	topGlobal = filas
end

---------------------------------------------------------------------------
-- Tableros de la plaza
---------------------------------------------------------------------------

-- La pantalla de un tablero de la plaza por el título que tiene escrito.
local function pantalla(titulo: string): Frame?
	local tableros = workspace:FindFirstChild("Plaza")
	tableros = tableros and tableros:FindFirstChild("Tableros")
	for _, d in if tableros then tableros:GetDescendants() else {} do
		if d:IsA("TextLabel") and d.Text == titulo then
			local marco = d.Parent
			return if marco and marco:IsA("Frame") then marco else nil
		end
	end
	return nil
end

local function texto(
	padre: Instance,
	nombre: string,
	pos: UDim2,
	tam: UDim2,
	color: Color3
): TextLabel
	local t = padre:FindFirstChild(nombre) :: TextLabel?
	if not t then
		local nuevo = Instance.new("TextLabel")
		nuevo.Name = nombre
		nuevo.BackgroundTransparency = 1
		nuevo.FontFace = FUENTE
		nuevo.TextScaled = true
		nuevo.TextXAlignment = Enum.TextXAlignment.Left
		local s = Instance.new("UIStroke")
		s.Color = Paleta.Contorno
		s.Thickness = 2
		s.Parent = nuevo
		nuevo.Parent = padre
		t = nuevo
	end
	local l = t :: TextLabel
	l.Position = pos
	l.Size = tam
	l.TextColor3 = color
	return l
end

-- Saca lo que decía "¡Muy pronto!" y el dibujo viejo del tablero (lo de abajo del título).
local function limpiar(marco: Frame, titulo: string)
	for _, d in marco:GetChildren() do
		if d:IsA("TextLabel") and d.Text ~= titulo and not d:GetAttribute("Nuestro") then
			d:Destroy()
		end
	end
end

-- Una columna de la tabla: el título y un renglón de alto fijo por puesto (así un solo jugador
-- no ocupa toda la pantalla con letras gigantes).
local function columna(
	marco: Frame,
	nombre: string,
	x: number,
	titulo: string,
	color: Color3,
	filas: { Fila }
)
	local t = texto(
		marco,
		"Titulo" .. nombre,
		UDim2.fromScale(x, 0.22),
		UDim2.fromScale(0.42, 0.1),
		color
	)
	t.Text = titulo
	t:SetAttribute("Nuestro", true)
	for i = 1, S.Mostrar do
		local f = filas[i]
		local r = texto(
			marco,
			nombre .. i,
			UDim2.fromScale(x, 0.35 + (i - 1) * 0.12),
			UDim2.fromScale(0.43, 0.1),
			if f then Paleta.Texto else Paleta.Metal
		)
		r.Text = if f
			then i .. ". " .. f.Nombre .. "  " .. f.Especies .. " esp. · " .. f.Variantes .. " var."
			elseif i == 1 then "Todavía nadie"
			else ""
		r:SetAttribute("Nuestro", true)
	end
end

local function pintarPosiciones()
	local marco = pantalla("TABLA DE POSICIONES")
	if not marco then
		return
	end
	limpiar(marco, "TABLA DE POSICIONES")
	local enServidor: { Fila } = {}
	for jugador, d in Jugadores.todos() do
		local especies, variantes = Social.puntaje(d)
		table.insert(
			enServidor,
			{ Nombre = jugador.DisplayName, Especies = especies, Variantes = variantes }
		)
	end
	table.sort(enServidor, function(a, b)
		if a.Especies ~= b.Especies then
			return a.Especies > b.Especies
		end
		return a.Variantes > b.Variantes
	end)
	while #enServidor > S.Mostrar do
		table.remove(enServidor)
	end
	columna(marco, "Servidor", 0.05, "En este servidor", Paleta.Acento, enServidor)
	columna(
		marco,
		"Global",
		0.53,
		if globales.Especies then "En todo el juego" else "En todo el juego (sin conexión)",
		Paleta.Dorado,
		topGlobal
	)
end

local diaPintado = -1

local function pintarExperimento()
	local hoy = Reloj.dia()
	if hoy == diaPintado then
		return
	end
	local marco = pantalla("EXPERIMENTO DEL DÍA")
	if not marco then
		return
	end
	diaPintado = hoy
	limpiar(marco, "EXPERIMENTO DEL DÍA")
	local c = Experimento.especie(hoy)
	-- La silueta, igual para todos.
	local vista = marco:FindFirstChild("Silueta") :: ViewportFrame?
	if not vista then
		local v = Instance.new("ViewportFrame")
		v.Name = "Silueta"
		v.BackgroundTransparency = 1
		v.Position = UDim2.fromScale(0.03, 0.2)
		v.Size = UDim2.fromScale(0.36, 0.78)
		v.Ambient = Paleta.LuzVista
		v.LightColor = Paleta.Texto
		v.Parent = marco
		vista = v
	end
	local visor = vista :: ViewportFrame
	visor:ClearAllChildren()
	local modelo = Generador.crear(c, CFrame.new(), nil)
	Generador.silueta(modelo)
	modelo.Parent = visor
	local camara = Instance.new("Camera")
	camara.FieldOfView = 38
	camara.CFrame = CFrame.lookAt(Vector3.new(-4, 3.8, -8.4), Vector3.new(0, 2.2, 0))
	camara.Parent = visor
	visor.CurrentCamera = camara
	local pistas = texto(
		marco,
		"Pistas",
		UDim2.fromScale(0.42, 0.22),
		UDim2.fromScale(0.55, 0.62),
		Paleta.Texto
	)
	pistas.Text = "¿Quién es?\n" .. table.concat(Experimento.pistas(c), "\n")
	pistas.TextYAlignment = Enum.TextYAlignment.Top
	pistas:SetAttribute("Nuestro", true)
	local pie =
		texto(marco, "Pie", UDim2.fromScale(0.42, 0.86), UDim2.fromScale(0.55, 0.11), Paleta.Acento)
	pie.Text = "Fusionala hoy y ganás un premio (menú Misiones)"
	pie:SetAttribute("Nuestro", true)
end

---------------------------------------------------------------------------
-- Me gusta
---------------------------------------------------------------------------

function Social.publicar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if d then
		Laboratorios.actualizarMeGusta(jugador, d.MeGusta)
		actualizarStats(jugador)
	end
end

local function darMeGusta(visitante: Player, lab: Model)
	local dueno = Laboratorios.duenoDe(lab)
	if not dueno or dueno == visitante then
		return
	end
	local dv, dd = Jugadores.obtener(visitante), Jugadores.obtener(dueno)
	if not dv or not dd then
		return
	end
	local hoy = Reloj.dia()
	local clave = tostring(dueno.UserId)
	if dv.MeGustaDados[clave] == hoy then
		Remotos.Aviso:FireClient(visitante, "Ya le diste me gusta hoy a este laboratorio.", "info")
		return
	end
	dv.MeGustaDados[clave] = hoy
	dd.MeGusta += 1
	Laboratorios.actualizarMeGusta(dueno, dd.MeGusta)
	Remotos.Aviso:FireClient(
		visitante,
		"¡Le diste me gusta al laboratorio de " .. dueno.DisplayName .. "!",
		"exito"
	)
	Remotos.Aviso:FireClient(
		dueno,
		"¡A " .. visitante.DisplayName .. " le gusta tu laboratorio!",
		"exito"
	)
end

function Social.iniciar()
	for _, lab in Laboratorios.todos() do
		local cartel = lab:FindFirstChild("MeGusta")
		for _, d in if cartel then cartel:GetDescendants() else {} do
			if d:IsA("ProximityPrompt") then
				d.Triggered:Connect(function(jugador: Player)
					darMeGusta(jugador, lab)
				end)
			end
		end
	end
	task.spawn(function()
		local vuelta = 0
		while true do
			for jugador in Jugadores.todos() do
				actualizarStats(jugador)
			end
			pintarExperimento()
			-- La tabla global se guarda y se lee cada tanto (el DataStore tiene límites).
			-- La primera, en la segunda vuelta (cuando ya cargaron los que estaban entrando).
			if vuelta % S.CadaGlobal == 1 then
				guardarGlobal()
				leerGlobal()
			end
			pintarPosiciones()
			vuelta += 1
			task.wait(S.CadaTablero)
		end
	end)
end

return Social
