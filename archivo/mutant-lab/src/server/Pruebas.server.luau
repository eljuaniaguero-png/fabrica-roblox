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

-- Especies de equipo (Parte 9): 10, con nombre y clave propios, y que solo salen en equipo.
local equipo = Fusion.deEquipo()
chequear(#equipo == 10, "hay " .. #equipo .. " especies de equipo, se esperaban 10")
for _, c in equipo do
	chequear(not nombres[c.Nombre], "nombre de equipo repetido: " .. c.Nombre)
	chequear(not claves[c.Clave], "clave de equipo repetida: " .. c.Clave)
	nombres[c.Nombre] = true
	claves[c.Clave] = c
	local x, y = Fusion.porClave(tostring(c.Bases[1])), Fusion.porClave(tostring(c.Bases[2]))
	if x and y then
		chequear(Fusion.fusionar(x, y) == nil, c.Nombre .. " sale en una máquina común")
		local r = Fusion.equipo(x, y)
		chequear(r ~= nil and r.Clave == c.Clave, c.Nombre .. " no sale en la máquina de equipo")
	end
end

print(("[Pruebas] Fusión: %d especies, %d errores"):format(#todas, errores))
