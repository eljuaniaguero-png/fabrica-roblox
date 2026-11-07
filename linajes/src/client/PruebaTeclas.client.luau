--!strict
-- Teclas de prueba para ver las animaciones jugando. No hace daño ni toca datos: es solo visual
-- y se apaga con Config.PruebaTeclas.Activas = false. El combate real va en el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local P = Config.PruebaTeclas
if not P.Activas then
	return
end

local K = Enum.KeyCode
local jugador = Players.LocalPlayer
local pistas: { [string]: AnimationTrack } = {}
local humanoid: Humanoid? = nil
local raiz: BasePart? = nil
local accion: AnimationTrack? = nil
local embistiendo = false
local golpe, ultimoGolpe = 0, 0

local UNA_VEZ: { [Enum.KeyCode]: string } = {
	[K.G] = "Parry",
	[K.Z] = "PunoSismico",
	[K.X] = "GolpePiso",
	[K.One] = "Saludar",
	[K.Two] = "Celebrar",
	[K.Three] = "Recoger",
	[K.Four] = "Hablar",
	[K.Five] = "Banco",
	[K.Six] = "Aturdido",
	[K.Seven] = "Derrota",
	[K.Eight] = "Levantarse",
	[K.Nine] = "GolpeLiviano", -- recibe un golpe liviano
	[K.Zero] = "GolpeFuerte", -- recibe un golpe fuerte
}

local function cargar(personaje: Model)
	local h = personaje:WaitForChild("Humanoid") :: Humanoid
	local animator = h:WaitForChild("Animator") :: Animator
	humanoid = h
	raiz = personaje:WaitForChild("HumanoidRootPart") :: BasePart
	h.WalkSpeed = P.Caminar
	table.clear(pistas)
	for _, grupo in { Config.Animaciones.base, Config.Animaciones.linaje_fuerzabruta } do
		for nombre, id in grupo do
			if typeof(id) == "string" then
				local anim = Instance.new("Animation")
				anim.AnimationId = id
				pistas[nombre] = animator:LoadAnimation(anim)
			end
		end
	end
end

local function tocar(nombre: string): AnimationTrack?
	local pista = pistas[nombre]
	if not pista then
		return nil
	end
	if accion then
		accion:Stop(0.08)
	end
	accion = pista
	pista:Play(0.08)
	return pista
end

local function soltar()
	if accion then
		accion:Stop(0.15)
		accion = nil
	end
end

-- Toca una animación de inicio y sigue con su loop si la tecla sigue apretada.
local function iniciarYSeguir(inicio: string, loop: string, tecla: Enum.KeyCode)
	local pista = tocar(inicio)
	if pista then
		pista.Stopped:Once(function()
			if accion == pista and UserInputService:IsKeyDown(tecla) then
				tocar(loop)
			end
		end)
	end
end

local function dash()
	local r, c = raiz, workspace.CurrentCamera
	if not (r and c) then
		return
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
	local fin = os.clock() + P.DashTiempo
	while os.clock() < fin do
		r.AssemblyLinearVelocity = direccion * P.Dash
			+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
		RunService.Heartbeat:Wait()
	end
end

local function comboGolpes()
	-- Un golpe no se corta con el siguiente: hay que esperar a que casi termine.
	local previo = accion
	if previo and previo.IsPlaying and previo.TimePosition < previo.Length * P.EsperaCombo then
		return
	end
	local ahora = os.clock()
	golpe = if ahora - ultimoGolpe > P.PausaCombo then 1 else golpe % 4 + 1
	ultimoGolpe = ahora
	local pista = tocar("Golpe" .. golpe)
	if pista then
		pista:AdjustSpeed(P.VelocidadCombo)
	end
end

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado then
		return
	end
	local tecla = entrada.KeyCode
	local h = humanoid
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 then
		comboGolpes()
	elseif UNA_VEZ[tecla] then
		tocar(UNA_VEZ[tecla])
	elseif tecla == K.R then
		-- Ataque desde arriba: salta y baja de un martillazo.
		local r = raiz
		if r then
			r.AssemblyLinearVelocity += Vector3.new(0, P.SaltoAire, 0)
		end
		tocar("GolpeAire")
	elseif tecla == K.Q then
		task.spawn(dash)
	elseif tecla == K.F then
		iniciarYSeguir("BloqueoInicio", "Bloqueo", K.F)
	elseif tecla == K.V then
		iniciarYSeguir("CargarInicio", "CargarLoop", K.V)
	elseif tecla == K.C then
		embistiendo = true
		iniciarYSeguir("EmbestidaInicio", "EmbestidaCarrera", K.C)
	elseif tecla == K.LeftShift and h then
		h.WalkSpeed = P.Correr
	elseif tecla == K.LeftControl and h then
		h.WalkSpeed = P.CorrerRapido
	elseif tecla == K.Y then
		local personaje = jugador.Character
		if personaje then
			personaje:SetAttribute("Volando", personaje:GetAttribute("Volando") ~= true)
		end
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	local tecla = entrada.KeyCode
	local h = humanoid
	if tecla == K.F or tecla == K.V then
		soltar()
	elseif tecla == K.C then
		embistiendo = false
		tocar("EmbestidaFrenada")
	elseif (tecla == K.LeftShift or tecla == K.LeftControl) and h then
		h.WalkSpeed = P.Caminar
	end
end)

RunService.Heartbeat:Connect(function()
	local r = raiz
	if embistiendo and r then
		local v = r.CFrame.LookVector * P.Embestida
		r.AssemblyLinearVelocity = Vector3.new(v.X, r.AssemblyLinearVelocity.Y, v.Z)
	end
end)

-- Cartel chico con las teclas.
local gui = Instance.new("ScreenGui")
gui.Name = "PruebaTeclas"
gui.ResetOnSpawn = false
local texto = Instance.new("TextLabel")
texto.AnchorPoint = Vector2.new(0, 1)
texto.Position = UDim2.new(0, 12, 1, -12)
texto.AutomaticSize = Enum.AutomaticSize.XY
texto.BackgroundColor3 = Color3.new(0, 0, 0)
texto.BackgroundTransparency = 0.45
texto.TextColor3 = Color3.new(1, 1, 1)
texto.TextSize = 14
texto.Font = Enum.Font.GothamMedium
texto.TextXAlignment = Enum.TextXAlignment.Left
texto.Text = P.Cartel
texto.Parent = gui
gui.Parent = jugador:WaitForChild("PlayerGui")

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
