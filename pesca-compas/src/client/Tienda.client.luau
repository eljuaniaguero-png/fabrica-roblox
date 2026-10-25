--!strict
-- Panel de la casa "CEBO & CAÑAS" y el indicador del cebo puesto (debajo del panel de Escamas).
-- Se abre con el ProximityPrompt de la puerta (lo pone server/Tienda.luau) y se cierra solo
-- cuando el jugador se aleja (PromptHidden) o con la X. Solo pide: la compra la valida el server.

local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estilo = require(ReplicatedStorage.Shared:WaitForChild("Estilo"))
local Limpieza = require(ReplicatedStorage.Shared:WaitForChild("Limpieza"))
local ModeloEquipo = require(ReplicatedStorage.Shared:WaitForChild("ModeloEquipo"))
local Boton = require(script.Parent:WaitForChild("ui"):WaitForChild("Boton"))
local Tokens = require(script.Parent.ui:WaitForChild("Tokens"))
local VistaModelo = require(script.Parent.ui:WaitForChild("VistaModelo"))
local UI = Estilo.UI
local Remotos = ReplicatedStorage:WaitForChild("Remotos")

local TAG = "TiendaCebo"

local jugador = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TiendaGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = jugador:WaitForChild("PlayerGui")

local function etiqueta(padre: Instance, tam: UDim2, pos: UDim2, alineado: Enum.TextXAlignment?): TextLabel
	local t = Instance.new("TextLabel")
	t.Size = tam
	t.Position = pos
	t.BackgroundTransparency = 1
	t.Font = UI.Fuente
	t.TextScaled = true
	t.TextColor3 = UI.Texto
	t.TextXAlignment = alineado or Enum.TextXAlignment.Center
	Estilo.bordeTexto(t)
	t.Parent = padre
	return t
end

local function redondear(f: GuiObject)
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, UI.Esquina)
	esquina.Parent = f
end

---------------------------------------------------------------- indicador del cebo puesto
-- debajo del panel de Escamas del HUD (0.01, 0.02 + 0.12): a la vista mientras pesca
local indicador = Instance.new("Frame")
indicador.Size = UDim2.fromScale(0.22, 0.045)
indicador.Position = UDim2.new(0.01, 0, 0.14, Tokens.Separacion)
indicador.BackgroundColor3 = UI.PanelOscuro
indicador.BackgroundTransparency = 0.1
indicador.Visible = false
indicador.Parent = gui
redondear(indicador)
Estilo.borde(indicador)
-- el cebo puesto en 3D, quieto (no gira: está a la vista todo el tiempo mientras pesca)
local vistaIndicador = VistaModelo.nueva({
	Tam = UDim2.fromScale(1, 1),
	Pos = UDim2.fromScale(0.01, 0),
	Padre = indicador,
})
local ceboIndicador: string? = nil
local tIndicador = etiqueta(indicador, UDim2.fromScale(0.78, 0.8), UDim2.fromScale(0.18, 0.1), Enum.TextXAlignment.Left)

---------------------------------------------------------------- panel de la tienda
local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.56, 0.5)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.BackgroundColor3 = UI.PanelOscuro
panel.Visible = false
panel.Parent = gui
redondear(panel)
Estilo.borde(panel)
local tamPanel = Instance.new("UISizeConstraint")
tamPanel.MinSize = Vector2.new(420, 260)
tamPanel.Parent = panel
local escalaPanel = Instance.new("UIScale")
escalaPanel.Parent = panel

local tTitulo = etiqueta(panel, UDim2.fromScale(0.8, 0.12), UDim2.fromScale(0.1, 0.04))
tTitulo.Text = "CEBO & CAÑAS"
tTitulo.TextColor3 = UI.Perfecto
local tSub = etiqueta(panel, UDim2.fromScale(0.9, 0.07), UDim2.fromScale(0.05, 0.16))
tSub.Text = "El cebo no cambia la rareza: pican más rápido y más pesados"

