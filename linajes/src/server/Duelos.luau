--!strict
-- 1 V 1 del sandbox: fila de espera, ring aparte flotando lejos de la arena, cuenta regresiva y
-- premio para el que gana. Mientras dura, los dos solo se pueden pegar entre ellos
-- (Combate.server mira el atributo DueloCon).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Perfiles = require(script.Parent.Perfiles)
local Analitica = require(script.Parent.Analitica)

local D = Config.Sandbox.Duelo

local Duelos = {}

type Avisar = (Player, string) -> ()

local cola: { Player } = {}
local avisos: { [Player]: Avisar } = {}
local rivalDe: { [Player]: Player } = {}
local ring: Model? = nil

-- Ring de duelo: piso octogonal con borde y paredes invisibles para no caerse.
local function armarRing(): Model
	if ring and ring.Parent then
		return ring
	end
	local m = Instance.new("Model")
	m.Name = "RingDuelo"
	local function pieza(
		nombre: string,
		tam: Vector3,
		cf: CFrame,
		color: Color3,
		mat: Enum.Material,
		transp: number?
	)
		local p = Instance.new("Part")
		p.Name = nombre
		p.Anchored = true
		p.Size = tam
		p.CFrame = cf
		p.Color = color
		p.Material = mat
		p.Transparency = transp or 0
		p.TopSurface = Enum.SurfaceType.Smooth
		p.Parent = m
		return p
	end
	local c = D.Centro
	local lado = D.Radio * 2
	for i = 0, 3 do
		-- Dos cuadrados girados 45° hacen un octógono.
		pieza(
			"Piso",
			Vector3.new(lado * 0.83, 2, lado),
			CFrame.new(c) * CFrame.Angles(0, math.rad(45 * i), 0),
			Color3.fromHex("#2B303A"),
			Enum.Material.Concrete
		)
	end
	local borde = pieza(
		"Borde",
		Vector3.new(0.4, lado * 0.9, lado * 0.9),
		CFrame.new(c + Vector3.new(0, 1.05, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromHex("#C2213A"),
		Enum.Material.Neon,
		0.35
	)
	borde.Shape = Enum.PartType.Cylinder
	borde.CanCollide = false
	local centro = pieza(
		"Centro",
		Vector3.new(0.45, lado * 0.84, lado * 0.84),
		CFrame.new(c + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromHex("#2B303A"),
		Enum.Material.Concrete
	)
	centro.Shape = Enum.PartType.Cylinder
	for i = 0, 7 do
		local a = math.rad(45 * i + 22.5)
		local pos = c
			+ Vector3.new(math.cos(a), 0, math.sin(a)) * (D.Radio + 1)
			+ Vector3.new(0, 12, 0)
		local pared = pieza(
			"Pared",
			Vector3.new(2, 24, D.Radio * 0.9),
			CFrame.lookAt(pos, c + Vector3.new(0, 12, 0)) * CFrame.Angles(0, math.rad(90), 0),
			Color3.new(1, 1, 1),
			Enum.Material.SmoothPlastic,
			1
		)
		pared.CanQuery = false
	end
	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromHex("#F29A3A")
	luz.Range = 60
	luz.Brightness = 2
	luz.Parent = centro
	m.Parent = workspace
	ring = m
	return m
end

local function terminar(ganador: Player?, perdedor: Player?)
	for _, j in { ganador, perdedor } do
		if j then
			j:SetAttribute("DueloCon", nil)
			rivalDe[j] = nil
		end
	end
	if ganador and ganador.Parent == Players then
		local d = Perfiles.datos(ganador)
		if d then
			Perfiles.cambiar(ganador, { Chatarra = d.Chatarra + D.PremioChatarra })
			Analitica.gana(ganador, D.PremioChatarra, d.Chatarra, "Duelo")
		end
		local aviso = avisos[ganador]
		if aviso then
			aviso(ganador, string.format("¡GANASTE EL 1 V 1!  +%d Chatarra", D.PremioChatarra))
		end
		task.delay(3, function()
			if ganador.Parent == Players and not ganador:GetAttribute("DueloCon") then
				ganador:LoadCharacter() -- vuelve a la arena
			end
		end)
	end
	if perdedor and perdedor.Parent == Players then
		local aviso = avisos[perdedor]
		if aviso then
			aviso(perdedor, "Perdiste el 1 V 1. Volvé a entrar desde el menú (M)")
		end
	end
end

local function empezar(a: Player, b: Player)
	local ca, cb = a.Character, b.Character
	if not (ca and cb) then
		return
	end
	armarRing()
	rivalDe[a], rivalDe[b] = b, a
	a:SetAttribute("DueloCon", b.UserId)
	b:SetAttribute("DueloCon", a.UserId)
	local c = D.Centro + Vector3.new(0, 4.5, 0)
	ca:PivotTo(CFrame.lookAt(c + Vector3.new(-D.Separacion, 0, 0), c))
	cb:PivotTo(CFrame.lookAt(c + Vector3.new(D.Separacion, 0, 0), c))
	for _, j in { a, b } do
		local personaje = j.Character
		if personaje then
			personaje:SetAttribute("Frenado", true) -- quietos durante la cuenta
		end
		local aviso = avisos[j]
		if aviso then
			aviso(j, string.format("1 V 1 contra %s  ·  %d...", rivalDe[j].DisplayName, D.Cuenta))
		end
	end
	task.delay(D.Cuenta, function()
		for _, j in { a, b } do
			local personaje = j.Character
			if personaje then
				personaje:SetAttribute("Frenado", false)
			end
			local aviso = avisos[j]
			if aviso and rivalDe[j] then
				aviso(j, "¡PELEEN!")
			end
		end
	end)
	for _, j in { a, b } do
		local h = j.Character and j.Character:FindFirstChildOfClass("Humanoid")
		if h then
			h.Died:Once(function()
				local rival = rivalDe[j]
				if rival then
					terminar(rival, j)
				end
			end)
		end
	end
end

-- Entra a la fila; si ya hay alguien esperando, arranca el duelo.
function Duelos.entrar(jugador: Player, avisar: Avisar)
	avisos[jugador] = avisar
	if rivalDe[jugador] or table.find(cola, jugador) then
		return
	end
	for i = #cola, 1, -1 do
		if cola[i].Parent ~= Players then
			table.remove(cola, i)
		end
	end
	local rival = table.remove(cola, 1)
	if rival then
		empezar(rival, jugador)
	else
		table.insert(cola, jugador)
		avisar(jugador, "Buscando rival para el 1 V 1…  (mientras, podés practicar)")
	end
end

-- Sale de la fila o abandona el duelo (pierde).
function Duelos.salir(jugador: Player)
	local i = table.find(cola, jugador)
	if i then
		table.remove(cola, i)
	end
	local rival = rivalDe[jugador]
	if rival then
		terminar(rival, jugador)
	end
end

Players.PlayerRemoving:Connect(function(jugador)
	Duelos.salir(jugador)
	avisos[jugador] = nil
end)

return Duelos
