--!strict
-- Física propia de la bola en 2D (sin Instances ni física de Roblox). Paso fijo y determinista:
-- mismo tablero + ángulo + semilla = mismo recorrido, en Studio y en Lune. El cliente la corre
-- para dibujar el tiro y el servidor la repite para revisar el daño (etapa 3).
--
-- El azar sale de shared/Azar (con semilla, no Random.new: Random no existe en Lune).
-- Paso 5a: el golpe es Fuerza × Multi. Cada clavija suma a una de las dos cajas según su tipo
-- (shared/Clavijas): gris y verde suman Fuerza, roja suma Multi, azul lo multiplica (y a veces
-- se rompe), dorada da oro y violeta hace que la próxima cuente varias veces. Los huecos no
-- existen para la bola. Las bolas de fuego y partida también pasan acá, así el servidor repite el
-- tiro igual. La bola partida se simula al mismo tiempo que la original, paso por paso, para que
-- los toques (y los × de las azules) queden en el orden en que pasan.
-- Paso 5c: las reliquias. Algunas cambian cada toque (rojas, azules, doradas, violetas, bolas
-- extra, Midas, Gemela); otras actúan al final del tiro, en el orden de la lista (de izquierda a
-- derecha): por eso importa si una suma Multi antes o después de otra que lo multiplica.
-- Paso 5d: las mañas de jefe que cambian el tiro (sangre fría, cristal maldito, paredes vivas,
-- silencio y viento). Las que cambian el turno (avaricia, coraza, rabia) están en Mazmorra.

local Azar = require(script.Parent.Azar)
local Config = require(script.Parent.Config)
local Clavijas = require(script.Parent.Clavijas)
local Reliquias = require(script.Parent.Reliquias)
local TableroModulo = require(script.Parent.Tablero)

type Tablero = TableroModulo.Tablero

export type Bola = {
	Radio: number,
	Velocidad: number,
}

-- Lo que cambia el tiro: el tablero de la partida (tipo de cada clavija), el nivel de cada tipo
-- y la bola elegida. {} = todo gris, nivel 1, bola de hierro. Lo pone el servidor.
export type Modificadores = {
	Tablero: Clavijas.TableroPartida?,
	Niveles: Clavijas.Niveles?,
	Bola: string?, -- "hierro", "fuego" o "partida"
	Furia: boolean?, -- pergamino Furia: el Multi se multiplica al final del tiro
	Reliquias: { Reliquias.Tenida }?, -- en orden, de izquierda a derecha
	Oro: number?, -- el que tenés antes del tiro (Avaro)
	Vida: number?, -- la del caballero (Último Aliento)
	TirosPelea: number?, -- tiros que ya hiciste en esta pelea (Paciencia)
	Mania: string?, -- la maña del jefe de esta pelea ("" o nil = ninguna)
}

-- Una reliquia que hizo algo al final del tiro (para que el cliente la sacuda y muestre el texto).
export type Activacion = {
	Lugar: number, -- en la lista de reliquias
	Id: string,
	Texto: string, -- "+6 Multi", "×2", "+30 Fuerza"…
}

export type Toque = {
	Clavija: number, -- Id de la clavija
	Paso: number, -- índice global del paso (1 = salida); para la bola 1 es su índice en X/Y
	Bola: number, -- qué bola la tocó (1 = la que tiraste; 2 o más = las de la división)
	Tipo: string, -- tipo de la clavija
	Veces: number, -- cuántas veces contó (más de 1 si venía de una violeta)
	Fuerza: number, -- lo que sumó a la Fuerza
	Multi: number, -- lo que sumó al Multi
	PorMulti: number, -- por cuánto multiplicó el Multi (1 = nada)
	Oro: number,
	Rota: boolean, -- era azul y se rompió
	FuerzaTotal: number, -- cómo quedaron las cajas después de este toque
	MultiTotal: number,
}

