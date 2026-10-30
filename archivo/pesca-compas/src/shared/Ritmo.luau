--!strict
-- Lógica pura de la pesca (sin servicios de Roblox, se puede probar con Lune).
-- El servidor la usa para sortear el pez y juzgar los toques; el cliente, para dibujar el
-- minijuego y dar feedback con la misma regla que después aplica el servidor.

local Config = require(script.Parent.Config)

export type Patron = {
	Tiempos: { number }, -- segundos desde la primera nota (la primera es 0)
	Alturas: { number }, -- semitonos sobre la nota base
	Duracion: number, -- segundo de la última nota
}

export type Calificacion = "Perfecto" | "Bien" | "Error"

export type Resultado = {
	Perfectos: number,
	Bien: number,
	Errores: number,
	Tension: number, -- 0 a 1, al terminar
	Sacado: boolean,
	Afinado: boolean,
	RachaMax: number,
	Desvios: { number }, -- toque - nota, de cada acierto (para vigilar bots)
}

-- Función que devuelve un número al azar en [0, 1).
export type Azar = () -> number

local Ritmo = {}

function Ritmo.rareza(id: string): Config.Rareza
	for _, r in Config.Rarezas do
		if r.Id == id then
			return r
		end
	end
	return Config.Rarezas[1]
end

function Ritmo.pezPorId(id: string): Config.Pez?
	for _, p in Config.Peces do
		if p.Id == id then
			return p
		end
	end
	return nil
end

-- Ventanas de acierto (Perfecto, Bien) en segundos según el nivel de la caña.
function Ritmo.ventanas(nivelCana: number): (number, number)
	local extra = (nivelCana - 1) * Config.VentanaPorNivel
	return math.min(Config.PerfectoBase + extra, Config.PerfectoTope), math.min(Config.BienBase + extra, Config.BienTope)
end

-- Rareza según las probabilidades fijas que se muestran en el muelle.
function Ritmo.sortearRareza(azar: Azar): string
	local r = azar()
	local acumulado = 0
	for _, rareza in Config.Rarezas do
		acumulado += rareza.Chance
		if r < acumulado then
			return rareza.Id
		end
	end
	return Config.Rarezas[1].Id
end

