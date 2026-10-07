--!strict
-- Tienda con vendedor: el cliente pide comprar o vender desde el menú y el servidor valida todo
-- (que esté cerca del vendedor, que no pida muy seguido, que le alcance).
--
-- En el mapa: un Model con atributo Vendedor = true (el ProximityPrompt "Hablar" lo usa el cliente).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)
local Datos = require(script.Parent.Datos)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Economia = {}

local ultimoPedido: { [Player]: number } = {}
local vendedor: Model? = nil

local function muyRapido(jugador: Player): boolean
	local ahora = os.clock()
	if ahora - (ultimoPedido[jugador] or 0) < Config.EsperaCompra then
		return true
	end
	ultimoPedido[jugador] = ahora
	return false
end

local function cercaDelVendedor(jugador: Player): boolean
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not vendedor or not raiz or not raiz:IsA("BasePart") then
		return false
	end
	return (raiz.Position - vendedor:GetPivot().Position).Magnitude <= Config.DistanciaVendedor
end

-- Perfil del jugador si el pedido es válido (cerca, sin apuro); si no, nil.
local function pedidoValido(jugador: Player): Datos.Perfil?
	local perfil = Datos.obtener(jugador)
	if not perfil or muyRapido(jugador) then
		return nil
	end
	if not cercaDelVendedor(jugador) then
		Remotos.avisar(jugador, `Acercate a {Config.NombreVendedor}`, "Error")
		return nil
	end
	return perfil
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

-- Cosmético: si no lo tenés, se cobra y se pone. Si ya lo tenés, tocarlo lo pone o lo saca (gratis).
local function comprarCosmetico(jugador: Player, perfil: Datos.Perfil, nombre: string)
	local cosmetico = Config.Cosmeticos[nombre]
	if perfil.Cosmeticos[nombre] then
		local puesto = perfil.Equipados[cosmetico.Tipo] == nombre
		perfil.Equipados[cosmetico.Tipo] = if puesto then nil else nombre
		Velocidad.aplicar(jugador)
		Remotos.avisar(
			jugador,
			if puesto then `Te sacaste {cosmetico.Nombre}` else `Te pusiste {cosmetico.Nombre}`,
			"Recoger"
		)
		return
	end
	if not cobrar(jugador, perfil, cosmetico.Precio) then
		return
	end
	perfil.Cosmeticos[nombre] = true
	perfil.Equipados[cosmetico.Tipo] = nombre
	Velocidad.aplicar(jugador)
	-- SONIDO: compra (Config.Efectos.Compra)
	Remotos.avisar(jugador, `¡{cosmetico.Nombre}!`, "Compra")
end

local function comprar(jugador: Player, articulo: unknown)
	if typeof(articulo) ~= "string" then
		return
	end
	if
		not Config.Mejoras[articulo]
		and not Config.Consumibles[articulo]
		and not Config.Cosmeticos[articulo]
	then
		return
	end
	local perfil = pedidoValido(jugador)
	if not perfil then
		return
	end
	if Config.Mejoras[articulo] then
		comprarMejora(jugador, perfil, articulo)
	elseif Config.Consumibles[articulo] then
		comprarConsumible(jugador, perfil, articulo)
	else
		comprarCosmetico(jugador, perfil, articulo)
	end
end

-- Vende todos los pasos disponibles que alcancen para monedas enteras. Los pasos totales
-- (los del nivel) no se tocan.
local function venderPasos(jugador: Player)
	local perfil = pedidoValido(jugador)
	if not perfil then
		return
	end
	local monedas = Precios.monedasPorPasos(perfil.PasosDisponibles)
	if monedas <= 0 then
		Remotos.avisar(jugador, `Necesitás al menos {Config.PasosPorMoneda} pasos`, "Error")
		return
	end
	perfil.PasosDisponibles -= monedas * Config.PasosPorMoneda
	perfil.Monedas += monedas
	Velocidad.aplicar(jugador)
	-- SONIDO: venta de pasos (Config.Efectos.Vender)
	Remotos.avisar(jugador, `+{monedas} monedas`, "Vender")
end

function Economia.iniciar()
	for _, objeto in workspace:GetDescendants() do
		if objeto:IsA("Model") and objeto:GetAttribute("Vendedor") == true then
			vendedor = objeto
		end
	end
	if not vendedor then
		warn("[Tienda] No hay vendedor en el mapa (Model con atributo Vendedor = true)")
	end
	Remotos.Comprar.OnServerEvent:Connect(comprar)
	Remotos.VenderPasos.OnServerEvent:Connect(venderPasos)
end

function Economia.olvidar(jugador: Player)
	ultimoPedido[jugador] = nil
end

return Economia
