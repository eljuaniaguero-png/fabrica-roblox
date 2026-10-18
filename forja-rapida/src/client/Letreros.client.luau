--!strict
-- Carteles de los lugares (Banco, Tienda, Ruleta, Museo...). El servidor (GeneradorMapa) solo
-- marca la parte con el tag "Letrero" y sus atributos; acá se dibuja con Estilo.cartelLugar.

local CollectionService = game:GetService("CollectionService")

local Estilo = require(script.Parent.Estilo)

local function dibujar(p: Instance)
	if not p:IsA("BasePart") or p:FindFirstChild("CartelLugar") then
		return
	end
	local texto = p:GetAttribute("LetreroTexto")
	local color = p:GetAttribute("LetreroColor")
	local alto = p:GetAttribute("LetreroAlto")
	local icono = p:GetAttribute("LetreroIcono")
	if typeof(texto) ~= "string" then
		return
	end
	local b = Estilo.cartelLugar(
		p,
		if typeof(alto) == "number" then alto else 4,
		texto,
		if typeof(icono) == "string" then icono else nil,
		if typeof(color) == "string" then Color3.fromHex(color) else nil
	)
	b.Parent = p
end

CollectionService:GetInstanceAddedSignal("Letrero"):Connect(dibujar)
for _, p in CollectionService:GetTagged("Letrero") do
	dibujar(p)
end
