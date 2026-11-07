--!strict
-- Guardado de cada jugador con ProfileStore: bloqueo de sesión y autoguardado incluidos.
-- Los datos se copian a atributos del Player para que el cliente pueda mostrarlos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ProfileStore = require(ServerStorage.ServerPackages.ProfileStore) :: any

local G = Config.Guardado
local almacen = ProfileStore.New(G.Almacen, {
	SchemaVersion = G.Version,
	Linaje = "",
	Fichas = 0,
	Bajas = 0,
	MejorRacha = 0,
})

local Perfiles = {}
local perfiles: { [Player]: any } = {}

local function mostrar(jugador: Player, datos: any)
	jugador:SetAttribute("Linaje", if datos.Linaje ~= "" then datos.Linaje else nil)
	jugador:SetAttribute("Fichas", datos.Fichas)
	jugador:SetAttribute("Bajas", datos.Bajas)
	jugador:SetAttribute("DatosListos", true)
end

function Perfiles.datos(jugador: Player): any?
	local p = perfiles[jugador]
	return p and p.Data
end

function Perfiles.cambiar(jugador: Player, campos: { [string]: any })
	local d = Perfiles.datos(jugador)
	if d then
		for k, v in campos do
			d[k] = v
		end
		mostrar(jugador, d)
	end
end

-- Baja en la arena: cuenta y cada tantas da una Ficha de Eclipse.
function Perfiles.sumarBaja(jugador: Player)
	local d = Perfiles.datos(jugador)
	if d then
		local bajas = d.Bajas + 1
		Perfiles.cambiar(jugador, {
			Bajas = bajas,
			Fichas = d.Fichas + (if bajas % Config.Ruleta.BajasPorFicha == 0 then 1 else 0),
		})
	end
end

local function alEntrar(jugador: Player)
	local perfil = almacen:StartSessionAsync("Jugador_" .. jugador.UserId, {
		Cancel = function()
			return jugador.Parent ~= Players
		end,
	})
	if not perfil then
		jugador:Kick("No pudimos cargar tu progreso. Volvé a entrar.")
		return
	end
	perfil:AddUserId(jugador.UserId)
	perfil:Reconcile()
	perfil.OnSessionEnd:Connect(function()
		perfiles[jugador] = nil
		jugador:Kick("Tu sesión se cerró. Volvé a entrar.")
	end)
	if jugador.Parent == Players then
		perfiles[jugador] = perfil
		mostrar(jugador, perfil.Data)
	else
		perfil:EndSession()
	end
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end
Players.PlayerRemoving:Connect(function(jugador)
	local p = perfiles[jugador]
	if p then
		p:EndSession()
	end
end)

return Perfiles
