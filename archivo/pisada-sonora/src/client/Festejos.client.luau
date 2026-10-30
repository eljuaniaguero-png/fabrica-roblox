--!strict
-- Festejos (solo visual y sonido, lo ves vos). Lo que se gana lo decide el servidor; acá se festeja:
--   * hito de combo (10, 25, 50, 100): cartel, arpegio, confeti y un golpe de cámara;
--   * canción completa: cartel grande, fanfarria, mucho confeti y destello en pantalla;
--   * baldosa dorada: sonido, chispas doradas y "+N monedas" que sube;
--   * cada paso: un "+1" que salta sobre tu cabeza (Config.Recompensas.NumerosFlotantes).
--
-- HUD > Festejo (CanvasGroup) > Titulo, Detalle (TextLabel), UIScale;  HUD > Destello (Frame)

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local cartel = hud:WaitForChild("Festejo") :: CanvasGroup
local titulo = cartel:WaitForChild("Titulo") :: TextLabel
local detalle = cartel:WaitForChild("Detalle") :: TextLabel
local escala = cartel:WaitForChild("UIScale") :: UIScale
local destello = hud:WaitForChild("Destello") :: Frame
local remotoCelebrar =
	ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Celebrar") :: RemoteEvent

local premios = Config.Recompensas
local paleta = Config.Paleta
local CHISPA = "rbxasset://textures/particles/sparkles_main.dds"
local COLORES_CONFETI = { paleta.Rosa, paleta.Cian, paleta.Amarillo, paleta.Violeta }

local function raiz(): BasePart?
	local personaje = jugador.Character
	local parte = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	return if parte and parte:IsA("BasePart") then parte else nil
end

local function tween(
	objeto: Instance,
	segundos: number,
	propiedades: { [string]: any },
	estilo: Enum.EasingStyle?
): Tween
	local t = TweenService:Create(
		objeto,
		TweenInfo.new(segundos, estilo or Enum.EasingStyle.Quad),
		propiedades
	)
	t:Play()
	return t
end

-- Cartel que aparece con un salto y se desvanece solo.
local cartelVersion = 0
local function mostrarCartel(textoTitulo: string, textoDetalle: string, color: Color3)
	cartelVersion += 1
	local version = cartelVersion
	titulo.Text = textoTitulo
	titulo.TextColor3 = color
	detalle.Text = textoDetalle
	cartel.GroupTransparency = 0
	cartel.Visible = true
	escala.Scale = 0.6
	tween(escala, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(premios.DuracionCartel, function()
		if version ~= cartelVersion then
			return
		end
		tween(cartel, 0.4, { GroupTransparency = 1 }).Completed:Wait()
		if version == cartelVersion then
			cartel.Visible = false
		end
	end)
end

-- Confeti de colores que sale del personaje (una ráfaga y listo).
local function confeti(cantidad: number, colores: { Color3 })
	local base = raiz()
	if not base then
		return
	end
	local ancla = Instance.new("Attachment")
	ancla.Position = Vector3.new(0, 2, 0)
	ancla.Parent = base
	for _, color in colores do
		local emisor = Instance.new("ParticleEmitter")
		emisor.Texture = CHISPA
		emisor.Color = ColorSequence.new(color)
		emisor.LightEmission = 1
		emisor.Size = NumberSequence.new(0.7, 0.2)
		emisor.Lifetime = NumberRange.new(0.8, 1.4)
		emisor.Speed = NumberRange.new(18, 30)
		emisor.SpreadAngle = Vector2.new(60, 60)
		emisor.Acceleration = Vector3.new(0, -35, 0)
		emisor.Drag = 1.5
		emisor.Rotation = NumberRange.new(0, 360)
		emisor.RotSpeed = NumberRange.new(-300, 300)
		emisor.EmissionDirection = Enum.NormalId.Top
		emisor.Rate = 0
		emisor.Parent = ancla
		emisor:Emit(math.ceil(cantidad / #colores))
	end
	Debris:AddItem(ancla, 2)
end

-- La cámara se abre un instante (Sensacion.client.luau la vuelve a su lugar sola).
local function golpeCamara(grados: number)
	local camara = workspace.CurrentCamera
	if camara then
		camara.FieldOfView += grados
	end
end

local function destellar(transparencia: number)
	destello.BackgroundTransparency = transparencia
	destello.Visible = true
	tween(destello, 0.5, { BackgroundTransparency = 1 })
end

-- Texto que sale de la cabeza, sube y se desvanece.
local function flotante(texto: string, color: Color3, tamano: number)
	local personaje = jugador.Character
	local cabeza = if personaje then personaje:FindFirstChild("Head") else nil
	if not cabeza or not cabeza:IsA("BasePart") then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(160, tamano)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Adornee = cabeza
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Text = texto
	etiqueta.TextScaled = true
	etiqueta.TextColor3 = color
	etiqueta.TextStrokeTransparency = 0.3
	etiqueta.TextStrokeColor3 = paleta.Fondo
	etiqueta.FontFace = titulo.FontFace
	etiqueta.Parent = gui
	gui.Parent = jugador:WaitForChild("PlayerGui")
	tween(
		gui,
		0.8,
		{ StudsOffset = gui.StudsOffset + Vector3.new(0, 2.5, 0) },
		Enum.EasingStyle.Quart
	)
	tween(
		etiqueta,
		0.8,
		{ TextTransparency = 1, TextStrokeTransparency = 1 },
		Enum.EasingStyle.Quint
	)
	Debris:AddItem(gui, 0.9)
end

remotoCelebrar.OnClientEvent:Connect(function(tipo: string, a: any, b: any)
	if tipo == "hito" then
		-- SONIDO: hito de combo (Config.Efectos.Hito)
		Sonidos.efecto("Hito")
		mostrarCartel(`¡COMBO x{a}!`, `+{b} monedas`, paleta.Amarillo)
		confeti(premios.ConfetiHito, COLORES_CONFETI)
		golpeCamara(6)
	elseif tipo == "cancion" then
		-- SONIDO: canción completa (Config.Efectos.Fanfarria)
		Sonidos.efecto("Fanfarria")
		mostrarCartel("¡CANCIÓN COMPLETA!", `{a} · +{b} monedas`, paleta.Cian)
		confeti(premios.ConfetiCancion, COLORES_CONFETI)
		destellar(0.4)
		golpeCamara(10)
	elseif tipo == "dorada" then
		-- SONIDO: baldosa dorada (Config.Efectos.Dorada)
		Sonidos.efecto("Dorada")
		confeti(30, { Config.Baldosas.ColorDorada, Color3.new(1, 1, 1) })
		flotante(`+{a} monedas`, Config.Baldosas.ColorDorada, 40)
	end
end)

-- "+N" por cada paso que suma (los pasos los decide el servidor).
local pasosAntes: number? = nil
jugador:GetAttributeChangedSignal("PasosTotales"):Connect(function()
	local valor = jugador:GetAttribute("PasosTotales")
	if typeof(valor) ~= "number" then
		return
	end
	local diferencia = if pasosAntes then valor - pasosAntes else 0
	pasosAntes = valor
	if premios.NumerosFlotantes and diferencia > 0 and diferencia < 50 then
		flotante(`+{diferencia}`, paleta.Rosa, 28)
	end
end)
