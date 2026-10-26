# Render rápido de un .glb (vista 3/4) para revisar modelos sin abrir Blender.
# Uso: blender -b --factory-startup --python render_glb.py -- entrada.glb salida.png
import bpy, sys, math
from mathutils import Vector
a = sys.argv[sys.argv.index("--") + 1:]
entrada, salida = a[0], a[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=entrada)
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
mn = Vector((1e9,) * 3); mx = Vector((-1e9,) * 3)
for o in objs:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c)
        mn = Vector(map(min, mn, w)); mx = Vector(map(max, mx, w))
centro = (mn + mx) / 2; tam = max(mx - mn)
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
bpy.context.scene.collection.objects.link(cam)
d = tam * 2.2
cam.location = centro + Vector((d * 0.55, -d * 0.8, d * 0.35))
cam.rotation_euler = (centro - cam.location).to_track_quat("-Z", "Y").to_euler()
bpy.context.scene.camera = cam
luz = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN"))
luz.data.energy = 3; luz.rotation_euler = (math.radians(50), 0, math.radians(30))
bpy.context.scene.collection.objects.link(luz)
w = bpy.data.worlds.new("w"); w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (0.25, 0.25, 0.27, 1)
w.node_tree.nodes["Background"].inputs[1].default_value = 1.0
bpy.context.scene.world = w
r = bpy.context.scene.render
r.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in [e.identifier for e in r.bl_rna.properties["engine"].enum_items] else "BLENDER_EEVEE"
r.resolution_x = r.resolution_y = 512
r.filepath = salida
bpy.ops.render.render(write_still=True)
