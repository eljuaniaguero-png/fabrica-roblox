--!strict
-- Pantallas del paso 5b, en graybox: la tienda (en la columna derecha, tapando al monstruo,
-- así el tablero queda libre para tocar clavijas) y los 2 lugares de pergaminos (a la
-- izquierda, debajo del oro). Solo dibuja y avisa qué se tocó: comprar, renovar, bajar y usar
-- lo hace Main.client con el servidor.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local TiendaModulo = require(Shared:WaitForChild("Tienda"))

export type Acciones = {
	comprar: (indice: number) -> (),
	renovar: () -> (),
	bajar: () -> (),
	usar: (lugar: number) -> (), -- pergamino
}

export type TiendaVista = {
	mostrar: (estado: Mazmorra.Estado) -> (),
	ocultar: () -> (),
	ponerPergaminos: (estado: Mazmorra.Estado) -> (),
}

local TiendaVista = {}

local function texto(padre: Instance, valor: string, fuente: Enum.Font?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = fuente or Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Text = valor
	t.Parent = padre
	return t
end

local function boton(padre: Instance, valor: string, hex: string): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Color3.fromHex(hex)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBlack
	b.TextScaled = true
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = valor
	b.Parent = padre
	local redondeo = Instance.new("UICorner")
	redondeo.CornerRadius = UDim.new(0.2, 0)
	redondeo.Parent = b
	return b
end

function TiendaVista.crear(acciones: Acciones): TiendaVista
	local gui = Instance.new("ScreenGui")
	gui.Name = "PantallaTienda"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.DisplayOrder = 8
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Pergaminos: 2 lugares a la izquierda, debajo del oro.
	local lugares = Instance.new("Frame")
	lugares.Name = "Pergaminos"
	lugares.Position = UDim2.fromOffset(12, 88)
	lugares.Size = UDim2.new(0.18, 0, 0, 44 * Config.LugaresPergamino + 6)
	lugares.BackgroundTransparency = 1
	lugares.Parent = gui
	local ordenLugares = Instance.new("UIListLayout")
	ordenLugares.Padding = UDim.new(0, 6)
	ordenLugares.Parent = lugares
	local botonesLugar: { TextButton } = {}
	for lugar = 1, Config.LugaresPergamino do
		local b = boton(lugares, "", Config.Colores.FondoBarra)
		b.Name = "Lugar" .. lugar
		b.Size = UDim2.new(1, 0, 0, 44)
		b.LayoutOrder = lugar
		b.Activated:Connect(function()
			acciones.usar(lugar)
		end)
		botonesLugar[lugar] = b
	end

	-- La tienda: columna derecha.
	local panel = Instance.new("Frame")
	panel.Name = "Tienda"
	panel.AnchorPoint = Vector2.new(1, 0.5)
	panel.Position = UDim2.new(1, -10, 0.5, 10)
	panel.Size = UDim2.fromScale(0.3, 0.84)
	panel.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	panel.BackgroundTransparency = 0.08
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = gui
	local redondeo = Instance.new("UICorner")
	redondeo.CornerRadius = UDim.new(0.04, 0)
	redondeo.Parent = panel
	local titulo = texto(panel, "Tienda")
	titulo.Position = UDim2.fromScale(0.05, 0.015)
	titulo.Size = UDim2.fromScale(0.9, 0.08)
	local ganado = texto(panel, "", Enum.Font.GothamBold)
	ganado.TextColor3 = Color3.fromHex(Config.Colores.Oro)
	ganado.Position = UDim2.fromScale(0.05, 0.1)
	ganado.Size = UDim2.fromScale(0.9, 0.05)

	local lista = Instance.new("Frame")
	lista.Position = UDim2.fromScale(0.04, 0.17)
	lista.Size = UDim2.fromScale(0.92, 0.55)
	lista.BackgroundTransparency = 1
	lista.Parent = panel
	local ordenLista = Instance.new("UIListLayout")
	ordenLista.Padding = UDim.new(0.025, 0)
	ordenLista.SortOrder = Enum.SortOrder.LayoutOrder
	ordenLista.Parent = lista

	local renovar = boton(panel, "", "#5A5A5A")
	renovar.Name = "Renovar"
	renovar.Position = UDim2.fromScale(0.04, 0.74)
	renovar.Size = UDim2.fromScale(0.55, 0.08)
	renovar.Activated:Connect(acciones.renovar)
	local info = boton(panel, "¿Qué sale?", "#3A3A3A")
	info.Name = "Info"
	info.Position = UDim2.fromScale(0.62, 0.74)
	info.Size = UDim2.fromScale(0.34, 0.08)
	local bajar = boton(panel, "Bajar", Config.Colores.VidaCaballero)
	bajar.Name = "Bajar"
	bajar.Position = UDim2.fromScale(0.04, 0.85)
	bajar.Size = UDim2.fromScale(0.92, 0.12)
	bajar.Activated:Connect(acciones.bajar)
	for _, b in { renovar, info, bajar } do
		local minimo = Instance.new("UISizeConstraint") -- 44 px o más para el dedo
		minimo.MinSize = Vector2.new(0, 44)
		minimo.Parent = b
	end

	-- "¿Qué sale?": las chances de todo lo que puede salir (sección 6 de la GUIA).
	local chances = Instance.new("TextButton")
	chances.Name = "Chances"
	chances.AnchorPoint = Vector2.new(0.5, 0.5)
	chances.Position = UDim2.fromScale(0.5, 0.5)
	chances.Size = UDim2.fromScale(0.5, 0.8)
	chances.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	chances.BorderSizePixel = 0
	chances.AutoButtonColor = false
	chances.Font = Enum.Font.GothamBold
	chances.TextScaled = true
	chances.TextColor3 = Color3.new(1, 1, 1)
	chances.TextXAlignment = Enum.TextXAlignment.Left
	chances.TextYAlignment = Enum.TextYAlignment.Top
	chances.Text = "Lo que puede salir en la tienda\n"
		.. table.concat(TiendaModulo.chances(), "\n")
		.. "\n\n(tocá para cerrar)"
	chances.Visible = false
	chances.ZIndex = 5
	chances.Parent = gui
	local margen = Instance.new("UIPadding")
	margen.PaddingLeft = UDim.new(0.04, 0)
	margen.PaddingTop = UDim.new(0.03, 0)
	margen.PaddingRight = UDim.new(0.04, 0)
	margen.PaddingBottom = UDim.new(0.03, 0)
	margen.Parent = chances
	info.Activated:Connect(function()
		chances.Visible = not chances.Visible
	end)
	chances.Activated:Connect(function()
		chances.Visible = false
	end)

	local function fila(e: Mazmorra.Estado, indice: number, item: Mazmorra.ItemTienda)
		local nombre, frase, hex = TiendaModulo.describir(item.Clase, item.Id, e)
		local b = Instance.new("TextButton")
		b.Name = "Item" .. indice
		b.LayoutOrder = indice
		b.Size = UDim2.fromScale(1, 0.3)
		b.BackgroundColor3 = Color3.fromHex(Config.Colores.Carta)
		b.BorderSizePixel = 0
		b.AutoButtonColor = not item.Vendido
		b.Text = ""
		b.Parent = lista
		local esquinas = Instance.new("UICorner")
		esquinas.CornerRadius = UDim.new(0.12, 0)
		esquinas.Parent = b
		local franja = Instance.new("Frame")
		franja.Size = UDim2.fromScale(0.05, 1)
		franja.BackgroundColor3 = Color3.fromHex(hex)
		franja.BorderSizePixel = 0
		franja.Parent = b
		local tNombre = texto(b, nombre)
		tNombre.TextXAlignment = Enum.TextXAlignment.Left
		tNombre.Position = UDim2.fromScale(0.09, 0.06)
		tNombre.Size = UDim2.fromScale(0.62, 0.38)
		local tFrase = texto(b, frase, Enum.Font.GothamBold)
		tFrase.TextXAlignment = Enum.TextXAlignment.Left
		tFrase.TextWrapped = true
		tFrase.Position = UDim2.fromScale(0.09, 0.48)
		tFrase.Size = UDim2.fromScale(0.88, 0.46)
		local tPrecio = texto(b, if item.Vendido then "Vendido" else ("%d oro"):format(item.Precio))
		tPrecio.TextColor3 = if item.Vendido
			then Color3.fromRGB(150, 150, 150)
			elseif e.Oro >= item.Precio then Color3.fromHex(Config.Colores.Oro)
			else Color3.fromHex(Config.Colores.Golpe)
		tPrecio.Position = UDim2.fromScale(0.72, 0.06)
		tPrecio.Size = UDim2.fromScale(0.25, 0.38)
		if item.Vendido then
			b.BackgroundTransparency = 0.6
		else
			b.Activated:Connect(function()
				acciones.comprar(indice)
			end)
		end
	end

	local function ponerPergaminos(e: Mazmorra.Estado)
		for lugar, b in botonesLugar do
			local id = e.Pergaminos[lugar]
			if id then
				local nombre, _, hex = TiendaModulo.describir("pergamino", id, e)
				b.Text = nombre
				b.TextColor3 = Color3.new(1, 1, 1)
				b.BackgroundColor3 = Color3.fromHex(hex)
				b.BackgroundTransparency = 0.15
			else
				b.Text = "Pergamino: libre"
				b.TextColor3 = Color3.fromRGB(140, 140, 140)
				b.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
				b.BackgroundTransparency = 0.4
			end
		end
	end

	return {
		mostrar = function(e: Mazmorra.Estado)
			for _, hijo in lista:GetChildren() do
				if hijo:IsA("GuiButton") then
					hijo:Destroy()
				end
			end
			for indice, item in e.Tienda.Items do
				fila(e, indice, item)
			end
			local o = e.UltimoOro
			local partes = { ("+%d por ganar"):format(o.Pelea) }
			if o.Bonus > 0 then
				table.insert(partes, ("+%d rápido"):format(o.Bonus))
			end
			if o.Interes > 0 then
				table.insert(partes, ("+%d interés"):format(o.Interes))
			end
			ganado.Text = ("Oro %d  (%s)"):format(e.Oro, table.concat(partes, ", "))
			local precio = TiendaModulo.precioRenovar(e)
			renovar.Text = ("Renovar · %d"):format(precio)
			renovar.TextColor3 = if e.Oro >= precio
				then Color3.new(1, 1, 1)
				else Color3.fromHex(Config.Colores.Golpe)
			panel.Visible = true
			ponerPergaminos(e)
		end,
		ocultar = function()
			panel.Visible = false
			chances.Visible = false
		end,
		ponerPergaminos = ponerPergaminos,
	}
end

return TiendaVista
