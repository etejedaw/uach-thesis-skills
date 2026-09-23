#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: bash build.sh [archivo.tex] [--out <dir>] [--engine xelatex|lualatex|pdflatex] [--clean]

Compila un documento LaTeX a PDF dentro de un contenedor Docker con TeX Live.

  archivo.tex   Archivo principal. Si se omite, se busca en docs/ el único .tex con \documentclass.
  --out <dir>   Carpeta donde queda el PDF (por defecto: tmp). Los intermedios van en <dir>/aux.
  --engine      Motor de compilación (por defecto: xelatex).
  --clean       Borra el PDF y los intermedios antes de compilar.
  -h, --help    Muestra esta ayuda.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

tex=""
out="tmp"
engine="xelatex"
clean=0

while [ $# -gt 0 ]; do
  case "$1" in
    --out) [ $# -ge 2 ] || die "--out requiere una carpeta"; out=$2; shift 2 ;;
    --out=*) out=${1#*=}; shift ;;
    --engine) [ $# -ge 2 ] || die "--engine requiere un valor"; engine=$2; shift 2 ;;
    --engine=*) engine=${1#*=}; shift ;;
    --clean) clean=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) usage >&2; die "opción desconocida: $1" ;;
    *) [ -z "$tex" ] || die "solo se admite un archivo .tex"; tex=$1; shift ;;
  esac
done

case "$engine" in
  xelatex|lualatex) latexmk_engine=$engine ;;
  pdflatex) latexmk_engine=pdf ;;
  *) die "motor no soportado: $engine (usa xelatex, lualatex o pdflatex)" ;;
esac

if [ -z "$tex" ]; then
  [ -d docs ] || die "no se indicó un archivo .tex y no existe la carpeta docs/"
  candidates=()
  while IFS= read -r file; do
    candidates+=("$file")
  done < <(grep -rl --include='*.tex' '^[[:space:]]*\\documentclass' docs 2>/dev/null || true)
  case ${#candidates[@]} in
    0) die "no se encontró ningún .tex con \\documentclass en docs/" ;;
    1) tex=${candidates[0]} ;;
    *) printf '  %s\n' "${candidates[@]}" >&2; die "hay varios .tex principales en docs/, indica cuál compilar" ;;
  esac
fi

[ -f "$tex" ] || die "no existe el archivo $tex"
case "$tex" in
  *.tex) ;;
  *) die "$tex no es un archivo .tex" ;;
esac

command -v docker >/dev/null 2>&1 || die "Docker no está instalado o no está en el PATH"
docker compose version >/dev/null 2>&1 || die "se requiere Docker Compose v2 (docker compose)"

mkdir -p "$out"

src_dir=$(cd "$(dirname "$tex")" && pwd)
out_dir=$(cd "$out" && pwd)
main=$(basename "$tex")
name=${main%.tex}

export THESIS_SRC=$src_dir
export THESIS_OUT=$out_dir
export THESIS_MAIN=$main
export LATEX_ENGINE=$latexmk_engine
LATEX_UID=$(id -u)
LATEX_GID=$(id -g)
export LATEX_UID LATEX_GID

compose=(docker compose -f "$script_dir/docker-compose.yml")

if [ "$clean" -eq 1 ]; then
  "${compose[@]}" run --rm latex latexmk -C -auxdir=/out/aux -outdir=/out "$main"
fi

if "${compose[@]}" run --rm latex; then
  echo "PDF generado: $out_dir/$name.pdf"
else
  log="$out_dir/aux/$name.log"
  echo >&2
  echo "La compilación falló. Log completo: $log" >&2
  if [ -f "$log" ]; then
    echo "Errores:" >&2
    grep -n -A3 -E '^!|^[^ ]+:[0-9]+: ' "$log" | head -40 >&2 || tail -n 40 "$log" >&2
  fi
  exit 1
fi
