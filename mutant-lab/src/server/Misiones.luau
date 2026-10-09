--!strict
-- Misiones del día y experimento del día (ficha, "Parte 8").
-- Misiones: tres por día, cortas, siempre las mismas para un jugador ese día (se arman con el
-- número de día y su UserId). Premio chico por cada una y uno más grande por las tres.
-- Experimento: la especie misteriosa de hoy (shared/Experimento.luau, igual para todos);
-- quien la fusiona hoy gana un premio.
-- Los días los da el servidor (Reloj.luau). Se publican los atributos "Misiones" (JSON) y
-- "Dia" / "FinDia" (para que el cliente muestre el experimento y cuánto falta).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Experimento = require(ReplicatedStorage.Shared.Experimento)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Jugadores = require(script.Parent.Jugadores)
local Reloj = require(script.Parent.Reloj)
local Remotos = require(script.Parent.Remotos)

local M = Config.Misiones

local Misiones = {}

-- Texto de una misión ("Hacé 6 fusiones", "Usá un catalizador de Hielo").
function Misiones.texto(m: Jugadores.Mision): string
	local plural = m.Meta > 1
	if m.Tipo == "Descubrir" then
		return if plural
			then "Descubrí " .. m.Meta .. " especies nuevas"
			else "Descubrí una especie nueva"
	elseif m.Tipo == "Fusionar" then
		return "Hacé " .. m.Meta .. " fusiones"
	elseif m.Tipo == "Entregar" then
		return if plural then "Entregá " .. m.Meta .. " pedidos" else "Entregá un pedido"
	elseif m.Tipo == "Residuos" then
		return "Hacé " .. m.Meta .. " residuos (fusiones que no reaccionan)"
	elseif m.Tipo == "Catalizador" then
		local cat = Catalizadores.porClave(m.Dato)
		return "Usá un catalizador de " .. (if cat then cat.Nombre else "?")
	elseif m.Tipo == "Personalidad" then
		local p = Personalidades.Datos[m.Dato or ""]
		return "Conseguí una criatura " .. (if p then p.Nombre else "?")
	end
	return m.Tipo
end

-- Personalidades que el jugador puede conseguir hoy: las que salen de juntar dos de las que
-- ya tiene en sus criaturas (tabla de herencia).
local function personalidadesPosibles(d: Jugadores.Datos): { string }
	local tiene = {}
	for _, u in d.Criaturas do
		tiene[u.Personalidad] = true
	end
	local posibles = {}
	for a in tiene do
		for b in tiene do
			local hija = Personalidades.heredar(a, b)
			if hija and not table.find(posibles, hija) then
				table.insert(posibles, hija)
			end
		end
	end
	table.sort(posibles)
	return posibles
end

