--!strict
-- Clasificación semanal (Grupo 7): una pestaña por tabla, podio del 1 al 3, lista del 4 al 10
-- y tu puesto si estás. Se reinicia cada lunes y no da premios: es solo para lucirse (así nadie
-- se siente obligado a competir). Los datos están en ReplicatedStorage.Clasificaciones (JSON
-- que arma el servidor en Social.luau).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local carpeta = ReplicatedStorage:WaitForChild("Clasificaciones")
local yo = Players.LocalPlayer

type Fila = { Nombre: string, Valor: number, UserId: number? }

local PODIO = {
	{ Puesto = 2, Colores = { "#FFFFFF", "#AEB6C4" }, Alto = 170, Icono = "Trofeo" },
	{ Puesto = 1, Colores = { "#FFF15C", "#F5A300" }, Alto = 230, Icono = "Corona" },
	{ Puesto = 3, Colores = { "#FFB98A", "#D9631E" }, Alto = 130, Icono = "Trofeo" },
}

local function leer(tabla: string): { Fila }
	local valor = carpeta:FindFirstChild(tabla)
	if not valor or not valor:IsA("StringValue") or valor.Value == "" then
		return {}
	end
	local ok, lista = pcall(HttpService.JSONDecode, HttpService, valor.Value)
	if not ok or typeof(lista) ~= "table" then
		return {}
	end
	return lista :: { Fila }
end

