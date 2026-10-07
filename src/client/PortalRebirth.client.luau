--!strict
-- Actualiza el cartel del portal de rebirth con tus números.
-- Es solo visual: el rebirth lo valida el servidor (Rebirth.luau).
--
-- En el mapa: portal = BasePart con atributo PortalRebirth = true, un ProximityPrompt
-- y un BillboardGui "Cartel" > Precio (TextLabel).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Precios = require(ReplicatedStorage.Shared.Precios)

local jugador = Players.LocalPlayer

-- Con streaming, el portal puede llegar e irse mientras jugás: se guarda por parte.
local carteles: { [BasePart]: TextLabel } = {}

local function atributoNumero(nombre: string): number
	local valor = jugador:GetAttribute(nombre)
	return if typeof(valor) == "number" then valor else 0
end

local function pintar(precio: TextLabel)
	local velocidad = atributoNumero("Velocidad")
	if velocidad >= Config.CostoRebirth then
		local ganadas = Precios.monedasPorRebirth(velocidad, atributoNumero("Mej_Bolsillo"))
		precio.Text = `+{ganadas} monedas`
		precio.TextColor3 = Config.Paleta.Cian
	else
		precio.Text = `Necesitás {Config.CostoRebirth} de velocidad`
		precio.TextColor3 = Color3.fromRGB(170, 160, 210)
	end
end

local function registrar(objeto: Instance)
	-- El cartel puede llegar después que la parte: se reintenta cuando aparece cualquier hijo.
	local parte = if objeto:IsA("BasePart")
		then objeto
		else objeto:FindFirstAncestorWhichIsA("BasePart")
	if not parte or carteles[parte] or parte:GetAttribute("PortalRebirth") ~= true then
		return
	end
	local cartel = parte:FindFirstChild("Cartel")
	local precio = if cartel then cartel:FindFirstChild("Precio", true) else nil
	if precio and precio:IsA("TextLabel") then
		carteles[parte] = precio
		pintar(precio)
	end
end

for _, objeto in workspace:GetDescendants() do
	registrar(objeto)
end
workspace.DescendantAdded:Connect(registrar)
workspace.DescendantRemoving:Connect(function(objeto)
	if objeto:IsA("BasePart") then
		carteles[objeto] = nil
	end
end)
jugador.AttributeChanged:Connect(function()
	for _, precio in carteles do
		pintar(precio)
	end
end)
