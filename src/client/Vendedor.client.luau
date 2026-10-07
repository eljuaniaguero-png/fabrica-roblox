--!strict
-- Menú del vendedor: te acercás, aparece "Hablar" y se abre un menú con "Vender pasos" y "Comprar".
-- El cliente solo muestra y pide; comprar y vender lo valida el servidor (Economia.luau).
--
-- En el mapa: Model con atributo Vendedor = true, con un Humanoid y un ProximityPrompt adentro.
-- MenuVendedor (ScreenGui) > Panel >
--   Encabezado > Nombre, Subtitulo, Monedas, Cerrar
--   Cuerpo > Opciones > Vender, Comprar (TextButton)
--            Vender > Saldo, Ganancia, Tasa, BotonVender, Nota
--            Comprar (ScrollingFrame) > Plantilla (Frame) > Nombre, Detalle, Boton
--   Pie > Volver (TextButton), Mensaje (TextLabel)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local menu = jugador:WaitForChild("PlayerGui"):WaitForChild("MenuVendedor")
local panel = menu:WaitForChild("Panel") :: Frame
local encabezado = panel:WaitForChild("Encabezado")
local subtitulo = encabezado:WaitForChild("Subtitulo") :: TextLabel
local etiquetaMonedas = encabezado:WaitForChild("Monedas") :: TextLabel
local botonCerrar = encabezado:WaitForChild("Cerrar") :: TextButton
local cuerpo = panel:WaitForChild("Cuerpo")
local opciones = cuerpo:WaitForChild("Opciones") :: Frame
local vistaVender = cuerpo:WaitForChild("Vender") :: Frame
local vistaComprar = cuerpo:WaitForChild("Comprar") :: ScrollingFrame
local plantilla = vistaComprar:WaitForChild("Plantilla") :: Frame
local pie = panel:WaitForChild("Pie")
local botonVolver = pie:WaitForChild("Volver") :: TextButton
local mensaje = pie:WaitForChild("Mensaje") :: TextLabel

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local remotoComprar = remotos:WaitForChild("Comprar") :: RemoteEvent
local remotoVender = remotos:WaitForChild("VenderPasos") :: RemoteEvent
local remotoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent

local ANIMACION_QUIETO = "rbxassetid://507766388" -- animación "idle" por defecto de Roblox
local COLOR_ALCANZA = Config.Paleta.Cian
local COLOR_NO_ALCANZA = Color3.fromRGB(55, 45, 95)

local vendedor: Model? = nil
local avisoHablar: ProximityPrompt? = nil
local filas: { [string]: Frame } = {}

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

local function pintarBoton(boton: TextButton, texto: string, habilitado: boolean)
	boton.Text = texto
	boton.BackgroundColor3 = if habilitado then COLOR_ALCANZA else COLOR_NO_ALCANZA
	boton.TextColor3 = if habilitado then Config.Paleta.Fondo else Color3.fromRGB(170, 160, 210)
end

local function actualizar()
	local monedas = atributoNumero("Monedas")
	etiquetaMonedas.Text = `{math.floor(monedas)} monedas`

	-- Vender pasos
	local disponibles = math.floor(atributoNumero("PasosDisponibles"))
	local ganancia = Precios.monedasPorPasos(disponibles)
	local saldo = vistaVender:FindFirstChild("Saldo")
	local ganado = vistaVender:FindFirstChild("Ganancia")
	local tasa = vistaVender:FindFirstChild("Tasa")
	local botonVender = vistaVender:FindFirstChild("BotonVender")
	if saldo and saldo:IsA("TextLabel") then
		saldo.Text = `Tenés {disponibles} pasos para vender`
	end
	if ganado and ganado:IsA("TextLabel") then
		ganado.Text = `+{ganancia} monedas`
	end
	if tasa and tasa:IsA("TextLabel") then
		tasa.Text = `{Config.PasosPorMoneda} pasos = 1 moneda`
	end
	if botonVender and botonVender:IsA("TextButton") then
		pintarBoton(botonVender, "VENDER TODO", ganancia > 0)
	end

	-- Comprar
	for articulo, fila in filas do
		local detalle = fila:FindFirstChild("Detalle") :: TextLabel
		local boton = fila:FindFirstChild("Boton") :: TextButton
		local mejora = Config.Mejoras[articulo]
		if mejora then
			local nivel = atributoNumero(`Mej_{articulo}`)
			local precio = Precios.mejora(articulo, nivel)
			detalle.Text = `{mejora.Descripcion} · nivel {nivel}`
			if precio then
				pintarBoton(boton, `{precio} monedas`, monedas >= precio)
			else
				pintarBoton(boton, "MÁXIMO", false)
			end
		else
			local consumible = Config.Consumibles[articulo]
			local cantidad = atributoNumero(`Inv_{articulo}`)
			detalle.Text = `{consumible.Descripcion} · tenés {cantidad}`
			local lleno = cantidad >= Config.InventarioMaximo
			pintarBoton(
				boton,
				if lleno then "LLENO" else `{consumible.Precio} monedas`,
				not lleno and monedas >= consumible.Precio
			)
		end
	end
