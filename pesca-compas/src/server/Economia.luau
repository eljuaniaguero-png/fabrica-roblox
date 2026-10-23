--!strict
-- Vender el balde (ProximityPrompt del puesto), mejorar caña y balde con Escamas, y guardar
-- la calibración. Todo se valida acá; el cliente solo pide.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Ritmo = require(ReplicatedStorage.Shared.Ritmo)
local Jugadores = require(script.Parent.Jugadores)
local Misiones = require(script.Parent.Misiones)
local Remotos = require(script.Parent.Remotos)

local Economia = {}

function Economia.vender(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	if #d.Cubeta == 0 then
		Remotos.Aviso:FireClient(jugador, "Tu balde está vacío")
		return
	end
	local total = 0
	for _, p in d.Cubeta do
		local pez = Ritmo.pezPorId(p.Id)
		if pez then
			total += Ritmo.precio(pez, p.Peso, p.Afinado)
		end
	end
	local cantidad = #d.Cubeta
	d.Escamas += total
	d.Cubeta = {}
	Remotos.Aviso:FireClient(jugador, ("Vendiste %d peces: +%d Escamas"):format(cantidad, total))
	Misiones.registrar(jugador, "Vender", 1)
	Misiones.registrar(jugador, "Escamas", total)
	Jugadores.enviar(jugador)
end

local function mejorar(jugador: Player, tipo: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or (tipo ~= "Cana" and tipo ~= "Balde") then
		return
	end
	local precios = if tipo == "Cana" then Config.PrecioCana else Config.PrecioBalde
	local nivel = if tipo == "Cana" then d.Cana else d.Balde
	local precio = precios[nivel + 1]
	if not precio then
		Remotos.Aviso:FireClient(jugador, "Ya está al máximo")
		return
	end
	if d.Escamas < precio then
		Remotos.Aviso:FireClient(jugador, ("Te faltan %d Escamas"):format(precio - d.Escamas))
		return
	end
	d.Escamas -= precio
	if tipo == "Cana" then
		d.Cana += 1
		Remotos.Aviso:FireClient(jugador, ("¡Caña nivel %d! Ventana de acierto más grande"):format(d.Cana))
	else
		d.Balde += 1
		Remotos.Aviso:FireClient(jugador, ("¡Balde nivel %d! Entran %d peces"):format(d.Balde, Jugadores.capacidad(d)))
	end
	Misiones.registrar(jugador, "Mejorar", 1)
	Jugadores.enviar(jugador)
end

local function calibrar(jugador: Player, desfase: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(desfase) ~= "number" or desfase ~= desfase then
		return
	end
	d.Desfase = math.clamp(desfase :: number, -Config.DesfaseMax, Config.DesfaseMax)
	d.Calibrado = true
	Jugadores.enviar(jugador)
end

local function conectarPuesto(puesto: Instance)
	local prompt = puesto:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		prompt.Triggered:Connect(Economia.vender)
	end
end

function Economia.iniciar()
	Remotos.Mejorar.OnServerEvent:Connect(mejorar)
	Remotos.Calibrar.OnServerEvent:Connect(calibrar)
	for _, puesto in CollectionService:GetTagged("Vendedor") do
		conectarPuesto(puesto)
	end
	CollectionService:GetInstanceAddedSignal("Vendedor"):Connect(conectarPuesto)
end

return Economia
