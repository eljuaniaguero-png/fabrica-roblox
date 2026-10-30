--!strict
-- Guardado de datos con ProfileStore (loleris): bloqueo de sesión (no se pisan datos entre
-- servidores), autoguardado cada 300 s y guardado al salir y al cerrar el servidor (ProfileStore
-- ya engancha BindToClose). Guarda la tabla de Jugadores.Datos, salvo la forja a medias (que
-- se entrega antes de salir).
--
-- Si no se puede cargar, se lo saca del juego con "No pudimos cargar tu progreso, volvé a
-- entrar" en vez de dejarlo jugar sin guardar. Un error con un jugador no frena a los demás.
-- En Studio sin acceso a la API usa la versión de prueba de ProfileStore (no guarda de verdad).
--
-- Forma de los datos: VERSION. Si cambia, subirla y agregar la migración en `migrar`.
-- Zonas, Llaves y Secretos usan números como clave: se guardan como lista de números.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService:WaitForChild("ServerPackages").ProfileStore)
local Jugadores = require(script.Parent.Jugadores)

local VERSION = 1
local NOMBRE_ALMACEN = "ForjaRapida_Jugadores_v1"
local NO_SE_GUARDA = { ForjaPendiente = true }
local CONJUNTOS_DE_NUMEROS = { Zonas = true, Llaves = true, Secretos = true }

local almacen = ProfileStore.New(NOMBRE_ALMACEN, { Version = VERSION, Datos = {} })

local Guardado = {}

local perfiles: { [Player]: any } = {}

local function copiar(v: any): any
	if typeof(v) ~= "table" then
		return v
	end
	local t = {}
	for k, x in v do
		t[k] = copiar(x)
	end
	return t
end

-- Datos del juego -> lo que va a la DataStore.
local function serializar(d: Jugadores.Datos): { [string]: any }
	local salida = {}
	for clave, v in d :: any do
		if NO_SE_GUARDA[clave] then
			continue
		end
		if CONJUNTOS_DE_NUMEROS[clave] then
			local lista = {}
			for n, si in v do
				if si then
					table.insert(lista, n)
				end
			end
			table.sort(lista)
			salida[clave] = lista
		else
			salida[clave] = copiar(v)
		end
	end
	return salida
end

-- Lo guardado -> datos del juego (lo que falta queda como en un jugador nuevo).
local function deserializar(guardado: { [string]: any }): Jugadores.Datos
	local d: any = Jugadores.nuevos()
	for clave, v in guardado do
		if NO_SE_GUARDA[clave] then
			continue
		end
		if CONJUNTOS_DE_NUMEROS[clave] and typeof(v) == "table" then
			local conjunto = {}
			for _, n in v do
				if typeof(n) == "number" then
					conjunto[n] = true
				end
			end
			d[clave] = conjunto
		else
			d[clave] = copiar(v)
		end
	end
	d.Zonas[1] = true
	return d
end

local function migrar(datos: any)
	-- Versión 1: la primera. Las próximas migraciones van acá (if datos.Version < 2 then ...).
	datos.Version = VERSION
end

-- Carga sus datos (espera). Devuelve nil si no se pudo: en ese caso ya lo sacó del juego.
function Guardado.cargar(jugador: Player): Jugadores.Datos?
	local ok, perfil = pcall(function()
		return almacen:StartSessionAsync("Jugador_" .. jugador.UserId, {
			Cancel = function()
				return jugador.Parent ~= Players
			end,
		})
	end)
	if not ok or not perfil then
		if not ok then
			warn("Guardado: error al cargar a", jugador.Name, perfil)
		end
		if jugador.Parent == Players then
			jugador:Kick("No pudimos cargar tu progreso, volvé a entrar")
		end
		return nil
	end
	perfil:AddUserId(jugador.UserId)
	perfil:Reconcile()
	if jugador.Parent ~= Players then
		perfil:EndSession() -- se fue mientras cargaba
		return nil
	end
	migrar(perfil.Data)
	local datos = deserializar(perfil.Data.Datos)
	perfiles[jugador] = perfil
	-- antes de cada guardado (automático o final) se copian los datos de ahora
	perfil.OnSave:Connect(function()
		local d = Jugadores.obtener(jugador)
		if d then
			perfil.Data.Datos = serializar(d)
		end
	end)
	perfil.OnSessionEnd:Connect(function()
		perfiles[jugador] = nil
		if jugador.Parent == Players then
			-- otro servidor tomó la sesión: se lo saca para no pisar datos
			jugador:Kick("Tu progreso se abrió en otro servidor, volvé a entrar")
		end
	end)
	return datos
end

-- Guarda ahora (por ejemplo después de una compra con Robux). No espera.
function Guardado.guardarYa(jugador: Player)
	local perfil = perfiles[jugador]
	if perfil and perfil:IsActive() then
		perfil:Save()
	end
end

-- Al salir: guardado final y se libera la sesión.
function Guardado.alSalir(jugador: Player)
	local perfil = perfiles[jugador]
	if perfil then
		perfil:EndSession() -- dispara OnSave con los datos de ahora
	end
end

return Guardado
