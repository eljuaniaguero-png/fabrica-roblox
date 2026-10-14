--!strict
-- HUD de Forja Rápida (diseño de Figma v2, piezas de ForgeGUI):
--   Arriba a la derecha: Monedas, Suerte y Fuerza en píldoras (saltan cuando cambian), y los
--   botones "Vender todo" y Ajustes.
--   A la izquierda: botones grandes de los menús (Tienda, Mochila, Índice, Vitrina, Ranking y
--   Eventos) con globitos de aviso. En celular van arriba, para no tapar el joystick.
--   Abajo al centro: barra "Próxima zona" (tu Fuerza contra la que pide la zona siguiente).
-- Arma también las ventanas de los menús (Menu*.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Avisos = require(script.Parent.Avisos)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)
local Ventanas = require(script.Parent.Ventanas)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Vender = remotos:WaitForChild("Vender") :: RemoteEvent
local Compra = remotos:WaitForChild("Compra") :: RemoteEvent
local estado = ReplicatedStorage:WaitForChild("EstadoMundo")

-- Las ventanas de los menús.
for _, nombre in
	{
		"MenuTienda",
		"MenuMochila",
		"MenuIndice",
		"MenuEventos",
		"MenuVitrina",
		"MenuClasificacion",
		"MenuAjustes",
	}
do
	local modulo =
		require(script.Parent:WaitForChild(nombre) :: ModuleScript) :: { crear: () -> () }
	modulo.crear()
end

local pantalla = Estilo.pantalla("Hud", 4)
pantalla.IgnoreGuiInset = false
pantalla.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
pantalla.Parent = jugador:WaitForChild("PlayerGui")

local celular = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function saltar(obj: GuiObject)
	local escala = obj:FindFirstChild("Salto") :: UIScale?
	if not escala then
		local nueva = Instance.new("UIScale")
		nueva.Name = "Salto"
		nueva.Parent = obj
		escala = nueva
	end
	local s = escala :: UIScale
	s.Scale = 1.18
	TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- Arriba a la derecha: recursos ------------------------------------------------------------

local derecha = Instance.new("Frame")
derecha.Name = "Recursos"
derecha.AnchorPoint = Vector2.new(1, 0)
derecha.Position = UDim2.new(1, -16, 0, 12)
derecha.AutomaticSize = Enum.AutomaticSize.XY
derecha.BackgroundTransparency = 1
local listaDer = Instance.new("UIListLayout")
listaDer.HorizontalAlignment = Enum.HorizontalAlignment.Right
listaDer.Padding = UDim.new(0, 10)
listaDer.SortOrder = Enum.SortOrder.LayoutOrder
listaDer.Parent = derecha
Estilo.escalar(derecha)
derecha.Parent = pantalla

local pMonedas, tMonedas = Estilo.pildora("Moneda", Estilo.Colores.Amarillo, 250, 60)
pMonedas.LayoutOrder = 1
pMonedas.Parent = derecha
local pSuerte, tSuerte = Estilo.pildora("Trebol", Estilo.Colores.Verde, 210, 52)
pSuerte.LayoutOrder = 2
pSuerte.Parent = derecha
local pFuerza, tFuerza = Estilo.pildora("Fuerza", Estilo.Colores.Rojo, 210, 52)
pFuerza.LayoutOrder = 3
pFuerza.Parent = derecha

local filaBotones = Estilo.fila(10)
filaBotones.LayoutOrder = 4
filaBotones.Parent = derecha
local vender = Estilo.boton({
	Texto = "Vender todo",
	Icono = "Banco",
	Color = "Amarillo",
	Ancho = 200,
	Alto = 58,
	TamanoTexto = 22,
})
vender.LayoutOrder = 1
vender.Parent = filaBotones
vender.Activated:Connect(function()
	Vender:FireServer()
end)
local ajustes = Estilo.boton({ Icono = "Engranaje", Color = "Azul", Ancho = 58, Alto = 58 })
ajustes.LayoutOrder = 2
ajustes.Parent = filaBotones
ajustes.Activated:Connect(function()
	Ventanas.alternar("Ajustes")
end)

