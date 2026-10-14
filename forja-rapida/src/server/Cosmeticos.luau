--!strict
-- Cosméticos del Museo (Grupo 3): auras, diseños de pico, estilos de vitrina y decoraciones.
-- Se ganan completando colecciones (GameConfig.Logros con Premio.Cosmetico) y se eligen con
-- Remotos.Equipar (tipo, Id o "" para sacarlo). El servidor revisa que lo tengas.
--   Pico en la mano: una herramienta "Pico" en el personaje (así el personaje la sostiene). El
--   diseño Clásico usa el color del pico que compraste; los demás, sus colores y material.
--   Aura: la dibuja cada cliente (atributo Aura del jugador), así respeta "Efectos reducidos".
--   Vitrina y decoración: las arma Social.luau en la vitrina del jugador.
--   Grupo 4, evolución del pico (tipo "Efecto"): partículas, estelas, luces y cristalitos en la
--   cabeza del pico. Solo se ve: la Fuerza sale del pico comprado, nunca del efecto. Con
--   "Efectos reducidos", cada cliente apaga las partículas de los picos (Cosmeticos.client).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)
local Social = require(script.Parent.Social)

local Cosmeticos = {}

local ultimo: { [Player]: number } = {}
local SIN_QUITAR = { Pico = "Clasico", Vitrina = "Clasica" } -- estos vuelven al clásico

local function material(nombre: string?, porDefecto: Enum.Material): Enum.Material
	if not nombre then
		return porDefecto
	end
	local ok, m = pcall(function()
		return (Enum.Material :: any)[nombre]
	end)
	return if ok and typeof(m) == "EnumItem" then m :: Enum.Material else porDefecto
end

local function parte(nombre: string, tam: Vector3, color: Color3, mat: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Color = color
	p.Material = mat
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false -- que los clics para golpear geodas no lo toquen
	p.Massless = true
	p.CastShadow = false
	return p
end

local function adjunto(donde: BasePart, nombre: string, pos: Vector3): Attachment
	local a = Instance.new("Attachment")
	a.Name = nombre
	a.Position = pos
	a.Parent = donde
	return a
end

local function secuencia(colores: { string }): ColorSequence
	local c1 = Color3.fromHex(colores[1] or "#FFFFFF")
	local c2 = Color3.fromHex(colores[2] or colores[1] or "#FFFFFF")
	return ColorSequence.new(c1, c2)
end

local function particulas(
	hoja: BasePart,
	colores: { string },
	o: { [string]: any }
): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = "Evolucion"
	e.Color = secuencia(colores)
	e.LightEmission = 1
	e.Size = NumberSequence.new(o.Tam or 0.35, 0)
	e.Transparency = NumberSequence.new(0, 1)
	e.Rate = o.Cantidad or 12
	e.Lifetime = NumberRange.new(o.Vida or 0.8, (o.Vida or 0.8) * 1.5)
	e.Speed = NumberRange.new(o.Velocidad or 0.6)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-90, 90)
	e.Drag = o.Freno or 1
	e.LockedToPart = o.Pegadas == true
	e.Parent = hoja
	return e
end

local function estela(hoja: BasePart, colores: { string }, vida: number, ancho: number)
	local a0 = adjunto(hoja, "EstelaArriba", Vector3.new(0, 1.3, 0))
	local a1 = adjunto(hoja, "EstelaAbajo", Vector3.new(0, -1.3, 0))
	local t = Instance.new("Trail")
	t.Name = "Evolucion"
	t.Attachment0, t.Attachment1 = a0, a1
	t.Color = secuencia(colores)
	t.Transparency = NumberSequence.new(0.15, 1)
	t.Lifetime = vida
	t.LightEmission = 1
	t.FaceCamera = true
	t.WidthScale = NumberSequence.new(ancho, 0)
	t.Parent = hoja
end

local function luzEfecto(hoja: BasePart, color: string, rango: number)
	local l = Instance.new("PointLight")
	l.Name = "Evolucion"
	l.Color = Color3.fromHex(color)
	l.Range = rango
	l.Brightness = 1.5
	l.Shadows = false
	l.Parent = hoja
