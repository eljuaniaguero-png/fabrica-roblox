--!strict
-- Fuego con volumen: muchas partículas chicas por capas (centro, llamas, humo y brasas).
-- Todos los valores están en Config.Efectos.Fuego. Solo se ve: no decide nada.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Niveles = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Niveles"))

local F = Config.Efectos.Fuego

type Capa = { emisor: ParticleEmitter, tam: { number } }

local Fuego = {}

local function tamanos(t: { number }, s: number): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, t[1] * s),
		NumberSequenceKeypoint.new(0.35, t[2] * s),
		NumberSequenceKeypoint.new(1, t[3] * s),
	})
end

local function colores(lista: { string }): ColorSequence
	local puntos = {}
	for i, hex in lista do
		table.insert(puntos, ColorSequenceKeypoint.new((i - 1) / (#lista - 1), Color3.fromHex(hex)))
	end
	return ColorSequence.new(puntos)
end

local function capa(padre: Instance, c: any, ritmo: boolean): Capa
	local e = Instance.new("ParticleEmitter")
	if c.Textura then
		e.Texture = (Config.Efectos :: any)[c.Textura]
		e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
		e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	end
	e.Color = colores(c.Colores)
	e.LightEmission = c.Brillo
	e.LightInfluence = 0
	e.Lifetime = NumberRange.new(c.Vida[1], c.Vida[2])
	e.Speed = NumberRange.new(c.Rapidez[1], c.Rapidez[2])
	e.SpreadAngle = Vector2.new(c.Abertura, c.Abertura)
	e.EmissionDirection = Enum.NormalId.Top
	e.Acceleration = Vector3.new(0, c.Sube, 0)
	e.Drag = c.Freno or 0
	e.Size = tamanos(c.Tam, 1)
	e.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, c.Opacidad[1]),
		NumberSequenceKeypoint.new(0.3, c.Opacidad[2]),
		NumberSequenceKeypoint.new(1, 1),
	})
	e.Rotation = NumberRange.new(0, 359)
	e.RotSpeed = NumberRange.new(-F.Giro, F.Giro)
	e.LockedToPart = c.Pegado == true
	e.ZOffset = c.Capa or 0
	e.Rate = if ritmo then c.Ritmo else 0
	e.Parent = padre
	return { emisor = e, tam = c.Tam }
end

local function armar(padre: Instance, juego: any): { Capa }
	local capas = {}
	for _, nombre in { "Humo", "Llamas", "Nucleo", "Brasas" } do
		if juego[nombre] then
			table.insert(capas, capa(padre, juego[nombre], true))
		end
	end
	return capas
end

local function escalar(capas: { Capa }, s: number)
	for _, c in capas do
		c.emisor.Size = tamanos(c.tam, s)
	end
end

local function apagar(capas: { Capa })
	for _, c in capas do
		c.emisor.Rate = 0
	end
end

-- Pasa de una escala a otra sin mandar nada por la red.
local function crecer(capas: { Capa }, desde: number, hasta: number, tiempo: number)
	task.spawn(function()
		local inicio = os.clock()
		while os.clock() - inicio < tiempo do
			local t = (os.clock() - inicio) / tiempo
			escalar(capas, desde + (hasta - desde) * t)
			RunService.Heartbeat:Wait()
		end
		escalar(capas, hasta)
	end)
end

local function luz(padre: Instance, l: any)
	local p = Instance.new("PointLight")
	p.Color = Color3.fromHex(F.ColorLuz)
	p.Shadows = false
	p.Parent = padre
	task.spawn(function()
		while p.Parent do
			local n = math.noise(os.clock() * F.LuzRapidez, l.Brillo)
			p.Brightness = l.Brillo * (1 + n * F.LuzVaria)
			p.Range = l.Alcance * (1 + n * F.LuzVaria * 0.4)
			task.wait(1 / 20)
		end
	end)
end

-- Se enciende chica en la mano hasta el marcador Lanza.
function Fuego.carga(personaje: Model, dura: number)
	task.delay(F.EnciendeEn, function()
		local mano = personaje:FindFirstChild("RightHand")
		if not mano then
			return
		end
		local punto = Instance.new("Attachment")
		punto.Position = Vector3.new(0, -0.6, 0)
		punto.Parent = mano
		local capas = armar(punto, F.Bola)
		luz(punto, F.Bola.Luz)
		local s = Niveles.tamano(personaje)
		crecer(capas, F.BolaEscalaMano * 0.4 * s, F.BolaEscalaMano * s, dura - F.EnciendeEn)
		task.delay(dura - F.EnciendeEn, function()
			apagar(capas)
		end)
		Debris:AddItem(punto, dura - F.EnciendeEn + 0.5)
	end)
end

local function alAparecerBola(parte: Instance)
	local capas = armar(parte, F.Bola)
	luz(parte, F.Bola.Luz)
	local s = (parte:GetAttribute("Escala") :: number?) or 1
	crecer(capas, F.BolaEscalaMano * s, s, F.BolaCrece)
end

local function alAparecerMuro(parte: Instance)
	local capas = armar(parte, F.Muro)
	luz(parte, F.Muro.Luz)
	local s = (parte:GetAttribute("Escala") :: number?) or 1
	crecer(capas, 0.4 * s, s, 0.3)
	task.delay(parte:GetAttribute("Dura") :: number, function()
		apagar(capas)
	end)
end

function Fuego.chorro(raiz: BasePart, dura: number, escala: number)
	local punto = Instance.new("Attachment")
	punto.Position = Vector3.new(0, 0.5, -2.5)
	punto.Orientation = Vector3.new(-90, 0, 0)
	punto.Parent = raiz
	local capas = armar(punto, F.Chorro)
	escalar(capas, escala)
	luz(punto, F.Chorro.Luz)
	task.delay(dura, function()
		apagar(capas)
	end)
	Debris:AddItem(punto, dura + 1.2)
end

function Fuego.explosion(centro: Vector3, escala: number)
	local soporte = Instance.new("Part")
	soporte.Anchored = true
	soporte.CanCollide = false
	soporte.CanQuery = false
	soporte.CanTouch = false
	soporte.Transparency = 1
	soporte.Size = Vector3.one * 0.2
	soporte.Position = centro
	soporte.Parent = workspace
	for nombre, cantidad in F.Explosion.Cantidad do
		local c = capa(soporte, (F.Explosion :: any)[nombre], false)
		escalar({ c }, escala)
		c.emisor:Emit(cantidad)
	end
	luz(soporte, F.Explosion.Luz)
	Debris:AddItem(soporte, 1.6)
end

for etiqueta, hacer in { BolaFuego = alAparecerBola, MuroFuego = alAparecerMuro } do
	CollectionService:GetInstanceAddedSignal(etiqueta):Connect(hacer)
	for _, parte in CollectionService:GetTagged(etiqueta) do
		hacer(parte)
	end
end

return Fuego
