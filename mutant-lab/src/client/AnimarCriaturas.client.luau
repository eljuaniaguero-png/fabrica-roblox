--!strict
-- Anima en el cliente todas las criaturas (modelos con la etiqueta "Criatura").

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animacion = require(ReplicatedStorage.Shared.Animacion)

local estados: { [Model]: Animacion.Estado } = {}

local function agregar(inst: Instance)
	if inst:IsA("Model") and inst:IsDescendantOf(workspace) then
		estados[inst] = Animacion.preparar(inst)
	end
end

CollectionService:GetInstanceAddedSignal("Criatura"):Connect(agregar)
CollectionService:GetInstanceRemovedSignal("Criatura"):Connect(function(inst)
	estados[inst :: Model] = nil
end)
for _, inst in CollectionService:GetTagged("Criatura") do
	agregar(inst)
end

RunService.RenderStepped:Connect(function()
	local reloj = os.clock()
	for modelo, estado in estados do
		if modelo.Parent then
			Animacion.paso(estado, reloj)
		else
			estados[modelo] = nil
		end
	end
end)
