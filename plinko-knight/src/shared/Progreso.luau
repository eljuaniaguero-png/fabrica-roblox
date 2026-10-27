--!strict
-- Lo que se guarda de cada jugador (etapa 6), sin Instances: la usan server/Guardado, server/Tiros
-- y las pruebas con Lune. La partida en curso NO se guarda (si salís a la mitad, la próxima vez
-- empezás de cero): solo el progreso entre partidas.
--
-- Datos: Version, MejorPiso, MejorZona, MejorGolpe, BolasDesbloqueadas, ReliquiasDesbloqueadas,
-- Logros, BolaElegida, PartidasJugadas, PartidasGanadas, JefesVencidos y Ajustes (sonido, música y
-- efectos reducidos, desde la versión 2). Las listas son listas de texto (así viajan bien por los
-- remotos y la DataStore).
--
-- Logros: los revisa el servidor después de cada tiro (alTirar) y de cada turno (alTurno). Cada
-- uno desbloquea una bola o una reliquia (Config.Bolas / Config.Reliquias, campos Desbloqueo y
-- Logro); los números están en Config.Logros.

local Config = require(script.Parent.Config)

export type Datos = {
	Version: number,
	MejorPiso: number,
	MejorZona: number,
	MejorGolpe: number,
	BolasDesbloqueadas: { string },
	ReliquiasDesbloqueadas: { string },
	Logros: { string },
	BolaElegida: string,
	PartidasJugadas: number,
	PartidasGanadas: number,
	JefesVencidos: number,
	Ajustes: Ajustes,
}

-- Lo que el jugador elige en la pantalla de Ajustes (etapa 7).
export type Ajustes = { Sonido: boolean, Musica: boolean, EfectosReducidos: boolean }

-- Algo que se desbloqueó recién (para el aviso grande "¡Nueva bola: Fuego!").
export type Nuevo = { Tipo: string, Id: string, Nombre: string }

local Progreso = {}

-- Datos de un jugador nuevo: la bola de hierro y las reliquias que están desde el principio.
function Progreso.nuevos(): Datos
	local reliquias = {}
	for _, id in Config.OrdenReliquias do
		if (Config.Reliquias :: any)[id].Desbloqueo == "inicio" then
			table.insert(reliquias, id)
		end
	end
	local bolas = {}
	for _, id in Config.OrdenBolas do
		if (Config.Bolas :: any)[id].Desbloqueo == "inicio" then
			table.insert(bolas, id)
		end
	end
	return {
		Version = Config.VERSION,
		MejorPiso = 0,
		MejorZona = 0,
		MejorGolpe = 0,
		BolasDesbloqueadas = bolas,
		ReliquiasDesbloqueadas = reliquias,
		Logros = {},
		BolaElegida = "hierro",
		PartidasJugadas = 0,
		PartidasGanadas = 0,
		JefesVencidos = 0,
		Ajustes = { Sonido = true, Musica = true, EfectosReducidos = false },
	}
end

-- Ajustes que mandó el cliente o que estaban guardados -> ajustes limpios (lo raro queda como
-- estaba en `base`).
function Progreso.limpiarAjustes(valor: any, base: Ajustes): Ajustes
	local a = table.clone(base)
	if typeof(valor) == "table" then
		for _, clave in { "Sonido", "Musica", "EfectosReducidos" } do
			if typeof(valor[clave]) == "boolean" then
				(a :: any)[clave] = valor[clave]
			end
		end
	end
	return a
end

-- Lo guardado -> datos completos y limpios: lo que falta queda como en un jugador nuevo, lo que no
-- existe más se descarta, y se sube la versión. Las migraciones de versiones futuras van acá
-- (if datos.Version < 2 then ... end).
function Progreso.migrar(guardado: any): Datos
	local d = Progreso.nuevos()
	if typeof(guardado) ~= "table" then
		return d
	end
	local function numero(clave: string)
		local v = guardado[clave]
		if typeof(v) == "number" and v == v and v >= 0 and v ~= math.huge then
			(d :: any)[clave] = math.floor(v)
		end
	end
	for _, clave in
		{
			"MejorPiso",
			"MejorZona",
			"MejorGolpe",
			"PartidasJugadas",
			"PartidasGanadas",
			"JefesVencidos",
		}
	do
		numero(clave)
	end
	-- Listas: se suman a las de un jugador nuevo, solo con Id que existen y sin repetir.
	local function lista(clave: string, existe: (string) -> boolean)
		local actual: { string } = (d :: any)[clave]
		if typeof(guardado[clave]) == "table" then
			for _, id in guardado[clave] do
				if typeof(id) == "string" and existe(id) and not table.find(actual, id) then
					table.insert(actual, id)
				end
			end
		end
	end
	lista("BolasDesbloqueadas", function(id: string): boolean
		return (Config.Bolas :: any)[id] ~= nil
	end)
	lista("ReliquiasDesbloqueadas", function(id: string): boolean
		return (Config.Reliquias :: any)[id] ~= nil
	end)
	lista("Logros", function(id: string): boolean
		return (Config.Bolas :: any)[id] ~= nil or (Config.Reliquias :: any)[id] ~= nil
	end)
	if typeof(guardado.BolaElegida) == "string" and table.find(d.BolasDesbloqueadas, guardado.BolaElegida) then
		d.BolaElegida = guardado.BolaElegida
	end
	-- Versión 2: los ajustes (si no estaban, quedan los de un jugador nuevo).
	d.Ajustes = Progreso.limpiarAjustes(guardado.Ajustes, d.Ajustes)
	d.Version = Config.VERSION
	return d
