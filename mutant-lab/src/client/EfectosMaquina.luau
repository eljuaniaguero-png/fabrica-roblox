--!strict
-- Todo lo que se ve y se escucha en la máquina de fusión (solo en el cliente).
-- Laboratorio > Maquina (armada en Studio):
--   Cuerpo (Model que tiembla) > CapsulaA/B, LiquidoA/B, TuboA/B, Cupula, Luces (Folder), Humo (Folder)
--   PuntoA, PuntoB (dónde va la criatura dentro de cada cápsula), Salida (centro de la cúpula),
--   PuntoCamara (desde dónde se mira la animación), Consola > Prompt
-- Revelacion (ScreenGui) > Cartel > Escala (UIScale), Titulo, Nombre, Gen, Mutante > Arcoiris (UIGradient)
--                        > Flash (Frame blanco de pantalla completa)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local MiLab = require(script.Parent.MiLab)
local Sonidos = require(script.Parent.Sonidos)

local E = Config.Estilo
local M = Config.Maquina

local maquina = MiLab.obtener():WaitForChild("Maquina") :: Model
local cuerpo = maquina:WaitForChild("Cuerpo") :: Model
local salida = maquina:WaitForChild("Salida") :: BasePart
local puntoCamara = maquina:WaitForChild("PuntoCamara") :: BasePart
local luces = (cuerpo:WaitForChild("Luces") :: Folder):GetChildren()
local humo = cuerpo:WaitForChild("Humo") :: Folder

local revelacion =
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Revelacion") :: ScreenGui
local cartel = revelacion:WaitForChild("Cartel") :: Frame
local escalaCartel = cartel:WaitForChild("Escala") :: UIScale
local titulo = cartel:WaitForChild("Titulo") :: TextLabel
local nombre = cartel:WaitForChild("Nombre") :: TextLabel
local gen = cartel:WaitForChild("Gen") :: TextLabel
local etiquetaMutante = cartel:WaitForChild("Mutante") :: TextLabel
local arcoiris = etiquetaMutante:WaitForChild("Arcoiris") :: UIGradient
local flash = revelacion:WaitForChild("Flash") :: Frame

-- Lo que crea la animación vive en una carpeta local (los demás jugadores no lo ven).
local carpeta = Instance.new("Folder")
carpeta.Name = "EfectosMaquina"
carpeta.Parent = workspace

type Capsula = {
	Punto: BasePart,
	Liquido: BasePart,
	Tubo: BasePart,
	ColorTubo: Color3,
	Fondo: Vector3, -- centro de la base del líquido
	AltoLleno: number,
	Diametro: number,
	Mini: Model?,
}

local GIRO_VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- cilindro parado

local function armarCapsula(lado: string): Capsula
	local liquido = cuerpo:WaitForChild("Liquido" .. lado) :: BasePart
	local tubo = cuerpo:WaitForChild("Tubo" .. lado) :: BasePart
	local alto = liquido.Size.X
	local c: Capsula = {
		Punto = maquina:WaitForChild("Punto" .. lado) :: BasePart,
		Liquido = liquido,
		Tubo = tubo,
		ColorTubo = tubo.Color,
		Fondo = liquido.Position - Vector3.new(0, alto / 2, 0),
		AltoLleno = alto,
		Diametro = liquido.Size.Y,
		Mini = nil,
	}
	-- Arranca vacía.
	liquido.Size = Vector3.new(0.05, c.Diametro, c.Diametro)
	liquido.CFrame = CFrame.new(c.Fondo) * GIRO_VERTICAL
	liquido.Transparency = 1
	return c
end

local capsulas: { [string]: Capsula } = { A = armarCapsula("A"), B = armarCapsula("B") }
local coloresLuces: { [BasePart]: Color3 } = {}
for _, l in luces do
	if l:IsA("BasePart") then
		coloresLuces[l] = l.Color
	end
end
local criaturaSalida: Model? = nil

local Efectos = {}

