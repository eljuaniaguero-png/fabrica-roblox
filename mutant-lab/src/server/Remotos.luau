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
	Celebracion = evento("Celebracion"), -- servidor -> cliente: Fusion.Celebracion
	ComprarPista = evento("ComprarPista"), -- cliente -> servidor: (clave)
	Aviso = evento("Aviso"), -- servidor -> cliente: texto corto para mostrar
	Comprar = evento("Comprar"), -- cliente -> servidor: ("Base", número) o ("Mejora", nombre)
	Compra = evento("Compra"), -- servidor -> cliente: ("Base", número), ("Mejora", nombre, nivel) o ("Pista", clave) si salió bien
}

carpeta.Parent = ReplicatedStorage

return Remotos
