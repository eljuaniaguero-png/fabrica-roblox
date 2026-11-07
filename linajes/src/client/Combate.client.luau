--!strict
-- Teclas del combate, animaciones, cola de teclas, efectos inmediatos y barras de vida y energía.
-- Acá no se decide nada: el daño lo valida el servidor (server/Combate.server.luau).

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local EfectosGolpe = require(script.Parent:WaitForChild("EfectosGolpe"))
local remoto = ReplicatedStorage:WaitForChild("Combate") :: RemoteEvent

local C = Config.Combate
local K = Enum.KeyCode
local jugador = Players.LocalPlayer

local pistas: { [string]: AnimationTrack } = {}
local personaje: Model? = nil
local humanoid: Humanoid? = nil
local raiz: BasePart? = nil
local accion: AnimationTrack? = nil
local libreDesde, ultimoGolpe, paso, dashListo, dashEn = 0, 0, 0, 0, 0
local bloqueando = false
local cola: { pedido: string, cuando: number }? = nil

local function cargar(nuevo: Model)
	personaje = nuevo
	local h = nuevo:WaitForChild("Humanoid") :: Humanoid
	local animator = h:WaitForChild("Animator") :: Animator
	humanoid = h
	raiz = nuevo:WaitForChild("HumanoidRootPart") :: BasePart
	table.clear(pistas)
	for nombre, id in Config.Animaciones.base do
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		pistas[nombre] = animator:LoadAnimation(anim)
	end
	h.WalkSpeed = Config.PruebaTeclas.Caminar
	nuevo:GetAttributeChangedSignal("Frenado"):Connect(function()
		h.WalkSpeed = if nuevo:GetAttribute("Frenado") == true
			then 0
			else Config.PruebaTeclas.Caminar
	end)
	nuevo:GetAttributeChangedSignal("Aturdido"):Connect(function()
		local aturdido = nuevo:GetAttribute("Aturdido") == true
		h.WalkSpeed = if aturdido then 0 else Config.PruebaTeclas.Caminar
		if aturdido then
			bloqueando = false
			if accion then
				accion:Stop(0.05)
			end
			accion = pistas.Aturdido
			pistas.Aturdido:Play(0.05)
		elseif accion == pistas.Aturdido then
			pistas.Aturdido:Stop(0.15)
			accion = nil
		end
	end)
end

local function aturdido(): boolean
	local p = personaje
	return p ~= nil and (p:GetAttribute("Aturdido") == true or p:GetAttribute("Frenado") == true)
end

local function tocar(nombre: string, velocidad: number?): AnimationTrack?
	local h = humanoid
	local torso = pistas[nombre .. "Torso"]
	local pista = if h and torso and h.MoveDirection.Magnitude > 0.1 then torso else pistas[nombre]
	if not pista then
		return nil
	end
	if accion then
		accion:Stop(0.08)
	end
	accion = pista
	pista:Play(0.08)
	if velocidad then
		pista:AdjustSpeed(velocidad)
	end
	return pista
end

-- Efecto: destello sobre el que recibe. SONIDO: golpe, en Config cuando estén los sonidos.
local function destello(objetivo: Instance, color: Color3)
	local luz = Instance.new("Highlight")
	luz.Adornee = objetivo
	luz.FillColor = color
	luz.FillTransparency = 0.35
	luz.OutlineTransparency = 1
	luz.Parent = objetivo
	Debris:AddItem(luz, C.Destello)
end

local function numero(objetivo: Model, texto: string, color: Color3)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(90, 34)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 3, 0)
	gui.AlwaysOnTop = true
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = color
	t.TextStrokeTransparency = 0.3
	t.Text = texto
	t.Parent = gui
	gui.Parent = r
	Debris:AddItem(gui, 0.6)
end

