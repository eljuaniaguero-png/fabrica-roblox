--!strict
-- Subir de nivel: una onda de luz y chispas alrededor del personaje (la ven todos),
-- y para vos además un cartel en pantalla y un sonido.
--
-- HUD > CartelNivel (CanvasGroup, con UIScale) > Titulo, Detalle (TextLabel)

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local cartel = hud:WaitForChild("CartelNivel") :: CanvasGroup
local titulo = cartel:WaitForChild("Titulo") :: TextLabel
local detalle = cartel:WaitForChild("Detalle") :: TextLabel
local escala = cartel:FindFirstChildOfClass("UIScale")
local remoto = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("SubioNivel") :: RemoteEvent

local ajustes = Config.SubirNivel
local CHISPA = "rbxasset://textures/particles/sparkles_main.dds"

-- Disco de neón que se abre desde los pies y se desvanece.
local function ondaDeLuz(raiz: BasePart)
	local onda = Instance.new("Part")
	onda.Name = "OndaNivel"
	onda.Shape = Enum.PartType.Cylinder
	onda.Material = Enum.Material.Neon
	onda.Color = Config.Paleta.Amarillo
	onda.Anchored = true
	onda.CanCollide = false
	onda.CanQuery = false
	onda.CanTouch = false
	onda.CastShadow = false
	onda.Transparency = 0.3
	onda.Size = Vector3.new(0.2, 2, 2)
	-- El eje del cilindro es X: se gira para que quede acostado en el piso.
	local pies = raiz.Position - Vector3.new(0, 2.9, 0)
	onda.CFrame = CFrame.new(pies) * CFrame.Angles(0, 0, math.rad(90))
	onda.Parent = workspace

	local diametro = ajustes.RadioAnillo * 2
	TweenService:Create(
		onda,
		TweenInfo.new(ajustes.DuracionAnillo, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.2, diametro, diametro), Transparency = 1 }
	):Play()
	Debris:AddItem(onda, ajustes.DuracionAnillo + 0.1)
end

local function chispas(raiz: BasePart)
	local punto = Instance.new("Attachment")
	punto.Name = "ChispasNivel"
	punto.Parent = raiz

	local emisor = Instance.new("ParticleEmitter")
	emisor.Texture = CHISPA
	emisor.Rate = 0
	emisor.LightEmission = 1
	emisor.Color = ColorSequence.new(Config.Paleta.Amarillo, Config.Paleta.Cian)
	emisor.Size = NumberSequence.new(0.8, 0)
	emisor.Lifetime = NumberRange.new(0.6, 1)
	emisor.Speed = NumberRange.new(10, 18)
	emisor.SpreadAngle = Vector2.new(180, 180)
	emisor.Drag = 3
	emisor.Acceleration = Vector3.new(0, 6, 0)
	emisor.Parent = punto
	emisor:Emit(ajustes.Particulas)
	Debris:AddItem(punto, 2)
end

local function mostrarCartel(nivel: number)
	local puertaQueAbre = nil
	for indice, minimo in Config.NivelPuertas do
		if minimo == nivel then
			puertaQueAbre = indice
		end
	end
	titulo.Text = `¡NIVEL {nivel}!`
	detalle.Text = if puertaQueAbre
		then `Se abrió la puerta {puertaQueAbre}`
		else `Próximo nivel: {Niveles.pasosDelNivel(nivel)} pasos`

	cartel.Visible = true
	cartel.GroupTransparency = 0
	if escala then
		escala.Scale = 0.6
		TweenService:Create(
			escala,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end
	local desvanecer = TweenService:Create(
		cartel,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In,
			0,
			false,
			ajustes.DuracionCartel
		),
		{ GroupTransparency = 1 }
	)
	desvanecer.Completed:Connect(function(estado)
		-- Ocultarlo del todo: un CanvasGroup transparente a veces deja un rastro dibujado.
		if estado == Enum.PlaybackState.Completed then
			cartel.Visible = false
		end
	end)
	desvanecer:Play()
end

remoto.OnClientEvent:Connect(function(quien: Player, nivel: number)
	local personaje = quien.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if raiz and raiz:IsA("BasePart") then
		ondaDeLuz(raiz)
		chispas(raiz)
	end
	if quien == jugador then
		-- SONIDO: subir de nivel (Config.Efectos.SubirNivel)
		Sonidos.efecto("SubirNivel")
		mostrarCartel(nivel)
		print(`[Cliente] Nivel {nivel}`)
	end
end)
