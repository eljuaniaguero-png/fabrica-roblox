--!strict
-- Pruebas de las reglas de la mazmorra y del balance. Se corren desde la raíz del repositorio:
--   lune run plinko-knight/pruebas/mazmorra
-- 1) Reglas: contraataque, curarse al ganar, perder y ganarle al jefe.
-- 2) Balance: juega muchas mazmorras con tiros a ángulos al azar y un bot en la tienda (sin
--    comprar, comprando al azar con cada bola, comprando todo y comprando siempre el mismo tipo)
--    y cuenta cuántos tiros dura cada pelea y en qué piso se pierde. Sale con error si una regla falla; el balance solo
--    se informa.
-- Para probar otras vidas de monstruos sin tocar Config (y menos corridas):
--   lune run plinko-knight/pruebas/mazmorra 50,90,160,300,500,900,1600,2800,5000 100
-- y con "rapido" al final mide solo 4 formas de jugar (al azar con hierro y las 3 familias).

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
	chequear(#Config.Monstruos == 9, "tienen que ser 3 zonas de 3 peleas")

	local rata = Config.Monstruos[1]
	local t = Mazmorra.turno(e, 10) -- la rata sigue viva y contraataca
	chequear(
		t.Resultado == "sigue" and t.VidaMonstruo == rata.Vida - 10,
		"el golpe no le bajó la vida"
	)
	chequear(
		t.Golpe == rata.Golpe and e.Vida == Config.VidaCaballero - rata.Golpe,
		"no contraatacó"
	)

	t = Mazmorra.turno(e, 100000) -- la mata: piso 2, se cura sin pasarse del máximo
	chequear(t.Resultado == "piso" and t.Golpe == 0, "matarla no dio piso")
	chequear(e.Piso == 2 and e.VidaMonstruo == Config.Monstruos[2].Vida, "no pasó al slime")
	chequear(e.Vida == Config.VidaCaballero, "la cura se pasó del máximo o no curó")

	e.Vida = 3
	t = Mazmorra.turno(e, 1)
	chequear(t.Resultado == "perdio" and e.Fase == "perdio" and e.Vida == 0, "no perdió")

	-- Etapa 11: la práctica (piso 0) no pega, no da oro ni tienda y lleva a la pelea 1.
	e = Mazmorra.nueva("hierro", nil, true)
	chequear(e.Piso == 0 and e.VidaMonstruo == Config.Practica.Vida, "la práctica no arranca")
	t = Mazmorra.turno(e, 1)
	chequear(t.Resultado == "sigue" and t.Golpe == 0, "la práctica pegó")
	local oro = e.Oro
	t = Mazmorra.turno(e, 1000)
	chequear(t.Resultado == "practica" and e.Fase == "peleando", "la práctica abrió la tienda")
	chequear(e.Piso == 1 and e.VidaMonstruo == Config.Monstruos[1].Vida, "no pasó a la pelea 1")
	chequear(e.Oro == oro and e.TirosPelea == 0, "la práctica dio oro o no reinició la pelea")

	e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, 9)
	chequear(
		e.Piso == 9 and e.VidaMonstruo == Config.Monstruos[9].Vida,
		"el comando no fue al jefe"
	)
	t = Mazmorra.turno(e, 10000000)
	chequear(t.Resultado == "gano" and e.Fase == "gano", "ganarle al jefe no terminó la mazmorra")

	Mazmorra.irAPiso(e, 99)
	chequear(e.Piso == 9, "el comando se pasó del último piso")
end

-- 2) Balance
local tablero = Tablero.generar()
local CORRIDAS = tonumber(process.args[2]) or 300 -- por cada forma de elegir
if process.args[1] then
	for i, vida in string.split(process.args[1], ",") do
		if Config.Monstruos[i] then
			Config.Monstruos[i].Vida = tonumber(vida) or Config.Monstruos[i].Vida
		end
	end
