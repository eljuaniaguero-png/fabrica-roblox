--!strict
-- Ventanas del kit de Forja Rápida, copiado de forja-rapida/src/client/Ventanas.luau (etapa 12a):
-- fondo oscurecido, ventana oscura con cabecera de color con rayas, ícono y título grande, X roja
-- arriba a la derecha. Una abierta por vez: se abre con un "pop" y se cierra con la X o tocando
-- afuera. En Plinko serán la tienda, el cofre, la ficha de reliquia, el pergamino, elegir bola,
-- ajustes, derrota y victoria (pasos 12c a 12e). Cada una pone lo suyo en Ventana.Cuerpo.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Estilo = require(script.Parent:WaitForChild("Kit"))
local Sonidos = require(script.Parent:WaitForChild("Sonidos"))

local Ventanas = {}

export type Ventana = {
	Id: string,
	Soporte: Frame, -- el que se escala según la pantalla
	Marco: Frame,
	Cuerpo: Frame, -- donde cada menú pone lo suyo
	Ancho: number, -- tamaño útil del cuerpo (en píxeles de diseño, para 1280×720)
	Alto: number,
	Pop: UIScale,
	alAbrir: { () -> () },
}

local pantalla = Estilo.pantalla("Ventanas", 30)
pantalla.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local velo = Instance.new("TextButton")
velo.Name = "Velo"
velo.Text = ""
velo.AutoButtonColor = false
velo.BackgroundColor3 = Color3.fromHex("#0E1230")
velo.BackgroundTransparency = 0.45
velo.BorderSizePixel = 0
velo.Size = UDim2.fromScale(1, 1)
velo.Visible = false
velo.Parent = pantalla

local ventanas: { [string]: Ventana } = {}
local abierta: string? = nil
local cambio = Instance.new("BindableEvent")

function Ventanas.crear(
	id: string,
	titulo: string,
	icono: string,
	colores: { string },
	ancho: number,
	alto: number
): Ventana
	local soporte = Instance.new("Frame")
	soporte.Name = "Ventana" .. id
	soporte.AnchorPoint = Vector2.new(0.5, 0.5)
	soporte.Position = UDim2.fromScale(0.5, 0.52)
	soporte.Size = UDim2.fromOffset(ancho, alto)
	soporte.BackgroundTransparency = 1
	soporte.Visible = false
	soporte.ZIndex = 2
	Estilo.escalar(soporte)

	local marco = Instance.new("Frame")
	marco.Name = "Marco"
	marco.Size = UDim2.fromScale(1, 1)
	Estilo.superficie(marco, { "Panel" }, Estilo.Colores.Noche, 28, 8, true)
	local pop = Instance.new("UIScale")
	pop.Parent = marco
	marco.Parent = soporte

	local cabecera = Instance.new("Frame")
	cabecera.Name = "Cabecera"
	cabecera.Position = UDim2.fromOffset(8, 8)
	cabecera.Size = UDim2.new(1, -16, 0, 96)
	cabecera.ZIndex = 1
	Estilo.superficie(cabecera, { "Cabecera" }, colores, 22, 5)
	Estilo.rayas(cabecera)
	cabecera.Parent = marco
	local nombre = Estilo.conIconos({ icono }, titulo, 58)
	nombre.AnchorPoint = Vector2.new(0, 0.5)
	nombre.Position = UDim2.new(0, 24, 0.5, 0)
	nombre.ZIndex = 3
	nombre.Parent = cabecera

	local x = Estilo.cerrar(64)
	x.AnchorPoint = Vector2.new(1, 0)
	x.Position = UDim2.new(1, -20, 0, 24)
	x.ZIndex = 4
	x.Activated:Connect(function()
		Ventanas.cerrar()
	end)
	x.Parent = marco

	local cuerpo = Instance.new("Frame")
	cuerpo.Name = "Cuerpo"
	cuerpo.BackgroundTransparency = 1
	cuerpo.Position = UDim2.fromOffset(24, 120)
	cuerpo.Size = UDim2.new(1, -48, 1, -140)
	cuerpo.ZIndex = 2
	cuerpo.Parent = marco

	soporte.Parent = pantalla
	local v: Ventana = {
		Id = id,
		Soporte = soporte,
		Marco = marco,
		Cuerpo = cuerpo,
		Ancho = ancho - 48,
		Alto = alto - 140,
		Pop = pop,
		alAbrir = {},
	}
	ventanas[id] = v
	return v
end

function Ventanas.cerrar()
	local id = abierta
	if not id then
		return
	end
	abierta = nil
	ventanas[id].Soporte.Visible = false
	velo.Visible = false
	cambio:Fire(nil)
