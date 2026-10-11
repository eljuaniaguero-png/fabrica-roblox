--!strict
-- Sacar a pasear una criatura (ficha, "Parte 9"): desde la ficha de la Mutadex, el jugador elige
-- una especie que tiene en su laboratorio y una criatura suya de esa especie lo sigue por todo
-- el mapa. La ven todos, con un cartel con su nombre, su generación y de quién es. Una por
-- jugador; la criatura no sale del laboratorio (sigue trabajando en su corral).
-- El modelo lo crea el servidor (Workspace > Paseos) con el atributo "Dueno"; cada cliente lo
-- mueve detrás del personaje de su dueño (client/AnimarCriaturas.client.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Generador = require(ReplicatedStorage.Shared.Generador)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Jugadores = require(script.Parent.Jugadores)
local Remotos = require(script.Parent.Remotos)

local P = Config.Paseo

local carpeta = Instance.new("Folder")
carpeta.Name = "Paseos"
carpeta.Parent = workspace

local paseos: { [Player]: Model } = {}

local Paseos = {}

local function guardar(jugador: Player)
	local m = paseos[jugador]
	if m then
		m:Destroy()
		paseos[jugador] = nil
	end
	jugador:SetAttribute("Paseo", nil)
end

-- La más vistosa de esa especie: con variante, después mutante, si no cualquiera.
local function elegir(d: Jugadores.Datos, clave: string): Jugadores.Unidad?
	local mejor: Jugadores.Unidad? = nil
	local puntos = -1
	for _, u in d.Criaturas do
		if u.Clave == clave then
			local p = (if u.Variante then 2 else 0) + (if u.Mutante then 1 else 0)
			if p > puntos then
				mejor, puntos = u, p
			end
		end
	end
	return mejor
end

-- Saca a pasear una criatura de la especie `clave` (nil la guarda). Lo valida el servidor:
-- la tiene que tener en su laboratorio.
function Paseos.pasear(jugador: Player, clave: unknown)
	guardar(jugador)
	if clave == nil then
		return
	end
	local d = Jugadores.obtener(jugador)
	if not d or typeof(clave) ~= "string" or #clave > 12 then
		return
	end
	local c = Fusion.porClave(clave)
	local u = elegir(d, clave)
	if not c or not u then
		Remotos.Aviso:FireClient(jugador, "No tenés esa criatura en tu laboratorio.", "error")
		return
	end
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	local donde = if raiz and raiz:IsA("BasePart")
		then CFrame.new(raiz.Position - Vector3.new(0, 3, 0) - raiz.CFrame.LookVector * P.Detras)
		else CFrame.new()
	local modelo = Generador.crear(c, donde, nil, u.Mutante, u.Personalidad, u.Variante)
	modelo.Name = "Paseo_" .. jugador.UserId
	modelo:SetAttribute("Dueno", jugador.UserId)
	modelo:SetAttribute("Paseo", true)
	Generador.cartel(
		modelo,
		Catalizadores.nombre(c.Nombre, u.Variante) .. " · Gen " .. c.Gen,
		if u.Mutante then Paleta.Mutante else Paleta.Generaciones[c.Gen] or Paleta.Texto,
		"de " .. jugador.DisplayName
	)
	modelo.Parent = carpeta
	paseos[jugador] = modelo
	jugador:SetAttribute("Paseo", clave)
end

function Paseos.iniciar()
	Remotos.Pasear.OnServerEvent:Connect(function(jugador: Player, clave: unknown)
		Paseos.pasear(jugador, clave)
	end)
	Players.PlayerRemoving:Connect(guardar)
	-- Si entregó la última de esa especie, la criatura vuelve al laboratorio.
	task.spawn(function()
		while true do
			task.wait(5)
			for jugador, modelo in paseos do
				local d = Jugadores.obtener(jugador)
				local clave = modelo:GetAttribute("Clave") :: string?
				if not d or not clave or Jugadores.contar(d, clave) == 0 then
					guardar(jugador)
				end
			end
		end
	end)
end

return Paseos
