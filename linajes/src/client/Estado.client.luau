--!strict
-- Abajo a la izquierda: nivel en un rombo, Linaje, vida, energía y experiencia. También la viñeta.
-- Solo muestra: vida, energía y experiencia las maneja el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Estadisticas = require(Shared:WaitForChild("Estadisticas"))
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
	Tema.grupo(gui, Vector2.new(0, 1), UDim2.new(0, H.Margen, 1, -34), Vector2.new(640, 118))

local rombo = Tema.rombo(caja, Vector2.new(40, 46), 88, true)
local nivel = Tema.texto(
	rombo,
	"1",
	{ tam = 32, letra = Tema.LetraGruesa, alineado = Enum.TextXAlignment.Center }
)
nivel.AutomaticSize = Enum.AutomaticSize.None
nivel.Size = UDim2.fromScale(1, 1)
nivel.ZIndex = 5

local X = 102
local iconoLinaje = Instance.new("ImageLabel")
iconoLinaje.Position = UDim2.fromOffset(X, 0)
iconoLinaje.Size = UDim2.fromOffset(26, 26)
iconoLinaje.BackgroundTransparency = 1
iconoLinaje.ScaleType = Enum.ScaleType.Fit
iconoLinaje.Visible = false
iconoLinaje.Parent = caja

local linaje = Tema.texto(caja, "", { tam = 20, letra = Tema.LetraGruesa })
linaje.Position = UDim2.fromOffset(X, 1)

local iconoBando = Instance.new("ImageLabel")
iconoBando.Position = UDim2.fromOffset(X, 88)
iconoBando.Size = UDim2.fromOffset(16, 16)
iconoBando.BackgroundTransparency = 1
iconoBando.ScaleType = Enum.ScaleType.Fit
iconoBando.Visible = false
iconoBando.Parent = caja

local textoBando = Tema.texto(caja, "", {
	tam = 12,
	letra = Tema.LetraFina,
	color = Color3.fromHex("#9fa7b5"),
})
textoBando.Position = UDim2.fromOffset(X + 22, 88)

local numeros = Tema.texto(caja, "", { tam = 18, letra = Tema.LetraFina, transparencia = 0.2 })
numeros.AnchorPoint = Vector2.new(1, 0)
numeros.Position = UDim2.fromOffset(X + H.AnchoVida, 3)

local fondoVida, vida = Tema.barra(caja, Vector2.new(X, 32), H.AnchoVida, 12, Tema.Vida)
local danio = Instance.new("Frame")
danio.Size = UDim2.fromScale(1, 1)
danio.BackgroundColor3 = Tema.Danio
danio.BackgroundTransparency = 0.12
danio.BorderSizePixel = 0
danio.ZIndex = 2
danio.Parent = fondoVida

local fondoEnergia, energia = Tema.barra(caja, Vector2.new(X, 50), H.AnchoEnergia, 5, Tema.Hueso)
local rastroEnergia = Instance.new("Frame")
rastroEnergia.Size = UDim2.fromScale(1, 1)
rastroEnergia.BackgroundColor3 = Tema.Hueso
rastroEnergia.BackgroundTransparency = 0.45
rastroEnergia.BorderSizePixel = 0
rastroEnergia.ZIndex = 2
rastroEnergia.Parent = fondoEnergia
energia.ZIndex = 3

local _, xp = Tema.barra(caja, Vector2.new(X, 62), H.AnchoVida, 2, Tema.Xp)
local textoXp = Tema.texto(caja, "", { tam = 14, letra = Tema.LetraFina, transparencia = 0.35 })
textoXp.Position = UDim2.fromOffset(X, 68)

local estrellaRacha = Instance.new("ImageLabel")
estrellaRacha.Position = UDim2.fromOffset(X + H.AnchoVida + 14, 24)
estrellaRacha.Size = UDim2.fromOffset(22, 22)
estrellaRacha.BackgroundTransparency = 1
estrellaRacha.ScaleType = Enum.ScaleType.Fit
estrellaRacha.Image = H.Imagenes.Menu.Estrella
estrellaRacha.ImageColor3 = Color3.fromHex("#ffd34d")
estrellaRacha.Visible = false
estrellaRacha.Parent = caja

