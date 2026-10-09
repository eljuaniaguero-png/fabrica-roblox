--!strict
-- Simulador de balance (solo para probar en Studio, no está en el juego): juega partidas de
-- un jugador nuevo con el jugador automático (Robot.luau) en tiempo simulado, usando las
-- mismas reglas que el servidor (MaquinaFusion.aplicar, Tienda.aplicar, Tablero).
-- Mide lo que pide la ficha: especies, pedidos entregados, ADN máximo, ADN comparado con lo
-- que cuesta la próxima fusión y cuántas veces se quedó sin saber qué hacer.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)
local Jugadores = require(script.Parent.Jugadores)
local MaquinaFusion = require(script.Parent.MaquinaFusion)
local Robot = require(script.Parent.Robot)
local Tablero = require(script.Parent.Tablero)
local Tienda = require(script.Parent.Tienda)

local R = Config.Prueba.Robot

export type Minuto = {
	Especies: number,
	ADN: number,
	PorSegundo: number,
	Entregados: number,
	Costo: number, -- de una fusión de gen 2
}

export type Informe = {
	Minutos: { Minuto },
	Especies: number,
	Entregados: number,
	ADNMaximo: number,
	RazonMaxima: number, -- ADN / costo de la próxima fusión, el máximo
	SegundosArribaDelTriple: number,
	SinSaber: number, -- veces que estuvo R.SinSaber segundos seguidos sin nada útil
	Fusiones: number,
	Compras: number,
	Descartes: number,
	ConCatalizador: number, -- fusiones que salieron con catalizador (variantes hechas)
	Variantes: number, -- variantes distintas conseguidas
	PedidosPersonalidad: number,
	PedidosVariante: number,
	PrimeraFusion: number?,
}

local Simulador = {}

-- Juega `segundos` de una partida nueva. Devuelve el informe.
function Simulador.jugar(segundos: number, semilla: number, registro: { string }?): Informe
	local d = Jugadores.nuevos()
	local rng = Random.new(semilla)
	local t = 0
	Tablero.llenar(d, t)
	-- Lo que cuentan las funciones del mundo (el informe se arma más abajo).
	local especiales = { ConCatalizador = 0, PedidosPersonalidad = 0, PedidosVariante = 0 }
	local mundo: Robot.Mundo = {
		datos = function()
			return d
		end,
		ahora = function()
			return t
		end,
		fusionar = function(a: string, b: string, catalizador: string?): boolean
			local r = MaquinaFusion.aplicar(d, a, b, t, rng, nil, nil, catalizador)
			if r.Ok and r.Variante then
				especiales.ConCatalizador += 1
			end
			return r.Ok or r.Motivo == "NoReaccionan"
		end,
		comprar = function(tipo: string, id: any): boolean
			return Tienda.aplicar(d, tipo, id).Ok
		end,
		entregar = function(lugar: number, unidades: { Pedidos.Unidad }): boolean
			local p = d.Pedidos[lugar]
			local ok = Tablero.aplicarEntrega(d, lugar, unidades)
			if ok and p and p.Requisito.Personalidad then
				especiales.PedidosPersonalidad += 1
			elseif ok and p and p.Requisito.Variante then
				especiales.PedidosVariante += 1
			end
			if ok then
				Tablero.llenar(d, t)
			end
			return ok
		end,
		descartar = function(lugar: number): boolean
			d.Pedidos[lugar] = nil
			d.EsperaPedido[lugar] = t + Config.Pedidos.EsperaDescarte
			return true
		end,
	}
	local mem = Robot.nuevaMemoria()
	local informe: Informe = {
		Minutos = {},
		Especies = 0,
		Entregados = 0,
		ADNMaximo = d.ADN,
		RazonMaxima = 0,
		SegundosArribaDelTriple = 0,
		SinSaber = 0,
		Fusiones = 0,
		Compras = 0,
		Descartes = 0,
		ConCatalizador = 0,
		Variantes = 0,
		PedidosPersonalidad = 0,
		PedidosVariante = 0,
		PrimeraFusion = nil,
	}
	local quieto = 0 -- segundos seguidos sin nada útil
	local contado = false

	while t < segundos do
		local accion = Robot.turno(mundo, mem)
		if registro and accion and accion ~= "Mirar" then
			table.insert(
				registro,
				("%3d %s | especies %d | criaturas %d | ADN %d | fusion %d"):format(
					t,
					accion,
					Jugadores.cantidadEspecies(d),
					#d.Criaturas,
					d.ADN,
					Costos.fusion(1, 1, Jugadores.cantidadEspecies(d)) or 0
				)
			)
		end
		if accion == "Fusion" then
			informe.Fusiones += 1
			informe.PrimeraFusion = informe.PrimeraFusion or t
		elseif accion == "Compra" then
			informe.Compras += 1
		elseif accion == "Descarte" then
			informe.Descartes += 1
		end
		-- Sin nada útil: no hizo nada y tampoco estaba juntando ADN para algo.
		if accion == nil and not mem.Esperando then
			quieto += Robot.duracion(nil)
			if quieto >= R.SinSaber and not contado then
				informe.SinSaber += 1
				contado = true
			end
		elseif accion ~= nil then
			quieto = 0
			contado = false
		end
		-- Mientras dura la acción las criaturas no cambian: se calcula una vez.
		local porSegundo = Mejoras.porSegundo(
			Mejoras.activas(d.Criaturas, d.Mejoras.Corrales),
			d.Mejoras.Nutrientes
		)
		for _ = 1, Robot.duracion(accion) do
			t += 1
			d.ADN += porSegundo
			Tablero.llenar(d, t)
			local costo = Costos.fusion(1, 1, Jugadores.cantidadEspecies(d)) or 1
			local razon = d.ADN / costo
			informe.ADNMaximo = math.max(informe.ADNMaximo, d.ADN)
			informe.RazonMaxima = math.max(informe.RazonMaxima, razon)
			if razon > 3 then
				informe.SegundosArribaDelTriple += 1
			end
			if t % 60 == 0 then
				table.insert(informe.Minutos, {
					Especies = Jugadores.cantidadEspecies(d),
					ADN = math.floor(d.ADN),
					PorSegundo = porSegundo,
					Entregados = d.Entregados,
					Costo = costo,
				})
			end
		end
	end
	informe.Especies = Jugadores.cantidadEspecies(d)
	informe.Entregados = d.Entregados
	informe.Variantes = #Jugadores.aLista(d.Variantes)
	informe.ConCatalizador = especiales.ConCatalizador
	informe.PedidosPersonalidad = especiales.PedidosPersonalidad
	informe.PedidosVariante = especiales.PedidosVariante
	return informe
