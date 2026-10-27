--!strict
-- Números en pantalla: lo que suma cada clavija tocada (salta sobre ella) y el panel de la
-- izquierda, FUERZA × MULTI = GOLPE, que sube con cada toque con un "pop" de tamaño.
-- Son BillboardGui con tamaño en studs, así acompañan al tablero en cualquier pantalla.

local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Clavijas = require(Shared:WaitForChild("Clavijas"))
local Config = require(Shared:WaitForChild("Config"))

local Numeros = {}

local amarillo = Color3.fromHex(Config.Colores.Numero)

local function etiqueta(padre: Instance, texto: string): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = amarillo
	t.TextStrokeTransparency = 0
	t.TextStrokeColor3 = Color3.fromHex(Config.Colores.BordeNumero)
	t.Text = texto
	t.Parent = padre
	return t
end

-- "+2" sobre una clavija (o el texto que se pase, por ejemplo la quemadura sobre el monstruo):
-- sube y se desvanece. tamanio: en studs (por defecto 3 × 1,6).
function Numeros.saltar(
	parte: BasePart,
	danio: number,
	texto: string?,
	color: Color3?,
	tamanio: Vector2?
)
	local n = Config.Numeros
	local medida = tamanio or Vector2.new(3, 1.6)
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "Numero"
	cartel.Size = UDim2.fromScale(medida.X, medida.Y) -- studs
	cartel.StudsOffsetWorldSpace = Vector3.new(0, 1, 2.5)
	cartel.LightInfluence = 0
	cartel.Adornee = parte
	local valor = texto or ("+" .. danio)
	local t = etiqueta(cartel, valor)
	t.Font = Enum.Font.Arcade
	-- Etapa 10b (Balatro/Peglin): los ×Multi salen en un cartelito rojo inclinado que crece un
	-- poco; el resto, blanco con borde azul (o del color de la clavija especial).
	local esPor = string.find(valor, "×", 1, true) ~= nil
		and string.find(valor, "eco", 1, true) == nil
	if esPor then
		local fondo = Instance.new("Frame")
		fondo.AnchorPoint = Vector2.new(0.5, 0.5)
		fondo.Position = UDim2.fromScale(0.5, 0.5)
		fondo.Size = UDim2.fromScale(1, 0.8)
		fondo.Rotation = -8
		fondo.BackgroundColor3 = Color3.fromHex(Config.Colores.Multi)
		fondo.BorderSizePixel = 0
		fondo.Parent = cartel
		local borde = Instance.new("UIStroke")
		borde.Thickness = 3
		borde.Color = Color3.fromHex("#0E0F18")
		borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		borde.Parent = fondo
		t.Parent = fondo
		t.Text = valor .. " MULTI"
		t.TextColor3 = Color3.new(1, 1, 1)
		t.TextStrokeColor3 = Color3.fromHex("#0E0F18")
		local crece = Instance.new("UIScale")
		crece.Scale = 0.8
		crece.Parent = fondo
		TweenService
			:Create(crece, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1.2,
			})
			:Play()
		TweenService:Create(fondo, TweenInfo.new(n.Duracion), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(borde, TweenInfo.new(n.Duracion), { Transparency = 1 }):Play()
	elseif color then
		t.TextColor3 = color
	else
		t.TextColor3 = Color3.new(1, 1, 1)
		t.TextStrokeColor3 = Color3.fromHex(Config.Colores.Fuerza)
	end
	cartel.Parent = parte

	local info = TweenInfo.new(n.Duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(cartel, info, { StudsOffsetWorldSpace = Vector3.new(0, 1 + n.Subida, 2.5) })
		:Play()
	-- Se ve entero la primera mitad y se desvanece en la segunda (si no, casi no se llega a leer).
	local desvanecer = TweenInfo.new(
		n.Duracion / 2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In,
		0,
		false,
		n.Duracion / 2
	)
	TweenService:Create(t, desvanecer, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(n.Duracion, function()
		cartel:Destroy()
	end)
end

-- 27/10: el número del golpe sobre el monstruo cuenta de 0 a su valor mientras crece, y después
-- sube y se desvanece como los demás.
function Numeros.contar(parte: BasePart, valor: number, color: Color3?, tamanio: Vector2?)
	local medida = tamanio or Vector2.new(9, 4)
	local cartel = Instance.new("BillboardGui")
	cartel.Name = "NumeroGolpe"
	cartel.Size = UDim2.fromScale(medida.X, medida.Y) -- studs
	cartel.StudsOffsetWorldSpace = Vector3.new(0, 1, 2.5)
	cartel.LightInfluence = 0
	cartel.Adornee = parte
	local t = etiqueta(cartel, "0")
	t.Font = Enum.Font.Arcade
	if color then
		t.TextColor3 = color
	end
	local escala = Instance.new("UIScale")
	escala.Scale = 0.4
	escala.Parent = t
	cartel.Parent = parte
	local duracion = Config.Feel.ConteoGolpe
	TweenService
		:Create(escala, TweenInfo.new(duracion, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.15,
		})
		:Play()
	task.spawn(function()
		local t0 = os.clock()
		while true do
			local f = math.min((os.clock() - t0) / duracion, 1)
			t.Text = Clavijas.numeroCorto(math.floor(valor * (1 - (1 - f) ^ 3)))
			if f >= 1 then
				break
			end
			task.wait()
		end
		t.Text = Clavijas.numeroCorto(valor)
		task.wait(Config.Feel.DanioGrande - duracion)
		local n = Config.Numeros
		TweenService:Create(
			cartel,
			TweenInfo.new(n.Duracion),
			{ StudsOffsetWorldSpace = Vector3.new(0, 1 + n.Subida, 2.5) }
		):Play()
		TweenService
			:Create(
				t,
				TweenInfo.new(n.Duracion),
				{ TextTransparency = 1, TextStrokeTransparency = 1 }
			)
			:Play()
		task.wait(n.Duracion)
		cartel:Destroy()
	end)
end

export type Panel = {
	-- Pone las dos cajas. pop: "fuerza", "multi", "por" (la azul multiplicó) o nil.
	poner: (fuerza: number, multi: number, pop: string?) -> (),
	golpe: (valor: number) -> (), -- muestra "= GOLPE" grande al caer la bola
	-- Etapa 10: el golpe en vivo mientras rebota. Devuelve true si pasó un umbral
	-- (Config.Feel.Umbrales): el número crece y cambia de color. 27/10: devuelve el nivel nuevo
	-- (1, 2, 3...) o nil.
	vivo: (total: number) -> number?,
	limpiar: () -> (), -- tiro nuevo: Fuerza 0, Multi 1 y sin golpe
	centro: () -> Vector2, -- etapa 10b: centro del "= GOLPE" en la pantalla (px), de ahí vuela al monstruo
}

-- Panel FUERZA × MULTI = GOLPE (etapa 10b: 2D, en la caja `contenedor` de la columna izquierda de
-- Pantallas, como en Balatro): caja azul con la espada, ×, caja roja con la llama y el golpe abajo.
function Numeros.crearPanel(contenedor: Frame): Panel
	local Estilo = require(script.Parent:WaitForChild("Estilo"))
	local cartel = contenedor

	local function caja(titulo: string, hex: string, x: number, icono: string): (TextLabel, UIScale)
		local fondo = Instance.new("Frame")
		fondo.Name = titulo
		fondo.Position = UDim2.new(x, 0, 0, 30)
		fondo.Size = UDim2.new(0.4, 0, 0, 86)
		fondo.BackgroundColor3 = Color3.fromHex(hex)
		fondo.BorderSizePixel = 0
		fondo.Parent = cartel
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0, 6)
		esquina.Parent = fondo
		local borde = Instance.new("UIStroke")
		borde.Thickness = 3
		borde.Color = Color3.fromHex("#0E0F18")
		borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		borde.Parent = fondo
		-- Sombra dura abajo (pixel).
		local sombra = Instance.new("Frame")
		sombra.BackgroundColor3 = Color3.fromHex("#0E0F18")
		sombra.BorderSizePixel = 0
		sombra.Position = UDim2.new(0, 3, 1, -2)
		sombra.Size = UDim2.new(1, -6, 0, 7)
		sombra.ZIndex = 0
		sombra.Parent = fondo
		local escala = Instance.new("UIScale")
		escala.Parent = fondo
		local dibujo = Estilo.iconoHud(cartel, icono)
		dibujo.AnchorPoint = Vector2.new(0.5, 0.5)
		dibujo.Position = UDim2.new(x + 0.2, 0, 0, 16)
		dibujo.Size = UDim2.fromOffset(26, 26)
		local t = etiqueta(cartel, titulo)
		t.TextScaled = false
		t.TextSize = 16
		t.Font = Enum.Font.Arcade
		t.TextColor3 = Color3.fromHex(hex)
		t.TextXAlignment = if x < 0.5 then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left
		t.Position = UDim2.new(if x < 0.5 then x - 0.06 else x + 0.32, 0, 0, 6)
		t.Size = UDim2.new(0.18, 0, 0, 20)
		t.Visible = false -- con el ícono alcanza; el nombre va dentro de la caja
		local nombre = etiqueta(fondo, titulo)
		nombre.TextScaled = false
		nombre.TextSize = 16
		nombre.Font = Enum.Font.Arcade
		nombre.TextColor3 = Color3.new(1, 1, 1)
		nombre.Position = UDim2.fromScale(0.08, 0.06)
		nombre.Size = UDim2.fromScale(0.84, 0.24)
		local valor = etiqueta(fondo, "0")
		valor.TextScaled = false
		valor.TextSize = 40
		valor.Font = Enum.Font.Arcade
		valor.TextColor3 = Color3.new(1, 1, 1)
		valor.Position = UDim2.fromScale(0.06, 0.34)
		valor.Size = UDim2.fromScale(0.88, 0.58)
		return valor, escala
	end

	local fuerza, escalaFuerza = caja("FUERZA", Config.Colores.Fuerza, 0.05, "Espada")
	local multi, escalaMulti = caja("MULTI", Config.Colores.Multi, 0.55, "Llama")
	local por = etiqueta(cartel, "×")
	por.TextScaled = false
	por.TextSize = 34
	por.Font = Enum.Font.Arcade
	por.TextColor3 = Color3.new(1, 1, 1)
	por.AnchorPoint = Vector2.new(0.5, 0)
	por.Position = UDim2.new(0.5, 0, 0, 52)
	por.Size = UDim2.new(0.1, 0, 0, 40)
	local golpe = etiqueta(cartel, "")
	golpe.TextScaled = false
	golpe.TextSize = 40
	golpe.Font = Enum.Font.Arcade
	golpe.Position = UDim2.new(0.04, 0, 0, 126)
	golpe.Size = UDim2.new(0.92, 0, 0, 42)
	local escalaGolpe = Instance.new("UIScale")
	escalaGolpe.Parent = golpe

	local info =
		TweenInfo.new(Config.Numeros.DuracionPop, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local function saltar(escala: UIScale, tamanio: number, final: number?)
		escala.Scale = tamanio
		TweenService:Create(escala, info, { Scale = final or 1 }):Play()
	end

	-- Umbrales del golpe (etapa 10).
	local F = Config.Feel
	local nivel = 0
	local function base(): number
		return 1 + nivel * F.UmbralEscala
	end

	return {
		poner = function(f: number, m: number, pop: string?)
			fuerza.Text = Clavijas.numeroCorto(f)
			multi.Text = Clavijas.numeroCorto(m)
			if pop == "fuerza" then
				saltar(escalaFuerza, Config.Numeros.PopTotal)
			elseif pop == "multi" then
				saltar(escalaMulti, Config.Numeros.PopTotal)
			elseif pop == "por" then
				saltar(escalaMulti, Config.Numeros.PopTotal * 1.3)
			end
		end,
		golpe = function(valor: number)
			-- Etapa 10b (como Balatro): las cajas azul y roja se juntan en el medio, chocan y sale
			-- el golpe gigante; después vuelven a su lugar.
			local cajaF = cartel:FindFirstChild("FUERZA") :: Frame?
			local cajaM = cartel:FindFirstChild("MULTI") :: Frame?
			if not cajaF or not cajaM then
				golpe.Text = "= " .. Clavijas.numeroCorto(valor)
				saltar(escalaGolpe, base() * 1.6, base())
				return
			end
			local posF, posM = cajaF.Position, cajaM.Position
			local medio = UDim2.new(0.3, 0, posF.Y.Scale, posF.Y.Offset)
			local ida = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			por.TextTransparency = 1
			por.TextStrokeTransparency = 1
			TweenService:Create(cajaF, ida, { Position = medio }):Play()
			TweenService:Create(cajaM, ida, { Position = medio }):Play()
			task.delay(0.14, function()
				golpe.Text = "= " .. Clavijas.numeroCorto(valor)
				saltar(escalaGolpe, base() * 2.4, base())
				escalaFuerza.Scale = 1.25
				escalaMulti.Scale = 1.25
				local vuelta = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				TweenService:Create(cajaF, vuelta, { Position = posF }):Play()
				TweenService:Create(cajaM, vuelta, { Position = posM }):Play()
				TweenService:Create(escalaFuerza, vuelta, { Scale = 1 }):Play()
				TweenService:Create(escalaMulti, vuelta, { Scale = 1 }):Play()
				task.delay(0.2, function()
					por.TextTransparency = 0
					por.TextStrokeTransparency = 0
				end)
			end)
		end,
		vivo = function(total: number): number?
			golpe.Text = "= " .. Clavijas.numeroCorto(total)
			local nuevo = 0
			for _, u in F.Umbrales do
				if total >= u then
					nuevo += 1
				end
			end
			if nuevo > nivel then
				nivel = nuevo
				golpe.TextColor3 =
					Color3.fromHex(F.UmbralColores[nivel + 1] or F.UmbralColores[#F.UmbralColores])
				saltar(escalaGolpe, base() * 1.5, base())
				return nivel
			end
			return nil
		end,
		centro = function(): Vector2
			return golpe.AbsolutePosition + golpe.AbsoluteSize / 2
		end,
		limpiar = function()
			nivel = 0
			escalaGolpe.Scale = 1
			golpe.TextColor3 = amarillo
			fuerza.Text = Clavijas.numeroCorto(Config.Danio.FuerzaInicial)
			multi.Text = Clavijas.numeroCorto(Config.Danio.MultiInicial)
			golpe.Text = ""
		end,
	}
end

return Numeros
