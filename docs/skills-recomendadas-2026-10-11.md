# Skills para hacer juegos en Roblox (revisión 2026-10-11)

Búsqueda en el directorio de plugins de Anthropic, marketplaces de la comunidad y GitHub.
Criterio: que sirvan para el setup real de Juan (Claude Code en su PC + Rojo + MCP oficial de Studio + git, juegos Pisada Sonora y Mutant Lab) sin pisar su GUIA-PARA-CLAUDE.md.

## Regla importante
Cualquier skill que se instale es conocimiento de apoyo. Si una skill dice algo distinto a GUIA-PARA-CLAUDE.md
(nombres en inglés tipo Services/Controllers, Knit, sacar el código de git, migrar a Script Sync), **gana la GUIA**.
Conviene agregar esa línea al CLAUDE.md de fabrica-roblox al instalar.

## Recomendadas

### 1. roblox-dev (Directorio de Anthropic) ⭐ la primera a instalar
- Dónde: directorio de plugins de claude.ai / Claude Code (autor comunitario "Ivar", revisado por el directorio).
- Trae: skills de seguridad de remotes, DataStores seguros, tipado estricto, rendimiento, arquitectura, UI, testing, un comando de revisión y un agente "roblox-reviewer".
- Por qué: es la más fácil de instalar y la única con revisión del directorio. Ataca justo los riesgos abiertos (guardado de Pisada Sonora sin autosave, falta de session locking, remotes explotables).
- Ojo: no usar sus comandos de "setup" ni "new-system" para armar estructura nueva; sus proyectos ya tienen estructura.

### 2. awesome-gamedev-agent-skills (gamedev-skills, GitHub)
- https://github.com/gamedev-skills/awesome-gamedev-agent-skills · ~1.4k estrellas · licencia Apache-2.0.
- Trae 74 skills; las útiles para él: roblox-luau, roblox-datastores, roblox-ui, roblox-networking, roblox-characters, roblox-physics, roblox-studio-workflow, más game-feel, level-design y game-ui-ux.
- Por qué: la más popular y mantenida; las de diseño (game-feel, level-design) suman algo que el plugin 1 no tiene.
- Ojo: instalar solo el paquete de Roblox y esas tres de diseño, no las 74 (las de Godot/Unity solo meten ruido).

### 3. roblox-game-skill (brockmartin, GitHub) — opcional
- https://github.com/brockmartin/roblox-game-skill · ~163 estrellas · sin licencia visible.
- Trae plantillas por género (simulator, tycoon, obby, RPG, horror, battle royale) y checklists de publicación y monetización.
- Por qué: útil cuando arranque un juego nuevo o vaya a publicar.
- Ojo: sugiere un MCP de terceros (boshyxd/robloxstudio-mcp); no instalarlo, él ya usa el oficial de Roblox.

## Descartadas
- AshExplained/roblox-skills (40 skills): 0 estrellas y asume que el código vive solo en Studio, fuera de git; choca con su Rojo + git.
- simplethinks99-hash/roblox-skills: copia de la anterior con otro dueño; desconfiar.
- MSayib/roblox-dev-skill: buen contenido sobre el MCP de Studio, pero 3 estrellas, 3 commits y se "auto-actualiza" bajándose cosas de internet.
- CellCog (directorio): genera assets con un servicio externo; no hace falta mientras use Blender + generación de Roblox.
- gogolumo/rbsmithy y x-Yami-Sukehiro-x/roblox-luau-expert-skill: sin señales de uso; no aportan sobre las de arriba.

## Fuentes
- Directorio de plugins de Anthropic (búsqueda "roblox", "game development").
- https://github.com/gamedev-skills/awesome-gamedev-agent-skills
- https://github.com/brockmartin/roblox-game-skill
- https://github.com/AshExplained/roblox-skills
- https://github.com/MSayib/roblox-dev-skill
- https://claudemarketplaces.com/skills/category/game-dev
