--!strict
-- Combate cuerpo a cuerpo. El servidor decide cada golpe: el cliente solo pide y muestra efectos.
-- Valida tipo de pedido, frecuencia, recargas, energía, distancia y que el objetivo esté vivo.
-- Peleadores: todo Model con el tag "Combatiente" (jugadores y maniquíes de práctica).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)
local CuerpoComic = require(script.Parent.CuerpoComic)

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
	pedidos: { number },
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
			pedidos = {},
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

local function empujar(objetivo: Model, raiz: BasePart, direccion: Vector3, lanza: boolean)
	local velocidad = if lanza
		then direccion * C.Lanza + Vector3.new(0, C.LanzaArriba, 0)
		else direccion * C.Empuje
	local jugador = Players:GetPlayerFromCharacter(objetivo)
	if jugador then
		remoto:FireClient(jugador, "Empuje", velocidad)
	else
		raiz.AssemblyLinearVelocity = velocidad
	end
end

local function pegarA(
	atacante: Model,
	objetivo: Model,
	danio: number,
	empuja: boolean,
	direccion: Vector3
)
	local h, r = partes(objetivo)
	if not (h and r) then
		return
	end
	local e = estadoDe(objetivo)
	local ahora = os.clock()
	if ahora < e.invulnerableHasta then
		return
	end
	local _, raizAtacante = partes(atacante)
	local deFrente = raizAtacante ~= nil
		and r.CFrame.LookVector:Dot((raizAtacante.Position - r.Position).Unit) > 0
	if e.bloqueoDesde and deFrente then
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
		remoto:FireAllClients("Golpeado", objetivo, danio, empuja, atacante)
		frenar(objetivo, if empuja then C.FrenoLanzado else C.Freno)
		if e.reacciona then
			e.reacciona(empuja)
		end
		empujar(objetivo, r, direccion, empuja)
	end
	h:TakeDamage(danio)
end

local function resolverGolpe(atacante: Model, danio: number, empuja: boolean)
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
				if plano.Magnitude <= C.Alcance and plano.Magnitude > 0 then
					local direccion = plano.Unit
					if r.CFrame.LookVector:Dot(direccion) >= C.ConoGolpe then
						pegarA(atacante, otro, danio, empuja, direccion)
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

local function pedirGolpe(personaje: Model, e: Estado)
	local ahora = os.clock()
	if ahora < e.libreDesde or e.bloqueoDesde or ahora < e.aturdidoHasta then
		return
	end
	e.paso = if ahora - e.ultimoGolpe > C.ReinicioCombo then 1 else e.paso % #C.Golpes + 1
	local g = C.Golpes[e.paso]
	e.libreDesde = ahora + g.Espera
	remoto:FireAllClients("Ataca", personaje, e.paso)
	task.delay(g.Impacto, function()
		e.ultimoGolpe = os.clock()
		resolverGolpe(personaje, g.Danio, g.Empuja)
	end)
end

remoto.OnServerEvent:Connect(function(jugador, pedido)
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
		pedirGolpe(personaje, e)
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
						resolverGolpe(m, C.ManiquiDanio, false)
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

local hayManiqui = false
local function primerManiqui(personaje: Model)
	if hayManiqui then
		return
	end
	hayManiqui = true
	local r = personaje:WaitForChild("HumanoidRootPart") :: BasePart
	task.wait(1)
	crearManiqui(r.CFrame)
end

Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Once(primerManiqui)
end)
for _, jugador in Players:GetPlayers() do
	if jugador.Character then
		task.spawn(primerManiqui, jugador.Character)
	end
end
