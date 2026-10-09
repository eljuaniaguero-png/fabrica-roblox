--!strict
-- Una sola animación para todas las criaturas: saltitos con bamboleo.
-- Algunos rasgos la cambian: flota (sin saltos), rueda (da una vuelta) y
-- se entierra (baja al piso y vuelve). Se mueve todo el modelo con PivotTo.
-- Si el modelo tiene los atributos ZonaCFrame y ZonaTamano (criaturas de un corral),
-- además camina: va a un punto al azar de la zona, se queda un rato y elige otro.
-- En el corral cada personalidad tiene su vida (ficha, "Animación"): cuando están quietas se
-- miran entre sí, la Alegre pega saltos grandes, la Vaga camina lento y se duerme con una "Z",
-- la Peleadora va hasta una vecina y la empuja, la Miedosa se queda pegada a otra y la Curiosa
-- se acerca al jugador. Al tocarla, salta y da una vuelta (Animacion.tocar).
-- Solo la usa el cliente (client/AnimarCriaturas.client.luau).

local Config = require(script.Parent.Config)
local Dibujos = require(script.Parent.Dibujos)
local Paleta = require(script.Parent.Paleta)

local A = Config.Animacion
local V = Config.Animacion.Vida

-- Rasgos que cambian el movimiento (número de base del rasgo).
local RASGO_RUEDA = 4
local RASGO_ENTIERRA = 6
local RASGO_FLOTA = 7
local RASGO_TRANSPARENTE = 10

export type Estado = {
	Modelo: Model,
	Base: CFrame,
	Fase: number,
	Rasgo: number,
	Personalidad: string?,
	Transparencias: { [BasePart]: number },
	Colores: { [BasePart]: Color3 }?, -- solo mutantes: colores originales para hacerlos cambiar
	Anillo: BasePart?, -- el anillo de luz queda en el piso aunque la criatura salte
	AnilloRel: CFrame,
	Paseo: Paseo?, -- solo criaturas de un corral
	-- Vida en el corral:
	Evento: number, -- segundos hasta lo próximo que hace su personalidad
	Salto: number, -- segundos que le quedan a un salto grande (Alegre, empujón)
	Duerme: number, -- segundos que le quedan dormida (Vaga)
	Suenio: BillboardGui?, -- la "Z" que flota mientras duerme
	Victima: Estado?, -- la vecina que va a empujar (Peleadora)
	Toque: number, -- segundos que le quedan a la reacción al tocarla
}

type Paseo = {
	Zona: CFrame, -- centro de la zona, a la altura del piso
	Tamano: Vector3,
	Pos: Vector3,
	Destino: Vector3?,
	Espera: number,
}

-- Lo que la criatura sabe de su alrededor en cada cuadro.
export type Alrededor = {
	Vecinas: { Estado }, -- las criaturas de su corral (incluida ella)
	Jugador: Vector3?, -- dónde está el personaje del jugador
}

local Animacion = {}

local azar = Random.new()

local function entre(rango: { number }): number
	return azar:NextNumber(rango[1], rango[2])
end

-- Una vecina al azar que no sea ella misma (o nil).
local function otraAlAzar(e: Estado, vecinas: { Estado }): Estado?
	local otras = {}
	for _, v in vecinas do
		if v ~= e and v.Paseo then
			table.insert(otras, v)
		end
	end
	return if #otras > 0 then otras[azar:NextInteger(1, #otras)] else nil
end

-- Lleva un punto adentro de la zona del corral.
local function dentro(p: Paseo, punto: Vector3): Vector3
	local rel = p.Zona:PointToObjectSpace(punto)
	local x = math.clamp(rel.X, -p.Tamano.X / 2, p.Tamano.X / 2)
	local z = math.clamp(rel.Z, -p.Tamano.Z / 2, p.Tamano.Z / 2)
	return (p.Zona * CFrame.new(x, 0, z)).Position
