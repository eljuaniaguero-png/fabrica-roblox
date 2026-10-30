---
tags: [prompt]
prompt: "20e"
estado: pendiente
---
# Prompt 20e Vehículos y objetos de la calle viva

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y la sección "Calle viva" de linajes/ideas/ficha.md. Guardá kit-base.blend
como linajes/arte/blender/calle-viva.blend. Diseños propios: ninguna marca real de autos.
VEHÍCULOS (cada uno en 2 a 3 mallas, ruedas aparte para girar, puertas aparte si se abren):
0. Helicóptero policial (≤ 14.000, rotor aparte que gira, reflector Neon abajo).
1. Auto patrulla (≤ 10.000): sedán anguloso azul petróleo y blanco, barra de luces roja y azul (Neon),
   estrella de 6 puntas propia en las puertas, "POLICÍA DE LA BAHÍA" (texto en textura aparte).
2. Camión de la Unidad Táctica (≤ 12.000): blindado negro, puertas traseras dobles, escalón.
3. Camión blindado de caudales (≤ 12.000): gris claro con franja verde, puerta trasera de bóveda que se
   abre (malla aparte), para el evento y el atraco mediano.
4. 3 autos civiles (≤ 7.000 c/u): compacto, camioneta, taxi amarillo apagado. 4 colores por material.
5. Moto del jugador (≤ 6.000) y auto del jugador (≤ 9.000), con 3 canales de color y hueco para el
   emblema. Mk I (simple) y Mk V (con placas, luces neon y alerón) como dos versiones.
6. Vagón de subte (≤ 12.000) y ferry al penal (≤ 15.000).
VIGILANCIA:
7. Cámara de seguridad de pared y de poste (≤ 800): carcasa blanca, lente negra, luz roja (Neon aparte).
   Versión rota (lente partida, cables colgando).
8. Reflector de la comisaría (≤ 4.000), barrera de corte de ruta con luces (≤ 1.500), arco escáner policial
   de 6 studs (≤ 3.000) con franja neon-cian.
CRIMEN Y ATRACOS:
9. Esposas (≤ 400), bolsa de botín de lona con símbolo de moneda (≤ 800), taladro de bóveda sobre trípode
   con barra de progreso en la carcasa (≤ 3.000), cajero automático (≤ 1.500, versión abierta con billetes),
   caja de herramientas de hacker con laptop (≤ 1.500), alijo de pandilla (cajón con candado, ≤ 1.000),
   tablero de golpes del Albatros (pizarra de corcho con fotos, hilos rojos y planos, ≤ 2.000).
NOTICIAS:
10. Kiosco de diarios (≤ 4.000) con revistas y la portada de El Faro (textura que cambia por código),
    pantalla gigante de edificio (≤ 2.000, solo marco: la imagen es un SurfaceGui), cartel de "BUSCADO"
    pegado en pared (plano con marco de cinta, ≤ 200), TV de bar (≤ 800), radio de auto (≤ 300).
CALLEJÓN PELIGROSO:
11. Farola rota que titila, contenedor de basura volcado, grafiti en decal (3 por pandilla, diseños propios),
    colchón viejo, barril con fuego, reja de depósito, escalera de incendio rota (≤ 1.500 c/u).
12. Perro callejero y perro con correa (≤ 3.000, rig propio de 4 patas).
PASO 1: bocetos de todo en grilla, mi OK. PASO 2: detalle con el NIVEL DE DETALLE OBLIGATORIO + render
de una cuadra de Corona con patrulla, cámaras y kiosco, y un callejón de Vórtice de noche, mi OK.
PASO 3: exportá a linajes/arte/exports/calle-viva/<grupo>/<pieza>.fbx, commit y push.
```

---
[[P20d Civiles y testigos|← P20d Civiles y testigos]]   ·   [[Todos los prompts]]   ·   [[P20c Mapa del mundo abierto|P20c Mapa del mundo abierto →]]
