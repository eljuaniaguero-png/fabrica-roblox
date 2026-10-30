---
tags: [prompt]
prompt: "34"
estado: pendiente
---
# Prompt 34 Base y guardado

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Copiá el guardado con ProfileStore del juego archivado más completo (ver archivo/README.md) y adaptalo.
DATOS por jugador: espacioActivo (1-3), fichasEclipse, seguroContador, compras (PurchaseIds entregados).
DATOS por espacio: nombre, nivel, xp, linaje, linajeSecundario, rareza, bando, rango, reputacion
{liga, cofradia, vigilantes}, reputacionNPC {rivas, vega, tano, okafor, kessler, brandt, senal},
trabajos {reportero, mecanico, patrullero, laboratorio, contrabandista} con nivel y xp,
puntosArbol, nodos[], despertar (0-2), implantes {brazo, ojos, columna}, cargaCibernetica,
tecnologia {traje: MkN, gadget: nombre y MkN}, trajes desbloqueados[], trajePuesto, fragmentos[],
misiones {activas, completas}, acto, dinero, chatarra, chips.
SchemaVersion 1. Autoguardado (ProfileStore), guardado al salir, en BindToClose y al recibir
ServerRestartScheduled. Si falla la carga, avisarle al jugador y no dejarlo jugar sin guardar.
Config.luau con TODOS los números de balance de los prompts siguientes.
Probá: entrar, cambiar cosas, salir, volver a entrar; y simular una falla de carga.
```

---
[[P33 HUD y menús|← P33 HUD y menús]]   ·   [[Todos los prompts]]   ·   [[P35 Combate|P35 Combate →]]
