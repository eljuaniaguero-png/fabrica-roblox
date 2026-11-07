--!strict
-- Luces reales del puerto: galpón con ventanas cálidas, barco amarrado y luz roja de altura.
-- Valores en shared/Iluminacion.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Luz = require(ReplicatedStorage.Shared.Iluminacion)

local M = Config.Arena.Mapa
local O = M.Centro
local kit = ServerStorage:WaitForChild("ArenaKit")
local carpeta = Instance.new("Folder")
carpeta.Name = "ArenaLuces"

local function en(x: number, y: number, z: number): CFrame
	return CFrame.new(O + Vector3.new(x, y, z))
end

local function parte(
	tam: Vector3,
	cf: CFrame,
	hex: string,
	material: Enum.Material,
	solido: boolean?
): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = solido == true
	p.CanQuery = solido == true
	p.CanTouch = false
	p.CastShadow = solido == true
	p.Size = tam
	p.CFrame = cf
	p.Color = Color3.fromHex(hex)
	p.Material = material
	p.Parent = carpeta
	return p
end

local function pieza(nombre: string, cf: CFrame, escala: number)
	local molde = kit:FindFirstChild(nombre, true) :: MeshPart
	local p = molde:Clone()
	p.Size *= escala
	p.CFrame = cf * (molde.CFrame - molde.CFrame.Position)
	p.Parent = carpeta
end

local function foco(padre: BasePart, datos: any)
	local l = Instance.new("PointLight")
	l.Color = Color3.fromHex(datos.Color)
	l.Brightness = datos.Brillo
	l.Range = datos.Alcance
	l.Shadows = false
	l.Parent = padre
end

-- Galpón en la esquina noreste: su frente mira al oeste, hacia la pelea.
local function galpon()
	local G = Luz.Galpon
	local x, alto = G.X, 18
	parte(
		Vector3.new(26, alto, 60),
		en(x + 13.5, alto / 2, G.Z),
		"#23252b",
		Enum.Material.Metal,
		true
	)
	local giro = CFrame.identity
	for i = -2, 2 do
		local z = G.Z + i * 12
		pieza(
			if i == 0 then "Galpon_ParedPorton" else "Galpon_Pared",
			en(x, alto / 2, z) * giro,
			1.5
		)
		if i ~= 0 then
			local ventana =
				parte(Vector3.new(0.3, 4, 6), en(x - 1, 12, z), G.Ventana, Enum.Material.Neon)
			foco(ventana, G.LuzVentana)
		end
	end
	-- Puerta entreabierta: hoja girada y una franja de luz.
	parte(Vector3.new(0.3, 11, 2), en(x - 1, 5.5, G.Z), G.Ventana, Enum.Material.Neon)
	parte(
		Vector3.new(0.4, 11, 6),
		en(x - 3.4, 5.5, G.Z + 3.4) * CFrame.Angles(0, math.rad(50), 0),
		"#3a3f47",
		Enum.Material.Metal,
		true
	)
	local derrame =
		parte(Vector3.new(1, 1, 1), en(x - 5, 4, G.Z), G.Ventana, Enum.Material.SmoothPlastic)
	derrame.Transparency = 1
	foco(derrame, G.LuzPuerta)
end

-- Barco amarrado detrás de la baranda, con pocas luces.
local function barco()
	local B = Luz.Barco
	local z = B.Z
	parte(Vector3.new(190, 26, 34), en(B.X, 8, z), "#39424f", Enum.Material.Metal)
	parte(Vector3.new(190, 2, 35), en(B.X, 19, z), "#7a3f22", Enum.Material.CorrodedMetal)
	parte(Vector3.new(36, 24, 24), en(B.X + 58, 33, z), "#c9c6bc", Enum.Material.Metal)
	parte(Vector3.new(24, 10, 20), en(B.X + 58, 50, z), "#b4b1a8", Enum.Material.Metal)
	parte(Vector3.new(3, 22, 3), en(B.X + 58, 66, z), "#3a3d44", Enum.Material.Metal)
	for i = 0, 5 do
		parte(
			Vector3.new(3, 2.6, 0.3),
			en(B.X + 44 + i * 5.6, 36, z + 12.2),
			Luz.Galpon.Ventana,
			Enum.Material.Neon
		)
	end
	for _, x in B.Luces do
		local l = parte(
			Vector3.new(1.2, 1.2, 1.2),
			en(B.X + x, 24, z + 15),
			"#fff2d0",
			Enum.Material.Neon
		)
		foco(l, B.Luz)
	end
end

local function luzRoja()
	local lamparas: { Part } = {}
	for _, x in M.Porticos do
		local l = parte(
			Vector3.new(2, 2, 2),
			en(x, Luz.Roja.Y, Luz.Roja.Z),
			"#ff2a20",
			Enum.Material.Neon
		)
		table.insert(lamparas, l)
	end
	task.spawn(function()
		while true do
			for _, l in lamparas do
				l.Transparency = if l.Transparency == 0 then 0.85 else 0
			end
			task.wait(Luz.Roja.Pausa)
		end
	end)
end

galpon()
barco()
luzRoja()
carpeta.Parent = workspace
