--!strict
-- Etapa 7b-3: viste la sala gris de GeneradorSala con los modelos de la IA (Config.Sala.Modelos,
-- subidos una vez a Roblox y duplicados acá). Cada modelo se carga con InsertService la primera
-- vez, se agranda o achica a su medida (Alto o Largo en studs) y se clona donde haga falta.
-- Los bloques grises quedan (invisibles) para las colisiones, los tags y el "E: Jugar"; si un
-- modelo no carga, el bloque gris se sigue viendo y el juego anda igual.

local InsertService = game:GetService("InsertService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local VestirSala = {}

local S = Config.Sala
local plantillas: { [string]: Model | false } = {}

-- Plantilla de un modelo, ya a su medida, con el punto de apoyo en el centro de la base.
local function plantilla(clave: string): Model?
	local cacheada = plantillas[clave]
	if cacheada ~= nil then
		return cacheada or nil
	end
	local d = (S.Modelos :: any)[clave]
	local ok, cargado = pcall(function()
		return InsertService:LoadAsset(d.Id)
	end)
	if not ok or not cargado then
		warn(
			("[Sala] No cargó el modelo %s (%s): queda el bloque gris"):format(
				clave,
				tostring(cargado)
			)
		)
		plantillas[clave] = false
		return nil
	end
	local modelo = Instance.new("Model")
	modelo.Name = clave
	for _, p in cargado:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = true
			p.CanTouch = false
			p.CastShadow = false
			p.Parent = modelo
		end
	end
	cargado:Destroy()
	local _, t = modelo:GetBoundingBox()
	local medida = if d.Largo then math.max(t.X, t.Z) else t.Y
	if medida > 0 then
		modelo:ScaleTo((d.Largo or d.Alto) / medida)
	end
	local caja, tam = modelo:GetBoundingBox()
	modelo.WorldPivot = CFrame.new(caja.Position - Vector3.new(0, tam.Y / 2, 0))
	plantillas[clave] = modelo
	return modelo
end

-- Pone una copia del modelo `clave` con la base en `donde` y el frente hacia `donde.LookVector`.
-- Devuelve la copia (o nil si no cargó).
function VestirSala.poner(clave: string, donde: CFrame, padre: Instance): Model?
	local p = plantilla(clave)
	if not p then
		return nil
	end
	local copia = p:Clone()
	copia:PivotTo(donde * CFrame.Angles(0, math.rad(S.GiroModelos), 0))
	copia.Parent = padre
	return copia
end

-- Esconde un bloque gris que ya tiene modelo (sigue chocando y conservando tags y prompts).
function VestirSala.esconder(parte: Instance?)
	if parte and parte:IsA("BasePart") then
		parte.Transparency = 1
		for _, g in parte:GetChildren() do
			if g:IsA("SurfaceGui") then
				g.Enabled = false
			end
		end
	end
end

-- Base (en el piso) y frente de un bloque: misma X/Z, Y del piso, mirando a su LookVector.
local function base(parte: BasePart, altura: number, mira: Vector3?): CFrame
	local pos = Vector3.new(parte.Position.X, altura, parte.Position.Z)
	return CFrame.lookAt(pos, pos + (mira or parte.CFrame.LookVector))
end

-- Viste toda la sala (corre aparte: cargar modelos espera).
function VestirSala.vestir(sala: Instance)
	local altura = sala:GetAttribute("Altura") or 0
	local modelos = Instance.new("Folder")
	modelos.Name = "Modelos"
	modelos.Parent = sala

	-- Tu máquina, su banqueta y la mesita al lado. La pantalla gris queda invisible delante de la
	-- pantalla del modelo: es adonde va la cámara al sentarte.
	local carpetaMaquinas = sala:FindFirstChild("Maquinas")
	for _, m in if carpetaMaquinas then carpetaMaquinas:GetChildren() else {} do
		local cuerpo = m:FindFirstChild("Cuerpo") :: BasePart?
		if not cuerpo then
			continue
		end
		local adelante = Vector3.new(0, 0, 1)
		local copia = VestirSala.poner("maquina", base(cuerpo, altura, adelante), m) -- adentro de la máquina gris: el contorno amarillo la abraza
		if copia then
			VestirSala.esconder(cuerpo)
			VestirSala.esconder(m:FindFirstChild("Cartel"))
			VestirSala.esconder(m:FindFirstChild("Botonera"))
			local pantalla = m:FindFirstChild("Pantalla") :: BasePart?
			if pantalla then
				local caja, t = copia:GetBoundingBox()
				pantalla.Transparency = 1
				pantalla.Position = Vector3.new(
					cuerpo.Position.X,
					altura + S.Modelos.maquina.Alto * S.AlturaPantalla,
					caja.Position.Z + t.Z / 2 - S.HundidoPantalla
				)
			end
		end
		local banqueta = m:FindFirstChild("Banqueta") :: BasePart?
		if banqueta and VestirSala.poner("banqueta", base(banqueta, altura, adelante), modelos) then
			VestirSala.esconder(banqueta)
		end
		local junto = cuerpo.Position
			+ Vector3.new(S.MaquinaTamanio.X / 2 + 1.6, 0, S.MaquinaTamanio.Z / 2 + 2.4)
		VestirSala.poner(
			"mesa",
			CFrame.new(junto.X, altura, junto.Z) * CFrame.Angles(0, math.rad(-20), 0),
			modelos
		)
	end

	-- Máquinas de fondo (atributo Tipo: 1 naves, 2 autos, 3 laberinto).
	local tipos = { "naves", "autos", "laberinto" }
	for _, m in sala:GetChildren() do
		local cuerpo = m:FindFirstChild("Cuerpo") :: BasePart?
		local tipo = m:GetAttribute("Tipo")
		if m:IsA("Model") and cuerpo and typeof(tipo) == "number" then
			if VestirSala.poner(tipos[tipo] or "naves", base(cuerpo, altura), modelos) then
				VestirSala.esconder(cuerpo)
				VestirSala.esconder(m:FindFirstChild("Pantalla"))
			end
		end
	end

	-- Mostrador (mira a la sala, -X) con 2 cajitas de vidrio arriba.
	local mostrador = sala:FindFirstChild("Mostrador") :: BasePart?
	if mostrador then
		local copia =
			VestirSala.poner("mostrador", base(mostrador, altura, Vector3.new(-1, 0, 0)), modelos)
		if copia then
			VestirSala.esconder(mostrador)
			local caja, t = copia:GetBoundingBox()
			for _, dz in { -3.2, 3.2 } do
				local pos =
					Vector3.new(caja.Position.X, caja.Position.Y + t.Y / 2, caja.Position.Z + dz)
				VestirSala.poner("cajita", CFrame.lookAt(pos, pos + Vector3.new(-1, 0, 0)), modelos)
			end
		end
	end

	-- Marco de la pared de récords: contra la pared sur, mirando a la sala; el cartel con tus
	-- récords queda delante del marco.
	local records = sala:FindFirstChild("Records") :: BasePart?
	if records then
		local pos = Vector3.new(records.Position.X, altura + S.AlturaRecords, S.Largo / 2)
		local copia =
			VestirSala.poner("records", CFrame.lookAt(pos, pos - Vector3.new(0, 0, 1)), modelos)
		if copia then
			local caja, t = copia:GetBoundingBox()
			copia:PivotTo(
				copia:GetPivot() + Vector3.new(0, 0, S.Largo / 2 - (caja.Position.Z + t.Z / 2))
			)
			caja, t = copia:GetBoundingBox()
			records.Size = Vector3.new(t.X * 0.78, t.Y * 0.7, 0.2)
			records.Position =
				Vector3.new(caja.Position.X, caja.Position.Y, caja.Position.Z - t.Z / 2 - 0.12)
		end
	end

	-- Entrada: 2 molinetes y 2 tachos. Decoración: macetas en las esquinas y postes de neón.
	local entradaZ = S.Largo / 2 - 2
	for _, x in { -3.2, 3.2 } do
		VestirSala.poner(
			"molinete",
			CFrame.lookAt(Vector3.new(x, altura, entradaZ), Vector3.new(x, altura, entradaZ - 1)),
			modelos
		)
		VestirSala.poner("tacho", CFrame.new(x * 2.2, altura, entradaZ - 0.5), modelos)
	end
	for _, molinete in sala:GetChildren() do
		if molinete.Name == "Molinete" and molinete:IsA("BasePart") then
			VestirSala.esconder(molinete)
			molinete.CanCollide = false
		end
	end
	local mx, mz = S.Ancho / 2 - 3, S.Largo / 2 - 3
	for _, esquina in
		{ Vector2.new(-mx, -mz), Vector2.new(mx, -mz), Vector2.new(-mx, mz), Vector2.new(mx, mz) }
	do
		VestirSala.poner("maceta", CFrame.new(esquina.X, altura, esquina.Y), modelos)
	end
	for _, punto in S.Postes do
		VestirSala.poner("poste", CFrame.new(punto.X, altura, punto.Y), modelos)
	end
	print("[Sala] Modelos puestos")
end

return VestirSala
