--!strict
-- Mascotas que acompañan a cada jugador (Grupo 4) y la Ruleta de Mascotas de la plaza.
--   Cada cliente arma las mascotas de todos los jugadores (atributo MascotasEquipadas) con
--   partes simples, una forma por mascota (GameConfig.Mascotas.Lista[..].Forma), y las hace
--   seguir al personaje flotando detrás. Las que están lejos de la cámara no se mueven.
--   La rueda de la plaza (tag "Ruleta", modelo "Rueda") gira despacito; cuando vos tirás, gira
--   rápido un rato. El resultado de verdad lo muestra el menú (MenuMascotas).
-- Solo se ve: los bonos de las mascotas los cuenta el servidor.

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)

local Ruleta = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Ruleta") :: RemoteEvent

local DISTANCIA = 160 -- studs: más lejos de la cámara, no se animan

local carpeta = Instance.new("Folder")
carpeta.Name = "MascotasLocales"
carpeta.Parent = Workspace

local mascotasDe: { [Player]: { Model } } = {}

-- Armado ------------------------------------------------------------------------------------

local function parte(
	modelo: Model,
	nombre: string,
	tam: Vector3,
	cf: CFrame,
	color: Color3,
	material: Enum.Material?,
	forma: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if forma then
		p.Shape = forma
	end
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = modelo
	return p
end

local BOLA = Enum.PartType.Ball

-- Arma una mascota mirando a -Z, con el centro del cuerpo en el origen.
local function armar(m: GameConfig.Mascota): Model
	local modelo = Instance.new("Model")
	modelo.Name = m.Id
	local c1, c2 = Color3.fromHex(m.Colores[1]), Color3.fromHex(m.Colores[2])
	local f = m.Forma
	local cuerpo: Part
	if f == "Topo" then
		cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.6, 1.4, 1.8), CFrame.new(), c1, nil, BOLA)
		parte(modelo, "Nariz", Vector3.new(0.45, 0.4, 0.45), CFrame.new(0, 0, -0.95), c2, nil, BOLA)
		for _, x in { -0.55, 0.55 } do
			parte(modelo, "Garra", Vector3.new(0.5, 0.2, 0.45), CFrame.new(x, -0.6, -0.55), c2)
		end
	elseif f == "Golem" then
		cuerpo = parte(
			modelo,
			"Cuerpo",
			Vector3.new(1.6, 1.5, 1.3),
			CFrame.new(),
			c1,
			Enum.Material.Slate
		)
		parte(
			modelo,
			"Cristal",
			Vector3.new(0.5, 0.9, 0.5),
			CFrame.new(0, 1.05, 0) * CFrame.Angles(0, math.rad(45), math.rad(12)),
			c2,
			Enum.Material.Neon
		)
		for _, x in { -1, 1 } do
			parte(
				modelo,
				"Brazo",
				Vector3.new(0.45, 0.9, 0.5),
				CFrame.new(x * 1.0, -0.2, 0),
				c1,
				Enum.Material.Slate
			)
		end
	elseif f == "Zorro" then
		cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.3, 1.2, 1.6), CFrame.new(), c1)
		for _, x in { -0.4, 0.4 } do
			parte(
				modelo,
				"Oreja",
				Vector3.new(0.35, 0.5, 0.2),
				CFrame.new(x, 0.8, -0.4) * CFrame.Angles(0, 0, x),
				c1
			)
		end
		parte(modelo, "Panza", Vector3.new(0.8, 0.6, 0.1), CFrame.new(0, -0.25, -0.81), c2)
		parte(
			modelo,
			"Cola",
			Vector3.new(0.45, 0.45, 1.1),
			CFrame.new(0, 0.1, 1.2) * CFrame.Angles(0.5, 0, 0),
			c1
		)
		parte(modelo, "Punta", Vector3.new(0.4, 0.4, 0.35), CFrame.new(0, 0.45, 1.75), c2)
	elseif f == "Tortuga" then
		cuerpo = parte(
			modelo,
			"Cuerpo",
			Vector3.new(1.9, 1.0, 1.9),
			CFrame.new(),
			c1,
			Enum.Material.Grass,
			BOLA
		)
		parte(
			modelo,
			"Cabeza",
			Vector3.new(0.7, 0.7, 0.7),
			CFrame.new(0, 0.05, -1.05),
			c2,
			nil,
			BOLA
		)
		for _, x in { -0.65, 0.65 } do
			for _, z in { -0.55, 0.55 } do
				parte(
					modelo,
					"Pata",
					Vector3.new(0.4, 0.35, 0.4),
					CFrame.new(x, -0.45, z),
					c2,
					nil,
					BOLA
				)
			end
		end
	elseif f == "Cristal" then
		cuerpo = parte(
			modelo,
			"Cuerpo",
			Vector3.new(1.1, 1.8, 1.1),
			CFrame.Angles(0, math.rad(45), 0),
			c1,
			Enum.Material.Glass
		)
		cuerpo.Transparency = 0.15
		for _, x in { -0.7, 0.7 } do
			parte(
				modelo,
				"Cristalito",
				Vector3.new(0.35, 0.8, 0.35),
				CFrame.new(x, -0.3, 0.2) * CFrame.Angles(0, 0, -x * 0.5),
				c2,
				Enum.Material.Neon
			)
		end
	elseif f == "Pinguino" then
		cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.3, 1.7, 1.2), CFrame.new(), c1, nil, BOLA)
		parte(
			modelo,
			"Panza",
			Vector3.new(0.95, 1.2, 0.5),
			CFrame.new(0, -0.15, -0.4),
			c2,
			nil,
			BOLA
		)
		parte(
			modelo,
			"Pico",
			Vector3.new(0.3, 0.2, 0.4),
			CFrame.new(0, 0.25, -0.7),
			Color3.fromHex("#FFB04D")
		)
		for _, x in { -0.7, 0.7 } do
			parte(
				modelo,
				"Aleta",
				Vector3.new(0.15, 0.8, 0.45),
				CFrame.new(x, -0.1, 0) * CFrame.Angles(0, 0, x * 0.4),
				c1
			)
		end
	elseif f == "Dragon" then
		cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.4, 1.2, 1.8), CFrame.new(), c1)
		parte(modelo, "Panza", Vector3.new(0.9, 0.7, 0.1), CFrame.new(0, -0.2, -0.91), c2)
		for _, x in { -1, 1 } do
			parte(
				modelo,
				"Ala",
				Vector3.new(1.3, 0.12, 0.9),
				CFrame.new(x * 1.2, 0.45, 0.2) * CFrame.Angles(0, 0, x * 0.5),
				c2,
				Enum.Material.Neon
			)
			parte(
				modelo,
				"Cuerno",
				Vector3.new(0.18, 0.5, 0.18),
				CFrame.new(x * 0.35, 0.8, -0.5) * CFrame.Angles(-0.4, 0, 0),
				c2
			)
		end
		parte(modelo, "Cola", Vector3.new(0.35, 0.35, 1.2), CFrame.new(0, -0.1, 1.4), c1)
	else -- Gato (y cualquier forma que falte)
		cuerpo = parte(modelo, "Cuerpo", Vector3.new(1.4, 1.3, 1.4), CFrame.new(), c1, nil, BOLA)
		for _, x in { -0.42, 0.42 } do
			parte(
				modelo,
				"Oreja",
				Vector3.new(0.35, 0.45, 0.2),
				CFrame.new(x, 0.75, -0.2) * CFrame.Angles(0, 0, x),
				c1
			)
		end
		parte(
			modelo,
			"Cola",
			Vector3.new(0.25, 0.25, 1.2),
			CFrame.new(0, 0.3, 1.0) * CFrame.Angles(0.7, 0, 0),
			c1
		)
		for k = 0, 2 do
			local a = k / 3 * math.pi * 2
			parte(
				modelo,
				"Estrella",
				Vector3.new(0.22, 0.22, 0.22),
				CFrame.new(math.cos(a) * 1.1, 0.9, math.sin(a) * 1.1) * CFrame.Angles(0.6, a, 0.6),
				c2,
				Enum.Material.Neon
			)
		end
	end
	-- ojos en la cara (adelante, -Z)
	local frente = -cuerpo.Size.Z / 2
	if f == "Tortuga" then
		frente = -1.35
	end
	for _, x in { -0.28, 0.28 } do
		local alto = if f == "Tortuga" then 0.15 else cuerpo.Size.Y * 0.18
		parte(
			modelo,
			"Ojo",
			Vector3.new(0.34, 0.34, 0.2),
			CFrame.new(x, alto, frente - 0.02),
			Color3.new(1, 1, 1),
			nil,
			BOLA
		)
		parte(
			modelo,
			"Pupila",
			Vector3.new(0.17, 0.17, 0.12),
			CFrame.new(x, alto, frente - 0.12),
			Color3.fromHex("#1B1F3B"),
			nil,
			BOLA
		)
	end
	-- las raras para arriba brillan un poco
	local r = m.Rareza
	if r == "Epico" or r == "Legendario" or r == "Mitico" then
		local luz = Instance.new("PointLight")
		luz.Color = c2
		luz.Range = if r == "Mitico" then 10 else 6
		luz.Brightness = 1
		luz.Parent = cuerpo
	end
	modelo.PrimaryPart = cuerpo
	return modelo
