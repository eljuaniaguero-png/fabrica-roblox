--!strict
-- Viste al jugador con el cuerpo cómic urbano: las piezas de ServerStorage.CuerpoComic se sueldan
-- a los huesos R15 del personaje. Solo corre en el servidor. Los civiles siguen con Apariencia.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)

local CuerpoComic = {}

local C = Config.Cuerpo.Comic

local function pegar(personaje: Model, molde: Model, pieza: BasePart)
	local hueso = pieza:GetAttribute("Hueso")
	local parte = typeof(hueso) == "string" and personaje:FindFirstChild(hueso)
	local reposo = typeof(hueso) == "string" and molde:FindFirstChild(hueso)
	if not (parte and parte:IsA("BasePart") and reposo and reposo:IsA("BasePart")) then
		warn("CuerpoComic: pieza sin hueso", pieza.Name)
		return
	end
	local copia = pieza:Clone()
	copia.Anchored = false
	copia.CFrame = parte.CFrame * reposo.CFrame:ToObjectSpace(pieza.CFrame)
	local union = Instance.new("Weld")
	union.Part0 = parte
	union.Part1 = copia
	union.C0 = reposo.CFrame:ToObjectSpace(pieza.CFrame)
	union.Parent = copia
	local apariencia = copia:FindFirstChildOfClass("SurfaceAppearance")
	if apariencia then
		apariencia.Color = C.ColorPelo
	end
	copia.Parent = personaje
end

function CuerpoComic.vestir(personaje: Model, semilla: number)
	local carpeta = ServerStorage:FindFirstChild("CuerpoComic")
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (carpeta and molde and molde:IsA("Model")) then
		warn("CuerpoComic: falta ServerStorage.CuerpoComic o StarterCharacter")
		return
	end
	local azar = Random.new(semilla)
	local peinado = C.Peinados[azar:NextInteger(1, #C.Peinados)]
	local cara = C.Caras[azar:NextInteger(1, #C.Caras)]
	for _, parte in personaje:GetChildren() do
		if parte:IsA("BasePart") then
			parte.Transparency = 1
		end
	end
	local lista = table.clone(C.Piezas)
	table.insert(lista, peinado)
	for _, nombre in lista do
		local grupo = carpeta:FindFirstChild(nombre)
		if grupo then
			for _, pieza in grupo:GetDescendants() do
				if pieza:IsA("BasePart") then
					pegar(personaje, molde, pieza)
				end
			end
		else
			warn("CuerpoComic: falta la pieza", nombre)
		end
	end
	local cabeza = personaje:FindFirstChild("Cuerpo_Head")
	if cabeza then
		local decal = Instance.new("Decal")
		decal.Name = "Cara"
		decal.Face = Enum.NormalId.Front
		decal.Texture = cara
		decal.Parent = cabeza
	end
end

return CuerpoComic
