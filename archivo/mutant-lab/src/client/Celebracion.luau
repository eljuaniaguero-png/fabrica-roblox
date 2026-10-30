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
	if c.Titulo then
		-- Logro de "volver mañana" (premio diario, misiones, experimento, metas).
		Carteles.mostrarYEsperar({
			Titulo = c.Titulo,
			Texto = c.Texto,
			Detalle = c.Detalle,
			Color = Paleta.Dorado,
			Duracion = C.DuracionFestejo,
			AlMostrar = function()
				-- SONIDO: logro (arpegio corto hacia arriba)
				Sonidos.secuencia({ 0, 4, 7, 12, 16 }, 0.09, 0.4)
				UI.papelitos(Carteles.Capa.Raiz, C.Papelitos[2])
			end,
		})
		return
	end
	if c.Novedad == "Ranura" then
		-- Se abrió la ranura de catalizador (Config.Residuos.RanuraDesde especies).
		Carteles.mostrarYEsperar({
			Titulo = "¡RANURA DE CATALIZADOR!",
			-- El cartel tiene lugar para una línea grande corta y dos chicas.
			Texto = "Arriba de la máquina",
			Detalle = "Poné un catalizador al fusionar y la cría sale como variante. Se arman con "
				.. Config.Residuos.ParaCatalizador
				.. " residuos.",
			Color = Paleta.Acento,
			Duracion = C.DuracionFestejo + 2,
			AlMostrar = function()
				-- SONIDO: se abre algo nuevo (tres notas que suben)
				Sonidos.secuencia({ 0, 7, 12 }, 0.12, 0.4)
			end,
		})
		return
	end
	local titulo, detalle
	if c.Pedidos then
		titulo = "¡" .. c.Pedidos .. " PEDIDOS ENTREGADOS!"
		detalle = "Tus clientes están felices"
	elseif c.Completo then
		titulo = "¡MUTADEX COMPLETA!"
		detalle = "¡Descubriste las 50 especies!"
	else
		titulo = "¡GENERACIÓN " .. c.Gen .. " COMPLETA!"
		detalle = "Descubriste todas las especies de la generación " .. c.Gen
	end
	Carteles.mostrarYEsperar({
		Titulo = titulo,
		Texto = "+" .. Formato.numero(c.Premio) .. " ADN",
		Detalle = detalle,
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
