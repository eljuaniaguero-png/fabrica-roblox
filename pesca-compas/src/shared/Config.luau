--!strict
-- Números de balance de Pesca al Compás (ficha v2). Todo lo que se ajusta, va acá.
-- Regla: ninguna mejora ni compra cambia las probabilidades de rareza. Son fijas y se muestran.

export type Rareza = {
	Id: string,
	Chance: number, -- 0 a 1; suman 1
	Color: Color3,
	PrecioKg: number, -- Escamas por kilo
	XP: number,
}

export type Pez = {
	Id: string,
	Nombre: string,
	Rareza: string,
	Isla: number,
	Color: Color3,
	PesoMin: number, -- kg
	PesoMax: number,
	Bpm: number,
	BpmFinal: number?, -- si está, el tempo cambia a la mitad del patrón (míticos)
	Duraciones: { number }, -- beats entre una nota y la siguiente (1 = negra, 0.5 = corchea)
	Jefe: boolean?, -- solo sale en la Hora del jefe (todavía no programada)
}

local Config = {}

Config.Rarezas = {
	{ Id = "Común", Chance = 0.60, Color = Color3.fromRGB(200, 215, 230), PrecioKg = 4, XP = 5 },
	{ Id = "Raro", Chance = 0.25, Color = Color3.fromRGB(70, 170, 255), PrecioKg = 12, XP = 12 },
	{ Id = "Épico", Chance = 0.10, Color = Color3.fromRGB(190, 90, 255), PrecioKg = 40, XP = 30 },
	{ Id = "Legendario", Chance = 0.04, Color = Color3.fromRGB(255, 190, 40), PrecioKg = 150, XP = 80 },
	{ Id = "Mítico", Chance = 0.01, Color = Color3.fromRGB(255, 70, 150), PrecioKg = 600, XP = 250 },
} :: { Rareza }

-- Isla 1 · Muelle Pastel (80-95 BPM). Los patrones son fijos: cada pez se aprende.
Config.Peces = {
	{
		Id = "MojarraGlobo",
		Nombre = "Mojarra Globo",
		Rareza = "Común",
		Isla = 1,
		Color = Color3.fromRGB(120, 200, 255),
		PesoMin = 0.4,
		PesoMax = 1.2,
		Bpm = 80,
		Duraciones = { 1, 1, 1, 1, 1, 1 },
	},
	{
		Id = "SardinaMaraca",
		Nombre = "Sardina Maraca",
		Rareza = "Común",
		Isla = 1,
		Color = Color3.fromRGB(255, 230, 120),
		PesoMin = 0.3,
		PesoMax = 0.9,
		Bpm = 85,
		Duraciones = { 1, 1, 0.5, 0.5, 1, 1, 1 },
	},
	{
		Id = "PejerreyFlauta",
		Nombre = "Pejerrey Flauta",
		Rareza = "Raro",
		Isla = 1,
		Color = Color3.fromRGB(120, 255, 170),
		PesoMin = 0.8,
		PesoMax = 2.0,
		Bpm = 88,
		Duraciones = { 1, 0.5, 0.5, 1, 0.5, 0.5, 1, 1 },
	},
	{
		Id = "CangrejoCastanuela",
		Nombre = "Cangrejo Castañuela",
		Rareza = "Raro",
		Isla = 1,
		Color = Color3.fromRGB(255, 110, 80),
		PesoMin = 0.6,
		PesoMax = 1.6,
		Bpm = 90,
		Duraciones = { 0.5, 0.5, 1, 0.5, 0.5, 1, 1.5, 0.5, 1 },
	},
	{
		Id = "GloboBombo",
		Nombre = "Pez Globo Bombo",
		Rareza = "Épico",
		Isla = 1,
		Color = Color3.fromRGB(190, 120, 255),
		PesoMin = 1.5,
		PesoMax = 4.0,
		Bpm = 92,
		Duraciones = { 1, 0.5, 0.5, 0.75, 0.25, 1, 0.5, 0.5, 0.75, 0.25, 1 },
	},
	{
		Id = "AnguilaTeclado",
		Nombre = "Anguila Teclado",
		Rareza = "Legendario",
		Isla = 1,
		Color = Color3.fromRGB(40, 40, 60),
		PesoMin = 2.0,
		PesoMax = 6.0,
		Bpm = 95,
		Duraciones = { 0.5, 0.5, 0.5, 0.5, 1, 0.75, 0.25, 0.5, 0.5, 1, 0.5, 0.5, 1 },
	},
	{
		Id = "PulpoDJ",
		Nombre = "Pulpo DJ",
		Rareza = "Mítico",
		Isla = 1,
		Color = Color3.fromRGB(255, 80, 200),
		PesoMin = 3.0,
		PesoMax = 9.0,
		Bpm = 90,
		BpmFinal = 120,
		Duraciones = { 1, 0.5, 0.5, 1, 0.75, 0.25, 1, 0.5, 0.5, 0.5, 0.5, 0.75, 0.25, 1, 1 },
	},
	{
		Id = "BallenaBandoneon",
		Nombre = "Ballena Bandoneón",
		Rareza = "Legendario",
		Isla = 1,
		Color = Color3.fromRGB(80, 110, 200),
		PesoMin = 40,
		PesoMax = 90,
		Bpm = 85,
		Duraciones = { 1, 1, 0.5, 0.5, 1, 0.5, 0.5, 1, 1, 0.5, 0.5, 0.5, 0.5, 1, 1, 0.5, 0.5, 2 },
		Jefe = true,
	},
} :: { Pez }

