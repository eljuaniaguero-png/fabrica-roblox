--!strict
-- "Efectos reducidos" (Grupo 1, pulido): menos partículas, sin destello blanco ni temblor de
-- cámara y auras solo de cerca. Lo elige el jugador con el botón de ajustes (se guarda en el
-- servidor como atributo EfectosReducidos). Si nunca lo tocó, se reduce solo cuando la calidad
-- gráfica de Roblox está baja (compus y celulares modestos).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local jugador = Players.LocalPlayer
local E = GameConfig.Efectos

local Efectos = {}

local function calidadBaja(): boolean
	local ok, nivel = pcall(function(): number
		local ajustes = UserSettings():GetService("UserGameSettings") :: any
		return ajustes.SavedQualityLevel.Value -- 0 = automática, 1 a 10
	end)
	return ok and nivel > 0 and nivel <= E.CalidadParaReducir
end

function Efectos.reducidos(): boolean
	local elegido = jugador:GetAttribute("EfectosReducidos")
	if typeof(elegido) == "boolean" then
		return elegido
	end
	return calidadBaja()
end

function Efectos.distanciaAura(): number
	return if Efectos.reducidos() then E.DistanciaAuraReducida else E.DistanciaAura
end

-- Llama a `fn` cada vez que cambia el ajuste.
function Efectos.alCambiar(fn: (boolean) -> ()): RBXScriptConnection
	return jugador:GetAttributeChangedSignal("EfectosReducidos"):Connect(function()
		fn(Efectos.reducidos())
	end)
end

return Efectos