local bCerrar = Boton.nuevo({
	Texto = "X",
	Color = UI.Error,
	Tam = UDim2.fromOffset(40, 40),
	Pos = UDim2.new(1, -Tokens.Margen, 0, Tokens.Margen),
	Ancla = Vector2.new(1, 0),
	Padre = panel,
})

-- ofertas con Robux encendidas (Id ~= 0 en Config): si no hay ninguna, la franja no existe
type Oferta = { Nombre: string, Id: number, EsPase: boolean, Clave: string }
local ofertas: { Oferta } = {}
for _, p in Config.Productos do
	if p.Id ~= 0 then
		table.insert(ofertas, { Nombre = p.Nombre, Id = p.Id, EsPase = false, Clave = "" })
	end
end
for clave, id in Config.Pases do
	if id ~= 0 then
		-- "CarreteDorado" -> "Carrete Dorado" (el precio sí sale del Dashboard, el nombre no)
		local nombre = clave:gsub("(%l)(%u)", "%1 %2")
		table.insert(ofertas, { Nombre = nombre, Id = id, EsPase = true, Clave = clave })
	end
end

local fila = Instance.new("Frame")
fila.Size = UDim2.fromScale(0.94, if #ofertas > 0 then Tokens.Robux.AltoTarjetasCon else Tokens.Robux.AltoTarjetasSin)
fila.Position = UDim2.fromScale(0.03, 0.27)
fila.BackgroundTransparency = 1
fila.Parent = panel
local lista = Instance.new("UIListLayout")
lista.FillDirection = Enum.FillDirection.Horizontal
lista.HorizontalAlignment = Enum.HorizontalAlignment.Center
lista.Padding = UDim.new(0, Tokens.Separacion * 2)
lista.SortOrder = Enum.SortOrder.LayoutOrder
lista.Parent = fila

local botones: { [string]: TextButton } = {}
local vistas: { VistaModelo.Vista } = {}
local escamas = 0
local ceboPuesto: string? = nil

for i, cebo in Config.Cebos do
	local tarjeta = Instance.new("Frame")
	tarjeta.LayoutOrder = i
	tarjeta.Size = UDim2.new(1 / #Config.Cebos, -Tokens.Separacion * 2, 1, 0)
	tarjeta.BackgroundColor3 = UI.Panel
	tarjeta.Parent = fila
	redondear(tarjeta)
	Estilo.borde(tarjeta)

	-- disco del color del cebo detrás del modelo 3D: así se lee el color aunque el modelo sea chico
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(0.34, 0.34)
	fondo.AnchorPoint = Vector2.new(0.5, 0)
	fondo.Position = UDim2.fromScale(0.5, 0.03)
	fondo.BackgroundColor3 = cebo.Color:Lerp(UI.Panel, 0.55)
	fondo.Parent = tarjeta
	local aspecto = Instance.new("UIAspectRatioConstraint")
	aspecto.Parent = fondo
	local redonda = Instance.new("UICorner")
	redonda.CornerRadius = UDim.new(0.5, 0)
	redonda.Parent = fondo
	Estilo.borde(fondo)

	local vista = VistaModelo.nueva({
		Tam = UDim2.fromScale(1.15, 1.15),
		Pos = UDim2.fromScale(0.5, 0.5),
		Ancla = Vector2.new(0.5, 0.5),
		Padre = fondo,
	})
	vista.poner(ModeloEquipo.cebo(cebo.Id))
	table.insert(vistas, vista)
	tarjeta.MouseEnter:Connect(function()
		vista.realzar(true)
	end)
	tarjeta.MouseLeave:Connect(function()
		vista.realzar(false)
	end)

	local tNombre = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.12), UDim2.fromScale(0.05, 0.38))
	tNombre.Text = cebo.Nombre
	tNombre.TextColor3 = cebo.Color
	local tDetalle = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.16), UDim2.fromScale(0.05, 0.51))
	tDetalle.Text = cebo.Detalle
	tDetalle.TextColor3 = UI.TextoOscuro
	tDetalle.TextWrapped = true
	local borde = tDetalle:FindFirstChildOfClass("UIStroke")
	if borde then
		borde.Enabled = false -- texto oscuro sobre panel claro: el contorno lo ensucia
	end
	local tTiradas = etiqueta(tarjeta, UDim2.fromScale(0.9, 0.09), UDim2.fromScale(0.05, 0.67))
	tTiradas.Text = ("%d tiradas"):format(cebo.Tiradas)
	tTiradas.TextColor3 = UI.TextoOscuro
	local bordeTiradas = tTiradas:FindFirstChildOfClass("UIStroke")
	if bordeTiradas then
		bordeTiradas.Enabled = false
	end

	local b = Boton.nuevo({
		Texto = ("%d 🐟"):format(cebo.Precio),
		Color = UI.BotonCana,
		Tam = UDim2.fromScale(0.84, 0.15),
		Pos = UDim2.fromScale(0.5, 0.95),
		Ancla = Vector2.new(0.5, 1),
		Padre = tarjeta,
	})
	b.Activated:Connect(function()
		Remotos.ComprarCebo:FireServer(cebo.Id)
	end)
	botones[cebo.Id] = b
