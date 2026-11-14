--!strict
-- Arma el cuerpo propio (StarterCharacter) con lo que eligió el jugador: tono, cara,
-- expresión, marca, peinado y color, contextura y altura. Solo corre en el servidor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Apariencia = {}

export type Datos = {
	Contextura: string,
	Altura: string,
	Tono: number,
	Cara: number,
	Peinado: string,
	ColorPelo: string,
	Marca: number,
}

local C = Config.Cuerpo

local function entero(v: any, minimo: number, maximo: number, defecto: number): number
	if typeof(v) == "number" and v == v and v % 1 == 0 and v >= minimo and v <= maximo then
		return v
	end
	return defecto
end

-- Datos válidos: lo que no está en las listas vuelve al valor inicial.
function Apariencia.limpiar(d: any): Datos
	local base = C.Inicial
	local t = if typeof(d) == "table" then d else {}
	local function clave(v: any, lista: { [string]: any }, defecto: string): string
		return if typeof(v) == "string" and lista[v] ~= nil then v else defecto
	end
	local peinado = if typeof(t.Peinado) == "string" and table.find(C.Peinados, t.Peinado)
		then t.Peinado
		else base.Peinado
	local colorPelo = if typeof(t.ColorPelo) == "string"
			and string.match(t.ColorPelo, "^%x%x%x%x%x%x$")
		then t.ColorPelo
		else base.ColorPelo
	return {
		Contextura = clave(t.Contextura, C.Contexturas, base.Contextura),
		Altura = clave(t.Altura, C.Alturas, base.Altura),
		Tono = entero(t.Tono, 1, #C.TonosPiel, base.Tono),
		Cara = entero(t.Cara, 1, #C.Caras, base.Cara),
		Peinado = peinado,
		ColorPelo = colorPelo,
		Marca = entero(t.Marca, 0, #C.Marcas, base.Marca),
	}
end

-- Apariencia al azar (fija para cada UserId) hasta que exista el creador de personaje.
function Apariencia.porDefecto(userId: number): Datos
	local r = Random.new(userId)
	local contexturas = { "Normal", "Ancha", "Delgada" }
	local alturas = { "Baja", "Media", "Alta" }
	local contextura = contexturas[r:NextInteger(1, 3)]
	local altura = alturas[r:NextInteger(1, 3)]
	local tono = r:NextInteger(1, #C.TonosPiel)
	local cara = r:NextInteger(1, #C.Caras)
	local peinado = C.Peinados[r:NextInteger(1, #C.Peinados)]
	-- Solo colores de pelo que se distingan de la piel (si no, el pelo "desaparece").
	local piel = C.TonosPiel[tono]
	local colores = {}
	for _, hex in C.ColoresPelo do
		local c = Color3.fromHex(hex)
		local d = Vector3.new(c.R - piel.R, c.G - piel.G, c.B - piel.B).Magnitude
		if d >= C.ContrastePelo then
			table.insert(colores, hex)
		end
	end
	if #colores == 0 then
		colores = C.ColoresPelo
	end
	return {
		Contextura = contextura,
		Altura = altura,
		Tono = tono,
		Cara = cara,
		Peinado = peinado,
		ColorPelo = colores[r:NextInteger(1, #colores)],
		Marca = if r:NextNumber() < 0.3 then r:NextInteger(1, #C.Marcas) else 0,
	}
end

local function decal(cabeza: BasePart, nombre: string, textura: string, z: number)
	local d = cabeza:FindFirstChild(nombre)
	if not (d and d:IsA("Decal")) then
		local nuevo = Instance.new("Decal")
		nuevo.Name = nombre
		nuevo.Face = Enum.NormalId.Front
		nuevo.ZIndex = z
		nuevo.Parent = cabeza
		d = nuevo
	end
	(d :: Decal).Texture = textura
end

-- Cambia la expresión (neutral, enojado, contento...) de un personaje ya armado.
function Apariencia.expresion(personaje: Model, expresion: string)
	local cabeza = personaje:FindFirstChild("Head")
	local cara = personaje:GetAttribute("CuerpoCara")
	if
		not (cabeza and cabeza:IsA("BasePart"))
		or typeof(cara) ~= "number"
		or not table.find(C.Expresiones, expresion)
	then
		return
	end
	decal(cabeza, "Cara", C.Caras[cara][expresion], 1)
	personaje:SetAttribute("Expresion", expresion)
end

-- Ensancha hombros y cadera sin tocar los huesos de las animaciones: escala el ancho del torso
-- y corre hacia afuera (o adentro) las articulaciones de brazos y piernas.
local function contextura(personaje: Model, nombre: string)
	local k = C.Contexturas[nombre]
	local factores = { UpperTorso = k.Hombros, LowerTorso = k.Cadera }
	for parte, factor in factores do
		local p = personaje:FindFirstChild(parte)
		if p and p:IsA("BasePart") and factor ~= 1 then
			p.Size = Vector3.new(p.Size.X * factor, p.Size.Y, p.Size.Z)
		end
	end
	for _, m in personaje:GetDescendants() do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 then
			local factor = factores[m.Part0.Name]
			local hijo = m.Part1.Name
			if factor and factor ~= 1 and hijo ~= "UpperTorso" and hijo ~= "Head" then
				m.C0 = CFrame.new(m.C0.Position.X * factor, m.C0.Position.Y, m.C0.Position.Z)
					* m.C0.Rotation
			end
		end
	end
end

function Apariencia.aplicar(personaje: Model, datos: Datos)
	for clave, valor in datos :: any do
		personaje:SetAttribute("Cuerpo" .. clave, valor)
	end
	local tono = C.TonosPiel[datos.Tono]
	for nombre, grupo in C.Ropa.Partes do
		local p = personaje:FindFirstChild(nombre)
		if p and p:IsA("BasePart") then
			p.Color = if grupo == "Piel" then tono else C.Ropa.Colores[grupo]
		end
	end
	local remera = personaje:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
	remera.ShirtTemplate = C.Ropa.Remera
	remera.Color3 = C.Ropa.Colores.Remera
	remera.Parent = personaje
	local pantalon = personaje:FindFirstChildOfClass("Pants") or Instance.new("Pants")
	pantalon.PantsTemplate = C.Ropa.Pantalon
	pantalon.Color3 = C.Ropa.Colores.Pantalon
	pantalon.Parent = personaje
	Apariencia.expresion(personaje, "neutral")
	local cabeza = personaje:FindFirstChild("Head")
	if cabeza and cabeza:IsA("BasePart") and datos.Marca > 0 then
		decal(cabeza, "Marca", C.Marcas[datos.Marca], 2)
	end

	local carpeta = ServerStorage:FindFirstChild("Cuerpo")
	local peinados = carpeta and carpeta:FindFirstChild("Peinados")
	local molde = peinados and peinados:FindFirstChild(datos.Peinado)
	local humanoid = personaje:FindFirstChildOfClass("Humanoid")
	if molde and molde:IsA("Accessory") and humanoid then
		local pelo = molde:Clone()
		local mango = pelo:FindFirstChild("Handle")
		if mango and mango:IsA("BasePart") then
			mango.Color = Color3.fromHex(datos.ColorPelo)
		end
		humanoid:AddAccessory(pelo)
	else
		warn("Falta el peinado", datos.Peinado, "en ServerStorage.Cuerpo.Peinados")
	end

	contextura(personaje, datos.Contextura)
	local altura = C.Alturas[datos.Altura]
	if altura ~= 1 then
		personaje:ScaleTo(altura)
	end
end

return Apariencia
