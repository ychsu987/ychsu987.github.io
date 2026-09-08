# ychsu987.github.io

Personal teaching site for Yu Cheng Hsu (HKU). Quarto website on GitHub Pages:

**https://ychsu987.github.io**

- `main` — source (`.qmd`, assets, `_content`, `_freeze`)
- `gh-pages` — rendered site only (`quarto publish gh-pages`)

This README is the author / maintenance guide. Match an existing file in the same course before inventing a new pattern.

---

## File structure

```text
ychsu987.github.io/
├── README.md                 # this guide
├── _quarto.yml               # navbar, freeze, post-render cleanup
├── about.qmd, cc.qmd, quant.qmd, programming.qmd, hybridPBL.qmd, courses.qmd
├── assets/
│   ├── css/                  # shared revealjs styles (general_style.css, student_view.css)
│   ├── images/               # shared figures (prefer this for 2026+ lectures)
│   └── data/                 # CSVs used in live / knitr chunks
├── _content/modules/         # reusable slide bodies (no YAML)
│   ├── bdata/                # R / tidyverse / epi
│   ├── methods/              # ODE, LR, EHR
│   ├── application/          # enrichment, RStudio
│   └── case/                 # ADT case material
├── courses/{YEAR}/{CODE}/    # one folder per offering
│   ├── index.qmd             # course card table (Blank / Sketch / Full)
│   ├── topic.qmd             # website lecture (YAML + class info + includes)
│   ├── topic-sketch.qmd      # in-class annotated copy
│   └── topic-full.qmd        # website “solutions” copy (optional; no student_view.css)
├── scripts/
│   ├── flatten_qmd.py        # student -full / -worksheet packs
│   └── cleanup-render-artifacts.ts
├── _extensions/              # Quarto Live (webr), etc.
├── _freeze/                  # commit this (execution cache)
├── _student/                 # generated packs — gitignored, not published
├── _site/                    # render output — gitignored
└── AILT9015/                 # static resource (listed in _quarto.yml)
```

Do not edit `_site/`, `.quarto/`, or leftover `*_files/` folders. They are rebuild artifacts.

---

## Naming conventions

| Pattern | Role | Published? |
|---------|------|------------|
| `topic.qmd` | Blank / student-facing website lecture | Yes |
| `topic-sketch.qmd` | In-class annotated slides (`chalkboard: src: …`) | Yes |
| `topic-full.qmd` | Website solutions deck (same includes; often **no** `student_view.css`) | Yes, if you add it |
| `_student/.../topic-full.qmd` | **Generated** standalone notes for students | No |
| `_student/.../topic-worksheet.qmd` | **Generated** fill-in worksheet | No |
| `index.qmd` | Course index table | Yes |
| `N-topic.qmd` | Older BIOF2014 numbered lectures | Yes |

Prefer hyphens: `adt-model-sketch.qmd`, not `adt-model_sketch.qmd`.

**Do not put generated `-full.qmd` / `-worksheet.qmd` next to the lecture.** `adt-model-full.qmd` is already a real website file. Flattened copies always go under `_student/` so Quarto will not publish them and they will not overwrite lectures.

Course index table (`courses/2026/{CODE}/index.qmd`):

| Column | Link to |
|--------|---------|
| Slides / Blank | `topic.qmd` |
| Annotated | `topic-sketch.qmd` or `—` |
| Solution (when used) | `topic-full.qmd` |

---

## Authoring a lecture (2026 pattern)

A website lecture is three parts, in order:

1. **YAML** — title slide (title, subtitle, background, revealjs theme)
2. **Class info** — ILOs, about me, AI policy, checkpoints (local to that course)
3. **Shared body** — `{{< include /_content/modules/... >}}`

Example (`courses/2026/SBMS7202/introR.qmd`):

```markdown
---
title: "Introduction to R"
subtitle: Ecosystem, Variables, and Operations
author: Yu Cheng Hsu
title-slide-attributes:
    data-background: /assets/images/IntroR/background-1.png
    data-background-size: 40% 100%
    data-background-position: right
format:
    revealjs:
        theme: [default, ../../../assets/css/general_style.css]
        slide-number: true
        smaller: true
        chalkboard:
            theme: whiteboard
            src: None
---

## About me {.smaller}
...

{{< include /_content/modules/bdata/reco.qmd >}}
{{< include /_content/modules/bdata/introR.qmd >}}
```

### Shared modules (`_content/modules/`)

- No YAML front matter
- No nested includes
- Paths starting with `/` are repo-root (`/assets/images/...`, `/_content/...`)
- Edit the module **once**; every lecture that includes it picks up the change
- After editing a module, re-run `flatten_qmd.py` if you already generated student copies

Put reusable teaching content in `_content`. Put course-specific wrapping (title, ILOs, policy) in `courses/{YEAR}/{CODE}/`.

### Images and data

| Use | Path |
|-----|------|
| 2026+ shared figures | `/assets/images/{topic}/file.png` |
| 2026+ data for `read.csv` | `../../../assets/data/{topic}/file.csv` from `courses/2026/CODE/` |
| Older course-local figures | `img/file.png` next to that course |

