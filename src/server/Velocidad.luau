--!strict
-- Cuenta pasos por distancia recorrida (medida en el servidor): suman velocidad, pasos totales
-- (dan el nivel) y pasos disponibles (se venden). Avisa a todos cuando alguien sube de nivel.
-- También publica el perfil como atributos del jugador para que el cliente lo muestre.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Datos = require(script.Parent.Datos)
local Efectos = require(script.Parent.Efectos)
local Remotos = require(script.Parent.Remotos)

local Velocidad = {}

local ultimaPosicion: { [Player]: Vector3 } = {}
local acumulado: { [Player]: number } = {}

-- Multiplicador permanente por rebirths (el que se muestra en el HUD).
function Velocidad.multiplicador(perfil: Datos.Perfil): number
	return 1 + perfil.Rebirths * Config.MultiplicadorPorRebirth
end

-- Cuánta velocidad da un paso ahora mismo, con rebirths, zapatillas y doble paso.
local function gananciaPorPaso(jugador: Player, perfil: Datos.Perfil): number
	local zapatillas = 1
		+ (perfil.Mejoras.Zapatillas or 0) * Config.Mejoras.Zapatillas.BonusPorNivel
	local doble = if Efectos.activo(jugador, "DoblePaso")
		then Config.Consumibles.DoblePaso.Factor or 1
		else 1
	return Config.PuntosPorPaso * Velocidad.multiplicador(perfil) * zapatillas * doble
end

function Velocidad.crearLeaderstats(jugador: Player)
	local carpeta = Instance.new("Folder")
	carpeta.Name = "leaderstats"
	for _, nombre in { "Nivel", "Velocidad", "Monedas", "Rebirths" } do
		local valor = Instance.new("IntValue")
		valor.Name = nombre
		valor.Parent = carpeta
	end
	carpeta.Parent = jugador
end

local function ponerStat(jugador: Player, nombre: string, valor: number)
	local stats = jugador:FindFirstChild("leaderstats")
	local stat = if stats then stats:FindFirstChild(nombre) else nil
	if stat and stat:IsA("IntValue") then
		stat.Value = math.floor(valor)
	end
end

-- Copia el perfil a atributos, leaderstats y WalkSpeed.
function Velocidad.aplicar(jugador: Player)
	local perfil = Datos.obtener(jugador)
	if not perfil then
		return
	end
	local nivel = Niveles.nivelDe(perfil.PasosTotales)
	jugador:SetAttribute("Velocidad", perfil.Velocidad)
	jugador:SetAttribute("PasosTotales", perfil.PasosTotales)
	jugador:SetAttribute("PasosDisponibles", perfil.PasosDisponibles)
	jugador:SetAttribute("Nivel", nivel)
	jugador:SetAttribute("Rebirths", perfil.Rebirths)
	jugador:SetAttribute("Multiplicador", Velocidad.multiplicador(perfil))
	jugador:SetAttribute("Checkpoint", perfil.Checkpoint)
	jugador:SetAttribute("Monedas", perfil.Monedas)
	for nombre, nivelMejora in perfil.Mejoras do
		jugador:SetAttribute(`Mej_{nombre}`, nivelMejora)
	end
	for nombre, cantidad in perfil.Inventario do
		jugador:SetAttribute(`Inv_{nombre}`, cantidad)
	end

	ponerStat(jugador, "Nivel", nivel)
	ponerStat(jugador, "Velocidad", perfil.Velocidad)
	ponerStat(jugador, "Monedas", perfil.Monedas)
	ponerStat(jugador, "Rebirths", perfil.Rebirths)

	local personaje = jugador.Character
	local humanoide = if personaje then personaje:FindFirstChildOfClass("Humanoid") else nil
	if humanoide then
		local walkSpeed = Config.WalkSpeedBase + perfil.Velocidad * Config.WalkSpeedPorPunto
		humanoide.WalkSpeed = math.min(walkSpeed, Config.WalkSpeedTope)
		humanoide.UseJumpPower = false
		humanoide.JumpHeight = Config.AlturaSaltoBase
	end
end

-- Llamar cuando el personaje se teletransporta, para no contar ese salto como pasos.
function Velocidad.olvidarPosicion(jugador: Player)
	ultimaPosicion[jugador] = nil
end

-- Mide cuánto caminó desde la última vez. Devuelve true si subió de nivel.
function Velocidad.medir(jugador: Player, dt: number): boolean
	local perfil = Datos.obtener(jugador)
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	local humanoide = if personaje then personaje:FindFirstChildOfClass("Humanoid") else nil
	if
		not perfil
		or not raiz
		or not raiz:IsA("BasePart")
		or not humanoide
		or humanoide.Health <= 0
	then
		ultimaPosicion[jugador] = nil
		return false
	end

	local posicion = raiz.Position * Vector3.new(1, 0, 1)
	local anterior = ultimaPosicion[jugador]
	ultimaPosicion[jugador] = posicion
	if not anterior then
		return false
	end

	local distancia = (posicion - anterior).Magnitude
	local maximo = Config.WalkSpeedTope * dt * Config.ToleranciaTeletransporte
	if distancia > maximo then
		return false
	end

	local total = (acumulado[jugador] or 0) + distancia
	local pasos = math.floor(total / Config.DistanciaPorPaso)
	acumulado[jugador] = total - pasos * Config.DistanciaPorPaso
	if pasos == 0 then
		return false
	end

	local nivelAntes = Niveles.nivelDe(perfil.PasosTotales)
	perfil.PasosTotales += pasos
	perfil.PasosDisponibles += pasos
	perfil.Velocidad += pasos * gananciaPorPaso(jugador, perfil)
	Velocidad.aplicar(jugador)

	local nivel = Niveles.nivelDe(perfil.PasosTotales)
	if nivel > nivelAntes then
		-- Todos ven el efecto alrededor del personaje; el cartel y el sonido son solo para él.
		Remotos.SubioNivel:FireAllClients(jugador, nivel)
		return true
	end
	return false
end

function Velocidad.olvidar(jugador: Player)
	ultimaPosicion[jugador] = nil
	acumulado[jugador] = nil
end

return Velocidad
