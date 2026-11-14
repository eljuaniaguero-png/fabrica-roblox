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

-- ---------------------------------------------------------------------------
-- Poco comunes: Electro, Criogenia y Telequinesis (notas de la bóveda, 06 Linajes)
-- ---------------------------------------------------------------------------

local function masCercano(
	atacante: Model,
	desde: Vector3,
	alcance: number,
	excluir: { [Model]: boolean }
): Model?
	local mejor, distancia = nil, alcance
	for _, m in CollectionService:GetTagged("Combatiente") do
		if m ~= atacante and m:IsA("Model") and not excluir[m] then
			local r = raizDe(m)
			if r then
				local d = (r.Position - desde).Magnitude
				if d <= distancia then
					mejor, distancia = m, d
				end
			end
		end
	end
	return mejor
end

-- Electro Z: el rayo pega al rival de adelante y salta a los más cercanos (20 / 15 / 10).
local function rayoCadena(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local primero = rivales(atacante, r.Position, r.CFrame.LookVector, datos.Alcance, 0.5)[1]
	local puntos = { r.Position + r.CFrame.LookVector * 2 }
	local tocados: { [Model]: boolean } = {}
	local actual = primero
	for i, danio in datos.Danios do
		if not actual then
			break
		end
		local ra = raizDe(actual)
		if not ra then
			break
		end
		tocados[actual] = true
		table.insert(puntos, ra.Position)
		pegar(atacante, actual, danio, if i == 1 then "Normal" else "Suave", direccionA(r, actual))
		actual = masCercano(atacante, ra.Position, P.CadenaSalto, tocados)
	end
	if #puntos == 1 then -- nadie adelante: el rayo se pierde en el aire
		table.insert(puntos, r.Position + r.CFrame.LookVector * datos.Alcance)
	end
	remoto:FireAllClients("Rayo", puntos)
end

-- Electro X: descarga alrededor; aturde un instante.
local function descarga(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if r then
		for _, m in rivales(atacante, r.Position, r.CFrame.LookVector, datos.Alcance, -1) do
			pegar(atacante, m, datos.Danio, "Normal", direccionA(r, m))
			api:Invoke("Aturdir", m, datos.Aturde)
		end
	end
end

-- Electro C: viaja por un rayo hasta el rival de adelante (o hasta el alcance) y le pega al llegar.
local function saltoCable(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local desde = r.Position
	local frente = r.CFrame.LookVector
	local m = rivales(atacante, r.Position, frente, datos.Alcance, 0.3)[1]
	local rm = m and raizDe(m)
	local destino: Vector3
	if rm then
		destino = rm.Position - direccionA(r, m :: Model) * 3
	else
		-- Sin rival: hasta donde no haya pared.
		local filtro = RaycastParams.new()
		filtro.FilterDescendantsInstances = { atacante }
		filtro.FilterType = Enum.RaycastFilterType.Exclude
		local choque = workspace:Raycast(desde, frente * datos.Alcance, filtro)
		destino = if choque then choque.Position - frente * 2 else desde + frente * datos.Alcance
	end
	atacante:PivotTo(CFrame.lookAt(destino, destino + frente))
	remoto:FireAllClients("Rayo", { desde, destino })
	if m and rm then
		pegar(atacante, m, datos.Danio, "Normal", frente)
	end
end

-- Criogenia, pasiva Escarcha: cada carga suma; a las 5, congelado.
local escarcha: { [Model]: { cargas: number, hasta: number } } = {}

local function sumarEscarcha(m: Model, cargas: number)
	local ahora = os.clock()
	local e = escarcha[m]
	if not e or ahora > e.hasta then
		e = { cargas = 0, hasta = 0 }
		escarcha[m] = e
	end
	local actual = e :: { cargas: number, hasta: number }
	actual.cargas += cargas
	actual.hasta = ahora + P.EscarchaDura
	if actual.cargas >= P.EscarchaMax then
		escarcha[m] = nil
		m:SetAttribute("Escarcha", 0)
		api:Invoke("Aturdir", m, P.CongeladoDura)
		remoto:FireAllClients("Congelado", m, P.CongeladoDura)
	else
		m:SetAttribute("Escarcha", actual.cargas)
	end
end

-- Proyectil genérico: el servidor lo mueve invisible y resuelve el choque; cada cliente lo dibuja.
local function proyectil(
	atacante: Model,
	tipo: string,
	velocidad: number,
	alcance: number,
	alChocar: (Model, Vector3) -> ()
)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local frente = r.CFrame.LookVector
	local pos = r.Position + frente * 3
	remoto:FireAllClients("Proyectil", tipo, pos, frente, alcance, velocidad)
	local recorrido = 0
	local conexion: RBXScriptConnection
	conexion = RunService.Heartbeat:Connect(function(dt)
		local paso = velocidad * dt
		recorrido += paso
		pos += frente * paso
		local cerca = rivales(atacante, pos, frente, 4, -1)
		if cerca[1] or recorrido >= alcance then
			conexion:Disconnect()
			remoto:FireAllClients("Choca", tipo, pos)
			for _, m in cerca do
				alChocar(m, frente)
			end
		end
	end)
end

local function lanzaHielo(atacante: Model, datos: any)
	proyectil(atacante, "LanzaHielo", P.LanzaVelocidad, datos.Alcance, function(m, frente)
		pegar(atacante, m, datos.Danio, "Normal", frente)
		sumarEscarcha(m, P.LanzaEscarcha)
	end)
end

local function hielo(nombre: string, tam: Vector3, cf: CFrame, colision: boolean): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = colision
	p.CanQuery = colision
	p.CanTouch = false
	p.Material = Enum.Material.Ice
	p.Color = P.Colores.Criogenia
	p.Transparency = 0.15
	p:AddTag("HieloCriogenia")
	p.Parent = workspace
	return p
end

-- Criogenia X: muro de hielo adelante que tapa el paso unos segundos.
local function muroHielo(atacante: Model, _datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local M = P.MuroHielo
	local escala = Niveles.tamano(atacante)
	local base = r.CFrame * CFrame.new(0, -3 + M.Alto * escala / 2, -M.Distancia)
	local muro = hielo("MuroHielo", Vector3.new(M.Ancho, M.Alto, M.Grosor) * escala, base, true)
	Debris:AddItem(muro, M.Dura)
end

-- Criogenia C: pista de hielo adelante; el rival que la pisa resbala y suma Escarcha.
local function pistaHelada(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local largo = datos.Alcance
	local cf = r.CFrame * CFrame.new(0, -2.9, -largo / 2)
	local pista = hielo("PistaHelada", Vector3.new(P.PistaAncho, 0.3, largo), cf, false)
	Debris:AddItem(pista, P.PistaDura)
	local proximo: { [Model]: number } = {}
	local fin = os.clock() + P.PistaDura
	while os.clock() < fin and pista.Parent do
		for _, m in CollectionService:GetTagged("Combatiente") do
			local rm = m:IsA("Model") and m ~= atacante and raizDe(m)
			if rm and os.clock() >= (proximo[m] or 0) then
				local p = pista.CFrame:PointToObjectSpace(rm.Position)
				if
					math.abs(p.X) <= P.PistaAncho / 2 + 1
					and math.abs(p.Z) <= largo / 2
					and p.Y < 5
				then
					proximo[m] = os.clock() + 1
					sumarEscarcha(m, 1)
					local lado = pista.CFrame.RightVector * (if p.X >= 0 then 1 else -1)
					api:Invoke("Mover", m, lado * 30) -- resbala de costado
				end
			end
		end
		task.wait(0.1)
	end
end

-- Telequinesis Z: agarra el objeto suelto más cercano (tag "Suelto") y lo tira. Sin objetos
-- cerca, arranca un pedazo del piso.
local function lanzar(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local objeto: BasePart? = nil
	local mejor = P.LanzarAgarre
	for _, o in CollectionService:GetTagged("Suelto") do
		if o:IsA("BasePart") and o:IsDescendantOf(workspace) then
			local d = (o.Position - r.Position).Magnitude
			if d < mejor then
				objeto, mejor = o, d
			end
		end
	end
	local extra = 0
	if objeto then
		if objeto.AssemblyMass >= P.PesoPesado then
			extra = P.LanzarPesado
		end
		objeto:Destroy() -- lo "agarra": el que vuela lo dibuja cada cliente
	end
	local tipo = if extra > 0 then "LanzarPesado" else "Lanzar"
	proyectil(atacante, tipo, P.LanzarVelocidad, datos.Alcance, function(m, frente)
		pegar(atacante, m, datos.Danio + extra, "Lanza", frente)
	end)
end

-- Telequinesis X: levanta al rival de adelante, lo deja flotando y lo estrella contra el piso.
local function levantar(atacante: Model, datos: any)
	local r = raizDe(atacante)
	if not r then
		return
	end
	local m = rivales(atacante, r.Position, r.CFrame.LookVector, datos.Alcance, 0.4)[1]
	if not m then
		return
	end
	local rm = raizDe(m)
	if not rm then
		return
	end
	api:Invoke("Aturdir", m, datos.Dura + 0.2)
	remoto:FireAllClients("Levitar", m, datos.Dura)
	-- Lo sostiene a LevantarAltura sobre donde estaba: cada instante corrige la velocidad hacia esa
	-- altura (sube rápido y queda flotando).
	local altura = rm.Position.Y + P.LevantarAltura
	local fin = os.clock() + datos.Dura
	while os.clock() < fin and m.Parent do
		local r2 = raizDe(m)
		if not r2 then
			break
		end
		local sube = math.clamp((altura - r2.Position.Y) * 8, -20, 60)
		api:Invoke("Mover", m, Vector3.new(0, sube, 0))
		task.wait(0.05)
	end
	if m.Parent and raizDe(m) then
		pegar(atacante, m, datos.Danio, "Piso", Vector3.zero)
	end
end

-- Telequinesis C: empujón en cono que tira a todos para atrás.
local function onda(atacante: Model, datos: any)
	golpeArea(atacante, datos, "Lanza", 0.5)
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
	RayoCadena = rayoCadena,
	Descarga = descarga,
	SaltoCable = saltoCable,
	LanzaHielo = lanzaHielo,
	MuroHielo = muroHielo,
	PistaHelada = pistaHelada,
	Lanzar = lanzar,
	Levantar = levantar,
	Onda = onda,
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

CollectionService:GetInstanceRemovedSignal("Combatiente"):Connect(function(m)
	escarcha[m :: Model] = nil
end)

Players.PlayerRemoving:Connect(function(jugador)
	recargas[jugador] = nil
	ultimoPedido[jugador] = nil
end)
