"""Convierte un video en material que Claude puede mirar y leer.

Uso:
  python herramientas/ver_video.py URL_O_ARCHIVO [--nombre x]
  python herramientas/ver_video.py URL --desde 12 --hasta 15 --fps 15   (cuadro por cuadro)

Deja en investigacion/<nombre>/: fotogramas, hojas de 4x4, indice.txt (segundo de
cada fotograma) y subtitulos. Es material de referencia: nunca se sube a Roblox.
"""

import argparse
import os
import re
import shutil
import subprocess
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
WINGET = Path(os.environ.get("LOCALAPPDATA", "")) / "Microsoft" / "WinGet" / "Packages"
LOCAL_BIN = Path.home() / ".local" / "bin"


def programa(nombre: str) -> str:
    ruta = shutil.which(nombre, path=os.pathsep.join([os.environ["PATH"], str(LOCAL_BIN), *map(str, WINGET.glob("Gyan.FFmpeg*/*/bin"))]))
    if not ruta:
        raise SystemExit(f"Falta instalar {nombre}")
    return ruta


def bajar(url: str, carpeta: Path) -> Path:
    # Se llama con uv: este Python de Windows no ve la carpeta Roaming donde quedó instalado.
    base = ["uv", "tool", "run", "yt-dlp", "--no-playlist", "--ffmpeg-location", str(Path(programa("ffmpeg")).parent)]
    subprocess.run(
        base + ["-f", "bv*[height<=720]+ba/b[height<=720]/b", "--merge-output-format", "mp4",
                "--write-info-json", "-o", str(carpeta / "video.%(ext)s"), url],
        check=True,
    )
    # Los subtítulos son un extra: si fallan, el video igual sirve.
    subprocess.run(
        base + ["--skip-download", "--write-subs", "--write-auto-subs", "--sub-langs", "en,es",
                "--sub-format", "vtt", "-o", str(carpeta / "subtitulos"), url],
        check=False,
    )
    return carpeta / "video.mp4"


def sacar_fotogramas(video: Path, salida: Path, args: argparse.Namespace) -> list[str]:
    salida.mkdir(parents=True, exist_ok=True)
    cmd = [programa("ffmpeg"), "-hide_banner", "-y"]
    if args.fps:
        cmd += ["-ss", str(args.desde), "-to", str(args.hasta), "-i", str(video)]
        filtro = f"fps={args.fps},showinfo,scale=480:-2"
    else:
        # Un fotograma por cada cambio de escena, y al menos uno cada N segundos.
        cmd += ["-i", str(video)]
        seleccion = f"gt(scene\\,{args.escena})+isnan(prev_selected_t)+gte(t-prev_selected_t\\,{args.cada})"
        filtro = f"select='{seleccion}',showinfo,scale=480:-2"
    cmd += ["-vf", filtro, "-fps_mode", "vfr", "-q:v", "4", str(salida / "f_%04d.jpg")]
    resultado = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if resultado.returncode:
        raise SystemExit(resultado.stderr[-1500:])
    return re.findall(r"pts_time:([\d.]+)", resultado.stderr)


def armar_hojas(salida: Path) -> None:
    subprocess.run(
        [programa("ffmpeg"), "-hide_banner", "-loglevel", "error", "-y", "-framerate", "1",
         "-i", str(salida / "f_%04d.jpg"), "-vf", "tile=4x4:padding=4", "-q:v", "4",
         str(salida / "hoja_%02d.jpg")],
        check=True,
    )


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("fuente")
    p.add_argument("--nombre", default="video")
    p.add_argument("--escena", type=float, default=0.3, help="sensibilidad al cambio de escena")
    p.add_argument("--cada", type=float, default=10, help="segundos máximos entre fotogramas")
    p.add_argument("--desde", type=float, default=0)
    p.add_argument("--hasta", type=float, default=0)
    p.add_argument("--fps", type=float, default=0, help="cuadro por cuadro en el tramo elegido")
    args = p.parse_args()

    carpeta = RAIZ / "investigacion" / args.nombre
    carpeta.mkdir(parents=True, exist_ok=True)
    if Path(args.fuente).is_file():
        video = Path(args.fuente)
    elif (carpeta / "video.mp4").is_file():
        video = carpeta / "video.mp4"
    else:
        video = bajar(args.fuente, carpeta)

    salida = carpeta / (f"tramo_{args.desde:g}-{args.hasta:g}" if args.fps else "escenas")
    tiempos = sacar_fotogramas(video, salida, args)
    armar_hojas(salida)
    indice = [f"f_{i:04d}.jpg  {args.desde + float(t):.2f}s" for i, t in enumerate(tiempos, 1)]
    (salida / "indice.txt").write_text("\n".join(indice), encoding="utf-8")
    print(f"{len(tiempos)} fotogramas en {salida}")


if __name__ == "__main__":
    main()
