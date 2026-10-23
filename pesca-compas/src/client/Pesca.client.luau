--!strict
-- Lado del jugador del loop: mantener y soltar para lanzar, minijuego de ritmo, calibración y
-- revelación del pez. Se toca en cualquier lado de la pantalla, con clic, espacio o botón A.
-- El cliente juzga en vivo solo para dar feedback; el resultado real lo calcula el servidor
-- con la misma regla (Ritmo.clasificar) a partir de la lista de toques que se le manda.
-- UI con el estilo "Toon de playa" (shared/Estilo.luau); las imágenes finales salen de Prompts del HUD.

local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estilo = require(ReplicatedStorage.Shared:WaitForChild("Estilo"))
local UI = Estilo.UI
local Ritmo = require(ReplicatedStorage.Shared:WaitForChild("Ritmo"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local jugador = Players.LocalPlayer

type Fase = "Libre" | "Cargando" | "Lanzando" | "Esperando" | "Ritmo" | "Juzgando" | "Calibrando" | "Revelacion"
local fase: Fase = "Libre"
local desfase = 0
local calibrado: boolean? = nil -- nil = todavía no llegó el estado del servidor

---------------------------------------------------------------- UI

local gui = Instance.new("ScreenGui")
gui.Name = "PescaGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 5
gui.Parent = jugador:WaitForChild("PlayerGui")

local function caja(padre: Instance, tam: UDim2, pos: UDim2, color: Color3, transp: number?): Frame
	local f = Instance.new("Frame")
	f.Size = tam
	f.Position = pos
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transp or 0
	f.BorderSizePixel = 0
	f.Parent = padre
	return f
end

local function redondear(f: GuiObject, radio: UDim?)
	local c = Instance.new("UICorner")
	c.CornerRadius = radio or UDim.new(0, 12)
	c.Parent = f
end

local function texto(padre: Instance, tam: UDim2, pos: UDim2, contenido: string): TextLabel
	local t = Instance.new("TextLabel")
	t.Size = tam
	t.Position = pos
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.BackgroundTransparency = 1
	t.Font = UI.Fuente
	t.TextScaled = true
	t.TextColor3 = UI.Texto
	t.Text = contenido
	Estilo.bordeTexto(t)
	t.Parent = padre
	return t
end

-- pista para lanzar y barra de carga
local pista = texto(gui, UDim2.fromScale(0.6, 0.05), UDim2.fromScale(0.5, 0.78), "")
local barraCarga = caja(gui, UDim2.fromScale(0.25, 0.025), UDim2.fromScale(0.5, 0.72), UI.PanelOscuro)
barraCarga.Visible = false
redondear(barraCarga)
Estilo.borde(barraCarga)
local rellenoCarga = caja(barraCarga, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0.5), UI.Carga)
rellenoCarga.AnchorPoint = Vector2.new(0, 0.5)
redondear(rellenoCarga)

-- minijuego: carril con notas que bajan hacia el aro, barra de tensión al costado
local panelRitmo = caja(gui, UDim2.fromScale(0.16, 0.62), UDim2.fromScale(0.5, 0.45), UI.PanelOscuro, 0.15)
panelRitmo.Visible = false
redondear(panelRitmo, UDim.new(0, UI.Esquina))
Estilo.borde(panelRitmo)
local ARO_Y = 0.85 -- altura del aro dentro del carril (0 arriba, 1 abajo)
local ANTICIPO = 1.6 -- segundos que tarda una nota en bajar del borde de arriba al aro
local aro = caja(panelRitmo, UDim2.fromScale(0.7, 0.7), UDim2.fromScale(0.5, ARO_Y), Color3.new(1, 1, 1), 1)
aro.SizeConstraint = Enum.SizeConstraint.RelativeXX
redondear(aro, UDim.new(1, 0))
local bordeAro = Instance.new("UIStroke")
bordeAro.Thickness = 5
bordeAro.Color = Color3.new(1, 1, 1)
bordeAro.Parent = aro

local barraTension = caja(gui, UDim2.fromScale(0.025, 0.5), UDim2.fromScale(0.62, 0.45), UI.PanelOscuro)
barraTension.Visible = false
redondear(barraTension, UDim.new(0, 8))
Estilo.borde(barraTension)
local rellenoTension = caja(barraTension, UDim2.fromScale(1, 0.5), UDim2.fromScale(0.5, 1), UI.TensionBien)
rellenoTension.AnchorPoint = Vector2.new(0.5, 1)
redondear(rellenoTension, UDim.new(0, 8))
local marca50 = caja(barraTension, UDim2.new(1.6, 0, 0, 3), UDim2.fromScale(0.5, 0.5), Color3.new(1, 1, 1))
marca50.ZIndex = 3

local cartel = texto(gui, UDim2.fromScale(0.4, 0.08), UDim2.fromScale(0.5, 0.1), "")
local calificacion = texto(gui, UDim2.fromScale(0.25, 0.06), UDim2.fromScale(0.5, 0.82), "")
local rachaTexto = texto(gui, UDim2.fromScale(0.15, 0.04), UDim2.fromScale(0.62, 0.17), "")

-- revelación del pez
local tarjeta = caja(gui, UDim2.fromScale(0.42, 0.42), UDim2.fromScale(0.5, 0.45), UI.PanelOscuro)
tarjeta.Visible = false
redondear(tarjeta, UDim.new(0, 20))
local bordeTarjeta = Instance.new("UIStroke") -- toma el color de la rareza
bordeTarjeta.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bordeTarjeta.Thickness = 8
bordeTarjeta.Parent = tarjeta
local tRareza = texto(tarjeta, UDim2.fromScale(0.9, 0.16), UDim2.fromScale(0.5, 0.14), "")
local tNombre = texto(tarjeta, UDim2.fromScale(0.9, 0.2), UDim2.fromScale(0.5, 0.36), "")
local tAfinado = texto(tarjeta, UDim2.fromScale(0.6, 0.12), UDim2.fromScale(0.5, 0.54), "")
local tDetalle = texto(tarjeta, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.5, 0.7), "")
local tPrecio = texto(tarjeta, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.5, 0.86), "")