end

-- Pone la evolución elegida en la cabeza del pico (Grupo 4).
local function evolucion(t: Tool, handle: BasePart, hoja: BasePart, efecto: GameConfig.Cosmetico)
	local c = efecto.Colores
	local forma = efecto.Forma
	if forma == "Metalico" then
		hoja.Reflectance = 0.35
		local brillo = Instance.new("Sparkles")
		brillo.Name = "Evolucion"
		brillo.SparkleColor = Color3.fromHex(c[1])
		brillo.Parent = hoja
	elseif forma == "Cristales" then
		for i, lado in { -1, 0, 1 } do
			local cr = parte(
				"Cristal",
				Vector3.new(0.22, 0.7 - math.abs(lado) * 0.2, 0.22),
				Color3.fromHex(c[(i % 2) + 1]),
				Enum.Material.Neon
			)
			cr.CFrame = hoja.CFrame
				* CFrame.new(0, lado * 0.8, -0.35)
				* CFrame.Angles(-0.6, 0, lado * 0.3)
			local w = Instance.new("WeldConstraint")
			w.Part0, w.Part1 = handle, cr
			w.Parent = cr
			cr.Parent = t
		end
		luzEfecto(hoja, c[1], 8)
	elseif forma == "Runas" then
		-- un anillo de runas (cuadraditos que brillan) alrededor de la cabeza
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			local runa = parte(
				"Runa",
				Vector3.new(0.18, 0.18, 0.04),
				Color3.fromHex(c[(k % 2) + 1]),
				Enum.Material.Neon
			)
			runa.CFrame = hoja.CFrame
				* CFrame.new(0, math.cos(a) * 1.15, math.sin(a) * 0.6)
				* CFrame.Angles(0, 0, a)
			local w = Instance.new("WeldConstraint")
			w.Part0, w.Part1 = handle, runa
			w.Parent = runa
			runa.Parent = t
		end
		particulas(hoja, c, { Cantidad = 10, Vida = 1.2, Velocidad = 0.3, Tam = 0.3 })
		luzEfecto(hoja, c[2], 7)
	elseif forma == "Fuego" then
		estela(hoja, c, 0.35, 0.9)
		local fuego = Instance.new("Fire")
		fuego.Name = "Evolucion"
		fuego.Size = 2
		fuego.Heat = 4
		fuego.Color = Color3.fromHex(c[2])
		fuego.SecondaryColor = Color3.fromHex(c[1])
		fuego.Parent = hoja
		if efecto.Id == "Fenix" then
			local brillo = Instance.new("Sparkles")
			brillo.Name = "Evolucion"
			brillo.SparkleColor = Color3.fromHex(c[1])
			brillo.Parent = hoja
		end
	elseif forma == "Rayos" then
		particulas(hoja, c, {
			Cantidad = 28,
			Vida = 0.12,
			Velocidad = 7,
			Tam = 0.18,
			Freno = 0,
		})
		estela(hoja, c, 0.15, 0.35)
		luzEfecto(hoja, c[2], 7)
	elseif forma == "Cosmico" then
		particulas(hoja, c, { Cantidad = 18, Vida = 1.2, Velocidad = 0.4, Tam = 0.45, Freno = 2 })
		estela(hoja, c, 0.4, 0.7)
		luzEfecto(hoja, c[1], 8)
	end
	t:SetAttribute("Efecto", efecto.Id)
end

