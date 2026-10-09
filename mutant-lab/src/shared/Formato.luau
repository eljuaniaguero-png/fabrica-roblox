--!strict
-- Formatos de texto que se repiten en la UI.

local Formato = {}

-- 100000 -> "100.000"
function Formato.numero(n: number): string
	local texto = tostring(math.floor(n))
	local resultado = texto:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if resultado:sub(1, 1) == "." then
		resultado = resultado:sub(2)
	end
	return resultado
end

export type Cuenta = { Normales: number, Mutantes: number }

-- Lee el atributo "Criaturas" ("1:2:0;1-2:1:1"): cuántas normales y mutantes de cada especie.
function Formato.inventario(texto: string?): { [string]: Cuenta }
	local r = {}
	for clave, n, m in (texto or ""):gmatch("([^;:]+):(%d+):(%d+)") do
		r[clave] = { Normales = tonumber(n) or 0, Mutantes = tonumber(m) or 0 }
	end
	return r
end

-- Lee un atributo con claves separadas por ";" como conjunto.
function Formato.conjunto(texto: string?): { [string]: boolean }
	local r = {}
	for clave in (texto or ""):gmatch("[^;]+") do
		r[clave] = true
	end
	return r
end

return Formato
