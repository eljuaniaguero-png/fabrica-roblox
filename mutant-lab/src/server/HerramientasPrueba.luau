--!strict
-- Solo en modo prueba: una BindableFunction para darle especies a un jugador sin fusionar
-- (sirve para probar la Mutadex con muchas especies). No existe en el juego real.
-- Uso desde la consola del servidor:
--   game.ServerStorage.Prueba.DarEspecies:Invoke("NombreDelJugador", { "1-2", "3-4" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)

if Config.Prueba.Activo then
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Prueba"
	local dar = Instance.new("BindableFunction")
	dar.Name = "DarEspecies"
	dar.OnInvoke = function(nombre: string, claves: { string }): number
		local jugador = Players:FindFirstChild(nombre) :: Player?
		local d = jugador and Jugadores.obtener(jugador)
		if not jugador or not d then
			return 0
		end
		for _, clave in claves do
			d.Especies[clave] = true
		end
		Jugadores.publicar(jugador)
		return Jugadores.cantidadEspecies(d)
	end
	dar.Parent = carpeta
	carpeta.Parent = ServerStorage
end

return {}
