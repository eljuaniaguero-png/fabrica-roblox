--!strict
-- Lo que el cliente sabe de su jugador: los atributos que publica el servidor
-- (Jugadores.publicar), ya convertidos. Solo para mostrar; las cuentas de verdad las hace el
-- servidor.
--   "Cuarzo;Jaspe" -> { Cuarzo = true, Jaspe = true }   Mochila (JSON) -> { gema = cantidad }

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Datos = {}

local yo = Players.LocalPlayer

function Datos.numero(nombre: string): number
	local v = yo:GetAttribute(nombre)
	return if typeof(v) == "number" and v == v then v else 0
end

function Datos.texto(nombre: string): string
	local v = yo:GetAttribute(nombre)
	return if typeof(v) == "string" then v else ""
end

function Datos.conjunto(nombre: string): { [string]: boolean }
	local r = {}
	for parte in Datos.texto(nombre):gmatch("[^;]+") do
		r[parte] = true
	end
	return r
end

function Datos.zonas(): { [number]: boolean }
	local r = { [1] = true }
	for parte in Datos.texto("Zonas"):gmatch("[^;]+") do
		local n = tonumber(parte)
		if n then
			r[n] = true
		end
	end
	return r
end

function Datos.mochila(): { [string]: number }
	local texto = Datos.texto("Mochila")
	if texto == "" then
		return {}
	end
	local ok, t = pcall(HttpService.JSONDecode, HttpService, texto)
	if not ok or typeof(t) ~= "table" then
		return {}
	end
	local r = {}
	for k, v in t :: { [any]: any } do
		if typeof(k) == "string" and typeof(v) == "number" then
			r[k] = v
		end
	end
	return r
end

-- Llama a `fn` cuando cambia cualquiera de esos atributos (una vez por cuadro como mucho).
function Datos.alCambiar(nombres: { string }, fn: () -> ())
	local pendiente = false
	local function avisar()
		if pendiente then
			return
		end
		pendiente = true
		task.defer(function()
			pendiente = false
			fn()
		end)
	end
	for _, n in nombres do
		yo:GetAttributeChangedSignal(n):Connect(avisar)
	end
end

return Datos
