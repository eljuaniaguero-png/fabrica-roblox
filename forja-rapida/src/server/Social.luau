--!strict
-- Exhibición social (Grupo 7). Mostrar lo que encontraste sin saturar el chat ni obligar a
-- competir:
--   Vitrinas   cada jugador que entra recibe un pedestal libre (tag "Vitrina", atributo Numero)
--              con una estatua de su gema elegida (o de su hallazgo más raro). El cliente le
--              pone el cartel con su nombre, título y "1 en N".
--   Títulos    se desbloquean con logros (GameConfig.Titulos); se eligen con Remotos.ElegirTitulo
--              y se ven arriba de la cabeza (cada uno puede ocultarlos).
--   Anuncios   opcionales (Anuncios.luau): cada uno decide si anuncia sus hallazgos y si ve los
--              de los demás.
--   Clasificaciones semanales  OrderedDataStore por semana (lunes a domingo, UTC): geodas,
--              exóticas, jefes y hallazgo más raro. Solo reconocimiento, sin premios.
--   Récords de jefes  al romper una Geoda Ancestral: puestos por daño, récord personal y récord
--              del servidor (anunciados como cartel).

local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Anuncios = require(script.Parent.Anuncios)
local Descubrimientos = require(script.Parent.Descubrimientos)
local Jugadores = require(script.Parent.Jugadores)
local Mundo = require(script.Parent.Mundo)
local Remotos = require(script.Parent.Remotos)

local S = GameConfig.Social
local CL = S.Clasificacion

local Social = {}

-- Vitrinas ----------------------------------------------------------------------------------------

local asignadas: { [Player]: BasePart } = {}

local function vitrinaLibre(): BasePart?
	local libres = {}
	local ocupadas: { [BasePart]: boolean } = {}
	for _, b in asignadas do
		ocupadas[b] = true
	end
	for _, b in CollectionService:GetTagged("Vitrina") do
		if b:IsA("BasePart") and not ocupadas[b] then
			table.insert(libres, b)
		end
	end
	table.sort(libres, function(a: BasePart, b: BasePart)
		return (tonumber(a:GetAttribute("Numero")) or 0) < (tonumber(b:GetAttribute("Numero")) or 0)
	end)
	return libres[1]
end

-- La piedra de Blender de esa gema (ServerStorage > Modelos > Gemas > <Id>, importada de
-- arte/fbx/Gemas_Zona<N>.fbx) soldada a una parte invisible "Estatua", que es la que gira.
local function piedraDeBlender(molde: Model): BasePart
	local copia = molde:Clone()
	local _, tam = copia:GetBoundingBox()
	local raiz = Instance.new("Part")
	raiz.Name = "Estatua"
	raiz.Size = tam
	raiz.CFrame = copia:GetBoundingBox()
	raiz.Transparency = 1
	raiz.Anchored = true
	raiz.CanCollide, raiz.CanTouch, raiz.CanQuery = false, false, false
	for _, parte in copia:GetDescendants() do
		if parte:IsA("BasePart") then
			parte.Anchored = false
			parte.CanCollide, parte.CanTouch, parte.CanQuery = false, false, false
			parte.Massless = true
			local soldadura = Instance.new("WeldConstraint")
			soldadura.Part0 = raiz
			soldadura.Part1 = parte
			soldadura.Parent = parte
		end
	end
	copia.Parent = raiz
	return raiz
end

-- La estatua: la piedra de Blender de esa gema; si no está, la malla de su rareza
-- (ServerStorage > Modelos > Estatuas) o un cristal de partes simples.
local function estatua(gemaId: string): BasePart?
	local gema = Reglas.gema(gemaId)
	if not gema then
		return nil
	end
	local carpeta = ServerStorage:FindFirstChild(GameConfig.Modelos.Carpeta)
	local piedras = carpeta and carpeta:FindFirstChild("Gemas")
	local piedra = piedras and piedras:FindFirstChild(gema.Id)
	if piedra and piedra:IsA("Model") then
		return piedraDeBlender(piedra)
	end
	local estatuas = carpeta and carpeta:FindFirstChild("Estatuas")
	local molde = estatuas and estatuas:FindFirstChild(gema.Rareza)
	local p: BasePart
	if molde and molde:IsA("BasePart") then
		p = molde:Clone()
	else
		local parte = Instance.new("Part")
		parte.Size = Vector3.new(2.6, 2.6, 2.6)
		p = parte
	end
	p.Name = "Estatua"
	p.Color = Color3.fromHex(gema.Color)
	p.Material = Enum.Material.Glass
	p.Transparency = 0.1
	p.Anchored = true
	p.CanCollide = false
	return p
end