On the website, `/assets/...` works. In a **standalone** student `.qmd`, those local paths would break — `flatten_qmd.py` rewrites them to `https://ychsu987.github.io/assets/...`.

### Slides and answers

- `#` = section, `##` = slide; dense slides: `## Title {.smaller}`
- Hide worked answers on blank slides: `:::{.hide}` plus `student_view.css` in the theme
- Website `-full.qmd` (solutions) usually **omits** `student_view.css` so answers are visible
- Author: `Yu Cheng Hsu` (tutorials may use a teaching-team line)
- Put **Intended learning outcomes** near the start

---

## Student packs (important)

Students should not open the website lecture with `{{< include >}}` unless they have this whole repo. Generate a standalone copy:

```bash
# from the repository root
python scripts/flatten_qmd.py courses/2026/SBMS7202/introR.qmd --mode worksheet
python scripts/flatten_qmd.py courses/2026/SBMS7202/introR.qmd --mode full
python scripts/flatten_qmd.py courses/2026/SBMS7202/introR.qmd --mode both
```

| Mode | Output under `_student/` | What it does |
|------|--------------------------|--------------|
| `worksheet` | `{stem}-worksheet.qmd` | Inlines includes; HTTPS image/data URLs; strips executable `{r}`/`{python}`/`{webr}`/`{dot}` code (**keeps `#` comments**); blanks display `$$` math; keeps inline `$g$` |
| `full` | `{stem}-full.qmd` | Inlines includes; HTTPS URLs; code and formulas kept |

Example output:

```text
_student/courses/2026/SBMS7202/introR-worksheet.qmd
_student/courses/2026/SBMS7202/introR-full.qmd
```

- Zip `_student/...` (or the single `.qmd`) to distribute. That folder is gitignored.
- Re-run the script after you change `_content` or the lecture. Do not edit generated files by hand.
- Several files: pass every lecture path on one command.
- If a website file already uses `-full` (BIOF3001 `adt-model-full.qmd`), flattening `adt-model.qmd` still writes to `_student/.../adt-model-full.qmd` — it will not overwrite the lecture.

---

## Add a course or lecture

1. Folder: `courses/{YEAR}/{CODE}/` (e.g. `courses/2026/SBMS7202/`).
2. Lecture `.qmd` using the YAML + class-info + include pattern.
3. Optional `topic-sketch.qmd` / website `topic-full.qmd`.
4. Register the file in `index.qmd` and, if needed, the hub listing (`quant.qmd`, `programming.qmd`, …).
5. Navbar: edit `_quarto.yml` only for a new top-level menu item.
6. `quarto render path/to/file.qmd` and check the hub page.

Hub listing pattern:

```yaml
listing:
  - id: my-list
    contents:
      - courses/2026/SBMS7202/introR.qmd
    fields: [title]
    sort: false
```

```markdown
::: {#my-list}
:::
```

---

## Build and publish

Needs Quarto ≥ 1.4 and R (knitr / webr documents).

```bash
quarto preview                          # local live preview
quarto render                           # whole site
quarto render courses/2026/SBMS7202/introR.qmd
quarto publish gh-pages                 # push _site/ to GitHub Pages
```

After every render/publish, `scripts/cleanup-render-artifacts.ts` (wired as `project.post-render` in `_quarto.yml`) deletes leftover `*_files/` next to sources, `.quarto_ipynb` files, and `_site/_freeze`. Leave that hook in place.

`execute: freeze: auto` caches chunk output in `_freeze/`. **Commit `_freeze/`** when code or figures change. Refresh with:

```bash
quarto render --cache-refresh
quarto render path/to/file.qmd --cache-refresh
```

---

## What to commit on `main`

| Commit | Do not commit |
|--------|----------------|
| `.qmd`, `_quarto.yml`, `README.md` | `_site/`, `.quarto/` |
| `_content/`, `assets/`, course `img/` / data / `.scss` | `**/*_files/`, `*.quarto_ipynb` |
| Root `_extensions/` | `_student/` (regenerate with the script) |
| `_freeze/` when execution output changed | `docs/` (legacy), `.DS_Store` |

GitHub Pages serves **`gh-pages` only**. Nothing on `main` is the live site except through publish.

---

## Course map (hub pages)

| Navbar | Hub file | Courses |
|--------|----------|---------|
| Home | `about.qmd` | — |
| Common core | `cc.qmd` | CCAI9007 |
| Hybrid PBL | `hybridPBL.qmd` | BIOF3001, BIOF4002 |
| Quantitative analysis | `quant.qmd` | BIOF2014, BBMS3009 |
| Scientific computing | `programming.qmd` | BBMS1021, AILT9015 |
| Course overview | `courses.qmd` | cards → `courses/2026/{CODE}/index.qmd` |

Per-course YAML templates and 2025 file lists: [`.cursor/skills/maintain-website/reference.md`](.cursor/skills/maintain-website/reference.md).
