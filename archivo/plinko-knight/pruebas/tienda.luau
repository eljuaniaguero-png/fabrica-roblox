--!strict
-- Pruebas del paso 5b: oro, tienda y pergaminos. Se corren desde la raíz del repositorio:
--   lune run archivo/plinko-knight/pruebas/tienda
-- 1) Oro al ganar: base, bonus por matar rápido e interés con tope.
-- 2) Tienda: qué sale, comprar (oro, vendido, lugares, clavija elegida), renovar y bajar.
-- 3) Pergaminos: cada uno hace lo suyo y valida las clavijas elegidas.
-- 4) Furia en la simulación y que el servidor coincida.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Revision = cargar("Revision")
local Mazmorra = cargar("Mazmorra")
local Tienda = cargar("Tienda")
local Clavijas = cargar("Clavijas")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
local o = Config.Oro

-- Una partida que acaba de ganar la primera pelea en `tiros` tiros, con la tienda abierta.
local function enTienda(tiros: number, oroAntes: number): any
	local e = Mazmorra.nueva()
	e.Oro = oroAntes
	for _ = 1, tiros - 1 do
		Mazmorra.turno(e, 1)
	end
	local t = Mazmorra.turno(e, 10000000)
	chequear(t.Resultado == "piso" and e.Fase == "tienda", "ganar no abrió la tienda")
	Tienda.abrir(e, 77)
	return e, t
end

-- 1) Oro
do
	local e, t = enTienda(1, 0)
	local base = o.PorMonstruo + o.BonusUnTiro
	local interes = math.min(math.floor(base / o.InteresCada), o.InteresTope)
	chequear(
		e.Oro == base + interes,
		("un tiro: oro %d, esperaba %d"):format(e.Oro, base + interes)
	)
	chequear(t.Oro ~= nil and t.Oro.Bonus == o.BonusUnTiro, "el turno no dice el oro ganado")
	e = enTienda(2, 0)
	chequear(e.UltimoOro.Bonus == o.BonusDosTiros, "dos tiros: bonus mal")
	e = enTienda(4, 0)
	chequear(e.UltimoOro.Bonus == 0, "cuatro tiros: no tiene que haber bonus")
	e = enTienda(4, 100)
	chequear(e.UltimoOro.Interes == o.InteresTope, "el interés no respeta el tope")
	e = enTienda(4, 7)
	chequear(e.UltimoOro.Interes == math.floor((7 + o.PorMonstruo) / o.InteresCada), "interés mal")
	chequear(e.TirosPelea == 4, "no contó los tiros de la pelea")
	Tienda.bajar(e)
	chequear(e.TirosPelea == 0 and e.Fase == "peleando", "bajar no arrancó la pelea de cero")
end

