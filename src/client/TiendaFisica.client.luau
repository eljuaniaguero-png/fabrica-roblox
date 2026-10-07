--!strict
-- Actualiza los carteles de los puestos de la tienda y del portal de rebirth con tus números.
-- Es solo visual: comprar y hacer rebirth lo valida el servidor (Economia.luau, Rebirth.luau).
--
-- En el mapa:
--   puesto = BasePart con atributo Articulo, un ProximityPrompt y un BillboardGui "Cartel" > Precio (TextLabel)
--   portal = BasePart con atributo PortalRebirth = true, igual que arriba

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)

local jugador = Players.LocalPlayer

local COLOR_ALCANZA = Color3.fromRGB(43, 210, 255)
local COLOR_FALTA = Color3.fromRGB(170, 160, 210)

type Puesto = { articulo: string?, precio: TextLabel }
-- Con streaming, las partes llegan y se van mientras jugás: se registran por parte.
local puestos: { [BasePart]: Puesto } = {}

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

local function pintar(puesto: Puesto, texto: string, alcanza: boolean)
	puesto.precio.Text = texto
	puesto.precio.TextColor3 = if alcanza then COLOR_ALCANZA else COLOR_FALTA
end

local function actualizarPuesto(puesto: Puesto)
	local monedas = atributoNumero("Monedas")
	local articulo = puesto.articulo
	if not articulo then
		-- Portal de rebirth
		local velocidad = atributoNumero("Velocidad")
		if velocidad >= Config.CostoRebirth then
			local ganadas = Precios.monedasPorRebirth(velocidad, atributoNumero("Mej_Bolsillo"))
			pintar(puesto, `+{ganadas} monedas`, true)
		else
			pintar(puesto, `Necesitás {Config.CostoRebirth} de velocidad`, false)
		end
		return
	end

	local mejora = Config.Mejoras[articulo]
	if mejora then
		local nivel = atributoNumero(`Mej_{articulo}`)
		local precio = Precios.mejora(articulo, nivel)
		if precio then
			pintar(puesto, `Nivel {nivel} · {precio} monedas`, monedas >= precio)
		else
			pintar(puesto, "MÁXIMO", false)
		end
		return
	end

	local consumible = Config.Consumibles[articulo]
	if consumible then
		local cantidad = atributoNumero(`Inv_{articulo}`)
		pintar(
			puesto,
			`{consumible.Precio} monedas · tenés {cantidad}`,
			monedas >= consumible.Precio
		)
	end
end

local function actualizar()
	for _, puesto in puestos do
		actualizarPuesto(puesto)
	end
end

local function registrar(parte: Instance)
	if not parte:IsA("BasePart") or puestos[parte] then
		return
	end
	local articulo = parte:GetAttribute("Articulo")
	local esPortal = parte:GetAttribute("PortalRebirth") == true
	if typeof(articulo) ~= "string" and not esPortal then
		return
	end
	local cartel = parte:FindFirstChild("Cartel")
	local precio = if cartel then cartel:FindFirstChild("Precio", true) else nil
	if not precio or not precio:IsA("TextLabel") then
		return
	end
	local puesto: Puesto = {
		articulo = if typeof(articulo) == "string" then articulo else nil,
		precio = precio,
	}
	puestos[parte] = puesto
	actualizarPuesto(puesto)
end

for _, parte in workspace:GetDescendants() do
	registrar(parte)
end
workspace.DescendantAdded:Connect(function(objeto)
	-- El cartel puede llegar después que la parte: se reintenta cuando aparece el texto del precio.
	local parte = if objeto:IsA("BasePart")
		then objeto
		else objeto:FindFirstAncestorWhichIsA("BasePart")
	if parte then
		registrar(parte)
	end
end)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		puestos[objeto] = nil
	end
end)
jugador.AttributeChanged:Connect(actualizar)