-- Chispas y anillo en el punto del golpe.
local function colorDe(atacante: Model?): Color3
	local dueno = atacante and Players:GetPlayerFromCharacter(atacante)
	local linaje = dueno and dueno:GetAttribute("Linaje")
	return typeof(linaje) == "string" and (Config.Poderes.Colores :: any)[linaje] or C.ColorChispas
end

local function impacto(objetivo: Model, fuerte: boolean, color: Color3)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	EfectosGolpe.reproducir(r.Position, fuerte, color)
end

-- Arco: la mano deja una estela mientras pega.
local function arco(atacante: Model, numeroGolpe: number)
	local mano = atacante:FindFirstChild(if numeroGolpe % 2 == 0 then "LeftHand" else "RightHand")
	if not (mano and mano:IsA("BasePart")) then
		return
	end
	local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
	a0.Position = Vector3.new(0, 1, 0)
	a1.Position = Vector3.new(0, -1, 0)
	a0.Parent = mano
	a1.Parent = mano
	local estela = Instance.new("Trail")
	estela.Attachment0 = a0
	estela.Attachment1 = a1
	estela.Lifetime = 0.18
	estela.LightEmission = 1
	estela.FaceCamera = true
	estela.Color = ColorSequence.new(Color3.new(1, 1, 1), colorDe(atacante))
	estela.Transparency = NumberSequence.new(0.05, 1)
	estela.Parent = mano
	Debris:AddItem(estela, 0.75)
	Debris:AddItem(a0, 0.75)
	Debris:AddItem(a1, 0.75)
end

local function sacudir(fuerza: number)
	local h = humanoid
	if not h then
		return
	end
	local fin = os.clock() + 0.16
	task.spawn(function()
		while os.clock() < fin do
			local k = (fin - os.clock()) / 0.16 * fuerza
			h.CameraOffset =
				Vector3.new(math.random(-10, 10) / 10 * k, math.random(-10, 10) / 10 * k, 0)
			RunService.RenderStepped:Wait()
		end
		h.CameraOffset = Vector3.zero
	end)
end

-- Paso hacia el rival más cercano que esté adelante.
local function avanzar()
	local r = raiz
	if not r then
		return
	end
	local mejor: BasePart? = nil
	local distancia = C.Asistencia
	for _, otro in CollectionService:GetTagged("Combatiente") do
		if otro ~= personaje then
			local ro = otro:FindFirstChild("HumanoidRootPart")
			if ro and ro:IsA("BasePart") then
				local d = (ro.Position - r.Position).Magnitude
				if d < distancia then
					mejor, distancia = ro, d
				end
			end
		end
	end
	if not mejor then
		return
	end
	local objetivo = mejor :: BasePart
	local plano = Vector3.new(objetivo.Position.X, r.Position.Y, objetivo.Position.Z)
	r.CFrame = CFrame.lookAt(r.Position, plano)
	task.spawn(function()
		local fin = os.clock() + C.AvanceTiempo
		while os.clock() < fin and (objetivo.Position - r.Position).Magnitude > C.Cercania do
			r.AssemblyLinearVelocity = r.CFrame.LookVector * C.Avance
				+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			RunService.Heartbeat:Wait()
		end
	end)
end

-- Contador de golpes y daño acumulado.
local golpes, acumulado, contadorHasta = 0, 0, 0
local contador = Instance.new("TextLabel")
contador.AnchorPoint = Vector2.new(1, 0.5)
contador.Position = UDim2.new(1, -40, 0.42, 0)
contador.Size = UDim2.fromOffset(260, 80)
contador.BackgroundTransparency = 1
contador.Font = Enum.Font.GothamBlack
contador.TextScaled = true
contador.TextColor3 = Color3.new(1, 1, 1)
contador.TextStrokeTransparency = 0.2
contador.TextXAlignment = Enum.TextXAlignment.Right
contador.Visible = false

