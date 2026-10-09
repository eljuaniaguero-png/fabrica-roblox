--!strict
-- HUD siempre visible, armado por código con los componentes de UI (ficha, "Guía de estilo", 6):
--   arriba a la izquierda, el ADN con su "+X/s" (rebota cuando sube);
--   arriba al centro, el progreso de la Mutadex (tocarlo la abre);
--   arriba a la derecha, los botones redondos de Mutadex, Tienda, Misiones y Ajustes;
--   a la derecha, las notificaciones (Notificaciones.luau). El centro queda siempre libre.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local Notificaciones = require(script.Parent.UI.Notificaciones)

local Tema = UI.Tema
local M = Tema.Margen

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local TOTAL = #Fusion.todas()

local capa = UI.Pantalla.crear("HUD", 1)

---------------------------------------------------------------------------
-- ADN (arriba a la izquierda)
---------------------------------------------------------------------------

local adn = UI.contador({
	Icono = "adn",
	Color = Paleta.Acento,
	Texto = "0",
	Sub = "+0/s",
	Ancho = 290,
	Alto = 96,
})
adn.Marco.Name = "ADN"
adn.Marco.Position = UDim2.fromOffset(M, M)
adn.Marco.Parent = capa.Raiz

local adnAnterior: number? = nil

local function porSegundo(): number
	return (jugador:GetAttribute("ADNPorSegundo") :: number?) or 0
end

-- "+N" (o "-N" al gastar) que salta al lado del contador y se desvanece subiendo.
local SALTO = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DESVANECER = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local alturaSalto = 0

local function numeroQueSalta(cambio: number)
	local grande = math.abs(cambio) >= Config.Efectos.NumeroADNGrande
	local color = if cambio < 0 then Paleta.Error elseif grande then Paleta.Dorado else Paleta.Acento
	local t = UI.texto({
		Nombre = "NumeroADN",
		Texto = (if cambio > 0 then "+" else "-") .. Formato.numero(math.abs(cambio)),
		Letra = if grande then Tema.Letra.Titulo else Tema.Letra.Subtitulo,
		Color = color,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.fromOffset(240, 56),
	})
	t.TextWrapped = false
	-- Los seguidos se escalonan un poco, para que no se pisen.
	alturaSalto = (alturaSalto + 1) % 3
	local inicio = UDim2.fromOffset(M + 290 + 10, M + 20 + alturaSalto * 8)
	t.Position = inicio
	local escala = Instance.new("UIScale")
	escala.Scale = 0.3
	escala.Parent = t
	t.Parent = capa.Raiz
	UI.animar(escala, Tema.Rebote, { Scale = 1 })
	UI.animar(t, SALTO, { Position = inicio - UDim2.fromOffset(0, if cambio > 0 then 46 else -46) })
	task.delay(0.45, function()
		UI.animar(t, DESVANECER, { TextTransparency = 1 })
		local borde = t:FindFirstChildOfClass("UIStroke")
		if borde then
			UI.animar(borde, DESVANECER, { Transparency = 1 })
		end
	end)
	Debris:AddItem(t, 1.1)
end

local function actualizarADN()
	local valor = (jugador:GetAttribute("ADN") :: number?) or 0
	adn.Valor.Text = Formato.numero(valor)
	if adnAnterior and valor ~= adnAnterior then
		local cambio = valor - adnAnterior
		if cambio > 0 then
			-- Lo de cada segundo es un saltito; un premio o algo grande, un rebote fuerte.
			adn.rebotar(if cambio > porSegundo() * 2 + 1 then 0.18 else 0.06)
		end
		if math.abs(cambio) >= Config.Efectos.NumeroADNMinimo then
			numeroQueSalta(cambio)
		end
	end
	adnAnterior = valor
end

local function actualizarPorSegundo()
	local n = porSegundo()
	-- Con Nutrientes puede tener decimales: se muestra con uno solo.
	local sub = adn.Sub :: TextLabel
	sub.Text = "+"
		.. (if n == math.floor(n) then Formato.numero(n) else string.format("%.1f", n))
		.. "/s"
end

---------------------------------------------------------------------------
-- Pedidos entregados (debajo del ADN): tocarlo abre el tablero
---------------------------------------------------------------------------

local P = Config.Pedidos
local TP = Tema.Pedidos
local pedidos = UI.contador({
	Icono = "caja",
	Color = Paleta.Dorado,
	Texto = "0",
	Sub = "",
	Ancho = TP.ContadorHUD.X,
	Alto = TP.ContadorHUD.Y,
	Boton = true,
})
pedidos.Marco.Name = "Pedidos"
pedidos.Marco.Position = UDim2.fromOffset(M, M + 96 + Tema.Separacion)
pedidos.Marco.Parent = capa.Raiz
UI.tocable(pedidos.Fondo :: TextButton, function()
	Menus.alternar("Pedidos")
end, pedidos.Marco)

local entregadosAntes: number? = nil

local function actualizarPedidos()
	local n = (jugador:GetAttribute("Entregados") :: number?) or 0
	local faltan = P.Hito - n % P.Hito
	pedidos.Valor.Text = Formato.numero(n)
	local sub = pedidos.Sub :: TextLabel
	sub.Text = "premio en " .. faltan
	if entregadosAntes and n > entregadosAntes then
		pedidos.rebotar(0.18)
	end
	entregadosAntes = n
end

---------------------------------------------------------------------------
-- Progreso de la Mutadex (arriba al centro)
---------------------------------------------------------------------------