end

local function mostrarVista(nombre: string)
	opciones.Visible = nombre == "Opciones"
	vistaVender.Visible = nombre == "Vender"
	vistaComprar.Visible = nombre == "Comprar"
	botonVolver.Visible = nombre ~= "Opciones"
	subtitulo.Text = if nombre == "Vender"
		then "Vender pasos"
		elseif nombre == "Comprar" then "Comprar"
		else "¿Qué hacemos?"
end

local function abrir()
	-- SONIDO: hablar con el vendedor (Config.Efectos.Hablar)
	Sonidos.efecto("Hablar")
	mensaje.Text = ""
	mostrarVista("Opciones")
	actualizar()
	panel.Visible = true
	if avisoHablar then
		avisoHablar.Enabled = false
	end
end

local function cerrar()
	panel.Visible = false
	if avisoHablar then
		avisoHablar.Enabled = true
	end
end

-- Filas de la tienda: una por mejora y una por consumible, copiadas de la plantilla.
local function armarFilas()
	local orden = 0
	local function agregar(articulo: string, nombre: string)
		orden += 1
		local fila = plantilla:Clone()
		fila.Name = articulo
		fila.LayoutOrder = orden
		fila.Visible = true
		local etiqueta = fila:FindFirstChild("Nombre")
		if etiqueta and etiqueta:IsA("TextLabel") then
			etiqueta.Text = string.upper(nombre)
		end
		local boton = fila:FindFirstChild("Boton")
		if boton and boton:IsA("TextButton") then
			boton.Activated:Connect(function()
				remotoComprar:FireServer(articulo)
			end)
		end
		fila.Parent = vistaComprar
		filas[articulo] = fila
	end
	for _, articulo in Config.OrdenMejoras do
		agregar(articulo, Config.Mejoras[articulo].Nombre)
	end
	for _, articulo in Config.OrdenConsumibles do
		agregar(articulo, Config.Consumibles[articulo].Nombre)
	end
end

armarFilas()
plantilla.Visible = false
panel.Visible = false
mostrarVista("Opciones")

local botonOpcionVender = opciones:WaitForChild("Vender") :: TextButton
local botonOpcionComprar = opciones:WaitForChild("Comprar") :: TextButton
botonOpcionVender.Activated:Connect(function()
	mostrarVista("Vender")
end)
botonOpcionComprar.Activated:Connect(function()
	mostrarVista("Comprar")
end)
botonVolver.Activated:Connect(function()
	mostrarVista("Opciones")
end)
botonCerrar.Activated:Connect(cerrar)
local botonVender = vistaVender:WaitForChild("BotonVender") :: TextButton
botonVender.Activated:Connect(function()
	remotoVender:FireServer()
end)

-- Lo que contesta el servidor (compra hecha, falta plata...) también se ve dentro del menú.
remotoAviso.OnClientEvent:Connect(function(texto: string)
	if panel.Visible then
		mensaje.Text = texto
	end
end)
jugador.AttributeChanged:Connect(function()
	if panel.Visible then
		actualizar()
	end
end)

-- Con streaming, el vendedor puede llegar e irse: se engancha cuando aparece.
local function prepararVendedor(modelo: Model)
	vendedor = modelo
	local humanoide = modelo:FindFirstChildOfClass("Humanoid")
	local animador = if humanoide then humanoide:FindFirstChildOfClass("Animator") else nil
	if animador then
		local animacion = Instance.new("Animation")
		animacion.AnimationId = ANIMACION_QUIETO
		local ok, pista = pcall(function()
			return animador:LoadAnimation(animacion)
		end)
		if ok and pista then
			pista.Looped = true
			pista:Play()
		end
	end
end

local function registrar(objeto: Instance)
	if objeto:IsA("Model") and objeto:GetAttribute("Vendedor") == true then
		prepararVendedor(objeto)
	elseif objeto:IsA("ProximityPrompt") and objeto ~= avisoHablar then
		local modelo = objeto:FindFirstAncestorWhichIsA("Model")
		if modelo and modelo:GetAttribute("Vendedor") == true then
			avisoHablar = objeto
			objeto.ObjectText = Config.NombreVendedor
			objeto.Triggered:Connect(abrir)
		end
	end
end

for _, objeto in workspace:GetDescendants() do
	registrar(objeto)
end
workspace.DescendantAdded:Connect(registrar)

-- Si te alejás (o el vendedor sale del streaming), el menú se cierra solo.
RunService.Heartbeat:Connect(function()
	if not panel.Visible then
		return
	end
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not vendedor or not vendedor.Parent or not raiz or not raiz:IsA("BasePart") then
		cerrar()
		return
	end
	if (raiz.Position - vendedor:GetPivot().Position).Magnitude > Config.DistanciaVendedor then
		cerrar()
	end
end)
