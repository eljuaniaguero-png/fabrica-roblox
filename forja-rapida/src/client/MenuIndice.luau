--!strict
-- Índice: las 5 gemas de cada zona (las que todavía no encontraste salen "???"), las exóticas
-- que rompiste y la tabla de probabilidades con TU suerte de ahora (amuletos, logros, zona y
-- evento). Las probabilidades salen de Reglas.probabilidades, igual que en el servidor, y
-- siempre suman 100 % (GUIA, sección 6).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local MenuMochila = require(script.Parent.MenuMochila)
local Ventanas = require(script.Parent.Ventanas)

local estado = ReplicatedStorage:WaitForChild("EstadoMundo")

local function porcentaje(p: number): string
	local x = p * 100
	local texto = if x >= 10
		then ("%.1f"):format(x)
		elseif x >= 0.01 then ("%.2f"):format(x)
		else ("%.4f"):format(x)
	return (texto:gsub("%.", ",")) .. " %"
end

local function crear()
	local v = Ventanas.crear("Indice", "Índice", "Libro", Estilo.Colores.Rosa, 1160, 690)
	local W, H = v.Ancho, v.Alto
	local area = Instance.new("Frame")
	area.Name = "Area"
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 80)
	area.Size = UDim2.fromOffset(W, H - 80)
	area.Parent = v.Cuerpo
	local zona = 1

	local function dibujar()
		Ventanas.vaciar(area)
		local z = GameConfig.Zonas[zona]
		local indice = Datos.conjunto("Indice")
		local abiertas = Datos.zonas()
		local AH = H - 80

		-- Izquierda: gemas de la zona y exóticas
		local izq = Ventanas.panel(640, AH)
		izq.Parent = area
		local titulo = Estilo.texto(z.Nombre, 38, Color3.fromHex(z.ColorCristal))
		titulo.Position = UDim2.fromOffset(20, 12)
		titulo.ZIndex = 3
		titulo.Parent = izq
		if not abiertas[zona] then
			local cerrada = Estilo.conIconos(
				{ "Candado" },
				("Se abre con %s de Fuerza"):format(Formato.corto(z.FuerzaParaAbrir)),
				22
			)
			cerrada.AnchorPoint = Vector2.new(1, 0)
			cerrada.Position = UDim2.new(1, -18, 0, 20)
			cerrada.ZIndex = 3
			cerrada.Parent = izq
		end
		local fila = Estilo.fila(10)
		fila.Position = UDim2.fromOffset(20, 66)
		fila.ZIndex = 3
		fila.Parent = izq
		local tiene = 0
		for i, r in GameConfig.Rarezas do
			local g = Reglas.gemaDe(zona, r.Id)
			if g then
				local conocida = indice[g.Id] == true
				if conocida then
					tiene += 1
				end
				local t = MenuMochila.tarjeta(
					g,
					Formato.corto(Reglas.valorGema(g.Id)) .. " c/u",
					110,
					conocida
				)
				t.LayoutOrder = i
				t.Parent = fila
			end
		end
		local barra, poner = Estilo.barra(440, 44, { "#B8FF6A", "#1FA33A" })
		barra.Position = UDim2.fromOffset(20, 216)
		barra.ZIndex = 3
		barra.Parent = izq
		poner(tiene / 5, ("%d / 5"):format(tiene))
		for _, l in GameConfig.Logros do
			if l.Necesita.Tipo == "Gemas" and l.Necesita.Zona == zona then
				local premio = {}
				if l.Premio.Monedas then
					table.insert(premio, "+" .. Formato.corto(l.Premio.Monedas) .. " Monedas")
				end
				if l.Premio.Suerte then
					table.insert(premio, "+" .. Formato.suerte(l.Premio.Suerte):sub(2) .. " Suerte")
				end
				local p = Estilo.conIconos(
					{ "Trofeo" },
					"Completala: " .. table.concat(premio, " y "),
					20,
					if tiene == 5 then Estilo.Verde else nil
				)
				p.Position = UDim2.fromOffset(20, 272)
				p.ZIndex = 3
				p.Parent = izq
			end
		end
		local ex = Estilo.texto("Exóticas que rompiste", 26)
		ex.Position = UDim2.fromOffset(20, 316)
		ex.ZIndex = 3
		ex.Parent = izq
		local exoticas = Datos.conjunto("Exoticas")
		local filaEx = Estilo.fila(8)
		filaEx.Position = UDim2.fromOffset(20, 354)
		filaEx.ZIndex = 3
		filaEx.Parent = izq
		local orden = 0
		for _, m in GameConfig.Modificadores do
			if m.Id ~= "Normal" then
				orden += 1
				local caja = Estilo.baldosa(
					if exoticas[m.Id] then { "#FFFFFF", m.Color } else { "#3A3F66", "#1B1F3B" },
					62
				)
				caja.LayoutOrder = orden
				local partes = Reglas.partes(m.Id)
				local c = Estilo.contenido(caja, -6)
				for k, parte in partes do
					local ic = Estilo.icono(
						if exoticas[m.Id] then parte else "Candado",
						if #partes > 1 then 30 else 42
					)
					ic.LayoutOrder = k
					ic.Parent = c
				end
				caja.Parent = filaEx
			end
		end

		-- Derecha: probabilidades con tu suerte
		local der = Ventanas.panel(W - 660, AH)
		der.Position = UDim2.fromOffset(660, 0)
		der.Parent = area
		local mia = math.max(1, Datos.numero("Suerte"))
		local suerte = mia * z.Suerte
		local ev = Reglas.evento(tostring(estado:GetAttribute("Evento") or ""))
		local extra = if ev and ev.Suerte then ev.Suerte else 1
		suerte *= extra
		local cab = Estilo.conIconos({ "Trebol" }, "Probabilidades", 32)
		cab.Position = UDim2.fromOffset(18, 12)
		cab.ZIndex = 3
		cab.Parent = der
		local cuenta = ("Tu suerte %s x zona %s"):format(
			Formato.suerte(mia),
			Formato.suerte(z.Suerte)
		)
		if extra ~= 1 and ev then
			cuenta ..= (" x %s %s"):format(ev.Nombre, Formato.suerte(extra))
		end
		local explica = Estilo.parrafo(
			cuenta .. " = " .. Formato.suerte(suerte),
			20,
			W - 700,
			Color3.fromHex("#C9D6EE")
		)
		explica.Position = UDim2.fromOffset(18, 58)
		explica.ZIndex = 3
		explica.Parent = der
		local p = Reglas.probabilidades(GameConfig.Rarezas, suerte)
		for i = #GameConfig.Rarezas, 1, -1 do
			local r = GameConfig.Rarezas[i]
			local y = 112 + (#GameConfig.Rarezas - i) * 52
			local nombre = Estilo.texto(r.Nombre, 30)
			nombre.Position = UDim2.fromOffset(18, y)
			nombre.ZIndex = 3
			nombre.Parent = der
			Estilo.degradado(nombre, Estilo.Rarezas[r.Id] or { "#FFFFFF" })
			local valor = Estilo.texto(
				porcentaje(p[r.Id]) .. "   " .. Formato.unoEn(1 / math.max(1e-12, p[r.Id])),
				24,
				Estilo.Verde
			)
			valor.AnchorPoint = Vector2.new(1, 0)
			valor.Position = UDim2.new(1, -18, 0, y + 4)
			valor.ZIndex = 3
			valor.Parent = der
		end
		local nota = Estilo.parrafo(
			"Suman 100 %. Las geodas grandes, el Jefe y algunos eventos dan más suerte.",
			18,
			W - 700,
			Color3.fromHex("#9AA3B8")
		)
		nota.Position = UDim2.fromOffset(18, AH - 70)
		nota.ZIndex = 3
		nota.Parent = der
	end

	local lista = {}
	for _, z in GameConfig.Zonas do
		table.insert(lista, {
			Id = tostring(z.Numero),
			Texto = z.Nombre:match("^(%S+)") or z.Nombre,
			Color = "Rosa",
		})
	end
	local pestanas, elegir = Ventanas.pestanas(
		lista,
		math.floor((W - 10 * (#lista - 1)) / #lista),
		60,
		function(id: string)
			zona = tonumber(id) or 1
			dibujar()
		end
	)
	pestanas.Parent = v.Cuerpo
	elegir("1")
	table.insert(v.alAbrir, function()
		elegir(tostring(Reglas.mejorZona(Datos.zonas())))
		dibujar()
	end)
	Datos.alCambiar({ "Indice", "Exoticas", "Suerte", "Zonas" }, function()
		if Ventanas.abierta() == "Indice" then
			dibujar()
		end
	end)
end

return { crear = crear }
