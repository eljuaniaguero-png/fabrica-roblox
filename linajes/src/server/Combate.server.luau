--!strict
-- Combate cuerpo a cuerpo. El servidor decide cada golpe: el cliente solo pide y muestra efectos.
-- Valida tipo de pedido, frecuencia, recargas, energía, distancia y que el objetivo esté vivo.
-- Peleadores: todo Model con el tag "Combatiente" (jugadores y maniquíes de práctica).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)
local CuerpoComic = require(script.Parent.CuerpoComic)
local Estadisticas = require(ReplicatedStorage.Shared.Estadisticas)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Perfiles = require(script.Parent.Perfiles)

local function hitoMinuto1(jugador: Player?, hito: string)
	if not jugador then
		return
	end
	local ev = script.Parent:FindFirstChild("Minuto1Hito")
	if ev and ev:IsA("BindableEvent") then
		ev:Fire(jugador, hito)
	end
end

local C = Config.Combate
local TAG = "Combatiente"

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Combate"
remoto.Parent = ReplicatedStorage

type Estado = {
	paso: number,
	ultimoGolpe: number,
	libreDesde: number,
	bloqueoDesde: number?,
	invulnerableHasta: number,
	aturdidoHasta: number,
	dashListo: number,
	dashEn: number,
	contraHasta: number,
	contraDanio: number,
	contraGolpes: number,
	pedidos: { number },
	golpesSeguidos: number,
	ultimoRecibido: number,
	reacciona: ((fuerte: boolean) -> ())?,
}

local estados: { [Model]: Estado } = {}

local function estadoDe(personaje: Model): Estado
	local e = estados[personaje]
	if not e then
		e = {
			paso = 0,
			ultimoGolpe = 0,
			libreDesde = 0,
			bloqueoDesde = nil,
			invulnerableHasta = 0,
			aturdidoHasta = 0,
			dashListo = 0,
			dashEn = 0,
			contraHasta = 0,
			contraDanio = 0,
			contraGolpes = 0,
			pedidos = {},
			golpesSeguidos = 0,
			ultimoRecibido = 0,
		}
		estados[personaje] = e
	end
	return e
end

local function partes(personaje: Model): (Humanoid?, BasePart?)
	local h = personaje:FindFirstChildOfClass("Humanoid")
	local r = personaje:FindFirstChild("HumanoidRootPart")
	if h and r and r:IsA("BasePart") and h.Health > 0 then
		return h, r
	end
	return nil, nil
end

local function enZona(posicion: Vector3): boolean
	local A = Config.Arena
	return (Vector3.new(posicion.X, 0, posicion.Z) - A.ZonaCentro).Magnitude <= A.ZonaRadio
end

local EXP_COMIC = Config.Cuerpo.Comic.Expresiones

local function actualizarCaraEstado(personaje: Model, textura: string?)
	local hum = personaje:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		CuerpoComic.cara(personaje, textura)
	end
end

-- Aturdido y Frenado comparten el mismo reloj (aturdidoHasta): cuando se cumple, se sacan LOS DOS.
-- Antes cada uno sacaba solo el suyo y, si se pisaban (te aturden y enseguida te frenan), el
-- primero quedaba prendido para siempre y no andaba ninguna tecla de combate.
local function liberarSiTermino(personaje: Model, e: any)
	if os.clock() >= e.aturdidoHasta - 0.01 then
		personaje:SetAttribute("Aturdido", false)
		personaje:SetAttribute("Frenado", false)
		actualizarCaraEstado(personaje, nil)
	end
end

local function aturdir(personaje: Model, tiempo: number?)
	local dura = tiempo or C.AturdeParry
	local e = estadoDe(personaje)
	local ahora = os.clock()
	if ahora + dura <= e.aturdidoHasta then
		return
	end
	e.aturdidoHasta = ahora + dura
	e.bloqueoDesde = nil
	personaje:SetAttribute("Aturdido", true)
	actualizarCaraEstado(personaje, EXP_COMIC.dolor)
	task.delay(dura, liberarSiTermino, personaje, e)
end

local function frenar(personaje: Model, tiempo: number)
	local e = estadoDe(personaje)
	local hasta = os.clock() + tiempo
	if hasta <= e.aturdidoHasta then
		return
	end
	e.aturdidoHasta = hasta
	e.bloqueoDesde = nil
	personaje:SetAttribute("Frenado", true)
	actualizarCaraEstado(personaje, EXP_COMIC.dolor)
	task.delay(tiempo, liberarSiTermino, personaje, e)
end

-- Un NPC cerca de un jugador queda con la física en ese cliente, que pisa la velocidad que pone el
-- servidor. Antes de empujarlo, el servidor la retoma.
local function tomarFisica(raiz: BasePart)
	if not raiz.Anchored then
		pcall(function()
			raiz:SetNetworkOwner(nil)
		end)
	end
end

