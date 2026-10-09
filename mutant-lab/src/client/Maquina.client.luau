--!strict
-- Une el panel, la máquina del mundo y el servidor.
-- El cliente solo pide la fusión; el servidor valida, cobra y decide el resultado.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Celebracion = require(script.Parent.Celebracion)
local EfectosMaquina = require(script.Parent.EfectosMaquina)
local Menus = require(script.Parent.UI.Menus)
local MiLab = require(script.Parent.MiLab)
local PanelFusion = require(script.Parent.PanelFusion)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local pedirFusion = remotos:WaitForChild("PedirFusion") :: RemoteEvent
local resultadoFusion = remotos:WaitForChild("ResultadoFusion") :: RemoteEvent
local celebracionEvento = remotos:WaitForChild("Celebracion") :: RemoteEvent
-- Solo se usa la máquina de tu laboratorio; los botones de los demás se apagan.
MiLab.apagarAjenos()
local prompt = MiLab.obtener()
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
		Menus.cerrarViejos()
		PanelFusion.abrir()
	end
end)

-- Las celebraciones (generación completa) esperan a que termine la animación de fusión.
local pendientes: { Fusion.Celebracion } = {}
local celebrando = false

local function mostrarPendientes()
	if celebrando then
		return
	end
	celebrando = true
	while #pendientes > 0 do
		Celebracion.mostrar(table.remove(pendientes, 1) :: Fusion.Celebracion)
	end
	celebrando = false
end

celebracionEvento.OnClientEvent:Connect(function(c: Fusion.Celebracion)
	table.insert(pendientes, c)
	task.wait(0.3)
	if not animando then
		mostrarPendientes()
	end
end)

resultadoFusion.OnClientEvent:Connect(function(r: Fusion.Resultado)
	if r.Ok or r.Motivo == "NoReaccionan" then
		animando = true
		PanelFusion.ocupada(true)
		PanelFusion.cerrar()
		EfectosMaquina.jugar(r)
		animando = false
		mostrarPendientes()
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
