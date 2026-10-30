--!strict
-- Correr (pedido A1, 25/10/2026; reemplaza al dash). El cliente avisa "corro / no corro" con
-- Remotos.Correr; acá se valida (tipo, frecuencia, que no esté en La Forja) y se deja el atributo
-- "Corriendo" del jugador, que Velocidad.luau usa para poner el WalkSpeed. Velocidad deja la
-- velocidad permitida en el atributo "VelocidadPermitida".
-- Control simple: cada GameConfig.Correr.Intervalo se mide cuánto avanzó cada jugador (sin la
-- altura). Si va más rápido que lo permitido (con margen) varias veces seguidas, vuelve a la
-- última posición buena. Los teletransportes del servidor avisan con Correr.teletransportado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local C = GameConfig.Correr

local Correr = {}

type Control = {
	Muestra: Vector3?, -- dónde estaba en la última medición
	Buena: CFrame?, -- última posición sin exceso
	Avisos: number,
	MaxPermitida: number, -- la mayor velocidad permitida desde la última medición
}

local controles: { [Player]: Control } = {}
local avisos: { [Player]: { number } } = {} -- tiempos de los últimos pedidos (límite de frecuencia)

local function control(jugador: Player): Control
	local c = controles[jugador]
	if not c then
		c = { Muestra = nil, Buena = nil, Avisos = 0, MaxPermitida = 0 }
		controles[jugador] = c
	end
	return c
end

local function permitido(jugador: Player): boolean
	local ahora = os.clock()
	local lista = avisos[jugador] or {}
	avisos[jugador] = lista
	while lista[1] and ahora - lista[1] > 1 do
		table.remove(lista, 1)
	end
	if #lista >= C.AvisosPorSegundo then
		return false
	end
	table.insert(lista, ahora)
	return true
end

local function enForja(jugador: Player): boolean
	local d = Jugadores.obtener(jugador)
	return d ~= nil and d.ForjaPendiente ~= nil
end

local function alPedir(jugador: Player, quiere: unknown)
	if typeof(quiere) ~= "boolean" or not permitido(jugador) then
		return
	end
	jugador:SetAttribute("Corriendo", quiere and not enForja(jugador))
end

-- Lo llaman los que mueven al jugador desde el servidor (viajes, portales, renacer, bordes):
-- la próxima medición arranca desde el lugar nuevo.
function Correr.teletransportado(jugador: Player)
	local c = control(jugador)
	c.Muestra = nil
	c.Avisos = 0
end

-- Velocidad.luau avisa cada vez que cambia la velocidad permitida.
function Correr.permitida(jugador: Player, velocidad: number)
	local c = control(jugador)
	c.MaxPermitida = math.max(c.MaxPermitida, velocidad)
end

local function medir(jugador: Player)
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local c = control(jugador)
	if not (raiz and humanoide) or humanoide.Health <= 0 then
		c.Muestra = nil
		return
	end
	if jugador:GetAttribute("Corriendo") == true and enForja(jugador) then
		jugador:SetAttribute("Corriendo", false)
	end
	local ahora = Vector3.new(raiz.Position.X, 0, raiz.Position.Z)
	local actual = tonumber(jugador:GetAttribute("VelocidadPermitida")) or humanoide.WalkSpeed
	local tope = math.max(c.MaxPermitida, actual)
	c.MaxPermitida = actual
	local antes = c.Muestra
	c.Muestra = ahora
	if not antes then
		return
	end
	if (ahora - antes).Magnitude > tope * C.Intervalo * C.Margen + C.Extra then
		c.Avisos += 1
		if c.Avisos >= C.Avisos and c.Buena then
			raiz.AssemblyLinearVelocity = Vector3.zero
			personaje:PivotTo(c.Buena)
			c.Muestra = nil
			c.Avisos = 0
		end
	else
		c.Avisos = 0
		c.Buena = raiz.CFrame
	end
end

function Correr.iniciar()
	Remotos.Correr.OnServerEvent:Connect(alPedir)
	local function alEntrar(jugador: Player)
		jugador.CharacterAdded:Connect(function()
			jugador:SetAttribute("Corriendo", false)
			Correr.teletransportado(jugador)
		end)
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		controles[jugador] = nil
		avisos[jugador] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(C.Intervalo)
			for _, jugador in Players:GetPlayers() do
				medir(jugador)
			end
		end
	end)
end

return Correr
