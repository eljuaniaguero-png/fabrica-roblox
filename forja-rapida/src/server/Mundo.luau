--!strict
-- Lo que comparten los sistemas del mundo: el evento que está pasando ahora (Eventos.luau lo
-- pone y GeodeServerService lo usa para las chances, las gemas y la suerte) y avisos de lo
-- que pasa con las geodas (para eventos, récords y clasificaciones). Así ningún módulo
-- necesita a los otros.
-- Los clientes ven el estado en ReplicatedStorage.EstadoMundo (atributos): Evento, EventoFin,
-- Proximo, ProximoInicio, Progreso, Meta, JefeVida, JefeVidaMax, JefeTop y RecordJefe.
-- Los tiempos son de workspace:GetServerTimeNow(), iguales en el servidor y en los clientes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

type Evento = GameConfig.Evento

-- Una geoda que se rompió.
export type Rotura = {
	Modelo: Model,
	Zona: number,
	Tamano: string,
	Modificador: string,
	Danio: { [Player]: number }, -- cuánto le hizo cada uno
	Premiados: { Player }, -- los que se llevaron gema
}

-- Una gema que le salió a un jugador.
export type Revelado = {
	Jugador: Player,
	Gema: string,
	Rareza: string,
	UnoEn: number,
	Modificador: string,
	Unidades: number,
}

local estado = Instance.new("Folder")
estado.Name = "EstadoMundo"
estado.Parent = ReplicatedStorage

local actual: Evento? = nil
local alRomper: { (Rotura) -> () } = {}
local alRevelar: { (Revelado) -> () } = {}

local Mundo = {}

Mundo.Estado = estado

function Mundo.evento(): Evento?
	return actual
end

function Mundo.poner(e: Evento?)
	actual = e
end

-- Multiplicadores de la chance de cada modificador durante el evento (nil = ninguno).
function Mundo.bonos(): { [string]: number }?
	return if actual then actual.Modificadores else nil
end

-- Multiplica las gemas de una geoda con ese modificador.
function Mundo.unidades(modificador: string): number
	if not actual then
		return 1
	end
	local m = actual.UnidadesTodas or 1
	local porModificador = actual.Unidades
	if porModificador and porModificador[modificador] then
		m *= porModificador[modificador]
	end
	return m
end

function Mundo.suerte(): number
	return if actual then actual.Suerte or 1 else 1
end

function Mundo.publicar(campos: { [string]: any })
	for k, v in campos do
		estado:SetAttribute(k, v)
	end
end

function Mundo.alRomper(fn: (Rotura) -> ())
	table.insert(alRomper, fn)
end

function Mundo.alRevelar(fn: (Revelado) -> ())
	table.insert(alRevelar, fn)
end

function Mundo.avisarRotura(r: Rotura)
	for _, fn in alRomper do
		task.spawn(fn, r)
	end
end

function Mundo.avisarRevelacion(r: Revelado)
	for _, fn in alRevelar do
		task.spawn(fn, r)
	end
end

return Mundo
