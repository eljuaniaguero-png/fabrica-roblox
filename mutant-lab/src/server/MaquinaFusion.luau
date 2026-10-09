--!strict
-- La máquina de fusión del lado del servidor: valida, cobra y decide el resultado.
-- El cliente solo pide (claveA, claveB); todo lo que importa se calcula acá.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Coleccion = require(script.Parent.Coleccion)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
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
	local conocidos = {}
	for _, c in Catalizadores.Lista do
		if d.CatalizadoresVistos[c.Clave] then
			table.insert(conocidos, c.Clave)
		end
	end
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

-- Las reglas de la fusión sobre los datos de un jugador, sin avisarle a nadie (también la usa
-- el simulador de balance). `ahora` es os.clock() o la hora simulada. Devuelve el resultado y
-- las celebraciones de generación completa.
function MaquinaFusion.aplicar(
	d: Jugadores.Datos,
	claveA: string,
	claveB: string,
	ahora: number,
	rng: Random
): (Fusion.Resultado, { Fusion.Celebracion })
	local base: Fusion.Resultado = { Ok = false, A = claveA, B = claveB }
	if ahora < d.OcupadoHasta then
		base.Motivo = "Ocupada"
		return base, {}
	end
	-- Hace falta tener una criatura de cada una (los padres no se gastan).
	if Jugadores.contar(d, claveA) < 1 or Jugadores.contar(d, claveB) < 1 then
		base.Motivo = "NoTenes"
		return base, {}
	end
	local ca, cb = Fusion.porClave(claveA), Fusion.porClave(claveB)
	if not ca or not cb then
		base.Motivo = "NoTenes"
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
	Jugadores.agregarCriatura(d, hijo.Clave, mutante)
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
	},
		celebraciones
end

-- Pide una fusión con una criatura de cada especie (también la usa el jugador automático de
-- prueba). Devuelve lo que le contestó al cliente.
function MaquinaFusion.pedir(jugador: Player, a: unknown, b: unknown): Fusion.Resultado?
	-- Nunca confiar en lo que manda el cliente.
	if typeof(a) ~= "string" or typeof(b) ~= "string" or #a > 12 or #b > 12 then
		return nil
	end
	local d = Jugadores.obtener(jugador)
	if not d then
		return nil
	end
	local resultado, celebraciones =
		MaquinaFusion.aplicar(d, a :: string, b :: string, os.clock(), azar)
	if resultado.Ok or resultado.Motivo == "NoReaccionan" then
		Jugadores.publicar(jugador)
	end
	responder(jugador, resultado)
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
	end)
	return resultado
end

Remotos.PedirFusion.OnServerEvent:Connect(function(jugador: Player, a: unknown, b: unknown)
	MaquinaFusion.pedir(jugador, a, b)
end)

return MaquinaFusion