end

local function puntoAlAzar(p: Paseo): Vector3
	local x = (azar:NextNumber() - 0.5) * p.Tamano.X
	local z = (azar:NextNumber() - 0.5) * p.Tamano.Z
	return (p.Zona * CFrame.new(x, 0, z)).Position
end

-- Adónde va cuando termina de esperar (depende de la personalidad).
local function nuevoDestino(e: Estado, p: Paseo, alrededor: Alrededor?): Vector3
	if alrededor then
		if e.Personalidad == "Curiosa" and alrededor.Jugador then
			-- Se acerca al jugador (hasta el borde del corral) si está cerca.
			local jugador = alrededor.Jugador :: Vector3
			if (jugador - p.Zona.Position).Magnitude < V.CuriosaDistancia then
				return dentro(p, jugador)
			end
		elseif e.Personalidad == "Miedosa" then
			-- Se esconde pegada a otra.
			local otra = otraAlAzar(e, alrededor.Vecinas)
			if otra and otra.Paseo then
				local lado = Vector3.new(azar:NextNumber(-1, 1), 0, azar:NextNumber(-1, 1))
				local cerca = otra.Paseo.Pos
					+ (if lado.Magnitude > 0.01 then lado.Unit else Vector3.xAxis)
						* V.MiedosaDistancia
				return dentro(p, cerca)
			end
		end
	end
	return puntoAlAzar(p)
end

-- Camina hacia el destino. Devuelve el nuevo "Base" (posición + hacia dónde mira).
local function caminar(e: Estado, p: Paseo, dt: number, alrededor: Alrededor?): CFrame
	if p.Espera > 0 then
		p.Espera -= dt
		-- Quieta: se da vuelta para mirar a la vecina más cercana.
		local mirar: Vector3? = nil
		local cerca = math.huge
		for _, otra in if alrededor then alrededor.Vecinas else {} do
			local op = otra.Paseo
			if op and otra ~= e then
				local d = (op.Pos - p.Pos).Magnitude
				if d < cerca and d > 0.3 then
					cerca, mirar = d, op.Pos
				end
			end
		end
		if mirar and e.Duerme <= 0 then
			local hacia = Vector3.new(mirar.X, p.Pos.Y, mirar.Z)
			local mirando = CFrame.lookAt(p.Pos, hacia)
			return CFrame.new(p.Pos) * e.Base.Rotation:Lerp(mirando.Rotation, math.min(1, dt * 3))
		end
		return e.Base
	end
	local destino = p.Destino
	if not destino then
		destino = nuevoDestino(e, p, alrededor)
		p.Destino = destino
	end
	local delta = (destino :: Vector3) - p.Pos
	delta = Vector3.new(delta.X, 0, delta.Z)
	if delta.Magnitude < 0.3 then
		p.Destino = nil
		p.Espera = entre(A.PausaPaseo)
		return e.Base
	end
	local velocidad = A.VelocidadPaseo * (if e.Personalidad == "Vaga" then V.VelocidadVaga else 1)
	local direccion = delta.Unit
	p.Pos += direccion * math.min(delta.Magnitude, velocidad * dt)
	-- El frente de la criatura es -Z: lookAt la deja mirando hacia donde camina. Gira suave.
	local mirando = CFrame.lookAt(p.Pos, p.Pos + direccion)
	local giro = e.Base.Rotation:Lerp(mirando.Rotation, math.min(1, dt * 6))
	return CFrame.new(p.Pos) * giro
end

-- La "Z" que flota sobre una Vaga dormida (se crea la primera vez que se duerme).
local function zeta(e: Estado): BillboardGui
	local actual = e.Suenio
	if actual then
		return actual
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Suenio"
	gui.Size = UDim2.fromScale(1.4, 1.4)
	gui.LightInfluence = 0
	gui.MaxDistance = Config.Criaturas.DistanciaIcono
	gui.Enabled = false
	local letra = Dibujos.letra(gui, "Z", Paleta.Texto)
	letra.Size = UDim2.fromScale(1, 1)
	gui.Parent = e.Modelo.PrimaryPart or e.Modelo
	e.Suenio = gui
	return gui
