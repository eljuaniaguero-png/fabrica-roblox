--!strict
-- Cliente de Plinko Knight (etapas 2 a 4): arma el tablero, apunta con mouse o dedo y, al
-- soltar, pide el tiro al servidor (número y semilla) y tira la bola. La bola sigue el
-- recorrido de shared/Simulacion (interpolado, así se ve suave a cualquier FPS); cada clavija
-- tocada brilla, salta su "+2" y sube el TOTAL. Al terminar, el servidor revisa el daño, juega
-- el turno y devuelve qué pasó; el cliente solo lo anima (golpe al monstruo, contraataque,
-- piso nuevo, perder o ganar la mazmorra).
-- Input con UserInputService: los otros juegos no usan el Input Action System.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Simulacion = require(Shared:WaitForChild("Simulacion"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Escena = require(script.Parent:WaitForChild("Escena"))
local MonstruoVista = require(script.Parent:WaitForChild("Monstruo"))
local Numeros = require(script.Parent:WaitForChild("Numeros"))
local PantallasModulo = require(script.Parent:WaitForChild("Pantallas"))

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
	EstadoCambio = carpetaRemotos:WaitForChild("EstadoCambio") :: RemoteEvent,
}

local escena = Escena.armar()
local total = Numeros.crearTotal(escena.AnclaTotal)
local tablero = escena.Tablero
local colorClavija = Color3.fromHex(Config.Colores.Clavija)
local colorBrillo = Color3.fromHex(Config.Colores.Brillo)
local monstruo = MonstruoVista.crear(escena.Cartel, escena.BarraMonstruo)
local pantallas = PantallasModulo.crear()

local estado: Mazmorra.Estado = Mazmorra.nueva() -- se pisa con el del servidor al arrancar
local tirosPelea = 0 -- para la consola: cuántos tiros lleva la pelea actual

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
			p.Color = colorClavija
			p.Material = Enum.Material.SmoothPlastic
		end
	end)
end

-- Dibuja el estado que mandó el servidor (pelea nueva, volver a bajar o comando de prueba).
local function ponerEstado(e: Mazmorra.Estado)
	estado = e
	tirosPelea = 0
	monstruo.mostrar(e.Piso, e.VidaMonstruo)
	pantallas.ponerEstado(e)
	total.poner(0, false)
	if e.Fase == "peleando" then
		pantallas.ocultarFinal()
	end
end

local mostrarFinal: (Mazmorra.Estado) -> ()

local function volverABajar()
	local inicio = os.clock()
	local ok, e = pcall(function()
		return remotos.VolverABajar:InvokeServer()
	end)
	if ok and typeof(e) == "table" then
		ponerEstado(e)
		print(("[Mazmorra] Volver a bajar: jugando en %d ms"):format((os.clock() - inicio) * 1000))
		if estado.Fase ~= "peleando" then
			mostrarFinal(estado)
		end
	else
		warn("No se pudo volver a bajar")
		mostrarFinal(estado)
	end
end

mostrarFinal = function(e: Mazmorra.Estado)
	if e.Fase == "perdio" then
		pantallas.mostrarFinal(
			("Caíste en el piso %d"):format(e.Piso),
			"Volver a bajar",
			volverABajar
		)
	elseif e.Fase == "gano" then
		pantallas.mostrarFinal("¡Ganaste la mazmorra!", "Volver", volverABajar)
	end
end

