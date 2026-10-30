--!strict
-- Contorno toon (shared/Toon.luau) de todo lo marcado con el tag "Toon". Lo pone cada cliente:
-- los cascos no viajan por la red y, con StreamingEnabled, solo existen cerca del jugador.
-- Si una pieza de un modelo marcado llega más tarde (streaming), recibe su casco al llegar.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Toon = require(ReplicatedStorage.Shared.Toon)

local conexiones: { [Instance]: RBXScriptConnection } = {}

local function agregar(raiz: Instance)
	if conexiones[raiz] then
		return
	end
	conexiones[raiz] = raiz.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") and not Toon.esContorno(d) and Toon.raizDe(d) == raiz then
			Toon.contornoParte(d, raiz:GetAttribute("ToonGrosor") :: number?)
		end
	end)
	Toon.contorno(raiz)
end

local function quitar(raiz: Instance)
	local c = conexiones[raiz]
	if c then
		c:Disconnect()
		conexiones[raiz] = nil
	end
end

CollectionService:GetInstanceAddedSignal(Toon.TAG):Connect(function(raiz)
	task.spawn(agregar, raiz)
end)
CollectionService:GetInstanceRemovedSignal(Toon.TAG):Connect(quitar)
for _, raiz in CollectionService:GetTagged(Toon.TAG) do
	task.spawn(agregar, raiz)
end
