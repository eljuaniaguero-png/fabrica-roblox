# Archivo de juegos viejos

Archivados el 2026-10-30 para empezar el RPG nuevo. No se borró nada: cada carpeta tiene el
juego completo (código, proyecto de Rojo, ficha en `ideas/`, arte y, fuera de git, sus
copias `.rbxl` en `backups/`).

| Carpeta | Juego | Cómo levantarlo |
|---|---|---|
| `pisada-sonora/` | Pisada Sonora (torre de baldosas musicales) | `rojo serve archivo/pisada-sonora` |
| `mutant-lab/` | Mutant Lab (laboratorio de mutantes, estilo toon) | `rojo serve archivo/mutant-lab` |
| `forja-rapida/` | Forja Rápida (minar geodas y forjar gemas) | `rojo serve archivo/forja-rapida` |
| `plinko-knight/` | Plinko Knight (mazmorra por turnos con tiros de plinko) | `rojo serve archivo/plinko-knight` |
| `pesca-compas/` | Pesca al Compás (prototipo de pesca con ritmo) | `rojo serve archivo/pesca-compas` |

Pruebas de lógica con Lune (desde la raíz): `lune run archivo/forja-rapida/pruebas/reglas`,
`lune run archivo/plinko-knight/pruebas/progreso`, etc.

## Código reutilizable para el RPG nuevo

- **Guardado con ProfileStore** (bloqueo de sesión, autoguardado, cierre en paralelo):
  `plinko-knight/src/server/Guardado.luau` (la versión más prolija) y
  `forja-rapida/src/server/Guardado.luau` + `Jugadores.luau`. El paquete está en
  `<juego>/ServerPackages` (se instala con `wally install`, ver `wally.toml`).
- **Minado de Forja Rápida**: `forja-rapida/src/server/GeodeServerService.luau` (geodas que
  nacen, reciben golpes y se rompen), fórmulas puras en `forja-rapida/src/shared/Reglas.luau`,
  números en `forja-rapida/src/shared/GameConfig.luau` y animaciones en
  `forja-rapida/src/shared/AnimacionesPicar.luau`.
- **Lógica de combate de Plinko Knight**: reglas puras (turnos, daño, contraataque, quemadura)
  en `plinko-knight/src/shared/Mazmorra.luau`, servidor en `plinko-knight/src/server/Peleas.luau`
  y `Partida.luau`, probadas con `plinko-knight/pruebas/mazmorra.luau`.
- **Generador de mapa de Pisada Sonora**: `pisada-sonora/src/server/GeneradorTorre.luau`
  (el mapa se arma por código, así vive en git), con niveles en
  `pisada-sonora/src/shared/Niveles.luau`.
