--!strict
-- Una sola animación para todas las criaturas: saltitos con bamboleo.
-- Algunos rasgos la cambian: flota (sin saltos), rueda (da una vuelta) y
-- se entierra (baja al piso y vuelve). Se mueve todo el modelo con PivotTo.
-- Si el modelo tiene los atributos ZonaCFrame y ZonaTamano (criaturas de un corral),
-- además camina: va a un punto al azar de la zona, se queda un rato y elige otro.

local Config = require(script.Parent.Config)

local A = Config.Animacion

-- Rasgos que cambian el movimiento (número de base del rasgo).
local RASGO_RUEDA = 4
local RASGO_ENTIERRA = 6
local RASGO_FLOTA = 7
local RASGO_TRANSPARENTE = 10

export type Estado = {
	Modelo: Model,
	Base: CFrame,
	Fase: number,
	Rasgo: number,
	Transparencias: { [BasePart]: number },
	Colores: { [BasePart]: Color3 }?, -- solo mutantes: colores originales para hacerlos cambiar
	Paseo: Paseo?, -- solo criaturas de un corral
}

type Paseo = {
	Zona: CFrame, -- centro de la zona, a la altura del piso
	Tamano: Vector3,
	Pos: Vector3,
	Destino: Vector3?,
	Espera: number,
}

local Animacion = {}

local azar = Random.new()

local function puntoAlAzar(p: Paseo): Vector3
	local x = (azar:NextNumber() - 0.5) * p.Tamano.X
	local z = (azar:NextNumber() - 0.5) * p.Tamano.Z
	return (p.Zona * CFrame.new(x, 0, z)).Position
end

-- Camina hacia el destino. Devuelve el nuevo "Base" (posición + hacia dónde mira).
local function caminar(e: Estado, p: Paseo, dt: number): CFrame
	if p.Espera > 0 then
		p.Espera -= dt
		return e.Base
	end
	local destino = p.Destino
	if not destino then
		destino = puntoAlAzar(p)
		p.Destino = destino
	end
	local delta = (destino :: Vector3) - p.Pos
	delta = Vector3.new(delta.X, 0, delta.Z)
	if delta.Magnitude < 0.3 then
		p.Destino = nil
		p.Espera = azar:NextNumber(A.PausaPaseo[1], A.PausaPaseo[2])
		return e.Base
	end
	local direccion = delta.Unit
	p.Pos += direccion * math.min(delta.Magnitude, A.VelocidadPaseo * dt)
	-- El frente de la criatura es -Z: lookAt la deja mirando hacia donde camina. Gira suave.
	local mirando = CFrame.lookAt(p.Pos, p.Pos + direccion)
	local giro = e.Base.Rotation:Lerp(mirando.Rotation, math.min(1, dt * 6))
	return CFrame.new(p.Pos) * giro
end

-- Velocidad del cambio de colores de los mutantes (vueltas a la rueda de colores por segundo).
local VELOCIDAD_TORNASOL = 0.12

function Animacion.preparar(modelo: Model): Estado
	local transparencias = {}
	local colores: { [BasePart]: Color3 }? = if modelo:GetAttribute("Mutante") then {} else nil
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "Raiz" then
			transparencias[d] = d.Transparency
			local _, saturacion = d.Color:ToHSV()
			-- Los ojos (blanco y negro) no cambian de color.
			if colores and saturacion > 0.15 then
				colores[d] = d.Color
			end
		end
	end
	local zona = modelo:GetAttribute("ZonaCFrame") :: CFrame?
	local tamano = modelo:GetAttribute("ZonaTamano") :: Vector3?
	local paseo: Paseo? = nil
	if zona and tamano then
		paseo = {
			Zona = zona,
			Tamano = tamano,
			Pos = modelo:GetPivot().Position,
			Destino = nil,
			Espera = azar:NextNumber(0, 2),
		}
	end
	return {
		Modelo = modelo,
		Base = modelo:GetPivot(),
		Fase = math.random() * 10,
		Rasgo = (modelo:GetAttribute("Rasgo") :: number?) or 0,
		Transparencias = transparencias,
		Colores = colores,
		Paseo = paseo,
	}
end

-- Curva suave de 0 a 1 a 0 dentro de una ventana de `duracion` segundos.
local function pulso(t: number, cada: number, duracion: number): number
	local x = t % cada
	if x > duracion then
		return 0
	end
	return math.sin(x / duracion * math.pi)
end

function Animacion.paso(e: Estado, reloj: number, dt: number)
	if e.Paseo then
		e.Base = caminar(e, e.Paseo, dt)
	end
	local t = reloj + e.Fase
	local fase = t / A.PeriodoSalto * math.pi
	local alto = math.abs(math.sin(fase)) * A.AlturaSalto
	local giroY = 0

	if e.Rasgo == RASGO_FLOTA then
		alto = A.AlturaFlotar + math.sin(t * 2) * 0.25
	elseif e.Rasgo == RASGO_ENTIERRA then
		alto -= pulso(t, A.CadaCuantoSeEntierra, 1.6) * A.ProfundidadEntierro
	elseif e.Rasgo == RASGO_RUEDA then
		local x = t % A.CadaCuantoRueda
		if x < 1 then
			giroY = x * 2 * math.pi
			alto += math.sin(x * math.pi) * 0.8
		end
	end

	local bamboleo = math.sin(fase) * A.Bamboleo
	e.Modelo:PivotTo(e.Base * CFrame.new(0, alto, 0) * CFrame.Angles(0, giroY, bamboleo))

	if e.Rasgo == RASGO_TRANSPARENTE then
		local nivel = pulso(t, 4, 2) * 0.65
		for parte, original in e.Transparencias do
			parte.Transparency = original + (1 - original) * nivel
		end
	end

	-- Mutantes: colores tornasolados que giran lento por la rueda de colores.
	if e.Colores then
		local corrimiento = (t * VELOCIDAD_TORNASOL) % 1
		for parte, original in e.Colores do
			local h, s, v = original:ToHSV()
			parte.Color = Color3.fromHSV((h + corrimiento) % 1, s, v)
		end
	end
end

return Animacion
