--!strict
-- Menú "Viajar" (idea elegida del 19/10/2026): una tarjeta por zona y una para el Lobby. Pagás
-- Monedas y aparecés al inicio de una zona que ya abriste; volver al Lobby es gratis. El
-- cliente solo muestra y pide: el servidor cobra y mueve (Viajes.luau).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Reglas = require(ReplicatedStorage.Shared.Reglas)
local Datos = require(script.Parent.Datos)
local Estilo = require(script.Parent.Estilo)
local Ventanas = require(script.Parent.Ventanas)

local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Viajar = remotos:WaitForChild("Viajar") :: RemoteEvent
local Viajo = remotos:WaitForChild("Viajo") :: RemoteEvent

local function crear()
	local v = Ventanas.crear("Viajar", "Viajar", "Cristal", Estilo.Colores.Cian, 1040, 600)
	local W, H = v.Ancho, v.Alto
	local grilla = Ventanas.desplazable(W, H - 10, Vector2.new(312, 250), 14)
	grilla.Parent = v.Cuerpo

	local function tarjeta(orden: number, zona: number)
		local z = Reglas.zona(zona)
		local abierta = zona == 0 or Datos.zonas()[zona] == true
		local precio = Reglas.precioViaje(zona)
		local alcanza = Datos.numero("Monedas") >= precio
		local c = Instance.new("Frame")
		c.Name = "Zona" .. zona
		c.LayoutOrder = orden
		local colores = if z then { z.ColorCristal, z.ColorRoca } else Estilo.Colores.Verde
		Estilo.superficie(
			c,
			{ "Baldosa" },
			if abierta then colores else Estilo.Colores.Gris,
			20,
			5,
			true
		)
		Estilo.rayas(c, 0.14)
		local col = Estilo.contenido(c, 8, true)
		local relleno = Instance.new("UIPadding")
		relleno.PaddingTop = UDim.new(0, 14)
		relleno.Parent = col

		local ic = Estilo.icono(if abierta then "Cristal" else "Candado", 70)
		ic.LayoutOrder = 1
		ic.Parent = col
		local n = Estilo.texto(if z then z.Nombre else "Lobby", 28)
		n.LayoutOrder = 2
		n.Parent = col

		local detalle: string
		if not abierta and z then
			detalle = "Necesitás " .. Reglas.textoRequisito(z, Formato.corto)
		elseif precio == 0 then
			detalle = "Gratis"
		else
			detalle = ("Cuesta %s Monedas"):format(Formato.corto(precio))
		end
		local d = Estilo.texto(detalle, 20, Color3.fromHex("#FFF6C8"))
		d.LayoutOrder = 3
		d.Parent = col

		local listo = abierta and alcanza
		local b = Estilo.boton({
			Texto = if not abierta
				then "Cerrada"
				elseif not alcanza then "Te falta"
				else "¡Viajar!",
			Color = if listo then "Verde" else "Gris",
			Ancho = 200,
			Alto = 56,
		})
		b.LayoutOrder = 4
		b.Active = listo
		b.Activated:Connect(function()
			if listo then
				Viajar:FireServer(zona)
			end
		end)
		b.Parent = col
		c.Parent = grilla
	end

	local function dibujar()
		Ventanas.vaciar(grilla)
		tarjeta(0, 0)
		for n in GameConfig.Zonas do
			tarjeta(n, n)
		end
	end

	table.insert(v.alAbrir, dibujar)
	Datos.alCambiar({ "Monedas", "Zonas" }, function()
		if Ventanas.abierta() == "Viajar" then
			dibujar()
		end
	end)
	Viajo.OnClientEvent:Connect(function()
		if Ventanas.abierta() == "Viajar" then
			Ventanas.cerrar()
		end
	end)
end

return { crear = crear }
