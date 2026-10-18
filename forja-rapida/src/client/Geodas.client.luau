--!strict
-- Lo que cada jugador ve en las geodas (Grupo 1): el cartel con modificador, nombre y barra de
-- vida (como "Huevo de roca / Común / 6/11 PV" de las capturas), y el aura de su modificador:
--   Lava   chispas que suben, luz naranja y un anillo de cubitos que gira (como la vaca de lava)
--   Neón   cubitos de colores que titilan sobre la roca y destellos (como el gato arcoíris)
--   Dorada destellos dorados y motitas verdes (como el cocodrilo de oro)
--   Vacío  motas violetas, estrellitas blancas y una luz violeta grande
-- Las combinaciones juntan los efectos de sus dos partes. Las grietas (parte "Grietas") laten.
-- Todo sale del atributo Modificador que puso el servidor, así lo que se ve es lo que hay.
-- Rendimiento: un solo bucle para todas las animaciones, y lo que está lejos no anima ni tira
-- partículas. Con "Efectos reducidos": sin anillo ni cubitos, menos partículas y menos alcance.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

type Vista = {
	Modelo: Model,
	Roca: BasePart,
	Cartel: BillboardGui,
	Relleno: Frame,
	TextoVida: TextLabel,
	Aura: { Instance }, -- todo lo que se crea para el aura (se borra junto)
	Emisores: { { Emisor: ParticleEmitter, Ritmo: number } },
	Anillo: { BasePart }, -- cubitos (o la malla) del anillo de lava
	Pixeles: { BasePart }, -- cubitos neón que titilan
	Grietas: { BasePart },
	Conexiones: { RBXScriptConnection },
	Fase: number,
	Cerca: boolean,
}

local vistas: { [Model]: Vista } = {}
local rng = Random.new()

-- Cartel ------------------------------------------------------------------------------------

local function crearCartel(m: Model, roca: BasePart): (BillboardGui, Frame, TextLabel)
	local tam = Reglas.tamano(tostring(m:GetAttribute("Tamano")))
	local mod = Reglas.modificador(tostring(m:GetAttribute("Modificador")))
	local nombre = if tam then tam.Nombre else "Geoda"
	-- arriba de todo el modelo (los cristales sobresalen de la roca)
	local caja, tamCaja = m:GetBoundingBox()
	local alto = math.max(roca.Size.Y / 2, caja.Position.Y + tamCaja.Y / 2 - roca.Position.Y) + 1.2
	local b, relleno, texto
	-- Jefes y eventos: cartel grande con calavera (jefes) o estrella (eventos)
	if tam and (tam.Id == "Jefe" or tam.Id == "Ancestral" or tam.Id == "Renacida") then
		local icono = if tam.Id == "Renacida" then "Chispa" else "Jefe"
		b, relleno, texto = Estilo.cartelJefe(roca, alto + 2, nombre, icono)
	else
		-- la rareza de la geoda es su modificador ("Común" si no tiene)
		local exotica = mod ~= nil and Reglas.esExotica(mod.Id)
		local rareza = if mod and mod.Id ~= "Normal" then mod.Nombre else "Común"
		local color = if mod and mod.Id ~= "Normal"
			then Color3.fromHex(mod.Color)
			else Color3.fromHex(Estilo.Rarezas.Comun[1])
		-- Grupo 4: el nombre de su roca, si no es la de siempre ("Musgosa", "de Obsidiana"...)
		local variante = m:GetAttribute("Variante")
		if typeof(variante) == "string" and variante ~= "" then
			rareza ..= " · " .. variante
		end
		b, relleno, texto = Estilo.cartelGeoda(
			roca,
			alto,
			nombre,
			rareza,
			color,
			if exotica and mod then Reglas.partes(mod.Id) else nil
		)
	end
	b.Name = "Cartel"
	b.Parent = m
	return b, relleno, texto
end

local function actualizarVida(v: Vista)
	local vida = tonumber(v.Modelo:GetAttribute("Vida")) or 0
	local maxima = math.max(1, tonumber(v.Modelo:GetAttribute("VidaMax")) or 1)
	local parte = math.clamp(vida / maxima, 0, 1)
	TweenService:Create(v.Relleno, TweenInfo.new(0.12), { Size = UDim2.fromScale(parte, 1) }):Play()
	v.TextoVida.Text = Formato.corto(vida) .. "/" .. Formato.corto(maxima) .. " PV"
