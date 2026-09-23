---
name: thesis-build
description: Compila una tesis LaTeX (.tex) a PDF dentro de un contenedor Docker con TeX Live, sin instalar LaTeX en la maquina. Usar cuando se pida compilar la tesis, generar o actualizar el PDF, o verificar que un cambio en el .tex compila.
---

# Compilar tesis LaTeX a PDF

La compilacion corre en un contenedor Docker con TeX Live 2026 completo, fijado por digest en `docker-compose.yml`. `latexmk` decide cuantas pasadas de LaTeX y `biber`/`bibtex` hacen falta, por lo que basta con un solo comando por compilacion.

## Requisitos

- Docker con Compose v2 (`docker compose version` debe responder).
- La primera ejecucion descarga la imagen de TeX Live (~5,6 GB) y puede tardar varios minutos. Avisar al usuario antes y usar un timeout amplio.

## Uso

Ejecutar desde la raiz del proyecto del usuario, invocando el script de esta skill con `bash` (no depender del permiso de ejecucion):

```bash
bash <directorio-de-esta-skill>/build.sh [archivo.tex] [--out <dir>] [--engine xelatex|lualatex|pdflatex] [--clean]
```

| Parametro     | Por defecto                                   | Descripcion                                              |
| ------------- | --------------------------------------------- | -------------------------------------------------------- |
| `archivo.tex` | El unico `.tex` con `\documentclass` en docs/ | Archivo principal de la tesis                            |
| `--out <dir>` | `tmp`                                         | Carpeta del PDF; los intermedios quedan en `<dir>/aux`   |
| `--engine`    | `xelatex`                                     | Motor de compilacion                                     |
| `--clean`     | desactivado                                   | Borra PDF e intermedios antes de compilar                |

Si el usuario indica una carpeta de salida, pasarla con `--out`. Si hay varios `.tex` principales en `docs/`, el script los lista y se detiene: preguntar cual compilar.

## Antes de compilar

- Verificar que la carpeta de salida este en `.gitignore` del proyecto. Si no lo esta, proponer agregarla (los intermedios no deben versionarse).
- Todo lo que el `.tex` use (capitulos con `\input`, `.bib`, imagenes) debe estar dentro de la carpeta del archivo principal o en subcarpetas: solo esa carpeta se monta en el contenedor. Rutas como `../img/figura.png` no funcionan.

## Si la compilacion falla

El script muestra las lineas de error del log y la ruta del log completo (`<out>/aux/<nombre>.log`). Leer el error, corregir el `.tex` y volver a compilar. Casos frecuentes:

- **Fuente no encontrada** (`The font "Times New Roman" cannot be found`): Times New Roman es propietaria y no viene en TeX Live. Usar TeX Gyre Termes, metricamente identica, como respaldo:

  ```latex
  \usepackage{fontspec}
  \IfFontExistsTF{Times New Roman}
    {\setmainfont{Times New Roman}}
    {\setmainfont{TeX Gyre Termes}}
  ```

- **Indice, referencias o numeracion inconsistentes** tras un cambio grande: recompilar con `--clean`.
- **Archivo no encontrado**: revisar que este dentro de la carpeta del `.tex` principal (ver "Antes de compilar").
- **Paquetes de pdflatex** (`inputenc`, `fontenc`) con xelatex: normalmente funcionan; si no, compilar con `--engine pdflatex`.

## Uso sin el script

El `docker-compose.yml` tambien puede usarse directamente (por ejemplo en Windows sin WSL), pasando las rutas como variables de entorno:

```bash
mkdir -p tmp
THESIS_SRC=./docs THESIS_OUT=./tmp THESIS_MAIN=tesis.tex \
  docker compose -f <directorio-de-esta-skill>/docker-compose.yml --project-directory . run --rm latex
```

`--project-directory .` hace que las rutas relativas se resuelvan desde el proyecto y no desde la carpeta de la skill. La carpeta de salida debe existir antes (`mkdir -p`): si no, Docker la crea como `root` y la compilacion falla con `Permission denied`. En Linux, agregar `LATEX_UID=$(id -u) LATEX_GID=$(id -g)` para que los archivos generados no queden con otro dueno.
