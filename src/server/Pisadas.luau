--!strict
-- Pisadas en las baldosas, por jugador y controladas por el servidor.
-- El cliente avisa "pisé esta baldosa"; acá se valida (que esté encima, que no sea demasiado
-- rápido, que la baldosa esté apagada para él) y se decide todo lo demás:
--   * una baldosa apagada da paso y velocidad, toca la siguiente nota de la canción de su zona
--     y queda prendida (usada);
--   * una baldosa prendida no da nada ni suena;
--   * se apaga con lo que pase primero: pisó Config.Baldosas.BaldosasParaApagar baldosas más,
--     o pasaron Config.Baldosas.SegundosParaApagar.
-- Al cliente se le manda solo lo que tiene que mostrar (encender con nota, o apagar).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Notas = require(ReplicatedStorage.Shared.Notas)
local Puertas = require(script.Parent.Puertas)
local Remotos = require(script.Parent.Remotos)
local Velocidad = require(script.Parent.Velocidad)

local Pisadas = {}

type Prendida = { numero: number, hasta: number } -- número de pisada y hora en que se apaga sola
type Estado = {
	contador: number, -- pisadas válidas que lleva
	prendidas: { [BasePart]: Prendida },
	zona: number, -- zona de la última pisada válida (0 = todavía ninguna)
	nota: number, -- cuántas notas de la canción de esa zona lleva
	ultimaPisada: number,
}

local estados: { [Player]: Estado } = {}

local function estadoDe(jugador: Player): Estado
	local estado = estados[jugador]
	if not estado then
		estado = { contador = 0, prendidas = {}, zona = 0, nota = 0, ultimaPisada = 0 }
		estados[jugador] = estado
	end
	return estado
end

-- El cliente identifica cada baldosa por su nombre completo (no cambia con streaming).
local function clave(parte: BasePart): string
	return parte:GetFullName()
end

local function apagar(jugador: Player, estado: Estado, parte: BasePart)
	estado.prendidas[parte] = nil
	Remotos.Baldosa:FireClient(jugador, "apagar", clave(parte))
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
	if
		estado.prendidas[parte]
		or ahora - estado.ultimaPisada < Config.Baldosas.EsperaMinimaPisada
	then
		return -- usada (prendida) o demasiado rápido: no suma ni suena
	end
	estado.ultimaPisada = ahora

	-- Prender esta y apagar las que ya quedaron 10 baldosas atrás.
	estado.contador += 1
	estado.prendidas[parte] = {
		numero = estado.contador,
		hasta = ahora + Config.Baldosas.SegundosParaApagar,
	}
	for otra, prendida in estado.prendidas do
		if estado.contador - prendida.numero >= Config.Baldosas.BaldosasParaApagar then
			apagar(jugador, estado, otra)
		end
	end

	-- Canción de la zona: al entrar a otra zona arranca de cero.
	local valor = parte:GetAttribute("Zona")
	local zona = if typeof(valor) == "number" and Config.Zonas[valor] then valor else 1
	if zona ~= estado.zona then
		estado.zona = zona
		estado.nota = 0
		jugador:SetAttribute("Zona", zona)
		local cancion = Notas.cancionDe(zona)
		Remotos.avisar(jugador, `{Config.Zonas[zona].Nombre} · {cancion.Titulo} ({cancion.Autor})`)
	end
	estado.nota += 1
	Remotos.Baldosa:FireClient(
		jugador,
		"encender",
		clave(parte),
		Notas.notaDeZona(zona, estado.nota)
	)

	if Velocidad.sumarPisada(jugador) then
		Puertas.actualizarNivel(jugador)
	end
end

function Pisadas.iniciar()
	Remotos.Pisada.OnServerEvent:Connect(alPisar)

	-- Apagar las que cumplieron el tiempo.
	task.spawn(function()
		while true do
			task.wait(0.25)
			local ahora = os.clock()
			for jugador, estado in estados do
				for parte, prendida in estado.prendidas do
					if prendida.hasta <= ahora then
						apagar(jugador, estado, parte)
					end
				end
			end
		end
	end)
end

function Pisadas.olvidar(jugador: Player)
	estados[jugador] = nil
end

return Pisadas
