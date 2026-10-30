---
tags: [prompt]
prompt: "33"
estado: pendiente
---
# Prompt 33 HUD y menús

Antes de pegarlo: Blender abierto con el conector de Claude, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Reglas: [[Reglas de los prompts]] · [[Nivel de detalle]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md (colores y letras: títulos Saira Condensed, texto Barlow; en Roblox usá
las fuentes más parecidas disponibles en Font.new). Armá en Studio, para compu y celular (probá 1920x1080
y 844x390):
1. MENÚ PRINCIPAL: fondo #0e1016 con un eclipse grande atrás (disco negro con aro #f2652b y brillo #ffb347
   que late cada 4 s). Personaje al centro girando lento. "Espacio 1/2/3" con flechas. Datos: Nombre,
   Linaje (en el color de su rareza), Bando (en su color), Rango, Nivel. Botones a la izquierda: Jugar,
   Servidores, Códigos, Controles, Créditos.
2. RULETA DE LINAJE: lista a la derecha por rareza con su % (Común 55, Poco común 28, Raro 12,
   Legendario 4, Mítico 1), cada título en su color. Contador "Seguro: N/40". Botón "Tirar (1 ficha)".
   Animación de giro (Prompt 30) y sonido por rareza.
3. HUD DE PELEA: abajo al centro, barra de vida #d23a4a (derecha) y energía #2c7be5 (izquierda) con un
   rombo al centro con el emblema del bando; escudo #3fc1b0 arriba de la vida; nombre arriba; íconos de
   Z X C V con recarga (se oscurecen y cuentan segundos); G (gadget), Q (dash), F (bloqueo).
   En celular: botones redondos grandes abajo a la derecha (ataque el más grande).
   Aviso "Tenés N puntos de habilidad" arriba a la derecha, que se va solo a los 4 s.
4. ÁRBOL: 3 ramas (Poder, Cuerpo, Técnica) en columnas, nodos cuadrados con borde #8a94a6 apagados y
   #3fe0f0 encendidos, líneas entre nodos, descripción al pasar el mouse o tocar, botón "Desbloquear".
5. DIÁLOGO CON NPC: recuadro abajo, nombre del NPC en una pestaña arriba a la izquierda, texto con efecto
   máquina de escribir, hasta 4 respuestas en botones debajo, la última siempre "Adiós".
6. TRAJES: personaje girando sobre degradado de #0e1016 a #6b5ba8, flechas para cambiar de traje,
   nombre del traje arriba en título grande, botón "Ponerse" o "Bloqueado: cómo conseguirlo".
7. LISTA DE JUGADORES: arriba a la derecha, agrupada por bando con cabecera en su color (Liga, Cofradía,
   Vigilantes, Neutral), cada jugador con su rango debajo en chico.
Captura de cada pantalla en compu y celular. Mostramelas y esperá mi OK. Commit y push.
```

---
[[P32 Ambientes y música|← P32 Ambientes y música]]   ·   [[Todos los prompts]]   ·   [[P34 Base y guardado|P34 Base y guardado →]]
