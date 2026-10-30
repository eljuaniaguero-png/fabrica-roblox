--!strict
-- Volver mañana (ficha, "Parte 8"): el ADN que juntaron tus criaturas mientras no estabas y
-- el premio diario de 7 días que crece. Los días los decide el servidor (Reloj.luau).
-- Premio diario: si cobraste ayer, hoy toca el día siguiente de la racha; si faltaste un
-- día, vuelve al día 1. El día 7 trae la especie especial (no se consigue de otra forma).
-- Se publica el atributo "Diario" (JSON: Dia, Disponible).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Metas = require(script.Parent.Metas)
local Reloj = require(script.Parent.Reloj)
local Remotos = require(script.Parent.Remotos)

local PREMIOS = Config.Diario.Premios
local R = Config.Regreso

local Diario = {}

export type Estado = { Dia: number, Disponible: boolean }

-- Qué día de la racha toca y si todavía no lo cobró hoy.
function Diario.estado(d: Jugadores.Datos, hoy: number): Estado
	local racha = d.Diario
	if racha.UltimoDia == hoy then
		return { Dia = racha.Racha, Disponible = false }
	end
	local siguiente = if racha.UltimoDia == hoy - 1 then racha.Racha % #PREMIOS + 1 else 1
	return { Dia = siguiente, Disponible = true }
end

export type Cobro = { Dia: number, ADN: number, Catalizadores: { string }, Especial: string? }

-- Cobra el premio de hoy sobre los datos (sin avisarle a nadie). nil si ya lo cobró.
function Diario.aplicar(d: Jugadores.Datos, hoy: number, rng: Random): Cobro?
	local e = Diario.estado(d, hoy)
	if not e.Disponible then
		return nil
	end
	local premio = PREMIOS[e.Dia]
	local adn = math.round((premio.ADN or 0) * Mejoras.fusion(Jugadores.cantidadEspecies(d)))
	d.ADN += adn
	local cats = {}
	local conocidos = Catalizadores.conocidos(d.Especies, d.CatalizadoresVistos)
	for _ = 1, premio.Catalizadores or 0 do
		local k = if #conocidos > 0 then conocidos[rng:NextInteger(1, #conocidos)] else nil
		if k then
			d.Catalizadores[k] = (d.Catalizadores[k] or 0) + 1
			d.CatalizadoresVistos[k] = true
			table.insert(cats, k)
		end
	end
	local especial = premio.Especial
	if especial then
		Jugadores.agregarCriatura(d, especial, false)
		d.Especiales[especial] = true
	end
	d.Diario = { Racha = e.Dia, UltimoDia = hoy }
	return { Dia = e.Dia, ADN = adn, Catalizadores = cats, Especial = especial }
end

function Diario.publicar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local e = Diario.estado(d, Reloj.dia())
	jugador:SetAttribute(
		"Diario",
		HttpService:JSONEncode({ Dia = e.Dia, Disponible = e.Disponible })
	)
end

local azar = Random.new()

-- El jugador toca "¡Cobrar!".
function Diario.cobrar(jugador: Player): boolean
	local d = Jugadores.obtener(jugador)
	if not d then
		return false
	end
	local cobro = Diario.aplicar(d, Reloj.dia(), azar)
	if not cobro then
		return false
	end
	Jugadores.publicar(jugador)
	Diario.publicar(jugador)
	local partes = {}
	if cobro.ADN > 0 then
		table.insert(partes, "+" .. Formato.numero(cobro.ADN) .. " ADN")
	end
	if #cobro.Catalizadores > 0 then
		local nombres = {}
		for _, k in cobro.Catalizadores do
			table.insert(nombres, (Catalizadores.porClave(k) :: Catalizadores.Catalizador).Nombre)
		end
		table.insert(
			partes,
			"+" .. #nombres .. (if #nombres > 1 then " catalizadores" else " catalizador")
		)
	end
	local especial = if cobro.Especial then Fusion.porClave(cobro.Especial) else nil
	Remotos.Celebracion:FireClient(jugador, {
		Gen = 0,
		Premio = cobro.ADN,
		Completo = false,
		Titulo = if especial then "¡ESPECIE ESPECIAL!" else "¡DÍA " .. cobro.Dia .. "!",
		Texto = if especial then especial.Nombre else table.concat(partes, " · "),
		Detalle = if especial
			then "Solo se consigue así · " .. table.concat(partes, " · ")
			else "Premio diario · volvé mañana por el día " .. cobro.Dia % #PREMIOS + 1,
	})
	if especial then
		Corrales.actualizar(jugador)
		Metas.revisar(jugador)
	end
	return true
end

-- ADN que juntaron tus criaturas mientras no estabas (sobre los datos). Devuelve cuánto y
-- cuántos segundos contó.
function Diario.regreso(d: Jugadores.Datos, ahora: number): (number, number)
	local ultima = d.UltimaVez
	if not ultima then
		return 0, 0
	end
	local afuera = ahora - ultima
	if afuera < R.Minimo then
		return 0, 0
	end
	local segundos = math.min(afuera, R.TopeHoras * 3600)
	local porSegundo =
		Mejoras.porSegundo(Mejoras.activas(d.Criaturas, d.Mejoras.Corrales), d.Mejoras.Nutrientes)
	local tope = R.TopeFusiones * Mejoras.fusion(Jugadores.cantidadEspecies(d))
	local ganado = math.floor(math.min(porSegundo * segundos * R.Rinde, tope))
	d.ADN += ganado
	d.UltimaVez = ahora
	return ganado, segundos
end

-- Al entrar: el cartel de regreso (si estuvo afuera) y el estado del premio diario.
function Diario.alEntrar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local ganado, segundos = Diario.regreso(d, Reloj.ahora())
	if ganado > 0 then
		Jugadores.publicar(jugador)
		Remotos.Regreso:FireClient(jugador, ganado, segundos)
	end
	Diario.publicar(jugador)
end

function Diario.iniciar()
	Remotos.CobrarDiario.OnServerEvent:Connect(function(jugador: Player)
		Diario.cobrar(jugador)
	end)
end

return Diario
