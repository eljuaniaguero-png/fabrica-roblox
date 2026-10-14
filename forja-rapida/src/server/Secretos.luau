--!strict
-- Secretos de los biomas (Grupo 3). Nada de esto hace falta para avanzar: premia al que explora.
--   Llaves     al romper geodas de un bioma, 1 en GameConfig.Secretos.LlaveUnoEn de encontrar su
--              llave (si todavía no abriste su puerta y no la tenés).
--   Puertas    parte con tag "PuertaSecreta" (atributo Zona): con la llave se abre para siempre
--              (para ese jugador: el cliente la hace atravesable). Adentro hay una cámara.
--   Cofres     tag "Cofre" (Zona, Id): se abre una vez y da monedas.
--   Vetas      puntos de geoda con Tamano = "Oculta" y Secreto = zona (ver GeodeServerService).
--   Altares    tag "Altar" (Zona): ofrecés gemas comunes del bioma y te da una bendición de
--              suerte por un rato y una pista para encontrar la puerta secreta.
--   Portales   tag "Portal" (Destino = nombre de una parte con tag "DestinoPortal"): te lleva a
--              la Dimensión Prisma y de vuelta. Pide tener abierta la zona del portal (Zona).
-- Todo lo valida el servidor: distancia, zona abierta, llave, que el cofre no esté abierto,
-- la espera del altar y la de los portales. Las interacciones son ProximityPrompts.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Jugadores = require(script.Parent.Jugadores)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

local S = GameConfig.Secretos
local rng = Random.new()

local Secretos = {}

local ultimoPortal: { [Player]: number } = {}

local function aviso(jugador: Player, texto: string)
	Remotos.Aviso:FireClient(jugador, texto)
end

local function hito(
	jugador: Player,
	titulo: string,
	nombre: string,
	descripcion: string,
	monedas: number?
)
	Remotos.Hitos:FireClient(jugador, {
		{
			Id = titulo,
			Titulo = titulo,
			Nombre = nombre,
			Descripcion = descripcion,
			Monedas = monedas,
			Coleccion = false,
		},
	})
end

-- ¿Está vivo y a menos de Distancia de la parte?
local function cerca(jugador: Player, parte: BasePart): boolean
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not humanoide or humanoide.Health <= 0 or not raiz or not raiz:IsA("BasePart") then
		return false
	end
	local radio = math.max(parte.Size.X, parte.Size.Y, parte.Size.Z) / 2
	return (raiz.Position - parte.Position).Magnitude - radio <= S.Distancia
end

local function zonaDe(parte: Instance): number?
	local z = parte:GetAttribute("Zona")
	return if typeof(z) == "number" and Reglas.zona(z) then z else nil
end

local function pedido(
	parte: BasePart,
	accion: string,
	objeto: string,
	espera: number
): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.ActionText = accion
	p.ObjectText = objeto
	p.HoldDuration = espera
	p.MaxActivationDistance = S.Distancia - 2
	p.RequiresLineOfSight = false
	p.Parent = parte
	return p
end

-- Llaves -----------------------------------------------------------------------------------

Mundo.alRomper(function(r: Mundo.Rotura)
	local t = Reglas.tamano(r.Tamano)
	-- solo las geodas comunes del bioma (no las de eventos ni las ocultas)
	if not t or t.Peso <= 0 and r.Tamano ~= "Jefe" then
		return
	end
	local zona = Reglas.zona(r.Zona)
	if not zona then
		return
	end
	for _, jugador in r.Premiados do
		local d = Jugadores.obtener(jugador)
		if
			d
			and not d.Secretos[r.Zona]
			and not d.Llaves[r.Zona]
			and rng:NextNumber() < Jugadores.bonos(d).Llaves / S.LlaveUnoEn
		then
			d.Llaves[r.Zona] = true
			Jugadores.publicar(jugador)
			hito(
				jugador,
				"¡Encontraste una llave!",
				"Llave de " .. zona.Nombre,
				"Abre la puerta secreta de este bioma: buscá una pared con grietas que brillan",
				nil
			)
		end
	end
end)

-- Puertas secretas -------------------------------------------------------------------------

local function puerta(parte: BasePart)
	local zona = zonaDe(parte)
	if not zona then
		return
	end
	local z = Reglas.zona(zona) :: GameConfig.Zona
	local prompt = pedido(parte, "Revisar", "Pared extraña", 0.6)
	prompt.Triggered:Connect(function(jugador: Player)
		local d = Jugadores.obtener(jugador)
		if not d or not d.Zonas[zona] or not cerca(jugador, parte) then
			return
		end
		if d.Secretos[zona] then
			aviso(jugador, "Ya abriste esta puerta secreta")
			return
		end
		if not d.Llaves[zona] then
			aviso(
				jugador,
				("Suena hueca... Necesitás la Llave de %s (sale rompiendo geodas de acá)"):format(
					z.Nombre
				)
			)
			return
		end
		d.Llaves[zona] = nil -- la llave se gasta y la puerta queda abierta para siempre
		d.Secretos[zona] = true
		Jugadores.publicar(jugador)
		Remotos.Secreto:FireClient(jugador, "Puerta", zona)
		Mundo.avisarAccion(jugador, "Puerta")
		hito(
			jugador,
			"¡Puerta secreta abierta!",
			"Cámara de " .. z.Nombre,
			"Adentro hay un cofre y una veta de un mineral secreto",
			nil
		)
	end)