end

-- Cambia números de Config mientras corre `f` (por ejemplo { ["Economia.CostoGen2"] = 150 })
-- y después los deja como estaban. Sirve para probar variantes sin reiniciar.
function Simulador.conCambios<T>(cambios: { [string]: any }?, f: () -> T): T
	local viejos = {}
	for camino, valor in cambios or {} do
		local partes = string.split(camino, ".")
		local tabla: any = Config
		for i = 1, #partes - 1 do
			tabla = tabla[partes[i]]
		end
		local ultima = partes[#partes]
		local clave: any = tonumber(ultima) or ultima
		table.insert(viejos, { Tabla = tabla, Clave = clave, Valor = tabla[clave] })
		tabla[clave] = valor
	end
	local ok, resultado = pcall(f)
	for i = #viejos, 1, -1 do
		local v = viejos[i]
		v.Tabla[v.Clave] = v.Valor
	end
	if not ok then
		error(resultado)
	end
	return resultado
end

-- Juega `partidas` partidas y devuelve un resumen en texto (promedios y peores casos).
function Simulador.resumen(segundos: number, partidas: number): string
	local suma = {
		Especies = 0,
		Entregados = 0,
		ADNMaximo = 0,
		Razon = 0,
		Arriba = 0,
		SinSaber = 0,
		Fusiones = 0,
		ConCatalizador = 0,
		Variantes = 0,
		PedidosPersonalidad = 0,
		PedidosVariante = 0,
	}
	local peorRazon, minimoEspecies, maximoEspecies = 0, math.huge, 0
	local porMinuto: { { number } } = {}
	for p = 1, partidas do
		local inf = Simulador.jugar(segundos, p)
		suma.Especies += inf.Especies
		suma.Entregados += inf.Entregados
		suma.ADNMaximo += inf.ADNMaximo
		suma.Razon += inf.RazonMaxima
		suma.Arriba += inf.SegundosArribaDelTriple
		suma.SinSaber += inf.SinSaber
		suma.Fusiones += inf.Fusiones
		suma.ConCatalizador += inf.ConCatalizador
		suma.Variantes += inf.Variantes
		suma.PedidosPersonalidad += inf.PedidosPersonalidad
		suma.PedidosVariante += inf.PedidosVariante
		peorRazon = math.max(peorRazon, inf.RazonMaxima)
		minimoEspecies = math.min(minimoEspecies, inf.Especies)
		maximoEspecies = math.max(maximoEspecies, inf.Especies)
		for m, datos in inf.Minutos do
			porMinuto[m] = porMinuto[m] or { 0, 0, 0 }
			porMinuto[m][1] += datos.Especies
			porMinuto[m][2] += datos.Entregados
			porMinuto[m][3] += datos.ADN
		end
	end
	local function prom(x: number): string
		return string.format("%.1f", x / partidas)
	end
	local lineas = {
		("%d partidas de %d s"):format(partidas, segundos),
		("Especies: %s (entre %d y %d)"):format(
			prom(suma.Especies),
			minimoEspecies,
			maximoEspecies
		),
		"Pedidos entregados: " .. prom(suma.Entregados),
		"Fusiones: " .. prom(suma.Fusiones),
		"ADN máximo: " .. prom(suma.ADNMaximo),
		("ADN / próxima fusión, máximo: %s (peor %.1f)"):format(prom(suma.Razon), peorRazon),
		"Segundos con más del triple: " .. prom(suma.Arriba),
		"Veces sin saber qué hacer: " .. prom(suma.SinSaber),
		"Fusiones con catalizador: "
			.. prom(suma.ConCatalizador)
			.. " | variantes distintas: "
			.. prom(suma.Variantes),
		"Pedidos con personalidad: "
			.. prom(suma.PedidosPersonalidad)
			.. " | con variante: "
			.. prom(suma.PedidosVariante),
		"Minuto a minuto (especies / entregados / ADN):",
	}
	for m, v in porMinuto do
		table.insert(lineas, ("  %d: %s / %s / %s"):format(m, prom(v[1]), prom(v[2]), prom(v[3])))
	end
	return table.concat(lineas, "\n")
end

return Simulador
