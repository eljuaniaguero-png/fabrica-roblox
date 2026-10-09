--!strict
-- Panel para elegir dos criaturas tuyas y confirmar la fusión.
-- Fusion (ScreenGui armado en Studio) > Panel > Titulo, Cerrar, Aviso, Plantilla (tarjeta oculta),
--   Ranuras > RanuraA, RanuraB (TextButton > Vista, Nombre, Mas), Fusionar (TextButton > Texto, Costo)
--   Lista (ScrollingFrame con UIGridLayout): una tarjeta por especie que tenés.
-- Tarjeta (TextButton) > Vista (ViewportFrame), Nombre, Gen (TextLabel), Borde (UIStroke)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costos = require(ReplicatedStorage.Shared.Costos)
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Sonidos = require(script.Parent.Sonidos)
local Vista = require(script.Parent.Vista)

export type Eventos = {
	AlElegir: (lado: string, clave: string?) -> (),
	AlConfirmar: (a: string, b: string) -> (),
}

local E = Config.Estilo
local ROJO = Color3.fromHex("E8254D")

local jugador = Players.LocalPlayer
local gui = jugador:WaitForChild("PlayerGui"):WaitForChild("Fusion") :: ScreenGui
local panel = gui:WaitForChild("Panel") :: Frame
local cerrar = panel:WaitForChild("Cerrar") :: TextButton
local aviso = panel:WaitForChild("Aviso") :: TextLabel
local plantilla = panel:WaitForChild("Plantilla") :: TextButton
local lista = panel:WaitForChild("Lista") :: ScrollingFrame
local ranuras = panel:WaitForChild("Ranuras") :: Frame
local botonFusionar = ranuras:WaitForChild("Fusionar") :: TextButton
local textoFusionar = botonFusionar:WaitForChild("Texto") :: TextLabel
local textoCosto = botonFusionar:WaitForChild("Costo") :: TextLabel

local ranura: { [string]: TextButton } = {
	A = ranuras:WaitForChild("RanuraA") :: TextButton,
	B = ranuras:WaitForChild("RanuraB") :: TextButton,
}
local COLOR_RANURA = { A = E.Menta, B = E.Rosa }

local seleccion: { [string]: string } = {}
local tarjetas: { [string]: TextButton } = {}
local eventos: Eventos? = nil
local ocupada = false

local Panel = {}

local function conjunto(atributo: string): { [string]: boolean }
	local texto = (jugador:GetAttribute(atributo) :: string?) or ""
	local r = {}
	for clave in texto:gmatch("[^;]+") do
		r[clave] = true
	end
	return r
end

local function cantidadEspecies(): number
	local n = 0
	for _ in conjunto("Especies") do
		n += 1
	end
	return n
end

local function actualizarBoton()
	local a, b = seleccion.A, seleccion.B
	local ca = if a then Fusion.porClave(a) else nil
	local cb = if b then Fusion.porClave(b) else nil
	local listo = false
	if ca and cb then
		local costo = Costos.fusion(ca.Gen, cb.Gen, cantidadEspecies())
		local adn = (jugador:GetAttribute("ADN") :: number?) or 0
		-- Si sale una especie que ya tenés, se avisa antes de cobrar (solo sirve para buscar
		-- el mutante). Solo se dice para las que ya tenés: no adelanta especies nuevas.
		local hijo = if costo then Fusion.fusionar(ca, cb) else nil
		if hijo and conjunto("Especies")[hijo.Clave] then
			aviso.Text = "Ya tenés a " .. hijo.Nombre .. ": solo sirve para buscar el mutante."
		end
		if costo then
			textoCosto.Text = costo .. " ADN"
			textoCosto.TextColor3 = if adn >= costo then E.Violeta else ROJO
			listo = adn >= costo
		else
			-- Esa mezcla de generaciones nunca reacciona (y no se cobra).
			textoCosto.Text = "gratis"
			textoCosto.TextColor3 = E.Violeta
			listo = true
		end
	else
		textoCosto.Text = "elegí 2"
		textoCosto.TextColor3 = E.Violeta
	end
	listo = listo and not ocupada
	botonFusionar.AutoButtonColor = listo
	botonFusionar.BackgroundColor3 = if listo then E.Amarillo else Color3.fromHex("D9D2C5")
	textoFusionar.TextTransparency = if listo then 0 else 0.4
end

