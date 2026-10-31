---
tags: [prompt]
prompt: "33"
estado: pendiente
---
# Prompt 33 HUD y menús: pasar la interfaz de Figma a Roblox

Antes de pegarlo: Studio abierto con el place de Linajes y `rojo serve linajes/linajes.project.json` corriendo, en Claude Code en `C:\Users\eljua\fabrica-roblox`. Hacé antes [[P33c HUD y menús en Figma]]: este prompt pasa a Roblox lo que ya aprobaste en Figma. Reglas: [[Reglas de los prompts]] · [[Colores]]

```
Leé linajes/arte/GUIA-ESTILO.md y linajes/arte/2d/figma/medidas.md. El diseño aprobado está en el archivo
de Figma "Linajes del Eclipse - Interfaz" (miralo con el conector de Figma): Roblox tiene que quedar igual.
Subí a Roblox las imágenes de linajes/arte/2d/ (íconos de Gemini ya limpios y piezas exportadas de Figma)
con el MCP de Studio, y anotá cada ID en Config.luau. Armá las pantallas por código en linajes/src/client/ui/
(un módulo por pantalla; Frames, UICorner, UIStroke y UIGradient donde se pueda, imágenes solo donde no),
con anclas y escalas para que se vean igual en compu y celular. Fuentes: las más parecidas a Saira
Condensed y Barlow en Font.new. Probá 1920x1080 y 844x390. Lo que dice abajo es el contenido mínimo de cada
pantalla (si Figma y esto no coinciden, manda Figma):
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
Captura de cada pantalla en compu y celular, al lado de su marco de Figma. Mostramelas y esperá mi OK. Commit y push.
```

---
[[P33c HUD y menús en Figma|← P33c HUD y menús en Figma]]   ·   [[Todos los prompts]]   ·   [[P34 Base y guardado|P34 Base y guardado →]]
