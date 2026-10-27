--!strict
-- El monstruo: el cartel plano de Escena con su imagen (ForgeGUI, Config.Assets), su nombre, su
-- barra de vida y la maña si es jefe (etapa 12b: kit de Forja, ver Monstruo.crear). Si falta la imagen, queda el rectángulo de su color. Solo dibuja: la vida y los golpes los decide el servidor.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Mazmorra = require(Shared:WaitForChild("Mazmorra"))
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Ajustes = require(script.Parent:WaitForChild("Ajustes"))

export type Monstruo = {
	mostrar: (piso: number, vida: number, mania: string?) -> (), -- mania: id de la maña o ""
	ponerVida: (vida: number, animado: boolean) -> (),
	recibir: () -> (), -- se sacude con el golpe (etapa 10: flash blanco y se inclina)
	romper: () -> (), -- etapa 10: al morir, el cartel se rompe en pedazos que caen
	atacar: () -> (), -- se agranda y vuelve
	centro: () -> Vector3,
}

local Monstruo = {}

-- La cámara mira hacia -Z: la cara que se ve de las partes es la de atrás.
local CARA = Enum.NormalId.Back

function Monstruo.crear(cartel: BasePart, _barra: BasePart): Monstruo
	local base = cartel.CFrame
	local tamanio = cartel.Size
	local t = Config.Turno
	local Kit = require(script.Parent:WaitForChild("Kit"))

	-- Etapa 12b: el cartel es transparente; en su cara van, de arriba a abajo, la cinta roja con la
	-- maña del jefe, el dibujo grande sobre un halo de su color (con rayos si es jefe), el nombre y
	-- la barra de vida del kit de Forja. Todo en la misma pieza, así se mueve junto al sacudirse,
	-- agrandarse y romperse, y los números 3D del golpe siguen saliendo delante.
	cartel.Transparency = 1
	local ANCHO = 600 -- lienzo de la cara: 600 × 800 (proporcional al cartel, 21 × 28 studs)
	local CENTRO = 380 -- alto del centro del dibujo
	local gui = Instance.new("SurfaceGui")
	gui.Face = CARA
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(ANCHO, 800)
	gui.Parent = cartel

	-- Halo: tres círculos del color del monstruo, del más grande y tenue al más chico.
	local halos: { Frame } = {}
	for i, lado in { 560, 430, 300 } do
		local h = Instance.new("Frame")
		h.Name = "Halo"
		h.AnchorPoint = Vector2.new(0.5, 0.5)
		h.Position = UDim2.fromOffset(ANCHO / 2, CENTRO)
		h.Size = UDim2.fromOffset(lado, lado)
		h.BackgroundTransparency = 0.94 - i * 0.05
		h.BorderSizePixel = 0
		h.ZIndex = 0
		local redondo = Instance.new("UICorner")
		redondo.CornerRadius = UDim.new(1, 0)
		redondo.Parent = h
		h.Parent = gui
		table.insert(halos, h)
	end
	-- Rayos dorados que giran detrás del jefe.
	local rayos = Instance.new("Frame")
	rayos.Name = "Rayos"
	rayos.AnchorPoint = Vector2.new(0.5, 0.5)
	rayos.Position = UDim2.fromOffset(ANCHO / 2, CENTRO)
	rayos.Size = UDim2.fromOffset(10, 10)
	rayos.BackgroundTransparency = 1
	rayos.ZIndex = 0
	rayos.Parent = gui
	for i = 1, 12 do
		local r = Instance.new("Frame")
		r.AnchorPoint = Vector2.new(0.5, 1)
		r.Position = UDim2.fromScale(0.5, 0.5)
		r.Size = UDim2.fromOffset(44, 330)
		r.Rotation = i * 30
		r.BackgroundColor3 = Color3.fromHex(Config.Colores.Oro)
		r.BorderSizePixel = 0
		r.ZIndex = 0
		local desvanecer = Instance.new("UIGradient")
		desvanecer.Rotation = 90
		desvanecer.Transparency = NumberSequence.new(1, 0.55)
		desvanecer.Parent = r
		r.Parent = rayos
	end

	local rectangulo = Instance.new("Frame")
	rectangulo.AnchorPoint = Vector2.new(0.5, 0.5)
	rectangulo.Position = UDim2.fromOffset(ANCHO / 2, CENTRO)
	rectangulo.Size = UDim2.fromOffset(380, 420)
	rectangulo.BorderSizePixel = 0
	rectangulo.ZIndex = 1
	rectangulo.Parent = gui
	local imagen = Instance.new("ImageLabel")
	imagen.Name = "Imagen"
	imagen.AnchorPoint = Vector2.new(0.5, 0.5)
	imagen.Position = UDim2.fromOffset(ANCHO / 2, CENTRO)
	imagen.Size = UDim2.fromOffset(500, 500)
	imagen.BackgroundTransparency = 1
	imagen.ScaleType = Enum.ScaleType.Fit
	imagen.ZIndex = 2
	imagen.Parent = gui
	-- 27/10: quieto, el monstruo respira (se balancea y se estira apenas); los rayos giran.
	local respirar = Instance.new("UIScale")
	respirar.Parent = imagen
	game:GetService("RunService").Heartbeat:Connect(function()
		if not gui.Enabled then
			return
		end
		local ahora = os.clock()
		local f = Ajustes.factorEfectos()
		imagen.Rotation = math.sin(ahora * 1.3) * Config.Feel.Respirar * f
		respirar.Scale = 1 + math.sin(ahora * 2.6) * 0.025 * f
		rayos.Rotation = ahora * Config.Feel.GiroRayos
	end)

	-- Cinta roja con la maña del jefe (arriba).
	local cinta = Instance.new("Frame")
	cinta.Name = "Mania"
	cinta.AnchorPoint = Vector2.new(0.5, 0)
	cinta.Position = UDim2.fromOffset(ANCHO / 2, 0)
	cinta.Size = UDim2.fromOffset(580, 112)
	cinta.ZIndex = 3
	Kit.superficie(cinta, { "Cabecera" }, Kit.Colores.Rojo, 26, 5)
	Kit.rayas(cinta)
	cinta.Parent = gui
	local maniaNombre = Kit.texto("", 46, nil, 5)
	maniaNombre.AnchorPoint = Vector2.new(0.5, 0.5)
	maniaNombre.Position = UDim2.fromOffset(290, 38)
	maniaNombre.ZIndex = 4
	maniaNombre.Parent = cinta
	local maniaRegla = Kit.texto("", 26, nil, 3)
	maniaRegla.AutomaticSize = Enum.AutomaticSize.None
	maniaRegla.AnchorPoint = Vector2.new(0.5, 0.5)
	maniaRegla.Position = UDim2.fromOffset(290, 82)
	maniaRegla.Size = UDim2.fromOffset(540, 32)
	maniaRegla.TextScaled = true
	maniaRegla.ZIndex = 4
	maniaRegla.Parent = cinta

	-- Nombre y barra de vida (abajo).
	local nombre = Kit.texto("", 46, nil, 5)
	nombre.AnchorPoint = Vector2.new(0.5, 0)
	nombre.Position = UDim2.fromOffset(ANCHO / 2, 642)
	nombre.ZIndex = 3
	nombre.Parent = gui
	local ANCHO_BARRA, ALTO_BARRA = 540, 66
	local barra, ponerBarra = Kit.barra(ANCHO_BARRA, ALTO_BARRA, Kit.Colores.Rojo)
	barra.AnchorPoint = Vector2.new(0.5, 0)
	barra.Position = UDim2.fromOffset(ANCHO / 2, 718)
	barra.ZIndex = 3
	barra.Parent = gui
	local relleno = barra:FindFirstChild("Relleno") :: Frame

	local vidaMaxima = 1

	local function ponerVida(vida: number, animado: boolean)
		local fraccion = math.clamp(vida / vidaMaxima, 0, 1)
		local texto = ("%s / %s"):format(
			Clavijas.numeroCorto(vida),
			Clavijas.numeroCorto(vidaMaxima)
		)
		if animado then
			ponerBarra(fraccion, texto) -- Kit.barra baja con una animación corta
		else
			ponerBarra(fraccion, texto)
			-- monstruo nuevo: la barra llena de una, sin animar desde la del anterior
			relleno.Size = UDim2.new(
				0,
				math.max(ALTO_BARRA - 6, math.floor((ANCHO_BARRA - 6) * fraccion)),
				1,
				-6
			)
		end
	end

	-- Flash blanco (etapa 10): encima del dibujo, se apaga rápido.
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.AnchorPoint = Vector2.new(0.5, 0.5)
	flash.Position = UDim2.fromOffset(ANCHO / 2, CENTRO)
	flash.Size = UDim2.fromOffset(420, 420)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 5
	local redondoFlash = Instance.new("UICorner")
	redondoFlash.CornerRadius = UDim.new(1, 0)
	redondoFlash.Parent = flash
	flash.Parent = gui
	local colorActual = Color3.new(1, 1, 1)
	local F = Config.Feel

	local sacudida = 0 -- para cortar una sacudida vieja si empieza otra
	return {
		mostrar = function(piso: number, vida: number, mania: string?)
			local m = Mazmorra.monstruo(piso)
			vidaMaxima = m.Vida
			local id = (Config.Assets.Monstruos :: any)[m.Id] or ""
			imagen.Image = id
			rectangulo.Visible = id == ""
			colorActual = Color3.fromHex(m.Color)
			rectangulo.BackgroundColor3 = colorActual
			for _, h in halos do
				h.BackgroundColor3 = colorActual
			end
			-- Etapa 12b: el jefe, más grande, con rayos y el nombre dorado.
			local jefe = m.EsJefe == true
			rayos.Visible = jefe
			local lado = if jefe then 560 else 500
			imagen.Size = UDim2.fromOffset(lado, lado)
			nombre.Text = m.Nombre
			nombre.TextColor3 = if jefe
				then Color3.fromHex(Config.Colores.Oro)
				else Color3.new(1, 1, 1)
			-- Cinta: "Rabia: si no lo matás, te pega el doble" → "RABIA" y la regla abajo.
			local texto = if mania and mania ~= "" then Mazmorra.textoMania(mania, m.Zona) else ""
			local dos = string.find(texto, ": ", 1, true)
			cinta.Visible = dos ~= nil
			if dos then
				maniaNombre.Text = string.upper(string.sub(texto, 1, dos - 1))
				local regla = string.sub(texto, dos + 2)
				maniaRegla.Text = string.upper(string.sub(regla, 1, 1)) .. string.sub(regla, 2)
			end
			cartel.Size = tamanio
			cartel.CFrame = base
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
				p.Material = Enum.Material.SmoothPlastic
				p.Color = colorActual
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
