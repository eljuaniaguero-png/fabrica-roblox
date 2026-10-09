--!strict
-- Pedidos de los clientes (ficha, "Pedidos"): qué piden, cómo se escribe, cuánto pagan y qué
-- criaturas los cumplen. El servidor los arma y valida las entregas; el cliente los muestra y
-- marca qué criaturas sirven. Todos los números están en Config.Pedidos.
--
-- Tipos de pedido (salen solos de las especies que existen):
--   Rasgo      "Algo de tipo fuego con alas", "Algo con cuernos y con cola"
--   Generacion "Una criatura de generación 2 de tipo agua"
--   Cantidad   "Dos criaturas de tipo planta" (se entregan dos)
--   Especie    "Un Glumulo" (solo especies que ya descubriste)
--   Mutante    "Cualquier mutante" (premio grande)

local Config = require(script.Parent.Config)
local Costos = require(script.Parent.Costos)
local Elementos = require(script.Parent.Elementos)
local Fusion = require(script.Parent.Fusion)
local Rasgos = require(script.Parent.Rasgos)

local P = Config.Pedidos

export type Requisito = {
	Tipo: string,
	Elemento: string?,
	Rasgos: { string }?,
	Gen: number?,
	Clave: string?,
	Cantidad: number?, -- cuántas criaturas hay que entregar (1 si no dice)
}

export type Pedido = {
	Id: number,
	Cliente: number, -- posición en Config.Pedidos.Clientes
	Texto: string,
	Requisito: Requisito,
	Premio: number, -- ADN
	Pista: boolean?, -- además, una pista gratis
	Dificultad: string, -- "Facil", "Media", "Dificil" o "Mutante"
	Nuevo: boolean?, -- pide algo que todavía no descubriste
}

-- Una criatura del inventario, tal como se entrega.
export type Unidad = { Clave: string, Mutante: boolean }

-- Lo que hace falta saber del jugador para armar un pedido.
export type Contexto = {
	Descubiertas: { [string]: boolean },
	Cantidades: { [string]: number }, -- cuántas criaturas tiene de cada especie
	Mutantes: number, -- criaturas mutantes que tiene ahora
}

local Pedidos = {}

local TODAS = Fusion.todas()

---------------------------------------------------------------------------
-- Cumplir
---------------------------------------------------------------------------

-- ¿Esta criatura sirve para el pedido? (sin contar cuántas hacen falta)
function Pedidos.sirve(r: Requisito, u: Unidad): boolean
	local c = Fusion.porClave(u.Clave)
	if not c then
		return false
	end
	if r.Tipo == "Mutante" then
		return u.Mutante
	end
	if r.Clave and c.Clave ~= r.Clave then
		return false
	end
	if r.Gen and c.Gen ~= r.Gen then
		return false
	end
	if r.Elemento and not Elementos.tiene(c, r.Elemento) then
		return false
	end
	for _, rasgo in r.Rasgos or {} do
		if not Rasgos.tiene(c, rasgo) then
			return false
		end
	end
	return true
end

function Pedidos.cantidad(r: Requisito): number
	return r.Cantidad or 1
end

-- ¿Estas criaturas cumplen el pedido entero?
function Pedidos.cumple(r: Requisito, unidades: { Unidad }): boolean
	if #unidades ~= Pedidos.cantidad(r) then
		return false
	end
	for _, u in unidades do
		if not Pedidos.sirve(r, u) then
			return false
		end
	end
	return true
end

---------------------------------------------------------------------------
-- Texto
---------------------------------------------------------------------------

local function deTipo(elemento: string): string
	return "de tipo " .. (Elementos.Nombres[elemento] or elemento):lower()
end

