--!strict
-- Destello al comprar o mejorar algo, sobre lo que cambió (guía de estilo, punto 7):
--   especie base -> sobre la criatura nueva, cuando llega al corral;
--   Más corrales -> sobre el corral que se abrió;
--   las otras mejoras y las pistas -> sobre el mostrador de la tienda.
-- Solo visual: el servidor avisa con el remoto Compra cuando la compra salió bien.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Paleta = require(ReplicatedStorage.Shared.Paleta)
local MiLab = require(script.Parent.MiLab)
local Sonidos = require(script.Parent.Sonidos)

local lab = MiLab.obtener()
local compra = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Compra") :: RemoteEvent

local CRECER = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function destello(donde: Vector3, tamano: number, color: Color3)
	-- Una esfera de luz que crece y se apaga, con chispas.
	local bola = Instance.new("Part")
	bola.Name = "DestelloCompra"
	bola.Shape = Enum.PartType.Ball
	bola.Material = Enum.Material.Neon
	bola.Color = color
	bola.Transparency = 0.15
	bola.Anchored = true
	bola.CanCollide = false
	bola.CanQuery = false
	bola.CanTouch = false
	bola.CastShadow = false
	bola.Size = Vector3.one * 1
	bola.Position = donde
	local luz = Instance.new("PointLight")
	luz.Color = color
	luz.Brightness = 4
	luz.Range = tamano * 2
	luz.Parent = bola
	local chispas = Instance.new("ParticleEmitter")
	chispas.Color = ColorSequence.new(color, Paleta.Texto)
	chispas.LightEmission = 1
	chispas.Size = NumberSequence.new(0.5, 0)
	chispas.Speed = NumberRange.new(10, 18)
	chispas.SpreadAngle = Vector2.new(180, 180)
	chispas.Lifetime = NumberRange.new(0.4, 0.8)
	chispas.Drag = 4
	chispas.Rate = 0
	chispas.Parent = bola
	bola.Parent = workspace
	chispas:Emit(30)
	TweenService:Create(bola, CRECER, { Size = Vector3.one * tamano, Transparency = 1 }):Play()
	TweenService:Create(luz, CRECER, { Brightness = 0 }):Play()
	-- SONIDO: destello de compra (acorde brillante)
	Sonidos.acorde({ 12, 16, 19 }, 0.25)
	Debris:AddItem(bola, 1.2)
end

local function posicion(inst: Instance?): Vector3?
	if not inst then
		return nil
	end
	if inst:IsA("BasePart") then
		return inst.Position
	elseif inst:IsA("Model") then
		return inst:GetPivot().Position
	end
	return nil
end

-- Espera a que la criatura de esa especie aparezca en un corral (la pone el servidor).
local function buscarCriatura(clave: string): Model?
	local corrales = lab:WaitForChild("Corrales")
	local inicio = os.clock()
	while os.clock() - inicio < 3 do
		for _, corral in corrales:GetChildren() do
			local criaturas = corral:FindFirstChild("Criaturas")
			for _, m in if criaturas then criaturas:GetChildren() else {} do
				if m:IsA("Model") and m:GetAttribute("Clave") == clave and m.PrimaryPart then
					return m
				end
			end
		end
		task.wait(0.1)
	end
	return nil
end

compra.OnClientEvent:Connect(function(tipo: string, id: any, nivel: number?)
	local mostrador = lab:FindFirstChild("Tienda")
	mostrador = mostrador and mostrador:FindFirstChild("Mostrador")
	if tipo == "Base" then
		local criatura = buscarCriatura(tostring(id))
		local donde = posicion(criatura) or posicion(mostrador)
		if donde then
			destello(donde + Vector3.new(0, 2, 0), 9, Paleta.Acento)
		end
	elseif tipo == "Mejora" and id == "Corrales" and nivel then
		local corral = lab:WaitForChild("Corrales"):FindFirstChild("Corral" .. nivel)
		local donde = posicion(corral and corral:FindFirstChild("Piso")) or posicion(corral)
		if donde then
			destello(donde + Vector3.new(0, 3, 0), 18, Paleta.Acento)
		end
	else
		local donde = posicion(mostrador)
		if donde then
			destello(donde + Vector3.new(0, 3, 0), 10, Paleta.Dorado)
		end
	end
end)
