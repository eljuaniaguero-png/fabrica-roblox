--!strict
-- Museo de minerales (Grupo 3; reemplaza al Índice). Cuatro pestañas:
--   Minerales       por bioma: las 5 gemas y sus secretas. Las que no encontraste salen "???".
--                   Al tocar una: rareza, bioma de origen, cuántas encontraste y la primera vez.
--   Colecciones     fáciles a legendarias, con su barra, su premio (títulos, auras, diseños de
--                   pico, vitrinas, decoraciones) y si están completas.
--   Cosméticos      lo que ganaste y lo que falta; se usa con Remotos.Equipar.
--   Probabilidades  la tabla con tu suerte de ahora en cada bioma (suma 100 %, GUIA sección 6).
-- Todo sale de los atributos del jugador (Datos) y de GameConfig; el servidor decide.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local MenuMochila = require(script.Parent.MenuMochila)
local Ventanas = require(script.Parent.Ventanas)

local estado = ReplicatedStorage:WaitForChild("EstadoMundo")
local Equipar = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Equipar") :: RemoteEvent

type Gema = GameConfig.Gema
type Logro = GameConfig.Logro

local DIFICULTAD: { [string]: { Texto: string, Color: string } } = {
	Facil = { Texto = "Fácil", Color = "Verde" },
	Media = { Texto = "Media", Color = "Azul" },
	Dificil = { Texto = "Difícil", Color = "Violeta" },
	Leyenda = { Texto = "Leyenda", Color = "Amarillo" },
}
local TIPOS = {
	{ Id = "Aura", Nombre = "Auras", Icono = "Chispa" },
	{ Id = "Pico", Nombre = "Diseños de pico", Icono = "Pico" },
	{ Id = "Vitrina", Nombre = "Vitrinas", Icono = "Corona" },
	{ Id = "Decoracion", Nombre = "Decoraciones", Icono = "Cristal" },
}
local ATRIBUTO_EQUIPADO =
	{ Aura = "Aura", Pico = "DisenoPico", Vitrina = "EstiloVitrina", Decoracion = "Decoracion" }

local function porcentaje(p: number): string
	local x = p * 100
	local texto = if x >= 10
		then ("%.1f"):format(x)
		elseif x >= 0.01 then ("%.2f"):format(x)
		else ("%.4f"):format(x)
	return (texto:gsub("%.", ",")) .. " %"
end

local function fecha(t: number): string
	if t <= 0 then
		return "antes del Museo"
	end
	local f = os.date("*t", t) :: any
	return ("%02d/%02d/%d"):format(f.day, f.month, f.year)
end

-- Lo que hace falta para las barras de las colecciones.
local function estadoLogros(): Reglas.EstadoLogros
	return {
		Indice = Datos.conjunto("Indice"),
		Exoticas = Datos.conjunto("Exoticas"),
		Rarezas = Datos.conjunto("Rarezas"),
		GeodasRotas = Datos.numero("GeodasRotas"),
		JefesDerrotados = Datos.numero("JefesDerrotados"),
		EventosJugados = Datos.numero("EventosJugados"),
		Logros = Datos.conjunto("Logros"),
	}
end

-- gema -> { cantidad, primera vez }
local function museo(): { [string]: { number } }
	local texto = Datos.texto("Museo")
	if texto == "" then
		return {}
	end
	local ok, t = pcall(HttpService.JSONDecode, HttpService, texto)
	return if ok and typeof(t) == "table" then t :: any else {}
end

local function gemasDeZona(zona: number): { Gema }
	local lista = {}
	for _, r in GameConfig.Rarezas do
		local g = Reglas.gemaDe(zona, r.Id)
		if g then
			table.insert(lista, g)
		end
	end
	for _, g in GameConfig.Gemas do
		if g.Secreta and g.Zona == zona then
			table.insert(lista, g)
		end
	end
	return lista
end

local function premioTexto(l: Logro): string
	local partes = {}
	for _, t in GameConfig.Titulos do
		if t.Requiere == l.Id then
			table.insert(partes, "Título «" .. t.Texto .. "»")
		end
	end
	local c = l.Premio.Cosmetico
	local datos = c and Reglas.cosmetico(c.Tipo, c.Id)
	if datos then
		table.insert(partes, datos.Nombre)
	end
	if l.Premio.Monedas then
		table.insert(partes, Formato.corto(l.Premio.Monedas) .. " Monedas")
	end
	if l.Premio.Suerte then
		table.insert(partes, "+" .. Formato.suerte(l.Premio.Suerte):sub(2) .. " Suerte")
	end
	return table.concat(partes, " · ")
