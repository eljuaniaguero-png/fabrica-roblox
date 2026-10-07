--!strict
-- Rebirth en el portal del mapa: convierte toda tu velocidad en monedas, sube el multiplicador
-- y te manda al inicio. El servidor valida todo.
--
-- En el mapa: BasePart con atributo PortalRebirth = true y un ProximityPrompt adentro.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Datos = require(script.Parent.Datos)
local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Rebirth = {}

local ultimoPedido: { [Player]: number } = {}

local function alPedir(jugador: Player)
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < Config.EsperaRebirth then
		return
	end
	ultimoPedido[jugador] = ahora

	local perfil = Datos.obtener(jugador)
	if not perfil then
		return
	end
	if perfil.Velocidad < Config.CostoRebirth then
		Remotos.avisar(jugador, `Necesitás {Config.CostoRebirth} de velocidad`, "Error")
		return
	end

	local ganadas = Precios.monedasPorRebirth(perfil.Velocidad, perfil.Mejoras.Bolsillo or 0)
	perfil.Monedas += ganadas
	perfil.Velocidad = 0
	perfil.Rebirths += 1
	perfil.Checkpoint = 0
	Velocidad.aplicar(jugador)
	Puertas.actualizarNivel(jugador)
	Puertas.teletransportar(jugador)
	-- SONIDO: rebirth (Config.Efectos.Rebirth)
	Remotos.avisar(
		jugador,
		`¡Rebirth! +{ganadas} monedas · ahora x{Velocidad.multiplicador(perfil)}`,
		"Rebirth"
	)
end

function Rebirth.iniciar()
	for _, parte in workspace:GetDescendants() do
		if parte:IsA("BasePart") and parte:GetAttribute("PortalRebirth") == true then
			local aviso = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
			if aviso then
				aviso.Triggered:Connect(alPedir)
			else
				warn(`[Rebirth] {parte:GetFullName()} no tiene ProximityPrompt`)
			end
		end
	end
end

function Rebirth.olvidar(jugador: Player)
	ultimoPedido[jugador] = nil
end

return Rebirth
