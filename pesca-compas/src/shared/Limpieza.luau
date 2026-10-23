--!strict
-- Maid mínimo: junta conexiones, instancias, tweens y funciones, y los suelta todos juntos con
-- :limpiar(). Para efectos temporales (el pez en la mano, la vitrina) que no pueden quedar
-- colgados si el personaje muere o llega otro pez antes de que termine la animación.

export type Tarea = RBXScriptConnection | Instance | Tween | () -> ()

export type Limpieza = {
	tareas: { Tarea },
	dar: <T>(self: Limpieza, tarea: T) -> T,
	limpiar: (self: Limpieza) -> (),
}

local Limpieza = {}
Limpieza.__index = Limpieza

function Limpieza.nueva(): Limpieza
	return (setmetatable({ tareas = {} }, Limpieza) :: any) :: Limpieza
end

function Limpieza.dar<T>(self: Limpieza, tarea: T): T
	table.insert(self.tareas, tarea :: any)
	return tarea
end

function Limpieza.limpiar(self: Limpieza)
	local tareas = self.tareas
	self.tareas = {}
	-- al revés: lo último que se creó se suelta primero (los hijos antes que el padre)
	for i = #tareas, 1, -1 do
		local t = tareas[i]
		if typeof(t) == "RBXScriptConnection" then
			(t :: RBXScriptConnection):Disconnect()
		elseif typeof(t) == "Instance" then
			local inst = t :: Instance
			if inst:IsA("Tween") then -- un Tween también es Instance: primero frenarlo
				(inst :: Tween):Cancel()
			end
			inst:Destroy()
		elseif type(t) == "function" then
			(t :: () -> ())()
		end
	end
end

return Limpieza
