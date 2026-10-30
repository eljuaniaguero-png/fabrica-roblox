-- Pegar en la Command Bar de Studio (View > Command Bar) con Rojo conectado.
-- Arma las 5 animaciones de shared/AnimBorrador como KeyframeSequence en
-- ServerStorage.AnimacionesPesca. Para publicar cada una: clic derecho > "Save to Roblox",
-- copiar el id y pegarlo en el campo Id de src/shared/Animaciones.luau.
-- Para retocarlas a mano: Animation Editor sobre un rig R15 > Import > From Roblox (con el id).
local AnimBorrador = require(game.ReplicatedStorage.Shared.AnimBorrador)
local carpeta = game.ServerStorage:FindFirstChild("AnimacionesPesca") or Instance.new("Folder")
carpeta.Name = "AnimacionesPesca"
carpeta.Parent = game.ServerStorage
for _, nombre in { "Esperar", "Recoger", "Lanzar", "Levantar", "Fallar" } do
	local vieja = carpeta:FindFirstChild(nombre)
	if vieja then
		vieja.Parent = nil -- se reemplaza por la versión nueva (queda en el historial de Ctrl+Z)
	end
	local secuencia = AnimBorrador.construir(nombre)
	if secuencia then
		secuencia.Parent = carpeta
	end
end
print("Listo: ServerStorage.AnimacionesPesca tiene las 5 animaciones")
