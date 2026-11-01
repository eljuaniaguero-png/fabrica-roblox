---
tags: [prompt]
prompt: "41c"
estado: pendiente
---
# Prompt 41c La agenda de los villanos y la Crónica de la ciudad

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé "Los villanos tienen su propia agenda" en la sección 0f de linajes/ideas/ficha.md.
1. PLAN SEMANAL: cada lunes, cada villano principal activo (Mascarada, Halden, el Albatros al empezar) elige
   un plan de una lista en Config (por ejemplo: noche de caos en Vórtice, implante nuevo en Corona,
   cargamento grande en el puerto), con una barra de avance global.
2. Los planes avanzan solos con el tiempo y con lo que hacen los jugadores que los ayudan; retroceden con lo
   que hacen los que los frenan. Se suma en todos los servidores con MemoryStore + DataStore cada 5 min.
3. El Narrador (Prompt 41) reparte ganchos para frenar o ayudar cada plan, según el bando y la reputación.
4. EL DOMINGO se resuelve: si la barra no llegó, el villano pierde algo (un barrio, un teniente, dinero); si
   llegó, el plan sale y cambia el mundo esa semana (barrio tomado, precios más caros, criatura suelta,
   evento especial). Los cambios viven en un módulo EstadoDelMundo que leen los otros sistemas.
5. CRÓNICA DE LA CIUDAD: El Faro (Prompt 38e) publica cada día cómo va cada plan y, el domingo, el
   resultado con los 3 jugadores que más pesaron de cada lado.
Probá adelantando el reloj: forzá un domingo con el plan logrado y otro frenado, y mostrame qué cambió.
Commit y push.
```

---
[[P41b Que cada partida sea distinta|← P41b Que cada partida sea distinta]]   ·   [[Todos los prompts]]   ·   [[P42 Piezas de traje de los NPCs y pantalla de trajes|P42 Piezas de traje de los NPCs y pantalla de trajes →]]
