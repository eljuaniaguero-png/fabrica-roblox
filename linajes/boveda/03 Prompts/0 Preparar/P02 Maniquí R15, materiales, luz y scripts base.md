---
tags: [prompt]
prompt: "02"
estado: hecho
---
# Prompt 2 Maniquí R15, materiales, luz y scripts base

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y mirá las imágenes de linajes/arte/referencias/.

PARTE 1 — Maniquí exacto de Roblox:
1. En Roblox Studio, por MCP, creá un Dummy R15 de bloques (Avatar > Rig Builder > R15 > Block Avatar)
   y exportalo a linajes/arte/blender/maniqui-r15.fbx (clic derecho > Export Selection).
   Si el export necesita que yo toque algo, decime exactamente qué botón.
2. En Blender, importá ese FBX (escala 1/0,28 para que 1 stud = 0,28 m), con su esqueleto (armature)
   de 15 partes: Head, UpperTorso, LowerTorso, LeftUpperArm, LeftLowerArm, LeftHand, RightUpperArm,
   RightLowerArm, RightHand, LeftUpperLeg, LeftLowerLeg, LeftFoot, RightUpperLeg, RightLowerLeg, RightFoot.
3. Material gris claro #b8bcc6 sin brillo. Guardá linajes/arte/blender/kit-base.blend.

PARTE 2 — Materiales de la guía (Principled BSDF, roughness indicada):
- asfalto #3a3f4b (0,9), ladrillo #6e3b2e (0,85), acero #8a94a6 (0,35, metallic 0,8),
  tela-oscura #1b1f2a (0,8), cuero #2a2018 (0,6), bronce #a0703a (0,4, metallic 0,9),
  oro #d9a441 (0,3, metallic 1), blanco-armadura #e8e6e0 (0,4),
  neon-cian #3fe0f0 (emission 5), neon-eclipse #f2652b (emission 5), neon-aviso #ff2a2a (emission 6),
  liga #2f6fdb, cofradia #c2213a, vigilantes #6b5ba8 (0,5 los tres).
  Un material por color. Nombres exactos: MAT_<nombre>.

PARTE 3 — Luz de render (para todos los renders de aprobación):
- Fondo #0e1016, luz principal fría (color #9fb4ff, fuerza 3) desde arriba-izquierda a 45°,
  luz de borde naranja #f2652b desde atrás-derecha (fuerza 4), niebla suave (volumen, densidad 0,02).
- Cámara 50 mm. Tres cámaras guardadas: Frente, Costado (90°), Espalda (180°), a la altura del pecho.
- Render Eevee 1600x1000.

PARTE 4 — Scripts reutilizables en linajes/arte/scripts/:
- base.py: funciones para cargar el kit, aplicar material, contar triángulos por objeto, renderizar las
  3 vistas en una sola imagen (linajes/arte/renders/<nombre>_vistas.png) y exportar FBX por pieza.
- trajes.py: funciones para crear piezas de traje pegadas a un hueso del maniquí (casco en Head,
  peto en UpperTorso, hombreras en UpperArm, guantes en Hand, botas en Foot, capa en UpperTorso
  con simulación de tela horneada a malla con pliegues), cada una como objeto separado.
- ciudad.py y props.py vacíos con la estructura para usarlos después.

Render del maniquí en las 3 vistas y mostramelo. Commit "Linajes: kit base de Blender" y push.
```

---
[[P01 Carpeta del juego y reglas de estilo|← P01 Carpeta del juego y reglas de estilo]]   ·   [[Todos los prompts]]   ·   [[P03 Cuervo|P03 Cuervo →]]
