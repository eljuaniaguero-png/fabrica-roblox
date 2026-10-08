--!strict
-- Arma el modelo de cualquier criatura a partir de sus piezas.

local CollectionService = game:GetService("CollectionService")

local Fusion = require(script.Parent.Fusion)
local Piezas = require(script.Parent.Piezas)

local Generador = {}

local COLOR_SILUETA = Color3.fromHex("1B1030")

-- Crea el modelo parado en `donde` (el pivote queda en el piso, mirando a -Z).
-- La versión mutante tiene las mismas piezas: solo suma estrellitas y colores que cambian.
function Generador.crear(
	c: Fusion.Criatura,
	donde: CFrame,
	padre: Instance?,
	mutante: boolean?
): Model
	local modelo = Instance.new("Model")
	modelo.Name = c.Nombre
	-- Que llegue entera a cada jugador (si no, la animación puede arrancar sin sus piezas).
	modelo.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

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
	if mutante then
		Piezas.estrellas(raiz)
		modelo:SetAttribute("Mutante", true)
	end

	modelo:SetAttribute("Clave", c.Clave)
	modelo:SetAttribute("Gen", c.Gen)
	modelo:SetAttribute("Rasgo", c.Rasgo)
	CollectionService:AddTag(modelo, "Criatura")

	modelo.Parent = padre
	return modelo
end

-- Deja el modelo como una silueta negra: sin colores, brillos ni partículas.
-- Conviene llamarla antes de ponerle Parent, así la animación guarda la versión negra.
function Generador.silueta(modelo: Model)
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "Raiz" then
			d.Color = COLOR_SILUETA
			d.Material = Enum.Material.SmoothPlastic
			d.Transparency = 0
		elseif d:IsA("ParticleEmitter") or d:IsA("Light") then
			d:Destroy()
		end
	end
	modelo:SetAttribute("Rasgo", 0)
	modelo:SetAttribute("Mutante", nil)
end

return Generador
