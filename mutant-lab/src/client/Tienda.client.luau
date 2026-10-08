--!strict
-- Tienda del laboratorio: especies base (precio creciente) y mejoras.
-- Tienda (ScreenGui armado en Studio) > Ventana >
--   Encabezado > Titulo, ADN (TextLabel), Cerrar (TextButton)
--   Pestanas > Especies, Mejoras (TextButton)
--   Info (TextLabel)
--   PaginaEspecies (ScrollingFrame con UIGridLayout), PaginaMejoras (ScrollingFrame con UIListLayout)
--   PlantillaBase (Frame oculto) > Vista (ViewportFrame), Nombre, Tema (TextLabel), Boton (TextButton > Texto)
--   PlantillaMejora (Frame oculto) > Icono, Nombre, Descripcion, Nivel (TextLabel), Boton (TextButton > Texto)
-- Se abre con el mostrador de la tienda de tu laboratorio (Tienda > Mostrador > Prompt).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local MiLab = require(script.Parent.MiLab)
local Sonidos = require(script.Parent.Sonidos)
local Vista = require(script.Parent.Vista)

local E = Config.Estilo
local GRIS = Color3.fromHex("D9D2C5")
local ROJO = Color3.fromHex("E8254D")
local ICONOS = { Corrales = "🏡", Rapida = "⚡", Nutrientes = "🧪" }

local jugador = Players.LocalPlayer
local ventana =
	jugador:WaitForChild("PlayerGui"):WaitForChild("Tienda"):WaitForChild("Ventana") :: Frame
local encabezado = ventana:WaitForChild("Encabezado")
local etiquetaADN = encabezado:WaitForChild("ADN") :: TextLabel
local cerrar = encabezado:WaitForChild("Cerrar") :: TextButton
local pestanas = ventana:WaitForChild("Pestanas")
local pestanaEspecies = pestanas:WaitForChild("Especies") :: TextButton
local pestanaMejoras = pestanas:WaitForChild("Mejoras") :: TextButton
local info = ventana:WaitForChild("Info") :: TextLabel
local paginaEspecies = ventana:WaitForChild("PaginaEspecies") :: ScrollingFrame
local paginaMejoras = ventana:WaitForChild("PaginaMejoras") :: ScrollingFrame
local plantillaBase = ventana:WaitForChild("PlantillaBase") :: Frame
local plantillaMejora = ventana:WaitForChild("PlantillaMejora") :: Frame
local comprar = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Comprar") :: RemoteEvent

local function hijo(padre: Instance, nombre: string): any
	return padre:WaitForChild(nombre)
end

local function numero(atributo: string): number
	return (jugador:GetAttribute(atributo) :: number?) or 0
end

local function pintarBoton(boton: TextButton, texto: string, activo: boolean, colorTexto: Color3?)
	hijo(boton, "Texto").Text = texto
	hijo(boton, "Texto").TextColor3 = colorTexto or E.Violeta
	boton.BackgroundColor3 = if activo then E.Amarillo else GRIS
	boton.AutoButtonColor = activo
end

-- Una tarjeta por especie base, en el orden de la rueda.
local tarjetas: { Frame } = {}
for n, base in Especies do
	local t = plantillaBase:Clone()
	t.Name = "Base" .. n
	t.LayoutOrder = n
	t.Visible = true
	hijo(t, "Nombre").Text = base.Nombre
	hijo(t, "Tema").Text = n .. " · " .. base.Tema
	local boton = hijo(t, "Boton") :: TextButton
	boton.Activated:Connect(function()
		if boton.AutoButtonColor then
			-- SONIDO: comprar en la tienda (dos notas que suben)
			Sonidos.secuencia({ 7, 12 }, 0.08, 0.4)
			comprar:FireServer("Base", n)
		end
	end)
	t.Parent = paginaEspecies
	Vista.mostrar(hijo(t, "Vista"), tostring(n))
	tarjetas[n] = t
end

