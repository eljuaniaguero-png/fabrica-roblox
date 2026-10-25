--!strict
-- Reglas de la mazmorra, sin Instances (las usa server/Partida y la prueba con Lune).
-- Un turno: el daño del tiro le pega al monstruo; si sigue vivo, contraataca. Al ganar una
-- pelea se pasa al piso siguiente, el caballero se cura y elige 1 de 3 cartas de clavijas (fase
-- "eligiendo"); al ganarle al jefe termina la mazmorra.
-- La bola de fuego deja al monstruo quemándose (daño extra en el mismo turno y los siguientes,
-- mientras le queden turnos); cada tiro con fuego lo vuelve a prender.
-- Paso 5a: la partida tiene su tablero (tipo de cada clavija), el nivel de cada tipo, la bola y
-- el oro. Las azules que se rompen quedan hueco hasta el final de la partida.

local Clavijas = require(script.Parent.Clavijas)
local Config = require(script.Parent.Config)
local TableroModulo = require(script.Parent.Tablero)

local CANTIDAD_CLAVIJAS = #TableroModulo.generar().Clavijas

export type Fase = "peleando" | "eligiendo" | "perdio" | "gano"

-- Lo que el servidor le manda al cliente para dibujar la pelea.
export type Estado = {
	Piso: number,
	Vida: number, -- del caballero
	VidaMaxima: number,
	VidaMonstruo: number,
	Fase: Fase,
	Tablero: Clavijas.TableroPartida, -- tipo de cada clavija (por Id)
	Niveles: Clavijas.Niveles, -- tipo -> nivel (los suben los pergaminos, paso 5b)
	Bola: string, -- "hierro", "fuego" o "partida"
	Oro: number,
	Ofrecidas: { string }, -- los tipos de las cartas para elegir (solo en la fase "eligiendo")
	Quemando: number, -- turnos que le quedan de quemadura al monstruo
	Quemadura: number, -- daño por turno de esa quemadura
}

-- "sigue": el monstruo sigue vivo · "piso": lo mataste y bajás · "perdio" · "gano" (el jefe)
export type Resultado = "sigue" | "piso" | "perdio" | "gano"

export type Turno = {
	Danio: number,
	Quemadura: number, -- lo que le sacó la quemadura este turno (0 si no hubo)
	VidaMonstruo: number, -- después del golpe y la quemadura (0 si murió)
	Golpe: number, -- lo que te sacó el contraataque (0 si no hubo)
	VidaCaballero: number, -- después del contraataque, antes de curarse
	Resultado: Resultado,
	Estado: Estado, -- cómo queda todo después del turno (piso nuevo incluido)
}

local Mazmorra = {}

