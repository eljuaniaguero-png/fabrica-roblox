--!strict
-- Hace aparecer un civil en cada parte con tag "PuntoCivil" (hasta el tope de Config). El cuerpo
-- es el mismo de los jugadores (StarterCharacter) con apariencia y ropa al azar; con el atributo
-- Especial = "Diarero" / "Vendedor" / "Musico" sale ese civil con su carrito o guitarra.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage.Shared.Config)
local Apariencia = require(script.Parent.Apariencia)
local Civiles = require(script.Parent.Civiles)

local carpeta = Instance.new("Folder")
carpeta.Name = "Civiles"
carpeta.Parent = workspace

local cantidad = 0
local azar = Random.new()

local function aparecer(punto: Instance)
	if not punto:IsA("BasePart") or cantidad >= Config.Civiles.MaximoPorServidor then
		return
	end
	local molde = StarterPlayer:FindFirstChild("StarterCharacter")
	if not (molde and molde:IsA("Model")) then
		warn("CalleViva: falta StarterPlayer.StarterCharacter para armar civiles")
		return
	end
	cantidad += 1
	local civil = molde:Clone()
	civil.Name = "Civil"
	-- Sin scripts de jugador (Animate, controles): el civil los tendrá propios cuando camine.
	for _, d in civil:GetDescendants() do
		if d:IsA("BaseScript") then
			d:Destroy()
		end
	end
	local semilla = azar:NextInteger(1, 2 ^ 30)
	Apariencia.aplicar(civil, Apariencia.limpiar(Apariencia.porDefecto(semilla)))
	-- Los civiles usan el pelo y los gorros del kit: se saca el peinado del cuerpo propio.
	for _, d in civil:GetChildren() do
		if d:IsA("Accessory") then
			d:Destroy()
		end
	end
	local especial = punto:GetAttribute("Especial")
	local receta = if typeof(especial) == "string" then Civiles.recetaEspecial(especial) else nil
	civil:PivotTo(punto.CFrame * CFrame.new(0, punto.Size.Y / 2 + 3, 0))
	civil.Parent = carpeta
	Civiles.vestir(civil, receta or Civiles.recetaAlAzar(Random.new(semilla)))
	civil:SetAttribute("Especial", especial)
end

CollectionService:GetInstanceAddedSignal("PuntoCivil"):Connect(aparecer)
for _, punto in CollectionService:GetTagged("PuntoCivil") do
	task.spawn(aparecer, punto)
end
