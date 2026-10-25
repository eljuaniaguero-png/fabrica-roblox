--!strict
-- Pruebas de las mejoras (etapa 5). Se corren desde la raíz del repositorio:
--   lune run plinko-knight/pruebas/mejoras
-- 1) Bola de fuego: daño por clavija, quemadura y que no cambie el recorrido.
-- 2) Clavija que duplica: qué clavijas son rojas, el ×2 y que cada una duplique una vez por tiro.
-- 3) Bola que se divide: en qué toque se parte, que las dos sumen y lleguen abajo.
-- 4) Las tres juntas a nivel alto: no explota (tope de bolas y de daño) y el servidor coincide.
-- 5) Elegir 1 de 3 y la quemadura en la mazmorra.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Revision = cargar("Revision")
local Mejoras = cargar("Mejoras")
local Mazmorra = cargar("Mazmorra")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
local TIROS = 150
local tope = Config.Punteria.AnguloMaximo
local function angulo(i: number): number
	return -tope + 2 * tope * (i - 1) / (TIROS - 1)
end

-- Todas las bolas de un tiro dentro de las paredes, sin NaN, y el tiro terminado abajo.
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

-- 1) Bola de fuego
do
	for nivel = 1, 3 do
		local porClavija = Config.Danio.PorClavija + Config.Mejoras.Fuego.DanioExtraPorClavija
		local quemadura = Config.Mejoras.Fuego.Quemadura
			+ (nivel - 1) * Config.Mejoras.Fuego.QuemaduraPorNivel
		local suma = 0
		for i = 1, TIROS do
			local sin = Simulacion.simular(tablero, angulo(i), Config.Bola, {}, i * 31)
			local con = Simulacion.simular(
				tablero,
				angulo(i),
				Config.Bola,
				{ Niveles = { Fuego = nivel } },
				i * 31
			)
			chequear(
				#sin.X == #con.X and sin.X[#sin.X] == con.X[#con.X],
				"fuego: cambió el recorrido de la bola"
			)
			chequear(
				con.Danio == con.ClavijasDistintas * porClavija,
				("fuego %d: daño %d con %d clavijas"):format(
					nivel,
					con.Danio,
					con.ClavijasDistintas
				)
			)
			chequear(con.Fuego and con.Quemadura == quemadura, "fuego: quemadura mal")
			chequear(not sin.Fuego and sin.Quemadura == 0, "sin fuego no tiene que quemar")
			suma += con.Danio
		end
		print(
			("Fuego nivel %d: %d por clavija, quema %d · daño promedio %.1f"):format(
				nivel,
				porClavija,
				quemadura,
				suma / TIROS
			)
		)
	end
end

