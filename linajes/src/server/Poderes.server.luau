--!strict
-- Habilidades Z, X y C de los Linajes. El servidor valida Linaje, recarga, energía y alcance.
-- El daño pasa por la API de Combate.server.luau, para respetar bloqueo, parry y dash.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
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
	local radio = alcance * Niveles.tamano(atacante)
	for _, m in CollectionService:GetTagged("Combatiente") do
		if m ~= atacante and m:IsA("Model") then
			local r = raizDe(m)
			if r then
				local hacia = Vector3.new(r.Position.X - centro.X, 0, r.Position.Z - centro.Z)
				if
					hacia.Magnitude <= radio
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
	bola:SetAttribute("Escala", Niveles.tamano(atacante))
	bola:AddTag("BolaFuego") -- el fuego lo dibuja cada cliente (client/Fuego.luau)
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
			remoto:FireAllClients("Explota", bola.Position, Niveles.tamano(atacante))
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
	-- Parte invisible sobre el piso: el fuego lo dibuja cada cliente (client/Fuego.luau).
	local muro = Instance.new("Part")
	local ancho = datos.Alcance * Niveles.tamano(atacante)
	muro.Size = Vector3.new(ancho, 0.4, 1.5)
	muro.Transparency = 1
	muro.Anchored = true
	muro.CanCollide = false
	muro.CanQuery = false
	muro.CanTouch = false
	muro.CFrame = r.CFrame * CFrame.new(0, -2.4, -Config.Efectos.Fuego.MuroDistancia)
	muro:SetAttribute("Dura", P.MuroDura)
	muro:SetAttribute("Escala", Niveles.tamano(atacante))
	muro:AddTag("MuroFuego")
	muro.Parent = workspace
	Debris:AddItem(muro, P.MuroDura + 1.4)
	-- Barrera: quien la toca se quema y sale despedido hacia el lado del que vino.
	local proximo: { [Model]: number } = {}
	local fin = os.clock() + P.MuroDura
	while os.clock() < fin do
		for _, m in CollectionService:GetTagged("Combatiente") do
			local rm = m:IsA("Model") and m ~= atacante and raizDe(m)
			if rm and os.clock() >= (proximo[m] or 0) then
				local p = muro.CFrame:PointToObjectSpace(rm.Position)
				if math.abs(p.X) <= ancho / 2 + 1 and math.abs(p.Z) <= P.MuroGrosor then
					local primera = proximo[m] == nil
					proximo[m] = os.clock() + 1
					local lado = if p.Z <= 0 then 1 else -1
					pegar(atacante, m, datos.Danio, "Lanza", muro.CFrame.LookVector * lado)
					if primera then
						quemar(atacante, m)
					end
				end
			end
		end
		task.wait(0.1)
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
	if datos.Accion == "BolaFuego" then
		remoto:FireAllClients("Carga", personaje, datos)
	end
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
