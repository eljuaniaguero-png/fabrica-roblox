--!strict
-- Ruleta de Linajes. El azar y las Fichas viven acá. Ninguna tirada se vende por Robux.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Perfiles = require(script.Parent.Perfiles)

local R = Config.Ruleta

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Ruleta"
remoto.Parent = ReplicatedStorage

local azar = Random.new()
local ultimo: { [Player]: number } = {}

local function sortear(): string
	local total = 0
	for _, o in R.Opciones do
		if o.Disponible then
			total += o.Peso
		end
	end
	local tiro = azar:NextNumber(0, total)
	for _, o in R.Opciones do
		if o.Disponible then
			tiro -= o.Peso
			if tiro <= 0 then
				return o.Linaje
			end
		end
	end
	return R.Opciones[1].Linaje
end

remoto.OnServerEvent:Connect(function(jugador, pedido)
	if pedido ~= "Tirar" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimo[jugador] or 0) < R.Espera then
		return
	end
	local d = Perfiles.datos(jugador)
	if not d then
		return
	end
	local gratis = d.Linaje == ""
	if not gratis and d.Fichas < 1 then
		return
	end
	ultimo[jugador] = ahora
	local linaje = sortear()
	Perfiles.cambiar(
		jugador,
		{ Linaje = linaje, Fichas = if gratis then d.Fichas else d.Fichas - 1 }
	)
	remoto:FireClient(jugador, linaje)
end)
