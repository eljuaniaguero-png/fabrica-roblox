--!strict
-- Rebirth: el cliente lo pide, el servidor valida. Vuelve la velocidad a 0 y sube el multiplicador.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Datos = require(script.Parent.Datos)
local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Rebirth = {}

local ultimoPedido: { [Player]: number } = {}

local function alPedir(jugador: Player)
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < Config.EsperaRebirth then
		return
	end
	ultimoPedido[jugador] = ahora

	local perfil = Datos.obtener(jugador)
	if not perfil or perfil.Velocidad < Config.CostoRebirth then
		return
	end

	perfil.Velocidad = 0
	perfil.Rebirths += 1
	perfil.Checkpoint = 0
	Velocidad.aplicar(jugador)
	Puertas.actualizarNivel(jugador)
	Puertas.teletransportar(jugador)
	Remotos.avisar(jugador, `¡Rebirth! Ahora ganás x{Velocidad.multiplicador(perfil)}`)
end

function Rebirth.iniciar()
	Remotos.PedirRebirth.OnServerEvent:Connect(alPedir)
end

function Rebirth.olvidar(jugador: Player)
	ultimoPedido[jugador] = nil
end

return Rebirth
