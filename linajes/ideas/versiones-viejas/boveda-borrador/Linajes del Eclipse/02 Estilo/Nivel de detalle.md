---
tags: [estilo]
---
# Nivel de detalle obligatorio

El PASO 1 es un boceto de bloques a propósito: sirve solo para aprobar la forma y SIEMPRE se ve simple. El PASO 2 tiene que cumplir todo esto, si no, no se aprueba:
- **Bisel en todos los bordes** (0,02 a 0,05 studs, 2 segmentos): nada de cajas con aristas filosas.
- **Capas**: cada placa de armadura es una pieza encima de otra, con grosor y borde levantado, nunca un color pintado sobre una caja.
- **Líneas de panel, costuras, remaches y tornillos** modelados o en el normal map (mínimo 10 detalles chicos por pieza grande).
- **Formas curvas** donde corresponde (hombreras, cascos, peto con músculos marcados), con subdivisión antes de reducir al presupuesto.
- **Telas** (capas, bufandas, faldas) con simulación de tela en Blender, horneada con pliegues reales.
- **Alto y bajo poligonaje**: se esculpe una versión con mucho detalle, se hornea su normal map (OpenGL, 1024 px) sobre la versión del presupuesto de triángulos.
- **Texturas con desgaste**: rayones en metal, bordes más claros, suciedad en las juntas (ambient occlusion horneado). Nada de colores planos sin textura.
- **Comparación**: el render del PASO 2 va al lado del boceto del PASO 1 y tiene que verse claramente distinto.


Ver también: [[Guía de estilo]] · [[Reglas de los prompts]]
