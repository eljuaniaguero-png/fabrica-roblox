--!strict
-- Tienda y pergaminos del paso 5b, sin Instances (las usan el servidor, el cliente para mostrar
-- y las pruebas con Lune). Todo lo que cambia la partida pasa por acá y valida: que haya oro, que
-- el ítem esté en la tienda y no se haya vendido, que haya lugar para el pergamino y que las
-- clavijas elegidas existan y no sean hueco. Los números están en Config.Oro, Config.Tienda y
-- Config.Pergaminos.
--
-- Pergaminos: "nivel:<tipo>" (sube ese tipo de clavija), "forja:<tipo>" (convierte 2 clavijas que
-- elijas), "martillo" (borra 1), "vendaje" (cura) y "furia" (×2 Multi en el próximo tiro).
-- Paso 5c: reliquias. Salen 2 por tienda (primero se sortea la rareza con Config.Rarezas y después
-- una de esa rareza que no tengas ni esté ya en la tienda). Se venden por la mitad y se mueven de
-- lugar (el orden importa: se aplican de izquierda a derecha). Vender y mover, solo en la tienda.
-- Paso 5d: después de un jefe, la tienda trae el cofre: 3 reliquias que no tenés y te llevás 1
-- gratis (si tenés lugar). Renovar no cambia el cofre.

local Azar = require(script.Parent.Azar)
local Clavijas = require(script.Parent.Clavijas)
local Config = require(script.Parent.Config)
local Mazmorra = require(script.Parent.Mazmorra)
local Reliquias = require(script.Parent.Reliquias)

type Estado = Mazmorra.Estado
type Item = Mazmorra.ItemTienda

local Tienda = {}

-- Todos los pergaminos que pueden salir, con su peso (la chance = peso / suma de pesos).
function Tienda.pergaminosPosibles(): { { Id: string, Peso: number } }
	local p = Config.Pergaminos
	local lista = {}
	table.insert(lista, { Id = "nivel:gris", Peso = p.nivel.Peso })
	for _, tipo in Config.OrdenClavijas do
		table.insert(lista, { Id = "nivel:" .. tipo, Peso = p.nivel.Peso })
	end
	for _, tipo in Config.OrdenClavijas do
		table.insert(lista, { Id = "forja:" .. tipo, Peso = p.forja.Peso })
	end
	table.insert(lista, { Id = "martillo", Peso = p.martillo.Peso })
	table.insert(lista, { Id = "vendaje", Peso = p.vendaje.Peso })
	table.insert(lista, { Id = "furia", Peso = p.furia.Peso })
	return lista
end

-- "nivel:roja" -> ("nivel", "roja"); "martillo" -> ("martillo", nil)
function Tienda.partes(id: string): (string, string?)
	local clase, tipo = string.match(id, "^(%a+):(%a+)$")
	if clase then
		return clase, tipo
	end
	return id, nil
end

function Tienda.esPergamino(id: any): boolean
	if typeof(id) ~= "string" then
		return false
	end
	for _, p in Tienda.pergaminosPosibles() do
		if p.Id == id then
			return true
		end
	end
	return false
end

-- Cuántas clavijas hay que elegir en el tablero para usarlo (0, 1 o 2).
function Tienda.clavijasAElegir(clase: string, id: string): number
	if clase == "clavija" then
		return 1
	end
	local tipoPergamino = Tienda.partes(id)
	if tipoPergamino == "forja" then
		return Config.Pergaminos.forja.Clavijas
	elseif tipoPergamino == "martillo" then
		return 1
	end
	return 0
end