-- Una fila por mejora.
local filas: { [string]: Frame } = {}
for i, nombre in Mejoras.Orden do
	local def = (Config.Mejoras :: any)[nombre]
	local fila = plantillaMejora:Clone()
	fila.Name = nombre
	fila.LayoutOrder = i
	fila.Visible = true
	hijo(fila, "Icono").Text = ICONOS[nombre] or "⭐"
	hijo(fila, "Nombre").Text = def.Nombre
	local boton = hijo(fila, "Boton") :: TextButton
	boton.Activated:Connect(function()
		if boton.AutoButtonColor then
			-- SONIDO: comprar una mejora (tres notas que suben)
			Sonidos.secuencia({ 4, 7, 12 }, 0.07, 0.4)
			comprar:FireServer("Mejora", nombre)
		end
	end)
	fila.Parent = paginaMejoras
	filas[nombre] = fila
end

local function detalleMejora(nombre: string, nivel: number): string
	local def = (Config.Mejoras :: any)[nombre]
	if nombre == "Corrales" then
		return def.Descripcion
			.. ". Ahora trabajan "
			.. numero("Activas")
			.. " de "
			.. numero("Tope")
			.. "."
	elseif nombre == "Rapida" then
		return def.Descripcion
			.. ". Ahora dura el "
			.. math.round(Mejoras.factorRapidez(nivel) * 100)
			.. " %."
	end
	return def.Descripcion
		.. ". Ahora: +"
		.. math.round((Mejoras.multiplicadorADN(nivel) - 1) * 100)
		.. " %."
end

local function actualizar()
	local adn = numero("ADN")
	local tengo = Formato.conjunto(jugador:GetAttribute("Especies") :: string?)
	etiquetaADN.Text = Formato.numero(adn) .. " ADN"

	local cantidad = 0
	for n = 1, Config.TamanioRueda do
		if tengo[tostring(n)] then
			cantidad += 1
		end
	end
	local precio = Mejoras.precioBase(cantidad)
	info.Text = if precio
		then "La próxima especie cuesta "
			.. Formato.numero(precio)
			.. " ADN. Conviene una vecina de las tuyas en la rueda."
		else "¡Ya tenés las 10 especies base!"
	for n, t in tarjetas do
		local boton = hijo(t, "Boton") :: TextButton
		if tengo[tostring(n)] then
			pintarBoton(boton, "La tenés", false)
		elseif precio then
			pintarBoton(
				boton,
				Formato.numero(precio) .. " ADN",
				adn >= precio,
				if adn >= precio then E.Violeta else ROJO
			)
		end
	end

	for nombre, fila in filas do
		local nivel = numero("Mejora" .. nombre)
		local maximo = Mejoras.maximo(nombre)
		local precioMejora = Mejoras.precio(nombre, nivel)
		hijo(fila, "Nivel").Text = "Nivel " .. nivel .. " de " .. maximo
		hijo(fila, "Descripcion").Text = detalleMejora(nombre, nivel)
		local boton = hijo(fila, "Boton") :: TextButton
		if precioMejora then
			local alcanza = adn >= precioMejora
			pintarBoton(
				boton,
				Formato.numero(precioMejora) .. " ADN",
				alcanza,
				if alcanza then E.Violeta else ROJO
			)
		else
			pintarBoton(boton, "Máximo", false)
		end
	end
end

local function mostrarPagina(nombre: string)
	paginaEspecies.Visible = nombre == "Especies"
	paginaMejoras.Visible = nombre == "Mejoras"
	info.Visible = nombre == "Especies"
	pestanaEspecies.BackgroundColor3 = if nombre == "Especies" then E.Menta else Color3.new(1, 1, 1)
	pestanaMejoras.BackgroundColor3 = if nombre == "Mejoras" then E.Menta else Color3.new(1, 1, 1)
end

pestanaEspecies.Activated:Connect(function()
	mostrarPagina("Especies")
end)
pestanaMejoras.Activated:Connect(function()
	mostrarPagina("Mejoras")
end)
cerrar.Activated:Connect(function()
	ventana.Visible = false
end)

local prompt = MiLab.obtener()
	:WaitForChild("Tienda")
	:WaitForChild("Mostrador")
	:WaitForChild("Prompt") :: ProximityPrompt
prompt.Triggered:Connect(function()
	ventana.Visible = true
	actualizar()
end)

for _, atributo in
	{ "ADN", "Especies", "Activas", "Tope", "MejoraCorrales", "MejoraRapida", "MejoraNutrientes" }
do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		if ventana.Visible then
			actualizar()
		end
	end)
end
mostrarPagina("Especies")
actualizar()
