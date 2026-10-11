--!strict
-- La máquina de fusión en equipo de la plaza (ficha, "Parte 9").
-- Dos jugadores ponen una criatura cada uno en los pedestales (tecla E en el pedestal: se abre
-- el selector en su pantalla). Con los dos lados ocupados, cada uno aprieta E en el cartel
-- ("¡Fusionar en equipo!"). Si reaccionan, cada uno paga su fusión (con su precio), los dos
-- reciben una cría y los dos descubren la especie. Nadie pierde su criatura: igual que en la
-- máquina común, los padres no se gastan (los de la máquina son copias que vuelven solas).
-- Además de las fusiones comunes salen las 10 especies de equipo (Fusion.equipo), que no salen
-- en ningún otro lado. No hay intercambio ni regalos: cada uno recibe su propia cría.
-- Todo lo valida el servidor: que la criatura sea tuya, que estés cerca y que el lado sea tuyo.
-- Plaza > MaquinaEquipo > Pedestal (x2), Ranura (x2), Cartel (x2, TextLabels), Liquido.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local Coleccion = require(script.Parent.Coleccion)
local Corrales = require(script.Parent.Corrales)
local Jugadores = require(script.Parent.Jugadores)
local Laboratorios = require(script.Parent.Laboratorios)
local Metas = require(script.Parent.Metas)
local Misiones = require(script.Parent.Misiones)
local Remotos = require(script.Parent.Remotos)

local E = Config.Equipo
local TITULO = "FUSIÓN EN EQUIPO"
local DISTANCIA_BOTON = 14 -- studs: para apretar los botones de la máquina

type Lado = {
	Numero: number,
	Pedestal: BasePart,
	Ranura: BasePart,
	Boton: ProximityPrompt,
	Jugador: Player?,
	Clave: string?,
	Personalidad: string?,
	Modelo: Model?,
	Listo: boolean,
}

local maquina = workspace:WaitForChild("Plaza"):WaitForChild("MaquinaEquipo") :: Model
-- Centro de la máquina en el piso (el pivote del modelo queda alto por el tubo de luz).
local pivote = maquina:GetPivot().Position
local centro = Vector3.new(pivote.X, 0, pivote.Z)
local lados: { Lado } = {}
local estados: { TextLabel } = {} -- el renglón de abajo de cada cartel
local liquido = maquina:FindFirstChild("Liquido") :: BasePart?
local trabajando = false

local Equipo = {}

local function partesLlamadas(nombre: string): { BasePart }
	local lista = {}
	for _, p in maquina:GetChildren() do
		if p:IsA("BasePart") and p.Name == nombre then
			table.insert(lista, p)
		end
	end
	-- El lado 1 es el de la izquierda (x más chica).
	table.sort(lista, function(a, b)
		return a.Position.X < b.Position.X
	end)
	return lista
end

local function cerca(jugador: Player, donde: Vector3, distancia: number): boolean
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if raiz and raiz:IsA("BasePart") then
		-- Se mide en el piso (sin la altura).
		local d = raiz.Position - donde
		return Vector3.new(d.X, 0, d.Z).Magnitude <= distancia
	end
	return false
end

local function avisar(jugador: Player?, texto: string, tipo: string?)
	if jugador and jugador.Parent then
		Remotos.Aviso:FireClient(jugador, texto, tipo or "info")
	end
end

-- Botones y carteles según cómo están los lados.
local function actualizar()
	for _, l in lados do
		local j = l.Jugador
		l.Boton.ActionText = if j then "Sacar la criatura" else "Poner una criatura"
		l.Boton.ObjectText = if j
			then "Lado " .. l.Numero .. " · de " .. j.DisplayName
			else "Lado " .. l.Numero
		l.Boton.Enabled = not trabajando
	end
	local a, b = lados[1], lados[2]
	local texto
	if trabajando then
		texto = "¡Fusionando!"
	elseif not a.Jugador and not b.Jugador then
		texto = "Poné una criatura en un pedestal"
	elseif not a.Jugador or not b.Jugador then
		texto = "Falta otro jugador del otro lado"
	elseif a.Listo ~= b.Listo then
		local esperando = if a.Listo then b.Jugador else a.Jugador
		texto = "Falta que " .. (esperando :: Player).DisplayName .. " apriete E"
	else
		texto = "¡Listos! Los dos aprietan E acá"
	end
	for _, t in estados do
		t.Text = texto
	end
end

