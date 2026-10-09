--!strict
-- Notificaciones del lado derecho: entran deslizándose, se apilan hasta 3 y se van solas.
-- Reemplazan al aviso único del HUD viejo.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local UI = require(script.Parent)
local Sonidos = require(script.Parent.Parent.Sonidos)

local Tema = UI.Tema
local C = Config.Interfaz

local capa = UI.Pantalla.crear("Notificaciones", 20)

-- Debajo de los botones redondos de arriba a la derecha.
local columna = UI.hueco(
	"Columna",
	UDim2.fromOffset(UI.AnchoNotificacion, 3 * (UI.AltoNotificacion + 20)),
	capa.Raiz
)
columna.AnchorPoint = Vector2.new(1, 0)
columna.Position = UDim2.new(1, -Tema.Margen, 0, Tema.Margen + Tema.Toque + 96)
local lista = UI.lista(columna, false, 10)
lista.HorizontalAlignment = Enum.HorizontalAlignment.Right

local activas: { Frame } = {}
local orden = 0

local ENTRAR = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SALIR = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local Notificaciones = {}

-- Si el que avisa no dice el tipo, se adivina por el texto.
local function adivinar(texto: string): string
	local t = texto:lower()
	-- "¡" ocupa dos bytes: se compara el principio entero.
	if texto:sub(1, #"¡") == "¡" then
		return "exito"
	elseif t:find("falta") or t:find("^no ") or t:find("todavía") then
		return "error"
	end
	return "info"
end

local function quitar(hueco: Frame)
	local i = table.find(activas, hueco)
	if not i then
		return
	end
	table.remove(activas, i)
	local tarjeta = hueco:FindFirstChildOfClass("Frame")
	if tarjeta then
		UI.animar(tarjeta, SALIR, { Position = UDim2.fromOffset(UI.AnchoNotificacion + 60, 0) })
	end
	task.delay(0.22, function()
		UI.animar(hueco, Tema.Rapida, { Size = UDim2.fromOffset(UI.AnchoNotificacion, 0) })
		task.wait(0.13)
		hueco:Destroy()
	end)
end

-- Muestra un aviso corto. `tipo`: "exito", "error", "info", "adn" o "premio".
function Notificaciones.mostrar(texto: string, tipo: string?)
	if texto == "" then
		return
	end
	local t = tipo or adivinar(texto)
	while #activas >= C.MaximoNotificaciones do
		quitar(activas[1])
	end
	orden += 1
	local hueco = UI.hueco(
		"Aviso" .. orden,
		UDim2.fromOffset(UI.AnchoNotificacion, UI.AltoNotificacion + Tema.Sombra),
		columna
	)
	hueco.LayoutOrder = orden
	local n = UI.notificacion(texto, t)
	n.Marco.Position = UDim2.fromOffset(UI.AnchoNotificacion + 60, 0)
	n.Marco.Parent = hueco
	UI.animar(n.Marco, ENTRAR, { Position = UDim2.fromOffset(0, 0) })
	Sonidos.notificacion(t)
	table.insert(activas, hueco)
	task.delay(C.DuracionNotificacion, quitar, hueco)
end

return Notificaciones