local colorCaballero = Color3.fromHex(Config.Colores.Caballero)
local colorGolpe = Color3.fromHex(Config.Colores.Golpe)

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
	monstruo.recibir()
	monstruo.ponerVida(turno.VidaMonstruo, true)
	task.wait(t.Sacudida)

	if turno.Golpe > 0 then
		monstruo.atacar()
		task.wait(t.DuracionAtaque / 2)
		escena.sacudir(t.TemblorPantalla, t.DuracionTemblor)
		escena.Caballero.Color = colorGolpe
		pantallas.ponerVida(turno.VidaCaballero, estado.VidaMaxima)
		task.wait(t.DuracionAtaque / 2)
		escena.Caballero.Color = colorCaballero
	end

	local e = turno.Estado
	if turno.Resultado == "piso" then
		print(("[Mazmorra] Pelea %d ganada en %d tiros"):format(estado.Piso, tirosPelea))
		task.wait(0.3)
		pantallas.anunciar(("¡Piso %d!"):format(e.Piso))
		ponerEstado(e)
	elseif turno.Resultado == "gano" then
		print(("[Mazmorra] Jefe ganado en %d tiros"):format(tirosPelea))
		estado = e
		mostrarFinal(e)
	elseif turno.Resultado == "perdio" then
		print(("[Mazmorra] Caíste en el piso %d (tiro %d de la pelea)"):format(e.Piso, tirosPelea))
		estado = e
		mostrarFinal(e)
	else
		estado = e
	end
end

local function tirar()
	if tirando or estado.Fase ~= "peleando" or pantallas.hayFinal() then
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
	local res = Simulacion.simular(tablero, anguloTiro, Config.Bola, {}, semilla)
	local bola = escena.Bola
	bola.Transparency = 0
	total.poner(0, false)

	local paso = Config.Simulacion.Paso
	local ultimo = #res.X
	local siguienteToque = 1
	local tiempo = 0
	local conexion: RBXScriptConnection
	conexion = RunService.RenderStepped:Connect(function(dt: number)
		tiempo += dt
		local i = math.min(tiempo / paso + 1, ultimo)
		local i0 = math.floor(i)
		local i1 = math.min(i0 + 1, ultimo)
		local f = i - i0
		local x = res.X[i0] + (res.X[i1] - res.X[i0]) * f
		local y = res.Y[i0] + (res.Y[i1] - res.Y[i0]) * f
		bola.Position = escena.aMundo(x, y, 0.6)

		while siguienteToque <= #res.Toques and res.Toques[siguienteToque].Paso <= i do
			local toque = res.Toques[siguienteToque]
			brillar(toque.Clavija)
			local clavija = escena.Clavijas[toque.Clavija]
			if clavija then
				Numeros.saltar(clavija, toque.Danio)
			end
			total.poner(toque.Total, true)
			siguienteToque += 1
		end

		if i >= ultimo then
			conexion:Disconnect()
			bola.Transparency = 1
			-- El servidor revisa el daño, juega el turno y devuelve qué pasó.
			local okTiro, turno = pcall(function()
				return remotos.Tirar:InvokeServer(numeroTiro, anguloTiro, res.Danio)
			end)
			local danio = if okTiro and typeof(turno) == "table" then turno.Danio else nil
			if danio and danio ~= res.Danio then
				total.poner(danio, true)
			end
			print(
				("[Tiro %d] ángulo %.1f° · %d clavijas · daño %d (servidor: %s) · %.1f s"):format(
					numeroTiro,
					anguloTiro,
					res.ClavijasDistintas,
					res.Danio,
					tostring(danio),
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
			dibujarLinea()
		end
	end)
end

-- Un clic que empieza con la pantalla final abierta (o justo al cerrarla) no apunta ni tira:
-- si no, tocar "Volver a bajar" también soltaba una bola.
UserInputService.InputBegan:Connect(function(input: InputObject, procesado: boolean)
	if procesado or pantallas.hayFinal() or os.clock() - pantallas.finalCerrado() < 0.3 then
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

-- Comando de prueba, solo en Studio: teclas 1 a 7 saltan a esa pelea y 0 pone 999 de vida.
local prueba = if RunService:IsStudio() then carpetaRemotos:WaitForChild("Prueba", 3) else nil
if RunService:IsStudio() and prueba and prueba:IsA("RemoteEvent") then
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
		end
	end)
end

remotos.EstadoCambio.OnClientEvent:Connect(function(e: Mazmorra.Estado)
	if typeof(e) == "table" then
		ponerEstado(e)
	end
end)

local okInicio, inicial = pcall(function()
	return remotos.ObtenerEstado:InvokeServer()
end)
if okInicio and typeof(inicial) == "table" then
	ponerEstado(inicial)
else
	ponerEstado(estado)
end

dibujarLinea()
print("Plinko Knight: tablero listo")
