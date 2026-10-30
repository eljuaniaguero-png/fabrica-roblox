--!strict
-- Simula a un jugador que juega solo, sin parar, para medir el ritmo del juego con los
-- números de GameConfig. Se corre desde la raíz del repositorio:
--   lune run archivo/forja-rapida/pruebas/simular            (4 golpes por segundo)
--   lune run archivo/forja-rapida/pruebas/simular 6          (otro ritmo de golpes)
--   lune run archivo/forja-rapida/pruebas/simular 4 sin-forja (sin La Forja, para comparar)
--   lune run archivo/forja-rapida/pruebas/simular 4 con-forja sin-coleccion
--     (sin el requisito de gemas de GameConfig.Zonas[n].GemasParaAbrir, para comparar)
-- El jugador: le pega a geodas de su mejor zona (tamaño al azar, como en el mapa), vende
-- todo apenas rompe (con un 15 % de tiempo extra por los viajes al Banco) y compra lo que más
-- le rinde por moneda entre: el próximo nivel de Fuerza, el próximo pico y el próximo amuleto.

local process = require("@lune/process")
local cargar = require("./cargar")

local GameConfig = cargar("GameConfig")
local Reglas = cargar("Reglas")

local GOLPES_POR_SEGUNDO = tonumber(process.args[1]) or 4
local CON_FORJA = process.args[2] ~= "sin-forja"
local CON_COLECCION = process.args[3] ~= "sin-coleccion"
local function gemasParaPasar(zona: number): number
	local z = GameConfig.Zonas[zona + 1]
	return if CON_COLECCION and z then Reglas.gemasParaAbrir(z) else 0
end
local ESCENA_FORJA = 4 -- segundos que dura la escena de La Forja (Rara o mejor)
local CAMINATA = 1.2 -- segundos para ir de una geoda a otra
local VIAJES_BANCO = 1.15
local DURACION = 3 * 3600 -- segundos simulados
local SEMILLAS = 5 -- se promedia el momento de cada hito entre varias partidas

local function rendimientoRareza(suerte: number): number
	local p = Reglas.probabilidades(GameConfig.Rarezas, suerte)
	local total = 0
	for _, r in GameConfig.Rarezas do
		total += p[r.Id] * r.Valor
	end
	return total
end

