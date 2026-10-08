--!strict
-- Cartel grande y lluvia de papelitos al completar una generación de la Mutadex.
-- Revelacion (ScreenGui) > Celebracion (Frame) > Escala (UIScale), Titulo, Premio, Subtitulo
--                        > Confeti (Frame transparente de pantalla completa)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Sonidos = require(script.Parent.Sonidos)

local E = Config.Estilo
local COLORES =
	{ E.Menta, E.Rosa, E.Amarillo, Color3.fromHex("38C8FF"), Color3.fromHex("FF3B30"), E.Violeta }

local revelacion = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Revelacion")
local cartel = revelacion:WaitForChild("Celebracion") :: Frame
local escala = cartel:WaitForChild("Escala") :: UIScale
local titulo = cartel:WaitForChild("Titulo") :: TextLabel
local premio = cartel:WaitForChild("Premio") :: TextLabel
local subtitulo = cartel:WaitForChild("Subtitulo") :: TextLabel
local confeti = revelacion:WaitForChild("Confeti") :: Frame

local Celebracion = {}

local function lluviaDePapelitos(cantidad: number)
	for _ = 1, cantidad do
		local p = Instance.new("Frame")
		p.BorderSizePixel = 0
		p.BackgroundColor3 = COLORES[math.random(#COLORES)]
		p.Size = UDim2.fromOffset(math.random(8, 14), math.random(14, 22))
		p.Position = UDim2.new(math.random(), 0, -0.05, -math.random(0, 200))
		p.Rotation = math.random(0, 360)
		p.Parent = confeti
		local duracion = 1.6 + math.random() * 1.4
		TweenService
			:Create(p, TweenInfo.new(duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(p.Position.X.Scale + (math.random() - 0.5) * 0.2, 1.1),
				Rotation = p.Rotation + math.random(-540, 540),
			})
			:Play()
		task.delay(duracion, function()
			p:Destroy()
		end)
	end
end

-- Muestra el cartel unos segundos (frena al que la llama hasta que termina).
function Celebracion.mostrar(c: Fusion.Celebracion)
	titulo.Text = if c.Completo
		then "¡MUTADEX COMPLETA!"
		else "¡GENERACIÓN " .. c.Gen .. " COMPLETA!"
	premio.Text = "+" .. Formato.numero(c.Premio) .. " ADN"
	subtitulo.Text = if c.Completo
		then "¡Descubriste las 50 especies!"
		else "Descubriste todas las especies de " .. string.rep("●", c.Gen)
	escala.Scale = 0.2
	cartel.Visible = true
	TweenService
		:Create(escala, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1,
		})
		:Play()
	-- SONIDO: fanfarria por completar una generación (arpegio largo hacia arriba)
	Sonidos.secuencia({ 0, 4, 7, 12, 7, 12, 16, 19, 24 }, 0.11, 0.45)
	lluviaDePapelitos(90)
	task.wait(1.2)
	lluviaDePapelitos(60)
	task.wait(2.6)
	cartel.Visible = false
end

return Celebracion
