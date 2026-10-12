--!strict
-- El arte hecho en Blender (ideas/mutant-lab-arte.md). Los modelos viven en
-- ReplicatedStorage > Arte > <grupo> > <Objeto>, cada uno con una malla por zona de color.
-- Acá se pintan según su nombre (ArteColores.luau, generado por los scripts de Blender) y se
-- piden copias. Si falta un modelo, `copia` devuelve nil y el que la pidió usa su versión vieja.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArteColores = require(script.Parent.ArteColores)
local Config = require(script.Parent.Config)
local Paleta = require(script.Parent.Paleta)

local Arte = {}

-- Color de la paleta por su clave con puntos ("Acento", "Especies.1.Color"), o nil.
local function dePaleta(clave: string): Color3?
	local actual: any = Paleta
	for parte in clave:gmatch("[^%.]+") do
		if typeof(actual) ~= "table" then
			return nil
		end
		actual = actual[tonumber(parte) or parte]
	end
	return if typeof(actual) == "Color3" then actual else nil
end

-- Pinta una malla según su nombre: color de la paleta y material por sufijo
-- (_Neon brilla, _Vidrio es transparente, el resto es plástico liso).
function Arte.pintarParte(parte: BasePart)
	local dato = ArteColores[parte.Name]
	if not dato then
		return
	end
	parte.Color = dePaleta(dato.Clave) or Color3.fromHex(dato.Color)
	if dato.Tipo == "Neon" then
		parte.Material = Enum.Material.Neon
	elseif dato.Tipo == "Vidrio" then
		parte.Material = Enum.Material.SmoothPlastic
		parte.Transparency = Config.Arte.Vidrio.Transparencia
		parte.Reflectance = Config.Arte.Vidrio.Reflejo
		parte.CastShadow = false
	else
		parte.Material = Enum.Material.SmoothPlastic
	end
end

function Arte.pintar(modelo: Instance)
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") then
			Arte.pintarParte(d)
		end
	end
	if modelo:IsA("BasePart") then
		Arte.pintarParte(modelo)
	end
end

-- El modelo guardado (sin copiar), o nil si todavía no se importó.
function Arte.modelo(grupo: string, nombre: string): Model?
	local arte = ReplicatedStorage:FindFirstChild("Arte")
	local carpeta = arte and arte:FindFirstChild(grupo)
	local m = carpeta and carpeta:FindFirstChild(nombre)
	return if m and m:IsA("Model") then m else nil
end

-- Una copia del modelo con el pivote en `donde`, o nil si falta (usar la versión vieja).
function Arte.copia(grupo: string, nombre: string, donde: CFrame?): Model?
	local m = Arte.modelo(grupo, nombre)
	if not m then
		return nil
	end
	local c = m:Clone()
	if donde then
		c:PivotTo(donde)
	end
	return c
end

return Arte
