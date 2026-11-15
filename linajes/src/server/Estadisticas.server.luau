--!strict
-- Árbol de estadísticas: el cliente pide subir una; acá se valida, se guarda y se aplica al
-- personaje (vida y energía máximas). Daño, defensa y recarga se leen al momento de usarse.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Estadisticas = require(ReplicatedStorage.Shared.Estadisticas)
local Perfiles = require(script.Parent.Perfiles)

local E = Config.Estadisticas

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Estadisticas"
remoto.Parent = ReplicatedStorage

local ultimo: { [Player]: number } = {}

-- Vida máxima nueva: conserva la vida que le faltaba (no cura de más ni mata).
local function aplicar(jugador: Player)
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if personaje and h and h.Health > 0 then
		local nueva = Estadisticas.vidaMax(personaje)
		local sube = nueva - h.MaxHealth
		h.MaxHealth = nueva
		if sube > 0 then
			h.Health = math.min(h.Health + sube, nueva)
		end
	end
end

remoto.OnServerEvent:Connect(function(jugador: Player, stat: unknown)
	local ahora = os.clock()
	if ahora - (ultimo[jugador] or 0) < E.Espera then
		return
	end
	ultimo[jugador] = ahora
	-- Validación: nombre conocido, datos cargados y que cumpla las reglas del árbol.
	if typeof(stat) ~= "string" or not table.find(E.Orden, stat) then
		return
	end
	local datos = Perfiles.datos(jugador)
	if not datos or not Estadisticas.puede(jugador, stat :: string) then
		return
	end
	datos.Stats[stat :: string] += 1
	Perfiles.cambiar(jugador, {}) -- refresca los atributos St_*
	aplicar(jugador)
end)

local function alEntrar(jugador: Player)
	jugador:GetAttributeChangedSignal("DatosListos"):Connect(function()
		aplicar(jugador)
	end)
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	alEntrar(jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	ultimo[jugador] = nil
end)
