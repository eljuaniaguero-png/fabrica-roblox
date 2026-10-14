--!strict
-- Misiones (Grupo 4): las que tenés ahora (Fácil, Media, Difícil y, desde el primer Renacer,
-- Prestigio) con su barra y su premio, el botón para cambiar una (gratis, con espera) y el
-- próximo premio por misiones cumplidas. Se siguen y se pagan solas en el servidor
-- (server/Misiones.luau); acá solo se muestran.
-- También exporta Misiones.lista() para el seguimiento del HUD.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local CambiarMision =
	ReplicatedStorage:WaitForChild("Remotos"):WaitForChild("CambiarMision") :: RemoteEvent

local M = GameConfig.Misiones

export type MisionVista = {
	Id: string,
	Texto: string,
	Dificultad: string,
	Meta: number,
	Progreso: number,
	Monedas: number,
	Esencia: number,
}

local MenuMisiones = {}

-- Las misiones de ahora, como las publica el servidor.
function MenuMisiones.lista(): { MisionVista }
	local r: { MisionVista } = {}
	for _, m in Datos.json("Misiones") do
		if typeof(m) == "table" and typeof(m.Texto) == "string" and typeof(m.Meta) == "number" then
			table.insert(r, m :: any)
		end
	end
	return r
end

-- Colores (de Estilo.Colores) de cada dificultad.
function MenuMisiones.color(dificultad: string): string
	local d = M.Dificultades[dificultad]
	return if d then d.Color else "Gris"
end

-- El próximo logro por misiones cumplidas (nil si ya los tiene todos).
local function proximoPremio(): GameConfig.Logro?
	local logros = Datos.conjunto("Logros")
	local mejor: GameConfig.Logro? = nil
	for _, l in GameConfig.Logros do
		if l.Necesita.Tipo == "Misiones" and not logros[l.Id] then
			if not mejor or (l.Necesita.Cuantas or 0) < (mejor.Necesita.Cuantas or 0) then
				mejor = l
			end
		end
	end
	return mejor
end

local function premioTexto(l: GameConfig.Logro): string
	local partes = {}
	if l.Premio.Monedas then
		table.insert(partes, Formato.corto(l.Premio.Monedas) .. " Monedas")
	end
	if l.Premio.Suerte then
		table.insert(partes, "+" .. Formato.suerte(l.Premio.Suerte):sub(2) .. " de suerte")
	end
	local c = l.Premio.Cosmetico
	local cos = c and Reglas.cosmetico(c.Tipo, c.Id)
	if cos then
		table.insert(partes, cos.Nombre)
	end
	return table.concat(partes, " · ")
end

