--!strict
-- Muestra una criatura dentro de un ViewportFrame (tarjetas, casilleros, Mutadex y tienda).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)

local Vista = {}

-- `silueta` = true la muestra toda negra (especies que todavía no descubriste).
-- `personalidad` le cambia los ojos y `variante` la pinta con su catalizador.
-- Devuelve el modelo (o nil si no hay criatura), por si hay que girarlo.
function Vista.mostrar(
	vista: ViewportFrame,
	clave: string?,
	mutante: boolean?,
	silueta: boolean?,
	personalidad: string?,
	variante: string?
): Model?
	for _, d in vista:GetChildren() do
		if d:IsA("Model") or d:IsA("Camera") then
			d:Destroy()
		end
	end
	local c = if clave then Fusion.porClave(clave) else nil
	if not c then
		return nil
	end
	-- Fuera del workspace la criatura no se anima: queda quieta como una foto.
	local modelo = Generador.crear(
		c,
		CFrame.new(),
		nil,
		mutante and not silueta,
		if silueta then nil else personalidad,
		if silueta then nil else variante
	)
	if silueta then
		Generador.silueta(modelo)
	end
	modelo.Parent = vista
	local camara = Instance.new("Camera")
	camara.FieldOfView = 38
	camara.CFrame = CFrame.lookAt(Vector3.new(-5, 5.5, -10.5), Vector3.new(0, 2.7, 0))
	camara.Parent = vista
	vista.CurrentCamera = camara
	vista.Ambient = Paleta.LuzVista
	vista.LightColor = Paleta.Texto
	vista.LightDirection = Vector3.new(0.5, -1, 0.6)
	return modelo
end

return Vista
