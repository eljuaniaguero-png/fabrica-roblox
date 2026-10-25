--!strict
-- Misiones de Pesca al Compás (lo que más hizo volver en las referencias: lista a la derecha).
-- Primero una cadena fija que enseña el loop (pescar -> vender -> mejorar -> raros -> Afinados)
-- y después una ronda de repetibles que se agrandan en cada vuelta, así nunca se queda sin misión.
-- Es puro (sin servicios): lo usan el servidor para contar y el HUD para mostrar.
-- Regla de la ficha: todas las misiones dan Escamas, nunca más suerte.

export type Tipo = "Sacar" | "Vender" | "Escamas" | "Mejorar" | "Afinado" | "Racha" | "Peso"

export type Mision = {
	Tipo: Tipo,
	Meta: number,
	Premio: number, -- Escamas
	Texto: string, -- %d = meta
	RarezaMin: string?, -- solo "Sacar": cuenta si el pez es de esta rareza o mejor
	PesoMin: number?, -- solo "Peso": kg mínimos
}

local ListaMisiones = {}

ListaMisiones.Cadena = {
	{ Tipo = "Sacar", Meta = 1, Premio = 10, Texto = "Sacá tu primer pez" },
	{ Tipo = "Vender", Meta = 1, Premio = 15, Texto = "Vendé el balde en el puesto" },
	{ Tipo = "Mejorar", Meta = 1, Premio = 20, Texto = "Mejorá la caña o el balde" },
	{ Tipo = "Sacar", Meta = 5, Premio = 25, Texto = "Sacá %d peces" },
	{ Tipo = "Sacar", Meta = 1, Premio = 40, Texto = "Sacá un pez Raro o mejor", RarezaMin = "Raro" },
	{ Tipo = "Racha", Meta = 1, Premio = 40, Texto = "Hacé una racha de 5 aciertos" },
	-- 7 y 8 bajados (60 -> 45, 80 -> 50, OK de Gemini): con 220 juntas el jugador se salteaba el
	-- escalón de Caña 4 (160) y Balde 3 (120) sin pasar por el ritmo
	{ Tipo = "Afinado", Meta = 1, Premio = 45, Texto = "Sacá un pez AFINADO" },
	{ Tipo = "Escamas", Meta = 300, Premio = 50, Texto = "Ganá %d Escamas vendiendo" },
	{ Tipo = "Peso", Meta = 1, Premio = 100, Texto = "Sacá un pez de 3 kg o más", PesoMin = 3 },
	{ Tipo = "Sacar", Meta = 1, Premio = 150, Texto = "Sacá un pez Épico o mejor", RarezaMin = "Épico" },
	{ Tipo = "Mejorar", Meta = 3, Premio = 150, Texto = "Mejorá %d veces" },
	{ Tipo = "Sacar", Meta = 25, Premio = 200, Texto = "Sacá %d peces" },
} :: { Mision }

ListaMisiones.Repetibles = {
	{ Tipo = "Sacar", Meta = 15, Premio = 150, Texto = "Sacá %d peces" },
	{ Tipo = "Afinado", Meta = 3, Premio = 200, Texto = "Sacá %d peces AFINADOS" },
	{ Tipo = "Escamas", Meta = 1000, Premio = 250, Texto = "Ganá %d Escamas vendiendo" },
	{ Tipo = "Sacar", Meta = 3, Premio = 200, Texto = "Sacá %d peces Raros o mejores", RarezaMin = "Raro" },
	{ Tipo = "Racha", Meta = 5, Premio = 180, Texto = "Hacé %d rachas de 5" },
} :: { Mision }

ListaMisiones.CrecePorVuelta = 0.5 -- cada vuelta de repetibles pide y paga 50% más que la anterior

-- La misión número `indice` (1 = la primera). Nunca devuelve nil.
function ListaMisiones.obtener(indice: number): Mision
	local cadena = ListaMisiones.Cadena
	if indice <= #cadena then
		return cadena[math.max(indice, 1)]
	end
	local rep = ListaMisiones.Repetibles
	local i = indice - #cadena - 1
	local base = rep[i % #rep + 1]
	local factor = 1 + ListaMisiones.CrecePorVuelta * (i // #rep)
	return {
		Tipo = base.Tipo,
		Meta = math.ceil(base.Meta * factor),
		Premio = math.ceil(base.Premio * factor),
		Texto = base.Texto,
		RarezaMin = base.RarezaMin,
		PesoMin = base.PesoMin,
	}
end

function ListaMisiones.texto(m: Mision): string
	return if string.find(m.Texto, "%%d") then m.Texto:format(m.Meta) else m.Texto
end

return ListaMisiones
