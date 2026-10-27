--!strict
-- Analítica con AnalyticsService (etapa 11). Se ve en Creator Hub → tu experiencia → Analytics:
--   - Embudo de los primeros pasos (Onboarding): los pasos de Config.Analitica.Embudo, en orden.
--   - Recorrido de pisos (Progression, camino "Mazmorra"): en qué piso empieza, pasa o cae cada uno.
--     "Cae" es lo que dice en qué piso se pierde más.
--   - Mejora elegida (evento "Mejora elegida", campo 1 = el id): qué se compra y qué se saca del
--     cofre; el campo 2 dice si fue "tienda" o "cofre".
--   - Oro (Economy): de dónde sale (peleas, clavijas, venta) y en qué se gasta (tienda).
-- Todo va con pcall: si Roblox no acepta un evento (por ejemplo, en Studio sin publicar), el juego
-- sigue igual.

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")

local Config =
	require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local A = Config.Analitica
local Campos = Enum.AnalyticsCustomFieldKeys

local Analitica = {}

local function intentar(f: () -> ())
	local ok, err = pcall(f)
	if not ok then
		warn("[Analítica] " .. tostring(err))
	end
end

-- Un paso del embudo, por su nombre en Config.Analitica.Embudo.
function Analitica.paso(jugador: Player, nombre: string)
	local numero = table.find(A.Embudo, nombre)
	if not numero or jugador.Parent ~= Players then
		return
	end
	intentar(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(jugador, numero, nombre)
	end)
end

-- Recorrido de pisos: "empezo", "paso" o "cayo" en el piso (1 a 9).
function Analitica.piso(jugador: Player, que: string, piso: number, nombre: string)
	intentar(function()
		if que == "empezo" then
			AnalyticsService:LogProgressionStartEvent(jugador, A.Camino, piso, nombre)
		elseif que == "paso" then
			AnalyticsService:LogProgressionCompleteEvent(jugador, A.Camino, piso, nombre)
		elseif que == "cayo" then
			AnalyticsService:LogProgressionFailEvent(jugador, A.Camino, piso, nombre)
		end
	end)
end

-- Una mejora elegida: id de la clavija, pergamino o reliquia, y de dónde ("tienda" o "cofre").
function Analitica.mejora(jugador: Player, id: string, donde: string)
	intentar(function()
		AnalyticsService:LogCustomEvent(jugador, "Mejora elegida", 1, {
			[Campos.CustomField01.Name] = id,
			[Campos.CustomField02.Name] = donde,
		})
	end)
end

-- Oro que entra (cantidad > 0) o sale (cantidad < 0). saldo: el oro que queda.
function Analitica.oro(jugador: Player, cantidad: number, saldo: number, motivo: string)
	if cantidad == 0 then
		return
	end
	intentar(function()
		AnalyticsService:LogEconomyEvent(
			jugador,
			if cantidad > 0
				then Enum.AnalyticsEconomyFlowType.Source
				else Enum.AnalyticsEconomyFlowType.Sink,
			A.Moneda,
			math.abs(cantidad),
			saldo,
			if cantidad > 0
				then Enum.AnalyticsEconomyTransactionType.Gameplay.Name
				else Enum.AnalyticsEconomyTransactionType.Shop.Name,
			motivo
		)
	end)
end

return Analitica
