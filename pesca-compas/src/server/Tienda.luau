--!strict
-- Casa "CEBO & CAÑAS": vende cebos con Escamas (Config.Cebos). El cliente abre el panel con el
-- ProximityPrompt de la puerta (client/Tienda.client.luau) y pide la compra; acá se valida todo:
-- que el cebo exista, que esté cerca de la tienda, que le alcance y el tope de tiradas.
-- El efecto del cebo lo aplica Pesca.luau con Tienda.ceboActivo y Tienda.gastarTirada.
--
-- La tienda se engancha sola a la casa del mapa (hecho a mano o por Mundo.luau): le pone el tag
-- "TiendaCebo" y el ProximityPrompt a la puerta, y apaga el cartel "¡PRONTO!" que tenía.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local TAG = "TiendaCebo"
local ESPERA_COMPRA = 0.4 -- segundos entre compras por jugador (un doble clic no cobra dos veces)

local Tienda = {}

local ultimaCompra: { [Player]: number } = {}

local function ceboPorId(id: string): Config.Cebo?
	for _, c in Config.Cebos do
		if c.Id == id then
			return c
		end
	end
	return nil
end

-- Cebo con tiradas, o nil.
function Tienda.ceboActivo(d: Jugadores.Datos): Config.Cebo?
	if d.CeboTiradas <= 0 then
		return nil
	end
	return ceboPorId(d.Cebo)
end

-- Se llama cuando pica un pez con cebo puesto. Avisa cuando se termina.
function Tienda.gastarTirada(jugador: Player, d: Jugadores.Datos)
	if d.CeboTiradas <= 0 then
		return
	end
	d.CeboTiradas -= 1
	if d.CeboTiradas == 0 then
		local cebo = ceboPorId(d.Cebo)
		d.Cebo = ""
		Remotos.Aviso:FireClient(
			jugador,
			("Se terminó tu %s: comprá más en CEBO & CAÑAS"):format(if cebo then cebo.Nombre else "cebo")
		)
	end
	Jugadores.enviar(jugador) -- el contador del HUD baja aunque el pez se escape
end

local function cercaDeLaTienda(jugador: Player): boolean
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return false
	end
	for _, puerta in CollectionService:GetTagged(TAG) do
		if puerta:IsA("BasePart") and puerta:IsDescendantOf(Workspace) then
			if (puerta.Position - raiz.Position).Magnitude <= Config.DistanciaTienda then
				return true
			end
		end
	end
	return false
end

local function comprar(jugador: Player, id: unknown)
	if typeof(id) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimaCompra[jugador] or -math.huge) < ESPERA_COMPRA then
		return
	end
	ultimaCompra[jugador] = ahora
	local d = Jugadores.obtener(jugador)
	local cebo = ceboPorId(id :: string)
	if not d or not cebo then
		return
	end
	if not cercaDeLaTienda(jugador) then
		Remotos.Aviso:FireClient(jugador, "Acercate a la casa de CEBO & CAÑAS")
		return
	end
	local mismo = d.CeboTiradas > 0 and d.Cebo == cebo.Id
	if mismo and d.CeboTiradas + cebo.Tiradas > Config.CeboTiradasMax then
		Remotos.Aviso:FireClient(jugador, ("Ya tenés %d tiradas de cebo, gastalas primero"):format(d.CeboTiradas))
		return
	end
	if d.Escamas < cebo.Precio then
		Remotos.Aviso:FireClient(jugador, ("Te faltan %d Escamas"):format(cebo.Precio - d.Escamas))
		return
	end
	d.Escamas -= cebo.Precio
	d.CeboTiradas = if mismo then d.CeboTiradas + cebo.Tiradas else cebo.Tiradas
	d.Cebo = cebo.Id
	Remotos.Aviso:FireClient(jugador, ("¡%s puesto! %d tiradas"):format(cebo.Nombre, d.CeboTiradas))
	Jugadores.enviar(jugador)
end

-- Busca la casa (por nombre, en el mapa hecho a mano o en el de Mundo.luau) y le pone la tienda.
local function engancharCasa()
	local muelle = Workspace:FindFirstChild("Muelle")
	local casa = muelle and muelle:FindFirstChild("CeboYCanas", true)
	local puerta = casa and casa:FindFirstChild("Puerta")
	if not puerta or not puerta:IsA("BasePart") then
		warn("Tienda: no encontré Muelle > CeboYCanas > Puerta, la tienda de cebo no se abre")
		return
	end
	CollectionService:AddTag(puerta, TAG)
	if not puerta:FindFirstChildOfClass("ProximityPrompt") then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Ver cebos"
		prompt.ObjectText = "CEBO & CAÑAS"
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = puerta
	end
	-- el "¡PRONTO!" ya no corresponde: se apaga (no se borra, el mapa del place queda igual)
	for _, x in (muelle :: Instance):GetDescendants() do
		if x:IsA("BillboardGui") and x.Name == "Pronto" then
			x.Enabled = false
		end
	end
end

function Tienda.alSalir(jugador: Player)
	ultimaCompra[jugador] = nil
end

function Tienda.iniciar()
	engancharCasa()
	Remotos.ComprarCebo.OnServerEvent:Connect(comprar)
end

return Tienda
