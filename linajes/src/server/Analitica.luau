--!strict
-- Analítica (Guía §6): embudo del primer minuto y entradas/salidas de Chatarra.
-- Todo va con pcall: si Roblox no acepta un evento (por ejemplo en Studio), el juego sigue igual.

local AnalyticsService = game:GetService("AnalyticsService")

local Analitica = {}

-- Pasos del embudo (en orden; cada uno se manda una sola vez por jugador y sesión).
Analitica.Pasos = {
	Entro = 1,
	EligioModo = 2,
	TiroRuleta = 3,
	Combate = 4,
	Defensa = 5,
	Poder = 6,
	Maton = 7, -- golpe fuerte al maniquí mientras no hay NPCs
	PrimerMinuto = 8,
}

local hechos: { [Player]: { [number]: boolean } } = {}

function Analitica.paso(jugador: Player, nombre: string)
	local n = (Analitica.Pasos :: any)[nombre]
	if typeof(n) ~= "number" then
		return
	end
	local propios = hechos[jugador] or {}
	hechos[jugador] = propios
	if propios[n] then
		return
	end
	propios[n] = true
	pcall(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(jugador, n, nombre)
	end)
end

-- Chatarra ganada jugando (fuente: Baja, Caer, Duelo, Tutorial, Jefe...).
function Analitica.gana(jugador: Player, cantidad: number, saldo: number, fuente: string)
	pcall(function()
		AnalyticsService:LogEconomyEvent(
			jugador,
			Enum.AnalyticsEconomyFlowType.Source,
			"Chatarra",
			cantidad,
			saldo,
			Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
			fuente
		)
	end)
end

-- Chatarra gastada (en qué: Tirada, LinajeVida_Electro...).
function Analitica.gasta(jugador: Player, cantidad: number, saldo: number, item: string)
	pcall(function()
		AnalyticsService:LogEconomyEvent(
			jugador,
			Enum.AnalyticsEconomyFlowType.Sink,
			"Chatarra",
			cantidad,
			saldo,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			item
		)
	end)
end

game:GetService("Players").PlayerRemoving:Connect(function(jugador)
	hechos[jugador] = nil
end)

return Analitica
