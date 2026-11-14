--!strict
-- Abajo a la izquierda: nivel en un rombo, Linaje, vida, energía y experiencia. También la viñeta.
-- Solo muestra: vida, energía y experiencia las maneja el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Niveles = require(Shared:WaitForChild("Niveles"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local H = Config.Hud
local jugador = Players.LocalPlayer

local nombres: { [string]: string } = {}
for _, o in Config.Ruleta.Opciones do
	nombres[o.Linaje] = o.Nombre
end

-- Viñeta: oscurece los bordes y lleva la vista al centro.
if H.Imagenes.Vineta ~= "" then
	local fondo = Tema.pantalla("Vineta", -10)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1, 1)
	img.BackgroundTransparency = 1
	img.Image = H.Imagenes.Vineta
	img.ImageTransparency = 0.15
	img.Parent = fondo
	fondo.Parent = jugador:WaitForChild("PlayerGui")
end

local gui = Tema.pantalla("Estado", 1)
local caja =
	Tema.grupo(gui, Vector2.new(0, 1), UDim2.new(0, H.Margen, 1, -40), Vector2.new(560, 100))

local rombo = Tema.rombo(caja, Vector2.new(30, 36), 70, true)
local nivel = Tema.texto(rombo, "1", { tam = 24, alineado = Enum.TextXAlignment.Center })
nivel.AutomaticSize = Enum.AutomaticSize.None
nivel.Size = UDim2.fromScale(1, 1)
nivel.ZIndex = 5

local X = 78
local linaje = Tema.texto(caja, "", { tam = 15 })
linaje.Position = UDim2.fromOffset(X, 2)
local numeros = Tema.texto(caja, "", { tam = 14, letra = Tema.LetraFina, transparencia = 0.25 })
numeros.AnchorPoint = Vector2.new(1, 0)
numeros.Position = UDim2.fromOffset(X + H.AnchoVida, 2)

local fondoVida, vida = Tema.barra(caja, Vector2.new(X, 26), H.AnchoVida, 7, Tema.Vida)
local danio = Instance.new("Frame")
danio.Size = UDim2.fromScale(1, 1)
danio.BackgroundColor3 = Tema.Danio
danio.BackgroundTransparency = 0.15
danio.BorderSizePixel = 0
danio.ZIndex = 2
danio.Parent = fondoVida

local _, energia = Tema.barra(caja, Vector2.new(X, 40), H.AnchoEnergia, 3, Tema.Hueso)
local _, xp = Tema.barra(caja, Vector2.new(X, 52), H.AnchoVida, 1, Tema.Xp)
local textoXp = Tema.texto(caja, "", { tam = 12, letra = Tema.LetraFina, transparencia = 0.45 })
textoXp.Position = UDim2.fromOffset(X, 60)

local function actualizarDatos()
	local l = jugador:GetAttribute("Linaje")
	linaje.Text = if typeof(l) == "string"
		then Tema.espaciar(string.upper(nombres[l] or l), 3)
		else ""
	energia.BackgroundColor3 = Tema.color(l)

	local n = jugador:GetAttribute("Nivel")
	local x = jugador:GetAttribute("Xp")
	if typeof(n) ~= "number" or typeof(x) ~= "number" then
		return
	end
	nivel.Text = tostring(n)
	local maximo = n >= Config.Niveles.Maximo
	local falta = Niveles.xpPara(n)
	xp.Size = UDim2.fromScale(if maximo then 1 else math.clamp(x / falta, 0, 1), 1)
	textoXp.Text = Tema.espaciar(
		if maximo
			then string.format("NIVEL %d  ·  MÁXIMO", n)
			else string.format("NIVEL %d  ·  %d / %d", n, x, falta),
		2
	)
end

for _, atributo in { "Linaje", "Nivel", "Xp" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizarDatos)
end
actualizarDatos()

-- La vida baja de golpe; la marca clara de daño la sigue un instante después.
local parteDanio, bajoEn, antes = 1, 0, 1
RunService.RenderStepped:Connect(function(dt)
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not (personaje and h) then
		return
	end
	local parte = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
	if parte < antes then
		bajoEn = os.clock()
	end
	antes = parte
	if parte >= parteDanio then
		parteDanio = parte
	elseif os.clock() - bajoEn > H.DanioEspera then
		parteDanio = math.max(parte, parteDanio - dt * 0.9)
	end
	vida.Size = UDim2.fromScale(parte, 1)
	danio.Size = UDim2.fromScale(parteDanio, 1)
	numeros.Text = string.format("%d / %d", math.ceil(h.Health), h.MaxHealth)
	local e = personaje:GetAttribute("Energia")
	if typeof(e) == "number" then
		energia.Size = UDim2.fromScale(math.clamp(e / Config.Combate.Energia, 0, 1), 1)
	end
end)

gui.Parent = jugador:WaitForChild("PlayerGui")
