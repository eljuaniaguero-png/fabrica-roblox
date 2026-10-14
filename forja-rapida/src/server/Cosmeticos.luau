--!strict
-- Cosméticos del Museo (Grupo 3): auras, diseños de pico, estilos de vitrina y decoraciones.
-- Se ganan completando colecciones (GameConfig.Logros con Premio.Cosmetico) y se eligen con
-- Remotos.Equipar (tipo, Id o "" para sacarlo). El servidor revisa que lo tengas.
--   Pico en la mano: una herramienta "Pico" en el personaje (así el personaje la sostiene). El
--   diseño Clásico usa el color del pico que compraste; los demás, sus colores y material.
--   Aura: la dibuja cada cliente (atributo Aura del jugador), así respeta "Efectos reducidos".
--   Vitrina y decoración: las arma Social.luau en la vitrina del jugador.

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
	if tipo == "Pico" then
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
