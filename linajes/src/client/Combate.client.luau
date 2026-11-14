--!strict
-- Teclas del combate, animaciones, cola de teclas, efectos inmediatos y barras de vida y energía.
-- Acá no se decide nada: el daño lo valida el servidor (server/Combate.server.luau).

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local CamaraCombate = require(script.Parent:WaitForChild("CamaraCombate"))
local EfectosGolpe = require(script.Parent:WaitForChild("EfectosGolpe"))
local Niveles = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Niveles"))
local Tema = require(script.Parent:WaitForChild("Tema"))
local remoto = ReplicatedStorage:WaitForChild("Combate") :: RemoteEvent

local C = Config.Combate
local K = Enum.KeyCode
local jugador = Players.LocalPlayer

local pistas: { [string]: AnimationTrack } = {}
local personaje: Model? = nil
local humanoid: Humanoid? = nil
local raiz: BasePart? = nil
local accion: AnimationTrack? = nil
local libreDesde, ultimoGolpe, paso, dashListo, dashEn = 0, 0, 0, 0, 0
local bloqueando = false
local cola: { pedido: string, variante: string?, cuando: number }? = nil

local function cargar(nuevo: Model)
	personaje = nuevo
	local h = nuevo:WaitForChild("Humanoid") :: Humanoid
	local animator = h:WaitForChild("Animator") :: Animator
	humanoid = h
	raiz = nuevo:WaitForChild("HumanoidRootPart") :: BasePart
	table.clear(pistas)
	for nombre, id in Config.Animaciones.base do
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		pistas[nombre] = animator:LoadAnimation(anim)
	end
	h.WalkSpeed = Config.PruebaTeclas.Caminar
	nuevo:GetAttributeChangedSignal("Frenado"):Connect(function()
		h.WalkSpeed = if nuevo:GetAttribute("Frenado") == true
			then 0
			else Config.PruebaTeclas.Caminar
	end)
	nuevo:GetAttributeChangedSignal("Aturdido"):Connect(function()
		local aturdido = nuevo:GetAttribute("Aturdido") == true
		h.WalkSpeed = if aturdido then 0 else Config.PruebaTeclas.Caminar
		if aturdido then
			bloqueando = false
			if accion then
				accion:Stop(0.05)
			end
			accion = pistas.Aturdido
			pistas.Aturdido:Play(0.05)
		elseif accion == pistas.Aturdido then
			pistas.Aturdido:Stop(0.15)
			accion = nil
		end
	end)
end

local function aturdido(): boolean
	local p = personaje
	return p ~= nil and (p:GetAttribute("Aturdido") == true or p:GetAttribute("Frenado") == true)
end

local function tocar(nombre: string, velocidad: number?): AnimationTrack?
	local h = humanoid
	local torso = pistas[nombre .. "Torso"]
	local pista = if h and torso and h.MoveDirection.Magnitude > 0.1 then torso else pistas[nombre]
	if not pista then
		return nil
	end
	if accion then
		accion:Stop(0.08)
	end
	accion = pista
	pista:Play(0.08)
	if velocidad then
		pista:AdjustSpeed(velocidad)
	end
	return pista
end

-- Efecto: destello sobre el que recibe. SONIDO: golpe, en Config cuando estén los sonidos.
local function destello(objetivo: Instance, color: Color3)
	local luz = Instance.new("Highlight")
	luz.Adornee = objetivo
	luz.FillColor = color
	luz.FillTransparency = 0.35
	luz.OutlineTransparency = 1
	luz.Parent = objetivo
	Debris:AddItem(luz, C.Destello)
end

local function numero(objetivo: Model, texto: string, color: Color3)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(90, 34)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 3, 0)
	gui.AlwaysOnTop = true
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.FontFace = Tema.LetraGruesa
	t.TextScaled = true
	t.TextColor3 = color
	t.TextStrokeColor3 = Tema.Fondo
	t.TextStrokeTransparency = 0.35
	t.Text = texto
	t.Parent = gui
	gui.Parent = r
	Debris:AddItem(gui, 0.6)
end

