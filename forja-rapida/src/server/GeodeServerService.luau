--!strict
-- Geodas: nacen, reciben golpes, se rompen y revelan una gema según la suerte de cada jugador.
--
-- Mapa: cada parte con el tag "PuntoGeoda" es un lugar donde nace una geoda. Atributos del
-- punto: Zona (número, obligatorio) y Jefe (true para el punto de la GEODA JEFE de la zona).
-- Grupo 3: Tamano (fijo, para las vetas ocultas y la Dimensión Prisma) y Secreto (número de
-- bioma: solo le pueden pegar los que abrieron su puerta secreta).
-- Grupo 4: Renacer (número: solo le pueden pegar los que renacieron esas veces; el Santuario).
-- Las geodas van a workspace.Geodas, con el tag "Geoda" y estos atributos (el cliente los lee
-- para el cartel, la barra de vida y los efectos): Zona, Tamano, Modificador, Vida, VidaMax,
-- Rota (true mientras se reproduce la revelación) y Variante (Grupo 4: el nombre de la roca, si
-- no es la de siempre).
--
-- El servidor decide todo. Por cada golpe revisa: que la geoda exista y siga viva, que el
-- jugador tenga datos, que no pase de GameConfig.Golpe.PorSegundo (con una ráfaga chica), que
-- su zona esté abierta para él y que esté a menos de GameConfig.Golpe.Alcance. El daño sale de
-- sus datos (Fuerza), nunca del cliente.
-- Al romperse, cada jugador que hizo al menos ParteParaPremio de la vida (y siempre el que la
-- rompió) tira su gema con su propia suerte. La Forja: la gema queda pendiente y el jugador
-- puede mejorarla con monedas "?"; Forja.luau la entrega (una sola vez) y manda la revelación.
-- Grupo 1: el modificador puede ser una combinación (dos exóticas juntas, mucho más rara). Al
-- romper, Descubrimientos anota lo encontrado y cobra los logros nuevos (una sola vez), que
-- viajan en la misma revelación para mostrarse en cadena. Lo rarísimo se anuncia a todos.
-- Grupo 6: durante un evento (Mundo.evento) cambian las chances de los modificadores, las gemas
-- y la suerte. La Geoda Ancestral la hace nacer Eventos.luau con GeodeServerService.nacerEspecial:
-- no vuelve a nacer y a cada uno le da una gema de su mejor zona.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Forja = require(script.Parent.Forja)
local Jugadores = require(script.Parent.Jugadores)
local ModeloGeoda = require(script.Parent.ModeloGeoda)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

-- Lo que se le manda a cada jugador al romper una geoda (ahora lo arma Forja.luau).
export type Revelacion = Forja.Revelacion

type Estado = {
	Modelo: Model,
	Roca: BasePart,
	Punto: BasePart,
	Zona: number,
	Tamano: string,
	Modificador: string,
	Vida: number,
	VidaMax: number,
	Viva: boolean,
	Danio: { [Player]: number }, -- cuánto le hizo cada uno
	Especial: boolean, -- la trae un evento: no vuelve a nacer
	ParteParaPremio: number,
	Secreto: number?, -- Grupo 3: está detrás de la puerta secreta de ese bioma
	Renacer: number?, -- Grupo 4: está en el Santuario (hace falta haber renacido tantas veces)
	Debil: Vector3?, -- punto débil en la superficie (atributo PuntoDebil para los clientes)
	DebilHasta: number,
}

local G = GameConfig.Golpe

local estados: { [Model]: Estado } = {}
local fichas: { [Player]: { Cantidad: number, Hora: number } } = {}
local rng = Random.new()
local function azar(): number
	return rng:NextNumber()
end

local carpeta = Instance.new("Folder")
carpeta.Name = "Geodas"
carpeta.Parent = workspace

local GeodeServerService = {}

-- Freno de golpes: cada jugador junta fichas a PorSegundo por segundo, hasta Rafaga.
-- Cada golpe gasta una; sin fichas, el golpe no cuenta.
local function gastarFicha(jugador: Player): boolean
	local ahora = os.clock()
	local f = fichas[jugador]
	if not f then
		f = { Cantidad = G.Rafaga, Hora = ahora }
		fichas[jugador] = f
	end
	local suyas = f :: { Cantidad: number, Hora: number }
	suyas.Cantidad = math.min(G.Rafaga, suyas.Cantidad + (ahora - suyas.Hora) * G.PorSegundo)
	suyas.Hora = ahora
	if suyas.Cantidad < 1 then
		return false
	end
	suyas.Cantidad -= 1
	return true
end

local function estaCerca(jugador: Player, e: Estado): boolean
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not humanoide or humanoide.Health <= 0 or not raiz or not raiz:IsA("BasePart") then
		return false
	end
	local radio = math.max(e.Roca.Size.X, e.Roca.Size.Z) / 2
	return (raiz.Position - e.Roca.Position).Magnitude - radio <= G.Alcance
