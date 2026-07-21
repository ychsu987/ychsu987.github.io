# Website reference

## Site architecture

```
ychsu987.github.io/
├── _quarto.yml              # Site-wide config
├── about.qmd                  # Home (about template)
├── cc.qmd                     # Common core courses hub
├── quant.qmd                  # Quantitative analysis hub
├── programming.qmd            # Scientific computing hub
├── hybridPBL.qmd              # Hybrid PBL hub
├── courses.qmd                # Legacy course list (not in navbar)
├── assets/
│   ├── css/                   # Shared stylesheets
│   └── images/                # Shared images (e.g. bio.jpeg)
├── _content/
│   └── modules/               # Reusable content modules (future)
├── courses/
│   ├── 2025/                  # Current teaching materials
│   │   ├── BIOF2014/
│   │   ├── BBMS1021/
│   │   ├── BBMS3009/
│   │   ├── BIOF3001/
│   │   ├── BIOF4002/
│   │   └── CCAI9007/
│   └── 2026/                  # Future courses
├── _extensions/r-wasm/live/   # Quarto Live (webr) extension
├── _freeze/                   # Frozen execution cache (mirrors course paths)
└── AILT9015/                  # Static HTML demos (resource only)
```

### Navbar structure (`_quarto.yml`)

| Menu item | Hub page | Courses |
|-----------|----------|---------|
| Home | `about.qmd` | — |
| Courses → Common core | `cc.qmd` | CCAI9007 |
| Courses → Hybrid PBL | `hybridPBL.qmd` | BIOF3001, BIOF4002 |
| Courses → Quantitative analysis | `quant.qmd` | BIOF2014, BBMS3009 |
| Courses → Scientific computing | `programming.qmd` | BBMS1021, AILT9015 |

## Course catalog

### Course code ↔ title mapping (used by `courses.qmd`)

| Course code | Course title (official) | Audience label on website* | Primary hub page |
|---|---|---|---|
| BBMS1021 | Introduction to AI and Biomedical Data Science | 大學部 | `programming.qmd` |
| BIOF4002 | Informatics Applications in Global Health | 碩士班 | `hybridPBL.qmd` |
| BIOF3001 | Big Data Biomedical Informatics | 碩士班 | `hybridPBL.qmd` |
| BIOF2014 | Statistical Modelling in Bioinformatics | 大學部 | `quant.qmd` |
| BBMS3009 | Genome Science | 碩士班 | `quant.qmd` |
| CCAI9007 | Hacking Aging: Partnering Human and Artificial Intelligence | 碩士班 | `cc.qmd` |

\*The audience label currently follows a simple inference rule based on the course number (1xxx/2xxx→大學部; 3xxx/4xxx/9xxx→碩士班). If you need a different mapping, update both this table and `courses.qmd`.

### BIOF2014 — Statistical Modelling in Bioinformatics

**Hub**: `quant.qmd`

| Type | Files | Format |
|------|-------|--------|
| Housekeeping | `0-Housekeeping.qmd` | revealjs |
| Lectures | `1-distribution.qmd` … `8-EM.qmd` | revealjs + scss themes |
| Sketches | `N-topic-sketch.qmd` | revealjs + chalkboard JSON |
| Tutorials | `N-Question sets-topic.qmd` | html (katex) or revealjs |
| Tutorial sketches | `N-Question sets-topic-sketch.qmd` | revealjs |

Shared assets: `courses/2025/BIOF2014/img/`, `courses/2025/BIOF2014/ref.bib`, `courses/2025/BIOF2014/general_style.scss`, `courses/2025/BIOF2014/student_view.scss`

Lecture YAML template:

```yaml
---
title: "Topic Title"
subtitle: "Optional subtitle"
author: Yu Cheng Hsu
title-slide-attributes:
    data-background-image: img/cover-image.jpg
    data-background-size: 35% 100%
    data-background-position: left
format:
  revealjs:
    theme: [default, student_view.scss, general_style.scss]
    slide-number: true
    reference-location: margin
    chalkboard: true
lightbox: true
---
```

Sketch variant adds chalkboard source:

```yaml
    chalkboard:
      src: compiled_pdf/chalkboard 2.json
```

Tutorial YAML template:

```yaml
---
title: "Question sets-Topic"
format:
  html:
    toc: true
    html-math-method: katex
    css: student_view.css
engine: knitr
bibliography: ref.bib
---
```

