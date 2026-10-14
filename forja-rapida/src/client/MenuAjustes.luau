--!strict
-- Ajustes: efectos reducidos, anunciar mis hallazgos, ver hallazgos de otros y ver títulos.
-- Cada interruptor pide el cambio al servidor (Remotos.Ajustes, Jugadores.luau), que lo guarda
-- y lo publica como atributo; el interruptor se pinta con lo que dice el atributo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Efectos = require(script.Parent.Efectos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local jugador = Players.LocalPlayer
local Ajustes = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Ajustes") :: RemoteEvent

type Opcion = { Atributo: string, Texto: string, Ayuda: string, PorDefecto: boolean }
local OPCIONES: { Opcion } = {
	{
		Atributo = "EfectosReducidos",
		Texto = "Efectos reducidos",
		Ayuda = "Sin destellos ni temblores y menos partículas (mejor en celulares)",
		PorDefecto = false,
	},
	{
		Atributo = "AnunciarHallazgos",
		Texto = "Anunciar mis hallazgos",
		Ayuda = "Los demás ven un cartel cuando encontrás algo rarísimo",
		PorDefecto = true,
	},
	{
		Atributo = "VerAnuncios",
		Texto = "Ver hallazgos de otros",
		Ayuda = "Los carteles de eventos y jefes se ven siempre",
		PorDefecto = true,
	},
	{
		Atributo = "VerTitulos",
		Texto = "Ver títulos",
		Ayuda = "Los títulos arriba de la cabeza de cada jugador",
		PorDefecto = true,
	},
}

local function valor(o: Opcion): boolean
	if o.Atributo == "EfectosReducidos" then
		return Efectos.reducidos()
	end
	local v = jugador:GetAttribute(o.Atributo)
	return if typeof(v) == "boolean" then v else o.PorDefecto
end

local function crear()
	local v = Ventanas.crear("Ajustes", "Ajustes", "Engranaje", Estilo.Colores.Azul, 820, 600)
	local lista = Instance.new("Frame")
	lista.BackgroundTransparency = 1
	lista.Size = UDim2.fromScale(1, 1)
	local orden = Instance.new("UIListLayout")
	orden.Padding = UDim.new(0, 12)
	orden.SortOrder = Enum.SortOrder.LayoutOrder
	orden.Parent = lista
	lista.Parent = v.Cuerpo

	local refrescos: { () -> () } = {}
	for i, o in OPCIONES do
		local fila = Instance.new("TextButton")
		fila.Name = o.Atributo
		fila.Text = ""
		fila.AutoButtonColor = false
		fila.LayoutOrder = i
		fila.Size = UDim2.fromOffset(v.Ancho, 98)
		Estilo.superficie(fila, { "Baldosa" }, { "#3A3F66", "#2A2F55" }, 18, 4, true)
		local t = Estilo.texto(o.Texto, 30)
		t.Position = UDim2.fromOffset(18, 12)
		t.ZIndex = 3
		t.Parent = fila
		local ayuda = Estilo.parrafo(o.Ayuda, 18, v.Ancho - 200, Color3.fromHex("#C9D6EE"))
		ayuda.Position = UDim2.fromOffset(18, 56)
		ayuda.ZIndex = 3
		ayuda.Parent = fila
		-- interruptor
		local llave = Instance.new("Frame")
		llave.Name = "Interruptor"
		llave.AnchorPoint = Vector2.new(1, 0.5)
		llave.Position = UDim2.new(1, -18, 0.5, 0)
		llave.Size = UDim2.fromOffset(120, 54)
		llave.ZIndex = 3
		llave.BackgroundColor3 = Color3.new(1, 1, 1)
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(1, 0)
		esquina.Parent = llave
		Estilo.borde(llave, 4)
		local fondo = Instance.new("UIGradient")
		fondo.Rotation = 90
		fondo.Parent = llave
		local bolita = Instance.new("Frame")
		bolita.AnchorPoint = Vector2.new(0.5, 0.5)
		bolita.Size = UDim2.fromOffset(42, 42)
		bolita.BackgroundColor3 = Color3.new(1, 1, 1)
		bolita.ZIndex = 4
		local redonda = esquina:Clone()
		redonda.Parent = bolita
		Estilo.borde(bolita, 3)
		bolita.Parent = llave
		local estado = Estilo.texto("", 20, nil, 2)
		estado.AnchorPoint = Vector2.new(0.5, 0.5)
		estado.ZIndex = 4
		estado.Parent = llave
		llave.Parent = fila
		local function refrescar()
			local si = valor(o)
			estado.Text = if si then "SÍ" else "NO"
			estado.Position = UDim2.fromScale(if si then 0.32 else 0.68, 0.5)
			fondo.Color = if si
				then ColorSequence.new(Color3.fromHex("#8CFF5A"), Color3.fromHex("#1FA33A"))
				else ColorSequence.new(Color3.fromHex("#D5DAE1"), Color3.fromHex("#8D939C"))
			TweenService:Create(bolita, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Position = UDim2.fromScale(if si then 0.77 else 0.23, 0.5),
			}):Play()
		end
		refrescar()
		table.insert(refrescos, refrescar)
		jugador:GetAttributeChangedSignal(o.Atributo):Connect(refrescar)
		Estilo.presionable(fila)
		fila.Activated:Connect(function()
			Ajustes:FireServer(o.Atributo, not valor(o))
		end)
		fila.Parent = lista
	end
	table.insert(v.alAbrir, function()
		for _, r in refrescos do
			r()
		end
	end)
end

return { crear = crear }
