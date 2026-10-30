---
tags: [prompt]
prompt: "05"
estado: pendiente
---
# Prompt 5 Mascarada (DC de trabajo: Joker) · Cofradía · jefe

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Abrí kit-base.blend y guardalo como linajes/arte/blender/mascarada.blend.

PERSONAJE: Mascarada. Villano teatral y caótico que cambia de "personaje" en cada fase de pelea.
Diseño propio: SIN maquillaje de payaso, SIN pelo verde, SIN traje violeta, SIN sonrisa pintada.

SILUETA: saco largo de teatro con cola, sombrero de copa torcido, una máscara distinta por fase.

PIEZAS:
1. Sombrero de copa torcido (Head) — 3.000 tris: negro con cinta cofradia (#c2213a).
2. Máscara 1 "Tragedia" (Head) — 3.000 tris: blanco-armadura, ceño triste, ojos neon-aviso.
3. Máscara 2 "Comedia" (Head) — 3.000 tris: blanco-armadura con grietas, sonrisa tallada, ojos neon-eclipse.
4. Máscara 3 "Ninguna" (Head) — 3.000 tris: espejo partido (acero, roughness 0,1) con grietas neon-aviso.
   Las 3 máscaras como objetos separados en el mismo lugar; solo una visible a la vez.
5. Saco de teatro (UpperTorso + LowerTorso) — 10.000 tris: tela cofradia oscura (#7a1424) con solapas
   negras, 6 botones de oro, cola larga partida en dos hasta las pantorrillas, pliegues horneados.
6. Chaleco y corbata de moño (UpperTorso) — 3.000 tris: chaleco negro a rayas finas, moño blanco.
7. Guantes blancos (Hands) — 2.000 tris el par.
8. Bastón con naipe gigante (RightHand) — 3.000 tris: bastón negro con punta de oro con forma de máscara.
9. Zapatos de charol (Feet) — 2.000 tris el par.
TOTAL ≤ 35.000 tris. Colores: 50 % negro, 35 % cofradia, 15 % blanco-armadura, oro y neon.

PASO 1: boceto, 3 vistas con la máscara 1, esperá mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO, 3 vistas + un render por máscara. Tabla de tris. Esperá mi OK.
PASO 3: exportá a linajes/arte/exports/mascarada/, script en scripts/personajes/mascarada.py,
commit "Linajes: traje de Mascarada" y push.
```

---
[[P04 Centinela Solar|← P04 Centinela Solar]]   ·   [[Todos los prompts]]   ·   [[P06 Remache|P06 Remache →]]