-- Nombre, frase y color (hex) para mostrar un ítem o un pergamino.
function Tienda.describir(clase: string, id: string, e: Estado?): (string, string, string)
	if clase == "reliquia" then
		local tenida = if e then Reliquias.buscar(e.Reliquias, id) else nil
		return Reliquias.datos(id).Nombre,
			Reliquias.describir(id, if tenida then tenida.Contador else 0),
			Reliquias.rareza(id).Color
	end
	if clase == "clavija" then
		local d = (Config.Clavijas :: any)[id]
		local nivel = Clavijas.nivel(if e then e.Niveles else nil, id)
		return ("Clavija %s"):format(d.Nombre:lower()),
			("Tocá una clavija y se vuelve %s: %s"):format(d.Nombre:lower(), Clavijas.efecto(id, nivel)),
			d.Color
	end
	local tipoPergamino, tipo = Tienda.partes(id)
	local p = Config.Pergaminos
	if tipoPergamino == "nivel" and tipo then
		local d = (Config.Clavijas :: any)[tipo]
		local nivel = Clavijas.nivel(if e then e.Niveles else nil, tipo) + 1
		return ("Pergamino de %s"):format(d.Plural or "grises"),
			("Las %s suben a nivel %d: %s"):format(d.Plural or "grises", nivel, Clavijas.efecto(tipo, nivel)),
			d.Color
	elseif tipoPergamino == "forja" and tipo then
		local d = (Config.Clavijas :: any)[tipo]
		return ("Forja %s"):format(d.Nombre:lower()),
			("Tocá %d clavijas y se vuelven %s"):format(p.forja.Clavijas, d.Plural),
			d.Color
	elseif tipoPergamino == "martillo" then
		return p.martillo.Nombre, "Tocá una clavija y la borrás (la bola pasa derecho)", "#B0B0B0"
	elseif tipoPergamino == "vendaje" then
		return p.vendaje.Nombre, ("+%d de vida"):format(p.vendaje.Cura), "#4CC46A"
	elseif tipoPergamino == "furia" then
		return p.furia.Nombre, ("El próximo tiro: ×%d Multi al final"):format(p.furia.PorMulti), "#FF4A4A"
	end
	return id, "", "#FFFFFF"
end

-- Las chances de lo que puede salir, en texto (botón "¿Qué puede salir?").
function Tienda.chances(): { string }
	local lineas = {}
	table.insert(
		lineas,
		("Reliquias (%d por tienda): %s; después, cualquiera de esa rareza que no tengas"):format(
			Config.Tienda.Reliquias,
			Reliquias.chances()
		)
	)
	local tipos = #Config.OrdenClavijas
	table.insert(
		lineas,
		("Mejoras de clavija (%d por tienda): cada tipo %s %%"):format(
			Config.Tienda.MejorasDeClavija,
			Clavijas.numeroCorto(math.floor(1000 / tipos + 0.5) / 10)
		)
	)
	local posibles = Tienda.pergaminosPosibles()
	local total = 0
	for _, p in posibles do
		total += p.Peso
	end
	table.insert(lineas, ("Pergaminos (%d por tienda):"):format(Config.Tienda.Pergaminos))
	for _, p in posibles do
		local nombre = Tienda.describir("pergamino", p.Id)
		table.insert(
			lineas,
			("  %s: %s %%"):format(nombre, Clavijas.numeroCorto(math.floor(p.Peso / total * 1000 + 0.5) / 10))
		)
	end
	return lineas
end