local function vaciar(l: Lado, aviso: string?)
	if l.Modelo then
		l.Modelo:Destroy()
	end
	if aviso then
		avisar(l.Jugador, aviso)
	end
	l.Jugador, l.Clave, l.Personalidad, l.Modelo, l.Listo = nil, nil, nil, nil, false
	for _, otro in lados do
		otro.Listo = false
	end
end

-- La criatura de ese jugador, de esa especie y personalidad (la más vistosa).
local function unidad(d: Jugadores.Datos, clave: string, personalidad: string): Jugadores.Unidad?
	local mejor: Jugadores.Unidad? = nil
	for _, u in d.Criaturas do
		if u.Clave == clave and u.Personalidad == personalidad then
			if
				not mejor
				or (u.Variante and not mejor.Variante)
				or (u.Mutante and not mejor.Mutante)
			then
				mejor = u
			end
		end
	end
	return mejor
end

-- Pone (una copia de) una criatura del jugador en su lado. Devuelve true si se pudo.
function Equipo.poner(
	jugador: Player,
	numero: unknown,
	clave: unknown,
	personalidad: unknown
): boolean
	if
		typeof(numero) ~= "number"
		or typeof(clave) ~= "string"
		or typeof(personalidad) ~= "string"
		or #clave > 12
		or #personalidad > 16
	then
		return false
	end
	local l = lados[numero :: number]
	local d = Jugadores.obtener(jugador)
	if not l or not d or trabajando then
		return false
	end
	if not cerca(jugador, centro, E.Abandono) then
		avisar(jugador, "Acercate a la máquina de equipo de la plaza.", "error")
		return false
	end
	if l.Jugador and l.Jugador ~= jugador then
		avisar(jugador, "Ese lado ya es de " .. (l.Jugador :: Player).DisplayName .. ".", "error")
		return false
	end
	for _, otro in lados do
		if otro ~= l and otro.Jugador == jugador then
			avisar(
				jugador,
				"Ya pusiste una del otro lado: este lado es para otro jugador.",
				"error"
			)
			return false
		end
	end
	local c = Fusion.porClave(clave :: string)
	local u = unidad(d, clave :: string, personalidad :: string)
	if not c or not u then
		avisar(jugador, "No tenés esa criatura en tu laboratorio.", "error")
		return false
	end
	if c.Especial then
		avisar(jugador, "Las especies especiales no se fusionan.", "error")
		return false
	end
	vaciar(l)
	-- Parada adentro de la ranura de vidrio, mirando al frente de la máquina.
	local piso = l.Ranura.Position - Vector3.new(0, l.Ranura.Size.X / 2 - 0.1, 0)
	local modelo = Generador.crear(
		c,
		CFrame.lookAt(piso, piso + Vector3.zAxis),
		nil,
		u.Mutante,
		u.Personalidad,
		u.Variante
	)
	modelo:ScaleTo(E.Escala)
	modelo:SetAttribute("Dueno", jugador.UserId)
	Generador.cartel(
		modelo,
		modelo.Name,
		if u.Mutante then Paleta.Mutante else Paleta.Generaciones[c.Gen],
		"de " .. jugador.DisplayName,
		5
	)
	modelo.Parent = maquina
	l.Jugador, l.Clave, l.Personalidad, l.Modelo = jugador, c.Clave, u.Personalidad, modelo
	for _, otro in lados do
		if otro ~= l and otro.Jugador then
			avisar(
				otro.Jugador,
				jugador.DisplayName .. " puso a " .. modelo.Name .. " en la máquina de equipo."
			)
		end
	end
	actualizar()
	return true
end

-- Lo que le pasa a cada uno de los dos (su cobro y su cría).
type Parte = {
	Jugador: Player,
	Datos: Jugadores.Datos,
	Costo: number,
	Nueva: boolean,
	Premio: number?,
	Personalidad: string,
	Celebraciones: { Fusion.Celebracion },
}

