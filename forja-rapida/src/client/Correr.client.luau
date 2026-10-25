--!strict
-- Correr (pedido A1, 25/10/2026; reemplaza al dash). Compu: mantener Shift. Joystick: apretar el
-- stick izquierdo (L3), prende y apaga. Celular: botón de la zapatilla arriba del salto, prende y
-- apaga (se pone verde). El cliente solo avisa al servidor (Remotos.Correr); el servidor decide la
-- velocidad. No se corre en La Forja (atributo EnForja) ni con un menú abierto.
-- Mientras corre: la cámara se abre un poco (FOV) y salen cubitos de polvo del color del piso
-- (sin polvo con "Efectos reducidos"). Números en GameConfig.Correr.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)
local Ventanas = require(script.Parent.Ventanas)

local C = GameConfig.Correr
local jugador = Players.LocalPlayer
local Remoto = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Correr") :: RemoteEvent

local shift = false -- compu: mientras está apretado
local prendido = false -- joystick y celular: prende y apaga
local avisado = false -- lo último que se le mandó al servidor
local botonCelular: TextButton? = nil

local function quiere(): boolean
	return (shift or prendido)
		and jugador:GetAttribute("EnForja") ~= true
		and Ventanas.abierta() == nil
end

local function pintarBoton()
	if botonCelular then
		Estilo.colorBoton(botonCelular, if prendido then "Verde" else "Gris")
	end
end

local function actualizar()
	local q = quiere()
	if q ~= avisado then
		avisado = q
		Remoto:FireServer(q)
	end
end

-- Teclado y joystick ---------------------------------------------------------------------------

local SHIFT = { [Enum.KeyCode.LeftShift] = true, [Enum.KeyCode.RightShift] = true }

UserInputService.InputBegan:Connect(function(input, _procesado)
	if SHIFT[input.KeyCode] then
		shift = true
		actualizar()
	elseif input.KeyCode == Enum.KeyCode.ButtonL3 then
		prendido = not prendido
		pintarBoton()
		actualizar()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if SHIFT[input.KeyCode] then
		shift = false
		actualizar()
	end
end)

jugador:GetAttributeChangedSignal("EnForja"):Connect(actualizar)
Ventanas.alCambiar(function()
	actualizar()
end)

-- Botón de celular (arriba del botón de saltar de Roblox) ---------------------------------------

local function armarBotonCelular()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Correr"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 5
	gui.Parent = jugador:WaitForChild("PlayerGui")
	local b = Estilo.boton({ Icono = "Zapatilla", Color = "Gris", Ancho = 64, Alto = 64 })
	b.AnchorPoint = Vector2.new(0.5, 1)
	b.Position = UDim2.new(1, -60, 1, -150)
	b.Parent = gui
	botonCelular = b
	b.Activated:Connect(function()
		prendido = not prendido
		pintarBoton()
		actualizar()
	end)
	-- se acomoda arriba del salto (que Roblox arma después y cambia según la pantalla)
	local function acomodar()
		local touch = jugador.PlayerGui:FindFirstChild("TouchGui")
		local marco = touch and touch:FindFirstChild("TouchControlFrame")
		local salto = marco and marco:FindFirstChild("JumpButton") :: GuiObject?
		if salto and salto.AbsoluteSize.X > 0 then
			local tam = math.floor(salto.AbsoluteSize.X * 0.75)
			local centro = salto.AbsolutePosition + salto.AbsoluteSize / 2
			b.Size = UDim2.fromOffset(tam, tam)
			b.Position = UDim2.fromOffset(centro.X, salto.AbsolutePosition.Y - 10)
		end
	end
	task.spawn(function()
		for _ = 1, 20 do
			acomodar()
			task.wait(0.5)
		end
	end)
	local cam = Workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			task.wait(0.2)
			acomodar()
		end)
	end
end

if UserInputService.TouchEnabled then
	armarBotonCelular()
end

-- Efectos mientras corre ---------------------------------------------------------------------------

local corriendoAntes = false
local tweenFov: Tween? = nil
local polvo: ParticleEmitter? = nil

local function emisor(raiz: BasePart): ParticleEmitter
	local a = Instance.new("Attachment")
	a.Name = "PolvoCorrer"
	a.Position = Vector3.new(0, -2.8, 0.6)
	a.Parent = raiz
	local p = Instance.new("ParticleEmitter")
	p.Texture = "rbxasset://textures/particles/smoke_main.dds"
	p.Shape = Enum.ParticleEmitterShape.Box
	p.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 0),
	})
	p.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	p.Lifetime = NumberRange.new(0.3, 0.5)
	p.Speed = NumberRange.new(2, 4)
	p.SpreadAngle = Vector2.new(35, 35)
	p.Acceleration = Vector3.new(0, -12, 0)
	p.Rate = 0
	p.Parent = a
	return p
end

local function colorPiso(raiz: BasePart): Color3?
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { raiz.Parent :: Instance }
	local r = Workspace:Raycast(raiz.Position, Vector3.new(0, -6, 0), params)
	return if r then r.Instance.Color else nil
end

local proximoColor = 0
RunService.Heartbeat:Connect(function()
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	-- se mide con la velocidad real (MoveDirection queda en 0 cuando lo mueve un MoveTo)
	local v = if raiz then raiz.AssemblyLinearVelocity else Vector3.zero
	local corre = jugador:GetAttribute("Corriendo") == true
		and humanoide ~= nil
		and Vector3.new(v.X, 0, v.Z).Magnitude > 4
	-- cámara
	if corre ~= corriendoAntes then
		corriendoAntes = corre
		local cam = Workspace.CurrentCamera
		if cam then
			if tweenFov then
				tweenFov:Cancel()
			end
			local t = TweenService:Create(
				cam,
				TweenInfo.new(C.FovTiempo, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ FieldOfView = if corre then C.FovCorrer else C.FovCaminar }
			)
			tweenFov = t
			t:Play()
		end
		if corre and raiz then
			-- SONIDO: arranca a correr
			Sonidos.tocar(GameConfig.Sonidos.Correr, 1.3, 0.25, raiz)
		end
	end
	-- polvo en los pies
	if not raiz or not humanoide then
		return
	end
	local p = polvo
	if not p or p.Parent == nil or (p.Parent :: Instance).Parent ~= raiz then
		p = emisor(raiz)
		polvo = p
	end
	local enElPiso = humanoide.FloorMaterial ~= Enum.Material.Air
	local activo = corre and enElPiso and not Efectos.reducidos()
	p.Rate = if activo then C.PolvoPorSegundo else 0
	if activo and os.clock() > proximoColor then
		proximoColor = os.clock() + 0.5
		local color = colorPiso(raiz)
		if color then
			p.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.25))
		end
	end
end)