-- Minijuego (ficha, sección 4)
Config.TensionInicial = 0.5
Config.PerfectoBase = 0.060 -- segundos de margen, antes y después de la nota
Config.BienBase = 0.130
Config.VentanaPorNivel = 0.010 -- cada nivel de caña agranda las dos ventanas
Config.PerfectoTope = 0.100
Config.BienTope = 0.200
Config.AfinadoPerfectos = 0.8 -- 0 errores y 80% de Perfectos
Config.RachaLargo = 5 -- aciertos seguidos para la racha
Config.RachaBonus = 0.10 -- +10% de Escamas
Config.CuentaRegresiva = 1.5 -- segundos de "¡PICÓ!" antes de la primera nota
Config.ToqueMinimo = 0.06 -- dos toques más juntos que esto = imposible para un humano

-- Lanzar y esperar
Config.CargaMax = 1.2 -- segundos de mantener para tirar al máximo
Config.EsperaMin = 2
Config.EsperaMax = 5
Config.DistanciaPesca = 14 -- studs desde un PuntoPesca para poder tirar
Config.BoyaCerca = 8 -- studs desde el punto, con carga 0
Config.BoyaLejos = 28 -- con carga 1
Config.PesoPorCarga = 0.5 -- lanzar al máximo da peces hasta 50% más pesados (no más raros)

-- Primeros 5 minutos
Config.EsperaPrimeraTirada = 1
Config.TiradaRaroGarantizado = 3

-- Mejoras (se pagan con Escamas). El índice es el nivel.
Config.PrecioCana = { 0, 25, 70, 160, 350, 700, 1300, 2400, 4200, 7000 }
Config.CapacidadBalde = { 10, 15, 20, 25, 30, 40, 50, 60 }
Config.PrecioBalde = { 0, 40, 120, 300, 650, 1300, 2500, 4500 }

-- Cebos (casa "CEBO & CAÑAS"). Respetan la regla de arriba: NO cambian la rareza. Solo hacen
-- picar más rápido (Espera multiplica el tiempo de espera) y dan peces más pesados (Peso
-- multiplica los kg, y el precio va por kg). Se gastan de a una tirada cuando el pez pica.
-- Comprar el mismo cebo suma tiradas; comprar otro reemplaza al que tenías.
export type Cebo = {
	Id: string,
	Nombre: string,
	Detalle: string, -- lo que lee el jugador en la tienda
	Precio: number, -- Escamas
	Tiradas: number,
	Espera: number,
	Peso: number,
	Color: Color3,
}