function Mazmorra.monstruo(piso: number): Config.Monstruo
	return Config.Monstruos[math.clamp(piso, 1, #Config.Monstruos)]
end

function Mazmorra.nueva(bola: string?): Estado
	return {
		Piso = 1,
		Vida = Config.VidaCaballero,
		VidaMaxima = Config.VidaCaballero,
		VidaMonstruo = Mazmorra.monstruo(1).Vida,
		Fase = "peleando",
		Tablero = Clavijas.nuevoTablero(CANTIDAD_CLAVIJAS),
		Niveles = {},
		Bola = if bola and table.find(Config.OrdenBolas, bola) then bola else "hierro",
		Oro = 0,
		Ofrecidas = {},
		Quemando = 0,
		Quemadura = 0,
	}
end

function Mazmorra.copiar(e: Estado): Estado
	local copia = table.clone(e)
	copia.Tablero = table.clone(e.Tablero)
	copia.Niveles = table.clone(e.Niveles)
	copia.Ofrecidas = table.clone(e.Ofrecidas)
	return copia
end

-- Lo que el tiro necesita saber de la partida (para Simulacion y Revision).
function Mazmorra.modificadores(
	e: Estado
): { Tablero: { string }, Niveles: Clavijas.Niveles, Bola: string }
	return { Tablero = e.Tablero, Niveles = e.Niveles, Bola = e.Bola }
end

-- Pelea nueva: se apaga la quemadura.
function Mazmorra.empezarPelea(e: Estado)
	e.Quemando = 0
	e.Quemadura = 0
end

-- Lo que dejó el tiro además del golpe: el oro de las doradas y las azules rotas (quedan hueco).
function Mazmorra.cobrarTiro(e: Estado, oro: number, rotas: { number })
	e.Oro += math.max(math.floor(oro), 0)
	for _, id in rotas do
		if e.Tablero[id] == "azul" then
			e.Tablero[id] = "hueco"
		end
	end
end

-- Al ganar una pelea: las cartas que salen (las elige el servidor con Clavijas.ofrecer).
function Mazmorra.ofrecer(e: Estado, cartas: { string })
	if e.Fase == "eligiendo" then
		e.Ofrecidas = table.clone(cartas)
	end
end

-- El jugador elige una carta: tiene que ser una de las ofrecidas. Convierte clavijas grises
-- (elegidas con la semilla) en ese tipo. Devuelve los Id convertidos, o nil si no se aceptó.
function Mazmorra.elegir(e: Estado, tipo: any, semilla: number): { number }?
	if e.Fase ~= "eligiendo" or typeof(tipo) ~= "string" or not table.find(e.Ofrecidas, tipo) then
		return nil
	end
	local ids = Clavijas.convertir(e.Tablero, tipo, Config.Cartas.ClavijasPorCarta, semilla)
	e.Ofrecidas = {}
	e.Fase = "peleando"
	return ids
end

-- Para el comando de prueba: arranca la pelea del piso pedido con el monstruo entero.
function Mazmorra.irAPiso(e: Estado, piso: number)
	e.Piso = math.clamp(math.floor(piso), 1, #Config.Monstruos)
	e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
	e.Fase = "peleando"
	e.Ofrecidas = {}
end

-- Aplica un tiro (modifica el estado) y devuelve qué pasó, para que el cliente lo anime.
-- quemadura: daño por turno que deja el tiro (el de la simulación; 0 o nil sin fuego).
function Mazmorra.turno(e: Estado, danio: number, quemadura: number?): Turno
	local monstruo = Mazmorra.monstruo(e.Piso)
	e.VidaMonstruo = math.max(e.VidaMonstruo - math.max(danio, 0), 0)
	if quemadura and quemadura > 0 then
		e.Quemando = Config.Bolas.fuego.TurnosQuemadura
		e.Quemadura = quemadura
	end
	local quemo = 0
	if e.VidaMonstruo > 0 and e.Quemando > 0 then
		quemo = math.min(e.Quemadura, e.VidaMonstruo)
		e.VidaMonstruo -= quemo
		e.Quemando -= 1
	end
	local vidaMonstruo = e.VidaMonstruo
	local golpe = 0
	local resultado: Resultado

	if vidaMonstruo > 0 then
		golpe = monstruo.Golpe
		e.Vida = math.max(e.Vida - golpe, 0)
		if e.Vida == 0 then
			e.Fase = "perdio"
			resultado = "perdio"
		else
			resultado = "sigue"
		end
	elseif e.Piso >= #Config.Monstruos then
		e.Fase = "gano"
		resultado = "gano"
	else
		resultado = "piso"
	end
	local vidaCaballero = e.Vida

	if resultado == "piso" then
		e.Piso += 1
		e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
		e.Vida = math.min(e.Vida + Config.CuraEntrePeleas, e.VidaMaxima)
		e.Fase = "eligiendo"
		e.Ofrecidas = {}
		e.Quemando = 0
	end

	return {
		Danio = danio,
		Quemadura = quemo,
		VidaMonstruo = vidaMonstruo,
		Golpe = golpe,
		VidaCaballero = vidaCaballero,
		Resultado = resultado,
		Estado = Mazmorra.copiar(e),
	}
end

return Mazmorra
