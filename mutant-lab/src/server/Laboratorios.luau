--!strict
-- Un laboratorio por jugador. Los laboratorios están armados en Studio:
-- Laboratorios > Lab1..Lab4 (Model) > Maquina, Corrales (Corral1..4), Tienda, Cartel, Aparicion
-- Corral > Piso, Zona (dónde caminan), Cerca (Model), Candado (Part con BillboardGui), Criaturas (Folder)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local GRIS = Color3.fromHex("C9C2D6")
local PISO_ABIERTO = Color3.fromHex("BFF5E0")
local PISO_CERRADO = Color3.fromHex("E4DFEA")

local carpeta = workspace:WaitForChild("Laboratorios")
local labDe: { [Player]: Model } = {}
local duenoDe: { [Model]: Player } = {}

local Laboratorios = {}

function Laboratorios.de(jugador: Player): Model?
	return labDe[jugador]
end

local function ponerCartel(lab: Model, texto: string)
	local cartel = lab:FindFirstChild("Cartel")
	local titulo = cartel and cartel:FindFirstChild("Titulo", true)
	if titulo and titulo:IsA("TextLabel") then
		titulo.Text = texto
	end
end

local function llevarAlLab(jugador: Player, personaje: Model)
	local lab = labDe[jugador]
	local aparicion = lab and lab:FindFirstChild("Aparicion")
	if not aparicion or not aparicion:IsA("BasePart") then
		return
	end
	personaje:WaitForChild("HumanoidRootPart", 5)
	task.wait() -- dejar que el personaje termine de aparecer
	-- Mirando hacia la máquina (-Z del laboratorio).
	personaje:PivotTo(aparicion.CFrame * CFrame.new(0, 4, 0))
end

-- Muestra qué corrales están abiertos según la mejora "Más corrales".
function Laboratorios.actualizarCorrales(jugador: Player, abiertos: number)
	local lab = labDe[jugador]
	if not lab then
		return
	end
	local corrales = lab:WaitForChild("Corrales")
	for k = 1, Config.Corrales.Maximo do
		local corral = corrales:FindFirstChild("Corral" .. k)
		if corral then
			local abierto = k <= abiertos
			local piso = corral:FindFirstChild("Piso")
			if piso and piso:IsA("BasePart") then
				piso.Color = if abierto then PISO_ABIERTO else PISO_CERRADO
			end
			local cerca = corral:FindFirstChild("Cerca")
			if cerca then
				for _, p in cerca:GetDescendants() do
					if p:IsA("BasePart") then
						p.Color = if abierto
							then (p:GetAttribute("ColorAbierto") :: Color3? or p.Color)
							else GRIS
					end
				end
			end
			local candado = corral:FindFirstChild("Candado")
			local aviso = candado and candado:FindFirstChildWhichIsA("BillboardGui")
			if aviso then
				aviso.Enabled = not abierto
			end
		end
	end
end

function Laboratorios.asignar(jugador: Player)
	for i = 1, Config.CantidadLaboratorios do
		local lab = carpeta:FindFirstChild("Lab" .. i)
		if lab and lab:IsA("Model") and not duenoDe[lab] then
			labDe[jugador] = lab
			duenoDe[lab] = jugador
			lab:SetAttribute("Dueno", jugador.UserId)
			jugador:SetAttribute("Laboratorio", lab.Name)
			ponerCartel(lab, "Laboratorio de " .. jugador.DisplayName)
			jugador.CharacterAdded:Connect(function(personaje)
				llevarAlLab(jugador, personaje)
			end)
			if jugador.Character then
				task.spawn(llevarAlLab, jugador, jugador.Character)
			end
			return
		end
	end
	warn("[Laboratorios] No hay laboratorio libre para " .. jugador.Name)
end

function Laboratorios.liberar(jugador: Player)
	local lab = labDe[jugador]
	if not lab then
		return
	end
	labDe[jugador] = nil
	duenoDe[lab] = nil
	lab:SetAttribute("Dueno", nil)
	ponerCartel(lab, "Laboratorio libre")
end

return Laboratorios
