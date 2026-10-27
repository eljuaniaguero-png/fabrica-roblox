--!strict
-- La sala desde el cliente (etapa 7b-1): caminar, sentarse en tu máquina y volver a caminar.
--   - Solo tu máquina (atributo Dueno) muestra "E: Jugar" (en celular, el botón del prompt) y un
--     contorno amarillo cuando estás cerca, como en CloverPit.
--   - Sentarse: el personaje queda quieto en la banqueta, la cámara se acerca a la pantalla en
--     Config.Sala.TiempoCamara, fundido a negro y adentro de la pantalla está la mazmorra (la
--     cámara del tablero de Escena), con un marco de pantalla alrededor.
--   - Levantarse: lo mismo al revés y vuelve la cámara normal y el movimiento.
--   - El mostrador abre "elegir bola" (lo dibuja Pantallas; Main.client avisa al servidor).
--   - Las máquinas de fondo muestran una demo de colores.
-- Solo cámara y personaje: la partida la sigue decidiendo el servidor.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

export type Opciones = {
	escena: any, -- Escena (activarCamara)
	alSentarse: () -> (), -- ya adentro de la pantalla
	alLevantarse: () -> (), -- antes de salir de la pantalla
	alMostrador: () -> (),
}

export type Sala = {
	enMaquina: () -> boolean, -- sentado y con la cámara adentro de la pantalla
	levantarse: () -> (),
}

local Sala = {}

local jugador = Players.LocalPlayer
local S = Config.Sala

-- Controles del personaje (también el joystick del celular).
local controles: any = nil
task.spawn(function()
	local modulo = jugador:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
	if modulo and modulo:IsA("ModuleScript") then
		local ok, playerModule = pcall(require, modulo)
		if ok and playerModule then
			controles = (playerModule :: any):GetControls()
		end
	end
end)
local function mover(si: boolean)
	if controles then
		if si then
			controles:Enable()
		else
			controles:Disable()
		end
	end
end

local function miMaquina(): Model?
	for _, m in CollectionService:GetTagged("Maquina") do
		if m:IsA("Model") and m:GetAttribute("Dueno") == jugador.UserId then
			return m
		end
	end
	return nil
end