end

-- Velocidad del cambio de colores de los mutantes (vueltas a la rueda de colores por segundo).
local VELOCIDAD_TORNASOL = 0.12

function Animacion.preparar(modelo: Model): Estado
	local transparencias = {}
	local colores: { [BasePart]: Color3 }? = if A.Tornasol and modelo:GetAttribute("Mutante")
		then {}
		else nil
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "Raiz" then
			transparencias[d] = d.Transparency
			local _, saturacion = d.Color:ToHSV()
			-- Los ojos (blanco y negro) no cambian de color.
			if colores and saturacion > 0.15 then
				colores[d] = d.Color
			end
		end
	end
	local base = modelo:GetPivot()
	local anillo = modelo:FindFirstChild("Anillo") :: BasePart?
	local zona = modelo:GetAttribute("ZonaCFrame") :: CFrame?
	local tamano = modelo:GetAttribute("ZonaTamano") :: Vector3?
	local paseo: Paseo? = nil
	if zona and tamano then
		paseo = {
			Zona = zona,
			Tamano = tamano,
			Pos = modelo:GetPivot().Position,
			Destino = nil,
			Espera = azar:NextNumber(0, 2),
		}
	end
	return {
		Modelo = modelo,
		Base = base,
		Fase = math.random() * 10,
		Rasgo = (modelo:GetAttribute("Rasgo") :: number?) or 0,
		Personalidad = modelo:GetAttribute("Personalidad") :: string?,
		Transparencias = transparencias,
		Colores = colores,
		Anillo = anillo,
		AnilloRel = if anillo then base:ToObjectSpace(anillo.CFrame) else CFrame.identity,
		Paseo = paseo,
		Evento = azar:NextNumber(1, 6),
		Salto = 0,
		Duerme = 0,
		Suenio = nil,
		Victima = nil,
		Toque = 0,
	}
end

-- Al tocarla: salta alto y da una vuelta (y si dormía, se despierta).
function Animacion.tocar(e: Estado)
	e.Toque = V.DuracionToque
	e.Duerme = 0
end

-- Lo que hace su personalidad cuando le toca (cada tanto).
local function evento(e: Estado, alrededor: Alrededor)
	local p = e.Paseo
	if e.Personalidad == "Alegre" then
		e.Salto = V.DuracionSalto
		e.Evento = entre(V.CadaSaltoAlegre)
	elseif e.Personalidad == "Vaga" and p then
		e.Duerme = entre(V.SuenioVaga)
		p.Destino = nil
		p.Espera = e.Duerme
		e.Evento = e.Duerme + entre(V.DespiertaVaga)
	elseif e.Personalidad == "Peleadora" and p then
		local victima = otraAlAzar(e, alrededor.Vecinas)
		if victima and victima.Paseo then
			e.Victima = victima
			p.Destino = victima.Paseo.Pos
			p.Espera = 0
		end
		e.Evento = entre(V.CadaEmpujon)
	else
		e.Evento = entre(V.CadaEmpujon)
	end
end

-- Curva suave de 0 a 1 a 0 dentro de una ventana de `duracion` segundos.
local function pulso(t: number, cada: number, duracion: number): number
	local x = t % cada
	if x > duracion then
		return 0
	end
	return math.sin(x / duracion * math.pi)
end