---------------------------------------------------------------------------
-- Piezas de la animación
---------------------------------------------------------------------------

-- Pone (o saca) una criatura chiquita dentro de una cápsula.
function Efectos.mostrarEnCapsula(lado: string, clave: string?)
	local cap = capsulas[lado]
	if cap.Mini then
		cap.Mini:Destroy()
		cap.Mini = nil
	end
	local c = if clave then Fusion.porClave(clave) else nil
	if c then
		local mini = Generador.crear(c, cap.Punto.CFrame, carpeta)
		mini:ScaleTo(M.EscalaEnCapsula)
		cap.Mini = mini
	end
end

local function llenar(cap: Capsula, color: Color3, nivel: number, tiempo: number)
	local alto = math.max(0.05, cap.AltoLleno * nivel)
	cap.Liquido.Color = color
	TweenService:Create(cap.Liquido, TweenInfo.new(tiempo, Enum.EasingStyle.Quad), {
		Size = Vector3.new(alto, cap.Diametro, cap.Diametro),
		CFrame = CFrame.new(cap.Fondo + Vector3.new(0, alto / 2, 0)) * GIRO_VERTICAL,
		Transparency = if nivel > 0 then 0.35 else 1,
	}):Play()
end

local function tubos(colores: { [string]: Color3 }?)
	for lado, cap in capsulas do
		if colores then
			cap.Tubo.Color = colores[lado]
			cap.Tubo.Material = Enum.Material.Neon
		else
			cap.Tubo.Color = cap.ColorTubo
			cap.Tubo.Material = Enum.Material.SmoothPlastic
		end
	end
end

local function temblar(duracion: number, fuerza: number)
	local original = cuerpo:GetPivot()
	local fin = os.clock() + duracion
	while os.clock() < fin do
		local x = (math.random() - 0.5) * fuerza
		local z = (math.random() - 0.5) * fuerza
		local giro = (math.random() - 0.5) * fuerza * 0.04
		cuerpo:PivotTo(original * CFrame.new(x, 0, z) * CFrame.Angles(0, 0, giro))
		RunService.RenderStepped:Wait()
	end
	cuerpo:PivotTo(original)
end

local PALETA_LUCES = { E.Menta, E.Rosa, E.Amarillo, Color3.fromHex("38C8FF") }

local function parpadear(duracion: number)
	local fin = os.clock() + duracion
	local paso = 0
	while os.clock() < fin do
		paso += 1
		for i, l in luces do
			if l:IsA("BasePart") then
				l.Color = PALETA_LUCES[(i + paso) % #PALETA_LUCES + 1]
			end
		end
		task.wait(0.1)
	end
	for l, color in coloresLuces do
		l.Color = color
	end
end

local function largarHumo(activo: boolean, rafaga: number?)
	for _, d in humo:GetDescendants() do
		if d:IsA("ParticleEmitter") then
			d.Enabled = activo
			if rafaga then
				d:Emit(rafaga)
			end
		end
	end
end

-- Esconde (solo para vos) tu personaje, así no tapa la máquina durante la animación.
local function verPersonaje(visible: boolean)
	local personaje = Players.LocalPlayer.Character
	if not personaje then
		return
	end
	for _, d in personaje:GetDescendants() do
		if d:IsA("BasePart") or d:IsA("Decal") then
			d.LocalTransparencyModifier = if visible then 0 else 1
		end
	end
end

local function enfocar()
	verPersonaje(false)
	local camara = workspace.CurrentCamera
	camara.CameraType = Enum.CameraType.Scriptable
	TweenService
		:Create(camara, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = puntoCamara.CFrame,
		})
		:Play()
end

local function soltar()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	verPersonaje(true)
end

-- La criatura que sale de la cúpula (de frente a la cámara).
local function crearEnSalida(c: Fusion.Criatura, silueta: boolean, mutante: boolean?): Model
	local m = Generador.crear(c, salida.CFrame, nil, mutante)
	if silueta then
		Generador.silueta(m)
	end
	m.Parent = carpeta
	return m
