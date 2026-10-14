--!strict
-- Eventos del mundo (Grupo 6). Uno por vez, configurables en GameConfig.Eventos (duración,
-- frecuencia, chances, premios). Ciclo: pausa al azar -> aviso ("¡En 20 segundos: ...!") ->
-- evento -> premios y fin. Lo que hace cada uno:
--   Lluvia de Cristales  caen cristales cerca de cada jugador; tocarlos da Monedas de su
--                        mejor zona (el servidor revisa que el cristal exista y que estés al lado)
--   Erupción / Tormenta Neón / Eclipse del Vacío
--                        cambian las chances de los modificadores, las gemas y la suerte
--                        (Mundo.luau) y renuevan parte de las geodas para que se note enseguida
--   Fiebre de Minería    meta entre todos; si se cumple, premio para los que rompieron alguna
--   Jefe Ancestral       una geoda gigante que hay que romper entre todos antes de que se vaya
-- Al terminar, los que rompieron al menos una geoda durante el evento suman "eventos jugados"
-- (logro y título "Cazador de Eventos").
-- Para probar en Studio: atributo ForzarEvento (texto, el Id) en Workspace.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Descubrimientos = require(script.Parent.Descubrimientos)
local GeodeServerService = require(script.Parent.GeodeServerService)
local Jugadores = require(script.Parent.Jugadores)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

type Evento = GameConfig.Evento

local E = GameConfig.Eventos
local rng = Random.new()
local function azar(): number
	return rng:NextNumber()
end
local function ahora(): number
	return Workspace:GetServerTimeNow()
end

local participantes: { [Player]: boolean } = {}
local progreso, meta = 0, 0
local jefe: Model? = nil
local jefeRoto = false
local terminarYa = false
local cristales: { [BasePart]: boolean } = {}
local carpetaCristales = Instance.new("Folder")
carpetaCristales.Name = "CristalesLluvia"
carpetaCristales.Parent = Workspace

local Eventos = {}

-- Lo que pasa con las geodas durante el evento.
Mundo.alRomper(function(r: Mundo.Rotura)
	local ev = Mundo.evento()
	if not ev then
		return
	end
	for jugador in r.Danio do
		if jugador.Parent then
			participantes[jugador] = true
		end
	end
	if ev.Meta then
		progreso += 1
		Mundo.publicar({ Progreso = progreso })
		if progreso >= meta then
			terminarYa = true
		end
	end
	if ev.Jefe and r.Modelo == jefe then
		jefeRoto = true
		terminarYa = true
	end
end)

-- Monedas de premio para un jugador: `veces` gemas comunes de su mejor zona.
local function pagar(jugador: Player, veces: number, donde: Vector3?): number
	local d = Jugadores.obtener(jugador)
	if not d then
		return 0
	end
	local monto = math.floor(veces * Reglas.valorComun(Reglas.mejorZona(d.Zonas)))
	d.Monedas += monto
	Jugadores.publicar(jugador)
	Remotos.Premio:FireClient(jugador, monto, donde)
	return monto
end

-- Lluvia de cristales ---------------------------------------------------------------------------

local filtroSuelo = RaycastParams.new()
filtroSuelo.FilterType = Enum.RaycastFilterType.Exclude

local function suelo(x: number, z: number): Vector3?
	local excluir: { Instance } = { carpetaCristales }
	local geodas = Workspace:FindFirstChild("Geodas")
	if geodas then
		table.insert(excluir, geodas)
	end
	for _, j in Players:GetPlayers() do
		if j.Character then
			table.insert(excluir, j.Character)
		end
	end
	filtroSuelo.FilterDescendantsInstances = excluir
	local r = Workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), filtroSuelo)
	return if r then r.Position else nil
end

