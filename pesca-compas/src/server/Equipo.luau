--!strict
-- Lo que el jugador lleva encima, visible para todo el server: la caña en la mano derecha
-- (carrete del color de su nivel), el cebo puesto colgando de la punta con una cuerda, y la
-- línea de pesca de la punta a la boya mientras espera.
-- Todo es adorno: no cambia nada del loop ni de la economía, y lo arma el servidor a partir de
-- datos que ya valida (nivel de caña, cebo con tiradas). El cliente no manda nada.
-- Se refresca solo cada vez que Jugadores.enviar le manda el estado al cliente.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Estilo = require(ReplicatedStorage.Shared.Estilo)
local Limpieza = require(ReplicatedStorage.Shared.Limpieza)
local ModeloEquipo = require(ReplicatedStorage.Shared.ModeloEquipo)
local Jugadores = require(script.Parent.Jugadores)
local Monetizacion = require(script.Parent.Monetizacion)
local Tienda = require(script.Parent.Tienda)

local PASE_DORADO = "CarreteDorado" -- clave de Config.Pases

-- Puño en la mano derecha R15 (sale de la palma, vara hacia adelante y un poco arriba).
-- Ajustado en Play contra las poses de AnimBorrador.luau.
local AGARRE = CFrame.new(0, -0.15, 0) * CFrame.Angles(math.rad(35), 0, 0)
local CUERDA_CEBO = 1.2 -- studs de la punta al cebo
local ALTO_CEBO = 0.8 -- studs: en la tienda se ve grande, colgando tiene que ser chiquito

type Equipado = {
	Limpieza: Limpieza.Limpieza, -- se suelta al morir o reaparecer
	Cana: Model,
	Punta: Attachment,
	Nivel: number,
	Dorado: boolean, -- pase Carrete Dorado
	CeboId: string, -- "" = sin cebo
	Cebo: Model?,
	Cuerda: RopeConstraint?,
	Lanzado: boolean, -- con la boya en el agua el cebo va con la línea, no en la punta
}

local Equipo = {}

local equipados: { [Player]: Equipado } = {}

local function ceboDe(jugador: Player): string
	local d = Jugadores.obtener(jugador)
	local cebo = d and Tienda.ceboActivo(d)
	return if cebo then cebo.Id else ""
end

local function mostrarCebo(eq: Equipado, visible: boolean)
	local cebo = eq.Cebo
	if not cebo then
		return
	end
	for _, d in cebo:GetDescendants() do
		if d:IsA("BasePart") then
			d.Transparency = if visible then 0 else 1
		end
	end
	if eq.Cuerda then
		eq.Cuerda.Visible = visible
	end
end

local function sacarCebo(eq: Equipado)
	if eq.Cebo then
		eq.Cebo:Destroy() -- la cuerda y el ojal viven adentro del cebo
	end
	eq.Cebo = nil
	eq.Cuerda = nil
end

-- Cuelga el cebo de la punta con una cuerda de verdad: se balancea al caminar y al lanzar.
local function ponerCebo(jugador: Player, eq: Equipado, id: string)
	sacarCebo(eq)
	eq.CeboId = id
	if id == "" then
		return
	end
	local cebo = ModeloEquipo.cebo(id, ALTO_CEBO)
	local principal = cebo.PrimaryPart
	if not principal then
		cebo:Destroy()
		return
	end
	for _, d in cebo:GetDescendants() do
		if d:IsA("BasePart") then
			d.Massless = false -- colgado de una cuerda no hay soldadura: necesita algo de peso
			d.CustomPhysicalProperties = PhysicalProperties.new(0.05, 0.3, 0.5)
		end
	end
	local ojal = Instance.new("Attachment")
	ojal.Name = "Ojal"
	ojal.CFrame = principal.CFrame:ToObjectSpace(cebo:GetPivot())
	ojal.Parent = principal
	local cuerda = Instance.new("RopeConstraint")
	cuerda.Attachment0 = eq.Punta
	cuerda.Attachment1 = ojal
	cuerda.Length = CUERDA_CEBO
	cuerda.Visible = true
	cuerda.Thickness = 0.04
	cuerda.Color = BrickColor.new(Estilo.Cana.Linea)
	cuerda.Parent = principal
	cebo:PivotTo(eq.Punta.WorldCFrame * CFrame.new(0, -CUERDA_CEBO, 0))
	cebo.Parent = eq.Cana
	eq.Cebo = cebo
	eq.Cuerda = cuerda
	-- que lo simule el jugador, igual que su personaje: si no, la cuerda tironea con lag
	if principal:CanSetNetworkOwnership() then
		principal:SetNetworkOwner(jugador)
	end
	mostrarCebo(eq, not eq.Lanzado)
end

