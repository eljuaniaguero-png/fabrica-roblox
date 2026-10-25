--!strict
-- Reglas de la mazmorra, sin Instances (las usa server/Partida y la prueba con Lune).
-- Un turno: el daño del tiro le pega al monstruo; si sigue vivo, contraataca. Al ganar una
-- pelea se pasa al piso siguiente y el caballero se cura; al ganarle al jefe termina la mazmorra.

local Config = require(script.Parent.Config)

export type Fase = "peleando" | "perdio" | "gano"

-- Lo que el servidor le manda al cliente para dibujar la pelea.
export type Estado = {
	Piso: number,
	Vida: number, -- del caballero
	VidaMaxima: number,
	VidaMonstruo: number,
	Fase: Fase,
}

-- "sigue": el monstruo sigue vivo · "piso": lo mataste y bajás · "perdio" · "gano" (el jefe)
export type Resultado = "sigue" | "piso" | "perdio" | "gano"

export type Turno = {
	Danio: number,
	VidaMonstruo: number, -- después del golpe (0 si murió)
	Golpe: number, -- lo que te sacó el contraataque (0 si no hubo)
	VidaCaballero: number, -- después del contraataque, antes de curarse
	Resultado: Resultado,
	Estado: Estado, -- cómo queda todo después del turno (piso nuevo incluido)
}

local Mazmorra = {}

function Mazmorra.monstruo(piso: number): Config.Monstruo
	return Config.Monstruos[math.clamp(piso, 1, #Config.Monstruos)]
end

function Mazmorra.nueva(): Estado
	return {
		Piso = 1,
		Vida = Config.VidaCaballero,
		VidaMaxima = Config.VidaCaballero,
		VidaMonstruo = Mazmorra.monstruo(1).Vida,
		Fase = "peleando",
	}
end

function Mazmorra.copiar(e: Estado): Estado
	return table.clone(e)
end

-- Para el comando de prueba: arranca la pelea del piso pedido con el monstruo entero.
function Mazmorra.irAPiso(e: Estado, piso: number)
	e.Piso = math.clamp(math.floor(piso), 1, #Config.Monstruos)
	e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
	e.Fase = "peleando"
end

-- Aplica un tiro (modifica el estado) y devuelve qué pasó, para que el cliente lo anime.
function Mazmorra.turno(e: Estado, danio: number): Turno
	local monstruo = Mazmorra.monstruo(e.Piso)
	e.VidaMonstruo = math.max(e.VidaMonstruo - math.max(danio, 0), 0)
	local vidaMonstruo = e.VidaMonstruo
	local golpe = 0
	local resultado: Resultado

	if vidaMonstruo > 0 then
		golpe = monstruo.Golpe
		e.Vida = math.max(e.Vida - golpe, 0)
		if e.Vida == 0 then
			e.Fase = "perdio"
			resultado = "perdio"
		else
			resultado = "sigue"
		end
	elseif e.Piso >= #Config.Monstruos then
		e.Fase = "gano"
		resultado = "gano"
	else
		resultado = "piso"
	end
	local vidaCaballero = e.Vida

	if resultado == "piso" then
		e.Piso += 1
		e.VidaMonstruo = Mazmorra.monstruo(e.Piso).Vida
		e.Vida = math.min(e.Vida + Config.CuraEntrePeleas, e.VidaMaxima)
	end

	return {
		Danio = danio,
		VidaMonstruo = vidaMonstruo,
		Golpe = golpe,
		VidaCaballero = vidaCaballero,
		Resultado = resultado,
		Estado = Mazmorra.copiar(e),
	}
end

return Mazmorra
