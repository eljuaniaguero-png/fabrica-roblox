--!strict
-- Solo jugando en Studio: BindableFunctions en ServerStorage.Prueba para preparar un jugador sin
-- jugar horas (probar la tienda, las zonas, los secretos, el renacer y las mascotas). No existen
-- en el juego publicado. Uso desde la consola del servidor:
--   game.ServerStorage.Prueba.Leer:Invoke("Nombre") -> los datos del jugador en JSON
--   game.ServerStorage.Prueba.Poner:Invoke("Nombre", { Monedas = 5000, NivelFuerza = 10 })
--     Zonas, Llaves y Secretos van como lista de números: { Zonas = { 1, 2, 3 } }.
--     Mochila, Amuletos, Logros, Ramas, Mascotas, etc. van como tabla: { Mochila = { Cuarzo = 5 } }.
--   game.ServerStorage.Prueba.Reiniciar:Invoke("Nombre") -> vuelve a jugador nuevo
--   game.ServerStorage.Prueba.Forjar:Invoke("Nombre", "Amatista", "Epico", 1, "Pequena")
--     -> empieza La Forja con esa piedra, como si hubiera roto una geoda (zona y tamaño)
--   game.ServerStorage.Prueba.Entregar:Invoke("Nombre") -> entrega la piedra pendiente
--   game.ServerStorage.Prueba.Estilo:Invoke("B") -> prueba un estilo de luz (GameConfig.Luz)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Economia = require(script.Parent.Economia)
local Forja = require(script.Parent.Forja)
local Iluminacion = require(script.Parent.Iluminacion)
local Jugadores = require(script.Parent.Jugadores)
local Misiones = require(script.Parent.Misiones)

local CONJUNTOS_DE_NUMEROS = { Zonas = true, Llaves = true, Secretos = true }

local HerramientasPrueba = {}

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

function HerramientasPrueba.iniciar()
	if not RunService:IsStudio() then
		return
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Prueba"

	funcion(carpeta, "Leer", function(nombre: string): string?
		local _, d = buscar(nombre)
		return d and HttpService:JSONEncode(d)
	end)

	funcion(carpeta, "Poner", function(nombre: string, campos: { [string]: any }): boolean
		local jugador, d = buscar(nombre)
		if not jugador or not d then
			return false
		end
		local crudo = d :: any
		for campo, valor in campos do
			if CONJUNTOS_DE_NUMEROS[campo] then
				local conjunto = {}
				for _, n in valor do
					conjunto[n] = true
				end
				crudo[campo] = conjunto
			elseif typeof(valor) == "table" then
				crudo[campo] = table.clone(valor)
			else
				crudo[campo] = valor
			end
		end
		Jugadores.publicar(jugador)
		Economia.revisarZonas(jugador)
		return true
	end)

	funcion(carpeta, "Reiniciar", function(nombre: string): boolean
		local jugador = Players:FindFirstChild(nombre) :: Player?
		if not jugador then
			return false
		end
		local stats = jugador:FindFirstChild("leaderstats")
		if stats then
			stats:Destroy()
		end
		Jugadores.quitar(jugador)
		Jugadores.crear(jugador)
		Misiones.reiniciar(jugador)
		return true
	end)

	funcion(
		carpeta,
		"Forjar",
		function(
			nombre: string,
			gema: string,
			rareza: string,
			zona: number,
			tamano: string
		): boolean
			local jugador = Players:FindFirstChild(nombre) :: Player?
			if not jugador then
				return false
			end
			Forja.empezar(jugador, {
				Gema = gema,
				Rareza = rareza,
				Zona = zona,
				Secreta = false,
				Unidades = 1,
				Intentos = 3,
				Geoda = nil,
				Modificador = "Normal",
				Suerte = 1,
				Tamano = tamano,
			})
			return true
		end
	)

	funcion(carpeta, "Entregar", function(nombre: string): boolean
		local jugador = Players:FindFirstChild(nombre) :: Player?
		if not jugador then
			return false
		end
		Forja.entregar(jugador)
		return true
	end)

	funcion(carpeta, "Estilo", function(nombre: string): boolean
		Iluminacion.aplicar(nombre)
		return true
	end)

	carpeta.Parent = ServerStorage
end

return HerramientasPrueba
