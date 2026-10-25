--!strict
-- Compras con Robux: developer products (Config.Productos) y pases (Config.Pases).
-- Un producto o pase con Id = 0 está apagado (todavía no existe en el Creator Dashboard).
--
-- ProcessReceipt es idempotente: cada PurchaseId entregado queda en d.Compras (se guarda con el
-- perfil). Si Roblox reintenta el mismo recibo después de un corte, se responde PurchaseGranted
-- sin entregar de nuevo. Si los datos del jugador no están cargados, NotProcessedYet: Roblox lo
-- vuelve a intentar cuando entre.
--
-- Pases: al entrar se consulta UserOwnsGamePassAsync y se pone el atributo "Pase_<clave>" en el
-- jugador (lo leen Equipo y la UI). Si lo compra en la partida, se prende en el momento.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Guardado = require(script.Parent.Guardado)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local MAX_COMPRAS_GUARDADAS = 50 -- los reintentos de Roblox llegan pronto: alcanza con los últimos

local Monetizacion = {}

local productoPorId: { [number]: Config.Producto } = {}
for _, p in Config.Productos do
	if p.Id ~= 0 then
		productoPorId[p.Id] = p
	end
end

local function yaEntregada(d: Jugadores.Datos, compra: string): boolean
	return table.find(d.Compras, compra) ~= nil
end

local function anotar(d: Jugadores.Datos, compra: string)
	table.insert(d.Compras, compra)
	while #d.Compras > MAX_COMPRAS_GUARDADAS do
		table.remove(d.Compras, 1)
	end
end

-- Entrega lo que da el producto. Los packs de cebo no respetan CeboTiradasMax: lo pagó con Robux.
local function entregar(jugador: Player, d: Jugadores.Datos, p: Config.Producto)
	if p.Cebo ~= "" then
		local mismo = d.CeboTiradas > 0 and d.Cebo == p.Cebo
		d.CeboTiradas = if mismo then d.CeboTiradas + p.Tiradas else p.Tiradas
		d.Cebo = p.Cebo
	end
	Remotos.Aviso:FireClient(jugador, ("¡Gracias! %s entregado"):format(p.Nombre))
end

local function procesarRecibo(recibo: any): Enum.ProductPurchaseDecision
	local p = productoPorId[recibo.ProductId]
	if not p then
		warn("Monetizacion: producto desconocido", recibo.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local jugador = Players:GetPlayerByUserId(recibo.PlayerId)
	local d = jugador and Jugadores.obtener(jugador)
	if not jugador or not d then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local compra = tostring(recibo.PurchaseId)
	if yaEntregada(d, compra) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local ok, err = pcall(entregar, jugador, d, p)
	if not ok then
		warn("Monetizacion: falló la entrega", compra, err)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	anotar(d, compra)
	Jugadores.enviar(jugador)
	Guardado.guardarYa(jugador)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function prenderPase(jugador: Player, clave: string)
	jugador:SetAttribute("Pase_" .. clave, true)
	Jugadores.enviar(jugador) -- Equipo repinta con el pase puesto (si sus datos ya cargaron)
end

local function revisarPases(jugador: Player)
	for clave, id in Config.Pases do
		if id ~= 0 then
			local ok, tiene = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, jugador.UserId, id)
			if ok and tiene and jugador.Parent == Players then
				prenderPase(jugador, clave)
			elseif not ok then
				warn("Monetizacion: no pude consultar el pase", clave, tiene)
			end
		end
	end
end

-- Para Equipo y otros sistemas del servidor.
function Monetizacion.tienePase(jugador: Player, clave: string): boolean
	return jugador:GetAttribute("Pase_" .. clave) == true
end

-- Expuesto solo para probar el recibo desde Studio (las compras reales entran por ProcessReceipt).
Monetizacion.procesarRecibo = procesarRecibo

function Monetizacion.iniciar()
	MarketplaceService.ProcessReceipt = procesarRecibo
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador: Player, id: number, compro: boolean)
		if not compro then
			return
		end
		for clave, idPase in Config.Pases do
			if idPase ~= 0 and idPase == id then
				prenderPase(jugador, clave)
			end
		end
	end)
	Players.PlayerAdded:Connect(revisarPases)
	for _, jugador in Players:GetPlayers() do
		task.spawn(revisarPases, jugador)
	end
end

return Monetizacion
