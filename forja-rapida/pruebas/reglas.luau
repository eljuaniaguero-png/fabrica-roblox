--!strict
-- Pruebas de lógica pura de Forja Rápida. Se corren desde la raíz del repositorio:
--   lune run forja-rapida/pruebas/reglas
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local GameConfig = cargar("GameConfig")
local Reglas = cargar("Reglas")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local function cerca(a: number, b: number, tolerancia: number): boolean
	return math.abs(a - b) <= tolerancia
end

-- 1. Las tablas que se tiran tienen la común primero (UnoEn = 1) y van de común a rara.
for nombre, tabla in { Rarezas = GameConfig.Rarezas, Modificadores = GameConfig.Modificadores } do
	chequear(tabla[1].UnoEn == 1, nombre .. ": la primera fila tiene que tener UnoEn = 1")
	for i = 2, #tabla do
		chequear(tabla[i].UnoEn > tabla[i - 1].UnoEn, nombre .. ": no están en orden de rareza")
	end
end

-- 2. Las probabilidades suman 100 % con cualquier suerte, y más suerte nunca baja una rareza
-- alta (de Épico para arriba).
for _, suerte in { 1, 1.25, 2.06, 5, 40, 400, 5000, 100000 } do
	local p = Reglas.probabilidades(GameConfig.Rarezas, suerte)
	local suma = 0
	for _, v in p do
		chequear(v >= 0 and v <= 1, ("probabilidad fuera de rango con suerte %g"):format(suerte))
		suma += v
	end
	chequear(cerca(suma, 1, 1e-9), ("con suerte %g suman %.12f"):format(suerte, suma))
end
local p1 = Reglas.probabilidades(GameConfig.Rarezas, 1)
local p2 = Reglas.probabilidades(GameConfig.Rarezas, 2)
for _, id in { "Epico", "Legendario", "Mitico" } do
	chequear(p2[id] > p1[id], id .. " no sube con más suerte")
end
-- Con suerte x1 el Mítico es 1 en 5000 exacto (es el primero que se prueba).
chequear(cerca(p1.Mitico, 1 / 5000, 1e-12), "el Mítico con suerte x1 no es 1 en 5000")

-- 3. Tirar de verdad da lo mismo que las probabilidades (500.000 tiradas).
-- Lune no trae Random de Roblox: se usa math.random.
math.randomseed(1234)
local function azarLune(): number
	return math.random()
end
for _, suerte in { 1, 3, 25 } do
	local N = 500000
	local cuenta: { [string]: number } = {}
	for _ = 1, N do
		local id = Reglas.tirar(GameConfig.Rarezas, suerte, azarLune)
		cuenta[id] = (cuenta[id] or 0) + 1
	end
	local p = Reglas.probabilidades(GameConfig.Rarezas, suerte)
	for id, esperado in p do
		local visto = (cuenta[id] or 0) / N
		-- 5 desvíos estándar de margen
		local margen = 5 * math.sqrt(esperado * (1 - esperado) / N) + 1e-6
		chequear(
			cerca(visto, esperado, margen),
			("suerte %g, %s: salió %.5f y se esperaba %.5f"):format(suerte, id, visto, esperado)
		)
	end
end

-- 4. Cada zona tiene exactamente una gema por rareza, con Id único.
local ids: { [string]: boolean } = {}
for _, g in GameConfig.Gemas do
	chequear(not ids[g.Id], "Id de gema repetido: " .. g.Id)
	ids[g.Id] = true
	chequear(Reglas.rareza(g.Rareza) ~= nil, g.Id .. ": rareza desconocida " .. g.Rareza)
	chequear(GameConfig.Zonas[g.Zona] ~= nil, g.Id .. ": zona desconocida")
end
for _, z in GameConfig.Zonas do
	for _, r in GameConfig.Rarezas do
		chequear(
			Reglas.gemaDe(z.Numero, r.Id) ~= nil,
			("falta la gema %s de la zona %d"):format(r.Id, z.Numero)
		)
	end
end
chequear(#GameConfig.Gemas == #GameConfig.Zonas * #GameConfig.Rarezas, "sobran gemas")

-- 5. Zonas, picos y amuletos van en orden creciente.
for i = 2, #GameConfig.Zonas do
	local a, b = GameConfig.Zonas[i - 1], GameConfig.Zonas[i]
	chequear(b.Numero == i, "zona " .. i .. " mal numerada")
	chequear(b.FuerzaParaAbrir > a.FuerzaParaAbrir, "zona " .. i .. ": la puerta no pide más")
	chequear(
		b.Dureza > a.Dureza and b.Valor > a.Valor,
		"zona " .. i .. ": no es más dura o no paga más"
	)
	chequear(b.Suerte >= a.Suerte, "zona " .. i .. ": baja la suerte")
end
for nombre, lista in { Picos = GameConfig.Picos, Amuletos = GameConfig.Amuletos } do
	for i = 2, #lista do
		chequear(lista[i].Precio > lista[i - 1].Precio, nombre .. " " .. i .. ": no es más caro")
	end
end

-- 6. Fórmulas.
chequear(Reglas.fuerza(0, 1) == 1, "la Fuerza inicial no es 1")
chequear(
	Reglas.fuerza(4, 2) == math.floor(5 * 1.025 ^ 4 * 2),
	"Fuerza nivel 4 con Pico de Piedra mal"
)
chequear(
	Reglas.precioFuerza(0) == GameConfig.Fuerza.PrecioInicial,
	"el primer nivel no cuesta el inicial"
)
chequear(
	Reglas.precioFuerza(GameConfig.Fuerza.NivelMaximo) == nil,
	"se puede pasar el nivel máximo"
)
chequear(Reglas.suerteJugador({}) == 1, "sin amuletos la suerte no es x1")
chequear(
	Reglas.suerteJugador({ Trebol = true, Herradura = true }) == 1.75,
	"amuletos no suman bien"
)
chequear(Reglas.vidaGeoda(1, "Pequena") == 10, "la geoda pequeña de la zona 1 no tiene 10 de vida")
chequear(Reglas.unidades("Mediana", "Vacio") == 75, "Mediana del Vacío no da 3 x 25")
chequear(Reglas.valorGema("Cuarzo") == 1, "el Cuarzo no vale 1")
chequear(Reglas.valorGema("NoExiste") == 0, "una gema que no existe vale algo")
chequear(Reglas.zonaMaxima(0) == 1 and Reglas.zonaMaxima(25) == 2, "zonaMaxima mal")
chequear(Reglas.suerteGeoda(2, 1, "Jefe") == 6, "suerte del Jefe en la zona 1 con x2 no es x6")

-- 7. El Jefe nunca sale en un punto común.
for _ = 1, 20000 do
	chequear(Reglas.tamanoAlAzar(azarLune) ~= "Jefe", "salió un Jefe en un punto común")
end

if errores > 0 then
	print(("%d pruebas fallaron"):format(errores))
	process.exit(1)
end
print("Reglas: todo bien")
