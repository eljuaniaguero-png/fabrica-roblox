--!strict
-- Feedback en el agua alrededor de la boya propia (solo lo ve este jugador, nada se replica):
--   Lanzado:   chapuzón (aro blanco + gotas) donde cae la boya.
--   Esperando: "mordisquitos": aros chiquitos cada tanto, para que la espera tenga tensión.
--   Pico:      aro dorado grande, gotas y un "¡!" que salta arriba de la boya.
--   Ritmo:     un aro por pulso del pez, desde la cuenta regresiva. El tiempo fuerte (cada 4)
--              abre más grande y la primera nota sale dorada: el agua marca el compás.
--   Resultado: si se escapó, un aro azul que se apaga (el salto del pez lo hace Captura.client).
-- Los aros son un SurfaceGui con UIStroke redondo sobre una placa invisible: se tweenea la UI,
-- no la física, y el borde queda grueso y plano como el resto del estilo toon.
-- El tempo sale de los mismos datos del "Pico" que usa Animaciones.client (Bpm, BpmFinal, Cuenta).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Estilo = require(Shared:WaitForChild("Estilo"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")
local UI = Estilo.UI

local jugador = Players.LocalPlayer

local AGUA_Y = 0.05 -- apenas arriba de la superficie (y = 0, ver Mundo.luau)
local PPS = 20 -- píxeles por stud de los aros: el grosor del borde se da en studs * PPS
-- radio final, grosor (studs) y duración de cada tipo de aro. Para bajarle intensidad en celular, acá.
local AROS = {
	Chapuzon = { Radio = 3.5, Grosor = 0.3, Duracion = 0.55, Color = Color3.new(1, 1, 1) },
	Mordisco = { Radio = 1.4, Grosor = 0.15, Duracion = 0.45, Color = Color3.new(1, 1, 1) },
	Pico = { Radio = 5.5, Grosor = 0.45, Duracion = 0.6, Color = UI.Perfecto },
	Pulso = { Radio = 2.4, Grosor = 0.2, Duracion = 0.4, Color = Color3.new(1, 1, 1) },
	Fuerte = { Radio = 3.6, Grosor = 0.3, Duracion = 0.5, Color = UI.Bien },
	PrimeraNota = { Radio = 4.5, Grosor = 0.4, Duracion = 0.55, Color = UI.Perfecto },
	Escapo = { Radio = 3, Grosor = 0.25, Duracion = 0.7, Color = UI.Bien },
	-- con racha (Config.RachaLargo o más) el agua se pone dorada: el premio se ve sin mirar el HUD
	PulsoRacha = { Radio = 2.8, Grosor = 0.25, Duracion = 0.4, Color = UI.Perfecto },
	FuerteRacha = { Radio = 4.2, Grosor = 0.35, Duracion = 0.5, Color = UI.Perfecto },
	EntraRacha = { Radio = 6, Grosor = 0.5, Duracion = 0.6, Color = UI.Perfecto },
}
type TipoAro = typeof(AROS.Chapuzon)
local MORDISCO_CADA = NumberRange.new(1.1, 2.4) -- segundos entre mordisquitos
local PULSOS_POR_COMPAS = 4

local azar = Random.new()

local carpeta = Instance.new("Folder")
carpeta.Name = "JugoBoyaLocal"
carpeta.Parent = Workspace

-- aros y gotas en vuelo: cada uno se borra solo al terminar y sale de este set (no es una
-- Limpieza porque esa lista crecería toda la sesión con referencias a cosas ya borradas)
local vivos: { [Instance]: boolean } = {}
local pesca = Limpieza.nueva() -- lo que dura una pesca: loop por frame y el "¡!"

local boya: BasePart? = nil
local posBoya: Vector3? = nil

---------------------------------------------------------------- piezas

local function efimero(obj: Instance)
	vivos[obj] = true
	obj.Destroying:Once(function()
		vivos[obj] = nil
	end)
end

local function tween(obj: Instance, t: number, estilo: Enum.EasingStyle, props: { [string]: any }): Tween
	local tw = TweenService:Create(obj, TweenInfo.new(t, estilo, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function aro(centro: Vector3, tipo: TipoAro)
	local diametro = tipo.Radio * 2
	local placa = Instance.new("Part")
	placa.Name = "Aro"
	placa.Size = Vector3.new(diametro, 0.05, diametro)
	placa.CFrame = CFrame.new(centro.X, AGUA_Y, centro.Z)
	placa.Transparency = 1
	placa.Anchored = true
	placa.CanCollide = false
	placa.CanQuery = false
	placa.CanTouch = false
	placa.CastShadow = false

	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Top
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	sg.PixelsPerStud = PPS
	sg.LightInfluence = 0
	sg.Parent = placa

	local circulo = Instance.new("Frame")
	circulo.AnchorPoint = Vector2.new(0.5, 0.5)
	circulo.Position = UDim2.fromScale(0.5, 0.5)
	circulo.Size = UDim2.fromScale(0.12, 0.12)
	circulo.BackgroundTransparency = 1
	circulo.Parent = sg
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(1, 0)
	esquina.Parent = circulo
	local borde = Instance.new("UIStroke")
	borde.Color = tipo.Color
	borde.Thickness = tipo.Grosor * PPS
	borde.Parent = circulo

	placa.Parent = carpeta
	efimero(placa)
	-- el aro se abre rápido y frena (Cubic Out); el borde se apaga y se afina un poco más tarde
	tween(circulo, tipo.Duracion, Enum.EasingStyle.Cubic, { Size = UDim2.fromScale(1, 1) })
	tween(borde, tipo.Duracion, Enum.EasingStyle.Quad, { Transparency = 1, Thickness = tipo.Grosor * PPS * 0.4 }).Completed:Once(
		function()
			placa:Destroy()
		end
	)
end

local function gotas(centro: Vector3, cantidad: number, velocidad: number)
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = Vector3.new(centro.X, AGUA_Y + 0.2, centro.Z)
	ancla.Parent = Workspace.Terrain
	local p = Instance.new("ParticleEmitter")
	p.Color = ColorSequence.new(Estilo.Mundo.Ventana, Estilo.Mundo.Agua)
	p.LightEmission = 0.3
	p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0) })
	p.Lifetime = NumberRange.new(0.35, 0.6)
	p.Speed = NumberRange.new(velocidad * 0.6, velocidad)
	p.SpreadAngle = Vector2.new(55, 55)
	p.Acceleration = Vector3.new(0, -40, 0)
	p.EmissionDirection = Enum.NormalId.Top
	p.Rate = 0
	p.Parent = ancla
	p:Emit(cantidad)
	efimero(ancla)
	task.delay(0.8, function() -- lo que tarda en caer la última gota (Lifetime máx + margen)
		if ancla.Parent then
			ancla:Destroy()
		end
	end)
end

-- "¡!" que salta arriba de la boya cuando pica y late en cada pulso de la cuenta.
local function exclamacion(centro: Vector3): UIScale
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = Vector3.new(centro.X, AGUA_Y, centro.Z)
	ancla.Parent = Workspace.Terrain
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(3, 3)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = ancla
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = UI.Fuente
	t.TextScaled = true
	t.TextColor3 = UI.Perfecto
	t.Text = "¡!"
	Estilo.bordeTexto(t)
	t.Parent = bb
	local escala = Instance.new("UIScale")
	escala.Scale = 0
	escala.Parent = t
	pesca:dar(ancla)
	tween(escala, 0.3, Enum.EasingStyle.Back, { Scale = 1 })
	return escala
end

---------------------------------------------------------------- loops por pesca

-- La racha la publica Pesca.client en el atributo "RachaRitmo" (0 al cerrar el ritmo).
local function enRachaAhora(): boolean
	local r = jugador:GetAttribute("RachaRitmo")
	return typeof(r) == "number" and r >= Config.RachaLargo
end

local function centro(): Vector3?
	local b = boya
	if b and b.Parent then
		posBoya = b.Position -- la boya se hunde al picar: seguirla mientras exista
	end
	return posBoya
end

local function empezarMordiscos()
	local proximo = os.clock() + azar:NextNumber(MORDISCO_CADA.Min, MORDISCO_CADA.Max)
	pesca:dar(RunService.RenderStepped:Connect(function()
		local ahora = os.clock()
		if ahora < proximo then
			return
		end
		proximo = ahora + azar:NextNumber(MORDISCO_CADA.Min, MORDISCO_CADA.Max)
		local c = centro()
		if c then
			-- un poco corrido: es el pez dando vueltas, no la boya
			aro(c + Vector3.new(azar:NextNumber(-0.8, 0.8), 0, azar:NextNumber(-0.8, 0.8)), AROS.Mordisco)
		end
	end))
end

-- Pulsos desde la cuenta regresiva hasta el Resultado. origen = os.clock() de la primera nota.
local function empezarPulsos(datos: any)
	if typeof(datos) ~= "table" or typeof(datos.Bpm) ~= "number" or typeof(datos.Cuenta) ~= "number" then
		return -- servidor viejo: queda solo el aro del pico
	end
	local origen = os.clock() + datos.Cuenta
	local bpm: number = datos.Bpm
	local bpmFinal: number? = if typeof(datos.BpmFinal) == "number" then datos.BpmFinal else nil
	local cambio: number? = nil -- BpmFinal arranca en la nota de la mitad (igual que Animaciones.client)
	if bpmFinal and typeof(datos.Tiempos) == "table" and #datos.Tiempos > 0 then
		cambio = datos.Tiempos[math.ceil(#datos.Tiempos / 2)]
	end

	local function pulsoEn(t: number): (number, number) -- (tramo, índice del pulso)
		if bpmFinal and cambio and t >= origen + cambio then
			return 2, math.floor((t - origen - cambio) / (60 / bpmFinal) + 1e-6)
		end
		return 1, math.floor((t - origen) / (60 / bpm) + 1e-6)
	end

	local escala = exclamacion(centro() or Vector3.zero)
	local ultimoTramo, ultimo = pulsoEn(os.clock())
	local exclamacionViva = true
	-- si el Resultado no llega nunca, que el agua no siga latiendo para siempre (mismo margen que el servidor)
	local duracion: number = if typeof(datos.Duracion) == "number" then datos.Duracion else 10
	local tope = origen + duracion + 6

	pesca:dar(RunService.RenderStepped:Connect(function()
		local ahora = os.clock()
		if ahora > tope then
			pesca:limpiar()
			return
		end
		local tramo, i = pulsoEn(ahora)
		if tramo == ultimoTramo and i == ultimo then
			return
		end
		ultimoTramo, ultimo = tramo, i
		local c = centro()
		if not c then
			return
		end
		local enRacha = enRachaAhora()
		if tramo == 1 and i == 0 then
			aro(c, AROS.PrimeraNota)
		elseif i % PULSOS_POR_COMPAS == 0 then
			aro(c, if enRacha then AROS.FuerteRacha else AROS.Fuerte)
		else
			aro(c, if enRacha then AROS.PulsoRacha else AROS.Pulso)
		end
		if exclamacionViva then
			if ahora >= origen then
				-- arrancó el ritmo: el "¡!" se va para no tapar la boya
				exclamacionViva = false
				tween(escala, 0.2, Enum.EasingStyle.Quad, { Scale = 0 })
			else
				escala.Scale = 1.3 -- late con la cuenta: el jugador agarra el tempo antes de la primera nota
				tween(escala, 0.18, Enum.EasingStyle.Back, { Scale = 1 })
			end
		end
	end))
end

local function terminarPesca()
	pesca:limpiar()
end

---------------------------------------------------------------- servidor

local function boyaDe(datos: any): BasePart?
	local b = if typeof(datos) == "table" then datos.Boya else nil
	if typeof(b) == "Instance" and b:IsA("BasePart") then
		return b
	end
	-- con streaming la referencia puede llegar vacía: buscarla por nombre
	local carpetaBoyas = Workspace:FindFirstChild("Boyas")
	local porNombre = carpetaBoyas and carpetaBoyas:FindFirstChild("Boya_" .. jugador.UserId)
	return if porNombre and porNombre:IsA("BasePart") then porNombre else nil
end

Remotos:WaitForChild("Pesca").OnClientEvent:Connect(function(tipo: string, datos: any)
	if tipo == "Lanzado" then
		terminarPesca()
		boya = boyaDe(datos)
		posBoya = nil
		local c = centro()
		if c then
			aro(c, AROS.Chapuzon)
			gotas(c, 12, 10)
		end
		empezarMordiscos()
	elseif tipo == "Pico" then
		pesca:limpiar() -- cortan los mordisquitos
		local c = centro()
		if c then
			aro(c, AROS.Pico)
			gotas(c, 24, 15)
		end
		empezarPulsos(datos)
	elseif tipo == "Resultado" then
		local c = posBoya -- la boya ya no existe: el servidor la borra antes del Resultado
		local escapo = not (typeof(datos) == "table" and datos.Sacado)
		terminarPesca()
		if escapo and c then
			aro(c, AROS.Escapo)
			gotas(c, 6, 6)
		end
		boya, posBoya = nil, nil
	elseif tipo == "Cancelado" then
		terminarPesca()
		boya, posBoya = nil, nil
	end
end)

-- Entró en racha (cruza el umbral, no cada acierto): un estallido dorado en el agua.
local rachaPrevia = 0
jugador:GetAttributeChangedSignal("RachaRitmo"):Connect(function()
	local r = jugador:GetAttribute("RachaRitmo")
	local n = if typeof(r) == "number" then r else 0
	if n >= Config.RachaLargo and rachaPrevia < Config.RachaLargo then
		local c = centro()
		if c then
			aro(c, AROS.EntraRacha)
			gotas(c, 18, 13)
		end
	end
	rachaPrevia = n
end)

-- murió o reapareció en el medio: no dejar loops ni el "¡!" de la vida anterior
jugador.CharacterRemoving:Connect(function()
	terminarPesca()
	for obj in vivos do
		obj:Destroy()
	end
	boya, posBoya = nil, nil
end)