local botonCalibrar = Instance.new("TextButton")
botonCalibrar.Size = UDim2.fromScale(0.12, 0.05)
botonCalibrar.Position = UDim2.fromScale(0.99, 0.62)
botonCalibrar.AnchorPoint = Vector2.new(1, 0.5)
botonCalibrar.BackgroundColor3 = UI.BotonNeutro
botonCalibrar.Font = UI.Fuente
botonCalibrar.TextScaled = true
botonCalibrar.TextColor3 = UI.Texto
botonCalibrar.Text = "Calibrar ritmo"
botonCalibrar.Parent = gui
redondear(botonCalibrar)
Estilo.borde(botonCalibrar) -- un solo UIStroke por objeto: Roblox dibuja uno solo

---------------------------------------------------------------- sonido

local function sonar(id: string, velocidad: number?, volumen: number?)
	if id == "" then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.PlaybackSpeed = velocidad or 1
	s.Volume = volumen or 0.6
	s.Parent = SoundService
	s.Ended:Once(function()
		s:Destroy()
	end)
	s:Play()
	task.delay(4, function()
		if s.Parent then
			s:Destroy()
		end
	end)
end

-- sin precargar, los primeros golpes de la calibración no suenan y el desfase sale mal
local function precargarNota()
	pcall(function()
		ContentProvider:PreloadAsync({ Config.SonidoNotaId })
	end)
end
task.spawn(precargarNota)

-- un acierto suena como la nota siguiente de la melodía (en la escala, nunca un "clic")
local function sonarNota(semitonos: number)
	sonar(Config.SonidoNotaId, 2 ^ (semitonos / 12), 0.7)
end

local function popup(etiqueta: TextLabel, contenido: string, color: Color3)
	etiqueta.Text = contenido
	etiqueta.TextColor3 = color
	etiqueta.Size = UDim2.fromScale(0.32, 0.08)
	TweenService:Create(etiqueta, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.fromScale(0.25, 0.06) }):Play()
end

---------------------------------------------------------------- cerca del muelle

local function cercaDePunto(): boolean
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return false
	end
	for _, punto in CollectionService:GetTagged("PuntoPesca") do
		if punto:IsA("BasePart") and (punto.Position - raiz.Position).Magnitude <= Config.DistanciaPesca then
			return true
		end
	end
	return false
