--!strict
-- Guardado de cada jugador con ProfileStore (Config.Guardado), que trae el bloqueo de
-- sesión: mientras un servidor tiene abierto el perfil de un jugador, ningún otro lo puede
-- pisar (así no se pierden ni se duplican criaturas al cambiar de servidor).
-- Se guarda: ADN, especies descubiertas, mutantes, las criaturas del laboratorio (con su
-- personalidad y variante), las variantes conseguidas, residuos, catalizadores, pistas
-- (compradas y gratis), premios de generación ya cobrados, niveles de las mejoras, los
-- pedidos del tablero, cuántos entregaste, lo de volver mañana y los "me gusta".
-- Cuándo: cada Config.Guardado.CadaCuanto segundos, al salir, al cerrar el servidor (todos en
-- paralelo, como mucho 25 s), cuando Roblox avisa que va a reiniciar el servidor y cuando se
-- pide (Guardado.guardar, por ejemplo después de una compra con Robux).
-- Versiones (SchemaVersion): 1 y 2 vivían en un DataStore propio (Config.Guardado.AlmacenViejo);
-- la primera vez que entra un jugador se leen de ahí y pasan al perfil (versión 3).
-- Si la carga falla, el jugador sale con un aviso ("volvé a entrar") en vez de jugar sin
-- guardar. El perfil de cada jugador es independiente: un error no frena a los demás.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Jugadores = require(script.Parent.Jugadores)
local Reloj = require(script.Parent.Reloj)
local Remotos = require(script.Parent.Remotos)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore) :: any

local G = Config.Guardado
local VERSION = 3
local MAXIMO_CRIATURAS = 1000
local TOPE_CIERRE = 25 -- segundos que se espera a que terminen los guardados al cerrar

type Guardados = Jugadores.Guardados

-- Lo que se usa de un perfil de ProfileStore.
type Senal = { Connect: (self: any, (...any) -> ()) -> { Disconnect: (self: any) -> () } }
type Perfil = {
	Data: { [string]: any },
	LastSavedData: { [string]: any },
	OnSave: Senal,
	OnAfterSave: Senal,
	OnSessionEnd: Senal,
	IsActive: (self: any) -> boolean,
	EndSession: (self: any) -> (),
	AddUserId: (self: any, userId: number) -> (),
	Save: (self: any) -> (),
}

ProfileStore.SetConstant("AUTO_SAVE_PERIOD", G.CadaCuanto)
local almacen = ProfileStore.New(G.Almacen, { SchemaVersion = 0 })

local perfiles: { [Player]: Perfil } = {}
local avisoSinAcceso = false
local cerrando = false -- el servidor se está apagando (BindToClose)

local Guardado = {}

local function clave(jugador: Player): string
	return "J_" .. jugador.UserId
end

