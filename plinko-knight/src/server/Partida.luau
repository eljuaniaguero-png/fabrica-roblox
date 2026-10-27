--!strict
-- La partida de cada jugador, en el servidor: la mazmorra (piso, vidas, fase, tablero de
-- clavijas, bola y oro, todo en Estado), el tiro en curso y su progreso guardado (Progreso, lo
-- carga server/Guardado). La partida en curso no se guarda: si sale a la mitad, empieza de cero.

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Progreso = require(Shared:WaitForChild("Progreso"))

export type Partida = {
	Estado: Mazmorra.Estado,
	NumeroTiro: number, -- el último tiro pedido (no vuelve a 0 al reiniciar la mazmorra)
	Semilla: number?, -- semilla del tiro pedido; nil si no hay uno pendiente
	UltimoTiro: number, -- os.clock() del último tiro aceptado
	UltimoVolver: number, -- os.clock() del último "Volver a bajar"
	Bola: string, -- la bola con la que baja (la elige en la fase "inicio")
	Progreso: Progreso.Datos, -- lo que se guarda (mejor piso, desbloqueos, logros…)
	UltimaAccion: number, -- os.clock() de la última compra / pergamino (límite de frecuencia)
}

local Partida = {}

local partidas: { [Player]: Partida } = {}
local azar = Random.new()

function Partida.nuevaPelea(p: Partida)
	Mazmorra.empezarPelea(p.Estado)
end

-- Partida nueva: se sortean las mañas de los jefes.
local function sortear(p: Partida)
	Mazmorra.sortearManias(p.Estado, azar:NextInteger(1, 2 ^ 31 - 1))
end

-- Semilla para las cartas que salen y las clavijas que convierte una carta.
function Partida.semilla(): number
	return azar:NextInteger(1, 2 ^ 31 - 1)
end

function Partida.de(jugador: Player): Partida?
	return partidas[jugador]
end

-- Con el progreso ya cargado: la partida arranca en la fase "inicio" (elegir bola).
function Partida.iniciar(jugador: Player, datos: Progreso.Datos): Partida
	local bola = if Progreso.tieneBola(datos, datos.BolaElegida)
		then datos.BolaElegida
		else "hierro"
	local p: Partida = {
		Estado = Mazmorra.nueva(bola, datos.ReliquiasDesbloqueadas),
		NumeroTiro = 0,
		Semilla = nil,
		UltimoTiro = -math.huge,
		UltimoVolver = -math.huge,
		Bola = bola,
		UltimaAccion = -math.huge,
		Progreso = datos,
	}
	sortear(p)
	p.Estado.Fase = "inicio"
	partidas[jugador] = p
	return p
end

-- Mazmorra nueva desde el piso 1 con la bola elegida: tablero todo gris otra vez, sin el tiro
-- pendiente y con las reliquias desbloqueadas hasta ahora. La primera partida del jugador arranca
-- con el monstruo de práctica (piso 0, etapa 11).
function Partida.empezar(p: Partida, bola: string)
	p.Bola = bola
	local practica = p.Progreso.PartidasJugadas == 0
	p.Estado = Mazmorra.nueva(bola, p.Progreso.ReliquiasDesbloqueadas, practica)
	p.Semilla = nil
	sortear(p)
	Progreso.alEmpezar(p.Progreso, bola)
end

function Partida.quitar(jugador: Player)
	partidas[jugador] = nil
end

return Partida