end

---------------------------------------------------------------- minijuego

type Partida = {
	Token: number,
	Patron: Ritmo.Patron,
	T0: number, -- os.clock() local de la primera nota
	Perfecto: number,
	Bien: number,
	Tension: number,
	Usadas: { [number]: boolean },
	Falladas: { [number]: boolean },
	Toques: { number },
	UltimoToque: number,
	Racha: number,
	Notas: { Frame },
}
local partida: Partida? = nil

-- Durante el ritmo el personaje queda quieto: el espacio toca notas y no tiene que saltar ni
-- tirarlo del muelle, y caminar no tiene que alejarlo del punto de pesca.
local congelado: { Humanoide: Humanoid, Velocidad: number }? = nil

local function congelar(activo: boolean)
	if activo and not congelado then
		local personaje = jugador.Character
		local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
		if humanoide then
			congelado = { Humanoide = humanoide, Velocidad = humanoide.WalkSpeed }
			humanoide.WalkSpeed = 0
			humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
	elseif not activo and congelado then
		local c = congelado
		congelado = nil
		if c.Humanoide.Parent then -- si murió y reapareció, el humanoide nuevo ya viene normal
			c.Humanoide.WalkSpeed = c.Velocidad
			c.Humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end
end

local function tiempoRitmo(p: Partida): number
	return os.clock() - p.T0
end

