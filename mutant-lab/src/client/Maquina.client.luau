--!strict
-- Une el panel, la máquina del mundo y el servidor.
-- El cliente solo pide la fusión; el servidor valida, cobra y decide el resultado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Celebracion = require(script.Parent.Celebracion)
local EfectosMaquina = require(script.Parent.EfectosMaquina)
local MiLab = require(script.Parent.MiLab)
local PanelFusion = require(script.Parent.PanelFusion)

local jugador = Players.LocalPlayer
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
	SinCatalizador = "No tenés ese catalizador.",
}

local animando = false

local function cantidadEspecies(): number
	local n = 0
	for _ in Formato.conjunto(jugador:GetAttribute("Especies") :: string?) do
		n += 1
	end
	return n
end

local function ranuraAbierta(): boolean
	return cantidadEspecies() >= Config.Residuos.RanuraDesde
end

PanelFusion.iniciar({
	AlElegir = function(lado, e)
		EfectosMaquina.mostrarEnCapsula(lado, e and e.Clave, e and e.Personalidad)
	end,
	AlCatalizador = function(clave)
		local cat = Catalizadores.porClave(clave)
		EfectosMaquina.ranura(ranuraAbierta(), if cat then cat.Color else nil)
	end,
	AlConfirmar = function(a, b, catalizador)
		if animando then
			return
		end
		PanelFusion.ocupada(true)
		-- El contador de la Mutadex espera a la revelación (lo suelta EfectosMaquina).
		jugador:SetAttribute("RetenerProgreso", true)
		-- Por si el servidor no contesta: el contador no queda trabado.
		task.delay(12, function()
			if not animando then
				jugador:SetAttribute("RetenerProgreso", nil)
			end
		end)
		pedirFusion:FireServer(a.Clave, b.Clave, a.Personalidad, b.Personalidad, catalizador)
	end,
})

prompt.Triggered:Connect(function()
	if not animando then
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

local function encolar(c: Fusion.Celebracion)
	table.insert(pendientes, c)
	task.wait(0.3)
	if not animando then
		mostrarPendientes()
	end
end

celebracionEvento.OnClientEvent:Connect(encolar)

-- Al llegar a Config.Residuos.RanuraDesde especies (fusionando o comprando) se abre la ranura
-- de catalizador: un cartel la explica (después de la animación, si hay una).
local especiesAntes = cantidadEspecies()
EfectosMaquina.ranura(ranuraAbierta())
jugador:GetAttributeChangedSignal("Especies"):Connect(function()
	local ahora = cantidadEspecies()
	local abre = especiesAntes < Config.Residuos.RanuraDesde
		and ahora >= Config.Residuos.RanuraDesde
	especiesAntes = ahora
	EfectosMaquina.ranura(ranuraAbierta())
	if abre then
		encolar({ Gen = 0, Premio = 0, Completo = false, Novedad = "Ranura" })
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
		end
		PanelFusion.abrir()
	else
		jugador:SetAttribute("RetenerProgreso", nil)
		PanelFusion.aviso(MENSAJES[r.Motivo or ""] or "")
	end
	if not animando then
		PanelFusion.ocupada(false)
	end
end)
