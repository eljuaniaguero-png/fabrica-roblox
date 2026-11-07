--!strict
-- Teclas Z, X y C: animación, movimiento propio y cartel de recargas. El daño lo decide el servidor.
-- T cambia de Linaje mientras no exista la ruleta (Config.Poderes.CambioLibre).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remoto = ReplicatedStorage:WaitForChild("Poderes") :: RemoteEvent

local P = Config.Poderes
local K = Enum.KeyCode
local jugador = Players.LocalPlayer
local pistas: { [string]: AnimationTrack } = {}
local listo: { [string]: number } = {}
local raiz: BasePart? = nil
local accion: AnimationTrack? = nil

local function cargar(personaje: Model)
	local h = personaje:WaitForChild("Humanoid") :: Humanoid
	local animator = h:WaitForChild("Animator") :: Animator
	raiz = personaje:WaitForChild("HumanoidRootPart") :: BasePart
	table.clear(pistas)
	local grupos: { [string]: { [string]: string } } = {
		FuerzaBruta = Config.Animaciones.linaje_fuerzabruta,
		Reflejos = Config.Animaciones.linaje_reflejos,
		Piroquinesis = Config.Animaciones.linaje_piroquinesis,
	}
	for linaje, grupo in grupos do
		for nombre, id in grupo do
			local anim = Instance.new("Animation")
			anim.AnimationId = id
			pistas[linaje .. nombre] = animator:LoadAnimation(anim)
		end
	end
end

local function tocar(nombre: string): AnimationTrack?
	local pista = pistas[nombre]
	if not pista then
		return nil
	end
	if accion then
		accion:Stop(0.08)
	end
	accion = pista
	pista:Play(0.08)
	return pista
end

local function mover(velocidad: Vector3, tiempo: number)
	local r = raiz
	if not r then
		return
	end
	task.spawn(function()
		local fin = os.clock() + tiempo
		while os.clock() < fin do
			r.AssemblyLinearVelocity = velocidad + Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			RunService.Heartbeat:Wait()
		end
	end)
end

local function encadenar(primera: string, resto: { string }, tiempos: { number })
	tocar(primera)
	local linaje = jugador:GetAttribute("Linaje")
	task.spawn(function()
		for i, nombre in resto do
			task.wait(tiempos[i])
			if jugador:GetAttribute("Linaje") == linaje then
				tocar(nombre)
			end
		end
	end)
end

-- Paso fantasma: aparece detrás del rival más cercano.
local function pasoFantasma(alcance: number)
	local r = raiz
	if not r then
		return
	end
	local mejor: BasePart? = nil
	local distancia = alcance
	for _, otro in CollectionService:GetTagged("Combatiente") do
		if otro ~= jugador.Character then
			local ro = otro:FindFirstChild("HumanoidRootPart")
			if ro and ro:IsA("BasePart") and (ro.Position - r.Position).Magnitude < distancia then
				mejor, distancia = ro, (ro.Position - r.Position).Magnitude
			end
		end
	end
	local objetivo = mejor
	if objetivo then
		task.delay(0.1, function()
			local detras = objetivo.Position - objetivo.CFrame.LookVector * 4
			r.CFrame = CFrame.lookAt(detras, objetivo.Position)
		end)
	else
		task.delay(0.1, function()
			r.CFrame += r.CFrame.LookVector * alcance
		end)
	end
end

local function usar(tecla: string)
	local linaje = jugador:GetAttribute("Linaje")
	local personaje = jugador.Character
	if typeof(linaje) ~= "string" or not personaje then
		return
	end
	local datos = P.Linajes[linaje] and (P.Linajes[linaje] :: any)[tecla]
	local clave = linaje .. tecla
	local energia = personaje:GetAttribute("Energia")
	if
		not datos
		or os.clock() < (listo[clave] or 0)
		or typeof(energia) ~= "number"
		or energia < datos.Energia
		or personaje:GetAttribute("Aturdido") == true
		or personaje:GetAttribute("Frenado") == true
	then
		return
	end
	listo[clave] = os.clock() + datos.Recarga
	remoto:FireServer(tecla)
	local r = raiz
	if datos.Accion == "Embestida" and r then
		encadenar(
			linaje .. "EmbestidaInicio",
			{ linaje .. "EmbestidaCarrera", linaje .. "EmbestidaFrenada" },
			{ 0.2, 0.45 }
		)
		mover(r.CFrame.LookVector * (datos.Alcance / 0.5), 0.5)
	elseif datos.Accion == "Chorro" then
		encadenar(
			linaje .. "ChorroInicio",
			{ linaje .. "ChorroLoop", linaje .. "ChorroFin" },
			{ 0.2, datos.Dura }
		)
	elseif datos.Accion == "LluviaGolpes" then
		tocar(linaje .. "LluviaGolpes")
		task.delay(1, function()
			if accion == pistas[linaje .. "LluviaGolpes"] and accion then
				accion:Stop(0.1)
			end
		end)
	elseif datos.Accion == "PasoFantasma" then
		tocar(linaje .. "PasoFantasma")
		pasoFantasma(datos.Alcance)
	else
		tocar(linaje .. datos.Accion)
	end
end

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado then
		return
	end
	local tecla = entrada.KeyCode
	if tecla == K.Z then
		usar("Z")
	elseif tecla == K.X then
		usar("X")
	elseif tecla == K.C then
		usar("C")
	elseif tecla == K.T then
		remoto:FireServer("Cambiar")
	end
end)

-- Cartel con el Linaje y las recargas.
local gui = Instance.new("ScreenGui")
gui.Name = "Poderes"
gui.ResetOnSpawn = false
local texto = Instance.new("TextLabel")
texto.AnchorPoint = Vector2.new(0.5, 1)
texto.Position = UDim2.new(0.5, 0, 1, -16)
texto.Size = UDim2.fromOffset(620, 54)
texto.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
texto.BackgroundTransparency = 0.3
texto.TextColor3 = Color3.new(1, 1, 1)
texto.Font = Enum.Font.GothamBold
texto.TextSize = 15
texto.Parent = gui
gui.Parent = jugador:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
	local linaje = jugador:GetAttribute("Linaje")
	local datos = typeof(linaje) == "string" and P.Linajes[linaje]
	if not datos then
		return
	end
	local partes = {}
	for _, tecla in { "Z", "X", "C" } do
		local d = (datos :: any)[tecla]
		local falta = (listo[linaje .. tecla] or 0) - os.clock()
		table.insert(
			partes,
			string.format(
				"%s %s%s",
				tecla,
				d.Nombre,
				if falta > 0 then string.format(" (%.0f)", math.ceil(falta)) else ""
			)
		)
	end
	texto.Text = string.format("%s  (T cambia)\n%s", linaje, table.concat(partes, "   "))
end)

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
