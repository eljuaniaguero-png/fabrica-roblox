--!strict
-- Pisadas en las baldosas, por jugador y controladas por el servidor.
-- El cliente avisa "pisé esta baldosa"; acá se valida (que esté encima, que no sea demasiado
-- rápido, que la baldosa esté apagada para él) y se decide todo lo demás:
--   * una baldosa apagada da paso y velocidad, toca la siguiente nota de la canción de su zona
--     y queda prendida (usada);
--   * una baldosa prendida no da nada ni suena (y cuenta como error del combo);
--   * se apaga con lo que pase primero: pisó Config.Baldosas.BaldosasParaApagar baldosas más,
--     o pasaron Config.Baldosas.SegundosParaApagar (menos con la mejora Apagado rápido).
-- También lleva el combo, el Imán (prende solo las baldosas cercanas) y el Reinicio.
-- Al cliente se le manda solo lo que tiene que mostrar (encender con nota, o apagar).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)
local Datos = require(script.Parent.Datos)
local Efectos = require(script.Parent.Efectos)
local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Pisadas = {}

type Prendida = { numero: number, desde: number, hasta: number } -- número de pisada, cuándo se prendió y cuándo se apaga sola
type Estado = {
	contador: number, -- pisadas válidas que lleva
	prendidas: { [BasePart]: Prendida },
	zona: number, -- zona de la última pisada válida (0 = todavía ninguna)
	nota: number, -- nota (baldosa) de la última pisada válida en esta zona
	racha: number, -- baldosas seguidas en orden (para completar la canción)
	ultimaPisada: number,
	combo: number, -- pisadas válidas seguidas
	aguante: number, -- errores que todavía le aguanta el combo
	proximoIman: number,
}

local estados: { [Player]: Estado } = {}
local todasLasBaldosas: { BasePart } = {}

local function nivelMejora(jugador: Player, nombre: string): number
	local perfil = Datos.obtener(jugador)
	return if perfil then perfil.Mejoras[nombre] or 0 else 0
end

local function aguanteMaximo(jugador: Player): number
	return nivelMejora(jugador, "ComboFirme") * Config.Mejoras.ComboFirme.BonusPorNivel
end

local function estadoDe(jugador: Player): Estado
	local estado = estados[jugador]
	if not estado then
		estado = {
			contador = 0,
			prendidas = {},
			zona = 0,
			nota = 0,
			racha = 0,
			ultimaPisada = 0,
			combo = 0,
			aguante = aguanteMaximo(jugador),
			proximoIman = 0,
		}
		estados[jugador] = estado
	end
	return estado
end

-- Con Apagado rápido, las baldosas se apagan antes (nunca menos de 1 baldosa ni 5 segundos).
local function limitesApagado(jugador: Player): (number, number)
	local nivel = nivelMejora(jugador, "ApagadoRapido") * Config.Mejoras.ApagadoRapido.BonusPorNivel
	local ajustes = Config.Baldosas
	local baldosas = math.max(ajustes.BaldosasParaApagar - nivel * ajustes.MenosBaldosasPorNivel, 1)
	local segundos = math.max(ajustes.SegundosParaApagar - nivel * ajustes.MenosSegundosPorNivel, 5)
	return baldosas, segundos
end

local function publicarCombo(jugador: Player, estado: Estado)
	jugador:SetAttribute("Combo", estado.combo)
	jugador:SetAttribute("ComboAguante", estado.aguante)
end

-- Un error (pisar una baldosa usada o caerse sin Escudo): gasta aguante o corta el combo.
local function cometerError(jugador: Player, estado: Estado)
	if estado.combo == 0 then
		return
	end
	if estado.aguante > 0 then
		estado.aguante -= 1
	else
		estado.combo = 0
		estado.aguante = aguanteMaximo(jugador)
	end
	publicarCombo(jugador, estado)
end

-- El cliente identifica cada baldosa por su nombre completo (no cambia con streaming).
local function clave(parte: BasePart): string
	return parte:GetFullName()
end

local function apagar(jugador: Player, estado: Estado, parte: BasePart)
	estado.prendidas[parte] = nil
	Remotos.Baldosa:FireClient(jugador, "apagar", clave(parte))
end

local function zonaDe(parte: BasePart): number
	local valor = parte:GetAttribute("Zona")
	return if typeof(valor) == "number" and Config.Zonas[valor] then valor else 1
end

-- ¿Está el personaje (según el servidor) parado sobre esta baldosa? Con margen por la demora
-- de la red, y por el recorrido si la baldosa se mueve (las mueve el cliente).
local function estaEncima(raiz: BasePart, parte: BasePart): boolean
	local margen = math.max(parte.Size.X, parte.Size.Z) / 2 + Config.Baldosas.ToleranciaDistancia
	local movil = parte:GetAttribute("Movil")
	if typeof(movil) == "Vector3" then
		margen += movil.Magnitude
	end
	local diferencia = raiz.Position - parte.Position
	local horizontal = Vector3.new(diferencia.X, 0, diferencia.Z).Magnitude
	return horizontal <= margen and diferencia.Y > -2 and diferencia.Y < 12
end

