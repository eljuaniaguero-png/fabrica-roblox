--!strict
-- Datos de las animaciones del ciclo de pesca. Solo datos: el que las reproduce es
-- client/AnimPesca. Para cambiar una animación se pega el id acá y no se toca código.
-- Id vacío = todavía no está publicada: Levantar usa una pose procedural de respaldo y el
-- resto no se reproduce (el juego sigue funcionando igual).
--
-- Marcadores (los pone el animador en el Animation Editor, como "Animation Event"):
--   Levantar: "Agarrar" en 0.55 s (el pez llega a la cabeza, ver SALTO en Captura.client),
--             "VFX" en 0.55 s (salpicadura de gotas), "Bajar" en 2.6 s (empieza a bajar).
--   Lanzar:   "Soltar" en el frame en que la caña apunta al agua (todavía nadie lo escucha).
-- Esperar y Recoger: solo torso para arriba, así las piernas siguen con la animación de caminar.

export type Anim = {
	Id: string,
	Prioridad: Enum.AnimationPriority,
	Loop: boolean,
	Entrada: number, -- fade in (s)
	Salida: number, -- fade out (s)
	Enfriamiento: number, -- no se vuelve a arrancar antes de esto (s)
}

local Animaciones = {
	-- en loop mientras la boya espera: brazos con la caña apuntando al agua
	Esperar = {
		Id = "",
		Prioridad = Enum.AnimationPriority.Action,
		Loop = true,
		Entrada = 0.25,
		Salida = 0.2,
		Enfriamiento = 0,
	} :: Anim,
	-- en loop durante el ritmo: tirones cortos de la caña, 2 por compás
	Recoger = {
		Id = "",
		Prioridad = Enum.AnimationPriority.Action,
		Loop = true,
		Entrada = 0.1,
		Salida = 0.15,
		Enfriamiento = 0,
	} :: Anim,
	-- tiro de la caña por arriba del hombro, 0.5 s
	Lanzar = {
		Id = "",
		Prioridad = Enum.AnimationPriority.Action2,
		Loop = false,
		Entrada = 0.05,
		Salida = 0.2,
		Enfriamiento = 0.4,
	} :: Anim,
	-- el momento de la foto: levanta el pez con los dos brazos, 2.8 s
	Levantar = {
		Id = "",
		Prioridad = Enum.AnimationPriority.Action2,
		Loop = false,
		Entrada = 0.08,
		Salida = 0.25,
		Enfriamiento = 0.3,
	} :: Anim,
	-- se escapó: hombros caídos y cabeza que niega, 1 s
	Fallar = {
		Id = "",
		Prioridad = Enum.AnimationPriority.Action2,
		Loop = false,
		Entrada = 0.1,
		Salida = 0.3,
		Enfriamiento = 0.5,
	} :: Anim,
}

export type Nombre = "Esperar" | "Recoger" | "Lanzar" | "Levantar" | "Fallar"

return {
	Lista = Animaciones :: { [string]: Anim },
	-- tiempos que tienen que coincidir con Captura.client (el pez que salta a la mano)
	AGARRAR = 0.55,
	BAJAR = 2.6,
	FIN = 2.8,
}