Config.Cebos = {
	{
		Id = "Lombriz",
		Nombre = "Lombriz Bailarina",
		Detalle = "Pican el doble de rápido",
		Precio = 15,
		Tiradas = 10,
		Espera = 0.5,
		Peso = 1,
		Color = Color3.fromRGB(255, 140, 170),
	},
	{
		Id = "Camaron",
		Nombre = "Camarón Groovy",
		Detalle = "Más rápido y peces +25% kg",
		Precio = 45,
		Tiradas = 10,
		Espera = 0.75,
		Peso = 1.25,
		Color = Color3.fromRGB(255, 160, 80),
	},
	{
		Id = "Calamar",
		Nombre = "Calamar Disco",
		Detalle = "El doble de rápido y peces +50% kg",
		Precio = 120,
		Tiradas = 10,
		Espera = 0.5,
		Peso = 1.5,
		Color = Color3.fromRGB(190, 110, 255),
	},
} :: { Cebo }
Config.CeboTiradasMax = 50 -- tope de tiradas acumuladas de un mismo cebo
Config.DistanciaTienda = 14 -- studs desde la puerta de la tienda para poder comprar

-- Robux (server/Monetizacion.luau). Id = 0 = todavía no creado en el Creator Dashboard: queda
-- apagado y no se puede comprar. Solo conveniencia o cosmético: nada cambia la rareza ni saltea
-- el ritmo. Al crear el producto/pase, pegar el id acá y listo.
export type Producto = { Id: number, Nombre: string, Cebo: string, Tiradas: number }
Config.Productos = {
	PackCalamar = { Id = 0, Nombre = "Pack Calamar Disco x30", Cebo = "Calamar", Tiradas = 30 },
} :: { [string]: Producto }
-- Pases: el jugador recibe el atributo "Pase_<clave>" = true (lo leen Equipo y la UI).
Config.Pases = {
	CarreteDorado = 0, -- cosmético: carrete dorado brillante en cualquier nivel de caña
} :: { [string]: number }

-- Premio diario (ficha, sección 7): Escamas por día de racha. Si saltea un día, vuelve al 1.
-- PENDIENTE: el día 7 también da una caña cosmética cuando existan los cosméticos.
Config.PremioDiario = { 20, 30, 45, 60, 80, 110, 200 }

-- Museo: premio único por isla al sacar todos sus peces (los jefes no cuentan: no salen al
-- sortear y tendrán su propio trofeo). Isla 1 = los 7 peces sin la Ballena.
Config.PremioMuseo = { 400 }

-- XP para pasar del nivel n al n+1
function Config.xpParaSubir(nivel: number): number
	return 20 + 15 * (nivel - 1)
end

-- Desfase de calibración permitido (segundos). Más que esto es un error de la prueba.
Config.DesfaseMax = 0.35
Config.CalibracionGolpes = 8
Config.CalibracionBpm = 100

-- Melodía: pentatónica mayor en semitonos desde la nota base (siempre suena bien)
Config.Escala = { 0, 2, 4, 7, 9, 12, 14, 16, 19, 21 }

-- SONIDO: nota base que se afina con PlaybackSpeed. Verificar en Studio que el id suene; si no, cambiarlo.
Config.SonidoNotaId = "rbxassetid://96243649310055"
-- SONIDO: vacío = no suena. Van cuando haya sonidos propios.
Config.SonidoLanzarId = ""
Config.SonidoPicoId = ""
Config.SonidoSacadoId = ""
Config.SonidoEscapoId = ""
Config.SonidoErrorId = ""

return Config