end
local semilla = 12345
local function azar(): number -- 0..1, determinista
	semilla = (semilla * 1103515245 + 12345) % 2147483648
	return semilla / 2147483648
end
local function nuevaSemilla(): number
	return math.floor(azar() * 2 ^ 31)
end

-- Un tiro a un ángulo al azar, con el tablero, niveles y bola de la partida (como el servidor).
local function tiro(e: any): (number, number)
	local angulo = (azar() * 2 - 1) * Config.Punteria.AnguloMaximo
	local res =
		Simulacion.simular(tablero, angulo, Config.Bola, Mazmorra.modificadores(e), nuevaSemilla())
	Mazmorra.cobrarTiro(e, res.Oro, res.Rotas)
	return res.Danio, res.Quemadura
end

local Tienda = cargar("Tienda")

-- Clavijas al azar (con el azar de la prueba) que no sean hueco ni del tipo `noEste`.
local function clavijasAlAzar(e: any, cantidad: number, noEste: string?): { number }?
	local libres = {}
	for id, tipo in e.Tablero do
		if tipo ~= "hueco" and tipo ~= noEste and (noEste == nil or tipo == "gris") then
			table.insert(libres, id)
		end
	end
	if #libres < cantidad then
		return nil
	end
	local elegidas = {}
	for _ = 1, cantidad do
		table.insert(elegidas, table.remove(libres, math.floor(azar() * #libres) + 1))
	end
	return elegidas
end

-- Usa todos los pergaminos que tiene (el martillo lo deja para no borrar clavijas buenas).
local function usarPergaminos(e: any)
	local lugar = 1
	while e.Pergaminos[lugar] do
		local id = e.Pergaminos[lugar]
		local clase, tipo = Tienda.partes(id)
		local ok = false
		if clase ~= "martillo" then
			local objetivos = clavijasAlAzar(e, Tienda.clavijasAElegir("pergamino", id), tipo)
			ok = objetivos ~= nil and Tienda.usar(e, lugar, objetivos)
		end
		if not ok then
			lugar += 1
		end
	end
end

-- Formas de comprar en la tienda. querer(item) dice si el bot lo quiere.
local function comprador(querer: ((item: any) -> boolean)?): (e: any) -> ()
	return function(e: any)
		-- Cofre del jefe: la primera que quiera (o la primera, si quiere todo al azar).
		if querer and not e.Tienda.CofreTomado then
			for indice, id in e.Tienda.Cofre do
				if querer({ Clase = "reliquia", Id = id, Precio = 0 }) then
					Tienda.tomarCofre(e, indice)
					break
				end
			end
		end
		if querer then
			for indice, item in e.Tienda.Items do
				if not item.Vendido and e.Oro >= item.Precio and querer(item) then
					local objetivos = if item.Clase == "clavija"
						then clavijasAlAzar(e, 1, item.Id)
						else nil
					Tienda.comprar(e, indice, objetivos)
				end
			end
		end
		usarPergaminos(e)
		chequear(Tienda.bajar(e), "el bot no pudo bajar")
	end
end

-- Juega CORRIDAS mazmorras con una forma de comprar.
type Medida = { tirosPorPelea: { { number } }, caidas: { number }, ganadas: number }
local function jugar(comprar: (e: any) -> (), bola: string?): Medida
	local m: Medida = { tirosPorPelea = {}, caidas = {}, ganadas = 0 }
	for piso = 1, #Config.Monstruos do
		m.tirosPorPelea[piso] = {}
		m.caidas[piso] = 0
	end
	for _ = 1, CORRIDAS do
		local e = Mazmorra.nueva(bola)
		Mazmorra.sortearManias(e, nuevaSemilla())
		local tiros = 0
		while e.Fase == "peleando" do
			local piso = e.Piso
			tiros += 1
			local t = Mazmorra.turno(e, tiro(e))
			if t.Resultado == "piso" or t.Resultado == "gano" then
				table.insert(m.tirosPorPelea[piso], tiros)
				tiros = 0
			elseif t.Resultado == "perdio" then
				m.caidas[piso] += 1
			end
			if e.Fase == "tienda" then
				Tienda.abrir(e, nuevaSemilla())
				comprar(e)
			end
		end
		if e.Fase == "gano" then
			m.ganadas += 1
		end
	end
	return m
end

local alAzar = comprador(function(): boolean
	return azar() < 0.7
end)

-- Formas de jugar. Con "rapido" como tercer argumento se miden solo las marcadas (para ajustar
-- números sin esperar 5 minutos).
local RAPIDO = process.args[3] == "rapido"
local medidas: { { titulo: string, medida: Medida } } = {}
local function medir(titulo: string, comprar: (e: any) -> (), bola: string?, enRapido: boolean?)
	if RAPIDO and not enRapido then
		return
	end
	table.insert(medidas, { titulo = titulo, medida = jugar(comprar, bola) })
end

medir("Sin comprar", comprador(nil))
for _, bola in Config.OrdenBolas do
	medir("Compra al azar, bola " .. bola, alAzar, bola, bola == "hierro")
end
medir(
	"Compra todo lo que puede",
	comprador(function(): boolean
		return true
	end)
)
for _, tipo in Config.OrdenClavijas do
	-- Solo clavijas y pergaminos de ese tipo, y vendajes.
	medir(
		"Siempre " .. tipo,
		comprador(function(item: any): boolean
			local _, del = Tienda.partes(item.Id)
			return item.Id == tipo or del == tipo or item.Id == "vendaje"
		end)
	)
end

-- Al azar pero sin reliquias (para comparar con el paso 5b).
medir(
	"Compra al azar sin reliquias",
	comprador(function(item: any): boolean
		return item.Clase ~= "reliquia" and azar() < 0.7
	end)
)

-- Armar una familia (paso 5c): sus clavijas, sus pergaminos y sus reliquias.
local familias = {
	{
		Nombre = "rojas",
		Tipo = "roja",
		Reliquias = { "brasa", "rubi", "corona", "cadena", "trofeo" },
	},
	{
		Nombre = "bolas",
		Tipo = "verde",
		Reliquias = { "gemela", "enjambre", "hoja", "cadena", "martillo" },
	},
	{
		Nombre = "oro",
		Tipo = "dorada",
		Reliquias = { "toqueOro", "avaro", "bolsa", "midas", "corona" },
	},
}
for _, f in familias do
	medir(
		"Familia " .. f.Nombre,
		comprador(function(item: any): boolean
			local _, del = Tienda.partes(item.Id)
			if item.Clase == "reliquia" then
				return table.find(f.Reliquias, item.Id) ~= nil
			end
			return item.Id == f.Tipo or del == f.Tipo or item.Id == "vendaje"
		end),
		nil,
		true
	)
end

-- El jefe de la zona 1 solo, sin comprar y con vida de sobra (como con la tecla 0).
local tirosJefe: { number } = {}
for _ = 1, CORRIDAS do
	local e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, 3)
	e.Vida = 9999
	local tiros = 0
	while e.Fase == "peleando" do
		tiros += 1
		Mazmorra.turno(e, tiro(e))
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

local function informar(titulo: string, medida: Medida)
	print(("%s, %d mazmorras con tiros al azar:"):format(titulo, CORRIDAS))
	for piso, m in Config.Monstruos do
		print(
			("  Pelea %d · %s (%d/%d): %s · caídas acá: %.1f %%"):format(
				piso,
				m.Nombre,
				m.Vida,
				m.Golpe,
				resumen(medida.tirosPorPelea[piso]),
				medida.caidas[piso] / CORRIDAS * 100
			)
		)
	end
	print(("  Mazmorras ganadas: %.1f %%"):format(medida.ganadas / CORRIDAS * 100))
end

for _, m in medidas do
	informar(m.titulo, m.medida)
end
print("Jefe de la zona 1 solo, sin comprar y con vida de sobra: " .. resumen(tirosJefe))

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Reglas de la mazmorra: todo bien")
