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

-- 8. Combinaciones (Grupo 1): sus dos partes existen, son más raras que cualquier modificador
-- simple y dan más que cada una de sus partes.
local masRaraSimple = 0
for _, m in GameConfig.Modificadores do
	if not m.Partes then
		masRaraSimple = math.max(masRaraSimple, m.UnoEn)
	end
end
local combos = 0
for _, m in GameConfig.Modificadores do
	if m.Partes then
		combos += 1
		chequear(
			#m.Partes == 2 and m.Partes[1] ~= m.Partes[2],
			m.Id .. ": tiene que juntar dos distintos"
		)
		chequear(m.Color2 ~= nil, m.Id .. ": le falta Color2")
		chequear(m.UnoEn > masRaraSimple, m.Id .. ": no es más rara que las simples")
		for _, parte in m.Partes do
			local p = Reglas.modificador(parte)
			chequear(p ~= nil and p.Partes == nil, m.Id .. ": parte desconocida " .. parte)
			chequear(p == nil or m.Premio > p.Premio, m.Id .. ": no da más que " .. parte)
		end
	end
	chequear(
		type(m.Textura) == "string" and type(m.Sonido) == "string",
		m.Id .. ": falta Textura o Sonido"
	)
end
chequear(combos == 4, "hay " .. combos .. " combinaciones, se esperaban 4")
chequear(Reglas.esExotica("Lava") and not Reglas.esExotica("Normal"), "esExotica mal")
chequear(
	Reglas.partes("VacioMidas")[2] == "Midas" and Reglas.partes("Neon")[1] == "Neon",
	"partes mal"
)

