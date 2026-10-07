--!strict
-- Arma el modelo de cualquier criatura a partir de sus piezas.

local CollectionService = game:GetService("CollectionService")

local Fusion = require(script.Parent.Fusion)
local Piezas = require(script.Parent.Piezas)

local Generador = {}

-- Crea el modelo parado en `donde` (el pivote queda en el piso, mirando a -Z).
function Generador.crear(c: Fusion.Criatura, donde: CFrame, padre: Instance?): Model
	local modelo = Instance.new("Model")
	modelo.Name = c.Nombre

	-- Raíz invisible: es el pivote y lleva las partículas y luces.
	local raiz = Instance.new("Part")
	raiz.Name = "Raiz"
	raiz.Anchored = true
	raiz.CanCollide = false
	raiz.CanQuery = false
	raiz.Transparency = 1
	raiz.Size = Vector3.new(1, 1, 1)
	raiz.CFrame = donde
	raiz.Parent = modelo
	modelo.PrimaryPart = raiz

	-- Cada pieza se pinta con los colores del padre que la trae.
	local function ctx(base: number): Piezas.Ctx
		local color, manchas = Fusion.pintura(c, base)
		return {
			Modelo = modelo,
			Origen = donde,
			Color = color,
			Manchas = manchas,
		}
	end

	Piezas.Patas[c.Patas](ctx(c.Patas))
	Piezas.Cuerpos[c.Cuerpo](ctx(c.Cuerpo))
	Piezas.Cabezas[c.Cabeza](ctx(c.Cabeza))
	Piezas.Extremidades[c.Extremidad](ctx(c.Extremidad))
	Piezas.Rasgos[c.Rasgo](ctx(c.Cuerpo), raiz, c.Cuerpo)
	if c.Gen >= 3 then
		Piezas.aura(raiz)
	end

	modelo:SetAttribute("Clave", c.Clave)
	modelo:SetAttribute("Gen", c.Gen)
	modelo:SetAttribute("Rasgo", c.Rasgo)
	CollectionService:AddTag(modelo, "Criatura")

	modelo.Parent = padre
	return modelo
end

return Generador
