--!strict
-- Eje central de la torre: un tramo por zona que se prende (neón del color de la zona) cuando
-- completaste su canción. Cada jugador ve los suyos. El modelo está siempre cargado, así se ve
-- desde cualquier zona.
--
-- En el mapa: Workspace.Torre.Eje > Tramo1, Tramo2... (BasePart con atributo Zona).
-- El servidor publica el atributo "Canciones" del jugador como ",1,3,".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local jugador = Players.LocalPlayer
local prendidos: { [BasePart]: boolean } = {}

local function completada(zona: number): boolean
	local valor = jugador:GetAttribute("Canciones")
	return typeof(valor) == "string" and string.find(valor, `,{zona},`, 1, true) ~= nil
end

local function pintar(tramo: BasePart)
	local zona = tramo:GetAttribute("Zona")
	local datos = if typeof(zona) == "number" then Config.Zonas[zona] else nil
	if not datos or prendidos[tramo] or not completada(zona :: number) then
		return
	end
	prendidos[tramo] = true
	tramo.Material = Enum.Material.Neon
	TweenService:Create(tramo, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
		Color = datos.Principal,
		Transparency = 0.35, -- prendido pero sin encandilar
	}):Play()
end

local function registrar(objeto: Instance)
	if
		objeto:IsA("BasePart")
		and objeto.Name:match("^Tramo%d+$")
		and objeto.Parent
		and objeto.Parent.Name == "Eje"
	then
		pintar(objeto)
	end
end

local function repintar()
	for tramo in prendidos do
		if not tramo.Parent then
			prendidos[tramo] = nil
		end
	end
	for _, objeto in workspace:GetDescendants() do
		registrar(objeto)
	end
end

workspace.DescendantAdded:Connect(registrar)
jugador:GetAttributeChangedSignal("Canciones"):Connect(repintar)
repintar()
