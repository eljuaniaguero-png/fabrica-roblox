--!strict
-- Reglas de la mazmorra, sin Instances (las usa server/Partida y la prueba con Lune).
-- Un turno: el daño del tiro le pega al monstruo; si sigue vivo, contraataca. Al ganar una
-- pelea se cobra el oro, se pasa al piso siguiente, el caballero se cura y se abre la tienda
-- (fase "tienda", shared/Tienda); al ganarle al jefe termina la mazmorra.
-- La bola de fuego deja al monstruo quemándose (daño extra en el mismo turno y los siguientes,
-- mientras le queden turnos); cada tiro con fuego lo vuelve a prender.
-- Paso 5a: la partida tiene su tablero (tipo de cada clavija), el nivel de cada tipo, la bola y
-- el oro. Las azules que se rompen quedan hueco hasta el final de la partida.
-- Paso 5b: oro por pelea (con bonus por matar rápido e interés), pergaminos y furia.
-- Paso 5c: reliquias. Acá crecen las que crecen (Trofeo al matar de un tiro, Callo con cada azul
-- rota, Racha con cada pelea sin que te peguen) y la Bolsa de Cuero sube el tope del interés.
-- Paso 5d: 3 zonas de 3 peleas. Cada jefe tiene una maña (sorteada al empezar la partida); acá
-- están las que cambian el turno (avaricia, coraza, rabia). Al ganarle a un jefe queda un cofre
-- pendiente para la tienda.
-- Etapa 6: la fase "inicio" (elegir con qué bola bajar, antes de cada partida), las reliquias que
-- puede ofrecer la tienda (las desbloqueadas) y la racha de peleas ganadas sin que te peguen.

local Azar = require(script.Parent.Azar)
local Clavijas = require(script.Parent.Clavijas)
local Config = require(script.Parent.Config)
local Reliquias = require(script.Parent.Reliquias)
local TableroModulo = require(script.Parent.Tablero)

local CANTIDAD_CLAVIJAS = #TableroModulo.generar().Clavijas

export type Fase = "inicio" | "peleando" | "tienda" | "perdio" | "gano"

export type ItemTienda = {
	Clase: string, -- "clavija" o "pergamino"
	Id: string, -- tipo de clavija o Id del pergamino
	Precio: number,
	Vendido: boolean,
}

export type TiendaEstado = {
	Items: { ItemTienda },
	Renovaciones: number, -- cuántas veces renovaste en esta tienda (sube el precio)
	Cofre: { string }, -- reliquias del cofre del jefe (vacío si no hay cofre)
	CofreTomado: boolean,
}

-- El oro que te dio la última pelea ganada (para mostrarlo en la tienda).
export type OroGanado = { Pelea: number, Bonus: number, Interes: number }

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
	Tienda: TiendaEstado, -- lo que hay en la tienda (vale en la fase "tienda")
	Pergaminos: { string }, -- los que tenés (hasta Config.LugaresPergamino)
	Furia: boolean, -- el próximo tiro tiene ×2 Multi (pergamino Furia)
	Reliquias: { Reliquias.Tenida }, -- en orden, de izquierda a derecha
	Golpeado: boolean, -- el monstruo te pegó en esta pelea (Racha)
	ManiasJefes: { string }, -- la maña de cada jefe (una por zona), sorteada al empezar
	Mania: string, -- la de esta pelea ("" si no es un jefe)
	CofrePendiente: boolean, -- le ganaste a un jefe: la próxima tienda trae el cofre
	ReliquiasDisponibles: { string }, -- las que pueden salir en tienda y cofre (vacía = todas)
	PeleasSinGolpe: number, -- peleas seguidas ganadas sin que te peguen (logro de la Racha)
	TirosPelea: number, -- tiros en la pelea actual (para el bonus de oro)
	UltimoOro: OroGanado,
	Quemando: number, -- turnos que le quedan de quemadura al monstruo
	Quemadura: number, -- daño por turno de esa quemadura
}

-- "sigue": el monstruo sigue vivo · "piso": lo mataste y bajás · "perdio" · "gano" (el jefe)
export type Resultado = "sigue" | "piso" | "perdio" | "gano"

