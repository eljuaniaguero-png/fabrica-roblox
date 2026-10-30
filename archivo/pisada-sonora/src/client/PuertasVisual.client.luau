--!strict
-- Pinta cada puerta según tu nivel (color "abierta" si ya pasás, "cerrada" si no) y escribe el nivel
-- que pide. Es solo visual: quién pasa lo decide el servidor.
--
-- En el mapa: puerta = BasePart con atributo PuertaIndice, y adentro:
--   SurfaceGui "Cartel" > TextLabel          (texto sobre el campo de fuerza)
--   BillboardGui "CartelNivel" > Nivel, Detalle (TextLabel)  (cartel encima de la puerta)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)

local jugador = Players.LocalPlayer

-- Con streaming, las puertas llegan y se van mientras jugás: se guardan por parte.
local puertas: { [BasePart]: number } = {} -- parte -> índice de la puerta

-- Los colores los define el estilo, en atributos de cada puerta (ColorAbierta, ColorCerrada).
local function colorDe(parte: BasePart, nombre: string, porDefecto: Color3): Color3
	local valor = parte:GetAttribute(nombre)
	return if typeof(valor) == "Color3" then valor else porDefecto
end

local function pasosTotales(): number
	local valor = jugador:GetAttribute("PasosTotales")
	return if typeof(valor) == "number" then valor else 0
end

local function texto(parte: BasePart, cartel: string, nombre: string?): TextLabel?
	local gui = parte:FindFirstChild(cartel)
	local etiqueta = if gui
		then (if nombre
			then gui:FindFirstChild(nombre, true)
			else gui:FindFirstChildWhichIsA("TextLabel", true))
		else nil
	return if etiqueta and etiqueta:IsA("TextLabel") then etiqueta else nil
end

local function pintar(parte: BasePart, indice: number, minimo: number)
	local pasos = pasosTotales()
	local abierta = Niveles.nivelDe(pasos) >= minimo
	local color = if abierta
		then colorDe(parte, "ColorAbierta", Config.Paleta.Cian)
		else colorDe(parte, "ColorCerrada", Config.Paleta.Rosa)
	parte.Color = color
	parte.Transparency = if abierta then 0.7 else 0.3

	local enPuerta = texto(parte, "Cartel")
	if enPuerta then
		enPuerta.Text = if abierta then "¡PASÁ!" else `NIVEL {minimo}`
	end
	-- Encima del candado: qué zona abre esta puerta (el nivel lo muestra el candado).
	local nivel = texto(parte, "CartelNivel", "Nivel")
	if nivel then
		local zona = Config.Zonas[indice + 1]
		nivel.Text = if zona then string.upper(zona.Nombre) else `NIVEL {minimo}`
		nivel.TextColor3 = color
	end
	local detalle = texto(parte, "CartelNivel", "Detalle")
	if detalle then
		local faltan = math.max(Niveles.pasosParaLlegar(minimo) - pasos, 0)
		detalle.Text = if abierta then "ABIERTA" else `Te faltan {math.ceil(faltan)} pasos`
	end
end

local function actualizar()
	for parte, indice in puertas do
		pintar(parte, indice, Config.NivelPuertas[indice])
	end
end

local function registrar(objeto: Instance)
	-- Los carteles pueden llegar después que la puerta: se repinta cuando aparece cualquier hijo.
	local parte = if objeto:IsA("BasePart")
		then objeto
		else objeto:FindFirstAncestorWhichIsA("BasePart")
	if not parte then
		return
	end
	local indice = parte:GetAttribute("PuertaIndice")
	local minimo = if typeof(indice) == "number" then Config.NivelPuertas[indice] else nil
	if typeof(indice) == "number" and minimo then
		puertas[parte] = indice
		pintar(parte, indice, minimo)
	end
end

for _, objeto in workspace:GetDescendants() do
	registrar(objeto)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		puertas[objeto] = nil
	end
end)
jugador:GetAttributeChangedSignal("PasosTotales"):Connect(actualizar)
