--!strict
-- Generador de números al azar con semilla (xorshift de 32 bits), sin Random.new: Random no
-- existe en Lune, y así las pruebas dan exactamente los mismos números que el juego.
-- Lo usan Simulacion (desvíos, división de la bola y rotura de azules), Clavijas y Tienda.

local Azar = {}

local DESCARTE = 12 -- números que se tiran al empezar cada semilla

-- Devuelve una función que da un número de 0 a 1 (sin llegar a 1) cada vez que se llama.
function Azar.nuevo(semilla: number): () -> number
	local estado = math.floor(semilla) % 4294967296
	if estado == 0 then
		estado = 0x9E3779B9
	end
	local function siguiente(): number
		estado = bit32.bxor(estado, bit32.lshift(estado, 13))
		estado = bit32.bxor(estado, bit32.rshift(estado, 17))
		estado = bit32.bxor(estado, bit32.lshift(estado, 5))
		return estado / 4294967296
	end
	-- Con semillas chicas (1, 2, 3…) los primeros números salen muy bajos: se tiran los primeros.
	-- (Lo encontró pruebas/reliquias: las rarezas de la tienda salían 85/12/3 en vez de 70/25/5.)
	for _ = 1, DESCARTE do
		siguiente()
	end
	return siguiente
end

-- Mezcla una lista en el lugar (Fisher-Yates) con el generador dado.
function Azar.mezclar<T>(lista: { T }, azar: () -> number)
	for i = #lista, 2, -1 do
		local j = math.floor(azar() * i) + 1
		lista[i], lista[j] = lista[j], lista[i]
	end
end

return Azar