-- El camino de una bola. X[1] es su posición en el paso global Inicio.
export type Recorrido = {
	X: { number },
	Y: { number },
	Inicio: number,
}

export type Resultado = {
	X: { number }, -- posición de la bola que tiraste en cada paso (= Recorridos[1])
	Y: { number },
	Recorridos: { Recorrido }, -- uno por bola (más de uno si se dividió)
	Pasos: number, -- índice global del último paso (cuando cayó la última bola)
	-- En orden. Cada bola suma cada clavija una sola vez (la segunda vez rebota pero no suma).
	Toques: { Toque },
	ClavijasDistintas: number, -- toques que sumaron (de todas las bolas)
	Fuerza: number,
	Multi: number,
	Danio: number, -- el golpe: Fuerza × Multi, para abajo (con tope Config.TopeDanioTiro)
	Oro: number, -- el que dieron las doradas
	Rotas: { number }, -- azules que se rompieron (el servidor las vuelve hueco después del tiro)
	Quemadura: number, -- daño por turno que deja la bola de fuego (0 sin fuego)
	Fuego: boolean,
	Furia: number, -- por cuánto multiplicó la furia al final (1 = no había)
	Activaciones: { Activacion }, -- reliquias que actuaron al final, en orden
	Paciencia: boolean, -- el golpe fue 0 por la reliquia Paciencia (primer tiro de la pelea)
	Empujones: number, -- cuántas veces actuó el anti-trabas
	Fin: string, -- "abajo" (cayeron todas) o "tope" (llegó al tiempo máximo)
}

-- Una bola en juego, durante la simulación.
type Viva = {
	x: number,
	y: number,
	vx: number,
	vy: number,
	recorrido: Recorrido,
	tocando: { [number]: boolean }, -- clavijas que está tocando ahora
	tocadas: { [number]: boolean }, -- clavijas que ya sumó esta bola
	toques: number,
	puedeDividir: boolean,
	toqueDividir: number, -- en qué toque se parte (si puedeDividir)
	eco: number, -- cuántas veces cuenta la próxima clavija (1 = normal)
	yVentana: number,
	activa: boolean,
}

local Simulacion = {}

-- Velocidad de salida para un ángulo en grados desde la vertical (positivo = a la derecha).
local function velocidadInicial(angulo: number, bola: Bola): (number, number)
	local a = math.rad(angulo)
	return math.sin(a) * bola.Velocidad, -math.cos(a) * bola.Velocidad
end

local function girar(vx: number, vy: number, angulo: number): (number, number)
	local c, s = math.cos(angulo), math.sin(angulo)
	return vx * c - vy * s, vx * s + vy * c
end

function Simulacion.limitarAngulo(angulo: number): number
	local tope = Config.Punteria.AnguloMaximo
	return math.clamp(angulo, -tope, tope)
end