### BBMS1021 — Introduction to AI and Biomedical Data Science

**Hub**: `programming.qmd`

| Type | Path | Format |
|------|------|--------|
| ggplot2 lecture | `ggplot2_intro/introduction_to_ggplot2.qmd` | live-html + webr |
| Real case study | `Real_case/Real-example.qmd` | live-html + webr |
| Tutorials | `tutorial/tutorial_*.qmd` | live-html + webr |

Live-html YAML template:

```yaml
---
title: "Tutorial N"
format:
  live-html:
    toc: true
    toc-depth: 3
    toc-location: left
    self-contained: true
engine: knitr
author: "Yu Cheng Hsu, BBMS1021 teaching team"
date: "YYYY-MM-DD"
eval: false
lightbox: true
---
```

### BBMS3009 — Genome Science

**Hub**: `quant.qmd` (listing `3009lecture`)

- `courses/2025/BBMS3009/System biology.qmd` — revealjs with `student_view.scss`, chalkboard

### BIOF3001 — Big Data Biomedical Informatics

**Hub**: `hybridPBL.qmd`

- `courses/2025/BIOF3001/suicide-media-slides.qmd` — revealjs, `courses/2025/BIOF3001/style.scss`

### BIOF4002 — Informatics Applications in Global Health

**Hub**: `hybridPBL.qmd`

- `courses/2025/BIOF4002/Global health informatics.qmd`
- `courses/2025/BIOF4002/mHealth and telemedicine.qmd`
- Assets: `courses/2025/BIOF4002/ghealth.bib`, `courses/2025/BIOF4002/style.scss`

### CCAI9007 — Hacking Aging: Partnering Human and Artificial Intelligence

**Hub**: `cc.qmd`

| File | Notes |
|------|-------|
| `CCAI-aging clock.qmd` | revealjs, bibliography |
| `CCAI-health monitoring.qmd` | revealjs |
| `CCAI-workshop.qmd` | html worksheet (cosmo theme) |

### AILT9015

Referenced in `programming.qmd` as `AILT9015/index.html`. Listed as a static resource in `_quarto.yml` (`project.resources`). Not a standard `.qmd` — may be pre-built HTML or OJS content. Ensure files exist before listing.

## Hub page listing patterns

`quant.qmd` example — multiple named listings per course:

```yaml
---
title: Quantitative analysis
listing:
  - id: 2014lecture
    contents:
      - courses/2025/BIOF2014/0-Housekeeping.qmd
      - courses/2025/BIOF2014/1-distribution.qmd
    fields: [title, subtitle, image]
    type: default
    sort: false
---
```

Body placement:

```markdown
## BIOF2014 Statistical Modelling in Bioinformatics

### Blank notes

::: {#2014lecture}
:::
```

## Revealjs slide conventions

- Section headers use `#` (h1) for major parts, `##` for slides
- Dense slides: `## Title {.smaller}`
- Two-column layout: `::::{.columns}` / `:::{.column width=50%}`
- Solution hiding: `:::{.hide}` around math and answers
- Callouts: `::: {.callout-tip}` / `::: {.callout-note}`
- Images: `![caption](img/file.png){.lightbox}` or `{.preview-images width=100}`

## Quarto extensions

### r-wasm/live (Quarto Live)

Installed at `_extensions/r-wasm/live/`. Provides:

- `live-html` output format
- `{webr}` knitr engine for in-browser R via WebR
- Optional `{pyodide}` for Python (templates in extension)

Subfolders (`courses/2025/BBMS1021/tutorial/_extensions/`, etc.) contain local copies. When updating the extension, update the root copy; subfolder copies may lag.

### shinylive

Present in `_extensions/quarto-ext/shinylive/` but not widely used in current content.

## Deployment details

| Branch | Contents | Purpose |
|--------|----------|---------|
| `main` | Source files | Development |
| `gh-pages` | Rendered `_site/` | GitHub Pages hosting |

Repository: `https://github.com/ychsu987/ychsu987.github.io.git`

GitHub Pages serves from the `gh-pages` branch for user sites (`username.github.io`).

The `docs/` folder at repo root contains **stale** partial renders — not the active publish target.

## Source vs published: file inventory

### How publishing works

```
main branch                          gh-pages branch
─────────────                        ───────────────
.qmd  ──┐
_quarto.yml ──┤
_extensions/ ─┤── quarto render ──►  _site/ contents ──► GitHub Pages
_freeze/ ──┤     (or publish)         (HTML, JS, CSS,
img/, data/ ─┘                        copied assets)
```

