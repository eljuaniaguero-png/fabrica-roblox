--!strict
-- Analítica con AnalyticsService (se ve en Creator Hub → Analytics):
--   Analitica.paso(jugador, n)  embudo del jugador nuevo (GameConfig.Embudo). Cada paso se
--       registra una sola vez por jugador (Datos.Embudo se guarda). Si llega a un paso sin haber
--       pasado por los anteriores (por ejemplo, una Épica antes del primer pico), se registran
--       también los que faltan, para que el embudo quede en orden.
--   Analitica.monedas(jugador, entra, cantidad, motivo)  de dónde salen y en qué se gastan las
--       Monedas (fuentes: "Venta"; gastos: "Fuerza", "Pico", "Amuleto", "Viaje", "Ruleta").
-- Nunca frena el juego: los errores de AnalyticsService se ignoran.

local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Jugadores = require(script.Parent.Jugadores)

local Analitica = {}

-- Números de cada paso, para no escribirlos sueltos en el código.
Analitica.Pasos = {
	Entro = 1,
	Golpe = 2,
	GeodaRota = 3,
	Venta = 4,
	Fuerza = 5,
	Zona2 = 6,
	Forja = 7,
	Pico = 8,
	Zona3 = 9,
	Mascota = 10,
}

function Analitica.paso(jugador: Player, n: number)
	local d = Jugadores.obtener(jugador)
	if not d or n <= d.Embudo then
		return
	end
	for i = d.Embudo + 1, math.min(n, #GameConfig.Embudo) do
		pcall(function()
			AnalyticsService:LogOnboardingFunnelStepEvent(jugador, i, GameConfig.Embudo[i])
		end)
	end
	d.Embudo = n
end

function Analitica.monedas(jugador: Player, entra: boolean, cantidad: number, motivo: string)
	local d = Jugadores.obtener(jugador)
	if not d or cantidad <= 0 then
		return
	end
	pcall(function()
		AnalyticsService:LogEconomyEvent(
			jugador,
			if entra
				then Enum.AnalyticsEconomyFlowType.Source
				else Enum.AnalyticsEconomyFlowType.Sink,
			"Monedas",
			cantidad,
			d.Monedas,
			if entra
				then Enum.AnalyticsEconomyTransactionType.Gameplay.Name
				else Enum.AnalyticsEconomyTransactionType.Shop.Name,
			motivo
		)
	end)
end

return Analitica