end

-- Aura --------------------------------------------------------------------------------------

local function emisor(
	v: Vista,
	padre: Instance,
	colores: { Color3 },
	ritmo: number,
	velocidad: NumberRange,
	vida: NumberRange,
	tamano: number,
	arriba: boolean
): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	local puntos = {}
	for i, c in colores do
		table.insert(puntos, ColorSequenceKeypoint.new((i - 1) / math.max(1, #colores - 1), c))
	end
	if #puntos == 1 then
		table.insert(puntos, ColorSequenceKeypoint.new(1, colores[1]))
	end
	e.Color = ColorSequence.new(puntos)
	e.LightEmission = 1
	e.Speed = velocidad
	e.Lifetime = vida
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, tamano),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Transparency =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
	if arriba then
		e.EmissionDirection = Enum.NormalId.Top
		e.SpreadAngle = Vector2.new(35, 35)
		e.Acceleration = Vector3.new(0, 2, 0)
	else
		e.SpreadAngle = Vector2.new(180, 180)
	end
	e.Rate = if Efectos.reducidos() then ritmo * 0.3 else ritmo
	e.Parent = padre
	table.insert(v.Emisores, { Emisor = e, Ritmo = ritmo })
	table.insert(v.Aura, e)
	return e
end

local function luz(v: Vista, padre: Instance, color: Color3, alcance: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = alcance
	l.Brightness = 2
	l.Shadows = false
	l.Parent = padre
	table.insert(v.Aura, l)
end

local function cubito(v: Vista, tamano: number, color: Color3): Part
	local p = Instance.new("Part")
	p.Size = Vector3.one * tamano
	p.Anchored = true
	p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Parent = v.Modelo
	table.insert(v.Aura, p)
	return p
end

-- Anillo de lava: la malla de Blender si está (ReplicatedStorage.Modelos.Anillo), si no 14 cubitos.
local function anillo(v: Vista, color: Color3)
	local radio = math.max(v.Roca.Size.X, v.Roca.Size.Z) * 0.75
	local modelos = ReplicatedStorage:FindFirstChild("Modelos")
	local malla = modelos and modelos:FindFirstChild("Anillo")
	if malla and malla:IsA("BasePart") then
		local a = malla:Clone()
		a.Anchored = true
		a.CanCollide, a.CanQuery, a.CanTouch = false, false, false
		a.Size = a.Size * (radio * 2 / math.max(a.Size.X, 0.01))
		a.Material = Enum.Material.Neon
		a.Color = color
		a.Parent = v.Modelo
		table.insert(v.Aura, a)
		table.insert(v.Anillo, a)
		return
	end
	for _ = 1, 14 do
		table.insert(v.Anillo, cubito(v, v.Roca.Size.X * 0.09, color))
	end
end

-- Puntos sobre la superficie de la roca (para los cubitos neón).
local function puntosSuperficie(roca: BasePart, cantidad: number): { CFrame }
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Include
	filtro.FilterDescendantsInstances = { roca }
	local r = roca.Size.Magnitude
	local puntos = {}
	for _ = 1, cantidad * 3 do
		local dir = rng:NextUnitVector()
		if dir.Y < -0.3 then
			continue -- abajo no se ve
		end
		local desde = roca.Position + dir * r
		local golpe = Workspace:Raycast(desde, roca.Position - desde, filtro)
		if golpe then
			table.insert(puntos, CFrame.lookAt(golpe.Position, golpe.Position + golpe.Normal))
			if #puntos >= cantidad then
				break
			end
		end
	end
	return puntos
end

local function crearAura(v: Vista)
	local mod = Reglas.modificador(tostring(v.Modelo:GetAttribute("Modificador")))
	if not mod or not Reglas.esExotica(mod.Id) then
		return
	end
	local reducidos = Efectos.reducidos()
	v.Cerca = true -- el bucle vuelve a revisar la distancia
	local centro = Instance.new("Attachment")
	centro.Name = "AuraCliente"
	centro.Parent = v.Roca
	table.insert(v.Aura, centro)
	local r = v.Roca.Size.Magnitude
	for _, parte in Reglas.partes(mod.Id) do
		local def = Reglas.modificador(parte)
		local color = if def then Color3.fromHex(def.Color) else Color3.new(1, 1, 1)
		if parte == "Lava" then
			local rojo = Color3.fromHex("#FF2A00")
			emisor(
				v,
				centro,
				{ Color3.fromHex("#FFE14D"), color, rojo },
				14,
				NumberRange.new(2, 4),
				NumberRange.new(0.8, 1.4),
				0.35,
				true
			)
			luz(v, centro, color, r * 1.6)
			if not reducidos then
				anillo(v, color)
			end
		elseif parte == "Neon" then
			local s = Instance.new("Sparkles")
			s.SparkleColor = color
			s.Parent = centro
			table.insert(v.Aura, s)
			luz(v, centro, color, r * 1.6)
			if not reducidos then
				for _, cf in puntosSuperficie(v.Roca, 10) do
					local p =
						cubito(v, v.Roca.Size.X * 0.08, Color3.fromHSV(rng:NextNumber(), 0.8, 1))
					p.CFrame = cf
					table.insert(v.Pixeles, p)
				end
			end
		elseif parte == "Midas" then
			emisor(
				v,
				centro,
				{ color, Color3.fromHex("#FFF3B0") },
				10,
				NumberRange.new(1, 2),
				NumberRange.new(1, 2),
				0.45,
				false
			)
			emisor(
				v,
				centro,
				{ Color3.fromHex("#7CFF6B") },
				4,
				NumberRange.new(0.5, 1),
				NumberRange.new(1.5, 2.5),
				0.25,
				true
			)
			luz(v, centro, color, r * 2)
		elseif parte == "Vacio" then
			emisor(
				v,
				centro,
				{ color, Color3.fromHex("#4D2BFF") },
				18,
				NumberRange.new(0.5, 1.2),
				NumberRange.new(1.5, 2.5),
				0.6,
				false
			)
			emisor(
				v,
				centro,
				{ Color3.new(1, 1, 1) },
				4,
				NumberRange.new(0.2, 0.6),
				NumberRange.new(1, 2),
				0.2,
				false
			)
			luz(v, centro, color, r * 2.5)
		end
	end
	-- SONIDO: aura de la geoda exótica (GameConfig.Modificadores[..].Sonido)
	local sonido = Sonidos.bucle(mod.Sonido, v.Roca)
	if sonido then
		table.insert(v.Aura, sonido)
	end
end

local function limpiarAura(v: Vista)
	for _, i in v.Aura do
		i:Destroy()
	end
	v.Aura, v.Emisores, v.Anillo, v.Pixeles = {}, {}, {}, {}
end

-- Ciclo de vida ------------------------------------------------------------------------------

local function polvo(roca: BasePart)
	-- al romperse: una nube de cubitos del color de la roca (la revelación grande es solo para
	-- el que la rompió; ver Revelacion.client.luau)
	local a = Instance.new("Attachment")
	a.WorldPosition = roca.Position
	a.Parent = Workspace.Terrain
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(roca.Color)
	e.Speed = NumberRange.new(6, 12)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Lifetime = NumberRange.new(0.4, 0.8)
	e.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
	e.Acceleration = Vector3.new(0, -30, 0)
	e.Rate = 0
	e.Parent = a
	e:Emit(if Efectos.reducidos() then 8 else 25)
	Debris:AddItem(a, 1.5)
end

local function quitar(m: Model)
	local v = vistas[m]
	if not v then
		return
	end
	vistas[m] = nil
	for _, c in v.Conexiones do
		c:Disconnect()
	end
	limpiarAura(v)
	v.Cartel:Destroy()
end

local function agregar(m: Instance)
	if not m:IsA("Model") or vistas[m] then
		return
	end
	local roca = m:FindFirstChild("Roca", true)
	if not roca or not roca:IsA("BasePart") then
		return
	end
	local cartel, relleno, texto = crearCartel(m, roca)
	local grietas = {}
	for _, p in m:GetDescendants() do
		if
			p:IsA("BasePart")
			and (p.Name == "Grietas" or p.Name == "Grietas2")
			and p.Transparency < 1
		then
			table.insert(grietas, p)
		end
	end
	local v: Vista = {
		Modelo = m,
		Roca = roca,
		Cartel = cartel,
		Relleno = relleno,
		TextoVida = texto,
		Aura = {},
		Emisores = {},
		Anillo = {},
		Pixeles = {},
		Grietas = grietas,
		Conexiones = {},
		Fase = rng:NextNumber() * 10,
		Cerca = true,
	}
	vistas[m] = v
	actualizarVida(v)
	crearAura(v)
	table.insert(
		v.Conexiones,
		m:GetAttributeChangedSignal("Vida"):Connect(function()
			actualizarVida(v)
		end)
	)
	table.insert(
		v.Conexiones,
		m:GetAttributeChangedSignal("Rota"):Connect(function()
			if m:GetAttribute("Rota") == true then
				polvo(roca)
				-- la geoda desaparece ya: el servidor la deja un rato más por la revelación
				for _, p in m:GetDescendants() do
					if p:IsA("BasePart") then
						p.LocalTransparencyModifier = 1
					end
				end
				-- SONIDO: geoda que se rompe (para todos los que están cerca)
				Sonidos.tocar(GameConfig.Sonidos.Romper, 0.9 + rng:NextNumber() * 0.2, 0.5, roca)
				quitar(m)
			end
		end)
	)
	table.insert(
		v.Conexiones,
		m.Destroying:Connect(function()
			quitar(m)
		end)
	)
end

CollectionService:GetInstanceAddedSignal("Geoda"):Connect(agregar)
CollectionService:GetInstanceRemovedSignal("Geoda"):Connect(function(m: Instance)
	if m:IsA("Model") then
		quitar(m)
	end
end)
for _, m in CollectionService:GetTagged("Geoda") do
	task.spawn(agregar, m)
end

-- Si cambia el ajuste de efectos, se rearman las auras.
Efectos.alCambiar(function()
	for _, v in vistas do
		limpiarAura(v)
		crearAura(v)
	end
end)

-- Un solo bucle para todas las animaciones --------------------------------------------------

local proximoChequeo = 0
local proximoPixel = 0
RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local camara = Workspace.CurrentCamera
	if not camara then
		return
	end
	-- Cada 0,25 s: qué geodas están cerca (las lejanas no animan ni tiran partículas).
	if t >= proximoChequeo then
		proximoChequeo = t + 0.25
		local alcance = Efectos.distanciaAura()
		local reducidos = Efectos.reducidos()
		for _, v in vistas do
			local cerca = (camara.CFrame.Position - v.Roca.Position).Magnitude <= alcance
			if cerca ~= v.Cerca then
				v.Cerca = cerca
				for _, e in v.Emisores do
					e.Emisor.Enabled = cerca
					e.Emisor.Rate = if reducidos then e.Ritmo * 0.3 else e.Ritmo
				end
				for _, p in v.Anillo do
					p.Transparency = if cerca then 0 else 1
				end
			end
		end
	end
	local cambiarPixel = t >= proximoPixel
	if cambiarPixel then
		proximoPixel = t + 0.12
	end
	for _, v in vistas do
		if not v.Cerca then
			continue
		end
		-- grietas que laten
		for _, g in v.Grietas do
			g.Transparency = 0.1 + 0.4 * (0.5 + 0.5 * math.sin(t * 3 + v.Fase))
		end
		-- anillo de lava que gira, un poco inclinado
		local n = #v.Anillo
		if n > 0 then
			local centro = CFrame.new(v.Roca.Position) * CFrame.Angles(0.35, 0, 0.15)
			if n == 1 then
				v.Anillo[1].CFrame = centro * CFrame.Angles(0, t * 0.8, 0)
			else
				local radio = math.max(v.Roca.Size.X, v.Roca.Size.Z) * 0.75
				for i, p in v.Anillo do
					local a = t * 0.8 + (i / n) * math.pi * 2
					p.CFrame = centro * CFrame.Angles(0, a, 0) * CFrame.new(radio, 0, 0)
				end
			end
		end
		-- cubitos neón que cambian de color
		if cambiarPixel and #v.Pixeles > 0 then
			local p = v.Pixeles[rng:NextInteger(1, #v.Pixeles)]
			p.Color = Color3.fromHSV(rng:NextNumber(), 0.8, 1)
		end
	end
end)