-- Pisada válida de una baldosa apagada (ya validada): paso, velocidad, nota, combo y apagados.
local function prender(jugador: Player, estado: Estado, parte: BasePart)
	local ahora = os.clock()
	local baldosasParaApagar, segundosParaApagar = limitesApagado(jugador)

	-- Prender esta y apagar las que ya quedaron N baldosas atrás.
	estado.contador += 1
	estado.prendidas[parte] = {
		numero = estado.contador,
		desde = ahora,
		hasta = ahora + segundosParaApagar,
	}
	for otra, prendida in estado.prendidas do
		if estado.contador - prendida.numero >= baldosasParaApagar then
			apagar(jugador, estado, otra)
		end
	end

	-- Canción de la zona: al entrar a otra zona arranca de cero.
	local zona = zonaDe(parte)
	local cancion = Notas.cancionDe(zona)
	if zona ~= estado.zona then
		estado.zona = zona
		estado.nota = 0
		estado.racha = 0
		jugador:SetAttribute("Zona", zona)
		Remotos.avisar(jugador, `{Config.Zonas[zona].Nombre} · {cancion.Titulo} ({cancion.Autor})`)
	end
	-- Cada baldosa toca su nota (atributo Nota: la baldosa N es la nota N). Si no tiene, la siguiente.
	local valorNota = parte:GetAttribute("Nota")
	local nota = if typeof(valorNota) == "number" then valorNota else estado.nota + 1
	Remotos.Baldosa:FireClient(jugador, "encender", clave(parte), Notas.notaDeZona(zona, nota))

	-- Canción completa: todas las baldosas de la zona seguidas, de la 1 a la última.
	if nota == estado.nota + 1 then
		estado.racha += 1
	else
		estado.racha = if nota == 1 then 1 else 0
	end
	estado.nota = nota
	if estado.racha >= #cancion.Notas and nota == #cancion.Notas then
		estado.racha = 0
		Velocidad.completarCancion(jugador, zona)
	end

	if estado.combo == 0 then
		estado.aguante = aguanteMaximo(jugador) -- combo nuevo: aguante lleno (con las mejoras al día)
	end
	estado.combo += 1
	publicarCombo(jugador, estado)
	local bonus = math.min(estado.combo * Config.Combo.BonusPorPisada, Config.Combo.BonusMaximo)
	if Velocidad.sumarPisada(jugador, bonus) then
		Puertas.actualizarNivel(jugador)
	end
end

local function alPisar(jugador: Player, parte: unknown)
	if typeof(parte) ~= "Instance" or not parte:IsA("BasePart") then
		return
	end
	if parte:GetAttribute("Baldosa") ~= true then
		return
	end
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not raiz or not raiz:IsA("BasePart") or not estaEncima(raiz, parte) then
		return
	end
	local estado = estadoDe(jugador)
	local ahora = os.clock()
	local prendida = estado.prendidas[parte]
	if prendida then
		-- Usada: no suma ni suena. Es error salvo que la acabe de prender (ida y vuelta de la red).
		if ahora - prendida.desde > Config.Combo.GraciaError then
			cometerError(jugador, estado)
		end
		return
	end
	if ahora - estado.ultimaPisada < Config.Baldosas.EsperaMinimaPisada then
		return -- demasiado rápido: no suma ni suena
	end
	estado.ultimaPisada = ahora
	prender(jugador, estado, parte)
end

-- Imán: mientras está activo, prende de a una la baldosa apagada más cercana dentro del radio.
local function usarIman(jugador: Player, estado: Estado, ahora: number)
	if ahora < estado.proximoIman or not Efectos.activo(jugador, "Iman") then
		return
	end
	local personaje = jugador.Character
	local raiz = if personaje then personaje:FindFirstChild("HumanoidRootPart") else nil
	if not raiz or not raiz:IsA("BasePart") then
		return
	end
	local mejor: BasePart? = nil
	local mejorDistancia = Config.Iman.Radio
	for _, parte in todasLasBaldosas do
		if not estado.prendidas[parte] and parte:GetAttribute("Movil") == nil then
			local distancia = (parte.Position - raiz.Position).Magnitude
			if distancia <= mejorDistancia then
				mejor = parte
				mejorDistancia = distancia
			end
		end
	end
	if mejor then
		estado.proximoIman = ahora + Config.Iman.Intervalo
		estado.ultimaPisada = ahora
		prender(jugador, estado, mejor)
	end
end

-- Reinicio: apaga todas las baldosas prendidas del jugador en la zona donde está.
function Pisadas.reiniciarZona(jugador: Player): number
	local estado = estadoDe(jugador)
	local zona = math.max(estado.zona, 1)
	local apagadas = 0
	for parte in estado.prendidas do
		if zonaDe(parte) == zona then
			apagar(jugador, estado, parte)
			apagadas += 1
		end
	end
	return apagadas
end

function Pisadas.iniciar()
	for _, parte in workspace:GetDescendants() do
		if parte:IsA("BasePart") and parte:GetAttribute("Baldosa") == true then
			table.insert(todasLasBaldosas, parte)
		end
	end
	Remotos.Pisada.OnServerEvent:Connect(alPisar)
	Puertas.alCaer(function(jugador)
		cometerError(jugador, estadoDe(jugador))
	end)
	Players.PlayerAdded:Connect(function(jugador)
		publicarCombo(jugador, estadoDe(jugador))
	end)

	-- Apagar las que cumplieron el tiempo, y mover el Imán.
	task.spawn(function()
		while true do
			task.wait(0.1)
			local ahora = os.clock()
			for _, jugador in Players:GetPlayers() do
				local estado = estadoDe(jugador)
				for parte, prendida in estado.prendidas do
					if prendida.hasta <= ahora then
						apagar(jugador, estado, parte)
					end
				end
				usarIman(jugador, estado, ahora)
			end
		end
	end)
end

function Pisadas.olvidar(jugador: Player)
	estados[jugador] = nil
end

return Pisadas
