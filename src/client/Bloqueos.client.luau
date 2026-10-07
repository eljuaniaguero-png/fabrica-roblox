--!strict
-- Zonas bloqueadas (solo visual, cada jugador ve las suyas según su nivel). Mientras no tenés el
-- nivel de una puerta, una pared de niebla opaca detrás de ella tapa la zona siguiente y encima
-- de la puerta hay un candado grande con el nivel que pide. Al llegar al nivel, el candado se abre
-- con una animación, la niebla se disuelve y se revela la zona. Si te toca lejos de la puerta, la
-- animación espera a que te acerques. Quién pasa lo siguen decidiendo las puertas (Puertas.luau).
--
-- En el mapa (Models con ModelStreamingMode = Persistent, así siempre están cargados):
--   Model con atributo BloqueoPuerta = índice de la puerta >
--     Niebla (BasePart opaca), Bruma (BasePart invisible con ParticleEmitter),
--     Candado (Model) > Cuerpo (BasePart con SurfaceGui "Cartel" > Marco > Nivel), Arco (Model)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Niveles = require(ReplicatedStorage.Shared.Niveles)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local ajustes = Config.Bloqueos

type Bloqueo = {
	modelo: Model,
	minimo: number,
	abierto: boolean, -- ya se ve abierto (sin niebla ni candado)
	pendiente: boolean, -- tenés el nivel pero todavía no viste la animación
}

local bloqueos: { [Model]: Bloqueo } = {}

local function miNivel(): number
	local pasos = jugador:GetAttribute("PasosTotales")
	return Niveles.nivelDe(if typeof(pasos) == "number" then pasos else 0)
end

local function ocultarAlInstante(bloqueo: Bloqueo)
	for _, objeto in bloqueo.modelo:GetDescendants() do
		if objeto:IsA("BasePart") then
			objeto.Transparency = 1
		elseif objeto:IsA("ParticleEmitter") or objeto:IsA("SurfaceGui") then
			(objeto :: any).Enabled = false
		end
	end
	bloqueo.abierto = true
	bloqueo.pendiente = false
end

local function tween(objeto: Instance, duracion: number, propiedades: { [string]: any }): Tween
	local animacion = TweenService:Create(
		objeto,
		TweenInfo.new(duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		propiedades
	)
	animacion:Play()
	return animacion
end

-- El arco salta, gira sobre su pata y después todo el candado se desvanece.
local function abrirCandado(candado: Model)
	local arco = candado:FindFirstChild("Arco")
	if arco and arco:IsA("Model") then
		local inicio = arco:GetPivot()
		local valor = Instance.new("CFrameValue")
		valor.Value = inicio
		valor.Changed:Connect(function(cframe)
			arco:PivotTo(cframe)
		end)
		local arriba = inicio * CFrame.new(0, ajustes.AlturaArco, 0)
		tween(valor, ajustes.SubidaArco, { Value = arriba }).Completed:Wait()
		local girado = arriba * CFrame.Angles(0, math.rad(ajustes.AnguloArco), 0)
		tween(valor, ajustes.GiroArco, { Value = girado }).Completed:Wait()
		valor:Destroy()
	end
	for _, objeto in candado:GetDescendants() do
		if objeto:IsA("BasePart") or objeto:IsA("UIStroke") then
			tween(objeto, ajustes.DesvanecerCandado, { Transparency = 1 })
		elseif objeto:IsA("TextLabel") then
			tween(objeto, ajustes.DesvanecerCandado, { TextTransparency = 1 })
		end
	end
end

local function abrir(bloqueo: Bloqueo)
	bloqueo.pendiente = false
	bloqueo.abierto = true
	-- SONIDO: se abre un candado y se revela la zona (Config.Efectos.Desbloquear)
	Sonidos.efecto("Desbloquear")
	local modelo = bloqueo.modelo
	for _, objeto in modelo:GetDescendants() do
		if objeto:IsA("ParticleEmitter") then
			objeto.Enabled = false -- la bruma que ya está en el aire se va sola
		end
	end
	local candado = modelo:FindFirstChild("Candado")
	if candado and candado:IsA("Model") then
		task.spawn(abrirCandado, candado)
	end
	local niebla = modelo:FindFirstChild("Niebla")
	if niebla and niebla:IsA("BasePart") then
		task.delay(ajustes.SubidaArco + ajustes.GiroArco, function()
			tween(niebla, ajustes.DuracionNiebla, { Transparency = 1 })
		end)
	end
end

local function registrar(objeto: Instance)
	local indice = objeto:GetAttribute("BloqueoPuerta")
	if not objeto:IsA("Model") or typeof(indice) ~= "number" or bloqueos[objeto] then
		return
	end
	local minimo = Config.NivelPuertas[indice]
	if not minimo then
		return
	end
	local bloqueo: Bloqueo =
		{ modelo = objeto, minimo = minimo, abierto = false, pendiente = false }
	bloqueos[objeto] = bloqueo

	-- El número del candado sale de Config, así siempre coincide con la puerta.
	local nivel = objeto:FindFirstChild("Nivel", true)
	if nivel and nivel:IsA("TextLabel") then
		nivel.Text = tostring(minimo)
	end
	if miNivel() >= minimo then
		ocultarAlInstante(bloqueo)
	end
end

-- Esperar a que el servidor publique tus pasos, así una zona que ya tenías abierta aparece
-- abierta de entrada (sin animación).
if jugador:GetAttribute("PasosTotales") == nil then
	jugador:GetAttributeChangedSignal("PasosTotales"):Wait()
end

for _, objeto in workspace:GetDescendants() do
	registrar(objeto)
end
workspace.DescendantAdded:Connect(registrar)

jugador:GetAttributeChangedSignal("PasosTotales"):Connect(function()
	local nivel = miNivel()
	for _, bloqueo in bloqueos do
		if not bloqueo.abierto and not bloqueo.pendiente and nivel >= bloqueo.minimo then
			bloqueo.pendiente = true
		end
	end
end)

-- Las que se abrieron se animan cuando estás cerca (si estás lejos, esperan).
local espera = 0
RunService.Heartbeat:Connect(function(dt)
	espera += dt
	if espera < 0.25 then
		return
	end
	espera = 0
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not raiz or not raiz:IsA("BasePart") then
		return
	end
	for _, bloqueo in bloqueos do
		if bloqueo.pendiente then
			local candado = bloqueo.modelo:FindFirstChild("Candado")
			local centro = if candado and candado:IsA("Model")
				then candado:GetPivot().Position
				else bloqueo.modelo:GetPivot().Position
			if (raiz.Position - centro).Magnitude <= ajustes.DistanciaAnimacion then
				abrir(bloqueo)
			end
		end
	end
end)