end

function Ventanas.abrir(id: string)
	local v = ventanas[id]
	if not v or abierta == id then
		return
	end
	if abierta then
		ventanas[abierta].Soporte.Visible = false
	end
	abierta = id
	for _, fn in v.alAbrir do
		task.spawn(fn)
	end
	velo.Visible = true
	v.Soporte.Visible = true
	v.Pop.Scale = 0.82
	TweenService:Create(v.Pop, TweenInfo.new(0.28, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	-- SONIDO: se abre un menú
	Sonidos.tocar("Whoosh")
	cambio:Fire(id)
end

function Ventanas.alternar(id: string)
	if abierta == id then
		Ventanas.cerrar()
	else
		Ventanas.abrir(id)
	end
end

function Ventanas.abierta(): string?
	return abierta
end

function Ventanas.alCambiar(fn: (string?) -> ()): RBXScriptConnection
	return cambio.Event:Connect(fn)
end

velo.Activated:Connect(Ventanas.cerrar)

-- Ayudas para armar los menús ------------------------------------------------------------------

export type Pestana = { Id: string, Texto: string, Icono: string?, Color: string }

-- Fila de pestañas. La elegida se ve de su color; las otras, grises.
-- Devuelve la fila y elegir(id) (también la llama cuando se toca una pestaña).
function Ventanas.pestanas(
	lista: { Pestana },
	ancho: number,
	alto: number,
	alElegir: (string) -> (),
	tamTexto: number?
): (Frame, (string) -> ())
	local fila = Estilo.fila(10)
	fila.Name = "Pestanas"
	local botones: { [string]: TextButton } = {}
	local actual = ""
	local function elegir(id: string)
		if actual == id then
			return
		end
		actual = id
		for _, p in lista do
			Estilo.colorBoton(botones[p.Id], if p.Id == id then p.Color else "Gris")
		end
		alElegir(id)
	end
	for i, p in lista do
		local b = Estilo.boton({
			Texto = p.Texto,
			Icono = p.Icono,
			Color = "Gris",
			Ancho = ancho,
			Alto = alto,
			TamanoTexto = tamTexto,
		})
		b.LayoutOrder = i
		b.Activated:Connect(function()
			elegir(p.Id)
		end)
		b.Parent = fila
		botones[p.Id] = b
	end
	return fila, elegir
end

-- Lista con scroll (vertical) o grilla, sin fondo, que crece con lo que tiene adentro.
function Ventanas.desplazable(
	ancho: number,
	alto: number,
	celda: Vector2?,
	espacio: number?
): ScrollingFrame
	local s = Instance.new("ScrollingFrame")
	s.Name = "Lista"
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.Size = UDim2.fromOffset(ancho, alto)
	s.CanvasSize = UDim2.new()
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.ScrollingDirection = Enum.ScrollingDirection.Y
	s.ScrollBarThickness = 8
	s.ScrollBarImageColor3 = Color3.fromHex("#C9D6EE")
	local relleno = Instance.new("UIPadding")
	relleno.PaddingTop = UDim.new(0, 8)
	relleno.PaddingBottom = UDim.new(0, 8)
	relleno.PaddingLeft = UDim.new(0, 8)
	relleno.PaddingRight = UDim.new(0, 14)
	relleno.Parent = s
	if celda then
		local g = Instance.new("UIGridLayout")
		g.CellSize = UDim2.fromOffset(celda.X, celda.Y)
		g.CellPadding = UDim2.fromOffset(espacio or 12, espacio or 12)
		g.SortOrder = Enum.SortOrder.LayoutOrder
		g.Parent = s
	else
		local l = Instance.new("UIListLayout")
		l.Padding = UDim.new(0, espacio or 10)
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Parent = s
	end
	return s
end

-- Panel para agrupar dentro de una ventana: el oscuro de siempre o, con `colores`, la baldosa
-- teñida de ese color.
function Ventanas.panel(ancho: number, alto: number, colores: { string }?): Frame
	local f = Instance.new("Frame")
	f.Name = "Panel"
	f.Size = UDim2.fromOffset(ancho, alto)
	if colores then
		Estilo.superficie(f, { "Baldosa" }, colores, 18, 5, true)
	else
		Estilo.superficie(f, { "Panel" }, Estilo.Colores.Oscuro, 18, 5, true)
	end
	return f
end

-- Borra lo que se dibujó adentro (menos layouts y rellenos) para volver a armarlo.
function Ventanas.vaciar(obj: Instance)
	for _, hijo in obj:GetChildren() do
		if hijo:IsA("GuiObject") then
			hijo:Destroy()
		end
	end
end

return Ventanas
