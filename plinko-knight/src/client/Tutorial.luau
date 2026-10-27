--!strict
-- El primer minuto (etapa 11): una mano que muestra cómo tirar, arriba del tablero, con el cartel
-- "ARRASTRÁ Y SOLTÁ". Apoya, arrastra de un lado al otro (la línea de puntos la sigue en la
-- pantalla del jugador cuando él lo hace) y suelta. Main.client la muestra en la pelea de
-- práctica hasta el primer tiro. Solo dibuja: no toca la partida.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Estilo = require(script.Parent:WaitForChild("Estilo"))

export type Tutorial = {
	mostrar: () -> (),
	ocultar: () -> (),
}

local Tutorial = {}

-- escena: la de Escena.armar (aMundo lleva un punto del tablero al mundo).
function Tutorial.crear(escena: any): Tutorial
	local T = Config.Tutorial
	local gui = Estilo.pantalla("Tutorial", 40, Players.LocalPlayer:WaitForChild("PlayerGui"))
	gui.ScreenInsets = Enum.ScreenInsets.None -- se ubica con WorldToViewportPoint
	gui.Enabled = false

	local caja = Instance.new("Frame")
	caja.BackgroundTransparency = 1
	caja.AnchorPoint = Vector2.new(0.5, 0.5)
	caja.Size = UDim2.fromOffset(320, 200)
	caja.Parent = gui
	local escala = Instance.new("UIScale")
	escala.Parent = caja

	local cartel = Estilo.texto(caja, T.Texto, Estilo.Texto.Grande)
	cartel.AnchorPoint = Vector2.new(0.5, 0)
	cartel.Position = UDim2.fromOffset(160, 160) -- debajo de la mano (arriba está tu avatar)
	cartel.Size = UDim2.new(1, 0, 0, 40)
	cartel.TextColor3 = Color3.fromHex(Config.Colores.Numero)
	cartel.BackgroundColor3 = Color3.new(0, 0, 0) -- franja oscura: se lee arriba de las clavijas
	cartel.BackgroundTransparency = 0.3

	-- La mano: un dedo que apunta para arriba (emoji, así no hace falta subir una imagen).
	local mano = Instance.new("TextLabel")
	mano.BackgroundTransparency = 1
	mano.AnchorPoint = Vector2.new(0.5, 0)
	mano.Size = UDim2.fromOffset(80, 80)
	mano.TextScaled = true
	mano.Text = "👆"
	mano.Parent = caja
	-- El punto donde apoya el dedo: se agranda al apoyar y se apaga al soltar.
	local punto = Instance.new("Frame")
	punto.AnchorPoint = Vector2.new(0.5, 0.5)
	punto.Size = UDim2.fromOffset(26, 26)
	punto.BackgroundColor3 = Color3.new(1, 1, 1)
	punto.BorderSizePixel = 0
	punto.Parent = caja
	local redondo = Instance.new("UICorner")
	redondo.CornerRadius = UDim.new(1, 0)
	redondo.Parent = punto

	local conexion: RBXScriptConnection? = nil
	local t0 = 0

	local function cuadro()
		local camara = Workspace.CurrentCamera
		-- Arriba del tablero, un poco abajo del lanzador.
		local pos, visible = camara:WorldToViewportPoint(escena.aMundo(0, -6, 1))
		caja.Visible = visible
		caja.Position = UDim2.fromOffset(pos.X, pos.Y)
		escala.Scale = Estilo.escala()
		-- Una vuelta: apoya (15 %), arrastra a la izquierda y a la derecha (70 %), suelta (15 %).
		local f = ((os.clock() - t0) % T.Vuelta) / T.Vuelta
		local x = 0
		local apoyado = f > 0.15 and f < 0.85
		if apoyado then
			x = math.sin((f - 0.15) / 0.7 * math.pi * 2) * T.Recorrido
		end
		local y = 70 + (if apoyado then 0 else 14)
		mano.Position = UDim2.fromOffset(160 + x + 14, y)
		punto.Position = UDim2.fromOffset(160 + x, y)
		punto.BackgroundTransparency = if apoyado then 0.35 else 1
		cartel.TextTransparency = 0.1 * math.sin(os.clock() * 6)
	end

	return {
		mostrar = function()
			if conexion then
				return
			end
			t0 = os.clock()
			gui.Enabled = true
			conexion = RunService.RenderStepped:Connect(cuadro)
		end,
		ocultar = function()
			gui.Enabled = false
			if conexion then
				conexion:Disconnect()
				conexion = nil
			end
		end,
	}
end

return Tutorial
