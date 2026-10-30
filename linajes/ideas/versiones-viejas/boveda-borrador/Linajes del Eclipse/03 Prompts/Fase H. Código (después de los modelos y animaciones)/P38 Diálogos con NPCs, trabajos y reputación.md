---
tags: [prompt]
prompt: "38"
estado: pendiente
---
# Prompt 38 Diálogos con NPCs, trabajos y reputación

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
SISTEMA DE DIÁLOGO (pantalla del Prompt 33): los diálogos viven en linajes/src/shared/Dialogos/<npc>.luau
como datos (nodos con texto, respuestas, condiciones y acciones), nunca mezclados en el código.
Condiciones posibles: nivel, bando, rango, reputación, trabajo y nivel de trabajo, misión activa o completa.
Acciones: dar misión, completar misión, dar trabajo, dar dinero/objetos, sumar reputación, enseñar nodo,
abrir tienda (taller, clínica), mover al jugador.
TRABAJOS (cada uno con una tarea corta repetible de 1 a 3 minutos, 5 niveles Aprendiz → Experto):
- Reportero con Lucía Vega: sacar 3 fotos de peleas o crímenes marcados (botón de cámara, la foto vale si
  el objetivo está en cuadro y a menos de 30 studs). Paga 40 + 10 por nivel. Da rumores = misiones.
- Mecánico con Tano: arreglar un auto (minijuego: tocar 5 piezas en orden antes de 15 s). Paga chatarra.
- Patrullero con Comisaria Rivas: recorrer 4 puntos y detener 3 matones. +20 reputación Liga.
- Laboratorio con Ingeniera Okafor: probar un prototipo (llegar a 3 blancos con el gancho). Da planos.
- Contrabandista con El Albatros: llevar un paquete a un punto sin que te vea un dron. +20 Cofradía.
PEDIR AYUDA: "¿Qué hago ahora?" en Señal y en la comisaría dice la próxima misión y a quién ir;
Tano y Atalanta enseñan un nodo extra si cumplís su prueba; con reputación ≥ 300 con un héroe, podés
pedirle que te acompañe en una misión (NPC aliado que pelea).
REPUTACIÓN Y RANGO: 0 a 1000 por bando. Rangos: Novato (0), Clase C (150), B (350), A (600), S (900).
Para subir hay que tener la reputación Y hablar con el líder del bando (Liga: Centinela Solar;
Cofradía: Mascarada; Vigilantes: Cuervo), que da una prueba (pelea o misión corta).
```

---
[[P37c Rasgos por estadísticas y Variantes secretas|← P37c Rasgos por estadísticas y Variantes secretas]]   ·   [[Todos los prompts]]   ·   [[P39 Prólogo tu origen y la Noche del Eclipse|P39 Prólogo tu origen y la Noche del Eclipse →]]
