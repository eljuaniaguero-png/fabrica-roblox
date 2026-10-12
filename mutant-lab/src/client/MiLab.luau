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
-- Con StreamingEnabled los laboratorios ajenos llegan (y vuelven a llegar) cuando te acercás,
-- así que también se revisa todo botón que aparece después.
function MiLab.apagarAjenos()
	local mio = MiLab.obtener()
	local carpeta = workspace:WaitForChild("Laboratorios")
	local function revisar(d: Instance)
		if not d:IsA("ProximityPrompt") then
			return
		end
		-- El laboratorio es el hijo de la carpeta que contiene al botón.
		local lab: Instance? = d
		while lab and lab.Parent ~= carpeta do
			lab = lab.Parent
		end
		local meGusta = d.Name == "MeGusta"
		if lab ~= mio then
			d.Enabled = meGusta
		elseif meGusta then
			d.Enabled = false
		end
	end
	for _, d in carpeta:GetDescendants() do
		revisar(d)
	end
	carpeta.DescendantAdded:Connect(revisar)
end

return MiLab