end

-- Mascotas de cada jugador ------------------------------------------------------------------

local function equipadas(jugador: Player): { string }
	local texto = jugador:GetAttribute("MascotasEquipadas")
	if typeof(texto) ~= "string" or texto == "" then
		return {}
	end
	local ok, lista = pcall(HttpService.JSONDecode, HttpService, texto)
	local r = {}
	if ok and typeof(lista) == "table" then
		for _, id in lista :: { any } do
			if typeof(id) == "string" then
				table.insert(r, id)
			end
		end
	end
	return r
end

local function rehacer(jugador: Player)
	local viejas = mascotasDe[jugador]
	if viejas then
		for _, m in viejas do
			m:Destroy()
		end
	end
	local lista: { Model } = {}
	local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	for _, id in equipadas(jugador) do
		local m = Reglas.mascota(id)
		if m then
			local modelo = armar(m)
			if raiz and raiz:IsA("BasePart") then
				modelo:PivotTo(raiz.CFrame * CFrame.new(0, 1, 4))
			end
			modelo.Parent = carpeta
			table.insert(lista, modelo)
		end
	end
	mascotasDe[jugador] = lista
end

local function seguir(jugador: Player)
	jugador:GetAttributeChangedSignal("MascotasEquipadas"):Connect(function()
		rehacer(jugador)
	end)
	jugador.CharacterAdded:Connect(function()
		task.defer(rehacer, jugador)
	end)
	rehacer(jugador)
