--!strict
-- Guía del jugador nuevo (primeros segundos): una flecha que salta sobre la máquina, un
-- camino de luz desde el personaje hasta la consola y un cartel corto arriba.
-- Se muestra si el servidor marcó al jugador con el atributo "Guia" (todavía no fusionó)
-- y se va la primera vez que abre la máquina.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local MiLab = require(script.Parent.MiLab)
local UI = require(script.Parent.UI)

local Tema = UI.Tema
local jugador = Players.LocalPlayer

if jugador:GetAttribute("Guia") == nil then
	jugador:GetAttributeChangedSignal("Guia"):Wait()
end
if not jugador:GetAttribute("Guia") then
	return
end

local consola = MiLab.obtener():WaitForChild("Maquina"):WaitForChild("Consola") :: BasePart
local prompt = consola:WaitForChild("Prompt") :: ProximityPrompt

local piezas: { Instance } = {}

-- Flecha que salta sobre la consola.
local ancla = Instance.new("Attachment")
ancla.Name = "GuiaFlecha"
ancla.Position = Vector3.new(0, Config.Guia.AlturaFlecha, 0)
ancla.Parent = consola
table.insert(piezas, ancla)

local cartelFlecha = Instance.new("BillboardGui")
cartelFlecha.Size = UDim2.fromScale(5, 5)
cartelFlecha.AlwaysOnTop = false -- así la tapa lo que está adelante, como un objeto más
cartelFlecha.LightInfluence = 0
cartelFlecha.Parent = ancla
local sombra = UI.Iconos.crear("flecha", 110, Paleta.Contorno)
sombra.Size = UDim2.fromScale(1.1, 1.1)
sombra.Rotation = 180
sombra.Position = UDim2.fromScale(0.5, 0.54)
sombra.Parent = cartelFlecha
local flecha = UI.Iconos.crear("flecha", 100, Paleta.Alerta)
flecha.Size = UDim2.fromScale(1, 1)
flecha.Rotation = 180
flecha.Parent = cartelFlecha
local salto = TweenService:Create(
	cartelFlecha,
	TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
	{ StudsOffset = Vector3.new(0, 2, 0) }
)
salto:Play()

-- Camino de luz del personaje a la consola.
local destino = Instance.new("Attachment")
destino.Name = "GuiaDestino"
destino.Parent = consola
table.insert(piezas, destino)
local camino = Instance.new("Beam")
camino.Name = "GuiaCamino"
camino.Attachment1 = destino
camino.Color = ColorSequence.new(Paleta.Acento)
camino.LightEmission = 1
camino.LightInfluence = 0
camino.Transparency = NumberSequence.new(0.2, 0.6)
camino.Width0 = 1.2
camino.Width1 = 1.2
camino.FaceCamera = true
camino.Segments = 2
camino.Parent = consola
table.insert(piezas, camino)

local function engancharPersonaje(personaje: Model)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 5)
	if not raiz then
		return
	end
	local origen = Instance.new("Attachment")
	origen.Name = "GuiaOrigen"
	origen.Position = Vector3.new(0, -2.5, 0) -- a la altura de los pies
	origen.Parent = raiz
	table.insert(piezas, origen)
	camino.Attachment0 = origen
end
if jugador.Character then
	task.spawn(engancharPersonaje, jugador.Character)
end
local conexionPersonaje = jugador.CharacterAdded:Connect(engancharPersonaje)

-- Cartel corto abajo al centro (el lugar de "la acción del momento" en la guía de estilo).
local capa = UI.Pantalla.crear("Guia", 2)
local cartel = UI.caja({ Nombre = "Cartel", Color = Paleta.Superficie, Borde = Paleta.Acento })
cartel.Marco.AnchorPoint = Vector2.new(0.5, 1)
cartel.Marco.Position = UDim2.new(0.5, 0, 1, -Tema.Margen - 40)
cartel.Marco.Size = UDim2.fromOffset(560, 76)
cartel.Marco.Parent = capa.Raiz
local texto = UI.texto({
	Texto = Config.Guia.Texto,
	Letra = Tema.Letra.Normal,
	Color = Paleta.Texto,
	Medida = UDim2.new(1, -24, 1, -8),
})
texto.AnchorPoint = Vector2.new(0.5, 0.5)
texto.Position = UDim2.fromScale(0.5, 0.5)
texto.Parent = cartel.Fondo
local escala = Instance.new("UIScale")
escala.Scale = 0.6
escala.Parent = cartel.Marco
UI.animar(escala, Tema.Rebote, { Scale = 1 })

local terminado = false
local function terminar()
	if terminado then
		return
	end
	terminado = true
	salto:Cancel()
	conexionPersonaje:Disconnect()
	for _, p in piezas do
		p:Destroy()
	end
	local t = UI.animar(escala, Tema.Cerrar, { Scale = 0 })
	t.Completed:Once(function()
		capa.Gui:Destroy()
	end)
end

prompt.Triggered:Connect(terminar)
jugador:GetAttributeChangedSignal("Guia"):Connect(function()
	if not jugador:GetAttribute("Guia") then
		terminar()
	end
end)
