--!strict
-- Carga y guarda el progreso de cada jugador.
-- Si DataStore no está disponible (por ejemplo, lugar sin publicar), guarda solo en memoria y avisa.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

export type Perfil = {
	Velocidad: number,
	Rebirths: number,
	Checkpoint: number,
	Monedas: number,
	Mejoras: { [string]: number },
	Inventario: { [string]: number },
}

local Datos = {}

local perfiles: { [Player]: Perfil } = {}
local almacen: DataStore? = nil
local modoMemoria = false

local function avisarModoMemoria(motivo: string)
	if modoMemoria then
		return
	end
	modoMemoria = true
	warn(`[Datos] DataStore no disponible ({motivo}). El progreso se guarda solo en memoria.`)
end

local okAlmacen, resultado = pcall(function()
	return DataStoreService:GetDataStore(Config.NombreDataStore)
end)
if okAlmacen then
	almacen = resultado
else
	avisarModoMemoria(tostring(resultado))
end

local function clave(jugador: Player): string
	return `jugador_{jugador.UserId}`
end

local function numeroO(valor: any, porDefecto: number): number
	if typeof(valor) == "number" and valor == valor and valor >= 0 then
		return valor
	end
	return porDefecto
end

function Datos.cargar(jugador: Player): Perfil
	local guardado: any = nil
	if almacen and not modoMemoria then
		local ok, valor = pcall(function()
			return almacen:GetAsync(clave(jugador))
		end)
		if ok then
			guardado = valor
		else
			avisarModoMemoria(tostring(valor))
		end
	end

	local perfil: Perfil = {
		Velocidad = 0,
		Rebirths = 0,
		Checkpoint = 0,
		Monedas = 0,
		Mejoras = {},
		Inventario = {},
	}
	if typeof(guardado) == "table" then
		perfil.Velocidad = numeroO(guardado.Velocidad, 0)
		perfil.Rebirths = numeroO(guardado.Rebirths, 0)
		perfil.Checkpoint = numeroO(guardado.Checkpoint, 0)
		perfil.Monedas = numeroO(guardado.Monedas, 0)
	end
	local mejorasGuardadas = if typeof(guardado) == "table" then guardado.Mejoras else nil
	for _, nombre in Config.OrdenMejoras do
		local nivel = if typeof(mejorasGuardadas) == "table" then mejorasGuardadas[nombre] else nil
		-- Guardados viejos tenían Zapatillas suelto en el perfil.
		if nivel == nil and nombre == "Zapatillas" and typeof(guardado) == "table" then
			nivel = guardado.Zapatillas
		end
		perfil.Mejoras[nombre] = math.min(numeroO(nivel, 0), Config.Mejoras[nombre].NivelMaximo)
	end
	local inventarioGuardado = if typeof(guardado) == "table" then guardado.Inventario else nil
	for _, nombre in Config.OrdenConsumibles do
		local cantidad = if typeof(inventarioGuardado) == "table"
			then inventarioGuardado[nombre]
			else 0
		perfil.Inventario[nombre] = math.min(numeroO(cantidad, 0), Config.InventarioMaximo)
	end

	perfiles[jugador] = perfil
	return perfil
end

function Datos.obtener(jugador: Player): Perfil?
	return perfiles[jugador]
end

function Datos.guardar(jugador: Player)
	local perfil = perfiles[jugador]
	if not perfil or not almacen or modoMemoria then
		return
	end
	local ok, err = pcall(function()
		almacen:SetAsync(clave(jugador), perfil)
	end)
	if not ok then
		warn(`[Datos] No se pudo guardar a {jugador.Name}: {err}`)
	end
end

function Datos.olvidar(jugador: Player)
	perfiles[jugador] = nil
end

return Datos
