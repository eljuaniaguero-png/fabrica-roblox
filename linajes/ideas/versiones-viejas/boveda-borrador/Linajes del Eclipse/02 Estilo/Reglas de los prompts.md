---
tags: [estilo, prompts]
---
# Reglas de los prompts

**Dónde va cada uno:** todos en 💻 **Claude Code en tu PC** (`C:\Users\eljua\fabrica-roblox`).
- Para modelos y animaciones: abrí **Blender** con el conector de Claude prendido.
- Para importar y código: abrí **Roblox Studio** y, cuando haga falta, `rojo serve linajes`.
- **Un prompt por sesión.** Cuando termina, mirás los renders o probás lo que te diga, y recién ahí pasás al siguiente.
- Si un prompt dice "mostrame para aprobar", Claude se frena ahí y espera tu OK.

**Reglas que valen para todos los prompts** (Claude las tiene en `GUIA-ESTILO.md`, pero se repiten adentro de cada prompt para que no se pierdan):
- 1 stud = 0,28 m en Blender. Pivote en el centro de la base. Frente hacia -Y en Blender (queda -Z en Roblox).
- Cada malla ≤ 20.000 triángulos, un material por malla, UV dentro de 0-1, normales hacia afuera, normal map OpenGL.
- Texturas: 1024 px trajes y edificios importantes, 512 px casi todo, 256 px props chicos.
- Nada de logos, emblemas, trajes, colores exactos, frases ni música de DC. Los nombres de DC son de trabajo.
- Guardar el `.blend` antes de cada cambio grande. Todo modelo y animación se hace con un **script** en `linajes/arte/scripts/` para poder rehacerlo.
- Commit en español y push al terminar.


Ver también: [[Nivel de detalle]] · [[Colores]] · [[Guía de estilo]]