local function moverTension(p: Partida, calif: Ritmo.Calificacion)
	p.Tension = math.clamp(p.Tension + Ritmo.delta(calif, #p.Patron.Tiempos), 0, 1)
	local color = if p.Tension > 0.5 then UI.TensionBien else UI.TensionMal
	TweenService:Create(rellenoTension, TweenInfo.new(0.1), {
		Size = UDim2.fromScale(1, p.Tension),
		BackgroundColor3 = color,
	}):Play()
end

local function anotarRacha(p: Partida, acierto: boolean)
	p.Racha = if acierto then p.Racha + 1 else 0
	if p.Racha >= Config.RachaLargo then
		rachaTexto.Text = ("¡RACHA x%d!"):format(p.Racha)
		bordeAro.Color = UI.Perfecto -- la caña brilla
	else
		rachaTexto.Text = if p.Racha >= 2 then ("x%d"):format(p.Racha) else ""
		bordeAro.Color = Color3.new(1, 1, 1)
	end
end

local terminarRitmo: (p: Partida) -> () -- se define más abajo
local lineaCortada = false

-- La barra llegó a 0: se cortó la línea y se termina ya (el servidor aplica la misma regla).
-- Antes el minijuego seguía y la barra podía terminar arriba de la raya con el pez perdido.
local function cortoLinea(p: Partida): boolean
	if p.Tension > 1e-9 then
		return false
	end
	lineaCortada = true
	terminarRitmo(p)
	cartel.Text = "¡Se cortó la línea!"
	cartel.TextColor3 = UI.Error
	return true
end

local function tocarRitmo(p: Partida)
	local t = tiempoRitmo(p) - desfase -- corregido por la calibración del dispositivo
	if t < -p.Bien or t - p.UltimoToque < Config.ToqueMinimo then
		return -- nervios durante la cuenta, o un doble toque del mismo dedo: no cuenta
	end
	p.UltimoToque = t
	table.insert(p.Toques, t)
	local i, calif = Ritmo.clasificar(p.Patron, p.Usadas, t, p.Perfecto, p.Bien)
	if i then
		p.Usadas[i] = true
		p.Notas[i].Visible = false
		sonarNota(p.Patron.Alturas[i])
		popup(
			calificacion,
			if calif == "Perfecto" then "¡PERFECTO!" else "Bien",
			if calif == "Perfecto" then UI.Perfecto else UI.Bien
		)
	else
		sonar(Config.SonidoErrorId)
		popup(calificacion, "Error", UI.Error)
	end
	moverTension(p, calif)
	anotarRacha(p, calif ~= "Error")
	cortoLinea(p)
end

local function empezarRitmo(datos: any)
	local patron: Ritmo.Patron = { Tiempos = datos.Tiempos, Alturas = datos.Alturas, Duracion = datos.Duracion }
	local p: Partida = {
		Token = datos.Token,
		Patron = patron,
		T0 = os.clock() + datos.Cuenta,
		Perfecto = datos.Perfecto,
		Bien = datos.Bien,
		Tension = datos.Tension,
		Usadas = {},
		Falladas = {},
		Toques = {},
		UltimoToque = -math.huge,
		Racha = 0,
		Notas = {},
	}
	for i = 1, #patron.Tiempos do
		local n = caja(panelRitmo, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, -0.1), UI.Nota)
		n.SizeConstraint = Enum.SizeConstraint.RelativeXX
		redondear(n, UDim.new(1, 0))
		n.ZIndex = 2
		n.Visible = false -- que no se vea un cuadro antes del primer RenderStepped
		p.Notas[i] = n
	end
	partida = p
	fase = "Ritmo"
	lineaCortada = false
	congelar(true)
	sonar(Config.SonidoPicoId)
	cartel.Text = "¡PICÓ!"
	cartel.TextColor3 = UI.Perfecto
	pista.Text = ""
	rachaTexto.Text = ""
	calificacion.Text = ""
	rellenoTension.Size = UDim2.fromScale(1, p.Tension)
	panelRitmo.Visible = true
	barraTension.Visible = true
	task.delay(datos.Cuenta, function()
		if partida == p then
			cartel.Text = ""
		end
	end)
end

local cerrarRitmo: () -> () -- se define más abajo

function terminarRitmo(p: Partida)
	fase = "Juzgando"
	Remotos.Toques:FireServer(p.Token, p.Toques)
	cartel.Text = "..."
	-- si el resultado no llega nunca, no dejar al jugador congelado y sin poder lanzar
	task.delay(8, function()
		if fase == "Juzgando" and partida == p then
			cerrarRitmo()
			fase = "Libre"
		end
	end)
end

local function actualizarRitmo()
	local p = partida
	if not p or fase ~= "Ritmo" then
		return
	end
	local t = tiempoRitmo(p)
	for i, nota in p.Patron.Tiempos do
		local frame = p.Notas[i]
		if not p.Usadas[i] then
			local y = ARO_Y - (nota - t) / ANTICIPO * ARO_Y
			frame.Position = UDim2.fromScale(0.5, y)
			frame.Visible = y > -0.1 and y < 1.05 and not p.Falladas[i]
			-- pasó la ventana sin tocarla: error (mismo momento que usa el servidor)
			if not p.Falladas[i] and t - desfase > nota + p.Bien then
				p.Falladas[i] = true
				frame.Visible = false
				popup(calificacion, "Error", UI.Error)
				moverTension(p, "Error")
				anotarRacha(p, false)
				if cortoLinea(p) then
					return
				end
			end
		end
	end
	if t - desfase > p.Patron.Duracion + p.Bien + 0.1 then
		terminarRitmo(p)
	end
end

function cerrarRitmo()
	local p = partida
	if p then
		for _, nota in p.Notas do
			nota:Destroy()
		end
	end
	partida = nil
	congelar(false)
	panelRitmo.Visible = false
	barraTension.Visible = false
	rachaTexto.Text = ""
	calificacion.Text = ""
	cartel.Text = ""
	bordeAro.Color = Color3.new(1, 1, 1)
end

local function revelar(datos: any)
	cerrarRitmo()
	fase = "Revelacion"
	if datos.Sacado then
		local rareza = Ritmo.rareza(datos.Rareza)
		sonar(Config.SonidoSacadoId)
		bordeTarjeta.Color = rareza.Color
		tRareza.Text = string.upper(datos.Rareza) .. (if datos.Nuevo then "  ·  ¡NUEVO!" else "")
		tRareza.TextColor3 = rareza.Color
		tNombre.Text = datos.Nombre
		tAfinado.Text = if datos.Afinado then "✦ AFINADO ✦" else ""
		tAfinado.TextColor3 = UI.Perfecto
		tDetalle.Text = ("%.2f kg  ·  %d perfectos  ·  %d errores"):format(datos.Peso, datos.Perfectos, datos.Errores)
		tPrecio.Text = ("Vale %d Escamas%s"):format(
			datos.Precio,
			if datos.Bonus > 0 then (" · racha +%d"):format(datos.Bonus) else ""
		)
		if datos.SubioNivel then
			cartel.Text = "¡SUBISTE DE NIVEL!"
			cartel.TextColor3 = UI.XP
		end
	else
		sonar(Config.SonidoEscapoId)
		bordeTarjeta.Color = UI.Error
		tRareza.Text = ""
		tNombre.Text = "¡Se escapó!"
		tAfinado.Text = ""
		tDetalle.Text = ("%d perfectos · %d bien · %d errores"):format(datos.Perfectos, datos.Bien, datos.Errores)
		tPrecio.Text = if lineaCortada
			then "Que la barra no llegue a 0"
			else "Terminá con la barra arriba de la raya"
	end
	tarjeta.Size = UDim2.fromScale(0.3, 0.3)
	tarjeta.Visible = true
	TweenService:Create(tarjeta, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Size = UDim2.fromScale(0.42, 0.42) }):Play()
	task.delay(if datos.Sacado then 2.6 else 1.8, function()
		if fase == "Revelacion" then
			tarjeta.Visible = false
			cartel.Text = ""
			fase = "Libre"
		end
	end)
