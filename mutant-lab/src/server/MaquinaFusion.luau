--!strict
-- La máquina de fusión del lado del servidor: valida, cobra y decide el resultado.
-- El cliente solo pide (claveA, claveB); todo lo que importa se calcula acá.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Coleccion = require(script.Parent.Coleccion)
local Jugadores = require(script.Parent.Jugadores)
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

local function pedir(jugador: Player, a: unknown, b: unknown)
	-- Nunca confiar en lo que manda el cliente.
	if typeof(a) ~= "string" or typeof(b) ~= "string" or #a > 12 or #b > 12 then
		return
	end
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local claveA, claveB = a :: string, b :: string
	local base: Fusion.Resultado = { Ok = false, A = claveA, B = claveB }

	local ahora = os.clock()
	if ahora < d.OcupadoHasta then
		base.Motivo = "Ocupada"
		responder(jugador, base)
		return
	end
	if not d.Especies[claveA] or not d.Especies[claveB] then
		base.Motivo = "NoTenes"
		responder(jugador, base)
		return
	end
	local ca, cb = Fusion.porClave(claveA), Fusion.porClave(claveB)
	if not ca or not cb then
		return
	end

	local costo = Costos.fusion(ca.Gen, cb.Gen, Jugadores.cantidadEspecies(d))
	local hijo = Fusion.fusionar(ca, cb)
	if not hijo or not costo then
		-- No reaccionan: no se cobra.
		d.OcupadoHasta = ahora + Config.Maquina.EsperaNoReacciona
		base.Motivo = "NoReaccionan"
		responder(jugador, base)
		return
	end
	if d.ADN < costo then
		base.Motivo = "FaltaADN"
		base.Costo = costo
		responder(jugador, base)
		return
	end

	-- Fusionar cobra ADN y no destruye a los padres.
	d.ADN -= costo
	local nueva = Coleccion.agregar(d, hijo.Clave)
	-- Premio por descubrirla (solo la primera vez).
	local premio = if nueva then Coleccion.premioDescubrir(costo) else nil
	if premio then
		d.ADN += premio
	end
	local mutante = azar:NextNumber() < probabilidadMutante()
	if mutante then
		d.Mutantes[hijo.Clave] = true
	end
	local celebraciones = Coleccion.revisarGeneraciones(d)
	d.OcupadoHasta = ahora + Config.Maquina.Espera
	Jugadores.publicar(jugador)

	responder(jugador, {
		Ok = true,
		A = claveA,
		B = claveB,
		Clave = hijo.Clave,
		Nueva = nueva,
		Mutante = mutante,
		Costo = costo,
		Premio = premio,
	})
	-- El cliente las muestra cuando termina la animación de la fusión.
	for _, celebracion in celebraciones do
		Remotos.Celebracion:FireClient(jugador, celebracion)
	end
end

Remotos.PedirFusion.OnServerEvent:Connect(pedir)

return {}
