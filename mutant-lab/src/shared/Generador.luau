--!strict
-- Arma el modelo de cualquier criatura a partir de sus piezas.
-- Estilo de la guía (ficha, "Guía de estilo", punto 5): chibi, ojos que cambian con la
-- personalidad, una gema de Neon con el color de su elemento, un anillo de luz con el color
-- de su generación y, si es mutante, colores más vivos, gema más grande y brillo dorado.

local CollectionService = game:GetService("CollectionService")

local Config = require(script.Parent.Config)
local Dibujos = require(script.Parent.Dibujos)
local Especies = require(script.Parent.Especies)
local Fusion = require(script.Parent.Fusion)
local Paleta = require(script.Parent.Paleta)
local Personalidades = require(script.Parent.Personalidades)
local Piezas = require(script.Parent.Piezas)

local Generador = {}

local C = Config.Criaturas
local COLOR_SILUETA = Paleta.Piezas.Negro
local CENTRO_CABEZA = Vector3.new(0, 3.9, -1.7) -- donde arma Piezas las cabezas

-- Partes que no se repintan ni se apagan: ojos, cejas y las piezas propias del estilo.
local SIN_PINTAR = {
	Raiz = true,
	Ojo = true,
	Brillo = true,
	Ceja = true,
	Gema = true,
	Anillo = true,
}

-- Color del elemento. Si la criatura viene de bases de distintos elementos, se mezclan:
-- se promedia el tono en la rueda de colores y se queda con la intensidad más alta
-- (así la mezcla sigue siendo un color vivo y no un gris).
function Generador.colorElemento(c: Fusion.Criatura): Color3
	local x, y, s, v = 0, 0, 0, 0
	for _, n in c.Bases do
		local h, sat, val = Paleta.Elementos[Especies[n].Elemento]:ToHSV()
		x += math.cos(h * 2 * math.pi)
		y += math.sin(h * 2 * math.pi)
		s = math.max(s, sat)
		v = math.max(v, val)
	end
	return Color3.fromHSV((math.atan2(y, x) / (2 * math.pi)) % 1, s, v)
end

-- Mueve y escala partes medidas desde `donde`: `mover` recibe la posición local de cada una.
local function reubicar(
	partes: { Instance },
	donde: CFrame,
	escala: number,
	mover: (Vector3) -> Vector3
)
	for _, p in partes do
		if p:IsA("BasePart") and p.Name ~= "Raiz" then
			local rel = donde:ToObjectSpace(p.CFrame)
			p.Size *= escala
			p.CFrame = donde * CFrame.new(mover(rel.Position)) * rel.Rotation
		end
	end
end

-- Anillo de luz en el piso, del color de la generación (o dorado si es mutante).
-- Es una SurfaceGui sobre una parte invisible: un círculo con borde grueso que brilla.
local function anillo(modelo: Model, donde: CFrame, color: Color3)
	local diametro = C.Anillo * C.Escala
	local p = Instance.new("Part")
	p.Name = "Anillo"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = Vector3.new(diametro, 0.05, diametro)
	p.CFrame = donde * CFrame.new(0, 0.08, 0)
	p.Parent = modelo

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.CanvasSize = Vector2.new(256, 256)
	gui.LightInfluence = 0
	gui.Brightness = 2
	gui.Parent = p

	local circulo = Instance.new("Frame")
	circulo.Size = UDim2.fromScale(1, 1)
	circulo.BackgroundColor3 = color
	circulo.BackgroundTransparency = 0.8
	circulo.BorderSizePixel = 0
	circulo.Parent = gui
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0.5, 0)
	esquina.Parent = circulo
	local borde = Instance.new("UIStroke")
	borde.Color = color
	borde.Thickness = 18
	borde.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borde.Parent = circulo
end

-- Ícono chico y semitransparente sobre la cabeza. Borde verde si la personalidad es
-- positiva y magenta si es negativa. Solo se ve de cerca.
local function icono(raiz: BasePart, personalidad: string, alto: number)
	local datos = Personalidades.Datos[personalidad]
	if not datos then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Icono"
	gui.Size = UDim2.fromScale(1.3, 1.3)
	gui.StudsOffsetWorldSpace = Vector3.new(0, alto + 0.9, 0)
	gui.MaxDistance = C.DistanciaIcono
	gui.LightInfluence = 0
	gui.Parent = raiz

	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.fromScale(1, 1)
	fondo.BackgroundColor3 = Paleta.Fondo
	fondo.BackgroundTransparency = 0.35
	fondo.Parent = gui
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0.5, 0)
	esquina.Parent = fondo
	local borde = Instance.new("UIStroke")
	borde.Color = if datos.Positiva then Paleta.Acento else Paleta.Alerta
	borde.Thickness = 3
	borde.Transparency = 0.15
	borde.Parent = fondo

	-- El dibujo se arma en proporciones, así que se estira al tamaño del cartel.
	local dibujo = Dibujos.crear(datos.Dibujo, 32, borde.Color)
	dibujo.Size = UDim2.fromScale(0.66, 0.66)
	dibujo.Parent = fondo
end

