--!strict
-- Guardado con ProfileStore (mismo patrón que Forja Rápida): bloqueo de sesión, autoguardado,
-- guardado al salir y al cerrar el servidor (ProfileStore ya engancha BindToClose).
--
-- Si no se puede cargar, se lo saca con "No pudimos cargar tu progreso, volvé a entrar" en vez
-- de dejarlo jugar sin guardar. Un error con un jugador no frena a los demás (el error de
-- Pisada Sonora que anotó la Revisión 11-10-2026).
--
-- Forma de los datos: VERSION. Si cambia, subirla y agregar la migración en `migrar`.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Jugadores = require(script.Parent.Jugadores)

local VERSION = 1
local NOMBRE_ALMACEN = "PescaAlCompas_Jugadores_v1"

-- Sin `wally install` no hay ProfileStore. En Studio se sigue en "modo prueba" (datos en
-- memoria, no se guarda nada) para poder probar el loop; en un servidor real es un error.
local paquetes = ServerScriptService:FindFirstChild("ServerPackages")
local moduloProfileStore = paquetes and paquetes:FindFirstChild("ProfileStore")
if not moduloProfileStore then
	if not RunService:IsStudio() then
		error("Guardado: falta ServerPackages/ProfileStore (correr wally install)")
	end
	warn("Guardado: MODO PRUEBA, falta ProfileStore. No se guarda nada (correr wally install)")
	local Prueba = {}
	function Prueba.cargar(jugador: Player): Jugadores.Datos?
		return Jugadores.nuevos()
	end
	function Prueba.guardarYa(_jugador: Player) end
	function Prueba.alSalir(_jugador: Player) end
	return Prueba
end

local ProfileStore = require(moduloProfileStore :: ModuleScript)

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

-- Lo guardado -> datos del juego (lo que falta queda como en un jugador nuevo).
local function deserializar(guardado: { [string]: any }): Jugadores.Datos
	local d: any = Jugadores.nuevos()
	for clave, v in guardado do
		if d[clave] ~= nil and typeof(d[clave]) == typeof(v) then
			d[clave] = copiar(v)
		end
	end
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
			perfil.Data.Datos = copiar(d)
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
