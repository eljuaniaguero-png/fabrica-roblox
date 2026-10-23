--!strict
-- Loop principal: lanzar -> esperar la picada -> el servidor sortea el pez -> ritmo -> balde.
--
-- Antitrampa (ficha, sección 10): el pez y su rareza se sortean en la picada, ANTES del ritmo.
-- El cliente toca con su propio reloj y al final manda la lista de toques; el servidor revisa
-- que la cantidad y los tiempos sean posibles y que haya pasado el tiempo real del patrón, y
-- calcula él el resultado. El cliente nunca dice "lo saqué".
-- Lo que un tramposo sí puede: mandar toques perfectos y sacar siempre Afinados. Por eso la
-- vigilancia de abajo deja una marca (sin baneo automático) para revisar a mano.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Estilo = require(ReplicatedStorage.Shared.Estilo)
local Ritmo = require(ReplicatedStorage.Shared.Ritmo)
local Jugadores = require(script.Parent.Jugadores)
local Misiones = require(script.Parent.Misiones)
local Remotos = require(script.Parent.Remotos)

type Fase = "Libre" | "Esperando" | "Ritmo"

type Estado = {
	Fase: Fase,
	Token: number,
	Carga: number,
	Pez: Config.Pez?,
	Peso: number,
	Patron: Ritmo.Patron?,
	Inicio: number, -- os.clock() del servidor en que suena la primera nota
	Perfecto: number,
	Bien: number,
	Boya: BasePart?,
}

local Pesca = {}

local estados: { [Player]: Estado } = {}
local rng = Random.new()
local function azar(): number
	return rng:NextNumber()
end

local carpetaBoyas = Instance.new("Folder")
carpetaBoyas.Name = "Boyas"
carpetaBoyas.Parent = Workspace

local function estadoDe(jugador: Player): Estado
	local e = estados[jugador]
	if not e then
		e = { Fase = "Libre", Token = 0, Carga = 0, Peso = 0, Inicio = 0, Perfecto = 0, Bien = 0 }
		estados[jugador] = e
	end
	return e
end

local function sacarBoya(e: Estado)
	if e.Boya then
		e.Boya:Destroy()
		e.Boya = nil
	end
end

local function puntoCercano(jugador: Player): BasePart?
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return nil
	end
	local mejor: BasePart? = nil
	local mejorDist = Config.DistanciaPesca
	for _, punto in CollectionService:GetTagged("PuntoPesca") do
		if punto:IsA("BasePart") and punto:IsDescendantOf(Workspace) then
			local d = (punto.Position - raiz.Position).Magnitude
			if d <= mejorDist then
				mejor = punto
				mejorDist = d
			end
		end
	end
	return mejor
end

---------------------------------------------------------------- vigilancia de bots
-- Un humano siempre tiene algo de error. Más del 95% de Perfectos en los últimos 200 peces y
-- toques casi sin variación (desvío < 5 ms) = marca para revisar. No se banea solo.
local VIGILAR_PECES = 200
local historial: { [Player]: { { Perfectos: number, Notas: number, Desvio: number } } } = {}
local marcados: { [Player]: boolean } = {}

