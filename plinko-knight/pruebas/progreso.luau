--!strict
-- Pruebas de la etapa 6: lo que se guarda, la migración y los logros. Se corren desde la raíz:
--   lune run plinko-knight/pruebas/progreso
-- (ProfileStore no corre en Lune: el guardado de verdad se prueba en Studio.)
-- 1) Jugador nuevo y migración de datos guardados (rotos, viejos o con cosas que ya no existen).
-- 2) Cada logro desbloquea lo suyo una sola vez.
-- 3) La tienda y el cofre solo ofrecen reliquias desbloqueadas.
-- 4) Partidas enteras con el bot: el mejor piso y los desbloqueos cierran.
-- Sale con error si algo falla.

local process = require("@lune/process")
local cargar = require("./cargar")

local Config = cargar("Config")
local Tablero = cargar("Tablero")
local Simulacion = cargar("Simulacion")
local Mazmorra = cargar("Mazmorra")
local Tienda = cargar("Tienda")
local Progreso = cargar("Progreso")

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		print("FALLA: " .. mensaje)
	end
end

local function contar(lista: { string }, id: string): number
	local n = 0
	for _, x in lista do
		if x == id then
			n += 1
		end
	end
	return n
end

-- 1) Nuevo y migración
do
	local d = Progreso.nuevos()
	chequear(
		#d.BolasDesbloqueadas == 1 and d.BolasDesbloqueadas[1] == "hierro",
		"un jugador nuevo tiene solo hierro"
	)
	local desdeInicio = 0
	for _, id in Config.OrdenReliquias do
		if Config.Reliquias[id].Desbloqueo == "inicio" then
			desdeInicio += 1
			chequear(
				table.find(d.ReliquiasDesbloqueadas, id) ~= nil,
				"falta una reliquia de inicio: " .. id
			)
		end
	end
	chequear(
		#d.ReliquiasDesbloqueadas == desdeInicio and desdeInicio == 12,
		"tienen que ser 12 reliquias de inicio"
	)
	chequear(d.Version == Config.VERSION and d.MejorPiso == 0, "versión o mejor piso mal")

	chequear(Progreso.migrar(nil).BolaElegida == "hierro", "migrar nada no da un jugador nuevo")
	chequear(Progreso.migrar("roto").MejorPiso == 0, "migrar algo roto no da un jugador nuevo")
	local m = Progreso.migrar({
		MejorPiso = 5,
		MejorZona = 2,
		JefesVencidos = -3, -- roto: se ignora
		PartidasJugadas = 0 / 0, -- NaN: se ignora
		PartidasGanadas = 2.7,
		BolasDesbloqueadas = { "fuego", "fuego", "bolaQueNoExiste", 5 },
		ReliquiasDesbloqueadas = { "corona", "reliquiaVieja" },
		Logros = { "corona", "otraCosa" },
		BolaElegida = "partida", -- no la tiene: queda hierro
		CampoViejo = true,
	})
	chequear(m.MejorPiso == 5 and m.MejorZona == 2, "migrar perdió el mejor piso")
	chequear(m.JefesVencidos == 0 and m.PartidasJugadas == 0, "migrar aceptó números rotos")
	chequear(m.PartidasGanadas == 2, "migrar no redondeó")
	chequear(
		contar(m.BolasDesbloqueadas, "fuego") == 1 and #m.BolasDesbloqueadas == 2,
		"migrar dejó bolas raras o repetidas"
	)
	chequear(
		table.find(m.ReliquiasDesbloqueadas, "corona") ~= nil,
		"migrar perdió una reliquia desbloqueada"
	)
	chequear(
		table.find(m.ReliquiasDesbloqueadas, "reliquiaVieja") == nil,
		"migrar dejó una reliquia que no existe"
	)
	chequear(#m.Logros == 1, "migrar dejó un logro raro")
	chequear(m.BolaElegida == "hierro", "migrar dejó elegida una bola que no tiene")
	chequear((m :: any).CampoViejo == nil, "migrar dejó un campo viejo")
	local m2 = Progreso.migrar({ BolasDesbloqueadas = { "fuego" }, BolaElegida = "fuego" })
	chequear(m2.BolaElegida == "fuego", "migrar no respetó la bola elegida")

	local c = Progreso.copiar(m)
	table.insert(c.BolasDesbloqueadas, "partida")
	chequear(#m.BolasDesbloqueadas == 2, "copiar comparte las listas")
	chequear(
		Progreso.tieneBola(m, "fuego") and not Progreso.tieneBola(m, "partida"),
		"tieneBola mal"
	)
	chequear(not Progreso.tieneBola(m, 5), "tieneBola aceptó un número")
	Progreso.alEmpezar(m, "fuego")
	chequear(m.PartidasJugadas == 1 and m.BolaElegida == "fuego", "alEmpezar no contó la partida")
end

-- 2) Logros
do
	local L = Config.Logros
	local function res(campos: any): any
		local r = { Danio = 10, Recorridos = { {} }, Toques = {} }
		for k, v in campos do
			r[k] = v
		end
		return r
	end
	local function ids(nuevos: { any }): string
		local t = {}
		for _, n in nuevos do
			table.insert(t, n.Id)
		end
		table.sort(t)
		return table.concat(t, ",")
	end

	local d = Progreso.nuevos()
	local e = Mazmorra.nueva()
	chequear(#Progreso.alTirar(d, e, res({})) == 0, "un tiro común desbloqueó algo")
	chequear(
		ids(Progreso.alTirar(d, e, res({ Recorridos = { {}, {}, {}, {} } }))) == "enjambre",
		"4 bolas: enjambre"
	)
	chequear(
		ids(Progreso.alTirar(d, e, res({ Danio = L.CoronaGolpe }))) == "corona",
		"golpe grande: corona"
	)
	chequear(d.MejorGolpe == L.CoronaGolpe, "no guardó el mejor golpe")
	chequear(
		ids(Progreso.alTirar(d, e, res({ Toques = { { Veces = L.EcoVeces } } }))) == "ecoInfinito",
		"clavija que cuenta 3 veces: eco infinito"
	)
	e.Oro = L.MidasOro
	chequear(ids(Progreso.alTirar(d, e, res({}))) == "midas", "mucho oro: midas")
	chequear(
		#Progreso.alTirar(d, e, res({ Danio = L.CoronaGolpe })) == 0,
		"desbloqueó dos veces lo mismo"
	)
	chequear(contar(d.ReliquiasDesbloqueadas, "corona") == 1, "corona repetida en la lista")

	-- Turnos: ganar la pelea 1 no desbloquea; el jefe de la zona 1 sí.
	d = Progreso.nuevos()
	e = Mazmorra.nueva()
	local t = Mazmorra.turno(e, 10000000)
	chequear(#Progreso.alTurno(d, e, t, 1, "hierro") == 0, "ganar la pelea 1 desbloqueó algo")
	chequear(d.MejorPiso == 1, "no guardó el mejor piso")
	local perdio = { Resultado = "sigue", VidaCaballero = 40 }
	chequear(
		#Progreso.alTurno(d, e, perdio, 2, "hierro") == 0 and d.MejorPiso == 1,
		"un turno sin ganar cambió algo"
	)

	e = Mazmorra.nueva()
	Mazmorra.irAPiso(e, 3)
	e.Oro = L.AvaroOro
	e.PeleasSinGolpe = L.RachaPeleas
	t = { Resultado = "piso", VidaCaballero = L.AlientoVida - 1 }
	local nuevos = Progreso.alTurno(d, e, t, 3, "fuego")
	chequear(
		ids(nuevos) == "aliento,avaro,fuego,partida,racha,yesca",
		"ganarle al jefe 1 con fuego y todo: " .. ids(nuevos)
	)
	chequear(d.JefesVencidos == 1 and d.MejorZona == 2, "jefes vencidos o mejor zona mal")
	local bola: any = nil
	for _, n in nuevos do
		if n.Id == "fuego" then
			bola = n
		end
	end
	chequear(
		bola ~= nil and bola.Tipo == "bola" and bola.Nombre == Config.Bolas.fuego.Nombre,
		"el aviso de la bola está mal"
	)
	chequear(#Progreso.alTurno(d, e, t, 3, "fuego") == 0, "el mismo jefe desbloqueó dos veces")
	chequear(d.JefesVencidos == 2, "no contó el segundo jefe")
	Progreso.alTurno(d, e, { Resultado = "gano", VidaCaballero = 30 }, 9, "hierro")
	chequear(d.PartidasGanadas == 1 and d.MejorPiso == 9, "ganar la mazmorra no se contó")
end

-- 3) Tienda y cofre con las desbloqueadas
do
	local e = Mazmorra.nueva("hierro", { "brasa", "cadena" })
	for semilla = 1, 300 do
		for _, item in Tienda.generar(semilla, e) do
			if item.Clase == "reliquia" then
				chequear(
					item.Id == "brasa" or item.Id == "cadena",
					"la tienda ofreció una bloqueada: " .. item.Id
				)
			end
		end
	end
	local f = Mazmorra.nueva("hierro", Progreso.nuevos().ReliquiasDesbloqueadas)
	Mazmorra.sortearManias(f, 1)
	Mazmorra.irAPiso(f, 3)
	for semilla = 1, 200 do
		f.Fase = "peleando"
		f.Piso = 3
		f.CofrePendiente = true
		f.Fase = "tienda"
		Tienda.abrir(f, semilla)
		for _, id in f.Tienda.Cofre do
			chequear(
				Config.Reliquias[id].Desbloqueo == "inicio",
				"el cofre ofreció una bloqueada: " .. id
			)
		end
	end
	local copia = Mazmorra.copiar(e)
	table.insert(copia.ReliquiasDisponibles, "corona")
	chequear(#e.ReliquiasDisponibles == 2, "copiar comparte las reliquias disponibles")
end

-- 4) Partidas enteras (como el servidor)
do
	local tablero = Tablero.generar()
	local semilla = 7
	local function azar(): number
		semilla = (semilla * 1103515245 + 12345) % 2147483648
		return semilla / 2147483648
	end
	local d = Progreso.nuevos()
	local mejor = 0
	for _ = 1, 40 do
		local bola = d.BolasDesbloqueadas[math.floor(azar() * #d.BolasDesbloqueadas) + 1]
		local e = Mazmorra.nueva(bola, d.ReliquiasDesbloqueadas)
		Mazmorra.sortearManias(e, math.floor(azar() * 2 ^ 31))
		Progreso.alEmpezar(d, bola)
		while e.Fase == "peleando" do
			local res = Simulacion.simular(
				tablero,
				(azar() * 2 - 1) * 60,
				Config.Bola,
				Mazmorra.modificadores(e),
				math.floor(azar() * 2 ^ 31)
			)
			Mazmorra.cobrarTiro(e, res.Oro, res.Rotas)
			e.Furia = false
			Progreso.alTirar(d, e, res)
			local piso = e.Piso
			local t = Mazmorra.turno(e, res.Danio, res.Quemadura)
			Progreso.alTurno(d, e, t, piso, e.Bola)
			if t.Resultado == "piso" or t.Resultado == "gano" then
				mejor = math.max(mejor, piso)
			end
			if e.Fase == "tienda" then
				Tienda.abrir(e, math.floor(azar() * 2 ^ 31))
				for i, item in e.Tienda.Items do
					if item.Clase == "reliquia" and e.Oro >= item.Precio then
						Tienda.comprar(e, i, nil)
					end
				end
				if #e.Tienda.Cofre > 0 then
					Tienda.tomarCofre(e, 1)
				end
				Tienda.bajar(e)
			end
		end
	end
	chequear(d.PartidasJugadas == 40, "no contó las 40 partidas")
	chequear(
		d.MejorPiso == mejor,
		("el mejor piso guardado (%d) no es el jugado (%d)"):format(d.MejorPiso, mejor)
	)
	chequear(
		(mejor >= 4) == Progreso.tieneBola(d, "fuego"),
		"la bola de fuego no coincide con haber llegado a la zona 2"
	)
	print(
		("40 partidas con el bot: mejor piso %d, %d jefes, %d bolas y %d reliquias desbloqueadas"):format(
			d.MejorPiso,
			d.JefesVencidos,
			#d.BolasDesbloqueadas,
			#d.ReliquiasDesbloqueadas
		)
	)
end

if errores > 0 then
	print(("%d fallas"):format(errores))
	process.exit(1)
end
print("Progreso: todo OK")
