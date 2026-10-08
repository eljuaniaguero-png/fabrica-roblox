--!strict
-- Une el panel, la máquina del mundo y el servidor.
-- El cliente solo pide la fusión; el servidor valida, cobra y decide el resultado.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)
local EfectosMaquina = require(script.Parent.EfectosMaquina)
local PanelFusion = require(script.Parent.PanelFusion)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local pedirFusion = remotos:WaitForChild("PedirFusion") :: RemoteEvent
local resultadoFusion = remotos:WaitForChild("ResultadoFusion") :: RemoteEvent
local prompt = workspace
	:WaitForChild("Laboratorio")
	:WaitForChild("Maquina")
	:WaitForChild("Consola")
	:WaitForChild("Prompt") :: ProximityPrompt

local MENSAJES = {
	FaltaADN = "Te falta ADN para esta fusión.",
	NoTenes = "Esa criatura no es tuya.",
	Ocupada = "La máquina todavía está trabajando.",
}

local animando = false

PanelFusion.iniciar({
	AlElegir = function(lado, clave)
		EfectosMaquina.mostrarEnCapsula(lado, clave)
	end,
	AlConfirmar = function(a, b)
		if animando then
			return
		end
		PanelFusion.ocupada(true)
		pedirFusion:FireServer(a, b)
	end,
})

prompt.Triggered:Connect(function()
	if not animando then
		PanelFusion.abrir()
	end
end)

resultadoFusion.OnClientEvent:Connect(function(r: Fusion.Resultado)
	if r.Ok or r.Motivo == "NoReaccionan" then
		animando = true
		PanelFusion.ocupada(true)
		PanelFusion.cerrar()
		EfectosMaquina.jugar(r)
		animando = false
		if r.Ok then
			PanelFusion.limpiar()
		else
			PanelFusion.aviso("No reaccionan: probá con otra pareja.")
		end
		PanelFusion.abrir()
	else
		PanelFusion.aviso(MENSAJES[r.Motivo or ""] or "")
	end
	if not animando then
		PanelFusion.ocupada(false)
	end
end)
