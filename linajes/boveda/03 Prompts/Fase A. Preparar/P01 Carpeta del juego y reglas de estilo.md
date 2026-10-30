---
tags: [prompt]
prompt: "01"
estado: hecho
---
# Prompt 1 Carpeta del juego y reglas de estilo

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Hola. Arrancamos el juego nuevo "Linajes del Eclipse": RPG de superhéroes, combate en tiempo real,
multijugador, ambientado en una ciudad propia muy parecida al mundo de DC (nombres de DC solo de trabajo).
Seguí GUIA-PARA-CLAUDE.md. Los juegos viejos están en archivo/ (ver archivo/README.md): NO los toques.

1. Si existe ideas/rpg-linajes.md ("Herederos del Eco"), movelo con git mv a archivo/ideas-descartadas/.
2. Creá esta estructura:
   linajes/linajes.project.json  (Rojo: ReplicatedStorage/Shared, ServerScriptService/Server,
                                  StarterPlayerScripts/Client, ServerStorage/ServerPackages)
   linajes/src/shared/  linajes/src/server/  linajes/src/client/
   linajes/ideas/  linajes/arte/referencias/  linajes/arte/scripts/  linajes/arte/blender/
   linajes/arte/exports/  linajes/arte/renders/  linajes/arte/animaciones/  linajes/arte/sonidos/
3. Copiá TODAS las imágenes de C:\Users\eljua\Downloads\referencias a linajes/arte/referencias/
   (son de otros juegos: solo para ideas, nunca se suben a Roblox ni se copian).
4. Escribí linajes/ideas/ficha.md con la ficha que pego abajo, entera.
5. Escribí linajes/arte/GUIA-ESTILO.md con las reglas del sistema de diseño "Linajes del Eclipse 3D"
   (README + lista de Modelos, pegados abajo) y la tabla de colores con sus hex.
6. En CLAUDE.md: sacá la tabla de juegos viejos (dejá una línea: "Los juegos viejos están en archivo/"),
   poné "Juego activo: linajes/" y agregá estas reglas:
   - "Antes de cualquier modelo o animación, leé linajes/arte/GUIA-ESTILO.md."
   - "Los modelos y animaciones los hace Claude en Blender. Los sonidos y la música, ForgeGUI."
   - "Los nombres de DC son nombres de trabajo: nunca van en el juego publicado. Ningún modelo copia logos,
     emblemas, trajes ni colores exactos de DC."
7. Commit "Linajes: carpeta, ficha y guía de estilo" y push. Decime qué quedó.

[PEGAR ACÁ: la ficha rpg-linajes-ficha-v2-superheroes-2026-10-30.md]
[PEGAR ACÁ: el README y la sección Modelos del sistema de diseño]
```
(Si preferís no pegar nada, decime "arrancá" y lo lanzo yo en tu PC con todo adentro.)

---
   ·   [[Todos los prompts]]   ·   [[P02 Maniquí R15, materiales, luz y scripts base|P02 Maniquí R15, materiales, luz y scripts base →]]
