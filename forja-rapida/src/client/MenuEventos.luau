--!strict
-- Eventos del mundo (Grupo 6): el que está pasando (o el próximo, con cuenta regresiva) en
-- grande y los seis eventos con lo que hace cada uno. Todo sale de GameConfig.Eventos y de
-- ReplicatedStorage.EstadoMundo (lo pone el servidor).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local estado = ReplicatedStorage:WaitForChild("EstadoMundo")

local ICONO: { [string]: string } = {
	LluviaCristales = "Cristal",
	Erupcion = "Lava",
	TormentaNeon = "Neon",
	EclipseVacio = "Vacio",
	FiebreMineria = "Trofeo",
	JefeAncestral = "Jefe",
}

local function reloj(segundos: number): string
	segundos = math.max(0, math.floor(segundos))
	return ("%d:%02d"):format(segundos // 60, segundos % 60)
end

local function crear()
	local v = Ventanas.crear("Eventos", "Eventos", "Reloj", Estilo.Colores.Azul, 1160, 660)
	local W, H = v.Ancho, v.Alto
	local E = GameConfig.Eventos

	-- Tarjeta grande: ahora o próximo.
	local grande = Instance.new("Frame")
	grande.Name = "Ahora"
	grande.Size = UDim2.fromOffset(380, H - 50)
	grande.Parent = v.Cuerpo
	local cuentaRegresiva: TextLabel? = nil

	local function dibujarGrande()
		Ventanas.vaciar(grande)
		for _, hijo in grande:GetChildren() do
			if hijo:IsA("UIGradient") or hijo:IsA("UIStroke") or hijo:IsA("UICorner") then
				hijo:Destroy()
			end
		end
		local ahora = Reglas.evento(tostring(estado:GetAttribute("Evento") or ""))
		local proximo = Reglas.evento(tostring(estado:GetAttribute("Proximo") or ""))
		local ev = ahora or proximo
		Estilo.superficie(
			grande,
			{ "Baldosa" },
			if ev then { ev.Color, ev.Color2 } else Estilo.Colores.Gris,
			22,
			6,
			true
		)
		Estilo.rayas(grande, 0.16)
		local col = Estilo.contenido(grande, 12, true)
		local relleno = Instance.new("UIPadding")
		relleno.PaddingLeft = UDim.new(0, 18)
		relleno.PaddingRight = UDim.new(0, 18)
		relleno.Parent = col
		local etiqueta = Estilo.boton({
			Texto = if ahora then "AHORA" elseif proximo then "SE VIENE" else "TRANQUI",
			Color = if ahora then "Rojo" else "Verde",
			Ancho = 170,
			Alto = 50,
		})
		etiqueta.Active = false
		etiqueta.LayoutOrder = 1
		etiqueta.Parent = col
		if ev then
			local ic = Estilo.icono(ICONO[ev.Id] or "Reloj", 120)
			ic.LayoutOrder = 2
			ic.Parent = col
			local n = Estilo.texto(ev.Nombre, 40)
			n.LayoutOrder = 3
			n.Parent = col
			local d = Estilo.parrafo(ev.Descripcion, 22, 330)
			d.TextXAlignment = Enum.TextXAlignment.Center
			d.LayoutOrder = 4
			d.Parent = col
			local t = Estilo.texto("", 34, Color3.fromHex("#FFF15C"))
			t.LayoutOrder = 5
			t.Parent = col
			cuentaRegresiva = t
		else
			local n =
				Estilo.parrafo("Ahora no hay ningún evento. ¡Seguí rompiendo geodas!", 28, 330)
			n.TextXAlignment = Enum.TextXAlignment.Center
			n.LayoutOrder = 2
			n.Parent = col
			cuentaRegresiva = nil
		end
	end

	-- Las seis tarjetas.
	local grilla = Ventanas.desplazable(W - 400, H - 50, Vector2.new(320, 150), 14)
	grilla.Position = UDim2.fromOffset(400, 0)
	grilla.Parent = v.Cuerpo
	for i, ev in E.Lista do
		local c = Instance.new("Frame")
		c.Name = ev.Id
		c.LayoutOrder = i
		Estilo.superficie(c, { "Baldosa" }, { ev.Color, ev.Color2 }, 20, 5, true)
		Estilo.rayas(c, 0.14)
		local ic = Estilo.icono(ICONO[ev.Id] or "Reloj", 74)
		ic.Position = UDim2.fromOffset(10, 38)
		ic.ZIndex = 3
		ic.Parent = c
		local textos = Instance.new("Frame")
		textos.BackgroundTransparency = 1
		textos.Position = UDim2.fromOffset(92, 10)
		textos.Size = UDim2.fromOffset(220, 130)
		textos.ZIndex = 3
		local orden = Instance.new("UIListLayout")
		orden.Padding = UDim.new(0, 4)
		orden.SortOrder = Enum.SortOrder.LayoutOrder
		orden.Parent = textos
		local n = Estilo.parrafo(ev.Nombre, 22, 216)
		n.LayoutOrder = 1
		n.Parent = textos
		local d = Estilo.parrafo(ev.Descripcion, 15, 216)
		d.LayoutOrder = 2
		d.Parent = textos
		textos.Parent = c
		c.Parent = grilla
	end

	local nota = Estilo.texto(
		("Un evento cada %d a %d minutos · se avisa %d segundos antes"):format(
			E.Intervalo[1] // 60,
			E.Intervalo[2] // 60,
			E.AvisoPrevio
		),
		22,
		Color3.fromHex("#C9D6EE")
	)
	nota.Position = UDim2.fromOffset(0, H - 36)
	nota.Parent = v.Cuerpo

	local function tic()
		local t = cuentaRegresiva
		if not t then
			return
		end
		local ahoraSrv = Workspace:GetServerTimeNow()
		local fin = tonumber(estado:GetAttribute("EventoFin")) or 0
		local inicio = tonumber(estado:GetAttribute("ProximoInicio")) or 0
		if estado:GetAttribute("Evento") then
			t.Text = "Termina en " .. reloj(fin - ahoraSrv)
		elseif inicio > 0 then
			t.Text = "Empieza en " .. reloj(inicio - ahoraSrv)
		else
			t.Text = ""
		end
	end

	table.insert(v.alAbrir, function()
		dibujarGrande()
		while Ventanas.abierta() == "Eventos" do
			tic()
			task.wait(0.5)
		end
	end)
	for _, n in { "Evento", "Proximo" } do
		estado:GetAttributeChangedSignal(n):Connect(function()
			if Ventanas.abierta() == "Eventos" then
				dibujarGrande()
			end
		end)
	end
end

return { crear = crear }
