--!strict
-- Animación propia de correr (pedido B1, 25/10/2026). Solo mientras el jugador corre (atributo
-- "Corriendo" que pone el servidor); caminar, saltar parado y quedarse quieto siguen con las
-- animaciones de Roblox. Las animaciones son Movement, así que tapan a las de Roblox (Core)
-- sin tocar el Animate.
--   Arranca desde quieto: 3 pasos de arranque y después el ciclo.
--   Corre: ciclo de 0,55 s con AdjustSpeed según la velocidad real y el largo de piernas del
--          avatar, para que el pie de apoyo no patine (GameConfig.Correr.VelocidadAnimacion).
--   Se para después de correr más de 1 s: derrape con polvo.
--   Salta corriendo: salto con la rodilla arriba hasta que toca el piso.
--   Con el pico en la mano: CorrerPico (brazo quieto) y el pico se balancea con retraso.
-- En cada pisada (markers Pisada_Izq y Pisada_Der) sale polvo del color del piso y suena la
-- pisada según el piso; se escucha también la de los demás jugadores.
-- Las animaciones salen de GameConfig.Animaciones; si están vacías, en Studio se arman desde
-- shared/AnimacionesCorrer (en el juego publicado, sin ID, queda la de Roblox).

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AnimacionesCorrer = require(ReplicatedStorage.Shared.AnimacionesCorrer)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Efectos = require(script.Parent.Efectos)
local Sonidos = require(script.Parent.Sonidos)

local C = GameConfig.Correr
local jugador = Players.LocalPlayer

-- IDs de las animaciones ---------------------------------------------------------------------

local ids: { [string]: string } = {}
local nuestras: { [string]: string } = {} -- AnimationId -> nombre (para reconocer las de otros)

local function idDe(nombre: string): string?
	local guardado = ids[nombre]
	if guardado == nil then
		local publicado: string = (GameConfig.Animaciones :: any)[nombre] or ""
		if publicado == "" and RunService:IsStudio() then
			local ok, id = pcall(function()
				return KeyframeSequenceProvider:RegisterKeyframeSequence(
					AnimacionesCorrer.crear(nombre)
				)
			end)
			publicado = if ok then id else ""
			if not ok then
				warn("AnimCorrer: no se pudo armar " .. nombre .. ": " .. tostring(id))
			end
		end
		guardado = publicado
		ids[nombre] = publicado
		if publicado ~= "" then
			nuestras[publicado] = nombre
		end
	end
	return if guardado ~= "" then guardado else nil
end

for _, n in AnimacionesCorrer.Nombres do
	idDe(n)
end

-- Polvo y sonido de pisada (para cualquier personaje) ---------------------------------------

local polvo: ParticleEmitter
do
	local a = Instance.new("Attachment")
	a.Name = "PolvoPisadas"
	a.Parent = Workspace.Terrain
	local p = Instance.new("ParticleEmitter")
	p.Texture = "rbxasset://textures/particles/smoke_main.dds"
	p.Rate = 0
	p.EmissionDirection = Enum.NormalId.Top
	p.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(0.3, 0.55),
		NumberSequenceKeypoint.new(1, 0),
	})
	p.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1),
	})
	p.Lifetime = NumberRange.new(0.3, 0.5)
	p.Speed = NumberRange.new(2.5, 5)
	p.SpreadAngle = Vector2.new(70, 70)
	p.Drag = 5
	p.Acceleration = Vector3.new(0, -4, 0)
	p.Parent = a
	polvo = p
end

local function tipoPiso(parte: Instance, material: Enum.Material): string
	if parte:IsA("BasePart") then
		for clave, tipo in C.PisoPorVariante do
			if string.find(parte.MaterialVariant, clave, 1, true) then
				return tipo
			end
		end
		material = parte.Material
	end
	return (C.PisoPorMaterial :: any)[material.Name] or "Piedra"
end

local function soltarPolvo(lugar: Vector3, color: Color3, cantidad: number)
	if cantidad <= 0 or Efectos.reducidos() then
		return
	end
	local a = polvo.Parent :: Attachment
	a.WorldPosition = lugar + Vector3.new(0, 0.15, 0)
	polvo.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.3))
	polvo:Emit(cantidad)
end

