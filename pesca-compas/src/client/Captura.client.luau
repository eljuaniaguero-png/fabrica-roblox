--!strict
-- "Mostrar la captura": cuando el servidor confirma que sacaste el pez, el modelo 3D salta desde
-- la boya, gira en el aire y queda arriba de la cabeza del personaje, de perfil a la cámara,
-- mientras está la tarjeta de kg (Pesca.client). Es la imagen que la gente captura y comparte.
-- Es solo visual y local: no decide nada. El pez y el peso vienen del Resultado del servidor.
-- Afinado = contorno dorado + destellos (ModeloPez). Todo lo temporal va a una Limpieza, que se
-- suelta si llega otro pez, si el personaje muere o al terminar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Limpieza = require(Shared:WaitForChild("Limpieza"))
local ModeloPez = require(Shared:WaitForChild("ModeloPez"))
local Estilo = require(Shared:WaitForChild("Estilo"))
local Remotos = ReplicatedStorage:WaitForChild("Remotos")
local AnimPesca = require(script.Parent:WaitForChild("AnimPesca"))

local jugador = Players.LocalPlayer

local SALTO = 0.55 -- segundos del salto boya -> cabeza (= marcador "Agarrar" de Levantar, ver shared/Animaciones)
local MOSTRAR = 2.6 -- igual que la tarjeta de Pesca.client (revelar)
local SALIDA = 0.2
local ALTO_SALTO = 7 -- studs que sube el arco por encima de la recta
local SOBRE_CABEZA = 1.8 -- centro del pez sobre la cabeza: las manos de Levantar quedan a ~1.1 (medido en R15)
local LARGO_BASE = 2.6 -- studs del pez en la mano; el peso lo mueve entre 85% y 120%

local carpeta = Instance.new("Folder")
carpeta.Name = "CapturaLocal"
carpeta.Parent = Workspace

local limpieza = Limpieza.nueva()
local posBoya: Vector3? = nil
local boya: BasePart? = nil

local function pezPorId(id: string): Config.Pez?
	for _, p in Config.Peces do
		if p.Id == id then
			return p
		end
	end
	return nil
end

-- más pesado dentro de su rango = más grande en la mano (el kg se tiene que "ver")
local function largoPara(id: string, peso: number): number
	local pez = pezPorId(id)
	if not pez or pez.PesoMax <= pez.PesoMin then
		return LARGO_BASE
	end
	local t = math.clamp((peso - pez.PesoMin) / (pez.PesoMax - pez.PesoMin), 0, 1)
	return LARGO_BASE * (0.85 + 0.35 * t)
end

local function golpeDeCamara()
	local camara = Workspace.CurrentCamera
	if not camara then
		return
	end
	local fov = camara.FieldOfView
	-- devolver el FOV pase lo que pase: si se corta a mitad, que no quede con zoom
	limpieza:dar(function()
		camara.FieldOfView = fov
	end)
	local acercar = TweenService:Create(camara, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fov - 8,
	})
	local volver = TweenService:Create(camara, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		FieldOfView = fov,
	})
	limpieza:dar(acercar)
	limpieza:dar(volver)
	limpieza:dar(acercar.Completed:Once(function()
		volver:Play()
	end))
	acercar:Play()
end

-- gotas que saltan del pez cuando llega a las manos (marcador "VFX")
local function salpicar(donde: Vector3)
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = donde
	ancla.Parent = Workspace.Terrain
	local gotas = Instance.new("ParticleEmitter")
	gotas.Color = ColorSequence.new(Estilo.Mundo.Ventana, Estilo.Mundo.Agua)
	gotas.LightEmission = 0.3
	gotas.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
	gotas.Lifetime = NumberRange.new(0.35, 0.6)
	gotas.Speed = NumberRange.new(8, 14)
	gotas.SpreadAngle = Vector2.new(70, 70)
	gotas.Acceleration = Vector3.new(0, -40, 0)
	gotas.EmissionDirection = Enum.NormalId.Top
	gotas.Rate = 0
	gotas.Parent = ancla
	gotas:Emit(18)
	limpieza:dar(ancla)
end