local function empujar(objetivo: Model, raiz: BasePart, direccion: Vector3, tipo: string)
	local velocidad = direccion * C.Empuje
	if tipo == "Suave" then
		return
	elseif tipo == "Lanza" or tipo == "Rompe" then
		velocidad = direccion * C.Lanza + Vector3.new(0, C.LanzaArriba, 0)
	elseif tipo == "Arriba" then
		velocidad = direccion * 4 + Vector3.new(0, C.SubeArriba, 0)
	elseif tipo == "Piso" then
		velocidad = Vector3.new(0, -C.BajaPiso, 0)
	end
	local jugador = Players:GetPlayerFromCharacter(objetivo)
	if jugador then
		remoto:FireClient(jugador, "Empuje", velocidad)
	else
		tomarFisica(raiz)
		raiz.AssemblyLinearVelocity = velocidad
	end
end

local pegarA: (Model, Model, number, string, Vector3) -> ()

-- Daño que hizo cada jugador al jefe actual: todos los que pegaron se llevan el premio.
local aportesJefe: { [Model]: { [Player]: number } } = {}

pegarA = function(atacante: Model, objetivo: Model, danio: number, tipo: string, direccion: Vector3)
	local h, r = partes(objetivo)
	if not (h and r) then
		return
	end
	if atacante:GetAttribute("Maton") and not Players:GetPlayerFromCharacter(objetivo) then
		return
	end
	local e = estadoDe(objetivo)
	local ahora = os.clock()
	if ahora < e.invulnerableHasta or enZona(r.Position) then
		return
	end
	local _, desde = partes(atacante)
	if desde and enZona(desde.Position) then
		return
	end
	danio *= Niveles.danio(atacante) * Estadisticas.defensa(objetivo)
	-- Contragolpe: esquiva y responde. Solo sirve contra golpes, no contra quemaduras.
	if ahora < e.contraHasta and tipo ~= "Suave" then
		e.contraHasta = 0
		e.invulnerableHasta = ahora + 0.5
		remoto:FireAllClients("Parry", objetivo, atacante)
		task.spawn(function()
			for _ = 1, e.contraGolpes do
				pegarA(objetivo, atacante, e.contraDanio, "Normal", -direccion)
				task.wait(0.14)
			end
		end)
		return
	end
	local _, raizAtacante = partes(atacante)
	local deFrente = raizAtacante ~= nil
		and r.CFrame.LookVector:Dot((raizAtacante.Position - r.Position).Unit) > 0
	local fuerte = tipo ~= "Normal" and tipo ~= "Suave"
	-- El martillazo desde el aire o golpe fuerte rompen la guardia.
	if e.bloqueoDesde and deFrente and tipo ~= "Piso" and tipo ~= "Rompe" and tipo ~= "Suave" then
		if ahora - e.bloqueoDesde <= C.VentanaParry then
			aturdir(atacante)
			remoto:FireAllClients("Parry", objetivo, atacante)
			return
		end
		local energia = (objetivo:GetAttribute("Energia") :: number?) or 0
		objetivo:SetAttribute("Energia", math.max(energia - C.EnergiaBloqueo, 0))
		danio *= 1 - C.FrenaBloqueo
		remoto:FireAllClients("Bloqueado", objetivo, danio)
		if energia <= C.EnergiaBloqueo then
			e.bloqueoDesde = nil -- sin energía se rompe la guardia
		end
	else
		local rompioGuardia = e.bloqueoDesde ~= nil and (tipo == "Piso" or tipo == "Rompe")
		if rompioGuardia then
			local energia = (objetivo:GetAttribute("Energia") :: number?) or 0
			objetivo:SetAttribute("Energia", math.max(energia - C.EnergiaBloqueo * 2, 0))
			aturdir(objetivo)
			remoto:FireAllClients("GuardiaRota", objetivo, danio, atacante)
		else
			remoto:FireAllClients("Golpeado", objetivo, danio, fuerte, atacante)
		end
		e.golpesSeguidos = if ahora - e.ultimoRecibido > C.VentanaDesgaste
			then 1
			else e.golpesSeguidos + 1
		e.ultimoRecibido = ahora
		local freno = C.Freno * C.DesgasteFreno ^ (e.golpesSeguidos - 1)
		if tipo ~= "Suave" and not rompioGuardia then
			frenar(objetivo, if fuerte then C.FrenoLanzado else freno)
		end
		if tipo == "Lanza" or tipo == "Piso" or tipo == "Rompe" then
			e.invulnerableHasta = ahora + C.FrenoLanzado + C.Proteccion
			e.golpesSeguidos = 0
		end
		if e.reacciona then
			e.reacciona(fuerte)
		end
		empujar(objetivo, r, direccion, tipo)
	end
	local estabaVivo = h.Health > 0
	h:TakeDamage(danio)
	do
		local atacanteJugador = Players:GetPlayerFromCharacter(atacante)
		if atacanteJugador then
			hitoMinuto1(atacanteJugador, "Combate")
			if objetivo:GetAttribute("Maton") then
				hitoMinuto1(atacanteJugador, "Maton")
			end
		end
	end
	if objetivo:GetAttribute("Jefe") then
		local quien = Players:GetPlayerFromCharacter(atacante)
		if quien then
			local lista = aportesJefe[objetivo] or {}
			aportesJefe[objetivo] = lista
			lista[quien] = (lista[quien] or 0) + danio
		end
	end
	if estabaVivo and h.Health <= 0 then
		CuerpoComic.cara(objetivo, EXP_COMIC.derrotado)
		local ganador = Players:GetPlayerFromCharacter(atacante)
		if objetivo:GetAttribute("Maton") then
			remoto:FireAllClients("Derribado", objetivo) -- estallido en el color del enemigo
		end
		-- Solo cuentan los jugadores: el maniquí no da Fichas.
		if ganador and Players:GetPlayerFromCharacter(objetivo) then
			Perfiles.sumarBaja(ganador)
		end
		if ganador and objetivo:GetAttribute("Maton") and not objetivo:GetAttribute("Jefe") then
			-- Premio según tipo y nivel del enemigo (Config.Enemigos).
			local xp = objetivo:GetAttribute("PremioXp")
			local chatarra = objetivo:GetAttribute("PremioChatarra")
			Perfiles.sumarXp(ganador, if typeof(xp) == "number" then xp else C.Matones.Xp)
			local datos = Perfiles.datos(ganador)
			if datos and typeof(chatarra) == "number" then
				Perfiles.cambiar(ganador, { Chatarra = datos.Chatarra + chatarra })
			end
			remoto:FireClient(ganador, "Premio", objetivo, xp, chatarra) -- "+60 XP" flotando
		end
	end
