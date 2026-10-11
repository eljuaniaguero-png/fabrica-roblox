--!strict
-- Ficha de una criatura ajena (ficha, "Parte 9"). Al acercarte a una criatura de otro jugador
-- (de paseo, en su laboratorio o en la máquina de equipo) aparece abajo su ficha: nombre,
-- generación, elemento, personalidad y de quién es. Si es una especie que todavía no
-- descubriste, la ves completa, pero la receta queda secreta y NO se marca en tu Mutadex: esto
-- es solo pantalla, no le avisa nada al servidor.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalizadores = require(ReplicatedStorage.Shared.Catalizadores)
local Config = require(ReplicatedStorage.Shared.Config)
local Elementos = require(ReplicatedStorage.Shared.Elementos)
local Especies = require(ReplicatedStorage.Shared.Especies)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Personalidades = require(ReplicatedStorage.Shared.Personalidades)
local UI = require(script.Parent.UI)
local Menus = require(script.Parent.UI.Menus)
local Vista = require(script.Parent.Vista)

local Tema = UI.Tema
local S = Config.Social
local F = Tema.FichaAjena
local jugador = Players.LocalPlayer

local capa = UI.Pantalla.crear("FichaAjena", 3)
local tarjeta =
	UI.tarjeta({ Nombre = "FichaAjena", Borde = Paleta.Dorado, Grosor = Tema.Contorno + 1 })
tarjeta.Marco.AnchorPoint = Vector2.new(0.5, 1)
tarjeta.Marco.Position = UDim2.new(0.5, 0, 1, -Tema.Margen)
tarjeta.Marco.Size = UDim2.fromOffset(F.Ancho, F.Alto)
tarjeta.Marco.Visible = false
tarjeta.Marco.Parent = capa.Raiz

local vista = Instance.new("ViewportFrame")
vista.BackgroundTransparency = 1
vista.Size = UDim2.new(0, F.Alto - 16, 1, -16)
vista.Position = UDim2.fromOffset(8, 8)
vista.Parent = tarjeta.Fondo

local izquierda = F.Alto
local function renglon(nombre: string, y: number, alto: number, letra: number): TextLabel
	local t = UI.texto({
		Nombre = nombre,
		Texto = "",
		Fuente = "fuerte",
		Letra = letra,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -izquierda - Tema.Relleno, 0, alto),
	})
	t.Position = UDim2.fromOffset(izquierda, y)
	t.Parent = tarjeta.Fondo
	return t
end
local nombre = renglon("Nombre", 10, 40, Tema.Letra.Subtitulo)
local datos = renglon("Datos", 52, 30, Tema.Letra.Chica)
local dueno = renglon("Dueno", 84, 30, Tema.Letra.Chica)
local receta = renglon("Receta", 116, 44, Tema.Letra.Chica)
receta.TextWrapped = true

-- Con qué bases se arma (solo si ya la descubriste).
local function textoReceta(c: Fusion.Criatura): string
	local nombres = {}
	for _, b in c.Bases do
		table.insert(nombres, Especies[b].Nombre)
	end
	if c.Gen == 1 or (c.Especial and not c.Equipo) then
		return "Ya la conocés."
	end
	return "Receta" .. (if c.Equipo then " (en equipo): " else ": ") .. table.concat(nombres, " + ")
end

local mostrada: Model? = nil

local function mostrar(modelo: Model?)
	if modelo == mostrada then
		return
	end
	mostrada = modelo
	tarjeta.Marco.Visible = modelo ~= nil
	if not modelo then
		Vista.mostrar(vista, nil)
		return
	end
	local c = Fusion.porClave((modelo:GetAttribute("Clave") :: string?) or "")
	if not c then
		tarjeta.Marco.Visible = false
		return
	end
	local mutante = modelo:GetAttribute("Mutante") == true
	local personalidad = modelo:GetAttribute("Personalidad") :: string?
	local variante = modelo:GetAttribute("Variante") :: string?
	-- Se ve completa aunque no la hayas descubierto.
	Vista.mostrar(vista, c.Clave, mutante, false, personalidad, variante)
	nombre.Text = Catalizadores.nombre(c.Nombre, variante)
		.. (if mutante then " · mutante" else "")
	nombre.TextColor3 = if mutante then Paleta.Mutante else Paleta.Texto
	local p = if personalidad then Personalidades.Datos[personalidad] else nil
	datos.Text = "Gen "
		.. c.Gen
		.. " · "
		.. Elementos.texto(c)
		.. (if p then " · " .. p.Nombre else "")
	local otro = Players:GetPlayerByUserId((modelo:GetAttribute("Dueno") :: number?) or 0)
	dueno.Text = "De " .. (if otro then otro.DisplayName else "otro jugador")
	-- La receta, solo si ya la descubriste (no se marca nada en tu Mutadex).
	local tuyas = if c.Especial
		then Formato.conjunto(jugador:GetAttribute("Especiales") :: string?)
		else Formato.conjunto(jugador:GetAttribute("Especies") :: string?)
	if tuyas[c.Clave] then
		receta.Text = textoReceta(c)
		receta.TextColor3 = Paleta.Texto
	else
		receta.Text = "¡No la descubriste! La receta es un secreto."
		receta.TextColor3 = Paleta.Dorado
	end
end

-- La criatura ajena más cerca (o nil), cada tanto.
task.spawn(function()
	while true do
		task.wait(0.25)
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		local elegida: Model? = nil
		if raiz and raiz:IsA("BasePart") and not Menus.abierto() then
			local mejor = S.DistanciaFicha
			for _, m in CollectionService:GetTagged("Criatura") do
				local de = m:GetAttribute("Dueno")
				if
					m:IsA("Model")
					and de
					and de ~= jugador.UserId
					and m:IsDescendantOf(workspace)
				then
					local d = (m:GetPivot().Position - raiz.Position).Magnitude
					if d < mejor then
						elegida, mejor = m, d
					end
				end
			end
		end
		mostrar(elegida)
	end
end)
