--!strict
-- Creador de personaje: piel, cara, peinado, color de pelo, campera, acento y pantalón.
-- Solo pide: cada cambio va al servidor (remoto "Creador"), que lo valida, lo guarda y viste al
-- personaje (así se ve en vivo). Se abre solo la primera vez y desde la fila PERSONAJE del menú.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local remoto = ReplicatedStorage:WaitForChild("Creador") :: RemoteEvent
local jugador = Players.LocalPlayer
local playerGui = jugador:WaitForChild("PlayerGui")

local CR = Config.Cuerpo.Creador
local GRIS = Color3.fromHex("#9FA7B5")
local RAPIDO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

type Opcion = { campo: string, titulo: string, total: number, color: ((number) -> Color3)? }

local OPCIONES: { Opcion } = {
	{
		campo = "Piel",
		titulo = "PIEL",
		total = #Config.Cuerpo.TonosPiel,
		color = function(i)
			return Config.Cuerpo.TonosPiel[i]
		end,
	},
	{ campo = "Cara", titulo = "CARA", total = #Config.Cuerpo.Comic.Caras },
	{ campo = "Peinado", titulo = "PEINADO", total = #Config.Cuerpo.Comic.Peinados },
	{
		campo = "Pelo",
		titulo = "COLOR DE PELO",
		total = #Config.Cuerpo.ColoresPelo,
		color = function(i)
			return Color3.fromHex(Config.Cuerpo.ColoresPelo[i])
		end,
	},
	{
		campo = "Campera",
		titulo = "CAMPERA",
		total = #CR.Campera,
		color = function(i)
			return Color3.fromHex(CR.Campera[i])
		end,
	},
	{
		campo = "Acento",
		titulo = "ACENTO",
		total = #CR.Acento,
		color = function(i)
			return Color3.fromHex(CR.Acento[i])
		end,
	},
	{
		campo = "Pantalon",
		titulo = "PANTALÓN",
		total = #CR.Pantalon,
		color = function(i)
			return Color3.fromHex(CR.Pantalon[i])
		end,
	},
}

-- HUD que se esconde mientras se crea el personaje (el menú hace lo mismo).
local HUD = { "Estado", "Poderes", "Combate", "Ruleta", "PruebaTeclas", "BotonMenu", "Vineta" }

local gui = Tema.pantalla("Creador", 20)
gui.Enabled = false

local contenido = Instance.new("Frame")
contenido.Size = UDim2.fromScale(1, 1)
contenido.BackgroundTransparency = 1
contenido.Parent = gui
local escala = Instance.new("UIScale")
escala.Parent = contenido

local function ajustarEscala()
	local cam = workspace.CurrentCamera
	if cam then
		local v = cam.ViewportSize
		local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.52, 1.15) * 1.1
		escala.Scale = s
		contenido.Size = UDim2.fromScale(1 / s, 1 / s)
	end
end
ajustarEscala()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
end

-- Velo oscuro a la izquierda para que el panel se lea sobre la escena.
local velo = Instance.new("Frame")
velo.Size = UDim2.fromScale(0.55, 1)
velo.BackgroundColor3 = Tema.Fondo
velo.BorderSizePixel = 0
velo.Parent = contenido
local grad = Instance.new("UIGradient")
grad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.15),
	NumberSequenceKeypoint.new(0.7, 0.5),
	NumberSequenceKeypoint.new(1, 1),
})
grad.Parent = velo

local panel = Instance.new("CanvasGroup")
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 60, 0.5, 0)
panel.Size = UDim2.fromOffset(520, 640)
panel.BackgroundTransparency = 1
panel.Parent = contenido

local titulo =
	Tema.texto(panel, Tema.espaciar("TU PERSONAJE", 3), { tam = 32, letra = Tema.LetraGruesa })
titulo.Position = UDim2.fromOffset(0, 0)
local sub =
	Tema.texto(panel, "Así te ven en la arena. Lo podés cambiar después desde el menú.", {
		tam = 16,
		letra = Tema.LetraFina,
		color = GRIS,
	})
sub.Position = UDim2.fromOffset(0, 44)

local valores: { [string]: number } = {}
local actualizadores: { [string]: () -> () } = {}

local function valorActual(campo: string): number
	local v = jugador:GetAttribute("Ap_" .. campo)
	return if typeof(v) == "number" then v else (CR.Inicial :: any)[campo]
end

for i, op in OPCIONES do
	local y = 84 + (i - 1) * 66
	local fila = Instance.new("Frame")
	fila.Position = UDim2.fromOffset(0, y)
	fila.Size = UDim2.fromOffset(500, 58)
	fila.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	fila.BackgroundTransparency = 0.45
	fila.BorderSizePixel = 0
	fila.Parent = panel
	local borde = Instance.new("UIStroke")
	borde.Color = Tema.Hueso
	borde.Transparency = 0.85
	borde.Parent = fila

	local nombre = Tema.texto(fila, Tema.espaciar(op.titulo, 2), { tam = 19 })
	nombre.Position = UDim2.fromOffset(18, 17)

	local muestra = Instance.new("Frame")
	muestra.AnchorPoint = Vector2.new(0.5, 0.5)
	muestra.Position = UDim2.fromOffset(372, 29)
	muestra.Size = UDim2.fromOffset(30, 30)
	muestra.Rotation = 45
	muestra.BorderSizePixel = 0
	muestra.Visible = op.color ~= nil
	muestra.Parent = fila
	local bordeM = Instance.new("UIStroke")
	bordeM.Color = Tema.Hueso
	bordeM.Transparency = 0.5
	bordeM.Parent = muestra

	local numero = Tema.texto(fila, "", { tam = 20, alineado = Enum.TextXAlignment.Center })
	numero.AutomaticSize = Enum.AutomaticSize.None
	numero.AnchorPoint = Vector2.new(0.5, 0.5)
	numero.Position = UDim2.fromOffset(372, 29)
	numero.Size = UDim2.fromOffset(70, 30)
	numero.Visible = op.color == nil

	local function actualizar()
		local v = valores[op.campo]
		numero.Text = string.format("%d / %d", v, op.total)
		if op.color then
			muestra.BackgroundColor3 = op.color(v)
		end
	end
	actualizadores[op.campo] = actualizar

	local function flecha(x: number, texto: string, paso: number)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromOffset(x, 29)
		b.Size = UDim2.fromOffset(48, 48)
		b.BackgroundTransparency = 1
		b.Text = texto
		b.TextColor3 = Tema.Hueso
		b.FontFace = Tema.Letra
		b.TextSize = 34
		b.Parent = fila
		b.Activated:Connect(function()
			-- SONIDO: cambiar una opción del creador
			local v = (valores[op.campo] - 1 + paso) % op.total + 1
			valores[op.campo] = v
			actualizar()
			muestra.Size = UDim2.fromOffset(38, 38)
			TweenService:Create(muestra, RAPIDO, { Size = UDim2.fromOffset(30, 30) }):Play()
			remoto:FireServer(op.campo, v)
		end)
	end
	flecha(306, "‹", -1)
	flecha(440, "›", 1)
