--!strict
-- HUD de Forja Rápida (diseño de Figma v2, piezas de ForgeGUI):
--   Abajo a la izquierda (en celular, arriba a la derecha): Fuerza, Suerte y Monedas en números
--   grandes con contorno (saltan cuando cambian). Arriba a la derecha: "Vender todo" y Ajustes.
--   Arriba al centro: el nombre de la zona donde estás.
--   A la izquierda: botones anchos de los menús (ícono y nombre al costado) con globitos de
--   aviso, en 2 columnas.
--   En celular van arriba, para no tapar el joystick.
--   A la derecha, abajo de los recursos (Grupo 4): el seguimiento de las misiones (en celular,
--   solo la que está más cerca de cumplirse). Tocarlo abre el menú.
--   Abajo al centro: barra "Próxima zona" (tu Fuerza contra la que pide la zona siguiente).
-- Arma también las ventanas de los menús (Menu*.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Avisos = require(script.Parent.Avisos)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local MenuMisiones = require(script.Parent.MenuMisiones)
local Sonidos = require(script.Parent.Sonidos)
local Ventanas = require(script.Parent.Ventanas)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Vender = remotos:WaitForChild("Vender") :: RemoteEvent
local Compra = remotos:WaitForChild("Compra") :: RemoteEvent
local MisionRemoto = remotos:WaitForChild("Mision") :: RemoteEvent
local RenacerRemoto = remotos:WaitForChild("Renacer") :: RemoteEvent
local estado = ReplicatedStorage:WaitForChild("EstadoMundo")

-- Las ventanas de los menús.
for _, nombre in
	{
		"MenuTienda",
		"MenuMochila",
		"MenuMuseo",
		"MenuEventos",
		"MenuVitrina",
		"MenuClasificacion",
		"MenuAjustes",
		"MenuMisiones",
		"MenuMascotas",
		"MenuRenacer",
		"MenuViajar",
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

-- Monedas, Suerte y Fuerza: números grandes con contorno negro y su ícono, sin fondo (como las
-- referencias de arte/referencias). En compu, abajo a la izquierda; en celular, arriba a la
-- derecha (abajo a la izquierda está el joystick).
local contadores = Instance.new("Frame")
contadores.Name = "Contadores"
contadores.AutomaticSize = Enum.AutomaticSize.XY
contadores.BackgroundTransparency = 1
local listaCont = Instance.new("UIListLayout")
listaCont.SortOrder = Enum.SortOrder.LayoutOrder
listaCont.Padding = UDim.new(0, 2)
listaCont.Parent = contadores
if celular then
	contadores.AnchorPoint = Vector2.new(1, 0)
	contadores.Position = UDim2.new(1, -16, 0, 12)
	listaCont.HorizontalAlignment = Enum.HorizontalAlignment.Right
	derecha.Position = UDim2.new(1, -16, 0, 190)
else
	contadores.AnchorPoint = Vector2.new(0, 1)
	contadores.Position = UDim2.new(0, 20, 1, -16)
end
Estilo.escalar(contadores, if celular then 0.7 else 1)
contadores.Parent = pantalla

local function contador(
	icono: string,
	color: string,
	tam: number,
	orden: number
): (Frame, TextLabel)
	local f = Estilo.conIconos({ icono }, "0", tam, Color3.fromHex(color))
	f.LayoutOrder = orden
	local t = f:FindFirstChildOfClass("TextLabel") :: TextLabel
	local trazo = t:FindFirstChildOfClass("UIStroke")
	if trazo then
		trazo.Thickness = math.max(3, tam / 11)
	end
	f.Parent = contadores
	return f, t
end
local pFuerza, tFuerza = contador("Fuerza", "#FF4D5E", 66, 1)
local pSuerte, tSuerte = contador("Trebol", "#5CFF4C", 56, 2)
local pMonedas, tMonedas = contador("Moneda", "#FFD93D", 84, 3)

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
	tSuerte.Text = Formato.suerte(math.max(1, s)) .. " Suerte"
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

-- Grupo 3: llaves sin usar y bendición del altar (solo se ven si hay).
local pLlaves, tLlaves = Estilo.pildora("Candado", Estilo.Colores.Violeta, 210, 46)
pLlaves.LayoutOrder = 5
pLlaves.Visible = false
pLlaves.Parent = derecha
local pBendicion, tBendicion = Estilo.pildora("Chispa", Estilo.Colores.Amarillo, 250, 46)
pBendicion.LayoutOrder = 6
pBendicion.Visible = false
pBendicion.Parent = derecha
local function llaves()
	local n = 0
	for _ in Datos.conjunto("Llaves") do
		n += 1
	end
	local antes = pLlaves.Visible
	pLlaves.Visible = n > 0
	tLlaves.Text = if n == 1 then "1 llave" else n .. " llaves"
	if n > 0 and not antes then
		saltar(pLlaves)
	end
end
llaves()
Datos.alCambiar({ "Llaves" }, llaves)
task.spawn(function()
	while true do
		local falta = Datos.numero("BendicionFin") - Workspace:GetServerTimeNow()
		pBendicion.Visible = falta > 0
		if falta > 0 then
			tBendicion.Text = ("%s · %d:%02d"):format(
				Formato.suerte(GameConfig.Secretos.Altar.Suerte),
				falta // 60,
				math.floor(falta % 60)
			)
		end
		task.wait(0.5)
	end
end)

-- A la izquierda: menús ----------------------------------------------------------------------

local izquierda = Instance.new("Frame")
izquierda.Name = "Menus"
izquierda.BackgroundTransparency = 1
-- 19/10/2026: HUD menos cargado. A la vista solo 4 botones en una columna (Tienda, Mochila,
-- Viajar y Más); "Más" despliega al costado los menús que se usan menos.
izquierda.Size = UDim2.fromOffset(190, 3 * 58 + 2 * 8)
if celular then
	izquierda.AnchorPoint = Vector2.new(0, 0)
	izquierda.Position = UDim2.fromOffset(12, 8)
else
	izquierda.AnchorPoint = Vector2.new(0, 0.5)
	izquierda.Position = UDim2.new(0, 16, 0.42, 0)
end
-- La columna lleva el orden; el panel "Más" va al costado, dentro del mismo bloque para que
-- se escalen juntos.
local columnaBotones = Instance.new("Frame")
columnaBotones.Name = "Columna"
columnaBotones.BackgroundTransparency = 1
columnaBotones.Size = UDim2.fromScale(1, 1)
columnaBotones.Parent = izquierda
local columna = Instance.new("UIListLayout")
columna.Padding = UDim.new(0, 8)
columna.SortOrder = Enum.SortOrder.LayoutOrder
columna.Parent = columnaBotones
Estilo.escalar(izquierda, if celular then 0.8 else 1)
izquierda.Parent = pantalla

-- Panel que abre "Más": botones cuadrados con ícono y nombre abajo.
local mas = Instance.new("Frame")
mas.Name = "Mas"
mas.BackgroundTransparency = 1

mas.Size = UDim2.fromOffset(3 * 96 + 2 * 8, 96)
mas.Visible = false
local grillaMas = Instance.new("UIGridLayout")
grillaMas.CellSize = UDim2.fromOffset(96, 96)
grillaMas.CellPadding = UDim2.fromOffset(8, 8)
grillaMas.SortOrder = Enum.SortOrder.LayoutOrder
grillaMas.Parent = mas
mas.Position = UDim2.fromOffset(200, 0)
mas.Parent = izquierda

type Boton = { Boton: TextButton, Globito: Frame }
local botones: { [string]: Boton } = {}
local enMas: { [string]: boolean } = {}

local function nuevoGlobito(b: GuiObject): Frame
	local g = Estilo.globito("!", 30)
	g.Position = UDim2.new(1, -4, 0, 4)
	g.Visible = false
	g.Parent = b
	return g
end

local function botonMenu(
	orden: number,
	id: string,
	texto: string,
	icono: string,
	color: string
): Boton
	-- botón ancho: ícono a la izquierda y el nombre grande al costado (como las referencias)
	local b = Estilo.boton({
		Texto = texto,
		Icono = icono,
		Color = color,
		Ancho = 190,
		Alto = 58,
		TamanoTexto = 26,
	})
	b.Name = id
	b.LayoutOrder = orden
	local g = nuevoGlobito(b)
	b.Activated:Connect(function()
		mas.Visible = false
		Ventanas.alternar(id)
	end)
	b.Parent = columnaBotones
	local r = { Boton = b, Globito = g }
	botones[id] = r
	return r
end

-- Botón chico del panel "Más": ícono arriba y nombre abajo.
local function botonMas(orden: number, id: string, texto: string, icono: string, color: string)
	local b = Estilo.boton({ Icono = icono, Color = color, Ancho = 96, Alto = 96 })
	b.Name = id
	b.LayoutOrder = orden
	local ic = b:FindFirstChild("Icono" .. icono, true) :: GuiObject?
	if ic then
		ic.Position = UDim2.fromScale(0.5, 0.4)
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
	end
	local t = Estilo.texto(texto, 17)
	t.AnchorPoint = Vector2.new(0.5, 1)
	t.Position = UDim2.new(0.5, 0, 1, -6)
	t.ZIndex = 5
	t.Parent = b
	local g = nuevoGlobito(b)
	b.Activated:Connect(function()
		mas.Visible = false
		Ventanas.alternar(id)
	end)
	b.Parent = mas
	botones[id] = { Boton = b, Globito = g }
	enMas[id] = true
end

-- 19/10/2026: la Tienda se abre solo en el mapa (alfombra del Lobby); sin botón acá.
botonMenu(2, "Mochila", "Mochila", "Mochila", "Naranja")
botonMenu(3, "Viajar", "Viajar", "Cristal", "Cian")
-- "Más" no abre una ventana: despliega el panel.
local botonMasB = Estilo.boton({
	Texto = "Más",
	Icono = "Corona",
	Color = "Violeta",
	Ancho = 190,
	Alto = 58,
	TamanoTexto = 26,
})
botonMasB.Name = "Mas"
botonMasB.LayoutOrder = 4
local botonMasR = { Boton = botonMasB, Globito = nuevoGlobito(botonMasB) }
botonMasB.Activated:Connect(function()
	Ventanas.cerrar()
	mas.Visible = not mas.Visible
end)
botonMasB.Parent = columnaBotones
-- 19/10/2026: sin Misiones (sacadas del juego) ni Eventos (se ven solos en pantalla).
botonMas(3, "Mascotas", "Mascotas", "Mascota", "Rosa")
botonMas(4, "Vitrina", "Vitrina", "Corona", "Violeta")
botonMas(5, "Clasificacion", "Ranking", "Trofeo", "Amarillo")
-- Museo y Renacer ya no tienen botón (17/10, plan v5 del mapa): sus menús siguen en el código.

-- "Más" muestra "!" si alguno de los que tiene adentro tiene un aviso.
local function globitoMas()
	local hay = false
	for id in enMas do
		local b = botones[id]
		if b and b.Globito.Visible then
			hay = true
		end
	end
	local g = botonMasR.Globito
	local antes = g.Visible
	g.Visible = hay
	if hay and not antes then
		saltar(g)
	end
end

local function globito(id: string, texto: string?)
	local b = botones[id]
	if not b then
		return
	end
	local g = b.Globito
	local antes = g.Visible
	g.Visible = texto ~= nil
	if texto then
		(g:FindFirstChild("Texto") :: TextLabel).Text = texto
		if not antes then
			saltar(g)
		end
	end
	if enMas[id] then
		globitoMas()
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

-- Museo: "!" cuando encontrás una gema nueva, hasta que lo abrís.
local vistas = #Datos.texto("Indice")
Datos.alCambiar({ "Indice" }, function()
	if #Datos.texto("Indice") > vistas and Ventanas.abierta() ~= "Museo" then
		globito("Museo", "!")
	end
end)

-- Eventos: "!" mientras hay uno.
local function avisoEvento()
	local ev = estado:GetAttribute("Evento")
	globito("Eventos", if ev and ev ~= "" then "!" else nil)
end
avisoEvento()
estado:GetAttributeChangedSignal("Evento"):Connect(avisoEvento)

-- Grupo 4: Mascotas "!" si te alcanza para la ruleta; Renacer "!" si podés renacer o mejorar
-- una rama; Misiones "!" cuando cumplís una (hasta que lo abrís).
local function avisoMascotasRenacer()
	local monedas = Datos.numero("Monedas")
	globito("Mascotas", if monedas >= Reglas.precioRuleta(Datos.zonas()) then "!" else nil)
	local n = Datos.numero("Renacimientos")
	local puede = Reglas.puedeRenacer(Datos.zonas(), n)
	local esencia = Datos.numero("Esencia")
	local ramas = Datos.json("Ramas")
	for _, r in GameConfig.Renacer.Ramas do
		local costo = Reglas.costoRama(r.Id, tonumber(ramas[r.Id]) or 0)
		if Reglas.ramaDisponible(r.Id, n) and costo and esencia >= costo then
			puede = true
		end
	end
	globito("Renacer", if puede then "!" else nil)
end
avisoMascotasRenacer()
Datos.alCambiar({ "Monedas", "Zonas", "Renacimientos", "Esencia", "Ramas" }, avisoMascotasRenacer)

-- El botón del menú abierto se marca con borde blanco.
Ventanas.alCambiar(function(id: string?)
	for nombre, b in botones do
		Estilo.marcar(b.Boton, nombre == id, 26)
	end
	if id == "Museo" then
		vistas = #Datos.texto("Indice")
		globito("Museo", nil)
	elseif id == "Misiones" then
		globito("Misiones", nil)
	end
end)

-- A la derecha: seguimiento de misiones (Grupo 4) ------------------------------------------

local seguimiento = Instance.new("TextButton")
seguimiento.Name = "Misiones"
seguimiento.Text = ""
seguimiento.BackgroundTransparency = 1
seguimiento.AnchorPoint = Vector2.new(1, 0)
seguimiento.Position = UDim2.new(1, -16, if celular then 0.58 else 0.56, 0)
seguimiento.AutomaticSize = Enum.AutomaticSize.XY
local listaSeg = Instance.new("UIListLayout")
listaSeg.HorizontalAlignment = Enum.HorizontalAlignment.Right
listaSeg.Padding = UDim.new(0, 8)
listaSeg.SortOrder = Enum.SortOrder.LayoutOrder
listaSeg.Parent = seguimiento
Estilo.escalar(seguimiento, if celular then 0.75 else 0.9)
seguimiento.Parent = pantalla
seguimiento.Activated:Connect(function()
	Ventanas.alternar("Misiones")
end)

local function dibujarSeguimiento()
	for _, h in seguimiento:GetChildren() do
		if h:IsA("GuiObject") then
			h:Destroy()
		end
	end
	local lista = MenuMisiones.lista()
	if #lista > 1 then
		-- solo la que está más cerca de cumplirse (las demás, en el menú Misiones)
		table.sort(lista, function(a, b)
			return a.Progreso / math.max(1, a.Meta) > b.Progreso / math.max(1, b.Meta)
		end)
		lista = { lista[1] }
	end
	for i, m in lista do
		local f = Instance.new("Frame")
		f.Name = m.Id
		f.LayoutOrder = i
		f.Size = UDim2.fromOffset(330, 66)
		Estilo.superficie(f, { "Panel" }, Estilo.Colores.Oscuro, 14, 4, true)
		local franja = Instance.new("Frame")
		franja.Size = UDim2.new(0, 10, 1, -12)
		franja.Position = UDim2.fromOffset(6, 6)
		franja.ZIndex = 3
		Estilo.superficie(franja, {}, Estilo.Colores[MenuMisiones.color(m.Dificultad)], 5, 0, true)
		franja.Parent = f
		local t = Estilo.texto(m.Texto, 17)
		t.Position = UDim2.fromOffset(24, 6)
		t.Size = UDim2.fromOffset(296, 22)
		t.AutomaticSize = Enum.AutomaticSize.None
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.ZIndex = 3
		t.Parent = f
		local barra, poner = Estilo.barra(296, 26, Estilo.Colores[MenuMisiones.color(m.Dificultad)])
		barra.Position = UDim2.fromOffset(24, 34)
		barra.ZIndex = 3
		barra.Parent = f
		poner(m.Progreso / math.max(1, m.Meta), ("%d / %d"):format(m.Progreso, m.Meta))
		f.Parent = seguimiento
	end
end
if GameConfig.Misiones.Activas then
	dibujarSeguimiento()
	Datos.alCambiar({ "Misiones" }, dibujarSeguimiento)
else
	seguimiento.Visible = false
end

MisionRemoto.OnClientEvent:Connect(function(texto: unknown, monedas: unknown, esencia: unknown)
	if typeof(texto) ~= "string" or typeof(monedas) ~= "number" then
		return
	end
	-- SONIDO: misión cumplida
	Sonidos.tocar(GameConfig.Sonidos.Mision)
	local premio = "+" .. Formato.corto(monedas) .. " Monedas"
	if typeof(esencia) == "number" and esencia > 0 then
		premio ..= (" · +%d Esencia"):format(esencia)
	end
	Avisos.mostrar({
		Titulo = "¡Misión cumplida!",
		Texto = texto .. " · " .. premio,
		Color = Color3.fromHex("#8CFF5A"),
		Duracion = 3,
		Icono = "Mision",
	})
	if Ventanas.abierta() ~= "Misiones" then
		globito("Misiones", "!")
	end
end)

RenacerRemoto.OnClientEvent:Connect(function(numero: unknown, esencia: unknown)
	if typeof(numero) ~= "number" or typeof(esencia) ~= "number" then
		return
	end
	-- SONIDO: renacer
	Sonidos.tocar(GameConfig.Sonidos.Renacer)
	Ventanas.cerrar()
	Avisos.mostrar({
		Titulo = ("¡Renaciste! Renacer %d"):format(numero),
		Texto = ("+%d de Esencia y bonos para siempre. ¡A romper de nuevo!"):format(esencia),
		Color = Color3.fromHex("#FFD23F"),
		Duracion = 4,
		Icono = "Renacer",
	})
	local destello = Instance.new("Frame")
	destello.Size = UDim2.fromScale(1, 1)
	destello.BackgroundColor3 = Color3.fromHex("#FFD23F")
	destello.BackgroundTransparency = 0.2
	destello.BorderSizePixel = 0
	destello.ZIndex = 50
	destello.Parent = pantalla
	local t = TweenService:Create(destello, TweenInfo.new(1.2), { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		destello:Destroy()
	end)
	t:Play()
end)

-- Arriba al centro: la zona donde estás, en letras grandes (como las referencias) ----------

local titulo = Estilo.texto("", 58)
titulo.Name = "TituloZona"
titulo.AnchorPoint = Vector2.new(0.5, 0)
titulo.Position = UDim2.new(0.5, 0, 0, 6)
Estilo.escalar(titulo, if celular then 0.6 else 1)
titulo.Parent = pantalla
local zonaActual = -1
task.spawn(function()
	while true do
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		local n = 0
		if raiz and raiz:IsA("BasePart") then
			for i, rango in GameConfig.Modelos.DecoExtra.Zonas do
				if raiz.Position.Z >= rango[1] - 8 and raiz.Position.Z <= rango[2] + 8 then
					n = i
				end
			end
		end
		if n ~= zonaActual then
			zonaActual = n
			local z = GameConfig.Zonas[n]
			titulo.Text = if z then z.Nombre else "Plaza"
			titulo.TextColor3 = if z then Color3.fromHex(z.ColorCristal) else Color3.new(1, 1, 1)
			saltar(titulo)
		end
		task.wait(0.3)
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
	-- Requisito de colección: también hacen falta gemas distintas de la zona anterior
	local pide = Reglas.gemasParaAbrir(z)
	local vistasZona = math.min(pide, Reglas.gemasVistas(Datos.conjunto("Indice"), z.Numero - 1))
	local texto = ("%s / %s de Fuerza"):format(Formato.corto(f), Formato.corto(z.FuerzaParaAbrir))
	if pide > 0 then
		texto ..= (" · Gemas %d/%d"):format(vistasZona, pide)
	end
	ponerZona(
		math.min(f / math.max(1, z.FuerzaParaAbrir), if pide > 0 then vistasZona / pide else 1),
		texto
	)
	nombreZona.Text = z.Nombre
	nombreZona.TextColor3 = Color3.fromHex(z.ColorCristal)
end
zona()
Datos.alCambiar({ "Fuerza", "Zonas", "Indice" }, zona)

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
	elseif tipo == "Rama" then
		Avisos.mostrar({
			Titulo = "¡Rama mejorada!",
			Texto = detalle,
			Color = Color3.fromHex("#FFB04D"),
			Duracion = 2.5,
			Icono = "Esencia",
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
