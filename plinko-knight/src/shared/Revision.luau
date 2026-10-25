--!strict
-- Revisión del daño de un tiro, sin Instances (la usa server/Tiros y la prueba con Lune).
-- Repite la simulación con el ángulo del cliente y la semilla y las mejoras que sabe el servidor.
-- El daño que vale es SIEMPRE el del servidor (con tope): como es el mismo módulo, en un tiro
-- normal coincide con el del cliente. Si el del cliente difiere más del margen, se marca para
-- avisar en la consola, pero no se castiga al jugador.

local Config = require(script.Parent.Config)
local Simulacion = require(script.Parent.Simulacion)
local TableroModulo = require(script.Parent.Tablero)

export type Revisado = {
	Danio: number, -- el que vale
	DanioServidor: number, -- el de la simulación del servidor, sin tope
	Corregido: boolean, -- el del cliente difería más del margen
	Quemadura: number, -- daño por turno que deja la bola de fuego (0 sin fuego)
}

local Revision = {}

function Revision.revisar(
	tablero: TableroModulo.Tablero,
	angulo: number,
	semilla: number,
	mejoras: Simulacion.Mejoras,
	danioVisto: number
): Revisado
	local res = Simulacion.simular(tablero, angulo, Config.Bola, mejoras, semilla)
	local servidor = res.Danio
	local margen = math.max(servidor, 1) * Config.Servidor.MargenDanio
	return {
		Danio = math.min(servidor, Config.Servidor.TopeDanioPorTiro),
		DanioServidor = servidor,
		Corregido = math.abs(danioVisto - servidor) > margen,
		Quemadura = res.Quemadura,
	}
end

return Revision
