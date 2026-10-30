--!strict
-- Cómo decide el jugador automático de prueba (no está en el juego): un jugador nuevo que no
-- conoce la regla y usa lo que le muestra la interfaz. Lo usan el simulador de balance
-- (tiempo simulado) y el jugador automático de Studio (tiempo real, funciones de verdad).
--
-- Cada turno hace una sola cosa, la primera que pueda de esta lista:
--   1. Entregar un pedido que ya puede cumplir (sin dar la última criatura de una especie).
--   2. Fusionar una pareja que ya miró en el panel y da una especie nueva (si le alcanza).
--   3. Comprar una base nueva vecina, cuando ya miró todas sus parejas y no queda nada nuevo.
--   4. Abrir un corral si los suyos están llenos.
--   5. Mirar en el panel una pareja que todavía no miró (el panel dice si reacciona y si es nueva).
--   6. Fusionar otra copia de una especie que ya conoce y que le pide un cliente (si pide una
--      variante, con su catalizador; si no, de paso prueba una variante nueva si tiene uno).
--   7. Comprar otra copia de una base: para un pedido o porque entregó la suya.
--   8. Con la ranura abierta, un catalizador y ADN de sobra, probar una variante nueva.
--   8b. Con ADN de sobra, comprar una mejora (Nutrientes o Fusión rápida).
--   9. Descartar un pedido imposible (mutante sin mutantes) o trabado hace mucho.
--  10. Probar una pareja que no reacciona, para juntar residuos (salen gratis).
-- Si no puede hacer nada, espera (y eso puede contar como "sin saber qué hacer").

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Jugadores = require(script.Parent.Jugadores)

local R = Config.Prueba.Robot
local N = Config.TamanioRueda
local TODAS = Fusion.todas()

export type Mundo = {
	datos: () -> Jugadores.Datos,
	ahora: () -> number,
	fusionar: (a: string, b: string, catalizador: string?) -> boolean,
	comprar: (tipo: string, id: any) -> boolean,
	entregar: (lugar: number, unidades: { Pedidos.Unidad }) -> boolean,
	descartar: (lugar: number) -> boolean,
}

export type Memoria = {
	Vistas: { [string]: boolean }, -- parejas que ya miró en el panel ("a|b", ordenadas)
	Desde: { [number]: number }, -- pedido (Id) -> desde cuándo lo ve sin poder cumplirlo
	Esperando: boolean, -- en el último turno tenía un objetivo pero le faltaba ADN
}

local Robot = {}

-- Segundos que tarda cada acción (o pensar, si no hizo nada).
function Robot.duracion(accion: string?): number
	if accion == "Residuo" then
		return R.Residuo
	elseif accion == "Fusion" then
		return R.Fusion
	elseif accion == "Entrega" then
		return R.Entrega
	elseif accion == "Compra" then
		return R.Compra
	elseif accion == "Descarte" then
		return R.Descarte
	end
	return R.Pensar
end

function Robot.nuevaMemoria(): Memoria
	return { Vistas = {}, Desde = {}, Esperando = false }
end

local function pareja(a: string, b: string): string
	return if a < b then a .. "|" .. b else b .. "|" .. a
end

-- Especies de las que tiene criaturas.
local function tiene(d: Jugadores.Datos): { [string]: boolean }
	local t = {}
	for _, u in d.Criaturas do
		t[u.Clave] = true
	end
	return t
end

local function costoDe(d: Jugadores.Datos, c: Fusion.Criatura): number
	local gens = if c.Gen == 3 then { 2, 1 } else { 1, 1 }
	return Costos.fusion(gens[1], gens[2], Jugadores.cantidadEspecies(d)) or math.huge
end

-- Con qué pareja de criaturas suyas se hace `c` (nil si le falta alguna).
local function receta(c: Fusion.Criatura, mias: { [string]: boolean }): (string?, string?)
	if c.Gen == 2 then
		local a, b = tostring(c.Bases[1]), tostring(c.Bases[2])
		if mias[a] and mias[b] then
			return a, b
		end
	elseif c.Gen == 3 then
		for i = 1, 3 do
			local resto = {}
			for j = 1, 3 do
				if j ~= i then
					table.insert(resto, c.Bases[j])
				end
			end
			local g = Fusion.porClave(
				table.concat({ math.min(resto[1], resto[2]), math.max(resto[1], resto[2]) }, "-")
			)
			local base = tostring(c.Bases[i])
			if g and mias[g.Clave] and mias[base] then
				return g.Clave, base
			end
		end
	end
	return nil, nil
end

