--!strict
-- Datos de cada jugador mientras está en el servidor (se guardan con Guardado.luau).
-- Hay dos cosas distintas:
--   Especies: lo que descubriste (la Mutadex). Nunca se pierde.
--   Criaturas: las que tenés en el laboratorio, una por una. Cada fusión y cada compra suma
--   una; entregar un pedido la saca. Con ellas se fusiona y trabajan en los corrales.
-- Cada criatura tiene su personalidad (shared/Personalidades.luau) y, si nació con un
-- catalizador, su variante (shared/Catalizadores.luau).
-- Se publican como atributos del Player para que el cliente los lea:
--   ADN (número entero), Especies y Mutantes (claves separadas por ";"),
--   Criaturas ("clave:normales:mutantes;..."), Grupos (JSON: las criaturas agrupadas por
--   especie, personalidad, tipo y variante; ver Formato.grupos), Pistas ("clave:cantidad;...") y
--   PistasCompradas, PistasGratis, MejoraCorrales, MejoraRapida, MejoraNutrientes (niveles),
--   FactorFusion, Tope, Entregados y Pedidos (texto JSON con los pedidos del tablero).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Pistas = require(ReplicatedStorage.Shared.Pistas)

-- Una criatura del laboratorio.
export type Unidad = {
	Id: number,
	Clave: string,
	Mutante: boolean,
	Personalidad: string,
	Variante: string?, -- catalizador con el que nació
}

-- Una criatura como se guarda en el DataStore.
export type CriaturaGuardada = {
	Clave: string,
	Mutante: boolean,
	Personalidad: string?, -- nil en los guardados de antes de las personalidades
	Variante: string?,
}

export type Datos = {
	ADN: number, -- puede tener decimales (los Nutrientes suman de a 0,25); se muestra redondeado
	Especies: { [string]: boolean }, -- descubiertas (Mutadex)
	Mutantes: { [string]: boolean }, -- especies que conseguiste mutantes alguna vez (Mutadex)
	Criaturas: { Unidad },
	SiguienteId: number,
	Pistas: { [string]: number }, -- cuántas pistas compraste de cada silueta
	PistasCompradas: number,
	PistasGratis: number, -- pistas que ganaste con pedidos (las próximas no se cobran)
	GeneracionesPremiadas: { [number]: boolean },
	Mejoras: Mejoras.Niveles,
	Pedidos: { [number]: Pedidos.Pedido }, -- lugar del tablero (1 a 3) -> pedido
	EsperaPedido: { [number]: number }, -- lugar descartado -> hora (del servidor) del próximo
	Entregados: number,
	SiguientePedido: number,
	Residuos: { { A: string, B: string } }, -- de las parejas que no reaccionaron (su color)
	Catalizadores: { [string]: number }, -- cuántos tenés de cada uno
	CatalizadoresVistos: { [string]: boolean }, -- los que conocés (tuviste alguna vez)
	Variantes: { [string]: { [string]: boolean } }, -- especie -> variantes conseguidas (Mutadex)
	Sellos: { [string]: { [string]: boolean } }, -- especie -> personalidades conseguidas (Mutadex)
	OcupadoHasta: number, -- la máquina está trabajando hasta este os.clock()
}

-- Lo que se guarda en el DataStore (Guardado.luau): solo tablas, textos y números.
export type Guardados = {
	Version: number,
	ADN: number,
	Especies: { string },
	Mutantes: { string },
	Criaturas: { CriaturaGuardada }?, -- nil en los guardados viejos
	Pistas: { [string]: number },
	PistasCompradas: number,
	PistasGratis: number?,
	GeneracionesPremiadas: { number },
	Mejoras: Mejoras.Niveles,
	Pedidos: { { Lugar: number, Pedido: Pedidos.Pedido } }?,
	Entregados: number?,
	Residuos: { { A: string, B: string } }?,
	Catalizadores: { [string]: number }?,
	CatalizadoresVistos: { string }?,
	Variantes: { string }?, -- "especie|variante"
	Sellos: { string }?, -- "especie|personalidad"
}