end

---------------------------------------------------------------- calibración

-- 8 golpes a 100 BPM con sonido y destello. El desfase es la mediana de (toque - golpe):
-- lo que tarda el dispositivo entre que suena y que llega el toque.
local tiemposCalibracion: { number } = {}
local inicioCalibracion = 0

local function calibrar()
	if fase ~= "Libre" then
		return
	end
	fase = "Calibrando"
	congelar(true) -- con espacio tampoco tiene que saltar durante la prueba
	precargarNota() -- ya cargada vuelve al toque
	tiemposCalibracion = {} -- después de precargar: los toques de mientras no cuentan
	pista.Text = ""
	cartel.TextColor3 = Color3.new(1, 1, 1)
	cartel.Text = "Calibración: tocá justo cuando suena (8 golpes)"
	panelRitmo.Visible = true
	local intervalo = 60 / Config.CalibracionBpm
	inicioCalibracion = os.clock() + 1.5
	for i = 0, Config.CalibracionGolpes - 1 do
		task.delay(1.5 + i * intervalo, function()
			sonarNota(Config.Escala[1 + i % 5])
			bordeAro.Color = UI.Perfecto
			task.delay(0.1, function()
				bordeAro.Color = Color3.new(1, 1, 1)
			end)
		end)
	end
	task.delay(1.5 + Config.CalibracionGolpes * intervalo + 0.3, function()
		panelRitmo.Visible = false
		local desvios = {}
		for _, toque in tiemposCalibracion do
			local golpe = math.floor(toque / intervalo + 0.5)
			local d = toque - golpe * intervalo
			if golpe >= 0 and golpe < Config.CalibracionGolpes and math.abs(d) <= Config.DesfaseMax then
				table.insert(desvios, d)
			end
		end
		if #desvios < Config.CalibracionGolpes - 3 then
			cartel.Text = "Faltaron toques, probá de nuevo con el botón Calibrar"
		else
			table.sort(desvios)
			local mediana = desvios[math.ceil(#desvios / 2)]
			desfase = mediana
			Remotos.Calibrar:FireServer(mediana)
			cartel.Text = ("¡Listo! Tu dispositivo tiene %d ms de desfase"):format(math.floor(mediana * 1000 + 0.5))
		end
		task.delay(2.5, function()
			if fase == "Libre" then
				cartel.Text = ""
			end
		end)
		congelar(false)
		fase = "Libre"
	end)
end

botonCalibrar.Activated:Connect(calibrar)

---------------------------------------------------------------- entrada

local inicioCarga = 0
-- En celular, arrastrar el dedo es girar la cámara: si el toque se mueve más que esto, no se
-- lanza. Y solo lanza al soltar el mismo dedo o botón que empezó la carga.
local ARRASTRE_MAX = 30 -- píxeles
local entradaCarga: InputObject? = nil
local posCarga = Vector3.zero

local function mismaEntrada(a: InputObject, b: InputObject): boolean
	if a.UserInputType == Enum.UserInputType.Touch then
		return a == b -- cada dedo usa el mismo InputObject de principio a fin
	end
	return a.UserInputType == b.UserInputType and a.KeyCode == b.KeyCode
end

local function esToque(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.Space
		or input.KeyCode == Enum.KeyCode.ButtonA
end

UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado or not esToque(input) then
		return
	end
	if fase == "Ritmo" and partida then
		tocarRitmo(partida)
	elseif fase == "Calibrando" then
		table.insert(tiemposCalibracion, os.clock() - inicioCalibracion)
	elseif input.KeyCode == Enum.KeyCode.Space then
		return -- el espacio solo toca notas: para lanzar haría saltar al personaje
	elseif fase == "Libre" and calibrado and cercaDePunto() then
		fase = "Cargando"
		inicioCarga = os.clock()
		entradaCarga = input
		posCarga = input.Position
		barraCarga.Visible = true
	elseif fase == "Esperando" then
		entradaCarga = input -- tocar mientras espera recoge la caña (se decide al soltar)
		posCarga = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	local inicio = entradaCarga
	if (fase ~= "Cargando" and fase ~= "Esperando") or not inicio or not mismaEntrada(inicio, input) then
		return
	end
	entradaCarga = nil
	barraCarga.Visible = false
	local arrastro = input.UserInputType == Enum.UserInputType.Touch
		and (input.Position - posCarga).Magnitude > ARRASTRE_MAX
	if fase == "Esperando" then
		if not arrastro then
			-- la fase cambia cuando el servidor contesta: "Cancelado", o "Pico" si ya había picado
			pista.Text = "Recogiendo..."
			Remotos.Cancelar:FireServer()
		end
		return
	end
	if arrastro then
		fase = "Libre" -- estaba girando la cámara, no lanzando
		return
	end
	local carga = math.clamp((os.clock() - inicioCarga) / Config.CargaMax, 0, 1)
	fase = "Lanzando"
	sonar(Config.SonidoLanzarId)
	Remotos.Lanzar:FireServer(carga)
	task.delay(2, function()
		if fase == "Lanzando" then
			fase = "Libre" -- el servidor no lo aceptó (balde lleno, lejos): ya mandó el aviso
		end
	end)
end)

-- si la ventana pierde el foco mientras carga, el "soltó" puede no llegar nunca
UserInputService.WindowFocusReleased:Connect(function()
	entradaCarga = nil
	if fase == "Cargando" then
		fase = "Libre"
		barraCarga.Visible = false
	end
end)

---------------------------------------------------------------- servidor

Remotos.Pesca.OnClientEvent:Connect(function(tipo: string, datos: any)
	if tipo == "Lanzado" then
		fase = "Esperando"
		pista.Text = "Esperá la picada... (tocá para recoger)"
	elseif tipo == "Pico" then
		tarjeta.Visible = false
		cerrarRitmo()
		empezarRitmo(datos)
	elseif tipo == "Resultado" then
		revelar(datos)
	elseif tipo == "Cancelado" then
		fase = "Libre"
	end
end)

Remotos.Estado.OnClientEvent:Connect(function(estado: any)
	desfase = estado.Desfase
	local primeraVez = calibrado == nil
	calibrado = estado.Calibrado
	if primeraVez and not estado.Calibrado then
		task.delay(2, calibrar) -- obligatoria la primera vez: sin esto el celular se siente injusto
	end
end)
Remotos.Estado:FireServer() -- pide el estado por si llegó antes de que este script escuchara

RunService.RenderStepped:Connect(function()
	if fase == "Ritmo" then
		actualizarRitmo()
	elseif fase == "Cargando" then
		local carga = math.clamp((os.clock() - inicioCarga) / Config.CargaMax, 0, 1)
		rellenoCarga.Size = UDim2.fromScale(carga, 1)
	elseif fase == "Libre" then
		-- sin calibrar no se puede lanzar: si la prueba falló, que sepa cómo seguir
		pista.Text = if calibrado == nil
			then ""
			elseif not calibrado then "Tocá «Calibrar ritmo» (a la derecha) para empezar a pescar"
			elseif cercaDePunto() then "Mantené y soltá para lanzar (más tiempo = más lejos)"
			else "Andá a la punta del muelle para pescar"
	elseif fase == "Esperando" and not cercaDePunto() then
		fase = "Libre"
		Remotos.Cancelar:FireServer() -- se fue del muelle: recoge la caña
	end
end)