local function crearCristal(
	posicion: Vector3,
	def: {
		Cada: number,
		Radio: number,
		Duran: number,
		Premio: number,
		Maximo: number,
	}
)
	local molde = ServerStorage:FindFirstChild(GameConfig.Modelos.Carpeta)
	local deBlender = molde and molde:FindFirstChild("CristalLluvia")
	local p: BasePart
	if deBlender and deBlender:IsA("BasePart") then
		p = deBlender:Clone()
	else
		local parte = Instance.new("Part")
		parte.Size = Vector3.new(1.2, 2.4, 1.2)
		parte.Material = Enum.Material.Neon
		parte.Color = Color3.fromHex("#7CF5FF")
		p = parte
	end
	p.Name = "CristalLluvia"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = true
	p.CFrame = CFrame.new(posicion + Vector3.new(0, p.Size.Y / 2 + 0.3, 0))
		* CFrame.Angles(0, rng:NextNumber() * math.pi, 0)
	CollectionService:AddTag(p, "CristalLluvia") -- el cliente lo hace caer, girar y brillar
	cristales[p] = true
	p.Touched:Connect(function(otro: BasePart)
		if not cristales[p] then
			return
		end
		local jugador = Players:GetPlayerFromCharacter(otro.Parent)
		if not jugador or (otro.Position - p.Position).Magnitude > 10 then
			return
		end
		cristales[p] = nil
		pagar(jugador, def.Premio, p.Position)
		participantes[jugador] = true
		p:Destroy()
	end)
	p.Parent = carpetaCristales
	task.delay(def.Duran, function()
		if cristales[p] then
			cristales[p] = nil
			p:Destroy()
		end
	end)
end

local function lluvia(ev: Evento)
	local def = ev.Cristales
	if not def then
		return
	end
	task.spawn(function()
		while Mundo.evento() == ev and not terminarYa do
			for _, jugador in Players:GetPlayers() do
				local raiz = jugador.Character
					and jugador.Character:FindFirstChild("HumanoidRootPart")
				local cuantos = 0
				for _ in cristales do
					cuantos += 1
				end
				if raiz and raiz:IsA("BasePart") and cuantos < def.Maximo then
					local angulo = rng:NextNumber() * math.pi * 2
					local distancia = rng:NextNumber(6, def.Radio)
					local x = raiz.Position.X + math.cos(angulo) * distancia
					local z = raiz.Position.Z + math.sin(angulo) * distancia
					local pos = suelo(x, z)
					if pos then
						crearCristal(pos, def)
					end
				end
			end
			task.wait(def.Cada)
		end
	end)
end

-- Jefe Ancestral --------------------------------------------------------------------------------

local function puntoJefe(): BasePart?
	for _, p in CollectionService:GetTagged("PuntoAncestral") do
		if p:IsA("BasePart") then
			return p
		end
	end
	-- si el mapa no tiene uno, el del Jefe de la zona 1 (abierta para todos)
	for _, p in CollectionService:GetTagged("PuntoGeoda") do
		if p:IsA("BasePart") and p:GetAttribute("Zona") == 1 and p:GetAttribute("Jefe") == true then
			return p
		end
	end
	return nil
end

local function aparecerJefe(ev: Evento)
	local def = ev.Jefe
	local punto = puntoJefe()
	if not def or not punto then
		return
	end
	local fuerzas = {}
	for _, d in Jugadores.todos() do
		table.insert(fuerzas, Jugadores.fuerza(d))
	end
	local vida = Reglas.vidaAncestral(fuerzas)
	local modificador = Reglas.tirar(GameConfig.Modificadores, def.SuerteModificador, azar)
	local m = GeodeServerService.nacerEspecial(punto, 1, "Ancestral", modificador, vida)
	jefe = m
	Mundo.publicar({ JefeVida = vida, JefeVidaMax = vida })
	m:GetAttributeChangedSignal("Vida"):Connect(function()
		Mundo.publicar({ JefeVida = m:GetAttribute("Vida") })
	end)
end

-- Ciclo de un evento ----------------------------------------------------------------------------

