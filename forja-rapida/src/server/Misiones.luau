--!strict
-- Misiones dinámicas (Grupo 4). Cada jugador tiene siempre una Fácil, una Media y una Difícil
-- (y una de Prestigio desde el primer Renacer), elegidas al azar entre las que puede hacer
-- (GameConfig.Misiones, Reglas.nuevaMision). Se siguen solas:
--   geodas que rompe (Mundo.alRomper), gemas que le salen (Mundo.alRevelar), cosas que hace en
--   el mapa (Mundo.alAccion: altar, puerta, portal, cofre) y su Museo (minerales nuevos y
--   colecciones).
-- Al cumplirse se paga sola (primero se saca, después se paga, así nunca paga dos veces) y a los
-- pocos segundos aparece otra en ese lugar. Remotos.CambiarMision cambia una por otra, gratis,
-- una vez cada GameConfig.Misiones.Cambiar segundos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Descubrimientos = require(script.Parent.Descubrimientos)
local Jugadores = require(script.Parent.Jugadores)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

local M = GameConfig.Misiones

local Misiones = {}

local rng = Random.new()
local function azar(): number
	return rng:NextNumber()
end

-- Dificultades que tiene este jugador, en orden.
local function lugares(d: Jugadores.Datos): { string }
	local lista = table.clone(M.Lugares)
	if d.Renacimientos >= 1 then
		table.insert(lista, M.LugarPrestigio)
	end
	return lista
end

local function ordenar(d: Jugadores.Datos)
	local orden: { [string]: number } = {}
	for i, dif in lugares(d) do
		orden[dif] = i
	end
	table.sort(d.Misiones, function(a, b)
		return (orden[a.Dificultad] or 99) < (orden[b.Dificultad] or 99)
	end)
end

-- Pone una misión en cada lugar vacío. `evitar`: plantillas que no conviene repetir.
local function completar(jugador: Player, d: Jugadores.Datos, evitar: { [string]: boolean }?)
	local ocupados: { [string]: boolean } = {}
	local usadas: { [string]: boolean } = table.clone(evitar or {})
	for _, m in d.Misiones do
		ocupados[m.Dificultad] = true
		usadas[m.Id] = true
	end
	local cambio = false
	for _, dif in lugares(d) do
		if not ocupados[dif] then
			local m = Reglas.nuevaMision(dif, d, azar, usadas)
			if m then
				table.insert(d.Misiones, m)
				usadas[m.Id] = true
				cambio = true
			end
		end
	end
	if cambio then
		ordenar(d)
		Jugadores.publicar(jugador)
	end
end

local function cumplir(jugador: Player, d: Jugadores.Datos, m: Reglas.Mision)
	local i = table.find(d.Misiones, m)
	if not i then
		return
	end
	table.remove(d.Misiones, i) -- primero se saca, después se paga
	d.MisionesHechas += 1
	d.Monedas += m.Monedas
	d.Esencia += m.Esencia
	Jugadores.publicar(jugador)
	Remotos.Mision:FireClient(jugador, m.Texto, m.Monedas, m.Esencia)
	Remotos.Premio:FireClient(jugador, m.Monedas)
	local hitos = Descubrimientos.revisar(jugador)
	if #hitos > 0 then
		Remotos.Hitos:FireClient(jugador, hitos)
	end
	task.delay(M.Espera, function()
		if Jugadores.obtener(jugador) == d then
			completar(jugador, d, { [m.Id] = true })
		end
	end)
end

-- Actualiza las que dependen del Museo y paga las que se cumplieron.
local function revisar(jugador: Player, d: Jugadores.Datos)
	local cambio = false
	for _, m in table.clone(d.Misiones) do
		local p = math.min(m.Meta, Reglas.progresoMision(m, d))
		if p ~= m.Progreso then
			m.Progreso = p
			cambio = true
		end
		if m.Progreso >= m.Meta then
			cumplir(jugador, d, m)
			cambio = false -- cumplir ya publicó
		end
	end
	if cambio then
		Jugadores.publicar(jugador)
	end
end

local function avanzar(jugador: Player, ev: Reglas.EventoMision)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	for _, m in d.Misiones do
		local mas = Reglas.avanceMision(m, ev)
		if mas > 0 then
			m.Progreso = math.min(m.Meta, m.Progreso + mas)
		end
	end
	revisar(jugador, d)
	Jugadores.publicar(jugador)
end

-- Otra misión en el lugar de esa dificultad (gratis, con espera).
local function alCambiar(jugador: Player, dificultad: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(dificultad) ~= "string" then
		return
	end
	local ahora = Workspace:GetServerTimeNow()
	local falta = M.Cambiar - (ahora - d.CambioMision)
	if falta > 0 then
		Remotos.Aviso:FireClient(
			jugador,
			("Podés cambiar otra misión en %s"):format(Formato.tiempo(falta))
		)
		return
	end
	local vieja: Reglas.Mision? = nil
	for _, m in d.Misiones do
		if m.Dificultad == dificultad then
			vieja = m
		end
	end
	if not vieja then
		return
	end
	local usadas: { [string]: boolean } = {}
	for _, m in d.Misiones do
		usadas[m.Id] = true
	end
	local nueva = Reglas.nuevaMision(dificultad, d, azar, usadas)
	if not nueva or nueva.Id == vieja.Id then
		Remotos.Aviso:FireClient(jugador, "No hay otra misión de esta dificultad para vos ahora")
		return
	end
	d.Misiones[table.find(d.Misiones, vieja) :: number] = nueva
	d.CambioMision = ahora
	Jugadores.publicar(jugador)
end

-- Al entrar: sus primeras misiones.
function Misiones.alEntrar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if d then
		completar(jugador, d)
	end
end

-- Después de renacer: misiones nuevas (las de antes pedían cosas de zonas que ya no tiene).
function Misiones.reiniciar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if d then
		d.Misiones = {}
		completar(jugador, d)
	end
end

function Misiones.iniciar()
	Mundo.alRomper(function(r: Mundo.Rotura)
		for _, jugador in r.Premiados do
			avanzar(jugador, {
				Tipo = "Geoda",
				Zona = r.Zona,
				Tamano = r.Tamano,
				Modificador = r.Modificador,
			})
		end
	end)
	Mundo.alRevelar(function(r: Mundo.Revelado)
		avanzar(r.Jugador, { Tipo = "Gema", Rareza = r.Rareza })
	end)
	Mundo.alAccion(function(jugador: Player, accion: string)
		avanzar(jugador, { Tipo = "Accion", Accion = accion })
	end)
	Remotos.CambiarMision.OnServerEvent:Connect(alCambiar)
	for _, jugador in Players:GetPlayers() do
		Misiones.alEntrar(jugador)
	end
end

return Misiones
