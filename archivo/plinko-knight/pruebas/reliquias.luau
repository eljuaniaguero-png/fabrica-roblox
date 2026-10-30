--!strict
-- Pruebas del paso 5c: las 20 reliquias. Se corren desde la raíz del repositorio:
--   lune run archivo/plinko-knight/pruebas/reliquias
-- 1) Cada reliquia sola: hace lo que dice (comparando el mismo tiro con y sin ella).
-- 2) Las que crecen (Trofeo, Callo, Racha) y la Bolsa de Cuero, en la mazmorra.
-- 3) El orden importa: sumar Multi antes o después de multiplicarlo.
-- 4) Combinaciones de 5 al azar: no explotan y el servidor coincide.
-- 5) Tienda: qué reliquias salen (rarezas), comprar, vender y mover.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Revision = cargar("Revision")
local Clavijas = cargar("Clavijas")
local Mazmorra = cargar("Mazmorra")
local Tienda = cargar("Tienda")
local Azar = cargar("Azar")
local ReliquiasModulo = cargar("Reliquias")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
local N = #tablero.Clavijas
local R = Config.Reliquias
local TIROS = 60
local function angulo(i: number): number
	return -55 + 110 * (i - 1) / (TIROS - 1)
end

local function con(...: string): { any }
	local lista = {}
	for _, id in { ... } do
		table.insert(lista, { Id = id, Contador = 0, Precio = 4 })
	end
	return lista
end

local function conTipo(tipo: string, cada: number): { string }
	local t = Clavijas.nuevoTablero(N)
	for id = 1, N, cada do
		t[id] = tipo
	end
	return t
end

local function cerca(a: number, b: number): boolean
	return math.abs(a - b) <= 1e-6 * math.max(1, math.abs(a), math.abs(b))
end

