--!strict
-- Pone en los corrales del laboratorio a las criaturas que trabajan (las de mayor
-- generación, hasta el tope). Los modelos los crea el servidor, así todos los ven;
-- la caminata la anima cada cliente.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)

local azar = Random.new()

local Corrales = {}

local function carpetaCriaturas(corral: Instance): Folder
	local f = corral:FindFirstChild("Criaturas")
	if f and f:IsA("Folder") then
		return f
	end
	local nueva = Instance.new("Folder")
	nueva.Name = "Criaturas"
	nueva.Parent = corral
	return nueva
end

type Lugar = { Corral: number, Mutante: boolean, Existe: boolean }

function Corrales.actualizar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	local lab = Laboratorios.de(jugador)
	if not d or not lab then
		return
	end
	local corrales = lab:WaitForChild("Corrales")
	local activas = Mejoras.activas(d.Especies, d.Mejoras.Corrales)

	-- Dónde tiene que estar cada criatura activa.
	local deseado: { [string]: Lugar } = {}
	for i, c in activas do
		deseado[c.Clave] = {
			Corral = math.ceil(i / Config.Corrales.PorCorral),
			Mutante = d.Mutantes[c.Clave] == true,
			Existe = false,
		}
	end

	-- Sacar las que sobran o cambiaron (de corral o a mutante).
	for k = 1, Config.Corrales.Maximo do
		local corral = corrales:FindFirstChild("Corral" .. k)
		if corral then
			for _, m in carpetaCriaturas(corral):GetChildren() do
				local lugar = deseado[m:GetAttribute("Clave") :: string]
				if
					not lugar
					or lugar.Corral ~= k
					or (m:GetAttribute("Mutante") == true) ~= lugar.Mutante
				then
					m:Destroy()
				else
					lugar.Existe = true
				end
			end
		end
	end

	-- Poner las que faltan, en un lugar al azar de la zona del corral.
	for clave, lugar in deseado do
		local corral = corrales:FindFirstChild("Corral" .. lugar.Corral)
		local zona = corral and corral:FindFirstChild("Zona")
		local c = Fusion.porClave(clave)
		if not lugar.Existe and corral and zona and zona:IsA("BasePart") and c then
			local x = (azar:NextNumber() - 0.5) * zona.Size.X
			local z = (azar:NextNumber() - 0.5) * zona.Size.Z
			local punto = (zona.CFrame * CFrame.new(x, 0, z)).Position
			local donde = CFrame.new(punto) * CFrame.Angles(0, azar:NextNumber(0, 2 * math.pi), 0)
			local modelo = Generador.crear(c, donde, nil, lugar.Mutante)
			modelo:SetAttribute("ZonaCFrame", zona.CFrame)
			modelo:SetAttribute("ZonaTamano", zona.Size)
			modelo.Parent = carpetaCriaturas(corral)
		end
	end

	Laboratorios.actualizarCorrales(jugador, d.Mejoras.Corrales)
	jugador:SetAttribute("Activas", #activas)
end

-- Saca todas las criaturas del laboratorio (cuando el jugador se va).
function Corrales.limpiar(jugador: Player)
	local lab = Laboratorios.de(jugador)
	if not lab then
		return
	end
	for _, corral in lab:WaitForChild("Corrales"):GetChildren() do
		local f = corral:FindFirstChild("Criaturas")
		if f then
			f:ClearAllChildren()
		end
	end
end

return Corrales
