import json, numpy as np
from PIL import Image, ImageDraw, ImageFilter
files=json.load(open("files.json"))
def recortar(i, interior=0, huecos=False):
    im=Image.open(files[i]).convert("RGB")
    s=512/max(im.size); im=im.resize((round(im.width*s),round(im.height*s)),Image.LANCZOS)
    a=np.asarray(im).astype(int); h,w,_=a.shape
    border=np.concatenate([a[0],a[-1],a[:,0],a[:,-1]])
    bg=np.median(border,axis=0)
    lum=0.3*a[...,0]+0.59*a[...,1]+0.11*a[...,2]
    dist=np.sqrt(((a-bg)**2).sum(-1))
    pas=(lum>85)|(dist<60)
    linea=Image.fromarray(((~pas)*255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))
    m=Image.fromarray((255-np.asarray(linea)).astype(np.uint8))
    # pad so flood reaches around
    pm=Image.new("L",(w+2,h+2),255); pm.paste(m,(1,1))
    ImageDraw.floodfill(pm,(0,0),128)
    if huecos:
        ys,xs=np.where((dist<40))
        for y,x in zip(ys,xs):
            if pm.getpixel((x+1,y+1))==255: ImageDraw.floodfill(pm,(x+1,y+1),128)
    fondo=(np.asarray(pm)[1:-1,1:-1]==128)
    fd=Image.fromarray((fondo*255).astype(np.uint8)).filter(ImageFilter.MaxFilter(7))
    fondo=(np.asarray(fd)>0)&pas
    if interior: fondo|=dist<interior
    alpha=Image.fromarray(((~fondo)*255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.6))
    out=im.convert("RGBA"); out.putalpha(alpha)
    bb=out.getbbox(); out=out.crop(bb)
    return out, bg
if __name__=="__main__":
    for i in range(1,64):
        o,bg=recortar(i, interior={42:70}.get(i,0), huecos=(i==15))
        o.save(f"rec/{i:02d}.png")