end

local nacer: (punto: BasePart) -> ()

-- Tira la gema de un jugador para esta geoda y se la pasa a La Forja (que se la entrega).
local function premiar(jugador: Player, e: Estado): boolean
	local d = Jugadores.obtener(jugador)
	if not d then
		return false
	end
	-- la Ancestral y la Renacida dan gemas de la mejor zona de cada uno; las demás, de su zona
	local deMejorZona = e.Tamano == "Ancestral" or e.Tamano == "Renacida"
	local zonaGema = if deMejorZona then Reglas.mejorZona(d.Zonas) else e.Zona
	local suerte = Reglas.suerteGeoda(Jugadores.suerte(d), zonaGema, e.Tamano)
		* Mundo.suerte()
		* Jugadores.bendicion(d)
	-- Grupo 3: las geodas ocultas y prismáticas pueden dar su mineral secreto
	local secreta, unoEnSecreta = Reglas.secretaDe(e.Tamano, zonaGema)
	local esSecreta = secreta ~= nil and azar() < 1 / unoEnSecreta
	local rareza = if esSecreta and secreta
		then secreta.Rareza
		else Reglas.tirar(GameConfig.Rarezas, suerte, azar)
	local gema = if esSecreta then secreta else Reglas.gemaDe(zonaGema, rareza, azar)
	if not gema then
		warn(("[Geodas] no hay gema %s en la zona %d"):format(rareza, zonaGema))
		return false
	end
	local unidades = math.max(
		1,
		math.floor(Reglas.unidades(e.Tamano, e.Modificador) * Mundo.unidades(e.Modificador) + 0.5)
	)
	-- Grupo 4: la Geoda Renacida a veces suelta Esencia
	if e.Tamano == "Renacida" and azar() < 1 / GameConfig.Renacer.EsenciaUnoEn then
		d.Esencia += 1
		Jugadores.publicar(jugador)
		Remotos.Aviso:FireClient(jugador, "¡La Geoda Renacida soltó 1 de Esencia!")
	end
	-- La Forja: la piedra queda pendiente y el jugador intenta mejorarla; al entregarla pasa
	-- lo de siempre (mochila, logros, anuncio, tarjeta). Ver Forja.luau.
	Forja.empezar(jugador, {
		Gema = gema.Id,
		Rareza = rareza,
		Zona = zonaGema,
		Secreta = esSecreta,
		Unidades = unidades,
		Intentos = Reglas.intentosForja(rareza, e.Tamano, e.Modificador),
		Geoda = e.Modelo,
		Modificador = e.Modificador,
		Suerte = suerte,
		Tamano = e.Tamano,
	})
	return true
end

local function romper(e: Estado, ultimo: Player)
	e.Viva = false
	e.Modelo:SetAttribute("Rota", true)
	for _, p in e.Modelo:GetDescendants() do
		if p:IsA("BasePart") then
			p.CanCollide = false
			p.CanQuery = false
		end
	end
	local minimo = e.VidaMax * e.ParteParaPremio
	local premiados: { Player } = {}
	for jugador, danio in e.Danio do
		if jugador.Parent and (jugador == ultimo or danio >= minimo) then
			if premiar(jugador, e) then
				table.insert(premiados, jugador)
			end
		end
	end
	Mundo.avisarRotura({
		Modelo = e.Modelo,
		Zona = e.Zona,
		Tamano = e.Tamano,
		Modificador = e.Modificador,
		Danio = e.Danio,
		Premiados = premiados,
	})
	-- Se deja la geoda un momento para la animación y después nace otra en el mismo punto
	-- (salvo las especiales de los eventos).
	local t = Reglas.tamano(e.Tamano)
	task.delay(GameConfig.Revelacion.Duracion, function()
		estados[e.Modelo] = nil
		e.Modelo:Destroy()
		if e.Especial then
			return
		end
		task.wait(if t then t.Reaparicion else 3)
		if e.Punto.Parent then
			nacer(e.Punto)
		end
	end)
end

-- Punto débil: un punto de la superficie de la roca, del lado de afuera (los costados o
-- arriba). Se busca con un rayo desde afuera hacia el centro que solo ve esta geoda.
local function moverDebil(e: Estado)
	-- solo la roca (el modelo entero incluye el aura y el cartel)
	local cf, tam = e.Roca.CFrame, e.Roca.Size
	local angulo = rng:NextNumber() * math.pi * 2
	local subida = rng:NextNumber(0.15, 0.7)
	local dir = Vector3.new(math.cos(angulo), subida, math.sin(angulo)).Unit
	local radio = tam.Magnitude
	local centro = cf.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { e.Roca }
	local r = workspace:Raycast(centro + dir * radio, -dir * radio, params)
	local punto = if r then r.Position else centro + dir * math.min(tam.X, tam.Z) * 0.45
	local P = G.PuntoDebil
	e.Debil = punto
	e.DebilHasta = os.clock() + rng:NextNumber(P.CambiaCada[1], P.CambiaCada[2])
	e.Modelo:SetAttribute("PuntoDebil", punto)