end

-- Cofres -----------------------------------------------------------------------------------

local function cofre(parte: BasePart)
	local zona = zonaDe(parte)
	local id = parte:GetAttribute("Id")
	if not zona or typeof(id) ~= "string" then
		return
	end
	local z = Reglas.zona(zona) :: GameConfig.Zona
	local prompt = pedido(parte, "Abrir", "Cofre del tesoro", 1)
	prompt.Triggered:Connect(function(jugador: Player)
		local d = Jugadores.obtener(jugador)
		if not d or not d.Secretos[zona] or not cerca(jugador, parte) then
			return
		end
		if d.Cofres[id] then
			aviso(jugador, "Este cofre ya lo abriste")
			return
		end
		d.Cofres[id] = true -- primero se marca, después se paga
		local monto = math.floor(Reglas.valorComun(zona) * S.CofreMonedas)
		d.Monedas += monto
		Jugadores.publicar(jugador)
		Remotos.Premio:FireClient(jugador, monto)
		Remotos.Secreto:FireClient(jugador, "Cofre", zona)
		Mundo.avisarAccion(jugador, "Cofre")
		hito(
			jugador,
			"¡Tesoro!",
			"Cofre de " .. z.Nombre,
			"+" .. Formato.corto(monto) .. " Monedas",
			monto
		)
	end)
end

-- Altares ----------------------------------------------------------------------------------

local function altar(parte: BasePart)
	local zona = zonaDe(parte)
	if not zona then
		return
	end
	local comun = Reglas.gemaDe(zona, "Comun")
	if not comun then
		return
	end
	local A = S.Altar
	local prompt =
		pedido(parte, ("Ofrecer %d %s"):format(A.Gemas, comun.Nombre), "Altar misterioso", 1)
	prompt.Triggered:Connect(function(jugador: Player)
		local d = Jugadores.obtener(jugador)
		if not d or not d.Zonas[zona] or not cerca(jugador, parte) then
			return
		end
		local ahora = Workspace:GetServerTimeNow()
		local falta = d.UltimoAltar + A.Espera - ahora
		if falta > 0 then
			aviso(
				jugador,
				("El altar descansa. Volvé en %d:%02d"):format(falta // 60, math.floor(falta % 60))
			)
			return
		end
		if (d.Mochila[comun.Id] or 0) < A.Gemas then
			aviso(jugador, ("El altar pide %d %s de tu mochila"):format(A.Gemas, comun.Nombre))
			return
		end
		d.Mochila[comun.Id] -= A.Gemas
		if d.Mochila[comun.Id] <= 0 then
			d.Mochila[comun.Id] = nil
		end
		d.UltimoAltar = ahora
		d.BendicionFin = ahora + A.Duracion
		Jugadores.publicar(jugador)
		Remotos.Secreto:FireClient(jugador, "Altar", zona)
		Mundo.avisarAccion(jugador, "Altar")
		hito(
			jugador,
			"Bendición del altar",
			("Suerte %s por %d minutos"):format(Formato.suerte(A.Suerte), A.Duracion // 60),
			S.Pistas[zona] or "",
			nil
		)
	end)
end

-- Portales ---------------------------------------------------------------------------------

local function portal(parte: BasePart)
	local destino = parte:GetAttribute("Destino")
	local zona = zonaDe(parte) or 1
	if typeof(destino) ~= "string" then
		return
	end
	parte.Touched:Connect(function(otra: BasePart)
		local personaje = otra.Parent
		local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
		if not jugador or not personaje or not personaje:IsA("Model") then
			return
		end
		local d = Jugadores.obtener(jugador)
		local ahora = os.clock()
		if
			not d
			or not d.Zonas[zona]
			or (ultimoPortal[jugador] and ahora - ultimoPortal[jugador] < S.PortalEspera)
		then
			return
		end
		if not cerca(jugador, parte) then
			return
		end
		for _, llegada in CollectionService:GetTagged("DestinoPortal") do
			if llegada:IsA("BasePart") and llegada:GetAttribute("Nombre") == destino then
				ultimoPortal[jugador] = ahora
				personaje:PivotTo(llegada.CFrame + Vector3.new(0, 4, 0))
				Remotos.Secreto:FireClient(jugador, "Portal", zona)
				Mundo.avisarAccion(jugador, "Portal")
				return
			end
		end
	end)
end

local function seguir(tag: string, fn: (BasePart) -> ())
	local function agregar(i: Instance)
		if i:IsA("BasePart") then
			fn(i)
		end
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(agregar)
	for _, i in CollectionService:GetTagged(tag) do
		agregar(i)
	end
end

function Secretos.iniciar()
	seguir("PuertaSecreta", puerta)
	seguir("Cofre", cofre)
	seguir("Altar", altar)
	seguir("Portal", portal)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimoPortal[jugador] = nil
	end)
end

return Secretos
