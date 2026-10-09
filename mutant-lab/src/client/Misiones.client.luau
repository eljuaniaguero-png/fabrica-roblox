--!strict
-- Menú Misiones (botón del HUD), armado con los componentes de UI (ficha, "Parte 8"):
--   Hoy: el premio diario de 7 días (con el botón para cobrarlo) y las tres misiones del día.
--   Experimento: la silueta misteriosa de hoy, igual para todos, con sus tres pistas.
--   Metas: las metas largas con su progreso (cada una deja un trofeo en el laboratorio).
-- Además, el cartel de regreso ("Tus criaturas juntaron...") y, si el premio diario está
-- para cobrar al entrar, el menú se abre solo en "Hoy".
-- Todo lo que importa lo decide el servidor (atributos Diario, Misiones, Metas, Dia, FinDia).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Experimento = require(ReplicatedStorage.Shared.Experimento)
local Formato = require(ReplicatedStorage.Shared.Formato)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Mejoras = require(ReplicatedStorage.Shared.Mejoras)
local Paleta = require(ReplicatedStorage.Shared.Paleta)
local Sonidos = require(script.Parent.Sonidos)
local UI = require(script.Parent.UI)
local Carteles = require(script.Parent.UI.Carteles)
local Menus = require(script.Parent.UI.Menus)
local Vista = require(script.Parent.Vista)

local Tema = UI.Tema
local V = Tema.Ventana
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local cobrarDiario = remotos:WaitForChild("CobrarDiario") :: RemoteEvent
local regreso = remotos:WaitForChild("Regreso") :: RemoteEvent

local PREMIOS = Config.Diario.Premios
local ALTO_FILA = 104
local ALTO_DIA = 168

local function leer(atributo: string): any
	local texto = jugador:GetAttribute(atributo) :: string?
	if not texto or texto == "" then
		return nil
	end
	local ok, datos = pcall(function()
		return HttpService:JSONDecode(texto)
	end)
	return if ok then datos else nil
end

local function cantidadEspecies(): number
	local n = 0
	for _ in Formato.conjunto(jugador:GetAttribute("Especies") :: string?) do
		n += 1
	end
	return n
end

-- "3 h 20 min", "12 min".
local function duracion(segundos: number): string
	local h = segundos // 3600
	local m = (segundos % 3600) // 60
	if h > 0 then
		return h .. " h " .. m .. " min"
	end
	return math.max(1, m) .. " min"
end

local function faltaParaManana(): string
	local fin = (jugador:GetAttribute("FinDia") :: number?) or 0
	return duracion(math.max(0, fin - workspace:GetServerTimeNow()))
end

---------------------------------------------------------------------------
-- Ventana y pestañas
---------------------------------------------------------------------------

local ventana = UI.ventana({
	Titulo = "Misiones",
	Icono = "misiones",
	ColorIcono = Paleta.Elementos.Agua,
	Ancho = V.Ancho,
	Alto = V.Alto,
	MaxAncho = V.MaxAncho,
	MaxAlto = V.MaxAlto,
})

local paginas: { [string]: Frame } = {}
local pintar: () -> () = function() end

local pestanas = UI.pestanas({
	{ Clave = "Hoy", Texto = "Hoy", Icono = "check", ColorIcono = Paleta.Acento },
	{
		Clave = "Experimento",
		Texto = "Experimento",
		Icono = "pregunta",
		ColorIcono = Paleta.Alerta,
	},
	{ Clave = "Metas", Texto = "Metas", Icono = "estrella", ColorIcono = Paleta.Dorado },
}, function(clave: string)
	for k, p in paginas do
		p.Visible = k == clave
	end
	pintar()
end)
pestanas.Marco.Parent = ventana.Cuerpo

local arriba = Tema.Toque + Tema.Separacion
local contenido = UI.hueco("Contenido", UDim2.new(1, 0, 1, -arriba), ventana.Cuerpo)
contenido.Position = UDim2.fromOffset(0, arriba)

local function pagina(clave: string): ScrollingFrame
	local marco = UI.hueco(clave, UDim2.fromScale(1, 1), contenido)
	marco.Visible = false
	paginas[clave] = marco
	local scroll = UI.desplazable("Lista", marco)
	UI.lista(scroll, false, Tema.Separacion)
	return scroll