local function mostrar(datos: any)
	limpieza:limpiar()
	local personaje = jugador.Character
	local cabeza = personaje and personaje:FindFirstChild("Head") :: BasePart?
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not cabeza or not raiz or not humanoide or typeof(datos.Id) ~= "string" then
		return
	end
	local cab: BasePart, rz: BasePart = cabeza, raiz -- ya sin nil: los usa el RenderStepped

	local modelo = ModeloPez.crear(datos.Id, {
		Largo = largoPara(datos.Id, tonumber(datos.Peso) or 0),
		Afinado = datos.Afinado == true,
	})
	local escala = modelo:GetScale()
	local origen = posBoya or (raiz.Position + raiz.CFrame.LookVector * 10)
	origen = Vector3.new(origen.X, -0.5, origen.Z) -- sale de abajo del agua (superficie en y = 0)
	modelo:PivotTo(CFrame.new(origen))
	modelo.Parent = carpeta
	limpieza:dar(modelo)
	limpieza:dar(humanoide.Died:Connect(function()
		limpieza:limpiar()
	end))
	posBoya = nil

	-- el personaje levanta los brazos; el golpe de cámara y las gotas salen de los marcadores
	-- "Agarrar"/"VFX" de la animación, no de un reloj propio
	local pararAnim, conAnim = AnimPesca.levantar(golpeDeCamara, function()
		salpicar(cab.Position + Vector3.new(0, SOBRE_CABEZA, 0))
	end)
	limpieza:dar(pararAnim)

	local inicio = os.clock()
	local aterrizo = conAnim -- sin animación (R6, enfriamiento) el golpe va por tiempo, como antes
	limpieza:dar(RunService.RenderStepped:Connect(function()
		if not cab.Parent then
			limpieza:limpiar()
			return
		end
		local t = os.clock() - inicio
		local camara = Workspace.CurrentCamera
		local derecha = if camara then camara.CFrame.RightVector else rz.CFrame.RightVector
		derecha = Vector3.new(derecha.X, 0, derecha.Z)
		if derecha.Magnitude < 1e-3 then
			derecha = Vector3.xAxis
		end
		derecha = derecha.Unit
		local destino = cab.Position +Vector3.new(0, SOBRE_CABEZA, 0)

		local pos: Vector3
		local giro: CFrame
		local factor = 1
		if t < SALTO then
			-- arco: recta boya -> cabeza más una parábola; 2 vueltas en el aire, frenando al final
			local a = t / SALTO
			local suave = 1 - (1 - a) ^ 3 -- Cubic Out
			pos = origen:Lerp(destino, suave) + Vector3.new(0, ALTO_SALTO * math.sin(math.pi * a), 0)
			giro = CFrame.Angles(0, (1 - suave) * math.pi * 4, 0)
		else
			if not aterrizo then
				aterrizo = true
				golpeDeCamara()
			end
			local h = t - SALTO
			pos = destino + Vector3.new(0, math.sin(h * 3) * 0.25, 0)
			giro = CFrame.Angles(0, math.sin(h * 9) * 0.18, math.sin(h * 4.5) * 0.08) -- coletea
			-- squash & stretch al llegar: rebota y se asienta en 0.35 s
			factor = 1 + 0.25 * math.exp(-h * 9) * math.cos(h * 28)
			if h > MOSTRAR - SALTO then
				factor *= math.max(0.01, 1 - (h - (MOSTRAR - SALTO)) / SALIDA)
			end
		end
		-- de perfil a la cámara: la cabeza apunta a la derecha de la pantalla
		modelo:PivotTo(CFrame.lookAt(pos, pos + derecha) * giro)
		modelo:ScaleTo(escala * factor)
		if t > MOSTRAR + SALIDA then
			limpieza:limpiar()
		end
	end))
end

Remotos:WaitForChild("Pesca").OnClientEvent:Connect(function(tipo: string, datos: any)
	if tipo == "Lanzado" then
		local b = datos and datos.Boya
		boya = if typeof(b) == "Instance" and b:IsA("BasePart") then b else nil
	elseif tipo == "Pico" then
		-- el servidor borra la boya antes de mandar el Resultado: guardar dónde estaba
		posBoya = if boya and boya.Parent then boya.Position else nil
		boya = nil
	elseif tipo == "Resultado" then
		if datos and datos.Sacado then
			mostrar(datos)
		end
		posBoya = nil
	elseif tipo == "Cancelado" then
		boya = nil
		posBoya = nil
	end
end)

jugador.CharacterRemoving:Connect(function()
	limpieza:limpiar()
end)
