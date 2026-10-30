--!strict
-- Descubrimiento en cadena (Grupo 1): geoda especial -> gema -> colección o logro -> premio.
-- Cada vez que un jugador rompe una geoda, se anota qué modificador tenía y qué rareza salió, y
-- se revisan los logros (GameConfig.Logros). Cada logro se marca como cobrado ANTES de dar el
-- premio, así nunca se paga dos veces (ni si se cumplen dos cosas en el mismo golpe).
-- Devuelve los hitos para que el cliente los muestre en fila después de la revelación.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Jugadores = require(script.Parent.Jugadores)

-- Lo que el cliente muestra de cada logro cumplido.
export type Hito = {
	Id: string,
	Titulo: string?, -- título del cartel si no es un logro común ("¡Nuevo récord!")
	Nombre: string,
	Descripcion: string,
	Monedas: number?,
	Suerte: number?,
	Coleccion: boolean, -- true si es una colección (completar el Índice de una zona, exóticas...)
	Cosmetico: string?, -- Grupo 3: lo que desbloquea ("Aura: Destellos de Cuarzo")
}

local NOMBRE_TIPO: { [string]: string } = {
	Aura = "Aura",
	Pico = "Diseño de pico",
	Vitrina = "Vitrina",
	Decoracion = "Decoración",
	Efecto = "Evolución del pico",
}

local Descubrimientos = {}

local function cosmetico(l: GameConfig.Logro): string?
	local c = l.Premio.Cosmetico
	local datos = c and Reglas.cosmetico(c.Tipo, c.Id)
	if not c or not datos then
		return nil
	end
	return (NOMBRE_TIPO[c.Tipo] or c.Tipo) .. ": " .. datos.Nombre
end

-- Cobra los logros que el jugador ya cumple y todavía no cobró (una sola vez cada uno). Da
-- más de una vuelta porque cobrar uno puede cumplir otro (Grupo 4: "completá 4 colecciones").
local function cobrar(jugador: Player, d: Jugadores.Datos): { Hito }
	local hitos: { Hito } = {}
	for _ = 1, 3 do
		local nuevos = Reglas.logrosNuevos(d)
		if #nuevos == 0 then
			break
		end
		for _, l in nuevos do
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
					Coleccion = l.Museo == true
						or l.Necesita.Tipo == "Gemas"
						or l.Id:sub(1, 9) == "Coleccion",
					Cosmetico = cosmetico(l),
				})
			end
		end
	end
	Jugadores.publicar(jugador)
	return hitos
end

-- Revisa los logros fuera de una revelación (por ejemplo, al terminar un evento).
function Descubrimientos.revisar(jugador: Player): { Hito }
	local d = Jugadores.obtener(jugador)
	return if d then cobrar(jugador, d) else {}
end

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
	return cobrar(jugador, d)
end

return Descubrimientos
