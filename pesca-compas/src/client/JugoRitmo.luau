--!strict
-- Feedback visual de cada toque del minijuego (lo usa Pesca.client). Antes la nota acertada
-- solo desaparecía; ahora cada calificación tiene su respuesta en el carril:
--   Perfecto: el aro late fuerte, sale una onda dorada y la nota estalla en el aro.
--   Bien:     latido chico y onda celeste.
--   Error:    el carril se sacude y parpadea en rojo.
--   Racha:    cada 5 aciertos seguidos el texto de la racha da un golpe.
-- Todo con TweenService (Back/Quad/Cubic Out) y sin task.wait: lo que se crea se destruye al
-- terminar su tween, y limpiar() lo saca todo de una si el minijuego se corta en el medio.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Estilo = require(Shared:WaitForChild("Estilo"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local UI = Estilo.UI

export type Calificacion = "Perfecto" | "Bien" | "Error"

local LATIDO = { Perfecto = 1.28, Bien = 1.12 }
local ONDA = { Perfecto = 2.1, Bien = 1.6 } -- tamaño final de la onda respecto del aro
local SACUDIDA = { Duracion = 0.25, Amplitud = 9, Frecuencia = 38 } -- px, rad/s
local CADA_RACHA = 5

local JugoRitmo = {}

local panel: Frame? = nil
local aro: Frame? = nil
local escalaAro: UIScale? = nil
local escalaRacha: UIScale? = nil
local destello: Frame? = nil
local posBase = UDim2.new()

local efimeros = Limpieza.nueva() -- ondas y estallidos en vuelo
local sacudida = Limpieza.nueva()
local latido: Tween? = nil
local golpeRacha: Tween? = nil

local function tween(obj: Instance, t: number, estilo: Enum.EasingStyle, props: { [string]: any }): Tween
	local tw = TweenService:Create(obj, TweenInfo.new(t, estilo, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

-- Un efecto de un solo uso: se destruye solo al terminar el tween (o antes, con limpiar()).
local function efimero(obj: GuiObject, t: number, estilo: Enum.EasingStyle, props: { [string]: any })
	efimeros:dar(obj)
	tween(obj, t, estilo, props).Completed:Once(function()
		obj:Destroy()
	end)
end

local function circulo(color: Color3, tam: number, transp: number): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.SizeConstraint = Enum.SizeConstraint.RelativeXX
	f.Size = UDim2.fromScale(tam, tam)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transp
	f.BorderSizePixel = 0
	f.ZIndex = 4
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	return f
end

-- Se llama una vez con las piezas del carril que arma Pesca.client.
function JugoRitmo.preparar(elPanel: Frame, elAro: Frame, rachaTexto: TextLabel)
	panel, aro = elPanel, elAro
	posBase = elPanel.Position
	local ea = Instance.new("UIScale")
	ea.Parent = elAro
	escalaAro = ea
	local er = Instance.new("UIScale")
	er.Parent = rachaTexto
	escalaRacha = er
	local d = Instance.new("Frame") -- tapa roja del carril para el parpadeo de error
	d.Size = UDim2.fromScale(1, 1)
	d.BackgroundColor3 = UI.Error
	d.BackgroundTransparency = 1
	d.BorderSizePixel = 0
	d.ZIndex = 5
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, UI.Esquina)
	c.Parent = d
	d.Parent = elPanel
	destello = d
end

local function latir(fuerza: number)
	local ea = escalaAro
	if not ea then
		return
	end
	if latido then
		latido:Cancel()
	end
	ea.Scale = fuerza
	latido = tween(ea, 0.22, Enum.EasingStyle.Back, { Scale = 1 })
end

-- Nota acertada. nota = el Frame que bajaba (se esconde acá; el estallido es una copia).
function JugoRitmo.acierto(nota: Frame, calif: Calificacion)
	local p, a = panel, aro
	nota.Visible = false
	if not p or not a or calif == "Error" then
		return
	end
	local perfecto = calif == "Perfecto"
	latir(if perfecto then LATIDO.Perfecto else LATIDO.Bien)

	-- onda: un anillo que se abre desde el aro y se apaga
	local onda = circulo(Color3.new(1, 1, 1), a.Size.X.Scale, 1)
	onda.Position = a.Position
	local borde = Instance.new("UIStroke")
	borde.Color = if perfecto then UI.Perfecto else UI.Bien
	borde.Thickness = if perfecto then 6 else 4
	borde.Parent = onda
	onda.Parent = p
	local fin = a.Size.X.Scale * (if perfecto then ONDA.Perfecto else ONDA.Bien)
	efimero(onda, if perfecto then 0.35 else 0.28, Enum.EasingStyle.Cubic, { Size = UDim2.fromScale(fin, fin) })
	efimeros:dar(tween(borde, if perfecto then 0.35 else 0.28, Enum.EasingStyle.Quad, { Transparency = 1 }))

	-- estallido: la nota se infla y se desvanece en el aro (solo en Perfecto, que se note la diferencia)
	if perfecto then
		local tam = nota.Size.X.Scale
		local bola = circulo(nota.BackgroundColor3, tam, 0)
		bola.Position = a.Position
		bola.Parent = p
		efimero(bola, 0.2, Enum.EasingStyle.Quad, {
			Size = UDim2.fromScale(tam * 1.9, tam * 1.9),
			BackgroundTransparency = 1,
		})
	end
end

-- Toque fuera de tiempo o nota que pasó de largo.
function JugoRitmo.error()
	local p, d = panel, destello
	if not p or not d then
		return
	end
	d.BackgroundTransparency = 0.55
	efimeros:dar(tween(d, 0.3, Enum.EasingStyle.Quad, { BackgroundTransparency = 1 }))

	-- sacudida horizontal que se apaga sola (seno amortiguado, por frame)
	sacudida:limpiar()
	local inicio = os.clock()
	sacudida:dar(function()
		p.Position = posBase
	end)
	sacudida:dar(RunService.RenderStepped:Connect(function()
		local t = os.clock() - inicio
		if t >= SACUDIDA.Duracion then
			sacudida:limpiar()
			return
		end
		local k = 1 - t / SACUDIDA.Duracion
		local dx = math.sin(t * SACUDIDA.Frecuencia) * SACUDIDA.Amplitud * k * k
		p.Position = posBase + UDim2.fromOffset(dx, 0)
	end))
end

-- Después de anotar la racha: golpe del texto en cada múltiplo de 5.
function JugoRitmo.racha(n: number)
	local er = escalaRacha
	if not er or n < CADA_RACHA or n % CADA_RACHA ~= 0 then
		return
	end
	if golpeRacha then
		golpeRacha:Cancel()
	end
	er.Scale = 1.6
	golpeRacha = tween(er, 0.3, Enum.EasingStyle.Back, { Scale = 1 })
	latir(1.35)
end

-- Fin del minijuego (o corte): nada de esto puede quedar a medio camino para la próxima pesca.
function JugoRitmo.limpiar()
	efimeros:limpiar()
	sacudida:limpiar()
	if latido then
		latido:Cancel()
		latido = nil
	end
	if golpeRacha then
		golpeRacha:Cancel()
		golpeRacha = nil
	end
	if escalaAro then
		escalaAro.Scale = 1
	end
	if escalaRacha then
		escalaRacha.Scale = 1
	end
	if destello then
		destello.BackgroundTransparency = 1
	end
end

return JugoRitmo
