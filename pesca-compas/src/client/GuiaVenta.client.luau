--!strict
-- Guía "¡Vendé!": cuando el balde está lleno, un haz de luz late entre el personaje y el puesto
-- de venta (tag "Vendedor"). Cierra el circuito para los más chicos sin tener que leer nada.
-- Es solo visual y local: el servidor no se entera ni decide nada acá.
-- Se apaga sola al vender (llega un Estado con lugar en el balde) o al llegar al puesto.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Estilo = require(Shared:WaitForChild("Estilo"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local jugador = Players.LocalPlayer

local CERCA = 10 -- studs al puesto: ya llegó, se esconde
local ANCHO = 0.6
local LATIDO = 3 -- latidos por segundo (rad/s / 2π aprox.)

local guia = Limpieza.nueva()
local lleno = false

local function puestoMasCercano(desde: Vector3): BasePart?
	local mejor: BasePart? = nil
	local dist = math.huge
	for _, v in CollectionService:GetTagged("Vendedor") do
		if v:IsA("BasePart") then
			local d = (v.Position - desde).Magnitude
			if d < dist then
				mejor, dist = v, d
			end
		end
	end
	return mejor
end

local function apagar()
	guia:limpiar()
end

local function prender()
	apagar()
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return
	end
	local destino = puestoMasCercano(raiz.Position)
	if not destino then
		return
	end
	-- copias no opcionales: el chequeo de tipos no lleva el "no es nil" adentro de las funciones
	local cuerpo: BasePart = raiz
	local puesto: BasePart = destino

	local desde = guia:dar(Instance.new("Attachment"))
	desde.Name = "GuiaVentaDesde"
	desde.Position = Vector3.new(0, -2.4, 0) -- a la altura de los pies
	desde.Parent = raiz
	local hasta = guia:dar(Instance.new("Attachment"))
	hasta.Name = "GuiaVentaHasta"
	hasta.Position = Vector3.new(0, -puesto.Size.Y / 2 + 0.3, 0)
	hasta.Parent = puesto

	local haz = guia:dar(Instance.new("Beam"))
	haz.Name = "GuiaVenta"
	haz.Attachment0 = desde
	haz.Attachment1 = hasta
	haz.Color = ColorSequence.new(Estilo.Mundo.PisoVenta)
	haz.LightEmission = 1
	haz.LightInfluence = 0
	haz.Width0 = ANCHO
	haz.Width1 = ANCHO
	haz.Segments = 20
	haz.CurveSize0 = 0
	haz.CurveSize1 = 0
	haz.FaceCamera = true
	haz.Parent = raiz

	guia:dar(RunService.RenderStepped:Connect(function()
		if not cuerpo.Parent or not puesto.Parent then
			apagar()
			return
		end
		if (cuerpo.Position - puesto.Position).Magnitude < CERCA then
			haz.Enabled = false
			return
		end
		haz.Enabled = true
		-- late de 0.15 a 0.6 de transparencia, con la punta del jugador más fuerte
		local a = 0.15 + 0.45 * (0.5 + 0.5 * math.sin(os.clock() * LATIDO * math.pi * 2))
		haz.Transparency = NumberSequence.new(a, math.min(a + 0.3, 1))
	end))
end

Remotos:WaitForChild("Estado").OnClientEvent:Connect(function(e: any)
	if typeof(e) ~= "table" or typeof(e.EnBalde) ~= "number" or typeof(e.Capacidad) ~= "number" then
		return
	end
	local ahora = e.EnBalde >= e.Capacidad
	if ahora == lleno then
		return
	end
	lleno = ahora
	if lleno then
		prender()
	else
		apagar()
	end
end)

-- al reaparecer, el haz viejo murió con el personaje: si sigue lleno, se vuelve a armar
jugador.CharacterAdded:Connect(function(personaje: Model)
	apagar()
	if lleno then
		personaje:WaitForChild("HumanoidRootPart", 10)
		if lleno and jugador.Character == personaje then
			prender()
		end
	end
end)
