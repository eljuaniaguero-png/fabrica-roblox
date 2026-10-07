--!strict
-- Solo en Studio: un BindableFunction en ServerStorage para que las pruebas automáticas puedan
-- dar monedas o pasos a un jugador. Los clientes no lo ven y en el juego publicado no existe.
--   ServerStorage.Pruebas:Invoke("monedas", jugador, cantidad)
--   ServerStorage.Pruebas:Invoke("pasos", jugador, cantidad)
--   ServerStorage.Pruebas:Invoke("checkpoint", jugador, número)

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Datos = require(script.Parent.Datos)
local Puertas = require(script.Parent.Puertas)
local Velocidad = require(script.Parent.Velocidad)

local Pruebas = {}

function Pruebas.iniciar()
	if not RunService:IsStudio() then
		return
	end
	local funcion = Instance.new("BindableFunction")
	funcion.Name = "Pruebas"
	funcion.OnInvoke = function(accion: string, jugador: Player, cantidad: number)
		local perfil = Datos.obtener(jugador)
		if not perfil then
			return "sin perfil"
		end
		if accion == "monedas" then
			perfil.Monedas += cantidad
		elseif accion == "pasos" then
			perfil.PasosTotales += cantidad
			Puertas.actualizarNivel(jugador)
		elseif accion == "checkpoint" then
			perfil.Checkpoint = cantidad
		end
		Velocidad.aplicar(jugador)
		return "ok"
	end
	funcion.Parent = ServerStorage
end

return Pruebas
