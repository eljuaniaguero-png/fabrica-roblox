--!strict
-- Pruebas de las reglas de la mazmorra y del balance. Se corren desde la raíz del repositorio:
--   lune run plinko-knight/pruebas/mazmorra
-- 1) Reglas: contraataque, curarse al ganar, perder y ganarle al jefe.
-- 2) Balance: juega muchas mazmorras con tiros a ángulos al azar (sin mejoras, como la etapa 4)
--    y cuenta cuántos tiros dura cada pelea y en qué piso se pierde. Sale con error si una regla
--    falla; el balance solo se informa.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Mazmorra = cargar("Mazmorra")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

-- 1) Reglas
do
	local e = Mazmorra.nueva()
	chequear(e.Piso == 1 and e.Vida == Config.VidaCaballero, "la mazmorra no arranca bien")
	chequear(#Config.Monstruos == 7, "tienen que ser 6 monstruos y el jefe")

	local t = Mazmorra.turno(e, 10) -- la rata (40) sigue viva y contraataca
	chequear(t.Resultado == "sigue" and t.VidaMonstruo == 30, "el golpe no le bajó la vida")
	chequear(t.Golpe == 4 and e.Vida == Config.VidaCaballero - 4, "no contraatacó")

	t = Mazmorra.turno(e, 100) -- la mata: piso 2, se cura sin pasarse del máximo
	chequear(t.Resultado == "piso" and t.Golpe == 0, "matarla no dio piso")
	chequear(e.Piso == 2 and e.VidaMonstruo == 60, "no pasó al slime")
	chequear(e.Vida == Config.VidaCaballero, "la cura se pasó del máximo o no curó")

	e.Vida = 3
	t = Mazmorra.turno(e, 1)
	chequear(t.Resultado == "perdio" and e.Fase == "perdio" and e.Vida == 0, "no perdió")

	e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, 7)
	chequear(e.Piso == 7 and e.VidaMonstruo == Config.Monstruos[7].Vida, "el comando no fue al jefe")
	t = Mazmorra.turno(e, 999)
	chequear(t.Resultado == "gano" and e.Fase == "gano", "ganarle al jefe no terminó la mazmorra")

	Mazmorra.irAPiso(e, 99)
	chequear(e.Piso == 7, "el comando se pasó del último piso")
end

-- 2) Balance
local tablero = Tablero.generar()
local CORRIDAS = 500 -- con 2000 tarda 3 minutos y da casi lo mismo
local semilla = 12345
local function azar(): number -- 0..1, determinista
	semilla = (semilla * 1103515245 + 12345) % 2147483648
	return semilla / 2147483648
end

local function tiro(): number
	local angulo = (azar() * 2 - 1) * Config.Punteria.AnguloMaximo
	local res = Simulacion.simular(tablero, angulo, Config.Bola, {}, math.floor(azar() * 2 ^ 31))
	return res.Danio
end

local tirosPorPelea: { { number } } = {}
local caidas: { number } = {}
for piso = 1, #Config.Monstruos do
	tirosPorPelea[piso] = {}
	caidas[piso] = 0
end
local ganadas = 0

for _ = 1, CORRIDAS do
	local e = Mazmorra.nueva()
	local tiros = 0
	while e.Fase == "peleando" do
		local piso = e.Piso
		tiros += 1
		local t = Mazmorra.turno(e, tiro())
		if t.Resultado == "piso" or t.Resultado == "gano" then
			table.insert(tirosPorPelea[piso], tiros)
			tiros = 0
		elseif t.Resultado == "perdio" then
			caidas[piso] += 1
		end
	end
	if e.Fase == "gano" then
		ganadas += 1
	end
end

-- El jefe solo, con vida de sobra (como en la prueba con "/vida"), para saber cuánto dura.
local tirosJefe: { number } = {}
for _ = 1, CORRIDAS do
	local e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, #Config.Monstruos)
	e.Vida = 9999
	local tiros = 0
	while e.Fase == "peleando" do
		tiros += 1
		Mazmorra.turno(e, tiro())
	end
	table.insert(tirosJefe, tiros)
end

local function resumen(lista: { number }): string
	if #lista == 0 then
		return "nadie llegó a ganarla"
	end
	local suma, minimo, maximo = 0, math.huge, 0
	for _, n in lista do
		suma += n
		minimo = math.min(minimo, n)
		maximo = math.max(maximo, n)
	end
	return ("%.1f tiros (de %d a %d, %d veces)"):format(suma / #lista, minimo, maximo, #lista)
end

print(("Balance sin mejoras, %d mazmorras con tiros al azar:"):format(CORRIDAS))
for piso, m in Config.Monstruos do
	print(
		("  Pelea %d · %s (%d/%d): %s · caídas acá: %.1f %%"):format(
			piso,
			m.Nombre,
			m.Vida,
			m.Golpe,
			resumen(tirosPorPelea[piso]),
			caidas[piso] / CORRIDAS * 100
		)
	)
end
print(("  Mazmorras ganadas: %.1f %%"):format(ganadas / CORRIDAS * 100))
print("  Jefe solo, con vida de sobra: " .. resumen(tirosJefe))

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Reglas de la mazmorra: todo bien")