-- Crea el modelo parado en `donde` (el pivote queda en el piso, mirando a -Z).
-- La versión mutante tiene las mismas piezas: cambia el color, la gema y suma brillo dorado.
function Generador.crear(
	c: Fusion.Criatura,
	donde: CFrame,
	padre: Instance?,
	mutante: boolean?,
	personalidad: string?
): Model
	local modelo = Instance.new("Model")
	modelo.Name = c.Nombre
	-- Que llegue entera a cada jugador (si no, la animación puede arrancar sin sus piezas).
	modelo.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

	-- Raíz invisible: es el pivote y lleva las partículas, luces e ícono.
	local raiz = Instance.new("Part")
	raiz.Name = "Raiz"
	raiz.Anchored = true
	raiz.CanCollide = false
	raiz.CanQuery = false
	raiz.Transparency = 1
	raiz.Size = Vector3.new(1, 1, 1)
	raiz.CFrame = donde
	raiz.Parent = modelo
	modelo.PrimaryPart = raiz

	-- Cada pieza se pinta con los colores del padre que la trae.
	local function ctx(base: number, destino: Model): Piezas.Ctx
		local color, manchas = Fusion.pintura(c, base)
		return {
			Modelo = destino,
			Origen = donde,
			Color = color,
			Manchas = manchas,
			Personalidad = personalidad,
		}
	end

	-- Cuerpo, patas, cola y rasgo se achican desde el piso.
	Piezas.Patas[c.Patas](ctx(c.Patas, modelo))
	Piezas.Cuerpos[c.Cuerpo](ctx(c.Cuerpo, modelo))
	Piezas.Extremidades[c.Extremidad](ctx(c.Extremidad, modelo))
	Piezas.Rasgos[c.Rasgo](ctx(c.Cuerpo, modelo), raiz, c.Cuerpo)
	local escalaCuerpo = C.EscalaCuerpo * C.Escala
	reubicar(modelo:GetChildren(), donde, escalaCuerpo, function(pos)
		return pos * escalaCuerpo
	end)
	for _, a in raiz:GetChildren() do
		if a:IsA("Attachment") then
			a.Position *= escalaCuerpo
		end
	end

	-- La cabeza se arma aparte, se agranda alrededor de su centro y se sube (chibi).
	local cabeza = Instance.new("Model")
	Piezas.Cabezas[c.Cabeza](ctx(c.Cabeza, cabeza))
	reubicar(cabeza:GetChildren(), donde, C.EscalaCabeza * C.Escala, function(pos)
		return (C.CentroCabeza + (pos - CENTRO_CABEZA) * C.EscalaCabeza) * C.Escala
	end)
	for _, p in cabeza:GetChildren() do
		p.Parent = modelo
	end
	cabeza:Destroy()

	-- Lo único que brilla es la gema del elemento (y el puntito de los ojos).
	local alto = 0
	for _, d in modelo:GetChildren() do
		if d:IsA("BasePart") and not SIN_PINTAR[d.Name] then
			if d.Material == Enum.Material.Neon then
				d.Material = Enum.Material.SmoothPlastic
			end
			if mutante then
				local h, s, v = d.Color:ToHSV()
				d.Color =
					Color3.fromHSV(h, math.min(1, s * 1.1 + 0.08), math.min(1, v * 1.1 + 0.15))
			end
			alto = math.max(alto, donde:ToObjectSpace(d.CFrame).Y + d.Size.Y / 2)
		end
	end

	-- Gema de Neon con el color del elemento, sobre el lomo y detrás de la cabeza.
	local gema = Instance.new("Part")
	gema.Name = "Gema"
	gema.Shape = Enum.PartType.Ball
	gema.Anchored = true
	gema.CanCollide = false
	gema.CanQuery = false
	gema.Material = Enum.Material.Neon
	gema.Color = Generador.colorElemento(c)
	gema.Size = Vector3.one * (if mutante then C.GemaMutante else C.Gema) * C.Escala
	gema.CFrame = donde
		* CFrame.new(Vector3.new(0, Piezas.AlturaLomo[c.Cuerpo], 0.6) * escalaCuerpo)
	gema.Parent = modelo

	anillo(modelo, donde, if mutante then Paleta.Mutante else Paleta.Generaciones[c.Gen])

	if c.Gen >= 3 then
		Piezas.aura(raiz)
	end
	if mutante then
		Piezas.estrellas(raiz)
		modelo:SetAttribute("Mutante", true)
	end
	if personalidad then
		icono(raiz, personalidad, alto)
		modelo:SetAttribute("Personalidad", personalidad)
	end

	modelo:SetAttribute("Clave", c.Clave)
	modelo:SetAttribute("Gen", c.Gen)
	modelo:SetAttribute("Rasgo", c.Rasgo)
	CollectionService:AddTag(modelo, "Criatura")

	modelo.Parent = padre
	return modelo
end

-- Deja el modelo como una silueta negra: sin colores, brillos, partículas ni carteles.
-- Conviene llamarla antes de ponerle Parent, así la animación guarda la versión negra.
function Generador.silueta(modelo: Model)
	for _, d in modelo:GetDescendants() do
		if
			d.Name == "Anillo"
			or d:IsA("ParticleEmitter")
			or d:IsA("Light")
			or d:IsA("LayerCollector")
		then
			d:Destroy()
		elseif d:IsA("BasePart") and d.Name ~= "Raiz" then
			d.Color = COLOR_SILUETA
			d.Material = Enum.Material.SmoothPlastic
			d.Transparency = 0
		end
	end
	modelo:SetAttribute("Rasgo", 0)
	modelo:SetAttribute("Mutante", nil)
end

return Generador
