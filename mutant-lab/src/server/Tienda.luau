--!strict
-- Tienda del laboratorio: especies base (precio creciente) y mejoras.
-- El cliente pide ("Base", número) o ("Mejora", nombre); el servidor valida y cobra.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Coleccion = require(script.Parent.Coleccion)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local function aviso(jugador: Player, texto: string)
	Remotos.Aviso:FireClient(jugador, texto)
end

local function comprarBase(jugador: Player, d: Jugadores.Datos, n: number)
	local clave = tostring(n)
	if d.Especies[clave] then
		aviso(jugador, "Ya tenés a " .. Especies[n].Nombre .. ".")
		return
	end
	local precio = Mejoras.precioBase(Jugadores.cantidadBases(d))
	if not precio then
		return
	end
	if d.ADN < precio then
		aviso(
			jugador,
			"Te falta ADN: " .. Especies[n].Nombre .. " cuesta " .. Formato.numero(precio) .. "."
		)
		return
	end
	d.ADN -= precio
	Coleccion.agregar(d, clave)
	local celebraciones = Coleccion.revisarGeneraciones(d)
	Jugadores.publicar(jugador)
	Corrales.actualizar(jugador)
	aviso(jugador, "¡" .. Especies[n].Nombre .. " llegó a tu laboratorio!")
	Remotos.Compra:FireClient(jugador, "Base", n)
	for _, c in celebraciones do
		Remotos.Celebracion:FireClient(jugador, c)
	end
end

local function comprarMejora(jugador: Player, d: Jugadores.Datos, nombre: string)
	local def = (Config.Mejoras :: any)[nombre]
	if not def then
		return
	end
	local nivel = (d.Mejoras :: any)[nombre] :: number
	local precio = Mejoras.precio(nombre, nivel)
	if not precio then
		aviso(jugador, def.Nombre .. " ya está al máximo.")
		return
	end
	if d.ADN < precio then
		aviso(jugador, "Te falta ADN para " .. def.Nombre .. ".")
		return
	end
	d.ADN -= precio
	local niveles = d.Mejoras :: any
	niveles[nombre] = nivel + 1
	Jugadores.publicar(jugador)
	if nombre == "Corrales" then
		Corrales.actualizar(jugador)
	end
	aviso(jugador, "¡" .. def.Nombre .. " nivel " .. (nivel + 1) .. "!")
	Remotos.Compra:FireClient(jugador, "Mejora", nombre, nivel + 1)
end

Remotos.Comprar.OnServerEvent:Connect(function(jugador: Player, tipo: unknown, id: unknown)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	if tipo == "Base" and typeof(id) == "number" then
		local n = id :: number
		if n == math.floor(n) and n >= 1 and n <= Config.TamanioRueda then
			comprarBase(jugador, d, n)
		end
	elseif tipo == "Mejora" and typeof(id) == "string" then
		comprarMejora(jugador, d, id :: string)
	end
end)

return {}