function MenuMisiones.crear()
	local v = Ventanas.crear("Misiones", "Misiones", "Mision", Estilo.Colores.Verde, 1160, 690)
	local W, H = v.Ancho, v.Alto

	local arriba = Instance.new("Frame")
	arriba.BackgroundTransparency = 1
	arriba.Size = UDim2.fromOffset(W, 110)
	arriba.Parent = v.Cuerpo
	local lista = Ventanas.desplazable(W, H - 170, nil, 12)
	lista.Position = UDim2.fromOffset(0, 120)
	lista.Parent = v.Cuerpo
	local pie = Estilo.parrafo(
		("Las misiones se siguen y se pagan solas. Podés cambiar una cada %s, gratis."):format(
			Formato.tiempo(M.Cambiar)
		),
		20,
		W,
		Color3.fromHex("#C9D6EE")
	)
	pie.Position = UDim2.fromOffset(0, H - 40)
	pie.Parent = v.Cuerpo

	-- botón "Cambiar" -> su texto y si ya está en gris (para no repintarlo cada vez)
	local botonesCambio: { [TextButton]: { Texto: TextLabel, Gris: boolean } } = {}

	local function dibujar()
		Ventanas.vaciar(arriba)
		Ventanas.vaciar(lista)
		table.clear(botonesCambio)

		-- arriba: cumplidas y próximo premio
		local hechas = Datos.numero("MisionesHechas")
		local cab = Estilo.texto(("Misiones cumplidas: %d"):format(hechas), 34)
		Estilo.degradado(cab, { "#B8FF6A", "#2DBA2D" })
		cab.Parent = arriba
		local l = proximoPremio()
		if l then
			local meta = l.Necesita.Cuantas or 1
			local barra, poner = Estilo.barra(420, 36, { "#8CFF5A", "#1FA33A" })
			barra.Position = UDim2.fromOffset(0, 56)
			barra.Parent = arriba
			poner(hechas / meta, ("%d / %d"):format(math.min(hechas, meta), meta))
			local premio = Estilo.parrafo(
				("Próximo premio: %s (%s)"):format(l.Nombre, premioTexto(l)),
				22,
				W - 450,
				Color3.fromHex("#FFE45C")
			)
			premio.Position = UDim2.fromOffset(440, 58)
			premio.Parent = arriba
		end

		local misiones = MenuMisiones.lista()
		if #misiones == 0 then
			local nada = Estilo.parrafo("Tus misiones nuevas están llegando...", 26, W - 40)
			nada.Parent = lista
		end
		for i, m in misiones do
			local d = M.Dificultades[m.Dificultad]
			local color = MenuMisiones.color(m.Dificultad)
			local f = Ventanas.panel(W - 40, 124, { "#353B63", "#262B4F" })
			f.Name = m.Id
			f.LayoutOrder = i
			-- etiqueta de dificultad
			local etiqueta = Instance.new("Frame")
			etiqueta.Size = UDim2.fromOffset(150, 96)
			etiqueta.Position = UDim2.fromOffset(14, 14)
			etiqueta.ZIndex = 3
			Estilo.superficie(etiqueta, { "Baldosa" }, Estilo.Colores[color], 16, 4)
			local c = Estilo.contenido(etiqueta, 0, true)
			local ic =
				Estilo.icono(if m.Dificultad == M.LugarPrestigio then "Renacer" else "Mision", 46)
			ic.LayoutOrder = 1
			ic.Parent = c
			local dt = Estilo.texto(if d then d.Nombre else m.Dificultad, 22)
			dt.LayoutOrder = 2
			dt.Parent = c
			etiqueta.Parent = f
			-- texto y barra
			local texto = Estilo.parrafo(m.Texto, 28, 560)
			texto.Position = UDim2.fromOffset(184, 14)
			texto.ZIndex = 3
			texto.Parent = f
			local barra, poner = Estilo.barra(540, 34, Estilo.Colores[color])
			barra.Position = UDim2.fromOffset(184, 74)
			barra.ZIndex = 3
			barra.Parent = f
			poner(m.Progreso / math.max(1, m.Meta), ("%d / %d"):format(m.Progreso, m.Meta))
			-- premio
			local premio = Instance.new("Frame")
			premio.BackgroundTransparency = 1
			premio.Position = UDim2.fromOffset(748, 18)
			premio.Size = UDim2.fromOffset(180, 90)
			premio.ZIndex = 3
			local col = Instance.new("UIListLayout")
			col.SortOrder = Enum.SortOrder.LayoutOrder
			col.Padding = UDim.new(0, 4)
			col.Parent = premio
			local pm = Estilo.conIconos(
				{ "Moneda" },
				Formato.corto(m.Monedas),
				26,
				Color3.fromHex("#FFE45C")
			)
			pm.LayoutOrder = 1
			pm.Parent = premio
			if m.Esencia > 0 then
				local pe = Estilo.conIconos(
					{ "Esencia" },
					"+" .. m.Esencia .. " Esencia",
					22,
					Color3.fromHex("#FFB04D")
				)
				pe.LayoutOrder = 2
				pe.Parent = premio
			end
			premio.Parent = f
			-- cambiar
			local b, t = Estilo.boton({
				Texto = "Cambiar",
				Color = "Azul",
				Ancho = 150,
				Alto = 56,
				TamanoTexto = 22,
			})
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, -16, 0.5, 0)
			b.ZIndex = 3
			b.Activated:Connect(function()
				CambiarMision:FireServer(m.Dificultad)
			end)
			b.Parent = f
			if t then
				botonesCambio[b] = { Texto = t, Gris = false }
			end
			f.Parent = lista
		end
	end

	-- La espera para cambiar se ve en los botones.
	task.spawn(function()
		while true do
			if Ventanas.abierta() == "Misiones" then
				local falta = M.Cambiar
					- (Workspace:GetServerTimeNow() - Datos.numero("CambioMision"))
				for b, info in botonesCambio do
					local esperar = falta > 0
					info.Texto.Text = if esperar then Formato.tiempo(falta) else "Cambiar"
					if esperar ~= info.Gris then
						info.Gris = esperar
						Estilo.colorBoton(b, if esperar then "Gris" else "Azul")
					end
				end
			end
			task.wait(0.5)
		end
	end)

	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Misiones", "MisionesHechas", "Logros" }, function()
		if Ventanas.abierta() == "Misiones" then
			dibujar()
		end
	end)
end

return MenuMisiones
