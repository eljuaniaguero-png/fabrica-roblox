--!strict
-- Teclas Z, X y C: animación, movimiento propio y cartel de recargas. El daño lo decide el servidor.
-- T cambia de Linaje mientras no exista la ruleta (Config.Poderes.CambioLibre).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Tema = require(script.Parent:WaitForChild("Tema"))
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
	if usado or jugador:GetAttribute("MenuAbierto") == true then
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

-- Abajo al centro: los tres poderes en rombos, T cambia a la izquierda y gadget G a la derecha.
local H = Config.Hud
local gui = Tema.pantalla("Poderes", 1)
local ANCHO = H.SeparacionRombos * 4 + H.TamRombo + 90
local caja =
	Tema.grupo(gui, Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -40), Vector2.new(ANCHO, 150))
local medio = ANCHO / 2
Tema.ornamento(caja, Vector2.new(medio, 24), 360)

local cambia = Instance.new("TextButton")
cambia.AnchorPoint = Vector2.new(1, 0.5)
cambia.Position = UDim2.fromOffset(medio - H.SeparacionRombos - H.TamRombo / 2 - 18, 92)
cambia.Size = UDim2.fromOffset(96, 36)
cambia.BackgroundTransparency = 1
cambia.Text = "T  CAMBIA"
cambia.TextColor3 = Tema.Hueso
cambia.TextTransparency = 0.45
cambia.FontFace = Tema.LetraFina
cambia.TextSize = 13
cambia.Visible = P.CambioLibre == true
cambia.Parent = caja
cambia.Activated:Connect(function()
	remoto:FireServer("Cambiar")
end)

-- Ranura satélite del gadget (G - Gancho táctico del Taller)
local centroGancho = Vector2.new(medio + H.SeparacionRombos * 2, 92)
local tamGancho = math.round(H.TamRombo * 0.8)
local romboGancho = Tema.rombo(caja, centroGancho, tamGancho, true)
local icoGancho = Instance.new("ImageLabel")
icoGancho.AnchorPoint = Vector2.new(0.5, 0.5)
icoGancho.Position = UDim2.fromScale(0.5, 0.5)
icoGancho.Size = UDim2.fromOffset(tamGancho * 0.56, tamGancho * 0.56)
icoGancho.BackgroundTransparency = 1
icoGancho.ScaleType = Enum.ScaleType.Fit
icoGancho.Image = H.Imagenes.Controles.Gancho
icoGancho.ImageColor3 = Tema.Hueso
icoGancho.ImageTransparency = 0.65
icoGancho.Visible = H.Imagenes.Controles.Gancho ~= ""
icoGancho.ZIndex = 5
icoGancho.Parent = romboGancho
if not icoGancho.Visible then
	local gTxt = Tema.texto(
		romboGancho,
		"G",
		{ tam = 18, transparencia = 0.55, alineado = Enum.TextXAlignment.Center }
	)
	gTxt.AutomaticSize = Enum.AutomaticSize.None
	gTxt.Size = UDim2.fromScale(1, 1)
	gTxt.ZIndex = 5
end
if H.Imagenes.Menu.Candado ~= "" then
	local candado = Instance.new("ImageLabel")
	candado.AnchorPoint = Vector2.new(0.5, 0.5)
	candado.Position = UDim2.fromScale(0.76, 0.76)
	candado.Size = UDim2.fromOffset(16, 16)
	candado.BackgroundTransparency = 1
	candado.ScaleType = Enum.ScaleType.Fit
	candado.Image = H.Imagenes.Menu.Candado
	candado.ImageColor3 = Tema.Hueso
	candado.ImageTransparency = 0.25
	candado.ZIndex = 7
	candado.Parent = romboGancho
end
local etiquetaGancho =
	Tema.texto(caja, "G", { tam = 13, transparencia = 0.45, alineado = Enum.TextXAlignment.Center })
etiquetaGancho.AnchorPoint = Vector2.new(0.5, 0)
etiquetaGancho.Position = UDim2.fromOffset(centroGancho.X, centroGancho.Y + tamGancho / 2 + 2)

type Ranura =
	{ caja: Frame, icono: ImageLabel, letra: TextLabel, recarga: TextLabel, lista: boolean }
