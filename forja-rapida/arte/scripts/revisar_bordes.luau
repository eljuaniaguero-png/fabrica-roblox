-- Revisión de bordes (pedido E1): se pega en execute_luau (datamodel Server, en Play).
-- Desde 8 puntos por zona (y el lobby) pone la cámara como la pondría un jugador con el zoom
-- máximo, mirando hacia afuera (alta y baja), tira una grilla de rayos por la pantalla y cuenta
-- qué porcentaje muestra "afuera": vacío debajo del horizonte o el piso de tierra de afuera.
-- Para probar otro zoom, cambiar este número antes de pegarlo.
local ZOOM = game.StarterPlayer.CameraMaxZoomDistance
local LARGO, MURO, SUBA = 200, 8, 6
local XMIN, XMAX = -80, 80
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local excluir = {}
for _, p in game.Players:GetPlayers() do
	table.insert(excluir, p.Character)
end
params.FilterDescendantsInstances = excluir

local function mirar(cam: CFrame, fov: number): (number, number)
	local vacio, tierra, total = 0, 0, 0
	local tan = math.tan(math.rad(fov / 2))
	for i = 0, 23 do
		for j = 0, 13 do
			local u = (i / 23 * 2 - 1) * tan * 16 / 9
			local v = (j / 13 * 2 - 1) * tan
			local dir = (cam.LookVector + cam.RightVector * u + cam.UpVector * v).Unit
			total += 1
			local r = workspace:Raycast(cam.Position, dir * 1500, params)
			if not r then
				if dir.Y < 0.02 then
					vacio += 1 -- se ve el cielo/vacío por debajo del horizonte
				end
			else
				local p = r.Position
				local fuera = math.abs(p.X) > XMAX + 8
					or p.Z < -150
					or p.Z > 5 * (LARGO + MURO) + 20
				if fuera and r.Instance.Transparency < 1 and p.Y < 1 + 30 then
					if
						r.Instance.Name == "Bloque"
						and r.Material == Enum.Material.Plastic
						and p.Y <= 4
					then
						tierra += 1 -- el piso de tierra de afuera (o el borde de la placa)
					end
				end
			end
		end
	end
	return math.round(vacio / total * 100), math.round(tierra / total * 100)
end

local salida = {}
local function revisar(nombre: string, base: Vector3, afuera: Vector3)
	for _, alta in { true, false } do
		local pitch = if alta then math.rad(55) else math.rad(8)
		local atras = -afuera * math.cos(pitch) * ZOOM + Vector3.yAxis * math.sin(pitch) * ZOOM
		local ojo = base + Vector3.new(0, 4, 0) + atras
		local objetivo = if alta
			then base + afuera * 10
			else base + afuera * 10 + Vector3.new(0, 25, 0)
		local v, t = mirar(CFrame.lookAt(ojo, objetivo), 70)
		table.insert(
			salida,
			("%s %s: vacío %d%% tierra %d%%"):format(nombre, alta and "alta" or "baja", v, t)
		)
	end
end

for n = 1, 5 do
	local zs = 8 + (n - 1) * (LARGO + MURO)
	local ze = zs + LARGO
	local h = (n - 1) * SUBA
	local zm = (zs + ze) / 2
	local P = {
		{
			"Z" .. n .. " esq izq atrás",
			Vector3.new(XMIN + 8, h, zs + 10),
			Vector3.new(-1, 0, -1).Unit,
		},
		{
			"Z" .. n .. " esq der atrás",
			Vector3.new(XMAX - 8, h, zs + 10),
			Vector3.new(1, 0, -1).Unit,
		},
		{
			"Z" .. n .. " esq izq fondo",
			Vector3.new(XMIN + 8, h, ze - 10),
			Vector3.new(-1, 0, 1).Unit,
		},
		{
			"Z" .. n .. " esq der fondo",
			Vector3.new(XMAX - 8, h, ze - 10),
			Vector3.new(1, 0, 1).Unit,
		},
		{ "Z" .. n .. " medio izq", Vector3.new(XMIN + 8, h, zm), Vector3.new(-1, 0, 0) },
		{ "Z" .. n .. " medio der", Vector3.new(XMAX - 8, h, zm), Vector3.new(1, 0, 0) },
		{ "Z" .. n .. " medio atrás", Vector3.new(0, h, zs + 10), Vector3.new(0, 0, -1) },
		{ "Z" .. n .. " medio fondo", Vector3.new(0, h, ze - 10), Vector3.new(0, 0, 1) },
	}
	for _, p in P do
		revisar(p[1], p[2], p[3])
	end
	task.wait()
end
local L = {
	{ "Lobby esq izq fondo", Vector3.new(XMIN + 8, 0, -128), Vector3.new(-1, 0, -1).Unit },
	{ "Lobby esq der fondo", Vector3.new(XMAX - 8, 0, -128), Vector3.new(1, 0, -1).Unit },
	{ "Lobby esq izq frente", Vector3.new(XMIN + 8, 0, -8), Vector3.new(-1, 0, 1).Unit },
	{ "Lobby esq der frente", Vector3.new(XMAX - 8, 0, -8), Vector3.new(1, 0, 1).Unit },
	{ "Lobby medio izq", Vector3.new(XMIN + 8, 0, -68), Vector3.new(-1, 0, 0) },
	{ "Lobby medio der", Vector3.new(XMAX - 8, 0, -68), Vector3.new(1, 0, 0) },
	{ "Lobby medio fondo", Vector3.new(0, 0, -128), Vector3.new(0, 0, -1) },
	{ "Lobby medio frente", Vector3.new(0, 0, -8), Vector3.new(0, 0, 1) },
}
for _, p in L do
	revisar(p[1], p[2], p[3])
end
return ("zoom %d\n"):format(ZOOM) .. table.concat(salida, "\n")
