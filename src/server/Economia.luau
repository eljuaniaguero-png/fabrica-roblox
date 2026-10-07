--!strict
-- Conversión de velocidad a monedas y compras en la tienda. Todo validado en el servidor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Datos = require(script.Parent.Datos)
local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Economia = {}

local ultimoPedido: { [Player]: number } = {}

local function muyRapido(jugador: Player): boolean
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < Config.EsperaCompra then
		return true
	end
	ultimoPedido[jugador] = ahora
	return false
end

local function convertir(jugador: Player)
	local perfil = Datos.obtener(jugador)
	if muyRapido(jugador) or not perfil then
		return
	end
	if perfil.Velocidad < Config.MinimoConversion then
		Remotos.avisar(jugador, `Necesitás al menos {Config.MinimoConversion} de velocidad`)
		return
	end
	local ganadas = math.floor(perfil.Velocidad * Config.TasaConversion)
	perfil.Monedas += ganadas
	perfil.Velocidad = 0
	Velocidad.aplicar(jugador)
	Puertas.actualizarNivel(jugador)
	-- SONIDO: monedas (conversión)
	Remotos.avisar(jugador, `+{ganadas} monedas`)
end

local function comprarZapatillas(jugador: Player, perfil: Datos.Perfil)
	if perfil.Zapatillas >= Config.Zapatillas.NivelMaximo then
		Remotos.avisar(jugador, "Zapatillas al máximo")
		return
	end
	local precio = Precios.zapatillas(perfil.Zapatillas)
	if perfil.Monedas < precio then
		Remotos.avisar(jugador, `Te faltan {precio - perfil.Monedas} monedas`)
		return
	end
	perfil.Monedas -= precio
	perfil.Zapatillas += 1
	Velocidad.aplicar(jugador)
	Remotos.avisar(jugador, `Zapatillas nivel {perfil.Zapatillas}`)
end

local function comprarConsumible(
	jugador: Player,
	perfil: Datos.Perfil,
	nombre: string,
	consumible: Config.Consumible
)
	if (perfil.Inventario[nombre] or 0) >= Config.InventarioMaximo then
		Remotos.avisar(jugador, `Ya tenés el máximo de {consumible.Nombre}`)
		return
	end
	if perfil.Monedas < consumible.Precio then
		Remotos.avisar(jugador, `Te faltan {consumible.Precio - perfil.Monedas} monedas`)
		return
	end
	perfil.Monedas -= consumible.Precio
	perfil.Inventario[nombre] = (perfil.Inventario[nombre] or 0) + 1
	Velocidad.aplicar(jugador)
	Remotos.avisar(jugador, `+1 {consumible.Nombre}`)
end

local function comprar(jugador: Player, articulo: unknown)
	local perfil = Datos.obtener(jugador)
	if muyRapido(jugador) or not perfil or typeof(articulo) ~= "string" then
		return
	end
	-- SONIDO: compra
	if articulo == "Zapatillas" then
		comprarZapatillas(jugador, perfil)
		return
	end
	local consumible = Config.Consumibles[articulo]
	if consumible then
		comprarConsumible(jugador, perfil, articulo, consumible)
	end
end

function Economia.iniciar()
	Remotos.Convertir.OnServerEvent:Connect(convertir)
	Remotos.Comprar.OnServerEvent:Connect(comprar)
end

function Economia.olvidar(jugador: Player)
	ultimoPedido[jugador] = nil
end

return Economia