end

---------------------------------------------------------------- ofertas con Robux
-- Franja al pie del panel. Solo abre el cartel de compra de Roblox: la entrega la hace
-- server/Monetizacion.luau (ProcessReceipt para productos, atributo "Pase_<clave>" para pases).
local botonesPase: { [string]: TextButton } = {}
local nombrePase: { [string]: string } = {}
local textoOferta: { [TextButton]: string } = {} -- texto base, para rearmarlo cuando llega el precio

local function textoConPrecio(o: Oferta, precio: number?): string
	if precio then
		return ("%s · %s %d"):format(o.Nombre, Tokens.Robux.Moneda, precio)
	end
	return ("%s · %s"):format(o.Nombre, Tokens.Robux.Moneda)
end

local function refrescarPases()
	for clave, b in botonesPase do
		local tiene = jugador:GetAttribute("Pase_" .. clave) == true
		b.Text = if tiene then ("%s · ¡YA ES TUYO!"):format(nombrePase[clave]) else textoOferta[b]
		Boton.habilitar(b, not tiene)
	end
end

if #ofertas > 0 then
	local franja = Instance.new("Frame")
	franja.Size = UDim2.fromScale(0.94, Tokens.Robux.Alto)
	franja.AnchorPoint = Vector2.new(0.5, 1)
	franja.Position = UDim2.new(0.5, 0, 1, -Tokens.Margen)
	franja.BackgroundTransparency = 1
	franja.Parent = panel
	local listaRobux = Instance.new("UIListLayout")
	listaRobux.FillDirection = Enum.FillDirection.Horizontal
	listaRobux.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listaRobux.VerticalAlignment = Enum.VerticalAlignment.Center
	listaRobux.Padding = UDim.new(0, Tokens.Separacion * 2)
	listaRobux.SortOrder = Enum.SortOrder.LayoutOrder
	listaRobux.Parent = franja

	for i, o in ofertas do
		local b = Boton.nuevo({
			Texto = textoConPrecio(o, nil),
			Color = if o.EsPase then UI.BotonPase else UI.BotonRobux,
			Tam = UDim2.new(1 / #ofertas, -Tokens.Separacion * 2, 1, 0),
			Pos = UDim2.new(),
			Padre = franja,
		})
		b.LayoutOrder = i
		textoOferta[b] = b.Text
		if o.EsPase then
			botonesPase[o.Clave] = b
			nombrePase[o.Clave] = o.Nombre
			jugador:GetAttributeChangedSignal("Pase_" .. o.Clave):Connect(refrescarPases)
		end
		b.Activated:Connect(function()
			if o.EsPase then
				if jugador:GetAttribute("Pase_" .. o.Clave) == true then
					return -- ya lo tiene: Roblox igual avisaría, pero no hace falta el cartel
				end
				MarketplaceService:PromptGamePassPurchase(jugador, o.Id)
			else
				MarketplaceService:PromptProductPurchase(jugador, o.Id)
			end
		end)
		-- precio real del Creator Dashboard (si falla, queda "R$" sin número)
		task.spawn(function()
			local tipo = if o.EsPase then Enum.InfoType.GamePass else Enum.InfoType.Product
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, o.Id, tipo)
			if ok and typeof(info) == "table" and b.Parent then
				local precio = if typeof(info.PriceInRobux) == "number" then info.PriceInRobux else nil
				textoOferta[b] = textoConPrecio(o, precio)
				b.Text = textoOferta[b]
				refrescarPases()
			end
		end)
	end
	refrescarPases()
