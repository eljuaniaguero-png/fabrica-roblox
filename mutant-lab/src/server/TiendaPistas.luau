--!strict
-- Venta de pistas de las siluetas. El cliente pide la pista de una especie;
-- el servidor revisa que no la tengas, que queden pistas y que te alcance el ADN.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Pistas = require(ReplicatedStorage.Shared.Pistas)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local function comprar(jugador: Player, clave: unknown)
	if typeof(clave) ~= "string" or #clave > 12 then
		return
	end
	local d = Jugadores.obtener(jugador)
	local c = Fusion.porClave(clave :: string)
	if not d or not c then
		return
	end
	if d.Especies[c.Clave] then
		Remotos.Aviso:FireClient(jugador, "Esa especie ya la descubriste.")
		return
	end
	local ya = d.Pistas[c.Clave] or 0
	if ya >= Pistas.maximo(c) then
		Remotos.Aviso:FireClient(jugador, "Ya tenés todas las pistas de esta silueta.")
		return
	end
	local costo = Pistas.costo(d.PistasCompradas)
	if d.ADN < costo then
		Remotos.Aviso:FireClient(jugador, "Te falta ADN para la pista.")
		return
	end
	d.ADN -= costo
	d.Pistas[c.Clave] = ya + 1
	d.PistasCompradas += 1
	Jugadores.publicar(jugador)
end

Remotos.ComprarPista.OnServerEvent:Connect(comprar)

return {}