local function contar(danio: number)
	golpes += 1
	acumulado += danio
	contadorHasta = os.clock() + C.ContadorDura
	contador.Text = string.format(
		"%d " .. (if golpes == 1 then "GOLPE" else "GOLPES") .. "\n%d",
		golpes,
		math.round(acumulado)
	)
	contador.Visible = true
	contador.Rotation = math.random(-4, 4)
end

-- Hit-stop: el golpe propio se frena un instante al conectar.
local function frenar(pista: AnimationTrack, velocidad: number, tiempo: number)
	pista:AdjustSpeed(0)
	task.delay(tiempo, function()
		if pista.IsPlaying then
			pista:AdjustSpeed(velocidad)
		end
	end)
end

local function golpear(): boolean
	local ahora = os.clock()
	if ahora < libreDesde or bloqueando or aturdido() then
		return false
	end
	local vigente = ahora - ultimoGolpe <= C.ReinicioCombo
	local h = humanoid
	local variante: string? = nil
	if h and h.FloorMaterial == Enum.Material.Air then
		variante = "Aire"
	elseif ahora - dashEn <= C.VentanaDash then
		variante = "Dash"
	elseif vigente and paso == #C.Golpes - 1 and UserInputService:IsKeyDown(K.S) then
		variante = "Arriba"
	end
	local g: any
	if variante then
		g = (C.Variantes :: any)[variante]
		if variante ~= "Dash" then
			paso = 0
		end
	else
		paso = if vigente then paso % #C.Golpes + 1 else 1
		g = C.Golpes[paso]
	end
	libreDesde = ahora + g.Espera + g.Recarga
	ultimoGolpe = ahora
	remoto:FireServer("Golpe", variante)
	avanzar()
	arco(personaje :: Model, math.max(paso, 1))
	tocar(g.Anim or ("Golpe" .. paso), C.VelocidadGolpes)
	return true
end

local function dash(): boolean
	local r, c = raiz, workspace.CurrentCamera
	local ahora = os.clock()
	if not (r and c) or ahora < dashListo or aturdido() then
		return false
	end
	dashListo = ahora + C.DashRecarga
	dashEn = ahora
	remoto:FireServer("Dash")
	if bloqueando then
		bloqueando = false
		remoto:FireServer("BloqueoFin")
	end
	local adelante = Vector3.new(c.CFrame.LookVector.X, 0, c.CFrame.LookVector.Z).Unit
	local derecha = Vector3.new(c.CFrame.RightVector.X, 0, c.CFrame.RightVector.Z).Unit
	local nombre, direccion = "DashAdelante", adelante
	if UserInputService:IsKeyDown(K.S) then
		nombre, direccion = "DashAtras", -adelante
	elseif UserInputService:IsKeyDown(K.A) then
		nombre, direccion = "DashIzquierda", -derecha
	elseif UserInputService:IsKeyDown(K.D) then
		nombre, direccion = "DashDerecha", derecha
	end
	tocar(nombre)
	task.spawn(function()
		local fin = os.clock() + C.DashTiempo
		while os.clock() < fin do
			r.AssemblyLinearVelocity = direccion * (C.DashDistancia / C.DashTiempo)
				+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			RunService.Heartbeat:Wait()
		end
	end)
	return true
end

local function pedir(pedido: string)
	local hecho = if pedido == "Golpe" then golpear() else dash()
	if not hecho then
		cola = { pedido = pedido, cuando = os.clock() }
	end
end

local function bloquear()
	if aturdido() or bloqueando then
		return
	end
	bloqueando = true
	remoto:FireServer("BloqueoInicio")
	local pista = tocar("BloqueoInicio")
	if pista then
		pista.Stopped:Once(function()
			if bloqueando and accion == pista then
				tocar("Bloqueo")
			end
		end)
	end
end

local function soltarBloqueo()
	if bloqueando then
		bloqueando = false
		remoto:FireServer("BloqueoFin")
		if accion then
			accion:Stop(0.15)
			accion = nil
		end
	end
