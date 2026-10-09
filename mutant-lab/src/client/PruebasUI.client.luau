--!strict
-- Herramientas para probar la interfaz en Studio (no hacen nada en el juego normal).
-- Se activan con atributos del jugador, que se ponen desde la consola del servidor:
--   MuestraUI = true          abre la pantalla de muestra con todos los componentes.
--   SimularPantalla = Vector2 simula una pantalla de ese tamaño (por ejemplo 844 × 390, un
--                             celular apaisado). Vector2.zero vuelve a la pantalla normal.

local Players = game:GetService("Players")

local UI = require(script.Parent.UI)

local jugador = Players.LocalPlayer

jugador:GetAttributeChangedSignal("MuestraUI"):Connect(function()
	if jugador:GetAttribute("MuestraUI") then
		require(script.Parent.UI.Muestra).abrir()
	end
end)

jugador:GetAttributeChangedSignal("SimularPantalla"):Connect(function()
	local tam = jugador:GetAttribute("SimularPantalla") :: Vector2?
	if tam and tam.X > 0 then
		UI.Pantalla.simular(tam, tam.Y < 500)
	else
		UI.Pantalla.simular(nil, nil)
	end
end)
