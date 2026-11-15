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
	Marca: number?,
	Contextura: number?,
	Altura: number?,
	Remera: number?,
	Zapatillas: number?,
	Bando: number?,
}

local HUESOS_SUPERIORES: { [string]: boolean } = {
	UpperTorso = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
}

local HUESOS_INFERIORES: { [string]: boolean } = {
	LowerTorso = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

local function idxSeguro(valor: number?, lista: { any }, fallback: number): number
	if typeof(valor) == "number" and valor >= 1 and valor <= #lista then
		return valor
	end
	return fallback
end

-- Color final de cada opción del creador (índices ya validados por el servidor).
local function colores(a: Apariencia): { [string]: Color3 }
	local campera = Color3.fromHex(CR.Campera[idxSeguro(a.Campera, CR.Campera, CR.Inicial.Campera)])
	return {
		Piel = Config.Cuerpo.TonosPiel[idxSeguro(a.Piel, Config.Cuerpo.TonosPiel, CR.Inicial.Piel)],
		Campera = campera,
		CamperaOscura = campera:Lerp(Color3.new(0, 0, 0), 1 - CR.Oscurecer),
		Acento = Color3.fromHex(CR.Acento[idxSeguro(a.Acento, CR.Acento, CR.Inicial.Acento)]),
		Pantalon = Color3.fromHex(
			CR.Pantalon[idxSeguro(a.Pantalon, CR.Pantalon, CR.Inicial.Pantalon)]
		),
		Remera = Color3.fromHex(CR.Remera[idxSeguro(a.Remera, CR.Remera, CR.Inicial.Remera)]),
		Zapatillas = Color3.fromHex(
			CR.Zapatillas[idxSeguro(a.Zapatillas, CR.Zapatillas, CR.Inicial.Zapatillas)]
		),
	}
end

local function anchoParaHueso(hueso: string, hombros: number, cadera: number): number
	if HUESOS_SUPERIORES[hueso] then
		return hombros
	elseif HUESOS_INFERIORES[hueso] then
		return cadera
	end
	return 1
end

local function parcheBando(copia: BasePart, bandoNombre: string)
	local img = (Config.Hud.Imagenes.Bandos :: any)[bandoNombre]
		or Config.Hud.Imagenes.Bandos.Neutral
	if typeof(img) ~= "string" or img == "" then
		return
	end
	local hex = (CR.BandoColores :: any)[bandoNombre] or CR.BandoColores.Neutral
	copia.Color = Color3.fromHex(hex):Lerp(Color3.fromHex("d7d2c4"), 0.55)
	local existente = copia:FindFirstChild("ParcheBando")
	local decal = if existente and existente:IsA("Decal") then existente else Instance.new("Decal")
	decal.Name = "ParcheBando"
	decal.Face = Enum.NormalId.Back
	decal.Texture = img
	decal.Parent = copia
end

local function pegar(
	personaje: Model,
	molde: Model,
	pieza: BasePart,
	grupoNombre: string,
	tinte: { [string]: Color3 }?,
	pelo: Color3,
	bandoNombre: string,
	hombros: number,
	cadera: number
)
	local hueso = pieza:GetAttribute("Hueso")
	local parte = typeof(hueso) == "string" and personaje:FindFirstChild(hueso)
	local reposo = typeof(hueso) == "string" and molde:FindFirstChild(hueso)
	if not (parte and parte:IsA("BasePart") and reposo and reposo:IsA("BasePart")) then
		warn("CuerpoComic: pieza sin hueso", pieza.Name)
		return
	end
	local ancho = anchoParaHueso(hueso :: string, hombros, cadera)
	local copia = pieza:Clone()
	copia.Anchored = false
	if ancho ~= 1 then
		copia.Size = Vector3.new(pieza.Size.X * ancho, pieza.Size.Y, pieza.Size.Z * ancho)
	end
	local c0 = reposo.CFrame:ToObjectSpace(pieza.CFrame)
	if ancho ~= 1 then
		c0 = CFrame.new(c0.Position.X * ancho, c0.Position.Y, c0.Position.Z * ancho)
			* (c0 - c0.Position)
	end
	copia.CFrame = parte.CFrame * c0
	local union = Instance.new("Weld")
	union.Part0 = parte
	union.Part1 = copia
	union.C0 = c0
	union.Parent = copia

	local esPelo = string.sub(grupoNombre, 1, 4) == "Pelo"
	local apariencia = copia:FindFirstChildOfClass("SurfaceAppearance")
	if apariencia then
		apariencia.Color = pelo
	end
	if esPelo then
		if grupoNombre == "PeloCresta" and string.find(pieza.Name, "_L") then
			copia.Color = pelo:Lerp(Color3.new(0, 0, 0), 0.48)
		else
			copia.Color = pelo
		end
	elseif grupoNombre == "Zapatillas" and tinte and tinte.Zapatillas then
		copia.Color = tinte.Zapatillas
	elseif pieza.Name == "Campera_ParcheCentro" then
		parcheBando(copia, bandoNombre)
	elseif tinte then
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
		nueva.ZIndex = 1
		nueva.Texture = destino
		nueva.Parent = cabeza
	end
end

local function ponerMarca(personaje: Model, indice: number)
	local cabeza = personaje:FindFirstChild("Cuerpo_Head")
	if not cabeza then
		return
	end
	local existente = cabeza:FindFirstChild("MarcaFacial")
	local textura = if indice >= 1 then Config.Cuerpo.Marcas[indice] else nil
	if not textura or textura == "" then
		if existente then
			existente:Destroy()
		end
		return
	end
	local decal = if existente and existente:IsA("Decal") then existente else Instance.new("Decal")
	decal.Name = "MarcaFacial"
	decal.Face = Enum.NormalId.Front
	decal.ZIndex = 2
	decal.Texture = textura
	decal.Parent = cabeza
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
	if math.abs(personaje:GetScale() - 1) > 0.001 then
		personaje:ScaleTo(1)
	end

	local azar = Random.new(semilla)
	local peinado = C.Peinados[azar:NextInteger(1, #C.Peinados)]
	local cara = C.Caras[azar:NextInteger(1, #C.Caras)]
	local pelo = C.ColorPelo
	local tinte: { [string]: Color3 }? = nil
	local marca = 0
	local bandoNombre = "Neutral"
	local hombros, cadera, altura = 1, 1, 1

	if apariencia then
		peinado = C.Peinados[idxSeguro(apariencia.Peinado, C.Peinados, CR.Inicial.Peinado)]
		cara = C.Caras[idxSeguro(apariencia.Cara, C.Caras, CR.Inicial.Cara)]
		pelo = Color3.fromHex(
			Config.Cuerpo.ColoresPelo[idxSeguro(
				apariencia.Pelo,
				Config.Cuerpo.ColoresPelo,
				CR.Inicial.Pelo
			)]
		)
		tinte = colores(apariencia)
		if typeof(apariencia.Marca) == "number" and Config.Cuerpo.Marcas[apariencia.Marca] then
			marca = apariencia.Marca
		end
		bandoNombre = CR.Bandos[idxSeguro(apariencia.Bando, CR.Bandos, CR.Inicial.Bando)]
			or "Neutral"
		local ctxNombre =
			CR.Contexturas[idxSeguro(apariencia.Contextura, CR.Contexturas, CR.Inicial.Contextura)]
		local ctx = Config.Cuerpo.Contexturas[ctxNombre]
		if ctx then
			hombros, cadera = ctx.Hombros, ctx.Cadera
		end
		local altNombre = CR.Alturas[idxSeguro(apariencia.Altura, CR.Alturas, CR.Inicial.Altura)]
		altura = Config.Cuerpo.Alturas[altNombre] or 1
	end

	for _, parte in personaje:GetChildren() do
		if parte:IsA("BasePart") then
			parte.Transparency = 1
		end
	end

	local lista = table.clone(C.Piezas)
	if peinado ~= "Rapado" then
		table.insert(lista, peinado)
	end
	for _, nombre in lista do
		local grupo = carpeta:FindFirstChild(nombre)
		if grupo then
			for _, pieza in grupo:GetDescendants() do
				if pieza:IsA("BasePart") then
					pegar(
						personaje,
						molde,
						pieza,
						nombre,
						tinte,
						pelo,
						bandoNombre,
						hombros,
						cadera
					)
				end
			end
		else
			warn("CuerpoComic: falta la pieza", nombre)
		end
	end

	if math.abs(altura - 1) > 0.001 then
		personaje:ScaleTo(altura)
	end
	personaje:SetAttribute("CaraBase", cara)
	CuerpoComic.cara(personaje, cara)
	ponerMarca(personaje, marca)
end

return CuerpoComic
