--!strict
-- La máquina de fusión del lado del servidor: valida, cobra y decide el resultado.
-- El cliente solo pide (claveA, claveB); todo lo que importa se calcula acá.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Coleccion = require(script.Parent.Coleccion)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Metas = require(script.Parent.Metas)
local Misiones = require(script.Parent.Misiones)
local Remotos = require(script.Parent.Remotos)

local azar = Random.new()

local function probabilidadMutante(): number
	if Config.Prueba.Activo then
		return Config.Prueba.ProbabilidadMutante
	end
	return Config.ProbabilidadMutante
end

local function responder(jugador: Player, r: Fusion.Resultado)
	Remotos.ResultadoFusion:FireClient(jugador, r)
	if Config.Prueba.Activo then
		local d = Jugadores.obtener(jugador)
		local hijo = if r.Clave then Fusion.porClave(r.Clave) else nil
		print(
			("[Fusion] %s: %s + %s -> %s%s%s | costo %s | premio %s | ADN %s"):format(
				jugador.Name,
				r.A,
				r.B,
				if hijo then hijo.Nombre .. " (gen " .. hijo.Gen .. ")" else tostring(r.Motivo),
				if r.Mutante then " MUTANTE" else "",
				if r.Nueva == false then " (repetida)" else "",
				tostring(r.Costo or 0),
				tostring(r.Premio or 0),
				tostring(d and d.ADN)
			)
		)
	end
end

local MaquinaFusion = {}

-- Los catalizadores que conocés: el de cada elemento del que ya descubriste una especie (y los
-- que ya tuviste alguna vez).
function MaquinaFusion.conocidos(d: Jugadores.Datos): { string }
	return Catalizadores.conocidos(d.Especies, d.CatalizadoresVistos)
end

