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

-- Para avisos que se repiten mucho y pueden perderse sin problema (números flotantes).
local function eventoRapido(nombre: string): UnreliableRemoteEvent
	local r = Instance.new("UnreliableRemoteEvent")
	r.Name = nombre
	r.Parent = carpeta
	return r
end

local Remotos = {
	Golpear = evento("Golpear"), -- cliente -> servidor: (geoda: Model) "le pegué a esta geoda"
	Golpe = eventoRapido("Golpe"), -- servidor -> cliente: (geoda, daño, vida que le queda)
	Revelacion = evento("Revelacion"), -- servidor -> cliente: GeodeServerService.Revelacion
	Aviso = evento("Aviso"), -- servidor -> cliente: texto corto para mostrar
	-- Grupo 1
	Anuncio = evento("Anuncio"), -- servidor -> todos: (texto, color hex) algo rarísimo pasó
	Ajustes = evento("Ajustes"), -- cliente -> servidor: (nombre del ajuste, boolean); ver Jugadores
	-- Grupos 6 y 7
	Hitos = evento("Hitos"), -- servidor -> cliente: { Descubrimientos.Hito } fuera de una revelación
	Premio = evento("Premio"), -- servidor -> cliente: (monedas, posición?) "+X" que salta
	ElegirTitulo = evento("ElegirTitulo"), -- cliente -> servidor: (Id del título)
	ElegirVitrina = evento("ElegirVitrina"), -- cliente -> servidor: (Id de la gema)
	-- Banco y Tienda (Economia.luau)
	Vender = evento("Vender"), -- cliente -> servidor: () vender toda la mochila
	Comprar = evento("Comprar"), -- cliente -> servidor: ("Fuerza" | "FuerzaMax" | "Pico" | "Amuleto")
	Compra = evento("Compra"), -- servidor -> cliente: (tipo, nombre) salió bien la compra o venta
}

carpeta.Parent = ReplicatedStorage

return Remotos
