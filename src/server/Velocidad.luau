--!strict
-- Suma los pasos de cada baldosa apagada que pisás: velocidad, pasos totales (dan el nivel)
-- y pasos disponibles (se venden). Avisa a todos cuando alguien sube de nivel.
-- También publica el perfil como atributos del jugador para que el cliente lo muestre.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Datos = require(script.Parent.Datos)
local Efectos = require(script.Parent.Efectos)
local Remotos = require(script.Parent.Remotos)

local Velocidad = {}

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

-- Suma los pasos de una baldosa apagada que pisó (ya validada en Pisadas.luau).
-- Devuelve true si subió de nivel.
function Velocidad.sumarPisada(jugador: Player): boolean
	local perfil = Datos.obtener(jugador)
	if not perfil then
		return false
	end
	local pasos = Config.PasosPorBaldosa

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

return Velocidad