-- Suena en el cuerpo que recibe, con una variación chica para que no se repita igual.
local function sonar(objetivo: Model, nombre: string)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	local datos = (Config.Sonidos :: any)[nombre]
	if r and datos and datos.Id ~= "" then
		local s = Instance.new("Sound")
		s.SoundId = datos.Id
		s.Volume = datos.Volumen
		s.PlaybackSpeed = 1 + (math.random() - 0.5) * Config.Sonidos.Variacion
		s.RollOffMaxDistance = 90
		s.Parent = r
		s:Play()
		Debris:AddItem(s, 2)
	end
end

-- Chispas y anillo en el punto del golpe.
local function colorDe(atacante: Model?): Color3
	local dueno = atacante and Players:GetPlayerFromCharacter(atacante)
	local linaje = dueno and dueno:GetAttribute("Linaje")
	return typeof(linaje) == "string" and (Config.Poderes.Colores :: any)[linaje] or C.ColorChispas
end

local function impacto(objetivo: Model, fuerte: boolean, color: Color3, escala: number)
	local r = objetivo:FindFirstChild("HumanoidRootPart")
	if not (r and r:IsA("BasePart")) then
		return
	end
	EfectosGolpe.reproducir(r.Position, fuerte, color, escala)
end

local ANGULOS_TAJO = { 26, -30, -76, 8 }

-- Arco: estela en la mano + media luna 3D cómic delante del ataque.
local function arco(atacante: Model, numeroGolpe: number, fuerte: boolean?)
	local color = colorDe(atacante)
	local mano = atacante:FindFirstChild(if numeroGolpe % 2 == 0 then "LeftHand" else "RightHand")
	if mano and mano:IsA("BasePart") then
		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		a0.Position = Vector3.new(0, 1.3, 0)
		a1.Position = Vector3.new(0, -1.3, 0)
		a0.Parent = mano
		a1.Parent = mano
		local estela = Instance.new("Trail")
		estela.Attachment0 = a0
		estela.Attachment1 = a1
		estela.Lifetime = 0.22
		estela.LightEmission = 1
		estela.FaceCamera = true
		estela.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
		estela.Transparency = NumberSequence.new(0, 1)
		estela.Parent = mano
		Debris:AddItem(estela, 0.75)
		Debris:AddItem(a0, 0.75)
		Debris:AddItem(a1, 0.75)
	end
	local r = atacante:FindFirstChild("HumanoidRootPart")
	if r and r:IsA("BasePart") then
		local ang = ANGULOS_TAJO[(numeroGolpe - 1) % #ANGULOS_TAJO + 1]
		EfectosGolpe.tajo(r.CFrame, ang, color, Niveles.tamano(atacante), fuerte)
	end
end

local function sacudir(fuerza: number, dir: Vector3?)
	CamaraCombate.sacudir(fuerza, dir)
end

-- Paso hacia el rival más cercano o hacia el rumbo de la cámara.
local function avanzar()
	local r = raiz
	if not r then
		return
	end
	local mejor: BasePart? = nil
	local distancia = C.Asistencia
	for _, otro in CollectionService:GetTagged("Combatiente") do
		if otro ~= personaje then
			local ro = otro:FindFirstChild("HumanoidRootPart")
			local ho = otro:FindFirstChildOfClass("Humanoid")
			if ro and ro:IsA("BasePart") and ho and ho.Health > 0 then
				local d = (ro.Position - r.Position).Magnitude
				if d < distancia then
					mejor, distancia = ro, d
				end
			end
		end
	end
	if not mejor then
		local cam = workspace.CurrentCamera
		if cam then
			local mira = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			if mira.Magnitude > 0.05 then
				r.CFrame = CFrame.lookAt(r.Position, r.Position + mira.Unit)
			end
		end
		return
	end
	local objetivo = mejor :: BasePart
	local plano = Vector3.new(objetivo.Position.X, r.Position.Y, objetivo.Position.Z)
	r.CFrame = CFrame.lookAt(r.Position, plano)
	task.spawn(function()
		local fin = os.clock() + C.AvanceTiempo
		while os.clock() < fin and (objetivo.Position - r.Position).Magnitude > C.Cercania do
			r.AssemblyLinearVelocity = r.CFrame.LookVector * C.Avance
				+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			RunService.Heartbeat:Wait()
		end
	end)
end

-- Contador de golpes y daño acumulado: número grande a la derecha, sin caja.
local gui = Tema.pantalla("Combate", 1)
local golpes, acumulado, contadorHasta = 0, 0, 0
local contador = Tema.grupo(
	gui,
	Vector2.new(1, 0.5),
	UDim2.new(1, -Config.Hud.Margen, 0.44, 0),
	Vector2.new(310, 180)
)
contador.Visible = false
local function linea(texto: string, y: number, opciones: Tema.OpcionesTexto): TextLabel
	local t = Tema.texto(contador, texto, opciones)
	t.AnchorPoint = Vector2.new(1, 0)
	t.Position = UDim2.new(1, 0, 0, y)
	t.TextXAlignment = Enum.TextXAlignment.Right
	return t
end
local cuenta = linea("0", 0, { tam = 104, letra = Tema.LetraGruesa })
local palabra = linea("", 108, { tam = 20 })
local suma = linea("", 136, { tam = 17, letra = Tema.LetraFina, transparencia = 0.28 })
local escalaCuenta = Instance.new("UIScale")
escalaCuenta.Parent = cuenta

local function contar(danio: number)
	golpes += 1
	acumulado += danio
	contadorHasta = os.clock() + C.ContadorDura
	cuenta.Text = tostring(golpes)
	palabra.Text = Tema.espaciar(if golpes == 1 then "GOLPE" else "GOLPES", 3)
	palabra.TextColor3 = Tema.color(jugador:GetAttribute("Linaje"))
	suma.Text = string.format("%d de daño", math.round(acumulado))
	contador.Visible = true
	escalaCuenta.Scale = 1.28
	TweenService:Create(escalaCuenta, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Scale = 1 })
		:Play()