local datos: { [Player]: Datos } = {}

local Jugadores = {}

local function unir(conjunto: { [string]: boolean }): string
	local lista = {}
	for clave in conjunto do
		table.insert(lista, clave)
	end
	table.sort(lista)
	return table.concat(lista, ";")
end

function Jugadores.obtener(jugador: Player): Datos?
	return datos[jugador]
end

function Jugadores.todos(): { [Player]: Datos }
	return datos
end

function Jugadores.cantidadEspecies(d: Datos): number
	local n = 0
	for _ in d.Especies do
		n += 1
	end
	return n
end

function Jugadores.cantidadBases(d: Datos): number
	local n = 0
	for b = 1, Config.TamanioRueda do
		if d.Especies[tostring(b)] then
			n += 1
		end
	end
	return n
end

---------------------------------------------------------------------------
-- Criaturas del laboratorio
---------------------------------------------------------------------------

-- Suma una criatura. Sin personalidad (una base que se compra, un guardado viejo), sale la
-- de su especie.
function Jugadores.agregarCriatura(
	d: Datos,
	clave: string,
	mutante: boolean,
	personalidad: string?,
	variante: string?
): Unidad
	local c = Fusion.porClave(clave)
	local u: Unidad = {
		Id = d.SiguienteId,
		Clave = clave,
		Mutante = mutante,
		Personalidad = personalidad or Personalidades.deEspecie(if c then c.Bases else {}),
		Variante = variante,
	}
	d.SiguienteId += 1
	table.insert(d.Criaturas, u)
	-- Sello de la Mutadex: esa personalidad ya la conseguiste en esa especie.
	local sellos = d.Sellos[clave] or {}
	sellos[u.Personalidad] = true
	d.Sellos[clave] = sellos
	return u
end

-- Cuántas criaturas de esa especie tenés (si `mutante` no es nil, solo de ese tipo).
function Jugadores.contar(d: Datos, clave: string, mutante: boolean?): number
	local n = 0
	for _, u in d.Criaturas do
		if u.Clave == clave and (mutante == nil or u.Mutante == mutante) then
			n += 1
		end
	end
	return n
end

-- Cuántas criaturas tenés iguales a `f` (especie, tipo, personalidad y variante).
function Jugadores.contarIguales(d: Datos, f: Pedidos.Unidad): number
	local n = 0
	for _, u in d.Criaturas do
		if Pedidos.igual(u, f) then
			n += 1
		end
	end
	return n
end

-- ¿Tenés alguna de esa especie con esa personalidad? (para elegir los padres de una fusión)
function Jugadores.tiene(d: Datos, clave: string, personalidad: string): boolean
	for _, u in d.Criaturas do
		if u.Clave == clave and u.Personalidad == personalidad then
			return true
		end
	end
	return false
end

-- Saca una criatura igual a `f`. Devuelve false si no tenías.
function Jugadores.quitarCriatura(d: Datos, f: Pedidos.Unidad): boolean
	for i, u in d.Criaturas do
		if Pedidos.igual(u, f) then
			table.remove(d.Criaturas, i)
			return true
		end
	end
	return false
end

-- Las criaturas agrupadas (las iguales juntas), en el orden en que llegaron.
function Jugadores.grupos(d: Datos): { Formato.Grupo }
	local lista: { Formato.Grupo } = {}
	for _, u in d.Criaturas do
		local g: Formato.Grupo? = nil
		for _, otro in lista do
			if Pedidos.igual(otro, u) then
				g = otro
				break
			end
		end
		if g then
			g.Cantidad += 1
		else
			table.insert(lista, {
				Clave = u.Clave,
				Mutante = u.Mutante,
				Personalidad = u.Personalidad,
				Variante = u.Variante,
				Cantidad = 1,
			})
		end
	end
	return lista
