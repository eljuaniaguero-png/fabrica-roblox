--!strict
-- Tienda (sistema 3): tres pestañas como en la ficha.
--   Fuerza    de a un nivel o "todo lo que alcance", con cuánto sube y la próxima zona.
--   Amuletos  en orden; cada uno dice cuánto cambia tu suerte (en números, GUIA sección 6).
--   Picos     el siguiente en grande ("Destacado", como las capturas) y la fila de todos.
-- Solo pide (Remotos.Comprar); el servidor cobra y decide (Economia.luau).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local Comprar = ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("Comprar") :: RemoteEvent

local function textoCentrado(
	padre: GuiObject,
	texto: string,
	tam: number,
	y: number,
	color: Color3?
): TextLabel
	local t = Estilo.texto(texto, tam, color)
	t.AnchorPoint = Vector2.new(0.5, 0)
	t.Position = UDim2.new(0.5, 0, 0, y)
	t.ZIndex = 3
	t.Parent = padre
	return t
end

-- Botón de compra: verde si alcanza, gris si no (igual se puede tocar: el servidor dice cuánto
-- falta).
local function botonPrecio(
	precio: number,
	ancho: number,
	alto: number,
	alcanza: boolean
): TextButton
	local b = Estilo.boton({
		Texto = Formato.corto(precio),
		Icono = "Moneda",
		Color = if alcanza then "Verde" else "Gris",
		Ancho = ancho,
		Alto = alto,
	})
	return b
end

