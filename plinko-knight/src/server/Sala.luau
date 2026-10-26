--!strict
-- Lo que pasa en la sala del lado del servidor (etapa 7b-1):
--   - La sala es en solitario (servidores de 1 jugador): el que entra recibe la máquina (atributo
--     Dueno = UserId); al salir se libera. La asignación sirve igual si algún día hay más.
--   - Remoto ElegirBola(bola): el mostrador de la sala guarda la bola con la que arrancás
--     (solo si la tenés desbloqueada y con límite de frecuencia).
--   - La pared de récords muestra tus récords (mejor piso, golpe, jefes, mazmorras, partidas).
-- Sentarse en la máquina es solo de cámara (cliente): la partida la sigue decidiendo el servidor.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Progreso = require(Shared:WaitForChild("Progreso"))
local Partida = require(script.Parent:WaitForChild("Partida"))
local GeneradorSala = require(script.Parent:WaitForChild("GeneradorSala"))

local Sala = {}

local function maquinas(): { Model }
	local lista = {}
	for _, m in CollectionService:GetTagged("Maquina") do
		if m:IsA("Model") then
			table.insert(lista, m)
		end
	end
	table.sort(lista, function(a: Model, b: Model): boolean
		return (a:GetAttribute("Indice") or 0) < (b:GetAttribute("Indice") or 0)
	end)
	return lista
end

local function asignar(jugador: Player)
	for _, m in maquinas() do
		if m:GetAttribute("Dueno") == jugador.UserId then
			return
		end
	end
	for _, m in maquinas() do
		if m:GetAttribute("Dueno") == 0 then
			m:SetAttribute("Dueno", jugador.UserId)
			return
		end
	end
	warn("[Sala] No quedan máquinas libres para " .. jugador.Name)
end

local function liberar(jugador: Player)
	for _, m in maquinas() do
		if m:GetAttribute("Dueno") == jugador.UserId then
			m:SetAttribute("Dueno", 0)
		end
	end
end

-- Pared de récords: la sala es en solitario, así que muestra los tuyos.
local function dibujarRecords(lista: TextLabel)
	local jugador = Players:GetPlayers()[1]
	local p = jugador and Partida.de(jugador)
	if not p then
		lista.Text = ""
		return
	end
	local d = p.Progreso
	lista.Text = table.concat({
		("Mejor piso: %d de %d"):format(d.MejorPiso, #Config.Monstruos),
		("Mejor golpe: %d"):format(d.MejorGolpe),
		("Jefes vencidos: %d"):format(d.JefesVencidos),
		("Mazmorras ganadas: %d"):format(d.PartidasGanadas),
		("Partidas jugadas: %d"):format(d.PartidasJugadas),
	}, "\n")
end

local function armarRecords(): TextLabel?
	local pared = CollectionService:GetTagged("Records")[1]
	if not pared or not pared:IsA("BasePart") then
		return nil
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front -- mira a la sala (-Z)
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = pared
	local titulo = Instance.new("TextLabel")
	titulo.BackgroundTransparency = 1
	titulo.Size = UDim2.fromScale(1, 0.18)
	titulo.Font = Enum.Font.FredokaOne
	titulo.TextScaled = true
	titulo.TextColor3 = Color3.fromHex(Config.Colores.Oro)
	titulo.Text = "TUS RÉCORDS"
	titulo.Parent = gui
	local lista = Instance.new("TextLabel")
	lista.BackgroundTransparency = 1
	lista.Position = UDim2.fromScale(0.06, 0.22)
	lista.Size = UDim2.fromScale(0.88, 0.74)
	lista.Font = Enum.Font.GothamBold
	lista.TextSize = 40
	lista.TextXAlignment = Enum.TextXAlignment.Left
	lista.TextYAlignment = Enum.TextYAlignment.Top
	lista.TextColor3 = Color3.new(1, 1, 1)
	lista.Parent = gui
	return lista
end

-- Personaje nuevo: a la entrada de la sala, mirando a las máquinas (si apareció antes de que
-- existiera la sala, quedaba arriba del techo).
local function aLaEntrada(personaje: Model)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 5)
	if raiz then
		local sala = workspace:FindFirstChild("Sala")
		local altura = if sala then sala:GetAttribute("Altura") or 0 else 0
		personaje:PivotTo(CFrame.new(0, altura + 3.5, Config.Sala.Largo / 2 - 6))
	end
end

local function alEntrar(jugador: Player)
	asignar(jugador)
	jugador.CharacterAdded:Connect(aLaEntrada)
	if jugador.Character then
		task.spawn(aLaEntrada, jugador.Character)
	end
end

function Sala.iniciar()
	GeneradorSala.generar()

	Players.PlayerAdded:Connect(alEntrar)
	for _, j in Players:GetPlayers() do
		alEntrar(j)
	end
	Players.PlayerRemoving:Connect(liberar)

	-- Mostrador: elegir la bola con la que arrancás.
	local ultimos: { [Player]: number } = {}
	local elegir = Instance.new("RemoteEvent")
	elegir.Name = "ElegirBola"
	elegir.OnServerEvent:Connect(function(jugador: Player, bola: any)
		local p = Partida.de(jugador)
		local ahora = os.clock()
		if
			not p
			or not Progreso.tieneBola(p.Progreso, bola)
			or ahora - (ultimos[jugador] or -math.huge) < Config.Sala.TiempoMinimoBola
		then
			return
		end
		ultimos[jugador] = ahora
		p.Progreso.BolaElegida = bola
	end)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimos[jugador] = nil
	end)
	elegir.Parent = ReplicatedStorage:WaitForChild("Remotos")

	local lista = armarRecords()
	if lista then
		task.spawn(function()
			while true do
				dibujarRecords(lista)
				task.wait(3)
			end
		end)
	end
end

return Sala
