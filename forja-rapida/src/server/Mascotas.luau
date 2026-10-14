--!strict
-- Mascotas y Ruleta de Mascotas (Grupo 4). La ruleta está en la plaza y se paga solo con
-- Monedas del juego (Reglas.precioRuleta): cada tirada da una mascota, con las chances de
-- GameConfig.Mascotas.Lista (suman 100 % y se ven siempre en el menú). Nada se compra con Robux.
--   Remotos.GirarRuleta     ()            cobra, tira y avisa cuál salió (Remotos.Ruleta). Si hay
--                                         lugar, la mascota nueva lo acompaña sola.
--   Remotos.EquiparMascota  (id, poner)   la suma o la saca de las que lo acompañan.
-- Las mascotas que lo acompañan dan sus bonos (Reglas.bonos) y las dibuja cada cliente
-- (client/Mascotas.client.luau), siguiendo al personaje.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local Mascotas = {}

local rng = Random.new()
local ultimaTirada: { [Player]: number } = {}
local ultimoEquipar: { [Player]: number } = {}

-- Rarezas que se anuncian a todo el servidor (Legendaria y Mítica).
local ANUNCIAR = { Legendario = true, Mitico = true }

local function girar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local t = os.clock()
	if ultimaTirada[jugador] and t - ultimaTirada[jugador] < GameConfig.Mascotas.Ruleta.Espera then
		return
	end
	local precio = Reglas.precioRuleta(d.Zonas)
	if d.Monedas < precio then
		Remotos.Aviso:FireClient(
			jugador,
			("Te faltan %s Monedas para la ruleta"):format(Formato.corto(precio - d.Monedas))
		)
		return
	end
	ultimaTirada[jugador] = t
	d.Monedas -= precio -- primero se cobra, después se tira
	local m = Reglas.tirarRuleta(function()
		return rng:NextNumber()
	end)
	d.Mascotas[m.Id] = (d.Mascotas[m.Id] or 0) + 1
	if Reglas.puedeEquipar(d.MascotasEquipadas, m.Id, d.Mascotas, Jugadores.bonos(d).Lugares) then
		table.insert(d.MascotasEquipadas, m.Id)
	end
	Jugadores.publicar(jugador)
	Remotos.Ruleta:FireClient(jugador, m.Id)
	local r = Reglas.rareza(m.Rareza)
	if ANUNCIAR[m.Rareza] and r then
		-- se anuncia cuando la ruleta ya frenó
		task.delay(GameConfig.Mascotas.Ruleta.Espera, function()
			Anuncios.enviar(
				("¡%s consiguió a %s (%s) en la Ruleta!"):format(
					jugador.DisplayName,
					m.Nombre,
					r.Nombre
				),
				r.Color,
				"Hallazgo",
				jugador
			)
		end)
	end
end

local function equipar(jugador: Player, id: unknown, poner: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(id) ~= "string" or typeof(poner) ~= "boolean" then
		return
	end
	local t = os.clock()
	if ultimoEquipar[jugador] and t - ultimoEquipar[jugador] < 0.2 then
		return
	end
	ultimoEquipar[jugador] = t
	if poner then
		if
			not Reglas.puedeEquipar(d.MascotasEquipadas, id, d.Mascotas, Jugadores.bonos(d).Lugares)
		then
			return
		end
		table.insert(d.MascotasEquipadas, id)
	else
		local i = table.find(d.MascotasEquipadas, id)
		if not i then
			return
		end
		table.remove(d.MascotasEquipadas, i)
	end
	Jugadores.publicar(jugador)
end

function Mascotas.iniciar()
	Remotos.GirarRuleta.OnServerEvent:Connect(girar)
	Remotos.EquiparMascota.OnServerEvent:Connect(equipar)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimaTirada[jugador] = nil
		ultimoEquipar[jugador] = nil
	end)
end

return Mascotas
