--!strict
-- Los íconos de la interfaz (sin emojis). Los dibujos están en shared/Dibujos.luau, porque
-- también se usan en el mundo; las pantallas los piden siempre por acá.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return require(ReplicatedStorage.Shared.Dibujos)
