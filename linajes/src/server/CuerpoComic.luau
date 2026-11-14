--!strict
-- Viste al jugador con el cuerpo cómic urbano: las piezas de ServerStorage.CuerpoComic se sueldan
-- a los huesos R15 del personaje. Solo corre en el servidor. Los civiles siguen con Apariencia.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)

local CuerpoComic = {}

local C = Config.Cuerpo.Comic
local CR = Config.Cuerpo.Creador

export type Apariencia = {
	Piel: number,
	Cara: number,
	Peinado: number,
	Pelo: number,
	Campera: number,
	Acento: number,
	Pantalon: number,
}

-- Color final de cada opción del creador (índices ya validados por el servidor).
local function colores(a: Apariencia): { [string]: Color3 }
	local campera = Color3.fromHex(CR.Campera[a.Campera])
	return {
		Piel = Config.Cuerpo.TonosPiel[a.Piel],
		Campera = campera,
		CamperaOscura = campera:Lerp(Color3.new(0, 0, 0), 1 - CR.Oscurecer),
		Acento = Color3.fromHex(CR.Acento[a.Acento]),
		Pantalon = Color3.fromHex(CR.Pantalon[a.Pantalon]),
	}
end

local function pegar(
	personaje: Model,
	molde: Model,
	pieza: BasePart,
	tinte: { [string]: Color3 }?,
	pelo: Color3
)
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
		apariencia.Color = pelo
	end
	if tinte then
		local opcion = (CR.Molde :: any)[string.lower(pieza.Color:ToHex())]
		if opcion and tinte[opcion] then
			copia.Color = tinte[opcion]
		end
	end
	copia:SetAttribute("PiezaCuerpo", true)
	copia.Parent = personaje
end

-- Cambia la cara de un personaje vestido con CuerpoComic; nil restaura su cara base.
function CuerpoComic.cara(personaje: Model, textura: string?)
	local destino = textura or (personaje:GetAttribute("CaraBase") :: string?)
	if typeof(destino) ~= "string" or destino == "" then
		return
	end
	local cabeza = personaje:FindFirstChild("Cuerpo_Head")
	if not cabeza then
		return
	end
	local decal = cabeza:FindFirstChild("Cara")
	if decal and decal:IsA("Decal") then
		decal.Texture = destino
	else
		local nueva = Instance.new("Decal")
		nueva.Name = "Cara"
		nueva.Face = Enum.NormalId.Front
		nueva.Texture = destino
		nueva.Parent = cabeza
	end
end

-- Viste al personaje. Con `apariencia` usa lo elegido en el creador; sin ella, al azar fijo por
-- `semilla` (maniquí de práctica). Si ya estaba vestido, saca lo anterior primero.
function CuerpoComic.vestir(personaje: Model, semilla: number, apariencia: Apariencia?)
	local carpeta = ServerStorage:FindFirstChild("CuerpoComic")
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (carpeta and molde and molde:IsA("Model")) then
		warn("CuerpoComic: falta ServerStorage.CuerpoComic o StarterCharacter")
		return
	end
	for _, viejo in personaje:GetChildren() do
		if viejo:GetAttribute("PiezaCuerpo") then
			viejo:Destroy()
		end
	end
	local azar = Random.new(semilla)
	local peinado = C.Peinados[azar:NextInteger(1, #C.Peinados)]
	local cara = C.Caras[azar:NextInteger(1, #C.Caras)]
	local pelo = C.ColorPelo
	local tinte: { [string]: Color3 }? = nil
	if apariencia then
		peinado = C.Peinados[apariencia.Peinado]
		cara = C.Caras[apariencia.Cara]
		pelo = Color3.fromHex(Config.Cuerpo.ColoresPelo[apariencia.Pelo])
		tinte = colores(apariencia)
	end
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
					pegar(personaje, molde, pieza, tinte, pelo)
				end
			end
		else
			warn("CuerpoComic: falta la pieza", nombre)
		end
	end
	personaje:SetAttribute("CaraBase", cara)
	CuerpoComic.cara(personaje, cara)
end

return CuerpoComic