-- `cantidad` reliquias distintas que no estén en `usadas`: primero la rareza (con su peso) y
-- después una de esa rareza. Marca las elegidas en `usadas`.
local function sortearReliquias(
	azar: () -> number,
	usadas: { [string]: boolean },
	cantidad: number,
	disponibles: { string }?
): { string }
	-- Solo las desbloqueadas (etapa 6); sin lista, todas.
	local permitidas: { [string]: boolean }? = nil
	if disponibles and #disponibles > 0 then
		permitidas = {}
		for _, id in disponibles do
			(permitidas :: { [string]: boolean })[id] = true
		end
	end
	local function vale(id: string): boolean
		return not usadas[id] and (permitidas == nil or permitidas[id] == true)
	end
	local pesoTotal = 0
	for _, r in Config.Rarezas do
		pesoTotal += r.Peso
	end
	local elegidas: { string } = {}
	for _ = 1, cantidad do
		local x = azar() * pesoTotal
		local rareza = Config.OrdenRarezas[#Config.OrdenRarezas]
		for _, id in Config.OrdenRarezas do
			x -= (Config.Rarezas :: any)[id].Peso
			if x < 0 then
				rareza = id
				break
			end
		end
		local posibles = {}
		for _, id in Config.OrdenReliquias do
			if Reliquias.datos(id).Rareza == rareza and vale(id) then
				table.insert(posibles, id)
			end
		end
		if #posibles == 0 then -- ya tenés todas las de esa rareza: cualquiera que no tengas
			for _, id in Config.OrdenReliquias do
				if vale(id) then
					table.insert(posibles, id)
				end
			end
		end
		if #posibles > 0 then
			local id = posibles[math.floor(azar() * #posibles) + 1]
			usadas[id] = true
			table.insert(elegidas, id)
		end
	end
	return elegidas
end

-- Lo que sale en una tienda (con la semilla): reliquias, mejoras de clavija y pergaminos. Las
-- reliquias que ya tenés (en `e`) no salen.
function Tienda.generar(semilla: number, e: Estado?): { Item }
	local azar = Azar.nuevo(semilla)
	local items: { Item } = {}
	local usadas: { [string]: boolean } = {}
	for _, r in (if e then e.Reliquias else {}) :: { Reliquias.Tenida } do
		usadas[r.Id] = true
	end
	local disponibles = if e then e.ReliquiasDisponibles else nil
	for _, id in sortearReliquias(azar, usadas, Config.Tienda.Reliquias, disponibles) do
		table.insert(items, { Clase = "reliquia", Id = id, Precio = Reliquias.precio(id), Vendido = false })
	end
	for _ = 1, Config.Tienda.MejorasDeClavija do
		local tipo = Config.OrdenClavijas[math.floor(azar() * #Config.OrdenClavijas) + 1]
		table.insert(items, { Clase = "clavija", Id = tipo, Precio = Config.Tienda.PrecioClavija, Vendido = false })
	end
	local posibles = Tienda.pergaminosPosibles()
	local total = 0
	for _, p in posibles do
		total += p.Peso
	end
	for _ = 1, Config.Tienda.Pergaminos do
		local x = azar() * total
		local elegido = posibles[#posibles].Id
		for _, p in posibles do
			x -= p.Peso
			if x < 0 then
				elegido = p.Id
				break
			end
		end
		table.insert(items, {
			Clase = "pergamino",
			Id = elegido,
			Precio = Config.Tienda.PrecioPergamino,
			Vendido = false,
		})
	end
	return items
end

-- Se abre la tienda (después de ganar una pelea, ya con el oro cobrado).
function Tienda.abrir(e: Estado, semilla: number)
	e.Fase = "tienda"
	local cofre: { string } = {}
	if e.CofrePendiente then
		local usadas: { [string]: boolean } = {}
		for _, r in e.Reliquias do
			usadas[r.Id] = true
		end
		-- Otra semilla para el cofre (así no repite las reliquias de la tienda).
		cofre = sortearReliquias(Azar.nuevo(semilla + 7919), usadas, Config.Cofre.Reliquias, e.ReliquiasDisponibles)
		e.CofrePendiente = false
	end
	e.Tienda = { Items = Tienda.generar(semilla, e), Renovaciones = 0, Cofre = cofre, CofreTomado = false }
end

-- Llevarse la reliquia `indice` del cofre (gratis, una sola).
function Tienda.tomarCofre(e: Estado, indice: any): (boolean, string?)
	if e.Fase ~= "tienda" then
		return false, "La tienda está cerrada"
	end
	local id = if typeof(indice) == "number" then e.Tienda.Cofre[indice] else nil
	if not id or e.Tienda.CofreTomado then
		return false, "Esa reliquia no está en el cofre"
	end
	if #e.Reliquias >= Config.LugaresReliquia then
		return false, "No tenés lugar: vendé una reliquia y volvé a abrir el cofre"
	end
	if Reliquias.tiene(e.Reliquias, id) then
		return false, "Ya la tenés"
	end
	table.insert(e.Reliquias, { Id = id, Contador = 0, Precio = Reliquias.precio(id) })
	e.Tienda.CofreTomado = true
	return true, nil
end

function Tienda.precioRenovar(e: Estado): number
	return Config.Tienda.Renovar + e.Tienda.Renovaciones * Config.Tienda.RenovarSube
end

function Tienda.renovar(e: Estado, semilla: number): (boolean, string?)
	if e.Fase ~= "tienda" then
		return false, "La tienda está cerrada"
	end
	local precio = Tienda.precioRenovar(e)
	if e.Oro < precio then
		return false, "No te alcanza el oro"
	end
	e.Oro -= precio
	e.Tienda = {
		Items = Tienda.generar(semilla, e),
		Renovaciones = e.Tienda.Renovaciones + 1,
		Cofre = e.Tienda.Cofre,
		CofreTomado = e.Tienda.CofreTomado,
	}
	return true, nil
end

-- Lista de Id de clavijas que mandó el cliente: tienen que ser `cantidad` números distintos de
-- clavijas que existen y no son hueco (ni del tipo `noEste`).
local function clavijasValidas(e: Estado, objetivos: any, cantidad: number, noEste: string?): { number }?
	if cantidad == 0 then
		return {}
	end
	if typeof(objetivos) ~= "table" or #objetivos ~= cantidad then
		return nil
	end
	local vistas: { [number]: boolean } = {}
	local ids: { number } = {}
	for i = 1, cantidad do
		local id = objetivos[i]
		if typeof(id) ~= "number" or id ~= math.floor(id) or id < 1 or id > #e.Tablero then
			return nil
		end
		local tipo = e.Tablero[id]
		if tipo == "hueco" or tipo == noEste or vistas[id] then
			return nil
		end
		vistas[id] = true
		table.insert(ids, id)
	end
	return ids
end

-- Comprar el ítem `indice` de la tienda. Las mejoras de clavija se aplican enseguida a la
-- clavija elegida (objetivos = { id }); los pergaminos van a un lugar libre.
function Tienda.comprar(e: Estado, indice: any, objetivos: any): (boolean, string?)
	if e.Fase ~= "tienda" then
		return false, "La tienda está cerrada"
	end
	if typeof(indice) ~= "number" then
		return false, "Ese ítem no está"
	end
	local item = e.Tienda.Items[indice]
	if not item or item.Vendido then
		return false, "Ese ítem no está"
	end
	if e.Oro < item.Precio then
		return false, "No te alcanza el oro"
	end
	if item.Clase == "reliquia" then
		if #e.Reliquias >= Config.LugaresReliquia then
			return false, "No tenés lugar: vendé una reliquia primero"
		end
		if Reliquias.tiene(e.Reliquias, item.Id) then
			return false, "Ya la tenés"
		end
		table.insert(e.Reliquias, { Id = item.Id, Contador = 0, Precio = item.Precio })
	elseif item.Clase == "clavija" then
		local ids = clavijasValidas(e, objetivos, 1, item.Id)
		if not ids then
			return false, "Elegí una clavija que no sea hueco ni de ese tipo"
		end
		e.Tablero[ids[1]] = item.Id
	else
		if #e.Pergaminos >= Config.LugaresPergamino then
			return false, "No tenés lugar: usá un pergamino primero"
		end
		table.insert(e.Pergaminos, item.Id)
	end
	e.Oro -= item.Precio
	item.Vendido = true
	return true, nil
end

-- Usar el pergamino del lugar `lugar` (en la pelea, entre tiros, o en la tienda).
function Tienda.usar(e: Estado, lugar: any, objetivos: any): (boolean, string?)
	if e.Fase ~= "peleando" and e.Fase ~= "tienda" then
		return false, "Ahora no se puede"
	end
	if typeof(lugar) ~= "number" then
		return false, "No hay pergamino ahí"
	end
	local id = e.Pergaminos[lugar]
	if not id then
		return false, "No hay pergamino ahí"
	end
	local clase, tipo = Tienda.partes(id)
	local ids = clavijasValidas(e, objetivos, Tienda.clavijasAElegir("pergamino", id), tipo)
	if not ids then
		return false, "Elegí clavijas que no sean hueco"
	end
	if clase == "nivel" and tipo then
		e.Niveles[tipo] = Clavijas.nivel(e.Niveles, tipo) + 1
	elseif clase == "forja" and tipo then
		for _, clavija in ids do
			e.Tablero[clavija] = tipo
		end
	elseif clase == "martillo" then
		e.Tablero[ids[1]] = "hueco"
	elseif clase == "vendaje" then
		e.Vida = math.min(e.Vida + Config.Pergaminos.vendaje.Cura, e.VidaMaxima)
	elseif clase == "furia" then
		e.Furia = true
	else
		return false, "Pergamino desconocido"
	end
	table.remove(e.Pergaminos, lugar)
	return true, nil
end

-- Vender la reliquia del lugar `lugar` (solo en la tienda): te dan la mitad de lo que pagaste.
function Tienda.vender(e: Estado, lugar: any): (boolean, string?)
	if e.Fase ~= "tienda" then
		return false, "Solo se vende en la tienda"
	end
	local r = if typeof(lugar) == "number" then e.Reliquias[lugar] else nil
	if not r then
		return false, "No hay reliquia ahí"
	end
	e.Oro += Reliquias.venta(r)
	table.remove(e.Reliquias, lugar)
	return true, nil
end

-- Mover la reliquia del lugar `desde` al lugar `hacia` (solo en la tienda). El orden importa:
-- las que actúan al final del tiro se aplican de izquierda a derecha.
function Tienda.mover(e: Estado, desde: any, hacia: any): (boolean, string?)
	if e.Fase ~= "tienda" then
		return false, "Solo se ordena en la tienda"
	end
	if typeof(desde) ~= "number" or typeof(hacia) ~= "number" or not e.Reliquias[desde] or not e.Reliquias[hacia] then
		return false, "No hay reliquia ahí"
	end
	local r = table.remove(e.Reliquias, desde)
	table.insert(e.Reliquias, hacia, r)
	return true, nil
end

-- Botón "Bajar": a la próxima pelea.
function Tienda.bajar(e: Estado): boolean
	if e.Fase ~= "tienda" then
		return false
	end
	e.Fase = "peleando"
	Mazmorra.empezarPelea(e)
	return true
end

return Tienda
