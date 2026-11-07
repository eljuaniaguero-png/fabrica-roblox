-- Arma un .rbxm por animación desde los JSON de roblox.py, para subirlos por Open Cloud (assetType Animation).
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local Instance, CFrame, Enum = roblox.Instance, roblox.CFrame, roblox.Enum

local ENT = "C:/Users/eljua/fabrica-roblox/investigacion/animjson"
local SAL = "C:/Users/eljua/fabrica-roblox/investigacion/rbxm"
if not fs.isDir(SAL) then
	fs.writeDir(SAL)
end

local HIJOS = {
	HumanoidRootPart = { "LowerTorso" },
	LowerTorso = { "UpperTorso", "LeftUpperLeg", "RightUpperLeg" },
	UpperTorso = { "Head", "LeftUpperArm", "RightUpperArm" },
	LeftUpperArm = { "LeftLowerArm" },
	LeftLowerArm = { "LeftHand" },
	RightUpperArm = { "RightLowerArm" },
	RightLowerArm = { "RightHand" },
	LeftUpperLeg = { "LeftLowerLeg" },
	LeftLowerLeg = { "LeftFoot" },
	RightUpperLeg = { "RightLowerLeg" },
	RightLowerLeg = { "RightFoot" },
}

local function pose(nombre, j, padre)
	local p = Instance.new("Pose")
	p.Name = nombre
	p.EasingStyle = Enum.PoseEasingStyle.Linear
	p.EasingDirection = Enum.PoseEasingDirection.In
	local c = j[nombre]
	if nombre == "HumanoidRootPart" then
		p.Weight = 0
		p.CFrame = CFrame.new(0, 0, 0)
	else
		p.Weight = 1
		p.CFrame = if c
			then CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
			else CFrame.new(0, 0, 0)
	end
	p.Parent = padre
	for _, h in HIJOS[nombre] or {} do
		pose(h, j, p)
	end
end

local n = 0
for _, archivo in fs.readDir(ENT) do
	local d = serde.decode("json", fs.readFile(ENT .. "/" .. archivo))
	local ks = Instance.new("KeyframeSequence")
	ks.Name = d.nombre
	ks.Loop = d.loop
	local pr = d.prioridad
	ks.Priority = if type(pr) == "string" then Enum.AnimationPriority[pr] else Enum.AnimationPriority:GetEnumItems()[1]
	for _, clave in d.claves do
		local kf = Instance.new("Keyframe")
		kf.Time = clave.t
		kf.Parent = ks
		pose("HumanoidRootPart", clave.j, kf)
		for _, m in d.marcadores do
			if math.abs(m[1] - clave.t) < 0.001 then
				local km = Instance.new("KeyframeMarker")
				km.Name = m[2]
				km.Parent = kf
			end
		end
	end
	fs.writeFile(SAL .. "/" .. d.nombre .. ".rbxm", roblox.serializeModel({ ks }))
	n += 1
end
print("armadas", n)