### Keep on `main` only

| Category | Examples | Count (approx.) |
|----------|----------|-----------------|
| Quarto sources | `about.qmd`, `courses/2025/BIOF2014/8-EM.qmd` | ~51 `.qmd` |
| Site config | `_quarto.yml` | 1 |
| Root extensions | `_extensions/r-wasm/live/` | 1 copy |
| Frozen execution | `_freeze/courses/2025/BIOF2014/.../execute-results/` | ~251 files |
| Course assets | `courses/2025/BIOF2014/img/`, `*.bib`, `*.scss`, `data/*.csv` | varies |

### Exclude from `main` (generated / local)

| Category | Pattern | Regenerated by | Legacy tracked? |
|----------|---------|----------------|-----------------|
| Full site build | `_site/` | `quarto render` | Yes (~308 files) — should untrack |
| Quarto project cache | `.quarto/` | preview/render | Yes (~33 files) — should untrack |
| Document render dirs | `**/*_files/` | per-file render | Yes (~376 files) — should untrack |
| Stale HTML folder | `docs/` | old workflow | Yes (~22 files) — should untrack |
| OS metadata | `.DS_Store` | Finder | Yes (~14 files) — should untrack |
| Notebook sidecars | `**/*.quarto_ipynb` | Quarto | Gitignored |
| Editor config | `.cursor/` (except skills) | Cursor | Not tracked |

#### What `*_files/` contains (all safe to drop from git)

- `figure-html/`, `figure-revealjs/` — chunk plot output
- `libs/revealjs/` — reveal.js plugin copies per slide deck
- `libs/quarto-html/`, `libs/quarto-contrib/` — HTML dependencies
- These are re-created next to the source `.qmd` and copied into `_site/` during a full render

#### Duplicate extensions (consolidate over time)

Nested copies exist under `courses/2025/BBMS1021/Real_case/_extensions/`, `courses/2025/BBMS1021/tutorial/_extensions/`, `courses/2025/BBMS1021/ggplot2_intro/_extensions/`. They duplicate the root `_extensions/r-wasm/live/`. Only the root copy needs to be maintained; subfolder copies can be deleted once documents render without them.

### Published on `gh-pages` only

Everything under `_site/` after `quarto render`:

| Content | Example paths on gh-pages |
|---------|---------------------------|
| Hub pages | `about.html`, `quant.html`, `programming.html` |
| Course pages | `courses/2025/BIOF2014/8-EM.html`, `courses/2025/BBMS1021/tutorial/tutorial_1.html` |
| Site libraries | `site_libs/bootstrap/`, `site_libs/quarto-contrib/live-runtime/` |
| Search index | `search.json` |
| Copied static assets | images, CSVs, bib files referenced by pages |

### Special case: `_freeze/`

| Branch | Include `_freeze/`? | Reason |
|--------|---------------------|--------|
| `main` | **Yes** | Speeds renders; shares computed output across machines |
| `gh-pages` | **No** | Build artifact for source repo only; output is baked into HTML |

When chunk code or inputs change, refresh with `quarto render --cache-refresh` and commit updated `_freeze/` files on `main`.

### Recommended `.gitignore`

```gitignore
# Quarto build output
/_site/
/.quarto/
**/*.quarto_ipynb

# Per-document render artifacts
**/*_files/

# Legacy output (not used; gh-pages is the publish target)
/docs/

# OS and editor
.DS_Store
Thumbs.db
.cursor/
```

### Cleanup legacy tracked artifacts

If the user wants a cleaner `main` branch, untrack (not delete locally) with:

```bash
git rm -r --cached _site/ .quarto/ docs/
git ls-files -z "*_files*" | xargs -0 git rm -r --cached
find . -name .DS_Store -print0 | xargs -0 git rm --cached
```

Then commit the `.gitignore` update and cleanup. Re-render with `quarto render` to regenerate ignored artifacts locally.

## Naming conventions

| Pattern | Meaning |
|---------|---------|
| `N-topic.qmd` | Numbered lecture (N = week/session) |
| `N-topic_sketch.qmd` or `N-topic-sketch.qmd` | In-class annotated version (mirror the lecture filename) |

Prefer the hyphen form (`-sketch`). All BIOF2014 sketches now use `-sketch`.
