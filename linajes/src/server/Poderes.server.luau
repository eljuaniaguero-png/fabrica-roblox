--!strict
-- Habilidades Z, X y C de los Linajes. El servidor valida Linaje, recarga, energía y alcance.
-- El daño pasa por la API de Combate.server.luau, para respetar bloqueo, parry y dash.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local api = script.Parent:WaitForChild("CombateApi") :: BindableFunction

local P = Config.Poderes

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Poderes"
remoto.Parent = ReplicatedStorage

local recargas: { [Player]: { [string]: number } } = {}
local ultimoPedido: { [Player]: number } = {}

local function raizDe(personaje: Model): BasePart?
	local r = personaje:FindFirstChild("HumanoidRootPart")
	local h = personaje:FindFirstChildOfClass("Humanoid")
	if r and r:IsA("BasePart") and h and h.Health > 0 then
		return r
	end
	return nil
end

local function pegar(
	atacante: Model,
	objetivo: Model,
	danio: number,
	tipo: string,
	direccion: Vector3
)
	api:Invoke("Pegar", atacante, objetivo, danio, tipo, direccion)
end

-- Rivales dentro de una distancia y, si cono > -1, hacia adelante.
local function rivales(
	atacante: Model,
	centro: Vector3,
	frente: Vector3,
	alcance: number,
	cono: number
): { Model }
	local lista = {}
	for _, m in CollectionService:GetTagged("Combatiente") do
		if m ~= atacante and m:IsA("Model") then
			local r = raizDe(m)
			if r then
				local hacia = Vector3.new(r.Position.X - centro.X, 0, r.Position.Z - centro.Z)
				if
					hacia.Magnitude <= alcance
					and (hacia.Magnitude < 0.1 or frente:Dot(hacia.Unit) >= cono)
				then
					table.insert(lista, m)
				end
			end
		end
	end
	return lista
end

local function direccionA(desde: BasePart, m: Model): Vector3
	local r = raizDe(m)
	if not r then
		return desde.CFrame.LookVector
	end
	local d = Vector3.new(r.Position.X - desde.Position.X, 0, r.Position.Z - desde.Position.Z)
	return if d.Magnitude > 0.1 then d.Unit else desde.CFrame.LookVector
end

local function golpeArea(atacante: Model, datos: any, tipo: string, cono: number)
	local r = raizDe(atacante)
	if r then
		for _, m in rivales(atacante, r.Position, r.CFrame.LookVector, datos.Alcance, cono) do
			pegar(atacante, m, datos.Danio, tipo, direccionA(r, m))
		end
	end
end

local function quemar(atacante: Model, objetivo: Model)
	task.spawn(function()
		for _ = 1, P.QuemaVeces do
			task.wait(1)
			pegar(atacante, objetivo, P.QuemaDanio, "Suave", Vector3.zero)
		end
	end)
end

-- Capa de fuego con textura propia; el color ya viene pintado en la imagen.
local function capaFuego(parte: BasePart, textura: string, ritmo: number): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Texture = textura
	e.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	e.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
	e.LightEmission = 0.25
	e.LightInfluence = 0
	e.ZOffset = 1
	e.Rate = ritmo
	e.Parent = parte
	return e
end

local function brasas(parte: BasePart, ritmo: number)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(Color3.fromHex("#fff0b0"), Color3.fromHex("#f2652b"))
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Lifetime = NumberRange.new(0.5, 1.1)
	e.Speed = NumberRange.new(5, 14)
	e.SpreadAngle = Vector2.new(35, 35)
	e.EmissionDirection = Enum.NormalId.Top
	e.Size = NumberSequence.new(0.22, 0)
	e.Acceleration = Vector3.new(0, 10, 0)
	e.Rate = ritmo
	e.Parent = parte
end

local function luzFuego(parte: BasePart, alcance: number)
	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromHex("#ff8a30")
	luz.Brightness = 3
	luz.Range = alcance
	luz.Parent = parte
end

