--!strict
-- Carteles que bajan desde arriba, de a uno por vez: logros, colecciones y anuncios del
-- servidor. Avisos.mostrar({ Titulo = "...", Texto = "...", Color = Color3, Duracion = 3 }).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Estilo = require(script.Parent.Estilo)

export type Aviso = {
	Titulo: string,
	Texto: string,
	Color: Color3?,
	Duracion: number?,
}

local pantalla = Estilo.pantalla("Avisos", 20)
pantalla.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local cola: { Aviso } = {}
local mostrando = false

local function dibujar(a: Aviso): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0)
	f.Position = UDim2.new(0.5, 0, 0, -140)
	f.Size = UDim2.fromOffset(0, 0)
	f.AutomaticSize = Enum.AutomaticSize.XY
	f.BackgroundColor3 = a.Color or Color3.fromHex("#FFC93C")
	Estilo.esquinas(f, 18)
	Estilo.borde(f, 4)
	local brillo = Instance.new("UIGradient")
	brillo.Rotation = 90
	brillo.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHex("#BBBBBB"))
	brillo.Parent = f
	local relleno = Instance.new("UIPadding")
	relleno.PaddingLeft = UDim.new(0, 26)
	relleno.PaddingRight = UDim.new(0, 26)
	relleno.PaddingTop = UDim.new(0, 10)
	relleno.PaddingBottom = UDim.new(0, 12)
	relleno.Parent = f
	local lista = Instance.new("UIListLayout")
	lista.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lista.Padding = UDim.new(0, 2)
	lista.SortOrder = Enum.SortOrder.LayoutOrder
	lista.Parent = f
	local titulo = Estilo.texto(a.Titulo, 34)
	titulo.LayoutOrder = 1
	titulo.Parent = f
	local texto = Estilo.texto(a.Texto, 22)
	texto.LayoutOrder = 2
	texto.Parent = f
	f.Parent = pantalla
	return f
end

local function siguiente()
	if mostrando then
		return
	end
	mostrando = true
	task.spawn(function()
		while #cola > 0 do
			local a = table.remove(cola, 1) :: Aviso
			local f = dibujar(a)
			local entrar = TweenService:Create(
				f,
				TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0.5, 0, 0, 120) }
			)
			entrar:Play()
			entrar.Completed:Wait()
			task.wait(a.Duracion or 3)
			local salir = TweenService:Create(
				f,
				TweenInfo.new(0.25),
				{ Position = UDim2.new(0.5, 0, 0, -140) }
			)
			salir:Play()
			salir.Completed:Wait()
			f:Destroy()
		end
		mostrando = false
	end)
end

local Avisos = {}

function Avisos.mostrar(a: Aviso)
	table.insert(cola, a)
	siguiente()
end

return Avisos