local ranuras: { [string]: Ranura } = {}
for i, tecla in { "Z", "X", "C" } do
	local centro = Vector2.new(medio + (i - 2) * H.SeparacionRombos, 92)
	local r = Tema.rombo(caja, centro, H.TamRombo, true)
	local icono = Instance.new("ImageLabel")
	icono.AnchorPoint = Vector2.new(0.5, 0.5)
	icono.Position = UDim2.fromScale(0.5, 0.5)
	icono.Size = UDim2.fromOffset(H.TamRombo * 0.6, H.TamRombo * 0.6)
	icono.BackgroundTransparency = 1
	icono.ImageColor3 = Tema.Hueso
	icono.ZIndex = 5
	icono.Parent = r
	-- Sin ícono subido, la letra va adentro del rombo en el color del Linaje.
	local letra = Tema.texto(r, tecla, { tam = 22, alineado = Enum.TextXAlignment.Center })
	letra.AutomaticSize = Enum.AutomaticSize.None
	letra.Size = UDim2.fromScale(1, 1)
	letra.ZIndex = 5
	local recarga = Tema.texto(
		r,
		"",
		{ tam = 30, letra = Tema.LetraGruesa, alineado = Enum.TextXAlignment.Center }
	)
	recarga.AutomaticSize = Enum.AutomaticSize.None
	recarga.Size = UDim2.fromScale(1, 1)
	recarga.ZIndex = 6
	recarga.TextStrokeTransparency = 0.2
	local boton = Instance.new("TextButton")
	boton.AnchorPoint = Vector2.new(0.5, 0.5)
	boton.Position = UDim2.fromScale(0.5, 0.5)
	boton.Size = UDim2.fromScale(1.15, 1.15)
	boton.BackgroundTransparency = 1
	boton.Text = ""
	boton.ZIndex = 8
	boton.Parent = r
	boton.Activated:Connect(function()
		usar(tecla)
	end)
	local abajo = Tema.texto(
		caja,
		tecla,
		{ tam = 14, transparencia = 0.3, alineado = Enum.TextXAlignment.Center }
	)
	abajo.AnchorPoint = Vector2.new(0.5, 0)
	abajo.Position = UDim2.fromOffset(centro.X, centro.Y + H.TamRombo / 2 + 2)
	ranuras[tecla] = { caja = r, icono = icono, letra = letra, recarga = recarga, lista = true }
end
gui.Parent = jugador:WaitForChild("PlayerGui")

-- Destello corto del rombo cuando el poder vuelve a estar listo.
local function avisarListo(r: Ranura, color: Color3)
	local escala = Instance.new("UIScale")
	escala.Scale = 1.18
	escala.Parent = r.caja
	TweenService:Create(escala, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	r.icono.ImageColor3 = color
	TweenService:Create(r.icono, TweenInfo.new(0.5), { ImageColor3 = Tema.Hueso }):Play()
	task.delay(0.3, function()
		escala:Destroy()
	end)
end

local linajeVisto: unknown = nil
RunService.RenderStepped:Connect(function()
	local linaje = jugador:GetAttribute("Linaje")
	local datos = typeof(linaje) == "string" and P.Linajes[linaje]
	caja.Visible = datos ~= nil and datos ~= false
	if not datos then
		return
	end
	local color = Tema.color(linaje)
	local nuevo = linaje ~= linajeVisto
	linajeVisto = linaje
	for tecla, r in ranuras do
		local d = (datos :: any)[tecla]
		if nuevo then
			local id = (H.Imagenes.Iconos :: any)[d.Accion] or ""
			r.icono.Image = id
			r.icono.Visible = id ~= ""
			r.letra.Visible = id == ""
			r.letra.TextColor3 = color
		end
		local falta = (listo[linaje .. tecla] or 0) - os.clock()
		local lista = falta <= 0
		r.recarga.Text = if lista then "" else tostring(math.ceil(falta))
		r.icono.ImageTransparency = if lista then 0 else 0.7
		r.letra.TextTransparency = if lista then 0 else 0.7
		if lista and not r.lista and not nuevo then
			avisarListo(r, color)
		end
		r.lista = lista
	end
end)

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
