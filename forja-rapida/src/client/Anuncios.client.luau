--!strict
-- Avisos del servidor y ajustes del jugador.
--   Remotos.Anuncio  carteles para todo el servidor. Los de tipo "Hallazgo" (gemas rarísimas de
--                    otros) se pueden ocultar con el ajuste "Ver anuncios de otros"; los de
--                    eventos y jefes se ven siempre. Nada va al chat.
--   Remotos.Aviso    avisos cortos para este jugador.
--   Remotos.Hitos    logros, metas y récords que llegan fuera de una revelación.
--   Remotos.Premio   "+X Monedas" que salta (cristales de la lluvia, metas de eventos).
-- Botón "Ajustes" abajo a la derecha: efectos reducidos, anunciar mis hallazgos, ver anuncios
-- de otros y ver títulos. Los guarda el servidor (Remotos.Ajustes).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Avisos = require(script.Parent.Avisos)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Anuncio = remotos:WaitForChild("Anuncio") :: RemoteEvent
local Aviso = remotos:WaitForChild("Aviso") :: RemoteEvent
local Ajustes = remotos:WaitForChild("Ajustes") :: RemoteEvent
local Hitos = remotos:WaitForChild("Hitos") :: RemoteEvent
local Premio = remotos:WaitForChild("Premio") :: RemoteEvent

local ICONO_TIPO: { [string]: string } = { Hallazgo = "Gema", Evento = "Reloj", Jefe = "Jefe" }

Anuncio.OnClientEvent:Connect(function(texto: unknown, color: unknown, tipo: unknown)
	if typeof(texto) ~= "string" then
		return
	end
	local clase = if typeof(tipo) == "string" then tipo else "Hallazgo"
	if clase == "Hallazgo" and jugador:GetAttribute("VerAnuncios") == false then
		return
	end
	local ok, c = pcall(Color3.fromHex, if typeof(color) == "string" then color else "#FFC93C")
	-- SONIDO: anuncio a todo el servidor
	Sonidos.tocar(GameConfig.Sonidos.Anuncio)
	Avisos.mostrar({
		Titulo = if clase == "Evento"
			then "¡EVENTO!"
			elseif clase == "Jefe" then "¡JEFE ANCESTRAL!"
			else "¡ATENCIÓN!",
		Texto = texto,
		Color = if ok then c else nil,
		Duracion = 4,
		Icono = ICONO_TIPO[clase],
	})
end)

Aviso.OnClientEvent:Connect(function(texto: unknown)
	if typeof(texto) == "string" then
		Avisos.mostrar({
			Titulo = "Aviso",
			Texto = texto,
			Color = Color3.fromHex("#3FA9FF"),
			Duracion = 3,
		})
	end
end)

Hitos.OnClientEvent:Connect(function(lista: unknown)
	if typeof(lista) == "table" then
		Avisos.hitos(lista :: { Avisos.Hito })
	end
end)

-- "+X Monedas" que sube desde abajo del centro de la pantalla.
local pantalla = Estilo.pantalla("Ajustes", 5)
pantalla.Parent = jugador:WaitForChild("PlayerGui")

Premio.OnClientEvent:Connect(function(monto: unknown)
	if typeof(monto) ~= "number" then
		return
	end
	-- SONIDO: monedas (cristal de la lluvia o premio de evento)
	Sonidos.tocar(GameConfig.Sonidos.Cristal, 1 + math.random() * 0.2)
	local f =
		Estilo.conIconos({ "Moneda" }, "+" .. Formato.corto(monto), 40, Color3.fromHex("#7CFF3C"))
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * 0.15, 0.72)
	f.Parent = pantalla
	TweenService:Create(
		f,
		TweenInfo.new(1, Enum.EasingStyle.Quad),
		{ Position = f.Position - UDim2.fromScale(0, 0.12) }
	):Play()
	task.delay(1, function()
		f:Destroy()
	end)
end)

-- Panel de ajustes ---------------------------------------------------------------------------