end

-- Arriba al centro: nombre y vida del último rival que golpeaste (como la barra de jefe).
local rival = Tema.grupo(gui, Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 42), Vector2.new(640, 62))
rival.Visible = false
local nombreRival = Tema.texto(rival, "", { tam = 20, alineado = Enum.TextXAlignment.Center })
nombreRival.AnchorPoint = Vector2.new(0.5, 0)
nombreRival.Position = UDim2.fromScale(0.5, 0)
local _, vidaRival = Tema.barra(rival, Vector2.new(0, 34), 640, 8, Tema.Vida)
local objetivo: Model? = nil
local rivalHasta = 0

local function marcarRival(m: Model)
	objetivo = m
	rivalHasta = os.clock() + Config.Hud.RivalDura
	local dueno = Players:GetPlayerFromCharacter(m)
	local nombre = if dueno then dueno.DisplayName else (m:GetAttribute("Nombre") or m.Name)
	nombreRival.Text = Tema.espaciar(string.upper(tostring(nombre)), 4)
	rival.Visible = true
end

-- Hit-stop: el golpe propio se frena un instante al conectar.
local function frenar(pista: AnimationTrack, velocidad: number, tiempo: number)
	pista:AdjustSpeed(0)
	task.delay(tiempo, function()
		if pista.IsPlaying then
			pista:AdjustSpeed(velocidad)
		end
	end)
end