end

-- Botón de confirmar: sólido Hueso con texto oscuro (Sistema de diseño).
local confirmar = Instance.new("TextButton")
confirmar.Position = UDim2.fromOffset(0, 84 + #OPCIONES * 66 + 14)
confirmar.Size = UDim2.fromOffset(500, 64)
confirmar.BackgroundColor3 = Tema.Hueso
confirmar.BorderSizePixel = 0
confirmar.AutoButtonColor = false
confirmar.Text = Tema.espaciar("CONFIRMAR", 3)
confirmar.FontFace = Tema.LetraGruesa
confirmar.TextSize = 26
confirmar.TextColor3 = Tema.Fondo
confirmar.Parent = panel
confirmar.MouseEnter:Connect(function()
	TweenService:Create(confirmar, RAPIDO, { BackgroundTransparency = 0.12 }):Play()
end)
confirmar.MouseLeave:Connect(function()
	TweenService:Create(confirmar, RAPIDO, { BackgroundTransparency = 0 }):Play()
end)

local abierto = false
local confirmado = false -- ya confirmó en esta sesión (el servidor tarda un instante en avisar)
local velocidadGuardada = 16
local saltoGuardado = 50

local function camaraDeFrente()
	local cam = workspace.CurrentCamera
	local p = jugador.Character
	local raiz = p and p:FindFirstChild("HumanoidRootPart")
	if cam and raiz and raiz:IsA("BasePart") then
		cam.CameraType = Enum.CameraType.Scriptable
		local frente = raiz.CFrame
		-- De frente al personaje y corrida de costado: el personaje queda a la derecha del panel.
		local ojo = frente * CFrame.new(2.4, 1.0, -7.5)
		cam.CFrame = CFrame.lookAt(ojo.Position, (frente * CFrame.new(2.4, 0.4, 0)).Position)
		cam.FieldOfView = 50
	end
end

local function abrir()
	if abierto then
		return
	end
	abierto = true
	for _, op in OPCIONES do
		valores[op.campo] = valorActual(op.campo)
		actualizadores[op.campo]()
	end
	for _, nombre in HUD do
		local g = playerGui:FindFirstChild(nombre)
		if g and g:IsA("ScreenGui") then
			g.Enabled = false
		end
	end
	local hum = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		velocidadGuardada, saltoGuardado = hum.WalkSpeed, hum.JumpPower
		hum.WalkSpeed, hum.JumpPower = 0, 0
	end
	jugador:SetAttribute("EnCreador", true)
	gui.Enabled = true
	camaraDeFrente()
	panel.GroupTransparency = 1
	panel.Position = UDim2.new(0, 20, 0.5, 0)
	TweenService
		:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.new(0, 60, 0.5, 0),
		})
		:Play()
end

local function cerrar()
	abierto = false
	gui.Enabled = false
	jugador:SetAttribute("EnCreador", false)
	jugador:SetAttribute("AbrirCreador", false)
	for _, nombre in HUD do
		local g = playerGui:FindFirstChild(nombre)
		if g and g:IsA("ScreenGui") then
			g.Enabled = true
		end
	end
	local hum = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed, hum.JumpPower = velocidadGuardada, saltoGuardado
	end
	local cam = workspace.CurrentCamera
	if cam then
		if hum then
			cam.CameraSubject = hum
		end
		cam.CameraType = Enum.CameraType.Custom
		cam.FieldOfView = Config.Mundo.Camara.FOV
	end
end

confirmar.Activated:Connect(function()
	-- SONIDO: confirmar el personaje
	confirmado = true
	remoto:FireServer("Confirmar")
	cerrar()
end)

-- Se abre cuando el menú se cierra y: el personaje todavía no se creó, o se pidió desde el menú.
local function revisar()
	if
		abierto
		or jugador:GetAttribute("MenuAbierto") == true
		or not jugador:GetAttribute("DatosListos")
	then
		return
	end
	if
		(jugador:GetAttribute("AparienciaCreada") == false and not confirmado)
		or jugador:GetAttribute("AbrirCreador") == true
	then
		task.defer(abrir)
	end
end
for _, atributo in { "MenuAbierto", "DatosListos", "AparienciaCreada", "AbrirCreador" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(revisar)
end
jugador.CharacterAdded:Connect(function()
	if abierto then
		task.wait(0.5)
		camaraDeFrente()
	end
end)
revisar()

gui.Parent = playerGui
