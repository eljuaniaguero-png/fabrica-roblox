--!strict
-- Renacer (Grupo 4, prestigio). Dos pestañas:
--   Renacer: qué pide, cuánta Esencia da, los bonos de ahora y los de después, qué estrena el
--            próximo renacer y, bien claro, qué se reinicia y qué se conserva. Hay que tocar
--            dos veces para confirmar.
--   Árbol:   las ramas del árbol de Esencia (las que todavía no aparecen dicen desde qué
--            renacer) con su nivel, su costo y el botón para mejorarlas.
-- Solo pide (Remotos.Renacer / MejorarRama); el servidor revisa todo (server/Renacer.luau).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local RenacerRemoto = remotos:WaitForChild("Renacer") :: RemoteEvent
local MejorarRama = remotos:WaitForChild("MejorarRama") :: RemoteEvent

local R = GameConfig.Renacer

-- 1.1 -> "x1,1"
local function porcentaje(x: number): string
	return Formato.suerte(x)
end

local function ramas(): { [string]: number }
	local r = {}
	for id, n in Datos.json("Ramas") do
		if typeof(id) == "string" and typeof(n) == "number" then
			r[id] = n
		end
	end
	return r
end

-- Una columna con título y renglones (Se reinicia / Se conserva).
local function columna(titulo: string, color: { string }, lineas: { string }, ancho: number): Frame
	local f = Ventanas.panel(ancho, 320, { "#353B63", "#262B4F" })
	local t = Estilo.texto(titulo, 30)
	Estilo.degradado(t, color)
	t.Position = UDim2.fromOffset(18, 12)
	t.ZIndex = 3
	t.Parent = f
	local col = Instance.new("Frame")
	col.BackgroundTransparency = 1
	col.Position = UDim2.fromOffset(18, 58)
	col.Size = UDim2.fromOffset(ancho - 36, 250)
	col.ZIndex = 3
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = col
	for i, linea in lineas do
		local p = Estilo.parrafo("• " .. linea, 21, ancho - 40)
		p.LayoutOrder = i
		p.Parent = col
	end
	col.Parent = f
	return f
end