local function golpear(varianteForzada: string?): boolean
	local ahora = os.clock()
	if ahora < libreDesde or bloqueando or aturdido() then
		return false
	end
	local vigente = ahora - ultimoGolpe <= C.ReinicioCombo
	local h = humanoid
	local variante: string? = varianteForzada
	if not variante then
		if h and h.FloorMaterial == Enum.Material.Air then
			variante = "Aire"
		elseif ahora - dashEn <= C.VentanaDash then
			variante = "Dash"
		elseif
			UserInputService:IsKeyDown(K.Space)
			or (vigente and paso == #C.Golpes - 1 and UserInputService:IsKeyDown(K.S))
		then
			variante = "Arriba"
		end
	end
	local g: any
	if variante then
		g = (C.Variantes :: any)[variante]
		if variante ~= "Dash" then
			paso = 0
		end
	else
		paso = if vigente then paso % #C.Golpes + 1 else 1
		g = C.Golpes[paso]
	end
	libreDesde = ahora + g.Espera + g.Recarga
	ultimoGolpe = ahora
	remoto:FireServer("Golpe", variante)
	avanzar()
	local fuerte = g.Tipo == "Rompe" or g.Tipo == "Lanza" or g.Tipo == "Piso"
	arco(personaje :: Model, math.max(paso, if fuerte then 4 else 1), fuerte)
	tocar(g.Anim or ("Golpe" .. paso), C.VelocidadGolpes)
	return true
end

local function dash(): boolean
	local r, c = raiz, workspace.CurrentCamera
	local ahora = os.clock()
	if not (r and c) or ahora < dashListo or aturdido() then
		return false
	end
	dashListo = ahora + C.DashRecarga
	dashEn = ahora
	libreDesde = 0 -- cancela recuperación de golpe para encadenar esquive + ataque
	remoto:FireServer("Dash")
	if bloqueando then
		bloqueando = false
		remoto:FireServer("BloqueoFin")
	end
	local adelante = Vector3.new(c.CFrame.LookVector.X, 0, c.CFrame.LookVector.Z).Unit
	local derecha = Vector3.new(c.CFrame.RightVector.X, 0, c.CFrame.RightVector.Z).Unit
	local nombre, direccion = "DashAdelante", adelante
	if UserInputService:IsKeyDown(K.S) then
		nombre, direccion = "DashAtras", -adelante
	elseif UserInputService:IsKeyDown(K.A) then
		nombre, direccion = "DashIzquierda", -derecha
	elseif UserInputService:IsKeyDown(K.D) then
		nombre, direccion = "DashDerecha", derecha
	end
	r.CFrame = CFrame.lookAt(r.Position, r.Position + adelante)
	tocar(nombre)
	EfectosGolpe.dash(personaje :: Model, r, direccion, colorDe(personaje))
	CamaraCombate.zoom(8)
	task.spawn(function()
		local fin = os.clock() + C.DashTiempo
		while os.clock() < fin do
			r.AssemblyLinearVelocity = direccion * (C.DashDistancia / C.DashTiempo)
				+ Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			RunService.Heartbeat:Wait()
		end
	end)
	return true
end

local function pedir(pedido: string, variante: string?)
	local hecho = if pedido == "Golpe" then golpear(variante) else dash()
	if not hecho then
		cola = { pedido = pedido, variante = variante, cuando = os.clock() }
	end
end

local function bloquear()
	if aturdido() or bloqueando then
		return
	end
	bloqueando = true
	remoto:FireServer("BloqueoInicio")
	if raiz then
		EfectosGolpe.bloqueo(raiz, colorDe(personaje), false)
	end
	local pista = tocar("BloqueoInicio")
	if pista then
		pista.Stopped:Once(function()
			if bloqueando and accion == pista then
				tocar("Bloqueo")
			end
		end)
	end
end

local function soltarBloqueo()
	if bloqueando then
		bloqueando = false
		remoto:FireServer("BloqueoFin")
		if accion then
			accion:Stop(0.15)
			accion = nil
		end
	end
end

UserInputService.InputBegan:Connect(function(entrada, usado)
	if usado or jugador:GetAttribute("MenuAbierto") == true then
		return
	end
	if entrada.UserInputType == Enum.UserInputType.MouseButton1 then
		pedir("Golpe")
	elseif entrada.UserInputType == Enum.UserInputType.MouseButton2 then
		pedir("Golpe", "Fuerte")
	elseif entrada.KeyCode == K.E then
		pedir("Golpe", "Arriba")
	elseif entrada.KeyCode == K.Q then
		pedir("Dash")
	elseif entrada.KeyCode == K.F then
		bloquear()
	end
end)

UserInputService.InputEnded:Connect(function(entrada)
	if entrada.KeyCode == K.F then
		soltarBloqueo()
	end
end)

-- Cola de teclas: lo apretado un poco antes de tiempo sale apenas se puede.
RunService.Heartbeat:Connect(function()
	local c = cola
	if c then
		local vencida = os.clock() - c.cuando > C.ColaTeclas
		local salio = not vencida and (if c.pedido == "Golpe" then golpear(c.variante) else dash())
		if vencida or salio then
			cola = nil
		end
	end
end)

remoto.OnClientEvent:Connect(function(tipo: string, a: any, b: any, _c: any, d: any)
	if tipo == "Ataca" then
		if a ~= personaje then
			arco(a, b, _c == true)
		end
	elseif tipo == "Golpeado" then
		local fuerte = _c == true
		destello(a, Color3.new(1, 1, 1))
		local color = colorDe(d)
		impacto(a, fuerte, color, Niveles.tamano(d))
		numero(a, tostring(math.round(b)), if fuerte then color else Color3.fromRGB(255, 225, 120))
		if d == personaje then
			contar(b)
			marcarRival(a)
			sacudir(if fuerte then C.SacudidaFuerte else C.Sacudida)
			CamaraCombate.zoom(if fuerte then -6 else -2.5)
			if fuerte then
				CamaraCombate.destelloImpacto(false)
			end
			if accion and accion.IsPlaying then
				frenar(accion, C.VelocidadGolpes, C.HitStop)
			end
		elseif a == personaje then
			sacudir(C.SacudidaFuerte)
			CamaraCombate.zoom(-4)
			if accion then
				accion:Stop(0.03)
			end
			accion = if fuerte then pistas.GolpeFuerte else pistas.GolpeLiviano
			accion:Play(0.03)
		end
		sonar(a, if fuerte then "GolpeFuerte" else "Golpe") -- SONIDO: golpe conecta
	elseif tipo == "GuardiaRota" then
		destello(a, Color3.fromRGB(255, 70, 70))
		numero(a, "¡GUARDIA ROTA!", Color3.fromRGB(255, 95, 95))
		local ra = a:FindFirstChild("HumanoidRootPart")
		if ra and ra:IsA("BasePart") then
			EfectosGolpe.rupturaGuardia(ra.Position, colorDe(_c))
		end
		if _c == personaje or a == personaje then
			CamaraCombate.sacudir(C.SacudidaFuerte * 1.2)
			CamaraCombate.zoom(-8)
			CamaraCombate.destelloImpacto(true)
			if _c == personaje then
				contar(b)
				marcarRival(a)
			end
		end
		sonar(a, "GolpeFuerte")
	elseif tipo == "Bloqueado" then
		destello(a, Color3.fromRGB(120, 170, 255))
		numero(a, tostring(math.round(b)), Color3.fromRGB(150, 190, 255))
		local ra = a:FindFirstChild("HumanoidRootPart")
		if ra and ra:IsA("BasePart") then
			EfectosGolpe.bloqueo(ra, Color3.fromRGB(120, 185, 255), true)
		end
		sonar(a, "Bloqueo") -- SONIDO: bloqueo
	elseif tipo == "Parry" then
		local azul = Color3.fromRGB(63, 224, 240)
		destello(a, azul)
		numero(a, "¡PARRY!", azul)
		local ra = a:FindFirstChild("HumanoidRootPart")
		if ra and ra:IsA("BasePart") then
			EfectosGolpe.parry(ra.Position, azul)
		end
		if a == personaje or b == personaje then
			CamaraCombate.sacudir(C.SacudidaFuerte * 1.15)
			CamaraCombate.zoom(-9)
			CamaraCombate.destelloImpacto(true)
		end
		if a == personaje then
			tocar("Parry")
			local pista = accion
			if pista then
				frenar(pista, 1, C.HitStopParry)
			end
		end
		-- SONIDO: parry, propio y no metálico
	elseif tipo == "Aviso" then
		destello(a, Color3.fromRGB(255, 42, 42))
		EfectosGolpe.aviso(a)
	elseif tipo == "Empuje" then
		local r = raiz
		if r then
			r.AssemblyLinearVelocity = a
		end
	end
end)

-- Botones e indicadores táctiles / PC abajo a la derecha (sobre H Controles).
local tactil = UserInputService.TouchEnabled
local tamBtn = if tactil then 70 else 60
local controles = Tema.grupo(
	gui,
	Vector2.new(1, 1),
	UDim2.new(1, -Config.Hud.Margen, 1, -86),
	Vector2.new(tamBtn * 4 + 42, tamBtn + 30)
)
local imgsControl = Config.Hud.Imagenes.Controles

local function crearAccion(
	orden: number,
	teclaTexto: string,
	etiqueta: string,
	imagenId: string
): (TextButton, UIStroke, ImageLabel?)
	local x = (orden - 1) * (tamBtn + 12)
	local btn = Instance.new("TextButton")
	btn.Position = UDim2.fromOffset(x, 0)
	btn.Size = UDim2.fromOffset(tamBtn, tamBtn)
	btn.BackgroundColor3 = Tema.Fondo
	btn.BackgroundTransparency = if tactil then 0.2 else 0.35
	btn.Text = if imagenId == "" then teclaTexto else ""
	btn.TextColor3 = Tema.Hueso
	btn.FontFace = Tema.Letra
	btn.TextSize = if tactil then 18 else 14
	btn.AutoButtonColor = tactil
	btn.Parent = controles

	local borde = Instance.new("UIStroke")
	borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borde.Color = Tema.Hueso
	borde.Transparency = if tactil then 0.3 else 0.55
	borde.Parent = btn

	local ico: ImageLabel? = nil
	if imagenId ~= "" then
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Size = UDim2.fromOffset(math.round(tamBtn * 0.66), math.round(tamBtn * 0.66))
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = imagenId
		img.ImageColor3 = Tema.Hueso
		img.Parent = btn
		ico = img
	end

	local pie = Tema.texto(controles, if tactil or imagenId == "" then etiqueta else teclaTexto, {
		tam = 13,
		letra = Tema.LetraFina,
		transparencia = 0.25,
		alineado = Enum.TextXAlignment.Center,
	})
	pie.AutomaticSize = Enum.AutomaticSize.None
	pie.Position = UDim2.fromOffset(x, tamBtn + 5)
	pie.Size = UDim2.fromOffset(tamBtn, 18)
	return btn, borde, ico
end

local btnAtaque = crearAccion(1, "LMB", "GOLPE", imgsControl.Ataque)
local btnRompe = crearAccion(2, "RMB", "ROMPE", imgsControl.Rompeguardia)
local btnDash, _, icoDash = crearAccion(3, "Q", "DASH", imgsControl.Dash)
local btnBloqueo, bordeBloqueo, icoBloqueo = crearAccion(4, "F", "BLOQ", imgsControl.Bloqueo)

btnAtaque.Activated:Connect(function()
	pedir("Golpe")
end)
btnRompe.Activated:Connect(function()
	pedir("Golpe", "Fuerte")
end)
btnDash.Activated:Connect(function()
	pedir("Dash")
end)
btnBloqueo.InputBegan:Connect(function(entrada)
	if
		entrada.UserInputType == Enum.UserInputType.Touch
		or entrada.UserInputType == Enum.UserInputType.MouseButton1
	then
		bloquear()
	end
end)
btnBloqueo.InputEnded:Connect(function(entrada)
	if
		entrada.UserInputType == Enum.UserInputType.Touch
		or entrada.UserInputType == Enum.UserInputType.MouseButton1
	then
		soltarBloqueo()
	end
end)

-- Vida, energía y nivel están en client/Estado.client.luau.
gui.Parent = jugador:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
	local dashEnRecarga = os.clock() < dashListo
	local transparenciaDash = if dashEnRecarga then 0.68 else 0
	if icoDash then
		icoDash.ImageTransparency = transparenciaDash
	else
		btnDash.TextTransparency = transparenciaDash
	end
	local colorLinaje = Tema.color(jugador:GetAttribute("Linaje"))
	bordeBloqueo.Color = if bloqueando then colorLinaje else Tema.Hueso
	bordeBloqueo.Transparency = if bloqueando then 0.05 else (if tactil then 0.35 else 0.65)
	if icoBloqueo then
		icoBloqueo.ImageColor3 = if bloqueando then colorLinaje else Tema.Hueso
	end

	if contador.Visible and os.clock() > contadorHasta then
		contador.Visible = false
		golpes, acumulado = 0, 0
	end
	local o = objetivo
	local h = o and o:FindFirstChildOfClass("Humanoid")
	if rival.Visible and (not (o and h and o.Parent) or os.clock() > rivalHasta) then
		rival.Visible = false
		objetivo = nil
	elseif h then
		vidaRival.Size = UDim2.fromScale(math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1), 1)
	end
end)

jugador.CharacterAdded:Connect(cargar)
if jugador.Character then
	cargar(jugador.Character)
end
