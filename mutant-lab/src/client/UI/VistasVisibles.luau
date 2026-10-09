--!strict
-- Vistas 3D solo para las tarjetas que están en pantalla (rendimiento en celular).
-- Cada lista desplazable tiene un grupo: las tarjetas se anotan con su hueco y su criatura,
-- y el grupo les presta una ViewportFrame solo mientras se ven. Al desplazar, las vistas que
-- salen de pantalla vuelven a una pila y se reutilizan; si la que vuelve ya mostraba esa misma
-- criatura, no se vuelve a armar.

local Vista = require(script.Parent.Parent.Vista)

export type Datos = {
	Clave: string,
	Mutante: boolean?,
	Silueta: boolean?,
}

type Entrada = {
	Item: GuiObject, -- la tarjeta (lo que se mide para saber si está en pantalla)
	Hueco: GuiObject, -- dónde va la vista
	Datos: Datos,
	Vista: ViewportFrame?,
}

export type Grupo = {
	agregar: (item: GuiObject, hueco: GuiObject, datos: Datos) -> (),
	cambiar: (item: GuiObject, datos: Datos) -> (),
	quitar: (item: GuiObject) -> (),
	actualizar: () -> (),
	cantidadVistas: () -> number,
}

local VistasVisibles = {}

local function marca(d: Datos): string
	return d.Clave .. (if d.Mutante then "M" else "") .. (if d.Silueta then "S" else "")
end

-- true si el objeto y todos los que lo contienen están visibles.
local function enPantalla(g: Instance): boolean
	local actual: Instance? = g
	while actual and actual:IsA("GuiObject") do
		if not actual.Visible then
			return false
		end
		actual = actual.Parent
	end
	return actual ~= nil
end

function VistasVisibles.nueva(scroll: ScrollingFrame): Grupo
	local entradas: { [GuiObject]: Entrada } = {}
	local libres: { ViewportFrame } = {}
	local creadas = 0
	local pendiente = false

	local function tomar(m: string): ViewportFrame
		for i, v in libres do
			if v:GetAttribute("Marca") == m then
				table.remove(libres, i)
				return v
			end
		end
		local v = table.remove(libres)
		if v then
			return v
		end
		local nueva = Instance.new("ViewportFrame")
		nueva.Name = "Vista3D"
		nueva.BackgroundTransparency = 1
		nueva.Size = UDim2.fromScale(1, 1)
		creadas += 1
		return nueva
	end

	local function poner(e: Entrada)
		local m = marca(e.Datos)
		local v = e.Vista or tomar(m)
		e.Vista = v
		if v:GetAttribute("Marca") ~= m then
			Vista.mostrar(v, e.Datos.Clave, e.Datos.Mutante, e.Datos.Silueta)
			v:SetAttribute("Marca", m)
		end
		v.Parent = e.Hueco
	end

	local function soltar(e: Entrada)
		local v = e.Vista
		if v then
			v.Parent = nil
			table.insert(libres, v)
			e.Vista = nil
		end
	end

	local function actualizar()
		pendiente = false
		if not enPantalla(scroll) then
			return
		end
		local pos, tam = scroll.AbsolutePosition, scroll.AbsoluteSize
		-- Un poco de margen, así las que están por entrar ya tienen su vista.
		local arriba, abajo = pos.Y - tam.Y * 0.4, pos.Y + tam.Y * 1.4
		local izq, der = pos.X - tam.X * 0.4, pos.X + tam.X * 1.4
		local fuera: { Entrada } = {}
		local dentro: { Entrada } = {}
		for item, e in entradas do
			local p, s = item.AbsolutePosition, item.AbsoluteSize
			local ve = item.Visible
				and item.Parent ~= nil
				and p.Y + s.Y >= arriba
				and p.Y <= abajo
				and p.X + s.X >= izq
				and p.X <= der
			table.insert(if ve then dentro else fuera, e)
		end
		-- Primero se liberan las que salieron, así las que entran las reutilizan.
		for _, e in fuera do
			soltar(e)
		end
		for _, e in dentro do
			poner(e)
		end
	end

	local function programar()
		if pendiente then
			return
		end
		pendiente = true
		task.defer(actualizar)
	end

	scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(programar)
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(programar)
	scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(programar)

	return {
		agregar = function(item: GuiObject, hueco: GuiObject, datos: Datos)
			entradas[item] = { Item = item, Hueco = hueco, Datos = datos, Vista = nil }
			programar()
		end,
		cambiar = function(item: GuiObject, datos: Datos)
			local e = entradas[item]
			if e and marca(e.Datos) ~= marca(datos) then
				e.Datos = datos
				if e.Vista then
					poner(e)
				end
			end
		end,
		quitar = function(item: GuiObject)
			local e = entradas[item]
			if e then
				soltar(e)
				entradas[item] = nil
			end
		end,
		actualizar = programar,
		cantidadVistas = function(): number
			return creadas
		end,
	}
end

return VistasVisibles
