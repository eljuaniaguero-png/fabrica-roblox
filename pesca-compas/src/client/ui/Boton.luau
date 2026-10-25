--!strict
-- Botón toon reutilizable: esquina redonda, borde azul marino, texto con contorno y el "jugo"
-- de interacción (MouseEnter crece, MouseLeave vuelve, MouseButton1Down se aplasta y al soltar
-- rebota). La escala va en un UIScale, así no pisa el Size que maneja el layout.
-- Las conexiones mueren solas con el botón (Destroy desconecta todo lo que tiene adentro).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Estilo = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Estilo"))
local Tokens = require(script.Parent.Tokens)
local UI = Estilo.UI

export type Opciones = {
	Texto: string,
	Color: Color3,
	Tam: UDim2,
	Pos: UDim2,
	Ancla: Vector2?,
	Padre: Instance,
}

local Boton = {}

-- Le suma las animaciones a un GuiButton que ya existe.
function Boton.jugo(b: GuiButton)
	local escala = b:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	escala.Parent = b
	local encima = false

	local function ir(valor: number, info: TweenInfo)
		TweenService:Create(escala, info, { Scale = valor }):Play()
	end

	b.MouseEnter:Connect(function()
		encima = true
		ir(Tokens.Boton.Encima, Tokens.Tween.Encima)
	end)
	b.MouseLeave:Connect(function()
		encima = false
		ir(1, Tokens.Tween.Encima)
	end)
	b.MouseButton1Down:Connect(function()
		ir(Tokens.Boton.Apretado, Tokens.Tween.Apretar)
	end)
	b.MouseButton1Up:Connect(function()
		-- en celular no hay MouseLeave después de tocar: vuelve a 1, no queda "encima"
		ir(if encima and b.Parent then Tokens.Boton.Encima else 1, Tokens.Tween.Soltar)
	end)
end

function Boton.nuevo(o: Opciones): TextButton
	local b = Instance.new("TextButton")
	b.Size = o.Tam
	b.Position = o.Pos
	b.AnchorPoint = o.Ancla or Vector2.zero
	b.BackgroundColor3 = o.Color
	b.AutoButtonColor = false -- el feedback lo dan los tweens, no el gris de Roblox
	b.Font = UI.Fuente
	b.TextScaled = true
	b.TextColor3 = UI.Texto
	b.Text = o.Texto
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, UI.Esquina)
	esquina.Parent = b
	local relleno = Instance.new("UIPadding")
	relleno.PaddingLeft = UDim.new(0, Tokens.Relleno)
	relleno.PaddingRight = UDim.new(0, Tokens.Relleno)
	relleno.PaddingTop = UDim.new(0, Tokens.Relleno // 2)
	relleno.PaddingBottom = UDim.new(0, Tokens.Relleno // 2)
	relleno.Parent = b
	Estilo.borde(b)
	Boton.jugo(b)
	b.Parent = o.Padre
	return b
end

-- Muestra si alcanza la plata sin desactivar el botón: el servidor valida igual y avisa.
function Boton.habilitar(b: GuiButton, si: boolean)
	b.BackgroundTransparency = if si then 0 else Tokens.Boton.Bloqueado
end

return Boton