end

-- Copia profunda (para guardar y para mandarle al cliente).
function Progreso.copiar(d: Datos): Datos
	local c = table.clone(d)
	c.BolasDesbloqueadas = table.clone(d.BolasDesbloqueadas)
	c.ReliquiasDesbloqueadas = table.clone(d.ReliquiasDesbloqueadas)
	c.Logros = table.clone(d.Logros)
	c.Ajustes = table.clone(d.Ajustes)
	return c
end

function Progreso.tieneBola(d: Datos, bola: any): boolean
	return typeof(bola) == "string" and table.find(d.BolasDesbloqueadas, bola) ~= nil
end

-- Desbloquea `id` (bola o reliquia) si todavía no lo tenía. Devuelve el aviso, o nil.
local function desbloquear(d: Datos, tipo: string, id: string): Nuevo?
	local listaClave = if tipo == "bola" then "BolasDesbloqueadas" else "ReliquiasDesbloqueadas"
	local lista: { string } = (d :: any)[listaClave]
	if table.find(lista, id) then
		return nil
	end
	table.insert(lista, id)
	if not table.find(d.Logros, id) then
		table.insert(d.Logros, id)
	end
	local datos = if tipo == "bola" then (Config.Bolas :: any)[id] else (Config.Reliquias :: any)[id]
	return { Tipo = tipo, Id = id, Nombre = datos.Nombre }
end

-- Empieza una partida: cuenta la partida y recuerda la bola.
function Progreso.alEmpezar(d: Datos, bola: string)
	d.PartidasJugadas += 1
	d.BolaElegida = bola
end

-- Después de cada tiro (con el resultado de la simulación del servidor y el estado ya cobrado).
function Progreso.alTirar(d: Datos, e: any, res: any): { Nuevo }
	local L = Config.Logros
	local nuevos: { Nuevo } = {}
	local function sumar(n: Nuevo?)
		if n then
			table.insert(nuevos, n)
		end
	end
	d.MejorGolpe = math.max(d.MejorGolpe, math.floor(res.Danio))
	if #res.Recorridos >= L.EnjambreBolas then
		sumar(desbloquear(d, "reliquia", "enjambre"))
	end
	if res.Danio >= L.CoronaGolpe then
		sumar(desbloquear(d, "reliquia", "corona"))
	end
	for _, t in res.Toques do
		if t.Veces >= L.EcoVeces then
			sumar(desbloquear(d, "reliquia", "ecoInfinito"))
			break
		end
	end
	if e.Oro >= L.MidasOro then
		sumar(desbloquear(d, "reliquia", "midas"))
	end
	return nuevos
end

-- Después de cada turno. `piso` y `bola` son los de la pelea que se jugó (antes del turno).
function Progreso.alTurno(d: Datos, e: any, turno: any, piso: number, bola: string): { Nuevo }
	local L = Config.Logros
	local nuevos: { Nuevo } = {}
	local function sumar(n: Nuevo?)
		if n then
			table.insert(nuevos, n)
		end
	end
	local gano = turno.Resultado == "piso" or turno.Resultado == "gano"
	if not gano then
		return nuevos
	end
	local m = Config.Monstruos[math.clamp(piso, 1, #Config.Monstruos)]
	d.MejorPiso = math.max(d.MejorPiso, piso)
	d.MejorZona = math.max(d.MejorZona, m.Zona)
	if turno.Resultado == "piso" then
		-- Llegar a la zona de la bola de fuego (el piso que sigue).
		local siguiente = Config.Monstruos[math.clamp(piso + 1, 1, #Config.Monstruos)]
		d.MejorZona = math.max(d.MejorZona, siguiente.Zona)
		if siguiente.Zona >= L.ZonaFuego then
			sumar(desbloquear(d, "bola", "fuego"))
		end
	end
	if m.EsJefe then
		d.JefesVencidos += 1
		sumar(desbloquear(d, "bola", "partida"))
		if bola == "fuego" then
			sumar(desbloquear(d, "reliquia", "yesca"))
		end
		if e.Oro >= L.AvaroOro then
			sumar(desbloquear(d, "reliquia", "avaro"))
		end
	end
	if e.PeleasSinGolpe >= L.RachaPeleas then
		sumar(desbloquear(d, "reliquia", "racha"))
	end
	if turno.VidaCaballero < L.AlientoVida then
		sumar(desbloquear(d, "reliquia", "aliento"))
	end
	if turno.Resultado == "gano" then
		d.PartidasGanadas += 1
	end
	return nuevos
end

return Progreso
