--!strict
-- Un laboratorio por jugador, alrededor de la plaza. Al arrancar, el servidor los genera
-- clonando el molde ServerStorage > Moldes > Laboratorio (guía de estilo, punto 4): cambiar
-- el diseño es cambiar el molde, y todos salen iguales.
-- Laboratorio (Model; su frente, +Z, mira a la plaza) >
--   Centro (PrimaryPart), Maquina, Corrales (Corral1..4), Tienda, Mutadex, Trofeos,
--   Cartel (TextLabels "Titulo"), Aparicion
-- Corral > Piso, Borde, Cupula, Cartel (TextLabel "Texto"), Candado (BillboardGui),
--          Zona (Attachment "Luz" > PointLight; por dónde caminan), Criaturas (Folder)
-- En la plaza, Plaza > Flechas > Lab1..LabN (TextLabels "Titulo") llevan el nombre del dueño.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Pedidos = require(ReplicatedStorage.Shared.Pedidos)

local PISO_ABIERTO = Paleta.Laboratorio.PisoAbierto
local PISO_CERRADO = Paleta.Laboratorio.PisoCerrado
local CUPULA_ABIERTA = Paleta.Laboratorio.CupulaAbierta
local CUPULA_CERRADA = Paleta.Laboratorio.CupulaCerrada
local TOTAL_ESPECIES = #Fusion.todas()

-- Arma los laboratorios alrededor de la plaza (si ya están, los deja como están).
local function generar(): Instance
	local existente = workspace:FindFirstChild("Laboratorios")
	if existente then
		return existente
	end
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Laboratorios"
	local molde = ServerStorage:WaitForChild("Moldes"):WaitForChild("Laboratorio") :: Model
	local M = Config.Mapa
	for i = 1, Config.CantidadLaboratorios do
		local angulo = math.rad(M.AnguloInicial + (i - 1) * 360 / Config.CantidadLaboratorios)
		local donde = M.CentroPlaza
			+ Vector3.new(math.sin(angulo), 0, math.cos(angulo)) * M.DistanciaLaboratorios
		local lab = molde:Clone()
		lab.Name = "Lab" .. i
		-- El -Z mira hacia afuera, así el frente (+Z, el arco) queda mirando a la plaza.
		lab:PivotTo(CFrame.lookAt(donde, donde + (donde - M.CentroPlaza)))
		lab.Parent = carpeta
	end
	carpeta.Parent = workspace
	return carpeta
end

local carpeta = generar()
local labDe: { [Player]: Model } = {}
local duenoDe: { [Model]: Player } = {}

local Laboratorios = {}

function Laboratorios.de(jugador: Player): Model?
	return labDe[jugador]
end

-- Busca un descendiente siguiendo los nombres (nil si falta alguno).
local function buscar(raiz: Instance?, ...: string): Instance?
	local actual = raiz
	for _, nombre in { ... } do
		if not actual then
			return nil
		end
		actual = actual:FindFirstChild(nombre)
	end
	return actual
end

-- Las partes dentro de un modelo (vacío si no está).
local function partes(modelo: Instance?): { BasePart }
	local lista = {}
	if modelo then
		for _, d in modelo:GetDescendants() do
			if d:IsA("BasePart") then
				table.insert(lista, d)
			end
		end
	end
	return lista
end

local function textos(raiz: Instance?, nombre: string, texto: string)
	if not raiz then
		return
	end
	for _, d in raiz:GetDescendants() do
		if d:IsA("TextLabel") and d.Name == nombre then
			d.Text = texto
		end
	end
end

-- Nombre del dueño en el arco del laboratorio y en la flecha de la plaza.
local function ponerCartel(lab: Model, dueno: string?)
	textos(
		lab:FindFirstChild("Cartel"),
		"Titulo",
		if dueno then "Laboratorio de " .. dueno else "Laboratorio libre"
	)
	textos(buscar(workspace, "Plaza", "Flechas", lab.Name), "Titulo", dueno or "Libre")
end

local function llevarAlLab(jugador: Player, personaje: Model)
	local lab = labDe[jugador]
	local aparicion = lab and lab:FindFirstChild("Aparicion")
	if not aparicion or not aparicion:IsA("BasePart") then
		return
	end
	personaje:WaitForChild("HumanoidRootPart", 5)
	task.wait() -- dejar que el personaje termine de aparecer
	-- Mirando hacia la máquina (-Z del laboratorio).
	personaje:PivotTo(aparicion.CFrame * CFrame.new(0, 4, 0))
end

