--!strict
-- Solo en modo prueba o jugando en Studio: BindableFunctions para preparar un jugador sin
-- jugar (probar la Mutadex con muchas especies, el laboratorio lleno, el guardado).
-- No existen en el juego publicado. Uso desde la consola del servidor:
--   game.ServerStorage.Prueba.DarEspecies:Invoke("NombreDelJugador", { "1-2", "3-4" })
--   game.ServerStorage.Prueba.DarMutantes:Invoke("NombreDelJugador", { "1-2" })
--   game.ServerStorage.Prueba.Reiniciar:Invoke("NombreDelJugador") -> vuelve a jugador nuevo
--   game.ServerStorage.Prueba.PonerDatos:Invoke("NombreDelJugador", 5000, { Corrales = 4 })
--   game.ServerStorage.Prueba.Guardar:Invoke("NombreDelJugador") -> true si guardó

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Corrales = require(script.Parent.Corrales)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)

local function buscar(nombre: string): (Player?, Jugadores.Datos?)
	local jugador = Players:FindFirstChild(nombre) :: Player?
	return jugador, jugador and Jugadores.obtener(jugador)
end

local function funcion(carpeta: Folder, nombre: string, f: (...any) -> any)
	local b = Instance.new("BindableFunction")
	b.Name = nombre
	b.OnInvoke = f
	b.Parent = carpeta
end

if Config.Prueba.Activo or RunService:IsStudio() then
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Prueba"

	funcion(carpeta, "DarEspecies", function(nombre: string, claves: { string }): number
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return 0
		end
		for _, clave in claves do
			d.Especies[clave] = true
		end
		Jugadores.publicar(jugador)
		Corrales.actualizar(jugador)
		return Jugadores.cantidadEspecies(d)
	end)

	-- Marca como mutantes especies que el jugador ya tiene (para ver la estrella dorada).
	funcion(carpeta, "DarMutantes", function(nombre: string, claves: { string }): number
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return 0
		end
		local n = 0
		for _, clave in claves do
			if d.Especies[clave] then
				d.Mutantes[clave] = true
				n += 1
			end
		end
		Jugadores.publicar(jugador)
		Corrales.actualizar(jugador)
		return n
	end)

	-- Deja al jugador como uno nuevo (para probar el arranque). Se guarda como cualquier partida.
	funcion(carpeta, "Reiniciar", function(nombre: string): boolean
		local jugador = buscar(nombre)
		if not jugador then
			return false
		end
		Jugadores.crear(jugador :: Player, nil)
		Corrales.actualizar(jugador :: Player)
		return true
	end)

	-- ADN y niveles de mejoras (los que no se pasan quedan como están).
	funcion(
		carpeta,
		"PonerDatos",
		function(nombre: string, adn: number?, niveles: { [string]: number }?)
			local jugador, d = buscar(nombre)
			if not jugador or not d then
				return false
			end
			if adn then
				d.ADN = adn
			end
			for _, mejora in Mejoras.Orden do
				local n = niveles and niveles[mejora]
				if n then
					(d.Mejoras :: any)[mejora] = math.clamp(n, 0, Mejoras.maximo(mejora))
				end
			end
			Jugadores.publicar(jugador)
			Corrales.actualizar(jugador)
			return true
		end
	)

	funcion(carpeta, "Guardar", function(nombre: string): boolean
		local jugador = buscar(nombre)
		return jugador ~= nil and Guardado.guardar(jugador :: Player)
	end)

	carpeta.Parent = ServerStorage
end

return {}
