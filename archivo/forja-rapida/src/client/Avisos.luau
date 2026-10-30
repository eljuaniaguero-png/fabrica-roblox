--!strict
-- Carteles que bajan desde arriba, de a uno por vez: logros, colecciones, récords, eventos y
-- anuncios del servidor. Avisos.mostrar({ Titulo, Texto, Color, Duracion, Icono }) y
-- Avisos.hitos(lista) para los hitos de la cadena de descubrimientos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

export type Aviso = {
	Titulo: string,
	Texto: string,
	Color: Color3?,
	Duracion: number?,
	Icono: string?, -- nombre de GameConfig.Iconos
}

-- Lo que manda el servidor (Descubrimientos.Hito).
export type Hito = {
	Id: string,
	Titulo: string?,
	Nombre: string,
	Descripcion: string,
	Monedas: number?,
	Suerte: number?,
	Coleccion: boolean,
	Cosmetico: string?, -- Grupo 3: lo que desbloquea ("Aura: Destellos de Cuarzo")
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
	local titulo = Estilo.conIconos(if a.Icono then { a.Icono } else {}, a.Titulo, 34)
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

-- Colecciones, logros y récords: un cartel por cada uno, con su premio.
function Avisos.hitos(lista: { Hito })
	for _, h in lista do
		local premio = {}
		if h.Monedas then
			table.insert(premio, "+" .. Formato.corto(h.Monedas) .. " Monedas")
		end
		if h.Suerte then
			table.insert(premio, "+" .. Formato.suerte(h.Suerte):sub(2) .. " Suerte para siempre")
		end
		if h.Cosmetico then
			table.insert(premio, h.Cosmetico)
		end
		local texto = h.Nombre
			.. " · "
			.. (if #premio > 0 then table.concat(premio, " · ") else h.Descripcion)
		-- SONIDO: logro o colección completada
		Sonidos.tocar(GameConfig.Sonidos.Logro, if h.Coleccion then 1.1 else 1)
		Avisos.mostrar({
			Titulo = h.Titulo
				or (if h.Coleccion then "¡Colección completa!" else "¡Logro desbloqueado!"),
			Texto = texto,
			Color = Color3.fromHex(if h.Coleccion then "#B04DFF" else "#FFC93C"),
			Duracion = 3,
			Icono = "Trofeo",
		})
	end
end

return Avisos
