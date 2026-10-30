--!strict
-- Pruebas de la simulación de la bola. Se corren desde la raíz del repositorio:
--   lune run archivo/plinko-knight/pruebas/simulacion
-- 200 tiros a ángulos distintos: ninguno se traba ni sale por los costados, el mismo tiro da
-- siempre lo mismo, y el promedio de clavijas tocadas queda entre 10 y 18. También el daño (cada
-- clavija suma una sola vez) y la revisión del servidor. Sale con error si falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Revision = cargar("Revision")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
chequear(
	#tablero.Clavijas == 52,
	("el tablero tiene %d clavijas, esperaba 52"):format(#tablero.Clavijas)
)

local TIROS = 200
local tope = Config.Punteria.AnguloMaximo
local suma, minimo, maximo = 0, math.huge, 0
local sumaSegundos, conEmpujon = 0, 0

for i = 1, TIROS do
	local angulo = -tope + 2 * tope * (i - 1) / (TIROS - 1)
	local semilla = i * 7919
	local res = Simulacion.simular(tablero, angulo, Config.Bola, {}, semilla)

	chequear(
		res.Fin == "abajo",
		("tiro %d (%.1f°): no llegó abajo (%s)"):format(i, angulo, res.Fin)
	)
	for paso = 1, #res.X do
		local x = res.X[paso]
		local afuera = x - Config.Bola.Radio < tablero.ParedIzquierda - 1e-9
			or x + Config.Bola.Radio > tablero.ParedDerecha + 1e-9
		if afuera or x ~= x then
			chequear(false, ("tiro %d: salió por el costado en el paso %d"):format(i, paso))
			break
		end
	end

	-- Mismo tablero + ángulo + semilla = mismo resultado.
	local otra = Simulacion.simular(tablero, angulo, Config.Bola, {}, semilla)
	local igual = #otra.X == #res.X and #otra.Toques == #res.Toques
	if igual then
		for paso = 1, #res.X do
			if otra.X[paso] ~= res.X[paso] or otra.Y[paso] ~= res.Y[paso] then
				igual = false
				break
			end
		end
		for k, t in res.Toques do
			if otra.Toques[k].Clavija ~= t.Clavija or otra.Toques[k].Paso ~= t.Paso then
				igual = false
				break
			end
		end
	end
	chequear(igual, ("tiro %d: repetirlo dio otro resultado"):format(i))

	-- Daño: cada clavija suma una sola vez, y el total cierra.
	local vistas: { [number]: boolean } = {}
	local acumulado = 0
	for _, t in res.Toques do
		chequear(
			not vistas[t.Clavija],
			("tiro %d: la clavija %d sumó dos veces"):format(i, t.Clavija)
		)
		vistas[t.Clavija] = true
		acumulado += t.Fuerza
		chequear(t.FuerzaTotal == acumulado, ("tiro %d: la Fuerza acumulada no cierra"):format(i))
	end
	chequear(
		res.Danio == res.ClavijasDistintas * Config.Clavijas.gris.Fuerza and res.Multi == 1,
		("tiro %d: daño %d con %d clavijas"):format(i, res.Danio, res.ClavijasDistintas)
	)

	-- Revisión del servidor: con el daño del cliente (mismo módulo) coincide y no se corrige;
	-- con un daño falso de 9999 vale el del servidor.
	local bien = Revision.revisar(tablero, angulo, semilla, {}, res.Danio)
	chequear(
		bien.Danio == res.Danio and not bien.Corregido,
		("tiro %d: cliente y servidor no coinciden"):format(i)
	)
	local falso = Revision.revisar(tablero, angulo, semilla, {}, 9999)
	chequear(
		falso.Danio == res.Danio and falso.Corregido,
		("tiro %d: el daño falso no se corrigió"):format(i)
	)

	suma += res.ClavijasDistintas
	minimo = math.min(minimo, res.ClavijasDistintas)
	maximo = math.max(maximo, res.ClavijasDistintas)
	sumaSegundos += (#res.X - 1) * Config.Simulacion.Paso
	if res.Empujones > 0 then
		conEmpujon += 1
	end
end

local promedio = suma / TIROS
print(
	("Clavijas tocadas por tiro: promedio %.1f (mín %d, máx %d)"):format(promedio, minimo, maximo)
)
print(
	("Duración promedio de un tiro: %.1f s · tiros con empujón anti-trabas: %d"):format(
		sumaSegundos / TIROS,
		conEmpujon
	)
)
chequear(
	promedio >= 10 and promedio <= 18,
	("el promedio %.1f está fuera de 10 a 18"):format(promedio)
)

-- La semilla cambia el tiro (si no, siempre sería el mismo recorrido para el mismo ángulo).
local a = Simulacion.simular(tablero, 10, Config.Bola, {}, 1)
local b = Simulacion.simular(tablero, 10, Config.Bola, {}, 2)
chequear(#a.X ~= #b.X or a.X[#a.X] ~= b.X[#b.X], "semillas distintas dieron el mismo tiro")

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Todo OK")