function Pedidos.texto(r: Requisito): string
	if r.Tipo == "Mutante" then
		return "Cualquier mutante"
	elseif r.Tipo == "Especie" then
		local c = Fusion.porClave(r.Clave or "")
		return "Un " .. (if c then c.Nombre else "?")
	elseif r.Tipo == "Generacion" then
		return "Una criatura de generación "
			.. tostring(r.Gen)
			.. (if r.Elemento then " " .. deTipo(r.Elemento) else "")
	elseif r.Tipo == "Cantidad" then
		return "Dos criaturas " .. (if r.Elemento then deTipo(r.Elemento) else "del mismo tipo")
	end
	local partes = {}
	for _, rasgo in r.Rasgos or {} do
		table.insert(partes, Rasgos.Textos[rasgo] or rasgo)
	end
	return "Algo"
		.. (if r.Elemento then " " .. deTipo(r.Elemento) else "")
		.. (if #partes > 0 then " " .. table.concat(partes, " y ") else "")
end

---------------------------------------------------------------------------
-- Armar pedidos
---------------------------------------------------------------------------

-- Especies que podés conseguir con las bases que ya descubriste (todas sus bases son tuyas).
function Pedidos.alcanzables(descubiertas: { [string]: boolean }): { Fusion.Criatura }
	local lista = {}
	for _, c in TODAS do
		local todas = true
		for _, b in c.Bases do
			if not descubiertas[tostring(b)] then
				todas = false
				break
			end
		end
		if todas then
			table.insert(lista, c)
		end
	end
	return lista
end

local function cantidadDe(t: { [string]: boolean }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

-- ADN que paga un pedido de esa dificultad (crece con el costo de las fusiones).
function Pedidos.premio(dificultad: string, cantidadEspecies: number, cantidad: number?): number
	local base = Costos.fusion(1, 1, cantidadEspecies) or 0
	local factor = P.Premio[dificultad] or P.Premio.Media
	local extra = if (cantidad or 1) > 1 then P.ExtraPorCantidad else 1
	return math.max(P.PremioMinimo, math.round(base * factor * extra))
end

local function elegir<T>(rng: Random, lista: { T }): T?
	if #lista == 0 then
		return nil
	end
	return lista[rng:NextInteger(1, #lista)]
end

-- Requisitos posibles para pedir la especie `c` (todos los cumple `c`). `copias` es cuántas
-- tiene el jugador: de una base que tiene una sola no se pide esa sola (la necesita para
-- fusionar), solo dos del mismo tipo.
local function opciones(c: Fusion.Criatura, descubierta: boolean, copias: number): { Requisito }
	local r: { Requisito } = {}
	local elementos = Elementos.de(c)
	if descubierta then
		for _, e in elementos do
			table.insert(r, { Tipo = "Cantidad", Cantidad = 2, Elemento = e })
		end
	end
	if c.Gen == 1 and copias < 2 then
		return r
	end
	local rasgos = Rasgos.de(c)
	for _, e in elementos do
		for _, rasgo in rasgos do
			table.insert(r, { Tipo = "Rasgo", Elemento = e, Rasgos = { rasgo } })
		end
		if c.Gen >= 2 then
			table.insert(r, { Tipo = "Generacion", Gen = c.Gen, Elemento = e })
		end
	end
	for i = 1, #rasgos do
		for j = i + 1, #rasgos do
			table.insert(r, { Tipo = "Rasgo", Rasgos = { rasgos[i], rasgos[j] } })
		end
	end
	if descubierta then
		table.insert(r, { Tipo = "Especie", Clave = c.Clave })
	end
	return r
end

local function dificultadDe(c: Fusion.Criatura, r: Requisito, nuevo: boolean): string
	if r.Tipo == "Mutante" then
		return "Mutante"
	end
	local d = if c.Gen >= 3 then "Dificil" elseif c.Gen == 2 then "Media" else "Facil"
	if r.Tipo == "Cantidad" and d == "Facil" then
		d = "Media"
	end
	if nuevo then
		d = if d == "Facil" then "Media" else "Dificil"
	end
	return d
end

-- ¿Alguna especie ya descubierta cumple el requisito? (un pedido "nuevo" no tiene que poder)
local function loCumpleAlgunaDescubierta(r: Requisito, descubiertas: { [string]: boolean }): boolean
	for clave in descubiertas do
		if Pedidos.sirve(r, { Clave = clave, Mutante = false }) then
			return true
		end
	end
	return false
end

-- Arma un pedido. Con `nuevo`, pide algo que solo se cumple descubriendo una especie.
-- Devuelve nil si no hay nada que pedir.
function Pedidos.generar(ctx: Contexto, rng: Random, id: number, nuevo: boolean): Pedido?
	local descubiertas = ctx.Descubiertas
	local cantidadEspecies = cantidadDe(descubiertas)
	local alcanzables = Pedidos.alcanzables(descubiertas)
	local cliente = rng:NextInteger(1, #P.Clientes)

	local function armar(c: Fusion.Criatura?, r: Requisito, esNuevo: boolean): Pedido
		local dificultad = if c then dificultadDe(c, r, esNuevo) else "Mutante"
		return {
			Id = id,
			Cliente = cliente,
			Texto = Pedidos.texto(r),
			Requisito = r,
			Premio = Pedidos.premio(dificultad, cantidadEspecies, r.Cantidad),
			Pista = dificultad ~= "Facil" and rng:NextNumber() < P.ProbabilidadPista or nil,
			Dificultad = dificultad,
			Nuevo = esNuevo or nil,
		}
	end

	if nuevo then
		-- Una especie que podés hacer y todavía no descubriste, pedida de forma que ninguna de
		-- las tuyas sirva.
		local candidatas = {}
		for _, c in alcanzables do
			if not descubiertas[c.Clave] then
				table.insert(candidatas, c)
			end
		end
		for _ = 1, #candidatas do
			local c = elegir(rng, candidatas) :: Fusion.Criatura
			local validas = {}
			for _, r in opciones(c, false, 0) do
				if not loCumpleAlgunaDescubierta(r, descubiertas) then
					table.insert(validas, r)
				end
			end
			local r = elegir(rng, validas)
			if r then
				return armar(c, r, true)
			end
			table.remove(candidatas, table.find(candidatas, c) :: number)
		end
		-- No hay nada nuevo para pedir con lo que tenés: sale un pedido común.
	end

	if cantidadEspecies >= P.MutanteDesde and rng:NextNumber() < P.ProbabilidadMutante then
		return armar(nil, { Tipo = "Mutante" }, false)
	end

	-- Casi siempre algo que ya tenés descubierto; a veces algo que podés hacer.
	local tuyas = {}
	for _, c in alcanzables do
		if descubiertas[c.Clave] then
			table.insert(tuyas, c)
		end
	end
	local lista = table.clone(
		if #tuyas > 0 and rng:NextNumber() < P.ProbabilidadDescubierta then tuyas else alcanzables
	)
	while #lista > 0 do
		local c = elegir(rng, lista) :: Fusion.Criatura
		local copias = ctx.Cantidades[c.Clave] or 0
		local r = elegir(rng, opciones(c, descubiertas[c.Clave] == true, copias))
		if r then
			return armar(c, r, false)
		end
		table.remove(lista, table.find(lista, c) :: number)
	end
	return nil
end

return Pedidos
