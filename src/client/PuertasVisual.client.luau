--!strict
-- Pinta cada puerta de verde si ya te alcanza la velocidad, o de rojo si no, y escribe su número.
-- Es solo visual: quién pasa lo decide el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local jugador = Players.LocalPlayer

local COLOR_ABIERTA = Color3.fromRGB(80, 220, 120)
local COLOR_CERRADA = Color3.fromRGB(230, 70, 70)

type Puerta = { parte: BasePart, umbral: number, texto: TextLabel? }
local puertas: { Puerta } = {}

-- Los colores los define el estilo, en atributos de cada puerta (ColorAbierta, ColorCerrada).
local function colorDe(parte: BasePart, nombre: string, porDefecto: Color3): Color3
	local valor = parte:GetAttribute(nombre)
	return if typeof(valor) == "Color3" then valor else porDefecto
end

local function velocidadActual(): number
	local valor = jugador:GetAttribute("Velocidad")
	return if typeof(valor) == "number" then valor else 0
end

local function pintar(puerta: Puerta, velocidad: number)
	local abierta = velocidad >= puerta.umbral
	puerta.parte.Color = if abierta
		then colorDe(puerta.parte, "ColorAbierta", COLOR_ABIERTA)
		else colorDe(puerta.parte, "ColorCerrada", COLOR_CERRADA)
	puerta.parte.Transparency = if abierta then 0.7 else 0.3
	if puerta.texto then
		puerta.texto.Text = if abierta then "¡PASÁ!" else `Velocidad {puerta.umbral}`
	end
end

local function registrar(parte: Instance)
	local indice = parte:GetAttribute("PuertaIndice")
	if parte:IsA("BasePart") and typeof(indice) == "number" then
		local cartel = parte:FindFirstChild("Cartel")
		local texto = if cartel then cartel:FindFirstChildWhichIsA("TextLabel", true) else nil
		local puerta: Puerta =
			{ parte = parte, umbral = Config.UmbralesPuertas[indice], texto = texto }
		table.insert(puertas, puerta)
		pintar(puerta, velocidadActual())
	end
end

local function actualizar()
	local velocidad = velocidadActual()
	for _, puerta in puertas do
		pintar(puerta, velocidad)
	end
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(registrar)
jugador:GetAttributeChangedSignal("Velocidad"):Connect(actualizar)