-- Si hay residuos suficientes, los gasta y arma un catalizador al azar entre los que conocés
-- (si todavía no conocés ninguno, uno cualquiera). Devuelve cuál, o nil.
function MaquinaFusion.fabricar(d: Jugadores.Datos, rng: Random): string?
	local hacen = Config.Residuos.ParaCatalizador
	if #d.Residuos < hacen then
		return nil
	end
	for _ = 1, hacen do
		table.remove(d.Residuos, 1)
	end
	local conocidos = MaquinaFusion.conocidos(d)
	if #conocidos == 0 then
		for _, c in Catalizadores.Lista do
			table.insert(conocidos, c.Clave)
		end
	end
	local clave = conocidos[rng:NextInteger(1, #conocidos)]
	d.Catalizadores[clave] = (d.Catalizadores[clave] or 0) + 1
	d.CatalizadoresVistos[clave] = true
	return clave
end

-- La personalidad del padre elegido: la que pidió el cliente si tiene una así, o la de la
-- primera criatura de esa especie si no dijo cuál. nil si no tiene.
local function personalidadPadre(d: Jugadores.Datos, clave: string, pedida: string?): string?
	for _, u in d.Criaturas do
		if u.Clave == clave and (pedida == nil or u.Personalidad == pedida) then
			return u.Personalidad
		end
	end
	return nil
end

-- ¿Ya se puede usar la ranura de catalizador?
function MaquinaFusion.ranuraAbierta(d: Jugadores.Datos): boolean
	return Jugadores.cantidadEspecies(d) >= Config.Residuos.RanuraDesde
end

-- Las reglas de la fusión sobre los datos de un jugador, sin avisarle a nadie (también la usa
-- el simulador de balance). `ahora` es os.clock() o la hora simulada. `personalidadA` y
-- `personalidadB` dicen qué criatura de cada especie se usa (nil = cualquiera) y
-- `catalizador`, el que va en la tercera ranura (nil = ninguno). Devuelve el resultado y las
-- celebraciones de generación completa.
function MaquinaFusion.aplicar(
	d: Jugadores.Datos,
	claveA: string,
	claveB: string,
	ahora: number,
	rng: Random,
	personalidadA: string?,
	personalidadB: string?,
	catalizador: string?
): (Fusion.Resultado, { Fusion.Celebracion })
	local base: Fusion.Resultado = { Ok = false, A = claveA, B = claveB }
	if ahora < d.OcupadoHasta then
		base.Motivo = "Ocupada"
		return base, {}
	end
	-- Hace falta tener una criatura de cada una (los padres no se gastan).
	local pa = personalidadPadre(d, claveA, personalidadA)
	local pb = personalidadPadre(d, claveB, personalidadB)
	local ca, cb = Fusion.porClave(claveA), Fusion.porClave(claveB)
	if not ca or not cb or not pa or not pb then
		base.Motivo = "NoTenes"
		return base, {}
	end
	-- El catalizador hay que tenerlo y la ranura tiene que estar abierta.
	local cat = Catalizadores.porClave(catalizador)
	if
		catalizador ~= nil
		and (not cat or (d.Catalizadores[cat.Clave] or 0) < 1 or not MaquinaFusion.ranuraAbierta(d))
	then
		base.Motivo = "SinCatalizador"
		return base, {}
	end

	local costo = Costos.fusion(ca.Gen, cb.Gen, Jugadores.cantidadEspecies(d))
	local hijo = Fusion.fusionar(ca, cb)
	if not hijo or not costo then
		-- No reaccionan: no se cobra, pero sale un residuo y la máquina dice por qué.
		d.OcupadoHasta = ahora
			+ Config.Maquina.EsperaNoReacciona * Mejoras.factorRapidez(d.Mejoras.Rapida)
		base.Motivo = "NoReaccionan"
		base.Razon = Fusion.motivo(ca, cb)
		table.insert(d.Residuos, { A = claveA, B = claveB })
		base.Fabricado = MaquinaFusion.fabricar(d, rng)
		base.Residuos = #d.Residuos
		return base, {}
	end
	if d.ADN < costo then
		base.Motivo = "FaltaADN"
		base.Costo = costo
		return base, {}
	end

	-- Fusionar cobra ADN, no destruye a los padres y suma una criatura al laboratorio
	-- (también si la especie ya la tenías: sirve para los pedidos).
	d.ADN -= costo
	local nueva = Coleccion.agregar(d, hijo.Clave)
	-- Premio por descubrirla (solo la primera vez).
	local premio = if nueva then Coleccion.premioDescubrir(costo) else nil
	if premio then
		d.ADN += premio
	end
	local mutante = rng:NextNumber() < probabilidadMutante()
	if mutante then
		d.Mutantes[hijo.Clave] = true
	end
	-- La personalidad sale de la tabla de herencia; algunos catalizadores la cambian.
	local personalidad = Personalidades.heredar(pa, pb) or Personalidades.deEspecie(hijo.Bases)
	local variante: string? = nil
	local nuevaVariante: boolean? = nil
	if cat then
		d.Catalizadores[cat.Clave] -= 1
		variante = cat.Clave
		personalidad = cat.Personalidad or personalidad
		local vistas = d.Variantes[hijo.Clave] or {}
		nuevaVariante = not vistas[cat.Clave]
		vistas[cat.Clave] = true
		d.Variantes[hijo.Clave] = vistas
	end
	Jugadores.agregarCriatura(d, hijo.Clave, mutante, personalidad, variante)
	d.Fusiones += 1
	local celebraciones = Coleccion.revisarGeneraciones(d)
	d.OcupadoHasta = ahora + Config.Maquina.Espera * Mejoras.factorRapidez(d.Mejoras.Rapida)
	return {
		Ok = true,
		A = claveA,
		B = claveB,
		Clave = hijo.Clave,
		Nueva = nueva,
		Mutante = mutante,
		Costo = costo,
		Premio = premio,
		Personalidad = personalidad,
		Variante = variante,
		NuevaVariante = nuevaVariante,
	},
		celebraciones
end

-- Un texto corto o nil (lo demás no se acepta).
local function textoOpcional(x: unknown): (boolean, string?)
	if x == nil then
		return true, nil
	end
	if typeof(x) == "string" and #x <= 16 then
		return true, x :: string
	end
	return false, nil
end

-- Pide una fusión con una criatura de cada especie (también la usa el jugador automático de
-- prueba). Devuelve lo que le contestó al cliente.
function MaquinaFusion.pedir(
	jugador: Player,
	a: unknown,
	b: unknown,
	pa: unknown?,
	pb: unknown?,
	catalizador: unknown?
): Fusion.Resultado?
	-- Nunca confiar en lo que manda el cliente.
	if typeof(a) ~= "string" or typeof(b) ~= "string" or #a > 12 or #b > 12 then
		return nil
	end
	local okA, personalidadA = textoOpcional(pa)
	local okB, personalidadB = textoOpcional(pb)
	local okC, cat = textoOpcional(catalizador)
	if not okA or not okB or not okC then
		return nil
	end
	local d = Jugadores.obtener(jugador)
	if not d then
		return nil
	end
	local resultado, celebraciones = MaquinaFusion.aplicar(
		d,
		a :: string,
		b :: string,
		os.clock(),
		azar,
		personalidadA,
		personalidadB,
		cat
	)
	if resultado.Ok or resultado.Motivo == "NoReaccionan" then
		Jugadores.publicar(jugador)
	end
	responder(jugador, resultado)
	if resultado.Motivo == "NoReaccionan" then
		Misiones.avisar(jugador, "Residuos")
	end
	if not resultado.Ok then
		return resultado
	end
	local nueva, mutante = resultado.Nueva == true, resultado.Mutante == true
	local hijo = Fusion.porClave(resultado.Clave :: string) :: Fusion.Criatura
	-- El cliente las muestra cuando termina la animación de la fusión.
	for _, celebracion in celebraciones do
		Remotos.Celebracion:FireClient(jugador, celebracion)
	end
	-- La criatura nueva llega al corral (y a la pantalla de la Mutadex) después de la
	-- revelación, para no adelantar la sorpresa.
	task.delay(Config.Maquina.Espera * Mejoras.factorRapidez(d.Mejoras.Rapida), function()
		if nueva then
			Laboratorios.mostrarNueva(jugador, hijo.Clave, mutante)
		end
		Corrales.actualizar(jugador)
		-- Misiones, experimento del día y metas (después de la revelación, para no adelantarla).
		Misiones.avisar(jugador, "Fusionar")
		if nueva then
			Misiones.avisar(jugador, "Descubrir")
		end
		if resultado.Variante then
			Misiones.avisar(jugador, "Catalizador", resultado.Variante)
		end
		Misiones.avisar(jugador, "Personalidad", resultado.Personalidad)
		Misiones.experimento(jugador, hijo.Clave)
		Metas.revisar(jugador)
	end)
	return resultado
end

Remotos.PedirFusion.OnServerEvent:Connect(
	function(jugador: Player, a: unknown, b: unknown, pa: unknown, pb: unknown, cat: unknown)
		MaquinaFusion.pedir(jugador, a, b, pa, pb, cat)
	end
)

return MaquinaFusion
