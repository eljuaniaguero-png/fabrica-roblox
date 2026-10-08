--!strict
-- Muestra una criatura dentro de un ViewportFrame (tarjetas, ranuras y Mutadex).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)

local Vista = {}

-- `silueta` = true la muestra toda negra (especies que todavía no descubriste).
function Vista.mostrar(vista: ViewportFrame, clave: string?, mutante: boolean?, silueta: boolean?)
	for _, d in vista:GetChildren() do
		if d:IsA("Model") or d:IsA("Camera") then
			d:Destroy()
		end
	end
	local c = if clave then Fusion.porClave(clave) else nil
	if not c then
		return
	end
	-- Fuera del workspace la criatura no se anima: queda quieta como una foto.
	local modelo = Generador.crear(c, CFrame.new(), nil, mutante and not silueta)
	if silueta then
		Generador.silueta(modelo)
	end
	modelo.Parent = vista
	local camara = Instance.new("Camera")
	camara.FieldOfView = 38
	camara.CFrame = CFrame.lookAt(Vector3.new(-5, 5.5, -10.5), Vector3.new(0, 2.7, 0))
	camara.Parent = vista
	vista.CurrentCamera = camara
	vista.Ambient = Color3.fromRGB(190, 180, 200)
	vista.LightColor = Color3.new(1, 1, 1)
	vista.LightDirection = Vector3.new(0.5, -1, 0.6)
end

return Vista
