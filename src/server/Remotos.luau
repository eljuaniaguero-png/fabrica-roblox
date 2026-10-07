--!strict
-- Crea los RemoteEvents en ReplicatedStorage.Remotos. El cliente pide; el servidor valida.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local carpeta = Instance.new("Folder")
carpeta.Name = "Remotos"

local function crear(nombre: string): RemoteEvent
	local remoto = Instance.new("RemoteEvent")
	remoto.Name = nombre
	remoto.Parent = carpeta
	return remoto
end

local Remotos = {
	PedirRebirth = crear("PedirRebirth"),
	Convertir = crear("Convertir"),
	Comprar = crear("Comprar"),
	UsarConsumible = crear("UsarConsumible"),
	Aviso = crear("Aviso"), -- servidor -> cliente: texto corto para mostrar en pantalla
}

carpeta.Parent = ReplicatedStorage

function Remotos.avisar(jugador: Player, texto: string)
	Remotos.Aviso:FireClient(jugador, texto)
end

return Remotos