function Animacion.paso(e: Estado, reloj: number, dt: number, alrededor: Alrededor?)
	local p = e.Paseo
	-- Vida en el corral (solo con vecinas y paseo).
	if p and alrededor then
		e.Evento -= dt
		if e.Evento <= 0 then
			evento(e, alrededor)
		end
		-- La Peleadora llegó a su vecina: la empuja (la otra sale despedida con un saltito).
		local victima = e.Victima
		if victima and not victima.Modelo.Parent then
			e.Victima = nil
			victima = nil
		end
		if victima and victima.Paseo then
			local vp = victima.Paseo
			local hacia = vp.Pos - p.Pos
			hacia = Vector3.new(hacia.X, 0, hacia.Z)
			p.Destino = vp.Pos
			if hacia.Magnitude < V.DistanciaEmpujon then
				local empuje = (if hacia.Magnitude > 0.01 then hacia.Unit else Vector3.xAxis)
					* V.Empujon
				vp.Pos = dentro(vp, vp.Pos + empuje)
				vp.Destino = nil
				vp.Espera = 0.4
				victima.Salto = V.DuracionSalto
				e.Victima = nil
				p.Destino = nil
				p.Espera = entre(A.PausaPaseo)
			end
		end
	end
	if p then
		e.Base = caminar(e, p, dt, alrededor)
	end

	local t = reloj + e.Fase
	local fase = t / A.PeriodoSalto * math.pi
	local alto = math.abs(math.sin(fase)) * A.AlturaSalto
	local giroY = 0
	local bamboleo = math.sin(fase) * A.Bamboleo

	if e.Rasgo == RASGO_FLOTA then
		alto = A.AlturaFlotar + math.sin(t * 2) * 0.25
	elseif e.Rasgo == RASGO_ENTIERRA then
		alto -= pulso(t, A.CadaCuantoSeEntierra, 1.6) * A.ProfundidadEntierro
	elseif e.Rasgo == RASGO_RUEDA then
		local x = t % A.CadaCuantoRueda
		if x < 1 then
			giroY = x * 2 * math.pi
			alto += math.sin(x * math.pi) * 0.8
		end
	end

	-- Dormida: quieta, respirando, con la "Z" que sube y se desvanece.
	if e.Duerme > 0 then
		e.Duerme -= dt
		alto = math.sin(t * 1.5) * 0.05
		bamboleo = 0
		local z = zeta(e)
		z.Enabled = true
		local subida = (t % 1.6) / 1.6
		z.StudsOffsetWorldSpace = Vector3.new(0.6, 4 + subida * 1.5, 0)
		local letra = z:FindFirstChild("Letra")
		if letra and letra:IsA("TextLabel") then
			letra.TextTransparency = subida
		end
	elseif e.Suenio and e.Suenio.Enabled then
		e.Suenio.Enabled = false
	end

	-- Salto grande (Alegre, o la que empujaron).
	if e.Salto > 0 then
		e.Salto -= dt
		alto += math.sin((1 - e.Salto / V.DuracionSalto) * math.pi) * V.AlturaSaltoGrande
	end

	-- La tocaron: salta más alto y da una vuelta.
	if e.Toque > 0 then
		e.Toque -= dt
		local x = 1 - e.Toque / V.DuracionToque
		alto += math.sin(x * math.pi) * V.AlturaToque
		giroY += x * 2 * math.pi
	end

	e.Modelo:PivotTo(e.Base * CFrame.new(0, alto, 0) * CFrame.Angles(0, giroY, bamboleo))
	local anillo = e.Anillo
	if anillo then
		anillo.CFrame = e.Base * e.AnilloRel
	end

	if e.Rasgo == RASGO_TRANSPARENTE then
		local nivel = pulso(t, 4, 2) * 0.65
		for parte, original in e.Transparencias do
			parte.Transparency = original + (1 - original) * nivel
		end
	end

	-- Mutantes: colores tornasolados que giran lento por la rueda de colores.
	if e.Colores then
		local corrimiento = (t * VELOCIDAD_TORNASOL) % 1
		for parte, original in e.Colores do
			local h, s, v = original:ToHSV()
			parte.Color = Color3.fromHSV((h + corrimiento) % 1, s, v)
		end
	end
end

return Animacion