end

-- Objetos que se rompen a golpes (muro de hielo): tag Rompible y atributo Vida.
local function golpearRompibles(atacante: Model, r: BasePart, danio: number, alcance: number)
	for _, o in CollectionService:GetTagged("Rompible") do
		if o:IsA("BasePart") and o.Parent then
			local cerca = o.CFrame:PointToObjectSpace(r.Position)
			local borde = o.Size / 2 + Vector3.one * alcance
			local hacia = Vector3.new(o.Position.X - r.Position.X, 0, o.Position.Z - r.Position.Z)
			local adelante = hacia.Magnitude < 0.1
				or r.CFrame.LookVector:Dot(hacia.Unit) >= C.ConoGolpe - 0.3
			if math.abs(cerca.X) <= borde.X and math.abs(cerca.Z) <= borde.Z and adelante then
				local vida = ((o:GetAttribute("Vida") :: number?) or 0)
					- danio * Niveles.danio(atacante)
				if vida <= 0 then
					remoto:FireAllClients("SeRompe", o.Position, o.Size, o.Color)
					o:Destroy()
				else
					o:SetAttribute("Vida", vida)
					o.Transparency = math.min(o.Transparency + 0.1, 0.6) -- se va agrietando
				end
			end
		end
	end
end

local function resolverGolpe(atacante: Model, danio: number, tipo: string, alcance: number?)
	local _, r = partes(atacante)
	if not r then
		return
	end
	if os.clock() < estadoDe(atacante).aturdidoHasta then
		return
	end
	golpearRompibles(atacante, r, danio, (alcance or C.Alcance) * Niveles.tamano(atacante))
	for _, otro in CollectionService:GetTagged(TAG) do
		if otro ~= atacante and otro:IsA("Model") then
			local _, ro = partes(otro)
			if ro then
				local hacia = ro.Position - r.Position
				local plano = Vector3.new(hacia.X, 0, hacia.Z)
				if
					plano.Magnitude <= (alcance or C.Alcance) * Niveles.tamano(atacante)
					and plano.Magnitude > 0
				then
					local direccion = plano.Unit
					if r.CFrame.LookVector:Dot(direccion) >= C.ConoGolpe then
						pegarA(atacante, otro, danio, tipo, direccion)
					end
				end
			end
		end
	end
end

local function limite(e: Estado): boolean
	local ahora = os.clock()
	local vivos = {}
	for _, t in e.pedidos do
		if ahora - t < 1 then
			table.insert(vivos, t)
		end
	end
	e.pedidos = vivos
	if #vivos >= C.PedidosPorSegundo then
		return false
	end
	table.insert(vivos, ahora)
	return true
end

local function enElAire(personaje: Model, raiz: BasePart): boolean
	local filtro = RaycastParams.new()
	filtro.FilterDescendantsInstances = { personaje }
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(raiz.Position, Vector3.new(0, -C.AlturaAire - 3, 0), filtro) == nil
end

