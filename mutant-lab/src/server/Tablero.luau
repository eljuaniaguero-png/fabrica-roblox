--!strict
-- El tablero de pedidos de cada jugador (ficha, "Pedidos"). Siempre hay Config.Pedidos.Activos
-- pedidos; uno pide algo que todavía no descubriste. Entregar saca las criaturas del
-- laboratorio, paga ADN (y a veces una pista gratis) y trae otro pedido. Descartar deja el
-- lugar vacío Config.Pedidos.EsperaDescarte segundos. Cada Config.Pedidos.Hito entregas,
-- un premio extra. Todo se valida acá: el cliente solo dice qué lugar y qué criaturas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Remotos = require(script.Parent.Remotos)

local P = Config.Pedidos
local azar = Random.new()

local Tablero = {}

local function ahora(): number
	return workspace:GetServerTimeNow()
end

local function aviso(jugador: Player, texto: string, tipo: string?)
	Remotos.Aviso:FireClient(jugador, texto, tipo)
end

local function contexto(d: Jugadores.Datos): Pedidos.Contexto
	local mutantes = 0
	local cantidades = {}
	for _, u in d.Criaturas do
		cantidades[u.Clave] = (cantidades[u.Clave] or 0) + 1
		if u.Mutante then
			mutantes += 1
		end
	end
	return { Descubiertas = d.Especies, Cantidades = cantidades, Mutantes = mutantes }
end

-- Un cliente que no esté ya en el tablero.
local function clienteLibre(d: Jugadores.Datos, preferido: number): number
	local usados = {}
	for _, p in d.Pedidos do
		usados[p.Cliente] = true
	end
	if not usados[preferido] then
		return preferido
	end
	for i = 1, #P.Clientes do
		local c = (preferido + i - 1) % #P.Clientes + 1
		if not usados[c] then
			return c
		end
	end
	return preferido
end

-- Llena los lugares vacíos de `d` (los descartados esperan su tiempo). No toca el mundo:
-- también la usa el simulador de balance. `hora` es la hora del servidor.
function Tablero.llenar(d: Jugadores.Datos, hora: number): boolean
	local cambio = false
	for i = 1, P.Activos do
		local espera = d.EsperaPedido[i]
		if not d.Pedidos[i] and (not espera or hora >= espera) then
			local nuevos = 0
			for _, p in d.Pedidos do
				if p.Nuevo then
					nuevos += 1
				end
			end
			local p = Pedidos.generar(contexto(d), azar, d.SiguientePedido, nuevos < P.Nuevos)
			if p then
				p.Cliente = clienteLibre(d, p.Cliente)
				d.SiguientePedido += 1
				d.Pedidos[i] = p
				d.EsperaPedido[i] = nil
				cambio = true
			end
		end
	end
	return cambio
end

-- Llena los lugares vacíos y actualiza el tablero del laboratorio. Devuelve true si cambió algo.
function Tablero.completar(jugador: Player, d: Jugadores.Datos): boolean
	local cambio = Tablero.llenar(d, ahora())
	if cambio then
		Laboratorios.actualizarTablero(jugador, d.Pedidos)
	end
	return cambio
end

-- El premio de entregar el pedido del lugar `i` (sin validar nada): ADN, pista y el premio
-- extra si llega a un hito. Saca el pedido del tablero. Devuelve el premio del hito (o nil).
function Tablero.cobrar(d: Jugadores.Datos, i: number): number?
	local p = d.Pedidos[i]
	if not p then
		return nil
	end
	d.ADN += p.Premio
	if p.Pista then
		d.PistasGratis += 1
	end
	d.Entregados += 1
	d.Pedidos[i] = nil
	if d.Entregados % P.Hito == 0 then
		local fusion = Costos.fusion(1, 1, Jugadores.cantidadEspecies(d)) or 0
		local hito = math.round(fusion * P.PremioHito)
		d.ADN += hito
		return hito
	end
	return nil
end

-- Revisa lo que manda el cliente: una lista de 1 o 2 criaturas { Clave, Mutante }.
local function leerUnidades(crudo: unknown): { Pedidos.Unidad }?
	if typeof(crudo) ~= "table" then
		return nil
	end
	local lista: { Pedidos.Unidad } = {}
	for i, u in crudo :: { any } do
		if typeof(i) ~= "number" or i > 2 or typeof(u) ~= "table" then
			return nil
		end
		local clave, mutante = u.Clave, u.Mutante
		if
			typeof(clave) ~= "string"
			or not Fusion.porClave(clave)
			or typeof(mutante) ~= "boolean"
		then
			return nil
		end
		table.insert(lista, { Clave = clave, Mutante = mutante })
	end
	return lista
