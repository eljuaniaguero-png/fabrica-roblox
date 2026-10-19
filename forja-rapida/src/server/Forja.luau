--!strict
-- La Forja: al romper una geoda, la piedra no entra a la mochila en el acto. Queda "pendiente"
-- (Datos.ForjaPendiente) y el jugador gasta monedas "?" para intentar mejorarla: cada intento
-- puede subirla 1 rareza, ponerle un efecto (Oro, Sombra, Fuego, Diamante, Arcoíris) o nada.
-- Números en GameConfig.Forja; la tirada es Reglas.intentoForja.
--
-- El servidor decide todo:
--   Remotos.ForjaIntentar (Id, Cantidad?)  1 o GameConfig.Forja.Lote ("Forjar x5"); revisa que la piedra sea suya, que le queden monedas "?" (de la
--                               geoda o guardadas), el tiempo y el freno; tira él y contesta.
--   Remotos.ForjaListo (Id)     se queda con la piedra como está.
-- Se entrega UNA sola vez (primero se borra la pendiente, después se suma a la mochila) cuando:
-- se gastan todas las monedas, aprieta Listo, pasan GameConfig.Forja.Vence segundos sin
-- apretar, rompe otra geoda, o se va del juego. Así no se duplica ni se pierde.
-- La escena es solo para Épica o mejor, la Jefe y la Ancestral (Reglas.forjaConEscena). En las
-- demás las monedas "?" se usan solas al romper y se entrega enseguida, para no frenar la
-- minería (con escena en cada Rara el juego iba 2 veces más lento; pruebas/simular).
-- Al entregar pasa todo lo de antes con la piedra final: mochila, Museo, logros, anuncio a
-- todos, misiones y eventos (Mundo.avisarRevelacion), y la tarjeta (Remotos.Revelacion).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Descubrimientos = require(script.Parent.Descubrimientos)
local Economia = require(script.Parent.Economia)
local Jugadores = require(script.Parent.Jugadores)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

local F = GameConfig.Forja
local rng = Random.new()
local function azar(): number
	return rng:NextNumber()
end

-- Lo que se le manda a cada jugador al romper una geoda (Remotos.Revelacion).
export type Revelacion = {
	Geoda: Model?,
	Gema: string,
	Rareza: string,
	Unidades: number,
	Modificador: string,
	Suerte: number, -- la suerte con la que se tiró (jugador x zona x tamaño)
	UnoEn: number, -- qué tan rara es con esa suerte: "1 en N"
	Nueva: boolean, -- primera vez que la consigue (Índice)
	Hitos: { Descubrimientos.Hito },
	Efecto: string?, -- La Forja: efecto que ganó
	Subio: number, -- La Forja: rarezas que subió
}

-- Lo que ve el cliente de la forja en curso (Remotos.Forja).
export type Estado = {
	Id: number,
	Gema: string,
	Rareza: string,
	Efecto: string?,
	Quedan: number,
	Guardadas: number,
	UnoEn: number,
	Zona: number,
	Geoda: Model?,
	Resultado: string?, -- "Sube" | "Efecto" | "Nada" (solo en "Resultado"; en lote, el mejor)
	Gastadas: number?, -- monedas "?" que gastó el pedido (solo en "Resultado")
}

-- Lo que trae la geoda rota para empezar.
export type Inicio = {
	Gema: string,
	Rareza: string,
	Zona: number,
	Secreta: boolean,
	Unidades: number,
	Intentos: number,
	Geoda: Model?,
	Modificador: string,
	Suerte: number,
	Tamano: string,
}

local function rarezaIndice(id: string): number
	for i, r in GameConfig.Rarezas do
		if r.Id == id then
			return i
		end
	end
	return 0
end
local RAREZA_ANUNCIO = rarezaIndice(GameConfig.Anuncios.RarezaMinima)

local function unoEn(rareza: string, suerte: number): number
	local chance = Reglas.probabilidades(GameConfig.Rarezas, suerte)[rareza] or 0
	return if chance > 0 then math.max(1, math.floor(1 / chance + 0.5)) else 0
end

local proximoId = 0
local Forja = {}

local function estado(d: Jugadores.Datos, p: Jugadores.Pendiente, resultado: string?): Estado
	return {
		Id = p.Id,
		Gema = p.Gema,
		Rareza = p.Rareza,
		Efecto = p.Efecto,
		Quedan = p.Quedan,
		Guardadas = d.FichasForja,
		UnoEn = unoEn(p.Rareza, p.Suerte),
		Zona = p.Zona,
		Geoda = p.Geoda,
		Resultado = resultado,
	}
