--!strict
-- Una sola animación para todas las criaturas: saltitos con bamboleo.
-- Algunos rasgos la cambian: flota (sin saltos), rueda (da una vuelta) y
-- se entierra (baja al piso y vuelve). Se mueve todo el modelo con PivotTo.

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
}

local Animacion = {}

function Animacion.preparar(modelo: Model): Estado
	local transparencias = {}
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "Raiz" then
			transparencias[d] = d.Transparency
		end
	end
	return {
		Modelo = modelo,
		Base = modelo:GetPivot(),
		Fase = math.random() * 10,
		Rasgo = (modelo:GetAttribute("Rasgo") :: number?) or 0,
		Transparencias = transparencias,
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

function Animacion.paso(e: Estado, reloj: number)
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
end

return Animacion
