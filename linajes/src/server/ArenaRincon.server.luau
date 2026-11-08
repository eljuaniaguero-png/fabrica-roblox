--!strict
-- Pone el rincón del puerto en el mundo. Si ya hay un workspace.Rincon guardado en el
-- place (Juani acomodó las piezas a mano en Studio), no toca nada: manda lo guardado.

local Armar = require(script.Parent.RinconArmar)

if not workspace:FindFirstChild("Rincon") then
	Armar.armar().Parent = workspace
end