end

local function titulo(texto: string, orden: number, padre: Instance): TextLabel
	local t = UI.texto({
		Nombre = "Titulo",
		Texto = texto,
		Letra = Tema.Letra.Subtitulo,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, 0, 0, Tema.Letra.Subtitulo + 12),
	})
	t.LayoutOrder = orden
	t.Parent = padre
	return t
end

-- Un renglón con progreso: insignia a la izquierda, texto, barra y "x / y" (misiones, metas).
type Renglon = {
	Tarjeta: UI.Tarjeta,
	Insignia: Frame,
	Texto: TextLabel,
	Barra: UI.Barra,
	Cuenta: TextLabel,
	poner: (texto: string, progreso: number, meta: number, hecha: boolean, extra: string?) -> (),
}

local function renglon(orden: number, padre: Instance, icono: string, color: Color3): Renglon
	local t = UI.tarjeta({ Nombre = "Renglon" .. orden })
	t.Marco.Size = UDim2.new(1, -Tema.Separacion, 0, ALTO_FILA)
	t.Marco.LayoutOrder = orden
	t.Marco.Parent = padre
	UI.relleno(t.Fondo, Tema.Separacion)
	local lado = ALTO_FILA - Tema.Separacion * 2
	local hueco = UI.hueco("Insignia", UDim2.fromOffset(lado, lado), t.Fondo)
	local texto = UI.texto({
		Nombre = "Texto",
		Fuente = "fuerte",
		Letra = Tema.Letra.Normal,
		AlineacionX = Enum.TextXAlignment.Left,
		Medida = UDim2.new(1, -(lado + Tema.Separacion) - 170, 0, lado * 0.55),
	})
	texto.Position = UDim2.fromOffset(lado + Tema.Separacion, 0)
	texto.TextScaled = true
	local tope = Instance.new("UITextSizeConstraint")
	tope.MaxTextSize = Tema.Letra.Normal
	tope.Parent = texto
	texto.Parent = t.Fondo
	local barra = UI.barra(color, 18)
	barra.Marco.Size = UDim2.new(1, -(lado + Tema.Separacion) - 170, 0, 18)
	barra.Marco.Position = UDim2.new(0, lado + Tema.Separacion, 1, -24)
	barra.Marco.Parent = t.Fondo
	local cuenta = UI.texto({
		Nombre = "Cuenta",
		Letra = Tema.Letra.Normal,
		AlineacionX = Enum.TextXAlignment.Right,
		Medida = UDim2.new(0, 160, 1, 0),
	})
	cuenta.AnchorPoint = Vector2.new(1, 0)
	cuenta.Position = UDim2.fromScale(1, 0)
	cuenta.Parent = t.Fondo
	local r: Renglon
	r = {
		Tarjeta = t,
		Insignia = hueco,
		Texto = texto,
		Barra = barra,
		Cuenta = cuenta,
		poner = function(txt, progreso, meta, hecha, extra)
			texto.Text = txt
			barra.poner(if meta > 0 then math.min(1, progreso / meta) else 0, true)
			cuenta.Text = (extra or (progreso .. " / " .. meta))
			cuenta.TextColor3 = if hecha then Paleta.Acento else Paleta.Texto
			hueco:ClearAllChildren()
			UI.insignia(
				if hecha then "check" else icono,
				if hecha then Paleta.Acento else color,
				lado
			).Parent =
				hueco
			t.Borde.Color = if hecha then Paleta.Acento else Paleta.Contorno
		end,
	}
	return r
end

---------------------------------------------------------------------------
-- Hoy: premio diario y misiones
---------------------------------------------------------------------------

local hoy = pagina("Hoy")
titulo("Premio diario: volvé cada día y crece (si faltás, vuelve al día 1)", 1, hoy)

local filaDias = UI.hueco("Dias", UDim2.new(1, -Tema.Separacion, 0, ALTO_DIA), hoy)
filaDias.LayoutOrder = 2
UI.lista(filaDias, true, Tema.Separacion / 2)

