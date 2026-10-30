--!strict
-- Misiones (lista en shared/ListaMisiones.luau) y premio diario con racha de 7 días.
-- Todo lo cuenta el servidor desde lo que ya validaron Pesca y Economia: el cliente no puede
-- avisar "completé una misión", solo ve el progreso que le manda Jugadores.enviar.
-- Las misiones se cobran solas al completarse (tarjeta de premio en el HUD).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ListaMisiones = require(ReplicatedStorage.Shared.ListaMisiones)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

export type Detalle = {
	Rareza: string?, -- "Sacar": rareza del pez
	Peso: number?, -- "Peso": kg del pez
}

local Misiones = {}

local ordenRareza: { [string]: number } = {}
for i, r in Config.Rarezas do
	ordenRareza[r.Id] = i
end

local function cuenta(m: ListaMisiones.Mision, tipo: ListaMisiones.Tipo, detalle: Detalle?): boolean
	if m.Tipo ~= tipo then
		return false
	end
	if m.RarezaMin then
		local r = detalle and detalle.Rareza
		return r ~= nil and (ordenRareza[r] or 0) >= (ordenRareza[m.RarezaMin] or math.huge)
	end
	if m.PesoMin then
		local p = detalle and detalle.Peso
		return p ~= nil and p >= m.PesoMin
	end
	return true
end

-- Suma `cantidad` a la misión actual si es de ese tipo. No manda el estado: lo hace quien llama
-- (Pesca y Economia ya llaman a Jugadores.enviar después de cada cambio).
-- Devuelve true si con esto completó la misión (para que un mismo pez no cuente para la siguiente).
function Misiones.registrar(jugador: Player, tipo: ListaMisiones.Tipo, cantidad: number, detalle: Detalle?): boolean
	local d = Jugadores.obtener(jugador)
	if not d or cantidad <= 0 then
		return false
	end
	local m = ListaMisiones.obtener(d.Mision)
	if not cuenta(m, tipo, detalle) then
		return false
	end
	d.MisionProgreso += cantidad
	if d.MisionProgreso < m.Meta then
		return false
	end
	-- completa: cobra y pasa a la siguiente (lo que sobra no se arrastra, así cada misión se juega)
	d.Escamas += m.Premio
	d.Mision += 1
	d.MisionProgreso = 0
	Remotos.Premio:FireClient(jugador, "Mision", { Texto = ListaMisiones.texto(m), Escamas = m.Premio })
	return true
end

-- Llamar cuando saca un pez que no tenía. Si con eso completó los peces de su isla (sin jefes),
-- cobra Config.PremioMuseo una sola vez por isla. No manda el estado: lo hace Pesca después.
function Misiones.revisarMuseo(jugador: Player, isla: number)
	local d = Jugadores.obtener(jugador)
	local premio = Config.PremioMuseo[isla]
	local clave = tostring(isla)
	if not d or not premio or d.MuseoCobrado[clave] then
		return
	end
	local total = 0
	for _, p in Config.Peces do
		if p.Isla == isla and not p.Jefe then
			if not d.Vistos[p.Id] then
				return
			end
			total += 1
		end
	end
	if total == 0 then
		return
	end
	d.MuseoCobrado[clave] = true
	d.Escamas += premio
	Remotos.Premio:FireClient(jugador, "Museo", {
		Texto = ("Encontraste los %d peces de la isla"):format(total),
		Escamas = premio,
	})
end

local function diaDeHoy(): number
	return os.time() // 86400 -- UTC, igual en todos los servidores
end

-- Al entrar: si hoy todavía no cobró, cobra el día de racha que le toca.
function Misiones.premioDiario(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local hoy = diaDeHoy()
	if d.DiarioDia >= hoy then
		return -- ya cobró hoy (o el reloj volvió atrás: no se paga dos veces)
	end
	-- seguido = ayer; si saltea un día, o completó los 7, arranca de nuevo en 1
	-- PENDIENTE (monetización): DevProduct "Revivir racha" (25 R$) para no perderla.
	local seguido = d.DiarioDia == hoy - 1
	d.DiarioRacha = if seguido and d.DiarioRacha < #Config.PremioDiario then d.DiarioRacha + 1 else 1
	d.DiarioDia = hoy
	local escamas = Config.PremioDiario[d.DiarioRacha]
	d.Escamas += escamas
	Remotos.Premio:FireClient(jugador, "Diario", {
		Texto = ("Premio diario · Día %d de %d"):format(d.DiarioRacha, #Config.PremioDiario),
		Escamas = escamas,
		Racha = d.DiarioRacha,
	})
	Jugadores.enviar(jugador)
end

return Misiones
