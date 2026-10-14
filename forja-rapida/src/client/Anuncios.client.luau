--!strict
-- Avisos del servidor: carteles, avisos cortos, hitos y el "+X" de los premios.
--   Remotos.Anuncio  carteles para todo el servidor. Los de tipo "Hallazgo" (gemas rarísimas de
--                    otros) se pueden ocultar con el ajuste "Ver anuncios de otros"; los de
--                    eventos y jefes se ven siempre. Nada va al chat.
--   Remotos.Aviso    avisos cortos para este jugador.
--   Remotos.Hitos    logros, metas y récords que llegan fuera de una revelación.
--   Remotos.Premio   "+X Monedas" que salta (cristales de la lluvia, metas de eventos).
-- Los ajustes (efectos reducidos, anuncios y títulos) están en su ventana: MenuAjustes.luau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Formato = require(ReplicatedStorage.Shared.Formato)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Avisos = require(script.Parent.Avisos)
local Estilo = require(script.Parent.Estilo)
local Sonidos = require(script.Parent.Sonidos)

local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("Remotos")
local Anuncio = remotos:WaitForChild("Anuncio") :: RemoteEvent
local Aviso = remotos:WaitForChild("Aviso") :: RemoteEvent
local Hitos = remotos:WaitForChild("Hitos") :: RemoteEvent
local Premio = remotos:WaitForChild("Premio") :: RemoteEvent

local ICONO_TIPO: { [string]: string } = { Hallazgo = "Gema", Evento = "Reloj", Jefe = "Jefe" }

Anuncio.OnClientEvent:Connect(function(texto: unknown, color: unknown, tipo: unknown)
	if typeof(texto) ~= "string" then
		return
	end
	local clase = if typeof(tipo) == "string" then tipo else "Hallazgo"
	if clase == "Hallazgo" and jugador:GetAttribute("VerAnuncios") == false then
		return
	end
	local ok, c = pcall(Color3.fromHex, if typeof(color) == "string" then color else "#FFC93C")
	-- SONIDO: anuncio a todo el servidor
	Sonidos.tocar(GameConfig.Sonidos.Anuncio)
	Avisos.mostrar({
		Titulo = if clase == "Evento"
			then "¡EVENTO!"
			elseif clase == "Jefe" then "¡JEFE ANCESTRAL!"
			else "¡ATENCIÓN!",
		Texto = texto,
		Color = if ok then c else nil,
		Duracion = 4,
		Icono = ICONO_TIPO[clase],
	})
end)

Aviso.OnClientEvent:Connect(function(texto: unknown)
	if typeof(texto) == "string" then
		Avisos.mostrar({
			Titulo = "Aviso",
			Texto = texto,
			Color = Color3.fromHex("#3FA9FF"),
			Duracion = 3,
		})
	end
end)

Hitos.OnClientEvent:Connect(function(lista: unknown)
	if typeof(lista) == "table" then
		Avisos.hitos(lista :: { Avisos.Hito })
	end
end)

-- "+X Monedas" que sube desde abajo del centro de la pantalla.
local pantalla = Estilo.pantalla("Premios", 5)
pantalla.Parent = jugador:WaitForChild("PlayerGui")

Premio.OnClientEvent:Connect(function(monto: unknown)
	if typeof(monto) ~= "number" then
		return
	end
	-- SONIDO: monedas (cristal de la lluvia o premio de evento)
	Sonidos.tocar(GameConfig.Sonidos.Cristal, 1 + math.random() * 0.2)
	local f =
		Estilo.conIconos({ "Moneda" }, "+" .. Formato.corto(monto), 40, Color3.fromHex("#7CFF3C"))
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * 0.15, 0.72)
	f.Parent = pantalla
	TweenService:Create(
		f,
		TweenInfo.new(1, Enum.EasingStyle.Quad),
		{ Position = f.Position - UDim2.fromScale(0, 0.12) }
	):Play()
	task.delay(1, function()
		f:Destroy()
	end)
end)
