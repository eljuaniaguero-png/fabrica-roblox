--!strict
-- Renacer y árbol de Esencia (Grupo 4, prestigio). Lo que se reinicia y lo que se conserva está
-- en GameConfig.Renacer (Reinicia y Conserva) y se muestra en el menú antes de confirmar.
--   Remotos.Renacer      ()   renace si tiene abierta la zona que pide (Reglas.puedeRenacer):
--                             suma Esencia y un renacer (bonos permanentes), vuelve a la plaza y
--                             le da misiones nuevas. Cada renacer desbloquea algo (logros
--                             Renacer*, ramas nuevas, la cuarta misión y el Santuario).
--   Remotos.MejorarRama  (id) compra el siguiente nivel de una rama con Esencia.
-- El servidor revisa todo: tipo, frecuencia, que la rama exista y esté a la vista, y que alcance.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Descubrimientos = require(script.Parent.Descubrimientos)
local Economia = require(script.Parent.Economia)
local Jugadores = require(script.Parent.Jugadores)
local Misiones = require(script.Parent.Misiones)
local Remotos = require(script.Parent.Remotos)

local Renacer = {}

local ultimo: { [Player]: number } = {}

local function permitir(jugador: Player, espera: number): boolean
	local t = os.clock()
	if ultimo[jugador] and t - ultimo[jugador] < espera then
		return false
	end
	ultimo[jugador] = t
	return true
end

-- Lleva el personaje al spawn de la plaza (sus zonas ya no están abiertas).
local function aLaPlaza(jugador: Player)
	local personaje = jugador.Character
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if personaje and spawn then
		personaje:PivotTo(spawn.CFrame + Vector3.new(0, 5, 0))
	end
end

local function renacer(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d or not permitir(jugador, 1) then
		return
	end
	if not Reglas.puedeRenacer(d.Zonas, d.Renacimientos) then
		local z = Reglas.zona(Reglas.zonaParaRenacer(d.Renacimientos))
		Remotos.Aviso:FireClient(
			jugador,
			("Para renacer tenés que abrir %s"):format(if z then z.Nombre else "la zona siguiente")
		)
		return
	end
	local esencia = Reglas.esenciaRenacer(d.Zonas)
	-- Lo que se reinicia (GameConfig.Renacer.Reinicia). Todo lo demás se conserva.
	d.Monedas = 0
	d.Mochila = {}
	d.Pico = 1
	d.Amuletos = {}
	d.Zonas = { [1] = true }
	d.Renacimientos += 1
	d.Esencia += esencia
	d.FichasForja =
		math.min(Jugadores.bonos(d).TopeForja, d.FichasForja + GameConfig.Forja.PorRenacer)
	d.NivelFuerza = math.min(GameConfig.Fuerza.NivelMaximo, Jugadores.bonos(d).NivelInicial)
	Jugadores.publicar(jugador)
	aLaPlaza(jugador)
	Remotos.Renacer:FireClient(jugador, d.Renacimientos, esencia)
	Anuncios.enviar(
		("¡%s renació! Renacer %d"):format(jugador.DisplayName, d.Renacimientos),
		"#FFD23F",
		"Hallazgo",
		jugador
	)
	Misiones.reiniciar(jugador)
	local hitos = Descubrimientos.revisar(jugador)
	if #hitos > 0 then
		Remotos.Hitos:FireClient(jugador, hitos)
	end
	Economia.revisarZonas(jugador) -- con Inicio Rápido puede abrir la zona 2 de entrada
end

local function mejorarRama(jugador: Player, id: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(id) ~= "string" or not permitir(jugador, 0.3) then
		return
	end
	local r = Reglas.rama(id)
	if not r or not Reglas.ramaDisponible(id, d.Renacimientos) then
		return
	end
	local nivel = d.Ramas[id] or 0
	local costo = Reglas.costoRama(id, nivel)
	if not costo then
		Remotos.Aviso:FireClient(jugador, "¡Esa rama ya está al máximo!")
		return
	end
	if d.Esencia < costo then
		Remotos.Aviso:FireClient(jugador, ("Te faltan %d de Esencia"):format(costo - d.Esencia))
		return
	end
	d.Esencia -= costo
	d.Ramas[id] = nivel + 1
	Jugadores.publicar(jugador)
	Remotos.Compra:FireClient(jugador, "Rama", ("%s %d"):format(r.Nombre, nivel + 1))
	Economia.revisarZonas(jugador) -- Golpe Firme sube la Fuerza
end

function Renacer.iniciar()
	Remotos.Renacer.OnServerEvent:Connect(renacer)
	Remotos.MejorarRama.OnServerEvent:Connect(mejorarRama)
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimo[jugador] = nil
	end)
end

return Renacer
