--!strict
-- Ventanas chicas de los botones Misiones y Ajustes del HUD, hasta que existan esos menús
-- (las misiones llegan en la Parte 8). Ajustes ya trae el interruptor del sonido.
-- Se abren y se cierran con UI/Menus, como el resto.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)

local Tema = UI.Tema
local V = Tema.VentanaChica

local function ventana(nombre: string, titulo: string, icono: string, color: Color3): UI.Ventana
	local v = UI.ventana({
		Titulo = titulo,
		Icono = icono,
		ColorIcono = color,
		Ancho = V.Ancho,
		Alto = V.Alto,
		MaxAncho = V.MaxAncho,
		MaxAlto = V.MaxAlto,
	})
	Menus.registrar(nombre, v)
	return v
end

-- Un ícono grande y un texto en el medio de la ventana.
local function proximamente(
	v: UI.Ventana,
	icono: string,
	color: Color3,
	texto: string,
	alto: number
)
	local insignia = UI.insignia(icono, color, Tema.Mutadex.InsigniaExtras)
	insignia.AnchorPoint = Vector2.new(0.5, 1)
	insignia.Position = UDim2.fromScale(0.5, alto)
	insignia.Parent = v.Cuerpo
	local t = UI.texto({
		Texto = texto,
		Letra = Tema.Letra.Subtitulo,
		Medida = UDim2.new(1, 0, 0, Tema.Toque),
	})
	t.Position = UDim2.new(0, 0, alto, Tema.Separacion)
	t.Parent = v.Cuerpo
end

---------------------------------------------------------------------------
-- Misiones
---------------------------------------------------------------------------

local misiones = ventana("Misiones", "Misiones", "misiones", Paleta.Elementos.Agua)
proximamente(misiones, "misiones", Paleta.Elementos.Agua, "Las misiones llegan pronto.", 0.55)

---------------------------------------------------------------------------
-- Ajustes: el sonido se prende y se apaga; lo demás llega más adelante.
---------------------------------------------------------------------------

local ajustes = ventana("Ajustes", "Ajustes", "engranaje", Paleta.Metal)

local fila = UI.hueco("Sonido", UDim2.new(1, 0, 0, Tema.Toque + Tema.Profundidad), ajustes.Cuerpo)
local l = UI.lista(fila, true, Tema.Separacion)
l.VerticalAlignment = Enum.VerticalAlignment.Center
local textoSonido = UI.texto({
	Texto = "Sonido",
	Letra = Tema.Letra.Subtitulo,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.fromScale(0.5, 1),
})
textoSonido.LayoutOrder = 1
textoSonido.Parent = fila

local interruptor: UI.Boton
local function pintarSonido()
	local si = Sonidos.estanActivos()
	interruptor.poner(if si then "Prendido" else "Apagado")
	interruptor.pintar(if si then Paleta.Acento else Paleta.Metal)
end
interruptor = UI.boton({
	Nombre = "Interruptor",
	Texto = "Prendido",
	Tipo = "principal",
	Medida = UDim2.fromOffset(Tema.Fusion.AnchoBoton, Tema.Toque + Tema.Profundidad),
	AlTocar = function()
		Sonidos.activar(not Sonidos.estanActivos())
		pintarSonido()
	end,
})
interruptor.Marco.LayoutOrder = 2
interruptor.Marco.Parent = fila
pintarSonido()

proximamente(ajustes, "engranaje", Paleta.Metal, "Más ajustes, próximamente.", 0.78)