local function reloj(s: number): string
	return ("%d:%02d"):format(s // 60, s % 60)
end

local hitos: { [string]: { number } } = {}
local ordenHitos: { string } = {}
local function anotar(nombre: string, t: number)
	if not hitos[nombre] then
		hitos[nombre] = {}
		table.insert(ordenHitos, nombre)
	end
	table.insert(hitos[nombre], t)
end

for semilla = 1, SEMILLAS do
	math.randomseed(semilla)
	local azar = function(): number
		return math.random()
	end
	local t = 0
	local monedas = 0
	local nivel, pico, amuletos, cantAmuletos = 0, 1, {}, 0
	local zona = 1
	local vistas: { [number]: { [string]: boolean } } = {}
	local function distintas(z: number): number
		local n = 0
		for _ in vistas[z] or {} do
			n += 1
		end
		return n
	end
	local trabado: number? = nil -- desde cuándo tiene la Fuerza pero le faltan gemas

	while t < DURACION do
		local fuerza = Reglas.fuerza(nivel, pico)
		-- Zonas nuevas apenas la Fuerza alcanza.
		local nueva = Reglas.zonaMaxima(fuerza)
		if zona < nueva and distintas(zona) < gemasParaPasar(zona) then
			trabado = trabado or t
		end
		while zona < nueva and distintas(zona) >= gemasParaPasar(zona) do
			if trabado then
				anotar("Espera por gemas en zona " .. zona, t - trabado)
				trabado = nil
			end
			zona += 1
			anotar("Zona " .. zona .. " (" .. GameConfig.Zonas[zona].Nombre .. ")", t)
		end

		-- Una geoda.
		local tamano = Reglas.tamanoAlAzar(azar)
		local modificador = Reglas.tirar(GameConfig.Modificadores, 1, azar)
		local golpes = math.ceil(Reglas.vidaGeoda(zona, tamano) / fuerza)
		t += (golpes / GOLPES_POR_SEGUNDO + CAMINATA) * VIAJES_BANCO
		local suerte = Reglas.suerteGeoda(Reglas.suerteJugador(amuletos), zona, tamano)
		local rareza = Reglas.tirar(GameConfig.Rarezas, suerte, azar)
		local gema = Reglas.gemaDe(zona, rareza)
		local clave = gema.Id
		local rarezaInicial = rareza
		-- La Forja: usa todas sus monedas "?" (las guardadas no se cuentan)
		if CON_FORJA then
			local efecto: string? = nil
			for _ = 1, Reglas.intentosForja(rareza, tamano, modificador) do
				local siguiente = Reglas.rarezaSiguiente(rareza)
				local r, e = Reglas.intentoForja(rareza, efecto ~= nil, siguiente ~= nil, azar)
				if r == "Sube" and siguiente and Reglas.gemaDe(zona, siguiente) then
					rareza = siguiente
					gema = Reglas.gemaDe(zona, rareza)
				elseif r == "Efecto" then
					efecto = e
				end
			end
			clave = Reglas.claveGema(gema.Id, efecto)
			if Reglas.forjaConEscena(rarezaInicial, tamano) then
				t += ESCENA_FORJA
			end
		end
		vistas[zona] = vistas[zona] or {}
		vistas[zona][gema.Id] = true
		monedas += Reglas.unidades(tamano, modificador) * Reglas.valorGema(clave)

		-- Compras: lo que más sube el ingreso por moneda gastada.
		while true do
			local opciones = {}
			local precioF = Reglas.precioFuerza(nivel)
			if precioF then
				local ganancia = Reglas.fuerza(nivel + 1, pico) / fuerza
				table.insert(opciones, { Tipo = "Fuerza", Precio = precioF, Ganancia = ganancia })
			end
			local sigPico = GameConfig.Picos[pico + 1]
			if sigPico then
				local ganancia = sigPico.Multiplicador / GameConfig.Picos[pico].Multiplicador
				table.insert(
					opciones,
					{ Tipo = "Pico", Precio = sigPico.Precio, Ganancia = ganancia }
				)
			end
			local sigAmuleto = GameConfig.Amuletos[cantAmuletos + 1]
			if sigAmuleto then
				local sj = Reglas.suerteJugador(amuletos)
				local ganancia = rendimientoRareza(sj + sigAmuleto.Suerte) / rendimientoRareza(sj)
				table.insert(
					opciones,
					{ Tipo = "Amuleto", Precio = sigAmuleto.Precio, Ganancia = ganancia }
				)
			end
			-- Mejor relación: lo que suma de ingreso (en %) por cada moneda.
			local mejor = nil
			for _, o in opciones do
				o.Puntaje = (o.Ganancia - 1) / o.Precio
				if not mejor or o.Puntaje > mejor.Puntaje then
					mejor = o
				end
			end
			if not mejor or mejor.Precio > monedas then
				break
			end
			monedas -= mejor.Precio
			if mejor.Tipo == "Fuerza" then
				nivel += 1
				if nivel % 25 == 0 then
					anotar("Fuerza nivel " .. nivel, t)
				end
			elseif mejor.Tipo == "Pico" then
				pico += 1
				anotar(GameConfig.Picos[pico].Nombre, t)
			else
				cantAmuletos += 1
				amuletos[GameConfig.Amuletos[cantAmuletos].Id] = true
				anotar(GameConfig.Amuletos[cantAmuletos].Nombre, t)
			end
			fuerza = Reglas.fuerza(nivel, pico)
		end
	end
	if semilla == 1 then
		print(
			("Al final (%s): Fuerza %d (nivel %d, %s), suerte x%.2f, zona %d"):format(
				reloj(DURACION),
				Reglas.fuerza(nivel, pico),
				nivel,
				GameConfig.Picos[pico].Nombre,
				Reglas.suerteJugador(amuletos),
				zona
			)
		)
	end
end

print(
	("Ritmo: %g golpes por segundo, promedio de %d partidas"):format(GOLPES_POR_SEGUNDO, SEMILLAS)
)
table.sort(ordenHitos, function(a, b)
	local function media(n: string): number
		local s = 0
		for _, v in hitos[n] do
			s += v
		end
		return s / #hitos[n]
	end
	return media(a) < media(b)
end)
for _, nombre in ordenHitos do
	local lista = hitos[nombre]
	local s = 0
	for _, v in lista do
		s += v
	end
	local extra = if #lista < SEMILLAS
		then ("  (solo en %d de %d)"):format(#lista, SEMILLAS)
		else ""
	print(("  %-36s %s%s"):format(nombre, reloj(s / #lista), extra))
end
