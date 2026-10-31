--!strict
-- Viste civiles con el kit de ropa (ServerStorage.Civiles): elige piezas y colores al azar y
-- pega cada malla a su parte del cuerpo con el desfase guardado. Solo corre en el servidor.

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local C = Config.Civiles

local Civiles = {}

-- Pieza -> { Color1, Color2 } en hex.
export type Receta = { [string]: { string } }

local TIPOS = { "Arriba", "Abajo", "Cabeza", "Accesorio", "Telefono", "Especial" }

local function carpetaDe(pieza: string): Instance?
	local kit = ServerStorage:FindFirstChild("Civiles")
	if not kit then
		return nil
	end
	for _, tipo in TIPOS do
		local carpeta = kit:FindFirstChild(tipo)
		local p = carpeta and carpeta:FindFirstChild(pieza)
		if p then
			return p
		end
	end
	return nil
end

local function elegir(r: Random, lista: { string }): string
	return lista[r:NextInteger(1, #lista)]
end

-- Ropa al azar: 1 de arriba, 1 de abajo, 1 de cabeza y a veces un accesorio.
function Civiles.recetaAlAzar(r: Random, lluvia: boolean?): Receta
	local receta: Receta = {}
	local piezas = { elegir(r, C.Arriba), elegir(r, C.Abajo), elegir(r, C.Cabeza) }
	if r:NextNumber() < C.ChanceAccesorio then
		local acc = elegir(r, C.Accesorio)
		if lluvia and acc == "ParaguasCerrado" then
			acc = C.ParaguasLluvia
		end
		table.insert(piezas, acc)
	end
	for _, pieza in piezas do
		local color1 = if C.Pelos[pieza] then elegir(r, C.PaletaPelo) else elegir(r, C.PaletaRopa)
		local color2 = C.Color2Fijo[pieza]
			or (
				if C.Pelos[pieza] then elegir(r, C.PaletaAccesorioPelo) else elegir(r, C.PaletaRopa)
			)
		receta[pieza] = { color1, color2 }
	end
	return receta
end

-- Receta fija de un civil especial (diarero, vendedor, músico).
function Civiles.recetaEspecial(nombre: string): Receta?
	local e = C.Especiales[nombre]
	if not e then
		return nil
	end
	local receta: Receta = {}
	for _, pieza in e.Piezas do
		receta[pieza] = e.Colores[pieza]
	end
	receta[nombre] = e.Colores[nombre]
	return receta
end

-- Pega una copia de cada malla de la pieza a la parte del cuerpo que dice su atributo Hueso.
local function ponerPieza(personaje: Model, pieza: string, colores: { string }?): { BasePart }
	local molde = carpetaDe(pieza)
	local puestas = {}
	if not molde then
		warn("Falta la pieza de civil", pieza, "en ServerStorage.Civiles")
		return puestas
	end
	for _, malla in molde:GetChildren() do
		if not malla:IsA("BasePart") then
			continue
		end
		local hueso = malla:GetAttribute("Hueso")
		local desfase = malla:GetAttribute("Desfase")
		local parte = if typeof(hueso) == "string" then personaje:FindFirstChild(hueso) else nil
		if not (parte and parte:IsA("BasePart") and typeof(desfase) == "CFrame") then
			continue
		end
		local copia = malla:Clone()
		local canal = copia:GetAttribute("Canal")
		if colores and canal == "C1" then
			copia.Color = Color3.fromHex(colores[1])
		elseif colores and canal == "C2" then
			copia.Color = Color3.fromHex(colores[2])
		end
		copia.Anchored = false
		copia.CanCollide = false
		copia.CanTouch = false
		copia.CanQuery = false
		copia.Massless = true
		copia.CFrame = parte.CFrame * desfase
		local soldadura = Instance.new("WeldConstraint")
		soldadura.Part0 = parte
		soldadura.Part1 = copia
		soldadura.Parent = copia
		copia:SetAttribute("PiezaCivil", pieza)
		copia.Parent = personaje
		table.insert(puestas, copia)
	end
	return puestas
end

-- Saca la ropa de civil que tenga y le pone la de la receta.
function Civiles.vestir(personaje: Model, receta: Receta)
	for _, d in personaje:GetChildren() do
		if d:GetAttribute("PiezaCivil") ~= nil then
			d:Destroy()
		end
	end
	for pieza, colores in receta do
		ponerPieza(personaje, pieza, colores)
	end
end

-- Muestra u oculta el teléfono en la mano (cuando llama a la policía). La pantalla brilla cian.
-- Mientras llama se esconde lo que tenga en la mano derecha (café, maletín, paraguas): las dos
-- cosas ocupan el mismo lugar.
function Civiles.telefono(personaje: Model, mostrar: boolean)
	for _, d in personaje:GetChildren() do
		if d:GetAttribute("PiezaCivil") == "Telefono" then
			d:Destroy()
		elseif
			d:IsA("BasePart")
			and d:GetAttribute("PiezaCivil") ~= nil
			and d:GetAttribute("Hueso") == "RightHand"
		then
			d.Transparency = if mostrar then 1 else 0
		end
	end
	if mostrar then
		ponerPieza(personaje, "Telefono", { "1b1f2a", "3a3f4b" })
	end
end

return Civiles
