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

-- Lee un atributo con claves separadas por ";" como conjunto.
function Formato.conjunto(texto: string?): { [string]: boolean }
	local r = {}
	for clave in (texto or ""):gmatch("[^;]+") do
		r[clave] = true
	end
	return r
end

return Formato
