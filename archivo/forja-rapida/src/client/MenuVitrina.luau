--!strict
-- Mi Vitrina (Grupo 7): elegir el título que se ve arriba de tu cabeza (los que todavía no
-- tenés salen con candado y qué logro los da) y la gema de tu vitrina (cualquiera de tu
-- Índice). Solo pide (Remotos.ElegirTitulo / ElegirVitrina); el servidor revisa que los tengas.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local MenuMochila = require(script.Parent.MenuMochila)
local Ventanas = require(script.Parent.Ventanas)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local ElegirTitulo = remotos:WaitForChild("ElegirTitulo") :: RemoteEvent
local ElegirVitrina = remotos:WaitForChild("ElegirVitrina") :: RemoteEvent

local ORDEN_RAREZA: { [string]: number } = {}
for i, r in GameConfig.Rarezas do
	ORDEN_RAREZA[r.Id] = i
end

local function crear()
	local v = Ventanas.crear("Vitrina", "Mi Vitrina", "Corona", Estilo.Colores.Violeta, 1160, 690)
	local W, H = v.Ancho, v.Alto
	local ANCHO_T = 560

	local cabT = Estilo.texto("Títulos", 34)
	Estilo.degradado(cabT, { "#FFF3B0", "#FFC93C" })
	cabT.Parent = v.Cuerpo
	local titulos = Ventanas.desplazable(ANCHO_T, H - 50, nil, 8)
	titulos.Position = UDim2.fromOffset(0, 50)
	titulos.Parent = v.Cuerpo

	local cabG = Estilo.texto("Gema de la vitrina", 34)
	Estilo.degradado(cabG, { "#9CFBFF", "#6CCBFF" })
	cabG.Position = UDim2.fromOffset(ANCHO_T + 30, 0)
	cabG.Parent = v.Cuerpo
	local gemas = Ventanas.desplazable(W - ANCHO_T - 30, H - 50, Vector2.new(112, 134), 10)
	gemas.Position = UDim2.fromOffset(ANCHO_T + 30, 50)
	gemas.Parent = v.Cuerpo

	local function dibujar()
		Ventanas.vaciar(titulos)
		Ventanas.vaciar(gemas)
		local logros = Datos.conjunto("Logros")
		local usando = Datos.texto("Titulo")
		for i, t in GameConfig.Titulos do
			local tiene = Reglas.tituloDisponible(t.Id, logros)
			local esEste = t.Id == usando
			local f = Instance.new("Frame")
			f.Name = t.Id
			f.LayoutOrder = i
			f.Size = UDim2.fromOffset(ANCHO_T - 30, 84)
			Estilo.superficie(
				f,
				{ "Baldosa" },
				if esEste
					then { "#5BD94A", "#1E8A2E" }
					elseif tiene then { "#4A5080", "#353B63" }
					else { "#2A2F55", "#1E2240" },
				16,
				if esEste then 5 else 4,
				true
			)
			if esEste then
				Estilo.rayas(f, 0.14)
			end
			local nombre = Estilo.texto(t.Texto, 26)
			nombre.Position = UDim2.fromOffset(16, 6)
			nombre.ZIndex = 3
			nombre.Parent = f
			Estilo.degradado(nombre, if tiene then t.Colores else { "#8D939C", "#5E6577" })
			local logro = if t.Requiere then Reglas.logro(t.Requiere) else nil
			local sub = Estilo.texto(
				if logro then logro.Descripcion else "El primero de todos",
				18,
				Color3.fromHex(if tiene then "#E3E8F2" else "#9AA3B8"),
				2
			)
			sub.Position = UDim2.fromOffset(16, 50)
			sub.ZIndex = 3
			sub.Parent = f
			local derecha: GuiObject
			if esEste then
				derecha = Estilo.texto("USANDO", 24, Estilo.Verde)
			elseif tiene then
				local b = Estilo.boton({ Texto = "Usar", Color = "Azul", Ancho = 110, Alto = 50 })
				b.Activated:Connect(function()
					ElegirTitulo:FireServer(t.Id)
				end)
				derecha = b
			else
				derecha = Estilo.icono("Candado", 52)
			end
			derecha.AnchorPoint = Vector2.new(1, 0.5)
			derecha.Position = UDim2.new(1, -14, 0.5, 0)
			derecha.ZIndex = 3
			derecha.Parent = f
			f.Parent = titulos
		end

		local indice = {}
		for id in Datos.conjunto("Indice") do
			if Reglas.gema(id) then
				table.insert(indice, Reglas.gema(id) :: GameConfig.Gema)
			end
		end
		table.sort(indice, function(a, b)
			local ra, rb = ORDEN_RAREZA[a.Rareza] or 0, ORDEN_RAREZA[b.Rareza] or 0
			if ra ~= rb then
				return ra > rb
			end
			return a.Zona > b.Zona
		end)
		local elegida = Datos.texto("Vitrina")
		if #indice == 0 then
			local nada = Estilo.parrafo("Todavía no encontraste gemas. ¡Rompé geodas!", 24, 400)
			nada.Parent = gemas
		end
		for i, g in indice do
			local boton = Instance.new("TextButton")
			boton.Name = g.Id
			boton.Text = ""
			boton.BackgroundTransparency = 1
			boton.LayoutOrder = i
			local t = MenuMochila.tarjeta(g, if g.Id == elegida then "ELEGIDA" else "", 112, true)
			t.Size = UDim2.fromScale(1, 1)
			if g.Id == elegida then
				Estilo.marcar(t, true, 16)
			end
			t.Parent = boton
			Estilo.presionable(boton)
			boton.Activated:Connect(function()
				ElegirVitrina:FireServer(g.Id)
			end)
			boton.Parent = gemas
		end
	end
	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Titulo", "Vitrina", "Logros", "Indice" }, function()
		if Ventanas.abierta() == "Vitrina" then
			dibujar()
		end
	end)
end

return { crear = crear }
