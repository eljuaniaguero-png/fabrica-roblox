--!strict
-- Usar consumibles del inventario y agarrar los que están en el mapa.
-- En el mapa: BasePart con atributo Recolectable = "Turbo" | "Resorte" | "Escudo".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Datos = require(script.Parent.Datos)
local Efectos = require(script.Parent.Efectos)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Consumibles = {}

local function usar(jugador: Player, nombre: unknown)
	local perfil = Datos.obtener(jugador)
	if not perfil or typeof(nombre) ~= "string" then
		return
	end
	local consumible = Config.Consumibles[nombre]
	if not consumible or not consumible.Usable or not consumible.Duracion then
		return
	end
	if (perfil.Inventario[nombre] or 0) <= 0 then
		return
	end

	perfil.Inventario[nombre] -= 1
	local hasta = Efectos.activar(jugador, nombre, consumible.Duracion)
	jugador:SetAttribute(`Hasta_{nombre}`, hasta)
	Velocidad.aplicar(jugador)
	-- SONIDO: usar consumible (Turbo / Resorte)
	Remotos.avisar(jugador, `¡{consumible.Nombre} activado!`)

	-- Cuando se termina, volver a aplicar para sacar el efecto (por ejemplo, el salto alto).
	task.delay(hasta - workspace:GetServerTimeNow() + 0.1, function()
		if jugador.Parent and not Efectos.activo(jugador, nombre) then
			Velocidad.aplicar(jugador)
		end
	end)
end

local function prepararRecolectable(parte: BasePart, nombre: string)
	local consumible = Config.Consumibles[nombre]
	if not consumible then
		warn(`[Consumibles] Recolectable desconocido: {nombre}`)
		return
	end
	local transparenciaOriginal = parte.Transparency
	local disponible = true

	parte.Touched:Connect(function(otra)
		if not disponible then
			return
		end
		local personaje = otra.Parent
		local jugador = if personaje then Players:GetPlayerFromCharacter(personaje) else nil
		local perfil = if jugador then Datos.obtener(jugador) else nil
		if not jugador or not perfil then
			return
		end
		if (perfil.Inventario[nombre] or 0) >= Config.InventarioMaximo then
			return
		end

		disponible = false
		perfil.Inventario[nombre] = (perfil.Inventario[nombre] or 0) + 1
		Velocidad.aplicar(jugador)
		-- SONIDO: agarrar consumible del mapa
		Remotos.avisar(jugador, `+1 {consumible.Nombre}`)

		parte.Transparency = 1
		for _, hijo in parte:GetDescendants() do
			if hijo:IsA("BillboardGui") or hijo:IsA("ParticleEmitter") then
				hijo.Enabled = false
			end
		end
		task.delay(Config.ReaparicionConsumible, function()
			parte.Transparency = transparenciaOriginal
			for _, hijo in parte:GetDescendants() do
				if hijo:IsA("BillboardGui") or hijo:IsA("ParticleEmitter") then
					hijo.Enabled = true
				end
			end
			disponible = true
		end)
	end)
end

function Consumibles.iniciar()
	Remotos.UsarConsumible.OnServerEvent:Connect(usar)
	for _, parte in workspace:GetDescendants() do
		local nombre = parte:GetAttribute("Recolectable")
		if parte:IsA("BasePart") and typeof(nombre) == "string" then
			prepararRecolectable(parte, nombre)
		end
	end
end

function Consumibles.olvidar(jugador: Player)
	Efectos.olvidar(jugador)
end

return Consumibles
