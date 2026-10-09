--!strict
-- Formatos de texto que se repiten en la UI.

local HttpService = game:GetService("HttpService")

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

-- Criaturas iguales (misma especie, tipo, personalidad y variante) y cuántas hay.
export type Grupo = {
	Clave: string,
	Mutante: boolean,
	Personalidad: string?,
	Variante: string?,
	Cantidad: number,
}

-- Lee el atributo "Grupos" (JSON, lo arma Jugadores.grupos en el servidor).
function Formato.grupos(texto: string?): { Grupo }
	if not texto or texto == "" then
		return {}
	end
	local ok, lista = pcall(function()
		return HttpService:JSONDecode(texto)
	end)
	if not ok or typeof(lista) ~= "table" then
		return {}
	end
	return lista :: { Grupo }
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
