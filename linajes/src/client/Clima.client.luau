--!strict
-- Ciclo de día y noche y niebla según la ciudad donde estás (partes con tag "Barrio" y atributo
-- Ciudad). Va en el cliente para que Vórtice tenga noche eterna sin cambiarle la hora a los demás.

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Luz = require(ReplicatedStorage.Shared.Iluminacion)
local Tiempo = require(ReplicatedStorage.Shared.Tiempo)

local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosfera.Parent = Lighting

local correccion = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	or Instance.new("ColorCorrectionEffect")
correccion.Parent = Lighting
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
local rayos = Lighting:FindFirstChildOfClass("SunRaysEffect")
if rayos then
	rayos.Enabled = false
end
local desenfoque = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
if desenfoque then
	desenfoque.Enabled = false -- en pelea hay que ver lejos
end

local function hexa(texto: string): Color3
	return Color3.fromHex(texto)
end

-- Mezcla los dos puntos de luz que rodean a la hora.
local function ponerLuz(hora: number)
	local puntos = Config.Mundo.Luz
	for i = 1, #puntos - 1 do
		local a, b = puntos[i], puntos[i + 1]
		if hora >= a.Hora and hora <= b.Hora then
			local t = (hora - a.Hora) / math.max(b.Hora - a.Hora, 0.01)
			local function mezcla(x: number, y: number): number
				return x + (y - x) * t
			end
			Lighting.Ambient = hexa(a.Ambiente):Lerp(hexa(b.Ambiente), t)
			Lighting.OutdoorAmbient = hexa(a.Exterior):Lerp(hexa(b.Exterior), t)
			Lighting.Brightness = mezcla(a.Brillo, b.Brillo)
			Lighting.ExposureCompensation = mezcla(a.Exposicion, b.Exposicion)
			correccion.TintColor = hexa(a.Tinte):Lerp(hexa(b.Tinte), t)
			correccion.Contrast = mezcla(a.Contraste, b.Contraste)
			correccion.Saturation = mezcla(a.Saturacion, b.Saturacion)
			if bloom then
				bloom.Intensity = mezcla(a.Resplandor, b.Resplandor)
				bloom.Threshold = 1.6
				bloom.Size = 24
			end
			return
		end
	end
end

local cielo = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
cielo.Parent = Lighting
local cieloOriginal = {}
for _, cara in { "Bk", "Dn", "Ft", "Lf", "Rt", "Up" } do
	cieloOriginal[cara] = (cielo :: any)["Skybox" .. cara]
end

local function ponerCielo(caras: { [string]: string })
	for cara, id in caras do
		(cielo :: any)["Skybox" .. cara] = id
	end
	cielo.MoonAngularSize = 0
	cielo.SunAngularSize = 0
	cielo.StarCount = if caras == Luz.Cielo then Luz.Estrellas else 0
end

local function ponerNoche()
	Lighting.ClockTime = Luz.Hora
	Lighting.GlobalShadows = true
	Lighting.Ambient = hexa(Luz.Ambiente)
	Lighting.OutdoorAmbient = hexa(Luz.Exterior)
	Lighting.Brightness = Luz.Brillo
	Lighting.ExposureCompensation = Luz.Exposicion
	correccion.TintColor = hexa(Luz.Tinte)
	correccion.Contrast = Luz.Contraste
	correccion.Saturation = Luz.Saturacion
	if bloom then
		bloom.Intensity = Luz.Resplandor
		bloom.Threshold = Luz.ResplandorUmbral
		bloom.Size = Luz.ResplandorTamano
	end
end

local function borde(raiz: BasePart, prendido: boolean)
	local luz = raiz:FindFirstChild("LuzBorde") :: PointLight?
	if not luz then
		local nueva = Instance.new("PointLight")
		nueva.Name = "LuzBorde"
		nueva.Shadows = false
		nueva.Color = hexa(Luz.Borde.Color)
		nueva.Brightness = Luz.Borde.Brillo
		nueva.Range = Luz.Borde.Alcance
		nueva.Parent = raiz
		luz = nueva
	end
	(luz :: PointLight).Enabled = prendido
end

local function enArena(pos: Vector3): boolean
	local m = Config.Arena.Mapa
	local d = pos - m.Centro
	return math.abs(d.X) <= m.Ancho / 2 and math.abs(d.Z) <= m.Largo / 2
end

local function ciudadEn(pos: Vector3): string
	for _, area in CollectionService:GetTagged("Barrio") do
		if area:IsA("BasePart") then
			local local_ = area.CFrame:PointToObjectSpace(pos)
			local m = area.Size / 2
			if math.abs(local_.X) <= m.X and math.abs(local_.Z) <= m.Z then
				return area:GetAttribute("Ciudad") or "Bahia"
			end
		end
	end
	return "Bahia"
end

local ciudadActual = ""

local function ponerNiebla(ciudad: string)
	ponerCielo(if ciudad == "Arena" then Luz.Cielo else cieloOriginal)
	local n = if ciudad == "Arena"
		then Luz.Niebla
		else Config.Mundo.Niebla[ciudad] or Config.Mundo.Niebla.Bahia
	TweenService:Create(atmosfera, TweenInfo.new(3), {
		Density = n.Densidad,
		Haze = n.Bruma,
		Glare = n.Destello or 0,
		Color = Color3.fromHex(n.Color),
		Decay = Color3.fromHex(n.Decaimiento or n.Color),
	}):Play()
end

local acumulado = 0
RunService.RenderStepped:Connect(function(dt)
	local personaje = Players.LocalPlayer.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	acumulado += dt
	if raiz and raiz:IsA("BasePart") and acumulado > 1 then
		acumulado = 0
		local ciudad = if enArena(raiz.Position) then "Arena" else ciudadEn(raiz.Position)
		if ciudad ~= ciudadActual then
			ciudadActual = ciudad
			ponerNiebla(ciudad)
		end
	end
	if raiz and raiz:IsA("BasePart") then
		borde(raiz, ciudadActual == "Arena")
	end
	if ciudadActual == "Arena" then
		ponerNoche()
		return
	end
	local hora = if ciudadActual == "CiudadVortice"
		then Config.Mundo.HoraNocheEterna
		else Tiempo.hora()
	Lighting.ClockTime = hora
	ponerLuz(hora)
end)
