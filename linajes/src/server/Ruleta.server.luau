--!strict
-- Ruleta de Linajes del sandbox (bóveda: 01 Juego/Sandbox - modos y ruleta).
-- Cada vez que entrás a un modo tirás GRATIS. Otra tirada o un Linaje directo se pagan con Chatarra,
-- que solo se gana jugando: ninguna tirada se vende por Robux.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Perfiles = require(script.Parent.Perfiles)
local Duelos = require(script.Parent.Duelos)
local Analitica = require(script.Parent.Analitica)

local R = Config.Ruleta
local S = Config.Sandbox

local remoto = Instance.new("RemoteEvent")
remoto.Name = "Ruleta"
remoto.Parent = ReplicatedStorage

local azar = Random.new()
local ultimo: { [Player]: number } = {}
local gratis: { [Player]: boolean } = {} -- le queda la tirada gratis de esta partida
local modo: { [Player]: string } = {}
local linajeBase: { [Player]: string } = {} -- el de la ruleta, mientras usa uno comprado por una vida

local function opcion(linaje: string): any?
	for _, o in R.Opciones do
		if o.Linaje == linaje and o.Disponible then
			return o
		end
	end
	return nil
end

local function sortear(): string
	local total = 0
	for _, o in R.Opciones do
		if o.Disponible then
			total += o.Peso
		end
	end
	local tiro = azar:NextNumber(0, total)
	for _, o in R.Opciones do
		if o.Disponible then
			tiro -= o.Peso
			if tiro <= 0 then
				return o.Linaje
			end
		end
	end
	return R.Opciones[1].Linaje
end

-- Pases de Linaje permanente: el atributo Pase_<Linaje> le avisa al cliente cuáles tiene.
local function idPase(linaje: string): number
	local id = (S.PasesLinaje :: any)[linaje]
	return if typeof(id) == "number" then id else 0
end

local function revisarPases(jugador: Player)
	for linaje in S.PasesLinaje do
		local id = idPase(linaje)
		if id > 0 then
			local ok, tiene = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, id)
			end)
			if ok and tiene then
				jugador:SetAttribute("Pase_" .. linaje, true)
			end
		end
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador, id, compro)
	if not compro then
		return
	end
	for linaje in S.PasesLinaje do
		if idPase(linaje) == id then
			-- Roblox ya validó la compra; igual se vuelve a preguntar para no confiar en el evento solo.
			local ok, tiene = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, id)
			end)
			if ok and tiene then
				jugador:SetAttribute("Pase_" .. linaje, true)
			end
		end
	end
end)

local function avisar(jugador: Player, texto: string)
	remoto:FireClient(jugador, "Aviso", texto)
end

local function ponerLinaje(
	jugador: Player,
	linaje: string,
	variante: boolean,
	extra: { [string]: any }?
)
	local campos: { [string]: any } = { Linaje = linaje }
	if extra then
		for k, v in extra do
			campos[k] = v
		end
	end
	Perfiles.cambiar(jugador, campos)
	jugador:SetAttribute("Variante", variante)
end

