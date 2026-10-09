--!strict
-- Cada segundo, las criaturas activas de cada jugador generan ADN según su generación.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Jugadores = require(script.Parent.Jugadores)

local Economia = {}

function Economia.iniciar()
	task.spawn(function()
		while true do
			task.wait(1)
			for jugador, d in Jugadores.todos() do
				local activas = Mejoras.activas(d.Criaturas, d.Mejoras.Corrales)
				local porSegundo = Mejoras.porSegundo(activas, d.Mejoras.Nutrientes)
				d.ADN += porSegundo
				jugador:SetAttribute("ADN", math.floor(d.ADN))
				jugador:SetAttribute("ADNPorSegundo", porSegundo)
			end
		end
	end)
end

return Economia
