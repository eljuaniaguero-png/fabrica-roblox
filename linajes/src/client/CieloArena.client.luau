--!strict
-- De noche Roblox apaga el cielo, así que la arena usa paneles lejanos que siguen a la cámara.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Luz = require(Shared:WaitForChild("Iluminacion"))

local M = Config.Arena.Mapa
local D = Luz.CieloDistancia
local caras = {
	{ Id = Luz.Cielo.Ft, Lado = Vector3.new(0, 0, -D) },
	{ Id = Luz.Cielo.Bk, Lado = Vector3.new(0, 0, D) },
	{ Id = Luz.Cielo.Rt, Lado = Vector3.new(D, 0, 0) },
	{ Id = Luz.Cielo.Lf, Lado = Vector3.new(-D, 0, 0) },
	{ Id = Luz.Cielo.Up, Lado = Vector3.new(0, D, 0) },
}

local carpeta = Instance.new("Folder")
carpeta.Name = "CieloArena"
local paneles: { { parte: Part, lado: Vector3 } } = {}
for _, c in caras do
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = Vector3.new(D * 2, D * 2, 1)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Brightness = Luz.CieloBrillo
	gui.Parent = p
	local imagen = Instance.new("ImageLabel")
	imagen.Size = UDim2.fromScale(1, 1)
	imagen.BackgroundTransparency = 1
	imagen.Image = c.Id
	imagen.Parent = gui
	p.Parent = carpeta
	table.insert(paneles, { parte = p, lado = c.Lado })
end

RunService.RenderStepped:Connect(function()
	local camara = workspace.CurrentCamera
	local pos = camara.CFrame.Position
	local d = pos - M.Centro
	local adentro = math.abs(d.X) <= M.Ancho and math.abs(d.Z) <= M.Largo
	carpeta.Parent = if adentro then camara else nil
	if adentro then
		for _, p in paneles do
			p.parte.CFrame = CFrame.lookAt(
				pos + p.lado,
				pos,
				if p.lado.Y ~= 0 then Vector3.zAxis else Vector3.yAxis
			)
		end
	end
end)