-- fuerza: 1 pisada normal, más para el derrape o el aterrizaje
local function pisada(personaje: Model, pie: string, fuerza: number)
	local p = personaje:FindFirstChild(pie)
	if not p or not p:IsA("BasePart") then
		return
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { personaje }
	local r = Workspace:Raycast(p.Position + Vector3.new(0, 1, 0), Vector3.new(0, -4, 0), params)
	if not r then
		return
	end
	local datos = (C.Pisadas :: any)[tipoPiso(r.Instance, r.Material)]
	-- SONIDO: pisada al correr (tono según el piso)
	Sonidos.tocar(
		GameConfig.Sonidos.Pisada,
		datos.Tono * (0.92 + math.random() * 0.16),
		datos.Volumen * math.min(fuerza, 1.5),
		p
	)
	local color = if r.Instance:IsA("BasePart") then r.Instance.Color else Color3.new(0.8, 0.8, 0.8)
	soltarPolvo(r.Position, color, math.floor(C.PolvoPisada * fuerza + 0.5))
end

local function derrape(personaje: Model)
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if not raiz or not raiz:IsA("BasePart") then
		return
	end
	pisada(personaje, "RightFoot", C.PolvoDerrape / C.PolvoPisada)
	if GameConfig.Sonidos.Derrape ~= "" then
		-- SONIDO: derrape de la frenada (se corta solo, el sample es largo)
		local s = Instance.new("Sound")
		s.SoundId = GameConfig.Sonidos.Derrape
		s.Volume = 0.35
		s.PlaybackSpeed = 1.25
		s.Parent = raiz
		s:Play()
		task.delay(0.6, function()
			s:Destroy()
		end)
	end
end