-- Grupo 3: estilo de la vitrina y decoración (cosméticos del Museo).
local function estiloVitrina(base: BasePart, id: string)
	local c = Reglas.cosmetico("Vitrina", id) or Reglas.cosmetico("Vitrina", "Clasica")
	if not c then
		return
	end
	base.Color = Color3.fromHex(c.Colores[1] or "#2A2F4F")
	local ok, m = pcall(function()
		return (Enum.Material :: any)[c.Material or "SmoothPlastic"]
	end)
	base.Material = if ok and typeof(m) == "EnumItem"
		then m :: Enum.Material
		else Enum.Material.SmoothPlastic
end

local function adorno(
	nombre: string,
	tam: Vector3,
	cf: CFrame,
	color: string,
	neon: boolean,
	padre: Instance
): Part
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.CFrame = cf
	p.Color = Color3.fromHex(color)
	p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.CastShadow = false
	p.Parent = padre
	return p
end

local function decorar(m: Model, base: BasePart, id: string)
	local c = Reglas.cosmetico("Decoracion", id)
	if not c then
		return
	end
	local deco = Instance.new("Model")
	deco.Name = "Decoracion"
	local radio = math.max(base.ExtentsSize.X, base.ExtentsSize.Z) / 2 + 0.9
	local piso = base.Position.Y - base.ExtentsSize.Y / 2
	local cantidad = if id == "Llamas" then 4 else 6
	for i = 1, cantidad do
		local a = (i / cantidad) * math.pi * 2
		local pos = Vector3.new(
			base.Position.X + math.cos(a) * radio,
			piso,
			base.Position.Z + math.sin(a) * radio
		)
		local color = c.Colores[(i - 1) % #c.Colores + 1]
		if id == "Flores" then
			adorno(
				"Tallo",
				Vector3.new(0.2, 1, 0.2),
				CFrame.new(pos + Vector3.new(0, 0.5, 0)),
				"#3E9E22",
				false,
				deco
			)
			adorno(
				"Flor",
				Vector3.new(0.7, 0.3, 0.7),
				CFrame.new(pos + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, a, 0),
				color,
				false,
				deco
			)
		elseif id == "Cristalitos" then
			local alto = 1 + (i % 3) * 0.5
			adorno(
				"Cristal",
				Vector3.new(0.45, alto, 0.45),
				CFrame.new(pos + Vector3.new(0, alto / 2, 0))
					* CFrame.Angles(0.25 * math.cos(a), a, 0.25 * math.sin(a)),
				color,
				true,
				deco
			)
		else
			local llama = adorno(
				"Llama",
				Vector3.new(0.5, 1.2, 0.5),
				CFrame.new(pos + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, a, 0),
				color,
				true,
				deco
			)
			local fuego = Instance.new("Fire")
			fuego.Size = 2
			fuego.Heat = 4
			fuego.Color = Color3.fromHex(c.Colores[1])
			fuego.SecondaryColor = Color3.fromHex(c.Colores[2] or c.Colores[1])
			fuego.Parent = llama
		end
	end
	deco.Parent = m
end

local function exhibir(jugador: Player)
	local base = asignadas[jugador]
	local d = Jugadores.obtener(jugador)
	if not base or not d then
		return
	end
	local vieja = base:FindFirstChild("Exhibicion")
	if vieja then
		vieja:Destroy()
	end
	local gemaId = d.Vitrina or (d.Hallazgos[1] and d.Hallazgos[1].Gema)
	local m = Instance.new("Model")
	m.Name = "Exhibicion"
	m:SetAttribute("UserId", jugador.UserId)
	m:SetAttribute("Dueno", jugador.DisplayName)
	if gemaId then
		local hallazgo = nil
		for _, h in d.Hallazgos do
			if h.Gema == gemaId then
				hallazgo = h
				break
			end
		end
		m:SetAttribute("Gema", gemaId)
		m:SetAttribute("UnoEn", if hallazgo then hallazgo.UnoEn else 0)
		m:SetAttribute("Modificador", if hallazgo then hallazgo.Modificador else "Normal")
		local p = estatua(gemaId)
		if p then
			-- arriba del pedestal (ExtentsSize: el tamaño en el mundo, aunque esté girado)
			p.CFrame = CFrame.new(
				base.Position + Vector3.new(0, base.ExtentsSize.Y / 2 + p.Size.Y / 2 + 1.2, 0)
			)
			p.Parent = m
			m.PrimaryPart = p
			CollectionService:AddTag(p, "Estatua") -- el cliente la hace girar y flotar
		end
	end
	estiloVitrina(base, d.Equipado.Vitrina or "Clasica")
	if d.Equipado.Decoracion and d.Equipado.Decoracion ~= "" then
		decorar(m, base, d.Equipado.Decoracion)
	end
	m.Parent = base
end

-- Hallazgos: los más raros de cada jugador (por "1 en N").
Mundo.alRevelar(function(r: Mundo.Revelado)
	local d = Jugadores.obtener(r.Jugador)
	if not d then
		return
	end
	local lista = d.Hallazgos
	local peor = lista[#lista]
	if #lista >= S.Hallazgos and peor and r.UnoEn <= peor.UnoEn then
		return
	end
	-- una entrada por gema: si ya estaba, queda la más rara
	for i, h in lista do
		if h.Gema == r.Gema then
			if r.UnoEn <= h.UnoEn then
				return
			end
			table.remove(lista, i)
			break
		end
	end
	table.insert(lista, {
		Gema = r.Gema,
		Rareza = r.Rareza,
		UnoEn = r.UnoEn,
		Modificador = r.Modificador,
		Cuando = os.time(),
	})
	table.sort(lista, function(a, b)
		return a.UnoEn > b.UnoEn
	end)
	while #lista > S.Hallazgos do
		table.remove(lista)
	end
	if not d.Vitrina then
		exhibir(r.Jugador)
	end
end)

-- Elegir título y gema de la vitrina (el servidor revisa que los tengas).
local ultimoPedido: { [Player]: number } = {}
local function permitir(jugador: Player): boolean
	local t = os.clock()
	if ultimoPedido[jugador] and t - ultimoPedido[jugador] < 0.5 then
		return false
	end
	ultimoPedido[jugador] = t
	return true
end

local function alElegirTitulo(jugador: Player, id: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(id) ~= "string" or not permitir(jugador) then
		return
	end
	if Reglas.tituloDisponible(id, d.Logros) then
		d.Titulo = id
		Jugadores.publicar(jugador)
	end
end

local function alElegirVitrina(jugador: Player, id: unknown)
	local d = Jugadores.obtener(jugador)
	if not d or typeof(id) ~= "string" or not permitir(jugador) then
		return
	end
	if d.Indice[id] then
		d.Vitrina = id
		Jugadores.publicar(jugador)
		exhibir(jugador)
	end
end

-- Clasificaciones semanales -----------------------------------------------------------------------

type Puntos = { Geodas: number, Exoticas: number, Jefes: number, Hallazgo: number }
local pendientes: { [Player]: Puntos } = {}
local almacenes: { [string]: OrderedDataStore } = {}
local semanaActual = ""
local sinDataStore = false
local nombres: { [number]: string } = {}

local carpetaClasificacion = Instance.new("Folder")
carpetaClasificacion.Name = "Clasificaciones"
carpetaClasificacion.Parent = ReplicatedStorage

local function puntos(jugador: Player): Puntos
	local p = pendientes[jugador]
	if not p then
		p = { Geodas = 0, Exoticas = 0, Jefes = 0, Hallazgo = 0 }
		pendientes[jugador] = p
	end
	return p :: Puntos
end

local function almacen(tabla: string): OrderedDataStore?
	if sinDataStore then
		return nil
	end
	local semana = Reglas.semana(os.time())
	if semana ~= semanaActual then
		semanaActual = semana
		almacenes = {}
		carpetaClasificacion:SetAttribute("Semana", semana)
	end
	local a = almacenes[tabla]
	if not a then
		local ok, resultado = pcall(function()
			return DataStoreService:GetOrderedDataStore(CL.Almacen .. "_" .. tabla, semana)
		end)
		if not ok then
			sinDataStore = true
			warn(
				"[Social] sin acceso a DataStores (en Studio: Game Settings > Security), sin clasificaciones"
			)
			return nil
		end
		a = resultado
		almacenes[tabla] = a
	end
	return a
end

local function subir(jugador: Player)
	local p = pendientes[jugador]
	if not p then
		return
	end
	pendientes[jugador] = nil
	local clave = tostring(jugador.UserId)
	for _, tabla in { "Geodas", "Exoticas", "Jefes" } do
		local n = (p :: any)[tabla] :: number
		local a = almacen(tabla)
		if n > 0 and a then
			pcall(function()
				a:IncrementAsync(clave, n)
			end)
		end
	end
	local a = almacen("Hallazgo")
	if p.Hallazgo > 0 and a then
		pcall(function()
			a:UpdateAsync(clave, function(viejo: number?)
				return math.max(viejo or 0, math.floor(p.Hallazgo))
			end)
		end)
	end
end

local function nombreDe(id: number): string
	if nombres[id] then
		return nombres[id]
	end
	local ok, nombre = pcall(function()
		return Players:GetNameFromUserIdAsync(id)
	end)
	local n = if ok and nombre then nombre else "Jugador"
	nombres[id] = n
	return n
end

local function leer()
	for _, t in CL.Tablas do
		local a = almacen(t.Id)
		if not a then
			return
		end
		local ok, pagina = pcall(function()
			return a:GetSortedAsync(false, CL.Cuantos):GetCurrentPage()
		end)
		if ok then
			local lista = {}
			for _, fila in pagina do
				local id = tonumber(fila.key) or 0
				table.insert(lista, { Nombre = nombreDe(id), Valor = fila.value, UserId = id })
			end
			local valor = carpetaClasificacion:FindFirstChild(t.Id)
			if not valor then
				local nuevo = Instance.new("StringValue")
				nuevo.Name = t.Id
				nuevo:SetAttribute("Titulo", t.Nombre)
				nuevo.Parent = carpetaClasificacion
				valor = nuevo
			end
			(valor :: StringValue).Value = HttpService:JSONEncode(lista)
		end
	end
end

-- Lo que suma a las clasificaciones y los récords de jefes.
local recordServidor = 0
Mundo.alRomper(function(r: Mundo.Rotura)
	for _, jugador in r.Premiados do
		local p = puntos(jugador)
		p.Geodas += 1
		if Reglas.esExotica(r.Modificador) then
			p.Exoticas += 1
		end
	end
	if r.Tamano ~= "Ancestral" then
		return
	end
	-- Récords de la Geoda Ancestral: puestos por daño.
	local ranking = {}
	for jugador, danio in r.Danio do
		if jugador.Parent then
			table.insert(ranking, { Jugador = jugador, Danio = danio })
		end
	end
	table.sort(ranking, function(a, b)
		return a.Danio > b.Danio
	end)
	local podio, top = {}, {}
	for i, fila in ranking do
		if i <= 3 then
			table.insert(
				podio,
				("%d° %s (%s)"):format(i, fila.Jugador.DisplayName, Formato.corto(fila.Danio))
			)
			table.insert(top, { Nombre = fila.Jugador.DisplayName, Danio = fila.Danio })
		end
		local d = Jugadores.obtener(fila.Jugador)
		if d then
			puntos(fila.Jugador).Jefes += 1
			d.JefesDerrotados += 1
			local hitos = Descubrimientos.revisar(fila.Jugador)
			if fila.Danio > d.MayorDanioJefe then
				d.MayorDanioJefe = fila.Danio
				table.insert(hitos, 1, {
					Id = "RecordJefe",
					Titulo = "¡Nuevo récord personal!",
					Nombre = "Geoda Ancestral",
					Descripcion = ("Le hiciste %s de daño (puesto %d de %d)"):format(
						Formato.corto(fila.Danio),
						i,
						#ranking
					),
					Coleccion = false,
				})
			end
			if d.MejorPuestoJefe == 0 or i < d.MejorPuestoJefe then
				d.MejorPuestoJefe = i
			end
			Jugadores.publicar(fila.Jugador)
			Remotos.Hitos:FireClient(fila.Jugador, hitos)
		end
	end
	Mundo.publicar({ JefeTop = HttpService:JSONEncode(top) })
	local evento = Reglas.evento("JefeAncestral")
	local color = if evento then evento.Color else "#FFD23F"
	Anuncios.enviar("¡Geoda Ancestral rota! " .. table.concat(podio, " · "), color, "Jefe")
	local mejor = ranking[1]
	if mejor and mejor.Danio > recordServidor then
		recordServidor = mejor.Danio
		Mundo.publicar({
			RecordJefe = HttpService:JSONEncode({
				Nombre = mejor.Jugador.DisplayName,
				Danio = mejor.Danio,
			}),
		})
	end
end)

Mundo.alRevelar(function(r: Mundo.Revelado)
	local p = puntos(r.Jugador)
	p.Hallazgo = math.max(p.Hallazgo, r.UnoEn)
end)

-- Entrada y salida ----------------------------------------------------------------------------------

-- Vuelve a armar la vitrina del jugador (cambió su gema, su estilo o su decoración).
function Social.refrescar(jugador: Player)
	exhibir(jugador)
end

function Social.alEntrar(jugador: Player)
	local base = vitrinaLibre()
	if base then
		asignadas[jugador] = base
		exhibir(jugador)
	end
end

function Social.alSalir(jugador: Player)
	task.spawn(subir, jugador)
	local base = asignadas[jugador]
	if base then
		local m = base:FindFirstChild("Exhibicion")
		if m then
			m:Destroy()
		end
		estiloVitrina(base, "Clasica")
	end
	asignadas[jugador] = nil
	ultimoPedido[jugador] = nil
end

function Social.iniciar()
	Remotos.ElegirTitulo.OnServerEvent:Connect(alElegirTitulo)
	Remotos.ElegirVitrina.OnServerEvent:Connect(alElegirVitrina)
	task.spawn(function()
		local proximaLectura = 0
		while true do
			task.wait(CL.Guardar)
			for jugador in pendientes do
				subir(jugador)
			end
			if os.clock() >= proximaLectura then
				proximaLectura = os.clock() + CL.Leer
				leer()
			end
		end
	end)
	game:BindToClose(function()
		for jugador in pendientes do
			subir(jugador)
		end
	end)
end

return Social
