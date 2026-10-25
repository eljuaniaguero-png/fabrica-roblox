--!strict
-- Datos de cada jugador en memoria. Guardado.luau los carga y los guarda; acá solo se leen,
-- se cambian y se le mandan al cliente.

local Remotos = require(script.Parent.Remotos)
local Ritmo = require(game:GetService("ReplicatedStorage").Shared.Ritmo)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local ListaMisiones = require(game:GetService("ReplicatedStorage").Shared.ListaMisiones)

export type PezGuardado = { Id: string, Peso: number, Afinado: boolean }

export type Datos = {
	Escamas: number,
	XP: number,
	Cana: number, -- nivel 1..#Config.PrecioCana
	Balde: number, -- nivel 1..#Config.CapacidadBalde
	Cubeta: { PezGuardado }, -- lo que hay en el balde ahora
	Vistos: { [string]: boolean }, -- museo: peces sacados alguna vez
	Afinados: { [string]: boolean }, -- museo: versiones Afinadas
	Tiradas: number, -- veces que llegó al ritmo (para los primeros 5 minutos)
	Sacados: number,
	MasPesado: number, -- kg
	Desfase: number, -- calibración del dispositivo, en segundos
	Calibrado: boolean,
	Mision: number, -- índice en ListaMisiones (1 = la primera)
	MisionProgreso: number,
	DiarioDia: number, -- día UTC (os.time() // 86400) del último premio diario; 0 = nunca
	DiarioRacha: number, -- 1..#Config.PremioDiario
	MuseoCobrado: { [string]: boolean }, -- isla (como texto: "1") -> ya cobró el premio del museo
	Cebo: string, -- Id en Config.Cebos; "" = sin cebo
	CeboTiradas: number,
	Compras: { string }, -- últimos PurchaseId de Robux ya entregados (no entregar dos veces)
}

local Jugadores = {}

local datosDe: { [Player]: Datos } = {}

-- Se llama cada vez que cambia algo y se manda el estado (lo usa Equipo para repintar la caña y
-- cambiar el cebo). Es un gancho para no requerir Equipo desde acá: Equipo ya requiere Jugadores.
Jugadores.alEnviar = nil :: ((jugador: Player, d: Datos) -> ())?

function Jugadores.nuevos(): Datos
	return {
		Escamas = 0,
		XP = 0,
		Cana = 1,
		Balde = 1,
		Cubeta = {},
		Vistos = {},
		Afinados = {},
		Tiradas = 0,
		Sacados = 0,
		MasPesado = 0,
		Desfase = 0,
		Calibrado = false,
		Mision = 1,
		MisionProgreso = 0,
		DiarioDia = 0,
		DiarioRacha = 0,
		MuseoCobrado = {},
		Cebo = "",
		CeboTiradas = 0,
		Compras = {},
	}
end

function Jugadores.crear(jugador: Player, datos: Datos)
	datosDe[jugador] = datos
	Jugadores.enviar(jugador)
end

function Jugadores.obtener(jugador: Player): Datos?
	return datosDe[jugador]
end

function Jugadores.quitar(jugador: Player)
	datosDe[jugador] = nil
end

function Jugadores.capacidad(d: Datos): number
	return Config.CapacidadBalde[d.Balde] or Config.CapacidadBalde[#Config.CapacidadBalde]
end

-- Manda al cliente lo que necesita el HUD.
function Jugadores.enviar(jugador: Player)
	local d = datosDe[jugador]
	if not d then
		return
	end
	local nivel, xpNivel, xpSiguiente = Ritmo.nivel(d.XP)
	local mision = ListaMisiones.obtener(d.Mision)
	Remotos.Estado:FireClient(jugador, {
		Mision = {
			Texto = ListaMisiones.texto(mision),
			Progreso = d.MisionProgreso,
			Meta = mision.Meta,
			Premio = mision.Premio,
		},
		DiarioRacha = d.DiarioRacha,
		Escamas = d.Escamas,
		Nivel = nivel,
		XPNivel = xpNivel,
		XPSiguiente = xpSiguiente,
		Cana = d.Cana,
		PrecioCana = Config.PrecioCana[d.Cana + 1], -- nil = nivel máximo
		Balde = d.Balde,
		PrecioBalde = Config.PrecioBalde[d.Balde + 1],
		EnBalde = #d.Cubeta,
		Cubeta = d.Cubeta, -- barra del balde (como mucho 60 peces, cabe de sobra en un evento)
		Capacidad = Jugadores.capacidad(d),
		Vistos = d.Vistos,
		Afinados = d.Afinados,
		Desfase = d.Desfase,
		Calibrado = d.Calibrado,
		Cebo = if d.CeboTiradas > 0 then d.Cebo else nil,
		CeboTiradas = d.CeboTiradas,
	})
	local gancho = Jugadores.alEnviar
	if gancho then
		gancho(jugador, d)
	end
end

return Jugadores
