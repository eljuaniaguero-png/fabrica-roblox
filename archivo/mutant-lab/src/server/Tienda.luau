--!strict
-- Tienda del laboratorio: especies base (precio creciente), copias de las bases que ya
-- descubriste (para pedidos o si entregaste la tuya) y mejoras.
-- El cliente pide ("Base", número) o ("Mejora", nombre); el servidor valida y cobra.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Coleccion = require(script.Parent.Coleccion)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

-- Lo que pasó con una compra.
export type Compra = {
	Ok: boolean,
	Motivo: string?, -- "FaltaADN", "Maximo" o "NoExiste"
	Copia: boolean?, -- era otra copia de una base que ya tenías
	Precio: number?,
	Nivel: number?, -- nivel nuevo de la mejora
	Celebraciones: { Fusion.Celebracion },
}

local Tienda = {}

-- Precio de una base (nueva o copia) para estos datos; nil si no se puede comprar.
function Tienda.precioBase(d: Jugadores.Datos, n: number): (number?, boolean)
	local copia = d.Especies[tostring(n)] == true
	if copia then
		return Mejoras.precioCopia(Jugadores.cantidadEspecies(d)), true
	end
	return Mejoras.precioBase(Jugadores.cantidadBases(d), Jugadores.cantidadEspecies(d)), false
end

-- Las reglas de la compra sobre los datos de un jugador, sin avisarle a nadie (también la usa
-- el simulador de balance).
function Tienda.aplicar(d: Jugadores.Datos, tipo: unknown, id: unknown): Compra
	if tipo == "Base" and typeof(id) == "number" then
		local n = id :: number
		if n ~= math.floor(n) or n < 1 or n > Config.TamanioRueda then
			return { Ok = false, Motivo = "NoExiste", Celebraciones = {} }
		end
		local precio, copia = Tienda.precioBase(d, n)
		if not precio then
			return { Ok = false, Motivo = "Maximo", Celebraciones = {} }
		end
		if d.ADN < precio then
			return {
				Ok = false,
				Motivo = "FaltaADN",
				Precio = precio,
				Copia = copia,
				Celebraciones = {},
			}
		end
		d.ADN -= precio
		local celebraciones = {}
		if not copia then
			Coleccion.agregar(d, tostring(n))
			celebraciones = Coleccion.revisarGeneraciones(d)
		end
		Jugadores.agregarCriatura(d, tostring(n), false)
		return { Ok = true, Copia = copia, Precio = precio, Celebraciones = celebraciones }
	elseif tipo == "Mejora" and typeof(id) == "string" then
		local nombre = id :: string
		if not (Config.Mejoras :: any)[nombre] then
			return { Ok = false, Motivo = "NoExiste", Celebraciones = {} }
		end
		local niveles = d.Mejoras :: any
		local nivel = niveles[nombre] :: number
		local precio = Mejoras.precio(nombre, nivel, Jugadores.cantidadEspecies(d))
		if not precio then
			return { Ok = false, Motivo = "Maximo", Celebraciones = {} }
		end
		if d.ADN < precio then
			return { Ok = false, Motivo = "FaltaADN", Precio = precio, Celebraciones = {} }
		end
		d.ADN -= precio
		niveles[nombre] = nivel + 1
		return { Ok = true, Precio = precio, Nivel = nivel + 1, Celebraciones = {} }
	end
	return { Ok = false, Motivo = "NoExiste", Celebraciones = {} }
end

local function aviso(jugador: Player, texto: string)
	Remotos.Aviso:FireClient(jugador, texto)
end

-- Compra ("Base", número) o ("Mejora", nombre) y le avisa al jugador. También la usa el
-- jugador automático de prueba.
function Tienda.comprar(jugador: Player, tipo: unknown, id: unknown): boolean
	local d = Jugadores.obtener(jugador)
	if not d then
		return false
	end
	local r = Tienda.aplicar(d, tipo, id)
	if tipo == "Base" and typeof(id) == "number" and Especies[id :: number] then
		local nombre = Especies[id :: number].Nombre
		if r.Motivo == "FaltaADN" then
			aviso(
				jugador,
				"Te falta ADN: " .. nombre .. " cuesta " .. Formato.numero(r.Precio or 0) .. "."
			)
		elseif r.Ok then
			aviso(
				jugador,
				if r.Copia
					then "¡Otra " .. nombre .. " llegó a tu laboratorio!"
					else "¡" .. nombre .. " llegó a tu laboratorio!"
			)
		end
	elseif tipo == "Mejora" and typeof(id) == "string" then
		local def = (Config.Mejoras :: any)[id :: string]
		if def and r.Motivo == "Maximo" then
			aviso(jugador, def.Nombre .. " ya está al máximo.")
		elseif def and r.Motivo == "FaltaADN" then
			aviso(jugador, "Te falta ADN para " .. def.Nombre .. ".")
		elseif def and r.Ok then
			aviso(jugador, "¡" .. def.Nombre .. " nivel " .. tostring(r.Nivel) .. "!")
		end
	end
	if not r.Ok then
		return false
	end
	Jugadores.publicar(jugador)
	if tipo == "Base" or id == "Corrales" then
		Corrales.actualizar(jugador)
	end
	Remotos.Compra:FireClient(jugador, tipo, id, r.Nivel)
	for _, c in r.Celebraciones do
		Remotos.Celebracion:FireClient(jugador, c)
	end
	return true
end

Remotos.Comprar.OnServerEvent:Connect(function(jugador: Player, tipo: unknown, id: unknown)
	Tienda.comprar(jugador, tipo, id)
end)

return Tienda
