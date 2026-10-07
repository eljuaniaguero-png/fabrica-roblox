--!strict
-- Arranque del servidor: conecta los sistemas y corre el chequeo de caídas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Ambiente = require(script.Parent.Ambiente)
local Consumibles = require(script.Parent.Consumibles)
local Datos = require(script.Parent.Datos)
local Economia = require(script.Parent.Economia)
local Pisadas = require(script.Parent.Pisadas)
local Pruebas = require(script.Parent.Pruebas)
local Puertas = require(script.Parent.Puertas)
local Rebirth = require(script.Parent.Rebirth)
local Tubos = require(script.Parent.Tubos)
local Velocidad = require(script.Parent.Velocidad)

Ambiente.aplicar()
Puertas.iniciar()
Rebirth.iniciar()
Economia.iniciar()
Consumibles.iniciar()
Pisadas.iniciar()
Pruebas.iniciar()
Tubos.iniciar()

local function prepararPersonaje(jugador: Player, personaje: Model)
	personaje:WaitForChild("Humanoid")
	personaje:WaitForChild("HumanoidRootPart")
	Puertas.alAparecer(jugador, personaje)
	Velocidad.aplicar(jugador)
end

local function alEntrar(jugador: Player)
	jugador.CharacterAdded:Connect(function(personaje)
		if Datos.obtener(jugador) then
			prepararPersonaje(jugador, personaje)
		end
	end)

	Datos.cargar(jugador)
	Velocidad.crearLeaderstats(jugador)
	Velocidad.aplicar(jugador)
	if jugador.Character then
		prepararPersonaje(jugador, jugador.Character)
	end
end

Players.PlayerAdded:Connect(alEntrar)
for _, jugador in Players:GetPlayers() do
	task.spawn(alEntrar, jugador)
end

Players.PlayerRemoving:Connect(function(jugador)
	Datos.guardar(jugador)
	Datos.olvidar(jugador)
	Pisadas.olvidar(jugador)
	Rebirth.olvidar(jugador)
	Economia.olvidar(jugador)
	Consumibles.olvidar(jugador)
end)

game:BindToClose(function()
	for _, jugador in Players:GetPlayers() do
		Datos.guardar(jugador)
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.IntervaloMedicion)
		for _, jugador in Players:GetPlayers() do
			Puertas.chequearCaida(jugador)
		end
	end
end)

print(`[Servidor] {Config.NombreDelJuego} iniciado`)
