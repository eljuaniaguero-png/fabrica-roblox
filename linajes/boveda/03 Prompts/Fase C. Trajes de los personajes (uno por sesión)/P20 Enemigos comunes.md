---
tags: [prompt]
prompt: "20"
estado: pendiente
---
# Prompt 20 Enemigos comunes (uno por sesión)

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md. Guardá kit-base.blend como linajes/arte/blender/enemigo-[archivo].blend.
Modelá este enemigo sobre el maniquí R15 (o con rig propio si no es humano), [TRIS] tris total,
3 VARIANTES de color (cambiá solo materiales, no mallas). Boceto → mi OK → detalle + 3 vistas de cada
variante → mi OK → exportar a linajes/arte/exports/enemigo-[archivo]/, commit y push.
ENEMIGO: [pegá una fila]
OBSIDIAN (en los pasos 1, 2 y 3): corré linajes/arte/scripts/obsidian.py -- <archivo> (deja el .glb y los
renders en linajes/boveda/04 Personajes/<Nombre>/) y escribí o actualizá la nota <Nombre>.md con el
modelo 3D para girar (bloque ```3D, igual que la de Remache), las vistas, los primeros planos, la tabla
de triángulos y el estado. Sumá o actualizá su fila en 04 Personajes/Personajes.md. Abrí la nota en
Obsidian con el conector y avisame que la mire ahí.
```
| Archivo | Enemigo | Tris | Detalles y variantes |
|---|---|---|---|
| maton | Matón del puerto | 8.000 | Campera de cuero, gorro de lana, pañuelo en la cara, cadena. Variantes: gorro rojo, verde, gris |
| maton-implantes | Matón con implantes | 10.000 | Igual que el matón + brazo de acero con pistón y ojo neon-aviso. Variantes por color del brazo |
| dron | Dron de seguridad Corona | 6.000 | Esfera de 1,5 studs blanca con 4 hélices en anillo, ojo neon-cian, logo de Corona Corp. Rig propio (hélices giran) |
| robot | Robot centinela Corona | 10.000 | Humanoide de 7 studs blanco y oro, cabeza de visor, escudo en el brazo izquierdo. Rig R15 escalado |
| preso | Preso fugado | 8.000 | Mameluco naranja apagado con número, esposas rotas, pelo rapado. Variantes: con casco de guardia robado, con barra de hierro, sin nada |
| soldado-umbra | Soldado de Umbra | 10.000 | Armadura de obsidiana con grietas naranjas, casco sin cara, lanza negra |
| criatura | Criatura abisal | 10.000 | Cuadrúpedo de 4 studs, piel petróleo con escamas, boca de anguila con luces cian. Rig propio de 4 patas |
| carterista | Carterista | 6.000 | Buzo con capucha gris, mochila chica, zapatillas gastadas, guantes finos. Variantes: buzo gris, bordó, azul marino |
| asaltante | Asaltante de callejón | 7.000 | Campera inflable rota, pasamontañas, caño de hierro, cadena en el cinturón. Variantes por color del pasamontañas |
| pandilla-oxido | Pandillero "Los Óxido" (Puerto) | 8.000 | Mameluco de estibador cortado, gorro de lana, pañuelo naranja óxido (#b5532a), llave grande como arma. Variantes: con casco de obra, con gancho de carga, con chaleco reflectivo roto |
| pandilla-mascaras | Pandillero "Máscaras Rotas" (Vórtice, siguen a Mascarada) | 8.000 | Traje barato con media máscara de teatro rota (diseño propio, nada de payaso), corbata floja, bate. Variantes: máscara blanca, dorada, negra |
| teniente | Teniente de pandilla (jefe de callejón) | 10.000 | Igual que su pandilla pero más grande (escala 1,15), hombrera de placas, implante de brazo con luz de aviso, cinturón con 3 llaves de alijo. Una variante por pandilla |
| policia | Policía de patrulla | 8.000 | Uniforme azul petróleo (#1f3a52), gorra con visera, chaleco con placa (estrella de 6 puntas propia, sin escudo real), radio al hombro, esposas al cinturón, linterna. Variantes: con gorra, con casco de moto, mujer con pelo recogido |
| tactico | Unidad Táctica | 10.000 | Armadura negra mate con placas, casco con visor, escudo antidisturbios transparente de 3 studs (malla aparte), letras "U.T." en la espalda |
| halcon | Escuadra Halcón (anti Linajes, de Brandt) | 10.000 | Armadura gris grafito con franjas neon-aviso, casco cerrado con 3 ojos ópticos, lanza de energía, emblema propio de un halcón de 3 trazos. Variantes: soldado, tirador, capitán con capa corta |
| guardia | Guardia de banco | 7.000 | Uniforme gris claro, gorra, chaleco liviano, porra, credencial de Banco Central Corona |

---
[[P19 NPCs|← P19 NPCs]]   ·   [[Todos los prompts]]   ·   [[P20b Piezas del creador de personaje|P20b Piezas del creador de personaje →]]
