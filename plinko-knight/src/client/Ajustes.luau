--!strict
-- Ajustes (etapa 7): sonido sí/no, música sí/no y efectos reducidos (menos temblor y partículas).
-- Se abren con el botón ⚙ de la pelea o de la pantalla de inicio. Se guardan con el progreso
-- (remoto GuardarAjustes, el servidor solo acepta 3 sí/no) y llegan con él al entrar.
--
-- Sonido y música: cada sonido del juego va en uno de estos dos SoundGroup de SoundService
-- (todavía no hay sonidos; llegan en la etapa 10). Apagar = volumen 0.
-- Efectos reducidos: Ajustes.factorEfectos() da 1 o 0 (sin temblor); lo usan el temblor de la
-- pantalla y la sacudida del monstruo (y las partículas de la etapa 10).

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local Estilo = require(script.Parent:WaitForChild("Estilo"))

export type Valores = { Sonido: boolean, Musica: boolean, EfectosReducidos: boolean }

local Ajustes = {}

local FACTOR_REDUCIDO = 0 -- etapa 10: con efectos reducidos no hay temblores (antes 0,25)

local valores: Valores = { Sonido = true, Musica = true, EfectosReducidos = false }

local function grupo(nombre: string): SoundGroup
	local g = SoundService:FindFirstChild(nombre)
	if g and g:IsA("SoundGroup") then
		return g
	end
	local nuevo = Instance.new("SoundGroup")
	nuevo.Name = nombre
	nuevo.Parent = SoundService
	return nuevo
end
-- SONIDO: los efectos van en SoundService.Efectos y la música en SoundService.Musica.
local grupoEfectos = grupo("Efectos")
local grupoMusica = grupo("Musica")

local function aplicar()
	grupoEfectos.Volume = if valores.Sonido then 1 else 0
	grupoMusica.Volume = if valores.Musica then 1 else 0
end
aplicar()

function Ajustes.efectosReducidos(): boolean
	return valores.EfectosReducidos
end

-- 1 normal, 0 con efectos reducidos: multiplica los temblores (las chispas usan la mitad).
function Ajustes.factorEfectos(): number
	return if valores.EfectosReducidos then FACTOR_REDUCIDO else 1
end

-- Lo guardado (llega con el progreso). No pisa lo que el jugador esté cambiando ahora.
local cambiando = false
local redibujar: () -> () = function() end
function Ajustes.cargar(guardado: any)
	if cambiando or typeof(guardado) ~= "table" then
		return
	end
	for _, clave in { "Sonido", "Musica", "EfectosReducidos" } do
		if typeof(guardado[clave]) == "boolean" then
			(valores :: any)[clave] = guardado[clave]
		end
	end
	aplicar()
	redibujar()
end

-- Avisa al servidor un rato después del último toque (si tocás varias veces, va uno solo).
local remoto: RemoteEvent? = nil
task.spawn(function()
	local r = game:GetService("ReplicatedStorage")
		:WaitForChild("Remotos")
		:WaitForChild("GuardarAjustes", 10)
	if r and r:IsA("RemoteEvent") then
		remoto = r
	end
end)
local toques = 0
local function guardar()
	toques += 1
	local marca = toques
	cambiando = true
	task.delay(0.6, function()
		if toques ~= marca then
			return
		end
		cambiando = false
		local r = remoto
		if r then
			r:FireServer(table.clone(valores))
		end
	end)
end

-- Panel de ajustes: arriba de todo.
local gui = Estilo.pantalla("Ajustes", 40, Players.LocalPlayer:WaitForChild("PlayerGui"))
gui.Enabled = false
Estilo.velo(gui)
local lienzo = Estilo.lienzo(gui)
local M = Estilo.Medidas

local caja = Estilo.panel(lienzo, "Panel")
caja.Name = "Caja"
caja.AnchorPoint = Vector2.new(0.5, 0.5)
caja.Position = UDim2.fromScale(0.5, 0.5)
caja.Size = UDim2.fromOffset(560, 420)
caja.BackgroundTransparency = 0
Estilo.borde(caja, "Borde")
local titulo = Estilo.texto(caja, "Ajustes", Estilo.Texto.Enorme)
titulo.Position = UDim2.fromOffset(0, 16)
titulo.Size = UDim2.new(1, 0, 0, 60)

local filas = {
	{ Clave = "Sonido", Nombre = "Sonido" },
	{ Clave = "Musica", Nombre = "Música" },
	{
		Clave = "EfectosReducidos",
		Nombre = "Efectos reducidos",
		Ayuda = "menos temblor y partículas",
	},
}
local interruptores: { [string]: TextButton } = {}
for i, f in filas do
	local y = 90 + (i - 1) * (M.Boton + 16)
	local nombre = Estilo.texto(caja, f.Nombre, Estilo.Texto.Grande)
	nombre.TextXAlignment = Enum.TextXAlignment.Left
	nombre.Position = UDim2.fromOffset(32, y)
	nombre.Size = UDim2.new(1, -230, 0, if f.Ayuda then 40 else M.Boton)
	if f.Ayuda then
		local ayuda = Estilo.texto(caja, f.Ayuda, Estilo.Texto.Chico, Estilo.Fuentes.Texto)
		ayuda.TextXAlignment = Enum.TextXAlignment.Left
		ayuda.TextColor3 = Estilo.color("Apagado")
		ayuda.Position = UDim2.fromOffset(32, y + 40)
		ayuda.Size = UDim2.new(1, -230, 0, 26)
	end
	local b = Estilo.boton(caja, "", "Si", Estilo.Texto.Grande)
	b.Name = f.Clave
	b.AnchorPoint = Vector2.new(1, 0)
	b.Position = UDim2.new(1, -32, 0, y)
	b.Size = UDim2.fromOffset(150, M.Boton)
	b.Activated:Connect(function()
		(valores :: any)[f.Clave] = not (valores :: any)[f.Clave]
		aplicar()
		redibujar()
		guardar()
	end)
	interruptores[f.Clave] = b
end

local listo = Estilo.boton(caja, "Listo", "Principal", Estilo.Texto.Grande)
listo.Name = "Listo"
listo.AnchorPoint = Vector2.new(0.5, 1)
listo.Position = UDim2.new(0.5, 0, 1, -20)
listo.Size = UDim2.fromOffset(260, M.Boton)

redibujar = function()
	for clave, b in interruptores do
		local si = (valores :: any)[clave]
		b.Text = if si then "Sí" else "No"
		b.BackgroundColor3 = Estilo.color(if si then "Si" else "No")
	end
end
redibujar()

local alCerrar: (() -> ())? = nil
function Ajustes.abrir(cuandoCierre: (() -> ())?)
	alCerrar = cuandoCierre
	gui.Enabled = true
end
function Ajustes.abierto(): boolean
	return gui.Enabled
end
listo.Activated:Connect(function()
	gui.Enabled = false
	local f = alCerrar
	alCerrar = nil
	if f then
		f()
	end
end)

-- Chat y lista de jugadores: se esconden en la pelea y vuelven fuera de ella. El botón del menú
-- de Roblox no se toca (siempre se ve). Si Roblox no deja (pcall), no pasa nada.
function Ajustes.modoPelea(peleando: boolean)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not peleando)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not peleando)
	end)
end
-- Lo que no se usa nunca en este juego: mochila y vida del personaje.
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

return Ajustes
