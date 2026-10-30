--!strict
-- Pruebas del paso 5a: golpe = Fuerza × Multi y clavijas especiales. Se corren desde la raíz:
--   lune run archivo/plinko-knight/pruebas/clavijas
-- 1) Todo gris: el golpe es la Fuerza (Multi 1).
-- 2) Cada tipo de clavija: lo que suma cada toque y que las cajas cierren.
-- 3) Niveles, bola de fuego y bola partida.
-- 4) Todo junto a nivel alto: no explota (topes) y el servidor coincide (golpe, oro y rotas).
-- 5) Convertir clavijas, azules rotas y quemadura en la mazmorra.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Revision = cargar("Revision")
local Clavijas = cargar("Clavijas")
local Mazmorra = cargar("Mazmorra")
local Azar = cargar("Azar")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
local N = #tablero.Clavijas
local TIROS = 120
local tope = Config.Punteria.AnguloMaximo
local function angulo(i: number): number
	return -tope + 2 * tope * (i - 1) / (TIROS - 1)
end

-- Un tablero de la partida con `cada`-ésima clavija del tipo dado (el resto gris).
local function conTipo(tipo: string, cada: number): { string }
	local t = Clavijas.nuevoTablero(N)
	for id = 1, N, cada do
		t[id] = tipo
	end
	return t
end

-- Un tablero mezclado al azar (con semilla) con todos los tipos.
local function mezclado(semilla: number): { string }
	local t = Clavijas.nuevoTablero(N)
	local azar = Azar.nuevo(semilla)
	for id = 1, N do
		local x = azar()
		if x < 0.12 then
			t[id] = "roja"
		elseif x < 0.2 then
			t[id] = "azul"
		elseif x < 0.28 then
			t[id] = "dorada"
		elseif x < 0.34 then
			t[id] = "verde"
		elseif x < 0.4 then
			t[id] = "violeta"
		end
	end
	return t
end

-- Todas las bolas dentro de las paredes, sin NaN, y el tiro terminado abajo.
local function tiroSano(res: any, nombre: string)
	chequear(res.Fin == "abajo", nombre .. ": no llegaron todas abajo")
	for k, rec in res.Recorridos do
		for paso = 1, #rec.X do
			local x = rec.X[paso]
			if
				x ~= x
				or x - Config.Bola.Radio < tablero.ParedIzquierda - 1e-9
				or x + Config.Bola.Radio > tablero.ParedDerecha + 1e-9
			then
				chequear(false, ("%s: la bola %d salió por el costado"):format(nombre, k))
				break
			end
		end
	end
end

-- Rehace las cuentas con los toques: las cajas tienen que cerrar con lo que dice el resultado.
local function cajasCierran(res: any, nombre: string)
	local f, m, oro = Config.Danio.FuerzaInicial, Config.Danio.MultiInicial, 0
	for _, t in res.Toques do
		f += t.Fuerza
		m = math.min((m + t.Multi) * t.PorMulti, Config.TopeMulti)
		oro += t.Oro
		chequear(
			math.abs(t.FuerzaTotal - f) < 1e-6 and math.abs(t.MultiTotal - m) < 1e-6,
			nombre .. ": las cajas no cierran"
		)
	end
	chequear(
		res.Danio == math.min(math.floor(f * m), Config.TopeDanioTiro),
		nombre .. ": golpe mal"
	)
	chequear(res.Oro == oro, nombre .. ": oro mal")
end

local function promedio(lista: { number }): number
	local s = 0
	for _, x in lista do
		s += x
	end
	return if #lista > 0 then s / #lista else 0
end

-- 1) Todo gris
do
	local golpes = {}
	for i = 1, TIROS do
		local res = Simulacion.simular(tablero, angulo(i), Config.Bola, {}, i * 31)
		chequear(res.Multi == 1, "gris: el Multi no es 1")
		chequear(res.Danio == res.ClavijasDistintas * 2, "gris: el golpe no es 2 por clavija")
		cajasCierran(res, "gris")
		table.insert(golpes, res.Danio)
	end
	print(("Todo gris: golpe promedio %.1f"):format(promedio(golpes)))
