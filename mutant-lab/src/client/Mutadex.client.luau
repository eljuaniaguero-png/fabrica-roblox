--!strict
-- La Mutadex: las 50 especies. Las descubiertas se ven completas; las otras, como silueta
-- negra con "?". Tocar una tarjeta muestra su ficha a la derecha; las siluetas venden pistas.
-- Mutadex (ScreenGui armado en Studio) > Ventana >
--   Encabezado > Titulo, Contador, ADN (TextLabel), Barra > Relleno, Cerrar (TextButton)
--   Lista (ScrollingFrame) > Gen1, Gen2, Gen3 (Frame) > Titulo, Nota, Grilla (Frame con UIGridLayout)
--   Ficha > Vista (ViewportFrame), Pregunta, Nombre, Gen, Detalle (TextLabel), Ayuda (TextLabel),
--           BotonPista (TextButton > Texto, Costo)
--   Plantilla (TextButton oculto) > Vista, Pregunta, Nombre, Gen, Estrella, Borde (UIStroke)
-- Se abre con el progreso o el botón Mutadex del HUD (puente temporal en UI/Menus.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Pistas = require(ReplicatedStorage.Shared.Pistas)
local Sonidos = require(script.Parent.Sonidos)
local Menus = require(script.Parent.UI.Menus)
local Vista = require(script.Parent.Vista)

local E = Config.Estilo
local BLANCO = Color3.new(1, 1, 1)
local LILA = Color3.fromHex("E6DDFF") -- fondo de las siluetas
local GRIS = Color3.fromHex("D9D2C5")
local ROJO = Color3.fromHex("E8254D")

local jugador = Players.LocalPlayer
local gui = jugador:WaitForChild("PlayerGui")
local ventana = gui:WaitForChild("Mutadex"):WaitForChild("Ventana") :: Frame
local encabezado = ventana:WaitForChild("Encabezado") :: Frame
local contador = encabezado:WaitForChild("Contador") :: TextLabel
local etiquetaADN = encabezado:WaitForChild("ADN") :: TextLabel
local rellenoBarra = encabezado:WaitForChild("Barra"):WaitForChild("Relleno") :: Frame
local cerrar = encabezado:WaitForChild("Cerrar") :: TextButton
local lista = ventana:WaitForChild("Lista") :: ScrollingFrame
local plantilla = ventana:WaitForChild("Plantilla") :: TextButton
local ficha = ventana:WaitForChild("Ficha") :: Frame
local fichaVista = ficha:WaitForChild("Vista") :: ViewportFrame
local fichaPregunta = ficha:WaitForChild("Pregunta") :: TextLabel
local fichaNombre = ficha:WaitForChild("Nombre") :: TextLabel
local fichaGen = ficha:WaitForChild("Gen") :: TextLabel
local fichaDetalle = ficha:WaitForChild("Detalle") :: TextLabel
local fichaAyuda = ficha:WaitForChild("Ayuda") :: TextLabel
local botonPista = ficha:WaitForChild("BotonPista") :: TextButton
local textoPista = botonPista:WaitForChild("Texto") :: TextLabel
local costoPista = botonPista:WaitForChild("Costo") :: TextLabel
local comprarPista =
	ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("ComprarPista") :: RemoteEvent

local TODAS = Fusion.todas()
local tarjetas: { [string]: TextButton } = {}
local seleccionada: string? = nil

type Estado = {
	Tengo: { [string]: boolean },
	Mutantes: { [string]: boolean },
	Pistas: { [string]: number },
	Compradas: number,
	ADN: number,
}

local function estado(): Estado
	return {
		Tengo = Formato.conjunto(jugador:GetAttribute("Especies") :: string?),
		Mutantes = Formato.conjunto(jugador:GetAttribute("Mutantes") :: string?),
		Pistas = Pistas.leer(jugador:GetAttribute("Pistas") :: string?),
		Compradas = (jugador:GetAttribute("PistasCompradas") :: number?) or 0,
		ADN = (jugador:GetAttribute("ADN") :: number?) or 0,
	}
end

local function hijo<T>(padre: Instance, nombre: string): T
	return padre:WaitForChild(nombre) :: any
end

-- Con qué bases se arma, en palabras.
local function receta(c: Fusion.Criatura): string
	local nombres = {}
	for _, b in c.Bases do
		table.insert(nombres, Especies[b].Nombre)
	end
	if c.Gen == 1 then
		return "Especie base de la rueda.\nTema: " .. Especies[c.Bases[1]].Tema .. "."
	elseif c.Gen == 2 then
		return "Se hace con:\n" .. nombres[1] .. " + " .. nombres[2]
	end
	return "Mezcla de:\n" .. nombres[1] .. ", " .. nombres[2] .. " y " .. nombres[3]
end

local function pintarTarjeta(t: TextButton, c: Fusion.Criatura, e: Estado)
	local descubierta = e.Tengo[c.Clave] == true
	local mutante = e.Mutantes[c.Clave] == true
	local marca = (if descubierta then "D" else "S") .. (if mutante then "M" else "")
	-- La vista 3D se rearma solo si cambió (es lo más pesado).
	if t:GetAttribute("Estado") ~= marca then
		Vista.mostrar(hijo(t, "Vista"), c.Clave, mutante, not descubierta)
		t:SetAttribute("Estado", marca)
	end
	local n = e.Pistas[c.Clave] or 0
	hijo(t, "Nombre").Text = if descubierta then c.Nombre else "???"
	hijo(t, "Pregunta").Visible = not descubierta
	hijo(t, "Estrella").Visible = mutante
	hijo(t, "Gen").Text = string.rep("●", c.Gen)
		.. (if not descubierta and n > 0 then "  🔍" .. n else "")
	t.BackgroundColor3 = if descubierta then BLANCO else LILA
	local borde: UIStroke = hijo(t, "Borde")
	if seleccionada == c.Clave then
		borde.Color, borde.Thickness = E.Rosa, 4
	else
		borde.Color, borde.Thickness = E.Violeta, 2
	end
end

local function actualizarFicha(e: Estado)
	local c = if seleccionada then Fusion.porClave(seleccionada) else nil
	local hay = c ~= nil
	fichaAyuda.Visible = not hay
	for _, x in { fichaVista, fichaNombre, fichaGen, fichaDetalle } :: { GuiObject } do
		x.Visible = hay
	end
	if not c then
		fichaPregunta.Visible = false
		botonPista.Visible = false
		Vista.mostrar(fichaVista, nil)
		return
	end
	local descubierta = e.Tengo[c.Clave] == true
	local mutante = e.Mutantes[c.Clave] == true
	Vista.mostrar(fichaVista, c.Clave, mutante, not descubierta)
	fichaPregunta.Visible = not descubierta
	fichaGen.Text = string.rep("●", c.Gen) .. "  Generación " .. c.Gen

	if descubierta then
		fichaNombre.Text = (if mutante then "⭐ " else "") .. c.Nombre
		fichaDetalle.Text = receta(c) .. (if mutante then "\n⭐ ¡La tenés mutante!" else "")
		botonPista.Visible = false
		return
	end

	fichaNombre.Text = "???"
	if c.Gen == 1 then
		fichaDetalle.Text = "Todavía no la tenés.\nLas especies base se compran con ADN."
		botonPista.Visible = false
		return
	end
	local n = e.Pistas[c.Clave] or 0
	local maximo = Pistas.maximo(c)
	local lineas = {}
	for i = 1, n do
		table.insert(lineas, "🔍 " .. Pistas.texto(c, i))
	end
	if n == 0 then
		table.insert(
			lineas,
			"Todavía no la descubriste.\nMirá la forma de la silueta o comprá una pista."
		)
	end
	fichaDetalle.Text = table.concat(lineas, "\n")
	botonPista.Visible = true
	if n >= maximo then
		textoPista.Text = "Sin más pistas"
		costoPista.Text = n .. " de " .. maximo
		costoPista.TextColor3 = E.Violeta
		botonPista.BackgroundColor3 = GRIS
		botonPista.AutoButtonColor = false
	else
		local costo = Pistas.costo(e.Compradas)
		textoPista.Text = "🔍 Comprar pista " .. (n + 1) .. " de " .. maximo
		costoPista.Text = Formato.numero(costo) .. " ADN"
		costoPista.TextColor3 = if e.ADN >= costo then E.Violeta else ROJO
		botonPista.BackgroundColor3 = if e.ADN >= costo then E.Amarillo else GRIS
		botonPista.AutoButtonColor = e.ADN >= costo
	end
end

local function actualizarTodo()
	local e = estado()
	local n = 0
	for _, c in TODAS do
		if e.Tengo[c.Clave] then
			n += 1
		end
		local t = tarjetas[c.Clave]
		if t then
			pintarTarjeta(t, c, e)
		end
	end
	contador.Text = n .. " / " .. #TODAS
	etiquetaADN.Text = Formato.numero(e.ADN) .. " ADN"
	rellenoBarra.Size = UDim2.fromScale(n / #TODAS, 1)
	actualizarFicha(e)
end

local function elegir(clave: string)
	-- SONIDO: tocar una tarjeta de la Mutadex (nota corta)
	Sonidos.nota(9, 0.3)
	seleccionada = clave
	actualizarTodo()
end

-- Una tarjeta por especie, en la grilla de su generación y en el orden de la rueda.
for orden, c in TODAS do
	local t = plantilla:Clone()
	t.Name = c.Clave
	t.LayoutOrder = orden
	t.Visible = true
	t.Activated:Connect(function()
		elegir(c.Clave)
	end)
	t.Parent = lista:WaitForChild("Gen" .. c.Gen):WaitForChild("Grilla")
	tarjetas[c.Clave] = t
end

botonPista.Activated:Connect(function()
	if seleccionada and botonPista.AutoButtonColor then
		-- SONIDO: comprar una pista (dos notas que suben)
		Sonidos.secuencia({ 4, 11 }, 0.08, 0.35)
		comprarPista:FireServer(seleccionada)
	end
end)

Menus.puenteViejo("Mutadex", ventana, function()
	-- Si estaba abierto el panel de la máquina, se cierra para no tapar.
	local panelFusion = gui:FindFirstChild("Fusion")
	local panel = panelFusion and panelFusion:FindFirstChild("Panel")
	if panel and panel:IsA("GuiObject") then
		panel.Visible = false
	end
	actualizarTodo()
end)

cerrar.Activated:Connect(function()
	ventana.Visible = false
end)

for _, atributo in { "Especies", "Mutantes", "Pistas", "PistasCompradas", "ADN" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		if ventana.Visible then
			actualizarTodo()
		end
	end)
end
actualizarTodo()