local function pedirGolpe(personaje: Model, e: Estado, variante: unknown)
	local ahora = os.clock()
	if ahora < e.libreDesde or e.bloqueoDesde or ahora < e.aturdidoHasta then
		return
	end
	local vigente = ahora - e.ultimoGolpe <= C.ReinicioCombo
	local _, raiz = partes(personaje)
	local g: any = nil
	-- La variante es un pedido: el servidor revisa que se cumpla.
	if variante == "Aire" and raiz and enElAire(personaje, raiz) then
		g = C.Variantes.Aire
		e.paso = 0
	elseif variante == "Fuerte" then
		g = C.Variantes.Fuerte
		e.paso = 0
	elseif variante == "Arriba" then
		g = C.Variantes.Arriba
		e.paso = 0
	elseif variante == "Dash" and ahora - e.dashEn <= C.VentanaDash then
		g = C.Variantes.Dash
	else
		e.paso = if vigente then e.paso % #C.Golpes + 1 else 1
		g = C.Golpes[e.paso]
	end
	e.ultimoGolpe = ahora
	e.libreDesde = ahora + (g.Espera + g.Recarga) * C.Tolerancia
	local esFuerte = g.Tipo == "Rompe" or g.Tipo == "Lanza" or g.Tipo == "Piso"
	remoto:FireAllClients("Ataca", personaje, math.max(e.paso, 1), esFuerte)
	-- Estática (pasiva de Electro): el 4.º golpe del combo electrocuta.
	local danio = g.Danio
	local jugador = Players:GetPlayerFromCharacter(personaje)
	if jugador and jugador:GetAttribute("Linaje") == "Electro" and e.paso == #C.Golpes then
		danio += Config.Poderes.EstaticaDanio
		remoto:FireAllClients("Estatica", personaje)
	end
	task.delay(g.Impacto, function()
		resolverGolpe(
			personaje,
			danio,
			g.Tipo,
			if g.Tipo == "Normal" then C.Alcance else C.AlcancePatada
		)
	end)
end

remoto.OnServerEvent:Connect(function(jugador, pedido, variante)
	if typeof(pedido) ~= "string" then
		return
	end
	local personaje = jugador.Character
	if not personaje then
		return
	end
	local h = partes(personaje)
	if not h then
		return
	end
	local e = estadoDe(personaje)
	if not limite(e) then
		return
	end
	local ahora = os.clock()
	if pedido == "Golpe" then
		pedirGolpe(personaje, e, variante)
	elseif pedido == "BloqueoInicio" then
		if
			ahora >= e.aturdidoHasta
			and ((personaje:GetAttribute("Energia") :: number?) or 0) > 0
		then
			e.bloqueoDesde = ahora
			hitoMinuto1(jugador, "Defensa")
		end
	elseif pedido == "BloqueoFin" then
		e.bloqueoDesde = nil
	elseif pedido == "Dash" then
		if ahora >= e.dashListo and ahora >= e.aturdidoHasta then
			e.dashListo = ahora + C.DashRecarga
			e.dashEn = ahora
			e.invulnerableHasta = ahora + C.DashInvulnerable
			e.bloqueoDesde = nil
			e.libreDesde = 0 -- permite cancelar recuperación y pegar enseguida
			hitoMinuto1(jugador, "Defensa")
		end
	end
end)

local function prepararPeleador(personaje: Model)
	local h = personaje:WaitForChild("Humanoid") :: Humanoid
	h.MaxHealth = Estadisticas.vidaMax(personaje)
	h.Health = h.MaxHealth
	personaje:SetAttribute("Energia", Estadisticas.energiaMax(personaje))
	personaje:SetAttribute("Aturdido", false)
	personaje:SetAttribute("Frenado", false)
	CollectionService:AddTag(personaje, TAG)
	local jugador = Players:GetPlayerFromCharacter(personaje)
	if jugador then
		estadoDe(personaje).invulnerableHasta = os.clock() + Config.Arena.ProteccionAparecer
		h.Died:Once(function()
			Perfiles.cortarRacha(jugador)
		end)
	end
	personaje.Destroying:Once(function()
		estados[personaje] = nil
	end)
end

Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Connect(prepararPeleador)
end)
for _, jugador in Players:GetPlayers() do
	jugador.CharacterAdded:Connect(prepararPeleador)
	if jugador.Character then
		task.spawn(prepararPeleador, jugador.Character)
	end
end

-- Arena: reaparición rápida y círculo que marca la zona segura.
Players.RespawnTime = Config.Arena.Reaparicion
do
	local zona = Instance.new("Part")
	zona.Name = "ZonaSegura"
	zona.Shape = Enum.PartType.Cylinder
	zona.Size = Vector3.new(0.3, Config.Arena.ZonaRadio * 2, Config.Arena.ZonaRadio * 2)
	zona.CFrame = CFrame.new(Config.Arena.ZonaCentro + Vector3.new(0, 1.2, 0))
		* CFrame.Angles(0, 0, math.pi / 2)
	zona.Anchored = true
	zona.CanCollide = false
	zona.CanQuery = false
	zona.CanTouch = false
	zona.Material = Enum.Material.Neon
	zona.Color = Color3.fromHex("#3fe0f0")
	zona.Transparency = 0.85
	zona.Parent = workspace