end

-- Las reglas de una entrega sobre los datos, sin avisarle a nadie (también la usa el
-- simulador). Si está todo bien, saca las criaturas y cobra. Devuelve si salió, el motivo
-- si no ("NoCumple" o "NoTenes") y el premio del hito (si llegó a uno).
function Tablero.aplicarEntrega(
	d: Jugadores.Datos,
	i: number,
	unidades: { Pedidos.Unidad }
): (boolean, string?, number?)
	local p = d.Pedidos[i]
	if not p or not Pedidos.cumple(p.Requisito, unidades) then
		return false, "NoCumple", nil
	end
	-- Hay que tenerlas todas (si piden dos iguales, hacen falta dos).
	local necesarias: { [string]: number } = {}
	for _, u in unidades do
		local k = u.Clave .. (if u.Mutante then "M" else "")
		necesarias[k] = (necesarias[k] or 0) + 1
		if Jugadores.contar(d, u.Clave, u.Mutante) < necesarias[k] then
			return false, "NoTenes", nil
		end
	end
	for _, u in unidades do
		Jugadores.quitarCriatura(d, u.Clave, u.Mutante)
	end
	return true, nil, Tablero.cobrar(d, i)
end

-- Entrega criaturas para el pedido del lugar `lugar`. También la usa el jugador automático.
function Tablero.entregar(jugador: Player, lugar: unknown, crudo: unknown): boolean
	local d = Jugadores.obtener(jugador)
	if not d or typeof(lugar) ~= "number" then
		return false
	end
	local i = lugar :: number
	local p = d.Pedidos[i]
	local unidades = leerUnidades(crudo)
	if not p or not unidades then
		return false
	end
	local ok, motivo, hito = Tablero.aplicarEntrega(d, i, unidades)
	if not ok then
		aviso(
			jugador,
			if motivo == "NoTenes"
				then "No tenés esas criaturas en tu laboratorio."
				else "Esa criatura no es lo que pide " .. P.Clientes[p.Cliente] .. ".",
			"error"
		)
		return false
	end
	Tablero.completar(jugador, d)
	Jugadores.publicar(jugador)
	Corrales.actualizar(jugador)
	Laboratorios.actualizarTablero(jugador, d.Pedidos)

	-- El cliente hace la despedida y, cada tantos pedidos, el festejo.
	Remotos.Entrega:FireClient(jugador, i, p, unidades)
	if hito then
		Remotos.Celebracion:FireClient(jugador, {
			Gen = 0,
			Premio = hito,
			Completo = false,
			Pedidos = d.Entregados,
		})
	end
	return true
end

-- Descarta el pedido de un lugar: llega otro después de la espera.
function Tablero.descartar(jugador: Player, lugar: unknown): boolean
	local d = Jugadores.obtener(jugador)
	if not d or typeof(lugar) ~= "number" then
		return false
	end
	local i = lugar :: number
	if not d.Pedidos[i] then
		return false
	end
	d.Pedidos[i] = nil
	d.EsperaPedido[i] = ahora() + P.EsperaDescarte
	Jugadores.publicarPedidos(jugador)
	Laboratorios.actualizarTablero(jugador, d.Pedidos)
	return true
end

function Tablero.iniciar()
	Remotos.EntregarPedido.OnServerEvent:Connect(
		function(jugador: Player, lugar: unknown, crudo: unknown)
			Tablero.entregar(jugador, lugar, crudo)
		end
	)
	Remotos.DescartarPedido.OnServerEvent:Connect(function(jugador: Player, lugar: unknown)
		Tablero.descartar(jugador, lugar)
	end)
	-- Los lugares descartados se vuelven a llenar cuando termina la espera.
	task.spawn(function()
		while true do
			task.wait(1)
			for jugador, d in Jugadores.todos() do
				if Tablero.completar(jugador, d) then
					Jugadores.publicarPedidos(jugador)
				end
			end
		end
	end)
end

return Tablero