-- Los abiertos tienen cúpula de vidrio, borde de neón verde, luz y su cartel de ADN por
-- segundo; los cerrados, cúpula opaca, borde de metal y candado.
-- `porCorral[k]` es el ADN/s del corral k.
local function pintarCorrales(lab: Model, abiertos: number, porCorral: { number })
	local corrales = lab:WaitForChild("Corrales")
	for k = 1, Config.Corrales.Maximo do
		local corral = corrales:FindFirstChild("Corral" .. k)
		if corral then
			local abierto = k <= abiertos
			for _, p in partes(corral:FindFirstChild("Piso")) do
				p.Color = if abierto then PISO_ABIERTO else PISO_CERRADO
			end
			for _, p in partes(corral:FindFirstChild("Borde")) do
				p.Material = if abierto then Enum.Material.Neon else Enum.Material.Metal
				p.Color = if abierto then Paleta.Acento else Paleta.Metal
			end
			local cupula = corral:FindFirstChild("Cupula")
			if cupula and cupula:IsA("BasePart") then
				cupula.Color = if abierto then CUPULA_ABIERTA else CUPULA_CERRADA
				cupula.Transparency = if abierto then 0.72 else 0.05
				cupula.Reflectance = if abierto then 0.12 else 0
			end
			local aviso = buscar(corral, "Candado", "BillboardGui")
			if aviso and aviso:IsA("BillboardGui") then
				aviso.Enabled = not abierto
			end
			local luz = buscar(corral, "Zona", "Luz", "PointLight")
			if luz and luz:IsA("Light") then
				luz.Enabled = abierto
			end
			local cartel = buscar(corral, "Cartel", "SurfaceGui", "Texto")
			if cartel and cartel:IsA("TextLabel") then
				cartel.Text = if abierto
					then "+" .. tostring(math.floor((porCorral[k] or 0) * 10 + 0.5) / 10) .. " ADN/s"
					else "Se abre en la tienda"
				cartel.TextColor3 = if abierto then Paleta.Acento else Paleta.Texto
			end
		end
	end
end

-- Muestra qué corrales están abiertos según la mejora "Más corrales".
function Laboratorios.actualizarCorrales(jugador: Player, abiertos: number, porCorral: { number })
	local lab = labDe[jugador]
	if lab then
		pintarCorrales(lab, abiertos, porCorral)
	end
end

local function fondoMutadex(lab: Model): Instance?
	return buscar(lab, "Mutadex", "Pantalla", "SurfaceGui", "Fondo")
end

-- Contador de la pantalla gigante de la Mutadex.
function Laboratorios.actualizarMutadex(jugador: Player, descubiertas: number)
	local lab = labDe[jugador]
	local fondo = lab and fondoMutadex(lab)
	if not fondo then
		return
	end
	textos(fondo, "Contador", descubiertas .. " / " .. TOTAL_ESPECIES)
	local relleno = buscar(fondo, "Barra", "Relleno")
	if relleno and relleno:IsA("Frame") then
		relleno.Size = UDim2.fromScale(descubiertas / TOTAL_ESPECIES, 1)
	end
end

-- Tarjeta "Última nueva" de la pantalla: la criatura, su nombre y el borde de su generación.
-- `clave` = nil la deja vacía.
local function ponerUltima(lab: Model, clave: string?, mutante: boolean?)
	local tarjeta = buscar(lab, "Mutadex", "Pantalla", "SurfaceGui", "Fondo", "Tarjeta")
	local vista = buscar(tarjeta, "Vista")
	if not tarjeta or not vista or not vista:IsA("ViewportFrame") then
		return
	end
	vista:ClearAllChildren()
	local c = if clave then Fusion.porClave(clave) else nil
	textos(tarjeta, "Nombre", if c then c.Nombre else "?")
	local borde = tarjeta:FindFirstChild("Borde")
	if borde and borde:IsA("UIStroke") then
		borde.Color = if not c
			then Paleta.Texto
			elseif mutante then Paleta.Mutante
			else Paleta.Generaciones[c.Gen]
	end
	if not c then
		return
	end
	local modelo = Generador.crear(c, CFrame.new(), nil, mutante)
	modelo.Parent = vista
	local camara = Instance.new("Camera")
	camara.FieldOfView = 38
	camara.CFrame = CFrame.lookAt(Vector3.new(-4.5, 4.5, -9.5), Vector3.new(0, 2.3, 0))
	camara.Parent = vista
	vista.CurrentCamera = camara
end

-- Tablero de pedidos del laboratorio (Tablero > Pantalla > SurfaceGui > Pedido1..3, cada uno con
-- los textos "Cliente" y "Texto"). `pedidos` nil lo deja vacío.
local function pintarTablero(lab: Model, pedidos: { [number]: Pedidos.Pedido }?)
	local gui = buscar(lab, "Tablero", "Pantalla", "SurfaceGui")
	if not gui then
		return
	end
	for i = 1, Config.Pedidos.Activos do
		local p = pedidos and pedidos[i]
		local fila = gui:FindFirstChild("Pedido" .. i, true)
		textos(fila, "Cliente", if p then Config.Pedidos.Clientes[p.Cliente] or "" else "")
		textos(fila, "Texto", if p then p.Texto else "Llega otro pedido en un ratito...")
	end
end

function Laboratorios.actualizarTablero(jugador: Player, pedidos: { [number]: Pedidos.Pedido })
	local lab = labDe[jugador]
	if lab then
		pintarTablero(lab, pedidos)
	end
end

function Laboratorios.mostrarNueva(jugador: Player, clave: string, mutante: boolean?)
	local lab = labDe[jugador]
	if lab then
		ponerUltima(lab, clave, mutante)
	end
