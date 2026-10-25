--!strict
-- Cliente de Plinko Knight (etapa 2): arma el tablero, apunta con mouse o dedo y, al soltar,
-- tira la bola. La bola sigue el recorrido de shared/Simulacion (interpolado, así se ve suave a
-- cualquier FPS) y cada clavija tocada brilla un momento. Todavía sin daño ni monstruos.
-- Input con UserInputService: los otros juegos no usan el Input Action System.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Simulacion = require(Shared:WaitForChild("Simulacion"))
local Escena = require(script.Parent:WaitForChild("Escena"))

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

local escena = Escena.armar()
local tablero = escena.Tablero
local colorClavija = Color3.fromHex(Config.Colores.Clavija)
local colorBrillo = Color3.fromHex(Config.Colores.Brillo)

local angulo = 0
local apuntando = false -- dedo apoyado o botón del mouse apretado
local tirando = false -- hay una bola en juego: no se puede tirar otra
local tiros = 0

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

local function tirar()
	if tirando then
		return
	end
	tirando = true
	tiros += 1
	dibujarLinea()
	-- Etapa 3: la semilla la va a dar el servidor. Por ahora, una del reloj (sin math.random).
	local semilla = math.floor(os.clock() * 1000) + tiros
	local res = Simulacion.simular(tablero, angulo, Config.Bola, {}, semilla)
	local bola = escena.Bola
	bola.Transparency = 0

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
			brillar(res.Toques[siguienteToque].Clavija)
			siguienteToque += 1
		end

		if i >= ultimo then
			conexion:Disconnect()
			bola.Transparency = 1
			print(
				("[Tiro %d] ángulo %.1f° · %d clavijas distintas · %d toques · %.1f s · %s"):format(
					tiros,
					angulo,
					res.ClavijasDistintas,
					#res.Toques,
					(ultimo - 1) * paso,
					res.Fin
				)
			)
			tirando = false
			dibujarLinea()
		end
	end)
end

UserInputService.InputBegan:Connect(function(input: InputObject, procesado: boolean)
	if procesado then
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
		tipo == Enum.UserInputType.MouseMovement or (tipo == Enum.UserInputType.Touch and apuntando)
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
		apuntarA(Vector2.new(input.Position.X, input.Position.Y))
		tirar()
	end
end)

dibujarLinea()
print("Plinko Knight: tablero listo")
