--!strict
-- Carteles grandes en el centro (especie nueva, premios, generación completa).
-- Entran con rebote y se van solos a los 3 segundos o al tocarlos. Nunca hay más de uno a la
-- vez: si llegan varios, se encolan. La máquina de fusión puede "fijar" el cartel mientras
-- dura su animación; la cola espera a que lo suelte.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local UI = require(script.Parent)

local Tema = UI.Tema

export type Opciones = {
	Titulo: string,
	Texto: string?, -- segunda línea grande (por ejemplo el nombre de la especie)
	Detalle: string?, -- línea chica (generación, premio)
	Color: Color3?, -- color del título (verde ácido por defecto)
	Mutante: boolean?, -- etiqueta "¡MUTANTE!" con colores que giran y borde dorado
	Duracion: number?,
	Arriba: boolean?, -- arriba de la pantalla (la máquina deja libre el centro para la criatura)
	AlMostrar: (() -> ())?, -- se llama cuando el cartel entra (papelitos, fanfarria)
}

local capa = UI.Pantalla.crear("Carteles", 30)
local cartel = UI.cartelGrande()
cartel.Marco.Parent = capa.Raiz

local ENTRAR = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local cola: { Opciones } = {}
local fijo = false
local tocado = false
local trabajando = false
local girando: RBXScriptConnection? = nil

local Carteles = {}

local function pintar(op: Opciones)
	cartel.Titulo.Text = op.Titulo
	cartel.Titulo.TextColor3 = op.Color or Paleta.Acento
	cartel.Texto.Text = op.Texto or ""
	cartel.Texto.Visible = op.Texto ~= nil
	cartel.Detalle.Text = op.Detalle or ""
	cartel.Detalle.Visible = op.Detalle ~= nil
	local mutante = op.Mutante == true
	cartel.Etiqueta.Visible = mutante
	cartel.Borde.Color = if mutante then Paleta.Dorado else Paleta.Contorno
	local alto = 32
		+ 80
		+ (if op.Texto then 60 else 0)
		+ (if op.Detalle then 44 else 0)
		+ (if mutante then 40 else 0)
	cartel.Marco.Size = UDim2.fromOffset(660, alto)
	if op.Arriba then
		cartel.Marco.AnchorPoint = Vector2.new(0.5, 0)
		cartel.Marco.Position = UDim2.new(0.5, 0, 0, Tema.Margen)
	else
		cartel.Marco.AnchorPoint = Vector2.new(0.5, 0.5)
		cartel.Marco.Position = UDim2.fromScale(0.5, 0.42)
	end
	if mutante and not girando then
		girando = RunService.RenderStepped:Connect(function(dt: number)
			cartel.Arcoiris.Rotation = (cartel.Arcoiris.Rotation + dt * 240) % 360
		end)
	elseif not mutante and girando then
		girando:Disconnect()
		girando = nil
	end
end

local function entrar()
	if cartel.Marco.Visible then
		-- Ya estaba: un saltito para que se note el cambio.
		cartel.Escala.Scale = 1.08
		UI.animar(cartel.Escala, Tema.Rebote, { Scale = 1 })
		return
	end
	cartel.Escala.Scale = 0.3
	cartel.Marco.Visible = true
	UI.animar(cartel.Escala, ENTRAR, { Scale = 1 })
end

local function salir()
	if not cartel.Marco.Visible then
		return
	end
	local t = UI.animar(cartel.Escala, Tema.Cerrar, { Scale = 0.5 })
	t.Completed:Wait()
	cartel.Marco.Visible = false
	if girando then
		girando:Disconnect()
		girando = nil
	end
end

local function trabajar()
	if trabajando then
		return
	end
	trabajando = true
	while #cola > 0 do
		while fijo do
			task.wait(0.1)
		end
		local op = table.remove(cola, 1) :: Opciones
		pintar(op)
		entrar()
		if op.AlMostrar then
			task.spawn(op.AlMostrar)
		end
		tocado = false
		local fin = os.clock() + (op.Duracion or Config.Interfaz.DuracionCartel)
		while os.clock() < fin and not tocado and not fijo do
			task.wait()
		end
		if not fijo then
			salir()
		end
	end
	trabajando = false
end

-- Encola un cartel (no frena al que lo llama).
function Carteles.mostrar(op: Opciones)
	table.insert(cola, op)
	task.spawn(trabajar)
end

-- Encola un cartel y espera a que se vaya.
function Carteles.mostrarYEsperar(op: Opciones)
	Carteles.mostrar(op)
	repeat
		task.wait()
	until #cola == 0 and not trabajando
end

-- Muestra un cartel ya mismo y lo deja hasta llamar a soltar() (animación de la máquina).
function Carteles.fijar(op: Opciones)
	fijo = true
	pintar(op)
	entrar()
	if op.AlMostrar then
		task.spawn(op.AlMostrar)
	end
end

-- Capa de pantalla completa sobre el juego, para papelitos y destellos de pantalla.
Carteles.Capa = capa

function Carteles.soltar()
	salir()
	fijo = false
end

cartel.Fondo.Activated:Connect(function()
	tocado = true
end)

return Carteles
