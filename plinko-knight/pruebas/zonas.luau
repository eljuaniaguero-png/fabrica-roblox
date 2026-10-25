--!strict
-- Pruebas del paso 5d: zonas, mañas de jefe y cofre. Se corren desde la raíz del repositorio:
--   lune run plinko-knight/pruebas/zonas
-- 1) Las 3 zonas: 9 peleas, un jefe al final de cada zona, la vida sube.
-- 2) Mañas: se sortean distintas, solo valen en los jefes y cada una hace lo suyo.
-- 3) Cofre: aparece después de un jefe, trae reliquias que no tenés y te llevás una sola.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Clavijas = cargar("Clavijas")
local Mazmorra = cargar("Mazmorra")
local Tienda = cargar("Tienda")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local tablero = Tablero.generar()
local N = #tablero.Clavijas

local function conTipo(tipo: string): { string }
	local t = Clavijas.nuevoTablero(N)
	for id = 1, N do
		t[id] = tipo
	end
	return t
end

-- 1) Zonas
do
	chequear(#Config.Monstruos == 9 and #Config.Zonas == 3, "tienen que ser 3 zonas de 3 peleas")
	for piso, m in Config.Monstruos do
		chequear(m.Zona == math.ceil(piso / 3), ("la pelea %d está en otra zona"):format(piso))
		chequear(
			(m.EsJefe == true) == (piso % 3 == 0),
			("la pelea %d: jefe mal puesto"):format(piso)
		)
		if piso > 1 then
			chequear(
				m.Vida > Config.Monstruos[piso - 1].Vida,
				("la pelea %d no tiene más vida"):format(piso)
			)
		end
	end
end

-- 2) Mañas
do
	local e = Mazmorra.nueva()
	Mazmorra.sortearManias(e, 123)
	chequear(#e.ManiasJefes == 3, "no se sortearon 3 mañas")
	chequear(
		e.ManiasJefes[1] ~= e.ManiasJefes[2]
			and e.ManiasJefes[2] ~= e.ManiasJefes[3]
			and e.ManiasJefes[1] ~= e.ManiasJefes[3],
		"las mañas se repiten"
	)
	for _, m in e.ManiasJefes do
		chequear(Config.Manias[m] ~= nil, "maña desconocida: " .. tostring(m))
	end
	local otra = Mazmorra.nueva()
	Mazmorra.sortearManias(otra, 123)
	chequear(
		table.concat(otra.ManiasJefes, ",") == table.concat(e.ManiasJefes, ","),
		"misma semilla, otras mañas"
	)
	chequear(e.Mania == "", "la primera pelea no es un jefe: no tiene maña")
	Mazmorra.irAPiso(e, 3)
	chequear(e.Mania == e.ManiasJefes[1], "el jefe de la zona 1 no tiene su maña")
	Mazmorra.irAPiso(e, 6)
	chequear(e.Mania == e.ManiasJefes[2], "el jefe de la zona 2 no tiene su maña")
	Mazmorra.irAPiso(e, 5)
	chequear(e.Mania == "", "una pelea común tiene maña")
	chequear(Mazmorra.modificadores(e).Mania == "", "la maña no llega a la simulación")
	chequear(
		Mazmorra.textoMania("coraza", 2):find(tostring(Config.Manias.coraza.Minimo[2])) ~= nil,
		"el texto de la coraza no dice el mínimo"
	)
	chequear(
		Mazmorra.textoMania("avaricia", 1):find("1") ~= nil,
		"el texto de la avaricia no dice el oro"
	)

	-- En la simulación.
	for i = 1, 30 do
		local ang = -50 + i * 3.3
		local roja = Simulacion.simular(
			tablero,
			ang,
			Config.Bola,
			{ Tablero = conTipo("roja"), Mania = "sangreFria" },
			i
		)
		chequear(roja.Multi == 1, "sangre fría: las rojas sumaron Multi")

		local azul = Simulacion.simular(
			tablero,
			ang,
			Config.Bola,
			{ Tablero = conTipo("azul"), Mania = "cristalMaldito" },
			i
		)
		local tocadas: { [number]: boolean } = {}
		local cuantas = 0
		for _, t in azul.Toques do
			if not tocadas[t.Clavija] then
				tocadas[t.Clavija] = true
				cuantas += 1
			end
		end
		chequear(#azul.Rotas == cuantas, "cristal maldito: no se rompieron todas")

		local paredes = Simulacion.simular(tablero, ang, Config.Bola, { Mania = "paredesVivas" }, i)
		for _, t in paredes.Toques do
			local c = tablero.Clavijas[t.Clavija]
			local esPunta = true
			for _, otra2 in tablero.Clavijas do
				if otra2.Fila == c.Fila and (otra2.X < c.X) and (otra2.X > c.X - 100) then
					esPunta = false
					break
				end
			end
			local esUltima = true
			for _, otra2 in tablero.Clavijas do
				if otra2.Fila == c.Fila and otra2.X > c.X then
					esUltima = false
					break
				end
			end
			chequear(
				not esPunta and not esUltima,
				"paredes vivas: contó una clavija de un costado"
			)
		end

		local lista = {
			{ Id = "corona", Contador = 0, Precio = 12 },
			{ Id = "cadena", Contador = 0, Precio = 4 },
		}
		local callado = Simulacion.simular(
			tablero,
			ang,
			Config.Bola,
			{ Reliquias = lista, Mania = "silencio" },
			i
		)
		local soloCadena =
			Simulacion.simular(tablero, ang, Config.Bola, { Reliquias = { lista[2] } }, i)
		chequear(
			callado.Multi == soloCadena.Multi,
			"silencio: la reliquia de la izquierda funcionó"
		)

		local normal = Simulacion.simular(tablero, ang, Config.Bola, {}, i)
		local viento = Simulacion.simular(tablero, ang, Config.Bola, { Mania = "viento" }, i)
		local dxNormal = math.abs(normal.X[2] - normal.X[1]) + math.abs(normal.Y[2] - normal.Y[1])
		local dxViento = math.abs(viento.X[2] - viento.X[1]) + math.abs(viento.Y[2] - viento.Y[1])
		chequear(dxViento > dxNormal, "viento: la bola no salió más rápida")
		chequear(viento.Fin == "abajo", "viento: la bola no llegó abajo")
	end

	-- En la mazmorra.
	local function jefeCon(mania: string): any
		local j = Mazmorra.nueva()
		Mazmorra.sortearManias(j, 1)
		j.ManiasJefes = { mania, mania, mania }
		Mazmorra.irAPiso(j, 3)
		return j
	end
	local j = jefeCon("avaricia")
	j.Oro = 5
	Mazmorra.cobrarTiro(j, 0, {})
	chequear(j.Oro == 5 - Config.Manias.avaricia.Oro, "avaricia: no sacó oro")
	j.Oro = 0
	Mazmorra.cobrarTiro(j, 0, {})
	chequear(j.Oro == 0, "avaricia: dejó el oro en negativo")

	j = jefeCon("coraza")
	local vida = j.VidaMonstruo
	local minimo = Config.Manias.coraza.Minimo[1]
	local t = Mazmorra.turno(j, minimo - 1)
	chequear(t.Danio == 0 and j.VidaMonstruo == vida, "coraza: un golpe chico hizo daño")
	t = Mazmorra.turno(j, minimo)
	chequear(
		t.Danio == minimo and j.VidaMonstruo == vida - minimo,
		"coraza: un golpe grande no hizo daño"
	)

	j = jefeCon("rabia")
	t = Mazmorra.turno(j, 1)
	chequear(
		t.Golpe == Config.Monstruos[3].Golpe * Config.Manias.rabia.Factor,
		"rabia: no pegó el doble"
	)
end

-- 3) Cofre
do
	local e = Mazmorra.nueva()
	Mazmorra.sortearManias(e, 5)
	Mazmorra.turno(e, 10000000) -- pelea común
	chequear(not e.CofrePendiente, "una pelea común dio cofre")
	Tienda.abrir(e, 1)
	chequear(#e.Tienda.Cofre == 0, "la tienda de una pelea común tiene cofre")
	Tienda.bajar(e)

	e.Reliquias = { { Id = "brasa", Contador = 0, Precio = 4 } }
	Mazmorra.irAPiso(e, 3)
	local t = Mazmorra.turno(e, 10000000)
	chequear(t.Resultado == "piso" and e.CofrePendiente, "ganarle al jefe no dejó el cofre")
	Tienda.abrir(e, 2)
	chequear(
		#e.Tienda.Cofre == Config.Cofre.Reliquias and not e.CofrePendiente,
		"el cofre no tiene 3 reliquias"
	)
	local vistas: { [string]: boolean } = {}
	for _, id in e.Tienda.Cofre do
		chequear(id ~= "brasa" and not vistas[id], "el cofre trae una repetida o una que tenés")
		vistas[id] = true
	end
	local cofre = table.clone(e.Tienda.Cofre)
	e.Oro = 50
	Tienda.renovar(e, 9)
	chequear(
		table.concat(e.Tienda.Cofre, ",") == table.concat(cofre, ","),
		"renovar cambió el cofre"
	)
	chequear(not Tienda.tomarCofre(e, 4), "tomó una reliquia que no está en el cofre")
	chequear(not Tienda.tomarCofre(e, "1"), "tomó con un índice de texto")
	local oro = e.Oro
	chequear(
		Tienda.tomarCofre(e, 2) and e.Reliquias[2].Id == cofre[2],
		"no tomó la reliquia del cofre"
	)
	chequear(e.Oro == oro, "el cofre cobró oro")
	chequear(not Tienda.tomarCofre(e, 1), "tomó dos reliquias del cofre")

	-- Lleno: no deja, y después de vender sí.
	local lleno = Mazmorra.nueva()
	Mazmorra.sortearManias(lleno, 5)
	lleno.Reliquias = {}
	for k = 1, Config.LugaresReliquia do
		table.insert(lleno.Reliquias, { Id = Config.OrdenReliquias[k], Contador = 0, Precio = 4 })
	end
	Mazmorra.irAPiso(lleno, 3)
	Mazmorra.turno(lleno, 10000000)
	Tienda.abrir(lleno, 3)
	chequear(not Tienda.tomarCofre(lleno, 1), "tomó del cofre con los lugares llenos")
	chequear(Tienda.vender(lleno, 1) and Tienda.tomarCofre(lleno, 1), "no tomó después de vender")

	-- El último jefe no da cofre: termina la mazmorra.
	local fin = Mazmorra.nueva()
	Mazmorra.sortearManias(fin, 5)
	Mazmorra.irAPiso(fin, 9)
	t = Mazmorra.turno(fin, 10000000)
	chequear(
		t.Resultado == "gano" and not fin.CofrePendiente,
		"el último jefe no terminó la mazmorra"
	)
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Zonas, mañas y cofre: todo OK")
