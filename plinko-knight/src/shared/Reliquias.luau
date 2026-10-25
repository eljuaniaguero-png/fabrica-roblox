--!strict
-- Reliquias del paso 5c, sin Instances (las usan Simulacion, Mazmorra, Tienda, el cliente y las
-- pruebas con Lune): datos, precio, venta, texto de cada una y ayudas para buscarlas en la lista.
-- Lo que hace cada una en el tiro está en shared/Simulacion; lo que hace en la partida (crecer,
-- interés), en shared/Mazmorra. Los números están en Config.Reliquias.

local Config = require(script.Parent.Config)

-- Una reliquia que tenés: su Id, el contador de las que crecen y lo que pagaste (para vender).
export type Tenida = { Id: string, Contador: number, Precio: number }

local Reliquias = {}

function Reliquias.datos(id: string): any
	return (Config.Reliquias :: any)[id]
end

function Reliquias.existe(id: any): boolean
	return typeof(id) == "string" and (Config.Reliquias :: any)[id] ~= nil
end

function Reliquias.rareza(id: string): any
	return (Config.Rarezas :: any)[Reliquias.datos(id).Rareza]
end

function Reliquias.precio(id: string): number
	return Reliquias.rareza(id).Precio
end

-- Lo que te dan al venderla: la mitad de lo que pagaste, para abajo.
function Reliquias.venta(tenida: Tenida): number
	return math.floor(tenida.Precio / 2)
end

-- La reliquia `id` en la lista (o nil).
function Reliquias.buscar(lista: { Tenida }?, id: string): Tenida?
	for _, r in lista or {} do
		if r.Id == id then
			return r
		end
	end
	return nil
end

function Reliquias.tiene(lista: { Tenida }?, id: string): boolean
	return Reliquias.buscar(lista, id) ~= nil
end

-- Qué hace, en una frase (con el contador de las que crecen).
function Reliquias.describir(id: string, contador: number?): string
	local d = Reliquias.datos(id)
	local n = contador or 0
	if id == "brasa" then
		return ("Al final del tiro: +%d Multi por cada clavija roja de tu tablero"):format(
			d.MultiPorRoja
		)
	elseif id == "rubi" then
		return ("Las rojas dan ×%d Multi de lo normal"):format(d.Factor)
	elseif id == "martillo" then
		return ("Al final: +%d Fuerza si tocaste %d clavijas o más"):format(d.Fuerza, d.Clavijas)
	elseif id == "cadena" then
		return ("Al final: +%d Multi por cada %d clavijas tocadas"):format(d.Multi, d.Cada)
	elseif id == "gemela" then
		return ("Cada bola se parte en 2 en su toque %d"):format(d.Toque)
	elseif id == "enjambre" then
		return ("Al final: ×%s Multi por cada bola extra"):format(
			tostring(d.PorBola):gsub("%.", ",")
		)
	elseif id == "hoja" then
		return ("Las bolas extra suman ×%d Fuerza"):format(d.Factor)
	elseif id == "bolsa" then
		return ("El interés de la tienda llega hasta %d"):format(d.InteresTope)
	elseif id == "avaro" then
		return ("Al final: +%d Multi por cada %d de oro que tengas"):format(d.Multi, d.Cada)
	elseif id == "toqueOro" then
		return ("Las doradas también dan +%d Multi"):format(d.Multi)
	elseif id == "trofeo" then
		return ("Crece: +%d Multi cada vez que matás de un tiro (ahora +%d)"):format(
			d.Multi,
			n * d.Multi
		)
	elseif id == "callo" then
		return ("Crece: +%d Fuerza por cada azul rota (ahora +%d)"):format(d.Fuerza, n * d.Fuerza)
	elseif id == "racha" then
		return ("Crece: ×Multi por peleas seguidas sin que te peguen (ahora ×%s)"):format(
			(tostring(1 + n * d.PorPelea):gsub("%.", ","))
		)
	elseif id == "yesca" then
		return "Con la bola de fuego: la quemadura hace tanto daño como tu Multi"
	elseif id == "vidrio" then
		return ("Las azules dan ×%d, pero se rompen 1 de cada %d"):format(
			d.PorMulti,
			math.floor(1 / d.Rotura + 0.5)
		)
	elseif id == "aliento" then
		return ("Al final: ×%d Multi si te queda menos de %d de vida"):format(d.Factor, d.Vida)
	elseif id == "paciencia" then
		return ("El 1.er tiro de cada pelea no hace daño; el 2.º tiene ×%d Multi"):format(
			d.Factor
		)
	elseif id == "corona" then
		return ("Al final: ×%d Multi en todos los tiros"):format(d.Factor)
	elseif id == "ecoInfinito" then
		return ("Las violetas hacen contar %d veces la próxima clavija"):format(d.Veces)
	elseif id == "midas" then
		return ("Cada clavija que toca la primera bola da +%d oro"):format(d.Oro)
	end
	return ""
end

-- Las chances de rareza en la tienda, en texto.
function Reliquias.chances(): string
	local total = 0
	for _, r in Config.Rarezas do
		total += r.Peso
	end
	local partes = {}
	for _, id in Config.OrdenRarezas do
		local r = (Config.Rarezas :: any)[id]
		table.insert(partes, ("%s %d %%"):format(r.Nombre, math.floor(r.Peso / total * 100 + 0.5)))
	end
	return table.concat(partes, ", ")
end

return Reliquias
