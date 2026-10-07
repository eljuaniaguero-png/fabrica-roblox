--!strict
-- Tubos de luz: en cada checkpoint, uno que te baja a la plaza; en la plaza, uno que te devuelve
-- a tu último checkpoint. El servidor hace el viaje (Puertas.luau).
--
-- En el mapa: BasePart con atributo Tubo = "Bajar" | "Subir" y un ProximityPrompt adentro
-- (los arma GeneradorTorre.luau).

local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)

local Tubos = {}

local function alUsar(tipo: string, jugador: Player)
	local checkpoint = jugador:GetAttribute("Checkpoint")
	if tipo == "Bajar" then
		Puertas.irAPlaza(jugador)
		-- SONIDO: viaje por el tubo (Config.Efectos.Puerta)
		Remotos.avisar(jugador, "A la plaza", "Puerta")
	elseif typeof(checkpoint) == "number" and checkpoint > 0 then
		Puertas.teletransportar(jugador)
		-- SONIDO: viaje por el tubo (Config.Efectos.Puerta)
		Remotos.avisar(jugador, `De vuelta al checkpoint {checkpoint}`, "Puerta")
	else
		Remotos.avisar(jugador, "Todavía no tenés checkpoint", "Error")
	end
end

function Tubos.iniciar()
	for _, parte in workspace:GetDescendants() do
		local tipo = parte:GetAttribute("Tubo")
		if parte:IsA("BasePart") and typeof(tipo) == "string" then
			local aviso = parte:FindFirstChildWhichIsA("ProximityPrompt")
			if aviso then
				aviso.Triggered:Connect(function(jugador)
					alUsar(tipo, jugador)
				end)
			end
		end
	end
end

return Tubos