local anteriores = { Monedas = -1, Suerte = -1, Fuerza = -1 }
local function recursos()
	local m, s, f = Datos.numero("Monedas"), Datos.numero("Suerte"), Datos.numero("Fuerza")
	tMonedas.Text = Formato.corto(m)
	tSuerte.Text = Formato.suerte(math.max(1, s))
	tFuerza.Text = Formato.corto(f)
	if anteriores.Monedas >= 0 and m > anteriores.Monedas then
		saltar(pMonedas)
	end
	if anteriores.Suerte >= 0 and s > anteriores.Suerte then
		saltar(pSuerte)
	end
	if anteriores.Fuerza >= 0 and f > anteriores.Fuerza then
		saltar(pFuerza)
	end
	anteriores.Monedas, anteriores.Suerte, anteriores.Fuerza = m, s, f
end
recursos()
Datos.alCambiar({ "Monedas", "Suerte", "Fuerza" }, recursos)

-- A la izquierda: menús ----------------------------------------------------------------------

local izquierda = Instance.new("Frame")
izquierda.Name = "Menus"
izquierda.BackgroundTransparency = 1
izquierda.Size = UDim2.fromOffset(2 * 96 + 12, 3 * 96 + 2 * 12)
if celular then
	izquierda.AnchorPoint = Vector2.new(0, 0)
	izquierda.Position = UDim2.fromOffset(12, 8)
else
	izquierda.AnchorPoint = Vector2.new(0, 0.5)
	izquierda.Position = UDim2.new(0, 16, 0.45, 0)
end
local grilla = Instance.new("UIGridLayout")
grilla.CellSize = UDim2.fromOffset(96, 96)
grilla.CellPadding = UDim2.fromOffset(12, 12)
grilla.SortOrder = Enum.SortOrder.LayoutOrder
grilla.Parent = izquierda
Estilo.escalar(izquierda, if celular then 0.9 else 1)
izquierda.Parent = pantalla

type Boton = { Boton: TextButton, Globito: Frame }
local botones: { [string]: Boton } = {}

local function botonMenu(
	orden: number,
	id: string,
	texto: string,
	icono: string,
	color: string
): Boton
	local b = Instance.new("TextButton")
	b.Name = id
	b.Text = ""
	b.AutoButtonColor = false
	b.LayoutOrder = orden
	Estilo.superficie(b, { "Boton" .. color, "BotonBlanco" }, Estilo.Colores[color], 24, 5)
	local c = Estilo.contenido(b, -4, true)
	local ic = Estilo.icono(icono, 60)
	ic.LayoutOrder = 1
	ic.Parent = c
	local t = Estilo.texto(texto, 20)
	t.LayoutOrder = 2
	t.Parent = c
	local g = Estilo.globito("!", 34)
	g.Position = UDim2.new(1, -6, 0, 6)
	g.Visible = false
	g.Parent = b
	Estilo.presionable(b)
	b.Activated:Connect(function()
		Ventanas.alternar(id)
	end)
	b.Parent = izquierda
	local r = { Boton = b, Globito = g }
	botones[id] = r
	return r
end

botonMenu(1, "Tienda", "Tienda", "Tienda", "Verde")
botonMenu(2, "Mochila", "Mochila", "Mochila", "Naranja")
botonMenu(3, "Indice", "Índice", "Libro", "Rosa")
botonMenu(4, "Vitrina", "Vitrina", "Corona", "Violeta")
botonMenu(5, "Clasificacion", "Ranking", "Trofeo", "Amarillo")
botonMenu(6, "Eventos", "Eventos", "Reloj", "Azul")

local function globito(id: string, texto: string?)
	local g = botones[id].Globito
	local antes = g.Visible
	g.Visible = texto ~= nil
	if texto then
		(g:FindFirstChild("Texto") :: TextLabel).Text = texto
		if not antes then
			saltar(g)
		end
	end
end

-- Mochila: cuántas gemas tenés sin vender.
local function avisoMochila()
	local total = 0
	for _, n in Datos.mochila() do
		total += n
	end
	globito("Mochila", if total > 0 then Formato.corto(total) else nil)
	Estilo.colorBoton(vender, if total > 0 then "Amarillo" else "Gris")
end
avisoMochila()
Datos.alCambiar({ "Mochila" }, avisoMochila)

