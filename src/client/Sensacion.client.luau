--!strict
-- Sensación de velocidad: cuanto más rápido corrés, más se nota.
--   * Estela y chispas por tramos de rapidez, cada tramo de otro color (en todos los personajes).
--   * Animación de correr más rápida, encima de lo que ya hace el script Animate de Roblox (la tuya).
--   * Cámara un poco más abierta (la tuya).
-- Es solo visual: la velocidad real la controla el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local jugador = Players.LocalPlayer
local ajustes = Config.Sensacion
local CHISPA = "rbxasset://textures/particles/sparkles_main.dds"

type Efectos = {
	raiz: BasePart,
	estela: Trail,
	chispas: ParticleEmitter,
	tramo: number,
	rapidez: number, -- suavizada
}

local efectos: { [Model]: Efectos } = {}

-- 0 parado o lento, 1 a rapidez máxima.
local function fraccion(rapidez: number): number
	local rango = ajustes.RapidezMaxima - ajustes.RapidezSinEfecto
	return math.clamp((rapidez - ajustes.RapidezSinEfecto) / rango, 0, 1)
end

local function crearEfectos(personaje: Model): Efectos?
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if not raiz or not raiz:IsA("BasePart") then
		return nil
	end
	local function punto(nombre: string, posicion: Vector3): Attachment
		local ancla = Instance.new("Attachment")
		ancla.Name = nombre
		ancla.Position = posicion
		ancla.Parent = raiz
		return ancla
	end

	local estela = Instance.new("Trail")
	estela.Name = "EstelaVelocidad"
	estela.Attachment0 = punto("EstelaArriba", Vector3.new(0, 0.9, 0.5))
	estela.Attachment1 = punto("EstelaAbajo", Vector3.new(0, -0.9, 0.5))
	estela.Lifetime = ajustes.DuracionEstela
	estela.FaceCamera = true -- si no, desde atrás se ve de canto, como una línea
	estela.LightEmission = 1
	estela.LightInfluence = 0
	estela.Transparency = NumberSequence.new(0.3, 1)
	estela.WidthScale = NumberSequence.new(1, 0.3)
	estela.Enabled = false
	estela.Parent = raiz

	local chispas = Instance.new("ParticleEmitter")
	chispas.Name = "ChispasVelocidad"
	chispas.Texture = CHISPA
	chispas.Rate = 0
	chispas.LightEmission = 1
	chispas.Lifetime = NumberRange.new(0.3, 0.6)
	chispas.Speed = NumberRange.new(2, 5)
	chispas.SpreadAngle = Vector2.new(40, 40)
	chispas.Acceleration = Vector3.new(0, 4, 0)
	chispas.Drag = 2
	chispas.Parent = punto("ChispasPies", Vector3.new(0, -2.6, 0.5))

	return { raiz = raiz, estela = estela, chispas = chispas, tramo = 0, rapidez = 0 }
end

-- Tramo que corresponde a la rapidez. Para bajar de tramo pide un margen (Histeresis).
local function tramoDe(rapidez: number, actual: number): number
	local tramo = 0
	for indice, datos in ajustes.Tramos do
		if rapidez >= datos.Desde then
			tramo = indice
		end
	end
	local datosActual = ajustes.Tramos[actual]
	if tramo < actual and datosActual and rapidez >= datosActual.Desde - ajustes.Histeresis then
		return actual
	end
	return tramo
end

local function aplicarTramo(e: Efectos, tramo: number)
	if tramo == e.tramo then
		return
	end
	e.tramo = tramo
	local datos = ajustes.Tramos[tramo]
	if not datos then
		e.estela.Enabled = false
		e.chispas.Rate = 0
		return
	end
	if not e.estela.Enabled then
		e.estela:Clear() -- que no dibuje un tramo viejo al volver a prenderse
	end
	e.estela.Color = ColorSequence.new(datos.Color)
	e.estela.Enabled = true
	e.chispas.Color = ColorSequence.new(datos.Color)
	e.chispas.Size = NumberSequence.new(datos.TamanoParticula, 0)
	e.chispas.Rate = datos.Particulas
end

RunService.Heartbeat:Connect(function(dt)
	-- Con streaming, los personajes de otros llegan y se van: se arman los efectos cuando aparecen.
	for _, otro in Players:GetPlayers() do
		local personaje = otro.Character
		if personaje then
			local e = efectos[personaje]
			if not e or e.raiz.Parent ~= personaje then
				efectos[personaje] = crearEfectos(personaje)
			end
		end
	end

	local suavizado = math.min(dt * ajustes.SuavizadoRapidez, 1)
	for personaje, e in efectos do
		if not personaje.Parent then
			efectos[personaje] = nil
			continue
		end
		local v = e.raiz.AssemblyLinearVelocity
		local rapidez = Vector3.new(v.X, 0, v.Z).Magnitude
		e.rapidez += (rapidez - e.rapidez) * suavizado
		aplicarTramo(e, tramoDe(e.rapidez, e.tramo))
	end

	-- Cámara: se abre un poco con la rapidez.
	local camara = workspace.CurrentCamera
	local mio = if jugador.Character then efectos[jugador.Character] else nil
	if camara and camara.CameraType == Enum.CameraType.Custom then
		local objetivo = ajustes.FovBase
			+ ajustes.FovExtra * fraccion(if mio then mio.rapidez else 0)
		camara.FieldOfView += (objetivo - camara.FieldOfView) * math.min(
			dt * ajustes.SuavizadoFov,
			1
		)
	end
end)

-- Animación de correr: el script Animate le pone su velocidad a la pista cada vez que cambia tu
-- rapidez. Si la pista tiene una velocidad distinta a la que le pusimos acá, la puso Animate:
-- esa es la base, y le multiplicamos el extra encima.
type Puesta = { base: number, final: number }
local puestas: { [AnimationTrack]: Puesta } = setmetatable({}, { __mode = "k" }) :: any

RunService.PreAnimation:Connect(function()
	local personaje = jugador.Character
	local humanoide = if personaje then personaje:FindFirstChildOfClass("Humanoid") else nil
	local animador = if humanoide then humanoide:FindFirstChildOfClass("Animator") else nil
	local mio = if personaje then efectos[personaje] else nil
	if not animador or not mio then
		return
	end
	local extra = 1 + ajustes.AnimacionExtra * fraccion(mio.rapidez)
	for _, pista in animador:GetPlayingAnimationTracks() do
		local animacion = pista.Animation
		if animacion and (animacion.Name == "RunAnim" or animacion.Name == "WalkAnim") then
			local puesta = puestas[pista]
			local base = if puesta and math.abs(pista.Speed - puesta.final) < 0.001
				then puesta.base
				else pista.Speed
			local final = base * extra
			pista:AdjustSpeed(final)
			puestas[pista] = { base = base, final = final }
		end
	end
end)
