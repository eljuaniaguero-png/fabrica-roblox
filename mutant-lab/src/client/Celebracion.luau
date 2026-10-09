--!strict
-- Festejo por completar una generación de la Mutadex (o la Mutadex entera): cartel grande de
-- UI/Carteles (uno por vez, encolados) con papelitos de la paleta (verde ácido, magenta,
-- dorado y los colores de los elementos) y una fanfarria.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Carteles = require(script.Parent.UI.Carteles)

local C = Config.Interfaz

local Celebracion = {}

-- Encola el festejo y espera a que el cartel se vaya (la máquina los muestra de a uno).
function Celebracion.mostrar(c: Fusion.Celebracion)
	Carteles.mostrarYEsperar({
		Titulo = if c.Completo
			then "¡MUTADEX COMPLETA!"
			else "¡GENERACIÓN " .. c.Gen .. " COMPLETA!",
		Texto = "+" .. Formato.numero(c.Premio) .. " ADN",
		Detalle = if c.Completo
			then "¡Descubriste las 50 especies!"
			else "Descubriste todas las especies de la generación " .. c.Gen,
		Color = Paleta.Dorado,
		Duracion = C.DuracionFestejo,
		AlMostrar = function()
			-- SONIDO: fanfarria por completar una generación (arpegio largo hacia arriba)
			Sonidos.secuencia({ 0, 4, 7, 12, 7, 12, 16, 19, 24 }, 0.11, 0.45)
			UI.papelitos(Carteles.Capa.Raiz, C.Papelitos[1])
			task.wait(1.2)
			UI.papelitos(Carteles.Capa.Raiz, C.Papelitos[2])
		end,
	})
end

return Celebracion
