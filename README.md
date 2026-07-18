# uach-thesis-skills

Skills basadas en la **pauta oficial de formato de redacción de tesis** de la Escuela de Ingeniería Civil en Informática (Facultad de Ciencias de la Ingeniería) de la Universidad Austral de Chile (UACh).

> Este repositorio **no es un producto oficial de la UACh**. Es una transcripción personal de la pauta institucional, pensada para asistir a estudiantes durante la redacción de su tesis con asistentes de IA.

## ¿Qué hace?

Cuando estas reglas están cargadas como contexto en un asistente de IA, este aplica automáticamente las reglas obligatorias de formato (márgenes, tipografía, interlineado, citas APA, estructura, numeración, etc.) al editar el documento de tesis.

## Skills incluidas

- **`thesis-format`** — Reglas obligatorias de formato del documento (papel, márgenes, tipografía, estructura, tablas/figuras, citas APA, anexos).

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
cp -r skills/thesis-format ~/.claude/skills/

# O a nivel de proyecto
cp -r skills/thesis-format .claude/skills/
```

### Opción 3: Otros asistentes (Cursor, Copilot, ChatGPT, etc.)

El contenido de `skills/thesis-format/SKILL.md` puede usarse directamente como:

- **Reglas de proyecto** (`.cursorrules`, `.github/copilot-instructions.md`, etc.)
- **System prompt** o **instrucciones personalizadas**
- **Contexto adjunto** en una conversación

Basta con copiar el cuerpo del archivo (después del frontmatter `---`) y pegarlo donde tu herramienta admita reglas o instrucciones.

### Opción 4: Lectura directa

El archivo también funciona como referencia en Markdown legible por humanos.

## Fuente

Las reglas provienen de la pauta de redacción de tesis publicada por la Escuela de Ingeniería Civil en Informática de la UACh. Ante cualquier discrepancia, **prevalece el documento oficial entregado por la escuela o el profesor patrocinante**.

## Licencia

MIT — ver [LICENSE](LICENSE).
