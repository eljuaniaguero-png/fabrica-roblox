--!strict
-- Chequeos de las reglas de fusión. Se corren al iniciar el servidor e imprimen el resultado.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Shared.Fusion)

local errores = 0
local function chequear(ok: boolean, mensaje: string)
	if not ok then
		errores += 1
		warn("[Pruebas] FALLA: " .. mensaje)
	end
end

local todas = Fusion.todas()
chequear(#todas == 50, "hay " .. #todas .. " especies, se esperaban 50")

local nombres, claves = {}, {}
for _, c in todas do
	chequear(not nombres[c.Nombre], "nombre repetido: " .. c.Nombre)
	chequear(not claves[c.Clave], "clave repetida: " .. c.Clave)
	nombres[c.Nombre] = true
	claves[c.Clave] = c
end

-- Todas las parejas de criaturas: el orden no importa y todo resultado está en la lista.
local reacciones = 0
for _, x in todas do
	for _, y in todas do
		local r1, r2 = Fusion.fusionar(x, y), Fusion.fusionar(y, x)
		chequear(
			(r1 and r1.Clave) == (r2 and r2.Clave),
			x.Nombre .. " + " .. y.Nombre .. " depende del orden"
		)
		if r1 then
			reacciones += 1
			local registrada = claves[r1.Clave]
			chequear(
				registrada ~= nil and registrada.Nombre == r1.Nombre,
				"resultado fuera de la lista: " .. r1.Nombre
			)
		end
	end
end
-- 30 parejas de bases + 30 caminos a gen 3, contadas en los dos órdenes.
chequear(reacciones == 120, "reacciones: " .. reacciones .. ", se esperaban 120")

print(("[Pruebas] Fusión: %d especies, %d errores"):format(#todas, errores))