local txtRacha = Tema.texto(caja, "", {
	tam = 14,
	letra = Tema.LetraGruesa,
	color = Color3.fromHex("#ffd34d"),
})
txtRacha.Position = UDim2.fromOffset(X + H.AnchoVida + 40, 26)
txtRacha.Visible = false

local CreadorCfg = Config.Cuerpo.Creador

local function actualizarDatos()
	local racha = jugador:GetAttribute("Racha")
	local r = if typeof(racha) == "number" then racha else 0
	estrellaRacha.Visible = r >= 1
	txtRacha.Visible = r >= 1
	txtRacha.Text = string.format("RACHA ×%d", r)
	local l = jugador:GetAttribute("Linaje")
	local idLinaje = if typeof(l) == "string" then ((H.Imagenes.Linajes :: any)[l] or "") else ""
	iconoLinaje.Image = idLinaje
	iconoLinaje.ImageColor3 = Tema.color(l)
	iconoLinaje.Visible = idLinaje ~= ""
	linaje.Position = UDim2.fromOffset(if idLinaje ~= "" then X + 32 else X, 1)
	linaje.Text = if typeof(l) == "string"
		then Tema.espaciar(string.upper(nombres[l] or l), 3)
		else ""
	energia.BackgroundColor3 = Tema.color(l)

	local bandoAttr = jugador:GetAttribute("Bando")
	local claveBando = if typeof(bandoAttr) == "string" and bandoAttr ~= ""
		then bandoAttr
		elseif typeof(bandoAttr) == "number" then (CreadorCfg.Bandos[bandoAttr] or "Neutral")
		else "Neutral"
	local idBando = (H.Imagenes.Bandos :: any)[claveBando] or ""
	local nombreBando = (CreadorCfg.BandoNombres :: any)[claveBando] or claveBando
	local hexBando = (CreadorCfg.BandoColores :: any)[claveBando] or "9fa7b5"
	iconoBando.Image = idBando
	iconoBando.Visible = idBando ~= ""
	textoBando.Position = UDim2.fromOffset(if idBando ~= "" then X + 22 else X, 88)
	textoBando.Text = Tema.espaciar("BANDO  ·  " .. string.upper(nombreBando), 2)
	textoBando.TextColor3 = if claveBando == "Neutral"
		then Color3.fromHex("#9fa7b5")
		else Color3.fromHex(hexBando)

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

for _, atributo in { "Linaje", "Nivel", "Xp", "Racha", "Bando" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(actualizarDatos)
end
actualizarDatos()

-- La vida y la energía bajan de golpe; sus rastros claros las siguen tras H.DanioEspera.
local parteDanio, bajoEn, antes = 1, 0, 1
local parteRastroE, bajoEnergiaEn, antesE = 1, 0, 1
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
	nivel.TextColor3 = if parte < 0.3 then Tema.Vida else Tema.Hueso

	local e = personaje:GetAttribute("Energia")
	if typeof(e) == "number" then
		local fracE = math.clamp(e / Estadisticas.energiaMax(jugador.Character), 0, 1)
		if fracE < antesE - 0.01 then
			bajoEnergiaEn = os.clock()
		end
		antesE = fracE
		if fracE >= parteRastroE then
			parteRastroE = fracE
		elseif os.clock() - bajoEnergiaEn > H.DanioEspera * 0.7 then
			parteRastroE = math.max(fracE, parteRastroE - dt * 1.1)
		end
		energia.Size = UDim2.fromScale(fracE, 1)
		rastroEnergia.Size = UDim2.fromScale(parteRastroE, 1)
	end
end)

gui.Parent = jugador:WaitForChild("PlayerGui")
