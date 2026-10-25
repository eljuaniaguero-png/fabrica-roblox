--!strict
-- Guardado del progreso con ProfileStore (loleris), etapa 6. Misma forma que el de Forja Rápida:
--   * Bloqueo de sesión: dos servidores no pueden tener el mismo jugador a la vez (no se pisan
--     datos). Si otro servidor toma la sesión, se lo saca de este.
--   * Autoguardado cada 300 s (lo hace ProfileStore) y guardado al salir.
--   * Al cerrar el servidor, ProfileStore guarda a todos en paralelo (engancha BindToClose solo).
--   * Cuando Roblox avisa que va a reiniciar el servidor (game.ServerRestartScheduled), se guarda a
--     todos enseguida.
--   * Si no se puede cargar, se lo saca con "No pudimos cargar tu progreso, volvé a entrar" en vez
--     de dejarlo jugar sin guardar. Un error con un jugador no frena a los demás.
--   * En Studio sin acceso a la API, ProfileStore usa su versión de prueba (no guarda de verdad).
--
-- Qué se guarda: shared/Progreso (la partida en curso no). Forma: Config.VERSION; si cambia, se
-- sube y se agrega la migración en Progreso.migrar.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Progreso = require(Shared:WaitForChild("Progreso"))
local ProfileStore = require(ServerScriptService:WaitForChild("ServerPackages").ProfileStore)

local almacen = ProfileStore.New(Config.Guardado.Almacen, { Version = Config.VERSION, Datos = {} })

local Guardado = {}

local perfiles: { [Player]: any } = {}
local cerrandoAPedido: { [Player]: boolean } = {} -- la sesión la cerramos nosotros (no otro servidor)
-- De dónde sacar los datos de ahora al guardar (lo pone Main.server: Partida.de(jugador).Progreso).
local obtenerDatos: (Player) -> Progreso.Datos? = function(_jugador: Player): Progreso.Datos?
	return nil
end

function Guardado.alGuardar(funcion: (Player) -> Progreso.Datos?)
	obtenerDatos = funcion
end

-- Carga sus datos (espera). Devuelve nil si no se pudo: en ese caso ya lo sacó del juego.
function Guardado.cargar(jugador: Player): Progreso.Datos?
	local ok, perfil = pcall(function()
		return almacen:StartSessionAsync("Jugador_" .. jugador.UserId, {
			Cancel = function()
				return jugador.Parent ~= Players
			end,
		})
	end)
	if not ok or not perfil then
		if not ok then
			warn("[Guardado] Error al cargar a", jugador.Name, perfil)
		end
		if jugador.Parent == Players then
			jugador:Kick("No pudimos cargar tu progreso, volvé a entrar")
		end
		return nil
	end
	perfil:AddUserId(jugador.UserId) -- GDPR
	perfil:Reconcile()
	if jugador.Parent ~= Players then
		perfil:EndSession() -- se fue mientras cargaba
		return nil
	end
	local datos = Progreso.migrar(perfil.Data.Datos)
	perfil.Data.Version = Config.VERSION
	perfiles[jugador] = perfil
	-- Antes de cada guardado (automático, al salir o al cerrar) se copian los datos de ahora.
	perfil.OnSave:Connect(function()
		local d = obtenerDatos(jugador)
		if d then
			perfil.Data.Datos = Progreso.copiar(d)
		end
	end)
	perfil.OnSessionEnd:Connect(function()
		perfiles[jugador] = nil
		if cerrandoAPedido[jugador] then
			cerrandoAPedido[jugador] = nil
			return
		end
		if jugador.Parent == Players then
			-- Otro servidor tomó la sesión: se lo saca para no pisar datos.
			jugador:Kick("Tu progreso se abrió en otro servidor, volvé a entrar")
		end
	end)
	return datos
end

-- Guarda ahora, sin esperar (por ejemplo, al desbloquear algo).
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
		-- Los datos se copian YA: el guardado final de EndSession puede pasar después de que
		-- Main.server borre la partida, y ahí OnSave ya no los encuentra (se perdía lo último).
		local d = obtenerDatos(jugador)
		if d then
			perfil.Data.Datos = Progreso.copiar(d)
		end
		cerrandoAPedido[jugador] = true
		perfil:EndSession()
	end
end

function Guardado.iniciar()
	ProfileStore.OnError:Connect(function(mensaje: string, almacenNombre: string, clave: string)
		warn(("[Guardado] ProfileStore (%s, %s): %s"):format(almacenNombre, clave, mensaje))
	end)
	-- Roblox avisa antes de reiniciar el servidor: se guarda a todos. Si el evento no existe en
	-- esta versión de Roblox, no pasa nada.
	local ok, senal = pcall(function()
		return (game :: any).ServerRestartScheduled
	end)
	if ok and typeof(senal) == "RBXScriptSignal" then
		senal:Connect(function()
			for jugador in perfiles do
				Guardado.guardarYa(jugador)
			end
		end)
	end
end

return Guardado