-- Un pez de esa rareza en la isla (nunca un jefe). Si no hay de esa rareza, uno común.
function Ritmo.sortearPez(isla: number, rareza: string, azar: Azar): Config.Pez
	local candidatos = {}
	for _, p in Config.Peces do
		if p.Isla == isla and p.Rareza == rareza and not p.Jefe then
			table.insert(candidatos, p)
		end
	end
	if #candidatos == 0 then
		if rareza ~= Config.Rarezas[1].Id then
			return Ritmo.sortearPez(isla, Config.Rarezas[1].Id, azar)
		end
		error("La isla " .. isla .. " no tiene peces comunes")
	end
	return candidatos[1 + math.floor(azar() * #candidatos)]
end

-- Generador fijo por pez: la misma melodía cada vez que sale (se aprende).
local function semilla(texto: string): () -> number
	local s = 17
	for i = 1, #texto do
		s = (s * 31 + string.byte(texto, i)) % 2147483647
	end
	return function()
		s = (s * 48271) % 2147483647
		return s / 2147483647
	end
end

function Ritmo.patron(pez: Config.Pez): Patron
	local n = #pez.Duraciones + 1
	local tiempos = { 0 }
	local t = 0
	for i, beats in pez.Duraciones do
		local bpm = pez.Bpm
		if pez.BpmFinal and i >= n / 2 then
			bpm = pez.BpmFinal
		end
		t += beats * 60 / bpm
		tiempos[i + 1] = t
	end
	local azar = semilla(pez.Id)
	local alturas = {}
	local grado = 3
	for i = 1, n do
		-- camina por la escala de a pasos chicos: suena a melodía, no a ruido
		grado = math.clamp(grado + math.floor(azar() * 5) - 2, 1, #Config.Escala)
		alturas[i] = Config.Escala[grado]
	end
	return { Tiempos = tiempos, Alturas = alturas, Duracion = t }
end

-- A qué nota corresponde un toque en el segundo t. Elige la nota libre más cercana dentro de
-- la ventana Bien. Devuelve (índice, calificación) o (nil, "Error") si no le toca a ninguna.
function Ritmo.clasificar(
	patron: Patron,
	usadas: { [number]: boolean },
	t: number,
	perfecto: number,
	bien: number
): (number?, Calificacion)
	local mejor: number? = nil
	local mejorDist = math.huge
	for i, nota in patron.Tiempos do
		local d = math.abs(t - nota)
		if not usadas[i] and d <= bien and d < mejorDist then
			mejor = i
			mejorDist = d
		end
	end
	if not mejor then
		return nil, "Error"
	end
	return mejor, if mejorDist <= perfecto then "Perfecto" else "Bien"
end

-- Cuánto mueve la barra cada calificación (N = cantidad de notas). Todo Perfecto = 100%.
function Ritmo.delta(calif: Calificacion, n: number): number
	if calif == "Perfecto" then
		return 0.5 / n
	elseif calif == "Bien" then
		return 0.25 / n
	end
	return -1 / n
end

-- Juzga todos los toques (segundos desde la primera nota, ya corregidos por la calibración).
-- Es la misma regla que el cliente aplica en vivo, así lo que ve el jugador coincide.
function Ritmo.juzgar(patron: Patron, toques: { number }, perfecto: number, bien: number, tensionInicial: number): Resultado
	local n = #patron.Tiempos
	local ordenados = table.clone(toques)
	table.sort(ordenados)

	-- eventos en orden de tiempo: cada toque y cada nota que pasó sin tocar
	local eventos: { { t: number, calif: Calificacion } } = {}
	local usadas: { [number]: boolean } = {}
	local desvios = {}
	for _, t in ordenados do
		local i, calif = Ritmo.clasificar(patron, usadas, t, perfecto, bien)
		if i then
			usadas[i] = true
			table.insert(desvios, t - patron.Tiempos[i])
		end
		table.insert(eventos, { t = t, calif = calif })
	end
	for i, nota in patron.Tiempos do
		if not usadas[i] then
			table.insert(eventos, { t = nota + bien, calif = "Error" })
		end
	end
	table.sort(eventos, function(a, b)
		return a.t < b.t
	end)

	local tension = tensionInicial
	local tocoCero = false
	local p, b, e = 0, 0, 0
	local racha, rachaMax = 0, 0
	for _, ev in eventos do
		tension = math.clamp(tension + Ritmo.delta(ev.calif, n), 0, 1)
		if tension <= 1e-9 then
			tocoCero = true
		end
		if ev.calif == "Error" then
			e += 1
			racha = 0
		else
			if ev.calif == "Perfecto" then
				p += 1
			else
				b += 1
			end
			racha += 1
			rachaMax = math.max(rachaMax, racha)
		end
	end

	local sacado = not tocoCero and tension > 0.5 + 1e-9
	return {
		Perfectos = p,
		Bien = b,
		Errores = e,
		Tension = tension,
		Sacado = sacado,
		Afinado = sacado and e == 0 and p / n >= Config.AfinadoPerfectos - 1e-9,
		RachaMax = rachaMax,
		Desvios = desvios,
	}
end

-- Peso en kg. Lanzar lejos (carga 0 a 1) da peces más pesados, nunca más raros.
function Ritmo.peso(pez: Config.Pez, carga: number, azar: Azar): number
	local base = pez.PesoMin + (pez.PesoMax - pez.PesoMin) * azar()
	local kg = base * (1 + Config.PesoPorCarga * math.clamp(carga, 0, 1))
	return math.floor(kg * 100 + 0.5) / 100
end

function Ritmo.precio(pez: Config.Pez, peso: number, afinado: boolean): number
	local valor = Ritmo.rareza(pez.Rareza).PrecioKg * peso * (if afinado then 2 else 1)
	return math.max(1, math.floor(valor + 0.5))
end

-- Nivel a partir de la XP total: (nivel, xp dentro del nivel, xp para el siguiente).
function Ritmo.nivel(xp: number): (number, number, number)
	local nivel = 1
	local resto = xp
	while resto >= Config.xpParaSubir(nivel) do
		resto -= Config.xpParaSubir(nivel)
		nivel += 1
	end
	return nivel, resto, Config.xpParaSubir(nivel)
end

return Ritmo