end

-- ¿El punto que tocó el cliente está sobre la grieta? Solo se cree si además está pegado a
-- la geoda (cerca de su caja), así no sirve mandar cualquier posición.
local function enDebil(e: Estado, punto: unknown): boolean
	if typeof(punto) ~= "Vector3" or not e.Debil then
		return false
	end
	if punto.X ~= punto.X or punto.Y ~= punto.Y or punto.Z ~= punto.Z then
		return false
	end
	local cf, tam = e.Roca.CFrame, e.Roca.Size
	if (punto - cf.Position).Magnitude > tam.Magnitude / 2 + 3 then
		return false
	end
	local radio = math.max(G.PuntoDebil.Radio, tam.Magnitude * 0.08)
	return (punto - e.Debil).Magnitude <= radio
end

local function alGolpear(jugador: Player, geoda: unknown, punto: unknown)
	if typeof(geoda) ~= "Instance" then
		return
	end
	local e = estados[geoda :: any]
	if not e or not e.Viva then
		return
	end
	local d = Jugadores.obtener(jugador)
	if not d or not gastarFicha(jugador) then
		return
	end
	if not d.Zonas[e.Zona] then
		return -- zona cerrada para este jugador
	end
	if e.Secreto and not d.Secretos[e.Secreto] then
		return -- veta oculta detrás de una puerta que no abrió
	end
	if e.Renacer and d.Renacimientos < e.Renacer then
		return -- Santuario del Renacer: solo para los que ya renacieron
	end
	if not estaCerca(jugador, e) then
		return
	end
	local fuerza = Jugadores.fuerza(d)
	local debil = enDebil(e, punto)
	local hecho = Reglas.danioGolpe(fuerza, e.Tamano, e.Vida, e.VidaMax, debil)
	if debil then
		moverDebil(e) -- acertaste: la grieta salta a otro lado
	end
	e.Vida -= hecho
	e.Danio[jugador] = (e.Danio[jugador] or 0) + hecho
	e.Modelo:SetAttribute("Vida", e.Vida)
	-- cada cliente anima el pico de los demás cuando cambia esto (Golpes.client)
	local pico = jugador.Character and jugador.Character:FindFirstChild("Pico")
	if pico then
		pico:SetAttribute("Golpe", os.clock())
	end
	-- El número flotante muestra toda la Fuerza del golpe, aunque a la geoda le quedara menos.
	local mostrado = if debil then fuerza * G.PuntoDebil.Multiplicador else fuerza
	Remotos.Golpe:FireClient(jugador, e.Modelo, mostrado, e.Vida, debil)
	if e.Vida <= 0 then
		romper(e, jugador)
	end
end

-- Arma una geoda en un punto (con todo lo que necesita el servidor y el cliente).
local function crear(
	punto: BasePart,
	zona: number,
	tamano: string,
	modificador: string,
	vida: number,
	especial: boolean
): Model
	local modelo, roca = ModeloGeoda.crear(zona, tamano, modificador)
	-- Apoyada arriba del punto, girada al azar para que no se vean todas iguales.
	local arriba = punto.CFrame * CFrame.new(0, punto.Size.Y / 2, 0)
	modelo:PivotTo(
		CFrame.new(arriba.Position) * CFrame.Angles(0, rng:NextNumber() * math.pi * 2, 0)
	)
	modelo:SetAttribute("Zona", zona)
	modelo:SetAttribute("Tamano", tamano)
	modelo:SetAttribute("Modificador", modificador)
	modelo:SetAttribute("Vida", vida)
	modelo:SetAttribute("VidaMax", vida)
	modelo:SetAttribute("Rota", false)
	CollectionService:AddTag(modelo, "Geoda")
	estados[modelo] = {
		Modelo = modelo,
		Roca = roca,
		Punto = punto,
		Zona = zona,
		Tamano = tamano,
		Modificador = modificador,
		Vida = vida,
		VidaMax = vida,
		Viva = true,
		Danio = {},
		Especial = especial,
		ParteParaPremio = if tamano == "Ancestral"
			then G.ParteParaPremioAncestral
			else G.ParteParaPremio,
		Secreto = if typeof(punto:GetAttribute("Secreto")) == "number"
			then punto:GetAttribute("Secreto") :: number
			else nil,
		Renacer = if typeof(punto:GetAttribute("Renacer")) == "number"
			then punto:GetAttribute("Renacer") :: number
			else nil,
		DebilHasta = 0,
	}
	modelo.Parent = carpeta
	moverDebil(estados[modelo])
	return modelo