-- Criaturas suyas para cumplir el pedido, sin dar la última de ninguna especie (el panel le
-- avisa, y la necesita para fusionar y para que trabaje). nil si no le alcanzan.
local function unidadesPara(d: Jugadores.Datos, r: Pedidos.Requisito): { Pedidos.Unidad }?
	local hacen = Pedidos.cantidad(r)
	local elegidas: { Pedidos.Unidad } = {}
	local usadas: { [string]: number } = {}
	-- Primero las de menor generación y las normales (las mutantes se guardan).
	local orden = table.clone(d.Criaturas)
	table.sort(orden, function(x, y)
		local cx, cy =
			Fusion.porClave(x.Clave) :: Fusion.Criatura, Fusion.porClave(y.Clave) :: Fusion.Criatura
		if x.Mutante ~= y.Mutante then
			return not x.Mutante
		end
		return cx.Gen < cy.Gen
	end)
	for _, u in orden do
		if #elegidas >= hacen then
			break
		end
		local unidad = {
			Clave = u.Clave,
			Mutante = u.Mutante,
			Personalidad = u.Personalidad,
			Variante = u.Variante,
		}
		if Pedidos.sirve(r, unidad) then
			local quedan = Jugadores.contar(d, u.Clave) - (usadas[u.Clave] or 0)
			if quedan > 1 then
				table.insert(elegidas, unidad)
				usadas[u.Clave] = (usadas[u.Clave] or 0) + 1
			end
		end
	end
	return if #elegidas == hacen then elegidas else nil
end

-- Parejas que el panel le dejaría probar: base + base y gen 2 + base.
local function parejasPosibles(mias: { [string]: boolean }): { { string } }
	local lista = {}
	local claves = {}
	for k in mias do
		table.insert(claves, k)
	end
	table.sort(claves)
	for i = 1, #claves do
		for j = i + 1, #claves do
			local a, b = Fusion.porClave(claves[i]), Fusion.porClave(claves[j])
			if a and b and a.Gen + b.Gen <= 3 then
				table.insert(lista, { claves[i], claves[j] })
			end
		end
	end
	return lista
end

-- Un catalizador que tenga para probar, de paso, una variante de `c` que todavía no consiguió.
local function variantePrueba(d: Jugadores.Datos, c: Fusion.Criatura, ranura: boolean): string?
	if not ranura then
		return nil
	end
	local vistas = d.Variantes[c.Clave]
	for clave, n in d.Catalizadores do
		if n > 0 and not (vistas and vistas[clave]) then
			return clave
		end
	end
	return nil
end

