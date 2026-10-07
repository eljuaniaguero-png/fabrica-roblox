--!strict
-- Variantes de parkour. Cada cliente las mueve en su pantalla, así tu personaje viaja suave
-- encima. Todas usan el reloj del servidor, así se ven igual para todos.
-- Las caídas, checkpoints y la velocidad los sigue controlando el servidor.
--
-- En el mapa (atributos de una BasePart anclada):
--   Movil = Vector3 (cuánto se aleja del centro) + Periodo = número (segundos por ida y vuelta)
--   Giratorio = número (grados por segundo, gira sobre su eje vertical)
--   Desaparece = true (al pisarla, se va un rato)
--   Trampolin = número (velocidad hacia arriba que te da)
--   Cinta = Vector3 (velocidad con la que te arrastra)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer

type Movil = { parte: BasePart, origen: CFrame, amplitud: Vector3, periodo: number }
type Giratorio = { parte: BasePart, origen: CFrame, gradosPorSegundo: number }

local moviles: { Movil } = {}
local giratorios: { Giratorio } = {}

-- Devuelve la raíz de tu personaje si `otra` es una parte de él.
local function miRaiz(otra: BasePart): BasePart?
	local personaje = jugador.Character
	if not personaje or not otra:IsDescendantOf(personaje) then
		return nil
	end
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	return if raiz and raiz:IsA("BasePart") then raiz else nil
end

local function prepararDesaparece(parte: BasePart)
	local transparencia = parte.Transparency
	local ocupada = false
	parte.Touched:Connect(function(otra)
		if ocupada or not miRaiz(otra) then
			return
		end
		ocupada = true
		parte.Transparency = math.max(transparencia, 0.4) -- aviso: está por irse
		task.wait(Config.Parkour.TiempoAntesDeDesaparecer)
		parte.Transparency = 0.9
		parte.CanCollide = false
		task.wait(Config.Parkour.TiempoDesaparecida)
		parte.Transparency = transparencia
		parte.CanCollide = true
		ocupada = false
	end)
end

local function prepararTrampolin(parte: BasePart, fuerza: number)
	local ultimo = 0
	parte.Touched:Connect(function(otra)
		local raiz = miRaiz(otra)
		if not raiz or os.clock() - ultimo < Config.Parkour.EsperaTrampolin then
			return
		end
		ultimo = os.clock()
		local v = raiz.AssemblyLinearVelocity
		raiz.AssemblyLinearVelocity = Vector3.new(v.X, fuerza, v.Z)
		-- SONIDO: trampolín (Config.Efectos.Trampolin)
		Sonidos.efecto("Trampolin")
	end)
end

local function registrar(parte: Instance)
	if not parte:IsA("BasePart") then
		return
	end
	local amplitud = parte:GetAttribute("Movil")
	local periodo = parte:GetAttribute("Periodo")
	if typeof(amplitud) == "Vector3" and typeof(periodo) == "number" and periodo > 0 then
		table.insert(
			moviles,
			{ parte = parte, origen = parte.CFrame, amplitud = amplitud, periodo = periodo }
		)
	end
	local grados = parte:GetAttribute("Giratorio")
	if typeof(grados) == "number" then
		table.insert(
			giratorios,
			{ parte = parte, origen = parte.CFrame, gradosPorSegundo = grados }
		)
	end
	if parte:GetAttribute("Desaparece") == true then
		prepararDesaparece(parte)
	end
	local fuerza = parte:GetAttribute("Trampolin")
	if typeof(fuerza) == "number" then
		prepararTrampolin(parte, fuerza)
	end
	local cinta = parte:GetAttribute("Cinta")
	if typeof(cinta) == "Vector3" then
		parte.AssemblyLinearVelocity = cinta
	end
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end

-- Antes de cada paso de física: mover y darles velocidad, así te llevan encima.
RunService.PreSimulation:Connect(function()
	local t = workspace:GetServerTimeNow()
	for _, m in moviles do
		local w = 2 * math.pi / m.periodo
		m.parte.CFrame = m.origen + m.amplitud * math.sin(w * t)
		m.parte.AssemblyLinearVelocity = m.amplitud * (w * math.cos(w * t))
	end
	for _, g in giratorios do
		local w = math.rad(g.gradosPorSegundo)
		g.parte.CFrame = g.origen * CFrame.Angles(0, (w * t) % (2 * math.pi), 0)
		g.parte.AssemblyAngularVelocity = Vector3.new(0, w, 0)
	end
end)