end

nacer = function(punto: BasePart)
	local zona = punto:GetAttribute("Zona")
	if typeof(zona) ~= "number" or not Reglas.zona(zona) then
		warn("[Geodas] el punto " .. punto:GetFullName() .. " no tiene un atributo Zona válido")
		return
	end
	-- Grupo 3: un punto puede pedir un tamaño fijo (las vetas ocultas y la Dimensión Prisma)
	local fijo = punto:GetAttribute("Tamano")
	local tamano = if typeof(fijo) == "string" and Reglas.tamano(fijo)
		then fijo
		elseif punto:GetAttribute("Jefe") == true then "Jefe"
		else Reglas.tamanoAlAzar(azar)
	local bonos = Mundo.bonos()
	local modificador = Reglas.tirar(GameConfig.Modificadores, 1, azar, bonos)
	local vida = Reglas.vidaGeoda(zona, tamano)
	if tamano == "Renacida" then
		-- Grupo 4: sigue al más fuerte de los que ya renacieron (para que no se rompa de un golpe)
		local fuerte = 0
		for _, d in Jugadores.todos() do
			if d.Renacimientos >= 1 then
				fuerte = math.max(fuerte, Jugadores.fuerza(d))
			end
		end
		vida = Reglas.vidaRenacida(fuerte)
	end
	crear(punto, zona, tamano, modificador, vida, false)
	-- Las rarísimas se anuncian (salvo las que el evento de ahora hace salir más: el evento ya
	-- se anunció y serían demasiados carteles).
	local mod = Reglas.modificador(modificador)
	local z = Reglas.zona(zona)
	if mod and mod.Anunciar and z and not (bonos and bonos[modificador]) then
		Anuncios.enviar(
			("¡Apareció una geoda %s en %s!"):format(mod.Nombre, z.Nombre),
			mod.Color,
			"Hallazgo"
		)
	end
end

local function alAgregarPunto(punto: Instance)
	if punto:IsA("BasePart") then
		punto.Transparency = 1
		punto.CanCollide = false
		punto.CanQuery = false
		punto.CanTouch = false
		nacer(punto)
	end
end

function GeodeServerService.iniciar()
	Remotos.Golpear.OnServerEvent:Connect(alGolpear)
	-- Los puntos débiles cambian de lugar solos cada tanto.
	task.spawn(function()
		while true do
			task.wait(0.5)
			local ahora = os.clock()
			for _, e in estados do
				if e.Viva and ahora >= e.DebilHasta then
					moverDebil(e)
				end
			end
		end
	end)
	CollectionService:GetInstanceAddedSignal("PuntoGeoda"):Connect(alAgregarPunto)
	for _, punto in CollectionService:GetTagged("PuntoGeoda") do
		alAgregarPunto(punto)
	end
	Players.PlayerRemoving:Connect(function(jugador: Player)
		fichas[jugador] = nil
		for _, e in estados do
			e.Danio[jugador] = nil
		end
	end)
end

-- Para los eventos ----------------------------------------------------------------------------

-- Hace nacer una geoda especial (no vuelve a nacer al romperse). Devuelve el modelo.
function GeodeServerService.nacerEspecial(
	punto: BasePart,
	zona: number,
	tamano: string,
	modificador: string,
	vida: number
): Model
	return crear(punto, zona, tamano, modificador, vida, true)
end

-- Saca una geoda especial que nadie terminó de romper (el jefe que se escapa).
function GeodeServerService.quitarEspecial(modelo: Model)
	local e = estados[modelo]
	if not e or not e.Viva then
		return
	end
	e.Viva = false
	modelo:SetAttribute("Escapo", true)
	task.delay(1.5, function()
		estados[modelo] = nil
		modelo:Destroy()
	end)
end

-- Vuelve a hacer nacer (con las chances de ahora) una parte de las geodas que nadie tocó.
-- Lo usan los eventos para que se note enseguida que cambiaron las chances.
function GeodeServerService.renovar(fraccion: number)
	local elegidas = {}
	for _, e in estados do
		if e.Viva and not e.Especial and e.Vida >= e.VidaMax and next(e.Danio) == nil then
			if rng:NextNumber() < fraccion then
				table.insert(elegidas, e)
			end
		end
	end
	for _, e in elegidas do
		e.Viva = false
		estados[e.Modelo] = nil
		e.Modelo:Destroy()
		if e.Punto.Parent then
			nacer(e.Punto)
		end
	end
end

-- Para las pruebas: cuántas geodas vivas hay.
function GeodeServerService.vivas(): number
	local n = 0
	for _, e in estados do
		if e.Viva then
			n += 1
		end
	end
	return n
end

return GeodeServerService
