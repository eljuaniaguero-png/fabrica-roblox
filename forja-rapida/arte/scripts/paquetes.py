"""Junta los FBX de arte/fbx en 2 paquetes para importarlos de una vez en Studio (17/10/2026).

  _PaqueteMapa.fbx     decoración del mapa (Deco_Comun, Deco_Zona1..5) y Tablero.
  _PaqueteObjetos.fbx  geodas, gemas, estatuas, picos y los efectos de eventos.

Cada archivo queda adentro de un grupo con su nombre (por ejemplo "Deco_Zona2"); Blender agrega
".001" a los nombres repetidos y el juego los ordena al cargarlos (ver Modelos en la ficha).

Uso: <blender.exe> -b --factory-startup --python forja-rapida/arte/scripts/paquetes.py
"""

import os

import bpy

FBX = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "fbx")
PAQUETES = {
    "_PaqueteMapa": ["Deco_Comun"] + ["Deco_Zona%d" % n for n in range(1, 6)] + ["Tablero"],
    "_PaqueteObjetos": ["Geodas_Zona%d" % n for n in range(1, 6)]
    + ["Gemas_Zona%d" % n for n in range(1, 6)]
    + ["Geodas_Especiales", "Geoda_Pequena", "Geoda_Mediana", "Geoda_Gigante", "Geoda_Jefe"]
    + ["Geoda_Ancestral", "Geoda_Anillo", "BombaLava", "CristalLluvia"]
    + ["Estatua_" + r for r in ("Comun", "Raro", "Epico", "Legendario", "Mitico")]
    + ["Gema_" + r for r in ("Comun", "Raro", "Epico", "Legendario", "Mitico")]
    + ["Pico_" + p for p in ("Madera", "Piedra", "Hierro", "Oro", "Cosmico")],
}

for paquete, archivos in PAQUETES.items():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for nombre in archivos:
        antes = set(bpy.data.objects)
        bpy.ops.import_scene.fbx(filepath=os.path.join(FBX, nombre + ".fbx"))
        nuevos = [o for o in bpy.data.objects if o not in antes]
        for o in nuevos:  # el cubo suelto que quedó en algún archivo
            if o.name.startswith("Cube") and not o.parent and not o.children:
                bpy.data.objects.remove(o)
        nuevos = [o for o in bpy.data.objects if o not in antes]
        ya = [o for o in nuevos if not o.parent and o.name == nombre]
        if ya:  # el archivo ya trae su grupo con ese nombre
            continue
        grupo = bpy.data.objects.new(nombre, None)
        bpy.context.scene.collection.objects.link(grupo)
        for o in nuevos:
            if not o.parent:
                m = o.matrix_world.copy()
                o.parent = grupo
                o.matrix_world = m
        if grupo.name != nombre:
            raise SystemExit("nombre repetido: " + grupo.name)
    salida = os.path.join(FBX, paquete + ".fbx")
    bpy.ops.export_scene.fbx(filepath=salida, object_types={"EMPTY", "MESH"}, bake_anim=False)
    print("PAQUETE", paquete, len(bpy.data.objects), round(os.path.getsize(salida) / 1e6, 1), "MB")
