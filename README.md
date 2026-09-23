# uach-thesis-skills

Skills basadas en la **pauta oficial de formato de redacción de tesis** de la Escuela de Ingeniería Civil en Informática (Facultad de Ciencias de la Ingeniería) de la Universidad Austral de Chile (UACh).

> Este repositorio **no es un producto oficial de la UACh**. Es una transcripción personal de la pauta institucional, pensada para asistir a estudiantes durante la redacción de su tesis con asistentes de IA.

## ¿Qué hace?

Cuando estas reglas están cargadas como contexto en un asistente de IA, este aplica automáticamente las reglas obligatorias de formato (márgenes, tipografía, interlineado, citas APA, estructura, numeración, etc.) al editar el documento de tesis. Además, el asistente puede compilar la tesis LaTeX a PDF dentro de un contenedor Docker, sin instalar LaTeX en la máquina.

## Skills incluidas

- **`thesis-format`** — Reglas obligatorias de formato del documento (papel, márgenes, tipografía, estructura, tablas/figuras, citas APA, anexos).
- **`thesis-build`** — Compila la tesis `.tex` a PDF con TeX Live en Docker. Incluye un `docker-compose.yml` y un script `build.sh` que también se pueden usar sin asistente (ver [Compilar la tesis a PDF](#compilar-la-tesis-a-pdf)).

Cada skill es un archivo `SKILL.md` con frontmatter (`name`, `description`) seguido del contenido en Markdown. Este formato es compatible con [Claude Code Agent Skills](https://docs.claude.com/en/docs/claude-code/skills), pero el contenido puede usarse con cualquier asistente que acepte reglas en texto plano.

## Instalación

### Opción 1: skills.sh (recomendada)

Instala con el [CLI de skills.sh](https://skills.sh):

```bash
npx skills add etejedaw/uach-thesis-skills
```

### Opción 2: Claude Code (manual)

Copia la carpeta de la skill al directorio correspondiente:

```bash
# A nivel de usuario
cp -r skills/thesis-format skills/thesis-build ~/.claude/skills/

# O a nivel de proyecto
cp -r skills/thesis-format skills/thesis-build .claude/skills/
```

### Opción 3: Otros asistentes (Cursor, Copilot, ChatGPT, etc.)

El contenido de `skills/thesis-format/SKILL.md` puede usarse directamente como:

- **Reglas de proyecto** (`.cursorrules`, `.github/copilot-instructions.md`, etc.)
- **System prompt** o **instrucciones personalizadas**
- **Contexto adjunto** en una conversación

Basta con copiar el cuerpo del archivo (después del frontmatter `---`) y pegarlo donde tu herramienta admita reglas o instrucciones.

### Opción 4: Lectura directa

El archivo también funciona como referencia en Markdown legible por humanos.

## Compilar la tesis a PDF

`thesis-build` compila el documento con TeX Live 2026 completo dentro de Docker. Solo requiere Docker con Compose v2. La imagen está fijada por digest para que la tesis compile igual durante todo su desarrollo, y funciona en amd64 y arm64 (Mac con Apple Silicon). La primera ejecución descarga la imagen (~5,6 GB) y tarda unos minutos.

Con un asistente basta con pedirle que compile la tesis. Sin asistente, desde la raíz del proyecto de tesis:

```bash
bash <ruta-a-la-skill>/thesis-build/build.sh [archivo.tex] [--out <dir>] [--engine xelatex|lualatex|pdflatex] [--clean]
```

- Sin `archivo.tex`, usa el único `.tex` con `\documentclass` dentro de `docs/`.
- El PDF queda en `tmp/` (o en la carpeta indicada con `--out`) y los intermedios en `<dir>/aux/`. Conviene agregar esa carpeta al `.gitignore`.
- El motor por defecto es `xelatex`, necesario para usar fuentes del sistema con `fontspec`.
- `--clean` borra el PDF y los intermedios antes de compilar; útil si el índice o las referencias quedan inconsistentes.
- Todo lo que use el `.tex` (capítulos, `.bib`, imágenes) debe estar en la carpeta del archivo principal o en sus subcarpetas, porque solo esa carpeta se monta en el contenedor.

Si prefieres no usar el script (por ejemplo en Windows sin WSL), el `docker-compose.yml` recibe las rutas por variables de entorno. La carpeta de salida debe existir antes de ejecutarlo; si no, Docker la crea como `root` y la compilación falla:

```bash
mkdir -p tmp
THESIS_SRC=./docs THESIS_OUT=./tmp THESIS_MAIN=tesis.tex docker compose -f <ruta-a-la-skill>/thesis-build/docker-compose.yml --project-directory . run --rm latex
```

Times New Roman, la fuente que exige la pauta, es propietaria y no viene en TeX Live. Para que la tesis compile tanto en Docker como en una máquina que sí la tenga, usa TeX Gyre Termes (métricamente idéntica) como respaldo:

```latex
\usepackage{fontspec}
\IfFontExistsTF{Times New Roman}
  {\setmainfont{Times New Roman}}
  {\setmainfont{TeX Gyre Termes}}
```

## Fuente

Las reglas provienen de la pauta de redacción de tesis publicada por la Escuela de Ingeniería Civil en Informática de la UACh. Ante cualquier discrepancia, **prevalece el documento oficial entregado por la escuela o el profesor patrocinante**.

## Licencia

MIT — ver [LICENSE](LICENSE).
