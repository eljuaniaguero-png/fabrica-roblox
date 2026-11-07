--!strict
-- Combate cuerpo a cuerpo. El servidor decide cada golpe: el cliente solo pide y muestra efectos.
-- Valida tipo de pedido, frecuencia, recargas, energía, distancia y que el objetivo esté vivo.
-- Peleadores: todo Model con el tag "Combatiente" (jugadores y maniquíes de práctica).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)
local CuerpoComic = require(script.Parent.CuerpoComic)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Perfiles = require(script.Parent.Perfiles)

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

local function aturdir(personaje: Model)
	local e = estadoDe(personaje)
	local ahora = os.clock()
	e.aturdidoHasta = ahora + C.AturdeParry
	e.bloqueoDesde = nil
	personaje:SetAttribute("Aturdido", true)
	task.delay(C.AturdeParry, function()
		if os.clock() >= e.aturdidoHasta - 0.01 then
			personaje:SetAttribute("Aturdido", false)
		end
	end)
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
	task.delay(tiempo, function()
		if os.clock() >= e.aturdidoHasta - 0.01 then
			personaje:SetAttribute("Frenado", false)
		end
	end)
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
		raiz.AssemblyLinearVelocity = velocidad
	end
end

local pegarA: (Model, Model, number, string, Vector3) -> ()

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
	danio *= Niveles.danio(atacante)
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
	-- El martillazo desde el aire rompe el bloqueo.
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
		remoto:FireAllClients("Golpeado", objetivo, danio, fuerte, atacante)
		e.golpesSeguidos = if ahora - e.ultimoRecibido > C.VentanaDesgaste
			then 1
			else e.golpesSeguidos + 1
		e.ultimoRecibido = ahora
		local freno = C.Freno * C.DesgasteFreno ^ (e.golpesSeguidos - 1)
		if tipo ~= "Suave" then
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
	if estabaVivo and h.Health <= 0 then
		local ganador = Players:GetPlayerFromCharacter(atacante)
		-- Solo cuentan los jugadores: el maniquí no da Fichas.
		if ganador and Players:GetPlayerFromCharacter(objetivo) then
			Perfiles.sumarBaja(ganador)
		end
		if ganador and objetivo:GetAttribute("Maton") then
			Perfiles.sumarXp(ganador, C.Matones.Xp)
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
	elseif variante == "Arriba" and vigente and e.paso == #C.Golpes - 1 then
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
	remoto:FireAllClients("Ataca", personaje, math.max(e.paso, 1))
	task.delay(g.Impacto, function()
		resolverGolpe(
			personaje,
			g.Danio,
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
		end
	elseif pedido == "BloqueoFin" then
		e.bloqueoDesde = nil
	elseif pedido == "Dash" then
		if ahora >= e.dashListo and ahora >= e.aturdidoHasta then
			e.dashListo = ahora + C.DashRecarga
			e.dashEn = ahora
			e.invulnerableHasta = ahora + C.DashInvulnerable
			e.bloqueoDesde = nil
		end
	end
end)

local function prepararPeleador(personaje: Model)
	local h = personaje:WaitForChild("Humanoid") :: Humanoid
	h.MaxHealth = C.Vida
	h.Health = C.Vida
	personaje:SetAttribute("Energia", C.Energia)
	personaje:SetAttribute("Aturdido", false)
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
			if typeof(energia) == "number" and energia < C.Energia then
				m:SetAttribute("Energia", math.min(energia + C.EnergiaPorSegundo * 0.25, C.Energia))
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
end

-- Borde rojo para distinguirlo de un jugador. La barra de vida la dibuja el cliente.
local function marcarMaton(m: Model)
	local borde = Instance.new("Highlight")
	borde.FillTransparency = 1
	borde.OutlineColor = Color3.fromRGB(230, 60, 60)
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

-- Matón: busca al jugador cercano, se acerca, avisa y pega. Si se traba, se corre de costado.
local function crearMaton(punto: { number }, numero: number)
	local M = C.Matones
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (molde and molde:IsA("Model")) then
		return
	end
	local m = molde:Clone()
	m.Name = "Maton"
	for _, s in m:GetDescendants() do
		if s:IsA("BaseScript") then
			s:Destroy()
		end
	end
	local base = Config.Arena.Mapa.Centro + Vector3.new(punto[1], 4, punto[2])
	m:PivotTo(CFrame.new(base))
	m:SetAttribute("Maton", true)
	m.Parent = workspace
	CuerpoComic.vestir(m, M.Semilla + numero)
	ropaMaton(m, numero)
	prepararPeleador(m)
	local h = m:WaitForChild("Humanoid") :: Humanoid
	h.MaxHealth = M.Vida
	h.Health = M.Vida
	h.WalkSpeed = M.Velocidad
	h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	marcarMaton(m)
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
	local golpe, camina, quieto = pistaDe("Golpe2"), pistaDe("Caminar"), pistaDe("Quieto")
	estadoDe(m).reacciona = function(duro: boolean)
		(if duro then fuerte else liviano):Play(0.03)
	end
	quieto:Play()
	h.Running:Connect(function(rapidez)
		if rapidez > 1 and not camina.IsPlaying then
			camina:Play(0.1)
		elseif rapidez <= 1 and camina.IsPlaying then
			camina:Stop(0.1)
		end
	end)

	task.spawn(function()
		local listo = 0
		local antes = base
		while m.Parent and h.Health > 0 do
			task.wait(0.2)
			local _, r = partes(m)
			local libre = r and os.clock() >= estadoDe(m).aturdidoHasta
			local objetivo = r and libre and objetivoDe(r)
			if r and objetivo then
				local d = (objetivo.Position - r.Position).Magnitude
				if d > M.Golpea then
					local trabado = (r.Position - antes).Magnitude < 0.5
					local costado = if trabado
						then r.CFrame.RightVector * (if math.random() < 0.5 then -14 else 14)
						else Vector3.zero
					h:MoveTo(objetivo.Position + costado)
				elseif os.clock() >= listo then
					h:MoveTo(r.Position)
					r.CFrame = CFrame.lookAt(
						r.Position,
						Vector3.new(objetivo.Position.X, r.Position.Y, objetivo.Position.Z)
					)
					remoto:FireAllClients("Aviso", m)
					task.wait(M.Aviso)
					if h.Health > 0 and os.clock() >= estadoDe(m).aturdidoHasta then
						golpe:Play()
						task.wait(C.Golpes[2].Impacto)
						resolverGolpe(m, M.Danio, "Normal")
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
		task.wait(M.Vuelve)
		m:Destroy()
		crearMaton(punto, numero)
	end)
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
	for i, punto in C.Matones.Puntos do
		task.spawn(crearMaton, punto, i)
	end
end

Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Once(primerManiqui)
end)
for _, jugador in Players:GetPlayers() do
	if jugador.Character then
		task.spawn(primerManiqui, jugador.Character)
	end
end