-- Tienda: "!" si alcanza para algo (un nivel de Fuerza, el próximo pico o amuleto).
local function avisoTienda()
	local m = Datos.numero("Monedas")
	local precio = Reglas.precioFuerza(Datos.numero("NivelFuerza"))
	local pico = Reglas.siguientePico(math.max(1, Datos.numero("Pico")))
	local amuleto = Reglas.siguienteAmuleto(Datos.conjunto("Amuletos"))
	local alcanza = (precio ~= nil and m >= precio)
		or (pico ~= nil and m >= pico.Precio)
		or (amuleto ~= nil and m >= amuleto.Precio)
	globito("Tienda", if alcanza then "!" else nil)
end
avisoTienda()
Datos.alCambiar({ "Monedas", "NivelFuerza", "Pico", "Amuletos" }, avisoTienda)

-- Índice: "!" cuando encontrás una gema nueva, hasta que lo abrís.
local vistas = #Datos.texto("Indice")
Datos.alCambiar({ "Indice" }, function()
	if #Datos.texto("Indice") > vistas and Ventanas.abierta() ~= "Indice" then
		globito("Indice", "!")
	end
end)

-- Eventos: "!" mientras hay uno.
local function avisoEvento()
	local ev = estado:GetAttribute("Evento")
	globito("Eventos", if ev and ev ~= "" then "!" else nil)
end
avisoEvento()
estado:GetAttributeChangedSignal("Evento"):Connect(avisoEvento)

-- El botón del menú abierto se marca con borde blanco.
Ventanas.alCambiar(function(id: string?)
	for nombre, b in botones do
		local borde = b.Boton:FindFirstChildOfClass("UIStroke")
		if borde then
			borde.Color = if nombre == id then Color3.new(1, 1, 1) else Estilo.Oscuro
		end
	end
	if id == "Indice" then
		vistas = #Datos.texto("Indice")
		globito("Indice", nil)
	end
end)

-- Abajo al centro: próxima zona ------------------------------------------------------------

local abajo = Estilo.fila(10)
abajo.Name = "ProximaZona"
abajo.AnchorPoint = Vector2.new(0.5, 1)
abajo.Position = UDim2.new(0.5, 0, 1, -16)
Estilo.escalar(abajo)
abajo.Parent = pantalla
local icZona = Estilo.icono("Fuerza", 52)
icZona.LayoutOrder = 1
icZona.Parent = abajo
local barraZona, ponerZona = Estilo.barra(460, 44, { "#FF8A94", "#D62839" })
barraZona.LayoutOrder = 2
barraZona.Parent = abajo
local nombreZona = Estilo.texto("", 24)
nombreZona.LayoutOrder = 3
nombreZona.Parent = abajo

local function zona()
	local z = Reglas.proximaZona(Datos.zonas())
	abajo.Visible = z ~= nil
	if not z then
		return
	end
	local f = Datos.numero("Fuerza")
	ponerZona(
		f / math.max(1, z.FuerzaParaAbrir),
		("%s / %s de Fuerza"):format(Formato.corto(f), Formato.corto(z.FuerzaParaAbrir))
	)
	nombreZona.Text = z.Nombre
	nombreZona.TextColor3 = Color3.fromHex(z.ColorCristal)
end
zona()
Datos.alCambiar({ "Fuerza", "Zonas" }, zona)

-- Compras: sonido, salto de la píldora y cartel para lo grande ------------------------------

Compra.OnClientEvent:Connect(function(tipo: unknown, texto: unknown)
	if typeof(tipo) ~= "string" then
		return
	end
	local detalle = if typeof(texto) == "string" then texto else ""
	if tipo == "Vender" then
		-- SONIDO: vender en el Banco
		Sonidos.tocar(GameConfig.Sonidos.Vender)
		saltar(pMonedas)
		return
	end
	-- SONIDO: comprar en la Tienda
	Sonidos.tocar(GameConfig.Sonidos.Comprar)
	if tipo == "Fuerza" then
		saltar(pFuerza)
	elseif tipo == "Pico" then
		saltar(pFuerza)
		Avisos.mostrar({
			Titulo = "¡Pico nuevo!",
			Texto = detalle,
			Color = Color3.fromHex("#6CCBFF"),
			Duracion = 2.5,
			Icono = "Pico",
		})
	elseif tipo == "Amuleto" then
		saltar(pSuerte)
		Avisos.mostrar({
			Titulo = "¡Amuleto nuevo!",
			Texto = detalle,
			Color = Color3.fromHex("#8CFF5A"),
			Duracion = 2.5,
			Icono = "Amuleto",
		})
	end
end)
