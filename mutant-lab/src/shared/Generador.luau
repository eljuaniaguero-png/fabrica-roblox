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

	local ctx: Piezas.Ctx = {
		Modelo = modelo,
		Origen = donde,
		Color = c.Color,
		Manchas = c.Manchas,
	}

	Piezas.Patas[c.Patas](ctx)
	Piezas.Cuerpos[c.Cuerpo](ctx)
	Piezas.Cabezas[c.Cabeza](ctx)

	-- En gen 3 la cola o las alas llevan el color "brillo" del último padre.
	local ctxExtremidad = ctx
	if c.Brillo then
		ctxExtremidad = table.clone(ctx)
		ctxExtremidad.Color = c.Brillo
	end
	Piezas.Extremidades[c.Extremidad](ctxExtremidad)

	Piezas.Rasgos[c.Rasgo](ctx, raiz, c.Cuerpo)
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
