--!strict
-- Carteles para todo el servidor (no van al chat), con freno para no saturar
-- (GameConfig.Anuncios): como mucho uno cada Minimo segundos y Cola esperando; lo que sobra se
-- descarta. Tipos:
--   "Hallazgo"  gemas rarísimas y geodas que nacen raras: el que lo encontró puede no
--               anunciarlo (Ajustes.AnunciarHallazgos) y cada uno puede no verlos
--               (Ajustes.VerAnuncios, lo filtra el cliente).
--   "Evento" y "Jefe": se ven siempre y no hacen fila.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local A = GameConfig.Anuncios

type Anuncio = { Texto: string, Color: string, Tipo: string }

local cola: { Anuncio } = {}
local ultimo = -math.huge
local enviando = false

local Anuncios = {}

local function mandar(a: Anuncio)
	Remotos.Anuncio:FireAllClients(a.Texto, a.Color, a.Tipo)
end

local function vaciar()
	if enviando then
		return
	end
	enviando = true
	task.spawn(function()
		while #cola > 0 do
			local espera = A.Minimo - (os.clock() - ultimo)
			if espera > 0 then
				task.wait(espera)
			end
			ultimo = os.clock()
			mandar(table.remove(cola, 1) :: Anuncio)
		end
		enviando = false
	end)
end

function Anuncios.enviar(texto: string, color: string, tipo: string, de: Player?)
	if de then
		local d = Jugadores.obtener(de)
		if d and d.Ajustes.AnunciarHallazgos == false then
			return
		end
	end
	local a = { Texto = texto, Color = color, Tipo = tipo }
	if tipo ~= "Hallazgo" then
		mandar(a)
		return
	end
	if #cola >= A.Cola then
		return
	end
	table.insert(cola, a)
	vaciar()
end

return Anuncios