local function pintarTarjetas()
	for clave, t in tarjetas do
		local borde = t:FindFirstChild("Borde") :: UIStroke?
		if borde then
			if seleccion.A == clave then
				borde.Color, borde.Thickness = COLOR_RANURA.A, 5
			elseif seleccion.B == clave then
				borde.Color, borde.Thickness = COLOR_RANURA.B, 5
			else
				borde.Color, borde.Thickness = E.Violeta, 2
			end
		end
	end
end

local function actualizarRanura(lado: string)
	local boton = ranura[lado]
	local clave = seleccion[lado]
	local c = if clave then Fusion.porClave(clave) else nil
	local mutante = if clave then conjunto("Mutantes")[clave] == true else false
	Vista.mostrar(boton:WaitForChild("Vista") :: ViewportFrame, clave, mutante)
	local nombre = boton:WaitForChild("Nombre") :: TextLabel
	nombre.Text = if c then c.Nombre else "Elegí una"
	local mas = boton:WaitForChild("Mas") :: TextLabel
	mas.Visible = c == nil
end

local function poner(lado: string, clave: string?)
	seleccion[lado] = clave
	actualizarRanura(lado)
	pintarTarjetas()
	aviso.Text = ""
	actualizarBoton()
	if eventos then
		eventos.AlElegir(lado, clave)
	end
end

local function elegir(clave: string)
	-- SONIDO: elegir una criatura (nota corta)
	Sonidos.nota(if seleccion.A then 7 else 4, 0.35)
	if seleccion.A == clave then
		poner("A", nil)
	elseif seleccion.B == clave then
		poner("B", nil)
	elseif not seleccion.A then
		poner("A", clave)
	else
		poner("B", clave)
	end
end

-- Arma una tarjeta por cada especie que tenés, en el orden de la Mutadex.
local function armarLista()
	local tengo = conjunto("Especies")
	local mutantes = conjunto("Mutantes")
	for clave, t in tarjetas do
		if not tengo[clave] then
			t:Destroy()
			tarjetas[clave] = nil
		end
	end
	for orden, c in Fusion.todas() do
		if tengo[c.Clave] then
			local t = tarjetas[c.Clave]
			if not t then
				local nueva = plantilla:Clone()
				nueva.Name = c.Clave
				nueva.Visible = true
				nueva.LayoutOrder = orden
				nueva.Activated:Connect(function()
					elegir(c.Clave)
				end)
				nueva.Parent = lista
				tarjetas[c.Clave] = nueva
				t = nueva
			end
			local tarjeta = t :: TextButton
			local mutante = mutantes[c.Clave] == true
			if
				tarjeta:GetAttribute("Mutante") ~= mutante
				or tarjeta:GetAttribute("Lista") == nil
			then
				Vista.mostrar(tarjeta:WaitForChild("Vista") :: ViewportFrame, c.Clave, mutante)
				tarjeta:SetAttribute("Mutante", mutante)
				tarjeta:SetAttribute("Lista", true)
			end
			(tarjeta:WaitForChild("Nombre") :: TextLabel).Text = (if mutante then "⭐ " else "")
				.. c.Nombre;
			(tarjeta:WaitForChild("Gen") :: TextLabel).Text = string.rep("●", c.Gen)
		end
	end
	pintarTarjetas()
	actualizarBoton()
end

function Panel.iniciar(e: Eventos)
	eventos = e
	for lado, boton in ranura do
		boton.Activated:Connect(function()
			if seleccion[lado] then
				poner(lado, nil)
			end
		end)
	end
	botonFusionar.Activated:Connect(function()
		local a, b = seleccion.A, seleccion.B
		if ocupada or not a or not b or not botonFusionar.AutoButtonColor then
			return
		end
		e.AlConfirmar(a, b)
	end)
	cerrar.Activated:Connect(function()
		Panel.cerrar()
	end)
	jugador:GetAttributeChangedSignal("Especies"):Connect(armarLista)
	jugador:GetAttributeChangedSignal("Mutantes"):Connect(armarLista)
	jugador:GetAttributeChangedSignal("ADN"):Connect(actualizarBoton)
	armarLista()
	actualizarRanura("A")
	actualizarRanura("B")
end

function Panel.abrir()
	panel.Visible = true
end

function Panel.cerrar()
	panel.Visible = false
end

function Panel.limpiar()
	poner("A", nil)
	poner("B", nil)
end

function Panel.aviso(texto: string)
	aviso.Text = texto
end

function Panel.ocupada(valor: boolean)
	ocupada = valor
	actualizarBoton()
end

return Panel
