--!strict
-- Solo en modo prueba o jugando en Studio: BindableFunctions para preparar un jugador sin
-- jugar (probar la Mutadex con muchas especies, el laboratorio lleno, el guardado).
-- No existen en el juego publicado. Uso desde la consola del servidor:
--   game.ServerStorage.Prueba.DarEspecies:Invoke("NombreDelJugador", { "1-2", "3-4" })
--   game.ServerStorage.Prueba.DarMutantes:Invoke("NombreDelJugador", { "1-2" })
--   game.ServerStorage.Prueba.Reiniciar:Invoke("NombreDelJugador") -> vuelve a jugador nuevo
--   game.ServerStorage.Prueba.PonerDatos:Invoke("NombreDelJugador", 5000, { Corrales = 4 })
--   game.ServerStorage.Prueba.Guardar:Invoke("NombreDelJugador") -> true si guardó
--   game.ServerStorage.Prueba.NuevosPedidos:Invoke("NombreDelJugador") -> otros 3 pedidos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Corrales = require(script.Parent.Corrales)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)
local Tablero = require(script.Parent.Tablero)

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
		-- Descubre la especie y, si no tenía ninguna, le da una criatura.
		for _, clave in claves do
			d.Especies[clave] = true
			if Jugadores.contar(d, clave) == 0 then
				Jugadores.agregarCriatura(d, clave, false)
			end
		end
		Jugadores.publicar(jugador)
		Corrales.actualizar(jugador)
		return Jugadores.cantidadEspecies(d)
	end)

	-- Copias extra de especies (para probar pedidos de dos criaturas).
	funcion(carpeta, "DarCriaturas", function(nombre: string, claves: { string }): number
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return 0
		end
		for _, clave in claves do
			d.Especies[clave] = true
			Jugadores.agregarCriatura(d, clave, false)
		end
		Jugadores.publicar(jugador)
		Corrales.actualizar(jugador)
		return #d.Criaturas
	end)

	-- Vuelve mutante una criatura de cada especie que el jugador ya tiene (estrella dorada).
	funcion(carpeta, "DarMutantes", function(nombre: string, claves: { string }): number
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return 0
		end
		local n = 0
		for _, clave in claves do
			for _, u in d.Criaturas do
				if u.Clave == clave and not u.Mutante then
					u.Mutante = true
					d.Mutantes[clave] = true
					n += 1
					break
				end
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

	-- Cambia los pedidos del tablero por otros nuevos (para ver cómo se ven).
	funcion(carpeta, "NuevosPedidos", function(nombre: string): boolean
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return false
		end
		for i = 1, Config.Pedidos.Activos do
			d.Pedidos[i] = nil
			d.EsperaPedido[i] = nil
		end
		Tablero.completar(jugador, d)
		Jugadores.publicarPedidos(jugador)
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

	-- Simulador de balance: `partidas` partidas de `segundos` con el jugador automático.
	-- `cambios` prueba otros números de Config sin tocar el código (ver Simulador.conCambios).
	funcion(
		carpeta,
		"Simular",
		function(segundos: number?, partidas: number?, cambios: { [string]: any }?): string
			local Simulador = require(script.Parent.Simulador) :: any
			return Simulador.conCambios(cambios, function()
				return Simulador.resumen(segundos or 600, partidas or 20)
			end)
		end
	)

	-- El jugador automático juega de verdad (tiempo real) con este jugador, desde donde esté.
	funcion(carpeta, "Jugar", function(nombre: string, segundos: number?): boolean
		local jugador = buscar(nombre)
		if not jugador then
			return false
		end
		local JugadorAutomatico = require(script.Parent.JugadorAutomatico) :: any
		return JugadorAutomatico.iniciar(jugador, segundos or 600)
	end)

	funcion(carpeta, "Informe", function(): string
		local JugadorAutomatico = require(script.Parent.JugadorAutomatico) :: any
		return JugadorAutomatico.informe()
	end)

	-- Una sola partida simulada, paso a paso (para ver qué hace el jugador automático).
	funcion(carpeta, "Traza", function(segundos: number?, cambios: { [string]: any }?): string
		local Simulador = require(script.Parent.Simulador) :: any
		return Simulador.conCambios(cambios, function()
			local registro = {}
			Simulador.jugar(segundos or 600, 1, registro)
			return table.concat(registro, "\n")
		end)
	end)

	funcion(carpeta, "Guardar", function(nombre: string): boolean
		local jugador = buscar(nombre)
		return jugador ~= nil and Guardado.guardar(jugador :: Player)
	end)

	carpeta.Parent = ServerStorage
end

return {}