type Opcion = { Atributo: string, Texto: string, PorDefecto: boolean }
local OPCIONES: { Opcion } = {
	{ Atributo = "EfectosReducidos", Texto = "Efectos reducidos", PorDefecto = false },
	{ Atributo = "AnunciarHallazgos", Texto = "Anunciar mis hallazgos", PorDefecto = true },
	{ Atributo = "VerAnuncios", Texto = "Ver hallazgos de otros", PorDefecto = true },
	{ Atributo = "VerTitulos", Texto = "Ver títulos", PorDefecto = true },
}

local function valor(o: Opcion): boolean
	if o.Atributo == "EfectosReducidos" then
		return Efectos.reducidos()
	end
	local v = jugador:GetAttribute(o.Atributo)
	return if typeof(v) == "boolean" then v else o.PorDefecto
end

local boton = Instance.new("TextButton")
boton.AnchorPoint = Vector2.new(1, 1)
boton.Position = UDim2.new(1, -16, 1, -16)
boton.Size = UDim2.fromOffset(150, 46)
boton.BackgroundColor3 = Color3.new(1, 1, 1)
boton.Text = ""
boton.AutoButtonColor = true
Estilo.esquinas(boton, 14)
Estilo.borde(boton, 3)
Estilo.degradado(boton, { "#5BBEFF", "#1C7FE0" })
boton.Parent = pantalla
local etiqueta = Estilo.conIconos({ "Chispa" }, "Ajustes", 22)
etiqueta.AnchorPoint = Vector2.new(0.5, 0.5)
etiqueta.Position = UDim2.fromScale(0.5, 0.5)
etiqueta.Parent = boton

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -16, 1, -72)
panel.AutomaticSize = Enum.AutomaticSize.XY
panel.Size = UDim2.fromOffset(0, 0)
panel.BackgroundColor3 = Color3.fromHex("#20243F")
panel.Visible = false
Estilo.esquinas(panel, 18)
Estilo.borde(panel, 4)
local relleno = Instance.new("UIPadding")
relleno.PaddingLeft, relleno.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
relleno.PaddingTop, relleno.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
relleno.Parent = panel
local lista = Instance.new("UIListLayout")
lista.Padding = UDim.new(0, 8)
lista.SortOrder = Enum.SortOrder.LayoutOrder
lista.Parent = panel
panel.Parent = pantalla

local refrescos: { () -> () } = {}
for i, o in OPCIONES do
	local fila = Instance.new("TextButton")
	fila.LayoutOrder = i
	fila.Size = UDim2.fromOffset(300, 44)
	fila.Text = ""
	fila.BackgroundColor3 = Color3.new(1, 1, 1)
	Estilo.esquinas(fila, 12)
	Estilo.borde(fila, 3)
	local fondo = Estilo.degradado(fila, { "#6BE86B", "#22A83A" })
	local texto = Estilo.texto(o.Texto, 20)
	texto.AnchorPoint = Vector2.new(0, 0.5)
	texto.Position = UDim2.new(0, 12, 0.5, 0)
	texto.Parent = fila
	local estado = Estilo.texto("", 20)
	estado.AnchorPoint = Vector2.new(1, 0.5)
	estado.Position = UDim2.new(1, -12, 0.5, 0)
	estado.Parent = fila
	local function refrescar()
		local si = valor(o)
		estado.Text = if si then "SÍ" else "NO"
		fondo.Color = if si
			then ColorSequence.new(Color3.fromHex("#6BE86B"), Color3.fromHex("#22A83A"))
			else ColorSequence.new(Color3.fromHex("#C2C8D0"), Color3.fromHex("#8D939C"))
	end
	refrescar()
	table.insert(refrescos, refrescar)
	jugador:GetAttributeChangedSignal(o.Atributo):Connect(refrescar)
	fila.Activated:Connect(function()
		Ajustes:FireServer(o.Atributo, not valor(o))
	end)
	fila.Parent = panel
end

boton.Activated:Connect(function()
	panel.Visible = not panel.Visible
	for _, r in refrescos do
		r()
	end
end)