function Simulacion.simular(
	tablero: Tablero,
	angulo: number,
	bola: Bola,
	mods: Modificadores,
	semilla: number
): Resultado
	local s = Config.Simulacion
	local dt = s.Paso
	local azar = Azar.nuevo(semilla)
	local r = bola.Radio
	local clavijas = tablero.Clavijas

	-- Tablero de la partida, niveles y bola.
	local tipos: { [number]: string } = {}
	for _, c in clavijas do
		tipos[c.Id] = Clavijas.tipo(mods.Tablero, c.Id)
	end
	local niveles = mods.Niveles
	local nombreBola = mods.Bola or "hierro"
	local fuego = nombreBola == "fuego"
	local fuerzaExtra = if fuego then Config.Bolas.fuego.FuerzaExtra else 0
	local divide = Config.Bolas.partida
	local impulso = Config.Clavijas.verde.Impulso

	-- Maña del jefe.
	local mania = mods.Mania or ""
	-- Paredes vivas: la primera y la última clavija de cada fila no cuentan (rebotan igual).
	local costados: { [number]: boolean } = {}
	if mania == "paredesVivas" then
		local porFila: { [number]: { number } } = {}
		for _, c in clavijas do
			porFila[c.Fila] = porFila[c.Fila] or {}
			table.insert(porFila[c.Fila], c.Id)
		end
		for _, ids in porFila do
			table.sort(ids, function(a: number, b: number): boolean
				return clavijas[a].X < clavijas[b].X
			end)
			costados[ids[1]] = true
			costados[ids[#ids]] = true
		end
	end

	-- Reliquias que cambian cada toque. Con Silencio, la de la izquierda no existe en este tiro.
	local lista = mods.Reliquias or {}
	if mania == "silencio" and #lista > 0 then
		lista = table.clone(lista)
		table.remove(lista, 1)
	end
	local R = Config.Reliquias
	local tiene = function(id: string): boolean
		return Reliquias.tiene(lista, id)
	end
	local gemela = tiene("gemela")
	local factorRojas = if tiene("rubi") then R.rubi.Factor else 1
	local factorExtra = if tiene("hoja") then R.hoja.Factor else 1
	local porDoradas = if tiene("toqueOro") then R.toqueOro.PorMulti else 1
	local vidrio = tiene("vidrio")
	local rotura = if mania == "cristalMaldito"
		then 1
		elseif vidrio then R.vidrio.Rotura
		else Config.Clavijas.azul.Rotura
	local ecoMinimo = if tiene("ecoInfinito") then R.ecoInfinito.Veces else 0
	local oroMidas = if tiene("midas") then R.midas.Oro else 0
	-- En qué toque se parte la bola que tirás: la partida en el suyo; si no, Gemela.
	local toquePrimera: number? = if nombreBola == "partida"
		then divide.ToqueParaDividir
		elseif gemela then R.gemela.Toque
		else nil

	local fuerza = Config.Danio.FuerzaInicial
	local multi = Config.Danio.MultiInicial
	local oro = 0
	local rotas: { number } = {}
	local rotasEnTiro: { [number]: boolean } = {}

	local function nuevaBola(x: number, y: number, vx: number, vy: number, inicio: number): Viva
		return {
			x = x,
			y = y,
			vx = vx,
			vy = vy,
			recorrido = { X = {}, Y = {}, Inicio = inicio },
			tocando = {},
			tocadas = {},
			toques = 0,
			puedeDividir = false,
			toqueDividir = 0,
			eco = 1,
			yVentana = y,
			activa = true,
		}
	end

	local vx0, vy0 = velocidadInicial(Simulacion.limitarAngulo(angulo), bola)
	if mania == "viento" then
		vx0 *= Config.Manias.viento.Velocidad
		vy0 *= Config.Manias.viento.Velocidad
	end
	local primera = nuevaBola(tablero.LanzadorX, tablero.LanzadorY, vx0, vy0, 1)
	table.insert(primera.recorrido.X, primera.x)
	table.insert(primera.recorrido.Y, primera.y)
	if toquePrimera then
		primera.puedeDividir = true
		primera.toqueDividir = toquePrimera
	end
	local bolas: { Viva } = { primera }
	local activas = 1

	local toques: { Toque } = {}
	local distintas = 0
	local empujones = 0
	local fin = "tope"
	local ultimoPaso = 1

	local pasosMaximos = math.floor(s.TiempoMaximo / dt)
	local pasosTraba = math.floor(s.TiempoTraba / dt)
	local desvioMaximo = math.rad(s.Desvio) * (if mania == "viento" then Config.Manias.viento.Desvio else 1)

	-- La bola se parte: ella y las nuevas salen abiertas en abanico desde el mismo punto.
	local function dividir(b: Viva, paso: number, clavija: number)
		b.puedeDividir = false
		local partes = math.min(divide.Partes, Config.TopeBolas - #bolas + 1)
		if partes < 2 then
			return
		end
		local abertura = math.rad(divide.AnguloDivision + (azar() * 2 - 1) * divide.AnguloAzar)
		local signo = if azar() < 0.5 then -1 else 1
		local vx, vy = b.vx, b.vy
		for k = 0, partes - 1 do
			local nvx, nvy = girar(vx, vy, signo * abertura * (k - (partes - 1) / 2))
			if k == 0 then
				b.vx, b.vy = nvx, nvy
			else
				local nueva = nuevaBola(b.x, b.y, nvx, nvy, paso + 1)
				-- La clavija donde se partió ya la tocó: no suma de nuevo enseguida.
				nueva.tocando[clavija] = true
				nueva.tocadas[clavija] = true
				-- Con Gemela, las bolas nuevas también se parten (hasta el tope de bolas).
				if gemela then
					nueva.puedeDividir = true
					nueva.toqueDividir = R.gemela.Toque
				end
				table.insert(bolas, nueva)
				activas += 1
			end
		end
	end

	for paso = 1, pasosMaximos do
		local cantidad = #bolas -- las que nacen en este paso se mueven desde el siguiente
		for indice = 1, cantidad do
			local b = bolas[indice]
			if not b.activa then
				continue
			end
			b.vy -= s.Gravedad * dt
			b.x += b.vx * dt
			b.y += b.vy * dt

			-- Clavijas: sacar la bola hacia afuera y rebotar. Los huecos no existen.
			for _, c in clavijas do
				local tipo = tipos[c.Id]
				if tipo == "hueco" then
					continue
				end
				local dx, dy = b.x - c.X, b.y - c.Y
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
					b.x, b.y = c.X + nx * minimo, c.Y + ny * minimo
					local vn = b.vx * nx + b.vy * ny
					if vn < 0 then
						local tx, ty = b.vx - vn * nx, b.vy - vn * ny
						b.vx = tx * (1 - s.Friccion) - vn * s.Restitucion * nx
						b.vy = ty * (1 - s.Friccion) - vn * s.Restitucion * ny
						-- Un desvío chico con la semilla: el mismo ángulo no da siempre el mismo tiro
						-- en turnos distintos, y la bola no queda quieta en equilibrio arriba de una clavija.
						b.vx, b.vy = girar(b.vx, b.vy, (azar() * 2 - 1) * desvioMaximo)
					end
					if not b.tocando[c.Id] then
						b.tocando[c.Id] = true
						if not b.tocadas[c.Id] and not costados[c.Id] then
							b.tocadas[c.Id] = true
							b.toques += 1
							distintas += 1
							local nivel = Clavijas.nivel(niveles, tipo)
							local veces = b.eco
							b.eco = 1
							local fuerzaToque = Clavijas.fuerza(tipo, nivel) + fuerzaExtra
							local multiToque = Clavijas.multi(tipo, nivel)
							local porToque = Clavijas.porMulti(tipo, nivel)
							local oroToque = Clavijas.oro(tipo, nivel)
							if tipo == "roja" then
								multiToque *= if mania == "sangreFria" then 0 else factorRojas
							elseif tipo == "dorada" then
								porToque *= porDoradas
							elseif tipo == "azul" and vidrio then
								porToque = R.vidrio.PorMulti + (porToque - Clavijas.porMulti("azul", 1))
							end
							if indice > 1 then
								fuerzaToque *= factorExtra
							else
								oroToque += oroMidas
							end
							local sumaF = fuerzaToque * veces
							local sumaM = multiToque * veces
							local por = porToque ^ veces
							local sumaOro = oroToque * veces
							fuerza += sumaF
							multi = math.min((multi + sumaM) * por, Config.TopeMulti)
							oro += sumaOro
							local eco = Clavijas.eco(tipo, nivel)
							if eco > 0 and ecoMinimo > eco then
								eco = ecoMinimo + (eco - Clavijas.eco("violeta", 1))
							end
							if eco > 0 then
								b.eco = eco
							end
							if tipo == "verde" then
								-- Resorte: la bola sale disparada hacia afuera de la clavija.
								b.vx += nx * impulso
								b.vy += ny * impulso
							end
							local rota = false
							if tipo == "azul" and not rotasEnTiro[c.Id] and azar() < rotura then
								rotasEnTiro[c.Id] = true
								table.insert(rotas, c.Id)
								rota = true
							end
							table.insert(toques, {
								Clavija = c.Id,
								Paso = paso + 1,
								Bola = indice,
								Tipo = tipo,
								Veces = veces,
								Fuerza = sumaF,
								Multi = sumaM,
								PorMulti = por,
								Oro = sumaOro,
								Rota = rota,
								FuerzaTotal = fuerza,
								MultiTotal = multi,
							})
							if b.puedeDividir and b.toques == b.toqueDividir then
								dividir(b, paso, c.Id)
							end
						end
					end
				elseif b.tocando[c.Id] and d2 > (minimo + 0.05) ^ 2 then
					b.tocando[c.Id] = nil
				end
			end

			-- Paredes y techo.
			if b.x - r < tablero.ParedIzquierda then
				b.x = tablero.ParedIzquierda + r
				if b.vx < 0 then
					b.vx = -b.vx * s.Restitucion
				end
			elseif b.x + r > tablero.ParedDerecha then
				b.x = tablero.ParedDerecha - r
				if b.vx > 0 then
					b.vx = -b.vx * s.Restitucion
				end
			end
			if b.y + r > tablero.Techo and b.vy > 0 then
				b.y = tablero.Techo - r
				b.vy = -b.vy * s.Restitucion
			end

			-- Tope de velocidad.
			local v2 = b.vx * b.vx + b.vy * b.vy
			if v2 > s.VelocidadMaxima * s.VelocidadMaxima then
				local k = s.VelocidadMaxima / math.sqrt(v2)
				b.vx *= k
				b.vy *= k
			end

			-- Anti-trabas: si en TiempoTraba casi no bajó, un empujón chico hacia abajo.
			if paso % pasosTraba == 0 then
				if b.yVentana - b.y < s.BajadaMinima then
					b.vx += (azar() * 2 - 1) * s.Empujon * 0.5
					b.vy -= s.Empujon
					empujones += 1
				end
				b.yVentana = b.y
			end

			table.insert(b.recorrido.X, b.x)
			table.insert(b.recorrido.Y, b.y)

			if b.y < tablero.Fondo then
				b.activa = false
				activas -= 1
			end
		end

		-- Las que nacieron en este paso arrancan su recorrido acá (en el punto donde se partió).
		for indice = cantidad + 1, #bolas do
			local b = bolas[indice]
			table.insert(b.recorrido.X, b.x)
			table.insert(b.recorrido.Y, b.y)
		end

		ultimoPaso = paso + 1
		if activas == 0 then
			fin = "abajo"
			break
		end
	end

	-- Reliquias al final del tiro, de izquierda a derecha.
	local activaciones: { Activacion } = {}
	local paciencia = false
	local function activar(lugar: number, id: string, texto: string)
		table.insert(activaciones, { Lugar = lugar, Id = id, Texto = texto })
	end
	local function corto(n: number): string
		return Clavijas.numeroCorto(n)
	end
	for lugar, tenida in lista do
		local id = tenida.Id
		local d = R[id]
		if id == "brasa" then
			local rojas = 0
			for _, tipo in tipos do
				if tipo == "roja" then
					rojas += 1
				end
			end
			if rojas > 0 then
				multi += rojas * d.MultiPorRoja
				activar(lugar, id, ("+%s Multi"):format(corto(rojas * d.MultiPorRoja)))
			end
		elseif id == "martillo" then
			if distintas >= d.Clavijas then
				fuerza += d.Fuerza
				activar(lugar, id, ("+%d Fuerza"):format(d.Fuerza))
			end
		elseif id == "cadena" then
			local suma = math.floor(distintas / d.Cada) * d.Multi
			if suma > 0 then
				multi += suma
				activar(lugar, id, ("+%d Multi"):format(suma))
			end
		elseif id == "enjambre" then
			local extra = #bolas - 1
			if extra > 0 then
				local factor = d.PorBola ^ extra
				multi *= factor
				activar(lugar, id, "×" .. corto(factor))
			end
		elseif id == "avaro" then
			local suma = math.floor((mods.Oro or 0) / d.Cada) * d.Multi
			if suma > 0 then
				multi += suma
				activar(lugar, id, ("+%d Multi"):format(suma))
			end
		elseif id == "trofeo" then
			if tenida.Contador > 0 then
				multi += tenida.Contador * d.Multi
				activar(lugar, id, ("+%d Multi"):format(tenida.Contador * d.Multi))
			end
		elseif id == "callo" then
			if tenida.Contador > 0 then
				fuerza += tenida.Contador * d.Fuerza
				activar(lugar, id, ("+%d Fuerza"):format(tenida.Contador * d.Fuerza))
			end
		elseif id == "racha" then
			if tenida.Contador > 0 then
				local factor = 1 + tenida.Contador * d.PorPelea
				multi *= factor
				activar(lugar, id, "×" .. corto(factor))
			end
		elseif id == "aliento" then
			if (mods.Vida or math.huge) < d.Vida then
				multi *= d.Factor
				activar(lugar, id, ("×%d"):format(d.Factor))
			end
		elseif id == "paciencia" then
			local tiros = mods.TirosPelea or 0
			if tiros == 0 then
				paciencia = true
				activar(lugar, id, "espera…")
			elseif tiros == 1 then
				multi *= d.Factor
				activar(lugar, id, ("×%d"):format(d.Factor))
			end
		elseif id == "corona" then
			multi *= d.Factor
			activar(lugar, id, ("×%d"):format(d.Factor))
		end
		multi = math.min(multi, Config.TopeMulti)
	end

	-- Pergamino Furia: al final del tiro, el Multi se multiplica.
	local furia = if mods.Furia then Config.Pergaminos.furia.PorMulti else 1
	multi = math.min(multi * furia, Config.TopeMulti)

	-- Quemadura de la bola de fuego (con Yesca, tanto como el Multi).
	local quemadura = 0
	if fuego then
		quemadura = Config.Bolas.fuego.Quemadura
		local lugarYesca = 0
		for lugar, tenida in lista do
			if tenida.Id == "yesca" then
				lugarYesca = lugar
			end
		end
		if lugarYesca > 0 and multi > quemadura then
			quemadura = math.floor(multi)
			activar(lugarYesca, "yesca", ("quema %s"):format(corto(quemadura)))
		end
	end

	local recorridos: { Recorrido } = {}
	for _, b in bolas do
		table.insert(recorridos, b.recorrido)
	end

	return {
		X = primera.recorrido.X,
		Y = primera.recorrido.Y,
		Recorridos = recorridos,
		Pasos = ultimoPaso,
		Toques = toques,
		ClavijasDistintas = distintas,
		Fuerza = fuerza,
		Multi = multi,
		Danio = if paciencia then 0 else math.min(math.floor(fuerza * multi), Config.TopeDanioTiro),
		Oro = oro,
		Rotas = rotas,
		Quemadura = quemadura,
		Fuego = fuego,
		Furia = furia,
		Activaciones = activaciones,
		Paciencia = paciencia,
		Empujones = empujones,
		Fin = fin,
	}
end

-- Puntos de la línea de puntería: solo el primer tramo, en vuelo libre (sin choques).
function Simulacion.primerTramo(tablero: Tablero, angulo: number, bola: Bola): { { X: number, Y: number } }
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