-- 2) Clavija que duplica
do
	local d = Config.Mejoras.Duplica
	local filaDe: { [number]: number } = {}
	for _, c in tablero.Clavijas do
		filaDe[c.Id] = c.Fila
	end
	for nivel = 1, 3 do
		local rojas = Mejoras.rojas(tablero, 777, nivel)
		chequear(
			#rojas == d.ClavijasRojas + (nivel - 1) * d.ClavijasRojasPorNivel,
			("duplica %d: hay %d rojas"):format(nivel, #rojas)
		)
		local vistas: { [number]: boolean } = {}
		for _, id in rojas do
			chequear(not vistas[id], "duplica: una clavija roja repetida")
			vistas[id] = true
			chequear(
				filaDe[id] >= d.FilaMinima and filaDe[id] <= d.FilaMaxima,
				"duplica: roja fuera de las filas permitidas"
			)
		end
		local otra = Mejoras.rojas(tablero, 777, nivel)
		chequear(
			table.concat(otra, ",") == table.concat(rojas, ","),
			"duplica: misma semilla, otras rojas"
		)
	end
	chequear(#Mejoras.rojas(tablero, 1, 0) == 0, "sin la mejora no hay rojas")
	local distintas = 0
	for semilla = 1, 20 do
		if
			table.concat(Mejoras.rojas(tablero, semilla, 1), ",")
			~= table.concat(Mejoras.rojas(tablero, 1, 1), ",")
		then
			distintas += 1
		end
	end
	chequear(distintas > 10, "duplica: las rojas casi no cambian con la semilla")

	for nivel = 1, 3 do
		local conDos, suma, sumaSin = 0, 0, 0
		for i = 1, TIROS do
			local rojas = Mejoras.rojas(tablero, i * 13, nivel)
			local mej = { Niveles = { Duplica = nivel }, Rojas = rojas }
			local res = Simulacion.simular(tablero, angulo(i), Config.Bola, mej, i * 31)
			local sin = Simulacion.simular(tablero, angulo(i), Config.Bola, {}, i * 31)
			local esRoja: { [number]: boolean } = {}
			for _, id in rojas do
				esRoja[id] = true
			end
			local anterior = 0
			local duplicadas: { [number]: boolean } = {}
			local hubo = false
			for _, t in res.Toques do
				local esperado = anterior + t.Danio
				if t.Duplico then
					chequear(
						esRoja[t.Clavija] == true,
						"duplica: duplicó una clavija que no es roja"
					)
					chequear(not duplicadas[t.Clavija], "duplica: la misma roja duplicó dos veces")
					duplicadas[t.Clavija] = true
					esperado *= d.Factor
					hubo = true
				else
					chequear(not esRoja[t.Clavija], "duplica: tocó una roja y no duplicó")
				end
				chequear(t.Total == esperado, "duplica: el total no cierra")
				anterior = t.Total
			end
			chequear(res.Danio == anterior, "duplica: el daño final no es el último total")
			if hubo then
				conDos += 1
			end
			suma += res.Danio
			sumaSin += sin.Danio
		end
		print(
			("Duplica nivel %d: %d rojas · %.0f %% de los tiros tocan una · daño %.1f (sin: %.1f)"):format(
				nivel,
				#Mejoras.rojas(tablero, 1, nivel),
				conDos / TIROS * 100,
				suma / TIROS,
				sumaSin / TIROS
			)
		)
	end

	-- Las rojas no duplican si no tenés la mejora.
	local res = Simulacion.simular(tablero, 0, Config.Bola, { Rojas = { 1, 2, 3, 4, 5, 6, 7 } }, 5)
	for _, t in res.Toques do
		chequear(not t.Duplico, "duplica: duplicó sin tener la mejora")
	end

	-- Todas rojas: el daño se dispara y tiene que frenar en el tope.
	local todas: { number } = {}
	for _, c in tablero.Clavijas do
		table.insert(todas, c.Id)
	end
	local maximo = 0
	for i = 1, 30 do
		local r = Simulacion.simular(
			tablero,
			angulo(i * 5),
			Config.Bola,
			{ Niveles = { Duplica = 1 }, Rojas = todas },
			i
		)
		chequear(r.Danio <= Config.TopeDanioTiro, "duplica: se pasó del tope de daño")
		maximo = math.max(maximo, r.Danio)
	end
	chequear(maximo == Config.TopeDanioTiro, "duplica: con todas rojas tendría que llegar al tope")
end

-- 3) Bola que se divide
do
	for nivel = 1, 3 do
		local toquesDividir = Config.Mejoras.Divide.ToquesParaDividir[nivel]
		local divididos, suma, sumaSin = 0, 0, 0
		for i = 1, TIROS do
			local mej = { Niveles = { Divide = nivel } }
			local res = Simulacion.simular(tablero, angulo(i), Config.Bola, mej, i * 31)
			local sin = Simulacion.simular(tablero, angulo(i), Config.Bola, {}, i * 31)
			tiroSano(res, ("divide %d, tiro %d"):format(nivel, i))
			chequear(#res.Recorridos <= 2, "divide: más de 2 bolas")

			-- Toques de la bola 1 antes de que nazca la 2.
			local deLaPrimera = 0
			local sumaToques = 0
			for _, t in res.Toques do
				sumaToques += t.Danio
				if t.Bola == 1 then
					deLaPrimera += 1
				end
			end
			chequear(res.Danio == sumaToques, "divide: las dos bolas no suman bien")
			if #res.Recorridos == 2 then
				divididos += 1
				local segunda = res.Recorridos[2]
				local antes = 0
				for _, t in res.Toques do
					if t.Bola == 1 and t.Paso <= segunda.Inicio then
						antes += 1
					end
				end
				chequear(
					antes == toquesDividir,
					("divide %d: se partió después de %d toques"):format(nivel, antes)
				)
				chequear(
					segunda.X[1] == res.X[segunda.Inicio] and segunda.Y[1] == res.Y[segunda.Inicio],
					"divide: la segunda bola no sale de donde estaba la primera"
				)
				chequear(
					res.Pasos >= segunda.Inicio + #segunda.X - 1 and res.Pasos >= #res.X,
					"divide: el tiro termina antes que una bola"
				)
			else
				chequear(deLaPrimera < toquesDividir, "divide: tocó lo suficiente y no se partió")
			end

			-- Determinista también con la división.
			local otra = Simulacion.simular(tablero, angulo(i), Config.Bola, mej, i * 31)
			chequear(
				#otra.Recorridos == #res.Recorridos
					and otra.Danio == res.Danio
					and otra.Pasos == res.Pasos,
				"divide: repetir el tiro dio otro resultado"
			)
			suma += res.Danio
			sumaSin += sin.Danio
		end
		print(
			("Divide nivel %d: se parte en el toque %d · %.0f %% de los tiros · daño %.1f (sin: %.1f)"):format(
				nivel,
				toquesDividir,
				divididos / TIROS * 100,
				suma / TIROS,
				sumaSin / TIROS
			)
		)
		chequear(divididos > TIROS * 0.6, "divide: casi ningún tiro se partió")
	end

	-- Tope de bolas: aunque Partes pida más, nunca hay más de TopeBolas.
	local partes = Config.Mejoras.Divide.Partes
	Config.Mejoras.Divide.Partes = 10
	local r = Simulacion.simular(tablero, 5, Config.Bola, { Niveles = { Divide = 3 } }, 99)
	chequear(#r.Recorridos <= Config.TopeBolas, "divide: se pasó del tope de bolas")
	tiroSano(r, "divide con 10 partes")
	Config.Mejoras.Divide.Partes = partes
end

-- 4) Las tres juntas
do
	for _, nivel in { 1, 3, 8 } do
		local suma, maximo, bolasMax = 0, 0, 0
		for i = 1, TIROS do
			local rojas = Mejoras.rojas(tablero, i * 13, nivel)
			local mej =
				{ Niveles = { Fuego = nivel, Duplica = nivel, Divide = nivel }, Rojas = rojas }
			local res = Simulacion.simular(tablero, angulo(i), Config.Bola, mej, i * 31)
			tiroSano(res, ("las 3 nivel %d, tiro %d"):format(nivel, i))
			chequear(#res.Recorridos <= Config.TopeBolas, "las 3: se pasó del tope de bolas")
			chequear(
				res.Danio <= Config.TopeDanioTiro and res.Danio == res.Danio,
				"las 3: daño fuera de tope"
			)
			local rev = Revision.revisar(tablero, angulo(i), i * 31, mej, res.Danio)
			chequear(rev.Danio == res.Danio and not rev.Corregido, "las 3: el servidor no coincide")
			chequear(rev.Quemadura == res.Quemadura, "las 3: la quemadura del servidor no coincide")
			local falso = Revision.revisar(tablero, angulo(i), i * 31, mej, 99999)
			chequear(
				falso.Corregido and falso.Danio == res.Danio,
				"las 3: un daño falso no se corrigió"
			)
			suma += res.Danio
			maximo = math.max(maximo, res.Danio)
			bolasMax = math.max(bolasMax, #res.Recorridos)
		end
		print(
			("Las 3 juntas, nivel %d: daño promedio %.1f, máximo %d · hasta %d bolas"):format(
				nivel,
				suma / TIROS,
				maximo,
				bolasMax
			)
		)
	end
end

-- 5) Elegir 1 de 3 y la quemadura
do
	local cartas = Mejoras.ofrecer(42)
	chequear(#cartas == 3, "tienen que salir 3 cartas")
	for _, id in Config.OrdenMejoras do
		chequear(
			table.find(cartas, id) ~= nil,
			"con 3 mejoras tienen que salir las 3: falta " .. id
		)
	end

	local e = Mazmorra.nueva()
	Mazmorra.empezarPelea(e, tablero, 5)
	chequear(#e.Rojas == 0, "sin la mejora no hay rojas en la pelea")
	chequear(not Mazmorra.elegir(e, "Fuego"), "se pudo elegir peleando")
	local t = Mazmorra.turno(e, 999)
	chequear(t.Resultado == "piso" and e.Fase == "eligiendo", "ganar no abrió las cartas")
	Mazmorra.ofrecer(e, cartas)
	chequear(not Mazmorra.elegir(e, "Trampa"), "se pudo elegir una mejora que no existe")
	chequear(not Mazmorra.elegir(e, 5), "se pudo elegir un número")
	chequear(Mazmorra.elegir(e, "Duplica"), "no se pudo elegir una carta ofrecida")
	chequear(e.Fase == "peleando" and e.Mejoras.Duplica == 1, "elegir no subió el nivel")
	chequear(not Mazmorra.elegir(e, "Fuego"), "se pudo elegir dos veces")
	Mazmorra.empezarPelea(e, tablero, 5)
	chequear(#e.Rojas == Config.Mejoras.Duplica.ClavijasRojas, "la pelea nueva no tiene rojas")

	-- Solo se puede elegir entre las ofrecidas.
	Mazmorra.turno(e, 999)
	Mazmorra.ofrecer(e, { "Fuego" })
	chequear(not Mazmorra.elegir(e, "Divide"), "se pudo elegir una carta no ofrecida")
	chequear(Mazmorra.elegir(e, "Fuego"), "no se pudo elegir la ofrecida")

	-- Quemadura: el turno con fuego quema enseguida y sigue el turno siguiente.
	local q = Mejoras.quemadura(1)
	local vida = e.VidaMonstruo
	t = Mazmorra.turno(e, 10, q)
	chequear(
		t.Quemadura == q and e.VidaMonstruo == vida - 10 - q,
		"la quemadura no pegó en el turno del tiro"
	)
	vida = e.VidaMonstruo
	t = Mazmorra.turno(e, 10, 0)
	local seguidos = Config.Mejoras.Fuego.TurnosQuemadura
	if seguidos >= 2 then
		chequear(t.Quemadura == q and e.VidaMonstruo == vida - 10 - q, "la quemadura no siguió")
	end
	for _ = 1, seguidos do
		t = Mazmorra.turno(e, 1, 0)
	end
	chequear(t.Quemadura == 0, "la quemadura no se apagó")
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Mejoras: todo OK")