end

-- Estante de trofeos (Trofeos > Hueco1..9): un trofeo por cada meta cumplida (Metas.luau),
-- una copa del color de la meta sobre una base dorada, con su nombre de cerca.
export type Trofeo = { Lugar: number, Color: Color3, Texto: string }

local function parteTrofeo(
	nombre: string,
	forma: Enum.PartType,
	tamano: Vector3,
	color: Color3
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Shape = forma
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = tamano
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	return p
end

local function ponerTrofeos(lab: Model, trofeos: { Trofeo }?)
	local estante = lab:FindFirstChild("Trofeos")
	if not estante then
		return
	end
	for _, viejo in estante:GetChildren() do
		if viejo.Name == "Trofeo" then
			viejo:Destroy()
		end
	end
	for _, t in trofeos or {} do
		local hueco = estante:FindFirstChild("Hueco" .. t.Lugar)
		if hueco and hueco:IsA("BasePart") then
			local abajo = hueco.Position + Vector3.new(0, hueco.Size.Y / 2, 0)
			local modelo = Instance.new("Model")
			modelo.Name = "Trofeo"
			local base =
				parteTrofeo("Base", Enum.PartType.Block, Vector3.new(0.9, 0.25, 0.9), Paleta.Dorado)
			base.Position = abajo + Vector3.new(0, 0.125, 0)
			base.Parent = modelo
			local pie = parteTrofeo(
				"Pie",
				Enum.PartType.Cylinder,
				Vector3.new(0.5, 0.25, 0.25),
				Paleta.Dorado
			)
			pie.CFrame = CFrame.new(abajo + Vector3.new(0, 0.5, 0))
				* CFrame.Angles(0, 0, math.rad(90))
			pie.Parent = modelo
			local copa = parteTrofeo("Copa", Enum.PartType.Ball, Vector3.one * 0.85, t.Color)
			copa.Material = Enum.Material.Neon
			copa.Position = abajo + Vector3.new(0, 1.05, 0)
			copa.Parent = modelo
			local cartel = Instance.new("BillboardGui")
			cartel.Size = UDim2.fromScale(3.2, 0.7)
			cartel.StudsOffsetWorldSpace = Vector3.new(0, 0.8, 0)
			cartel.MaxDistance = 18
			cartel.LightInfluence = 0
			local texto = Instance.new("TextLabel")
			texto.Size = UDim2.fromScale(1, 1)
			texto.BackgroundTransparency = 1
			texto.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
			texto.TextScaled = true
			texto.Text = t.Texto
			texto.TextColor3 = Paleta.Texto
			local borde = Instance.new("UIStroke")
			borde.Color = Paleta.Contorno
			borde.Thickness = 2
			borde.Parent = texto
			texto.Parent = cartel
			cartel.Parent = copa
			modelo.Parent = estante
		end
	end
end

function Laboratorios.actualizarTrofeos(jugador: Player, trofeos: { Trofeo })
	local lab = labDe[jugador]
	if lab then
		ponerTrofeos(lab, trofeos)
	end
end

function Laboratorios.asignar(jugador: Player)
	for i = 1, Config.CantidadLaboratorios do
		local lab = carpeta:FindFirstChild("Lab" .. i)
		if lab and lab:IsA("Model") and not duenoDe[lab] then
			labDe[jugador] = lab
			duenoDe[lab] = jugador
			lab:SetAttribute("Dueno", jugador.UserId)
			jugador:SetAttribute("Laboratorio", lab.Name)
			ponerCartel(lab, jugador.DisplayName)
			jugador.CharacterAdded:Connect(function(personaje)
				llevarAlLab(jugador, personaje)
			end)
			if jugador.Character then
				task.spawn(llevarAlLab, jugador, jugador.Character)
			end
			return
		end
	end
	warn("[Laboratorios] No hay laboratorio libre para " .. jugador.Name)
end

function Laboratorios.liberar(jugador: Player)
	local lab = labDe[jugador]
	if not lab then
		return
	end
	labDe[jugador] = nil
	duenoDe[lab] = nil
	lab:SetAttribute("Dueno", nil)
	ponerCartel(lab, nil)
	pintarCorrales(lab, Config.Mejoras.Corrales.Inicial, {})
	ponerUltima(lab, nil)
	pintarTablero(lab, nil)
	ponerTrofeos(lab, nil)
	textos(fondoMutadex(lab), "Contador", "0 / " .. TOTAL_ESPECIES)
	local relleno = buscar(fondoMutadex(lab), "Barra", "Relleno")
	if relleno and relleno:IsA("Frame") then
		relleno.Size = UDim2.fromScale(0, 1)
	end
end

-- Los laboratorios libres se ven como uno nuevo: cartel "Laboratorio libre", flecha en
-- "Libre" y solo el primer corral abierto.
for _, lab in carpeta:GetChildren() do
	if lab:IsA("Model") then
		ponerCartel(lab, nil)
		pintarCorrales(lab, Config.Mejoras.Corrales.Inicial, {})
	end
end

return Laboratorios
