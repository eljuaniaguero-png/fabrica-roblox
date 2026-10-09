--!strict
-- HUD siempre visible, armado por código con los componentes de UI (ficha, "Guía de estilo", 6):
--   arriba a la izquierda, el ADN con su "+X/s" (rebota cuando sube);
--   arriba al centro, el progreso de la Mutadex (tocarlo la abre);
--   arriba a la derecha, los botones redondos de Mutadex, Tienda, Misiones y Ajustes;
--   a la derecha, las notificaciones (Notificaciones.luau). El centro queda siempre libre.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function actualizarADN()
	local valor = (jugador:GetAttribute("ADN") :: number?) or 0
	adn.Valor.Text = Formato.numero(valor)
	if adnAnterior and valor > adnAnterior then
		-- Lo de cada segundo es un saltito; un premio o algo grande, un rebote fuerte.
		local subida = valor - adnAnterior
		adn.rebotar(if subida > porSegundo() * 2 + 1 then 0.18 else 0.06)
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

local function actualizarProgreso()
	local n = 0
	for _ in Formato.conjunto(jugador:GetAttribute("Especies") :: string?) do
		n += 1
	end
	textoProgreso.Text = n .. " / " .. TOTAL
	barra.poner(n / TOTAL, cantidadAnterior ~= nil)
	if cantidadAnterior and n ~= cantidadAnterior then
		escalaProgreso.Scale = 1.15
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
local eventoAviso = remotos:WaitForChild("Aviso") :: RemoteEvent
eventoAviso.OnClientEvent:Connect(function(texto: string, tipo: string?)
	Notificaciones.mostrar(texto, tipo)
end)
actualizarADN()
actualizarPorSegundo()
actualizarProgreso()
