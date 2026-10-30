---
tags: [prompt]
prompt: "20d"
estado: pendiente
---
# Prompt 20d Civiles y testigos (la gente de la calle)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y la sección "Calle viva" de linajes/ideas/ficha.md. Guardá kit-base.blend
como linajes/arte/blender/civiles.blend. Los civiles aparecen de a muchos, así que van LIVIANOS.
Modelá, sobre el maniquí R15, un KIT de ropa de civil para mezclar por código:
- 8 partes de arriba (≤ 2.500 tris c/u): campera de jean, saco de oficina, buzo con capucha, camisa a
  cuadros, piloto largo, chaleco de obra, remera con estampa propia, uniforme de enfermera/o.
- 6 partes de abajo (≤ 1.500): jean, pantalón de vestir, pollera, jogging, bermuda, mameluco.
- 8 cabezas/pelos/gorros (≤ 1.500): gorra, gorro de lana, pelo corto, pelo largo atado, rulos, pelado con
  barba, sombrero, auriculares.
- 6 accesorios (≤ 800): maletín, bolsa de compras, mochila, paraguas (abierto y cerrado), café para llevar,
  correa de perro (el perro va en el Prompt 20e).
- TELÉFONO del civil (≤ 300): se ve en la mano cuando llama a la policía, pantalla neon-cian.
REGLAS: cada pieza con 2 canales de color (Color1, Color2) para variar por código. Un civil armado completo
≤ 6.000 tris. Además, 3 civiles especiales completos (≤ 8.000): DIARERO con carrito de diarios de El Faro
(carrito con 3 pilas y cartel), VENDEDOR de panchos con carrito, MÚSICO callejero con guitarra y estuche.
PASO 1: bocetos de todas las piezas en grilla + 6 civiles armados de ejemplo, mi OK.
PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO + render de una vereda con 12 civiles mezclados, mi OK.
PASO 3: exportá a linajes/arte/exports/civiles/<tipo>/<pieza>.fbx, script scripts/civiles.py, commit y push.
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```

---
[[P20b Piezas del creador de personaje|← P20b Piezas del creador de personaje]]   ·   [[Todos los prompts]]   ·   [[P20e Vehículos y objetos de la calle viva|P20e Vehículos y objetos de la calle viva →]]
