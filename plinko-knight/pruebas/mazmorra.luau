--!strict
-- Pruebas de las reglas de la mazmorra y del balance. Se corren desde la raíz del repositorio:
--   lune run plinko-knight/pruebas/mazmorra
-- 1) Reglas: contraataque, curarse al ganar, perder y ganarle al jefe.
-- 2) Balance: juega muchas mazmorras con tiros a ángulos al azar y un bot en la tienda (sin
--    comprar, comprando al azar con cada bola, comprando todo y comprando siempre el mismo tipo)
--    y cuenta cuántos tiros dura cada pelea y en qué piso se pierde. Sale con error si una regla falla; el balance solo
--    se informa.
-- Para probar otras vidas de monstruos sin tocar Config (y menos corridas):
--   lune run plinko-knight/pruebas/mazmorra 40,80,150,250,400,600,900 100

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

	e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, 7)
	chequear(
		e.Piso == 7 and e.VidaMonstruo == Config.Monstruos[7].Vida,
		"el comando no fue al jefe"
	)
	t = Mazmorra.turno(e, 10000000)
	chequear(t.Resultado == "gano" and e.Fase == "gano", "ganarle al jefe no terminó la mazmorra")

	Mazmorra.irAPiso(e, 99)
	chequear(e.Piso == 7, "el comando se pasó del último piso")
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

local medidas: { { titulo: string, medida: Medida } } = {}
table.insert(medidas, { titulo = "Sin comprar", medida = jugar(comprador(nil)) })
for _, bola in Config.OrdenBolas do
	table.insert(
		medidas,
		{ titulo = "Compra al azar, bola " .. bola, medida = jugar(alAzar, bola) }
	)
end
table.insert(medidas, {
	titulo = "Compra todo lo que puede",
	medida = jugar(comprador(function(): boolean
		return true
	end)),
})
for _, tipo in Config.OrdenClavijas do
	-- Solo clavijas y pergaminos de ese tipo, y vendajes.
	table.insert(medidas, {
		titulo = "Siempre " .. tipo,
		medida = jugar(comprador(function(item: any): boolean
			local _, del = Tienda.partes(item.Id)
			return item.Id == tipo or del == tipo or item.Id == "vendaje"
		end)),
	})
end

-- El jefe solo, sin comprar y con vida de sobra (como con la tecla 0), para saber cuánto dura.
local tirosJefe: { number } = {}
for _ = 1, CORRIDAS do
	local e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, #Config.Monstruos)
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
print("Jefe solo, sin comprar y con vida de sobra: " .. resumen(tirosJefe))

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Reglas de la mazmorra: todo bien")
