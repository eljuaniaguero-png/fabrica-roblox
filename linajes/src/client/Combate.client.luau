--!strict
-- Teclas del combate, animaciones, cola de teclas, efectos inmediatos y barras de vida y energía.
-- Acá no se decide nada: el daño lo valida el servidor (server/Combate.server.luau).

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Combate") :: RemoteEvent

local C = Config.Combate
local K = Enum.KeyCode
local jugador = Players.LocalPlayer

local pistas: { [string]: AnimationTrack } = {}
local personaje: Model? = nil
local humanoid: Humanoid? = nil
local raiz: BasePart? = nil
local accion: AnimationTrack? = nil
local libreDesde, ultimoGolpe, paso, dashListo = 0, 0, 0, 0
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
	return personaje ~= nil and (personaje :: Model):GetAttribute("Aturdido") == true
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
	paso = if ahora - ultimoGolpe > C.ReinicioCombo + 0.3 then 1 else paso % #C.Golpes + 1
	local g = C.Golpes[paso]
	libreDesde = ahora + g.Espera
	ultimoGolpe = ahora
	remoto:FireServer("Golpe")
	tocar("Golpe" .. paso, C.VelocidadGolpes)
	return true
end

local function dash(): boolean
	local r, c = raiz, workspace.CurrentCamera
	local ahora = os.clock()
	if not (r and c) or ahora < dashListo or aturdido() then
		return false
	end
	dashListo = ahora + C.DashRecarga
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

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any, _c: any)
	if tipo == "Golpeado" then
		destello(a, Color3.new(1, 1, 1))
		numero(a, tostring(math.round(b)), Color3.fromRGB(255, 225, 120))
		if accion and accion.IsPlaying and a ~= personaje then
			frenar(accion, C.VelocidadGolpes, C.HitStop)
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

local vida = barra(16, Color3.fromRGB(210, 58, 74))
local energia = barra(36, Color3.fromRGB(44, 123, 229))
gui.Parent = jugador:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
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
