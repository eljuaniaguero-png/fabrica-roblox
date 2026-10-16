--!strict
-- Cómo se escriben los números en pantalla (lógica pura, se prueba con Lune).
--   Formato.corto(2500)      -> "2,5K"     Formato.corto(1234567) -> "1,2M"
--   Formato.miles(2500)      -> "2.500"
--   Formato.suerte(2.06)     -> "x2,06"
--   Formato.unoEn(2427)      -> "1 en 2.427"

local Formato = {}

local SUFIJOS = { "K", "M", "B", "T", "Qa", "Qi" }

local function coma(texto: string): string
	return (texto:gsub("%.", ","))
end

-- 1234567 -> "1.234.567"
function Formato.miles(n: number): string
	local texto = tostring(math.floor(math.abs(n)))
	local r = texto:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if r:sub(1, 1) == "." then
		r = r:sub(2)
	end
	return if n < 0 then "-" .. r else r
end

-- Números cortos para el HUD: hasta 9.999 enteros, después K, M, B, T...
function Formato.corto(n: number): string
	if n ~= n then
		return "0"
	end
	local signo = if n < 0 then "-" else ""
	n = math.abs(n)
	if n < 10000 then
		return signo .. Formato.miles(n)
	end
	local i = 0
	while n >= 1000 and i < #SUFIJOS do
		n /= 1000
		i += 1
	end
	-- 1 decimal debajo de 100 (12,3K), entero arriba (123K); sin ",0"
	local texto = if n < 100
		then ("%.1f"):format(math.floor(n * 10) / 10)
		else tostring(math.floor(n))
	texto = texto:gsub("%.0$", "")
	return signo .. coma(texto) .. SUFIJOS[i]
end

function Formato.suerte(x: number): string
	local texto = ("%.2f"):format(x):gsub("0+$", ""):gsub("%.$", "")
	return "x" .. coma(texto)
end

function Formato.unoEn(n: number): string
	return "1 en " .. Formato.miles(math.max(1, math.floor(n + 0.5)))
end

-- Mayúsculas que también cambian las letras con tilde y la ñ: "Común" -> "COMÚN"
-- (string.upper solo cambia de la a a la z).
local TILDES =
	{ ["á"] = "Á", ["é"] = "É", ["í"] = "Í", ["ó"] = "Ó", ["ú"] = "Ú", ["ñ"] = "Ñ" }

function Formato.mayusculas(texto: string): string
	local r = texto:upper()
	for minuscula, mayuscula in TILDES do
		r = (r:gsub(minuscula, mayuscula))
	end
	return r
end

-- Segundos como reloj: 75 -> "1:15", 3700 -> "1:01:40".
function Formato.tiempo(segundos: number): string
	local t = math.max(0, math.ceil(segundos))
	local h, m, sg = t // 3600, (t % 3600) // 60, t % 60
	if h > 0 then
		return ("%d:%02d:%02d"):format(h, m, sg)
	end
	return ("%d:%02d"):format(m, sg)
end

return Formato