end

-- "1:2:0;1-2:1:1" (especie, normales, mutantes), ordenado por especie.
local function resumen(d: Datos): string
	local cuentas: { [string]: { number } } = {}
	for _, u in d.Criaturas do
		local c = cuentas[u.Clave] or { 0, 0 }
		c[if u.Mutante then 2 else 1] += 1
		cuentas[u.Clave] = c
	end
	local partes = {}
	for clave, c in cuentas do
		table.insert(partes, clave .. ":" .. c[1] .. ":" .. c[2])
	end
	table.sort(partes)
	return table.concat(partes, ";")
end

---------------------------------------------------------------------------
-- Publicar (atributos que lee el cliente)
---------------------------------------------------------------------------

function Jugadores.publicarPedidos(jugador: Player)
	local d = datos[jugador]
	if not d then
		return
	end
	local lugares = {}
	for i = 1, Config.Pedidos.Activos do
		lugares[i] = { Pedido = d.Pedidos[i], Espera = d.EsperaPedido[i] }
	end
	jugador:SetAttribute("Pedidos", HttpService:JSONEncode(lugares))
	jugador:SetAttribute("Entregados", d.Entregados)
end

-- { especie = { x = true } } -> { "especie|x" } ordenada (variantes y sellos, para guardar
-- y publicar), y al revés.
function Jugadores.aLista(t: { [string]: { [string]: boolean } }): { string }
	local lista = {}
	for clave, vistas in t do
		for x in vistas do
			table.insert(lista, clave .. "|" .. x)
		end
	end
	table.sort(lista)
	return lista
end

function Jugadores.deLista(lista: { string }?): { [string]: { [string]: boolean } }
	local t = {}
	for _, texto in lista or {} do
		local clave, x = string.match(texto, "^([^|]+)|(.+)$")
		if clave and x then
			local vistas = t[clave] or {}
			vistas[x] = true
			t[clave] = vistas
		end
	end
	return t
end

function Jugadores.publicar(jugador: Player)
	local d = datos[jugador]
	if not d then
		return
	end
	jugador:SetAttribute("ADN", math.floor(d.ADN))
	jugador:SetAttribute("Especies", unir(d.Especies))
	jugador:SetAttribute("Mutantes", unir(d.Mutantes))
	jugador:SetAttribute("Criaturas", resumen(d))
	jugador:SetAttribute("Grupos", HttpService:JSONEncode(Jugadores.grupos(d)))
	jugador:SetAttribute("Pistas", Pistas.escribir(d.Pistas))
	jugador:SetAttribute("PistasCompradas", d.PistasCompradas)
	jugador:SetAttribute("PistasGratis", d.PistasGratis)
	jugador:SetAttribute("MejoraCorrales", d.Mejoras.Corrales)
	jugador:SetAttribute("MejoraRapida", d.Mejoras.Rapida)
	jugador:SetAttribute("MejoraNutrientes", d.Mejoras.Nutrientes)
	jugador:SetAttribute("FactorFusion", Mejoras.factorRapidez(d.Mejoras.Rapida))
	jugador:SetAttribute("Tope", Mejoras.tope(d.Mejoras.Corrales))
	local residuos = {}
	for _, r in d.Residuos do
		table.insert(residuos, r.A .. "|" .. r.B)
	end
	jugador:SetAttribute("Residuos", table.concat(residuos, ";"))
	jugador:SetAttribute("Catalizadores", Catalizadores.escribir(d.Catalizadores))
	jugador:SetAttribute("Variantes", table.concat(Jugadores.aLista(d.Variantes), ";"))
	jugador:SetAttribute("Sellos", table.concat(Jugadores.aLista(d.Sellos), ";"))
	Jugadores.publicarPedidos(jugador)
end