end

local function refrescarBotones()
	for _, cebo in Config.Cebos do
		local b = botones[cebo.Id]
		if ceboPuesto == cebo.Id then
			b.Text = ("+%d · %d 🐟"):format(cebo.Tiradas, cebo.Precio)
		elseif ceboPuesto then
			b.Text = ("Cambiar · %d 🐟"):format(cebo.Precio)
		else
			b.Text = ("%d 🐟"):format(cebo.Precio)
		end
		Boton.habilitar(b, escamas >= cebo.Precio)
	end
end

---------------------------------------------------------------- abrir y cerrar
local animacion = Limpieza.nueva()
local abierto = false

local function cerrar()
	if not abierto then
		return
	end
	abierto = false
	animacion:limpiar()
	for _, v in vistas do
		v.girar(false)
		v.realzar(false)
	end
	panel.Visible = false
end

local function abrir()
	if abierto then
		return
	end
	abierto = true
	animacion:limpiar()
	refrescarBotones()
	for _, v in vistas do
		v.girar(true)
	end
	escalaPanel.Scale = 0.6
	panel.Visible = true
	local t = animacion:dar(TweenService:Create(escalaPanel, Tokens.Tween.Entrar, { Scale = 1 }))
	t:Play()
end

bCerrar.Activated:Connect(cerrar)

local function esDeLaTienda(prompt: ProximityPrompt): boolean
	local padre = prompt.Parent
	return padre ~= nil and CollectionService:HasTag(padre, TAG)
end

ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
	if esDeLaTienda(prompt) then
		abrir()
	end
end)
ProximityPromptService.PromptHidden:Connect(function(prompt: ProximityPrompt)
	if esDeLaTienda(prompt) then
		cerrar() -- se alejó de la puerta
	end
end)

---------------------------------------------------------------- estado
local function nombreDe(id: string): string
	for _, c in Config.Cebos do
		if c.Id == id then
			return c.Nombre
		end
	end
	return id
end

Remotos.Estado.OnClientEvent:Connect(function(e: any)
	escamas = if typeof(e.Escamas) == "number" then e.Escamas else 0
	ceboPuesto = if typeof(e.Cebo) == "string" then e.Cebo else nil
	if ceboPuesto then
		tIndicador.Text = ("%s x%d"):format(nombreDe(ceboPuesto), e.CeboTiradas or 0)
		if ceboIndicador ~= ceboPuesto then -- el Estado llega seguido: el modelo solo si cambió
			ceboIndicador = ceboPuesto
			vistaIndicador.poner(ModeloEquipo.cebo(ceboPuesto))
		end
		indicador.Visible = true
	else
		indicador.Visible = false
	end
	if abierto then
		refrescarBotones()
	end
end)
-- el HUD pide el estado al arrancar y el server acepta un pedido por segundo: si este script
-- conectó tarde se perdió esa respuesta (y el cebo puesto al volver a entrar). Se pide de nuevo.
task.delay(1.2, function()
	Remotos.Estado:FireServer()
end)