-- Markers de las animaciones de cualquier personaje (las propias y las de otros jugadores).
-- AnimationPlayed salta cada vez que una pista vuelve a sonar: se conecta una sola vez.
local conectadas: { [AnimationTrack]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function vigilarAnimator(personaje: Model, animator: Animator)
	animator.AnimationPlayed:Connect(function(pista)
		local anim = pista.Animation
		if conectadas[pista] or not anim or not nuestras[anim.AnimationId] then
			return
		end
		conectadas[pista] = true
		pista:GetMarkerReachedSignal("Pisada_Izq"):Connect(function()
			pisada(personaje, "LeftFoot", 1)
		end)
		pista:GetMarkerReachedSignal("Pisada_Der"):Connect(function()
			pisada(personaje, "RightFoot", 1)
		end)
		pista:GetMarkerReachedSignal("Derrape"):Connect(function()
			derrape(personaje)
		end)
	end)
end

local function vigilarPersonaje(personaje: Model)
	local h = personaje:WaitForChild("Humanoid", 10)
	local animator = h and h:WaitForChild("Animator", 10)
	if animator and animator:IsA("Animator") then
		vigilarAnimator(personaje, animator)
	end
end

local function vigilarJugador(p: Player)
	if p.Character then
		task.spawn(vigilarPersonaje, p.Character)
	end
	p.CharacterAdded:Connect(vigilarPersonaje)
end
for _, p in Players:GetPlayers() do
	vigilarJugador(p)
end
Players.PlayerAdded:Connect(vigilarJugador)

-- El pico se balancea con retraso (superposición): se gira el agarre de la mano según cuánto
-- se movió la mano hace un instante. Para todos los que corren con el pico.
type Agarre = { base: CFrame, suave: number, angulo: number }
local agarres: { [Weld]: Agarre } = {}

local function moverPico(p: Player, dt: number)
	local personaje = p.Character
	local mano = personaje and personaje:FindFirstChild("RightHand")
	local torso = personaje and personaje:FindFirstChild("UpperTorso")
	local grip = mano and mano:FindFirstChild("RightGrip")
	if not grip or not grip:IsA("Weld") or not torso or not torso:IsA("BasePart") then
		return
	end
	local raiz = (personaje :: Model):FindFirstChild("HumanoidRootPart")
	local v = if raiz and raiz:IsA("BasePart") then raiz.AssemblyLinearVelocity else Vector3.zero
	local activo = p:GetAttribute("Corriendo") == true
		and (personaje :: Model):FindFirstChild("Pico") ~= nil
		and Vector3.new(v.X, 0, v.Z).Magnitude >= C.MinimaParaAnimar
	local e = agarres[grip]
	if not e then
		if not activo then
			return
		end
		e = { base = grip.C0, suave = 0, angulo = 0 }
		agarres[grip] = e
	end
	local rx = (torso.CFrame:ToObjectSpace((mano :: BasePart).CFrame)):ToEulerAnglesXYZ()
	e.suave += (rx - e.suave) * (1 - math.exp(-dt * 8))
	local objetivo = if activo then math.clamp((e.suave - rx) * 0.9, -0.45, 0.45) else 0
	e.angulo += (objetivo - e.angulo) * (1 - math.exp(-dt * 16))
	if not activo and math.abs(e.angulo) < 0.01 then
		grip.C0 = e.base
		agarres[grip] = nil
		return
	end
	grip.C0 = e.base * CFrame.Angles(e.angulo, 0, 0)
end

-- El personaje propio --------------------------------------------------------------------------

type Estado = {
	personaje: Model,
	humanoide: Humanoid,
	raiz: BasePart,
	pistas: { [string]: AnimationTrack },
	modo: string, -- "nada", "arranque", "correr", "frenada", "salto"
	bucle: AnimationTrack?, -- Correr o CorrerPico, el que esté sonando
	quietoHasta: number, -- última vez que estuvo casi quieto
	corriendoDesde: number?,
	corriendoHasta: number, -- última vez que corría (para no cortar el ciclo por un instante)
	volumenPasos: number?, -- volumen original del sonido de pasos de Roblox
}
local estado: Estado? = nil

local function pista(e: Estado, nombre: string): AnimationTrack?
	local t = e.pistas[nombre]
	if t then
		return t
	end
	local id = idDe(nombre)
	local animator = e.humanoide:FindFirstChildOfClass("Animator")
	if not id or not animator then
		return nil
	end
	local a = Instance.new("Animation")
	a.AnimationId = id
	local nueva = animator:LoadAnimation(a)
	nueva.Priority = Enum.AnimationPriority.Movement
	e.pistas[nombre] = nueva
	return nueva
end

local function conPico(e: Estado): boolean
	local h = e.personaje:FindFirstChild("Pico")
	return h ~= nil and h:IsA("Tool")
end

local function ajuste(e: Estado, rapidez: number): number
	local escala = if e.humanoide.HipHeight > 0.5 then e.humanoide.HipHeight / C.CaderaMedida else 1
	return math.clamp(rapidez / (C.VelocidadAnimacion * escala), C.AjusteMinimo, C.AjusteMaximo)
end

local function pararTodo(e: Estado, fade: number, menos: string?)
	for n, t in e.pistas do
		if n ~= menos and t.IsPlaying then
			t:Stop(fade)
		end
	end
	e.bucle = nil
end

local function tocarBucle(e: Estado, desde: number, fade: number)
	local nombre = if conPico(e) then "CorrerPico" else "Correr"
	local t = pista(e, nombre)
	if not t then
		return
	end
	pararTodo(e, fade, nombre)
	if not t.IsPlaying then
		t:Play(fade)
	end
	t.TimePosition = desde
	e.bucle = t
	e.modo = "correr"
end

-- el sonido de pasos de Roblox se calla mientras suenan las pisadas propias
local function pasosDeRoblox(e: Estado, callados: boolean)
	local s = e.raiz:FindFirstChild("Running")
	if not s or not s:IsA("Sound") then
		return
	end
	if callados and e.volumenPasos == nil then
		e.volumenPasos = s.Volume
		s.Volume = 0
	elseif not callados and e.volumenPasos ~= nil then
		s.Volume = e.volumenPasos :: number
		e.volumenPasos = nil
	end
end

local function saltar(e: Estado)
	local t = pista(e, "Salto")
	if not t then
		return
	end
	pararTodo(e, 0.1, "Salto")
	t:Play(0.06)
	e.modo = "salto"
end

local function alAterrizar(e: Estado)
	if e.modo ~= "salto" then
		return
	end
	local t = e.pistas.Salto
	if t then
		t:Stop(0.12)
	end
	e.modo = "nada"
	pisada(e.personaje, "LeftFoot", 1.5)
end

local function nuevoPersonaje(personaje: Model)
	local h = personaje:WaitForChild("Humanoid", 10)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 10)
	if not h or not h:IsA("Humanoid") or not raiz or not raiz:IsA("BasePart") then
		return
	end
	if h.RigType ~= Enum.HumanoidRigType.R15 then
		estado = nil -- las animaciones son para R15
		return
	end
	h:WaitForChild("Animator", 10)
	local e: Estado = {
		personaje = personaje,
		humanoide = h,
		raiz = raiz,
		pistas = {},
		modo = "nada",
		quietoHasta = os.clock(),
		corriendoHasta = 0,
	}
	estado = e
	for _, n in AnimacionesCorrer.Nombres do
		pista(e, n)
	end
	local salto = e.pistas.Salto
	if salto then
		-- se queda en la última pose hasta caer
		salto:GetMarkerReachedSignal("Fin"):Connect(function()
			if e.modo == "salto" then
				salto:AdjustSpeed(0)
			end
		end)
	end
	h.StateChanged:Connect(function(_, nuevo)
		if estado ~= e then
			return
		end
		if
			nuevo == Enum.HumanoidStateType.Jumping
			and (e.modo == "correr" or e.modo == "arranque")
		then
			saltar(e)
		elseif
			nuevo == Enum.HumanoidStateType.Landed or nuevo == Enum.HumanoidStateType.Running
		then
			alAterrizar(e)
		end
	end)
