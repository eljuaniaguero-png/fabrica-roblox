--!strict
-- Remotos de los tiros. El cliente pide un tiro (recibe número y semilla), simula y dibuja, y
-- al terminar manda el ángulo y el daño que vio. El servidor revisa el daño, juega el turno de la
-- mazmorra (golpe al monstruo y contraataque) y devuelve qué pasó para que el cliente lo anime.
--   PedirTiro() -> (numeroTiro, semilla)  (nil si no estás peleando)
--   Tirar(numeroTiro, angulo, danioVisto) -> Mazmorra.Turno  (nil si el pedido no es válido)
-- El tablero de clavijas, los niveles y la bola los pone el servidor desde la partida: el
-- cliente no los manda. El oro de las doradas y las azules rotas también salen de la revisión.
-- La furia (pergamino) se gasta en este tiro. Al ganar una pelea, el turno vuelve con la fase
-- "tienda" y lo que hay en la tienda. Al ganar una pelea, el turno vuelve con la fase "eligiendo" y las cartas ofrecidas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local TiendaModulo = require(Shared:WaitForChild("Tienda"))
local Revision = require(Shared:WaitForChild("Revision"))
local TableroModulo = require(Shared:WaitForChild("Tablero"))
local Partida = require(script.Parent:WaitForChild("Partida"))

local Tiros = {}

local tablero = TableroModulo.generar()
local azar = Random.new()

local function numeroValido(x: any): boolean
	return typeof(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge
end

local function pedirTiro(jugador: Player): (number?, number?)
	local p = Partida.de(jugador)
	if not p or p.Estado.Fase ~= "peleando" then
		return nil, nil
	end
	-- Si ya hay un tiro pendiente se devuelve el mismo: pedir de nuevo no cambia la semilla.
	if p.Semilla == nil then
		p.NumeroTiro += 1
		p.Semilla = azar:NextInteger(1, 2 ^ 31 - 1)
	end
	return p.NumeroTiro, p.Semilla
end

local function tirar(
	jugador: Player,
	numeroTiro: any,
	angulo: any,
	danioVisto: any
): Mazmorra.Turno?
	local p = Partida.de(jugador)
	if not p or p.Estado.Fase ~= "peleando" then
		return nil
	end
	if not (numeroValido(numeroTiro) and numeroValido(angulo) and numeroValido(danioVisto)) then
		return nil
	end
	local semilla = p.Semilla
	if semilla == nil or numeroTiro ~= p.NumeroTiro then
		return nil -- no es el tiro que corresponde
	end
	if math.abs(angulo) > Config.Punteria.AnguloMaximo then
		return nil
	end
	local ahora = os.clock()
	if ahora - p.UltimoTiro < Config.Servidor.TiempoMinimoEntreTiros then
		return nil
	end
	p.UltimoTiro = ahora
	p.Semilla = nil

	local e = p.Estado
	local r = Revision.revisar(tablero, angulo, semilla, Mazmorra.modificadores(e), danioVisto)
	if r.Corregido then
		warn(
			("[Tiros] %s dijo %s de daño en el tiro %d; el servidor calculó %d y usa ese."):format(
				jugador.Name,
				tostring(danioVisto),
				numeroTiro,
				r.DanioServidor
			)
		)
	end
	Mazmorra.cobrarTiro(e, r.Oro, r.Rotas)
	e.Furia = false
	local turno = Mazmorra.turno(e, r.Danio, r.Quemadura)
	if e.Fase == "tienda" then
		TiendaModulo.abrir(e, Partida.semilla())
		turno.Estado = Mazmorra.copiar(e)
	end
	return turno
end

function Tiros.iniciar()
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Remotos"

	local pedir = Instance.new("RemoteFunction")
	pedir.Name = "PedirTiro"
	pedir.OnServerInvoke = pedirTiro
	pedir.Parent = carpeta

	local tirarRemoto = Instance.new("RemoteFunction")
	tirarRemoto.Name = "Tirar"
	tirarRemoto.OnServerInvoke = tirar
	tirarRemoto.Parent = carpeta

	carpeta.Parent = ReplicatedStorage
end

return Tiros
