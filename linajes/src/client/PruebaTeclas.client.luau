--!strict
-- Correr (Shift / Ctrl) y la lista de controles escondida (H). Las teclas viejas para probar
-- animaciones (1 a 0, J, K, L, U, I, O, P, R, V, Y) se sacaron el 15 nov 2026: ya no hacen falta.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estadisticas = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Estadisticas"))
local Tema = require(script.Parent:WaitForChild("Tema"))

local P = Config.PruebaTeclas
if not P.Activas then
	return
end

local K = Enum.KeyCode
local jugador = Players.LocalPlayer
local humanoid: Humanoid? = nil

local function cargar(personaje: Model)
	local h = personaje:WaitForChild("Humanoid") :: Humanoid
	humanoid = h
	h.WalkSpeed = Estadisticas.velocidad(P.Caminar)
end

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado then
		return
	end
	local h = humanoid
	if entrada.KeyCode == K.LeftShift and h then
		h.WalkSpeed = Estadisticas.velocidad(P.Correr)
	elseif entrada.KeyCode == K.LeftControl and h then
		h.WalkSpeed = Estadisticas.velocidad(P.CorrerRapido)
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	local h = humanoid
	if (entrada.KeyCode == K.LeftShift or entrada.KeyCode == K.LeftControl) and h then
		h.WalkSpeed = Estadisticas.velocidad(P.Caminar)
	end
end)

-- Controles escondidos: abajo a la derecha solo dice "H  CONTROLES"; H muestra u oculta la lista.
local gui = Tema.pantalla("PruebaTeclas", 2)
local esquina = Tema.grupo(
	gui,
	Vector2.new(1, 1),
	UDim2.new(1, -Config.Hud.Margen, 1, -48),
	Vector2.new(700, 120)
)
local pista = Tema.texto(esquina, "H  CONTROLES", {
	tam = 15,
	letra = Tema.LetraFina,
	transparencia = 0.4,
	espaciado = 2,
})
pista.AnchorPoint = Vector2.new(1, 1)
pista.Position = UDim2.fromScale(1, 1)
local texto =
	Tema.texto(esquina, P.Cartel, { tam = 16, letra = Tema.LetraFina, transparencia = 0.08 })
texto.AnchorPoint = Vector2.new(1, 1)
texto.Position = UDim2.new(1, 0, 1, -28)
texto.AutomaticSize = Enum.AutomaticSize.XY
texto.TextXAlignment = Enum.TextXAlignment.Right
texto.LineHeight = 1.3
texto.Visible = false
UserInputService.InputBegan:Connect(function(entrada, usado)
	if not usado and entrada.KeyCode == Config.Hud.TeclaControles then
		texto.Visible = not texto.Visible
	end
end)
gui.Parent = jugador:WaitForChild("PlayerGui")

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
