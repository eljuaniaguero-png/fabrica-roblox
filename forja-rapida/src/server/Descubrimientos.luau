--!strict
-- Descubrimiento en cadena (Grupo 1): geoda especial -> gema -> colección o logro -> premio.
-- Cada vez que un jugador rompe una geoda, se anota qué modificador tenía y qué rareza salió, y
-- se revisan los logros (GameConfig.Logros). Cada logro se marca como cobrado ANTES de dar el
-- premio, así nunca se paga dos veces (ni si se cumplen dos cosas en el mismo golpe).
-- Devuelve los hitos para que el cliente los muestre en fila después de la revelación.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Jugadores = require(script.Parent.Jugadores)

-- Lo que el cliente muestra de cada logro cumplido.
export type Hito = {
	Id: string,
	Nombre: string,
	Descripcion: string,
	Monedas: number?,
	Suerte: number?,
	Coleccion: boolean, -- true si es una colección (completar el Índice de una zona, exóticas...)
}

local Descubrimientos = {}

-- Anota lo que rompió y encontró, cobra los logros nuevos y los devuelve.
function Descubrimientos.registrar(jugador: Player, modificador: string, rareza: string): { Hito }
	local d = Jugadores.obtener(jugador)
	if not d then
		return {}
	end
	if Reglas.esExotica(modificador) then
		d.Exoticas[modificador] = true
		-- una combinación también cuenta para cada una de sus partes
		for _, parte in Reglas.partes(modificador) do
			d.Exoticas[parte] = true
		end
	end
	d.Rarezas[rareza] = true

	local hitos: { Hito } = {}
	for _, l in Reglas.logrosNuevos(d) do
		if not d.Logros[l.Id] then
			d.Logros[l.Id] = true -- primero se marca, después se paga
			if l.Premio.Monedas then
				d.Monedas += l.Premio.Monedas
			end
			table.insert(hitos, {
				Id = l.Id,
				Nombre = l.Nombre,
				Descripcion = l.Descripcion,
				Monedas = l.Premio.Monedas,
				Suerte = l.Premio.Suerte,
				Coleccion = l.Necesita.Tipo == "Gemas" or l.Id:sub(1, 9) == "Coleccion",
			})
		end
	end
	Jugadores.publicar(jugador)
	return hitos
end

return Descubrimientos
