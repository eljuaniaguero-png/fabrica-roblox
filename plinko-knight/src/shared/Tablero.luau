--!strict
-- Genera el tablero de la ficha como datos (sin Instances): 7 × 8 filas alternadas.
-- Lo usan la simulación (cliente y servidor), el cliente para dibujarlo y las pruebas de Lune.

local Config = require(script.Parent.Config)

export type Clavija = {
	Id: number,
	X: number,
	Y: number,
	Radio: number,
	Fila: number, -- 1 = la de arriba
	Tipo: string, -- "normal" (las rojas de la mejora "Duplica" van aparte: cambian por pelea)
}

export type Tablero = {
	Clavijas: { Clavija },
	ParedIzquierda: number, -- x
	ParedDerecha: number, -- x
	Techo: number, -- y: la bola no sube más que esto
	Fondo: number, -- y: al cruzarlo termina el tiro
	LanzadorX: number,
	LanzadorY: number,
}

local Tablero = {}

function Tablero.generar(): Tablero
	local c = Config.Tablero
	local clavijas: { Clavija } = {}
	for fila = 0, c.Filas - 1 do
		-- Las filas pares tienen todas las columnas; las impares una menos, corridas media separación.
		local cantidad = if fila % 2 == 0 then c.Columnas else c.Columnas - 1
		local y = c.PrimeraFila - fila * c.SeparacionY
		for i = 0, cantidad - 1 do
			local x = (i - (cantidad - 1) / 2) * c.SeparacionX
			table.insert(clavijas, {
				Id = #clavijas + 1,
				X = x,
				Y = y,
				Radio = c.RadioClavija,
				Fila = fila + 1,
				Tipo = "normal",
			})
		end
	end
	-- Las paredes dejan un hueco libre (más ancho que la bola) junto a las clavijas de las puntas.
	local mitad = (c.Columnas - 1) * c.SeparacionX / 2 + c.RadioClavija + c.HuecoPared
	return {
		Clavijas = clavijas,
		ParedIzquierda = -mitad,
		ParedDerecha = mitad,
		Techo = 3,
		Fondo = c.PrimeraFila - (c.Filas - 1) * c.SeparacionY - c.MargenAbajo,
		LanzadorX = 0,
		LanzadorY = 0,
	}
end

return Tablero