end

Players.PlayerAdded:Connect(seguir)
for _, j in Players:GetPlayers() do
	seguir(j)
end
Players.PlayerRemoving:Connect(function(jugador: Player)
	local viejas = mascotasDe[jugador]
	if viejas then
		for _, m in viejas do
			m:Destroy()
		end
	end
	mascotasDe[jugador] = nil
end)

-- Ruleta de la plaza ------------------------------------------------------------------------

type Rueda = { Modelo: Model, Base: CFrame, Angulo: number }
local ruedas: { [BasePart]: Rueda } = {}
local velocidadExtra = 0 -- grados por segundo de más mientras tirás

local function agregarRuleta(p: Instance)
	if not p:IsA("BasePart") then
		return
	end
	local modelo = p:WaitForChild("Rueda", 10)
	if modelo and modelo:IsA("Model") then
		ruedas[p] = { Modelo = modelo, Base = modelo:GetPivot(), Angulo = 0 }
	end
end
CollectionService:GetInstanceAddedSignal("Ruleta"):Connect(agregarRuleta)
CollectionService:GetInstanceRemovedSignal("Ruleta"):Connect(function(p: Instance)
	ruedas[p :: BasePart] = nil
end)
for _, p in CollectionService:GetTagged("Ruleta") do
	task.spawn(agregarRuleta, p)
end
Ruleta.OnClientEvent:Connect(function()
	velocidadExtra = 900
end)

-- Cada cuadro -------------------------------------------------------------------------------

local reloj = 0
RunService.RenderStepped:Connect(function(dt: number)
	reloj += dt
	local cam = Workspace.CurrentCamera
	local ojo = if cam then cam.CFrame.Position else Vector3.zero
	for jugador, lista in mascotasDe do
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if not raiz or not raiz:IsA("BasePart") or (raiz.Position - ojo).Magnitude > DISTANCIA then
			continue
		end
		local n = #lista
		for i, modelo in lista do
			local lado = (i - (n + 1) / 2) * 3
			local flota = math.sin(reloj * 3 + i) * 0.3
			local destino = raiz.CFrame * CFrame.new(lado, 1 + flota, 4 + (i % 2) * 1.5)
			local actual = modelo:GetPivot()
			modelo:PivotTo(actual:Lerp(destino, math.min(1, dt * 7)))
		end
	end
	velocidadExtra = math.max(0, velocidadExtra - dt * 300)
	for p, r in ruedas do
		if (p.Position - ojo).Magnitude <= DISTANCIA and r.Modelo.Parent then
			r.Angulo = (r.Angulo + (12 + velocidadExtra) * dt) % 360
			r.Modelo:PivotTo(r.Base * CFrame.Angles(0, 0, math.rad(r.Angulo)))
		end
	end
end)
