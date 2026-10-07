--!strict
-- Tienda física: puestos en el mapa con un ProximityPrompt. Todo validado en el servidor.
--
-- En el mapa: BasePart con atributo Articulo = "DoblePaso" | "Escudo" | "Zapatillas" | "Bolsillo"
-- y un ProximityPrompt adentro.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Datos = require(script.Parent.Datos)
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

-- Cobra si alcanza. Devuelve true si cobró.
local function cobrar(jugador: Player, perfil: Datos.Perfil, precio: number): boolean
	if perfil.Monedas < precio then
		Remotos.avisar(jugador, `Te faltan {precio - perfil.Monedas} monedas`, "Error")
		return false
	end
	perfil.Monedas -= precio
	return true
end

local function comprarMejora(jugador: Player, perfil: Datos.Perfil, nombre: string)
	local nivel = perfil.Mejoras[nombre] or 0
	local precio = Precios.mejora(nombre, nivel)
	if not precio then
		Remotos.avisar(jugador, `{Config.Mejoras[nombre].Nombre} al máximo`, "Error")
		return
	end
	if not cobrar(jugador, perfil, precio) then
		return
	end
	perfil.Mejoras[nombre] = nivel + 1
	Velocidad.aplicar(jugador)
	-- SONIDO: compra (Config.Efectos.Compra)
	Remotos.avisar(jugador, `{Config.Mejoras[nombre].Nombre} nivel {nivel + 1}`, "Compra")
end

local function comprarConsumible(jugador: Player, perfil: Datos.Perfil, nombre: string)
	local consumible = Config.Consumibles[nombre]
	if (perfil.Inventario[nombre] or 0) >= Config.InventarioMaximo then
		Remotos.avisar(jugador, `Ya tenés el máximo de {consumible.Nombre}`, "Error")
		return
	end
	if not cobrar(jugador, perfil, consumible.Precio) then
		return
	end
	perfil.Inventario[nombre] = (perfil.Inventario[nombre] or 0) + 1
	Velocidad.aplicar(jugador)
	-- SONIDO: compra (Config.Efectos.Compra)
	Remotos.avisar(jugador, `+1 {consumible.Nombre}`, "Compra")
end

local function comprar(jugador: Player, articulo: string)
	local perfil = Datos.obtener(jugador)
	if muyRapido(jugador) or not perfil then
		return
	end
	if Config.Mejoras[articulo] then
		comprarMejora(jugador, perfil, articulo)
	elseif Config.Consumibles[articulo] then
		comprarConsumible(jugador, perfil, articulo)
	end
end

function Economia.iniciar()
	for _, parte in workspace:GetDescendants() do
		local articulo = parte:GetAttribute("Articulo")
		if parte:IsA("BasePart") and typeof(articulo) == "string" then
			local aviso = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
			if aviso then
				aviso.Triggered:Connect(function(jugador)
					comprar(jugador, articulo)
				end)
			else
				warn(`[Tienda] {parte:GetFullName()} no tiene ProximityPrompt`)
			end
		end
	end
end

function Economia.olvidar(jugador: Player)
	ultimoPedido[jugador] = nil
end

return Economia
