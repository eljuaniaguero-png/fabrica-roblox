--!strict
-- Mochila y Banco: las gemas que juntaste (de la zona más alta a la más baja y de la más rara a
-- la más común), cuánto vale todo y el botón "¡Vender todo!". Vender lo hace el servidor
-- (Remotos.Vender, Economia.luau); acá solo se muestra.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local Vender = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Vender") :: RemoteEvent

local ORDEN_RAREZA: { [string]: number } = {}
for i, r in GameConfig.Rarezas do
	ORDEN_RAREZA[r.Id] = i
end

-- Tarjeta de una gema (también la usan el Índice y la Vitrina).
local function tarjeta(gema: GameConfig.Gema, abajo: string, tam: number, conocida: boolean): Frame
	local colores = Estilo.Rarezas[gema.Rareza] or Estilo.Rarezas.Comun
	local f = Estilo.baldosa(if conocida then colores else { colores[2], "#1B1F3B" }, tam)
	f.Name = gema.Id
	f.Size = UDim2.fromOffset(tam, math.floor(tam * 1.2))
	local nombre = Estilo.texto(if conocida then gema.Nombre else "???", math.floor(tam * 0.15))
	nombre.AnchorPoint = Vector2.new(0.5, 0)
	nombre.Position = UDim2.new(0.5, 0, 0, 6)
	nombre.ZIndex = 3
	nombre.Parent = f
	local g = Estilo.dibujoGema(gema, math.floor(tam * 0.62), conocida)
	g.AnchorPoint = Vector2.new(0.5, 0.5)
	g.Position = UDim2.fromScale(0.5, 0.52)
	g.ZIndex = 3
	g.Parent = f
	if abajo ~= "" then
		local t = Estilo.texto(abajo, math.floor(tam * 0.16))
		t.AnchorPoint = Vector2.new(0.5, 1)
		t.Position = UDim2.new(0.5, 0, 1, -6)
		t.ZIndex = 3
		t.Parent = f
	end
	return f
end

local function crear()
	local v = Ventanas.crear("Mochila", "Mochila", "Mochila", Estilo.Colores.Naranja, 1000, 660)
	local W, H = v.Ancho, v.Alto
	local lista = Ventanas.desplazable(W, H - 120, Vector2.new(138, 166), 12)
	lista.Parent = v.Cuerpo
	local vacia =
		Estilo.texto("Tu mochila está vacía. ¡Rompé geodas!", 34, Color3.fromHex("#C9D6EE"))
	vacia.AnchorPoint = Vector2.new(0.5, 0.5)
	vacia.Position = UDim2.fromOffset(W // 2, (H - 120) // 2)
	vacia.Parent = v.Cuerpo

	local pie = Ventanas.panel(W, 104, { "#5BD94A", "#1E8A2E" })
	pie.Position = UDim2.fromOffset(0, H - 104)
	pie.Parent = v.Cuerpo
	Estilo.rayas(pie, 0.12)
	local total = Estilo.conIconos({ "Moneda" }, "Total: 0", 44)
	total.AnchorPoint = Vector2.new(0, 0.5)
	total.Position = UDim2.new(0, 24, 0.5, 0)
	total.ZIndex = 3
	total.Parent = pie
	local textoTotal = total:FindFirstChildOfClass("TextLabel") :: TextLabel
	local vender = Estilo.boton({
		Texto = "¡Vender todo!",
		Icono = "Banco",
		Color = "Amarillo",
		Ancho = 330,
		Alto = 80,
	})
	vender.AnchorPoint = Vector2.new(1, 0.5)
	vender.Position = UDim2.new(1, -18, 0.5, 0)
	vender.ZIndex = 3
	vender.Parent = pie
	vender.Activated:Connect(function()
		Vender:FireServer()
	end)

	local function dibujar()
		Ventanas.vaciar(lista)
		local mochila = Datos.mochila()
		local ids = {}
		for id, n in mochila do
			if n > 0 and Reglas.gema(id) then
				table.insert(ids, id)
			end
		end
		table.sort(ids, function(a, b)
			local ga, gb = Reglas.gema(a) :: GameConfig.Gema, Reglas.gema(b) :: GameConfig.Gema
			if ga.Zona ~= gb.Zona then
				return ga.Zona > gb.Zona
			end
			return (ORDEN_RAREZA[ga.Rareza] or 0) > (ORDEN_RAREZA[gb.Rareza] or 0)
		end)
		for i, id in ids do
			local g = Reglas.gema(id) :: GameConfig.Gema
			local t = tarjeta(g, "x" .. Formato.corto(mochila[id]), 138, true)
			t.LayoutOrder = i
			t.Parent = lista
		end
		vacia.Visible = #ids == 0
		-- Grupo 4: con los bonos del Renacer, el árbol y las mascotas (lo mismo que paga el Banco)
		textoTotal.Text = "Total: "
			.. Formato.corto(math.floor(Reglas.valorMochila(mochila) * Datos.bonos().Monedas))
		Estilo.colorBoton(vender, if #ids > 0 then "Amarillo" else "Gris")
	end
	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Mochila" }, function()
		if Ventanas.abierta() == "Mochila" then
			dibujar()
		end
	end)
end

return { crear = crear, tarjeta = tarjeta }