-- ¿ProfileStore está usando el DataStore de verdad? (en Studio sin "Acceso de Studio a los
-- servicios de API" usa uno de mentira y no se guarda nada entre partidas)
local function hayAcceso(): boolean
	while ProfileStore.DataStoreState == "NotReady" do
		task.wait()
	end
	return ProfileStore.DataStoreState == "Access"
end

-- Lee el guardado de antes de ProfileStore (versiones 1 y 2). Devuelve ok y los datos crudos
-- (nil si el jugador es nuevo). Reintenta Config.Guardado.Intentos veces.
local function leerViejo(jugador: Player): (boolean, any)
	local ok, viejo = pcall(function()
		return DataStoreService:GetDataStore(G.AlmacenViejo)
	end)
	if not ok then
		return false, nil
	end
	local ultimoError: any = nil
	for intento = 1, G.Intentos do
		local leido, crudo = pcall(function()
			return (viejo :: DataStore):GetAsync(clave(jugador))
		end)
		if leido then
			return true, crudo
		end
		ultimoError = crudo
		task.wait(intento)
	end
	warn(
		"[Guardado] No se pudo leer el guardado viejo de "
			.. jugador.Name
			.. ": "
			.. tostring(ultimoError)
	)
	return false, nil
end

local function lista(conjunto: { [any]: boolean }): { any }
	local r = {}
	for k, v in conjunto do
		if v then
			table.insert(r, k)
		end
	end
	return r
end

-- Solo se guardan los "me gusta" que diste hoy o ayer (los viejos ya no importan).
local function meGustaRecientes(d: Jugadores.Datos): { [string]: number }
	local hoy = Reloj.dia()
	local r = {}
	for k, dia in d.MeGustaDados do
		if dia >= hoy - 1 then
			r[k] = dia
		end
	end
	return r
end

local function aGuardados(d: Jugadores.Datos): Guardados
	local criaturas = {}
	for _, u in d.Criaturas do
		table.insert(criaturas, {
			Clave = u.Clave,
			Mutante = u.Mutante,
			Personalidad = u.Personalidad,
			Variante = u.Variante,
		})
	end
	local pedidos = {}
	for lugar, p in d.Pedidos do
		table.insert(pedidos, { Lugar = lugar, Pedido = p })
	end
	return {
		SchemaVersion = VERSION,
		ADN = math.floor(d.ADN),
		Especies = lista(d.Especies),
		Mutantes = lista(d.Mutantes),
		Criaturas = criaturas,
		Pistas = table.clone(d.Pistas),
		PistasCompradas = d.PistasCompradas,
		PistasGratis = d.PistasGratis,
		GeneracionesPremiadas = lista(d.GeneracionesPremiadas),
		Mejoras = table.clone(d.Mejoras),
		Pedidos = pedidos,
		Entregados = d.Entregados,
		Residuos = table.clone(d.Residuos),
		Catalizadores = table.clone(d.Catalizadores),
		CatalizadoresVistos = lista(d.CatalizadoresVistos),
		Variantes = Jugadores.aLista(d.Variantes),
		Sellos = Jugadores.aLista(d.Sellos),
		UltimaVez = Reloj.ahora(),
		Fusiones = d.Fusiones,
		Diario = table.clone(d.Diario),
		Misiones = {
			Dia = d.Misiones.Dia,
			Lista = table.clone(d.Misiones.Lista),
			Bono = d.Misiones.Bono,
		},
		ExperimentoGanado = d.ExperimentoGanado,
		Metas = lista(d.Metas),
		Especiales = lista(d.Especiales),
		MeGusta = d.MeGusta,
		MeGustaDados = meGustaRecientes(d),
	}
end

-- Un pedido guardado sirve si tiene todas sus partes con el tipo correcto.
local function pedidoValido(p: any): boolean
	if typeof(p) ~= "table" or typeof(p.Requisito) ~= "table" then
		return false
	end
	return typeof(p.Id) == "number"
		and typeof(p.Cliente) == "number"
		and p.Cliente >= 1
		and p.Cliente <= #Config.Pedidos.Clientes
		and typeof(p.Texto) == "string"
		and typeof(p.Premio) == "number"
		and p.Premio >= 0
		and typeof(p.Dificultad) == "string"
		and typeof(p.Requisito.Tipo) == "string"
end

-- Revisa lo que vino del DataStore: solo pasan especies que existen y niveles válidos.
local function limpiar(crudo: any): Guardados?
	if typeof(crudo) ~= "table" then
		return nil
	end
	-- Versión 1 y 2: DataStore propio (campo "Version"). Desde la 3: ProfileStore ("SchemaVersion").
	local version = if typeof(crudo.SchemaVersion) == "number"
		then crudo.SchemaVersion
		else crudo.Version
	if version ~= 1 and version ~= 2 and version ~= VERSION then
		return nil
	end
	local function numero(x: any, minimo: number, maximo: number): number
		if typeof(x) ~= "number" or x ~= x then
			return minimo
		end
		return math.clamp(math.floor(x), minimo, maximo)
	end
	local function claves(x: any): { string }
		local r = {}
		if typeof(x) == "table" then
			for _, k in x do
				if typeof(k) == "string" and Fusion.porClave(k) then
					table.insert(r, k)
				end
			end
		end
		return r
	end
	local pistas = {}
	if typeof(crudo.Pistas) == "table" then
		for k, n in crudo.Pistas do
			if typeof(k) == "string" and Fusion.porClave(k) and typeof(n) == "number" then
				pistas[k] = numero(n, 0, 3)
			end
		end
	end
	local gens = {}
	if typeof(crudo.GeneracionesPremiadas) == "table" then
		for _, g in crudo.GeneracionesPremiadas do
			if g == 1 or g == 2 or g == 3 then
				table.insert(gens, g)
			end
		end
	end
	local m = if typeof(crudo.Mejoras) == "table" then crudo.Mejoras else {}
	local niveles = Mejoras.iniciales()
	for _, nombre in Mejoras.Orden do
		local inicial = (niveles :: any)[nombre] :: number
		(niveles :: any)[nombre] = numero(m[nombre], inicial, Mejoras.maximo(nombre))
	end
	-- Criaturas (versión 2). En la versión 1 no existen: las arma Jugadores.crear.
	-- La personalidad y la variante solo pasan si existen (si no, Jugadores pone la de su
	-- especie y ninguna variante).
	local criaturas: { Jugadores.CriaturaGuardada }? = nil
	if version >= 2 and typeof(crudo.Criaturas) == "table" then
		local leidas = {}
		for _, c in crudo.Criaturas do
			if
				#leidas < MAXIMO_CRIATURAS
				and typeof(c) == "table"
				and typeof(c.Clave) == "string"
				and Fusion.porClave(c.Clave)
			then
				table.insert(leidas, {
					Clave = c.Clave,
					Mutante = c.Mutante == true,
					Personalidad = if typeof(c.Personalidad) == "string"
							and Personalidades.Datos[c.Personalidad]
						then c.Personalidad
						else nil,
					Variante = if typeof(c.Variante) == "string"
							and Catalizadores.porClave(c.Variante)
						then c.Variante
						else nil,
				})
			end
		end
		criaturas = leidas
	end
	local variantes = {}
	if typeof(crudo.Variantes) == "table" then
		for _, texto in crudo.Variantes do
			local especie, v =
				string.match(if typeof(texto) == "string" then texto else "", "^([^|]+)|(.+)$")
			if especie and v and Fusion.porClave(especie) and Catalizadores.porClave(v) then
				table.insert(variantes, especie .. "|" .. v)
			end
		end
	end
	local sellos = {}
	if typeof(crudo.Sellos) == "table" then
		for _, texto in crudo.Sellos do
			local especie, p =
				string.match(if typeof(texto) == "string" then texto else "", "^([^|]+)|(.+)$")
			if especie and p and Fusion.porClave(especie) and Personalidades.Datos[p] then
				table.insert(sellos, especie .. "|" .. p)
			end
		end
	end
	local pedidos = {}
	if typeof(crudo.Pedidos) == "table" then
		for _, g in crudo.Pedidos do
			if typeof(g) == "table" and typeof(g.Lugar) == "number" and pedidoValido(g.Pedido) then
				table.insert(pedidos, { Lugar = math.floor(g.Lugar), Pedido = g.Pedido })
			end
		end
	end
	-- Residuos (parejas de especies que existen) y catalizadores (de los que existen).
	local residuos = {}
	if typeof(crudo.Residuos) == "table" then
		for _, r in crudo.Residuos do
			if
				#residuos < 100
				and typeof(r) == "table"
				and typeof(r.A) == "string"
				and typeof(r.B) == "string"
				and Fusion.porClave(r.A)
				and Fusion.porClave(r.B)
			then
				table.insert(residuos, { A = r.A, B = r.B })
			end
		end
	end
	local catalizadores, vistos = {}, {}
	for _, c in Catalizadores.Lista do
		if typeof(crudo.Catalizadores) == "table" then
			catalizadores[c.Clave] = numero(crudo.Catalizadores[c.Clave], 0, 1e6)
		end
		if
			typeof(crudo.CatalizadoresVistos) == "table"
			and table.find(crudo.CatalizadoresVistos, c.Clave)
		then
			table.insert(vistos, c.Clave)
		end
	end
	-- Volver mañana (Parte 8): racha, misiones del día, metas y especies especiales.
	local diario = nil
	if typeof(crudo.Diario) == "table" then
		diario = {
			Racha = numero(crudo.Diario.Racha, 0, #Config.Diario.Premios),
			UltimoDia = numero(crudo.Diario.UltimoDia, -1, 1e9),
		}
	end
	local misiones = nil
	if typeof(crudo.Misiones) == "table" and typeof(crudo.Misiones.Lista) == "table" then
		local leidas = {}
		for _, mision in crudo.Misiones.Lista do
			if
				#leidas < Config.Misiones.PorDia
				and typeof(mision) == "table"
				and typeof(mision.Tipo) == "string"
				and typeof(mision.Meta) == "number"
				and typeof(mision.Progreso) == "number"
			then
				table.insert(leidas, {
					Tipo = mision.Tipo,
					Meta = numero(mision.Meta, 1, 1000),
					Progreso = numero(mision.Progreso, 0, 1000),
					Dato = if typeof(mision.Dato) == "string" then mision.Dato else nil,
					Hecha = mision.Hecha == true,
				})
			end
		end
		misiones = {
			Dia = numero(crudo.Misiones.Dia, -1, 1e9),
			Lista = leidas,
			Bono = crudo.Misiones.Bono == true,
		}
	end
	local metas = {}
	for _, k in if typeof(crudo.Metas) == "table" then crudo.Metas else {} do
		if typeof(k) == "string" then
			table.insert(metas, k)
		end
	end
	local meGustaDados = {}
	if typeof(crudo.MeGustaDados) == "table" then
		for k, dia in crudo.MeGustaDados do
			if typeof(k) == "string" and typeof(dia) == "number" then
				meGustaDados[k] = math.floor(dia)
			end
		end
	end
	local especiales = {}
	for _, k in if typeof(crudo.Especiales) == "table" then crudo.Especiales else {} do
		local c = if typeof(k) == "string" then Fusion.porClave(k) else nil
		if c and c.Especial then
			table.insert(especiales, k)
		end
	end

	return {
		SchemaVersion = VERSION,
		ADN = numero(crudo.ADN, 0, 1e15),
		UltimaVez = if typeof(crudo.UltimaVez) == "number" then crudo.UltimaVez else nil,
		Fusiones = numero(crudo.Fusiones, 0, 1e9),
		Diario = diario,
		Misiones = misiones,
		ExperimentoGanado = numero(crudo.ExperimentoGanado, -1, 1e9),
		Metas = metas,
		Especiales = especiales,
		MeGusta = numero(crudo.MeGusta, 0, 1e9),
		MeGustaDados = meGustaDados,
		Residuos = residuos,
		Catalizadores = catalizadores,
		CatalizadoresVistos = vistos,
		Variantes = variantes,
		Sellos = sellos,
		Especies = claves(crudo.Especies),
		Mutantes = claves(crudo.Mutantes),
		Criaturas = criaturas,
		Pistas = pistas,
		PistasCompradas = numero(crudo.PistasCompradas, 0, 1e6),
		PistasGratis = numero(crudo.PistasGratis, 0, 1e6),
		GeneracionesPremiadas = gens,
		Mejoras = niveles,
		Pedidos = pedidos,
		Entregados = numero(crudo.Entregados, 0, 1e9),
	}
end

-- Pasa lo que el jugador tiene ahora al perfil (ProfileStore lo guarda en el próximo guardado).
local function volcar(jugador: Player, perfil: Perfil)
	local d = Jugadores.obtener(jugador)
	if d then
		perfil.Data = aGuardados(d) :: any
	end
end

-- Lo que está guardado en el perfil, pasando antes por la migración si viene de la versión 1
-- o 2. Devuelve ok y los datos crudos (o nil si es un jugador nuevo).
local function migrar(jugador: Player, perfil: Perfil): (boolean, any)
	local version = perfil.Data.SchemaVersion
	if typeof(version) == "number" and version >= VERSION then
		return true, perfil.Data
	end
	-- Perfil nuevo: ¿había un guardado de antes de ProfileStore?
	if not hayAcceso() then
		return true, nil -- en Studio sin acceso no hay guardados de verdad
	end
	local ok, crudo = leerViejo(jugador)
	if not ok then
		return false, nil
	end
	local limpios = limpiar(crudo)
	if limpios then
		perfil.Data = limpios :: any -- ya queda en la versión 3
		print(
			("[Guardado] %s: guardado viejo (versión %s) pasado a ProfileStore."):format(
				jugador.Name,
				tostring(crudo.SchemaVersion or crudo.Version)
			)
		)
		return true, perfil.Data
	end
	perfil.Data = { SchemaVersion = VERSION }
	return true, nil
end

-- Abre la sesión del jugador y carga sus datos. Devuelve los datos (nil si es nuevo) y si se
-- pudo. Si no se pudo, el jugador ya salió del juego con el aviso de Config.Guardado.
function Guardado.cargar(jugador: Player): (Guardados?, boolean)
	if not hayAcceso() and not avisoSinAcceso then
		avisoSinAcceso = true
		warn(
			"[Guardado] Sin acceso al DataStore (en Studio: Configuración del juego > Seguridad >"
				.. " Acceso de Studio a los servicios de API). Se juega sin guardar entre partidas."
		)
	end
	local seFue = function()
		return jugador.Parent ~= Players
	end
	local perfil: Perfil? = almacen:StartSessionAsync(clave(jugador), { Cancel = seFue })
	if not perfil then
		if not seFue() then
			warn("[Guardado] No se pudo abrir el perfil de " .. jugador.Name)
			jugador:Kick(G.AvisoError)
		end
		return nil, false
	end
	local p = perfil :: Perfil
	if seFue() then
		p:EndSession()
		return nil, false
	end
	local ok, crudo = migrar(jugador, p)
	if not ok then
		p:EndSession()
		jugador:Kick(G.AvisoError)
		return nil, false
	end
	p:AddUserId(jugador.UserId)
	p.OnSave:Connect(function()
		volcar(jugador, p)
	end)
	-- Si otro servidor se queda con el perfil (el jugador entró a otro), este lo suelta.
	p.OnSessionEnd:Connect(function()
		local abierta = perfiles[jugador] == p -- si no, la cerró este servidor (salir)
		if abierta then
			perfiles[jugador] = nil
		end
		if abierta and not seFue() and not cerrando and not ProfileStore.IsClosing then
			jugador:Kick(G.AvisoOtroServidor)
		end
	end)
	perfiles[jugador] = p
	return limpiar(crudo), true
end

-- El perfil abierto de un jugador (nil si no tiene). Lo usan las compras con Robux.
function Guardado.perfil(jugador: Player): Perfil?
	return perfiles[jugador]
end

-- Guarda ya y espera a que Roblox lo confirme (como mucho `tope` segundos, 15 si no se dice).
-- Devuelve true si quedó guardado.
function Guardado.guardar(jugador: Player, tope: number?): boolean
	local p = perfiles[jugador]
	if not p or not p:IsActive() then
		return false
	end
	local listo = false
	local conexion = p.OnAfterSave:Connect(function()
		listo = true
	end)
	p:Save()
	local inicio = os.clock()
	while not listo and os.clock() - inicio < (tope or 15) do
		task.wait(0.1)
	end
	conexion:Disconnect()
	return listo
end

-- Al salir: lo último que tiene pasa al perfil y se cierra la sesión (ProfileStore guarda y
-- suelta el bloqueo, así puede entrar en otro servidor).
function Guardado.salir(jugador: Player)
	local p = perfiles[jugador]
	perfiles[jugador] = nil
	if p and p:IsActive() then
		volcar(jugador, p)
		p:EndSession()
	end
end

function Guardado.iniciar()
	-- El guardado automático lo hace ProfileStore cada Config.Guardado.CadaCuanto segundos.
	-- Al cerrar el servidor: todos en paralelo y como mucho 25 s (Roblox corta a los 30).
	game:BindToClose(function()
		cerrando = true
		local pendientes = 0
		for jugador, p in perfiles do
			if p:IsActive() then
				pendientes += 1
				local conexion
				conexion = p.OnAfterSave:Connect(function()
					pendientes -= 1
					conexion:Disconnect()
				end)
				volcar(jugador, p)
				p:EndSession()
			end
		end
		if not hayAcceso() then
			return -- sin DataStore de verdad no hay nada que esperar
		end
		local inicio = os.clock()
		while pendientes > 0 and os.clock() - inicio < TOPE_CIERRE do
			task.wait(0.1)
		end
	end)
	-- Roblox avisa antes de reiniciar el servidor (game.ServerRestartScheduled): se guarda a
	-- todos y se les avisa. Si el evento no existe en esta versión, no pasa nada.
	local ok, senal = pcall(function()
		return (game :: any).ServerRestartScheduled
	end)
	if ok and typeof(senal) == "RBXScriptSignal" then
		senal:Connect(function()
			for jugador in perfiles do
				task.spawn(Guardado.guardar, jugador)
				Remotos.Aviso:FireClient(jugador, G.AvisoReinicio, "info")
			end
		end)
	end
	ProfileStore.OnError:Connect(
		function(mensaje: string, almacenNombre: string, claveNombre: string)
			warn(
				("[Guardado] ProfileStore (%s, %s): %s"):format(almacenNombre, claveNombre, mensaje)
			)
		end
	)
end

return Guardado