end

local function destello(color: Color3)
	local bola = Instance.new("Part")
	bola.Shape = Enum.PartType.Ball
	bola.Anchored = true
	bola.CanCollide = false
	bola.CanQuery = false
	bola.Material = Enum.Material.Neon
	bola.Color = color
	bola.Size = Vector3.one
	bola.CFrame = salida.CFrame * CFrame.new(0, 3, 0)
	bola.Parent = carpeta
	TweenService
		:Create(bola, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.one * 16,
			Transparency = 1,
		})
		:Play()
	task.delay(0.6, function()
		bola:Destroy()
	end)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 0.15
	TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end

-- Efecto extra de mutante: lluvia de papelitos de colores y un segundo destello dorado.
local function efectoMutante()
	local a = Instance.new("Attachment")
	a.WorldCFrame = salida.CFrame * CFrame.new(0, 4, 0)
	a.Parent = workspace.Terrain
	local p = Instance.new("ParticleEmitter")
	p.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("FF3B30")),
		ColorSequenceKeypoint.new(0.25, E.Amarillo),
		ColorSequenceKeypoint.new(0.5, E.Menta),
		ColorSequenceKeypoint.new(0.75, Color3.fromHex("38C8FF")),
		ColorSequenceKeypoint.new(1, E.Rosa),
	})
	p.LightEmission = 0.4
	p.Size = NumberSequence.new(0.45)
	p.Speed = NumberRange.new(18, 30)
	p.SpreadAngle = Vector2.new(60, 60)
	p.Acceleration = Vector3.new(0, -30, 0)
	p.Lifetime = NumberRange.new(1.5, 2.5)
	p.Rotation = NumberRange.new(0, 360)
	p.RotSpeed = NumberRange.new(-200, 200)
	p.EmissionDirection = Enum.NormalId.Top
	p.Enabled = false
	p.Parent = a
	p:Emit(140)
	task.delay(3, function()
		a:Destroy()
	end)
	task.delay(0.35, destello, E.Amarillo)
	-- SONIDO: mutante (escalera muy aguda y rápida)
	Sonidos.secuencia({ 12, 16, 19, 24, 28, 31, 36 }, 0.05, 0.4)
end

local function mostrarCartel(
	textoTitulo: string,
	textoNombre: string,
	textoGen: string,
	mutante: boolean
)
	titulo.Text = textoTitulo
	nombre.Text = textoNombre
	gen.Text = textoGen
	etiquetaMutante.Visible = mutante
	cartel.Size =
		UDim2.new(cartel.Size.X.Scale, cartel.Size.X.Offset, 0, if mutante then 196 else 160)
	escalaCartel.Scale = 0.3
	cartel.Visible = true
	TweenService
		:Create(
			escalaCartel,
			TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Scale = 1,
			}
		)
		:Play()
	if mutante then
		task.spawn(function()
			while cartel.Visible and etiquetaMutante.Visible do
				arcoiris.Rotation = (arcoiris.Rotation + 6) % 360
				task.wait()
			end
		end)
	end
end

local function ocultarCartel()
	cartel.Visible = false
end

---------------------------------------------------------------------------
-- Secuencias completas
---------------------------------------------------------------------------

local function noReaccionan(ca: Fusion.Criatura, cb: Fusion.Criatura, f: number)
	-- SONIDO: no reaccionan (dos notas graves que chocan)
	Sonidos.acorde({ -12, -11 }, 0.45)
	llenar(capsulas.A, ca.Color, 0.4, 0.35 * f)
	llenar(capsulas.B, cb.Color, 0.4, 0.35 * f)
	task.wait(0.35 * f)
	largarHumo(false, 12)
	temblar(0.5 * f, 0.15)
	mostrarCartel("No reaccionan", "¡Probá otra pareja!", "No se gastó ADN", false)
	llenar(capsulas.A, ca.Color, 0, 0.4 * f)
	llenar(capsulas.B, cb.Color, 0, 0.4 * f)
	task.wait(1.4 * f)
	ocultarCartel()
