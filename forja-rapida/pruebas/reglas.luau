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
for _, id in { "Epico", "Legendario", "Mitico", "Celestial" } do
	chequear(p2[id] > p1[id], id .. " no sube con más suerte")
end
-- Con suerte x1 la Celestial es 1 en 50.000 exacto (es la primera que se prueba) y el Mítico
-- casi 1 en 5000 (lo que queda después de la Celestial).
chequear(cerca(p1.Celestial, 1 / 50000, 1e-12), "la Celestial con suerte x1 no es 1 en 50.000")
chequear(
	cerca(p1.Mitico, (1 - 1 / 50000) / 5000, 1e-12),
	"el Mítico con suerte x1 no es 1 en 5000"
)

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

-- 4. Cada zona tiene exactamente 2 gemas por rareza, con Id único, y al tirar salen las dos.
local ids: { [string]: boolean } = {}
for _, g in GameConfig.Gemas do
	chequear(not ids[g.Id], "Id de gema repetido: " .. g.Id)
	ids[g.Id] = true
	chequear(Reglas.rareza(g.Rareza) ~= nil, g.Id .. ": rareza desconocida " .. g.Rareza)
	chequear(GameConfig.Zonas[g.Zona] ~= nil, g.Id .. ": zona desconocida")
end
for _, z in GameConfig.Zonas do
	for _, r in GameConfig.Rarezas do
		local lista = Reglas.gemasDe(z.Numero, r.Id)
		chequear(
			#lista == 2,
			("la zona %d tiene %d gemas %s (van 2)"):format(z.Numero, #lista, r.Id)
		)
		local vistas: { [string]: boolean } = {}
		for _ = 1, 200 do
			local g = Reglas.gemaDe(z.Numero, r.Id, azarLune)
			if g then
				vistas[g.Id] = true
			end
		end
		for _, g in lista do
			chequear(vistas[g.Id] == true, g.Id .. " nunca sale al tirar")
		end
	end
end
local comunes, secretas = 0, 0
for _, g in GameConfig.Gemas do
	if g.Secreta then
		secretas += 1
	else
		comunes += 1
	end
end
chequear(comunes == #GameConfig.Zonas * #GameConfig.Rarezas * 2, "sobran gemas")
-- Grupo 3: un mineral secreto por bioma (más la Prismita) que nunca sale al tirar la rareza
for _, z in GameConfig.Zonas do
	local s = Reglas.gemaSecreta(z.Numero)
	chequear(
		s ~= nil and s.Secreta == true and s.Zona == z.Numero,
		"falta la gema secreta de la zona " .. z.Numero
	)
	for _, r in GameConfig.Rarezas do
		local g = Reglas.gemaDe(z.Numero, r.Id)
		chequear(g ~= nil and not g.Secreta, "una secreta sale al tirar en la zona " .. z.Numero)
	end
end
chequear(secretas == #GameConfig.Zonas + 1, "tienen que ser 6 secretas: " .. secretas)

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
	elseif n.Tipo == "Distintas" then
		chequear(
			(n.Cuantas or 0) > 0 and (n.Cuantas or 0) <= #GameConfig.Gemas,
			l.Id .. ": Cuantas fuera de rango"
		)
	elseif n.Tipo == "Secretas" then
		chequear(
			(n.Cuantas or 0) > 0 and (n.Cuantas or 0) <= secretas,
			l.Id .. ": pide más secretas de las que hay"
		)
	elseif n.Tipo == "Lista" then
		for _, id in n.Ids or {} do
			chequear(Reglas.gema(id) ~= nil, l.Id .. ": gema desconocida " .. id)
		end
	elseif n.Tipo == "Rarezas" then
		for _, id in n.Ids or {} do
			chequear(Reglas.rareza(id) ~= nil, l.Id .. ": rareza desconocida " .. id)
		end
	elseif n.Tipo == "Pico" then
		chequear(
			(n.Cuantos or 0) >= 1 and (n.Cuantos or 0) <= #GameConfig.Picos,
			l.Id .. ": pico fuera de rango"
		)
	elseif n.Tipo == "Colecciones" then
		local museo = 0
		for _, otro in GameConfig.Logros do
			if otro.Museo then
				museo += 1
			end
		end
		chequear(
			(n.Cuantas or 0) > 0 and (n.Cuantas or 0) <= museo,
			l.Id .. ": pide más colecciones de las que hay"
		)
	elseif n.Tipo == "Misiones" then
		chequear((n.Cuantas or 0) > 0, l.Id .. ": Cuantas tiene que ser > 0")
	elseif n.Tipo == "Renacer" then
		chequear((n.Cuantos or 0) > 0, l.Id .. ": Cuantos tiene que ser > 0")
	else
		chequear(false, l.Id .. ": tipo desconocido " .. tostring(n.Tipo))
	end
	chequear(
		l.Premio.Monedas ~= nil or l.Premio.Suerte ~= nil or l.Premio.Cosmetico ~= nil,
		l.Id .. ": no tiene premio"
	)
	local c = l.Premio.Cosmetico
	if c then
		chequear(
			Reglas.cosmetico(c.Tipo, c.Id) ~= nil,
			l.Id .. ": cosmético desconocido " .. c.Tipo .. "/" .. c.Id
		)
	end
	if l.Museo then
		chequear(
			l.Dificultad == "Facil"
				or l.Dificultad == "Media"
				or l.Dificultad == "Dificil"
				or l.Dificultad == "Leyenda",
			l.Id .. ": dificultad desconocida"
		)
	end
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
	if g.Zona == 1 and g.Id ~= "JadeArcoiris" and not g.Secreta then
		e.Indice[g.Id] = true
	end
end
chequear(not ids(Reglas.logrosNuevos(e)):find("Coleccion1"), "la colección 1 sale sin una mítica")
e.Indice.JadeArcoiris = true
e.Rarezas.Mitico = true
e.GeodasRotas = 100
local todo = ids(Reglas.logrosNuevos(e))
chequear(
	todo
		== "Picapiedras,ColeccionExotica,PrimeraCombinacion,Mitica,Coleccion1,Museo3,PraderaBrillante,Museo10",
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
chequear(
	Formato.mayusculas("Común y Mítica") == "COMÚN Y MÍTICA",
	"Formato.mayusculas mal: " .. Formato.mayusculas("Común y Mítica")
)

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

-- 14. Tienda, Banco y zonas.
local niveles, costo = Reglas.nivelesFuerza(0, 0)
chequear(niveles == 0 and costo == 0, "sin monedas se compra Fuerza")
local p0 = Reglas.precioFuerza(0) :: number
local p1n = Reglas.precioFuerza(1) :: number
niveles, costo = Reglas.nivelesFuerza(0, p0 + p1n)
chequear(niveles == 2 and costo == p0 + p1n, "comprar el máximo no junta los dos niveles justos")
niveles, costo = Reglas.nivelesFuerza(0, p0 + p1n - 1)
chequear(niveles == 1 and costo == p0, "compra un nivel que no alcanza")
niveles = Reglas.nivelesFuerza(0, 1e300, 1)
chequear(niveles == 1, "comprar de a uno compra más de uno")
niveles = Reglas.nivelesFuerza(GameConfig.Fuerza.NivelMaximo, 1e300)
chequear(niveles == 0, "se pasa del nivel máximo")
local sig, n = Reglas.siguientePico(1)
chequear(sig ~= nil and n == 2 and sig.Id == GameConfig.Picos[2].Id, "el pico que sigue al primero")
chequear(Reglas.siguientePico(#GameConfig.Picos) == nil, "hay pico después del último")
chequear(
	(Reglas.siguienteAmuleto({}) :: any).Id == GameConfig.Amuletos[1].Id,
	"el primer amuleto no es el primero"
)
local todos = {}
for _, a in GameConfig.Amuletos do
	todos[a.Id] = true
end
chequear(Reglas.siguienteAmuleto(todos) == nil, "hay amuleto después de tenerlos todos")
local g1 = GameConfig.Gemas[1]
chequear(
	Reglas.valorMochila({ [g1.Id] = 3, Inventada = 99 }) == 3 * Reglas.valorGema(g1.Id),
	"el valor de la mochila está mal (o cuenta gemas que no existen)"
)
chequear(#Reglas.zonasNuevas({ [1] = true }, 0) == 0, "con Fuerza 0 se abre una zona")
local z2 = GameConfig.Zonas[2]
local nuevas = Reglas.zonasNuevas({ [1] = true }, z2.FuerzaParaAbrir)
chequear(#nuevas == 1 and nuevas[1] == 2, "la zona 2 no se abre con su Fuerza justa")
chequear((Reglas.proximaZona({ [1] = true }) :: any).Numero == 2, "la próxima zona no es la 2")
local abiertas = {}
for _, z in GameConfig.Zonas do
	abiertas[z.Numero] = true
end
chequear(Reglas.proximaZona(abiertas) == nil, "hay próxima zona con todas abiertas")

-- 15. Grupo 3: Museo, cosméticos y geodas ocultas.
local m = {
	Indice = {} :: { [string]: boolean },
	Exoticas = {},
	Rarezas = {} :: { [string]: boolean },
	GeodasRotas = 0,
	JefesDerrotados = 0,
	EventosJugados = 0,
	Logros = {},
}
local tiene, total = Reglas.progreso(Reglas.logro("Museo10") :: any, m)
chequear(tiene == 0 and total == 10, "progreso del museo vacío")
m.Indice.Cuarzo, m.Indice.Jaspe, m.Indice.Inventada = true, true, true
tiene = Reglas.progreso(Reglas.logro("Museo3") :: any, m)
chequear(tiene == 2, "cuenta gemas que no existen: " .. tiene)
m.Indice.CuarzoLunar = true
local nuevos = ids(Reglas.logrosNuevos(m))
chequear(nuevos == "Museo3,PrimerSecreto", "museo: salió " .. nuevos)
tiene, total = Reglas.progreso(Reglas.logro("Coleccion1") :: any, m)
chequear(tiene == 2 and total == 12, "la colección 1 cuenta la secreta: " .. tiene .. "/" .. total)
chequear(Reglas.tieneCosmetico("Pico", "Clasico", {}), "el pico clásico no lo tiene todo el mundo")
chequear(
	not Reglas.tieneCosmetico("Aura", "Cuarzo", {}),
	"el aura de cuarzo sale sin la colección"
)
chequear(
	Reglas.tieneCosmetico("Aura", "Cuarzo", { Coleccion1 = true }),
	"el aura de cuarzo no sale con la colección"
)
chequear(not Reglas.tieneCosmetico("Aura", "Inventada", { Coleccion1 = true }), "aura inventada")
for tipo, lista in Reglas.tiposCosmeticos() do
	for _, c in lista do
		chequear(
			(tipo == "Pico" and c.Id == "Clasico")
				or (tipo == "Vitrina" and c.Id == "Clasica")
				or Reglas.logroDeCosmetico(tipo, c.Id) ~= nil,
			"cosmético que no se puede ganar: " .. tipo .. "/" .. c.Id
		)
	end
end
local sec, unoEn = Reglas.secretaDe("Oculta", 3)
chequear(
	sec ~= nil and sec.Id == (Reglas.gemaSecreta(3) :: any).Id and unoEn > 1,
	"la geoda oculta no da la secreta de su zona"
)
sec = Reglas.secretaDe("Prisma", 2)
chequear(sec ~= nil and sec.Id == "Prismita", "la geoda prismática no da la Prismita")
chequear(Reglas.secretaDe("Mediana", 1) == nil, "una geoda común da secretas")
local col = Reglas.coleccionesMuseo()
chequear(
	#col >= 10 and col[1].Dificultad == "Facil" and col[#col].Dificultad == "Leyenda",
	"colecciones del museo mal ordenadas"
)

-- 16. Grupo 4: logros nuevos, evoluciones del pico y variantes de roca.
local g4 = {
	Indice = {},
	Exoticas = {},
	Rarezas = {},
	GeodasRotas = 0,
	JefesDerrotados = 0,
	EventosJugados = 0,
	Logros = {} :: { [string]: boolean },
	Pico = 2,
	MisionesHechas = 2,
	Renacimientos = 0,
}
chequear(#Reglas.logrosNuevos(g4) == 0, "grupo 4: logros sin cumplir nada")
g4.Pico, g4.MisionesHechas, g4.Renacimientos = 3, 10, 2
local g4n = ids(Reglas.logrosNuevos(g4))
chequear(g4n == "Forjador,Misiones3,Misiones10,Renacer1,Renacer2", "grupo 4: salió " .. g4n)
for _, id in { "Coleccion1", "Coleccion2", "Museo3" } do
	g4.Logros[id] = true
end
chequear(
	not ids(Reglas.logrosNuevos(g4)):find("BrilloInterior"),
	"brillo interior con 3 colecciones"
)
g4.Logros.PraderaBrillante = true
chequear(
	ids(Reglas.logrosNuevos(g4)):find("BrilloInterior") ~= nil,
	"brillo interior no sale con 4 colecciones"
)
local efectos = Reglas.tiposCosmeticos().Efecto
chequear(efectos ~= nil and #efectos >= 6, "faltan evoluciones del pico")
for _, z in GameConfig.Zonas do
	chequear(#z.Variantes == 5, z.Nombre .. ": no tiene 5 rocas")
	chequear(
		z.Variantes[1].ColorRoca == z.ColorRoca and z.Variantes[1].ColorCristal == z.ColorCristal,
		z.Nombre .. ": la roca 1 no es la de siempre"
	)
	local colores = {}
	for _, v in z.Variantes do
		chequear(not colores[v.ColorRoca], z.Nombre .. ": dos rocas del mismo color")
		colores[v.ColorRoca] = true
	end
end
chequear(
	Reglas.fuerza(10, 2, 1.5) == math.floor(Reglas.fuerza(10, 2) * 1.5 + 0.5)
		or Reglas.fuerza(10, 2, 1.5) >= Reglas.fuerza(10, 2),
	"bono de fuerza"
)

-- 17. Grupo 4: bonos, Renacer y árbol de Esencia.
local b0 = Reglas.bonos({ Renacimientos = 0, Ramas = {}, MascotasEquipadas = {} })
chequear(
	b0.Fuerza == 1
		and b0.Monedas == 1
		and b0.Suerte == 0
		and b0.Lugares == GameConfig.Mascotas.Lugares,
	"bonos de un jugador nuevo"
)
local b2 = Reglas.bonos({
	Renacimientos = 2,
	Ramas = { Golpe = 2, Mercader = 1, Domador = 1 },
	MascotasEquipadas = { "Topito", "Piedrin", "Inventada" },
})
chequear(
	cerca(b2.Fuerza, 1 + 2 * GameConfig.Renacer.BonoFuerza + 0.1, 1e-9),
	"bono de fuerza con renacer y rama"
)
chequear(
	cerca(b2.Monedas, 1 + 2 * GameConfig.Renacer.BonoMonedas + 0.08 + 0.05, 1e-9),
	"bono de monedas: " .. b2.Monedas
)
chequear(
	cerca(b2.Suerte, 0.05, 1e-9) and b2.Lugares == GameConfig.Mascotas.Lugares + 1,
	"suerte y lugares"
)
local b99 = Reglas.bonos({ Renacimientos = 99, Ramas = {}, MascotasEquipadas = {} })
chequear(
	cerca(b99.Fuerza, 1 + GameConfig.Renacer.MaximoBonos * GameConfig.Renacer.BonoFuerza, 1e-9),
	"los bonos de renacer no tienen tope"
)
local cuatro = Reglas.bonos({
	Renacimientos = 0,
	Ramas = {},
	MascotasEquipadas = { "Nebula", "Nebula", "Nebula", "Nebula" },
})
chequear(cerca(cuatro.Suerte, 0.5 * GameConfig.Mascotas.Lugares, 1e-9), "cuentan mascotas de más")
chequear(
	Reglas.zonaParaRenacer(0) == 3
		and Reglas.zonaParaRenacer(1) == 4
		and Reglas.zonaParaRenacer(7) == 5,
	"zona para renacer"
)
chequear(not Reglas.puedeRenacer({ [1] = true, [2] = true }, 0), "renace sin el Glaciar")
chequear(Reglas.puedeRenacer({ [1] = true, [2] = true, [3] = true }, 0), "no renace con el Glaciar")
chequear(
	not Reglas.puedeRenacer({ [1] = true, [2] = true, [3] = true }, 1),
	"el segundo renacer no pide el Volcán"
)
chequear(
	Reglas.esenciaRenacer({ [1] = true, [2] = true, [3] = true }) == 2,
	"esencia por renacer en el Glaciar"
)
chequear(Reglas.esenciaRenacer({ [1] = true }) >= 1, "renacer da 0 de esencia")
for _, r in GameConfig.Renacer.Ramas do
	chequear(
		#r.Costos > 0 and Reglas.costoRama(r.Id, 0) == r.Costos[1],
		r.Id .. ": costo del primer nivel"
	)
	chequear(Reglas.costoRama(r.Id, #r.Costos) == nil, r.Id .. ": se puede pasar del máximo")
	chequear(
		r.Renacer >= 1 and r.Renacer <= #GameConfig.Renacer.Desbloqueos,
		r.Id .. ": renacer fuera de rango"
	)
end
chequear(
	Reglas.ramaDisponible("Golpe", 1) and not Reglas.ramaDisponible("Domador", 3),
	"ramas por renacer"
)
chequear(
	Reglas.vidaRenacida(0) == 400
		and Reglas.vidaRenacida(1000) == 1000 * GameConfig.Renacer.GolpesRenacida,
	"vida de la renacida"
)

-- 18. Grupo 4: Ruleta de Mascotas.
local sumaChances = 0
for _, m in GameConfig.Mascotas.Lista do
	sumaChances += m.Chance
	chequear(Reglas.rareza(m.Rareza) ~= nil, m.Id .. ": rareza desconocida")
	chequear((m.Monedas or 0) > 0 or (m.Suerte or 0) > 0, m.Id .. ": no da nada")
	chequear(#m.Colores >= 2, m.Id .. ": faltan colores")
end
chequear(cerca(sumaChances, 100, 1e-9), "las chances de la ruleta no suman 100: " .. sumaChances)
local cuentas: { [string]: number } = {}
local TIRADAS = 200000
for _ = 1, TIRADAS do
	local m = Reglas.tirarRuleta(azarLune)
	cuentas[m.Id] = (cuentas[m.Id] or 0) + 1
end
for _, m in GameConfig.Mascotas.Lista do
	local real = (cuentas[m.Id] or 0) / TIRADAS * 100
	chequear(
		cerca(real, m.Chance, math.max(0.25, m.Chance * 0.06)),
		("ruleta %s: %.2f %% en vez de %.2f %%"):format(m.Id, real, m.Chance)
	)
end
chequear(
	Reglas.tirarRuleta(function()
		return 0.999999
	end).Id == GameConfig.Mascotas.Lista[#GameConfig.Mascotas.Lista].Id,
	"la última de la ruleta no sale"
)
chequear(
	Reglas.precioRuleta({ [1] = true }) == GameConfig.Mascotas.Ruleta.Precio,
	"precio de la ruleta en la Pradera"
)
chequear(
	Reglas.precioRuleta({ [1] = true, [2] = true }) > Reglas.precioRuleta({ [1] = true }),
	"la ruleta no sube con la zona"
)
chequear(
	Reglas.puedeEquipar({}, "Topito", { Topito = 1 }, 3),
	"no deja equipar una mascota que tiene"
)
chequear(
	not Reglas.puedeEquipar({ "Topito" }, "Topito", { Topito = 1 }, 3),
	"deja equipar dos veces la misma copia"
)
chequear(
	Reglas.puedeEquipar({ "Topito" }, "Topito", { Topito = 2 }, 3),
	"no deja equipar la segunda copia"
)
chequear(
	not Reglas.puedeEquipar({ "A", "B", "C" }, "Topito", { Topito = 5 }, 3),
	"deja equipar sin lugar"
)
chequear(
	not Reglas.puedeEquipar({}, "Inventada", { Inventada = 1 }, 3),
	"deja equipar una mascota inventada"
)

-- 19. Grupo 4: misiones.
local plantillasVistas: { [string]: boolean } = {}
for _, pl in GameConfig.Misiones.Plantillas do
	chequear(not plantillasVistas[pl.Id], "misión repetida: " .. pl.Id)
	plantillasVistas[pl.Id] = true
	chequear(
		GameConfig.Misiones.Dificultades[pl.Dificultad] ~= nil,
		pl.Id .. ": dificultad desconocida"
	)
	chequear(
		#pl.Meta >= 1 and pl.Meta[1] >= 1 and (pl.Meta[2] or pl.Meta[1]) >= pl.Meta[1],
		pl.Id .. ": meta mal"
	)
	if pl.Tamano then
		chequear(Reglas.tamano(pl.Tamano) ~= nil, pl.Id .. ": tamaño desconocido")
	end
	if pl.Rareza then
		chequear(Reglas.rareza(pl.Rareza) ~= nil, pl.Id .. ": rareza desconocida")
	end
	chequear(pl.Texto:find("%%") ~= nil, pl.Id .. ": el texto no muestra la meta")
end
local jm = {
	Indice = {} :: { [string]: boolean },
	Exoticas = {},
	Rarezas = {},
	GeodasRotas = 0,
	JefesDerrotados = 0,
	EventosJugados = 0,
	Logros = {} :: { [string]: boolean },
	Zonas = { [1] = true } :: { [number]: boolean },
	Secretos = {} :: { [number]: boolean },
	Renacimientos = 0,
}
for _, dif in GameConfig.Misiones.Lugares do
	for _ = 1, 200 do
		local mi = Reglas.nuevaMision(dif, jm, azarLune)
		chequear(mi ~= nil, "no hay misión " .. dif .. " para un jugador nuevo")
		if mi then
			chequear(
				mi.Meta >= 1 and mi.Monedas > 0 and mi.Texto ~= "" and not mi.Texto:find("%%"),
				"misión mal armada: " .. mi.Id
			)
			chequear(
				mi.Id ~= "Ocultas"
					and mi.Id ~= "Portal"
					and mi.Id ~= "Legendaria"
					and mi.Id ~= "Coleccion",
				"misión imposible para un jugador nuevo: " .. mi.Id
			)
		end
	end
end
chequear(Reglas.nuevaMision("Prestigio", jm, azarLune) == nil, "misión de prestigio sin renacer")
jm.Renacimientos = 1
chequear(
	Reglas.nuevaMision("Prestigio", jm, azarLune) ~= nil,
	"no hay misión de prestigio después de renacer"
)
-- evita repetir la plantilla si puede
local soloFaciles = 0
for _, pl in GameConfig.Misiones.Plantillas do
	if pl.Dificultad == "Facil" then
		soloFaciles += 1
	end
end
local evitar = { Geodas = true }
for _ = 1, 100 do
	local mi = Reglas.nuevaMision("Facil", jm, azarLune, evitar) :: any
	chequear(soloFaciles == 1 or mi.Id ~= "Geodas", "repite la misión que tenía")
end
-- avance
local mg = {
	Id = "x",
	Tipo = "Geodas",
	Dificultad = "Facil",
	Meta = 3,
	Progreso = 0,
	Texto = "",
	Monedas = 1,
	Esencia = 0,
	Tamano = "Mediana",
}
chequear(
	Reglas.avanceMision(
		mg,
		{ Tipo = "Geoda", Tamano = "Mediana", Zona = 1, Modificador = "Normal" }
	) == 1,
	"misión de medianas no avanza"
)
chequear(
	Reglas.avanceMision(
		mg,
		{ Tipo = "Geoda", Tamano = "Pequena", Zona = 1, Modificador = "Normal" }
	) == 0,
	"misión de medianas avanza con una pequeña"
)
local mr = {
	Id = "x",
	Tipo = "Rareza",
	Dificultad = "Facil",
	Meta = 3,
	Progreso = 0,
	Texto = "",
	Monedas = 1,
	Esencia = 0,
	Rareza = "Raro",
}
chequear(
	Reglas.avanceMision(mr, { Tipo = "Gema", Rareza = "Epico" }) == 1,
	"una épica no cuenta como rara o mejor"
)
chequear(
	Reglas.avanceMision(mr, { Tipo = "Gema", Rareza = "Comun" }) == 0,
	"una común cuenta como rara"
)
local me = {
	Id = "x",
	Tipo = "Exotica",
	Dificultad = "Media",
	Meta = 1,
	Progreso = 0,
	Texto = "",
	Monedas = 1,
	Esencia = 0,
}
chequear(
	Reglas.avanceMision(me, { Tipo = "Geoda", Modificador = "VacioLava" }) == 1,
	"una combinación no cuenta como exótica"
)
chequear(
	Reglas.avanceMision(me, { Tipo = "Geoda", Modificador = "Normal" }) == 0,
	"una normal cuenta como exótica"
)
local mj = {
	Id = "x",
	Tipo = "Jefe",
	Dificultad = "Media",
	Meta = 1,
	Progreso = 0,
	Texto = "",
	Monedas = 1,
	Esencia = 0,
}
chequear(
	Reglas.avanceMision(mj, { Tipo = "Geoda", Tamano = "Ancestral" }) == 1,
	"la ancestral no cuenta como jefe"
)
local mz = Reglas.nuevaMision(
	"Facil",
	{
		Indice = {},
		Exoticas = {},
		Rarezas = {},
		GeodasRotas = 0,
		JefesDerrotados = 0,
		EventosJugados = 0,
		Logros = {},
		Zonas = { [1] = true, [2] = true },
		Secretos = {},
	},
	function()
		return 0.4
	end
) :: any
if mz.Id == "GeodasZona" then
	chequear(
		mz.Zona == 2 and Reglas.avanceMision(mz, { Tipo = "Geoda", Zona = 1 }) == 0,
		"misión de zona cuenta otra zona"
	)
end
-- nuevas y colecciones
jm.Indice.Cuarzo = true
local mn: any = nil
for _ = 1, 300 do
	local mi = Reglas.nuevaMision("Media", jm, azarLune)
	if mi and mi.Id == "Nuevo" then
		mn = mi
		break
	end
end
chequear(mn ~= nil and mn.Base == 1, "misión de mineral nuevo sin base")
if mn then
	chequear(Reglas.progresoMision(mn, jm) == 0, "mineral nuevo arranca avanzada")
	jm.Indice.Jaspe = true
	chequear(Reglas.progresoMision(mn, jm) == 1, "mineral nuevo no avanza")
end
jm.Indice.Amatista = true -- Museo3 (3 distintas) queda a punto; PraderaBrillante completa
jm.Logros.Museo3 = true
jm.Indice.Ambar = true
-- con 6 de las 12 de la Pradera, la colección 1 queda por la mitad y sirve para una misión
jm.Indice.AgataMusgosa, jm.Indice.Esmeralda, jm.Indice.TurmalinaRosa = true, true, true
jm.Zonas[3] = true
local mc: any = nil
for _ = 1, 300 do
	local mi = Reglas.nuevaMision("Dificil", jm, azarLune)
	if mi and mi.Id == "Coleccion" then
		mc = mi
		break
	end
end
chequear(
	mc ~= nil and mc.Logro ~= nil and not jm.Logros[mc.Logro],
	"misión de colección sin colección"
)
if mc then
	chequear(Reglas.progresoMision(mc, jm) == 0, "colección arranca hecha")
	jm.Logros[mc.Logro] = true
	chequear(Reglas.progresoMision(mc, jm) == 1, "colección no se completa")
end

if errores > 0 then
	print(("%d pruebas fallaron"):format(errores))
	process.exit(1)
end
print("Reglas: todo bien")