type Dia = { Tarjeta: UI.Tarjeta, Icono: Frame, Cantidad: TextLabel, Nombre: TextLabel }
local dias: { Dia } = {}
for i = 1, #PREMIOS do
	local t = UI.tarjeta({ Nombre = "Dia" .. i })
	t.Marco.Size = UDim2.new(1 / #PREMIOS, -Tema.Separacion / 2, 1, 0)
	t.Marco.LayoutOrder = i
	t.Marco.Parent = filaDias
	local nombre = UI.texto({
		Nombre = "Nombre",
		Texto = "Día " .. i,
		Letra = Tema.Letra.Chica,
		Medida = UDim2.new(1, 0, 0, 30),
	})
	nombre.Position = UDim2.fromOffset(0, 6)
	nombre.Parent = t.Fondo
	local icono = UI.hueco("Icono", UDim2.fromOffset(64, 64), t.Fondo)
	icono.AnchorPoint = Vector2.new(0.5, 0)
	icono.Position = UDim2.new(0.5, 0, 0, 38)
	local cantidad = UI.texto({
		Nombre = "Cantidad",
		Fuente = "fuerte",
		Letra = Tema.Letra.Chica,
		Medida = UDim2.new(1, -8, 0, 52),
	})
	cantidad.AnchorPoint = Vector2.new(0.5, 1)
	cantidad.Position = UDim2.new(0.5, 0, 1, -4)
	cantidad.TextScaled = true
	local tope = Instance.new("UITextSizeConstraint")
	tope.MaxTextSize = Tema.Letra.Chica
	tope.Parent = cantidad
	cantidad.Parent = t.Fondo
	dias[i] = { Tarjeta = t, Icono = icono, Cantidad = cantidad, Nombre = nombre }
end

local filaCobrar =
	UI.hueco("Cobrar", UDim2.new(1, -Tema.Separacion, 0, Tema.Toque + Tema.Profundidad), hoy)
filaCobrar.LayoutOrder = 3
local botonCobrar = UI.boton({
	Nombre = "Cobrar",
	Texto = "¡Cobrar!",
	Tipo = "principal",
	Letra = Tema.Letra.Boton,
	Medida = UDim2.fromOffset(360, Tema.Toque + Tema.Profundidad),
	AlTocar = function()
		cobrarDiario:FireServer()
	end,
})
botonCobrar.Marco.AnchorPoint = Vector2.new(0.5, 0)
botonCobrar.Marco.Position = UDim2.fromScale(0.5, 0)
botonCobrar.Marco.Parent = filaCobrar

local tituloMisiones = titulo("Misiones de hoy", 4, hoy)
local misiones: { Renglon } = {}
for i = 1, Config.Misiones.PorDia do
	misiones[i] = renglon(4 + i, hoy, "misiones", Paleta.Elementos.Agua)
end
local bono = renglon(4 + Config.Misiones.PorDia + 1, hoy, "estrella", Paleta.Dorado)

-- Lo que trae cada día (ADN según lo que cuesta hoy una fusión de gen 2).
local function textoPremio(i: number): (string, string, Color3)
	local p = PREMIOS[i]
	if p.Especial then
		local c = Fusion.porClave(p.Especial)
		return (if c then c.Nombre else "Especial") .. " y más", "estrella", Paleta.Dorado
	elseif p.Catalizadores then
		return "+" .. p.Catalizadores .. (if p.Catalizadores > 1
			then " catalizadores"
			else " catalizador"),
			"frasco",
			Paleta.Catalizadores.Hielo
	end
	local adn = math.round((p.ADN or 0) * Mejoras.fusion(cantidadEspecies()))
	return "+" .. Formato.numero(adn) .. " ADN", "adn", Paleta.Acento
end

local function pintarHoy()
	local diario = leer("Diario") or { Dia = 1, Disponible = false }
	for i, d in dias do
		local texto, icono, color = textoPremio(i)
		d.Cantidad.Text = texto
		local cobrado = i < diario.Dia or (i == diario.Dia and not diario.Disponible)
		local esHoy = i == diario.Dia
		d.Icono:ClearAllChildren()
		UI.Iconos.crear(
			if cobrado then "check" else icono,
			56,
			if cobrado then Paleta.Acento else color
		).Parent =
			d.Icono
		d.Tarjeta.Borde.Color = if esHoy then Paleta.Acento else Paleta.Contorno
		d.Tarjeta.Borde.Thickness = if esHoy then Tema.Contorno + 3 else Tema.Contorno
		d.Tarjeta.Fondo.BackgroundColor3 = if i == #PREMIOS
			then Paleta.oscuro(Paleta.Dorado, 0.6)
			else Paleta.SuperficieElevada
	end
	if diario.Disponible then
		botonCobrar.poner("¡Cobrar el día " .. diario.Dia .. "!")
		botonCobrar.habilitar(true)
	else
		botonCobrar.poner("Volvé mañana (en " .. faltaParaManana() .. ")")
		botonCobrar.habilitar(false)
	end

	local m = leer("Misiones")
	tituloMisiones.Text = "Misiones de hoy (cambian en " .. faltaParaManana() .. ")"
	for i, r in misiones do
		local dato = m and m.Lista[i]
		r.Tarjeta.Marco.Visible = dato ~= nil
		if dato then
			r.poner(
				dato.Texto,
				dato.Progreso,
				dato.Meta,
				dato.Hecha,
				if dato.Hecha then "+" .. Formato.numero(m.Premio) .. " ADN" else nil
			)
		end
	end
	if m then
		local hechas = 0
		for _, dato in m.Lista do
			if dato.Hecha then
				hechas += 1
			end
		end
		bono.poner(
			"Las " .. #m.Lista .. ": +" .. Formato.numero(m.PremioTodas) .. " ADN y un catalizador",
			hechas,
			#m.Lista,
			m.Bono
		)
	end
end

---------------------------------------------------------------------------
-- Experimento del día
---------------------------------------------------------------------------

local experimento = pagina("Experimento")
local textoExperimento =
	titulo("Experimento del día: la misma especie misteriosa para todos", 1, experimento)
textoExperimento.TextWrapped = true

local cajaVista = UI.tarjeta({ Nombre = "Vista" })
cajaVista.Marco.Size = UDim2.new(1, -Tema.Separacion, 0, 300)
cajaVista.Marco.LayoutOrder = 2
cajaVista.Marco.Parent = experimento
local vistaExperimento = Instance.new("ViewportFrame")
vistaExperimento.BackgroundTransparency = 1
vistaExperimento.Size = UDim2.fromScale(1, 1)
vistaExperimento.Parent = cajaVista.Fondo
local nombreExperimento = UI.texto({
	Nombre = "Nombre",
	Letra = Tema.Letra.Titulo,
	Medida = UDim2.new(1, 0, 0, 56),
})
nombreExperimento.AnchorPoint = Vector2.new(0, 1)
nombreExperimento.Position = UDim2.fromScale(0, 1)
nombreExperimento.Parent = cajaVista.Fondo

local pistas: { Renglon } = {}
for i = 1, 3 do
	pistas[i] = renglon(2 + i, experimento, "lupa", Paleta.Alerta)
	pistas[i].Barra.Marco.Visible = false
	pistas[i].Texto.Size = UDim2.new(1, -(ALTO_FILA + Tema.Separacion) - 20, 1, 0)
end
local estadoExperimento = UI.texto({
	Nombre = "Estado",
	Fuente = "fuerte",
	Letra = Tema.Letra.Normal,
	Medida = UDim2.new(1, -Tema.Separacion, 0, 72),
})
estadoExperimento.LayoutOrder = 10
estadoExperimento.Parent = experimento

local marcaExperimento: string? = nil

local function pintarExperimento()
	local dia = jugador:GetAttribute("Dia") :: number?
	if not dia then
		return
	end
	local c = Experimento.especie(dia)
	local tengo = Formato.conjunto(jugador:GetAttribute("Especies") :: string?)[c.Clave] == true
	local gane = jugador:GetAttribute("ExperimentoGanado") == dia
	local marca = c.Clave .. (if tengo then "T" else "") .. (if gane then "G" else "")
	if marca ~= marcaExperimento then
		marcaExperimento = marca
		local modelo = Vista.mostrar(vistaExperimento, c.Clave, nil, not tengo)
		if modelo then
			local camara = vistaExperimento.CurrentCamera
			if camara then
				-- Un poco más cerca y mirando más abajo, así el nombre no le tapa las patas.
				camara.CFrame = CFrame.lookAt(Vector3.new(-4, 3.8, -8.4), Vector3.new(0, 1.6, 0))
			end
		end
	end
	nombreExperimento.Text = if tengo then c.Nombre else "???"
	for i, texto in Experimento.pistas(c) do
		pistas[i].poner(texto, 0, 0, false, "")
	end
	local premio = math.round(Config.Experimento.Premio * Mejoras.fusion(cantidadEspecies()))
	if gane then
		estadoExperimento.Text = "¡Lo lograste hoy! Mañana hay otro (en "
			.. faltaParaManana()
			.. ")."
		estadoExperimento.TextColor3 = Paleta.Acento
	else
		estadoExperimento.Text = (
			if tengo then "Ya la conocés: hacé otra hoy" else "Descubrila hoy"
		)
			.. " y ganás +"
			.. Formato.numero(premio)
			.. " ADN y un catalizador. Cambia en "
			.. faltaParaManana()
			.. "."
		estadoExperimento.TextColor3 = Paleta.Texto
	end
end

---------------------------------------------------------------------------
-- Metas
---------------------------------------------------------------------------

local metas = pagina("Metas")
titulo("Metas largas: cada una deja un trofeo en el estante de tu laboratorio", 1, metas)
local renglonesMetas: { Renglon } = {}

local function pintarMetas()
	local lista = leer("Metas") or {}
	for i, m in lista do
		local r = renglonesMetas[i]
		if not r then
			r = renglon(1 + i, metas, "estrella", Paleta.Dorado)
			renglonesMetas[i] = r
		end
		r.poner(
			m.Texto,
			m.Progreso,
			m.Meta,
			m.Cumplida,
			if m.Cumplida
				then "¡Trofeo!"
				elseif m.Premio > 0 then m.Progreso .. " / " .. m.Meta
				else nil
		)
	end
end

---------------------------------------------------------------------------
-- Pintar y abrir
---------------------------------------------------------------------------

pintar = function()
	if not ventana.Marco.Visible then
		return
	end
	if pestanas.Actual == "Hoy" then
		pintarHoy()
	elseif pestanas.Actual == "Experimento" then
		pintarExperimento()
	else
		pintarMetas()
	end
end

Menus.registrar("Misiones", ventana, function()
	pintar()
end)
pestanas.elegir("Hoy")

for _, atributo in
	{ "Diario", "Misiones", "Metas", "Dia", "Especies", "ExperimentoGanado", "FinDia" }
do
	jugador:GetAttributeChangedSignal(atributo):Connect(pintar)
end

-- El cartel de regreso: lo que juntaron tus criaturas mientras no estabas.
local abrirAlEntrar = true
regreso.OnClientEvent:Connect(function(ganado: number, segundos: number)
	Carteles.mostrar({
		Titulo = "¡VOLVISTE!",
		Texto = "+" .. Formato.numero(ganado) .. " ADN",
		Detalle = "Tus criaturas trabajaron " .. duracion(segundos) .. " mientras no estabas",
		Color = Paleta.Acento,
		Duracion = Config.Interfaz.DuracionFestejo,
		AlMostrar = function()
			-- SONIDO: regreso (tres notas alegres)
			Sonidos.secuencia({ 0, 4, 7, 12 }, 0.1, 0.4)
		end,
	})
end)

-- Si el premio diario está para cobrar al entrar, se abre el menú solo (una vez).
task.delay(5, function()
	local diario = leer("Diario")
	if abrirAlEntrar and diario and diario.Disponible and not Menus.abierto() then
		abrirAlEntrar = false
		pestanas.elegir("Hoy")
		Menus.abrir("Misiones")
	end
end)

-- Cada tanto se actualiza el "cambian en ..." mientras está abierto.
task.spawn(function()
	while true do
		task.wait(30)
		pintar()
	end
end)
