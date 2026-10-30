--!strict
-- Rasgos que se ven en una criatura ("con alas", "con cuernos"), para los pedidos.
-- Salen de las piezas que trae cada base (shared/Piezas.luau): la cabeza, las patas y la
-- cola o las alas. Una criatura tiene el rasgo si alguna de sus piezas lo trae.

local Fusion = require(script.Parent.Fusion)

local Rasgos = {}

-- Rasgo de la cabeza de cada base (las que no tienen nada llamativo no figuran).
local CABEZA: { [number]: string } = {
	[2] = "hojas",
	[3] = "hongo",
	[5] = "cuernos",
	[6] = "orejas",
	[7] = "pico",
	[8] = "cuernos",
	[9] = "antenas",
	[10] = "tresojos",
}

-- Rasgo de la cola o las alas de cada base.
local EXTREMIDAD: { [number]: string } = {
	[1] = "cola",
	[2] = "cola",
	[3] = "cola",
	[4] = "cola",
	[5] = "cola",
	[6] = "cola",
	[7] = "alas",
	[8] = "cola",
	[9] = "alas",
	[10] = "alas",
}

-- Rasgo de las patas de cada base.
local PATAS: { [number]: string } = {
	[2] = "seispatas",
	[3] = "dospatas",
	[7] = "dospatas",
	[9] = "seispatas",
}

-- Cómo se escribe cada rasgo en un pedido ("algo de fuego con alas").
Rasgos.Textos = {
	hojas = "con hojas en la cabeza",
	hongo = "con sombrero de hongo",
	cuernos = "con cuernos",
	orejas = "con orejas enormes",
	pico = "con pico",
	antenas = "con antenas",
	tresojos = "con tres ojos",
	cola = "con cola",
	alas = "con alas",
	seispatas = "de seis patas",
	dospatas = "de dos patas",
} :: { [string]: string }

-- Los rasgos de una especie, sin repetir.
function Rasgos.de(c: Fusion.Criatura): { string }
	local lista = {}
	for _, r in { CABEZA[c.Cabeza], EXTREMIDAD[c.Extremidad], PATAS[c.Patas] } do
		if r and not table.find(lista, r) then
			table.insert(lista, r)
		end
	end
	return lista
end

function Rasgos.tiene(c: Fusion.Criatura, rasgo: string): boolean
	return CABEZA[c.Cabeza] == rasgo or EXTREMIDAD[c.Extremidad] == rasgo or PATAS[c.Patas] == rasgo
end

return Rasgos
