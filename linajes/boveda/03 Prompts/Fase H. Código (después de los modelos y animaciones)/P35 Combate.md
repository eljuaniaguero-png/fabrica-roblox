---
tags: [prompt]
prompt: "35"
estado: pendiente
---
# Prompt 35 Combate

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Usá el traje de Cuervo y las animaciones base (IDs en Config.luau).
NÚMEROS (en Config.luau): combo 4 golpes de 8, 8, 10 y 14 de daño; 0,35 s entre golpes; el combo se
corta si pasan 1,0 s; el golpe 4 empuja 6 studs. Bloqueo: reduce 80 % del daño, no podés atacar
mientras bloqueás. Parry: si bloqueás en los 0,2 s antes de un golpe, el atacante queda aturdido 1,2 s.
Dash: 14 studs en 0,25 s, recarga 2,5 s, invulnerable los primeros 0,15 s. Vida 100, energía 100,
energía vuelve 8 por segundo.
REGLAS: el cliente reproduce la animación y el sonido al instante; el SERVIDOR decide el golpe en el
marcador Impacto: hitbox con GetPartBoundsInBox de 5x5x6 studs delante del atacante, chequea distancia
(máx. 8 studs), recargas, energía, y un límite de 10 pedidos por segundo por jugador.
ENEMIGOS DE PRUEBA: un maniquí con vida infinita que muestra el número de daño flotando; un matón del
puerto (modelo + animaciones) con 120 de vida que te persigue a 14 studs/s, y antes de pegar muestra
flechas rojas #ff2a2a en el piso 0,4 s (marcador Aviso), pega 12.
CELULAR: botones del HUD del Prompt 33.
Si pelear no se siente bien, decime qué ajustarías antes de seguir.
```

---
[[P34 Base y guardado|← P34 Base y guardado]]   ·   [[Todos los prompts]]   ·   [[P36 Ruleta Linaje, Variante y Rasgos|P36 Ruleta Linaje, Variante y Rasgos →]]
