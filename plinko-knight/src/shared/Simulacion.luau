--!strict
-- Física propia de la bola en 2D (sin Instances ni física de Roblox). Paso fijo y determinista:
-- mismo tablero + ángulo + semilla = mismo recorrido, en Studio y en Lune. El cliente la corre
-- para dibujar el tiro y el servidor la repite para revisar el daño (etapa 3).
--
-- El azar sale de un generador propio con semilla (xorshift de 32 bits) y no de Random.new:
-- Random no existe en Lune, y así las pruebas dan exactamente los mismos números que el juego.

local Config = require(script.Parent.Config)
local TableroModulo = require(script.Parent.Tablero)

type Tablero = TableroModulo.Tablero

export type Bola = {
	Radio: number,
	Velocidad: number,
}

-- Mejoras activas en el tiro. Todavía no cambian nada (llegan en la etapa 5).
export type Mejoras = { [string]: number }

export type Toque = {
	Clavija: number, -- Id de la clavija
	Paso: number, -- índice en el recorrido (1 = posición de salida)
}

export type Resultado = {
	X: { number }, -- posición de la bola en cada paso
	Y: { number },
	Toques: { Toque }, -- en orden; un toque nuevo cada vez que la bola vuelve a chocar una clavija
	ClavijasDistintas: number,
	Empujones: number, -- cuántas veces actuó el anti-trabas
	Fin: string, -- "abajo" (cruzó el borde de abajo) o "tope" (llegó al tiempo máximo)
}

local Simulacion = {}

local function nuevoAzar(semilla: number): () -> number
	local estado = math.floor(semilla) % 4294967296
	if estado == 0 then
		estado = 0x9E3779B9
	end
	return function(): number
		estado = bit32.bxor(estado, bit32.lshift(estado, 13))
		estado = bit32.bxor(estado, bit32.rshift(estado, 17))
		estado = bit32.bxor(estado, bit32.lshift(estado, 5))
		return estado / 4294967296
	end
end

-- Velocidad de salida para un ángulo en grados desde la vertical (positivo = a la derecha).
local function velocidadInicial(angulo: number, bola: Bola): (number, number)
	local a = math.rad(angulo)
	return math.sin(a) * bola.Velocidad, -math.cos(a) * bola.Velocidad
end

function Simulacion.limitarAngulo(angulo: number): number
	local tope = Config.Punteria.AnguloMaximo
	return math.clamp(angulo, -tope, tope)
end

function Simulacion.simular(
	tablero: Tablero,
	angulo: number,
	bola: Bola,
	_mejoras: Mejoras,
	semilla: number
): Resultado
	local s = Config.Simulacion
	local dt = s.Paso
	local azar = nuevoAzar(semilla)
	local r = bola.Radio
	local clavijas = tablero.Clavijas

	local x, y = tablero.LanzadorX, tablero.LanzadorY
	local vx, vy = velocidadInicial(Simulacion.limitarAngulo(angulo), bola)

	local xs, ys = { x }, { y }
	local toques: { Toque } = {}
	local tocando: { [number]: boolean } = {}
	local tocadas: { [number]: boolean } = {}
	local distintas = 0
	local empujones = 0
	local fin = "tope"

	local pasosMaximos = math.floor(s.TiempoMaximo / dt)
	local pasosTraba = math.floor(s.TiempoTraba / dt)
	local yVentana = y
	local desvioMaximo = math.rad(s.Desvio)

	for paso = 1, pasosMaximos do
		vy -= s.Gravedad * dt
		x += vx * dt
		y += vy * dt

		-- Clavijas: sacar la bola hacia afuera y rebotar.
		for _, c in clavijas do
			local dx, dy = x - c.X, y - c.Y
			local minimo = r + c.Radio
			local d2 = dx * dx + dy * dy
			if d2 < minimo * minimo then
				local d = math.sqrt(d2)
				local nx, ny
				if d > 1e-6 then
					nx, ny = dx / d, dy / d
				else
					nx, ny = 0, 1
				end
				x, y = c.X + nx * minimo, c.Y + ny * minimo
				local vn = vx * nx + vy * ny
				if vn < 0 then
					local tx, ty = vx - vn * nx, vy - vn * ny
					vx = tx * (1 - s.Friccion) - vn * s.Restitucion * nx
					vy = ty * (1 - s.Friccion) - vn * s.Restitucion * ny
					-- Un desvío chico con la semilla: el mismo ángulo no da siempre el mismo tiro
					-- en turnos distintos, y la bola no queda quieta en equilibrio arriba de una clavija.
					local giro = (azar() * 2 - 1) * desvioMaximo
					local cg, sg = math.cos(giro), math.sin(giro)
					vx, vy = vx * cg - vy * sg, vx * sg + vy * cg
				end
				if not tocando[c.Id] then
					tocando[c.Id] = true
					table.insert(toques, { Clavija = c.Id, Paso = paso + 1 })
					if not tocadas[c.Id] then
						tocadas[c.Id] = true
						distintas += 1
					end
				end
			elseif tocando[c.Id] and d2 > (minimo + 0.05) ^ 2 then
				tocando[c.Id] = nil
			end
		end

		-- Paredes y techo.
		if x - r < tablero.ParedIzquierda then
			x = tablero.ParedIzquierda + r
			if vx < 0 then
				vx = -vx * s.Restitucion
			end
		elseif x + r > tablero.ParedDerecha then
			x = tablero.ParedDerecha - r
			if vx > 0 then
				vx = -vx * s.Restitucion
			end
		end
		if y + r > tablero.Techo and vy > 0 then
			y = tablero.Techo - r
			vy = -vy * s.Restitucion
		end

		-- Tope de velocidad.
		local v2 = vx * vx + vy * vy
		if v2 > s.VelocidadMaxima * s.VelocidadMaxima then
			local k = s.VelocidadMaxima / math.sqrt(v2)
			vx *= k
			vy *= k
		end

		-- Anti-trabas: si en TiempoTraba casi no bajó, un empujón chico hacia abajo.
		if paso % pasosTraba == 0 then
			if yVentana - y < s.BajadaMinima then
				vx += (azar() * 2 - 1) * s.Empujon * 0.5
				vy -= s.Empujon
				empujones += 1
			end
			yVentana = y
		end

		table.insert(xs, x)
		table.insert(ys, y)

		if y < tablero.Fondo then
			fin = "abajo"
			break
		end
	end

	return {
		X = xs,
		Y = ys,
		Toques = toques,
		ClavijasDistintas = distintas,
		Empujones = empujones,
		Fin = fin,
	}
end

-- Puntos de la línea de puntería: solo el primer tramo, en vuelo libre (sin choques).
function Simulacion.primerTramo(
	tablero: Tablero,
	angulo: number,
	bola: Bola
): { { X: number, Y: number } }
	local p = Config.Punteria
	local g = Config.Simulacion.Gravedad
	local vx, vy = velocidadInicial(Simulacion.limitarAngulo(angulo), bola)
	local puntos = {}
	for i = 1, p.PuntosLinea do
		local t = p.DuracionLinea * i / p.PuntosLinea
		table.insert(puntos, {
			X = tablero.LanzadorX + vx * t,
			Y = tablero.LanzadorY + vy * t - g * t * t / 2,
		})
	end
	return puntos
end

return Simulacion
