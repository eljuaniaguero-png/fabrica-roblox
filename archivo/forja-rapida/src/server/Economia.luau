--!strict
-- Banco y Tienda (sistema 3 de la ficha) y zonas que se abren con la Fuerza (sistema 4).
-- El cliente solo pide; el servidor revisa todo:
--   Remotos.Vender   ()       vende toda la mochila al precio de GameConfig (Reglas.valorMochila).
--   Remotos.Comprar  (tipo)   "Fuerza" (un nivel), "FuerzaMax" (todos los que alcancen),
--                             "Pico" o "Amuleto" (el siguiente en orden).
-- Cada pedido: tipo de dato, que sea un tipo conocido, frecuencia (un pedido cada 0,2 s) y
-- monedas suficientes. Si sale bien, avisa con Remotos.Compra; si no, con un Aviso que dice
-- qué falta. Las zonas se abren solas apenas la Fuerza llega a la que piden (no se gasta).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Analitica = require(script.Parent.Analitica)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local Economia = {}

local ESPERA = 0.2
local ultimo: { [Player]: number } = {}

local function permitir(jugador: Player): boolean
	local t = os.clock()
	if ultimo[jugador] and t - ultimo[jugador] < ESPERA then
		return false
	end
	ultimo[jugador] = t
	return true
end

local function faltan(jugador: Player, precio: number, monedas: number)
	Remotos.Aviso:FireClient(
		jugador,
		("Te faltan %s Monedas"):format(Formato.corto(math.max(0, precio - monedas)))
	)
end

-- Abre las zonas que ya alcanza con su Fuerza y le avisa con un hito por cada una.
function Economia.revisarZonas(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local nuevas = Reglas.zonasNuevas(d.Zonas, Jugadores.fuerza(d), d.Indice)
	if #nuevas == 0 then
		return
	end
	local hitos = {}
	for _, n in nuevas do
		d.Zonas[n] = true
		if n == 2 then
			Analitica.paso(jugador, Analitica.Pasos.Zona2)
		elseif n == 3 then
			Analitica.paso(jugador, Analitica.Pasos.Zona3)
		end
		local z = GameConfig.Zonas[n]
		table.insert(hitos, {
			Id = "Zona" .. n,
			Titulo = "¡Zona nueva!",
			Nombre = z.Nombre,
			Descripcion = "Ya podés romper sus geodas",
			Coleccion = false,
		})
	end
	Jugadores.publicar(jugador)
	Remotos.Hitos:FireClient(jugador, hitos)
end

local function vender(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d or not permitir(jugador) then
		return
	end
	-- Grupo 4: el Renacer, la rama Mercader y las mascotas suben lo que te pagan
	local total = math.floor(Reglas.valorMochila(d.Mochila) * Jugadores.bonos(d).Monedas)
	if total <= 0 then
		Remotos.Aviso:FireClient(jugador, "Tu mochila está vacía: ¡rompé geodas!")
		return
	end
	d.Mochila = {} -- primero se vacía, después se paga
	d.Monedas += total
	Analitica.monedas(jugador, true, total, "Venta")
	Analitica.paso(jugador, Analitica.Pasos.Venta)
	Jugadores.publicar(jugador)
	Remotos.Premio:FireClient(jugador, total)
	Remotos.Compra:FireClient(jugador, "Vender", Formato.corto(total))
end

local function comprarFuerza(jugador: Player, d: Jugadores.Datos, todos: boolean)
	local niveles, costo = Reglas.nivelesFuerza(d.NivelFuerza, d.Monedas, if todos then nil else 1)
	if niveles == 0 then
		local precio = Reglas.precioFuerza(d.NivelFuerza)
		if precio then
			faltan(jugador, precio, d.Monedas)
		else
			Remotos.Aviso:FireClient(jugador, "¡Ya tenés la Fuerza al máximo!")
		end
		return
	end
	d.Monedas -= costo
	d.NivelFuerza += niveles
	Analitica.monedas(jugador, false, costo, "Fuerza")
	Analitica.paso(jugador, Analitica.Pasos.Fuerza)
	Jugadores.publicar(jugador)
	Remotos.Compra:FireClient(jugador, "Fuerza", "+" .. niveles)
	Economia.revisarZonas(jugador)
end

local function comprarPico(jugador: Player, d: Jugadores.Datos)
	local pico, numero = Reglas.siguientePico(d.Pico)
	if not pico then
		Remotos.Aviso:FireClient(jugador, "¡Ya tenés el mejor pico!")
		return
	end
	if d.Monedas < pico.Precio then
		faltan(jugador, pico.Precio, d.Monedas)
		return
	end
	d.Monedas -= pico.Precio
	d.Pico = numero
	Analitica.monedas(jugador, false, pico.Precio, "Pico")
	Analitica.paso(jugador, Analitica.Pasos.Pico)
	Jugadores.publicar(jugador)
	Remotos.Compra:FireClient(jugador, "Pico", pico.Nombre)
	Economia.revisarZonas(jugador)
end

local function comprarAmuleto(jugador: Player, d: Jugadores.Datos)
	local amuleto = Reglas.siguienteAmuleto(d.Amuletos)
	if not amuleto then
		Remotos.Aviso:FireClient(jugador, "¡Ya tenés todos los amuletos!")
		return
	end
	if d.Monedas < amuleto.Precio then
		faltan(jugador, amuleto.Precio, d.Monedas)
		return
	end
	d.Monedas -= amuleto.Precio
	Analitica.monedas(jugador, false, amuleto.Precio, "Amuleto")
	d.Amuletos[amuleto.Id] = true
	Jugadores.publicar(jugador)
	Remotos.Compra:FireClient(jugador, "Amuleto", amuleto.Nombre)
end

local function comprar(jugador: Player, tipo: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(tipo) ~= "string" or not permitir(jugador) then
		return
	end
	if tipo == "Fuerza" or tipo == "FuerzaMax" then
		comprarFuerza(jugador, d, tipo == "FuerzaMax")
	elseif tipo == "Pico" then
		comprarPico(jugador, d)
	elseif tipo == "Amuleto" then
		comprarAmuleto(jugador, d)
	end
end

function Economia.iniciar()
	Remotos.Vender.OnServerEvent:Connect(vender)
	Remotos.Comprar.OnServerEvent:Connect(comprar)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimo[jugador] = nil
	end)
end

return Economia
