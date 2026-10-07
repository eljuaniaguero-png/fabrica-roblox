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
	UsarConsumible = crear("UsarConsumible"),
	Aviso = crear("Aviso"), -- servidor -> cliente: texto corto y, opcional, el efecto de sonido a tocar
	SubioNivel = crear("SubioNivel"), -- servidor -> todos: (jugador, nivel nuevo)
	Comprar = crear("Comprar"), -- cliente -> servidor: (artículo) en el menú del vendedor
	VenderPasos = crear("VenderPasos"), -- cliente -> servidor: vende todos los pasos disponibles
	Pisada = crear("Pisada"), -- cliente -> servidor: (baldosa) que acaba de pisar
	Baldosa = crear("Baldosa"), -- servidor -> cliente: ("encender", clave, nota), ("apagar", clave) o ("dorada", clave)
	Celebrar = crear("Celebrar"), -- servidor -> cliente: ("hito", combo, monedas), ("cancion", título, monedas) o ("dorada", monedas)
}

carpeta.Parent = ReplicatedStorage

-- `sonido` es una clave de Config.Efectos (por ejemplo "Compra"). El cliente lo toca.
function Remotos.avisar(jugador: Player, texto: string, sonido: string?)
	Remotos.Aviso:FireClient(jugador, texto, sonido)
end

return Remotos
