--!strict
-- Ventanita 3D (ViewportFrame) que muestra un modelo centrado y encuadrado solo, de 3/4.
-- Sirve para cualquier Model (cebos de ModeloEquipo, peces de ModeloPez). El modelo pasa a ser
-- de la vista: al cambiarlo o destruir la vista, se destruye.
-- Giro: solo con girar(true) (un RenderStepped por vista), así un panel cerrado no gasta nada.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tokens = require(script.Parent.Tokens)

local VistaModelo = {}

export type Opciones = {
	Tam: UDim2,
	Pos: UDim2,
	Ancla: Vector2?,
	Padre: GuiObject,
}

export type Vista = {
	Marco: ViewportFrame,
	poner: (modelo: Model?) -> (),
	girar: (activo: boolean) -> (),
	realzar: (activo: boolean) -> (),
	destruir: () -> (),
}

function VistaModelo.nueva(op: Opciones): Vista
	local V = Tokens.Vista

	local marco = Instance.new("ViewportFrame")
	marco.Size = op.Tam
	marco.Position = op.Pos
	marco.AnchorPoint = op.Ancla or Vector2.zero
	marco.BackgroundTransparency = 1
	marco.Ambient = V.Ambiente
	marco.LightColor = V.Luz
	marco.LightDirection = V.DireccionLuz
	marco.Parent = op.Padre
	local aspecto = Instance.new("UIAspectRatioConstraint")
	aspecto.Parent = marco
	local escala = Instance.new("UIScale")
	escala.Parent = marco

	local camara = Instance.new("Camera")
	camara.FieldOfView = V.Fov
	camara.Parent = marco
	marco.CurrentCamera = camara

	local modelo: Model? = nil
	local base = CFrame.identity -- pivote del modelo con el centro de su caja en el origen
	local angulo = V.AnguloInicial
	local giro: RBXScriptConnection? = nil
	local tweenRealce: Tween? = nil

	local function ubicar()
		if modelo then
			modelo:PivotTo(CFrame.Angles(0, angulo, 0) * base)
		end
	end

	local function poner(nuevo: Model?)
		if modelo then
			modelo:Destroy()
		end
		modelo = nuevo
		if not nuevo then
			return
		end
		-- centrar la caja en el origen: gira sobre sí mismo aunque el pivote esté arriba (cebos)
		local caja, tam = nuevo:GetBoundingBox()
		base = CFrame.new(-caja.Position) * nuevo:GetPivot()
		-- encuadre: la esfera que envuelve la caja entra justo en el campo de visión
		local radio = math.max(tam.Magnitude / 2, 0.1)
		local distancia = radio / math.tan(math.rad(V.Fov / 2)) * V.Margen
		-- el modelo mira a -Z: la cámara va de ese lado, un poco arriba
		camara.CFrame = CFrame.lookAt(Vector3.new(0, radio * 0.35, -distancia), Vector3.zero)
		nuevo.Parent = marco
		ubicar()
	end

	local function girar(activo: boolean)
		if activo and not giro then
			giro = RunService.RenderStepped:Connect(function(dt: number)
				angulo = (angulo + dt * V.Giro) % (math.pi * 2)
				ubicar()
			end)
		elseif not activo and giro then
			giro:Disconnect()
			giro = nil
		end
	end

	-- crece un poco con el mouse encima de la tarjeta (mismo token que los botones)
	local function realzar(activo: boolean)
		if tweenRealce then
			tweenRealce:Cancel()
		end
		local meta = if activo then Tokens.Boton.Encima * 1.08 else 1
		local info = if activo then Tokens.Tween.Soltar else Tokens.Tween.Encima
		local t = TweenService:Create(escala, info, { Scale = meta })
		tweenRealce = t
		t:Play()
	end

	local function destruir()
		girar(false)
		if tweenRealce then
			tweenRealce:Cancel()
		end
		modelo = nil
		marco:Destroy()
	end

	return {
		Marco = marco,
		poner = poner,
		girar = girar,
		realzar = realzar,
		destruir = destruir,
	}
end

return VistaModelo
