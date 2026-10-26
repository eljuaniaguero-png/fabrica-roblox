import subprocess, urllib.request, os
from PIL import Image, ImageDraw, ImageFont
B="https://azyjlkhpdgafuobyxoax.supabase.co/storage/v1/object/public/asset-models/3f5e8b51-0cea-4ead-9005-a6757f92df15/chat/remesh-"
L=[("M2","maquina-fondo-naves","01a17626-7003-75bd-b13c-b569cbbed30c"),("M3","maquina-fondo-autos","01a17626-7927-713c-87e3-47aa8baafc87"),("M4","maquina-fondo-laberinto","01a17626-8278-7094-b537-827d38df0e8b"),("M5","banqueta","01a17626-8a24-72a0-a3df-b8197b414337"),("M6","mesa-objetos","01a17626-9343-7058-9003-60bb849d045b"),("M7","mostrador-tienda","01a17626-9ce6-7769-841c-3e85c5783715"),("M8","cajita-vidrio","01a17626-a3e1-71db-b1a9-c38f1b3e833a"),("M9","pared-records","01a17626-af67-73a4-bbee-bb6471c57cd7"),("M10","molinete-entrada","01a17626-c8cc-7681-b552-35461002c952"),("M11","maceta-planta","01a17626-de92-7333-8896-7c489a452ff2"),("M12","tacho-basura",None),("M13","poste-neon","01a17626-e997-7702-9539-15a308a74dce")]
BL=r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"
os.makedirs("limpios/render",exist_ok=True)
for k,n,t in L:
    if t and not os.path.exists(f"limpios/{n}.glb"): urllib.request.urlretrieve(B+t+".glb",f"limpios/{n}.glb")
    subprocess.run([BL,"-b","--factory-startup","--python","scripts/render_glb.py","--",os.path.abspath(f"limpios/{n}.glb"),os.path.abspath(f"limpios/render/{n}.png")],capture_output=True)
c=320; W=4
s=Image.new('RGB',(W*c,3*(c+34)),(240,240,244)); d=ImageDraw.Draw(s); f=ImageFont.truetype("arial.ttf",20)
for i,(k,n,t) in enumerate(L):
    im=Image.open(f"limpios/render/{n}.png").convert('RGB'); im.thumbnail((c-6,c-6))
    x=(i%W)*c; y=(i//W)*(c+34); s.paste(im,(x+3,y+3)); d.text((x+8,y+c+4),f"{k} {n}",fill=(20,17,43),font=f)
s.save("limpios/todos-limpios.png"); print("ok")
