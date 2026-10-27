--!strict
-- Carga módulos de src/shared en Lune como si fuera Roblox: dentro del módulo,
-- `require(script.Parent.Otro)` busca Otro.luau en la misma carpeta.
-- Uso: local cargar = require("./cargar"); local Reglas = cargar("Reglas")

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local CARPETA = "plinko-knight/src/shared"

local cache: { [string]: any } = {}

-- Config tiene algunos números de la sala como Vector3 (no se usan en las reglas): en Lune
-- alcanza con una tabla que guarde X, Y y Z.
local Vector3 = {
	new = function(x: number?, y: number?, z: number?)
		return { X = x or 0, Y = y or 0, Z = z or 0 }
	end,
}

local function cargar(nombre: string): any
	if cache[nombre] ~= nil then
		return cache[nombre]
	end
	local ruta = CARPETA .. "/" .. nombre .. ".luau"
	local fuente = fs.readFile(ruta)
	-- `script.Parent.X` devuelve un marcador; `require` lo carga con esta misma función.
	local padre = setmetatable({}, {
		__index = function(_, hijo: string)
			return { __modulo = hijo }
		end,
	})
	local entorno = {
		script = { Parent = padre },
		Vector3 = Vector3,
		require = function(x: any): any
			if type(x) == "table" and x.__modulo then
				return cargar(x.__modulo)
			end
			return require(x)
		end,
	}
	local chunk = luau.load(fuente, { debugName = ruta, environment = entorno })
	local resultado = chunk()
	cache[nombre] = resultado
	return resultado
end

return cargar
