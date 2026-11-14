--!strict
-- Cada personaje que aparece (StarterCharacter = cuerpo propio, nunca el avatar de Roblox) se
-- arma con la apariencia guardada del jugador. El creador de personaje (client/Creador) pide
-- cambios por el remoto "Creador"; acá se validan, se guardan y se vuelve a vestir.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CuerpoComic = require(script.Parent.CuerpoComic)
local Perfiles = require(script.Parent.Perfiles)

local CR = Config.Cuerpo.Creador

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Creador"
remoto.Parent = ReplicatedStorage

-- Cuántas opciones tiene cada campo (el valor va de 1 a este número).
local MAXIMOS: { [string]: number } = {
	Piel = #Config.Cuerpo.TonosPiel,
	Cara = #Config.Cuerpo.Comic.Caras,
	Peinado = #Config.Cuerpo.Comic.Peinados,
	Pelo = #Config.Cuerpo.ColoresPelo,
	Campera = #CR.Campera,
	Acento = #CR.Acento,
	Pantalon = #CR.Pantalon,
}

local ultimoCambio: { [Player]: number } = {}

local function vestir(jugador: Player)
	local personaje = jugador.Character
	local datos = Perfiles.datos(jugador)
	if personaje and datos then
		CuerpoComic.vestir(personaje, jugador.UserId, datos.Apariencia)
	end
end

local function alAparecer(jugador: Player, personaje: Model)
	-- Los datos pueden tardar un poco en cargar al entrar: hasta entonces, al azar fijo.
	if not Perfiles.datos(jugador) then
		CuerpoComic.vestir(personaje, jugador.UserId)
		local inicio = os.clock()
		while not Perfiles.datos(jugador) and os.clock() - inicio < 15 and personaje.Parent do
			task.wait(0.25)
		end
	end
	if personaje.Parent then
		vestir(jugador)
	end
end

remoto.OnServerEvent:Connect(function(jugador: Player, campo: unknown, valor: unknown)
	local ahora = os.clock()
	if ahora - (ultimoCambio[jugador] or 0) < CR.Espera then
		return
	end
	ultimoCambio[jugador] = ahora
	local datos = Perfiles.datos(jugador)
	if not datos then
		return
	end
	if campo == "Confirmar" then
		datos.Apariencia.Creada = true
		Perfiles.cambiar(jugador, {})
		return
	end
	-- Validación: campo conocido y número entero dentro del rango.
	if typeof(campo) ~= "string" or typeof(valor) ~= "number" then
		return
	end
	local maximo = MAXIMOS[campo :: string]
	local n = valor :: number
	if not maximo or n ~= n or n % 1 ~= 0 or n < 1 or n > maximo then
		return
	end
	datos.Apariencia[campo :: string] = n
	Perfiles.cambiar(jugador, {}) -- refresca los atributos Ap_*
	vestir(jugador)
end)

local function alEntrar(jugador: Player)
	jugador.CharacterAdded:Connect(function(personaje)
		alAparecer(jugador, personaje)
	end)
	if jugador.Character then
		task.spawn(alAparecer, jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	ultimoCambio[jugador] = nil
end)
