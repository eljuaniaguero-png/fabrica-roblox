--!strict
-- Reglas de la mazmorra, sin Instances (las usa server/Partida y la prueba con Lune).
-- Un turno: el daño del tiro le pega al monstruo; si sigue vivo, contraataca. Al ganar una
-- pelea se pasa al piso siguiente, el caballero se cura y elige 1 de 3 mejoras (fase
-- "eligiendo"); al ganarle al jefe termina la mazmorra.
-- Etapa 5: la bola de fuego deja al monstruo quemándose (daño extra en el mismo turno y los
-- siguientes, mientras le queden turnos); cada tiro con fuego lo vuelve a prender.

local Config = require(script.Parent.Config)
local Mejoras = require(script.Parent.Mejoras)
local TableroModulo = require(script.Parent.Tablero)

export type Fase = "peleando" | "eligiendo" | "perdio" | "gano"

-- Lo que el servidor le manda al cliente para dibujar la pelea.
export type Estado = {
	Piso: number,
	Vida: number, -- del caballero
	VidaMaxima: number,
	VidaMonstruo: number,
	Fase: Fase,
	Mejoras: Mejoras.Niveles, -- nombre -> nivel (cuántas veces la elegiste)
	Rojas: { number }, -- Id de las clavijas que duplican en esta pelea
	Ofrecidas: { string }, -- las cartas para elegir (solo en la fase "eligiendo")
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

function Mazmorra.nueva(): Estado
	return {
		Piso = 1,
		Vida = Config.VidaCaballero,
		VidaMaxima = Config.VidaCaballero,
		VidaMonstruo = Mazmorra.monstruo(1).Vida,
		Fase = "peleando",
		Mejoras = {},
		Rojas = {},
		Ofrecidas = {},
		Quemando = 0,
		Quemadura = 0,
	}
end

function Mazmorra.copiar(e: Estado): Estado
	local copia = table.clone(e)
	copia.Mejoras = table.clone(e.Mejoras)
	copia.Rojas = table.clone(e.Rojas)
	copia.Ofrecidas = table.clone(e.Ofrecidas)
	return copia
end

-- Pelea nueva: las clavijas rojas salen de la semilla de la pelea y no se mueven hasta la
-- próxima. Lo llama el servidor al arrancar la mazmorra, al elegir una mejora y al saltar de piso.
function Mazmorra.empezarPelea(e: Estado, tablero: TableroModulo.Tablero, semilla: number)
	e.Rojas = Mejoras.rojas(tablero, semilla, Mejoras.nivel(e.Mejoras, "Duplica"))
	e.Quemando = 0
	e.Quemadura = 0
end

-- Al ganar una pelea: las cartas que salen (las elige el servidor con Mejoras.ofrecer).
function Mazmorra.ofrecer(e: Estado, cartas: { string })
	if e.Fase == "eligiendo" then
		e.Ofrecidas = table.clone(cartas)
	end
end

-- El jugador elige una carta: tiene que ser una de las ofrecidas. Devuelve si se aceptó.
function Mazmorra.elegir(e: Estado, id: any): boolean
	if e.Fase ~= "eligiendo" or typeof(id) ~= "string" or not table.find(e.Ofrecidas, id) then
		return false
	end
	e.Mejoras[id] = Mejoras.nivel(e.Mejoras, id) + 1
	e.Ofrecidas = {}
	e.Fase = "peleando"
	return true
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
		e.Quemando = Config.Mejoras.Fuego.TurnosQuemadura
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
