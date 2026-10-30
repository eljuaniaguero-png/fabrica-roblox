--!strict
-- Selector de la máquina de equipo de la plaza (ficha, "Parte 9"). Al apretar E en un pedestal
-- libre, el servidor abre esta ventana con tus criaturas (las iguales juntas). Tocar una la pone
-- en ese lado: va una copia, la tuya sigue en tu laboratorio. El servidor valida todo
-- (server/Equipo.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local VistasVisibles = require(script.Parent.UI.VistasVisibles)

local Tema = UI.Tema
local T = Tema.Mutadex
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local elegirEquipo = remotos:WaitForChild("ElegirEquipo") :: RemoteEvent
local ponerEquipo = remotos:WaitForChild("PonerEquipo") :: RemoteEvent

local ventana = UI.ventana({
	Titulo = "Máquina de equipo",
	Icono = "criatura",
	ColorIcono = Paleta.Dorado,
	Ancho = 0.8,
	Alto = 0.85,
	MaxAncho = 1000,
	MaxAlto = 760,
})

local nota = UI.texto({
	Nombre = "Nota",
	Texto = "",
	Fuente = "fuerte",
	Letra = Tema.Letra.Chica,
	Color = Paleta.Dorado,
	AlineacionX = Enum.TextXAlignment.Left,
	Medida = UDim2.new(1, 0, 0, T.AltoNota),
})
nota.Parent = ventana.Cuerpo
local scroll = UI.desplazable("Lista", ventana.Cuerpo)
scroll.Position = UDim2.fromOffset(0, T.AltoNota)
scroll.Size = UDim2.new(1, 0, 1, -T.AltoNota)
local grilla = UI.grilla(scroll, Vector2.new(T.AltoTarjeta.Minimo, T.AltoTarjeta.Minimo))
local grupo = VistasVisibles.nueva(scroll)

local lado = 1
local tarjetas: { UI.Casillero } = {}

type Opcion = { Grupo: Formato.Grupo, Criatura: Fusion.Criatura }

-- Una tarjeta por grupo de criaturas iguales (las especiales no se fusionan).
local function llenar()
	for _, cas in tarjetas do
		grupo.quitar(cas.Marco)
		cas.Marco:Destroy()
	end
	tarjetas = {}
	local opciones: { Opcion } = {}
	for _, g in Formato.grupos(jugador:GetAttribute("Grupos") :: string?) do
		local c = Fusion.porClave(g.Clave)
		if c and not c.Especial then
			table.insert(opciones, { Grupo = g, Criatura = c })
		end
	end
	table.sort(opciones, function(a, b)
		if a.Criatura.Gen ~= b.Criatura.Gen then
			return a.Criatura.Gen < b.Criatura.Gen
		end
		return a.Criatura.Nombre < b.Criatura.Nombre
	end)
	for orden, o in opciones do
		local g, c = o.Grupo, o.Criatura
		local cas = UI.casillero({
			Nombre = g.Clave,
			Medida = UDim2.fromOffset(T.AltoTarjeta.Minimo, T.AltoTarjeta.Minimo),
			Borde = if g.Mutante then Paleta.Mutante else Paleta.Generaciones[c.Gen],
			Prestada = true,
		})
		cas.Marco.LayoutOrder = orden
		cas.Marco.Parent = scroll
		grupo.agregar(cas.Marco, cas.Hueco, {
			Clave = g.Clave,
			Mutante = g.Mutante,
			Personalidad = g.Personalidad,
			Variante = g.Variante,
		})
		local nombre = Catalizadores.nombre(c.Nombre, g.Variante)
		cas.poner(
			g.Clave,
			if g.Cantidad > 1 then nombre .. " x" .. g.Cantidad else nombre,
			g.Mutante
		)
		cas.elemento(Generador.colorElemento(c))
		cas.personalidad(g.Personalidad)
		UI.tocable(cas.Fondo, function()
			-- SONIDO: elegir una criatura para la máquina de equipo (nota corta)
			Sonidos.nota(9, 0.3)
			ponerEquipo:FireServer(lado, g.Clave, g.Personalidad or "")
			Menus.cerrar("Equipo")
		end, cas.Marco)
		table.insert(tarjetas, cas)
	end
end

ventana.alAcomodar(function(tam: Vector2)
	local columnas = if UI.Pantalla.esCelular() then T.ColumnasCelular else T.Columnas + 1
	local ancho = UI.anchoCelda(UI.anchoUtil(tam.X - Tema.Relleno * 2), columnas)
	local alto = math.clamp(
		math.floor(ancho * T.AltoTarjeta.Proporcion),
		T.AltoTarjeta.Minimo,
		T.AltoTarjeta.Maximo
	)
	grilla.CellSize = UDim2.fromOffset(ancho, alto)
end)

Menus.registrar("Equipo", ventana, function()
	llenar()
	grupo.actualizar()
end)

elegirEquipo.OnClientEvent:Connect(function(numero: number)
	lado = numero
	nota.Text = "Lado "
		.. numero
		.. ": elegí una criatura (va una copia, la tuya sigue en tu laboratorio). Dos bases a 4 lugares en la rueda solo reaccionan acá."
	Menus.abrir("Equipo")
end)