local function crear()
	local v = Ventanas.crear("Tienda", "Tienda", "Tienda", Estilo.Colores.Verde, 1100, 660)
	local area = Instance.new("Frame")
	area.Name = "Area"
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 84)
	area.Size = UDim2.fromOffset(v.Ancho, v.Alto - 84)
	area.Parent = v.Cuerpo
	local W, H = v.Ancho, v.Alto - 84
	local actual = "Fuerza"

	local function fuerza()
		local nivel = Datos.numero("NivelFuerza")
		local monedas = Datos.numero("Monedas")
		local pico = Datos.numero("Pico")
		local ahora = Reglas.fuerza(nivel, math.max(1, pico))
		local precio = Reglas.precioFuerza(nivel)
		local maximos, costoMax = Reglas.nivelesFuerza(nivel, monedas)

		local izq = Ventanas.panel(500, H, { "#5A2A3A", "#2A1A2E" })
		izq.Parent = area
		Estilo.rayas(izq, 0.08)
		local ic = Estilo.icono("Fuerza", 120)
		ic.AnchorPoint = Vector2.new(0.5, 0)
		ic.Position = UDim2.new(0.5, 0, 0, 18)
		ic.ZIndex = 3
		ic.Parent = izq
		textoCentrado(izq, "Nivel " .. nivel, 44, 140)
		if precio then
			local despues = Reglas.fuerza(nivel + 1, math.max(1, pico))
			local fila = Estilo.fila(10)
			fila.AnchorPoint = Vector2.new(0.5, 0)
			fila.Position = UDim2.new(0.5, 0, 0, 196)
			fila.ZIndex = 3
			Estilo.texto(Formato.corto(ahora), 40).Parent = fila
			local flecha = Estilo.texto(">", 40, Color3.fromHex("#FFE45C"))
			flecha.LayoutOrder = 1
			flecha.Parent = fila
			local nuevo = Estilo.texto(Formato.corto(despues) .. " Fuerza", 40, Estilo.Verde)
			nuevo.LayoutOrder = 2
			nuevo.Parent = fila
			fila.Parent = izq
			local uno = botonPrecio(precio, 220, 76, monedas >= precio)
			uno.Position = UDim2.fromOffset(24, 280)
			uno.Parent = izq
			uno.Activated:Connect(function()
				Comprar:FireServer("Fuerza")
			end)
			local max, etiqueta = Estilo.boton({
				Texto = if maximos > 0 then ("Máximo x%d"):format(maximos) else "Máximo",
				Color = if maximos > 0 then "Azul" else "Gris",
				Ancho = 220,
				Alto = 76,
				TamanoTexto = 28,
			})
			max.Position = UDim2.fromOffset(256, 280)
			max.Parent = izq
			max.Activated:Connect(function()
				Comprar:FireServer("FuerzaMax")
			end)
			if etiqueta and maximos > 0 then
				textoCentrado(
					izq,
					("Todo lo que alcanza: %s Monedas"):format(Formato.corto(costoMax)),
					22,
					374,
					Color3.fromHex("#C9D6EE")
				)
			end
		else
			textoCentrado(izq, "¡Fuerza al máximo!", 40, 220, Estilo.Verde)
		end

		local der = Ventanas.panel(W - 520, H)
		der.Position = UDim2.fromOffset(520, 0)
		der.Parent = area
		local col = Estilo.contenido(der, 14, true)
		local proxima = Reglas.proximaZona(Datos.zonas())
		local t1 = Estilo.conIconos({ "Trofeo" }, "Próxima zona", 34)
		t1.LayoutOrder = 1
		t1.Parent = col
		if proxima then
			local nombre = Estilo.texto(proxima.Nombre, 40, Color3.fromHex(proxima.ColorCristal))
			nombre.LayoutOrder = 2
			nombre.Parent = col
			local barra, poner = Estilo.barra(W - 600, 46, { "#FF8A94", "#D62839" })
			barra.LayoutOrder = 3
			barra.Parent = col
			poner(
				ahora / math.max(1, proxima.FuerzaParaAbrir),
				("%s / %s Fuerza"):format(
					Formato.corto(ahora),
					Formato.corto(proxima.FuerzaParaAbrir)
				)
			)
		else
			local listo = Estilo.texto("¡Abriste todas las zonas!", 34, Estilo.Verde)
			listo.LayoutOrder = 2
			listo.Parent = col
		end
		local p = GameConfig.Picos[math.max(1, pico)]
		local ayuda = Estilo.parrafo(
			("Cada nivel suma +1 de Fuerza y un 2,5 %% más de todo. Tu %s la multiplica x%d."):format(
				p.Nombre,
				p.Multiplicador
			),
			24,
			W - 600,
			Color3.fromHex("#E3E8F2")
		)
		ayuda.LayoutOrder = 4
		ayuda.Parent = col
	end

	local function amuletos()
		local tiene = Datos.conjunto("Amuletos")
		local monedas = Datos.numero("Monedas")
		local suerte = Datos.numero("Suerte")
		local siguiente = Reglas.siguienteAmuleto(tiene)
		local cab = Estilo.conIconos(
			{ "Trebol" },
			if siguiente
				then ("Tu suerte: %s  >  con el próximo: %s"):format(
					Formato.suerte(math.max(1, suerte)),
					Formato.suerte(math.max(1, suerte) + siguiente.Suerte)
				)
				else ("Tu suerte: %s (tenés todos)"):format(
					Formato.suerte(math.max(1, suerte))
				),
			30
		)
		cab.Parent = area
		local lista = Ventanas.desplazable(W, H - 56, nil, 10)
		lista.Position = UDim2.fromOffset(0, 56)
		lista.Parent = area
		for i, a in GameConfig.Amuletos do
			local fila = Instance.new("Frame")
			fila.Name = a.Id
			fila.LayoutOrder = i
			fila.Size = UDim2.fromOffset(W - 30, 96)
			local esSiguiente = siguiente ~= nil and siguiente.Id == a.Id
			Estilo.superficie(
				fila,
				{ "Baldosa" },
				if tiene[a.Id]
					then { "#3E8A3A", "#1E5A2A" }
					elseif esSiguiente then { "#4A5080", "#353B63" }
					else { "#2A2F55", "#1E2240" },
				18,
				4,
				true
			)
			local ic = Estilo.icono(if i == 1 then "Trebol" else "Amuleto", 76)
			ic.Position = UDim2.fromOffset(14, 10)
			ic.ZIndex = 3
			ic.Parent = fila
			local nombre = Estilo.texto(a.Nombre, 32)
			nombre.Position = UDim2.fromOffset(104, 10)
			nombre.ZIndex = 3
			nombre.Parent = fila
			local efecto = Estilo.texto(
				("+%s de Suerte, para siempre"):format(Formato.suerte(a.Suerte):sub(2)),
				24,
				Estilo.Verde
			)
			efecto.Position = UDim2.fromOffset(104, 52)
			efecto.ZIndex = 3
			efecto.Parent = fila
			local derecha: GuiObject
			if tiene[a.Id] then
				derecha = Estilo.texto("¡Lo tenés!", 30, Estilo.Verde)
			elseif esSiguiente then
				local b = botonPrecio(a.Precio, 220, 70, monedas >= a.Precio)
				b.Activated:Connect(function()
					Comprar:FireServer("Amuleto")
				end)
				derecha = b
			else
				derecha = Estilo.conIconos(
					{ "Candado" },
					"Primero el anterior",
					22,
					Color3.fromHex("#9AA3B8")
				)
			end
			derecha.AnchorPoint = Vector2.new(1, 0.5)
			derecha.Position = UDim2.new(1, -16, 0.5, 0)
			derecha.ZIndex = 3
			derecha.Parent = fila
			fila.Parent = lista
		end
	end

	local function picos()
		local pico = math.max(1, Datos.numero("Pico"))
		local monedas = Datos.numero("Monedas")
		local siguiente = Reglas.siguientePico(pico)
		local dest = textoCentrado(area, "~ Destacado ~", 34, 0)
		Estilo.degradado(dest, { "#FFF3B0", "#FFC93C" })
		local carta = Instance.new("Frame")
		carta.Name = "Destacado"
		carta.Position = UDim2.fromOffset(0, 48)
		carta.Size = UDim2.fromOffset(W, 170)
		Estilo.superficie(carta, { "MarcoDestacado" }, { "#3A1A7A", "#4A1A3A" }, 20, 6, true)
		if not Estilo.pieza("MarcoDestacado") then
			local borde = carta:FindFirstChildOfClass("UIStroke")
			if borde then
				borde.Color = Color3.fromHex("#FFC93C")
			end
		end
		Estilo.rayas(carta, 0.1)
		carta.Parent = area
		local ic = Estilo.icono("Pico", 130)
		ic.Position = UDim2.fromOffset(40, 20)
		ic.ZIndex = 3
		ic.Parent = carta
		if siguiente then
			local n = Estilo.texto(siguiente.Nombre, 52)
			n.Position = UDim2.fromOffset(200, 24)
			n.ZIndex = 3
			Estilo.degradado(n, { "#FFF3B0", "#C99BFF" })
			n.Parent = carta
			local d = Estilo.texto(
				("x%d de Fuerza · siempre usás el mejor"):format(siguiente.Multiplicador),
				28
			)
			d.Position = UDim2.fromOffset(200, 96)
			d.ZIndex = 3
			d.Parent = carta
			local b = botonPrecio(siguiente.Precio, 230, 86, monedas >= siguiente.Precio)
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, -40, 0.5, 0)
			b.ZIndex = 3
			b.Activated:Connect(function()
				Comprar:FireServer("Pico")
			end)
			b.Parent = carta
		else
			local n = Estilo.texto("¡Tenés el mejor pico!", 48, Estilo.Verde)
			n.Position = UDim2.fromOffset(200, 56)
			n.ZIndex = 3
			n.Parent = carta
		end
		local fila = Estilo.fila(14)
		fila.Position = UDim2.fromOffset(0, 236)
		fila.Parent = area
		local ancho = math.floor((W - 14 * (#GameConfig.Picos - 1)) / #GameConfig.Picos)
		for i, p in GameConfig.Picos do
			local cartaPico = Estilo.baldosa(
				if i == pico
					then Estilo.Colores.Verde
					elseif i < pico then Estilo.Colores.Gris
					else { "#FFFFFF", "#C9CFDA" },
				ancho
			)
			cartaPico.Size = UDim2.fromOffset(ancho, H - 250)
			cartaPico.LayoutOrder = i
			local col = Estilo.contenido(cartaPico, 4, true)
			local nombre = Estilo.texto(p.Nombre, 24)
			nombre.LayoutOrder = 1
			nombre.Parent = col
			local icono = Estilo.icono("Pico", 70)
			icono.LayoutOrder = 2
			icono.Parent = col
			local mult =
				Estilo.texto(("x%d Fuerza"):format(p.Multiplicador), 26, Color3.fromHex("#6CCBFF"))
			mult.LayoutOrder = 3
			mult.Parent = col
			local estado = Estilo.texto(
				if i == pico
					then "Equipado"
					elseif i < pico then "Ya lo tuviste"
					else Formato.corto(p.Precio),
				24,
				if i == pico then Estilo.Verde else nil
			)
			estado.LayoutOrder = 4
			estado.Parent = col
			cartaPico.Parent = fila
		end
	end

	local DIBUJAR: { [string]: () -> () } = { Fuerza = fuerza, Amuletos = amuletos, Picos = picos }
	local function dibujar()
		Ventanas.vaciar(area)
		DIBUJAR[actual]()
	end

	local pestanas, elegir = Ventanas.pestanas(
		{
			{ Id = "Fuerza", Texto = "Fuerza", Icono = "Fuerza", Color = "Rojo" },
			{ Id = "Amuletos", Texto = "Amuletos", Icono = "Trebol", Color = "Verde" },
			{ Id = "Picos", Texto = "Picos", Icono = "Pico", Color = "Azul" },
		},
		230,
		64,
		function(id: string)
			actual = id
			dibujar()
		end
	)
	pestanas.Parent = v.Cuerpo
	elegir("Fuerza")
	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Monedas", "NivelFuerza", "Pico", "Amuletos", "Suerte", "Zonas" }, function()
		if Ventanas.abierta() == "Tienda" then
			dibujar()
		end
	end)
end

return { crear = crear }
