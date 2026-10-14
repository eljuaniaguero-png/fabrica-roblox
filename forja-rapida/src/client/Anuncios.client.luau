--!strict
-- Avisos del servidor (Grupo 1): cuando nace una geoda rarísima o alguien encuentra una gema
-- Mítica, le llega a todo el servidor. También los avisos cortos de Remotos.Aviso.
-- Y el botón de ajustes "Efectos: completos / reducidos" (abajo a la derecha).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Avisos = require(script.Parent.Avisos)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Anuncio = remotos:WaitForChild("Anuncio") :: RemoteEvent
local Aviso = remotos:WaitForChild("Aviso") :: RemoteEvent
local Ajustes = remotos:WaitForChild("Ajustes") :: RemoteEvent

Anuncio.OnClientEvent:Connect(function(texto: unknown, color: unknown)
	if typeof(texto) ~= "string" then
		return
	end
	local ok, c = pcall(Color3.fromHex, if typeof(color) == "string" then color else "#FFC93C")
	-- SONIDO: anuncio a todo el servidor
	Sonidos.tocar(GameConfig.Sonidos.Anuncio)
	Avisos.mostrar({
		Titulo = "¡ATENCIÓN!",
		Texto = texto,
		Color = if ok then c else nil,
		Duracion = 4,
	})
end)

Aviso.OnClientEvent:Connect(function(texto: unknown)
	if typeof(texto) == "string" then
		Avisos.mostrar({
			Titulo = "Aviso",
			Texto = texto,
			Color = Color3.fromHex("#3FA9FF"),
			Duracion = 3,
		})
	end
end)

-- Botón de efectos ---------------------------------------------------------------------------

local pantalla = Estilo.pantalla("Ajustes", 5)
pantalla.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local boton = Instance.new("TextButton")
boton.AnchorPoint = Vector2.new(1, 1)
boton.Position = UDim2.new(1, -16, 1, -16)
boton.Size = UDim2.fromOffset(190, 46)
boton.BackgroundColor3 = Color3.fromHex("#3FA9FF")
boton.Text = ""
boton.AutoButtonColor = true
Estilo.esquinas(boton, 14)
Estilo.borde(boton, 3)
boton.Parent = pantalla
local etiqueta = Estilo.texto("", 20)
etiqueta.AnchorPoint = Vector2.new(0.5, 0.5)
etiqueta.Position = UDim2.fromScale(0.5, 0.5)
etiqueta.Parent = boton

local function mostrar(reducidos: boolean)
	etiqueta.Text = if reducidos then "✨ Efectos: reducidos" else "✨ Efectos: completos"
	boton.BackgroundColor3 = Color3.fromHex(if reducidos then "#8D939C" else "#3FA9FF")
end
mostrar(Efectos.reducidos())
Efectos.alCambiar(mostrar)

boton.Activated:Connect(function()
	Ajustes:FireServer("EfectosReducidos", not Efectos.reducidos())
end)
