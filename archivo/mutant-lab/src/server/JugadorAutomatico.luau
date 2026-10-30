--!strict
-- Jugador automático de verdad (solo en Studio, no está en el juego): juega con un jugador
-- conectado usando las funciones reales del servidor (máquina, tienda y tablero), en tiempo
-- real y con las mismas decisiones que el simulador (Robot.luau). Mientras juega, el cliente
-- ve todo: las animaciones de la máquina, las despedidas y los festejos.
-- Se arranca con ServerStorage.Prueba.Jugar y el informe se lee con Prueba.Informe.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Jugadores = require(script.Parent.Jugadores)
local MaquinaFusion = require(script.Parent.MaquinaFusion)
local Robot = require(script.Parent.Robot)
local Tablero = require(script.Parent.Tablero)
local Tienda = require(script.Parent.Tienda)

local R = Config.Prueba.Robot

local JugadorAutomatico = {}

local corriendo = false
local lineas: { string } = {}
local resumen = "Todavía no jugó."

local function anotar(texto: string)
	table.insert(lineas, texto)
end

-- "Alegre 3, Vaga 1, ..." (las personalidades de las criaturas que tiene ahora).
local function contarPersonalidades(d: Jugadores.Datos): string
	local cuentas: { [string]: number } = {}
	for _, u in d.Criaturas do
		cuentas[u.Personalidad] = (cuentas[u.Personalidad] or 0) + 1
	end
	local partes = {}
	for _, p in Personalidades.Orden do
		if cuentas[p] then
			table.insert(partes, p .. " " .. cuentas[p])
		end
	end
	return table.concat(partes, ", ")
end

function JugadorAutomatico.iniciar(jugador: Player, segundos: number): boolean
	if corriendo or not Jugadores.obtener(jugador) then
		return false
	end
	corriendo = true
	lineas = {}
	resumen = "Jugando..."
	local inicio = os.clock()
	local mem = Robot.nuevaMemoria()
	local conPersonalidad, conVariante = 0, 0
	local mundo: Robot.Mundo = {
		datos = function()
			return Jugadores.obtener(jugador) :: Jugadores.Datos
		end,
		ahora = os.clock,
		fusionar = function(a: string, b: string, catalizador: string?): boolean
			local r = MaquinaFusion.pedir(jugador, a, b, nil, nil, catalizador)
			return r ~= nil and (r.Ok or r.Motivo == "NoReaccionan")
		end,
		comprar = function(tipo: string, id: any): boolean
			return Tienda.comprar(jugador, tipo, id)
		end,
		entregar = function(lugar: number, unidades: { Pedidos.Unidad }): boolean
			local d = Jugadores.obtener(jugador)
			local p = d and d.Pedidos[lugar]
			local ok = Tablero.entregar(jugador, lugar, unidades)
			if ok and p then
				if p.Requisito.Personalidad then
					conPersonalidad += 1
				elseif p.Requisito.Variante then
					conVariante += 1
				end
			end
			return ok
		end,
		descartar = function(lugar: number): boolean
			return Tablero.descartar(jugador, lugar)
		end,
	}

	local adnMaximo, razonMaxima, arriba = 0, 0, 0
	local fusiones, compras, descartes, sinSaber, residuos = 0, 0, 0, 0, 0
	local especiesAntes = 0
	local nuevas: { string } = {}

	-- Cada segundo: ADN máximo, ADN comparado con la próxima fusión y un renglón por minuto.
	task.spawn(function()
		local segundo = 0
		while corriendo do
			task.wait(1)
			segundo += 1
			local d = Jugadores.obtener(jugador)
			if d then
				local n = Jugadores.cantidadEspecies(d)
				local costo = Costos.fusion(1, 1, n) or 1
				adnMaximo = math.max(adnMaximo, d.ADN)
				razonMaxima = math.max(razonMaxima, d.ADN / costo)
				if d.ADN / costo > 3 then
					arriba += 1
				end
				if n > especiesAntes then
					if especiesAntes > 0 then
						table.insert(nuevas, ("%d:%02d"):format(segundo // 60, segundo % 60))
					end
					especiesAntes = n
				end
				if segundo % 60 == 0 then
					local activas = Mejoras.activas(d.Criaturas, d.Mejoras.Corrales)
					anotar(
						("Minuto %d: %d especies | ADN %d | %s ADN/s | %d entregados | próxima fusión %d"):format(
							segundo // 60,
							n,
							d.ADN,
							tostring(Mejoras.porSegundo(activas, d.Mejoras.Nutrientes)),
							d.Entregados,
							costo
						)
					)
				end
			end
		end
	end)

	task.spawn(function()
		local quieto = 0
		local contado = false
		while os.clock() - inicio < segundos and jugador.Parent and Jugadores.obtener(jugador) do
			local ok, accion = pcall(Robot.turno, mundo, mem)
			if not ok then
				anotar("Error del jugador automático: " .. tostring(accion))
				break
			end
			if accion == "Fusion" then
				fusiones += 1
			elseif accion == "Residuo" then
				residuos += 1
			elseif accion == "Compra" then
				compras += 1
			elseif accion == "Descarte" then
				descartes += 1
			end
			if accion == nil and not mem.Esperando then
				quieto += Robot.duracion(nil)
				if quieto >= R.SinSaber and not contado then
					sinSaber += 1
					contado = true
					anotar(
						("Sin saber qué hacer a los %d s"):format(math.floor(os.clock() - inicio))
					)
				end
			elseif accion ~= nil then
				quieto = 0
				contado = false
			end
			task.wait(Robot.duracion(accion :: string?))
		end
		corriendo = false
		local d = Jugadores.obtener(jugador)
		resumen = table.concat({
			("Jugó %d s como jugador nuevo."):format(math.floor(os.clock() - inicio)),
			"Especies: " .. (if d then Jugadores.cantidadEspecies(d) else 0),
			"Pedidos entregados: " .. (if d then d.Entregados else 0),
			"Fusiones: " .. fusiones .. " | compras: " .. compras .. " | descartes: " .. descartes,
			"ADN máximo: " .. math.floor(adnMaximo),
			("ADN / próxima fusión, máximo: %.1f (segundos con más del triple: %d)"):format(
				razonMaxima,
				arriba
			),
			"Veces sin saber qué hacer: " .. sinSaber,
			"Residuos hechos: " .. residuos .. " | catalizadores: " .. (if d
				then Catalizadores.escribir(d.Catalizadores)
				else ""),
			"Especies nuevas en: " .. table.concat(nuevas, ", "),
			"Pedidos con personalidad: " .. conPersonalidad .. " | con variante: " .. conVariante,
			"Personalidades en el laboratorio: " .. (if d then contarPersonalidades(d) else ""),
			"Variantes conseguidas: "
				.. (if d then table.concat(Jugadores.aLista(d.Variantes), ", ") else ""),
		}, "\n")
	end)
	return true
end

function JugadorAutomatico.informe(): string
	return resumen .. "\n" .. table.concat(lineas, "\n")
end

return JugadorAutomatico