end

-- 2) Cada tipo
do
	for _, tipo in Config.OrdenClavijas do
		local golpes, tocadas, oros, rotas = {}, {}, {}, 0
		for i = 1, TIROS do
			local mods = { Tablero = conTipo(tipo, 3) }
			local res = Simulacion.simular(tablero, angulo(i), Config.Bola, mods, i * 31)
			local nombre = ("%s, tiro %d"):format(tipo, i)
			tiroSano(res, nombre)
			cajasCierran(res, nombre)
			local anteriorPorBola: { [number]: string } = {}
			for _, t in res.Toques do
				chequear(t.Tipo == mods.Tablero[t.Clavija], nombre .. ": tipo de clavija mal")
				local esperadas = if anteriorPorBola[t.Bola] == "violeta"
					then Clavijas.eco("violeta", 1)
					else 1
				chequear(t.Veces == esperadas, nombre .. ": la violeta no hizo contar doble")
				anteriorPorBola[t.Bola] = t.Tipo
				if t.Tipo == "roja" then
					chequear(t.Multi == 2 * t.Veces, nombre .. ": la roja no dio +2 Multi")
				elseif t.Tipo == "azul" then
					chequear(t.PorMulti == 2 ^ t.Veces, nombre .. ": la azul no dio ×2")
				elseif t.Tipo == "dorada" then
					chequear(
						t.Oro == t.Veces and t.Fuerza == 6 * t.Veces,
						nombre .. ": la dorada mal"
					)
				elseif t.Tipo == "verde" then
					chequear(t.Fuerza == 10 * t.Veces, nombre .. ": la verde no dio +10")
				elseif t.Tipo == "gris" then
					chequear(t.Fuerza == 2 * t.Veces, nombre .. ": la gris no dio +2")
				end
				chequear(
					not t.Rota or t.Tipo == "azul",
					nombre .. ": se rompió algo que no es azul"
				)
			end
			local vistas: { [number]: boolean } = {}
			for _, id in res.Rotas do
				chequear(mods.Tablero[id] == "azul" and not vistas[id], nombre .. ": rota mal")
				vistas[id] = true
			end
			rotas += #res.Rotas
			table.insert(golpes, res.Danio)
			table.insert(tocadas, res.ClavijasDistintas)
			table.insert(oros, res.Oro)
		end
		print(
			("Un tercio %s: golpe %.1f · %.1f clavijas · oro %.1f · azules rotas %d"):format(
				tipo,
				promedio(golpes),
				promedio(tocadas),
				promedio(oros),
				rotas
			)
		)
	end

	-- Azul: siempre se rompe o nunca, según la chance.
	local rotura = Config.Clavijas.azul.Rotura
	Config.Clavijas.azul.Rotura = 1
	local siempre = Simulacion.simular(tablero, 5, Config.Bola, { Tablero = conTipo("azul", 1) }, 7)
	local tocadasAzul: { [number]: boolean } = {}
	for _, t in siempre.Toques do
		tocadasAzul[t.Clavija] = true
	end
	local cuantas = 0
	for _ in tocadasAzul do
		cuantas += 1
	end
	chequear(#siempre.Rotas == cuantas, "azul: con chance 1 no se rompieron todas las tocadas")
	Config.Clavijas.azul.Rotura = 0
	local nunca = Simulacion.simular(tablero, 5, Config.Bola, { Tablero = conTipo("azul", 1) }, 7)
	chequear(#nunca.Rotas == 0, "azul: con chance 0 se rompió alguna")
	Config.Clavijas.azul.Rotura = rotura

	-- Huecos: la bola pasa derecho y no suma nada.
	local vacio = Simulacion.simular(tablero, 10, Config.Bola, { Tablero = conTipo("hueco", 1) }, 3)
	chequear(
		#vacio.Toques == 0 and vacio.Danio == 0 and vacio.Fin == "abajo",
		"huecos: la bola chocó"
	)

	-- Verde: tiene que cambiar el recorrido (resorte).
	local gris = Simulacion.simular(tablero, 0, Config.Bola, {}, 11)
	local verde = Simulacion.simular(tablero, 0, Config.Bola, { Tablero = conTipo("verde", 1) }, 11)
	chequear(#gris.X ~= #verde.X or gris.X[#gris.X] ~= verde.X[#verde.X], "verde: no hizo resorte")
end

-- 3) Niveles y bolas
do
	local niveles = { roja = 3, azul = 2, dorada = 2, verde = 2, violeta = 2, gris = 3 }
	chequear(Clavijas.multi("roja", 3) == 6, "roja nivel 3 tiene que dar +6")
	chequear(Clavijas.porMulti("azul", 2) == 2.5, "azul nivel 2 tiene que dar ×2,5")
	chequear(Clavijas.oro("dorada", 2) == 2, "dorada nivel 2 tiene que dar 2 de oro")
	chequear(Clavijas.fuerza("verde", 2) == 15, "verde nivel 2 tiene que dar +15")
	chequear(Clavijas.eco("violeta", 2) == 3, "violeta nivel 2 tiene que contar 3 veces")
	chequear(Clavijas.fuerza("gris", 3) == 4, "gris nivel 3 tiene que dar +4")
	for i = 1, 30 do
		local mods = { Tablero = mezclado(i), Niveles = niveles }
		local res = Simulacion.simular(tablero, angulo(i * 4), Config.Bola, mods, i)
		cajasCierran(res, "niveles " .. i)
	end

	local f = Config.Bolas.fuego
	for i = 1, 30 do
		local res = Simulacion.simular(tablero, angulo(i * 4), Config.Bola, { Bola = "fuego" }, i)
		chequear(res.Fuego and res.Quemadura == f.Quemadura, "fuego: quemadura mal")
		chequear(
			res.Danio == res.ClavijasDistintas * (2 + f.FuerzaExtra),
			"fuego: no suma +1 Fuerza"
		)
	end

	local partidas = 0
	for i = 1, TIROS do
		local res =
			Simulacion.simular(tablero, angulo(i), Config.Bola, { Bola = "partida" }, i * 31)
		tiroSano(res, "partida " .. i)
		chequear(#res.Recorridos <= 2, "partida: más de 2 bolas")
		if #res.Recorridos == 2 then
			partidas += 1
			local antes = 0
			for _, t in res.Toques do
				if t.Bola == 1 and t.Paso <= res.Recorridos[2].Inicio then
					antes += 1
				end
			end
			chequear(
				antes == Config.Bolas.partida.ToqueParaDividir,
				"partida: se partió en otro toque"
			)
		end
	end
	chequear(partidas > TIROS * 0.8, "partida: casi ningún tiro se partió")
end

-- 4) Todo junto
do
	for _, nivel in { 1, 3, 10 } do
		local golpes, maximo = {}, 0
		local niveles: { [string]: number } = {}
		for tipo in Config.Clavijas do
			niveles[tipo] = nivel
		end
		for i = 1, TIROS do
			local mods = {
				Tablero = mezclado(i * 7),
				Niveles = niveles,
				Bola = Config.OrdenBolas[i % 3 + 1],
			}
			local res = Simulacion.simular(tablero, angulo(i), Config.Bola, mods, i * 31)
			local nombre = ("todo nivel %d, tiro %d"):format(nivel, i)
			tiroSano(res, nombre)
			cajasCierran(res, nombre)
			chequear(#res.Recorridos <= Config.TopeBolas, nombre .. ": más bolas que el tope")
			chequear(
				res.Danio <= Config.TopeDanioTiro and res.Danio == res.Danio,
				nombre .. ": golpe fuera de tope"
			)
			local rev = Revision.revisar(tablero, angulo(i), i * 31, mods, res.Danio)
			chequear(
				rev.Danio == res.Danio and not rev.Corregido,
				nombre .. ": el servidor no coincide"
			)
			chequear(
				rev.Oro == res.Oro and #rev.Rotas == #res.Rotas,
				nombre .. ": oro o rotas no coinciden"
			)
			local falso = Revision.revisar(tablero, angulo(i), i * 31, mods, res.Danio * 3 + 100)
			chequear(
				falso.Corregido and falso.Danio == res.Danio,
				nombre .. ": golpe falso no corregido"
			)
			table.insert(golpes, res.Danio)
			maximo = math.max(maximo, res.Danio)
		end
		print(
			("Tablero mezclado, todo nivel %d: golpe promedio %s, máximo %s"):format(
				nivel,
				Clavijas.numeroCorto(promedio(golpes)),
				Clavijas.numeroCorto(maximo)
			)
		)
	end
	-- Tope de Multi y de golpe: todo azul a nivel 30.
	local res = Simulacion.simular(
		tablero,
		0,
		Config.Bola,
		{ Tablero = conTipo("azul", 1), Niveles = { azul = 30 } },
		5
	)
	chequear(res.Multi <= Config.TopeMulti and res.Danio <= Config.TopeDanioTiro, "tope: se pasó")
end

-- 5) Mazmorra: números cortos, convertir, rotas y quemadura (la tienda: pruebas/tienda)
do
	chequear(Clavijas.numeroCorto(1.75) == "1,75", "número corto: 1,75")
	chequear(Clavijas.numeroCorto(12400) == "12,4 mil", "número corto: 12,4 mil")
	chequear(Clavijas.numeroCorto(1500000) == "1,5 M", "número corto: 1,5 M")
	chequear(Clavijas.numeroCorto(168) == "168", "número corto: 168")

	local e = Mazmorra.nueva()
	chequear(#e.Tablero == N and e.Bola == "hierro" and e.Oro == 0, "la partida no arranca bien")
	local ids = Clavijas.convertir(e.Tablero, "azul", 2, 9)
	chequear(#ids == 2 and e.Tablero[ids[1]] == "azul", "no convirtió 2 clavijas")

	-- Convertir solo agarra grises.
	local t2 = Clavijas.nuevoTablero(N)
	for id = 1, N - 1 do
		t2[id] = "roja"
	end
	local solo = Clavijas.convertir(t2, "verde", 2, 3)
	chequear(
		#solo == 1 and solo[1] == N and t2[N] == "verde",
		"convertir agarró una que no era gris"
	)

	-- Rotas y oro.
	local ida = (ids or {})[1]
	Mazmorra.cobrarTiro(e, 3, { ida })
	chequear(
		e.Tablero[ida] == "hueco" and e.Oro == 3,
		"cobrar el tiro no rompió la azul o no dio oro"
	)
	Mazmorra.cobrarTiro(e, 0, { 1 })
	chequear(e.Tablero[1] ~= "hueco" or ida == 1, "rompió una clavija que no era azul")

	-- Copiar no comparte el tablero.
	local copia = Mazmorra.copiar(e)
	copia.Tablero[2] = "roja"
	chequear(
		e.Tablero[2] ~= "roja" or e.Tablero[2] == copia.Tablero[2] and false,
		"copiar comparte el tablero"
	)

	-- Quemadura de la bola de fuego.
	local q = Config.Bolas.fuego.Quemadura
	local vida = e.VidaMonstruo
	local t = Mazmorra.turno(e, 10, q)
	chequear(t.Quemadura == q and e.VidaMonstruo == vida - 10 - q, "la quemadura no pegó")
	Mazmorra.turno(e, 1, 0)
	t = Mazmorra.turno(e, 1, 0)
	chequear(t.Quemadura == 0, "la quemadura no se apagó")
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Clavijas: todo OK")
