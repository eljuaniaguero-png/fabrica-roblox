---
tags: [prompt, codigo]
beta: "Taller de Tano: **traje Mk I** y **gancho Mk I**. Implantes, Mk II-V y transferencias, en la Post beta."
---
# P40 Tecnología e implantes

> [!summary] En tres líneas
> Fabricar en el taller de Tano el primer traje (escudo) y el gancho (tecla G), con chatarra y chips.

> [!info] En la Beta
> Taller de Tano: **traje Mk I** y **gancho Mk I**. Implantes, Mk II-V y transferencias, en la Post beta.

## 1. Para qué es
El taller es la recompensa de los trabajos de mecánico; el gancho abre los techos del puerto.

**Qué tener abierto:** Roblox Studio con el place de Linajes (confirmá por MCP que es ese), `rojo serve linajes/linajes.project.json` y el plugin de Rojo conectado.

**Dónde queda:** `linajes/src/server/Tecnologia/`, pantalla de taller de P33, `Config.luau` (Tecnologia).

## 2. Qué leer antes
- [[Mejoras (tecnología, implantes, transferencias)]]
- [[Taller de Tano]] · [[Tano]]
- [[Guía de estilo]] · [[Reglas de los prompts]] · [[Plantilla de prompt]]

## 3. Referencias para Gemini
Pegá cada bloque **por separado** en Gemini (en inglés). La línea de arriba dice qué tiene que salir. Si sale algo de DC, de otro juego o un logo, descartala y pedila de nuevo. Son **solo referencia**: nunca se suben a Roblox.

**Referencia 1: Gancho en uso en el puerto** → guardar como `linajes/arte/referencias/gemini/taller/gancho.png`
```
A blocky hero swinging from a wrist grappling hook between two harbor warehouses at night, thin cyan cable, fog, cranes, eclipse in the sky, dynamic comic-book angle. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

**Referencia 2: Traje Mk I** → guardar como `linajes/arte/referencias/gemini/taller/traje.png`
```
Front, side and back view of an original blocky Roblox-proportioned starter supersuit made from scavenged harbor parts: padded jacket, riveted steel chest plate, welding goggles, worn gloves, rust and navy colors with cyan accents, grey background. Style: dark comic-book 3D game art, stylized Roblox-scale proportions, heavy shape detail (layered plates, seams, rivets, bevels), wet night city lit by neon, faction color only in accents, worn textures (scratches, light edges, grime in joints). Original design: no DC or Marvel characters, no existing game assets, no logos, no readable text, no watermarks. Include a plain blocky 5-stud-tall Roblox-style mannequin for scale.
```

## 4. El bloque para Claude
Copialo entero y pegalo en Claude Code (en tu PC, carpeta `fabrica-roblox`).

```
Leé linajes/arte/GUIA-ESTILO.md, GUIA-PARA-CLAUDE.md y las notas de la bóveda que dice "Qué leer
antes" (linajes/boveda/...): si algo de este prompt choca con la bóveda, MANDA LA BÓVEDA; avisame.
Código en linajes/src/ (--!strict), números en linajes/src/shared/Config.luau, stylua y selene sin
errores. El servidor decide todo; en cada OnServerEvent validá tipo, número finito, instancia del
jugador, distancia y frecuencia.
TALLER (Part con tag "Banco" en el interior de P25d), pantalla de P33:
- TRAJE Mk I: +50 de vida y 30 de escudo; cuesta 50 chatarra y 5 chips. El escudo baja primero y se
  recupera 5/s después de 4 s sin daño.
- GANCHO Mk I: alcance 30 studs, recarga 6 s; tecla G (botón en celular). Apuntás a una superficie con
  tag "Enganchable" o a cualquier techo a menos de 30 studs; el servidor valida la distancia y la línea
  de vista y mueve al jugador (animación de P26b, cable por código).
- Se desbloquea con la misión del gancho de Tano (Los muelles rojos).
POST BETA: Mk II-V (Config ya tiene la tabla), otros gadgets, clínica de Kessler con 3 ranuras, Carga
Cibernética y Sincronía, transferencias.
PRUEBA: Play por MCP (y Local Server con 2 jugadores si dice), consola sin rojo, captura.
Commit en español y push. Decime qué tengo que probar yo y cómo.
```

## 5. Reglas de Roblox que aplican
- El servidor decide todo; el cliente solo pide y muestra.
- Validar cada `OnServerEvent`: tipo, número finito, instancia del jugador, distancia, frecuencia (máx. 10 por segundo).
- Números en `Config.luau`, nunca sueltos.
- Las piezas del mapa se buscan por **tag/atributo**, nunca por nombre.
- Probado o no está hecho: Play, consola sin rojo, captura.
- El servidor valida el gancho (distancia y línea de vista).

## 6. Pasos y puntos de control
### Paso 1: Fabricar y usar
Fabricar los 2 y subir a un techo.

**Para dar el OK:**
- [ ] Gasta los materiales correctos.
- [ ] El escudo funciona.
- [ ] El gancho no atraviesa paredes.

## 7. Qué se entrega y cómo lo probás
**Archivos:**
- Módulos y Config.

**Cómo lo probás vos:**
- En Play, fabricá el gancho y subí a una grúa.

## 8. Alcance completo (Post beta)
Para cuando se haga la versión completa. Es el pedido anterior: actualizá los números con la bóveda antes de usarlo (la bóveda manda) y cambiá `linajes/ideas/ficha.md` por las notas de la bóveda.

```
TALLER DE TANO: traje (Mk I a Mk V: +10 escudo por nivel, cuesta 50/120/250/500/900 chatarra) y gadget
gancho (Mk I a V: alcance 30 a 60 studs, recarga 6 a 3 s). Botón G usa el gadget.
CLÍNICA DE LA DRA. KESSLER (solo si hiciste 3 trabajos para ella o reputación Cofradía ≥ 150):
3 ranuras. Brazo: Puño hidráulico (+20 % daño del combo, carga 3) o Cañón de muñeca (disparo 15 daño,
carga 4). Ojos: Analizador (ves la vida del enemigo, carga 2) o Visión nocturna (carga 1).
Columna: Doble salto (carga 2) o Reflejos rápidos (recargas -10 %, carga 4).
Carga Cibernética máxima = 3 + nivel/10 + nodos de Cuerpo. Si te pasás, Sincronía baja: tus habilidades
de Linaje recargan +25 % más lento. Instalar cuesta chips y dinero; sacar es gratis.
Los implantes se ven en el personaje (modelos chicos hechos en Blender con el mismo formato).
```

---
[[P38d Atracos|← P38d Atracos]]   ·   [[Todos los prompts]]   ·   [[P39 Prólogo tu origen y la Noche del Eclipse|P39 Prólogo tu origen y la Noche del Eclipse →]]