-- Hace una cosa y devuelve cuál ("Entrega", "Fusion", "Compra", "Mirar", "Descarte") o nil.
function Robot.turno(m: Mundo, mem: Memoria): string?
	local d = m.datos()
	local ahora = m.ahora()
	local mias = tiene(d)
	local nEspecies = Jugadores.cantidadEspecies(d)
	mem.Esperando = false

	-- 1. Entregar.
	for i, p in d.Pedidos do
		local us = unidadesPara(d, p.Requisito)
		if us and m.entregar(i, us) then
			mem.Desde[p.Id] = nil
			return "Entrega"
		end
		mem.Desde[p.Id] = mem.Desde[p.Id] or ahora
	end

	local libre = ahora >= d.OcupadoHasta
	local posibles = parejasPosibles(mias)

	-- 2. Una especie nueva que ya vio en el panel.
	local nuevaVista: { string }? = nil
	local costoNueva = math.huge
	for _, par in posibles do
		if mem.Vistas[pareja(par[1], par[2])] then
			local hijo = Fusion.fusionar(
				Fusion.porClave(par[1]) :: Fusion.Criatura,
				Fusion.porClave(par[2]) :: Fusion.Criatura
			)
			if hijo and not d.Especies[hijo.Clave] then
				local costo = costoDe(d, hijo)
				if costo < costoNueva then
					nuevaVista, costoNueva = par, costo
				end
			end
		end
	end
	if nuevaVista then
		if libre and d.ADN >= costoNueva and m.fusionar(nuevaVista[1], nuevaVista[2]) then
			return "Fusion"
		end
		mem.Esperando = true
	end

	-- Parejas que todavía no miró en el panel.
	local sinMirar = {}
	for _, par in posibles do
		if not mem.Vistas[pareja(par[1], par[2])] then
			table.insert(sinMirar, par)
		end
	end

	-- 3. Base nueva vecina, si ya miró todo y no le queda nada nuevo para fusionar.
	if #sinMirar == 0 and not nuevaVista then
		local precio = Mejoras.precioBase(Jugadores.cantidadBases(d), nEspecies)
		if precio then
			for n = 1, N do
				if not d.Especies[tostring(n)] then
					local vecina = false
					for k = -Config.DistanciaMaxima, Config.DistanciaMaxima do
						if mias[tostring((n - 1 + k) % N + 1)] and k ~= 0 then
							vecina = true
						end
					end
					if vecina then
						if d.ADN >= precio and m.comprar("Base", n) then
							return "Compra"
						end
						mem.Esperando = true
						break
					end
				end
			end
		end
	end

	-- 4. Un corral más si los que tiene están llenos.
	local precioCorral = Mejoras.precio("Corrales", d.Mejoras.Corrales, nEspecies)
	if precioCorral and #d.Criaturas >= Mejoras.tope(d.Mejoras.Corrales) then
		if d.ADN >= precioCorral and m.comprar("Mejora", "Corrales") then
			return "Compra"
		end
	end

	-- 5. Mirar una pareja que todavía no miró.
	if #sinMirar > 0 then
		local par = sinMirar[math.random(#sinMirar)]
		mem.Vistas[pareja(par[1], par[2])] = true
		return "Mirar"
	end

	-- 6. Otra copia de una especie conocida que le piden (una variante, con su catalizador).
	local ranura = nEspecies >= Config.Residuos.RanuraDesde
	for _, p in d.Pedidos do
		local cat = p.Requisito.Variante
		local puede = cat == nil or (ranura and (d.Catalizadores[cat] or 0) > 0)
		if not unidadesPara(d, p.Requisito) and p.Requisito.Tipo ~= "Mutante" and puede then
			for _, c in TODAS do
				if
					c.Gen >= 2
					and d.Especies[c.Clave]
					and Pedidos.sirve(
						p.Requisito,
						{ Clave = c.Clave, Mutante = false, Variante = cat }
					)
				then
					local a, b = receta(c, mias)
					if a and b then
						local usar = cat or variantePrueba(d, c, ranura)
						if
							libre
							and d.ADN >= costoDe(d, c)
							and m.fusionar(a, b :: string, usar)
						then
							return "Fusion"
						end
						mem.Esperando = true
					end
				end
			end
		end
	end

	-- 7. Copia de una base: para un pedido, o porque se quedó sin ella.
	local copia = Mejoras.precioCopia(nEspecies)
	for n = 1, N do
		local clave = tostring(n)
		if d.Especies[clave] then
			local falta = not mias[clave]
			if not falta then
				for _, p in d.Pedidos do
					if
						not unidadesPara(d, p.Requisito)
						and Pedidos.sirve(p.Requisito, { Clave = clave, Mutante = false })
					then
						falta = true
					end
				end
			end
			if falta then
				if d.ADN >= copia and m.comprar("Base", n) then
					return "Compra"
				end
				mem.Esperando = true
			end
		end
	end

	-- 8. Con la ranura abierta, un catalizador y ADN de sobra (más de dos fusiones), una
	-- variante que todavía no tiene de una especie de gen 2 que sabe hacer.
	if ranura and libre and d.ADN >= 2 * Mejoras.fusion(nEspecies) then
		for clave, n in d.Catalizadores do
			if n > 0 then
				for _, c in TODAS do
					local vistas = d.Variantes[c.Clave]
					if c.Gen == 2 and d.Especies[c.Clave] and not (vistas and vistas[clave]) then
						local a, b = receta(c, mias)
						if
							a
							and b
							and d.ADN >= costoDe(d, c)
							and m.fusionar(a, b :: string, clave)
						then
							return "Fusion"
						end
					end
				end
			end
		end
	end

	-- 8b. Con ADN de sobra (más de dos fusiones) y nada mejor, una mejora (la más barata).
	if d.ADN >= 2 * Mejoras.fusion(nEspecies) then
		local mejor: string? = nil
		local barata = math.huge
		for _, nombre in { "Nutrientes", "Rapida" } do
			local precio = Mejoras.precio(nombre, (d.Mejoras :: any)[nombre], nEspecies)
			if precio and precio < barata then
				mejor, barata = nombre, precio
			end
		end
		if mejor and d.ADN >= barata and m.comprar("Mejora", mejor) then
			return "Compra"
		end
	end

	-- 9. Descartar lo imposible o lo trabado hace mucho (antes que los residuos: si no, nunca
	-- descarta, porque un residuo siempre se puede hacer).
	local mutantes = 0
	for _, u in d.Criaturas do
		if u.Mutante then
			mutantes += 1
		end
	end
	for i, p in d.Pedidos do
		local desde = mem.Desde[p.Id] or ahora
		if (p.Requisito.Tipo == "Mutante" and mutantes == 0) or ahora - desde > R.Trabado then
			if m.descartar(i) then
				mem.Desde[p.Id] = nil
				return "Descarte"
			end
		end
	end

	-- 10. Una pareja que ya sabe que no reacciona: igual sale un residuo (gratis).
	if libre then
		for _, par in posibles do
			if mem.Vistas[pareja(par[1], par[2])] then
				local x = Fusion.porClave(par[1]) :: Fusion.Criatura
				local y = Fusion.porClave(par[2]) :: Fusion.Criatura
				if not Fusion.fusionar(x, y) and m.fusionar(par[1], par[2]) then
					return "Residuo"
				end
			end
		end
	end

	return nil
end

return Robot
