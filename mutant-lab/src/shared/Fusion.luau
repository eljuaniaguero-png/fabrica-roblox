--!strict
-- Reglas fijas de fusión (ficha, puntos 2 a 4).
-- Una especie se identifica por el CONJUNTO de bases que la forman,
-- así que el resultado no depende del orden ni del jugador.

local Config = require(script.Parent.Config)
local Especies = require(script.Parent.Especies)

export type Criatura = {
	Clave: string, -- bases ordenadas, ej. "1-2-3"
	Nombre: string,
	Gen: number,
	Bases: { number }, -- en orden de la rueda: primero, (medio), último
	Cabeza: number,
	Cuerpo: number,
	Patas: number,
	Extremidad: number, -- cola o alas
	Rasgo: number,
	Color: Color3, -- color de la cabeza (para la UI)
}

local N = Config.TamanioRueda

local Fusion = {}

-- Pasos que hay que avanzar en la rueda (sentido horario) para ir de a hasta b.
local function avance(a: number, b: number): number
	return (b - a) % N
end

local function siguiente(a: number, pasos: number): number
	return (a - 1 + pasos) % N + 1
end

local function clave(bases: { number }): string
	local copia = table.clone(bases)
	table.sort(copia)
	local partes = {}
	for _, b in copia do
		table.insert(partes, tostring(b))
	end
	return table.concat(partes, "-")
end

function Fusion.base(n: number): Criatura
	local e = Especies[n]
	return {
		Clave = tostring(n),
		Nombre = e.Nombre,
		Gen = 1,
		Bases = { n },
		Cabeza = n,
		Cuerpo = n,
		Patas = n,
		Extremidad = n,
		Rasgo = n,
		Color = e.Color,
	}
end

-- Gen 2: el "primero" es el que está antes en la rueda por el camino corto.
local function gen2(a: number, b: number): Criatura?
	local primero, segundo
	local d = avance(a, b)
	if d >= 1 and d <= Config.DistanciaMaxima then
		primero, segundo = a, b
	elseif N - d >= 1 and N - d <= Config.DistanciaMaxima then
		primero, segundo = b, a
	else
		return nil
	end
	local p, s = Especies[primero], Especies[segundo]
	return {
		Clave = clave({ primero, segundo }),
		Nombre = p.Silabas[1] .. s.Silabas[2] .. s.Silabas[3],
		Gen = 2,
		Bases = { primero, segundo },
		Cabeza = primero,
		Cuerpo = segundo,
		Patas = primero,
		Extremidad = segundo,
		Rasgo = segundo,
		Color = p.Color,
	}
end

-- Gen 3: tres bases seguidas en la rueda (primero, medio, último).
local function gen3(bases: { number }): Criatura?
	if #bases ~= 3 then
		return nil
	end
	local conjunto = {}
	for _, b in bases do
		conjunto[b] = true
	end
	for _, f in bases do
		local m, u = siguiente(f, 1), siguiente(f, 2)
		if conjunto[m] and conjunto[u] then
			local ep, em, eu = Especies[f], Especies[m], Especies[u]
			return {
				Clave = clave({ f, m, u }),
				Nombre = ep.Silabas[1] .. em.Silabas[2] .. eu.Silabas[3],
				Gen = 3,
				Bases = { f, m, u },
				Cabeza = f,
				Cuerpo = m,
				Patas = u,
				Extremidad = u,
				Rasgo = m,
				Color = ep.Color,
			}
		end
	end
	return nil
end

-- Devuelve la especie que sale de fusionar x con y, o nil si no reaccionan.
function Fusion.fusionar(x: Criatura, y: Criatura): Criatura?
	if x.Gen == 1 and y.Gen == 1 then
		if x.Bases[1] == y.Bases[1] then
			return nil
		end
		return gen2(x.Bases[1], y.Bases[1])
	end
	local dos, uno
	if x.Gen == 2 and y.Gen == 1 then
		dos, uno = x, y
	elseif x.Gen == 1 and y.Gen == 2 then
		dos, uno = y, x
	else
		return nil
	end
	local b = uno.Bases[1]
	if table.find(dos.Bases, b) then
		return nil
	end
	return gen3({ dos.Bases[1], dos.Bases[2], b })
end

-- Las 50 especies descubribles, en orden: bases, gen 2, gen 3.
function Fusion.todas(): { Criatura }
	local lista = {}
	for n = 1, N do
		table.insert(lista, Fusion.base(n))
	end
	for a = 1, N do
		for d = 1, Config.DistanciaMaxima do
			local c = gen2(a, siguiente(a, d))
			if c then
				table.insert(lista, c)
			end
		end
	end
	for a = 1, N do
		local c = gen3({ a, siguiente(a, 1), siguiente(a, 2) })
		if c then
			table.insert(lista, c)
		end
	end
	return lista
end

-- Colores de una pieza: cada pieza conserva el color del padre que la trae,
-- y sus manchas llevan el color del padre siguiente (así se nota la mezcla).
function Fusion.pintura(c: Criatura, base: number): (Color3, Color3)
	if c.Gen == 1 then
		local e = Especies[base]
		return e.Color, e.Manchas
	end
	local i = table.find(c.Bases, base) or 1
	local otra = c.Bases[i % #c.Bases + 1]
	return Especies[base].Color, Especies[otra].Color
end

-- Busca una especie por nombre (útil para pruebas y para la vitrina).
function Fusion.porNombre(nombre: string): Criatura?
	for _, c in Fusion.todas() do
		if c.Nombre == nombre then
			return c
		end
	end
	return nil
end

return Fusion
