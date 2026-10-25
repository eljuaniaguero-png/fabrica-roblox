--!strict
-- Remotos de la mazmorra (los tiros están en Tiros.luau):
--   ObtenerEstado() -> Mazmorra.Estado
--   VolverABajar() -> Mazmorra.Estado  (solo después de perder o de ganar la mazmorra)
--   ElegirCarta(tipo) -> (Mazmorra.Estado, ids convertidos)  (solo en la fase "eligiendo" y si
--   tipo es una de las cartas ofrecidas; si no, devuelve el estado como está y nil)
--   EstadoCambio (servidor -> cliente): el estado cambió fuera de un tiro (comandos de prueba)
--   Prueba(comando, n) (SOLO existe en Studio): "piso" salta a la pelea n (7 = el jefe), "vida"
--   te pone n de vida, "bola" cambia a la bola n de Config.OrdenBolas, "clavija" convierte
--   grises en el tipo n de Config.OrdenClavijas y "nivel" sube 1 nivel todos los tipos. El
--   cliente lo manda con las teclas 1 a 7, 0, Z, X y C (ver Main.client).
-- Con teclas y no con el chat porque este place usa el chat viejo, que Roblox ya no carga.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Partida = require(script.Parent:WaitForChild("Partida"))

local Peleas = {}

local estadoCambio: RemoteEvent

local function avisar(jugador: Player, p: Partida.Partida)
	estadoCambio:FireClient(jugador, Mazmorra.copiar(p.Estado))
end

-- Comando de prueba: salta a la pelea del piso pedido (con el tiro pendiente anulado).
function Peleas.saltarAPiso(jugador: Player, piso: number)
	local p = Partida.de(jugador)
	if not p then
		return
	end
	Mazmorra.irAPiso(p.Estado, piso)
	Partida.nuevaPelea(p)
	p.Semilla = nil
	avisar(jugador, p)
end

-- Comandos de prueba de clavijas y bolas (sin ganar la pelea).
function Peleas.probar(jugador: Player, comando: string, n: number)
	local p = Partida.de(jugador)
	if not p or p.Estado.Fase ~= "peleando" then
		return
	end
	local e = p.Estado
	if comando == "bola" then
		local bola = Config.OrdenBolas[math.floor(n)]
		if bola then
			p.Bola = bola
			e.Bola = bola
		end
	elseif comando == "clavija" then
		local tipo = Config.OrdenClavijas[math.floor(n)]
		if tipo then
			Clavijas.convertir(e.Tablero, tipo, Config.Cartas.ClavijasPorCarta, Partida.semilla())
		end
	elseif comando == "nivel" then
		for tipo in Config.Clavijas do
			e.Niveles[tipo] = Clavijas.nivel(e.Niveles, tipo) + 1
		end
	end
	p.Semilla = nil
	avisar(jugador, p)
end

-- Comando de prueba: pone la vida del caballero (para llegar al jefe sin mejoras).
function Peleas.ponerVida(jugador: Player, vida: number)
	local p = Partida.de(jugador)
	if not p then
		return
	end
	p.Estado.Vida = math.max(math.floor(vida), 1)
	p.Estado.VidaMaxima = math.max(p.Estado.VidaMaxima, p.Estado.Vida)
	avisar(jugador, p)
end

function Peleas.iniciar()
	local carpeta = ReplicatedStorage:WaitForChild("Remotos")

	local obtener = Instance.new("RemoteFunction")
	obtener.Name = "ObtenerEstado"
	obtener.OnServerInvoke = function(jugador: Player): Mazmorra.Estado?
		local p = Partida.de(jugador)
		return if p then Mazmorra.copiar(p.Estado) else nil
	end
	obtener.Parent = carpeta

	local volver = Instance.new("RemoteFunction")
	volver.Name = "VolverABajar"
	volver.OnServerInvoke = function(jugador: Player): Mazmorra.Estado?
		local p = Partida.de(jugador)
		if not p then
			return nil
		end
		local ahora = os.clock()
		local fase = p.Estado.Fase
		if
			(fase ~= "perdio" and fase ~= "gano")
			or ahora - p.UltimoVolver < Config.Servidor.TiempoMinimoVolver
		then
			return Mazmorra.copiar(p.Estado) -- no se puede: se devuelve como está
		end
		p.UltimoVolver = ahora
		Partida.reiniciar(p)
		return Mazmorra.copiar(p.Estado)
	end
	volver.Parent = carpeta

	local elegir = Instance.new("RemoteFunction")
	elegir.Name = "ElegirCarta"
	elegir.OnServerInvoke = function(jugador: Player, tipo: any): (Mazmorra.Estado?, { number }?)
		local p = Partida.de(jugador)
		if not p then
			return nil, nil
		end
		-- Mazmorra.elegir valida la fase, el tipo y que sea una de las cartas ofrecidas.
		local ids = Mazmorra.elegir(p.Estado, tipo, Partida.semilla())
		if ids then
			Partida.nuevaPelea(p)
			p.Semilla = nil
		end
		return Mazmorra.copiar(p.Estado), ids
	end
	elegir.Parent = carpeta

	estadoCambio = Instance.new("RemoteEvent")
	estadoCambio.Name = "EstadoCambio"
	estadoCambio.Parent = carpeta

	if RunService:IsStudio() then
		local prueba = Instance.new("RemoteEvent")
		prueba.Name = "Prueba"
		prueba.OnServerEvent:Connect(function(jugador: Player, comando: any, n: any)
			if typeof(n) ~= "number" or n ~= n or math.abs(n) == math.huge then
				return
			end
			if comando == "piso" then
				Peleas.saltarAPiso(jugador, n)
			elseif comando == "vida" then
				Peleas.ponerVida(jugador, n)
			elseif comando == "bola" or comando == "clavija" or comando == "nivel" then
				Peleas.probar(jugador, comando, n)
			end
		end)
		prueba.Parent = carpeta
	end
end

return Peleas
