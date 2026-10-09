--!strict
-- Las capas de la interfaz (un ScreenGui por capa) y su escala.
-- Cada capa tiene una Raiz con un UIScale: adentro todo se mide en puntos de diseño
-- (ver Tema.luau), y la Raiz mide lo que mide la pantalla dividido por la escala.
-- Las capas respetan la zona segura (ScreenInsets = CoreUISafeInsets): no tapan los botones
-- de Roblox ni la muesca del celular.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Tema = require(script.Parent.Tema)

export type Capa = {
	Gui: ScreenGui,
	Raiz: Frame,
	Escala: UIScale,
}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local capas: { Capa } = {}
local simulada: Vector2? = nil -- tamaño de pantalla simulado (para probar el celular en Studio)
local celularForzado: boolean? = nil
local marcoSimulado: Frame? = nil
local avisoPendiente = false
local cambio = Instance.new("BindableEvent")

local Pantalla = {}

-- Se dispara cuando cambia el tamaño de la pantalla o el modo celular.
Pantalla.Cambio = cambio.Event

local function avisar()
	if avisoPendiente then
		return
	end
	avisoPendiente = true
	task.defer(function()
		avisoPendiente = false
		cambio:Fire()
	end)
end

local function tamanoReal(c: Capa): Vector2
	return simulada or c.Gui.AbsoluteSize
end

function Pantalla.escalaPara(real: Vector2): number
	local s = math.min(real.Y / Tema.AltoReferencia, real.X / Tema.AnchoReferencia)
	return math.clamp(s, Tema.EscalaMinima, Tema.EscalaMaxima)
end

local function acomodar(c: Capa)
	local real = tamanoReal(c)
	if real.X < 1 or real.Y < 1 then
		return
	end
	local s = Pantalla.escalaPara(real)
	c.Escala.Scale = s
	c.Raiz.Size = UDim2.fromOffset(real.X / s, real.Y / s)
end

-- Crea una capa. `orden` decide qué capa queda arriba (DisplayOrder).
function Pantalla.crear(nombre: string, orden: number): Capa
	local gui = Instance.new("ScreenGui")
	gui.Name = nombre
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = orden

	local raiz = Instance.new("Frame")
	raiz.Name = "Raiz"
	raiz.BackgroundTransparency = 1
	raiz.AnchorPoint = Vector2.new(0.5, 0.5)
	raiz.Position = UDim2.fromScale(0.5, 0.5)
	local escala = Instance.new("UIScale")
	escala.Parent = raiz
	raiz.Parent = gui

	local c: Capa = { Gui = gui, Raiz = raiz, Escala = escala }
	table.insert(capas, c)
	gui.Parent = playerGui
	acomodar(c)
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		acomodar(c)
		avisar()
	end)
	return c
end

-- Tamaño de la pantalla en puntos de diseño.
function Pantalla.lienzo(): Vector2
	local c = capas[1]
	if not c then
		return Vector2.new(Tema.AnchoReferencia, Tema.AltoReferencia)
	end
	local real = tamanoReal(c)
	return real / Pantalla.escalaPara(real)
end

-- Escala actual (píxeles reales por punto de diseño).
function Pantalla.escala(): number
	local c = capas[1]
	return if c then c.Escala.Scale else 1
end

-- true en celular: se usa para la cantidad de columnas y el acomodo de los menús.
function Pantalla.esCelular(): boolean
	if celularForzado ~= nil then
		return celularForzado
	end
	local c = capas[1]
	local real = if c then tamanoReal(c) else Vector2.new(1920, 1080)
	return real.Y < 500 or (UserInputService.TouchEnabled and not UserInputService.MouseEnabled)
end

-- Pasa una posición de la pantalla (píxeles reales) a puntos de diseño dentro de `marco`.
function Pantalla.dentroDe(marco: GuiObject, absoluta: Vector2): Vector2
	local factor = if marco.Size.X.Offset > 0
		then marco.AbsoluteSize.X / marco.Size.X.Offset
		else Pantalla.escala()
	return (absoluta - marco.AbsolutePosition) / factor
end

-- Para probar en Studio: simula una pantalla de `tamano` píxeles (por ejemplo un celular
-- apaisado de 844 × 390) en el medio de la pantalla real. Sin argumentos vuelve a la normal.
function Pantalla.simular(tamano: Vector2?, celular: boolean?)
	simulada = tamano
	celularForzado = celular
	if marcoSimulado then
		marcoSimulado:Destroy()
		marcoSimulado = nil
	end
	if tamano then
		local gui = Instance.new("ScreenGui")
		gui.Name = "MarcoSimulado"
		gui.ResetOnSpawn = false
		gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		gui.DisplayOrder = 1000
		local marco = Instance.new("Frame")
		marco.AnchorPoint = Vector2.new(0.5, 0.5)
		marco.Position = UDim2.fromScale(0.5, 0.5)
		marco.Size = UDim2.fromOffset(tamano.X, tamano.Y)
		marco.BackgroundTransparency = 1
		local borde = Instance.new("UIStroke")
		borde.Thickness = 2
		borde.Color = Paleta.Alerta
		borde.Parent = marco
		marco.Parent = gui
		gui.Parent = playerGui
		marcoSimulado = marco
	end
	for _, c in capas do
		acomodar(c)
	end
	avisar()
end

return Pantalla
