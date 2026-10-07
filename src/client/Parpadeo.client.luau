--!strict
-- Luces que titilan (solo visual): toda BasePart con atributo Parpadeo = segundos de cada ciclo
-- (antenas de la ciudad, farolitos de las nubes, estrellas). Un solo bucle para todas.

local RunService = game:GetService("RunService")

local luces: { [BasePart]: { periodo: number, fase: number } } = {}

local function registrar(objeto: Instance)
	local periodo = objeto:GetAttribute("Parpadeo")
	if objeto:IsA("BasePart") and typeof(periodo) == "number" and periodo > 0 then
		luces[objeto] = { periodo = periodo, fase = math.random() * periodo }
	end
end

for _, objeto in workspace:GetDescendants() do
	registrar(objeto)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		luces[objeto] = nil
	end
end)

local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 1 / 20 then -- 20 veces por segundo alcanza
		return
	end
	acumulado = 0
	local ahora = os.clock()
	for parte, datos in luces do
		local onda = math.sin((ahora + datos.fase) / datos.periodo * math.pi * 2)
		parte.Transparency = 0.35 - onda * 0.35 -- entre 0 (pleno) y 0.7
	end
end)