local function desvioEstandar(lista: { number }): number
	if #lista < 2 then
		return math.huge
	end
	local media = 0
	for _, x in lista do
		media += x
	end
	media /= #lista
	local suma = 0
	for _, x in lista do
		suma += (x - media) ^ 2
	end
	return math.sqrt(suma / (#lista - 1))
end

local function vigilar(jugador: Player, res: Ritmo.Resultado, notas: number)
	local h = historial[jugador]
	if not h then
		h = {}
		historial[jugador] = h
	end
	table.insert(h, { Perfectos = res.Perfectos, Notas = notas, Desvio = desvioEstandar(res.Desvios) })
	if #h > VIGILAR_PECES then
		table.remove(h, 1)
	end
	if #h < VIGILAR_PECES or marcados[jugador] then
		return
	end
	local perfectos, total, desvio = 0, 0, 0
	for _, x in h do
		perfectos += x.Perfectos
		total += x.Notas
		desvio += if x.Desvio == math.huge then 1 else x.Desvio
	end
	if perfectos / total > 0.95 and desvio / #h < 0.005 then
		marcados[jugador] = true
		-- ANALÍTICA: cuando se copie Analitica.luau de Forja Rápida, mandar esto como evento.
		warn(("Vigilancia: %s (%d) toca demasiado perfecto, revisar a mano"):format(jugador.Name, jugador.UserId))
	end
end

---------------------------------------------------------------- loop

local function terminar(jugador: Player, e: Estado, res: Ritmo.Resultado?)
	local pez, patron = e.Pez, e.Patron
	sacarBoya(e)
	e.Fase = "Libre"
	e.Pez = nil
	e.Patron = nil
	local d = Jugadores.obtener(jugador)
	if not d or not pez or not patron then
		return
	end

	if not res or not res.Sacado then
		Remotos.Pesca:FireClient(jugador, "Resultado", {
			Sacado = false,
			Perfectos = res and res.Perfectos or 0,
			Bien = res and res.Bien or 0,
			Errores = res and res.Errores or #patron.Tiempos,
		})
		if res then
			vigilar(jugador, res, #patron.Tiempos)
		end
		return
	end

	vigilar(jugador, res, #patron.Tiempos)
	local rareza = Ritmo.rareza(pez.Rareza)
	local precio = Ritmo.precio(pez, e.Peso, res.Afinado)
	local bonus = if res.RachaMax >= Config.RachaLargo then math.ceil(precio * Config.RachaBonus) else 0
	local nivelAntes = Ritmo.nivel(d.XP)
	local nuevo = not d.Vistos[pez.Id]
	local nuevoAfinado = res.Afinado and not d.Afinados[pez.Id]

	d.Escamas += bonus -- la racha paga en el momento; el pez se cobra al vender
	d.XP += rareza.XP * (if res.Afinado then 2 else 1)
	d.Vistos[pez.Id] = true
	if res.Afinado then
		d.Afinados[pez.Id] = true
	end
	d.Sacados += 1
	d.MasPesado = math.max(d.MasPesado, e.Peso)
	table.insert(d.Cubeta, { Id = pez.Id, Peso = e.Peso, Afinado = res.Afinado })
	Misiones.registrar(jugador, "Sacar", 1, { Rareza = pez.Rareza })
	Misiones.registrar(jugador, "Peso", 1, { Peso = e.Peso })
	if res.Afinado then
		Misiones.registrar(jugador, "Afinado", 1)
	end
	if res.RachaMax >= Config.RachaLargo then
		Misiones.registrar(jugador, "Racha", 1)
	end

	Remotos.Pesca:FireClient(jugador, "Resultado", {
		Sacado = true,
		Id = pez.Id,
		Nombre = pez.Nombre,
		Rareza = pez.Rareza,
		Peso = e.Peso,
		Afinado = res.Afinado,
		Precio = precio,
		Bonus = bonus,
		Perfectos = res.Perfectos,
		Bien = res.Bien,
		Errores = res.Errores,
		Nuevo = nuevo,
		NuevoAfinado = nuevoAfinado,
		SubioNivel = Ritmo.nivel(d.XP) > nivelAntes,
	})
	Jugadores.enviar(jugador)
end

local function yaSacoRaro(d: Jugadores.Datos): boolean
	for _, p in Config.Peces do
		if p.Rareza == "Raro" and d.Vistos[p.Id] then
			return true
		end
	end
	return false
end

local function elegirPez(d: Jugadores.Datos): Config.Pez
	-- primeros 5 minutos: la 1ª tirada es el pez más fácil y desde la 3ª sale un Raro hasta
	-- que saque uno (si se le escapa, el garantizado no se pierde)
	if d.Tiradas == 1 then
		return Ritmo.pezPorId("MojarraGlobo") or Ritmo.sortearPez(1, "Común", azar)
	elseif d.Tiradas >= Config.TiradaRaroGarantizado and not yaSacoRaro(d) then
		return Ritmo.sortearPez(1, "Raro", azar)
	end
	return Ritmo.sortearPez(1, Ritmo.sortearRareza(azar), azar)
end

local function picar(jugador: Player, token: number)
	local e = estados[jugador]
	local d = Jugadores.obtener(jugador)
	if not e or not d or e.Token ~= token or e.Fase ~= "Esperando" then
		return
	end
	-- si murió o se alejó mientras esperaba, el pez no pica y la caña se recoge
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 or not puntoCercano(jugador) then
		e.Token += 1
		e.Fase = "Libre"
		sacarBoya(e)
		Remotos.Pesca:FireClient(jugador, "Cancelado")
		return
	end
	d.Tiradas += 1
	local pez = elegirPez(d)
	local patron = Ritmo.patron(pez)
	local perfecto, bien = Ritmo.ventanas(d.Cana)
	e.Fase = "Ritmo"
	e.Pez = pez
	e.Peso = Ritmo.peso(pez, e.Carga, azar)
	e.Patron = patron
	e.Perfecto = perfecto
	e.Bien = bien
	e.Inicio = os.clock() + Config.CuentaRegresiva
	if e.Boya then
		e.Boya.CFrame -= Vector3.new(0, 0.6, 0) -- se hunde: picó
	end
	-- no se manda qué pez es: la rareza se revela al final
	Remotos.Pesca:FireClient(jugador, "Pico", {
		Token = token,
		Tiempos = patron.Tiempos,
		Alturas = patron.Alturas,
		Duracion = patron.Duracion,
		Cuenta = Config.CuentaRegresiva,
		Perfecto = perfecto,
		Bien = bien,
		Tension = Config.TensionInicial,
	})
	-- si el cliente nunca contesta (se colgó, cerró), el pez se escapa
	task.delay(Config.CuentaRegresiva + patron.Duracion + 6, function()
		if e.Token == token and e.Fase == "Ritmo" then
			terminar(jugador, e, nil)
		end
	end)
end

local function alLanzar(jugador: Player, carga: unknown)
	if typeof(carga) ~= "number" or carga ~= carga then
		return
	end
	local d = Jugadores.obtener(jugador)
	local e = estadoDe(jugador)
	if not d or e.Fase ~= "Libre" then
		return
	end
	if #d.Cubeta >= Jugadores.capacidad(d) then
		Remotos.Aviso:FireClient(jugador, "¡Balde lleno! Vendé en el puesto del muelle")
		return
	end
	local punto = puntoCercano(jugador)
	if not punto then
		Remotos.Aviso:FireClient(jugador, "Acercate a la punta del muelle para pescar")
		return
	end

	e.Token += 1
	e.Fase = "Esperando"
	e.Carga = math.clamp(carga :: number, 0, 1)
	local dist = Config.BoyaCerca + (Config.BoyaLejos - Config.BoyaCerca) * e.Carga
	local pos = punto.Position + punto.CFrame.LookVector * dist
	local boya = Instance.new("Part")
	boya.Name = "Boya_" .. jugador.UserId
	boya.Shape = Enum.PartType.Ball
	boya.Size = Vector3.new(1.2, 1.2, 1.2)
	boya.Color = Estilo.Mundo.Boya -- sin Highlight: hay una por jugador y el límite es 31
	boya.Material = Enum.Material.SmoothPlastic
	boya.Anchored = true
	boya.CanCollide = false
	boya.CanQuery = false
	boya.CFrame = CFrame.new(pos.X, 0.3, pos.Z) -- superficie del agua en y = 0 (ver Mundo.luau)
	boya.Parent = carpetaBoyas
	e.Boya = boya

	local espera = if d.Tiradas == 0
		then Config.EsperaPrimeraTirada
		else Config.EsperaMin + (Config.EsperaMax - Config.EsperaMin) * azar()
	Remotos.Pesca:FireClient(jugador, "Lanzado", { Boya = boya })
	task.delay(espera, picar, jugador, e.Token)
end

local function alRecibirToques(jugador: Player, token: unknown, lista: unknown)
	local e = estados[jugador]
	if not e or e.Fase ~= "Ritmo" or token ~= e.Token or typeof(lista) ~= "table" then
		return
	end
	local patron = e.Patron :: Ritmo.Patron
	local n = #patron.Tiempos

	-- toques posibles: números, en el rango del patrón, no demasiados y no imposiblemente juntos
	local toques = {}
	local valido = true
	for _, t in lista :: { any } do
		if typeof(t) ~= "number" or t ~= t or t < -1 or t > patron.Duracion + 1 then
			valido = false
			break
		end
		table.insert(toques, t)
		if #toques > n * 2 + 4 then
			valido = false
			break
		end
	end
	table.sort(toques)
	for i = 2, #toques do
		if toques[i] - toques[i - 1] < Config.ToqueMinimo then
			valido = false
			break
		end
	end
	if not valido then
		terminar(jugador, e, nil)
		return
	end

	local res = Ritmo.juzgar(patron, toques, e.Perfecto, e.Bien, Config.TensionInicial)
	-- terminar antes de que el patrón haya sonado de verdad (±1 s) solo pasa cuando la barra
	-- llegó a 0 y se cortó la línea: nunca da el pez, aunque los toques digan otra cosa
	if os.clock() - e.Inicio < patron.Duracion - 1 then
		res.Sacado = false
		res.Afinado = false
	end
	terminar(jugador, e, res)
end

local function alCancelar(jugador: Player)
	local e = estados[jugador]
	if e and e.Fase == "Esperando" then
		e.Token += 1
		e.Fase = "Libre"
		sacarBoya(e)
		Remotos.Pesca:FireClient(jugador, "Cancelado")
	end
end

function Pesca.alSalir(jugador: Player)
	local e = estados[jugador]
	if e then
		e.Token += 1
		sacarBoya(e)
	end
	estados[jugador] = nil
	historial[jugador] = nil
	marcados[jugador] = nil
end

function Pesca.iniciar()
	Remotos.Lanzar.OnServerEvent:Connect(alLanzar)
	Remotos.Toques.OnServerEvent:Connect(alRecibirToques)
	Remotos.Cancelar.OnServerEvent:Connect(alCancelar)
end

return Pesca