-- Arma la herramienta "Pico" con el diseño y el nivel de pico del jugador.
local function armarPico(d: Jugadores.Datos): Tool
	local diseno = Reglas.cosmetico("Pico", d.Equipado.Pico or "Clasico")
	local nivel = GameConfig.Picos[d.Pico] or GameConfig.Picos[1]
	local colores = diseno and diseno.Colores or {}
	local cabeza = Color3.fromHex(colores[1] or nivel.Color)
	local mango = Color3.fromHex(colores[2] or "#8A5A2B")
	local mat = material(diseno and diseno.Material, Enum.Material.Metal)

	local t = Instance.new("Tool")
	t.Name = "Pico"
	t.CanBeDropped = false
	t.RequiresHandle = true
	t.ToolTip = nivel.Nombre
	-- el mango va a lo largo de Z; se agarra cerca de la punta de atrás
	t.Grip = CFrame.new(0, 0, 1)
	local handle = parte("Handle", Vector3.new(0.35, 0.35, 3.4), mango, Enum.Material.Wood)
	handle.Parent = t
	local hoja = parte("Cabeza", Vector3.new(0.45, 2.8, 0.5), cabeza, mat)
	hoja.CFrame = handle.CFrame * CFrame.new(0, 0, -1.55)
	hoja.Parent = t
	for _, punta in { 1, -1 } do
		local p = parte("Punta", Vector3.new(0.3, 0.6, 0.35), cabeza, mat)
		p.CFrame = hoja.CFrame * CFrame.new(0, punta * 1.6, 0.15) * CFrame.Angles(punta * 0.5, 0, 0)
		p.Parent = t
		local w = Instance.new("WeldConstraint")
		w.Part0, w.Part1 = handle, p
		w.Parent = p
	end
	local w = Instance.new("WeldConstraint")
	w.Part0, w.Part1 = handle, hoja
	w.Parent = hoja
	if mat == Enum.Material.Neon then
		local luz = Instance.new("PointLight")
		luz.Color = cabeza
		luz.Range = 6
		luz.Brightness = 1.2
		luz.Parent = hoja
	end
	t:SetAttribute("Diseno", diseno and diseno.Id or "Clasico")
	local efecto = d.Equipado.Efecto and Reglas.cosmetico("Efecto", d.Equipado.Efecto)
	if efecto then
		evolucion(t, handle, hoja, efecto)
	end
	return t
end

-- Pone (o cambia) el pico en la mano del personaje.
function Cosmeticos.ponerPico(jugador: Player)
	local d = Jugadores.obtener(jugador)
	local personaje = jugador.Character
	if not d or not personaje then
		return
	end
	local viejo = personaje:FindFirstChild("Pico")
	if viejo and viejo:IsA("Tool") then
		viejo:Destroy()
	end
	local mochila = jugador:FindFirstChildOfClass("Backpack")
	local enMochila = mochila and mochila:FindFirstChild("Pico")
	if enMochila then
		enMochila:Destroy()
	end
	armarPico(d).Parent = personaje -- en el personaje = en la mano
end

local function alEquipar(jugador: Player, tipo: unknown, id: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(tipo) ~= "string" or typeof(id) ~= "string" then
		return
	end
	if not Reglas.tiposCosmeticos()[tipo] then
		return
	end
	local t = os.clock()
	if ultimo[jugador] and t - ultimo[jugador] < 0.3 then
		return
	end
	ultimo[jugador] = t
	if id == "" then
		d.Equipado[tipo] = SIN_QUITAR[tipo :: any]
	elseif Reglas.tieneCosmetico(tipo, id, d.Logros) then
		d.Equipado[tipo] = id
	else
		return
	end
	Jugadores.publicar(jugador)
	if tipo == "Pico" or tipo == "Efecto" then
		Cosmeticos.ponerPico(jugador)
	elseif tipo == "Vitrina" or tipo == "Decoracion" then
		Social.refrescar(jugador)
	end
end

local function seguir(jugador: Player)
	jugador.CharacterAdded:Connect(function()
		task.defer(Cosmeticos.ponerPico, jugador)
	end)
	-- al comprar un pico nuevo cambia el color del Clásico
	jugador:GetAttributeChangedSignal("Pico"):Connect(function()
		Cosmeticos.ponerPico(jugador)
	end)
	if jugador.Character then
		task.defer(Cosmeticos.ponerPico, jugador)
	end
end

function Cosmeticos.iniciar()
	Remotos.Equipar.OnServerEvent:Connect(alEquipar)
	Players.PlayerAdded:Connect(seguir)
	for _, j in Players:GetPlayers() do
		seguir(j)
	end
	Players.PlayerRemoving:Connect(function(jugador: Player)
		ultimo[jugador] = nil
	end)
end

return Cosmeticos