local function empezar(ev: Evento)
	participantes, progreso, meta = {}, 0, 0
	jefe, jefeRoto, terminarYa = nil, false, false
	Mundo.poner(ev)
	if ev.Meta then
		meta = math.max(ev.Meta.Minimo, ev.Meta.PorJugador * #Players:GetPlayers())
	end
	Mundo.publicar({
		Evento = ev.Id,
		EventoFin = ahora() + ev.Duracion,
		Proximo = "",
		ProximoInicio = 0,
		Progreso = 0,
		Meta = meta,
		JefeVida = 0,
		JefeVidaMax = 0,
		JefeTop = "",
	})
	Anuncios.enviar(("¡Empezó %s! %s"):format(ev.Nombre, ev.Descripcion), ev.Color, "Evento")
	if ev.Renovar then
		GeodeServerService.renovar(ev.Renovar)
	end
	lluvia(ev)
	if ev.Jefe then
		aparecerJefe(ev)
	end
end

local function terminar(ev: Evento)
	-- Fiebre: premio para todos los que ayudaron, si llegaron a la meta.
	if ev.Meta and progreso >= meta then
		for jugador in participantes do
			if jugador.Parent then
				local monto = pagar(jugador, ev.Meta.Premio, nil)
				Remotos.Hitos:FireClient(jugador, {
					{
						Id = "Meta" .. ev.Id,
						Titulo = "¡Meta cumplida!",
						Nombre = ev.Nombre,
						Descripcion = "Entre todos rompieron " .. Formato.miles(meta) .. " geodas",
						Monedas = monto,
						Coleccion = false,
					},
				})
			end
		end
		Anuncios.enviar(
			("¡Meta cumplida en la %s! Premio para todos los que ayudaron"):format(ev.Nombre),
			ev.Color,
			"Evento"
		)
	end
	-- Jefe: si nadie lo terminó, se va.
	if ev.Jefe and jefe and not jefeRoto then
		GeodeServerService.quitarEspecial(jefe)
		Anuncios.enviar(
			"La Geoda Ancestral se fue... ¡la próxima vez entre todos!",
			ev.Color,
			"Jefe"
		)
	end
	-- Participación (logro "Cazador de Eventos").
	for jugador in participantes do
		local d = Jugadores.obtener(jugador)
		if d and jugador.Parent then
			d.EventosJugados += 1
			local hitos = Descubrimientos.revisar(jugador)
			if #hitos > 0 then
				Remotos.Hitos:FireClient(jugador, hitos)
			end
		end
	end
	for p in cristales do
		p:Destroy()
	end
	cristales = {}
	Mundo.poner(nil)
	Mundo.publicar({
		Evento = "",
		EventoFin = 0,
		Progreso = 0,
		Meta = 0,
		JefeVida = 0,
		JefeVidaMax = 0,
	})
end

local function forzado(): Evento?
	if not RunService:IsStudio() then
		return nil
	end
	local id = Workspace:GetAttribute("ForzarEvento")
	if typeof(id) ~= "string" or id == "" then
		return nil
	end
	Workspace:SetAttribute("ForzarEvento", nil)
	return Reglas.evento(id)
end

function Eventos.iniciar()
	if not E.Activos then
		return
	end
	task.spawn(function()
		local anterior: string? = nil
		local espera = E.PrimeraEspera
		while true do
			local elegido: Evento? = nil
			local hasta = os.clock() + espera
			while os.clock() < hasta do
				elegido = forzado()
				if elegido then
					break
				end
				task.wait(1)
			end
			local ev = elegido or Reglas.eventoAlAzar(azar, anterior)
			if ev.Jefe and not puntoJefe() then
				ev = Reglas.eventoAlAzar(azar, ev.Id) -- sin lugar para el jefe: otro evento
			end
			local aviso = if elegido then 3 else E.AvisoPrevio
			Mundo.publicar({ Proximo = ev.Id, ProximoInicio = ahora() + aviso })
			Anuncios.enviar(("¡En %d segundos: %s!"):format(aviso, ev.Nombre), ev.Color, "Evento")
			task.wait(aviso)
			empezar(ev)
			local fin = os.clock() + ev.Duracion
			while os.clock() < fin and not terminarYa do
				task.wait(0.5)
			end
			terminar(ev)
			anterior = ev.Id
			espera = rng:NextNumber(E.Intervalo[1], E.Intervalo[2])
		end
	end)
end

return Eventos
