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
	PedirFusion = evento("PedirFusion"), -- cliente -> servidor: (claveA, claveB, personalidadA, personalidadB, catalizador?)
	ResultadoFusion = evento("ResultadoFusion"), -- servidor -> cliente: Fusion.Resultado
	Celebracion = evento("Celebracion"), -- servidor -> cliente: Fusion.Celebracion
	ComprarPista = evento("ComprarPista"), -- cliente -> servidor: (clave)
	Aviso = evento("Aviso"), -- servidor -> cliente: texto corto para mostrar
	Comprar = evento("Comprar"), -- cliente -> servidor: ("Base", número) o ("Mejora", nombre)
	Compra = evento("Compra"), -- servidor -> cliente: ("Base", número), ("Mejora", nombre, nivel) o ("Pista", clave) si salió bien
	EntregarPedido = evento("EntregarPedido"), -- cliente -> servidor: (lugar, { { Clave, Mutante } })
	DescartarPedido = evento("DescartarPedido"), -- cliente -> servidor: (lugar)
	Entrega = evento("Entrega"), -- servidor -> cliente: (lugar, pedido, criaturas) si se entregó
	CobrarDiario = evento("CobrarDiario"), -- cliente -> servidor: cobrar el premio diario
	Regreso = evento("Regreso"), -- servidor -> cliente: (ADN ganado sin estar, segundos afuera)
	-- Jugar con otros (Parte 9).
	Pasear = evento("Pasear"), -- cliente -> servidor: (clave) saca a pasear una criatura; nil la guarda
	ElegirEquipo = evento("ElegirEquipo"), -- servidor -> cliente: (lado) abre el selector de la máquina de equipo
	PonerEquipo = evento("PonerEquipo"), -- cliente -> servidor: (lado, clave, personalidad)
}

carpeta.Parent = ReplicatedStorage

return Remotos
