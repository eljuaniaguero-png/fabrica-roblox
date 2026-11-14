"""Genera en SVG vectorial de alta precisión (renderizado via Edge con doble pase negro/blanco
para alfa RGBA perfecto sin halos) todos los íconos geométricos, emblemas de bandos a color
y símbolos de Linajes restantes de Linajes del Eclipse.

Uso:
    python linajes/arte/scripts/vectores_menu.py
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

from PIL import Image

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from menu_procesar import DOSD, HUD_LISTAS, encajar, render_svg_transparente


def _pt(cx: float, cy: float, r: float, deg: float) -> tuple[float, float]:
    rad = math.radians(deg)
    return (cx + r * math.cos(rad), cy + r * math.sin(rad))


def _poly(pts: list[tuple[float, float]]) -> str:
    return " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)


# ---------------------------------------------------------------------------
# A. 4 Emblemas de Bandos (a color, forma distinta por bando, contorno #0E1016)
# ---------------------------------------------------------------------------

def svg_emblema_liga() -> str:
    # Escudo hexagonal angosto azul #2F6FDB + sol naciente y rayo Hueso #EDE6D6 + oro #D9A441
    return """
    <defs>
      <clipPath id="clipLiga">
        <polygon points="256,56 406,112 384,316 256,456 128,316 106,112"/>
      </clipPath>
    </defs>
    <polygon points="256,56 406,112 384,316 256,456 128,316 106,112"
             fill="#2F6FDB" stroke="#0E1016" stroke-width="22" stroke-linejoin="miter"/>
    <g clip-path="url(#clipLiga)">
      <polygon points="256,56 406,112 384,316 256,456" fill="#2152A8"/>
      <polygon points="256,74 388,124 368,308 256,434 144,308 124,124"
               fill="none" stroke="#EDE6D6" stroke-width="4" stroke-opacity="0.55"/>
      <!-- Sol naciente y rayos calados -->
      <polygon points="256,110 278,218 234,218" fill="#EDE6D6" stroke="#0E1016" stroke-width="6"/>
      <polygon points="154,160 226,232 204,252" fill="#EDE6D6" stroke="#0E1016" stroke-width="6"/>
      <polygon points="358,160 308,252 286,232" fill="#EDE6D6" stroke="#0E1016" stroke-width="6"/>
      <path d="M 180,298 A 76,76 0 0,1 332,298 Z" fill="#EDE6D6" stroke="#0E1016" stroke-width="8"/>
      <polygon points="164,314 348,314 330,336 182,336" fill="#D9A441" stroke="#0E1016" stroke-width="7"/>
      <polygon points="256,356 276,386 256,416 236,386" fill="#D9A441" stroke="#0E1016" stroke-width="6"/>
    </g>
    <polygon points="256,56 406,112 384,316 256,456 128,316 106,112"
             fill="none" stroke="#0E1016" stroke-width="18" stroke-linejoin="miter"/>
    """


def svg_emblema_cofradia() -> str:
    # Rombo alargado vertical carmesí #C2213A partido diagonalmente por daga Hueso #EDE6D6
    return """
    <polygon points="256,46 392,256 256,466 120,256"
             fill="#C2213A" stroke="#0E1016" stroke-width="22" stroke-linejoin="miter"/>
    <polygon points="256,46 392,256 256,466" fill="#8E2A22"/>
    <polygon points="256,74 366,256 256,438 146,256"
             fill="none" stroke="#EDE6D6" stroke-width="4" stroke-opacity="0.45"/>
    <!-- Corte diagonal de daga -->
    <polygon points="104,408 398,114 426,86 382,154 142,394"
             fill="#0E1016"/>
    <polygon points="108,404 422,90 388,152 140,400"
             fill="#EDE6D6" stroke="#0E1016" stroke-width="10" stroke-linejoin="miter"/>
    <!-- Empuñadura y guarda inferior izq -->
    <polygon points="154,302 210,358 192,374 138,318"
             fill="#D9A441" stroke="#0E1016" stroke-width="8"/>
    <polygon points="94,418 134,378 148,392 108,432"
             fill="#EDE6D6" stroke="#0E1016" stroke-width="8"/>
    """


def svg_emblema_vigilantes() -> str:
    # Emblema en V vertical de dos alas/plumas angulares plegadas violeta #6B5BA8
    return """
    <polygon points="256,458 106,154 156,74 220,218 220,104 256,56 292,104 292,218 356,74 406,154"
             fill="#6B5BA8" stroke="#0E1016" stroke-width="22" stroke-linejoin="miter"/>
    <polygon points="256,458 256,56 292,104 292,218 356,74 406,154"
             fill="#4F4085"/>
    <!-- Muescas de plumas angulares en los flancos -->
    <polygon points="122,190 184,224 134,218" fill="#0E1016"/>
    <polygon points="148,248 202,276 160,274" fill="#0E1016"/>
    <polygon points="390,190 328,224 378,218" fill="#0E1016"/>
    <polygon points="364,248 310,276 352,274" fill="#0E1016"/>
    <!-- Hendidura vertical central Hueso -->
    <polygon points="256,118 274,234 256,374 238,234"
             fill="#EDE6D6" stroke="#0E1016" stroke-width="10"/>
    <polygon points="256,458 106,154 156,74 220,218 220,104 256,56 292,104 292,218 356,74 406,154"
             fill="none" stroke="#0E1016" stroke-width="16" stroke-linejoin="miter"/>
    """


def svg_emblema_neutral() -> str:
    # Aro incompleto metálico #8A8F99 rodeando un disco partido de eclipse
    return """
    <defs>
      <clipPath id="ringClip">
        <circle cx="256" cy="256" r="184"/>
      </clipPath>
      <mask id="ringGap">
        <rect width="512" height="512" fill="white"/>
        <circle cx="256" cy="256" r="126" fill="black"/>
        <polygon points="256,256 350,40 480,140" fill="black"/>
        <polygon points="256,256 162,472 32,372" fill="black"/>
      </mask>
    </defs>
    <!-- Aro exterior partido -->
    <g mask="url(#ringGap)">
      <circle cx="256" cy="256" r="184" fill="#8A8F99"/>
      <polygon points="256,256 512,512 0,512 0,256" fill="#5D6472" clip-path="url(#ringClip)"/>
      <circle cx="256" cy="256" r="184" fill="none" stroke="#0E1016" stroke-width="24"/>
      <circle cx="256" cy="256" r="126" fill="none" stroke="#0E1016" stroke-width="24"/>
    </g>
    <!-- Tapas angulares en cortes del aro -->
    <polygon points="318,78 334,132 344,126 328,74" fill="#0E1016"/>
    <polygon points="194,434 178,380 168,386 184,438" fill="#0E1016"/>
    <!-- Disco interior partido -->
    <path d="M 192,192 A 92,92 0 0,1 322,320 L 266,272 L 246,240 Z"
          fill="#EDE6D6" stroke="#0E1016" stroke-width="14" stroke-linejoin="miter"/>
    <path d="M 320,322 A 92,92 0 0,1 190,194 L 246,240 L 266,272 Z"
          fill="#1D2230" stroke="#0E1016" stroke-width="14" stroke-linejoin="miter"/>
    """


# ---------------------------------------------------------------------------
# B. 9 Íconos Monocromo HUD / Menú / Economía (#FFFFFF + transparencia pura)
# ---------------------------------------------------------------------------

def svg_icono_bloqueo() -> str:
    return """
    <defs>
      <mask id="cutShield">
        <rect width="512" height="512" fill="white"/>
        <!-- Cortes cómic en Y separando las 3 placas -->
        <polygon points="244,74 268,74 268,248 256,262 244,248" fill="black"/>
        <polygon points="256,246 112,332 126,352 256,274 386,352 400,332" fill="black"/>
        <polygon points="256,162 290,196 256,230 222,196" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#cutShield)">
      <polygon points="256,70 416,126 392,316 256,448 120,316 96,126" fill="#FFFFFF"/>
    </g>
    <polygon points="256,174 278,196 256,218 234,196" fill="#FFFFFF"/>
    """


def svg_estrella_buscado() -> str:
    outer = 204
    inner = 74
    pts: list[tuple[float, float]] = []
    for i in range(10):
        ang = -90 + i * 36
        r = outer if i % 2 == 0 else inner
        pts.append(_pt(256, 266, r, ang))

    # Facetas negativas en cada brazo derecho para estética afilada editorial
    facets = []
    for i in range(5):
        ang_tip = -90 + i * 72
        ang_valley = ang_tip + 36
        p_c = (256.0, 266.0)
        p_t = _pt(256, 266, outer - 18, ang_tip)
        p_v = _pt(256, 266, inner - 8, ang_valley)
        facets.append(f'<polygon points="{_poly([p_c, p_t, p_v])}" fill="black"/>')

    return f"""
    <defs>
      <mask id="starMask">
        <rect width="512" height="512" fill="white"/>
        {''.join(facets)}
        <polygon points="256,242 276,266 256,290 236,266" fill="black"/>
      </mask>
    </defs>
    <polygon points="{_poly(pts)}" fill="#FFFFFF" mask="url(#starMask)"/>
    <polygon points="256,252 268,266 256,280 244,266" fill="#FFFFFF"/>
    """


def svg_flecha_menu() -> str:
    return """
    <polygon points="88,256 132,212 176,256 132,300" fill="#FFFFFF"/>
    <polygon points="216,124 416,256 216,388 266,256" fill="#FFFFFF"/>
    """


def svg_rueda_ruleta() -> str:
    ticks = []
    for i in range(24):
        deg = i * 15 - 90
        r_out = 216
        r_in = 172 if i % 2 == 0 else 194
        w = 10 if i % 2 == 0 else 5
        x1, y1 = _pt(256, 256, r_in, deg)
        x2, y2 = _pt(256, 256, r_out, deg)
        ticks.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="#FFFFFF" stroke-width="{w}"/>')

    spokes = []
    for i in range(6):
        deg = i * 60 - 90
        x1, y1 = _pt(256, 256, 76, deg)
        x2, y2 = _pt(256, 256, 162, deg)
        spokes.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="#FFFFFF" stroke-width="7"/>')

    return f"""
    <circle cx="256" cy="256" r="222" fill="none" stroke="#FFFFFF" stroke-width="11"/>
    <circle cx="256" cy="256" r="164" fill="none" stroke="#FFFFFF" stroke-width="6" stroke-opacity="0.88"/>
    <circle cx="256" cy="256" r="74" fill="none" stroke="#FFFFFF" stroke-width="9"/>
    <polygon points="256,238 274,256 256,274 238,256" fill="#FFFFFF"/>
    {''.join(ticks)}
    {''.join(spokes)}
    <polygon points="256,14 278,46 256,78 234,46" fill="#FFFFFF"/>
    """


def svg_icono_ajustes() -> str:
    teeth = []
    for i in range(8):
        deg = i * 45
        p1 = _pt(256, 256, 194, deg - 11)
        p2 = _pt(256, 256, 194, deg + 11)
        p3 = _pt(256, 256, 146, deg + 16)
        p4 = _pt(256, 256, 146, deg - 16)
        teeth.append(f'<polygon points="{_poly([p1, p2, p3, p4])}" fill="#FFFFFF"/>')

    return f"""
    <defs>
      <mask id="gearHole">
        <rect width="512" height="512" fill="white"/>
        <circle cx="256" cy="256" r="78" fill="black"/>
        <circle cx="256" cy="256" r="118" fill="none" stroke="black" stroke-width="12"/>
      </mask>
      <mask id="hubCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,224 288,256 256,288 224,256" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#gearHole)">
      <circle cx="256" cy="256" r="154" fill="#FFFFFF"/>
      {''.join(teeth)}
    </g>
    <polygon points="256,198 314,256 256,314 198,256" fill="#FFFFFF" mask="url(#hubCut)"/>
    """


def svg_icono_arbol() -> str:
    # Tres ramas con nodos rombo 45° conectados por líneas rectas con centros calados reales
    nodos_coords = [(256, 404, 48), (122, 196, 46), (390, 196, 46), (256, 118, 54)]
    agujeros = []
    rombos = []
    for cx, cy, r in nodos_coords:
        pts = [(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)]
        in_pts = [(cx, cy - r * 0.45), (cx + r * 0.45, cy), (cx, cy + r * 0.45), (cx - r * 0.45, cy)]
        agujeros.append(f'<polygon points="{_poly(in_pts)}" fill="black"/>')
        rombos.append(f'<polygon points="{_poly(pts)}" fill="#FFFFFF"/>')

    return f"""
    <defs>
      <mask id="treeMask">
        <rect width="512" height="512" fill="white"/>
        {''.join(agujeros)}
      </mask>
    </defs>
    <g mask="url(#treeMask)">
      <line x1="256" y1="398" x2="256" y2="128" stroke="#FFFFFF" stroke-width="18"/>
      <line x1="256" y1="316" x2="122" y2="196" stroke="#FFFFFF" stroke-width="18"/>
      <line x1="256" y1="316" x2="390" y2="196" stroke="#FFFFFF" stroke-width="18"/>
      {''.join(rombos)}
    </g>
    """


def svg_icono_taller() -> str:
    return """
    <defs>
      <mask id="hammerGap">
        <rect width="512" height="512" fill="white"/>
        <!-- Borde negro alrededor del martillo (+45°) para cruce limpio sobre la llave -->
        <g transform="rotate(45 256 256)">
          <rect x="230" y="138" width="52" height="294" rx="4" fill="black"/>
          <polygon points="150,94 350,94 380,126 350,164 150,164 150,94" fill="black"/>
        </g>
      </mask>
      <mask id="wrenchHole">
        <rect width="512" height="512" fill="white"/>
        <circle cx="256" cy="404" r="14" fill="black"/>
      </mask>
    </defs>
    <!-- Llave inglesa diagonal (-45°) -->
    <g mask="url(#hammerGap)">
      <g mask="url(#wrenchHole)" transform="rotate(-45 256 256)">
        <rect x="238" y="148" width="36" height="248" fill="#FFFFFF"/>
        <path d="M 210,74 L 228,118 L 284,118 L 302,74 A 60,60 0 1,1 210,74 Z" fill="#FFFFFF"/>
        <circle cx="256" cy="404" r="32" fill="#FFFFFF"/>
      </g>
    </g>
    <!-- Martillo diagonal (+45°) encima -->
    <g transform="rotate(45 256 256)">
      <rect x="242" y="152" width="28" height="268" fill="#FFFFFF"/>
      <polygon points="164,104 342,104 366,128 342,152 164,152" fill="#FFFFFF"/>
    </g>
    """


def svg_icono_candado() -> str:
    return """
    <path d="M 164,228 L 164,164 A 92,92 0 0,1 348,164 L 348,228"
          fill="none" stroke="#FFFFFF" stroke-width="34" stroke-linecap="butt"/>
    <defs>
      <mask id="lockCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,282 292,318 256,354 220,318" fill="black"/>
        <polygon points="244,344 268,344 274,398 238,398" fill="black"/>
        <line x1="120" y1="256" x2="392" y2="256" stroke="black" stroke-width="10"/>
      </mask>
    </defs>
    <polygon points="132,226 380,226 392,248 392,422 368,444 144,444 120,422 120,248"
             fill="#FFFFFF" mask="url(#lockCut)"/>
    """


def svg_moneda_ficha_eclipse() -> str:
    return """
    <defs>
      <mask id="eclipseCoinCut">
        <rect width="512" height="512" fill="white"/>
        <circle cx="256" cy="256" r="144" fill="black"/>
        <circle cx="256" cy="256" r="122" fill="white"/>
        <circle cx="276" cy="244" r="90" fill="black"/>
        <polygon points="62,250 176,244 176,264 62,258" fill="black"/>
        <polygon points="450,250 336,244 336,264 450,258" fill="black"/>
      </mask>
    </defs>
    <circle cx="256" cy="256" r="190" fill="#FFFFFF" mask="url(#eclipseCoinCut)"/>
    """


# ---------------------------------------------------------------------------
# C. 8 Íconos de Linajes faltantes (monocromo cómic #FFFFFF + transparencia)
# ---------------------------------------------------------------------------

def svg_linaje_criogenia() -> str:
    arms = []
    for i in range(6):
        deg = i * 60 - 90
        p1 = _pt(256, 256, 206, deg)
        p2 = _pt(256, 256, 152, deg + 10)
        p3 = _pt(256, 256, 62, deg + 18)
        p4 = _pt(256, 256, 62, deg - 18)
        p5 = _pt(256, 256, 152, deg - 10)
        arms.append(f'<polygon points="{_poly([p1, p2, p3, p4, p5])}" fill="#FFFFFF"/>')
        # Púas laterales de cristal
        b1 = _pt(256, 256, 134, deg + 16)
        b2 = _pt(256, 256, 162, deg + 24)
        b3 = _pt(256, 256, 114, deg + 24)
        arms.append(f'<polygon points="{_poly([b1, b2, b3])}" fill="#FFFFFF"/>')
        c1 = _pt(256, 256, 134, deg - 16)
        c2 = _pt(256, 256, 162, deg - 24)
        c3 = _pt(256, 256, 114, deg - 24)
        arms.append(f'<polygon points="{_poly([c1, c2, c3])}" fill="#FFFFFF"/>')

    hex_in = [_pt(256, 256, 48, i * 60 - 90) for i in range(6)]
    hex_core = [_pt(256, 256, 24, i * 60 - 90) for i in range(6)]
    return f"""
    <defs>
      <mask id="iceCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="{_poly(hex_in)}" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#iceCut)">
      {''.join(arms)}
    </g>
    <polygon points="{_poly(hex_core)}" fill="#FFFFFF"/>
    """


def svg_icono_dash() -> str:
    # Esquive / Dash direccional: silueta angular inclinada 35° lanzándose adelante + 2 ecos fantasma detrás
    return """
    <defs>
      <mask id="dashEchoMask">
        <rect width="512" height="512" fill="white"/>
        <polygon points="36,154 220,154 208,170 36,170" fill="black"/>
        <polygon points="28,236 254,236 242,254 28,254" fill="black"/>
        <polygon points="44,318 232,318 220,336 44,336" fill="black"/>
      </mask>
    </defs>
    <!-- Dos estelas fantasma escalonadas detrás -->
    <g mask="url(#dashEchoMask)">
      <polygon points="78,128 196,128 134,256 196,384 78,384 140,256" fill="#FFFFFF" opacity="0.48"/>
      <polygon points="154,116 286,116 218,256 286,396 154,396 222,256" fill="#FFFFFF" opacity="0.78"/>
    </g>
    <!-- Flecha/cuerpo principal lanzándose en punta hacia la derecha + círculo cabeza estilizada -->
    <circle cx="348" cy="144" r="32" fill="#FFFFFF"/>
    <polygon points="234,178 446,248 258,396 312,268 188,268" fill="#FFFFFF"/>
    <!-- Rayas rápidas en primer plano -->
    <polygon points="56,374 214,374 200,392 56,392" fill="#FFFFFF"/>
    <polygon points="72,110 218,110 206,126 72,126" fill="#FFFFFF"/>
    """


def svg_linaje_telequinesis() -> str:
    return """
    <defs>
      <mask id="teleCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,142 326,256 256,370 186,256" fill="black"/>
      </mask>
      <mask id="teleCenterCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,204 282,256 256,308 230,256" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#teleCut)">
      <ellipse cx="256" cy="256" rx="198" ry="66" transform="rotate(-30 256 256)" fill="none" stroke="#FFFFFF" stroke-width="18"/>
      <ellipse cx="256" cy="256" rx="198" ry="66" transform="rotate(30 256 256)" fill="none" stroke="#FFFFFF" stroke-width="18"/>
      <ellipse cx="256" cy="256" rx="172" ry="52" transform="rotate(90 256 256)" fill="none" stroke="#FFFFFF" stroke-width="14"/>
    </g>
    <polygon points="256,162 308,256 256,350 204,256" fill="#FFFFFF" mask="url(#teleCenterCut)"/>
    """


def svg_linaje_velocista() -> str:
    return """
    <defs>
      <mask id="velCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="62,194 316,194 302,210 62,210" fill="black"/>
        <polygon points="48,252 346,252 332,268 48,268" fill="black"/>
        <polygon points="74,310 310,310 296,326 74,326" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#velCut)">
      <polygon points="154,104 426,246 218,396 270,262 108,262" fill="#FFFFFF"/>
    </g>
    <polygon points="68,142 186,142 162,162 68,162" fill="#FFFFFF"/>
    <polygon points="46,220 198,220 180,236 46,236" fill="#FFFFFF"/>
    <polygon points="78,342 214,342 198,358 78,358" fill="#FFFFFF"/>
    """


def svg_linaje_sombra_viva() -> str:
    return """
    <defs>
      <mask id="shadowMask">
        <rect width="512" height="512" fill="white"/>
        <!-- Vacío interno del rostro en la capucha y ojos rasgados -->
        <polygon points="256,126 306,184 284,264 256,282 228,264 206,184" fill="black"/>
        <!-- Cortes verticales entre zarcillos -->
        <polygon points="168,318 186,448 158,448 148,328" fill="black"/>
        <polygon points="222,306 232,456 206,456 204,314" fill="black"/>
        <polygon points="290,306 306,314 306,456 280,456" fill="black"/>
        <polygon points="344,318 364,328 354,448 326,448" fill="black"/>
      </mask>
    </defs>
    <path mask="url(#shadowMask)" d="M 256,66 L 348,144 L 388,334 L 408,434 L 352,386 L 320,452 L 284,382 L 256,458 L 228,382 L 192,452 L 160,386 L 104,434 L 124,334 L 164,144 Z"
          fill="#FFFFFF"/>
    <!-- Ojos estrechos y afilados dentro de la capucha -->
    <polygon points="218,196 246,210 226,216" fill="#FFFFFF"/>
    <polygon points="294,196 286,216 266,210" fill="#FFFFFF"/>
    """


def svg_linaje_sangre_abisal() -> str:
    return """
    <!-- Ola abisal en espiral con crestas afiladas -->
    <path d="M 102,334 C 90,210 184,116 306,120 C 378,122 414,170 400,224 C 362,178 308,166 268,186 C 218,210 212,268 258,284 C 288,294 316,278 326,252 C 314,318 254,352 198,338 C 148,324 128,354 114,382 Z"
          fill="#FFFFFF"/>
    <!-- Espinas/crestas abisales superiores -->
    <polygon points="208,136 254,78 262,126" fill="#FFFFFF"/>
    <polygon points="274,122 328,74 326,128" fill="#FFFFFF"/>
    <polygon points="338,132 398,104 378,154" fill="#FFFFFF"/>
    <!-- Gotas afiladas abajo -->
    <polygon points="236,356 254,412 236,426 218,412" fill="#FFFFFF"/>
    <polygon points="312,336 330,394 312,408 294,394" fill="#FFFFFF"/>
    <polygon points="384,306 400,356 384,368 368,356" fill="#FFFFFF"/>
    """


def svg_linaje_origen_estelar() -> str:
    return """
    <defs>
      <mask id="starOrbitMask">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,64 294,218 448,256 294,294 256,448 218,294 64,256 218,218" fill="black"/>
      </mask>
      <mask id="starCenterCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,226 286,256 256,286 226,256" fill="black"/>
      </mask>
    </defs>
    <!-- Aro orbital inclinado -->
    <g mask="url(#starOrbitMask)">
      <path d="M 120,168 A 164,164 0 1,1 142,368" fill="none" stroke="#FFFFFF" stroke-width="20"/>
    </g>
    <!-- Estrella radiante 4 puntas alargadas con rombo calado -->
    <polygon points="256,66 286,226 446,256 286,286 256,446 226,286 66,256 226,226" fill="#FFFFFF" mask="url(#starCenterCut)"/>
    <!-- Estrellas satélite -->
    <polygon points="122,122 134,142 154,154 134,166 122,186 110,166 90,154 110,142" fill="#FFFFFF"/>
    <polygon points="392,344 402,360 418,370 402,380 392,396 382,380 366,370 382,360" fill="#FFFFFF"/>
    """


def svg_linaje_herencia_olimpica() -> str:
    # Punta de lanza alada central + ramas de laurel angulares simétricas
    return """
    <defs>
      <mask id="spearCut">
        <rect width="512" height="512" fill="white"/>
        <polygon points="256,118 272,182 256,212 240,182" fill="black"/>
      </mask>
    </defs>
    <polygon points="256,56 312,186 276,228 276,438 236,438 236,228 200,186" fill="#FFFFFF" mask="url(#spearCut)"/>
    <!-- Laureles geométricos izquierda -->
    <polygon points="172,388 122,344 138,314 196,356" fill="#FFFFFF"/>
    <polygon points="136,320 96,262 124,234 168,288" fill="#FFFFFF"/>
    <polygon points="124,236 106,168 142,150 164,212" fill="#FFFFFF"/>
    <polygon points="148,154 156,102 188,108 184,158" fill="#FFFFFF"/>
    <!-- Laureles geométricos derecha -->
    <polygon points="340,388 390,344 374,314 316,356" fill="#FFFFFF"/>
    <polygon points="376,320 416,262 388,234 344,288" fill="#FFFFFF"/>
    <polygon points="388,236 406,168 370,150 348,212" fill="#FFFFFF"/>
    <polygon points="364,154 356,102 324,108 328,158" fill="#FFFFFF"/>
    """


def svg_linaje_eclipse() -> str:
    # Corona solar irregular afilada + disco interior vacío + grieta de luz diagonal
    rays = []
    for i in range(16):
        deg = i * 22.5
        r_out = 208 if i % 2 == 0 else 174
        p_tip = _pt(256, 256, r_out, deg)
        p_l = _pt(256, 256, 134, deg - 9)
        p_r = _pt(256, 256, 134, deg + 9)
        rays.append(f'<polygon points="{_poly([p_l, p_tip, p_r])}" fill="#FFFFFF"/>')

    return f"""
    <defs>
      <mask id="ecGlyphMask">
        <rect width="512" height="512" fill="white"/>
        <circle cx="246" cy="256" r="108" fill="black"/>
        <polygon points="84,412 414,82 430,98 100,428" fill="black"/>
      </mask>
    </defs>
    <g mask="url(#ecGlyphMask)">
      <circle cx="256" cy="256" r="144" fill="#FFFFFF"/>
      {''.join(rays)}
    </g>
    <polygon points="104,394 396,102 410,116 118,408" fill="#FFFFFF"/>
    """


def main() -> None:
    DOSD.mkdir(parents=True, exist_ok=True)
    HUD_LISTAS.mkdir(parents=True, exist_ok=True)

    emblemas = {
        "emblema-liga": svg_emblema_liga(),
        "emblema-cofradia": svg_emblema_cofradia(),
        "emblema-vigilantes": svg_emblema_vigilantes(),
        "emblema-neutral": svg_emblema_neutral(),
    }
    for nombre, svg in emblemas.items():
        img = render_svg_transparente(svg, 512, 512, DOSD / f"{nombre}.png")
        encajar(img, (512, 512), margen=0.04, crop=True).save(DOSD / f"{nombre}.png")
        encajar(img, (256, 256), margen=0.06, crop=True).save(HUD_LISTAS / f"{nombre}.png")
        print("listo vector color:", nombre)

    monocromos: dict[str, tuple[str, tuple[int, int]]] = {
        "icono-bloqueo": (svg_icono_bloqueo(), (256, 256)),
        "icono-dash": (svg_icono_dash(), (256, 256)),
        "estrella-buscado": (svg_estrella_buscado(), (256, 256)),
        "flecha-menu": (svg_flecha_menu(), (256, 256)),
        "rueda-ruleta": (svg_rueda_ruleta(), (512, 512)),
        "icono-ajustes": (svg_icono_ajustes(), (256, 256)),
        "icono-arbol": (svg_icono_arbol(), (256, 256)),
        "icono-taller": (svg_icono_taller(), (256, 256)),
        "icono-candado": (svg_icono_candado(), (256, 256)),
        "moneda-ficha-eclipse": (svg_moneda_ficha_eclipse(), (256, 256)),
        "linaje-criogenia": (svg_linaje_criogenia(), (256, 256)),
        "linaje-telequinesis": (svg_linaje_telequinesis(), (256, 256)),
        "linaje-velocista": (svg_linaje_velocista(), (256, 256)),
        "linaje-sombra-viva": (svg_linaje_sombra_viva(), (256, 256)),
        "linaje-sangre-abisal": (svg_linaje_sangre_abisal(), (256, 256)),
        "linaje-origen-estelar": (svg_linaje_origen_estelar(), (256, 256)),
        "linaje-herencia-olimpica": (svg_linaje_herencia_olimpica(), (256, 256)),
        "linaje-eclipse": (svg_linaje_eclipse(), (256, 256)),
    }
    for nombre, (svg, tam) in monocromos.items():
        tmp = HUD_LISTAS / f"_{nombre}_tmp.png"
        img = render_svg_transparente(svg, 512, 512, tmp)
        # Asegura blanco puro en los canales RGB para teñido exacto con ImageColor3 en Roblox
        _, _, _, a = img.split()
        blanco = Image.new("RGBA", img.size, (255, 255, 255, 0))
        blanco.putalpha(a)
        encajar(blanco, tam, margen=0.06, crop=True).save(HUD_LISTAS / f"{nombre}.png")
        tmp.unlink(missing_ok=True)
        print("listo vector hud:", nombre)


if __name__ == "__main__":
    main()
