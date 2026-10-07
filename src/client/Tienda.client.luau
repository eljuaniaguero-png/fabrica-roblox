--!strict
-- Abre y cierra la tienda y le pide compras al servidor (el servidor cobra y valida).
-- HUD > Panel > BotonTienda (TextButton)
-- HUD > Tienda (Frame) > Cerrar (TextButton), Lista > [Turbo|Resorte|Escudo|Zapatillas] > Nombre, Descripcion, Comprar

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)

local jugador = Players.LocalPlayer
local hud = jugador:WaitForChild("PlayerGui"):WaitForChild("HUD")
local botonTienda = hud:WaitForChild("Panel"):WaitForChild("BotonTienda") :: TextButton
local tienda = hud:WaitForChild("Tienda") :: Frame
local botonCerrar = tienda:WaitForChild("Cerrar") :: TextButton
local lista = tienda:WaitForChild("Lista")

local pedirCompra = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Comprar") :: RemoteEvent

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

type Fila = { nombre: TextLabel, descripcion: TextLabel, comprar: TextButton }

local function fila(articulo: string): Fila?
	local marco = lista:FindFirstChild(articulo)
	if not marco then
		warn(`[Tienda] Falta la fila {articulo} en el HUD`)
		return nil
	end
	return {
		nombre = marco:WaitForChild("Nombre") :: TextLabel,
		descripcion = marco:WaitForChild("Descripcion") :: TextLabel,
		comprar = marco:WaitForChild("Comprar") :: TextButton,
	}
end

local filas: { [string]: Fila } = {}
local articulos = table.clone(Config.OrdenConsumibles)
table.insert(articulos, "Zapatillas")
for _, articulo in articulos do
	local f = fila(articulo)
	if f then
		filas[articulo] = f
		f.comprar.Activated:Connect(function()
			pedirCompra:FireServer(articulo)
		end)
	end
end

local function actualizar()
	local monedas = atributoNumero("Monedas")
	for nombre, f in filas do
		local precio: number
		if nombre == "Zapatillas" then
			local nivel = atributoNumero("Zapatillas")
			local z = Config.Zapatillas
			f.nombre.Text = `{z.Nombre} (nivel {nivel})`
			f.descripcion.Text = z.Descripcion
			if nivel >= z.NivelMaximo then
				f.comprar.Text = "MÁXIMO"
				f.comprar.AutoButtonColor = false
				continue
			end
			precio = Precios.zapatillas(nivel)
		else
			local c = Config.Consumibles[nombre]
			f.nombre.Text = `{c.Nombre} (tenés {atributoNumero(`Inv_{nombre}`)})`
			f.descripcion.Text = c.Descripcion
			precio = c.Precio
		end
		f.comprar.Text = `{precio} monedas`
		f.comprar.AutoButtonColor = monedas >= precio
		f.comprar.TextTransparency = if monedas >= precio then 0 else 0.5
	end
end

botonTienda.Activated:Connect(function()
	tienda.Visible = not tienda.Visible
	actualizar()
end)

botonCerrar.Activated:Connect(function()
	tienda.Visible = false
end)

jugador.AttributeChanged:Connect(function()
	if tienda.Visible then
		actualizar()
	end
end)

tienda.Visible = false
actualizar()
