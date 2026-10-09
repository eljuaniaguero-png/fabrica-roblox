--!strict
-- Anima en el cliente todas las criaturas (modelos con la etiqueta "Criatura").

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animacion = require(ReplicatedStorage.Shared.Animacion)
local Config = require(ReplicatedStorage.Shared.Config)

local estados: { [Model]: Animacion.Estado } = {}

local function agregar(inst: Instance)
	if not inst:IsA("Model") or not inst:IsDescendantOf(workspace) then
		return
	end
	-- Las criaturas que crea el servidor pueden avisar que llegaron antes que sus piezas:
	-- sin la raíz, el pivote da el centro del mapa. Se espera a la raíz y un ratito más
	-- para que lleguen las demás piezas (las usan los rasgos y los mutantes).
	if not inst.PrimaryPart then
		local inicio = os.clock()
		repeat
			task.wait()
		until inst.PrimaryPart or not inst.Parent or os.clock() - inicio > 5
		if not inst.PrimaryPart or not inst.Parent then
			return
		end
		task.wait(0.1)
	end
	estados[inst] = Animacion.preparar(inst)
end

CollectionService:GetInstanceAddedSignal("Criatura"):Connect(function(inst)
	task.spawn(agregar, inst)
end)
CollectionService:GetInstanceRemovedSignal("Criatura"):Connect(function(inst)
	estados[inst :: Model] = nil
end)
for _, inst in CollectionService:GetTagged("Criatura") do
	task.spawn(agregar, inst)
end

local DISTANCIA = Config.Animacion.DistanciaAnimar

RunService.RenderStepped:Connect(function(dt: number)
	local reloj = os.clock()
	local camara = workspace.CurrentCamera.CFrame.Position
	for modelo, estado in estados do
		if modelo.Parent then
			-- Las lejanas no se animan (rendimiento en celular); siguen donde quedaron.
			if (estado.Base.Position - camara).Magnitude < DISTANCIA then
				Animacion.paso(estado, reloj, dt)
			end
		else
			estados[modelo] = nil
		end
	end
end)
