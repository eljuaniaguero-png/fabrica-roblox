--!strict
-- Cliente de Plinko Knight (etapas 2 a 4): arma el tablero, apunta con mouse o dedo y, al
-- soltar, pide el tiro al servidor (número y semilla) y tira la bola. La bola sigue el
-- recorrido de shared/Simulacion (interpolado, así se ve suave a cualquier FPS); cada clavija
-- tocada brilla, salta lo que sumó y sube el panel FUERZA × MULTI. Al terminar, el servidor
-- revisa el golpe, juega el turno y devuelve qué pasó; el cliente solo lo anima (golpe al
-- monstruo, contraataque, piso nuevo, perder o ganar la mazmorra).
-- Paso 5a: cada clavija tiene el color de su tipo (el tablero de la partida lo manda el servidor)
-- y la bola de fuego es naranja y la
-- quemadura salta sobre el monstruo; con la partida se ven las dos bolas. Las azules rotas
-- quedan como hueco. Abajo, la fila con tu bola y tus clavijas especiales.
-- Paso 5b: al ganar una pelea se abre la tienda (TiendaVista). Las mejoras de clavija y los
-- pergaminos de forja y martillo piden tocar clavijas (Seleccion); todo lo valida el servidor.
-- Paso 5c: la fila de reliquias (TiendaVista). Al final de cada tiro, las que actuaron saltan en
-- orden y muestran lo que sumaron o multiplicaron.
-- Paso 5d: zona y pelea arriba, cartel con la maña del jefe, "Próximo" en la tienda y el cofre.
-- Etapa 6: el progreso guardado llega del servidor (remoto Progreso). Antes de cada partida
-- (fase "inicio") se elige la bola; al desbloquear algo sale un aviso grande.
-- Etapa 7: todas las pantallas con client/Estilo; la cámara deja libres las franjas de arriba y de
-- abajo; Ajustes (sonido, música, efectos reducidos) se guardan con el progreso. "Volver a bajar"
-- arranca otra partida con la misma bola en un toque.
-- Input con UserInputService: los otros juegos no usan el Input Action System.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Simulacion = require(Shared:WaitForChild("Simulacion"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local ProgresoModulo = require(Shared:WaitForChild("Progreso"))
local TiendaModulo = require(Shared:WaitForChild("Tienda"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Escena = require(script.Parent:WaitForChild("Escena"))
local MonstruoVista = require(script.Parent:WaitForChild("Monstruo"))
local Numeros = require(script.Parent:WaitForChild("Numeros"))
local PantallasModulo = require(script.Parent:WaitForChild("Pantallas"))
local SeleccionModulo = require(script.Parent:WaitForChild("Seleccion"))
local TiendaVistaModulo = require(script.Parent:WaitForChild("TiendaVista"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))
local Sonidos = require(script.Parent:WaitForChild("Sonidos"))

local jugador = Players.LocalPlayer

-- Durante la pelea no se camina: apagar los controles (también el joystick del celular).
task.spawn(function()
	local scripts = jugador:WaitForChild("PlayerScripts")
	local modulo = scripts:WaitForChild("PlayerModule", 10)
	if modulo and modulo:IsA("ModuleScript") then
		local ok, playerModule = pcall(require, modulo)
		if ok and playerModule then
			(playerModule :: any):GetControls():Disable()
		end
	end
end)

local carpetaRemotos = game:GetService("ReplicatedStorage"):WaitForChild("Remotos")
local remotos = {
	PedirTiro = carpetaRemotos:WaitForChild("PedirTiro") :: RemoteFunction,
	Tirar = carpetaRemotos:WaitForChild("Tirar") :: RemoteFunction,
	ObtenerEstado = carpetaRemotos:WaitForChild("ObtenerEstado") :: RemoteFunction,
	VolverABajar = carpetaRemotos:WaitForChild("VolverABajar") :: RemoteFunction,
	Tienda = carpetaRemotos:WaitForChild("Tienda") :: RemoteFunction,
	UsarPergamino = carpetaRemotos:WaitForChild("UsarPergamino") :: RemoteFunction,
	EstadoCambio = carpetaRemotos:WaitForChild("EstadoCambio") :: RemoteEvent,
	Progreso = carpetaRemotos:WaitForChild("Progreso") :: RemoteEvent,
	ObtenerProgreso = carpetaRemotos:WaitForChild("ObtenerProgreso") :: RemoteFunction,
}

local escena = Escena.armar()
local panel = Numeros.crearPanel(escena.AnclaTotal)
local tablero = escena.Tablero
local colorBrillo = Color3.fromHex(Config.Colores.Brillo)
local colorBola = Color3.fromHex(Config.Colores.Bola)
local colorFuego = Color3.fromHex(Config.Colores.BolaFuego)
local colorQuemadura = Color3.fromHex(Config.Colores.Quemadura)
local monstruo = MonstruoVista.crear(escena.Cartel, escena.BarraMonstruo)
local pantallas = PantallasModulo.crear()
local seleccion = SeleccionModulo.crear(escena)
escena.ponerZonaLibre(pantallas.zonaLibre)

local estado: Mazmorra.Estado = Mazmorra.nueva() -- se pisa con el del servidor al arrancar
estado.Fase = "inicio" -- hasta que el servidor termine de cargar el progreso, no se tira
local progreso: ProgresoModulo.Datos? = nil
local abrirInicio: () -> ()
local mostrarAvisos: () -> ()
local tirosPelea = 0 -- para la consola: cuántos tiros lleva la pelea actual
-- Para la pantalla final: el récord al empezar la partida y lo que se desbloqueó en ella.
local mejorAntes = 0
local desbloqueosPartida: { string } = {}

local angulo = 0
local apuntando = false -- dedo apoyado o botón del mouse apretado
local tirando = false -- hay una bola en juego: no se puede tirar otra

-- Línea de puntos: solo el primer tramo del vuelo.
local function dibujarLinea()
	local puntos = Simulacion.primerTramo(tablero, angulo, Config.Bola)
	for i, p in escena.Puntos do
		local punto = puntos[i]
		if punto and not tirando then
			p.Position = escena.aMundo(punto.X, punto.Y, 0.6)
			p.Transparency = 0.15 + 0.6 * (i - 1) / #escena.Puntos
		else
			p.Transparency = 1
		end
	end
end

local function apuntarA(posicionPantalla: Vector2)
	local x, y = escena.aTablero(posicionPantalla)
	local dx, dy = x - tablero.LanzadorX, y - tablero.LanzadorY
	if dx == 0 and dy == 0 then
		return
	end
	angulo = Simulacion.limitarAngulo(math.deg(math.atan2(dx, -dy)))
	dibujarLinea()
end

-- Clavijas: color de su tipo según el tablero de la partida (lo manda el servidor). Los huecos
-- (azules rotas) casi no se ven.
local function colorDe(id: number): Color3
	return Color3.fromHex(Clavijas.color(Clavijas.tipo(estado.Tablero, id)))
end
-- Material: todas brillan (Neon, Config.Mundo.MaterialClavija) sobre el fondo oscuro; con la luz
-- cian, el metal o el plástico se ven verdosos u oscuros.
local function materialDe(_id: number): Enum.Material
	return (Enum.Material :: any)[Config.Mundo.MaterialClavija] or Enum.Material.Neon
end
local function pintarClavijas()
	for id, p in escena.Clavijas do
		p.Color = colorDe(id)
		p.Material = materialDe(id)
		p.Transparency = if Clavijas.tipo(estado.Tablero, id) == "hueco" then 0.85 else 0
	end
end

-- Lo que salta sobre cada clavija tocada: "+2", "+2 Multi", "×2", "+6 +1 oro"…
local function textoToque(t: Simulacion.Toque): string
	local partes = {}
	if t.Fuerza > 0 then
		table.insert(partes, "+" .. Clavijas.numeroCorto(t.Fuerza))
	end
	if t.Multi > 0 then
		table.insert(partes, ("+%s Multi"):format(Clavijas.numeroCorto(t.Multi)))
	end
	if t.PorMulti > 1 then
		table.insert(partes, "×" .. Clavijas.numeroCorto(t.PorMulti))
	end
	if t.Oro > 0 then
		table.insert(partes, ("+%d oro"):format(t.Oro))
	end
	local texto = table.concat(partes, " ")
	if t.Veces > 1 then
		texto = ("eco ×%d: %s"):format(t.Veces, texto)
	end
	if t.Rota then
		texto ..= " ¡se rompió!"
	end
	return texto
end

local brillos: { [number]: number } = {}
local function brillar(id: number)
	local p = escena.Clavijas[id]
	if not p then
		return
	end
	local marca = (brillos[id] or 0) + 1
	brillos[id] = marca
	p.Color = colorBrillo
	p.Material = Enum.Material.Neon
	task.delay(Config.Simulacion.BrilloClavija, function()
		if brillos[id] == marca then
			p.Color = colorDe(id)
			p.Material = materialDe(id)
		end
	end)
end

local tiendaVista: TiendaVistaModulo.TiendaVista

-- Dibuja el estado que mandó el servidor (pelea nueva, tienda, volver a bajar, pergamino o
-- comando de prueba).
local function ponerEstado(e: Mazmorra.Estado)
	estado = e
	tirosPelea = 0
	monstruo.mostrar(e.Piso, e.VidaMonstruo)
	pantallas.ponerEstado(e)
	pantallas.ponerTablero(e)
	tiendaVista.ponerPergaminos(e)
	tiendaVista.ponerReliquias(e)
	pintarClavijas()
	panel.limpiar()
	if e.Fase == "tienda" then
		tiendaVista.mostrar(e)
	else
		tiendaVista.ocultar()
	end
	-- SONIDO: música de pelea o de jefe.
	Sonidos.musica(
		if e.Fase == "peleando" and Mazmorra.monstruo(e.Piso).EsJefe then "jefe" else "pelea"
	)
	if e.Fase == "peleando" then
		pantallas.ocultarFinal()
		pantallas.ocultarInicio()
	elseif e.Fase == "inicio" then
		abrirInicio()
	end
end

-- Pide al servidor una acción de la tienda o un pergamino y dibuja lo que devuelve. Si no se
-- pudo, muestra el motivo un momento.
local function pedir(remoto: RemoteFunction, ...: any): boolean
	local argumentos = table.pack(...)
	local ok, e, motivo = pcall(function()
		return remoto:InvokeServer(table.unpack(argumentos, 1, argumentos.n))
	end)
	if not ok or typeof(e) ~= "table" then
		warn("No se pudo hablar con el servidor")
		return false
	end
	ponerEstado(e)
	if typeof(motivo) == "string" then
		pantallas.anunciar(motivo)
		return false
	end
	return true
end

-- Tocar clavijas para un ítem o pergamino (si hace falta). nil = se canceló.
local function elegirClavijas(clase: string, id: string): ({ number }?, boolean)
	local cantidad = TiendaModulo.clavijasAElegir(clase, id)
	if cantidad == 0 then
		return nil, true
	end
	local nombre = TiendaModulo.describir(clase, id, estado)
	local _, tipo = TiendaModulo.partes(id)
	local noEste = if clase == "clavija" then id else tipo
	local texto = if cantidad == 1
		then ("%s: tocá 1 clavija"):format(nombre)
		else ("%s: tocá %d clavijas"):format(nombre, cantidad)
	local ids = seleccion.elegir(cantidad, texto, function(clavija: number): boolean
		local actual = Clavijas.tipo(estado.Tablero, clavija)
		return actual ~= "hueco" and actual ~= noEste
	end)
	return ids, ids ~= nil
end

tiendaVista = TiendaVistaModulo.crear({
	comprar = function(indice: number)
		local item = estado.Tienda.Items[indice]
		if seleccion.activa() or not item or item.Vendido then
			return
		end
		if estado.Oro < item.Precio then
			pantallas.anunciar("No te alcanza el oro")
			return
		end
		local ids, seguir = elegirClavijas(item.Clase, item.Id)
		if seguir and pedir(remotos.Tienda, "comprar", indice, ids) then
			print(("[Tienda] Compraste %s %s · oro %d"):format(item.Clase, item.Id, estado.Oro))
			Sonidos.tocar("Comprar") -- SONIDO
			for _, id in ids or {} do
				brillar(id)
			end
		end
	end,
	tomarCofre = function(indice: number)
		local id = estado.Tienda.Cofre[indice]
		if id and pedir(remotos.Tienda, "cofre", indice) then
			print(("[Tienda] Del cofre te llevaste %s"):format(id))
		end
	end,
	renovar = function()
		if not seleccion.activa() then
			pedir(remotos.Tienda, "renovar")
		end
	end,
	bajar = function()
		if not seleccion.activa() and pedir(remotos.Tienda, "bajar") then
			local m = Mazmorra.monstruo(estado.Piso)
			pantallas.anunciar(
				if m.EsJefe
					then ("¡Jefe: %s!"):format(m.Nombre)
					else ("¡Piso %d!"):format(estado.Piso)
			)
		end
	end,
	vender = function(lugar: number)
		local r = estado.Reliquias[lugar]
		if r and pedir(remotos.Tienda, "vender", lugar) then
			print(("[Tienda] Vendiste %s · oro %d"):format(r.Id, estado.Oro))
		end
	end,
	mover = function(desde: number, hacia: number)
		pedir(remotos.Tienda, "mover", desde, hacia)
	end,
	usar = function(lugar: number)
		local id = estado.Pergaminos[lugar]
		if tirando or seleccion.activa() or not id then
			return
		end
		local ids, seguir = elegirClavijas("pergamino", id)
		if seguir and pedir(remotos.UsarPergamino, lugar, ids) then
			print(("[Pergamino] Usaste %s"):format(id))
			for _, clavija in ids or {} do
				brillar(clavija)
			end
		end
	end,
})

local mostrarFinal: (Mazmorra.Estado) -> ()

-- Elegiste la bola: el servidor revisa que la tengas y arranca la partida.
local function volverABajar(bola: string)
	local inicio = os.clock()
	local ok, e = pcall(function()
		return remotos.VolverABajar:InvokeServer(bola)
	end)
	if ok and typeof(e) == "table" then
		if e.Fase == "peleando" and estado.Fase ~= "peleando" then
			mejorAntes = if progreso then progreso.MejorPiso else 0
			desbloqueosPartida = {}
		end
		ponerEstado(e)
		print(
			("[Mazmorra] Bajás con la bola %s: jugando en %d ms"):format(
				bola,
				(os.clock() - inicio) * 1000
			)
		)
		if estado.Fase ~= "peleando" then
			abrirInicio() -- no se aceptó: elegir de nuevo
		end
	else
		warn("No se pudo volver a bajar")
		abrirInicio()
	end
end

-- Pantalla de inicio: elegir bola (necesita el progreso; si todavía no llegó, espera).
abrirInicio = function()
	if progreso then
		pantallas.mostrarInicio(progreso, volverABajar)
	end
end

-- Pantalla de perder o ganar. "Volver a bajar" arranca con la misma bola; "Cambiar bola" abre el
-- inicio.
mostrarFinal = function(e: Mazmorra.Estado)
	if e.Fase ~= "perdio" and e.Fase ~= "gano" then
		return
	end
	local gano = e.Fase == "gano"
	local ganadas = if gano then #Config.Monstruos else e.Piso - 1
	pantallas.mostrarFinal({
		Gano = gano,
		Piso = e.Piso,
		MejorAntes = mejorAntes,
		MejorAhora = math.max(if progreso then progreso.MejorPiso else 0, ganadas),
		Desbloqueos = desbloqueosPartida,
	}, function()
		volverABajar(if progreso then progreso.BolaElegida else e.Bola)
	end, abrirInicio)
end

-- Bolita de luz del TOTAL al cartel del monstruo.
local function volarTotal()
	local luz = Instance.new("Part")
	luz.Name = "LuzTotal"
	luz.Shape = Enum.PartType.Ball
	luz.Size = Vector3.new(1.4, 1.4, 1.4)
	luz.Material = Enum.Material.Neon
	luz.Color = Color3.fromHex(Config.Colores.Numero)
	luz.Anchored = true
	luz.CanCollide = false
	luz.CanTouch = false
	luz.CanQuery = false
	luz.CastShadow = false
	luz.Position = escena.AnclaTotal.Position
	luz.Parent = escena.Cartel.Parent
	local tween = TweenService:Create(
		luz,
		TweenInfo.new(Config.Turno.VueloTotal, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = monstruo.centro() + Vector3.new(0, 0, 1) }
	)
	tween:Play()
	tween.Completed:Wait()
	luz:Destroy()
end

-- Anima lo que pasó en el turno (todo lo decidió el servidor).
local function animarTurno(turno: Mazmorra.Turno)
	local t = Config.Turno
	tirosPelea += 1
	volarTotal()
	Sonidos.tocar("Golpe") -- SONIDO
	monstruo.recibir()
	monstruo.ponerVida(turno.VidaMonstruo + turno.Quemadura, true)
	task.wait(t.Sacudida)
	if turno.Quemadura > 0 then
		-- La quemadura salta sobre el monstruo, naranja.
		Numeros.saltar(
			escena.Cartel,
			turno.Quemadura,
			("+%d fuego"):format(turno.Quemadura),
			colorQuemadura,
			Vector2.new(7, 2.4)
		)
		monstruo.ponerVida(turno.VidaMonstruo, true)
		task.wait(t.Sacudida)
	end

	if turno.Golpe > 0 then
		monstruo.atacar()
		Sonidos.tocar("Ataque") -- SONIDO
		task.wait(t.DuracionAtaque / 2)
		escena.sacudir(t.TemblorPantalla, t.DuracionTemblor)
		escena.golpearCaballero(true)
		pantallas.ponerVida(turno.VidaCaballero, estado.VidaMaxima)
		task.wait(t.DuracionAtaque / 2)
		escena.golpearCaballero(false)
	end

	local e = turno.Estado
	-- Azules rotas y oro nuevo (también si la pelea sigue).
	estado.Tablero = e.Tablero
	pintarClavijas()
	pantallas.ponerTablero(e)
	if turno.Resultado == "piso" then
		Sonidos.tocar("GanarPelea") -- SONIDO
		print(("[Mazmorra] Pelea %d ganada en %d tiros"):format(estado.Piso, tirosPelea))
		task.wait(0.3)
		ponerEstado(e) -- fase "tienda": se abre la tienda; "¡Piso N!" sale al bajar
	elseif turno.Resultado == "gano" then
		Sonidos.musica(nil)
		Sonidos.tocar("Victoria") -- SONIDO
		print(("[Mazmorra] Jefe ganado en %d tiros"):format(tirosPelea))
		estado = e
		mostrarFinal(e)
	elseif turno.Resultado == "perdio" then
		Sonidos.musica(nil)
		Sonidos.tocar("Perder") -- SONIDO
		print(("[Mazmorra] Caíste en el piso %d (tiro %d de la pelea)"):format(e.Piso, tirosPelea))
		estado = e
		mostrarFinal(e)
	else
		estado = e
	end
end

local function tirar()
	if
		tirando
		or estado.Fase ~= "peleando"
		or pantallas.hayFinal()
		or seleccion.activa()
		or tiendaVista.abierta()
	then
		return
	end
	tirando = true
	dibujarLinea()

	-- El servidor da el número de tiro y la semilla; el ángulo se fija acá.
	local ok, numeroTiro, semilla = pcall(function()
		return remotos.PedirTiro:InvokeServer()
	end)
	if not ok or typeof(numeroTiro) ~= "number" or typeof(semilla) ~= "number" then
		warn("No se pudo pedir el tiro al servidor")
		tirando = false
		dibujarLinea()
		return
	end
	local anguloTiro = angulo
	Sonidos.tocar("Tirar") -- SONIDO
	-- Tablero, niveles y bola salen del estado del servidor (el servidor repite el tiro igual).
	local mods = Mazmorra.modificadores(estado)
	local res = Simulacion.simular(tablero, anguloTiro, Config.Bola, mods, semilla)
	for _, bola in escena.Bolas do
		bola.Color = if res.Fuego then colorFuego else colorBola
		bola.Material = Enum.Material.Neon -- brilla sobre el fondo oscuro
		bola.Transparency = 1
	end
	panel.limpiar()

	local paso = Config.Simulacion.Paso
	local ultimo = res.Pasos
	local siguienteToque = 1
	local tiempo = 0
	local conexion: RBXScriptConnection
	conexion = RunService.RenderStepped:Connect(function(dt: number)
		tiempo += dt
		local i = math.min(tiempo / paso + 1, ultimo)
		-- Cada bola sigue su recorrido: aparece en su paso de inicio y se esconde al caer.
		for k, rec in res.Recorridos do
			local bola = escena.Bolas[k]
			if not bola then
				continue
			end
			local j = i - rec.Inicio + 1
			if j < 1 or j > #rec.X then
				bola.Transparency = 1
				continue
			end
			local j0 = math.floor(j)
			local j1 = math.min(j0 + 1, #rec.X)
			local f = j - j0
			local x = rec.X[j0] + (rec.X[j1] - rec.X[j0]) * f
			local y = rec.Y[j0] + (rec.Y[j1] - rec.Y[j0]) * f
			bola.Position = escena.aMundo(x, y, 0.6)
			bola.Transparency = 0
		end

		while siguienteToque <= #res.Toques and res.Toques[siguienteToque].Paso <= i do
			local toque = res.Toques[siguienteToque]
			brillar(toque.Clavija)
			-- SONIDO: "tink" que sube de tono con cada toque; aparte, ×Multi, oro y rotura.
			Sonidos.tocar("Toque", siguienteToque)
			if toque.PorMulti > 1 then
				Sonidos.tocar("Multi")
			end
			if toque.Oro > 0 then
				Sonidos.tocar("Oro")
			end
			if toque.Rota then
				Sonidos.tocar("Rotura")
			end
			local clavija = escena.Clavijas[toque.Clavija]
			if clavija then
				local color = if toque.Tipo == "gris"
					then nil
					else Color3.fromHex(Clavijas.color(toque.Tipo))
				local largo = if toque.Tipo == "gris" then 3 else 6
				Numeros.saltar(clavija, 0, textoToque(toque), color, Vector2.new(largo, 1.6))
				if toque.Rota then
					clavija.Transparency = 0.85
				end
			end
			local pop = if toque.PorMulti > 1
				then "por"
				elseif toque.Multi > 0 then "multi"
				else "fuerza"
			panel.poner(toque.FuerzaTotal, toque.MultiTotal, pop)
			siguienteToque += 1
		end

		if i >= ultimo then
			conexion:Disconnect()
			for _, bola in escena.Bolas do
				bola.Transparency = 1
			end
			-- El servidor revisa el daño, juega el turno y devuelve qué pasó.
			local okTiro, turno = pcall(function()
				return remotos.Tirar:InvokeServer(numeroTiro, anguloTiro, res.Danio)
			end)
			local danio = if okTiro and typeof(turno) == "table" then turno.Danio else nil
			-- Reliquias que actuaron al final del tiro, de izquierda a derecha.
			for _, a in res.Activaciones do
				tiendaVista.activar(a.Lugar, a.Texto)
				task.wait(0.22)
			end
			if #res.Activaciones > 0 then
				panel.poner(res.Fuerza, res.Multi, "por")
			end
			if res.Furia > 1 then
				panel.poner(res.Fuerza, res.Multi, "por") -- la furia multiplica al final
				pantallas.anunciar(("¡Furia ×%d!"):format(res.Furia))
			end
			panel.golpe(danio or res.Danio)
			print(
				("[Tiro %d] ángulo %.1f° · %d clavijas · %d bolas · Fuerza %s × Multi %s = %d (servidor: %s) · oro %d · rotas %d · %.1f s"):format(
					numeroTiro,
					anguloTiro,
					res.ClavijasDistintas,
					#res.Recorridos,
					Clavijas.numeroCorto(res.Fuerza),
					Clavijas.numeroCorto(res.Multi),
					res.Danio,
					tostring(danio),
					res.Oro,
					#res.Rotas,
					(ultimo - 1) * paso
				)
			)
			if danio then
				animarTurno(turno)
			else
				-- Tiro rechazado (por ejemplo, un comando de prueba lo anuló): volver al estado real.
				local okEstado, e = pcall(function()
					return remotos.ObtenerEstado:InvokeServer()
				end)
				if okEstado and typeof(e) == "table" then
					ponerEstado(e)
				end
			end
			tirando = false
			task.spawn(mostrarAvisos)
			dibujarLinea()
		end
	end)
end

-- Un clic que empieza con la pantalla final abierta (o justo al cerrarla) no apunta ni tira:
-- si no, tocar "Volver a bajar" también soltaba una bola.
UserInputService.InputBegan:Connect(function(input: InputObject, procesado: boolean)
	if
		procesado
		or pantallas.hayFinal()
		or seleccion.activa()
		or tiendaVista.abierta()
		or os.clock() - pantallas.finalCerrado() < 0.3
	then
		return
	end
	local tipo = input.UserInputType
	if tipo == Enum.UserInputType.MouseButton1 or tipo == Enum.UserInputType.Touch then
		apuntando = true
		apuntarA(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

UserInputService.InputChanged:Connect(function(input: InputObject)
	local tipo = input.UserInputType
	-- El mouse apunta siempre; el dedo, mientras está apoyado.
	if
		tipo == Enum.UserInputType.MouseMovement
		or (tipo == Enum.UserInputType.Touch and apuntando)
	then
		apuntarA(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	local tipo = input.UserInputType
	if
		(tipo == Enum.UserInputType.MouseButton1 or tipo == Enum.UserInputType.Touch) and apuntando
	then
		apuntando = false
		if pantallas.hayFinal() or os.clock() - pantallas.finalCerrado() < 0.3 then
			return
		end
		apuntarA(Vector2.new(input.Position.X, input.Position.Y))
		tirar()
	end
end)

-- Comando de prueba, solo en Studio: teclas 1 a 7 saltan a esa pelea, 0 pone 999 de vida,
-- Z cambia de bola, X convierte 2 grises (cada vez un tipo distinto), C sube de nivel todos los
-- tipos de clavija, 8 da 20 de oro, 9 agrega un pergamino y R una reliquia (cada vez una distinta).
-- L hace como si salieras y volvieras a entrar (prueba del guardado).
local prueba = if RunService:IsStudio() then carpetaRemotos:WaitForChild("Prueba", 3) else nil
if RunService:IsStudio() and prueba and prueba:IsA("RemoteEvent") then
	local tipoPrueba = 0
	local pergaminoPrueba = 0
	local reliquiaPrueba = 0
	local teclas = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
		[Enum.KeyCode.Seven] = 7,
	}
	UserInputService.InputBegan:Connect(function(input: InputObject, procesado: boolean)
		if procesado then
			return
		end
		local piso = teclas[input.KeyCode]
		if piso then
			prueba:FireServer("piso", piso)
		elseif input.KeyCode == Enum.KeyCode.Zero then
			prueba:FireServer("vida", 999)
		elseif input.KeyCode == Enum.KeyCode.Z then
			local actual = table.find(Config.OrdenBolas, estado.Bola) or 1
			prueba:FireServer("bola", actual % #Config.OrdenBolas + 1)
		elseif input.KeyCode == Enum.KeyCode.X then
			tipoPrueba = tipoPrueba % #Config.OrdenClavijas + 1
			prueba:FireServer("clavija", tipoPrueba)
		elseif input.KeyCode == Enum.KeyCode.C then
			prueba:FireServer("nivel", 1)
		elseif input.KeyCode == Enum.KeyCode.Eight then
			prueba:FireServer("oro", 20)
		elseif input.KeyCode == Enum.KeyCode.Nine then
			pergaminoPrueba += 1
			prueba:FireServer("pergamino", pergaminoPrueba)
		elseif input.KeyCode == Enum.KeyCode.L then
			prueba:FireServer("recargar", 0)
		elseif input.KeyCode == Enum.KeyCode.R then
			reliquiaPrueba += 1
			prueba:FireServer("reliquia", reliquiaPrueba)
		end
	end)
end

remotos.EstadoCambio.OnClientEvent:Connect(function(e: Mazmorra.Estado)
	if typeof(e) == "table" then
		ponerEstado(e)
	end
end)

-- Avisos de desbloqueo, uno por uno. Si llegan con la bola en juego, esperan a que termine el
-- turno (si no, el aviso anticipaba que ibas a ganar la pelea).
local avisosPendientes: { any } = {}
local mostrandoAvisos = false
mostrarAvisos = function()
	if mostrandoAvisos then
		return
	end
	mostrandoAvisos = true
	while #avisosPendientes > 0 do
		local n = table.remove(avisosPendientes, 1)
		Sonidos.tocar("Desbloqueo") -- SONIDO
		pantallas.anunciar(
			if n.Tipo == "bola"
				then ("¡Nueva bola: %s!"):format(n.Nombre)
				else ("¡Nueva reliquia: %s!"):format(n.Nombre)
		)
		task.wait(Config.Turno.CartelPiso + 0.4)
	end
	mostrandoAvisos = false
end

-- Progreso guardado: llega al cargar y cada vez que cambia (mejor piso, desbloqueos). Lo nuevo
-- sale en un aviso grande, uno por uno.
remotos.Progreso.OnClientEvent:Connect(function(datos: any, nuevos: any)
	if typeof(datos) ~= "table" then
		return
	end
	progreso = datos
	Ajustes.cargar(datos.Ajustes)
	if estado.Fase == "inicio" then
		abrirInicio() -- se dibuja con el progreso nuevo (mejor piso, bolas, la elegida)
	end
	if typeof(nuevos) == "table" then
		for _, n in nuevos do
			print(("[Progreso] Desbloqueaste %s: %s"):format(n.Tipo, n.Nombre))
			table.insert(
				desbloqueosPartida,
				if n.Tipo == "bola" then ("bola %s"):format(n.Nombre) else n.Nombre
			)
			table.insert(avisosPendientes, n)
		end
		if not tirando then
			task.spawn(mostrarAvisos)
		end
	end
end)

-- El estado de la partida: mientras el servidor carga el progreso devuelve nil (se reintenta).
task.spawn(function()
	for _ = 1, 60 do
		local ok, inicial = pcall(function()
			return remotos.ObtenerEstado:InvokeServer()
		end)
		if ok and typeof(inicial) == "table" then
			if not progreso then
				local okP, datos = pcall(function()
					return remotos.ObtenerProgreso:InvokeServer()
				end)
				if okP and typeof(datos) == "table" then
					progreso = datos
					Ajustes.cargar(datos.Ajustes)
				end
			end
			ponerEstado(inicial)
			return
		end
		task.wait(0.5)
	end
	warn("No llegó el estado de la partida")
end)

dibujarLinea()
print("Plinko Knight: tablero listo")