-- Arma las misiones del día `dia` para este jugador (siempre las mismas para ese día).
function Misiones.armar(d: Jugadores.Datos, dia: number, semilla: number): Jugadores.MisionesDelDia
	local rng = Random.new(dia * 7919 + semilla)
	local tipos = { "Descubrir", "Fusionar", "Entregar", "Residuos" }
	local personalidades = personalidadesPosibles(d)
	if #personalidades > 0 then
		table.insert(tipos, "Personalidad")
	end
	local ranura = Jugadores.cantidadEspecies(d) >= Config.Residuos.RanuraDesde
	local conocidos = Catalizadores.conocidos(d.Especies, d.CatalizadoresVistos)
	if ranura and #conocidos > 0 then
		table.insert(tipos, "Catalizador")
	end
	local lista: { Jugadores.Mision } = {}
	for _ = 1, math.min(M.PorDia, #tipos) do
		local tipo = table.remove(tipos, rng:NextInteger(1, #tipos)) :: string
		local m: Jugadores.Mision =
			{ Tipo = tipo, Meta = 1, Progreso = 0, Dato = nil, Hecha = false }
		local rango = (M.Rangos :: any)[tipo]
		if rango then
			m.Meta = rng:NextInteger(rango[1], rango[2])
		elseif tipo == "Personalidad" then
			m.Dato = personalidades[rng:NextInteger(1, #personalidades)]
		elseif tipo == "Catalizador" then
			m.Dato = conocidos[rng:NextInteger(1, #conocidos)]
		end
		table.insert(lista, m)
	end
	return { Dia = dia, Lista = lista, Bono = false }
end

local function premioMision(d: Jugadores.Datos): number
	return math.round(M.Premio * Mejoras.fusion(Jugadores.cantidadEspecies(d)))
end

function Misiones.publicar(jugador: Player)
	local d = Jugadores.obtener(jugador)
	if not d then
		return
	end
	local lista = {}
	for _, m in d.Misiones.Lista do
		table.insert(lista, {
			Texto = Misiones.texto(m),
			Progreso = math.min(m.Progreso, m.Meta),
			Meta = m.Meta,
			Hecha = m.Hecha,
		})
	end
	local fusion = Mejoras.fusion(Jugadores.cantidadEspecies(d))
	jugador:SetAttribute(
		"Misiones",
		HttpService:JSONEncode({
			Lista = lista,
			Bono = d.Misiones.Bono,
			Premio = premioMision(d),
			PremioTodas = math.round(M.PremioTodas * fusion),
		})
	)
	local hoy = Reloj.dia()
	jugador:SetAttribute("Dia", hoy)
	-- Cuándo termina el día, en la hora real del servidor (la que ve el cliente).
	jugador:SetAttribute("FinDia", os.time() + Reloj.faltaParaManana())
end

-- Si cambió el día, misiones nuevas. Devuelve true si las cambió.
function Misiones.alDia(jugador: Player): boolean
	local d = Jugadores.obtener(jugador)
	if not d then
		return false
	end
	local hoy = Reloj.dia()
	local cambio = d.Misiones.Dia ~= hoy
	if cambio then
		d.Misiones = Misiones.armar(d, hoy, jugador.UserId)
	end
	Misiones.publicar(jugador)
	return cambio
end

local function celebrar(
	jugador: Player,
	titulo: string,
	texto: string,
	detalle: string,
	premio: number
)
	Remotos.Celebracion:FireClient(jugador, {
		Gen = 0,
		Premio = premio,
		Completo = false,
		Titulo = titulo,
		Texto = texto,
		Detalle = detalle,
	})
end

-- Avisa que pasó algo que puede hacer avanzar las misiones: "Descubrir", "Fusionar",
-- "Entregar", "Residuos", "Catalizador" (dato: cuál) o "Personalidad" (dato: cuál).
function Misiones.avisar(jugador: Player, tipo: string, dato: string?)
	local d = Jugadores.obtener(jugador)
	if not d or d.Misiones.Dia ~= Reloj.dia() then
		return
	end
	local cambio = false
	for _, m in d.Misiones.Lista do
		if not m.Hecha and m.Tipo == tipo and (m.Dato == nil or m.Dato == dato) then
			m.Progreso += 1
			cambio = true
			if m.Progreso >= m.Meta then
				m.Hecha = true
				local premio = premioMision(d)
				d.ADN += premio
				Remotos.Aviso:FireClient(
					jugador,
					"¡Misión cumplida! "
						.. Misiones.texto(m)
						.. " · +"
						.. Formato.numero(premio)
						.. " ADN",
					"exito"
				)
			end
		end
	end
	if not cambio then
		return
	end
	-- Las tres: premio grande y un catalizador.
	local todas = #d.Misiones.Lista > 0
	for _, m in d.Misiones.Lista do
		todas = todas and m.Hecha
	end
	if todas and not d.Misiones.Bono then
		d.Misiones.Bono = true
		local premio = math.round(M.PremioTodas * Mejoras.fusion(Jugadores.cantidadEspecies(d)))
		d.ADN += premio
		local conocidos = Catalizadores.conocidos(d.Especies, d.CatalizadoresVistos)
		local nombres = {}
		for _ = 1, M.CatalizadoresTodas do
			local k = if #conocidos > 0 then conocidos[math.random(1, #conocidos)] else nil
			if k then
				d.Catalizadores[k] = (d.Catalizadores[k] or 0) + 1
				d.CatalizadoresVistos[k] = true
				table.insert(
					nombres,
					(Catalizadores.porClave(k) :: Catalizadores.Catalizador).Nombre
				)
			end
		end
		celebrar(
			jugador,
			"¡MISIONES DEL DÍA!",
			"+" .. Formato.numero(premio) .. " ADN",
			"Completaste las tres"
				.. (
					if #nombres > 0
						then " · +1 catalizador de " .. table.concat(nombres, ", ")
						else ""
				),
			premio
		)
	end
	Jugadores.publicar(jugador)
	Misiones.publicar(jugador)
end

-- Después de una fusión que salió: si es la especie del experimento de hoy, premio.
function Misiones.experimento(jugador: Player, clave: string)
	local d = Jugadores.obtener(jugador)
	local hoy = Reloj.dia()
	if not d or d.ExperimentoGanado == hoy then
		return
	end
	local c = Experimento.especie(hoy)
	if c.Clave ~= clave then
		return
	end
	d.ExperimentoGanado = hoy
	local premio =
		math.round(Config.Experimento.Premio * Mejoras.fusion(Jugadores.cantidadEspecies(d)))
	d.ADN += premio
	local conocidos = Catalizadores.conocidos(d.Especies, d.CatalizadoresVistos)
	for _ = 1, Config.Experimento.Catalizadores do
		local k = if #conocidos > 0 then conocidos[math.random(1, #conocidos)] else nil
		if k then
			d.Catalizadores[k] = (d.Catalizadores[k] or 0) + 1
			d.CatalizadoresVistos[k] = true
		end
	end
	Jugadores.publicar(jugador)
	celebrar(
		jugador,
		"¡EXPERIMENTO DEL DÍA!",
		c.Nombre,
		"+" .. Formato.numero(premio) .. " ADN y un catalizador",
		premio
	)
end

-- La especie de hoy (para las herramientas de prueba).
function Misiones.especieDeHoy(): Fusion.Criatura
	return Experimento.especie(Reloj.dia())
end

return Misiones
