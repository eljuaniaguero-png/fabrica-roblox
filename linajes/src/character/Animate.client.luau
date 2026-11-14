--!strict
-- Nuestro Animate: reemplaza al de Roblox (no usa paquetes de animación ni gestos del avatar).
-- Elige la animación según el estado del Humanoid. IDs en Config.Animaciones.base (P26-01).
-- Volar no es un estado del Humanoid: lo prende el sistema de vuelo con el atributo "Volando"
-- (true/false) del personaje.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local personaje = script.Parent
local humanoid = personaje:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator
local A = Config.Animaciones

-- Loop y prioridad vienen de las animaciones publicadas (Quieto: Core; el resto: Movement).
local pistas: { [string]: AnimationTrack } = {}
for nombre, id in A.base do
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	pistas[nombre] = animator:LoadAnimation(anim)
end

local actual: string? = nil
local function tocar(nombre: string, fundido: number?)
	if actual == nombre then
		return
	end
	if actual then
		pistas[actual]:Stop(fundido or 0.2)
	end
	actual = nombre
	pistas[nombre]:Play(fundido or 0.2)
end

-- Ajusta la velocidad de la animación a la del personaje (con tope) para que no patine.
local function ajustar(nombre: string, v: number)
	local ref = A.Referencia[nombre]
	if ref then
		pistas[nombre]:AdjustSpeed(math.clamp(v / ref, A.TopeVelocidad[1], A.TopeVelocidad[2]))
	end
end

local function segunVelocidad(v: number): string
	if v < 0.5 then
		return "Quieto"
	elseif v < A.VelocidadCorrer then
		return "Caminar"
	elseif v < A.VelocidadCorrerRapido then
		return "Correr"
	end
	return "CorrerRapido"
end

local velocidad = 0
local function enElPiso()
	local nombre = segunVelocidad(velocidad)
	tocar(nombre)
	ajustar(nombre, velocidad)
end

local function volando(): boolean
	return personaje:GetAttribute("Volando") == true
end

local function animarVuelo()
	local v = (personaje :: Model).PrimaryPart
			and ((personaje :: Model).PrimaryPart :: BasePart).AssemblyLinearVelocity.Magnitude
		or 0
	tocar(if v < A.VelocidadVolar then "VolarQuieto" else "VolarAvanzando", 0.3)
end

humanoid.Running:Connect(function(v)
	velocidad = v
	if volando() then
		return
	end
	local estado = humanoid:GetState()
	if
		estado == Enum.HumanoidStateType.Running
		or estado == Enum.HumanoidStateType.RunningNoPhysics
	then
		-- Si está terminando de caer, deja que la caída amortigüe antes de cambiar.
		if actual ~= "SaltarCaer" or not pistas.SaltarCaer.IsPlaying then
			enElPiso()
		end
	end
end)

humanoid.Climbing:Connect(function(v)
	if actual == "Trepar" then
		-- Quieto en la pared: la animación se frena; trepando, va a velocidad normal.
		pistas.Trepar:AdjustSpeed(if math.abs(v) < 0.1 then 0 else 1)
	end
end)

humanoid.Swimming:Connect(function(v)
	tocar(if v < 1 then "Flotar" else "Nadar", 0.3)
end)

-- Cuando termina el aterrizaje (no tiene loop), vuelve a caminar, correr o quedarse quieto.
pistas.SaltarCaer.Stopped:Connect(function()
	if actual == "SaltarCaer" then
		actual = nil
		enElPiso()
	end
end)

-- El impulso del salto (no tiene loop) pasa al loop en el aire.
pistas.SaltarInicio.Stopped:Connect(function()
	if actual == "SaltarInicio" and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		tocar("SaltarAire", 0.15)
	end
end)

humanoid.StateChanged:Connect(function(_, estado)
	if volando() then
		return
	end
	if estado == Enum.HumanoidStateType.Jumping then
		tocar("SaltarInicio", 0.1)
	elseif estado == Enum.HumanoidStateType.Freefall then
		if actual ~= "SaltarInicio" then
			tocar("SaltarAire", 0.3)
		end
	elseif estado == Enum.HumanoidStateType.Climbing then
		tocar("Trepar", 0.1)
	elseif estado == Enum.HumanoidStateType.Landed then
		tocar("SaltarCaer", 0.05)
	elseif estado == Enum.HumanoidStateType.Running then
		if actual ~= "SaltarCaer" then
			enElPiso()
		end
	end
end)

personaje:GetAttributeChangedSignal("Volando"):Connect(function()
	if volando() then
		animarVuelo()
	else
		enElPiso()
	end
end)

-- Volando, revisa la velocidad 5 veces por segundo para pasar de quieto a avanzando.
task.spawn(function()
	while personaje.Parent do
		if volando() then
			animarVuelo()
		end
		task.wait(0.2)
	end
end)

tocar("Quieto", 0)