-- 2) Tienda
do
	local items = Tienda.generar(5)
	chequear(
		#items
			== Config.Tienda.Reliquias
				+ Config.Tienda.MejorasDeClavija
				+ Config.Tienda.Pergaminos,
		"cantidad de ítems mal"
	)
	for _, item in items do
		if item.Clase == "reliquia" then
			chequear(Config.Reliquias[item.Id] ~= nil, "reliquia rara: " .. item.Id)
		elseif item.Clase == "clavija" then
			chequear(table.find(Config.OrdenClavijas, item.Id) ~= nil, "mejora de clavija rara")
		else
			chequear(Tienda.esPergamino(item.Id), "pergamino raro: " .. item.Id)
		end
	end
	local otra = Tienda.generar(5)
	chequear(
		otra[1].Id == items[1].Id and otra[#otra].Id == items[#items].Id,
		"misma semilla, otra tienda"
	)

	-- Que salgan todos los pergaminos y todas las clavijas con muchas semillas.
	local vistos: { [string]: boolean } = {}
	for semilla = 1, 3000 do
		for _, item in Tienda.generar(semilla) do
			vistos[item.Id] = true
		end
	end
	for _, p in Tienda.pergaminosPosibles() do
		chequear(vistos[p.Id] == true, "nunca salió " .. p.Id)
	end
	for _, tipo in Config.OrdenClavijas do
		chequear(vistos[tipo] == true, "nunca salió la mejora " .. tipo)
	end
	chequear(#Tienda.chances() > 3, "faltan las chances")

	local e = enTienda(3, 0)
	e.Oro = 20
	e.Tienda.Items = {
		{ Clase = "clavija", Id = "roja", Precio = 3, Vendido = false },
		{ Clase = "pergamino", Id = "vendaje", Precio = 3, Vendido = false },
		{ Clase = "pergamino", Id = "furia", Precio = 3, Vendido = false },
		{ Clase = "pergamino", Id = "martillo", Precio = 3, Vendido = false },
	}
	chequear(not Tienda.comprar(e, 1, nil), "compró una clavija sin elegir dónde")
	chequear(not Tienda.comprar(e, 1, { 999 }), "compró sobre una clavija que no existe")
	chequear(not Tienda.comprar(e, 1, { 1.5 }), "compró con un Id con coma")
	chequear(not Tienda.comprar(e, 1, { 1, 2 }), "compró dos clavijas con una mejora")
	chequear(not Tienda.comprar(e, 9, { 1 }), "compró un ítem que no está")
	chequear(not Tienda.comprar(e, "1", { 1 }), "compró con un índice de texto")
	e.Tablero[5] = "hueco"
	chequear(not Tienda.comprar(e, 1, { 5 }), "convirtió un hueco")
	e.Tablero[6] = "roja"
	chequear(not Tienda.comprar(e, 1, { 6 }), "convirtió una roja en roja")
	chequear(
		Tienda.comprar(e, 1, { 7 }) and e.Tablero[7] == "roja" and e.Oro == 17,
		"no compró la roja"
	)
	chequear(not Tienda.comprar(e, 1, { 8 }), "compró dos veces lo mismo")
	chequear(Tienda.comprar(e, 2, nil) and e.Pergaminos[1] == "vendaje", "no compró el vendaje")
	chequear(Tienda.comprar(e, 3, nil) and #e.Pergaminos == 2, "no compró la furia")
	chequear(not Tienda.comprar(e, 4, nil), "compró un pergamino sin lugar")
	chequear(e.Oro == 11, "el oro no cierra")
	e.Oro = 2
	e.Tienda.Items[4].Vendido = false
	chequear(Tienda.usar(e, 1, nil), "no usó el vendaje en la tienda")
	chequear(not Tienda.comprar(e, 4, nil), "compró sin oro")

	-- Renovar: cuesta y sube.
	e.Oro = 10
	local precio = Tienda.precioRenovar(e)
	chequear(precio == Config.Tienda.Renovar, "el primer renovar no cuesta lo de Config")
	chequear(Tienda.renovar(e, 1) and e.Oro == 10 - precio, "renovar no cobró")
	chequear(Tienda.precioRenovar(e) == precio + Config.Tienda.RenovarSube, "renovar no subió")
	e.Oro = 0
	chequear(not Tienda.renovar(e, 2), "renovó sin oro")
	chequear(Tienda.bajar(e) and not Tienda.bajar(e), "bajar mal")
	chequear(not Tienda.comprar(e, 1, { 9 }), "compró con la tienda cerrada")
	chequear(not Tienda.renovar(e, 3), "renovó con la tienda cerrada")
end

-- 3) Pergaminos
do
	local function con(id: string): any
		local e = Mazmorra.nueva()
		e.Pergaminos = { id }
		return e
	end
	local e = con("nivel:roja")
	chequear(Tienda.usar(e, 1, nil) and Clavijas.nivel(e.Niveles, "roja") == 2, "nivel: no subió")
	chequear(#e.Pergaminos == 0, "el pergamino no se gastó")
	chequear(not Tienda.usar(e, 1, nil), "usó un lugar vacío")

	e = con("nivel:gris")
	chequear(
		Tienda.usar(e, 1, nil) and Clavijas.nivel(e.Niveles, "gris") == 2,
		"nivel gris: no subió"
	)

	e = con("forja:verde")
	chequear(not Tienda.usar(e, 1, { 3 }), "forja con una sola clavija")
	chequear(not Tienda.usar(e, 1, { 3, 3 }), "forja con la misma clavija dos veces")
	chequear(
		Tienda.usar(e, 1, { 3, 4 }) and e.Tablero[3] == "verde" and e.Tablero[4] == "verde",
		"forja mal"
	)

	e = con("martillo")
	chequear(not Tienda.usar(e, 1, nil), "martillo sin elegir clavija")
	chequear(Tienda.usar(e, 1, { 10 }) and e.Tablero[10] == "hueco", "martillo no borró")

	e = con("vendaje")
	e.Vida = 20
	chequear(
		Tienda.usar(e, 1, nil) and e.Vida == 20 + Config.Pergaminos.vendaje.Cura,
		"vendaje no curó"
	)
	e = con("vendaje")
	e.Vida = e.VidaMaxima - 1
	Tienda.usar(e, 1, nil)
	chequear(e.Vida == e.VidaMaxima, "el vendaje se pasó del máximo")

	e = con("furia")
	chequear(Tienda.usar(e, 1, nil) and e.Furia, "furia no quedó prendida")

	e = con("vendaje")
	e.Fase = "perdio"
	chequear(not Tienda.usar(e, 1, nil), "usó un pergamino después de perder")
	chequear(not Tienda.usar(con("vendaje"), "1", nil), "usó con un lugar de texto")
end

-- 4) Furia en la simulación
do
	local f = Config.Pergaminos.furia.PorMulti
	for i = 1, 40 do
		local angulo = -50 + i * 2.5
		local sin = Simulacion.simular(tablero, angulo, Config.Bola, {}, i)
		local con = Simulacion.simular(tablero, angulo, Config.Bola, { Furia = true }, i)
		chequear(
			con.Multi == sin.Multi * f and con.Furia == f and sin.Furia == 1,
			"furia: Multi mal"
		)
		chequear(con.Danio == math.floor(con.Fuerza * con.Multi), "furia: golpe mal")
		local rev = Revision.revisar(tablero, angulo, i, { Furia = true }, con.Danio)
		chequear(rev.Danio == con.Danio and not rev.Corregido, "furia: el servidor no coincide")
	end
	local e = Mazmorra.nueva()
	e.Furia = true
	chequear(Mazmorra.modificadores(e).Furia == true, "la furia no llega a la simulación")
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Tienda: todo OK")