end

-- Entrega la piedra pendiente (una sola vez) y hace todo lo que antes pasaba al romper.
function Forja.entregar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	local p = d and d.ForjaPendiente
	if not d or not p then
		return
	end
	d.ForjaPendiente = nil -- primero se borra, después se entrega: nunca dos veces
	local nueva = Jugadores.agregarGema(jugador, p.Gema, p.Unidades, p.Efecto)
	if nueva then
		Economia.revisarZonas(jugador) -- una gema nueva puede cumplir el requisito de colección
	end
	local hitos = Descubrimientos.registrar(jugador, p.Modificador, p.Rareza)
	local uno = unoEn(p.Rareza, p.Suerte)
	local gema = Reglas.gema(p.Gema)
	local r = Reglas.rareza(p.Rareza)
	if gema and r and rarezaIndice(p.Rareza) >= RAREZA_ANUNCIO then
		local e = if p.Efecto then Reglas.efectoForja(p.Efecto) else nil
		Anuncios.enviar(
			("¡%s encontró %s%s (%s)%s!"):format(
				jugador.DisplayName,
				gema.Nombre,
				if e then " " .. e.Nombre else "",
				r.Nombre,
				if p.Subio > 0 then ", ¡forjada!" else ""
			),
			r.Color,
			"Hallazgo",
			jugador
		)
	end
	if p.Usados > 0 then
		Remotos.Forja:FireClient(jugador, "Fin", estado(d, p, nil))
	end
	local revelacion: Revelacion = {
		Geoda = p.Geoda,
		Gema = p.Gema,
		Rareza = p.Rareza,
		Unidades = p.Unidades,
		Modificador = p.Modificador,
		Suerte = p.Suerte,
		UnoEn = uno,
		Nueva = nueva,
		Hitos = hitos,
		Efecto = p.Efecto,
		Subio = p.Subio,
	}
	Remotos.Revelacion:FireClient(jugador, revelacion)
	Mundo.avisarRevelacion({
		Jugador = jugador,
		Gema = p.Gema,
		Rareza = p.Rareza,
		UnoEn = uno,
		Modificador = p.Modificador,
		Unidades = p.Unidades,
	})
end

-- Tira un intento sobre la pendiente (ya validado). Devuelve el resultado.
local function tirar(p: Jugadores.Pendiente): string
	local puedeSubir = not p.Secreta and Reglas.rarezaSiguiente(p.Rareza) ~= nil
	local resultado, efecto = Reglas.intentoForja(p.Rareza, p.Efecto ~= nil, puedeSubir, azar)
	if resultado == "Sube" then
		local siguiente = Reglas.rarezaSiguiente(p.Rareza) :: string
		local gema = Reglas.gemaDe(p.Zona, siguiente, azar)
		if gema then
			p.Rareza, p.Gema = siguiente, gema.Id
			p.Subio += 1
		else
			resultado = "Nada" -- la zona no tiene esa rareza: no se pierde nada
		end
	elseif resultado == "Efecto" then
		p.Efecto = efecto
	end
	p.Usados += 1
	return resultado
end

-- Una geoda se rompió: la piedra queda pendiente (o, si es Común con 1 moneda, se tira sola).
function Forja.empezar(jugador: Player, i: Inicio)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	Forja.entregar(jugador) -- si había otra a medias, se entrega como estaba
	proximoId += 1
	local ahora = os.clock()
	local p: Jugadores.Pendiente = {
		Id = proximoId,
		Gema = i.Gema,
		Rareza = i.Rareza,
		Efecto = nil,
		Zona = i.Zona,
		Secreta = i.Secreta,
		Unidades = i.Unidades,
		Quedan = i.Intentos,
		Usados = 0,
		Subio = 0,
		Vence = ahora + F.Vence,
		Ultimo = 0,
		Geoda = i.Geoda,
		Modificador = i.Modificador,
		Suerte = i.Suerte,
	}
	d.ForjaPendiente = p
	if not Reglas.forjaConEscena(i.Rareza, i.Tamano) then
		-- sin escena (Común, Rara): sus monedas "?" se usan solas y se entrega al toque
		while p.Quedan > 0 do
			p.Quedan -= 1
			tirar(p)
		end
		Forja.entregar(jugador)
		return
	end
	Remotos.Forja:FireClient(jugador, "Empieza", estado(d, p, nil))
end

local PESO_RESULTADO = { Nada = 0, Efecto = 1, Sube = 2 }

