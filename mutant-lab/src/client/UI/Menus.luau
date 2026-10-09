--!strict
-- Los menús (Mutadex, tienda, panel de fusión, misiones y ajustes).
-- Solo uno abierto a la vez. Todos se abren y se cierran con la misma animación corta, y se
-- cierran con la X, tocando afuera de la ventana o con la tecla Escape.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local UI = require(script.Parent)
local Sonidos = require(script.Parent.Parent.Sonidos)

local Tema = UI.Tema

type Registro = {
	Ventana: UI.Ventana,
	AlAbrir: (() -> ())?,
	AlCerrar: (() -> ())?,
}

-- Fondo oscuro de pantalla completa: tocarlo cierra el menú.
local guiFondo = Instance.new("ScreenGui")
guiFondo.Name = "MenusFondo"
guiFondo.ResetOnSpawn = false
guiFondo.IgnoreGuiInset = true
guiFondo.ScreenInsets = Enum.ScreenInsets.None
guiFondo.DisplayOrder = 9
local afuera = Instance.new("TextButton")
afuera.Name = "Afuera"
afuera.Text = ""
afuera.AutoButtonColor = false
afuera.BorderSizePixel = 0
afuera.Size = UDim2.fromScale(1, 1)
afuera.BackgroundColor3 = Paleta.Contorno
afuera.BackgroundTransparency = 1
afuera.Visible = false
afuera.Parent = guiFondo
guiFondo.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local capa = UI.Pantalla.crear("Menus", 10)

local registros: { [string]: Registro } = {}
local abierto: string? = nil
local cambio = Instance.new("BindableEvent")

local Menus = {}

-- Se dispara con el nombre del menú que se abrió (o nil si se cerró).
Menus.Cambio = cambio.Event
Menus.Capa = capa

function Menus.registrar(
	nombre: string,
	ventana: UI.Ventana,
	alAbrir: (() -> ())?,
	alCerrar: (() -> ())?
)
	registros[nombre] = { Ventana = ventana, AlAbrir = alAbrir, AlCerrar = alCerrar }
	ventana.Marco.Name = nombre
	ventana.Marco.Visible = false
	ventana.Marco.Parent = capa.Raiz
	ventana.Cerrar.AlTocar = function()
		Menus.cerrar(nombre)
	end
end

local function ocultar(nombre: string, animado: boolean)
	local r = registros[nombre]
	if r.AlCerrar then
		task.spawn(r.AlCerrar)
	end
	local marco = r.Ventana.Marco
	if not animado then
		marco.Visible = false
		return
	end
	local t = UI.animar(r.Ventana.Escala, Tema.Cerrar, { Scale = 0.88 })
	t.Completed:Once(function()
		if abierto ~= nombre then
			marco.Visible = false
		end
	end)
end

function Menus.abrir(nombre: string)
	local r = registros[nombre]
	if not r or abierto == nombre then
		return
	end
	local anterior = abierto
	abierto = nombre
	if anterior then
		ocultar(anterior, false)
	end
	r.Ventana.Escala.Scale = 0.85
	r.Ventana.Marco.Visible = true
	UI.animar(r.Ventana.Escala, Tema.Abrir, { Scale = 1 })
	afuera.Visible = true
	UI.animar(afuera, Tema.Rapida, { BackgroundTransparency = Tema.TransparenciaFondo })
	Sonidos.abrirMenu()
	if r.AlAbrir then
		task.spawn(r.AlAbrir)
	end
	cambio:Fire(nombre)
end

-- Cierra el menú abierto (o solo `nombre`, si es ese el abierto).
function Menus.cerrar(nombre: string?)
	local actual = abierto
	if not actual or (nombre and nombre ~= actual) then
		return
	end
	abierto = nil
	ocultar(actual, true)
	local t = UI.animar(afuera, Tema.Cerrar, { BackgroundTransparency = 1 })
	t.Completed:Once(function()
		if not abierto then
			afuera.Visible = false
		end
	end)
	Sonidos.cerrarMenu()
	cambio:Fire(nil)
end

-- TEMPORAL (hasta rehacer la Mutadex y la tienda con los componentes nuevos): menús viejos
-- que se abren y cierran con los botones del HUD. Abrir uno cierra los demás viejos.
type Viejo = { Ventana: GuiObject, AlAbrir: () -> () }
local viejos: { [string]: Viejo } = {}

function Menus.puenteViejo(nombre: string, ventana: GuiObject, alAbrir: () -> ())
	viejos[nombre] = { Ventana = ventana, AlAbrir = alAbrir }
end

-- Cierra la Mutadex y la tienda viejas (al abrir la máquina, por ejemplo).
function Menus.cerrarViejos()
	for _, v in viejos do
		v.Ventana.Visible = false
	end
end

function Menus.alternar(nombre: string)
	local viejo = viejos[nombre]
	if viejo and not registros[nombre] then
		Menus.cerrar()
		local abrir = not viejo.Ventana.Visible
		for _, otro in viejos do
			otro.Ventana.Visible = false
		end
		if abrir then
			viejo.Ventana.Visible = true
			Sonidos.abrirMenu()
			viejo.AlAbrir()
		end
		return
	end
	if abierto == nombre then
		Menus.cerrar(nombre)
	else
		Menus.abrir(nombre)
	end
end

function Menus.abierto(): string?
	return abierto
end

afuera.Activated:Connect(function()
	Menus.cerrar()
end)

UserInputService.InputBegan:Connect(function(entrada: InputObject)
	if entrada.KeyCode == Enum.KeyCode.Escape and abierto then
		Menus.cerrar()
	end
end)

return Menus