end

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado then
		return
	end
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 then
		pedir("Golpe")
	elseif entrada.KeyCode == K.Q then
		pedir("Dash")
	elseif entrada.KeyCode == K.F then
		bloquear()
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	if entrada.KeyCode == K.F then
		soltarBloqueo()
	end
end)

-- Cola de teclas: lo apretado un poco antes de tiempo sale apenas se puede.
RunService.Heartbeat:Connect(function()
	local c = cola
	if c then
		local vencida = os.clock() - c.cuando > C.ColaTeclas
		local salio = not vencida and (if c.pedido == "Golpe" then golpear() else dash())
		if vencida or salio then
			cola = nil
		end
	end
end)

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any, _c: any, d: any)
	if tipo == "Ataca" then
		if a ~= personaje then
			arco(a, b)
		end
	elseif tipo == "Golpeado" then
		local fuerte = _c == true
		destello(a, Color3.new(1, 1, 1))
		local color = colorDe(d)
		impacto(a, fuerte, color)
		numero(a, tostring(math.round(b)), if fuerte then color else Color3.fromRGB(255, 225, 120))
		if d == personaje then
			contar(b)
			sacudir(if fuerte then C.SacudidaFuerte else C.Sacudida)
			if accion and accion.IsPlaying then
				frenar(accion, C.VelocidadGolpes, C.HitStop)
			end
		elseif a == personaje then
			sacudir(C.SacudidaFuerte)
			if accion then
				accion:Stop(0.03)
			end
			accion = if fuerte then pistas.GolpeFuerte else pistas.GolpeLiviano
			accion:Play(0.03)
		end
		-- SONIDO: golpe conecta
	elseif tipo == "Bloqueado" then
		destello(a, Color3.fromRGB(120, 170, 255))
		numero(a, tostring(math.round(b)), Color3.fromRGB(150, 190, 255))
		-- SONIDO: bloqueo
	elseif tipo == "Parry" then
		destello(a, Color3.fromRGB(63, 224, 240))
		numero(a, "¡PARRY!", Color3.fromRGB(63, 224, 240))
		if a == personaje then
			tocar("Parry")
			local pista = accion
			if pista then
				frenar(pista, 1, C.HitStopParry)
			end
		end
		-- SONIDO: parry, propio y no metálico
	elseif tipo == "Aviso" then
		destello(a, Color3.fromRGB(255, 42, 42))
	elseif tipo == "Empuje" then
		local r = raiz
		if r then
			r.AssemblyLinearVelocity = a
		end
	end
end)

-- Barras: vida roja y energía cian, arriba a la izquierda.
local gui = Instance.new("ScreenGui")
gui.Name = "Barras"
gui.ResetOnSpawn = false

local function barra(y: number, color: Color3): Frame
	local fondo = Instance.new("Frame")
	fondo.Position = UDim2.fromOffset(16, y)
	fondo.Size = UDim2.fromOffset(240, 16)
	fondo.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
	fondo.BorderSizePixel = 0
	fondo.Parent = gui
	local lleno = Instance.new("Frame")
	lleno.Size = UDim2.fromScale(1, 1)
	lleno.BackgroundColor3 = color
	lleno.BorderSizePixel = 0
	lleno.Parent = fondo
	return lleno
end

contador.Parent = gui
local vida = barra(16, Color3.fromRGB(210, 58, 74))
local energia = barra(36, Color3.fromRGB(44, 123, 229))
gui.Parent = jugador:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
	if contador.Visible and os.clock() > contadorHasta then
		contador.Visible = false
		golpes, acumulado = 0, 0
	end
	local h, p = humanoid, personaje
	if h and p then
		vida.Size = UDim2.fromScale(math.clamp(h.Health / h.MaxHealth, 0, 1), 1)
		local e = p:GetAttribute("Energia")
		if typeof(e) == "number" then
			energia.Size = UDim2.fromScale(math.clamp(e / C.Energia, 0, 1), 1)
		end
	end
end)

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
