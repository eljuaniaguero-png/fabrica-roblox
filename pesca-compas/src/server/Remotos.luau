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
	Lanzar = evento("Lanzar"), -- cliente -> servidor: (carga 0..1) tirar la caña cerca de un PuntoPesca
	Toques = evento("Toques"), -- cliente -> servidor: (token, { number }) segundos desde la 1ª nota
	Cancelar = evento("Cancelar"), -- cliente -> servidor: () recoger la caña mientras espera
	-- servidor -> cliente: ("Lanzado" | "Pico" | "Resultado" | "Cancelado", datos?)
	Pesca = evento("Pesca"),
	Mejorar = evento("Mejorar"), -- cliente -> servidor: ("Cana" | "Balde")
	Calibrar = evento("Calibrar"), -- cliente -> servidor: (desfase en segundos)
	Estado = evento("Estado"), -- servidor -> cliente: (datos visibles) cada vez que cambian
	Aviso = evento("Aviso"), -- servidor -> cliente: (texto) mensaje corto
	-- servidor -> cliente: ("Mision" | "Diario", { Texto, Escamas, Racha? }) tarjeta de premio
	Premio = evento("Premio"),
}

carpeta.Parent = ReplicatedStorage

return Remotos
