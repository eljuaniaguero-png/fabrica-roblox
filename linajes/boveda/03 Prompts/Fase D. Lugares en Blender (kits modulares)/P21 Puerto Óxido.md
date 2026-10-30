---
tags: [prompt]
prompt: "21"
estado: pendiente
---
# Prompt 21 Puerto Óxido (primera ciudad modelada)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Mirá en linajes/arte/referencias/ las capturas de mundo de Bloodlines
(155302 a 155744: niebla, piedra, óxido) y la de ciudad de noche (160028). Guardá kit-base.blend como
linajes/arte/blender/puerto-oxido.blend. Usá ciudad.py y props.py.

KIT MODULAR (cada pieza encaja en una grilla de 8 studs):
1. Muelle de madera recto 8x8 (≤ 1.500 tris) y esquina (≤ 1.500): tablones con huecos, postes con soga.
2. Pared de galpón 8x12 de chapa ondulada oxidada (≤ 1.200) + versión con portón corredizo (≤ 2.000)
   + versión con ventanas rotas (≤ 2.000).
3. Techo de galpón a dos aguas 8x8 (≤ 1.000).
4. Calle de adoquines 8x8 (≤ 800) con charcos (material espejo suave) y versión con vías de tren (≤ 1.200).
5. Grúa portuaria gigante (≤ 18.000, en 2 mallas): estructura de vigas en X amarillo apagado (#a08a3a)
   y óxido, cabina, gancho con cadena.
6. Contenedores 4x4x10 (≤ 600 cada uno), 4 colores apagados (rojo óxido, azul petróleo, verde musgo, gris).
7. Props (≤ 500 cada uno): farola de puerto con luz naranja, bita de amarre, pila de cajones, barril,
   red de pesca colgada, cartel roto "PUERTO ÓXIDO" (texto en una textura aparte), bote volcado.
8. EDIFICIO IMPORTANTE: Galpón del Albatros (≤ 25.000 en 2 mallas): galpón doble con letrero neon de un
   albatros (cofradia), oficina en el piso de arriba con ventanal.
9. EDIFICIO IMPORTANTE: Barco del Albatros (≤ 30.000 en 2 mallas): carguero viejo de 60 studs de largo,
   casco oxidado, puente de mando, cubierta con contenedores (escenario del evento de 8 jugadores).

CLIMA: niebla verde-gris (#7f9a96), luz de luna fría, charcos que reflejan las farolas naranjas, lluvia
fina (partículas en Roblox, no en Blender).

PASO 1: bocetos de bloques de todas las piezas en una grilla + una calle armada de muestra. Mi OK.
PASO 2: detalle de todo, render de la calle de muestra con la luz de noche, tabla de tris. Mi OK.
PASO 3: exportá cada pieza a linajes/arte/exports/puerto-oxido/<pieza>.fbx, commit y push.
```

---
[[P20c Mapa del mundo abierto|← P20c Mapa del mundo abierto]]   ·   [[Todos los prompts]]   ·   [[P22-25 Los otros lugares|P22-25 Los otros lugares →]]