-- La cría aparece en la cápsula (la ven todos). Devuelve el modelo, para sacarlo después.
local function mostrarCria(hijo: Fusion.Criatura, personalidad: string): Model
	-- Parada sobre el líquido (adentro se pierde entre el verde).
	local donde = Vector3.new(centro.X, 3.5, centro.Z)
	if liquido then
		local c = liquido.CFrame
		local medio = math.abs(c.RightVector.Y) * liquido.Size.X / 2
			+ math.abs(c.UpVector.Y) * liquido.Size.Y / 2
			+ math.abs(c.LookVector.Y) * liquido.Size.Z / 2
		donde = Vector3.new(centro.X, liquido.Position.Y + medio, centro.Z)
	end
	if liquido then
		local tinte = liquido.Color
		local t = TweenService:Create(
			liquido,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true),
			{ Color = Paleta.Acento }
		)
		t:Play()
		t.Completed:Once(function()
			liquido.Color = tinte
		end)
	end
	task.wait(1.2)
	local modelo =
		Generador.crear(hijo, CFrame.lookAt(donde, donde + Vector3.zAxis), nil, false, personalidad)
	modelo.Name = "Cria"
	Generador.cartel(
		modelo,
		hijo.Nombre,
		Paleta.Dorado,
		if hijo.Equipo then "¡Especie de equipo!" else "Gen " .. hijo.Gen
	)
	modelo.Parent = maquina
	return modelo
end

local function fusionar()
	local a, b = lados[1], lados[2]
	local ja, jb = a.Jugador :: Player, b.Jugador :: Player
	local da, db = Jugadores.obtener(ja), Jugadores.obtener(jb)
	local ca = Fusion.porClave(a.Clave or "")
	local cb = Fusion.porClave(b.Clave or "")
	if not da or not db or not ca or not cb then
		return
	end
	-- Se vuelve a validar todo: que sigan teniendo esas criaturas y que estén cerca.
	if
		not unidad(da, ca.Clave, a.Personalidad or "")
		or not unidad(db, cb.Clave, b.Personalidad or "")
	then
		vaciar(a, "Tu criatura ya no está en tu laboratorio.")
		vaciar(b)
		actualizar()
		return
	end
	local hijo = Fusion.equipo(ca, cb)
	local costoA = Costos.fusion(ca.Gen, cb.Gen, Jugadores.cantidadEspecies(da))
	local costoB = Costos.fusion(ca.Gen, cb.Gen, Jugadores.cantidadEspecies(db))
	if not hijo or not costoA or not costoB then
		local razon = Fusion.motivo(ca, cb) or "No reaccionan."
		for _, j in { ja, jb } do
			avisar(j, "No reaccionan ni en equipo. " .. razon, "error")
		end
		a.Listo, b.Listo = false, false
		actualizar()
		return
	end
	for _, x in { { ja, da, costoA }, { jb, db, costoB } } :: { { any } } do
		local j, d, costo = x[1] :: Player, x[2] :: Jugadores.Datos, x[3] :: number
		if d.ADN < costo then
			local texto = "A " .. j.DisplayName .. " le falta ADN (cuesta " .. costo .. ")."
			avisar(ja, texto, "error")
			avisar(jb, texto, "error")
			a.Listo, b.Listo = false, false
			actualizar()
			return
		end
	end

	-- Cada uno paga su fusión y recibe su cría. La personalidad sale de la tabla de herencia.
	local personalidad = Personalidades.heredar(a.Personalidad, b.Personalidad)
		or Personalidades.deEspecie(hijo.Bases)
	local partes: { Parte } = {}
	for _, x in { { ja, da, costoA }, { jb, db, costoB } } :: { { any } } do
		local j, d, costo = x[1] :: Player, x[2] :: Jugadores.Datos, x[3] :: number
		d.ADN -= costo
		local nueva
		if hijo.Equipo then
			nueva = not d.Especiales[hijo.Clave]
			d.Especiales[hijo.Clave] = true
		else
			nueva = Coleccion.agregar(d, hijo.Clave)
		end
		local premio = if nueva then Coleccion.premioDescubrir(costo) else nil
		if premio then
			d.ADN += premio
		end
		Jugadores.agregarCriatura(d, hijo.Clave, false, personalidad)
		d.Fusiones += 1
		table.insert(partes, {
			Jugador = j,
			Datos = d,
			Costo = costo,
			Nueva = nueva,
			Premio = premio,
			Personalidad = personalidad,
			Celebraciones = Coleccion.revisarGeneraciones(d),
		})
		Jugadores.publicar(j)
	end

	trabajando = true
	actualizar()
	local cria = mostrarCria(hijo, personalidad)
	-- Primero se ve la cría en la cápsula; después, el cartel de festejo de cada uno.
	task.wait(E.Revelar)
	for i, p in partes do
		local otro = partes[3 - i].Jugador
		Remotos.Celebracion:FireClient(p.Jugador, {
			Gen = 0,
			Premio = p.Premio or 0,
			Completo = false,
			Titulo = "¡FUSIÓN EN EQUIPO!",
			Texto = hijo.Nombre .. (if p.Nueva then " · ¡nueva!" else ""),
			Detalle = "Con " .. otro.DisplayName .. (if hijo.Equipo
				then " · especie de equipo: solo sale así"
				else " · los dos la descubren"),
		})
		for _, celebracion in p.Celebraciones do
			Remotos.Celebracion:FireClient(p.Jugador, celebracion)
		end
		if p.Nueva then
			Laboratorios.mostrarNueva(p.Jugador, hijo.Clave, false)
		end
		Corrales.actualizar(p.Jugador)
		Misiones.avisar(p.Jugador, "Fusionar")
		if p.Nueva then
			Misiones.avisar(p.Jugador, "Descubrir")
		end
		Misiones.avisar(p.Jugador, "Personalidad", p.Personalidad)
		Misiones.experimento(p.Jugador, hijo.Clave)
		Metas.revisar(p.Jugador)
	end
	task.wait(math.max(0, E.Espera - E.Revelar))
	cria:Destroy()
	trabajando = false
	vaciar(a)
	vaciar(b)
	actualizar()