function Sala.crear(o: Opciones): Sala
	local camara = Workspace.CurrentCamera
	local sentado = false
	local adentro = false
	local ocupado = false -- en plena transición

	-- Fundido y marco de pantalla.
	local gui = Instance.new("ScreenGui")
	gui.Name = "SalaCamara"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.DisplayOrder = 50
	gui.Parent = jugador:WaitForChild("PlayerGui")
	local negro = Instance.new("Frame")
	negro.Size = UDim2.fromScale(1, 1)
	negro.BackgroundColor3 = Color3.new(0, 0, 0)
	negro.BackgroundTransparency = 1
	negro.BorderSizePixel = 0
	negro.Parent = gui
	local guiMarco = Instance.new("ScreenGui")
	guiMarco.Name = "MarcoPantalla"
	guiMarco.ResetOnSpawn = false
	guiMarco.IgnoreGuiInset = true
	guiMarco.ScreenInsets = Enum.ScreenInsets.None
	guiMarco.DisplayOrder = -5 -- debajo de las pantallas del juego
	guiMarco.Enabled = false
	guiMarco.Parent = gui.Parent
	local marco = Instance.new("Frame")
	marco.Position = UDim2.fromOffset(8, 8)
	marco.Size = UDim2.new(1, -16, 1, -16)
	marco.BackgroundTransparency = 1
	marco.Parent = guiMarco
	local esquinas = Instance.new("UICorner")
	esquinas.CornerRadius = UDim.new(0, 28)
	esquinas.Parent = marco
	local borde = Instance.new("UIStroke")
	borde.Thickness = 18
	borde.Color = Color3.fromHex("#0D0A14")
	borde.Parent = marco

	local function fundir(hacia: number)
		local t = TweenService:Create(
			negro,
			TweenInfo.new(S.TiempoFundido),
			{ BackgroundTransparency = hacia }
		)
		t:Play()
		t.Completed:Wait()
	end

	local function moverCamara(destino: CFrame)
		camara.CameraType = Enum.CameraType.Scriptable
		local t = TweenService:Create(
			camara,
			TweenInfo.new(S.TiempoCamara, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ CFrame = destino }
		)
		t:Play()
		t.Completed:Wait()
	end

	local function frenteAPantalla(m: Model): CFrame?
		local pantalla = m:FindFirstChild("Pantalla")
		if not pantalla or not pantalla:IsA("BasePart") then
			return nil
		end
		-- La pantalla mira a +Z: la cámara queda delante, a la distancia justa para llenarla.
		local frente = pantalla.CFrame.LookVector * -1
		return CFrame.lookAt(pantalla.Position + frente * 1.5, pantalla.Position)
	end

	local function raiz(): BasePart?
		local personaje = jugador.Character
		local r = personaje and personaje:FindFirstChild("HumanoidRootPart")
		return if r and r:IsA("BasePart") then r else nil
	end

	local function sentarse()
		local m = miMaquina()
		local destino = m and frenteAPantalla(m)
		if sentado or ocupado or not m or not destino then
			return
		end
		sentado, ocupado = true, true
		ProximityPromptService.Enabled = false
		mover(false)
		local r = raiz()
		local banqueta = m:FindFirstChild("Banqueta")
		if r and banqueta and banqueta:IsA("BasePart") then
			r.Anchored = true
			local pos = banqueta.Position + Vector3.new(0, 2.6, 0)
			r.CFrame = CFrame.lookAt(pos, Vector3.new(m:GetPivot().X, pos.Y, m:GetPivot().Z))
		end
		Ajustes.modoPelea(true)
		moverCamara(destino)
		fundir(0)
		o.escena.activarCamara(true)
		guiMarco.Enabled = true
		adentro = true
		o.alSentarse()
		fundir(1)
		ocupado = false
	end

	local function levantarse()
		local m = miMaquina()
		if not sentado or ocupado then
			return
		end
		ocupado = true
		adentro = false
		o.alLevantarse()
		fundir(0)
		guiMarco.Enabled = false
		o.escena.activarCamara(false)
		local destino = m and frenteAPantalla(m)
		if destino then
			camara.CameraType = Enum.CameraType.Scriptable
			camara.CFrame = destino
		end
		fundir(1)
		local r = raiz()
		if r then
			moverCamara(r.CFrame * CFrame.new(0, 4, 11) * CFrame.Angles(math.rad(-12), 0, 0))
			r.Anchored = false
		end
		camara.CameraType = Enum.CameraType.Custom
		-- La cámara de Roblox recuerda el zoom de antes: se la obliga a alejarse un momento.
		local minimo = jugador.CameraMinZoomDistance
		jugador.CameraMinZoomDistance = 10
		task.delay(0.1, function()
			jugador.CameraMinZoomDistance = minimo
		end)
		Ajustes.modoPelea(false)
		mover(true)
		ProximityPromptService.Enabled = true
		sentado, ocupado = false, false
	end

	-- Prompts: "Jugar" solo en tu máquina, con contorno amarillo cuando está a mano.
	local function prepararMaquina(m: Instance)
		if not m:IsA("Model") then
			return
		end
		local cuerpo = m:FindFirstChild("Cuerpo")
		local prompt = cuerpo and cuerpo:FindFirstChild("Jugar")
		if not prompt or not prompt:IsA("ProximityPrompt") then
			return
		end
		local contorno = Instance.new("Highlight")
		contorno.FillTransparency = 1
		contorno.OutlineColor = Color3.fromHex(S.Colores.Borde)
		contorno.Enabled = false
		contorno.Adornee = m
		contorno.Parent = m
		local function actualizar()
			prompt.Enabled = m:GetAttribute("Dueno") == jugador.UserId
		end
		m:GetAttributeChangedSignal("Dueno"):Connect(actualizar)
		actualizar()
		prompt.PromptShown:Connect(function()
			contorno.Enabled = true
		end)
		prompt.PromptHidden:Connect(function()
			contorno.Enabled = false
		end)
	end
	for _, m in CollectionService:GetTagged("Maquina") do
		prepararMaquina(m)
	end
	CollectionService:GetInstanceAddedSignal("Maquina"):Connect(prepararMaquina)

	ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
		if
			prompt.Name == "Jugar" and prompt:IsDescendantOf(miMaquina() or Instance.new("Folder"))
		then
			task.spawn(sentarse)
		elseif prompt.Name == "VerBolas" and not sentado then
			o.alMostrador()
		end
	end)

	-- 27/10: la sala se mueve (solo en tu pantalla): el ventilador gira, el fluorescente titila de vez
	-- en cuando y los tubos de neón laten.
	task.spawn(function()
		local sala = Workspace:WaitForChild("Sala", 30)
		if not sala then
			return
		end
		local ventilador = sala:WaitForChild("Ventilador", 10)
		local aspas: { { Parte: BasePart, Relativo: CFrame } } = {}
		local tubos: { BasePart } = {}
		for _, d in sala:GetChildren() do
			if
				d:IsA("BasePart")
				and d.Name == "Aspa"
				and ventilador
				and ventilador:IsA("BasePart")
			then
				-- Centro del giro: la boca del ventilador, mirando a la sala (+Z).
				local centro = CFrame.new(ventilador.Position + Vector3.new(0, 0, 0.25))
				table.insert(aspas, { Parte = d, Relativo = centro:ToObjectSpace(d.CFrame) })
			elseif d:IsA("BasePart") and d.Name == "Tubo" then
				table.insert(tubos, d)
			end
		end
		local centroAspas = if ventilador and ventilador:IsA("BasePart")
			then CFrame.new(ventilador.Position + Vector3.new(0, 0, 0.25))
			else CFrame.identity
		RunService.Heartbeat:Connect(function()
			if sentado and not ocupado then
				return -- jugando, la sala no se ve
			end
			local t = os.clock()
			local giro = CFrame.Angles(0, 0, t * 5)
			for _, a in aspas do
				a.Parte.CFrame = centroAspas * giro * a.Relativo
			end
			local latido = (math.sin(t * 2.2) + 1) / 2
			for _, tubo in tubos do
				tubo.Transparency = latido * 0.3
			end
		end)
		local fluor = sala:FindFirstChild("Fluorescente")
		if not fluor or not fluor:IsA("BasePart") then
			return
		end
		local luzFluor = fluor:FindFirstChildOfClass("PointLight")
		while true do
			task.wait(4 + math.random() * 6)
			for _ = 1, math.random(2, 4) do
				fluor.Transparency = 0.7
				if luzFluor then
					luzFluor.Enabled = false
				end
				task.wait(0.04 + math.random() * 0.06)
				fluor.Transparency = 0
				if luzFluor then
					luzFluor.Enabled = true
				end
				task.wait(0.05 + math.random() * 0.1)
			end
		end
	end)

	return {
		enMaquina = function(): boolean
			return adentro and not ocupado
		end,
		levantarse = function()
			task.spawn(levantarse)
		end,
	}
end

return Sala