end

-- API para Poderes.server.luau: el daño pasa siempre por acá.
local api = Instance.new("BindableFunction")
api.Name = "CombateApi"
api.OnInvoke = function(accion: string, a: Model, b: any, c: any, d: any, e2: any)
	if accion == "Pegar" then
		pegarA(a, b, c, d, e2)
	elseif accion == "Aturdir" then
		-- Descarga de Electro, congelado de Criogenia: no se mueve ni ataca por `b` segundos.
		aturdir(a, b)
	elseif accion == "Mover" then
		-- Levantar de Telequinesis: le pone una velocidad (en el cliente si es un jugador).
		local _, r = partes(a)
		if r then
			local jugador = Players:GetPlayerFromCharacter(a)
			if jugador then
				remoto:FireClient(jugador, "Empuje", b)
			else
				tomarFisica(r)
				r.AssemblyLinearVelocity = b
			end
		end
	elseif accion == "Contra" then
		local e = estadoDe(a)
		e.contraHasta = os.clock() + b
		e.contraDanio = c
		e.contraGolpes = d
	end
	return true
end
api.Parent = script.Parent

-- Energía: se recupera sola.
task.spawn(function()
	while true do
		task.wait(0.25)
		for _, m in CollectionService:GetTagged(TAG) do
			local energia = m:GetAttribute("Energia")
			local tope = Estadisticas.energiaMax(m)
			if typeof(energia) == "number" and energia < tope then
				m:SetAttribute("Energia", math.min(energia + C.EnergiaPorSegundo * 0.25, tope))
			end
		end
	end
end)

-- Maniquí de práctica: aparece cerca del jugador, avisa y pega cada tanto para probar el parry.
local function crearManiqui(cerca: CFrame)
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (molde and molde:IsA("Model")) then
		warn("Combate: falta StarterCharacter para el maniquí")
		return
	end
	local m = molde:Clone()
	m.Name = "Maniqui"
	for _, s in m:GetDescendants() do
		if s:IsA("BaseScript") then
			s:Destroy()
		end
	end
	local donde = cerca * CFrame.new(0, 0, -C.ManiquiDistancia) * CFrame.Angles(0, math.pi, 0)
	m:PivotTo(donde)
	m.Parent = workspace
	CuerpoComic.vestir(m, C.ManiquiSemilla)
	prepararPeleador(m)
	local h = m:WaitForChild("Humanoid") :: Humanoid
	h.WalkSpeed = 0
	h.JumpPower = 0
	local animator = h:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = h
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = Config.Animaciones.base.Golpe2
	local pista = animator:LoadAnimation(anim)
	local function pistaDe(nombre: string): AnimationTrack
		local a = Instance.new("Animation")
		a.AnimationId = (Config.Animaciones.base :: any)[nombre]
		return (animator :: Animator):LoadAnimation(a)
	end
	local liviano, fuerte = pistaDe("GolpeLiviano"), pistaDe("GolpeFuerte")
	estadoDe(m).reacciona = function(duro: boolean)
		(if duro then fuerte else liviano):Play(0.03)
	end
	local quieta = Instance.new("Animation")
	quieta.AnimationId = Config.Animaciones.base.Quieto
	animator:LoadAnimation(quieta):Play()

	task.spawn(function()
		while m.Parent and h.Health > 0 do
			task.wait(C.ManiquiPausa)
			local _, r = partes(m)
			if r and os.clock() >= estadoDe(m).aturdidoHasta then
				for _, jugador in Players:GetPlayers() do
					local p = jugador.Character
					local rp = p and p:FindFirstChild("HumanoidRootPart") :: BasePart?
					if rp and (rp.Position - r.Position).Magnitude <= C.ManiquiAtaca then
						r.CFrame = CFrame.lookAt(
							r.Position,
							Vector3.new(rp.Position.X, r.Position.Y, rp.Position.Z)
						)
						remoto:FireAllClients("Aviso", m)
						task.wait(C.ManiquiAviso)
						pista:Play()
						task.wait(C.Golpes[2].Impacto)
						resolverGolpe(m, C.ManiquiDanio, "Normal")
						break
					end
				end
			end
		end
	end)
	h.Died:Once(function()
		task.wait(C.ManiquiVuelve)
		local lugar = m:GetPivot()
		m:Destroy()
		crearManiqui(lugar * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, C.ManiquiDistancia))
	end)
end