end

local function texto(
	padre: GuiObject,
	s: string,
	tam: number,
	x: number,
	y: number,
	color: Color3?
): TextLabel
	local t = Estilo.texto(s, tam, color)
	t.Position = UDim2.fromOffset(x, y)
	t.ZIndex = 3
	t.Parent = padre
	return t
end

local function crear()
	local v = Ventanas.crear("Museo", "Museo de Minerales", "Libro", Estilo.Colores.Rosa, 1180, 700)
	local W, H = v.Ancho, v.Alto
	local area = Instance.new("Frame")
	area.Name = "Area"
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 76)
	area.Size = UDim2.fromOffset(W, H - 76)
	area.Parent = v.Cuerpo
	local AH = H - 76
	local pestana = "Minerales"
	local zona = 1
	local elegida: string? = nil

	-- Minerales ------------------------------------------------------------------------------
	local function minerales()
		local indice = Datos.conjunto("Indice")
		local fichas = museo()
		local abiertas = Datos.zonas()
		-- biomas
		for i, z in GameConfig.Zonas do
			local b = Estilo.boton({
				Texto = z.Nombre:match("^(%S+)") or z.Nombre,
				Icono = if abiertas[z.Numero] then nil else "Candado",
				Color = if z.Numero == zona then "Rosa" else "Gris",
				Ancho = 210,
				Alto = 64,
				TamanoTexto = 26,
			})
			b.Position = UDim2.fromOffset(0, (i - 1) * 74)
			b.Activated:Connect(function()
				zona = z.Numero
				elegida = nil
				Ventanas.vaciar(area)
				minerales()
			end)
			b.Parent = area
		end
		local total, tiene = #GameConfig.Gemas, 0
		for id in indice do
			if Reglas.gema(id) then
				tiene += 1
			end
		end
		local barra, poner = Estilo.barra(210, 44, { "#FF9ED8", "#E0308F" })
		barra.Position = UDim2.fromOffset(0, AH - 48)
		barra.Parent = area
		poner(tiene / total, ("%d / %d"):format(tiene, total))
		texto(area, "Tu museo", 22, 0, AH - 82)

		-- grilla del bioma
		local z = GameConfig.Zonas[zona]
		local panel = Ventanas.panel(520, AH)
		panel.Position = UDim2.fromOffset(226, 0)
		panel.Parent = area
		texto(panel, z.Nombre, 32, 16, 10, Color3.fromHex(z.ColorCristal))
		local grilla = Ventanas.desplazable(500, AH - 64, Vector2.new(112, 134), 10)
		grilla.Position = UDim2.fromOffset(10, 56)
		grilla.ZIndex = 3
		grilla.Parent = panel
		local lista = gemasDeZona(zona)
		if not elegida then
			elegida = lista[1] and lista[1].Id
		end
		for i, g in lista do
			local conocida = indice[g.Id] == true
			local ficha = fichas[g.Id]
			local abajo = if conocida and ficha
				then "x" .. Formato.corto(ficha[1])
				elseif g.Secreta then "Secreta"
				else ""
			local boton = Instance.new("TextButton")
			boton.Name = g.Id
			boton.Text = ""
			boton.BackgroundTransparency = 1
			boton.LayoutOrder = i
			local t = MenuMochila.tarjeta(g, abajo, 112, conocida)
			t.Size = UDim2.fromScale(1, 1)
			if g.Secreta then
				Estilo.rayas(t, 0.12)
			end
			Estilo.marcar(t, g.Id == elegida, 16)
			t.Parent = boton
			Estilo.presionable(boton)
			boton.Activated:Connect(function()
				elegida = g.Id
				Ventanas.vaciar(area)
				minerales()
			end)
			boton.Parent = grilla
		end

		-- ficha del mineral elegido
		local det = Ventanas.panel(W - 762, AH, { "#4A5080", "#2A2F55" })
		det.Position = UDim2.fromOffset(762, 0)
		det.Parent = area
		local g = elegida and Reglas.gema(elegida)
		if not g then
			return
		end
		local conocida = indice[g.Id] == true
		local ficha = fichas[g.Id]
		local DW = W - 762
		local dibujo = Estilo.gema(if conocida then g.Color else "#0E1230", 150)
		dibujo.AnchorPoint = Vector2.new(0.5, 0)
		dibujo.Position = UDim2.new(0.5, 0, 0, 14)
		dibujo.ZIndex = 3
		dibujo.Parent = det
		local col = Instance.new("Frame")
		col.BackgroundTransparency = 1
		col.Position = UDim2.fromOffset(16, 176)
		col.Size = UDim2.fromOffset(DW - 32, AH - 190)
		col.ZIndex = 3
		local l = Instance.new("UIListLayout")
		l.Padding = UDim.new(0, 8)
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Parent = col
		col.Parent = det
		local function linea(orden: number, s: string, tam: number, color: Color3?): TextLabel
			local t = Estilo.parrafo(s, tam, DW - 40, color)
			t.TextXAlignment = Enum.TextXAlignment.Center
			t.LayoutOrder = orden
			t.Parent = col
			return t
		end
		local r = Reglas.rareza(g.Rareza)
		local lugar = g.Lugar or GameConfig.Zonas[g.Zona].Nombre
		if conocida then
			linea(1, g.Nombre, 38)
			local rz = linea(
				2,
				(r and r.Nombre or g.Rareza) .. (if g.Secreta then " · Secreta" else ""),
				28
			)
			Estilo.degradado(rz, Estilo.Rarezas[g.Rareza] or { "#FFFFFF" })
			linea(3, "Bioma: " .. lugar, 22, Color3.fromHex("#C9D6EE"))
			linea(4, "Encontradas: " .. Formato.miles(ficha and ficha[1] or 0), 24, Estilo.Verde)
			linea(
				5,
				"Primera vez: " .. fecha(ficha and ficha[2] or 0),
				22,
				Color3.fromHex("#FFE45C")
			)
			linea(6, "Vale " .. Formato.corto(Reglas.valorGema(g.Id)) .. " Monedas c/u", 20)
		else
			linea(1, "???", 40)
			linea(2, r and r.Nombre or g.Rareza, 26)
			linea(
				3,
				if g.Secreta
					then (if g.Lugar
						then "Se esconde en la " .. g.Lugar
						else "Se esconde en la veta oculta de " .. lugar)
					else "Sale rompiendo geodas en " .. lugar,
				22,
				Color3.fromHex("#C9D6EE")
			)
			linea(4, "Todavía no la encontraste", 22, Color3.fromHex("#9AA3B8"))
		end
	end

	-- Colecciones ----------------------------------------------------------------------------
	local function colecciones()
		local e = estadoLogros()
		local lista = Reglas.coleccionesMuseo()
		local completas = 0
		for _, l in lista do
			if e.Logros[l.Id] then
				completas += 1
			end
		end
		texto(area, ("Colecciones completas: %d / %d"):format(completas, #lista), 26, 0, 0)
		local scroll = Ventanas.desplazable(W, AH - 44, nil, 10)
		scroll.Position = UDim2.fromOffset(0, 44)
		scroll.Parent = area
		local RW = W - 30
		for i, l in lista do
			local hecha = e.Logros[l.Id] == true
			local tiene, total = Reglas.progreso(l, e)
			local f = Instance.new("Frame")
			f.Name = l.Id
			f.LayoutOrder = i
			f.Size = UDim2.fromOffset(RW, 104)
			Estilo.superficie(
				f,
				{ "Baldosa" },
				if hecha then { "#5BD94A", "#1E8A2E" } else { "#3A3F66", "#2A2F55" },
				18,
				4,
				true
			)
			local d = DIFICULTAD[l.Dificultad or "Media"] or DIFICULTAD.Media
			local chip = Estilo.boton({
				Texto = d.Texto,
				Color = d.Color,
				Ancho = 120,
				Alto = 42,
				TamanoTexto = 20,
			})
			chip.Active = false
			chip.Position = UDim2.fromOffset(14, 12)
			chip.ZIndex = 3
			chip.Parent = f
			texto(f, l.Nombre, 28, 148, 8)
			local desc = Estilo.parrafo(l.Descripcion, 18, 420, Color3.fromHex("#E3E8F2"))
			desc.Position = UDim2.fromOffset(148, 48)
			desc.ZIndex = 3
			desc.Parent = f
			local barra, poner = Estilo.barra(
				260,
				34,
				if hecha then { "#FFF15C", "#F5A300" } else { "#B8FF6A", "#1FA33A" }
			)
			barra.Position = UDim2.fromOffset(590, 12)
			barra.ZIndex = 3
			barra.Parent = f
			poner(
				tiene / math.max(1, total),
				("%s / %s"):format(Formato.corto(tiene), Formato.corto(total))
			)
			local premio = Estilo.parrafo(
				"Premio: " .. premioTexto(l),
				16,
				RW - 600,
				Color3.fromHex("#FFE45C")
			)
			premio.Position = UDim2.fromOffset(590, 54)
			premio.ZIndex = 3
			premio.Parent = f
			if hecha then
				local ok = Estilo.texto("¡COMPLETA!", 24, Color3.fromHex("#FFFFFF"))
				ok.AnchorPoint = Vector2.new(1, 0)
				ok.Position = UDim2.new(1, -16, 0, 14)
				ok.ZIndex = 3
				ok.Parent = f
			end
			f.Parent = scroll
		end
	end

	-- Cosméticos -----------------------------------------------------------------------------
	local function cosmeticos()
		local logros = Datos.conjunto("Logros")
		local scroll = Ventanas.desplazable(W, AH, nil, 12)
		scroll.Parent = area
		for i, tipo in TIPOS do
			local seccion = Instance.new("Frame")
			seccion.LayoutOrder = i
			seccion.BackgroundTransparency = 1
			seccion.Size = UDim2.fromOffset(W - 30, 226)
			local cab = Estilo.conIconos({ tipo.Icono }, tipo.Nombre, 28)
			cab.Parent = seccion
			local fila = Estilo.fila(12)
			fila.Position = UDim2.fromOffset(0, 46)
			fila.Parent = seccion
			local usando = Datos.texto(ATRIBUTO_EQUIPADO[tipo.Id])
			for j, c in Reglas.tiposCosmeticos()[tipo.Id] do
				local tiene = Reglas.tieneCosmetico(tipo.Id, c.Id, logros)
				local esEste = usando == c.Id
				local carta = Estilo.baldosa(
					if esEste
						then { "#5BD94A", "#1E8A2E" }
						elseif tiene then { "#4A5080", "#353B63" }
						else { "#2A2F55", "#1E2240" },
					170
				)
				carta.LayoutOrder = j
				carta.Size = UDim2.fromOffset(170, 176)
				local colc = Estilo.contenido(carta, 4, true)
				local ic = Estilo.icono(if tiene then tipo.Icono else "Candado", 54)
				ic.LayoutOrder = 1
				ic.Parent = colc
				local muestras = Estilo.fila(4)
				muestras.LayoutOrder = 2
				for k, hex in c.Colores do
					local m = Instance.new("Frame")
					m.LayoutOrder = k
					m.Size = UDim2.fromOffset(16, 16)
					m.BackgroundColor3 = Color3.fromHex(hex)
					Estilo.esquinas(m, 8)
					Estilo.borde(m, 2)
					m.Parent = muestras
				end
				muestras.Parent = colc
				local nombre = Estilo.parrafo(c.Nombre, 18, 156)
				nombre.TextXAlignment = Enum.TextXAlignment.Center
				nombre.LayoutOrder = 3
				nombre.Parent = colc
				if tiene then
					local quitable = tipo.Id == "Aura" or tipo.Id == "Decoracion"
					local b = Estilo.boton({
						Texto = if esEste then (if quitable then "Sacar" else "Usando") else "Usar",
						Color = if esEste then "Gris" else "Azul",
						Ancho = 130,
						Alto = 40,
						TamanoTexto = 20,
					})
					b.LayoutOrder = 4
					b.Activated:Connect(function()
						if esEste and quitable then
							Equipar:FireServer(tipo.Id, "")
						elseif not esEste then
							Equipar:FireServer(tipo.Id, c.Id)
						end
					end)
					b.Parent = colc
				else
					local l = Reglas.logroDeCosmetico(tipo.Id, c.Id)
					local como = Estilo.parrafo(
						"Colección: " .. (if l then l.Nombre else "?"),
						14,
						156,
						Color3.fromHex("#9AA3B8")
					)
					como.TextXAlignment = Enum.TextXAlignment.Center
					como.LayoutOrder = 4
					como.Parent = colc
				end
				carta.Parent = fila
			end
			seccion.Parent = scroll
		end
	end

	-- Probabilidades -------------------------------------------------------------------------
	local function probabilidades()
		for i, z in GameConfig.Zonas do
			local b = Estilo.boton({
				Texto = z.Nombre:match("^(%S+)") or z.Nombre,
				Color = if z.Numero == zona then "Rosa" else "Gris",
				Ancho = 200,
				Alto = 54,
				TamanoTexto = 22,
			})
			b.Position = UDim2.fromOffset((i - 1) * 212, 0)
			b.Activated:Connect(function()
				zona = z.Numero
				Ventanas.vaciar(area)
				probabilidades()
			end)
			b.Parent = area
		end
		local z = GameConfig.Zonas[zona]
		local panel = Ventanas.panel(W, AH - 70)
		panel.Position = UDim2.fromOffset(0, 70)
		panel.Parent = area
		local mia = math.max(1, Datos.numero("Suerte"))
		local ev = Reglas.evento(tostring(estado:GetAttribute("Evento") or ""))
		local extra = if ev and ev.Suerte then ev.Suerte else 1
		local bendicion = if Workspace:GetServerTimeNow() < Datos.numero("BendicionFin")
			then GameConfig.Secretos.Altar.Suerte
			else 1
		local suerte = mia * z.Suerte * extra * bendicion
		local cuenta = ("Tu suerte %s x %s %s"):format(
			Formato.suerte(mia),
			z.Nombre,
			Formato.suerte(z.Suerte)
		)
		if extra ~= 1 and ev then
			cuenta ..= (" x %s %s"):format(ev.Nombre, Formato.suerte(extra))
		end
		if bendicion ~= 1 then
			cuenta ..= (" x bendición %s"):format(Formato.suerte(bendicion))
		end
		local cab = Estilo.conIconos({ "Trebol" }, cuenta .. " = " .. Formato.suerte(suerte), 24)
		cab.Position = UDim2.fromOffset(18, 14)
		cab.ZIndex = 3
		cab.Parent = panel
		local p = Reglas.probabilidades(GameConfig.Rarezas, suerte)
		for i = #GameConfig.Rarezas, 1, -1 do
			local r = GameConfig.Rarezas[i]
			local y = 70 + (#GameConfig.Rarezas - i) * 56
			local g = Reglas.gemaDe(zona, r.Id)
			local nombre =
				texto(panel, r.Nombre .. (if g then " · " .. g.Nombre else ""), 28, 24, y)
			Estilo.degradado(nombre, Estilo.Rarezas[r.Id] or { "#FFFFFF" })
			local valor = Estilo.texto(
				porcentaje(p[r.Id]) .. "    " .. Formato.unoEn(1 / math.max(1e-12, p[r.Id])),
				26,
				Estilo.Verde
			)
			valor.AnchorPoint = Vector2.new(1, 0)
			valor.Position = UDim2.new(1, -24, 0, y + 2)
			valor.ZIndex = 3
			valor.Parent = panel
		end
		local nota = Estilo.parrafo(
			"Suman 100 %. Las geodas grandes, el Jefe, los eventos y el altar dan más suerte. Los minerales secretos salen solo en las vetas ocultas.",
			18,
			W - 48,
			Color3.fromHex("#9AA3B8")
		)
		nota.Position = UDim2.fromOffset(24, AH - 70 - 60)
		nota.ZIndex = 3
		nota.Parent = panel
	end

	local DIBUJAR: { [string]: () -> () } = {
		Minerales = minerales,
		Colecciones = colecciones,
		Cosmeticos = cosmeticos,
		Probabilidades = probabilidades,
	}
	local function dibujar()
		Ventanas.vaciar(area)
		DIBUJAR[pestana]()
	end
	local pestanas, elegir = Ventanas.pestanas(
		{
			{ Id = "Minerales", Texto = "Minerales", Icono = "Gema", Color = "Rosa" },
			{ Id = "Colecciones", Texto = "Colecciones", Icono = "Trofeo", Color = "Amarillo" },
			{ Id = "Cosmeticos", Texto = "Cosméticos", Icono = "Chispa", Color = "Violeta" },
			{ Id = "Probabilidades", Texto = "Probabilidades", Icono = "Trebol", Color = "Verde" },
		},
		math.floor((W - 30) / 4),
		60,
		function(id: string)
			pestana = id
			dibujar()
		end,
		22
	)
	pestanas.Parent = v.Cuerpo
	elegir("Minerales")
	table.insert(v.alAbrir, function()
		zona = Reglas.mejorZona(Datos.zonas())
		elegida = nil
		dibujar()
	end)
	Datos.alCambiar({
		"Indice",
		"Museo",
		"Logros",
		"Suerte",
		"Zonas",
		"Aura",
		"DisenoPico",
		"EstiloVitrina",
		"Decoracion",
	}, function()
		if Ventanas.abierta() == "Museo" then
			dibujar()
		end
	end)
end

return { crear = crear }