local function tiroSano(res: any, nombre: string)
	chequear(res.Fin == "abajo", nombre .. ": no llegaron todas abajo")
	chequear(#res.Recorridos <= Config.TopeBolas, nombre .. ": más bolas que el tope")
	chequear(res.Danio == res.Danio and res.Danio <= Config.TopeDanioTiro, nombre .. ": golpe raro")
	for _, rec in res.Recorridos do
		for _, x in rec.X do
			if x ~= x or x < tablero.ParedIzquierda or x > tablero.ParedDerecha then
				chequear(false, nombre .. ": una bola salió del tablero")
				break
			end
		end
	end
end

-- El mismo tiro con y sin las reliquias (y con los mismos otros modificadores).
local function par(i: number, base: any, lista: { any }): (any, any)
	local sin = Simulacion.simular(tablero, angulo(i), Config.Bola, base, i * 31)
	local mods = table.clone(base)
	mods.Reliquias = lista
	local conR = Simulacion.simular(tablero, angulo(i), Config.Bola, mods, i * 31)
	return sin, conR
end

-- 1) Cada reliquia sola
do
	local roja = conTipo("roja", 4)
	local rojas = 0
	for _, t in roja do
		if t == "roja" then
			rojas += 1
		end
	end
	for i = 1, TIROS do
		local sin, c = par(i, { Tablero = roja }, con("brasa"))
		chequear(cerca(c.Multi, sin.Multi + rojas * R.brasa.MultiPorRoja), "brasa: Multi mal")
		chequear(#c.Activaciones == 1 and c.Activaciones[1].Id == "brasa", "brasa: no se activó")

		sin, c = par(i, { Tablero = roja }, con("rubi"))
		local esperado = 1
		for _, t in sin.Toques do
			esperado += t.Multi * R.rubi.Factor
		end
		chequear(cerca(c.Multi, esperado), "rubí: las rojas no dieron el doble")

		sin, c = par(i, {}, con("martillo"))
		local extra = if sin.ClavijasDistintas >= R.martillo.Clavijas then R.martillo.Fuerza else 0
		chequear(c.Fuerza == sin.Fuerza + extra, "martillo: Fuerza mal")

		sin, c = par(i, {}, con("cadena"))
		chequear(
			cerca(c.Multi, 1 + math.floor(sin.ClavijasDistintas / R.cadena.Cada) * R.cadena.Multi),
			"cadena: Multi mal"
		)

		sin, c = par(i, { Bola = "partida" }, con("enjambre"))
		chequear(
			cerca(c.Multi, sin.Multi * R.enjambre.PorBola ^ (#sin.Recorridos - 1)),
			"enjambre: mal"
		)

		sin, c = par(i, { Bola = "partida" }, con("hoja"))
		local f = 0
		for _, t in c.Toques do
			f += t.Fuerza
			if t.Bola > 1 then
				chequear(
					t.Fuerza == 2 * R.hoja.Factor * t.Veces,
					"hoja: la bola extra no sumó doble"
				)
			end
		end
		chequear(c.Fuerza == f, "hoja: la Fuerza no cierra")

		sin, c = par(i, { Oro = 17 }, con("avaro"))
		chequear(
			cerca(c.Multi, 1 + math.floor(17 / R.avaro.Cada) * R.avaro.Multi),
			"avaro: Multi mal con 17 de oro"
		)

		sin, c = par(i, { Tablero = conTipo("dorada", 3) }, con("toqueOro"))
		for _, t in c.Toques do
			if t.Tipo == "dorada" then
				chequear(
					t.PorMulti == R.toqueOro.PorMulti ^ t.Veces,
					"toque de oro: la dorada no multiplicó"
				)
			end
		end

		local tenidas = con("trofeo", "callo", "racha")
		tenidas[1].Contador, tenidas[2].Contador, tenidas[3].Contador = 3, 2, 2
		sin, c = par(i, {}, tenidas)
		chequear(
			cerca(c.Multi, (1 + 3 * R.trofeo.Multi) * (1 + 2 * R.racha.PorPelea)),
			"trofeo y racha: Multi mal"
		)
		chequear(c.Fuerza == sin.Fuerza + 2 * R.callo.Fuerza, "callo: Fuerza mal")

		sin, c = par(i, { Tablero = conTipo("roja", 4), Bola = "fuego" }, con("yesca"))
		chequear(
			c.Quemadura == math.max(Config.Bolas.fuego.Quemadura, math.floor(c.Multi)),
			"yesca: mal"
		)
		chequear(
			sin.Quemadura == Config.Bolas.fuego.Quemadura,
			"sin yesca la quemadura es la normal"
		)

		sin, c = par(i, { Tablero = conTipo("azul", 3) }, con("vidrio"))
		for _, t in c.Toques do
			if t.Tipo == "azul" then
				chequear(t.PorMulti == R.vidrio.PorMulti ^ t.Veces, "vidrio: la azul no dio ×3")
			end
		end

		sin, c = par(i, { Vida = 10 }, con("aliento"))
		chequear(
			cerca(c.Multi, sin.Multi * R.aliento.Factor),
			"aliento: con poca vida no multiplicó"
		)
		sin, c = par(i, { Vida = 40 }, con("aliento"))
		chequear(c.Multi == sin.Multi and #c.Activaciones == 0, "aliento: con vida multiplicó")

		sin, c = par(i, { TirosPelea = 0 }, con("paciencia"))
		chequear(c.Danio == 0 and c.Paciencia, "paciencia: el primer tiro hizo daño")
		sin, c = par(i, { TirosPelea = 1 }, con("paciencia"))
		chequear(cerca(c.Multi, sin.Multi * R.paciencia.Factor), "paciencia: el segundo no fue ×4")
		sin, c = par(i, { TirosPelea = 2 }, con("paciencia"))
		chequear(c.Danio == sin.Danio, "paciencia: el tercero cambió")

		sin, c = par(i, {}, con("corona"))
		chequear(cerca(c.Multi, sin.Multi * R.corona.Factor), "corona: no fue ×2")

		sin, c = par(i, { Tablero = conTipo("violeta", 3) }, con("ecoInfinito"))
		local anterior: { [number]: string } = {}
		for _, t in c.Toques do
			if anterior[t.Bola] == "violeta" then
				chequear(t.Veces == R.ecoInfinito.Veces, "eco infinito: no contó 4 veces")
			end
			anterior[t.Bola] = t.Tipo
		end

		sin, c = par(i, {}, con("midas"))
		local dePrimera = 0
		for _, t in c.Toques do
			if t.Bola == 1 then
				dePrimera += t.Veces
			end
		end
		chequear(c.Oro == sin.Oro + dePrimera * R.midas.Oro, "midas: oro mal")
	end

	-- Gemela: con hierro se parte en el toque 6; con la partida, hasta el tope de bolas.
	local partidas, conMasDeDos = 0, 0
	for i = 1, TIROS do
		local _, c = par(i, {}, con("gemela"))
		tiroSano(c, "gemela " .. i)
		if #c.Recorridos >= 2 then
			partidas += 1
			local antes = 0
			for _, t in c.Toques do
				if t.Bola == 1 and t.Paso <= c.Recorridos[2].Inicio then
					antes += 1
				end
			end
			chequear(antes == R.gemela.Toque, "gemela: se partió en otro toque")
		end
		local _, c2 = par(i, { Bola = "partida" }, con("gemela"))
		tiroSano(c2, "gemela con partida " .. i)
		if #c2.Recorridos > 2 then
			conMasDeDos += 1
		end
	end
	chequear(partidas > TIROS * 0.6, "gemela: casi nunca se partió")
	chequear(conMasDeDos > 0, "gemela con la partida: nunca hubo más de 2 bolas")

	-- Vidrio: se rompe más o menos 1 de cada 2.
	local tocadas, rotas = 0, 0
	for i = 1, TIROS do
		local _, c = par(i, { Tablero = conTipo("azul", 2) }, con("vidrio"))
		for _, t in c.Toques do
			if t.Tipo == "azul" then
				tocadas += 1
			end
		end
		rotas += #c.Rotas
	end
	local parte = rotas / math.max(tocadas, 1)
	print(("Vidrio Frágil: se rompió el %.0f %% de las azules tocadas"):format(parte * 100))
	chequear(parte > 0.3 and parte < 0.7, "vidrio: no se rompe 1 de cada 2")
end

-- 2) En la mazmorra: las que crecen y la Bolsa
do
	local e = Mazmorra.nueva()
	e.Reliquias = con("trofeo", "racha", "callo", "bolsa")
	Mazmorra.turno(e, 10000000) -- de un tiro y sin que te peguen
	chequear(e.Reliquias[1].Contador == 1, "trofeo: no creció al matar de un tiro")
	chequear(e.Reliquias[2].Contador == 1, "racha: no creció al ganar sin que te peguen")
	Tienda.abrir(e, 1)
	Tienda.bajar(e)
	Mazmorra.turno(e, 1) -- te pega
	chequear(e.Reliquias[2].Contador == 0, "racha: no se reinició al pegarte")
	Mazmorra.turno(e, 10000000) -- segundo tiro: sin trofeo, y te pegaron en esta pelea
	chequear(e.Reliquias[1].Contador == 1, "trofeo: creció matando en dos tiros")
	chequear(e.Reliquias[2].Contador == 0, "racha: creció en una pelea donde te pegaron")

	e.Tablero[3] = "azul"
	e.Tablero[4] = "azul"
	Mazmorra.cobrarTiro(e, 0, { 3, 4, 5 }) -- la 5 no es azul
	chequear(e.Reliquias[3].Contador == 2, "callo: no contó las azules rotas")

	local b = Mazmorra.nueva()
	b.Reliquias = con("bolsa")
	b.Oro = 100
	Mazmorra.turno(b, 10000000)
	chequear(b.UltimoOro.Interes == R.bolsa.InteresTope, "bolsa: el interés no llegó a 10")

	-- Las reliquias llegan a la simulación con el oro, la vida y los tiros de la pelea.
	local m = Mazmorra.modificadores(e)
	chequear(
		m.Reliquias == e.Reliquias and m.Vida == e.Vida and m.TirosPelea == e.TirosPelea,
		"mods mal"
	)
end

-- 3) El orden importa
do
	local roja = conTipo("roja", 4)
	for i = 1, 20 do
		local _, a = par(i, { Tablero = roja }, con("brasa", "corona"))
		local _, b = par(i, { Tablero = roja }, con("corona", "brasa"))
		chequear(a.Multi > b.Multi, "orden: sumar antes de multiplicar tiene que dar más")
		chequear(
			a.Activaciones[1].Lugar == 1 and a.Activaciones[2].Lugar == 2,
			"orden: activaciones mal"
		)
	end
end

-- 4) Combinaciones de 5 al azar
do
	local azar = Azar.nuevo(99)
	local maximo = 0
	for i = 1, 200 do
		local ids = table.clone(Config.OrdenReliquias)
		Azar.mezclar(ids, azar)
		local lista = con(ids[1], ids[2], ids[3], ids[4], ids[5])
		for _, r in lista do
			r.Contador = math.floor(azar() * 5)
		end
		local t = Clavijas.nuevoTablero(N)
		for id = 1, N do
			local x = azar()
			t[id] = if x < 0.15
				then "roja"
				elseif x < 0.25 then "azul"
				elseif x < 0.32 then "dorada"
				elseif x < 0.38 then "verde"
				elseif x < 0.45 then "violeta"
				else "gris"
		end
		local mods = {
			Tablero = t,
			Niveles = { roja = 1 + math.floor(azar() * 3) },
			Bola = Config.OrdenBolas[math.floor(azar() * 3) + 1],
			Reliquias = lista,
			Oro = math.floor(azar() * 40),
			Vida = 1 + math.floor(azar() * 50),
			TirosPelea = math.floor(azar() * 3),
			Furia = azar() < 0.2,
		}
		local ang = (azar() * 2 - 1) * 60
		local res = Simulacion.simular(tablero, ang, Config.Bola, mods, i)
		tiroSano(res, "combo " .. i)
		local rev = Revision.revisar(tablero, ang, i, mods, res.Danio)
		chequear(rev.Danio == res.Danio and not rev.Corregido, "combo: el servidor no coincide")
		chequear(
			rev.Quemadura == res.Quemadura and rev.Oro == res.Oro,
			"combo: quemadura u oro no coinciden"
		)
		maximo = math.max(maximo, res.Danio)
	end
	print("Combinaciones de 5 reliquias: golpe máximo " .. Clavijas.numeroCorto(maximo))
end

-- 5) Tienda
do
	local cuenta: { [string]: number } = {}
	local total = 0
	for semilla = 1, 4000 do
		for _, item in Tienda.generar(semilla) do
			if item.Clase == "reliquia" then
				local rareza = R[item.Id].Rareza
				cuenta[rareza] = (cuenta[rareza] or 0) + 1
				total += 1
				chequear(item.Precio == Config.Rarezas[rareza].Precio, "precio de reliquia mal")
			end
		end
	end
	for _, rareza in Config.OrdenRarezas do
		local parte = (cuenta[rareza] or 0) / total * 100
		local esperado = Config.Rarezas[rareza].Peso
		print(("Rareza %s: %.1f %% (esperado %d %%)"):format(rareza, parte, esperado))
		chequear(math.abs(parte - esperado) < 3, "las chances de rareza no son las que se muestran")
	end

	-- No salen las que ya tenés ni dos iguales.
	local e = Mazmorra.nueva()
	e.Reliquias = con("brasa", "cadena", "hoja", "bolsa")
	for semilla = 1, 500 do
		local vistas: { [string]: boolean } = {}
		for _, item in Tienda.generar(semilla, e) do
			if item.Clase == "reliquia" then
				chequear(not vistas[item.Id], "salió dos veces la misma reliquia")
				chequear(
					not ReliquiasModulo.tiene(e.Reliquias, item.Id),
					"salió una reliquia que ya tenés"
				)
				vistas[item.Id] = true
			end
		end
	end

	-- Comprar, vender y mover.
	e = Mazmorra.nueva()
	Mazmorra.turno(e, 10000000)
	Tienda.abrir(e, 3)
	e.Oro = 100
	e.Tienda.Items = {
		{ Clase = "reliquia", Id = "corona", Precio = 12, Vendido = false },
		{ Clase = "reliquia", Id = "brasa", Precio = 4, Vendido = false },
	}
	chequear(
		Tienda.comprar(e, 1, nil) and e.Reliquias[1].Id == "corona" and e.Oro == 88,
		"no compró"
	)
	chequear(Tienda.comprar(e, 2, nil) and #e.Reliquias == 2, "no compró la segunda")
	chequear(Tienda.mover(e, 2, 1) and e.Reliquias[1].Id == "brasa", "mover no anduvo")
	chequear(not Tienda.mover(e, 1, 5), "movió a un lugar vacío")
	chequear(not Tienda.mover(e, "1", 2), "movió con un lugar de texto")
	chequear(
		Tienda.vender(e, 2) and e.Oro == 88 - 4 + 6 and #e.Reliquias == 1,
		"vender no dio la mitad"
	)
	chequear(not Tienda.vender(e, 3), "vendió un lugar vacío")
	e.Reliquias = con("trofeo", "callo", "racha", "yesca", "vidrio")
	e.Tienda.Items = { { Clase = "reliquia", Id = "midas", Precio = 12, Vendido = false } }
	chequear(not Tienda.comprar(e, 1, nil), "compró con los 5 lugares llenos")
	e.Tienda.Items = { { Clase = "reliquia", Id = "trofeo", Precio = 7, Vendido = false } }
	table.remove(e.Reliquias, 5)
	chequear(not Tienda.comprar(e, 1, nil), "compró una reliquia repetida")
	Tienda.bajar(e)
	chequear(
		not Tienda.vender(e, 1) and not Tienda.mover(e, 1, 2),
		"vendió o movió fuera de la tienda"
	)
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Reliquias: todo OK")