-- Modelo propio: esconde la ropa del cuerpo común y suelda las piezas de ServerStorage.MatonRopa.
local function ropaMaton(m: Model, numero: number)
	-- numero elige el gorro (1 a 3): cada tipo de enemigo tiene el suyo.
	local carpeta = ServerStorage:FindFirstChild("MatonRopa")
	if not carpeta then
		warn("Combate: falta ServerStorage.MatonRopa")
		return
	end
	for _, parte in m:GetChildren() do
		if parte:IsA("MeshPart") and parte.Name ~= "Cuello_Piel" then
			local prefijo = string.match(parte.Name, "^%a+")
			if prefijo ~= "Cuerpo" and prefijo ~= "Remera" then
				parte.Transparency = 1
			end
		end
	end
	local gorros = C.Matones.Gorros
	local gorro = gorros[(numero - 1) % #gorros + 1]
	for _, pieza in carpeta:GetChildren() do
		local esGorro = string.find(pieza.Name, "Gorro", 1, true) ~= nil
		local hueso = m:FindFirstChild(pieza:GetAttribute("Hueso") :: string)
		local desfase = pieza:GetAttribute("Desfase")
		if
			pieza:IsA("BasePart")
			and not (C.Matones.SinPiezas :: any)[pieza.Name]
			and (not esGorro or pieza.Name == gorro)
			and hueso
			and hueso:IsA("BasePart")
			and typeof(desfase) == "CFrame"
		then
			local copia = pieza:Clone()
			copia.Anchored = false
			copia.CFrame = hueso.CFrame * desfase
			local union = Instance.new("WeldConstraint")
			union.Part0 = hueso
			union.Part1 = copia
			union.Parent = copia
			copia.Parent = m
		end
	end
	local caraMaton = Config.Cuerpo.Comic.CarasNpc.Maton
	m:SetAttribute("CaraBase", caraMaton)
	CuerpoComic.cara(m, caraMaton)
end

-- Borde rojo para distinguirlo de un jugador. La barra de vida la dibuja el cliente.
local function marcarMaton(m: Model, color: Color3)
	local borde = Instance.new("Highlight")
	borde.FillTransparency = 1
	borde.OutlineColor = color
	borde.DepthMode = Enum.HighlightDepthMode.Occluded
	borde.Parent = m
end

local function objetivoDe(r: BasePart): BasePart?
	local mejor: BasePart? = nil
	local distancia = C.Matones.Detecta
	for _, jugador in Players:GetPlayers() do
		local p = jugador.Character
		local rp = p and p:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hp = p and p:FindFirstChildOfClass("Humanoid")
		if rp and hp and hp.Health > 0 and not enZona(rp.Position) then
			local d = (rp.Position - r.Position).Magnitude
			if d < distancia then
				mejor, distancia = rp, d
			end
		end
	end
	return mejor
end

-- Lugar al azar sobre el piso de una zona de enemigos (no arriba de contenedores).
local function puntoEnZona(zona: any): Vector3
	local centro = Config.Arena.Mapa.Centro + Vector3.new(zona.Centro[1], 0, zona.Centro[2])
	local filtro = RaycastParams.new()
	filtro.FilterDescendantsInstances = CollectionService:GetTagged(TAG)
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	for _ = 1, 20 do
		local a = math.random() * math.pi * 2
		local d = math.sqrt(math.random()) * zona.Radio
		local x, z = centro.X + math.cos(a) * d, centro.Z + math.sin(a) * d
		local golpe = workspace:Raycast(Vector3.new(x, 80, z), Vector3.new(0, -120, 0), filtro)
		if golpe and golpe.Position.Y <= Config.Enemigos.AlturaPiso then
			return golpe.Position + Vector3.new(0, 4, 0)
		end
	end
	return centro + Vector3.new(0, 4, 0)
end

local crearEnemigo: (number, string?) -> Model?

-- Enemigo: busca al jugador cercano, se acerca, avisa y pega. Si se traba, se corre de costado.
-- Tipo y nivel salen de su zona (Config.Enemigos); al morir aparece otro en la misma zona.
crearEnemigo = function(zonaIdx: number, forzado: string?): Model?
	local EN = Config.Enemigos
	local zona = EN.Zonas[zonaIdx]
	local tipoNombre = forzado or zona.Tipos[math.random(1, #zona.Tipos)]
	local T = (EN.Tipos :: any)[tipoNombre]
	local esJefe = forzado == "Jefe"
	local nivel = T.Nivel or math.random(zona.Nivel[1], zona.Nivel[2])
	local extra = nivel - 1
	local vidaMax = math.round(T.Vida * (1 + extra * EN.PorNivel.Vida))
	local danio = T.Danio * (1 + extra * EN.PorNivel.Danio)
	local M = table.clone(C.Matones)
	M.Vida = vidaMax
	M.Danio = danio
	M.Velocidad = T.Velocidad
	M.Golpea = C.Matones.Golpea * T.Escala -- los grandes pegan desde más lejos
	M.Bloqueo = table.clone(C.Matones.Bloqueo)
	M.Bloqueo.Chance = T.Bloqueo
	M.Embestida = table.clone(C.Matones.Embestida)
	M.Embestida.Recarga = T.EmbestidaRecarga
	local numero = T.Gorro
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (molde and molde:IsA("Model")) then
		return nil
	end
	local m = molde:Clone()
	m.Name = if esJefe then "Jefe" else "Maton"
	for _, s in m:GetDescendants() do
		if s:IsA("BaseScript") then
			s:Destroy()
		end
	end
	local base = puntoEnZona(zona)
	m:PivotTo(CFrame.new(base))
	m:SetAttribute("Maton", true)
	m:SetAttribute("Jefe", esJefe)
	m:SetAttribute("Tipo", tipoNombre)
	m:SetAttribute("Nivel", nivel)
	m:SetAttribute("Nombre", string.format("%s  ·  NV %d", T.Nombre, nivel))
	m:SetAttribute("PremioXp", math.round(T.Xp * (1 + extra * EN.PorNivel.Premio)))
	m:SetAttribute("PremioChatarra", math.round(T.Chatarra * (1 + extra * EN.PorNivel.Premio)))
	m:SetAttribute("ColorVfx", Color3.fromHex(T.ColorVfx or EN.ColorVfx))
	m.Parent = workspace
	CuerpoComic.vestir(m, M.Semilla + zonaIdx * 10 + math.random(1, 9))
	ropaMaton(m, numero)
	if T.Escala ~= 1 then
		m:ScaleTo(T.Escala) -- tamaño distinto por tipo (se lee de lejos)
	end
	prepararPeleador(m)
	local h = m:WaitForChild("Humanoid") :: Humanoid
	h.MaxHealth = M.Vida
	h.Health = M.Vida
	h.WalkSpeed = M.Velocidad
	h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	marcarMaton(m, Color3.fromHex(T.Borde))
	if not esJefe then
		remoto:FireAllClients("EnemigoAparece", m) -- sello en el piso
	end
	local animator = h:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = h
	end
	local function pistaDe(nombre: string): AnimationTrack
		local a = Instance.new("Animation")
		a.AnimationId = (Config.Animaciones.base :: any)[nombre]
		return (animator :: Animator):LoadAnimation(a)
	end
	local liviano, fuerte = pistaDe("GolpeLiviano"), pistaDe("GolpeFuerte")
	local golpes = { pistaDe("Golpe1"), pistaDe("Golpe2"), pistaDe("Golpe3") }
	local camina, quieto = pistaDe("Caminar"), pistaDe("Quieto")
	local bloqueoListo = 0
	estadoDe(m).reacciona = function(duro: boolean)
		(if duro then fuerte else liviano):Play(0.03)
		-- A veces corta tu combo cubriéndose.
		local B = M.Bloqueo
		if os.clock() >= bloqueoListo and math.random() < B.Chance then
			bloqueoListo = os.clock() + B.Recarga
			task.delay(0.25, function()
				local e = estadoDe(m)
				e.bloqueoDesde = os.clock()
				task.delay(B.Dura, function()
					e.bloqueoDesde = nil
				end)
			end)
		end
	end
	quieto:Play()
	h.Running:Connect(function(rapidez)
		if rapidez > 1 and not camina.IsPlaying then
			camina:Play(0.1)
		elseif rapidez <= 1 and camina.IsPlaying then
			camina:Stop(0.1)
		end
	end)

	-- Golpazo del jefe: círculo rojo en el piso, aviso y golpe fuerte a todos los que quedan adentro.
	local golpazoListo = os.clock() + 3
	local function golpazo(r: BasePart): boolean
		local G = T.Golpazo
		if not G or os.clock() < golpazoListo then
			return false
		end
		golpazoListo = os.clock() + G.Cada
		h:MoveTo(r.Position)
		local centro = r.Position - Vector3.new(0, 2.8 * T.Escala, 0)
		remoto:FireAllClients("Golpazo", centro, G.Radio, G.Aviso)
		fuerte:Play(0.05)
		task.wait(G.Aviso)
		if h.Health <= 0 then
			return true
		end
		for _, jugador in Players:GetPlayers() do
			local p = jugador.Character
			local rp = p and p:FindFirstChild("HumanoidRootPart")
			if p and rp and rp:IsA("BasePart") then
				local plano = Vector3.new(rp.Position.X - centro.X, 0, rp.Position.Z - centro.Z)
				if plano.Magnitude <= G.Radio then
					local dir = if plano.Magnitude > 0.1 then plano.Unit else Vector3.zAxis
					pegarA(m, p, G.Danio, "Rompe", dir)
				end
			end
		end
		return true
	end

	task.spawn(function()
		local listo = 0
		local embestidaLista = 0
		local antes = base
		while m.Parent and h.Health > 0 do
			task.wait(0.2)
			local _, r = partes(m)
			local libre = r and os.clock() >= estadoDe(m).aturdidoHasta
			local objetivo = r and libre and objetivoDe(r)
			if r and objetivo then
				local d = (objetivo.Position - r.Position).Magnitude
				local E = M.Embestida
				if T.Golpazo and d <= T.Golpazo.Radio and golpazo(r) then
					listo = os.clock() + M.Pausa
				elseif d >= E.Desde and d <= E.Hasta and os.clock() >= embestidaLista then
					embestidaLista = os.clock() + E.Recarga
					local fin = os.clock() + E.Dura
					local rumbo = Vector3.new(
						objetivo.Position.X - r.Position.X,
						0,
						objetivo.Position.Z - r.Position.Z
					).Unit
					r.CFrame = CFrame.lookAt(r.Position, r.Position + rumbo)
					while os.clock() < fin and h.Health > 0 do
						r.AssemblyLinearVelocity = rumbo * E.Rapidez
							+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
						task.wait()
					end
				elseif d > M.Golpea then
					local trabado = (r.Position - antes).Magnitude < 0.5
					local costado = if trabado
						then r.CFrame.RightVector * (if math.random() < 0.5 then -14 else 14)
						else Vector3.zero
					h:MoveTo(objetivo.Position + costado)
				elseif os.clock() >= listo then
					h:MoveTo(r.Position)
					remoto:FireAllClients("Aviso", m)
					task.wait(M.Aviso)
					-- Combo de 2 o 3 golpes: el último lanza.
					local cantidad = math.random(2, 3)
					for i = 1, cantidad do
						if h.Health <= 0 or os.clock() < estadoDe(m).aturdidoHasta then
							break
						end
						r.CFrame = CFrame.lookAt(
							r.Position,
							Vector3.new(objetivo.Position.X, r.Position.Y, objetivo.Position.Z)
						)
						golpes[i]:Play()
						task.wait(C.Golpes[i].Impacto)
						resolverGolpe(
							m,
							M.Danio,
							if i == 3 then "Lanza" else "Normal",
							C.Alcance * T.Escala
						)
						task.wait(0.14)
					end
					listo = os.clock() + M.Pausa
				end
				antes = r.Position
			elseif r and libre and (r.Position - base).Magnitude > 6 then
				h:MoveTo(base)
			end
		end
	end)
	h.Died:Once(function()
		if esJefe then
			return -- el jefe lo maneja su propio ciclo (no reaparece)
		end
		task.wait(EN.Vuelve)
		m:Destroy()
		crearEnemigo(zonaIdx)
	end)
	return m
end

-- Jefe: aparece cada tanto en una zona, avisa a todo el servidor y reparte el premio entre todos
-- los que le pegaron. Si nadie lo derrota en DuraMax, se va.
local function cicloJefe()
	local J = Config.Enemigos.Jefe
	task.wait(if RunService:IsStudio() then J.PrimeroAStudio else J.PrimeroA)
	while true do
		if #Players:GetPlayers() > 0 then
			local zonaIdx = J.Zonas[math.random(1, #J.Zonas)]
			local zona = Config.Enemigos.Zonas[zonaIdx]
			local jefe = crearEnemigo(zonaIdx, "Jefe")
			if jefe then
				local nombre = Config.Enemigos.Tipos.Jefe.Nombre
				remoto:FireAllClients("Jefe", "Aparece", nombre, zona.Nombre, jefe)
				local h = jefe:FindFirstChildOfClass("Humanoid")
				local fin = os.clock() + J.DuraMax
				while h and h.Health > 0 and jefe.Parent and os.clock() < fin do
					task.wait(0.5)
				end
				if h and h.Health <= 0 then
					local cuantos = 0
					for jugador in aportesJefe[jefe] or {} do
						local datos = Perfiles.datos(jugador)
						if datos then
							cuantos += 1
							Perfiles.sumarXp(jugador, J.Premio.Xp)
							Perfiles.cambiar(jugador, {
								Chatarra = datos.Chatarra + J.Premio.Chatarra,
								Fichas = datos.Fichas + J.Premio.Fichas,
							})
						end
					end
					remoto:FireAllClients("Jefe", "Derrotado", nombre, cuantos)
					task.wait(4)
				else
					remoto:FireAllClients("Jefe", "SeFue", nombre)
				end
				aportesJefe[jefe] = nil
				jefe:Destroy()
			end
		end
		task.wait(J.Cada)
	end
end

local hayManiqui = false
local function primerManiqui(personaje: Model)
	if hayManiqui then
		return
	end
	hayManiqui = true
	local r = personaje:WaitForChild("HumanoidRootPart") :: BasePart
	task.wait(1)
	crearManiqui(r.CFrame)
	for zonaIdx, zona in Config.Enemigos.Zonas do
		for _ = 1, zona.Max do
			task.spawn(crearEnemigo, zonaIdx)
		end
	end
	task.spawn(cicloJefe)
end

Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Once(primerManiqui)
end)
for _, jugador in Players:GetPlayers() do
	if jugador.Character then
		task.spawn(primerManiqui, jugador.Character)
	end
end
