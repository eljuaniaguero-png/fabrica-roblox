--!strict
-- Remotos de la mazmorra (los tiros están en Tiros.luau):
--   ObtenerEstado() -> Mazmorra.Estado
--   VolverABajar() -> Mazmorra.Estado  (solo después de perder o de ganar la mazmorra)
--   Tienda(accion, indice, clavijas) -> (Mazmorra.Estado, error?)  acciones: "comprar" (el ítem
--   indice; clavijas = { id } para una mejora de clavija), "vender" (la reliquia del lugar indice),
--   "mover" (la reliquia del lugar indice al lugar que viene en clavijas), "renovar" y "bajar"
--   UsarPergamino(lugar, clavijas) -> (Mazmorra.Estado, error?)  (en la pelea o en la tienda)
--   Todo lo valida shared/Tienda; si no se puede, devuelve el estado como está y el motivo.
--   EstadoCambio (servidor -> cliente): el estado cambió fuera de un tiro (comandos de prueba)
--   Prueba(comando, n) (SOLO existe en Studio): "piso" salta a la pelea n (7 = el jefe), "vida"
--   te pone n de vida, "bola" cambia a la bola n de Config.OrdenBolas, "clavija" convierte
--   grises en el tipo n de Config.OrdenClavijas, "nivel" sube 1 nivel todos los tipos, "oro" da n
--   de oro, "pergamino" agrega el pergamino n de Tienda.pergaminosPosibles y "reliquia" agrega la
--   n de Config.OrdenReliquias. El cliente lo manda con las teclas 1 a 7, 0, Z, X, C, 8, 9 y R
--   (ver Main.client).
-- Con teclas y no con el chat porque este place usa el chat viejo, que Roblox ya no carga.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local TiendaModulo = require(Shared:WaitForChild("Tienda"))
local Reliquias = require(Shared:WaitForChild("Reliquias"))
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
	if not p or (p.Estado.Fase ~= "peleando" and p.Estado.Fase ~= "tienda") then
		return
	end
	local e = p.Estado
	if comando == "oro" then
		e.Oro += math.floor(n)
	elseif comando == "reliquia" then
		local id = Config.OrdenReliquias[(math.floor(n) - 1) % #Config.OrdenReliquias + 1]
		if #e.Reliquias < Config.LugaresReliquia and not Reliquias.tiene(e.Reliquias, id) then
			table.insert(e.Reliquias, { Id = id, Contador = 0, Precio = Reliquias.precio(id) })
		end
	elseif comando == "pergamino" then
		local posibles = TiendaModulo.pergaminosPosibles()
		local elegido = posibles[(math.floor(n) - 1) % #posibles + 1]
		if #e.Pergaminos < Config.LugaresPergamino then
			table.insert(e.Pergaminos, elegido.Id)
		end
	elseif comando == "bola" then
		local bola = Config.OrdenBolas[math.floor(n)]
		if bola then
			p.Bola = bola
			e.Bola = bola
		end
	elseif comando == "clavija" then
		local tipo = Config.OrdenClavijas[math.floor(n)]
		if tipo then
			Clavijas.convertir(e.Tablero, tipo, 2, Partida.semilla())
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

	-- Límite de frecuencia de compras y pergaminos (además de lo que valida shared/Tienda).
	local function puedeActuar(p: Partida.Partida): boolean
		local ahora = os.clock()
		if ahora - p.UltimaAccion < Config.Servidor.TiempoMinimoAccion then
			return false
		end
		p.UltimaAccion = ahora
		return true
	end

	local tienda = Instance.new("RemoteFunction")
	tienda.Name = "Tienda"
	tienda.OnServerInvoke = function(
		jugador: Player,
		accion: any,
		indice: any,
		clavijas: any
	): (Mazmorra.Estado?, string?)
		local p = Partida.de(jugador)
		if not p then
			return nil, nil
		end
		if not puedeActuar(p) then
			return Mazmorra.copiar(p.Estado), "Más despacio"
		end
		local ok, motivo = false, "Acción desconocida"
		if accion == "comprar" then
			ok, motivo = TiendaModulo.comprar(p.Estado, indice, clavijas)
		elseif accion == "vender" then
			ok, motivo = TiendaModulo.vender(p.Estado, indice)
		elseif accion == "mover" then
			ok, motivo = TiendaModulo.mover(p.Estado, indice, clavijas) -- de lugar indice a lugar clavijas
		elseif accion == "renovar" then
			ok, motivo = TiendaModulo.renovar(p.Estado, Partida.semilla())
		elseif accion == "bajar" then
			ok = TiendaModulo.bajar(p.Estado)
			motivo = if ok then nil else "La tienda está cerrada"
			if ok then
				p.Semilla = nil
			end
		end
		return Mazmorra.copiar(p.Estado), if ok then nil else motivo
	end
	tienda.Parent = carpeta

	local usar = Instance.new("RemoteFunction")
	usar.Name = "UsarPergamino"
	usar.OnServerInvoke = function(
		jugador: Player,
		lugar: any,
		clavijas: any
	): (Mazmorra.Estado?, string?)
		local p = Partida.de(jugador)
		if not p then
			return nil, nil
		end
		if not puedeActuar(p) then
			return Mazmorra.copiar(p.Estado), "Más despacio"
		end
		local ok, motivo = TiendaModulo.usar(p.Estado, lugar, clavijas)
		if ok then
			-- El tablero o la furia cambiaron: el tiro pedido (si había) se anula y se pide otro.
			p.Semilla = nil
		end
		return Mazmorra.copiar(p.Estado), if ok then nil else motivo
	end
	usar.Parent = carpeta

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
			elseif
				comando == "bola"
				or comando == "clavija"
				or comando == "nivel"
				or comando == "oro"
				or comando == "pergamino"
				or comando == "reliquia"
			then
				Peleas.probar(jugador, comando, n)
			end
		end)
		prueba.Parent = carpeta
	end
end

return Peleas
