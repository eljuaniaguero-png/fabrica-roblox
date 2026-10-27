--!strict
-- El monstruo: el cartel plano de Escena (piedra) con su imagen (ForgeGUI, Config.Assets) y su
-- nombre, y la barra de vida arriba. Si falta la imagen, queda el rectángulo de su color. Solo dibuja: la vida y los golpes los decide el servidor.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

export type Monstruo = {
	mostrar: (piso: number, vida: number) -> (),
	ponerVida: (vida: number, animado: boolean) -> (),
	recibir: () -> (), -- se sacude con el golpe (etapa 10: flash blanco y se inclina)
	romper: () -> (), -- etapa 10: al morir, el cartel se rompe en pedazos que caen
	atacar: () -> (), -- se agranda y vuelve
	centro: () -> Vector3,
}

local Monstruo = {}

-- La cámara mira hacia -Z: la cara que se ve de las partes es la de atrás.
local CARA = Enum.NormalId.Back

local function texto(padre: Instance, valor: string): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Text = valor
	t.Parent = padre
	return t
end

function Monstruo.crear(cartel: BasePart, barra: BasePart): Monstruo
	local base = cartel.CFrame
	local tamanio = cartel.Size
	local t = Config.Turno

	-- Cartel de piedra: imagen (o rectángulo de color) y nombre abajo.
	cartel.Material = Enum.Material.Slate
	cartel.Color = Color3.fromHex(Config.Colores.Gris)
	local gui = Instance.new("SurfaceGui")
	gui.Face = CARA
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(500, 600)
	gui.Parent = cartel
	local rectangulo = Instance.new("Frame")
	rectangulo.AnchorPoint = Vector2.new(0.5, 0)
	rectangulo.Position = UDim2.fromScale(0.5, 0.08)
	rectangulo.Size = UDim2.fromScale(0.75, 0.66)
	rectangulo.BorderSizePixel = 0
	rectangulo.Parent = gui
	local imagen = Instance.new("ImageLabel")
	imagen.Name = "Imagen"
	imagen.AnchorPoint = Vector2.new(0.5, 0)
	imagen.Position = UDim2.fromScale(0.5, 0.02)
	imagen.Size = UDim2.fromScale(0.96, 0.76)
	imagen.BackgroundTransparency = 1
	imagen.ScaleType = Enum.ScaleType.Fit
	imagen.Parent = gui
	local nombre = texto(gui, "")
	nombre.Position = UDim2.fromScale(0.05, 0.78)
	nombre.Size = UDim2.fromScale(0.9, 0.16)

	-- Barra de vida.
	local guiBarra = Instance.new("SurfaceGui")
	guiBarra.Face = CARA
	guiBarra.LightInfluence = 0
	guiBarra.CanvasSize = Vector2.new(500, 65)
	guiBarra.Parent = barra
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Color3.fromHex(Config.Colores.FondoBarra)
	fondo.BorderSizePixel = 0
	fondo.Parent = guiBarra
	local relleno = Instance.new("Frame")
	relleno.Size = UDim2.fromScale(1, 1)
	relleno.BackgroundColor3 = Color3.fromHex(Config.Colores.VidaMonstruo)
	relleno.BorderSizePixel = 0
	relleno.Parent = fondo
	local numeros = texto(fondo, "")
	numeros.Size = UDim2.fromScale(1, 1)
	numeros.ZIndex = 2

	local vidaMaxima = 1

	local function ponerVida(vida: number, animado: boolean)
		local fraccion = math.clamp(vida / vidaMaxima, 0, 1)
		numeros.Text = ("%d/%d"):format(vida, vidaMaxima)
		local destino = UDim2.fromScale(fraccion, 1)
		if animado then
			TweenService:Create(
				relleno,
				TweenInfo.new(t.BajadaBarra, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = destino }
			):Play()
		else
			relleno.Size = destino
		end
	end

	-- Flash blanco (etapa 10): un cuadro blanco encima de la imagen que se apaga rápido.
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 5
	flash.Parent = gui
	local F = Config.Feel

	local sacudida = 0 -- para cortar una sacudida vieja si empieza otra
	return {
		mostrar = function(piso: number, vida: number)
			local m = Mazmorra.monstruo(piso)
			vidaMaxima = m.Vida
			local id = (Config.Assets.Monstruos :: any)[m.Id] or ""
			imagen.Image = id
			rectangulo.Visible = id == ""
			rectangulo.BackgroundColor3 = Color3.fromHex(m.Color)
			nombre.Text = m.Nombre
			cartel.Size = tamanio
			cartel.CFrame = base
			cartel.Transparency = 0
			gui.Enabled = true
			ponerVida(vida, false)
		end,
		ponerVida = ponerVida,
		recibir = function()
			sacudida += 1
			local marca = sacudida
			flash.BackgroundTransparency = 0.2
			TweenService:Create(flash, TweenInfo.new(F.Destello), { BackgroundTransparency = 1 })
				:Play()
			task.spawn(function()
				local fin = os.clock() + t.Sacudida
				local lado = if math.random() < 0.5 then -1 else 1
				while os.clock() < fin and sacudida == marca do
					local queda = (fin - os.clock()) / t.Sacudida * Ajustes.factorEfectos()
					-- Se inclina hacia un lado y vuelve, temblando un poco.
					cartel.CFrame = base
						* CFrame.new((math.random() * 2 - 1) * 0.6 * queda, 0, 0)
						* CFrame.Angles(0, 0, math.rad(F.Inclinar * lado * queda))
					task.wait()
				end
				if sacudida == marca then
					cartel.CFrame = base
				end
			end)
		end,
		atacar = function()
			-- Se agranda y se acerca a la cámara (que mira hacia -Z: acercarse es +Z), y vuelve.
			local info = TweenInfo.new(
				t.DuracionAtaque / 2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out,
				0,
				true
			)
			TweenService:Create(cartel, info, {
				Size = Vector3.new(tamanio.X * t.Agrandar, tamanio.Y * t.Agrandar, tamanio.Z),
				CFrame = base + Vector3.new(0, 0, F.Acercar),
			}):Play()
		end,
		romper = function()
			-- Pedazos planos del color del cartel que caen girando; el cartel se esconde hasta
			-- que aparece el próximo monstruo (mostrar).
			sacudida += 1
			gui.Enabled = false
			cartel.Transparency = 1
			local n = F.Pedazos
			for i = 1, n do
				local p = Instance.new("Part")
				p.Name = "Pedazo"
				p.Anchored = true
				p.CanCollide = false
				p.CanTouch = false
				p.CanQuery = false
				p.CastShadow = false
				p.Material = Enum.Material.Slate
				p.Color = cartel.Color
				p.Size = Vector3.new(tamanio.X / 2.2, tamanio.Y / (n / 2), 0.2)
				local col = (i - 1) % 2
				local fila = math.floor((i - 1) / 2)
				p.CFrame = base
					* CFrame.new(
						(col - 0.5) * tamanio.X / 2,
						tamanio.Y / 2 - (fila + 0.5) * tamanio.Y / (n / 2),
						0.2
					)
				p.Parent = cartel.Parent
				local caida = TweenService:Create(
					p,
					TweenInfo.new(
						0.7 + math.random() * 0.3,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					),
					{
						CFrame = p.CFrame
							* CFrame.new((col - 0.5) * 3, -tamanio.Y * 1.3, 1)
							* CFrame.Angles(0, 0, math.rad((math.random() * 2 - 1) * 160)),
						Transparency = 1,
					}
				)
				caida:Play()
				caida.Completed:Once(function()
					p:Destroy()
				end)
			end
		end,
		centro = function(): Vector3
			return base.Position
		end,
	}
end

return Monstruo