local progreso = UI.caja({
	Nombre = "Progreso",
	Color = Paleta.Superficie,
	Transparencia = 0.05,
	Boton = true,
})
progreso.Marco.AnchorPoint = Vector2.new(0.5, 0)
progreso.Marco.Position = UDim2.new(0.5, 0, 0, M)
progreso.Marco.Size = UDim2.fromOffset(330, 96)
progreso.Marco.Parent = capa.Raiz
local escalaProgreso = Instance.new("UIScale")
escalaProgreso.Parent = progreso.Marco

local insignia = Instance.new("Frame")
insignia.Size = UDim2.fromOffset(72, 72)
insignia.AnchorPoint = Vector2.new(0, 0.5)
insignia.Position = UDim2.new(0, 12, 0.5, 0)
insignia.BackgroundColor3 = Paleta.oscuro(Paleta.Generaciones[3], 0.55)
UI.redondo(insignia)
UI.contorno(insignia, Paleta.Contorno, 2)
UI.Iconos.crear("libro", 46, Paleta.Generaciones[3]).Parent = insignia
insignia.Parent = progreso.Fondo

local textoProgreso = UI.texto({
	Texto = "0 / " .. TOTAL,
	Letra = Tema.Letra.Numero,
	Medida = UDim2.new(1, -110, 0, 46),
})
textoProgreso.Position = UDim2.fromOffset(96, 8)
textoProgreso.Parent = progreso.Fondo
local barra = UI.barra(Paleta.Acento, 20)
barra.Marco.Size = UDim2.new(1, -116, 0, 20)
barra.Marco.Position = UDim2.fromOffset(98, 60)
barra.Marco.Parent = progreso.Fondo

UI.tocable(progreso.Fondo :: TextButton, function()
	Menus.alternar("Mutadex")
end, progreso.Marco)

local cantidadAnterior: number? = nil

-- Mientras la máquina anima una fusión, el contador espera a la revelación para subir (lo
-- marca Maquina.client con el atributo local "RetenerProgreso" y lo suelta EfectosMaquina).
local function actualizarProgreso()
	if jugador:GetAttribute("RetenerProgreso") then
		return
	end
	local n = 0
	for _ in Formato.conjunto(jugador:GetAttribute("Especies") :: string?) do
		n += 1
	end
	textoProgreso.Text = n .. " / " .. TOTAL
	barra.poner(n / TOTAL, cantidadAnterior ~= nil)
	if cantidadAnterior and n ~= cantidadAnterior then
		escalaProgreso.Scale = if n > cantidadAnterior then 1.3 else 1.15
		UI.animar(escalaProgreso, Tema.Rebote, { Scale = 1 })
	end
	cantidadAnterior = n
end

---------------------------------------------------------------------------
-- Botones redondos (arriba a la derecha)
---------------------------------------------------------------------------

local LADO = Tema.Toque + 4
local BOTONES = {
	{ Menu = "Mutadex", Texto = "Mutadex", Icono = "libro", Color = Paleta.Generaciones[3] },
	{ Menu = "Tienda", Texto = "Tienda", Icono = "carrito", Color = Paleta.Dorado },
	{ Menu = "Misiones", Texto = "Misiones", Icono = "misiones", Color = Paleta.Elementos.Agua },
	{ Menu = "Ajustes", Texto = "Ajustes", Icono = "engranaje", Color = Paleta.Metal },
}

local fila = UI.hueco(
	"Botones",
	UDim2.fromOffset(#BOTONES * LADO + (#BOTONES - 1) * Tema.Separacion, LADO + 30),
	capa.Raiz
)
fila.AnchorPoint = Vector2.new(1, 0)
fila.Position = UDim2.new(1, -M, 0, M)
UI.lista(fila, true, Tema.Separacion)

for i, d in BOTONES do
	local columna = UI.hueco(d.Menu, UDim2.fromOffset(LADO, LADO + 30), fila)
	columna.LayoutOrder = i
	local b = UI.boton({
		Nombre = "Boton",
		Icono = d.Icono,
		ColorIcono = Paleta.Contorno,
		Color = d.Color,
		Redondo = true,
		Medida = UDim2.fromOffset(LADO, LADO),
		AlTocar = function()
			Menus.alternar(d.Menu)
		end,
	})
	b.Marco.Parent = columna
	local etiqueta = UI.texto({
		Texto = d.Texto,
		Letra = Tema.Letra.Chica,
		Medida = UDim2.new(1, 20, 0, 28),
	})
	etiqueta.AnchorPoint = Vector2.new(0.5, 0)
	etiqueta.Position = UDim2.new(0.5, 0, 0, LADO + 2)
	etiqueta.Parent = columna
end

---------------------------------------------------------------------------
-- Conexiones
---------------------------------------------------------------------------

jugador:GetAttributeChangedSignal("ADN"):Connect(actualizarADN)
jugador:GetAttributeChangedSignal("ADNPorSegundo"):Connect(actualizarPorSegundo)
jugador:GetAttributeChangedSignal("Especies"):Connect(actualizarProgreso)
jugador:GetAttributeChangedSignal("RetenerProgreso"):Connect(actualizarProgreso)
jugador:GetAttributeChangedSignal("Entregados"):Connect(actualizarPedidos)
local eventoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent
eventoAviso.OnClientEvent:Connect(function(texto: string, tipo: string?)
	Notificaciones.mostrar(texto, tipo)
end)
actualizarADN()
actualizarPorSegundo()
actualizarProgreso()
actualizarPedidos()
