--!strict
-- Dash minero (idea elegida del 19/10/2026): Shift o Q en compu, botón con viento en celular.
-- Te lanza GameConfig.Dash.Distancia studs hacia adelante con una estela de polvo y tiene una
-- espera de GameConfig.Dash.Espera segundos. Antes de moverse avisa al servidor (Remotos.Dash),
-- que revisa la espera. Marca el atributo "UltimoDash" para que el primer golpe después suene
-- más fuerte (Golpes.client.luau): solo se siente, no cambia el daño.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Sonidos = require(script.Parent.Sonidos)

local D = GameConfig.Dash
local jugador = Players.LocalPlayer
local Remoto = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Dash") :: RemoteEvent

local ultimo = -math.huge

local function estela(raiz: BasePart)
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, -2.5, 0.5)
	a0.Parent = raiz
	local polvo = Instance.new("ParticleEmitter")
	polvo.Color = ColorSequence.new(Color3.fromHex("#D9C9A3"))
	polvo.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(1, 2.5),
	})
	polvo.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	polvo.Lifetime = NumberRange.new(0.4, 0.6)
	polvo.Speed = NumberRange.new(2, 5)
	polvo.SpreadAngle = Vector2.new(40, 40)
	polvo.Rate = 0
	polvo.Parent = a0
	polvo:Emit(25)
	task.delay(1, function()
		a0:Destroy()
	end)
end

local function hacerDash(_: string, estado: Enum.UserInputState): Enum.ContextActionResult
	if estado ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local ahora = os.clock()
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if
		ahora - ultimo < D.Espera
		or not raiz
		or not humanoide
		or humanoide.Health <= 0
		or jugador:GetAttribute("EnForja") == true
	then
		return Enum.ContextActionResult.Sink
	end
	ultimo = ahora
	Remoto:FireServer()
	-- hacia donde camina; si está quieto, hacia donde mira
	local dir = humanoide.MoveDirection
	if dir.Magnitude < 0.1 then
		dir = raiz.CFrame.LookVector
	end
	dir = Vector3.new(dir.X, 0, dir.Z).Unit
	local a = Instance.new("Attachment")
	a.Parent = raiz
	local empuje = Instance.new("LinearVelocity")
	empuje.Attachment0 = a
	empuje.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	empuje.PrimaryTangentAxis = Vector3.xAxis
	empuje.SecondaryTangentAxis = Vector3.zAxis
	empuje.PlaneVelocity = Vector2.new(dir.X, dir.Z) * (D.Distancia / D.Duracion)
	empuje.MaxForce = math.huge
	empuje.RelativeTo = Enum.ActuatorRelativeTo.World
	empuje.Parent = raiz
	estela(raiz)
	-- SONIDO: el envión del dash
	Sonidos.tocar(GameConfig.Sonidos.Dash, 1, 0.7, raiz)
	jugador:SetAttribute("UltimoDash", ahora)
	task.delay(D.Duracion, function()
		a:Destroy()
		empuje:Destroy()
		-- frena en seco para que no se deslice de más
		local v = raiz.AssemblyLinearVelocity
		raiz.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
	end)
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction(
	"Dash",
	hacerDash,
	true,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.Q,
	Enum.KeyCode.ButtonB
)
ContextActionService:SetTitle("Dash", "Dash")
ContextActionService:SetImage("Dash", "rbxasset://textures/ui/Controls/DesignSystem/ButtonB@2x.png")
ContextActionService:SetPosition("Dash", UDim2.new(1, -170, 1, -150))