local function equipar(jugador: Player, personaje: Model)
	local anterior = equipados[jugador]
	if anterior then
		anterior.Limpieza:limpiar()
		equipados[jugador] = nil
	end
	local mano = personaje:WaitForChild("RightHand", 10)
	if not mano or not mano:IsA("BasePart") or not personaje.Parent then
		return -- R6 o personaje custom: sin caña en la mano (el juego anda igual)
	end
	local d = Jugadores.obtener(jugador)
	local nivel = if d then d.Cana else 1
	local dorado = Monetizacion.tienePase(jugador, PASE_DORADO)
	local cana = ModeloEquipo.cana(nivel, dorado)
	local principal = cana.PrimaryPart
	if not principal then
		cana:Destroy()
		return
	end

	local punta = Instance.new("Attachment")
	punta.Name = "Punta"
	punta.CFrame = ModeloEquipo.puntaLocal(cana)
	punta.Parent = principal

	local agarre = Instance.new("Weld")
	agarre.Name = "Agarre"
	agarre.Part0 = mano
	agarre.Part1 = principal
	agarre.C0 = AGARRE
	agarre.C1 = principal.CFrame:ToObjectSpace(cana:GetPivot()) -- el pivote (puño) cae en AGARRE
	agarre.Parent = principal
	-- ya en su lugar antes de entrar al workspace: los WeldConstraint toman la distancia entre
	-- piezas recién ahí, y si la caña entra en el origen y el Weld la mueve, quedaba desarmada
	cana:PivotTo(mano.CFrame * AGARRE)
	cana.Parent = personaje

	local limpieza = Limpieza.nueva()
	limpieza:dar(cana)
	local eq: Equipado = {
		Limpieza = limpieza,
		Cana = cana,
		Punta = punta,
		Nivel = nivel,
		Dorado = dorado,
		CeboId = "",
		Lanzado = false,
	}
	equipados[jugador] = eq
	ponerCebo(jugador, eq, ceboDe(jugador))
	limpieza:dar(personaje.AncestryChanged:Connect(function(_, padre)
		if padre == nil and equipados[jugador] == eq then
			limpieza:limpiar()
			equipados[jugador] = nil
		end
	end))
end

-- Repinta el carrete si cambió el nivel o el pase dorado.
local function repintar(jugador: Player, eq: Equipado, nivel: number)
	local dorado = Monetizacion.tienePase(jugador, PASE_DORADO)
	if nivel ~= eq.Nivel or dorado ~= eq.Dorado then
		eq.Nivel = nivel
		eq.Dorado = dorado
		ModeloEquipo.pintarCarrete(eq.Cana, nivel, dorado)
	end
end

-- Repinta el carrete y cambia el cebo si se puso otro o se gastó.
function Equipo.actualizar(jugador: Player, d: Jugadores.Datos)
	local eq = equipados[jugador]
	if not eq then
		return
	end
	repintar(jugador, eq, d.Cana)
	local id = ceboDe(jugador)
	if id ~= eq.CeboId then
		ponerCebo(jugador, eq, id)
	end
end

-- La boya cayó al agua: línea de la punta a la boya y el cebo se va con ella.
-- Todo lo nuevo vive adentro de la boya, así que se borra solo cuando Pesca la saca.
function Equipo.lanzado(jugador: Player, boya: BasePart)
	local eq = equipados[jugador]
	if not eq then
		return
	end
	local nudo = Instance.new("Attachment")
	nudo.Name = "Nudo"
	nudo.Position = Vector3.new(0, boya.Size.Y / 2, 0)
	nudo.Parent = boya
	local linea = Instance.new("Beam") -- Beam y no cuerda: una cuerda tironearía al personaje
	linea.Name = "Linea"
	linea.Attachment0 = eq.Punta
	linea.Attachment1 = nudo
	linea.Width0 = 0.06
	linea.Width1 = 0.06
	linea.FaceCamera = true
	linea.Segments = 1
	linea.Color = ColorSequence.new(Estilo.Cana.Linea)
	linea.LightInfluence = 0
	linea.Parent = boya

	eq.Lanzado = true
	mostrarCebo(eq, false)
	if eq.CeboId ~= "" then
		local abajo = ModeloEquipo.cebo(eq.CeboId, ALTO_CEBO)
		local principal = abajo.PrimaryPart
		abajo:PivotTo(boya.CFrame * CFrame.new(0, -boya.Size.Y / 2, 0))
		if principal then -- soldado a la boya (anclada): cuando pica y se hunde, baja con ella
			local w = Instance.new("WeldConstraint")
			w.Part0 = boya
			w.Part1 = principal
			w.Parent = principal
		end
		abajo.Parent = boya
	end
	boya.Destroying:Once(function()
		if equipados[jugador] == eq then
			eq.Lanzado = false
			mostrarCebo(eq, true)
		end
	end)
end

local function alEntrar(jugador: Player)
	jugador.CharacterAdded:Connect(function(personaje)
		equipar(jugador, personaje)
	end)
	-- el pase puede prenderse antes de que carguen los datos (Jugadores.enviar no llega a Equipo):
	-- el atributo avisa siempre. La conexión muere sola cuando el jugador se va.
	jugador:GetAttributeChangedSignal("Pase_" .. PASE_DORADO):Connect(function()
		local eq = equipados[jugador]
		if eq then
			repintar(jugador, eq, eq.Nivel)
		end
	end)
	if jugador.Character then
		task.spawn(equipar, jugador, jugador.Character)
	end
end

function Equipo.alSalir(jugador: Player)
	local eq = equipados[jugador]
	if eq then
		eq.Limpieza:limpiar()
	end
	equipados[jugador] = nil
end

function Equipo.iniciar()
	Jugadores.alEnviar = Equipo.actualizar
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end
end

return Equipo