end

-- Apretó E en el cartel: queda listo; con los dos listos, fusiona.
local function listo(jugador: Player)
	if trabajando or not cerca(jugador, centro, DISTANCIA_BOTON + 6) then
		return
	end
	local mio: Lado? = nil
	for _, l in lados do
		if l.Jugador == jugador then
			mio = l
		end
	end
	if not mio then
		avisar(jugador, "Primero poné una criatura en un pedestal (tecla E).")
		return
	end
	local l = mio :: Lado
	l.Listo = true
	local otro = lados[3 - l.Numero]
	if not otro.Jugador then
		avisar(jugador, "Falta que otro jugador ponga una criatura del otro lado.")
	elseif not otro.Listo then
		avisar(
			otro.Jugador,
			"¡" .. jugador.DisplayName .. " está listo! Apretá E en el cartel de la máquina."
		)
	else
		fusionar()
		return
	end
	actualizar()
end

-- Apretó E en un pedestal: si es suyo, saca la criatura; si está libre, abre el selector.
local function tocarPedestal(jugador: Player, l: Lado)
	if trabajando or not cerca(jugador, l.Pedestal.Position, DISTANCIA_BOTON) then
		return
	end
	if l.Jugador == jugador then
		vaciar(l)
		actualizar()
		return
	end
	if l.Jugador then
		avisar(jugador, "Ese lado es de " .. (l.Jugador :: Player).DisplayName .. ".")
		return
	end
	Remotos.ElegirEquipo:FireClient(jugador, l.Numero)
end

local function boton(padre: Instance, accion: string, objeto: string): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.Name = "Boton"
	p.ActionText = accion
	p.ObjectText = objeto
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = 0
	p.MaxActivationDistance = 10
	p.RequiresLineOfSight = false
	p.Parent = padre
	return p
end

function Equipo.iniciar()
	local pedestales, ranuras = partesLlamadas("Pedestal"), partesLlamadas("Ranura")
	for i = 1, 2 do
		local l: Lado = {
			Numero = i,
			Pedestal = pedestales[i],
			Ranura = ranuras[i],
			Boton = boton(pedestales[i], "Poner una criatura", "Lado " .. i),
			Jugador = nil,
			Clave = nil,
			Personalidad = nil,
			Modelo = nil,
			Listo = false,
		}
		lados[i] = l
		l.Boton.Triggered:Connect(function(jugador: Player)
			tocarPedestal(jugador, l)
		end)
	end
	for _, cartel in partesLlamadas("Cartel") do
		for _, t in cartel:GetDescendants() do
			if t:IsA("TextLabel") and t.Text ~= TITULO then
				table.insert(estados, t)
			end
		end
		boton(cartel, "¡Fusionar en equipo!", "Máquina de equipo").Triggered:Connect(listo)
	end
	Remotos.PonerEquipo.OnServerEvent:Connect(Equipo.poner)
	-- Si alguno se va o se aleja, su criatura vuelve a su laboratorio.
	Players.PlayerRemoving:Connect(function(jugador: Player)
		for _, l in lados do
			if l.Jugador == jugador then
				vaciar(l)
			end
		end
		actualizar()
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if not trabajando then
				local cambio = false
				for _, l in lados do
					local j = l.Jugador
					if j and not cerca(j, centro, E.Abandono) then
						vaciar(l, "Te alejaste: tu criatura volvió a tu laboratorio.")
						cambio = true
					end
				end
				if cambio then
					actualizar()
				end
			end
		end
	end)
	actualizar()
end

return Equipo
