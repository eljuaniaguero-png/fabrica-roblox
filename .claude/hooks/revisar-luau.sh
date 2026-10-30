#!/usr/bin/env bash
# Hook PostToolUse (Edit|Write): cada vez que Claude guarda un .luau, lo ordena con StyLua
# y lo revisa con Selene. Si Selene marca algo, sale con código 2 para que Claude lo vea y lo arregle.
entrada=$(cat)
archivo=$(printf '%s' "$entrada" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//; s/\\\\/\\/g')
case "$archivo" in
*.luau) ;;
*) exit 0 ;;
esac
[ -f "$archivo" ] || exit 0

# StyLua y Selene leen su configuración de la carpeta donde corren: Mutant Lab y Forja Rápida
# tienen la suya. (Si StyLua corre en otra carpeta, usa el ancho de línea por defecto y
# desordena el código.)
raiz="${CLAUDE_PROJECT_DIR:-.}"
case "$archivo" in
*mutant-lab*) raiz="$raiz/archivo/mutant-lab" ;;
*forja-rapida*) raiz="$raiz/archivo/forja-rapida" ;;
esac
(cd "$raiz" && stylua "$archivo") 2>&1 >/dev/null

salida=$(cd "$raiz" && selene --display-style quiet "$archivo" 2>&1)
if [ $? -ne 0 ]; then
	printf 'Selene encontró problemas en %s:\n%s\n' "$archivo" "$salida" >&2
	exit 2
fi
exit 0