-- Los datos de un jugador nuevo (también los usa el simulador de balance).
function Jugadores.nuevos(): Datos
	local d: Datos = {
		ADN = Config.Economia.ADNInicial,
		Especies = {},
		Mutantes = {},
		Criaturas = {},
		SiguienteId = 1,
		Pistas = {},
		PistasCompradas = 0,
		PistasGratis = 0,
		GeneracionesPremiadas = {},
		Mejoras = Mejoras.iniciales(),
		Pedidos = {},
		EsperaPedido = {},
		Entregados = 0,
		SiguientePedido = 1,
		Residuos = {},
		Catalizadores = {},
		CatalizadoresVistos = {},
		Variantes = {},
		Sellos = {},
		OcupadoHasta = 0,
	}
	for _, n in Config.Economia.BasesIniciales do
		d.Especies[tostring(n)] = true
		Jugadores.agregarCriatura(d, tostring(n), false)
	end
	return d
end

-- Crea los datos de un jugador que entra: los guardados, si tiene, o los de un jugador nuevo.
function Jugadores.crear(jugador: Player, guardados: Guardados?)
	local d = Jugadores.nuevos()
	-- Modo prueba: las 10 bases y ADN de sobra (la gen 1 no paga premio porque viene regalada).
	if Config.Prueba.Activo then
		d.ADN = Config.Prueba.ADN
		for n = 1, Config.TamanioRueda do
			if not d.Especies[tostring(n)] then
				d.Especies[tostring(n)] = true
				Jugadores.agregarCriatura(d, tostring(n), false)
			end
		end
		d.GeneracionesPremiadas[1] = true
	elseif guardados and #guardados.Especies > 0 then
		d.ADN = guardados.ADN
		d.Especies = {}
		for _, k in guardados.Especies do
			d.Especies[k] = true
		end
		for _, k in guardados.Mutantes do
			d.Mutantes[k] = true
		end
		d.Criaturas = {}
		if guardados.Criaturas then
			for _, c in guardados.Criaturas do
				Jugadores.agregarCriatura(d, c.Clave, c.Mutante, c.Personalidad, c.Variante)
			end
		else
			-- Guardado de antes de los pedidos: una criatura por especie descubierta.
			for k in d.Especies do
				Jugadores.agregarCriatura(d, k, d.Mutantes[k] == true)
			end
		end
		d.Pistas = table.clone(guardados.Pistas)
		d.PistasCompradas = guardados.PistasCompradas
		d.PistasGratis = guardados.PistasGratis or 0
		for _, g in guardados.GeneracionesPremiadas do
			d.GeneracionesPremiadas[g] = true
		end
		d.Mejoras = table.clone(guardados.Mejoras)
		d.Entregados = guardados.Entregados or 0
		d.Residuos = table.clone(guardados.Residuos or {})
		d.Catalizadores = table.clone(guardados.Catalizadores or {})
		for _, k in guardados.CatalizadoresVistos or {} do
			d.CatalizadoresVistos[k] = true
		end
		d.Variantes = Jugadores.deLista(guardados.Variantes)
		for k, vistas in Jugadores.deLista(guardados.Sellos) do
			local sellos = d.Sellos[k] or {}
			for p in vistas do
				sellos[p] = true
			end
			d.Sellos[k] = sellos
		end
		for _, g in guardados.Pedidos or {} do
			if g.Lugar >= 1 and g.Lugar <= Config.Pedidos.Activos then
				d.Pedidos[g.Lugar] = g.Pedido
				d.SiguientePedido = math.max(d.SiguientePedido, g.Pedido.Id + 1)
			end
		end
	end
	datos[jugador] = d
	-- Si todavía no fusionó nunca, el cliente le muestra la flecha hasta la máquina.
	jugador:SetAttribute("Guia", Jugadores.cantidadEspecies(d) <= #Config.Economia.BasesIniciales)
	Jugadores.publicar(jugador)
end

function Jugadores.quitar(jugador: Player)
	datos[jugador] = nil
end

return Jugadores