local function bolaDeFuego(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local frente = r.CFrame.LookVector
	local bola = Instance.new("Part")
	bola.Shape = Enum.PartType.Ball
	bola.Size = Vector3.one * 2
	bola.Transparency = 1
	bola.Anchored = true
	bola.CanCollide = false
	bola.CanQuery = false
	bola.CanTouch = false
	bola.Position = r.Position + frente * 3
	local nucleo = capaFuego(bola, Config.Efectos.BolaFuego, 30)
	nucleo.FlipbookMode = Enum.ParticleFlipbookMode.Loop
	nucleo.LockedToPart = true
	nucleo.Lifetime = NumberRange.new(0.14)
	nucleo.Speed = NumberRange.new(0)
	nucleo.Size = NumberSequence.new(8)
	nucleo.Rotation = NumberRange.new(0, 359)
	nucleo.ZOffset = 2
	local cola = capaFuego(bola, Config.Efectos.BolaFuego, 110)
	cola.FlipbookMode = Enum.ParticleFlipbookMode.Loop
	cola.Lifetime = NumberRange.new(0.22, 0.42)
	cola.Speed = NumberRange.new(1, 4)
	cola.SpreadAngle = Vector2.new(180, 180)
	cola.Size = NumberSequence.new(5.5, 0.6)
	cola.Rotation = NumberRange.new(0, 359)
	cola.Transparency = NumberSequence.new(0, 0.5)
	brasas(bola, 40)
	luzFuego(bola, 24)
	bola.Parent = workspace
	local recorrido = 0
	local conexion: RBXScriptConnection
	conexion = RunService.Heartbeat:Connect(function(dt)
		local paso = P.BolaVelocidad * dt
		recorrido += paso
		bola.Position += frente * paso
		local cerca = rivales(atacante, bola.Position, frente, 4, -1)
		if cerca[1] or recorrido >= datos.Alcance then
			conexion:Disconnect()
			remoto:FireAllClients("Explota", bola.Position)
			bola:Destroy()
			for _, m in cerca do
				pegar(atacante, m, datos.Danio, "Normal", frente)
				quemar(atacante, m)
			end
		end
	end)
end

local function muroDeFuego(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	-- Fila de llamas sobre el piso: la parte es invisible, solo sostiene el fuego.
	local muro = Instance.new("Part")
	muro.Size = Vector3.new(datos.Alcance, 0.4, 1.5)
	muro.Transparency = 1
	muro.Anchored = true
	muro.CanCollide = false
	muro.CanQuery = false
	muro.CanTouch = false
	muro.CFrame = r.CFrame * CFrame.new(0, -2.4, -8)
	local altas = capaFuego(muro, Config.Efectos.Llama, datos.Alcance * 3.5)
	altas.EmissionDirection = Enum.NormalId.Top
	altas.Lifetime = NumberRange.new(0.6, 0.95)
	altas.Speed = NumberRange.new(4, 7)
	altas.Size = NumberSequence.new(8, 10)
	local bajas = capaFuego(muro, Config.Efectos.Llama, datos.Alcance * 3)
	bajas.EmissionDirection = Enum.NormalId.Top
	bajas.Lifetime = NumberRange.new(0.4, 0.65)
	bajas.Speed = NumberRange.new(2, 4)
	bajas.Size = NumberSequence.new(4.5, 5.5)
	bajas.ZOffset = 2
	brasas(muro, datos.Alcance * 2)
	luzFuego(muro, 26)
	muro.Parent = workspace
	Debris:AddItem(muro, P.MuroDura + 1.2)
	task.delay(P.MuroDura, function()
		for _, e in muro:GetChildren() do
			if e:IsA("ParticleEmitter") then
				e.Rate = 0
			end
		end
	end)
	local frente = r.CFrame.LookVector
	for _ = 1, P.MuroDura * 2 do
		task.wait(0.5)
		for _, m in rivales(atacante, muro.Position, frente, datos.Alcance / 2 + 1, -1) do
			pegar(atacante, m, datos.Danio / 2, "Suave", Vector3.zero)
		end
	end
end

-- Cada habilidad: qué hace el servidor después de su Impacto.
local acciones: { [string]: (Model, any) -> () } = {
	PunoSismico = function(a, d)
		golpeArea(a, d, "Rompe", 0.3)
	end,
	GolpePiso = function(a, d)
		golpeArea(a, d, "Lanza", -1)
	end,
	Embestida = function(a, d)
		golpeArea(a, d, "Lanza", 0)
	end,
	Contragolpe = function(a, d)
		api:Invoke("Contra", a, d.Dura, d.Danio, d.Golpes)
	end,
	PasoFantasma = function(a, d)
		local r = raizDe(a)
		if r then
			local m = rivales(a, r.Position, r.CFrame.LookVector, d.Alcance + P.MargenRed, -1)[1]
			if m then
				pegar(a, m, d.Danio, "Lanza", direccionA(r, m))
			end
		end
	end,
	LluviaGolpes = function(a, d)
		for _ = 1, d.Golpes do
			golpeArea(a, d, "Normal", 0)
			task.wait(1 / d.Golpes)
		end
	end,
	BolaFuego = bolaDeFuego,
	Chorro = function(a, d)
		for _ = 1, d.Golpes do
			local r = raizDe(a)
			if r then
				for _, m in rivales(a, r.Position, r.CFrame.LookVector, d.Alcance, 0.6) do
					pegar(a, m, d.Danio, "Normal", direccionA(r, m))
				end
			end
			task.wait(d.Dura / d.Golpes)
		end
	end,
	MuroFuego = muroDeFuego,
}

remoto.OnServerEvent:Connect(function(jugador, pedido)
	if typeof(pedido) ~= "string" then
		return
	end
	local personaje = jugador.Character
	if not personaje or not raizDe(personaje) then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < 0.1 then
		return
	end
	ultimoPedido[jugador] = ahora
	local actual = jugador:GetAttribute("Linaje")
	if pedido == "Cambiar" then
		if P.CambioLibre and RunService:IsStudio() then
			local i = table.find(P.Orden, actual) or 0
			jugador:SetAttribute("Linaje", P.Orden[i % #P.Orden + 1])
		end
		return
	end
	if typeof(actual) ~= "string" or not (pedido == "Z" or pedido == "X" or pedido == "C") then
		return
	end
	local datos = P.Linajes[actual] and P.Linajes[actual][pedido]
	if
		not datos
		or personaje:GetAttribute("Aturdido") == true
		or personaje:GetAttribute("Frenado") == true
	then
		return
	end
	local propias = recargas[jugador] or {}
	recargas[jugador] = propias
	local clave = actual .. pedido
	local energia = (personaje:GetAttribute("Energia") :: number?) or 0
	if ahora < (propias[clave] or 0) - P.MargenRecarga or energia < datos.Energia then
		return
	end
	propias[clave] = ahora + datos.Recarga
	personaje:SetAttribute("Energia", energia - datos.Energia)
	task.delay(datos.Impacto, function()
		if personaje.Parent and personaje:GetAttribute("Aturdido") ~= true then
			remoto:FireAllClients("Efecto", personaje, datos)
			acciones[datos.Accion](personaje, datos)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(jugador)
	recargas[jugador] = nil
	ultimoPedido[jugador] = nil
end)