export type Turno = {
	Danio: number,
	Oro: OroGanado?, -- si ganaste la pelea: el oro que cobraste
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

function Mazmorra.nueva(bola: string?, disponibles: { string }?): Estado
	return {
		Piso = 1,
		Vida = Config.VidaCaballero,
		VidaMaxima = Config.VidaCaballero,
		VidaMonstruo = Mazmorra.monstruo(1).Vida,
		Fase = "peleando",
		Tablero = Clavijas.nuevoTablero(CANTIDAD_CLAVIJAS),
		Niveles = {},
		Bola = if bola and table.find(Config.OrdenBolas, bola) then bola else "hierro",
		Oro = Config.Oro.Inicial,
		Tienda = { Items = {}, Renovaciones = 0, Cofre = {}, CofreTomado = false },
		Pergaminos = {},
		Furia = false,
		Reliquias = {},
		Golpeado = false,
		ManiasJefes = {},
		Mania = "",
		CofrePendiente = false,
		ReliquiasDisponibles = if disponibles then table.clone(disponibles) else {},
		PeleasSinGolpe = 0,
		TirosPelea = 0,
		UltimoOro = { Pelea = 0, Bonus = 0, Interes = 0 },
		Quemando = 0,
		Quemadura = 0,
	}
end

function Mazmorra.copiar(e: Estado): Estado
	local copia = table.clone(e)
	copia.Tablero = table.clone(e.Tablero)
	copia.Niveles = table.clone(e.Niveles)
	copia.Pergaminos = table.clone(e.Pergaminos)
	local reliquias = {}
	for i, r in e.Reliquias do
		reliquias[i] = table.clone(r)
	end
	copia.Reliquias = reliquias
	copia.UltimoOro = table.clone(e.UltimoOro)
	local items = {}
	for i, item in e.Tienda.Items do
		items[i] = table.clone(item)
	end
	copia.Tienda = {
		Items = items,
		Renovaciones = e.Tienda.Renovaciones,
		Cofre = table.clone(e.Tienda.Cofre),
		CofreTomado = e.Tienda.CofreTomado,
	}
	copia.ManiasJefes = table.clone(e.ManiasJefes)
	copia.ReliquiasDisponibles = table.clone(e.ReliquiasDisponibles)
	return copia
end

-- Lo que el tiro necesita saber de la partida (para Simulacion y Revision).
function Mazmorra.modificadores(e: Estado): {
	Tablero: { string },
	Niveles: Clavijas.Niveles,
	Bola: string,
	Furia: boolean,
	Reliquias: { Reliquias.Tenida },
	Oro: number,
	Vida: number,
	TirosPelea: number,
	Mania: string,
}
	return {
		Tablero = e.Tablero,
		Niveles = e.Niveles,
		Bola = e.Bola,
		Furia = e.Furia,
		Reliquias = e.Reliquias,
		Oro = e.Oro,
		Vida = e.Vida,
		TirosPelea = e.TirosPelea,
		Mania = e.Mania,
	}
end

-- La maña de un jefe, en texto ("Coraza: solo le hacen daño los golpes de 500 o más").
function Mazmorra.textoMania(id: string, zona: number): string
	local m = (Config.Manias :: any)[id]
	if not m then
		return ""
	end
	local detalle = m.Texto
	if id == "avaricia" then
		detalle = detalle:format(m.Oro)
	elseif id == "coraza" then
		detalle = detalle:format(Clavijas.numeroCorto(m.Minimo[math.clamp(zona, 1, #m.Minimo)]))
	end
	return ("%s: %s"):format(m.Nombre, detalle)
end

-- Sortea la maña de cada jefe (distintas entre sí). Lo hace el servidor al empezar la partida.
function Mazmorra.sortearManias(e: Estado, semilla: number)
	local todas = table.clone(Config.OrdenManias)
	Azar.mezclar(todas, Azar.nuevo(semilla))
	e.ManiasJefes = {}
	for zona = 1, #Config.Zonas do
		e.ManiasJefes[zona] = todas[(zona - 1) % #todas + 1]
	end
	Mazmorra.empezarPelea(e)
end

-- Pelea nueva: se apaga la quemadura y se cuentan los tiros de cero.
function Mazmorra.empezarPelea(e: Estado)
	e.Quemando = 0
	e.Quemadura = 0
	e.TirosPelea = 0
	e.Golpeado = false
	local m = Mazmorra.monstruo(e.Piso)
	e.Mania = if m.EsJefe then e.ManiasJefes[m.Zona] or "" else ""
end

-- Lo que dejó el tiro además del golpe: el oro de las doradas y las azules rotas (quedan hueco).
function Mazmorra.cobrarTiro(e: Estado, oro: number, rotas: { number })
	e.Oro += math.max(math.floor(oro), 0)
	if e.Mania == "avaricia" then
		e.Oro = math.max(e.Oro - Config.Manias.avaricia.Oro, 0)
	end
	local callo = Reliquias.buscar(e.Reliquias, "callo")
	for _, id in rotas do
		if e.Tablero[id] == "azul" then
			e.Tablero[id] = "hueco"
			if callo then
				callo.Contador += 1
			end
		end
	end
end

-- Para el comando de prueba: arranca la pelea del piso pedido con el monstruo entero.
function Mazmorra.irAPiso(e: Estado, piso: number)
	e.Piso = math.clamp(math.floor(piso), 1, #Config.Monstruos)
	e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
	e.Fase = "peleando"
	Mazmorra.empezarPelea(e)
end

-- Oro por ganar una pelea: base (más si es jefe), bonus por matarlo rápido y, sobre lo que
-- tenés al entrar a la tienda, interés (+1 cada 5, con tope).
function Mazmorra.cobrarPelea(e: Estado, esJefe: boolean): OroGanado
	local o = Config.Oro
	local pelea = if esJefe then o.PorJefe else o.PorMonstruo
	local bonus = if e.TirosPelea <= 1 then o.BonusUnTiro elseif e.TirosPelea == 2 then o.BonusDosTiros else 0
	e.Oro += pelea + bonus
	local tope = if Reliquias.tiene(e.Reliquias, "bolsa") then Config.Reliquias.bolsa.InteresTope else o.InteresTope
	local interes = math.min(math.floor(e.Oro / o.InteresCada), tope)
	e.Oro += interes
	e.UltimoOro = { Pelea = pelea, Bonus = bonus, Interes = interes }
	return e.UltimoOro
end

-- Aplica un tiro (modifica el estado) y devuelve qué pasó, para que el cliente lo anime.
-- quemadura: daño por turno que deja el tiro (el de la simulación; 0 o nil sin fuego).
function Mazmorra.turno(e: Estado, danio: number, quemadura: number?): Turno
	local monstruo = Mazmorra.monstruo(e.Piso)
	e.TirosPelea += 1
	if e.Mania == "coraza" then
		local minimo = Config.Manias.coraza.Minimo[math.clamp(monstruo.Zona, 1, #Config.Manias.coraza.Minimo)]
		if danio < minimo then
			danio = 0
		end
	end
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
		golpe = monstruo.Golpe * (if e.Mania == "rabia" then Config.Manias.rabia.Factor else 1)
		e.Vida = math.max(e.Vida - golpe, 0)
		e.Golpeado = true
		e.PeleasSinGolpe = 0
		local racha = Reliquias.buscar(e.Reliquias, "racha")
		if racha then
			racha.Contador = 0
		end
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

	local oro: OroGanado? = nil
	if resultado == "piso" or resultado == "gano" then
		local trofeo = Reliquias.buscar(e.Reliquias, "trofeo")
		if trofeo and e.TirosPelea == 1 then
			trofeo.Contador += 1
		end
		local racha = Reliquias.buscar(e.Reliquias, "racha")
		if racha and not e.Golpeado then
			racha.Contador += 1
		end
		if not e.Golpeado then
			e.PeleasSinGolpe += 1
		end
	end
	if resultado == "piso" then
		oro = Mazmorra.cobrarPelea(e, monstruo.EsJefe == true)
		e.CofrePendiente = monstruo.EsJefe == true
		e.Piso += 1
		e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
		e.Vida = math.min(e.Vida + Config.CuraEntrePeleas, e.VidaMaxima)
		e.Fase = "tienda" -- lo que hay en la tienda lo pone el servidor (Tienda.abrir)
		e.Quemando = 0
	end

	return {
		Danio = danio,
		Oro = oro,
		Quemadura = quemo,
		VidaMonstruo = vidaMonstruo,
		Golpe = golpe,
		VidaCaballero = vidaCaballero,
		Resultado = resultado,
		Estado = Mazmorra.copiar(e),
	}
end

return Mazmorra