-- 9. Logros: Ids únicos y todo lo que nombran existe.
local logrosVistos: { [string]: boolean } = {}
for _, l in GameConfig.Logros do
	chequear(not logrosVistos[l.Id], "logro repetido: " .. l.Id)
	logrosVistos[l.Id] = true
	local n = l.Necesita
	if n.Tipo == "Gemas" then
		chequear(GameConfig.Zonas[n.Zona or 0] ~= nil, l.Id .. ": zona desconocida")
	elseif n.Tipo == "Modificadores" then
		for _, id in n.Ids or {} do
			chequear(Reglas.esExotica(id), l.Id .. ": modificador desconocido " .. id)
		end
		chequear((n.Cuantos or 1) <= #(n.Ids or {}), l.Id .. ": pide más de los que hay")
	elseif n.Tipo == "Rareza" then
		chequear(Reglas.rareza(n.Id or "") ~= nil, l.Id .. ": rareza desconocida")
	elseif n.Tipo == "Geodas" then
		chequear((n.Cuantas or 0) > 0, l.Id .. ": Cuantas tiene que ser > 0")
	elseif n.Tipo == "Jefes" or n.Tipo == "Eventos" then
		chequear((n.Cuantos or 0) > 0, l.Id .. ": Cuantos tiene que ser > 0")
	else
		chequear(false, l.Id .. ": tipo desconocido " .. tostring(n.Tipo))
	end
	chequear(l.Premio.Monedas ~= nil or l.Premio.Suerte ~= nil, l.Id .. ": no tiene premio")
end

-- 10. La cadena de descubrimientos: cada logro sale una sola vez y en el momento justo.
local function ids(lista): string
	local r = {}
	for _, l in lista do
		table.insert(r, l.Id)
	end
	return table.concat(r, ",")
end
local e = {
	Indice = {},
	Exoticas = {},
	Rarezas = {},
	GeodasRotas = 0,
	JefesDerrotados = 0,
	EventosJugados = 0,
	Logros = {},
}
chequear(#Reglas.logrosNuevos(e) == 0, "un jugador nuevo ya tiene logros")
e.Exoticas.Lava = true
chequear(ids(Reglas.logrosNuevos(e)) == "PrimeraExotica", "la primera exótica no da su logro")
e.Logros.PrimeraExotica = true
chequear(#Reglas.logrosNuevos(e) == 0, "un logro cobrado vuelve a salir")
e.Exoticas.Neon, e.Exoticas.Midas, e.Exoticas.Vacio = true, true, true
chequear(
	ids(Reglas.logrosNuevos(e)) == "ColeccionExotica",
	"las 4 exóticas no completan la colección"
)
e.Exoticas.VacioMidas = true
local conCombo = ids(Reglas.logrosNuevos(e))
chequear(conCombo == "ColeccionExotica,PrimeraCombinacion", "combinación: salió " .. conCombo)
for _, g in GameConfig.Gemas do
	if g.Zona == 1 and g.Rareza ~= "Mitico" then
		e.Indice[g.Id] = true
	end
end
chequear(not ids(Reglas.logrosNuevos(e)):find("Coleccion1"), "la colección 1 sale sin la mítica")
e.Indice.CorazonPradera = true
e.Rarezas.Mitico = true
e.GeodasRotas = 100
local todo = ids(Reglas.logrosNuevos(e))
chequear(
	todo == "Picapiedras,ColeccionExotica,PrimeraCombinacion,Mitica,Coleccion1",
	"cadena completa: salió " .. todo
)
chequear(
	math.abs(
		Reglas.suerteJugador({ Trebol = true }, { Mitica = true, ColeccionExotica = true }) - 1.7
	) < 1e-9,
	"la suerte de los logros no se suma"
)

-- 11. Formato de números en pantalla.
local Formato = cargar("Formato")
for _, caso in
	{
		{ 0, "0" },
		{ 999, "999" },
		{ 9999, "9.999" },
		{ 10000, "10K" },
		{ 12345, "12,3K" },
		{ 123456, "123K" },
		{ 1234567, "1,2M" },
		{ 3000000000, "3B" },
		{ -2500000, "-2,5M" },
	}
do
	chequear(
		Formato.corto(caso[1]) == caso[2],
		("corto(%s) dio %s"):format(caso[1], Formato.corto(caso[1]))
	)
end
chequear(
	Formato.suerte(2.06) == "x2,06" and Formato.suerte(1) == "x1",
	"Formato.suerte mal: " .. Formato.suerte(2.06)
)
chequear(Formato.suerte(1.5) == "x1,5", "Formato.suerte(1.5) dio " .. Formato.suerte(1.5))
chequear(Formato.unoEn(2427.3) == "1 en 2.427", "Formato.unoEn mal: " .. Formato.unoEn(2427.3))

-- 12. Eventos del mundo (Grupo 6).
local eventosVistos: { [string]: boolean } = {}
for _, ev in GameConfig.Eventos.Lista do
	chequear(not eventosVistos[ev.Id], "evento repetido: " .. ev.Id)
	eventosVistos[ev.Id] = true
	chequear(ev.Duracion > 0 and ev.Peso > 0, ev.Id .. ": Duracion y Peso tienen que ser > 0")
	for id, x in ev.Modificadores or {} do
		chequear(
			Reglas.modificador(id) ~= nil and x > 0,
			ev.Id .. ": modificador desconocido " .. id
		)
	end
	for id, x in ev.Unidades or {} do
		chequear(
			Reglas.modificador(id) ~= nil and x > 0,
			ev.Id .. ": unidades de modificador desconocido " .. id
		)
	end
end
for _, id in
	{
		"LluviaCristales",
		"Erupcion",
		"TormentaNeon",
		"EclipseVacio",
		"FiebreMineria",
		"JefeAncestral",
	}
do
	chequear(Reglas.evento(id) ~= nil, "falta el evento " .. id)
end
-- con bonos de evento las probabilidades siguen sumando 100 % y la bonificada sube
local erupcion = Reglas.evento("Erupcion")
local bonos = if erupcion then erupcion.Modificadores else nil
local sinBono = Reglas.probabilidades(GameConfig.Modificadores, 1)
local conBono = Reglas.probabilidades(GameConfig.Modificadores, 1, bonos)
local sumaBono = 0
for _, v in conBono do
	sumaBono += v
end
chequear(cerca(sumaBono, 1, 1e-9), "con bonos no suman 100 %")
chequear(conBono.Lava > sinBono.Lava * 3, "la Erupción no sube la Lava")
local cuentaLava = 0
for _ = 1, 200000 do
	if Reglas.tirar(GameConfig.Modificadores, 1, azarLune, bonos) == "Lava" then
		cuentaLava += 1
	end
end
chequear(
	cerca(cuentaLava / 200000, conBono.Lava, 0.005),
	"tirar con bonos no coincide con las probabilidades"
)
-- el evento al azar nunca repite el anterior
for _ = 1, 2000 do
	chequear(
		Reglas.eventoAlAzar(azarLune, "Erupcion").Id ~= "Erupcion",
		"se repitió el evento anterior"
	)
end
-- vida del Jefe Ancestral
chequear(Reglas.vidaAncestral({}) == 3000, "la vida mínima del jefe no es 3000")
chequear(Reglas.vidaAncestral({ 100, 300 }) == 100000, "la vida del jefe no crece con la Fuerza")
chequear(Reglas.tamanoAlAzar(azarLune) ~= "Ancestral", "la Ancestral salió en un punto común")
chequear(Reglas.mejorZona({ [1] = true, [3] = true }) == 3, "mejorZona mal")

-- 13. Exhibición social (Grupo 7).
chequear(Reglas.semana(1791763199) ~= Reglas.semana(1791763200), "la semana no cambia el lunes")
chequear(
	Reglas.semana(1791763200) == Reglas.semana(1791763200 + 6 * 86400),
	"la semana cambia antes del lunes"
)
local titulosVistos: { [string]: boolean } = {}
for _, t in GameConfig.Titulos do
	chequear(not titulosVistos[t.Id], "título repetido: " .. t.Id)
	titulosVistos[t.Id] = true
	chequear(
		t.Requiere == nil or Reglas.logro(t.Requiere) ~= nil,
		t.Id .. ": pide un logro que no existe"
	)
	chequear(#t.Colores >= 1, t.Id .. ": sin colores")
end
chequear(#Reglas.titulosDe({}) == 1, "un jugador nuevo tiene más de un título")
chequear(
	Reglas.tituloDisponible("CazaJefes", { JefeAncestral1 = true }),
	"el título de jefes no se desbloquea"
)
chequear(not Reglas.tituloDisponible("CazaJefes", {}), "el título de jefes sale sin el logro")
e.JefesDerrotados = 1
e.EventosJugados = 5
local jefesYEventos = ids(Reglas.logrosNuevos(e))
chequear(
	jefesYEventos:find("JefeAncestral1") ~= nil and jefesYEventos:find("Eventos5") ~= nil,
	"logros de jefes/eventos: " .. jefesYEventos
)
chequear(not jefesYEventos:find("JefeAncestral10"), "Leyenda de los Jefes salió con 1 jefe")

if errores > 0 then
	print(("%d pruebas fallaron"):format(errores))
	process.exit(1)
end
print("Reglas: todo bien")