-- Lunes 00:00 UTC que viene (las semanas de Reglas.semana arrancan los lunes).
local function faltaReinicio(): string
	local t = Workspace:GetServerTimeNow()
	local semana = math.floor((t - 4 * 86400) / 604800)
	local fin = 4 * 86400 + (semana + 1) * 604800
	local s = math.max(0, fin - t)
	return ("%dd %dh"):format(s // 86400, (s % 86400) // 3600)
end

local function crear()
	local v = Ventanas.crear(
		"Clasificacion",
		"Clasificación",
		"Trofeo",
		Estilo.Colores.Amarillo,
		1160,
		690
	)
	local W, H = v.Ancho, v.Alto
	local area = Instance.new("Frame")
	area.Name = "Area"
	area.BackgroundTransparency = 1
	area.Position = UDim2.fromOffset(0, 80)
	area.Size = UDim2.fromOffset(W, H - 80)
	area.Parent = v.Cuerpo
	local tabla = GameConfig.Social.Clasificacion.Tablas[1].Id

	local function valorTexto(n: number): string
		return if tabla == "Hallazgo" then Formato.unoEn(n) else Formato.corto(n)
	end

	local function dibujar()
		Ventanas.vaciar(area)
		local lista = leer(tabla)
		local AH = H - 80 - 110
		-- podio
		local podio = Instance.new("Frame")
		podio.Name = "Podio"
		podio.BackgroundTransparency = 1
		podio.Size = UDim2.fromOffset(540, AH)
		podio.Parent = area
		for col, p in PODIO do
			local x = (col - 1) * 180
			local fila = lista[p.Puesto]
			local bloque = Instance.new("Frame")
			bloque.Name = "Puesto" .. p.Puesto
			bloque.Position = UDim2.fromOffset(x + 5, AH - p.Alto)
			bloque.Size = UDim2.fromOffset(170, p.Alto)
			Estilo.superficie(bloque, { "Baldosa" }, p.Colores, 18, 6)
			Estilo.rayas(bloque, 0.18)
			local num = Estilo.texto(tostring(p.Puesto), 90, nil, 8)
			num.AnchorPoint = Vector2.new(0.5, 0)
			num.Position = UDim2.new(0.5, 0, 0, 8)
			num.ZIndex = 3
			num.Parent = bloque
			bloque.Parent = podio
			local ic = Estilo.icono(p.Icono, 72)
			ic.AnchorPoint = Vector2.new(0.5, 1)
			ic.Position = UDim2.fromOffset(x + 90, AH - p.Alto - 70)
			ic.Parent = podio
			local nombre = Estilo.texto(if fila then fila.Nombre else "---", 24)
			nombre.AnchorPoint = Vector2.new(0.5, 1)
			nombre.Position = UDim2.fromOffset(x + 90, AH - p.Alto - 38)
			nombre.Parent = podio
			local val = Estilo.texto(if fila then valorTexto(fila.Valor) else "", 22, Estilo.Verde)
			val.AnchorPoint = Vector2.new(0.5, 1)
			val.Position = UDim2.fromOffset(x + 90, AH - p.Alto - 8)
			val.Parent = podio
		end
		-- del 4 al 10
		local resto = Ventanas.desplazable(W - 560, AH, nil, 8)
		resto.Position = UDim2.fromOffset(560, 0)
		resto.Parent = area
		for i = 4, #lista do
			local fila = lista[i]
			local f = Instance.new("Frame")
			f.LayoutOrder = i
			f.Size = UDim2.fromOffset(W - 600, 62)
			Estilo.superficie(
				f,
				{ "Baldosa" },
				if i % 2 == 0 then { "#454B78", "#363C68" } else { "#3A3F66", "#2E3358" },
				14,
				4,
				true
			)
			local n = Estilo.texto(("%d.  %s"):format(i, fila.Nombre), 28)
			n.AnchorPoint = Vector2.new(0, 0.5)
			n.Position = UDim2.new(0, 16, 0.5, 0)
			n.ZIndex = 3
			n.Parent = f
			local val = Estilo.texto(valorTexto(fila.Valor), 28, Estilo.Verde)
			val.AnchorPoint = Vector2.new(1, 0.5)
			val.Position = UDim2.new(1, -16, 0.5, 0)
			val.ZIndex = 3
			val.Parent = f
			f.Parent = resto
		end
		if #lista == 0 then
			local nadie =
				Estilo.parrafo("Todavía nadie esta semana. ¡Rompé geodas!", 26, W - 620)
			nadie.Parent = resto
		end
		-- tu puesto
		local puesto = 0
		for i, fila in lista do
			if fila.UserId == yo.UserId then
				puesto = i
			end
		end
		local tuyo = Instance.new("Frame")
		tuyo.Name = "TuPuesto"
		tuyo.Position = UDim2.fromOffset(0, AH + 18)
		tuyo.Size = UDim2.fromOffset(W, 84)
		Estilo.superficie(tuyo, { "Baldosa" }, { "#5BD94A", "#1E8A2E" }, 20, 5, true)
		Estilo.rayas(tuyo, 0.14)
		local tt = Estilo.texto(
			if puesto > 0
				then ("Tu puesto: #%d · %s"):format(puesto, valorTexto(lista[puesto].Valor))
				else "Todavía no estás en el top 10 de esta semana",
			30
		)
		tt.AnchorPoint = Vector2.new(0, 0.5)
		tt.Position = UDim2.new(0, 20, 0.5, 0)
		tt.ZIndex = 3
		tt.Parent = tuyo
		local nota = Estilo.conIconos(
			{ "Chispa" },
			"Solo para lucirse: no da premios · se reinicia en " .. faltaReinicio(),
			20,
			Color3.fromHex("#E3FFE0")
		)
		nota.AnchorPoint = Vector2.new(1, 0.5)
		nota.Position = UDim2.new(1, -18, 0.5, 0)
		nota.ZIndex = 3
		nota.Parent = tuyo
		tuyo.Parent = area
	end

	local pest = {}
	local ICONOS = { Geodas = "Gema", Exoticas = "Lava", Jefes = "Jefe", Hallazgo = "Chispa" }
	for _, t in GameConfig.Social.Clasificacion.Tablas do
		table.insert(
			pest,
			{ Id = t.Id, Texto = t.Nombre, Icono = ICONOS[t.Id], Color = "Amarillo" }
		)
	end
	local pestanas, elegir = Ventanas.pestanas(
		pest,
		math.floor((W - 30) / #pest),
		60,
		function(id: string)
			tabla = id
			dibujar()
		end,
		22
	)
	pestanas.Parent = v.Cuerpo
	elegir(tabla)
	table.insert(v.alAbrir, dibujar)
	carpeta.ChildAdded:Connect(function(hijo: Instance)
		if hijo:IsA("StringValue") then
			hijo.Changed:Connect(function()
				if Ventanas.abierta() == "Clasificacion" and hijo.Name == tabla then
					dibujar()
				end
			end)
		end
	end)
	for _, hijo in carpeta:GetChildren() do
		if hijo:IsA("StringValue") then
			hijo.Changed:Connect(function()
				if Ventanas.abierta() == "Clasificacion" and hijo.Name == tabla then
					dibujar()
				end
			end)
		end
	end
end

return { crear = crear }
