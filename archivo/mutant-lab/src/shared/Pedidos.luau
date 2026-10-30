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
--   Personalidad "Una criatura Alegre de tipo agua" (de las que tenés)
--   Variante   "Un Glumulo de Hielo" (variantes que ya conocés)

local Catalizadores = require(script.Parent.Catalizadores)
local Config = require(script.Parent.Config)
local Costos = require(script.Parent.Costos)
local Elementos = require(script.Parent.Elementos)
local Fusion = require(script.Parent.Fusion)
local Personalidades = require(script.Parent.Personalidades)
local Rasgos = require(script.Parent.Rasgos)

local P = Config.Pedidos

export type Requisito = {
	Tipo: string,
	Elemento: string?,
	Rasgos: { string }?,
	Gen: number?,
	Clave: string?,
	Cantidad: number?, -- cuántas criaturas hay que entregar (1 si no dice)
	Personalidad: string?,
	Variante: string?,
}

export type Pedido = {
	Id: number,
	Cliente: number, -- posición en Config.Pedidos.Clientes
	Texto: string,
	Requisito: Requisito,
	Premio: number, -- ADN
	Pista: boolean?, -- además, una pista gratis
	Catalizador: string?, -- o, en vez de la pista, un catalizador (lo pone Tablero)
	Dificultad: string, -- "Facil", "Media", "Dificil" o "Mutante"
	Nuevo: boolean?, -- pide algo que todavía no descubriste
}

-- Una criatura del inventario, tal como se entrega.
export type Unidad = {
	Clave: string,
	Mutante: boolean,
	Personalidad: string?,
	Variante: string?,
}

-- Lo que hace falta saber del jugador para armar un pedido.
export type Contexto = {
	Descubiertas: { [string]: boolean },
	Cantidades: { [string]: number }, -- cuántas criaturas tiene de cada especie
	Mutantes: number, -- criaturas mutantes que tiene ahora
	-- Especie -> personalidad -> cuántas tiene (para los pedidos de personalidad).
	Personalidades: { [string]: { [string]: number } }?,
	-- Especie -> variantes que ya consiguió alguna vez (para los pedidos de variante).
	Variantes: { [string]: { string } }?,
	HayMutante: boolean?, -- ya hay un pedido de mutante en el tablero (no se pide otro)
}

local Pedidos = {}

local TODAS = Fusion.todas()

-- ¿Son la misma clase de criatura? (especie, tipo, personalidad y variante)
function Pedidos.igual(a: Unidad, b: Unidad): boolean
	return a.Clave == b.Clave
		and a.Mutante == b.Mutante
		and a.Personalidad == b.Personalidad
		and a.Variante == b.Variante
end

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
	if r.Personalidad and u.Personalidad ~= r.Personalidad then
		return false
	end
	if r.Variante and u.Variante ~= r.Variante then
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
	elseif r.Tipo == "Especie" or r.Tipo == "Variante" then
		local c = Fusion.porClave(r.Clave or "")
		return "Un " .. Catalizadores.nombre(if c then c.Nombre else "?", r.Variante)
	elseif r.Tipo == "Personalidad" then
		local p = Personalidades.Datos[r.Personalidad or ""]
		return "Una criatura "
			.. (if p then p.Nombre else "?")
			.. (if r.Elemento then " " .. deTipo(r.Elemento) else "")
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
	if (r.Tipo == "Cantidad" or r.Tipo == "Personalidad") and d == "Facil" then
		d = "Media"
	elseif r.Tipo == "Variante" then
		d = "Dificil"
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

-- Pedido de personalidad: una que el jugador tiene en esa especie (de una base, solo si tiene
-- más de una copia con esa personalidad) y uno de sus elementos.
local function pedidoPersonalidad(c: Fusion.Criatura, ctx: Contexto, rng: Random): Requisito?
	local cuentas = ctx.Personalidades and ctx.Personalidades[c.Clave]
	if not cuentas then
		return nil
	end
	local minimo = if c.Gen == 1 then 2 else 1
	local lista = {}
	for _, p in Personalidades.Orden do
		if (cuentas[p] or 0) >= minimo then
			table.insert(lista, p)
		end
	end
	local p, e = elegir(rng, lista), elegir(rng, Elementos.de(c))
	if not p or not e then
		return nil
	end
	return { Tipo = "Personalidad", Personalidad = p, Elemento = e }
end

-- Pedido de variante: una variante de esa especie que el jugador ya consiguió alguna vez.
local function pedidoVariante(c: Fusion.Criatura, ctx: Contexto, rng: Random): Requisito?
	local variantes = ctx.Variantes and ctx.Variantes[c.Clave]
	local v = if variantes then elegir(rng, variantes) else nil
	if not v then
		return nil
	end
	return { Tipo = "Variante", Clave = c.Clave, Variante = v }
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

	if
		cantidadEspecies >= P.MutanteDesde
		and not ctx.HayMutante
		and rng:NextNumber() < P.ProbabilidadMutante
	then
		return armar(nil, { Tipo = "Mutante" }, false)
	end

	-- A veces, una variante que ya conseguiste (Config.Pedidos.ProbabilidadVariante).
	if ctx.Variantes and rng:NextNumber() < P.ProbabilidadVariante then
		local conVariantes = {}
		for clave in ctx.Variantes do
			table.insert(conVariantes, clave)
		end
		table.sort(conVariantes)
		local clave = elegir(rng, conVariantes)
		local c = if clave then Fusion.porClave(clave) else nil
		local r = if c then pedidoVariante(c, ctx, rng) else nil
		if c and r then
			return armar(c, r, false)
		end
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
		local especial = if rng:NextNumber() < P.ProbabilidadPersonalidad
			then pedidoPersonalidad(c, ctx, rng)
			else nil
		if especial then
			return armar(c, especial, false)
		end
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