local function crear()
	local v = Ventanas.crear("Renacer", "Renacer", "Renacer", Estilo.Colores.Naranja, 1160, 690)
	local W, H = v.Ancho, v.Alto
	local area = Instance.new("Frame")
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 84)
	area.Size = UDim2.fromOffset(W, H - 84)
	area.Parent = v.Cuerpo
	local AH = H - 84
	local actual = "Renacer"
	local confirmar = false

	local function pestanaRenacer()
		local n = Datos.numero("Renacimientos")
		local zonas = Datos.zonas()
		local puede = Reglas.puedeRenacer(zonas, n)
		local zonaPide = Reglas.zona(Reglas.zonaParaRenacer(n))
		local esencia = Reglas.esenciaRenacer(zonas)

		local izq = Ventanas.panel(560, AH, { "#5A3A1A", "#2A1A2E" })
		izq.Parent = area
		Estilo.rayas(izq, 0.08)
		local col = Instance.new("Frame")
		col.BackgroundTransparency = 1
		col.Position = UDim2.fromOffset(20, 16)
		col.Size = UDim2.fromOffset(520, AH - 32)
		col.ZIndex = 3
		local l = Instance.new("UIListLayout")
		l.Padding = UDim.new(0, 10)
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Parent = col
		col.Parent = izq
		local function linea(orden: number, obj: GuiObject)
			obj.LayoutOrder = orden
			obj.Parent = col
		end

		local titulo = Estilo.texto(("Renacer %d  >  %d"):format(n, n + 1), 44)
		Estilo.degradado(titulo, { "#FFF3B0", "#FFD23F", "#FF6A3D" })
		linea(1, titulo)
		local pide = Estilo.conIconos(
			{ if puede then "Trofeo" else "Candado" },
			("Pide: abrir %s"):format(if zonaPide then zonaPide.Nombre else "?"),
			24,
			if puede then Estilo.Verde else Color3.fromHex("#FF8A94")
		)
		linea(2, pide)
		linea(
			3,
			Estilo.conIconos(
				{ "Esencia" },
				("Ganás %d de Esencia"):format(esencia),
				26,
				Color3.fromHex("#FFB04D")
			)
		)
		local bonoAhora = Reglas.bonos({ Renacimientos = n, Ramas = {}, MascotasEquipadas = {} })
		local bonoDespues =
			Reglas.bonos({ Renacimientos = n + 1, Ramas = {}, MascotasEquipadas = {} })
		linea(
			4,
			Estilo.parrafo(
				("Bonos para siempre: Monedas %s > %s · Fuerza %s > %s"):format(
					porcentaje(bonoAhora.Monedas),
					porcentaje(bonoDespues.Monedas),
					porcentaje(bonoAhora.Fuerza),
					porcentaje(bonoDespues.Fuerza)
				),
				21,
				520,
				Color3.fromHex("#C9F0FF")
			)
		)
		local estrena = R.Desbloqueos[n + 1]
		local cab = Estilo.texto("Lo que estrenás:", 26, Color3.fromHex("#FFE45C"))
		linea(5, cab)
		local lista: { string } = if estrena
			then estrena
			else { "Más Esencia y más bonos (hasta " .. R.MaximoBonos .. " renaceres)" }
		for i, t in lista do
			linea(5 + i, Estilo.parrafo("• " .. t, 21, 520))
		end
		local b, t = Estilo.boton({
			Texto = if puede then "¡Renacer!" else "Todavía no",
			Icono = "Renacer",
			Color = if puede then "Naranja" else "Gris",
			Ancho = 300,
			Alto = 76,
			TamanoTexto = 30,
		})
		linea(20, b)
		b.Activated:Connect(function()
			if not puede then
				return
			end
			if confirmar then
				confirmar = false
				RenacerRemoto:FireServer()
			else
				confirmar = true
				if t then
					t.Text = "¿Seguro? Tocá de nuevo"
					t.TextSize = 22
				end
				task.delay(4, function()
					if confirmar then
						confirmar = false
						if t and t.Parent then
							t.Text = "¡Renacer!"
							t.TextSize = 30
						end
					end
				end)
			end
		end)

		local der = Instance.new("Frame")
		der.BackgroundTransparency = 1
		der.Position = UDim2.fromOffset(580, 0)
		der.Size = UDim2.fromOffset(W - 580, AH)
		der.Parent = area
		local ancho = math.floor((W - 600) / 2)
		local reinicia = columna("Se reinicia", { "#FF8A94", "#D62839" }, R.Reinicia, ancho)
		reinicia.Parent = der
		local conserva = columna("Se conserva", { "#B8FF6A", "#2DBA2D" }, R.Conserva, ancho)
		conserva.Position = UDim2.fromOffset(ancho + 20, 0)
		conserva.Parent = der
		local nota = Estilo.parrafo(
			("Renaciste %d %s. Tenés %d de Esencia para el árbol."):format(
				n,
				if n == 1 then "vez" else "veces",
				Datos.numero("Esencia")
			),
			22,
			W - 600,
			Color3.fromHex("#FFE45C")
		)
		nota.Position = UDim2.fromOffset(0, 340)
		nota.Parent = der
	end

	local function pestanaArbol()
		local n = Datos.numero("Renacimientos")
		local niveles = ramas()
		local esencia = Datos.numero("Esencia")
		local cab = Estilo.conIconos(
			{ "Esencia" },
			("Esencia: %d"):format(esencia),
			32,
			Color3.fromHex("#FFB04D")
		)
		cab.Parent = area
		local lista = Ventanas.desplazable(W, AH - 56, Vector2.new(360, 230), 16)
		lista.Position = UDim2.fromOffset(0, 52)
		lista.Parent = area
		for i, r in R.Ramas do
			local visible = Reglas.ramaDisponible(r.Id, n)
			local nivel = niveles[r.Id] or 0
			local costo = Reglas.costoRama(r.Id, nivel)
			local f = Ventanas.panel(
				360,
				230,
				if visible then { "#5A3A1A", "#2A1A2E" } else { "#2A2F55", "#1E2240" }
			)
			f.LayoutOrder = i
			local nombre = Estilo.texto(r.Nombre, 28)
			Estilo.degradado(
				nombre,
				if visible then { "#FFF3B0", "#FFD23F" } else { "#8D939C", "#5E6577" }
			)
			nombre.Position = UDim2.fromOffset(16, 12)
			nombre.ZIndex = 3
			nombre.Parent = f
			local d = Estilo.parrafo(r.Descripcion, 20, 328, Color3.fromHex("#E3E8F2"))
			d.Position = UDim2.fromOffset(16, 52)
			d.ZIndex = 3
			d.Parent = f
			local barra, poner = Estilo.barra(328, 30, { "#FFB04D", "#E8590C" })
			barra.Position = UDim2.fromOffset(16, 112)
			barra.ZIndex = 3
			barra.Parent = f
			poner(nivel / #r.Costos, ("Nivel %d / %d"):format(nivel, #r.Costos))
			local abajo: GuiObject
			if not visible then
				abajo =
					Estilo.conIconos({ "Candado" }, ("Desde el renacer %d"):format(r.Renacer), 22)
			elseif not costo then
				abajo = Estilo.texto("¡AL MÁXIMO!", 26, Estilo.Verde)
			else
				local b = Estilo.boton({
					Texto = ("Mejorar (%d)"):format(costo),
					Icono = "Esencia",
					Color = if esencia >= costo then "Naranja" else "Gris",
					Ancho = 250,
					Alto = 58,
					TamanoTexto = 22,
				})
				b.Activated:Connect(function()
					MejorarRama:FireServer(r.Id)
				end)
				abajo = b
			end
			abajo.AnchorPoint = Vector2.new(0.5, 1)
			abajo.Position = UDim2.new(0.5, 0, 1, -14)
			abajo.ZIndex = 3
			abajo.Parent = f
			f.Parent = lista
		end
	end

	local function dibujar()
		Ventanas.vaciar(area)
		confirmar = false
		if actual == "Renacer" then
			pestanaRenacer()
		else
			pestanaArbol()
		end
	end

	local fila, elegir = Ventanas.pestanas(
		{
			{ Id = "Renacer", Texto = "Renacer", Icono = "Renacer", Color = "Naranja" },
			{ Id = "Arbol", Texto = "Árbol de Esencia", Icono = "Esencia", Color = "Amarillo" },
		},
		300,
		64,
		function(id: string)
			actual = id
			dibujar()
		end,
		24
	)
	fila.Parent = v.Cuerpo
	elegir("Renacer")

	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Renacimientos", "Esencia", "Ramas", "Zonas" }, function()
		if Ventanas.abierta() == "Renacer" then
			dibujar()
		end
	end)
end

return { crear = crear }
