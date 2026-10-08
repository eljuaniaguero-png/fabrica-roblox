--!strict
-- Crea los remotos que usan el cliente y el servidor (ReplicatedStorage.Remotos).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local carpeta = Instance.new("Folder")
carpeta.Name = "Remotos"

local function evento(nombre: string): RemoteEvent
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = carpeta
	return r
end

local Remotos = {
	PedirFusion = evento("PedirFusion"), -- cliente -> servidor: (claveA, claveB)
	ResultadoFusion = evento("ResultadoFusion"), -- servidor -> cliente: Fusion.Resultado
}

carpeta.Parent = ReplicatedStorage

return Remotos
