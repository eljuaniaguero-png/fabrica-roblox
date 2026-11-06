---
tags: [ficha, combate]
---
# Combate y progresión

> [!summary] En tres líneas
> Combate en tiempo real: combo de 4 golpes, bloqueo y parry, dash, 3 habilidades, gadget, definitiva y técnica combinada. **El servidor decide cada golpe.** Subís de nivel peleando y con misiones, y repartís puntos en el árbol de estadísticas y en el de tu Linaje.

## Teclas (computadora y celular)
| Tecla | Botón en celular | Qué hace | Detalle |
|---|---|---|---|
| Clic | Botón grande abajo a la derecha | **Combo de 4 golpes** | 8, 8, 10 y 14 de daño; el 4.º empuja. Si pasan 0,8 s sin pegar, el combo vuelve al 1.º |
| F | Escudo | **Bloqueo** | Frena el 70 % del daño de frente; gasta 10 de energía por golpe recibido |
| F justo antes del golpe | — | **Parry** | Ventana de 0,2 s: anula el golpe y aturde 1 s al atacante |
| Q | Flecha | **Dash** | 20 studs, 1,5 s de recarga, 0,25 s sin recibir daño |
| Z, X, C | 3 círculos | **Habilidades** | Las que equipes (Linaje, Variante, árbol o mentores) |
| V | Círculo grande | **Definitiva** | Después del Despertar 1; usa toda la energía; 60 s de recarga |
| G | Engranaje | **Gadget** | Gancho en la Beta |
| B | Dos círculos | **Técnica combinada** | Con 2 Linajes compatibles |

## Números de partida (los reales viven en `Config.luau`)
- Nivel 1: **400 de vida**, **100 de energía** (+8 por segundo sin usar habilidades), escudo según el traje.
- Habilidad básica: 20 a 35 de daño, 6 a 12 s de recarga, 15 a 30 de energía.
- Definitiva: 100 a 150 de daño.
- Jefes: **avisan antes de pegar** (círculo rojo en el piso 0,8 s antes). Remache: 2.000 de vida.

## Qué valida el servidor (siempre)
Distancia del golpe (hitbox en el servidor), recargas, energía, que el objetivo exista y esté vivo, y un **límite de pedidos** por jugador (10 por segundo). El cliente solo pide y muestra efectos.

## Subir de nivel
- **Niveles 1 a 100.** Experiencia por enemigos, misiones, trabajos y arcos.
- **2 puntos por nivel** para el árbol de estadísticas común (vida, energía, fuerza, velocidad, defensa, recarga) y las mejoras de movimiento. Ver [[Estadísticas y movimiento]].
- El **árbol del Linaje** tiene 3 ramas: **Poder**, **Cuerpo** y **Técnica** (cambia cómo funciona una habilidad). Ver cada nota en [[Linajes]].
- **Despertar 1** (nivel 25): elegís una de 2 ramas a ciegas y se abre la definitiva. **Despertar 2** (nivel 60): segundo poder.

## Rangos de bando
Novato → Clase C → B → A → S. Se sube con reputación de bando **y** la prueba del líder (Gorrión para Vigilantes, Centinela para la Liga, el Albatros para la Cofradía).

## Sensación del golpe (a probar)
Ideas de mecánica sacadas de [[Referencias de combate]]. No se copian efectos, nombres ni arte de otros juegos.
- **Color dominante por Linaje:** los golpes fuertes y la definitiva usan el color de su Linaje, para reconocerlos de un vistazo.
- **Marca en el piso:** después de una definitiva queda una grieta, quemadura o similar durante unos segundos. Es solo visual.
- **Corte de contraste:** un destello muy breve, solo en el impacto más fuerte. Con límite para no repetirlo seguido y apagado en Calidad Baja.
- **Combinación dentro del Linaje:** dos habilidades del mismo Linaje usadas seguidas dan un efecto extra. Es distinta de la técnica combinada (tecla B), que necesita 2 Linajes compatibles. El servidor valida el orden y el tiempo.
- **Regla:** ningún efecto puede tapar al jugador ni al rival en una pelea. Los números van en `Config.luau` cuando se implemente.

## Pantallas (tomado de las referencias)
| Pantalla | Cómo es en Linajes |
|---|---|
| Menú principal | Tu personaje en el centro, **3 espacios** con flechas, y sus datos (nombre, Linaje, bando, rango, nivel, implantes) |
| Ruleta | Lista de Linajes con rareza y % siempre a la vista |
| Árbol | Nodos conectados; encendidos = desbloqueados |
| Barras | **Vida** (roja), **Energía** (cian) y **Escudo** (blanco) arriba a la izquierda |
| Lista de jugadores | Agrupada por bando con su rango |

Volver a [[Ficha del juego]]