local function alIntentar(jugador: Player, id: unknown, cantidad: unknown)
	local d = Jugadores.obtener(jugador)
	local p = d and d.ForjaPendiente
	if not d or not p or typeof(id) ~= "number" or id ~= p.Id then
		return
	end
	local n = if cantidad == F.Lote then F.Lote else 1
	local ahora = os.clock()
	if ahora > p.Vence or ahora - p.Ultimo < F.Espera then
		return
	end
	local mejor: string? = nil
	local gastadas = 0
	for _ = 1, n do
		if p.Quedan > 0 then
			p.Quedan -= 1
		elseif d.FichasForja > 0 then
			d.FichasForja -= 1 -- se descuenta en el mismo paso que el intento
		else
			break
		end
		gastadas += 1
		local r = tirar(p)
		if not mejor or PESO_RESULTADO[r] > PESO_RESULTADO[mejor] then
			mejor = r
		end
	end
	if not mejor then
		return
	end
	p.Ultimo = ahora
	p.Vence = ahora + F.Vence
	Jugadores.publicar(jugador)
	local e = estado(d, p, mejor)
	e.Gastadas = gastadas
	Remotos.Forja:FireClient(jugador, "Resultado", e)
	if p.Quedan <= 0 and d.FichasForja <= 0 then
		-- sin monedas: se entrega cuando el cliente termina la animación (o al vencer)
		p.Vence = ahora + 3
	end
end

local function alListo(jugador: Player, id: unknown)
	local d = Jugadores.obtener(jugador)
	local p = d and d.ForjaPendiente
	if p and typeof(id) == "number" and id == p.Id then
		Forja.entregar(jugador)
	end
end

-- Suma monedas "?" guardadas (misiones, renacer, fundir), hasta el tope (con Fragua Amplia).
function Forja.sumarFichas(jugador: Player, cantidad: number)
	local d = Jugadores.obtener(jugador)
	if not d or cantidad <= 0 then
		return
	end
	d.FichasForja = math.min(Jugadores.bonos(d).TopeForja, d.FichasForja + cantidad)
	Jugadores.publicar(jugador)
end

-- Fundir: una gema Legendaria o mejor de la mochila se cambia por monedas "?" guardadas
-- (GameConfig.Forja.Fundir). Revisa que la tenga, que la rareza se pueda fundir, el tope y el freno.
local ultimoFundir: { [Player]: number } = {}
local function alFundir(jugador: Player, clave: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(clave) ~= "string" or (d.Mochila[clave] or 0) <= 0 then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimoFundir[jugador] or 0) < 0.2 then
		return
	end
	ultimoFundir[jugador] = ahora
	local gema = Reglas.gema((Reglas.separarClave(clave)))
	local valor = gema and (F.Fundir :: { [string]: number })[gema.Rareza]
	if not gema or not valor then
		return
	end
	local tope = Jugadores.bonos(d).TopeForja
	if d.FichasForja >= tope then
		Remotos.Aviso:FireClient(jugador, ('Ya tenés el máximo de monedas "?" (%d)'):format(tope))
		return
	end
	d.Mochila[clave] -= 1 -- primero se saca, después se paga
	if d.Mochila[clave] <= 0 then
		d.Mochila[clave] = nil
	end
	d.FichasForja = math.min(tope, d.FichasForja + valor)
	Jugadores.publicar(jugador)
	Remotos.Aviso:FireClient(
		jugador,
		('Fundiste %s: +%d monedas "?" (%d/%d)'):format(gema.Nombre, valor, d.FichasForja, tope)
	)
end

-- Antes de borrar sus datos: lo que tenga a medias se le entrega.
function Forja.alSalir(jugador: Player)
	Forja.entregar(jugador)
	ultimoFundir[jugador] = nil
end

function Forja.iniciar()
	Remotos.ForjaIntentar.OnServerEvent:Connect(alIntentar)
	Remotos.ForjaListo.OnServerEvent:Connect(alListo)
	Remotos.Fundir.OnServerEvent:Connect(alFundir)
	-- las que vencen se entregan solas
	local proximo = 0
	RunService.Heartbeat:Connect(function()
		local ahora = os.clock()
		if ahora < proximo then
			return
		end
		proximo = ahora + 0.5
		for _, jugador in Players:GetPlayers() do
			local d = Jugadores.obtener(jugador)
			local p = d and d.ForjaPendiente
			if p and ahora > p.Vence then
				Forja.entregar(jugador)
			end
		end
	end)
end

return Forja