end

-- Anima una fusión de unos 3,3 segundos y deja el cartel unos segundos más (menos con "Fusión rápida").
-- Frena al que la llama hasta que termina.
function Efectos.jugar(r: Fusion.Resultado)
	local ca, cb = Fusion.porClave(r.A), Fusion.porClave(r.B)
	if not ca or not cb then
		return
	end
	-- Las cápsulas muestran a los padres (los padres no se gastan).
	for lado, clave in { A = r.A, B = r.B } do
		local mini = capsulas[lado].Mini
		if not mini or mini:GetAttribute("Clave") ~= clave then
			Efectos.mostrarEnCapsula(lado, clave)
		end
	end
	if criaturaSalida then
		criaturaSalida:Destroy()
		criaturaSalida = nil
	end
	enfocar()
	-- Con la mejora "Fusión rápida" todo dura menos (f = 1 normal, 0.5 la mitad).
	local f = (Players.LocalPlayer:GetAttribute("FactorFusion") :: number?) or 1

	local c = if r.Clave then Fusion.porClave(r.Clave) else nil
	if not r.Ok or not c then
		noReaccionan(ca, cb, f)
		soltar()
		return
	end

	-- 1) Las cápsulas se llenan del color de cada padre (0,8 s).
	-- SONIDO: burbujeo (notas que suben rápido)
	Sonidos.secuencia({ 0, 4, 7, 9, 12, 16 }, 0.12 * f, 0.3)
	llenar(capsulas.A, ca.Color, 1, 0.8 * f)
	llenar(capsulas.B, cb.Color, 1, 0.8 * f)
	task.wait(0.8 * f)

	-- 2) La máquina tiembla, las luces parpadean y sale humo (1,4 s).
	-- SONIDO: zumbido de la máquina (nota grave repetida)
	Sonidos.secuencia({ -12, -12, -10, -12, -12, -10, -9 }, 0.2 * f, 0.4)
	tubos({ A = ca.Color, B = cb.Color })
	task.spawn(temblar, 1.4 * f, 0.35)
	task.spawn(parpadear, 1.4 * f)
	largarHumo(true, 10)
	task.wait(0.7 * f)

	-- 3) Aparece la silueta negra dentro de la cúpula.
	-- SONIDO: suspenso (escalera que sube)
	Sonidos.secuencia({ 0, 1, 2, 3, 4, 5, 6, 7 }, 0.1 * f, 0.35)
	local silueta = crearEnSalida(c, true)
	mostrarCartel("¿Qué será?", "???", string.rep("●", c.Gen), false)
	task.wait(0.7 * f)
	largarHumo(false)
	task.wait(0.8 * f)

	-- 4) Revelación: destello, la criatura de verdad y el cartel con nombre y generación.
	-- SONIDO: revelación (acorde mayor + nota aguda)
	Sonidos.acorde({ 0, 4, 7 }, 0.45)
	Sonidos.secuencia({ 12, 16, 19, 24 }, 0.08, 0.35)
	destello(Color3.new(1, 1, 1))
	silueta:Destroy()
	criaturaSalida = crearEnSalida(c, false, r.Mutante)
	tubos(nil)
	llenar(capsulas.A, ca.Color, 0, 0.6 * f)
	llenar(capsulas.B, cb.Color, 0, 0.6 * f)
	local mutante = r.Mutante == true
	mostrarCartel(
		if r.Nueva then "¡ESPECIE NUEVA!" else "Ya la tenías",
		(if mutante then "⭐ " else "") .. c.Nombre,
		string.rep("●", c.Gen)
			.. "  Generación "
			.. c.Gen
			.. (if r.Premio then "   +" .. Formato.numero(r.Premio) .. " ADN" else ""),
		mutante
	)
	if mutante then
		efectoMutante()
	end

	task.wait(M.TiempoRevelacion * f)
	ocultarCartel()
	soltar()
end

return Efectos
