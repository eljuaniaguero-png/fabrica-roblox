--!strict
-- Encuentra el laboratorio que el servidor le asignó a este jugador (atributo "Laboratorio").

local Players = game:GetService("Players")

local jugador = Players.LocalPlayer

local MiLab = {}

-- Espera hasta que el servidor asigne el laboratorio y lo devuelve.
function MiLab.obtener(): Model
	local nombre = jugador:GetAttribute("Laboratorio") :: string?
	while not nombre do
		jugador:GetAttributeChangedSignal("Laboratorio"):Wait()
		nombre = jugador:GetAttribute("Laboratorio") :: string?
	end
	return workspace:WaitForChild("Laboratorios"):WaitForChild(nombre :: string) :: Model
end

-- Apaga (solo para vos) los botones de los laboratorios de los demás: de visita se mira, pero
-- no se toca nada. El único que queda es el "me gusta" (y ese, en el tuyo, se apaga).
function MiLab.apagarAjenos()
	local mio = MiLab.obtener()
	for _, lab in workspace:WaitForChild("Laboratorios"):GetChildren() do
		for _, d in lab:GetDescendants() do
			if d:IsA("ProximityPrompt") then
				local meGusta = d.Name == "MeGusta"
				if lab ~= mio then
					d.Enabled = meGusta
				elseif meGusta then
					d.Enabled = false
				end
			end
		end
	end
end

return MiLab