remoto.OnServerEvent:Connect(function(jugador: Player, pedido: unknown, dato: unknown)
	if typeof(pedido) ~= "string" then
		return
	end
	local ahora = os.clock()
	if ahora - (ultimo[jugador] or 0) < 0.4 then
		return
	end
	local d = Perfiles.datos(jugador)
	if not d then
		return
	end

	if pedido == "Partida" then
		-- Eligió un modo en el menú: tirada gratis y se abre la ruleta.
		if dato ~= "FFA" and dato ~= "Duelo" then
			return
		end
		ultimo[jugador] = ahora
		Duelos.salir(jugador)
		modo[jugador] = dato :: string
		gratis[jugador] = true
		jugador:SetAttribute("Modo", dato)
		jugador:SetAttribute("TiradaGratis", true)
		remoto:FireClient(jugador, "Abrir", dato)
		Analitica.paso(jugador, "EligioModo")
	elseif pedido == "Tirar" then
		if ahora - (ultimo[jugador] or 0) < R.Espera then
			return
		end
		local esGratis = gratis[jugador] == true
		if not esGratis and d.Chatarra < S.PrecioTirada then
			avisar(jugador, string.format("Te faltan %d de Chatarra", S.PrecioTirada - d.Chatarra))
			return
		end
		ultimo[jugador] = ahora
		gratis[jugador] = false
		jugador:SetAttribute("TiradaGratis", false)
		linajeBase[jugador] = nil
		jugador:SetAttribute("LinajeVida", nil)
		local linaje = sortear()
		local variante = azar:NextNumber() < S.Variante.Chance
		ponerLinaje(
			jugador,
			linaje,
			variante,
			if esGratis then nil else { Chatarra = d.Chatarra - S.PrecioTirada }
		)
		remoto:FireClient(jugador, "Resultado", linaje, variante)
		Analitica.paso(jugador, "TiroRuleta")
		if not esGratis then
			Analitica.gasta(jugador, S.PrecioTirada, d.Chatarra, "Tirada")
		end
	elseif pedido == "Elegir" then
		-- Linaje de un pase comprado con Robux: se elige gratis y queda (no es por una vida).
		if typeof(dato) ~= "string" or not opcion(dato) then
			return
		end
		if jugador:GetAttribute("Pase_" .. dato) ~= true then
			return
		end
		ultimo[jugador] = ahora
		linajeBase[jugador] = nil
		jugador:SetAttribute("LinajeVida", nil)
		ponerLinaje(jugador, dato, false)
		remoto:FireClient(jugador, "Resultado", dato, false)
	elseif pedido == "PedirPase" then
		if typeof(dato) ~= "string" or not opcion(dato) or idPase(dato) <= 0 then
			return
		end
		ultimo[jugador] = ahora
		MarketplaceService:PromptGamePassPurchase(jugador, idPase(dato))
	elseif pedido == "Comprar" then
		-- Un Linaje elegido, por Chatarra y por UNA vida: al caer vuelve el de la ruleta.
		if typeof(dato) ~= "string" then
			return
		end
		local o = opcion(dato)
		local precio = o and (S.PrecioLinajeVida :: any)[o.Rareza]
		if not (o and typeof(precio) == "number") or dato == d.Linaje then
			return
		end
		if d.Chatarra < precio then
			avisar(jugador, string.format("Te faltan %d de Chatarra", precio - d.Chatarra))
			return
		end
		ultimo[jugador] = ahora
		if not linajeBase[jugador] then
			linajeBase[jugador] = d.Linaje
		end
		ponerLinaje(jugador, dato, false, { Chatarra = d.Chatarra - precio })
		jugador:SetAttribute("LinajeVida", true)
		Analitica.gasta(jugador, precio, d.Chatarra, "LinajeVida_" .. dato)
		remoto:FireClient(jugador, "Resultado", dato, false)
	elseif pedido == "Listo" then
		-- Cierra la ruleta: en 1 V 1 entra a la fila de duelos.
		ultimo[jugador] = ahora
		if modo[jugador] == "Duelo" then
			Duelos.entrar(jugador, avisar)
		end
	end
end)

-- Al caer se pierde el Linaje comprado por una vida y vuelve el de la ruleta.
local function conectar(jugador: Player)
	task.spawn(revisarPases, jugador)
	jugador.CharacterAdded:Connect(function()
		local base = linajeBase[jugador]
		if base then
			linajeBase[jugador] = nil
			jugador:SetAttribute("LinajeVida", nil)
			if base ~= "" then
				ponerLinaje(jugador, base, false)
			end
			avisar(jugador, "Volviste a tu Linaje de la ruleta")
		end
	end)
end
Players.PlayerAdded:Connect(conectar)
for _, j in Players:GetPlayers() do
	conectar(j)
end

Players.PlayerRemoving:Connect(function(jugador)
	ultimo[jugador] = nil
	gratis[jugador] = nil
	modo[jugador] = nil
	linajeBase[jugador] = nil
end)