end

jugador.CharacterAdded:Connect(nuevoPersonaje)
if jugador.Character then
	task.spawn(nuevoPersonaje, jugador.Character)
end

local function actualizar(e: Estado)
	if not e.personaje.Parent or e.humanoide.Health <= 0 then
		return
	end
	local ahora = os.clock()
	local v = e.raiz.AssemblyLinearVelocity
	local rapidez = Vector3.new(v.X, 0, v.Z).Magnitude
	local enPiso = e.humanoide.FloorMaterial ~= Enum.Material.Air
	local st = e.humanoide:GetState()
	local parado = st == Enum.HumanoidStateType.Running
		or st == Enum.HumanoidStateType.RunningNoPhysics
		or st == Enum.HumanoidStateType.Landed
	if rapidez < 4 then
		e.quietoHasta = ahora
	end
	local corre = jugador:GetAttribute("Corriendo") == true
		and enPiso
		and parado
		and rapidez >= C.MinimaParaAnimar

	if e.modo == "salto" then
		e.personaje:SetAttribute("AnimCorrer", false)
		pasosDeRoblox(e, false)
		return
	end

	if corre then
		e.corriendoDesde = e.corriendoDesde or ahora
		e.corriendoHasta = ahora
		if e.modo == "nada" or e.modo == "frenada" then
			local arranque = pista(e, "Arranque")
			if arranque and ahora - e.quietoHasta < C.ArranqueSi then
				pararTodo(e, 0.08, "Arranque")
				arranque:Play(0.08)
				arranque.TimePosition = 0
				e.modo = "arranque"
			else
				-- un poquito después de la pisada del principio (ya suena la de aterrizar o caminar)
				tocarBucle(e, 0.03, 0.15)
			end
		elseif e.modo == "arranque" then
			local arranque = e.pistas.Arranque
			if
				not arranque
				or not arranque.IsPlaying
				or arranque.TimePosition >= arranque.Length - 0.02
			then
				-- el arranque termina en la pisada izquierda: la mitad del ciclo
				tocarBucle(e, AnimacionesCorrer.Ciclo / 2, 0.06)
			end
		elseif e.modo == "correr" then
			local b = e.bucle
			local quiere = if conPico(e) then "CorrerPico" else "Correr"
			if b and b ~= e.pistas[quiere] then
				tocarBucle(e, b.TimePosition, 0.15) -- sacó o guardó el pico
				b = e.bucle
			end
			if b then
				b:AdjustSpeed(ajuste(e, rapidez))
			end
		end
	elseif
		(e.modo == "correr" or e.modo == "arranque")
		and enPiso
		and st ~= Enum.HumanoidStateType.Climbing
		and e.humanoide.MoveDirection.Magnitude >= 0.1
		and ahora - e.corriendoHasta < 0.12
	then
		-- un instante sin correr (un escalón, el aterrizaje): sigue el ciclo para que no salte la pose
		if e.bucle then
			e.bucle:AdjustSpeed(ajuste(e, math.max(rapidez, C.MinimaParaAnimar)))
		end
	elseif e.modo == "correr" or e.modo == "arranque" then
		local venia = e.corriendoDesde and ahora - e.corriendoDesde or 0
		local frenada = pista(e, "Frenada")
		-- se para (soltó el movimiento) después de correr un rato: derrape
		local solto = e.humanoide.MoveDirection.Magnitude < 0.1
		if enPiso and solto and venia > C.FrenadaSi and frenada then
			pararTodo(e, 0.08, "Frenada")
			frenada:Play(0.06)
			e.modo = "frenada"
		elseif enPiso or st ~= Enum.HumanoidStateType.Jumping then
			pararTodo(e, 0.2)
			e.modo = "nada"
		end
	elseif e.modo == "frenada" then
		local f = e.pistas.Frenada
		if not f or not f.IsPlaying then
			e.modo = "nada"
		end
	end
	if not corre then
		e.corriendoDesde = nil
	end
	local propia = e.modo == "correr" or e.modo == "arranque"
	e.personaje:SetAttribute("AnimCorrer", propia)
	pasosDeRoblox(e, propia)
end

RunService.Heartbeat:Connect(function(dt)
	local e = estado
	if e then
		actualizar(e)
	end
	for _, p in Players:GetPlayers() do
		moverPico(p, dt)
	end
	for g in agarres do
		if not g:IsDescendantOf(Workspace) then
			agarres[g] = nil
		end
	end
end)
