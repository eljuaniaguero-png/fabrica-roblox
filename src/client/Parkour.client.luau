--!strict
-- Variantes de parkour. Cada cliente las mueve en su pantalla, así tu personaje viaja suave
-- encima. Todas usan el reloj del servidor, así se ven igual para todos.
-- Las caídas, checkpoints y la velocidad los sigue controlando el servidor.
--
-- En el mapa (atributos de una BasePart anclada):
--   Movil = Vector3 (cuánto se aleja del centro) + Periodo = número (segundos por ida y vuelta)
--   Giratorio = número (grados por segundo, gira sobre su eje vertical). Si no choca (CanCollide = false),
--               al tocarte te da un empujón controlado en vez de un choque físico.
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

-- Con streaming, las partes llegan y se van mientras jugás: todo se guarda por parte.
local moviles: { [BasePart]: Movil } = {}
local giratorios: { [BasePart]: Giratorio } = {}
local registradas: { [BasePart]: boolean } = {}

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

-- Empujón de una barra giratoria: de costado, en el sentido en que gira, y un poco hacia arriba.
local function prepararEmpuje(parte: BasePart, gradosPorSegundo: number)
	local ultimo = 0
	parte.Touched:Connect(function(otra)
		local raiz = miRaiz(otra)
		if not raiz or os.clock() - ultimo < Config.Parkour.EsperaEmpuje then
			return
		end
		ultimo = os.clock()
		local radio = (raiz.Position - parte.Position) * Vector3.new(1, 0, 1)
		if radio.Magnitude < 0.1 then
			return
		end
		local sentido = if gradosPorSegundo >= 0 then 1 else -1
		-- Girar (x, z) alrededor del eje Y en sentido positivo mueve hacia (z, -x).
		local costado = Vector3.new(radio.Z, 0, -radio.X).Unit * sentido
		raiz.AssemblyLinearVelocity = costado * Config.Parkour.EmpujeBarra
			+ Vector3.new(0, Config.Parkour.EmpujeBarraArriba, 0)
		-- SONIDO: golpe de la barra (Config.Efectos.Error)
		Sonidos.efecto("Error")
	end)
end

local function registrar(parte: Instance)
	if not parte:IsA("BasePart") or registradas[parte] then
		return
	end
	registradas[parte] = true
	local amplitud = parte:GetAttribute("Movil")
	local periodo = parte:GetAttribute("Periodo")
	if typeof(amplitud) == "Vector3" and typeof(periodo) == "number" and periodo > 0 then
		moviles[parte] =
			{ parte = parte, origen = parte.CFrame, amplitud = amplitud, periodo = periodo }
	end
	local grados = parte:GetAttribute("Giratorio")
	if typeof(grados) == "number" then
		giratorios[parte] = { parte = parte, origen = parte.CFrame, gradosPorSegundo = grados }
		if not parte.CanCollide then
			prepararEmpuje(parte, grados)
		end
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
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		registradas[objeto] = nil
		moviles[objeto] = nil
		giratorios[objeto] = nil
	end
end)

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
